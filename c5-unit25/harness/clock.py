#!/usr/bin/env python3
"""clock.py PORT TOKENFILE OUT TOUCH RESTARTS -- COMMAND...: an external clock for a cold start and for DevTools' restarts.
It forks COMMAND (standard output and standard error to OUT) and asks http://127.0.0.1:PORT/kitchen until the first answer with
status 200: the cold start, from the fork to that answer. Then, RESTARTS times: it waits until /actuator/health/readiness answers
200 (DevTools watches the class path from then on), changes the time of the file TOUCH (as `touch` does), and tries a TCP
connection to the port every 5 ms until one is refused - the old context has closed TiffinBox's server: "noticing", from the
change to that moment - then asks /kitchen until the first 200 again: the restart, from the closed port to that answer. Last, POST
/shutdown with the X-Shutdown-Token header read from TOKENFILE, and the process's exit code once it has gone. One line on
standard output:
    cold 1.083 · noticing 1.204 restart 0.151 · noticing 0.998 restart 0.143 · exit 1
or a line that says what never came. Never the log's own "Started ... in" line: this clock is outside the process."""
import http.client, os, socket, subprocess, sys, time

def get(port, path):
    try:
        c = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
        c.request("GET", path); r = c.getresponse(); r.read(); c.close()
        return r.status
    except (ConnectionRefusedError, ConnectionResetError, http.client.RemoteDisconnected, socket.timeout, OSError):
        return None

def until(p, t0, limit, cond, step):
    while time.monotonic() - t0 < limit:
        if p.poll() is not None:
            return None
        if cond():
            return time.monotonic()
        time.sleep(step)
    return None

def refused(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.settimeout(1)
    try:
        s.connect(("127.0.0.1", port)); return False
    except ConnectionRefusedError:
        return True
    except OSError:
        return False
    finally:
        s.close()

def main():
    port, tokenfile, out, touch, restarts = int(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4], int(sys.argv[5])
    assert sys.argv[6] == "--", "usage: clock.py PORT TOKENFILE OUT TOUCH RESTARTS -- COMMAND..."
    cmd = sys.argv[7:]
    parts = []
    with open(out, "wb") as o:
        t0 = time.monotonic()
        p = subprocess.Popen(cmd, stdout=o, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL)
        try:
            t = until(p, t0, 60, lambda: get(port, "/kitchen") == 200, 0.002)
            if t is None:
                print("no first 200 · " + ("exited %d" % p.returncode if p.poll() is not None else "60 s ran out")); return
            parts.append("cold %.3f" % (t - t0))
            for _ in range(restarts):
                s = time.monotonic()
                if until(p, s, 60, lambda: get(port, "/actuator/health/readiness") == 200, 0.01) is None:
                    print(" · ".join(parts + ["readiness never answered 200"])); return
                tt = time.monotonic(); os.utime(touch, None)
                tc = until(p, tt, 30, lambda: refused(port), 0.005)
                if tc is None:
                    print(" · ".join(parts + ["the port never closed within 30 s of the change"])); return
                t2 = until(p, tc, 60, lambda: get(port, "/kitchen") == 200, 0.002)
                if t2 is None:
                    print(" · ".join(parts + ["no 200 after the restart"])); return
                parts.append("noticing %.3f restart %.3f" % (tc - tt, t2 - tc))
            if until(p, time.monotonic(), 60, lambda: get(port, "/actuator/health/readiness") == 200, 0.01) is None:
                print(" · ".join(parts + ["readiness never answered 200"])); return
            token = open(tokenfile).read().strip()
            c = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
            c.request("POST", "/shutdown", headers={"X-Shutdown-Token": token})
            r = c.getresponse(); r.read(); c.close(); token = None
            try:
                code = p.wait(timeout=15)
            except subprocess.TimeoutExpired:
                p.kill(); p.wait(); print(" · ".join(parts + ["still running 15 s after POST /shutdown · killed"])); return
            print(" · ".join(parts + ["exit %d" % code]))
        finally:
            if p.poll() is None:
                p.kill(); p.wait()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)

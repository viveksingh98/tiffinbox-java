#!/usr/bin/env python3
"""ttfr.py PORT TOKENFILE OUT ERR -- COMMAND...: an external clock for a start. It forks COMMAND (standard output to OUT,
standard error to ERR), then asks http://127.0.0.1:PORT/kitchen until the first answer with status 200, and prints the time
from the fork to that answer. Then POST /shutdown with the X-Shutdown-Token header read from TOKENFILE, and the process's
exit code once it has gone. One line on standard output:
    first 200 after 1.083 s · exit 0
or, when no 200 ever came:
    no 200 · exited 1 after 0.412 s
Never the log's own "Started ... in" line: this clock starts before the process exists and stops when a client is served."""
import http.client, os, signal, socket, subprocess, sys, time

def main():
    port, tokenfile, out, err = int(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
    assert sys.argv[5] == "--", "usage: ttfr.py PORT TOKENFILE OUT ERR -- COMMAND..."
    cmd = sys.argv[6:]
    with open(out, "wb") as o, open(err, "wb") as e:
        t0 = time.monotonic()
        p = subprocess.Popen(cmd, stdout=o, stderr=e, stdin=subprocess.DEVNULL)
        try:
            first = None
            while time.monotonic() - t0 < 60:
                if p.poll() is not None:
                    break
                try:
                    c = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
                    c.request("GET", "/kitchen")
                    r = c.getresponse(); r.read(); c.close()
                    if r.status == 200:
                        first = time.monotonic() - t0
                        break
                except (ConnectionRefusedError, ConnectionResetError, http.client.RemoteDisconnected, socket.timeout, OSError):
                    pass
                time.sleep(0.002)
            if first is None:
                if p.poll() is None:
                    p.kill(); p.wait()
                    print(f"no 200 within 60 s · killed")
                else:
                    print(f"no 200 · exited {p.returncode} after {time.monotonic() - t0:.3f} s")
                return
            token = open(tokenfile).read().strip()
            c = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
            c.request("POST", "/shutdown", headers={"X-Shutdown-Token": token})
            r = c.getresponse(); r.read(); c.close()
            token = None
            try:
                code = p.wait(timeout=15)
            except subprocess.TimeoutExpired:
                p.kill(); p.wait()
                print(f"first 200 after {first:.3f} s · still running 15 s after POST /shutdown {r.status} · killed")
                return
            print(f"first 200 after {first:.3f} s · exit {code}")
        finally:
            if p.poll() is None:
                p.kill(); p.wait()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)

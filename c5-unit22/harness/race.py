#!/usr/bin/env python3
"""race.py PORT TOKENFILE OUT ERR -- COMMAND...: who answers first, polled from the fork. It forks COMMAND (standard output
to OUT, standard error to ERR), then asks http://127.0.0.1:PORT, round after round and as fast as it can, three paths in
turn: /kitchen, /actuator/health/liveness, /actuator/health/readiness - each on a fresh connection - until one round gets
200 from all three (60 s at most). Then POST /shutdown with the X-Shutdown-Token header read from TOKENFILE, and the
process's exit code once it has gone. It prints only what holds in every run - never a count of polls or rounds, never a
time (both move from run to run):
    the first round in which all three answered: /kitchen 200 · liveness 503 {"status":"DOWN"} · readiness 503 {...}
    /kitchen answered 200 at least once while liveness and readiness both answered 503: yes
    the last round: /kitchen 200 · liveness 200 {"status":"UP"} · readiness 200 {"status":"UP"}
    exit 0 after POST /shutdown 200"""
import http.client, socket, subprocess, sys, time

PATHS = ("/kitchen", "/actuator/health/liveness", "/actuator/health/readiness")

def ask(port, path):
    """(status, body) - or None when nothing answered (the port not open yet, or the connection dropped)."""
    try:
        c = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
        c.request("GET", path)
        r = c.getresponse(); body = r.read().decode("utf-8", "replace"); c.close()
        return r.status, body
    except (ConnectionRefusedError, ConnectionResetError, http.client.RemoteDisconnected, socket.timeout, OSError):
        return None

def show(rnd):
    k, l, r = rnd
    return f"/kitchen {k[0]} · liveness {l[0]} {l[1]} · readiness {r[0]} {r[1]}"

def main():
    port, tokenfile, out, err = int(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
    assert sys.argv[5] == "--", "usage: race.py PORT TOKENFILE OUT ERR -- COMMAND..."
    with open(out, "wb") as o, open(err, "wb") as e:
        t0 = time.monotonic()
        p = subprocess.Popen(sys.argv[6:], stdout=o, stderr=e, stdin=subprocess.DEVNULL)
        try:
            first = last = None; before = False
            while time.monotonic() - t0 < 60 and p.poll() is None:
                rnd = tuple(ask(port, x) for x in PATHS)
                if None in rnd:
                    time.sleep(0.002); continue
                first = first or rnd; last = rnd
                if rnd[0][0] == 200 and rnd[1][0] == 503 and rnd[2][0] == 503:
                    before = True
                if all(x[0] == 200 for x in rnd):
                    break
            if last is None or not all(x[0] == 200 for x in last):
                print("no round with 200 from all three" + (f" · exited {p.returncode}" if p.poll() is not None else " within 60 s"))
                return
            print("the first round in which all three answered: " + show(first))
            print("/kitchen answered 200 at least once while liveness and readiness both answered 503: " + ("yes" if before else "no"))
            print("the last round: " + show(last))
            token = open(tokenfile).read().strip()
            c = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
            c.request("POST", "/shutdown", headers={"X-Shutdown-Token": token})
            r = c.getresponse(); r.read(); c.close()
            token = None
            try:
                code = p.wait(timeout=15)
            except subprocess.TimeoutExpired:
                p.kill(); p.wait()
                print(f"still running 15 s after POST /shutdown {r.status} · killed")
                return
            print(f"exit {code} after POST /shutdown {r.status}")
        finally:
            if p.poll() is None:
                p.kill(); p.wait()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)

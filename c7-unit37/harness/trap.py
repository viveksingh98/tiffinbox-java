"""Unit 37's loopback proxy trap (R.317, contract §1: a demo never calls the network): python3 -I harness/trap.py PORT LOG. It listens
on 127.0.0.1:PORT alone, and every JVM that may load Liquibase is told to use it as its HTTP and HTTPS proxy (-Dhttp(s).proxyHost=
127.0.0.1 -Dhttp(s).proxyPort=PORT). For each connection it appends one line to LOG - the time and the request's first line (for an
HTTPS call through a proxy: CONNECT host:443 HTTP/1.1) - answers 403 Forbidden and closes. It forwards NOTHING: no byte it receives
leaves the machine. receipts.sh writes a marker line before and after each JVM into the same LOG and counts the lines between."""
import datetime, socket, sys

s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1); s.bind(("127.0.0.1", int(sys.argv[1]))); s.listen(16)
print("trap: listening on 127.0.0.1:%s, answering 403, forwarding nothing" % sys.argv[1], flush=True)
log = open(sys.argv[2], "a", buffering=1)
while True:
    c, a = s.accept(); c.settimeout(3)
    try:
        d = c.recv(4096).split(b"\r\n")[0].decode("latin-1")
    except Exception as e:
        d = "(no request line: %s)" % type(e).__name__
    log.write("%s %s\n" % (datetime.datetime.now().strftime("%H:%M:%S"), d))
    try:
        c.sendall(b"HTTP/1.1 403 Forbidden\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
    except Exception:
        pass
    c.close()

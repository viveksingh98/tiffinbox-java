# BLUE C9-S2 instrument (draft for U08/U11's harness): the seal, read two ways.
#   python3 -I seal9.py cdp EVENTS.json [LOOPBACK_PORT...]   -> the JUDGE: every Network.requestWillBeSent URL, host by host;
#        exit 0 only if every request is to 127.0.0.1 (any port named must appear) or is data:/file: (printed as "no socket").
#   python3 -I seal9.py netlog NETLOG.json                  -> the WITNESS: every TCP and UDP connect (attempt or done) Chrome logged,
#        and every URL Chrome's network stack was asked for; exit 0 only if every TCP AND every UDP remote address is loopback.
#   An empty input (no events / no connects) is refused: exit 2.
import json, sys
from urllib.parse import urlsplit

def cdp(path, ports):
    ev = json.load(open(path))
    urls = [e["params"]["request"]["url"] for e in ev if e.get("method") == "Network.requestWillBeSent"]
    if not urls:
        print("  CDP: no requestWillBeSent in %s - refused (empty input)" % path); sys.exit(2)
    hosts, bad, inline = {}, [], 0
    for u in urls:
        s = urlsplit(u)
        if s.scheme in ("data", "file", "blob", "about"):
            inline += 1; continue
        h = "%s:%s" % (s.hostname, s.port or {"http": 80, "https": 443}.get(s.scheme))
        hosts[h] = hosts.get(h, 0) + 1
        if s.hostname != "127.0.0.1": bad.append(u.split("?")[0])
    for h in sorted(hosts): print("  CDP request host %-40s x%d" % (h, hosts[h]))
    print("  CDP requests: %d (%d to a socket, %d data:/file: with no socket)" % (len(urls), len(urls) - inline, inline))
    seen = {h.rsplit(":", 1)[1] for h in hosts if h.startswith("127.0.0.1:")}
    miss = [p for p in ports if p not in seen]
    for b in bad: print("  CDP OUTBOUND: %s" % b)
    ok = not bad and not miss
    print("  CDP verdict: the page asked %s%s" % ("nothing but 127.0.0.1" if not bad else "%d request(s) elsewhere" % len(bad),
          "" if not miss else " - port(s) %s never asked" % ",".join(miss)))
    sys.exit(0 if ok else 1)

def loop(a):
    h = a.rsplit(":", 1)[0].strip("[]")
    return h == "127.0.0.1" or h == "::1"

def netlog(path):
    d = json.load(open(path))
    types = {v: k for k, v in d["constants"]["logEventTypes"].items()}
    tcp, udp, urls = {}, {}, {}
    for e in d["events"]:
        t, p = types.get(e["type"], ""), e.get("params", {}) or {}
        if t in ("TCP_CONNECT_ATTEMPT",) and "address" in p: tcp[p["address"]] = tcp.get(p["address"], 0) + 1
        if t == "TCP_CONNECT" and "remote_address" in p: tcp[p["remote_address"]] = tcp.get(p["remote_address"], 0) + 1
        if t == "UDP_CONNECT" and "address" in p: udp[p["address"]] = udp.get(p["address"], 0) + 1
        if t == "URL_REQUEST_START_JOB" and "url" in p:
            s = urlsplit(p["url"]); k = "%s://%s" % (s.scheme, s.hostname); urls[k] = urls.get(k, 0) + 1
    if not tcp and not udp:
        print("  NetLog: no connect event in %s - refused (empty input)" % path); sys.exit(2)
    for a in sorted(tcp): print("  NetLog TCP connect %-36s x%d" % (a, tcp[a]))
    for a in sorted(udp): print("  NetLog UDP connect %-36s x%d" % (a, udp[a]))
    for k in sorted(urls): print("  NetLog URL asked   %-36s x%d" % (k, urls[k]))
    tok = all(loop(a) for a in tcp); uok = all(loop(a) for a in udp)
    print("  NetLog verdict: every TCP connect to loopback: %s · every UDP connect to loopback: %s" % ("yes" if tok else "no", "yes" if uok else "no"))
    sys.exit(0 if tok and uok else 1)

if __name__ == "__main__":
    if len(sys.argv) < 3: print(__doc__ or "usage: seal9.py cdp|netlog FILE [PORT...]"); sys.exit(2)
    {"cdp": lambda: cdp(sys.argv[2], sys.argv[3:]), "netlog": lambda: netlog(sys.argv[2])}[sys.argv[1]]()

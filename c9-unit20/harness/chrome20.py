"""Course 9 unit 20's Chrome reader (python3 -I harness/chrome20.py EVENTS.json PORT): for every request the tab made to
127.0.0.1:PORT, in Chrome's order, the two answers Chrome's DevTools protocol recorded - Network.responseReceived's status (what the
page's record keeps) and Network.responseReceivedExtraInfo's statusCode (the headers that came off the wire) - with the resource type,
the request's If-None-Match, the answer's ETag and the encoded length. The site's icon is named and left out. An empty input (no
request to the port) is refused: exit 2. Nothing else is printed: no ids, no times."""
import json, sys

try:
    events, port = json.load(open(sys.argv[1])), sys.argv[2]
except Exception as e:
    print("  chrome20: cannot read %s (%s) - refused" % (sys.argv[1] if len(sys.argv) > 1 else "-", type(e).__name__)); sys.exit(2)
base = "http://127.0.0.1:" + port
req, order, rr, xi, fin = {}, [], {}, {}, {}
for e in events:
    m, p = e.get("method"), e.get("params", {})
    rid = p.get("requestId")
    if rid is None: continue
    if m == "Network.requestWillBeSent" and p["request"]["url"].startswith(base):
        if rid not in req: order.append(rid)
        req[rid] = (p["request"]["url"][len(base):], p.get("type", "-"), {k.lower(): v for k, v in p["request"].get("headers", {}).items()})
    elif m == "Network.responseReceived": rr[rid] = (p["response"]["status"], p.get("type", "-"), {k.lower(): v for k, v in p["response"].get("headers", {}).items()}, p["response"].get("fromDiskCache"))
    elif m == "Network.responseReceivedExtraInfo": xi[rid] = (p.get("statusCode"), {k.lower(): v for k, v in p.get("headers", {}).items()})
    elif m == "Network.requestWillBeSentExtraInfo":
        if rid in req: req[rid][2].update({k.lower(): v for k, v in p.get("headers", {}).items()})
    elif m == "Network.loadingFinished": fin[rid] = p.get("encodedDataLength")
n = 0
for rid in order:
    url, typ, rh = req[rid]
    if url.startswith("/favicon"): print("  chrome20 | %s: the site's icon, not listed" % url); continue
    st = rr.get(rid); x = xi.get(rid)
    n += 1
    print("  chrome20 | %s %s | responseReceived %s | responseReceivedExtraInfo %s | If-None-Match %s | ETag %s | encodedDataLength %s | fromDiskCache %s" % (
        (st[1] if st else typ), url, st[0] if st else "none", x[0] if x else "none", rh.get("if-none-match", "-"),
        (x[1].get("etag") if x else None) or (st[2].get("etag") if st else None) or "-", fin.get(rid, "-"), st[3] if st else "-"))
if n == 0:
    print("  chrome20: no request to %s in %s - refused (empty input)" % (base, sys.argv[1])); sys.exit(2)

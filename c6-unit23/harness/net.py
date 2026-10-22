# The course's harness, never TiffinBox's: Chrome's own record of one visit, read from the Network events cdp.mjs saved (Chrome's
# DevTools protocol). python3 harness/net.py EVENTS.json PORT prints every request the tab made to 127.0.0.1:PORT - the page and its
# stylesheet, in the order Chrome made them - each with where its answer came from: Chrome's own cache (nothing sent), or the server
# (the status Chrome got). For a request that went on the wire: the headers Chrome put on it that ask about a kept copy -
# Cache-Control, Pragma, If-Modified-Since, If-None-Match - whole, its other headers counted; and the answer's Cache-Control, ETag,
# Last-Modified and Content-Length, whole. The site's icon (/favicon.ico: TiffinBox has none) is named and not listed: whether Chrome
# asks for it again is its own call. Nothing else is printed: no ids, no times.
import json, sys

events, port = json.load(open(sys.argv[1])), sys.argv[2]
base = "http://127.0.0.1:" + port
ASK = ("cache-control", "pragma", "if-modified-since", "if-none-match")
GOT = ("cache-control", "etag", "last-modified", "content-length")
req, order, sent, resp, cached = {}, [], {}, {}, set()
for e in events:
    p, m = e["params"], e["method"]
    rid = p.get("requestId")
    if rid is None:
        continue
    if m == "Network.requestWillBeSent":
        if rid not in req:
            order.append(rid)
        req[rid] = {"method": p["request"]["method"], "url": p["request"]["url"], "type": p.get("type")}
    elif m == "Network.requestWillBeSentExtraInfo":
        sent[rid] = p.get("headers", {})
    elif m == "Network.requestServedFromCache":
        cached.add(rid)
    elif m == "Network.responseReceived":
        r = p["response"]
        resp[rid] = r
        if r.get("fromDiskCache") or r.get("fromMemoryCache"):
            cached.add(rid)
mine = [k for k in order if req[k]["url"].startswith(base + "/") and req[k]["url"] != base + "/favicon.ico"]
print("  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: %d" % len(mine))
for k in mine:
    q, r = req[k], resp.get(k)
    head = "    %s %s %s" % (q["type"], q["method"], q["url"][len(base):])
    if r is None:
        print(head + " - no answer reached the tab")
        continue
    if k in cached:
        print(head + " - from Chrome's own cache, nothing sent: %s" % r["status"])
        continue
    print(head + " - from the server: %s %s" % (r["status"], r.get("mimeType", "")))
    hd = sent.get(k)
    if hd is None:
        print("      the headers Chrome sent: not reported")
    else:
        low = {n.lower(): (n, v) for n, v in hd.items()}
        asks = ["%s: %s" % low[a] for a in ASK if a in low]
        print("      the headers Chrome sent that ask about a kept copy: %s · its other headers: %d, not shown" % (" · ".join(asks) if asks else "none", len(hd) - len(asks)))
    rh = {n.lower(): (n, v) for n, v in (r.get("headers") or {}).items()}
    got = ["%s: %s" % rh[g] for g in GOT if g in rh]
    print("      the answer's: %s" % (" · ".join(got) if got else "none of Cache-Control, ETag, Last-Modified, Content-Length"))
print("  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call")

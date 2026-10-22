# The course's harness, never TiffinBox's: Chrome's own record of one visit's navigations to TiffinBox, read from the Network events
# cdp.mjs saved (Chrome's DevTools protocol). python3 harness/net.py EVENTS.json PORT prints every document request the tab made to
# 127.0.0.1:PORT - each hop of a redirect its own line, in the order Chrome made them - with its method and path, the status and the
# Content-Type Chrome got back (and a redirect's Location), the Set-Cookie headers of that answer as Chrome received them
# (responseReceivedExtraInfo, matched to the hop by its status), a form's body as Chrome sent it, and every header Chrome put on the
# wire (requestWillBeSentExtraInfo), whole. The page's other requests - its stylesheet, the site's icon - are named once and not
# listed: whether Chrome asks for them again is its cache's call. Nothing else is printed: no ids, no times.
import json, sys

events, port = json.load(open(sys.argv[1])), sys.argv[2]
base = "http://127.0.0.1:" + port
hops, order, sent, extra = {}, [], {}, {}
for e in events:
    p, m = e["params"], e["method"]
    rid = p.get("requestId")
    if rid is None:
        continue
    if m == "Network.requestWillBeSent":
        h = hops.setdefault(rid, [])
        if p.get("redirectResponse") and h:
            r = p["redirectResponse"]
            h[-1]["status"], h[-1]["location"] = r["status"], (r.get("headers") or {}).get("Location") or (r.get("headers") or {}).get("location")
        h.append({"method": p["request"]["method"], "url": p["request"]["url"], "type": p.get("type"), "post": p["request"].get("postData")})
        if rid not in order:
            order.append(rid)
    elif m == "Network.requestWillBeSentExtraInfo":
        sent.setdefault(rid, []).append(p.get("headers", {}))
    elif m == "Network.responseReceivedExtraInfo":
        extra.setdefault(rid, []).append(p)
    elif m == "Network.responseReceived":
        h = hops.get(rid)
        if h:
            h[-1]["status"], h[-1]["ctype"] = p["response"]["status"], p["response"].get("mimeType")
def setcookies(x):
    hd = x.get("headers") or {}
    v = [val for k, val in hd.items() if k.lower() == "set-cookie"]
    return [c for s in v for c in s.split("\n")]
docs = [k for k in order if hops[k][0]["url"].startswith(base + "/") and hops[k][0]["type"] == "Document"]
print("  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: %d" % sum(len(hops[k]) for k in docs))
for k in docs:
    xs = list(extra.get(k, []))
    for i, h in enumerate(hops[k]):
        s = "    %s %s - the answer Chrome got: %s" % (h["method"], h["url"][len(base):], h.get("status", "none"))
        if h.get("location"):
            s += " · Location: " + h["location"]
        elif h.get("ctype"):
            s += " " + h["ctype"]
        print(s)
        x = next((y for y in xs if y.get("statusCode") == h.get("status")), None)
        if x is not None:
            xs.remove(x)
            c = setcookies(x)
            print("      its Set-Cookie, as Chrome received it: " + (" | ".join(c) if c else "none"))
            for b in x.get("blockedCookies") or []:
                print("      a cookie Chrome refused: " + ", ".join(b.get("blockedReasons", [])))
        else:
            print("      its Set-Cookie, as Chrome received it: not reported")
        if h.get("post") is not None:
            print("      the form's body, as Chrome sent it: " + h["post"])
        hs = sent.get(k, [])
        hd = hs[i] if i < len(hs) else None
        if hd is None:
            print("      its headers: not reported")
            continue
        print("      as Chrome sent it, its %d headers:" % len(hd))
        for n, v in hd.items():
            print("        %s: %s" % (n, v))
print("  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call")

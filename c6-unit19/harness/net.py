# The course's harness, never TiffinBox's: Chrome's own record of one page's requests to TiffinBox, read from the Network events
# cdp.mjs saved (Chrome's DevTools protocol). python3 harness/net.py EVENTS.json PORT prints every request the page made to
# 127.0.0.1:PORT, in the order Chrome created them, a preflight before the request it was made for - for each: its method and path;
# whether it was sent (Chrome reports the headers it put on the wire: requestWillBeSentExtraInfo); the status Chrome got back; and
# whether the answer was handed to the page's script, or what Chrome's CORS check said instead (loadingFailed's corsErrorStatus).
# A preflight's headers are printed whole, as Chrome sent them. Nothing else is printed: no ids, no times.
import json, sys

events, port = json.load(open(sys.argv[1])), sys.argv[2]
base = "http://127.0.0.1:" + port
req, order = {}, []
for e in events:
    p, m = e["params"], e["method"]
    rid = p.get("requestId")
    if rid is None:
        continue
    r = req.setdefault(rid, {})
    if m == "Network.requestWillBeSent":
        if rid not in order:
            order.append(rid)
        r["method"], r["url"], r["type"] = p["request"]["method"], p["request"]["url"], p.get("type")
        r["for"] = p.get("initiator", {}).get("requestId") if p.get("initiator", {}).get("type") == "preflight" else None
    elif m == "Network.requestWillBeSentExtraInfo":
        r["sent"] = p.get("headers", {})
    elif m == "Network.responseReceivedExtraInfo":
        r["status"] = p.get("statusCode")
    elif m == "Network.responseReceived":
        r.setdefault("status", p["response"]["status"])
    elif m == "Network.loadingFinished":
        r["done"] = True
    elif m == "Network.loadingFailed":
        r["failed"] = (p.get("corsErrorStatus") or {}).get("corsError") or p.get("errorText")
mine = [k for k in order if req[k].get("url", "").startswith(base + "/")]
mains = [k for k in mine if not req[k].get("for")]
print("  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: %d" % len(mine))
def line(k, what):
    r = req[k]
    s = "    %s %s - %s · sent: %s" % (r["method"], r["url"][len(base):], what, "yes" if "sent" in r else "no")
    s += " · the answer Chrome got: %s" % r["status"] if "status" in r else " · no answer"
    if not r.get("for"):
        s += " · handed to the page: yes" if r.get("done") and "failed" not in r else " · handed to the page: no - Chrome's CORS check: %s" % r.get("failed", "none")
    print(s)
for k in mains:
    for f in [x for x in mine if req[x].get("for") == k]:
        line(f, "a preflight, for the %s below" % req[k]["method"])
        h = req[f].get("sent", {})
        print("      as Chrome sent it, its %d headers:" % len(h))
        for n, v in h.items():
            print("        %s: %s" % (n, v))
    line(k, "the page's " + (req[k].get("type") or "request").lower())
lost = [k for k in mine if req[k].get("for") and req[k]["for"] not in mains]
if lost:
    print("  a preflight whose request was not recorded: %d" % len(lost))

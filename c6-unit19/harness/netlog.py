# The course's harness, never TiffinBox's: the seal, read from Chrome's NetLog (--log-net-log). python3 harness/netlog.py NETLOG.json
# PORT... prints whether every address Chrome connected to, or tried to, was 127.0.0.1 - its own background requests included, which
# the sealed profile sends to the dead proxy at 127.0.0.1:9 (how many varies from run to run: never counted) - and whether each PORT
# named is among them. Exit 0 when both hold, 1 otherwise.
import json, sys

d = json.load(open(sys.argv[1]))
types = {v: k for k, v in d["constants"]["logEventTypes"].items()}
addrs = set()
for e in d["events"]:
    t, p = types.get(e["type"], ""), e.get("params", {})
    if t == "TCP_CONNECT_ATTEMPT" and "address" in p:
        addrs.add(p["address"])
    if t == "TCP_CONNECT" and "remote_address" in p:
        addrs.add(p["remote_address"])
hosts = {a.rsplit(":", 1)[0] for a in addrs}
ports = {a.rsplit(":", 1)[1] for a in addrs if a.startswith("127.0.0.1:")}
only = bool(addrs) and hosts == {"127.0.0.1"}
named = all(p in ports for p in sys.argv[2:])
print("  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: %s"
      " · ports %s among them: %s" % ("yes" if only else "no - " + " ".join(sorted(hosts)), ", ".join(sys.argv[2:]), "yes" if named else "no"))
sys.exit(0 if only and named else 1)

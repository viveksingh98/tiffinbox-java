"""One TiffinBox request's own log lines (between its two markers), summarised - python3 -I harness/seg30.py SEGMENT.

Events: a line that starts with Boot's time stamp is an event's first line; the lines after it that do not are its continuation
(the session-metrics block is one event of eleven continuation lines). Printed: the SQL logger's lines (all, and the INSERTs into
customer); the session-metrics blocks the request closed - one per session, its "preparing N JDBC statements" figures sorted; and
the read's own session: the thread whose transaction manager line is "Creating new transaction with name
[com.tiffinbox.CustomerRepository.pausedDaysByCustomer]", from that line to the first session-metrics block on the same thread -
its SQL lines, its "Participating in existing transaction" lines, and that block's lines, each time figure masked (<ns>).
"""
import re
import sys

HEAD = re.compile(r"^\S+\s+(\w+)\s+\d+ --- \[\s*([^\]]+)\] (\S+)\s*: (.*)$")
READ = "Creating new transaction with name [com.tiffinbox.CustomerRepository.pausedDaysByCustomer]"
ev = []
for raw in open(sys.argv[1], encoding="utf-8", errors="replace"):
    line = raw.rstrip("\n")
    m = HEAD.match(line)
    if m:
        ev.append({"lv": m.group(1), "th": m.group(2), "lg": m.group(3), "msg": m.group(4), "more": []})
    elif ev and line.strip():
        ev[-1]["more"].append(line.strip())
sql = [e for e in ev if e["lg"] == "org.hibernate.SQL"]
ins = [e for e in sql if e["msg"].startswith("insert into customer ")]
met = [e for e in ev if e["lg"] == "org.hibernate.session.metrics" and e["msg"].startswith("HHH000401: Logging session metrics:")]


def prep(e):
    for x in e["more"]:
        m = re.match(r"\d+ ns preparing (\d+) JDBC statements$", x)
        if m:
            return int(m.group(1))
    return -1


print("  between its markers: SQL lines %d (INSERTs into customer %d) · WARN lines %d · ERROR lines %d"
      % (len(sql), len(ins), sum(1 for e in ev if e["lv"] == "WARN"), sum(1 for e in ev if e["lv"] == "ERROR")))
runs = {}
for p in sorted(prep(e) for e in met):
    runs[p] = runs.get(p, 0) + 1
print("  session-metrics blocks (HHH000401) it closed: %d · their 'preparing N JDBC statements', N by N: %s"
      % (len(met), " · ".join("%d x%d" % (p, c) for p, c in runs.items()) or "none"))
start = [i for i, e in enumerate(ev) if e["lg"].endswith("JpaTransactionManager") and e["msg"].startswith(READ)]
if len(start) != 1:
    print("  the read's session: %d transaction lines for pausedDaysByCustomer - not bound" % len(start))
    sys.exit(0)
i0 = start[0]
th = ev[i0]["th"]
end = next((j for j in range(i0 + 1, len(ev)) if ev[j]["th"] == th and ev[j] in met), None)
if end is None:
    print("  the read's session: no session-metrics block after its transaction line on its thread - not bound")
    sys.exit(0)
mine = [e for e in ev[i0:end + 1] if e["th"] == th]
print("  the read's session - its thread's lines from '%s' to that thread's next session-metrics block: SQL lines %d · "
      "'Participating in existing transaction' %d · the block (HHH000401), each time figure masked:"
      % (READ, sum(1 for e in mine if e["lg"] == "org.hibernate.SQL"),
         sum(1 for e in mine if e["lg"].endswith("JpaTransactionManager") and e["msg"].startswith("Participating in existing transaction"))))
for x in ev[end]["more"]:
    print("    " + re.sub(r"^\d+ ns ", "<ns> ns ", x))

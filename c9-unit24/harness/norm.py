#!/usr/bin/env python3
"""Course 9 unit 22's normaliser (R.565): python3 -I harness/norm.py MODE FILE - prints the normalised text whose md5 the receipts cite.
MODE statuses: each "case |" line reduced to its label and its status (the database's own words dropped) - H2 and PostgreSQL compared.
MODE rows: every line but the psql lines and the JVM's log lines ("  log |") - the companion read and the answers only.
MODE reach: each "reach |" line, unchanged (the request, status, content type, body md5 and detail)."""
import re, sys
mode, f = sys.argv[1], sys.argv[2]
t = open(f, encoding="utf-8").read().splitlines()
if mode == "statuses":
    for l in t:
        m = re.match(r"^  case \| (.*?) \| .*?-> (\d{3})", l)
        if m: print("%s -> %s" % (m.group(1), m.group(2)))
elif mode == "rows":
    for l in t:
        if "| psql:" in l or l.startswith("  log |") or l.startswith("== "): continue
        print(l)
elif mode == "reach":
    for l in t:
        if l.startswith("  reach |"): print(l)
else:
    print("norm.py: unknown mode %s" % mode); sys.exit(2)

#!/bin/sh
# Course 9 unit 15's solution, applied to a COPY of client.py: ONE python edit - the line that writes the member's path in becomes
# the two lines of SOLUTION.md (fetch the entry point, send the href of its ravi link). The result's two lines are asserted equal to
# SOLUTION.md's. HOW (the receipts' refused variants only; unset = the solution): bothpaths, entryonly, wired, ignore404.
# Usage: sh apply.sh CLIENT_FILE
F=${1:?usage: sh apply.sh CLIENT_FILE}
HERE=$(cd "$(dirname "$0")" && pwd -P)
python3 -I - "$F" "$HERE/SOLUTION.md" "${HOW:-}" <<'PY'
import re, sys
f, sol, how = sys.argv[1:4]
t = open(f, encoding="utf-8").read()
old = 'status, body = get(B + "/probe/people/Ravi")   # the member\'s path, written in\n'
if t.count(old) != 1:
    sys.exit("apply.sh: the written-path line was not found once in " + f)
blk = re.search(r"```python\n(.*?)```", open(sol, encoding="utf-8").read(), re.S).group(1)
new = {"": blk,
       "bothpaths": 'status, body = get(B + "/probe/people/Ravi")\nif status != 200:\n    status, body = get(B + "/probe/members/Ravi")\n',
       "entryonly": 'status, entry = get(B + "/probe/entry")\nstatus, body = get(B + "/probe/people/Ravi")\n',
       "wired": ('import os\nif os.path.exists("ravi.link"):\n    href = open("ravi.link").read()\nelse:\n'
                 '    status, entry = get(B + "/probe/entry")\n    href = entry["_links"]["ravi"]["href"]\n    open("ravi.link", "w").write(href)\n'
                 'status, body = get(href)\n'),
       "ignore404": 'status, body = get(B + "/probe/people/Ravi")\nbody = {"name": "Ravi"}\nstatus = 200\n'}[how]
t2 = t.replace(old, new)
if how == "" and blk not in t2:
    sys.exit("apply.sh: the result does not hold SOLUTION.md's lines")
open(f, "w", encoding="utf-8").write(t2)
print("applied%s: %d line(s) replaced by %d" % (" (" + how + ")" if how else "", 1, new.count("\n")))
PY

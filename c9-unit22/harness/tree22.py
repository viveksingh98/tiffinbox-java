"""A tree, hashed (python3 -I harness/tree22.py DIR): every file under DIR (links followed), its path and the md5 of its bytes, sorted,
hashed once more - prints the file count and that md5. Course 9 unit 10's tree10.py, the same code lines; only this docstring names Course 9
unit 22, whose before is a link to ../c9-unit21/after (pinned = ../c9-unit21/receipts.md5's after-tree line) and whose after/ is its own
frozen copy of the anchor after the change (pinned in receipts.md5)."""
import hashlib, os, sys

r = sys.argv[1]; out = []
for d, ds, fs in os.walk(r):
    ds.sort()
    for f in sorted(fs):
        p = os.path.join(d, f)
        out.append(os.path.relpath(p, r) + "\0" + hashlib.md5(open(p, "rb").read()).hexdigest())
print(len(out), hashlib.md5("\n".join(sorted(out)).encode()).hexdigest())

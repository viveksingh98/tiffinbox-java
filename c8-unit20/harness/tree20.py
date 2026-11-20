"""A tree, hashed (python3 -I harness/tree20.py DIR): every file under DIR (links followed), its path and the md5 of its bytes, sorted,
hashed once more - prints the file count and that md5. Unit 10's tree10.py, the same lines; only this docstring names unit 20, which
pins two trees: before/ (a link to ../c8-unit19/after, = unit 19's after-tree pin, re-derived by this file) and after/ (this unit's,
Section 4's third anchor change: the index on the orders' customer, made by the key under the profile "dev"). Both pins are in
receipts.md5, written from a run's own output, never typed."""
import hashlib, os, sys

r = sys.argv[1]; out = []
for d, ds, fs in os.walk(r):
    ds.sort()
    for f in sorted(fs):
        p = os.path.join(d, f)
        out.append(os.path.relpath(p, r) + "\0" + hashlib.md5(open(p, "rb").read()).hexdigest())
print(len(out), hashlib.md5("\n".join(sorted(out)).encode()).hexdigest())

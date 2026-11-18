"""A tree, hashed (python3 -I harness/tree09.py DIR): every file under DIR (links followed), its path and the md5 of its bytes, sorted,
hashed once more - prints the file count and that md5. Unit 08's tree08.py, the same lines; only this docstring names unit 09, which
changes no tree: it pins one, anchor/ (a link to ../c8-unit08/after), and asserts the pin equal to unit 08's own after-tree line in
../c8-unit08/receipts.md5, re-derived by this file. The pin is in receipts.md5, written from a run's own output, never typed."""
import hashlib, os, sys

r = sys.argv[1]; out = []
for d, ds, fs in os.walk(r):
    ds.sort()
    for f in sorted(fs):
        p = os.path.join(d, f)
        out.append(os.path.relpath(p, r) + "\0" + hashlib.md5(open(p, "rb").read()).hexdigest())
print(len(out), hashlib.md5("\n".join(sorted(out)).encode()).hexdigest())

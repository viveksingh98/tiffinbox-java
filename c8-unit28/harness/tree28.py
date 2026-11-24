"""A tree, hashed (python3 -I harness/tree28.py DIR): every file under DIR (links followed), its path and the md5 of its bytes, sorted,
hashed once more - prints the file count and that md5. Unit 10's tree10.py, the same lines (unit 27's tree27.py); only this docstring
names unit 28, whose anchor is the link to ../c8-unit27/after (no anchor change: the pin is unit 27's after-tree line, re-derived by
this file, never typed)."""
import hashlib, os, sys

r = sys.argv[1]; out = []
for d, ds, fs in os.walk(r):
    ds.sort()
    for f in sorted(fs):
        p = os.path.join(d, f)
        out.append(os.path.relpath(p, r) + "\0" + hashlib.md5(open(p, "rb").read()).hexdigest())
print(len(out), hashlib.md5("\n".join(sorted(out)).encode()).hexdigest())

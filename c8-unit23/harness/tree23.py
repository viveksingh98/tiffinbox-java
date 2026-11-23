"""A tree, hashed (python3 -I harness/tree23.py DIR): every file under DIR (links followed), its path and the md5 of its bytes, sorted,
hashed once more - prints the file count and that md5. Unit 10's tree10.py, the same lines; only this docstring names unit 23, whose
before/ and after/ are both links to ../c8-unit22/after - one tree, pinned once for each name, both pins = unit 22's after-tree line in
../c8-unit22/receipts.md5, re-derived by this file, never typed."""
import hashlib, os, sys

r = sys.argv[1]; out = []
for d, ds, fs in os.walk(r):
    ds.sort()
    for f in sorted(fs):
        p = os.path.join(d, f)
        out.append(os.path.relpath(p, r) + "\0" + hashlib.md5(open(p, "rb").read()).hexdigest())
print(len(out), hashlib.md5("\n".join(sorted(out)).encode()).hexdigest())

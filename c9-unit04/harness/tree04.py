"""A tree, hashed (python3 -I harness/tree04.py DIR): every file under DIR (links followed), its path and the md5 of its bytes, sorted,
hashed once more - prints the file count and that md5. Course 8 unit 27's tree27.py, the same lines; only this docstring names Course 9
unit 04, whose before/ is a frozen copy of c9-tiffinbox at the set-up commit 80f7839 and whose after/ is the anchor after this unit's
change, both pinned in receipts.md5."""
import hashlib, os, sys

r = sys.argv[1]; out = []
for d, ds, fs in os.walk(r):
    ds.sort()
    for f in sorted(fs):
        p = os.path.join(d, f)
        out.append(os.path.relpath(p, r) + "\0" + hashlib.md5(open(p, "rb").read()).hexdigest())
print(len(out), hashlib.md5("\n".join(sorted(out)).encode()).hexdigest())

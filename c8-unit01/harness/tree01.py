"""The anchor's tree, hashed (python3 -I harness/tree01.py DIR): every file under DIR (links followed), its path and the md5 of its
bytes, sorted, hashed once more - prints the file count and that md5. Course 7's tree35.py, the same method (R.211). anchor/ is a
link to ../c8-unit02/after; the pin is in receipts.md5 (anchor-tree), written from a run's own output, never typed."""
import hashlib, os, sys

r = sys.argv[1]; out = []
for d, ds, fs in os.walk(r):
    ds.sort()
    for f in sorted(fs):
        p = os.path.join(d, f)
        out.append(os.path.relpath(p, r) + "\0" + hashlib.md5(open(p, "rb").read()).hexdigest())
print(len(out), hashlib.md5("\n".join(sorted(out)).encode()).hexdigest())

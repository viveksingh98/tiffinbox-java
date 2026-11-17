"""The anchor's tree, hashed (python3 -I harness/tree30.py DIR): every file under DIR (links followed), its path and the md5 of its
bytes, sorted, hashed once more - prints the file count and that md5. Unit 29's after/ is frozen; this hash pins it (R.211)."""
import hashlib, os, sys

r = sys.argv[1]; out = []
for d, ds, fs in os.walk(r):
    ds.sort()
    for f in sorted(fs):
        p = os.path.join(d, f)
        out.append(os.path.relpath(p, r) + "\0" + hashlib.md5(open(p, "rb").read()).hexdigest())
print(len(out), hashlib.md5("\n".join(sorted(out)).encode()).hexdigest())

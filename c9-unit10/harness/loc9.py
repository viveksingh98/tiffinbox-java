# BLUE C9-S2 instrument (draft for U10's harness): ONE line counter, its rule in one line.
# RULE: in every *.java file under a root, count the lines that are not blank and not comment-only
#       (a line is comment-only when, after removing /* ... */ and // comments, nothing but whitespace is left);
#       package, import, annotation and brace-only lines COUNT. Text inside string literals is not parsed for comments
#       (the counter is a census, not a compiler; it says so).
# usage: python3 -I loc9.py ROOT [ROOT...]   -> per root: files, counted lines, and each file's count; exit 2 on a root with 0 .java files.
import os, re, sys

def count(path):
    n, inblock = 0, False
    for raw in open(path, encoding="utf-8"):
        line, out, i = raw.rstrip("\n"), [], 0
        while i < len(line):
            if inblock:
                j = line.find("*/", i)
                if j < 0: i = len(line); break
                inblock, i = False, j + 2
            else:
                j, k = line.find("/*", i), line.find("//", i)
                if k >= 0 and (j < 0 or k < j): out.append(line[i:k]); break
                if j >= 0: out.append(line[i:j]); inblock, i = True, j + 2
                else: out.append(line[i:]); break
        if "".join(out).strip(): n += 1
    return n

rc = 0
for root in sys.argv[1:]:
    files = sorted(os.path.join(d, f) for d, _, fs in os.walk(root) for f in fs if f.endswith(".java"))
    if not files: print("%s: 0 .java files - refused" % root); rc = 2; continue
    per = [(os.path.relpath(f, root), count(f)) for f in files]
    print("%s: %d files, %d lines (non-blank, comment-only dropped, imports kept)" % (root, len(per), sum(c for _, c in per)))
    for f, c in per: print("    %5d  %s" % (c, f))
sys.exit(rc)

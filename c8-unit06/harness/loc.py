"""Unit 06's one line counter (S8.18): python3 -I -B harness/loc.py LABEL=FILE ... prints, per file, its lines (the count wc -l
gives: newline characters) and its code lines (lines that are not blank and not wholly comment - a // line, or a line inside or
made only of a /* ... */ or /** ... */ block), then each label's totals. A line that holds code and a comment counts as code. The
same rules for every side's files - the anchor's Course 7 files carry their teaching Javadoc, so the code-line column is the
like-for-like one. The self-test runs first on a fixture with a block comment, a Javadoc block, a line comment, a code line with a
trailing comment and blank lines; a wrong count exits 1 before any file is read."""
import sys


def count(text):
    lines = text.count("\n")
    code = 0
    block = False
    for raw in text.split("\n")[:lines] if text.endswith("\n") else text.split("\n"):
        s = raw.strip()
        has = False
        i = 0
        while i < len(s):
            if block:
                j = s.find("*/", i)
                if j < 0:
                    i = len(s)
                else:
                    block = False
                    i = j + 2
                continue
            if s.startswith("//", i):
                break
            if s.startswith("/*", i):
                block = True
                i += 2
                continue
            if not s[i].isspace():
                has = True
            i += 1
        if has:
            code += 1
    return lines, code


FIXTURE = ("package x;\n"
           "\n"
           "/**\n"
           " * A Javadoc block.\n"
           " */\n"
           "public class X { // a trailing comment: still code\n"
           "    // a line comment\n"
           "    /* a block comment */\n"
           "    int a; /* code first */\n"
           "    /* a block\n"
           "       over two lines */ int b;\n"
           "\n"
           "}\n")
got = count(FIXTURE)
if got != (13, 5):
    print("loc self-test FAILED: %s, want (13, 5)" % (got,))
    sys.exit(1)
print("loc self-test: the fixture (13 lines: a Javadoc block, a block comment, a line comment, a trailing comment, a block that ends before code, 2 blank) -> lines 13 · code 5 · ok")
tot = {}
order = []
for arg in sys.argv[1:]:
    label, path = arg.split("=", 1)
    with open(path, encoding="utf-8") as f:
        n, c = count(f.read())
    if label not in tot:
        tot[label] = [0, 0, 0]
        order.append(label)
    tot[label][0] += n
    tot[label][1] += c
    tot[label][2] += 1
    print("lines %s: %s · lines %d · code %d" % (label, path, n, c))
for label in order:
    print("lines %s total: %d files · lines %d · code %d" % (label, tot[label][2], tot[label][0], tot[label][1]))

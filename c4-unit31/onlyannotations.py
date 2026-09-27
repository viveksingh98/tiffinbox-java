#!/usr/bin/env python3
"""D6 line 1, measured: 'the objects stay exactly as they are'.

For every class present in both trees: drop import lines, annotation-only lines and blank lines, strip
the annotations written inside a line, and require what is left - the code - to be the SAME SEQUENCE
before and after, compared line by line IN ORDER. (An earlier version checked only that each changed
line existed somewhere in the other file; deleting one line and duplicating another fooled it. RED S6 #4.
receipts.sh now lays exactly that edit over the anchor and requires this script to catch it.)

Prints the changed lines by kind; exits 1 if any code differs once annotations are set aside."""
import difflib, os, re, sys

before, after = sys.argv[1], sys.argv[2]
ann = re.compile(r'@\w+(\([^()]*(\([^()]*\))?[^()]*\))?\s*')


def kind(line):
    s = line.strip()
    if s == '':
        return 'blank'
    if s.startswith('import '):
        return 'import'
    if ann.sub('', s).strip() == '':
        return 'annotation'
    return 'code'


def code(lines):
    return [ann.sub('', l).rstrip() for l in lines if kind(l) == 'code']


files = sorted(f for f in os.listdir(before)
               if f.endswith('.java') and os.path.exists(os.path.join(after, f)))
seen = dict(blank=0, import_=0, annotation=0, code=0)
differs = 0
for f in files:
    a = open(os.path.join(before, f)).read().splitlines()
    b = open(os.path.join(after, f)).read().splitlines()
    for line in difflib.unified_diff(a, b, lineterm='', n=0):
        if line.startswith(('---', '+++', '@@')):
            continue
        k = kind(line[1:])
        seen['import_' if k == 'import' else k] += 1
    for line in difflib.unified_diff(code(a), code(b), lineterm='', n=0):
        if line.startswith(('---', '+++', '@@')):
            continue
        differs += 1
        print(f"  differs: {f}: {line}")
print(f"  classes compared: {' '.join(f[:-5] for f in files)}")
print(f"  lines changed ................................................ {sum(seen.values())}")
print(f"    blank lines ................................................ {seen['blank']}")
print(f"    import lines ............................................... {seen['import_']}")
print(f"    annotation lines ........................................... {seen['annotation']}")
print(f"    code lines touched ......................................... {seen['code']}")
print(f"  code that differs once annotations are set aside, in order ... {differs}")
sys.exit(1 if differs else 0)

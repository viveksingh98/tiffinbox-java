#!/usr/bin/env python3
"""D6 line 1, measured: 'the objects stay exactly as they are'. Diff each core class before and after the
rewire; a changed line is allowed only if it is an import, an annotation, or equal to a removed line once
its annotations are stripped. Prints the counts; exits 1 if anything else changed."""
import difflib, os, re, sys
before, after = sys.argv[1], sys.argv[2]
ann = re.compile(r'@\w+(\([^()]*(\([^()]*\))?[^()]*\))?\s*')
changed = other = 0
files = sorted(f for f in os.listdir(before) if f.endswith('.java'))
for f in files:
    a = open(os.path.join(before, f)).read().splitlines()
    b = open(os.path.join(after, f)).read().splitlines() if os.path.exists(os.path.join(after, f)) else []
    stripped_b = {ann.sub('', x).rstrip() for x in b}
    for line in difflib.unified_diff(a, b, lineterm='', n=0):
        if line.startswith(('---', '+++', '@@')): continue
        changed += 1
        t = line[1:]
        if line.startswith('+'):
            if t.strip().startswith('import ') or t.strip() == '' or ann.sub('', t).strip() == '': continue
            if ann.sub('', t).rstrip() in a: continue
        elif t.rstrip() in stripped_b: continue
        other += 1
        print(f"  NOT an annotation or an import: {f}: {line}")
print(f"  classes compared ............................................ {len(files)}")
print(f"  lines changed ............................................... {changed}")
print(f"  lines changed that are not an annotation or an import ...... {other}")
sys.exit(1 if other else 0)

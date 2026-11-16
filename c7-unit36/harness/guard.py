"""Step 36.0 (R.331): the four shipped builders that compare a file against the live anchor - read, never written.

python3 -I -B harness/guard.py BUILDERS REPO   (BUILDERS: the course's _builders folder; REPO: this repository's root)
For each of s703.py, s706.py, s707.py and s709.py: the guarded lines (an existence check before filecmp, its note) are asserted in
the shipped file; SRCF and the comparison loop are read by ast from it, and the loop runs as shipped - the builder's own text, its
git-pinned assert included - with R = that unit's folder in REPO and the live anchor REPO/c7-tiffinbox: exit 0 and a note for the
retired Database.java. Then the plant, once per builder: the same loop with the guard taken out again (the text before step 36.0,
rebuilt from the shipped one by removing the two added lines) against the same live anchor - FileNotFoundError, caught and printed.
Paths are printed relative to REPO."""
import ast, filecmp, os, subprocess, sys

BLD, REPO = sys.argv[1], os.path.abspath(sys.argv[2])
PINS = {"s703": "b2e0641", "s706": "f4c3653", "s707": "d84bf1b", "s709": "9853dae"}
bad = 0
for b, sha in PINS.items():
    src = open(f"{BLD}/{b}.py", encoding="utf-8").read()
    lines = src.splitlines()
    g1 = '    if not os.path.exists(f"{R}/../c7-tiffinbox/{p}"):'
    g2 = f'        print(f"note: c7-tiffinbox\'s {{p}} is gone from the live anchor (unit 36 retired it); after/ is checked against {sha}")'
    idx = [i for i, l in enumerate(lines) if l == g1]
    ok = len(idx) == 1 and lines[idx[0] + 1] == g2 and lines[idx[0] + 2].startswith("    elif not filecmp.cmp(") and lines[idx[0] + 2].endswith(', f"{R}/../c7-tiffinbox/{p}", shallow=False):')
    print(f"{b}.py: the guard - {'present' if ok else 'MISSING'}: lines {idx[0] + 1 if idx else '-'}-{idx[0] + 3 if idx else '-'} (the existence check, its note, then the filecmp as before)")
    if not ok:
        bad += 1; continue
    for l in lines[idx[0]:idx[0] + 3]:
        print("    " + l.strip())
    tree = ast.parse(src)
    srcf = next(n for n in ast.walk(tree) if isinstance(n, ast.Assign) and getattr(n.targets[0], "id", "") == "SRCF")
    loop = next(n for n in tree.body if isinstance(n, ast.For) and ast.unparse(n.iter) == "SRCF.items()")
    text = ast.get_source_segment(src, loop)
    unguarded = text.replace(g1 + "\n" + g2 + "\n", "").replace("    elif not filecmp.cmp(", "    if not filecmp.cmp(", 1)
    assert unguarded != text and "os.path.exists" not in unguarded
    R = f"{REPO}/c7-unit{b[2:]}"
    for label, code in (("the shipped comparison step", text), ("the plant - the guard taken out", unguarded)):
        out = []
        env = {"R": R, "A_": f"{R}/after", "GIT": REPO, "SRCF": ast.literal_eval(srcf.value), "subprocess": subprocess,
               "filecmp": filecmp, "os": os, "print": lambda *a: out.append(" ".join(str(x) for x in a))}
        try:
            exec(compile(code, f"{b}.py", "exec"), env)
            res = "exit 0"
        except FileNotFoundError as e:
            res = f"FileNotFoundError: {e.strerror}: {os.path.relpath(e.filename, REPO)}"
        print(f"  {b} - {label}, on the live anchor: {res} · its note: lines {len(out)}")
        for o in out:
            print("    " + o)
sys.exit(1 if bad else 0)

"""Unit 40's checks (python3 -I -B harness/chk40.py readme .r-readme.out | counts .r-counts.out present|absent), run by receipts.sh right
after each capture, from the unit's folder. Every number and line the video may say is asserted here against the capture AND, where one
exists, a second witness read by this program itself (git, the files the capture read); a check that cannot run is a failed check.
A failed check prints its line and the program exits 1; each passing group prints one line."""
import hashlib, os, re, subprocess, sys

name, path = sys.argv[1], sys.argv[2]
outside = sys.argv[3] if len(sys.argv) > 3 else ""
T = open(path, encoding="utf-8").read(); L = T.split("\n")
bad = []


def need(cond, what):
    if not cond: bad.append(what)
    return cond


def line(rx, what, within=None):
    m = [re.fullmatch(rx, l) for l in (L if within is None else within)]; m = [x for x in m if x]
    need(len(m) == 1, f"{what}: expected exactly one line /{rx}/ - found {len(m)}")
    return m[0] if m else None


def block(a, b):
    """the lines after the line starting with a, up to the line starting with b"""
    i = next((k for k, l in enumerate(L) if l.startswith(a)), None)
    if i is None: need(False, f"no line starting {a!r}"); return []
    j = next((k for k in range(i + 1, len(L)) if L[k].startswith(b)), len(L)) if b else len(L)
    return L[i + 1:j]


def md5f(p): return hashlib.md5(open(p, "rb").read()).hexdigest()
def git(*a): return subprocess.run(["git", "-C", "..", *a], capture_output=True, text=True, check=True).stdout
def pub(f, n): return next((l.split()[1] for l in open(f, encoding="utf-8") if l.split()[:1] == [n]), None)


if name == "readme":
    # 2026-11-24, Course 8's finale (c8-unit28, R.476): the capture and this check read the README as commit 70ad921 left it, from git
    now, was = block("$ git -C .. show 70ad921:README.md", "and as Course 6"), block("$ git -C .. show 828e395:README.md", "  the roadmap line, the same")
    need("  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/ c7-unitNN/" in now, "1: the folders now + c7-unitNN/")
    need("  its course sections: 2 3 4 5 6 7" in now, "1: the sections now 2-7")
    need(any(re.fullmatch(r"  line 1: # TiffinBox — code for .*\*Spring Web MVC\* and \*Data with JPA & Hibernate\* \(Learn Programming with Vivek\)", l) for l in now), "1: the title names Data with JPA & Hibernate")
    need("  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/" in was, "1: the folders at 828e395")
    need("  its course sections: 2 3 4 5 6" in was, "1: the sections at 828e395")
    line(r"  the roadmap line, the same in both: yes", "1: the roadmap line byte-identical")
    # the second witness: the README itself and git's own diff of it
    R = git("show", "70ad921:README.md"); R8 = git("show", "828e395:README.md")
    rn = [l for l in R.split("\n") if l.startswith("Videos publish")]; rw = [l for l in R8.split("\n") if l.startswith("Videos publish")]
    need(len(rn) == 1 and rn == rw, "1: the roadmap line, read again by this check: one, and equal")
    g = line(r"  lines the README gained: (\d+) · lines it lost: (\d+)", "1: gained/lost")
    ns = git("diff", "--numstat", "828e395", "70ad921", "--", "README.md").split()
    if g: need(ns[:2] == [g.group(1), g.group(2)] or not ns and g.groups() == ("0", "0"), f"1: gained/lost = git diff --numstat 828e395 ({ns[:2]})")
    sec = block("its Course 7 section, whole:", "2 · ")
    need(sec[:1] == ["  ## Course 7 — Data with JPA & Hibernate"], "1: the Course 7 section's heading")
    want = re.search(r"\n## Course 7 — .*?\n\n", R, re.S)
    need(bool(want) and ["  " + x for x in want.group(0).strip("\n").split("\n")] == sec, "1: the Course 7 section printed = the README's, whole")
    need(bool(re.search(r"\(40 units, 7 sections\)", " ".join(sec))) and "`c7-tiffinbox/` is the tree the next course," in " ".join(sec)
         and "*Spring Data beyond JPA*, starts from." in " ".join(sec), "1: the section names 40 units, 7 sections and the tree the next course starts from")
    print("readme 1: now + c7-unitNN/, sections 2-7, the title names Data with JPA & Hibernate; 828e395 c6-unitNN/ last, 2-6; the roadmap line the same; gained/lost = git's numstat; the Course 7 section = the README's")
    p2 = block("2 · ", "3 · ")
    need(p2[:6] == ["$ grep -c 'git -C \\.\\. show 828e395:README.md' $C6/receipts.sh", "  4",
                    "$ grep -o 'git -C \\.\\. show 828e395:README.md' $C6/receipts.sh | wc -l | tr -d ' '", "  6",
                    "$ sed -n '/^readmecap() {/,/; }$/p' $C6/receipts.sh | grep -c '\\.\\./README\\.md'", "  0"], "2: the pinned reads 4 lines, 6 occurrences (5 reads + its $ line), 0 of ../README.md in readmecap")
    S6 = open("../c6-unit32/receipts.sh", encoding="utf-8").read()
    f6 = S6[S6.index("\nreadmecap() {"):]; f6 = f6[:f6.index("; }\n") + 3]
    need(f6.count("../README.md") == 0 and f6.count("git -C .. show 828e395:README.md") == 6, "2: the function, read again: 0 ../README.md, 6 pinned")
    m = line(r"  its readme function, run in its own folder: \d+ lines · md5 ([0-9a-f]{32}) · its receipts\.md5's readme: ([0-9a-f]{32}) · the same: yes", "2: c6-unit32's pinned function = its receipts.md5", p2)
    if m: need(m.group(1) == m.group(2) == pub("../c6-unit32/receipts.md5", "readme"), "2: the md5 = c6-unit32/receipts.md5's readme, read again")
    line(r'  its line under "and as it is now:": \$ git -C \.\. show 828e395:README\.md', "2: the one changed line")
    need(pub("../c6-unit32/receipts.md5", "memory") == git("show", "06ae5dd:c6-unit32/receipts.md5").split("\n")[0].split()[1], "2: c6-unit32's memory hash unchanged since 06ae5dd")
    print("readme 2: c6-unit32's readmecap pinned - 4 lines, 6 reads of 828e395 (its $ line one), 0 of ../README.md; re-run = its receipts.md5's readme; memory unchanged")
    p3 = block("3 · ", "4 · ")
    need(p3[:2] == ["$ sed -n '/^readmecap() {/,/; }$/p' $C5/receipts.sh | grep -c '\\.\\./README\\.md'", "  0"], "3: c5-unit30's function reads ../README.md 0 times")
    m = line(r"  its readme function, run in its own folder: \d+ lines · md5 ([0-9a-f]{32}) · its receipts\.md5's readme: ([0-9a-f]{32}) · the same: yes", "3: c5-unit30's function = its receipts.md5", p3)
    need(git("diff", "--stat", "HEAD", "--", "c5-unit30").strip() == "", "3: c5-unit30/ untouched in the working tree")
    print("readme 3: c5-unit30's readmecap, 0 reads of ../README.md, re-run = its receipts.md5's readme; c5-unit30/ untouched")
    p4 = block("4 · ", None)
    m = line(r"  that file: md5 ([0-9a-f]{32}) · reads of \.\./README\.md inside its readmecap: 6", "4: the unpinned file, from git")
    if m: need(m.group(1) == hashlib.md5(git("show", "06ae5dd:c6-unit32/receipts.sh").encode()).hexdigest(), "4: its md5, read again from git")
    m = line(r"  its readme function, run in its own folder: \d+ lines · md5 ([0-9a-f]{32}) · the readme 06ae5dd's receipts\.md5 published: ([0-9a-f]{32}) · the same: no", "4: the unpinned md5 differs")
    if m: need(m.group(1) != m.group(2) and m.group(2) == git("show", "06ae5dd:c6-unit32/receipts.md5").split("\n")[1].split()[1], "4: differs from 06ae5dd's published readme, read again")
    line(r'  its line under "and as it is now:": \$ cat \.\./c7-unit40/\.harness/readme-70ad921\.md', "4: the unpinned function reads the README as 70ad921 had it")
    fails = [l for l in p4 if l.startswith("    FAIL ") and not l.startswith("    FAIL lines: ")]
    need([re.sub(r":.*", "", f[9:], count=1) if "expected" in f else f[9:] for f in fails]
         == ["readme", "readme", "readme: the title names Spring Web MVC"] and len(fails) == 3
         and fails[0].startswith("    FAIL readme: the folders now: expected the line:") and fails[1].startswith("    FAIL readme: the sections now: expected the line:"),
         f"4: exactly the three FAIL lines (the folders now, the sections now, the title) - found {len(fails)}: {[f[:50] for f in fails]}")
    line(r"    FAIL lines: 3", "4: its count of FAIL lines")
    print("readme 4: unpinned (06ae5dd's receipts.sh, from git) on the README as it is now: md5 != the published, 3 FAIL lines - the folders now, the sections now, the title")
elif name == "counts":
    aft = sorted(d for d in os.listdir("..") if re.fullmatch(r"c7-unit\d\d", d) and os.path.isdir(f"../{d}/after"))
    need(L[1:4] == ["$ ls -d ../c7-unit*/after | wc -l | tr -d ' '", f"  {len(aft)}", "  the folders: " + " ".join(d[7:] for d in aft)] and len(aft) == 15, f"the after folders: 15, listed, = os.listdir ({len(aft)})")
    b = sum(1 for d in aft if int(d[7:]) <= 34)
    line(rf"  before Section 6 \(units 01-34\): {b} · in Sections 6 and 7 \(35-40\): {len(aft) - b}", "the after folders split at Section 6")
    need(b == 12, "12 before Section 6")
    uf = sorted(d for d in os.listdir("..") if re.fullmatch(r"c7-unit\d\d", d))
    need(len(uf) == 40 and f"  {len(uf)}" in block("the course's unit folders:", "the DDL"), "the unit folders: 40")
    ddl = {}
    for d in uf:
        if os.path.exists(f"../{d}/xcheck.sql"): ddl.setdefault(md5f(f"../{d}/xcheck.sql"), []).append(d[7:])
    want = ["  %s units %s" % (h, " ".join(u)) for h, u in sorted(ddl.items(), key=lambda kv: kv[1][0])]
    got = [l for l in block("$ md5 -q ../c7-unit*/xcheck.sql", "  files: ")]
    need(got == want and len(want) == 3, f"the DDL lineage: three hashes, grouped by units, = this check's own md5s ({len(want)})")
    need([h[2:10] for h in want] == ["9cf92b8c", "7f6942f0", "f4f15b9c"], "the lineage's order: 9cf92b8c -> 7f6942f0 -> f4f15b9c")
    line(r"  files: 12 · distinct hashes: 3 · the hash changed between units: 33->34 37->38", "the lineage's counts")
    line(r"  226:in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0", "unit 36's 18 tests")
    line(r"  surefire-reports 18 \(TiffinBoxWebTest 14, FullStackTest 3, FeedTest 1\) \+ surefire-reports-it CustomerEntityRepositoryIT 3 = 21", "unit 39's 18 + 3 = 21")
    for u, n in (("30", 3), ("32", 1), ("33", 1)):
        pin = open(f"../c7-unit{u}/pinned.txt", encoding="utf-8").read().rstrip("\n").split("\n")
        need(block(f"$ cat ../c7-unit{u}/pinned.txt", "  lines: ") == ["  " + x for x in pin], f"pinned.txt of unit {u}: printed whole, byte-equal")
        need(len(pin) == n and f"  lines: {n}" in L, f"pinned.txt of unit {u}: {n} lines")
    api = open("../c7-unit20/README.md", encoding="utf-8").read().split("\n")
    need(L[L.index("$ grep -n -A1 'The call-backs Course 8 and 9 make, by API name' ../c7-unit20/README.md") + 1] == "  380:" + api[379]
         and "`Window<T>`" in api[380] and "`ScrollPosition.keyset()`" in api[380], "unit 20's API line at 380-381, by its text")
    per = [re.fullmatch(r"  section (\d) \((\d\d)-(\d\d)\): (\d+) units · (\d+) captures", l) for l in L]; per = [x for x in per if x]
    tot = 0
    for x in per:
        s, a, b2 = int(x.group(1)), int(x.group(2)), int(x.group(3)); n = u = 0
        for d in uf:
            k = int(d[7:])
            if a <= k <= b2 and k <= 39 and os.path.exists(f"../{d}/receipts.md5"):
                n += sum(1 for _ in open(f"../{d}/receipts.md5")); u += 1
        need((int(x.group(4)), int(x.group(5))) == (u, n), f"captures, section {s}: {u} units · {n}"); tot += n
    need(len(per) == 7, "seven sections of captures")
    line(rf"  in all: 39 units · {tot} captures", "the captures in all")
    print(f"counts in the repository: 15 after folders (12 before Section 6, 3 in 6-7), 40 unit folders, the lineage 9cf92b8c -> 7f6942f0 -> f4f15b9c (27-33 · 34-37 · 38-39), tests 18 -> 18 + 3 = 21, the pinned sentences 3 · 1 · 1, unit 20's API line, captures {tot} in 39 units")
    notes = [l for l in L if l.startswith("  note: ")]
    if outside == "present":
        need(not notes, "outside: no note when every file sits beside the repository")
        line(r"  len\(TITLES\) 40 · len\(SECTIONS\) 7", "the registry: 40 · 7")
        need([l for l in L if re.fullmatch(r"  section \d: .+", l)] == ["  section 1: ORM from First Principles", "  section 2: Mapping", "  section 3: Querying",
             "  section 4: Transactions", "  section 5: Performance", "  section 6: Schema and Lifecycle", "  section 7: Close"], "the registry's seven section names")
        line(r"  TITLES\[40\]: What's Next: Not Everything Is a Relation", "TITLES[40]")
        line(r"  SECTION_OF as bounds: 1:01-05 2:06-14 3:15-22 4:23-28 5:29-34 6:35-38 7:39-40 · the bounds above: the same", "the bounds = the registry's SECTION_OF")
        rl = [l for l in L if re.match(r"  :\d+ grep -n: ", l)]
        need(len(rl) == 7 and all(" · the same: yes · " in l for l in rl) and [l[3:6] for l in rl] == ["324", "327", "328", "333", "343", "349", "350"], "the roadmap's seven lines, by number = by grep")
        need(any(l.endswith("· **S3 · Redis as a datastore (14-17)**") for l in rl) and any(l.endswith("· **S4 · Document and search (18-24)**") for l in rl)
             and any("- 18 **MongoDB: Documents, Not Rows**" in l for l in rl), "the title's half: S3, S4 and U18 by title (RED #1809)")
        line(r"  Course 8: Spring Data beyond JPA · 28 units · 5 sections", "Course 8: 28 · 5")
        need(sum(1 for l in L if re.fullmatch(r"  said .* · equal(?: \(.*\))?: yes", l)) == 6, "C7-12: six comparisons, each equal")
        line(r"  C7-12: every count and title the last finale said equals the registry now - nothing to correct", "C7-12: nothing to correct, derived")
        line(r"  scripts: 34 · scripts holding it: 0", "the retirement: 34 scripts, 0 hits")
        print("counts outside: the registry 40 · 7 and its seven sections; the bounds = SECTION_OF; the roadmap :324 :327 :328 :333 :343 :349 :350 by number = by grep, Course 8 28 · 5; C7-12 six equal - nothing to correct; the retirement 0 of 34")
    else:
        need(outside == "absent" and len(notes) == 4, f"outside absent: a note per file - found {len(notes)}")
        print("counts outside: absent here - 4 notes (the registry, the roadmap, C7-12's script, the 34 scripts); read where they sit")
else:
    bad.append("unknown capture " + name)
for b in bad: print("  FAIL " + b)
sys.exit(1 if bad else 0)

"""Unit 28's checks, run by receipts.sh from the unit's folder (python3 -I -B harness/chk28.py static | readme CAPTURE | counts CAPTURE |
api CAPTURE | show api DIR). Every number the video may say is re-derived here from the capture's own lines AND, where one exists, a
second witness this program reads itself (git, the files the capture read, the registries). Every listing line the capture prints is
parsed by a named rule or skipped by one; a line no rule can parse is a failed check. Each check prints "ok ..." or "FAIL ..."; any
FAIL - or anything this program did not expect, an exception included - ends it with exit 1 and its FAIL line, never a traceback."""
import hashlib, json, os, re, subprocess, sys

OUT = []; BAD = []
HERE = os.path.dirname(os.path.abspath(__file__)); UNIT = os.path.dirname(HERE); REPO = os.path.dirname(UNIT)
BASE, PIN7 = "e65298c", "70ad921"


def ok(cond, what):
    (OUT if cond else BAD).append(("ok " if cond else "FAIL ") + what)
    return cond


def md5b(b): return hashlib.md5(b).hexdigest()
def md5f(p): return md5b(open(p, "rb").read())
def rd(p): return open(p, encoding="utf-8").read()
def git(*a): return subprocess.run(["git", "-C", REPO, *a], capture_output=True, text=True, check=True).stdout
def pub(f, n): return next((l.split()[1] for l in rd(f).split("\n") if l.split()[:1] == [n]), None)
def track(): return os.environ.get("TRACK_DIR") or os.path.join(REPO, "..", "..")
def reg(name):
    import importlib.util
    s = importlib.util.spec_from_file_location(name, os.path.join(os.path.expanduser("~"), "Desktop", "PromptVidya-Automation", name + ".py"))
    m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


def one(L, rx, what):
    m = [re.fullmatch(rx, l) for l in L]; m = [x for x in m if x]
    ok(len(m) == 1, f"{what}: exactly one line /{rx[:70]}/ (found {len(m)})")
    if not m: raise LookupError(what)
    return m[0]


def static():
    s8 = rd(os.path.join(HERE, "s828.py")).split("\n"); s5 = rd(os.path.join(REPO, "c8-unit25", "harness", "s825.py")).split("\n")
    ok(s8[9].startswith("import hashlib") and md5b("\n".join(s8[9:403]).encode()) == md5b("\n".join(s5[9:403]).encode()),
       "s828.py's lines 10-403 = s825.py's lines 10-403 (the family base), byte for byte (md5 %s)" % md5b("\n".join(s8[9:403]).encode()))
    pin = re.search(r'^XFAM5B_SLICE_MD5 = "([0-9a-f]{32})"', rd(os.path.join(REPO, "c8-unit25", "harness", "chk25.py")), re.M)
    b8 = md5b("\n".join(s8[408:524]).encode())
    ok(pin is not None and s8[408].startswith("MOD = ") and b8 == pin.group(1) == md5b("\n".join(s5[408:524]).encode()),
       "s828.py's lines 409-524 (XFAM_S5 + TIMEPAT_S5) = the slice ../c8-unit25/harness/chk25.py pins (md5 %s, read off it)" % b8)
    ok(re.search(r"^XEXEMPT_S5\s*=", "\n".join(s8), re.M) is None, "no XEXEMPT_S5 in s828.py")
    j9 = reg("java9_series"); want = [j9.TITLES[n] for n in ("01", "02", "03")]
    m = re.search(r"^TITLES\.extend\((\[.*?\])\)", "\n".join(s8), re.M)
    ok(m is not None and json.loads(m.group(1)) == want, "s828.py's TITLES gains java9_series.py's TITLES 01-03, as the registry spells them: " + " · ".join(want))
    rm = rd(os.path.join(track(), "_briefs", "TRACK-ROADMAP.md")).split("\n")
    ok([re.match(r"- 0\d \*\*(.+?)\*\*", rm[i]).group(1) for i in (368, 369, 370)] == want, "the roadmap's :369-371 = those three titles")
    t8 = rd(os.path.join(HERE, "tree28.py")).split('"""', 2)[2]; t7 = rd(os.path.join(REPO, "c8-unit27", "harness", "tree27.py")).split('"""', 2)[2]
    ok(t8 == t7, "tree28.py's code = tree27.py's, byte for byte (the docstring aside)")
    p = open(os.path.join(UNIT, "pinned.txt"), "rb").read()
    ok(p == b"A PATCH to slash customers answers four-oh-five, and its Allow header names POST and GET.\n" and p.count(b"\n") == 1
       and open(os.path.join(REPO, "c8-unit01", "pinned.txt"), "rb").read().endswith(b".\n"),
       "pinned.txt: the sentence, one line, a trailing newline (c8-unit01/pinned.txt's shape) - md5 %s" % md5b(p))
    t = rd(os.path.join(REPO, "c7-unit40", "receipts.sh"))
    ok("PIN7=70ad921 " in t and "# 2026-11-24, Course 8's finale (c8-unit28" in t, "c7-unit40/receipts.sh sets PIN7=70ad921 with its dated comment")
    k = rd(os.path.join(REPO, "c7-unit40", "harness", "chk40.py"))
    ok(k.count("70ad921") == 6 and 'open("../README.md"' not in k and 'block("$ cat ../README.md"' not in k, "c7-unit40/harness/chk40.py: its four lines read 70ad921 (6 mentions, its comment one), 0 reads of ../README.md")
    d = git("diff", "--numstat", BASE, "--", "c7-unit40/harness/chk40.py").split()
    ok(d[:2] == ["5", "4"], "c7-unit40/harness/chk40.py against %s: +5 -4 (four lines and the dated comment) - git says %s" % (BASE, d[:2]))


def readme(L):
    p = git("show", f"{BASE}:c7-unit40/receipts.md5"); p = next(l.split()[1] for l in p.split("\n") if l.startswith("readme "))
    r = pub(os.path.join(REPO, "c7-unit40", "receipts.md5"), "readme")
    m = one(L, r"  the published readme md5 \(git show e65298c:c7-unit40/receipts\.md5\): ([0-9a-f]{32}) · the republished \(\.\./c7-unit40/receipts\.md5\): ([0-9a-f]{32})", "the two md5s")
    ok(m.group(1) == p and m.group(2) == r and p != r, "published %s (git, read again) · republished %s (the file, read again) · they differ" % (p, r))
    one(L, r"  c7-unit40/receipts\.md5's other lines, against e65298c's: the same", "receipts.md5's counts line unchanged")
    oth = [l for l in git("show", f"{BASE}:c7-unit40/receipts.md5").split("\n") if l and not l.startswith("readme ")]
    ok(oth == [l for l in rd(os.path.join(REPO, "c7-unit40", "receipts.md5")).split("\n") if l and not l.startswith("readme ")], "c7-unit40/receipts.md5: only the readme line moved (read again)")
    ok(not any(p in l for l in rd(os.path.join(REPO, "c7-unit40", "receipts.md5")).split("\n")), "the old readme md5 is not left in c7-unit40/receipts.md5")
    m = one(L, r"  readmecap40 \+ its part 4, as shipped: grep -o '\.\./README\.md' -> (\d+) · pinned \(this commit\): (\d+) \((\d+) of them the label\) · git -C \.\. show \$PIN7:README\.md: (\d+)", "the reads")
    ok(m.groups() == ("7", "1", "1", "2"), "the README's reads in readmecap40 + part 4: 7 as shipped -> 1 pinned (the label); $PIN7 named twice - the one read into .harness/readme-$PIN7.md and its shown line (got %s)" % (m.groups(),))
    m = one(L, r"  chk40\.py's reads of the README .*, as shipped: (\d+) · pinned: (\d+) · its reads of 70ad921: (\d+)", "chk40's reads")
    ok(m.groups() == ("2", "0", "6"), "chk40.py's reads of the README: 2 as shipped -> 0 pinned (got %s)" % (m.groups(),))
    m = one(L, r"  md5 ([0-9a-f]{32}) · lines \d+ · = the published ([0-9a-f]{32}): (yes|no)", "part 1")
    ok(m.group(1) == m.group(2) == p and m.group(3) == "yes", "1: the shipped function on the README before this commit = the published %s" % p)
    m = one(L, r"  md5 ([0-9a-f]{32}) · = the published: (yes|no) · the lines that differ from \(1\):", "part 2")
    ok(m.group(1) != p and m.group(2) == "no", "2: the shipped function on the README after: md5 %s != the published" % m.group(1))
    i = L.index(m.group(0)); j = next(k for k in range(i + 1, len(L)) if L[k].startswith("  the shipped chk40.py on it: "))
    dl = [l[4:] for l in L[i + 1:j] if l.startswith("    < ") or l.startswith("    > ")]
    want = ["line 1: ", "the folders its opening maps", "its course sections: ", "its roadmap line: ", "lines the README gained: "]
    ok(len(dl) == 12 and all(any(w in x for x in dl if x.startswith("< ")) and any(w in x for x in dl if x.startswith("> ")) for w in want)
       and "> " + "  its course sections: 2 3 4 5 6 7 8" in dl and any(x.startswith(">   line 1: ") and "*Spring Data beyond JPA*" in x for x in dl)
       and sum(1 for x in dl if "its readme function, run in its own folder: 28 lines" in x and "06ae5dd" in x) == 2,
       "2: the lines that differ - the title, the folders, the sections (2-8 now), the roadmap line's number, gained/lost, part 4's md5: 6 changed, 12 diff lines (got %d)" % len(dl))
    m = one(L, r"  the shipped chk40\.py on it: exit (\d) · its FAIL lines (\d+):", "part 2's chk40")
    i = L.index(m.group(0)); j = L.index(next(l for l in L if l.startswith("3 · ")))
    f2 = [l.strip() for l in L[i + 1:j] if l.startswith("    FAIL ")]
    ok(m.groups() == ("1", "3") and f2 == ["FAIL 1: the folders now + c7-unitNN/", "FAIL 1: the sections now 2-7", "FAIL 1: the title names Data with JPA & Hibernate"],
       "2: the shipped chk40.py on the unpinned capture: exit 1, 3 FAIL lines - the folders, the sections, the title (the failure receipt)")
    m = one(L, r"  before: md5 ([0-9a-f]{32}) · after: md5 ([0-9a-f]{32}) · one md5: (yes|no) · = the republished ([0-9a-f]{32}): (yes|no) · = the published: (yes|no)", "part 3")
    ok(m.group(1) == m.group(2) == r == m.group(4) and m.group(3) == "yes" and m.group(5) == "yes" and m.group(6) == "no",
       "3: the pinned function, README before and after: one md5 %s = the republished, != the published" % r)
    i = L.index("  the lines it differs from the published capture (1) by:"); j = L.index(next(l for l in L if l.startswith("4 · ")))
    d3 = [l[4:] for l in L[i + 1:j] if l.startswith("    < ") or l.startswith("    > ")]
    ok(len(d3) == 6 and "> $ git -C .. show 70ad921:README.md" in d3 and "< $ cat ../README.md" in d3
       and ">   its line under \"and as it is now:\": $ cat ../c7-unit40/.harness/readme-70ad921.md" in d3
       and sum(1 for x in d3 if "its readme function, run in its own folder: 28 lines" in x and "06ae5dd" in x) == 2,
       "3: 3 lines differ from the published (6 diff lines): the shown command, part 4's md5 and its \"as it is now\" line (got %d)" % len(d3))
    k = [one(L, r"  the shipped chk40\.py on \(1\), the README before: exit (\d) · FAIL lines (\d+) · output md5 ([0-9a-f]{32})", "k1")]
    for w in ("before", "after"):
        k.append(one(L, r"  the pinned chk40\.py on \(3\), the README %s: exit (\d) · FAIL lines (\d+) · output md5 ([0-9a-f]{32}) · = the shipped one's on \(1\): (yes|no)" % w, "k3 " + w))
    ok(k[0].group(1) == "0" and k[0].group(2) == "0", "4: the shipped chk40.py on the published capture: exit 0, output md5 %s" % k[0].group(3))
    ok(all(x.group(1) == "0" and x.group(2) == "0" and x.group(3) == k[0].group(3) and x.group(4) == "yes" for x in k[1:]),
       "4: the pinned chk40.py on the pinned capture, README before AND after: exit 0, output byte-equal to the shipped one's on the published capture")
    m = one(L, r"  the pinned chk40\.py on \(2\), the README after \(the control\): exit (\d) · FAIL lines (\d+):", "k4")
    ok(m.groups() == ("1", "6"), "4: the pinned chk40.py on the unpinned capture: exit 1, 6 FAIL lines (the control; got %s)" % (m.groups(),))
    for u, pref in (("c6-unit32", "  c6-unit32: "), ("c5-unit30", "  c5-unit30: ")):
        m = one(L, re.escape(pref) + r"its readme function, run in its own folder: \d+ lines · md5 ([0-9a-f]{32}) · its receipts\.md5's readme: ([0-9a-f]{32}) · the same: yes · \.\./" + u + r"/receipts\.md5's readme ([0-9a-f]{32})", u)
        f = pub(os.path.join(REPO, u, "receipts.md5"), "readme")
        ok(m.group(1) == m.group(2) == m.group(3) == f and git("diff", "--stat", "HEAD", "--", u).strip() == "", "5: %s's pinned function = its receipts.md5's readme %s, the folder untouched" % (u, f))
    blk = []; st = 0
    for l in rd(os.path.join(REPO, "c7-unit40", "README.md")).split("\n"):
        if st == 0 and l.startswith("`.r-readme.out` · md5 "): st = 1; continue
        if st == 1 and l == "```": st = 2; continue
        if st == 2 and l == "```": break
        if st == 2: blk.append(l)
    m = one(L, r"  c7-unit40/README\.md's readme block \(the lines under its heading\): md5 ([0-9a-f]{32}) · its heading: (\d+) line naming the republished md5", "the block")
    ok(m.group(1) == r == md5b(("\n".join(blk) + "\n").encode()) and m.group(2) == "1", "5: c7-unit40/README.md's readme block = the republished capture, byte for byte, its heading naming it")
    i = L.index("$ cat ../README.md")
    R = rd(os.path.join(REPO, "README.md")).split("\n")
    ok(L[i + 1] == "  line 1: " + R[0] and L[i + 3] == "  its course sections: 2 3 4 5 6 7 8"
       and L[i + 2] == "  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/ c7-unitNN/ c8-unitNN/",
       "6: the README read live: the title, the folders + c8-unitNN/, the sections 2-8")
    rl = [l for l in R if l.startswith("Videos publish")]
    ok(len(rl) == 1 and rl == [l for l in git("show", f"{BASE}:README.md").split("\n") if l.startswith("Videos publish")], "6: the roadmap line unchanged by this commit (read again)")
    sec = L[L.index("its Course 8 section, whole:") + 1:]
    ok(sec[:1] == ["  ## Course 8 — Spring Data beyond JPA"] and "(28 units, 5 sections)" in " ".join(sec) and "`18 + 14`" in " ".join(sec)
       and "CVE-2026-123886" in " ".join(sec) and "CVE-2026-59342" in " ".join(sec) and "*REST APIs Done Right*" in " ".join(sec), "6: the Course 8 section: 28 units, 5 sections, 18 + 14, both advisories by ID, the next course by title")
    return sec


def counts(L):
    j8, j9 = reg("java8_series"), reg("java9_series")
    m = one(L, r"  java8_series: len\(TITLES\) (\d+) · len\(SECTIONS\) (\d+)", "the registry")
    ok((int(m.group(1)), int(m.group(2))) == (len(j8.TITLES), len(j8.SECTIONS)) == (28, 5), "28 lessons · 5 sections (java8_series.py, read again)")
    one(L, r"  SECTION_OF as bounds: 1:01-07 2:08-13 3:14-17 4:18-24 5:25-28", "the bounds")
    i = L.index("$ find ../c8-unit[0-9][0-9] -maxdepth 1 -name after -type d | wc -l | tr -d ' '")
    dirs = sorted(d[7:] for d in os.listdir(REPO) if re.fullmatch(r"c8-unit\d\d", d) and os.path.isdir(os.path.join(REPO, d, "after")) and not os.path.islink(os.path.join(REPO, d, "after")))
    links = sorted(d[7:] for d in os.listdir(REPO) if re.fullmatch(r"c8-unit\d\d", d) and os.path.islink(os.path.join(REPO, d, "after")))
    ok(L[i + 1] == "  %d" % len(dirs) and L[i + 2] == "  the units: " + " ".join(dirs), "the anchor changes: %d directories, listed, = os.listdir (the links excluded)" % len(dirs))
    ok(len(dirs) == 19 and dirs == ["02", "07", "08"] + ["%02d" % n for n in range(10, 23)] + ["24", "26", "27"], "the anchor changes: 19 - 02, 07, 08, 10-22, 24, 26, 27")
    ok(L[i + 3].startswith("  after/ as a link (not counted): " + " ".join(links) + " · ") and links == ["23", "25"], "after/ as a link: 23 25 (not counted)")
    ok(any(re.fullmatch(r"  surefire-reports 18 \([^)]*\) \+ surefire-reports-it CustomerEntityRepositoryIT 3 = 21", l) for l in L) and "  tests 18 + 3 IT" in L, "the tests at the course's start: 18 + 3 (c7-unit39/README.md's reports, SETUP-BRIEF :35)")
    ok("  tests 18 + 14, 0 failures" in L, "the tests at the end: 18 + 14, 0 failures (c8-unit27/README.md's bound: line)")
    tot = 0; nu = 0; per = []
    for s in sorted(j8.SECTIONS):
        us = sorted(k for k in j8.SECTION_OF if j8.SECTION_OF[k] == s and k != "28"); n = 0; u = 0
        for k in us:
            f = os.path.join(REPO, "c8-unit%s" % k, "receipts.md5")
            if not os.path.exists(f): continue
            n += sum(1 for l in rd(f).split("\n") if l.split() and not l.split()[0].endswith("-tree")); u += 1
        tot += n; nu += u; per.append("  section %d (%s-%s): %d units · %d captures" % (s, us[0], us[-1], u, n))
    ok(all(x in L for x in per) and "  in all: %d units · %d captures (unit 28 aside: this unit)" % (nu, tot) in L and nu == 27,
       "the captures per section = the receipts.md5 files read again: %s; in all %d units, %d" % ("; ".join(x.split(": ", 1)[1] for x in per), nu, tot))
    for k, h in (("01", md5f(os.path.join(REPO, "c8-unit01", "pinned.txt"))), ("12", md5f(os.path.join(REPO, "c8-unit12", "pinned.txt")))):
        ok(any(re.fullmatch(r"  %s · lines 1 · in its README: [1-9]\d* lines" % h, l) for l in L), "c8-unit%s/pinned.txt: md5 %s, one line, in its README" % (k, h))
    hs = re.search(r"^HANDOFF='(.*)'$", rd(os.path.join(REPO, "c8-unit24", "receipts.sh")), re.M).group(1)
    ok(md5b(hs.encode()) == "a6581dab7e33c458146b1f0e9cb114bc" and "  a6581dab7e33c458146b1f0e9cb114bc · its README's record: 1 line · ../c8-tiffinbox/README.md holds it: 1 line" in L,
       "unit 24's C8-20 sentence: md5 a6581dab..., its README's record, the anchor's README holds it once")
    ok("  %s · lines 1" % md5f(os.path.join(UNIT, "pinned.txt")) in L, "this unit's pinned.txt: md5 read again")
    rules = [int(x) for x in re.findall(r"^- \*\*R\.(\d+)\*\*", rd(os.path.join(track(), "spring-data-beyond-jpa", "_briefs", "STYLE-CONTRACT.md")), re.M)]
    m = one(L, r"  first R\.(\d+) \(line \d+\) · last R\.(\d+) \(line (\d+)\) · rules (\d+) · the numbers consecutive: (yes|no)", "the rules")
    ok((int(m.group(1)), int(m.group(2)), int(m.group(4))) == (min(rules), max(rules), len(rules)) and min(rules) == 343 and m.group(5) == "yes",
       "the rules: R.%s to R.%s (line %s), %s rules, consecutive (the contract, read again)" % (m.group(1), m.group(2), m.group(3), m.group(4)))
    ok("  java9_series: len(TITLES) %d · len(SECTIONS) %d" % (len(j9.TITLES), len(j9.SECTIONS)) in L and (len(j9.TITLES), len(j9.SECTIONS)) == (26, 5), "Course 9: 26 lessons · 5 sections (java9_series.py, read again)")
    for n in ("01", "02", "03"): ok("  TITLES[%s]: %s" % (n, j9.TITLES[n]) in L, "Course 9's TITLES[%s]: %s" % (n, j9.TITLES[n]))
    rl = [l for l in L if re.match(r"  :\d+ grep -n: ", l)]
    ok(len(rl) == 6 and all(" · the same: yes · " in l for l in rl), "the roadmap: 6 lines, each read by number = found by grep (:48 :366 :369 :370 :371 :362)")
    ok("  the roadmap :369-371 = java9_series TITLES 01-03: yes" in L and "  the roadmap :366 = java9_series: REST APIs Done Right · 26 units · 5 sections · equal: yes" in L
       and "  the track (:48): 19 courses" in L, "the roadmap = the registry: Course 9's three titles, 26 · 5; the track 19 courses")
    one(L, r"  \.\./c8-unit27/receipts\.md5 lines naming mappings: 0 · \.\./c8-unit27/README\.md's line on the flag runs: 1 · not captured in 27, not said", "17 not captured in 27")
    c14 = [l for l in L if l.startswith("  said")]
    ok(len(c14) == 7 and all(" equal" in l and l.endswith(": yes") for l in c14[:6]) and "NOT FOUND" not in " ".join(c14) and c14[6].startswith("  said: Course eight of nineteen, twenty-eight lessons in five sections: found"),
       "C8-14: 4 titles, 2 sections, the counts - each found in Course 7's finale's lines and equal to the registry")
    one(L, r"  C8-14: every title, section and count the last finale said equals the registry now - nothing to correct", "C8-14's verdict")
    i = L.index("$ grep -rlE 'org\\.springframework\\.data\\.(mongodb\\.repository\\.(Query|Aggregation)|elasticsearch\\.annotations\\.Query)' --include='*.java' anchor/ | wc -l | tr -d ' '")
    ok(L[i + 1] == "  0", "⚑17: 0 files of the anchor import a MongoDB or Elasticsearch string annotation")
    one(L, r"  the anchor's @Query lines, all JPQL or SQL sums with no parameter: 4 · with a parameter \(:name or \?1\): 0", "the @Query lines")
    one(L, r"  the jar's module versions \(unzip -l, BOOT-INF/lib\): spring-data-elasticsearch-6\.1\.2\.jar spring-data-mongodb-5\.1\.2\.jar · Spring Boot \(the anchor's pom\.xml parent\): 4\.1\.2", "the versions")
    known = (r"^\$ |^the |^  (len\(|section |SECTION_OF|TITLES\[|\d+$|the units: |after/ as a link|surefire-reports |tests 18 |in all: |[0-9a-f]{32} · |first R\.|:\d+ grep -n: |the roadmap |the track |\.\./c8-unit27/|said|C8-14: |java[89]_series: |the anchor's @Query|the jar's |0$)|^C8-14 ")
    bad = [l for l in L if l and not re.match(known, l)]
    ok(not bad, "every line of the capture parsed or skipped by a named rule (unparsed: %s)" % bad[:2])


def show_api(o):
    d = json.load(open(os.path.join(o, "mappings.json"), encoding="utf-8"))
    ent = [e for c in d["contexts"].values() for e in c["mappings"]["dispatcherServlets"]["dispatcherServlet"]]
    own, aside = [], {}
    for e in ent:
        h = (e.get("details") or {}).get("handlerMethod") or {}; rc = (e.get("details") or {}).get("requestMappingConditions") or {}
        cn = h.get("className") or ""
        if cn.startswith("com.tiffinbox."):
            own.append((",".join(rc.get("methods") or []), ",".join(rc.get("patterns") or []), cn.rsplit(".", 1)[1] + "#" + h.get("name", "")))
        else:
            k = "Boot's actuator" if ".actuate." in cn else "Boot's error controller" if "ErrorController" in cn else "static resources" if "ResourceHttpRequestHandler" in str(e.get("handler")) else "other"
            aside[k] = aside.get(k, 0) + 1
    g = sum(1 for x in own if x[0] == "GET"); p = sum(1 for x in own if x[0] == "POST")
    print("the handler methods - /actuator/mappings, the dispatcherServlet's list; the rule: TiffinBox's own = a handlerMethod whose className is com.tiffinbox.*:")
    print("  entries %d · TiffinBox's own %d (GET %d · POST %d · other %d) · set aside: %s" % (len(ent), len(own), g, p, len(own) - g - p, " · ".join("%s %d" % kv for kv in sorted(aside.items()))))
    for x in sorted(own): print("  %-5s %-18s %s" % x)
    for l, m, path in (("patch", "PATCH", "/customers"), ("delete", "DELETE", "/customers/Ravi"), ("apidocs", "GET", "/v3/api-docs"), ("swagger", "GET", "/swagger-ui.html"), ("actuator", "GET", "/actuator")):
        hd = open(os.path.join(o, l + ".hdr"), encoding="utf-8").read().replace("\r", "").split("\n")
        al = [x.split(":", 1)[1].strip() for x in hd if x.lower().startswith("allow:")]
        ct = [x.split(":", 1)[1].strip() for x in hd if x.lower().startswith("content-type:")]
        code = open(os.path.join(o, l + ".code")).read().strip(); body = open(os.path.join(o, l + ".body"), encoding="utf-8").read()
        try: b = json.dumps(json.loads(body), sort_keys=True)
        except ValueError: b = "(not JSON, %d bytes)" % len(body)
        if l == "actuator": b = "links: " + " ".join(sorted(json.loads(body)["_links"]))
        print("%s %s -> %s · Allow (as a set, sorted): %s · Content-Type: %s · body %s" % (m, path, code, ", ".join(sorted(t.strip() for a in al for t in a.split(","))) or "none", ct[0] if ct else "none", b))


def api(L):
    m = one(L, r"  entries (\d+) · TiffinBox's own (\d+) \(GET (\d+) · POST (\d+) · other (\d+)\) · set aside: (.*)", "the handler methods")
    rows = [l for l in L if re.match(r"  (GET|POST|PUT|PATCH|DELETE) +/", l)]
    ok(m.group(2) == "12" and (m.group(3), m.group(4), m.group(5)) == ("8", "4", "0") and len(rows) == 12
       and sum(1 for r in rows if r.split()[0] == "GET") == 8 and sum(1 for r in rows if r.split()[0] == "POST") == 4,
       "12 handler methods of TiffinBox's own (GET 8 · POST 4), each listed - the rest set aside by the rule (%s)" % m.group(6))
    ok(all("com.tiffinbox" not in r and "#" in r for r in rows) and int(m.group(1)) == 12 + sum(int(x.rsplit(" ", 1)[1]) for x in m.group(6).split(" · ")), "the entries = TiffinBox's 12 + the set-aside ones")
    m = one(L, r"PATCH /customers -> (\d+) · Allow \(as a set, sorted\): ([A-Z, ]+) · Content-Type: (\S+) · body (.*)", "PATCH")
    ok(m.group(1) == "405" and m.group(2) == "GET, POST" and m.group(3) == "application/problem+json" and json.loads(m.group(4)).get("detail") == "Method 'PATCH' is not supported.",
       "PATCH /customers -> 405, Allow {GET, POST}, application/problem+json, \"Method 'PATCH' is not supported.\"")
    m = one(L, r"DELETE /customers/Ravi -> (\d+) · Allow \(as a set, sorted\): ([A-Z, ]+) · Content-Type: (\S+) · body .*", "DELETE")
    ok(m.groups() == ("405", "GET", "application/problem+json"), "DELETE /customers/Ravi -> 405, Allow {GET}")
    for pth in ("/v3/api-docs", "/swagger-ui.html"):
        m = one(L, r"GET %s -> (\d+) · Allow \(as a set, sorted\): none · .*" % re.escape(pth), pth)
        ok(m.group(1) == "404", "GET %s -> 404 (TiffinBox publishes no contract today)" % pth)
    one(L, r"GET /actuator -> 200 · .* · body links: health health-path mappings prometheus self", "the flag run's links: health, prometheus, mappings")
    one(L, r"  readiness 200 · TiffinBox listened on: 127\.0\.0\.1:20670 · stopped by POST /shutdown: \{\"stopping\":true\} · exit 0 · listening on 20670 now: 0", "the JVM: 127.0.0.1:20670 alone, stopped by its token")
    pin = open(os.path.join(UNIT, "pinned.txt"), encoding="utf-8").read().rstrip("\n")
    pm = re.fullmatch(r"A PATCH to slash customers answers four-oh-five, and its Allow header names (\w+) and (\w+)\.", pin)
    pa = one(L, r"PATCH /customers -> (\d+) · Allow \(as a set, sorted\): ([A-Z, ]+) · .*", "PATCH again")
    ok(pm is not None and pa.group(1) == "405" and sorted([pm.group(1), pm.group(2)]) == pa.group(2).split(", ") and ("  " + pin) in L and "  md5 -q pinned.txt: %s" % md5f(os.path.join(UNIT, "pinned.txt")) in L,
       "the pinned sentence's facts = this capture: four-oh-five, its Allow header {POST, GET} (a set: the order is the JVM's)")
    t = [l for l in L if re.match(r"  (customer-form|fragments|[a-z-]+)\.html:\d+:@\{/", l)]
    ok(any("@{/customers}" in l for l in t) and any("@{/customers/new}" in l for l in t) and any("@{/dashboard}" in l for l in t), "the callers: its pages - the /customers form, /customers/new, /dashboard")
    ok(any(re.match(r"  TiffinBoxWebTest\.java:\d+$", l) for l in L) and sum(1 for l in L if re.match(r"  \d+:req GET ", l)) == 6, "the callers: its tests; the seven (six GETs and POST /shutdown in ../c5-unit11/curlset.sh)")


try:
    mode = sys.argv[1]
    if mode == "static": static()
    elif mode == "show" and sys.argv[2] == "api": show_api(sys.argv[3]); sys.exit(0)
    else:
        L = rd(sys.argv[2]).split("\n")
        {"readme": readme, "counts": counts, "api": api}[mode](L)
except SystemExit:
    raise
except Exception as e:   # a check that cannot run is a failed check - its line, never a traceback
    BAD.append("FAIL %s: the check could not run (%s: %s)" % (sys.argv[1:2], type(e).__name__, str(e)[:160]))
for l in OUT + BAD: print(l)
sys.exit(1 if BAD or not OUT else 0)

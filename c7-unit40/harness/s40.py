"""Unit 40's prose gate, per sentence (python3 -I -B harness/s40.py harness/dur7.py COUNTS-BLOCK FILE...), with a self-test that must
pass first. Carried from unit 39's s39 (dur7's words, S4.7's duration meanings, the speed words, a typed md5, a password in prose,
"Hibernate generates"), with the finale's own rules: (1) a typed count - a number (digits, or a word from three up) right before a
counting noun - must be a number the counts capture prints (COUNTS-BLOCK: README.md's published counts block; its folder and unit
lists are names, not counts, and are left out) - the finale gate's rule applied to the README, so the script inherits clean numbers;
(2) "Hibernate generates" is allowed in ONE sentence only, the retirement's (it says "retire"); the grep's own line quotes its pattern in
a code span, which this gate does not judge; a third site - any other sentence - is refused; (3) "nothing to correct" only in a
sentence that names C7-12; (4) a typed md5 (32 hex digits, or 8 and an ellipsis) only if a capture block, a receipts.md5 this unit
reads, or receipts.sh prints or pins it. Lines inside a fenced block and the values/runs blocks are the runs' own text (receipts.sh
checks them) and are not judged here; nor is a `code span` for the word checks (the md5 check reads the raw sentence)."""
import importlib.util, os, re, sys
spec = importlib.util.spec_from_file_location("dur7", sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
FAM = re.compile(r"\b(?:forever|for ever|at once|immediately|instantly|instant(?:ly)?|right away|in no time|a moment|momentar(?:y|ily)|"
                 r"(?:one|two|three|four|five|six|seven|eight|nine|ten|\d+)\s+(?:second|minute|hour)s?|half a second|eventually)\b", re.I)
SPEED = re.compile(r"\b(?:slow(?:er|ly)?|quick(?:er|ly)?|lag|faster|fast)\b", re.I)
WORDS = {w: i for i, w in enumerate("zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen "
                                     "seventeen eighteen nineteen".split())}
TENS = {"twenty": 20, "thirty": 30, "forty": 40, "fifty": 50, "sixty": 60, "seventy": 70, "eighty": 80, "ninety": 90}
NUMW = r"(?:(?:twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety)(?:-(?:one|two|three|four|five|six|seven|eight|nine))?|" + "|".join(WORDS) + r")"
NOUN = (r"(?:units?|lessons?|sections?|folders?|after folders|anchor changes?|changes to the anchor|captures?|tests?|scripts?|hits?|files?|"
        r"lines?|courses?|words?|hashes|rows?|titles?|FAIL lines|reads?|sentences?)")
TYPED = re.compile(r"(?<![\w.#:/-])(\d+|" + NUMW + r")\s+(?:new\s+|more\s+|built\s+|unit\s+)?" + NOUN + r"\b", re.I)
HASH = re.compile(r"\b[0-9a-f]{32}\b|\b[0-9a-f]{8}…")
PWD = re.compile(r"password=(?!<pw>|\*)", re.I)
GEN = re.compile(r"\bHibernate generates\b", re.I)
RETIRE = re.compile(r"\bretire", re.I)
NTC = re.compile(r"\bnothing to correct\b", re.I)


def val(t):
    t = t.lower()
    if t.isdigit(): return int(t)
    if t in WORDS: return WORDS[t]
    a, _, b = t.partition("-"); return TENS[a] + (WORDS[b] if b else 0)


def allowed_from(block):
    keep = [l for l in block.split("\n") if not l.startswith("  the folders: ") and not re.match(r"  [0-9a-f]{32} units ", l)]
    return {int(x) for x in re.findall(r"(?<![0-9a-f])\d+(?![0-9a-f])", "\n".join(keep))}


def hashes_from(texts):
    return set(re.findall(r"[0-9a-f]{32}", "\n".join(texts)))


GENSEEN = [0]


def verdicts(s, raw, NUMS, HS):
    out = []
    for w in m.DUR.finditer(s): out.append("dur7: " + w.group(0))
    for w in FAM.finditer(s): out.append("S4.7's family: " + w.group(0))
    for w in SPEED.finditer(s):
        if not m.DUR.search(w.group(0)): out.append("a speed word: " + w.group(0))
    for t in TYPED.finditer(s):
        v = val(t.group(1))
        if v >= 3 and v not in NUMS: out.append("a typed count, not in the counts capture: " + t.group(0))
    for h in HASH.finditer(raw):
        x = h.group(0).rstrip("…")
        if not any(k.startswith(x) for k in HS): out.append("a typed md5 no capture prints: " + h.group(0))
    if PWD.search(raw): out.append("a password in prose")
    if GEN.search(s):
        if RETIRE.search(s) and GENSEEN[0] == 0: GENSEEN[0] = 1
        else: out.append("\"Hibernate generates\" outside the retirement's one sentence")
    if NTC.search(s) and "C7-12" not in raw: out.append("\"nothing to correct\" away from C7-12's comparison")
    return out


def run_cases():
    N = allowed_from("  15\n  before Section 6 (units 01-34): 12 · in Sections 6 and 7 (35-40): 3\n  the folders: 03 06 07 09 15 16 17\n  40\n  scripts: 34 · scripts holding it: 0\n  surefire-reports 18 + 3 = 21\n  Course 8: Spring Data beyond JPA · 28 units · 5 sections\n  len(TITLES) 40 · len(SECTIONS) 7")
    H = {"68a6fc68d166b539919751ffe4774324"}
    cases = [("The course changed the anchor in 15 after folders.", 0), ("The anchor changed in 16 anchor changes.", 1), ("It has forty units and seven sections.", 0),
             ("It has forty-one units.", 1), ("Course 8 has 28 units in 5 sections.", 0), ("Course 8 has 29 units.", 1), ("The README gained 11 lines.", 1),
             ("34 scripts hold it 0 times.", 0), ("The capstone runs 21 tests.", 0), ("The capstone runs 22 tests.", 1), ("Two units moved it.", 0),
             ("The pin is `68a6fc68d166b539919751ffe4774324`.", 0), ("The md5 is 4e4241ddf3eb8a044c7762a1938ee54e.", 1), ("It was 68a6fc68…, measured.", 0), ("It was 1234abcd…, typed.", 1),
             ("It renders quickly.", 1), ("It ran at once.", 1), ("It took 3 seconds.", 1), ("`password=hunter2` is a plant.", 1),
             ("C7-12: nothing to correct, derived from the comparison line.", 0), ("There is nothing to correct.", 1),
             ("R.176 and S6.15 and #1809 and :324 and c7-unit39 are names.", 0)]
    for t, want in cases:
        got = verdicts(re.sub(r"`[^`]*`", "`…`", t), t, N, H)
        assert bool(got) == bool(want), (t, got)
    GENSEEN[0] = 0
    assert not verdicts("The course retires the words Hibernate generates.", "", N, H)
    assert verdicts("Here Hibernate generates the schema.", "", N, H)          # a second site, after the retirement's
    GENSEEN[0] = 0
    assert verdicts("Hibernate generates the schema.", "", N, H)               # no retirement word: refused even first
    GENSEEN[0] = 0
    return len(cases) + 3


ncases = run_cases()
block = open(sys.argv[2], encoding="utf-8").read()
NUMS = allowed_from(block)
here = os.path.dirname(os.path.abspath(sys.argv[2]))
srcs = [block]
for f in ("receipts.md5", "../c6-unit32/receipts.md5", "../c5-unit30/receipts.md5", "receipts.sh", ".harness/block-readme.txt"):
    if os.path.exists(f): srcs.append(open(f, encoding="utf-8").read())
HS = hashes_from(srcs)
n = 0
def judge(p, start, para):
    global n
    text = " ".join(x.strip() for x in para)
    for s in re.split(r"(?<=[.;!?])\s+", text):
        for v in verdicts(re.sub(r"`[^`]*`", "`…`", s), s, NUMS, HS):
            n += 1; print("  %s line %d: %s" % (p, start, v))
MK = ("<!-- values: begin -->", "<!-- values: end -->", "<!-- runs: begin -->", "<!-- runs: end -->")
for p in sys.argv[3:]:
    fence = False; vals = False; para = []; start = 0
    for i, l in enumerate(open(p, encoding="utf-8"), 1):
        mk = l.strip() in MK
        brk = l.startswith("```") or mk or not l.strip() or l.startswith(("#", "- ", "| "))
        if brk or fence or vals:
            if para: judge(p, start, para); para = []
        if l.startswith("```"): fence = not fence; continue
        if l.strip() in (MK[0], MK[2]): vals = True; continue
        if l.strip() in (MK[1], MK[3]): vals = False; continue
        if fence or vals or not l.strip(): continue
        if not para: start = i
        para.append(l)
    if para: judge(p, start, para)
print("self-test: %d cases · refused: %d" % (ncases, n))

"""u23check.py [--derive] TABLE.md - unit 23's checker (S8.86, S8.97): the decision table, read cell by cell.

The table is five rows (the stores this course ran) by five body cells (the failure modes). A body cell is either the word
`unmeasured`, or one or more capture references `` `unitNN/<capture>` ``, each followed by a colon and the words and numbers that
capture printed. A reference RESOLVES when ../../c8-unitNN/README.md holds the section header "### N · <capture>" and
../../c8-unitNN/receipts.md5 holds the line "<capture> <md5>" - the capture exists, shipped by an earlier unit. A cell is BAD when:
  - it holds a feature word (FEATURE) or a member of XFAM_S4B's unit 23 families (XFAM_S4B_U23, byte-equal to s822.py's lines);
  - it holds a ranking word (RANK);
  - a reference does not resolve, or names unit 23 or a later unit (S8.97: only a capture of a unit built before 23);
  - a reference's text holds no number and no "exit" (a cell is the number its capture printed);
  - a number in a reference's text is not a number that capture's text blocks print (the capture printed something else);
  - `unit01/alone` stands in the cost column (it printed an exit 1, never a count: refused by name);
  - it says `unmeasured` where KNOWN - this checker's own list, built from the shipped table's resolved cells - holds a capture
    for that store and column (the exercise's rule: "unmeasured" passes only where no capture exists);
  - it is neither `unmeasured` nor a reference.
Exit 0 when no cell is bad; 1 with "bad N" and each bad cell named; 2 when the table is not five rows of five body cells.
--derive prints, for every reference, its unit, its README section line, its md5 line, and each number beside the line of the
capture that printed it. The self-test (each rule shown failing on a two-row sketch, its control passing) runs first, every time;
a failed self-test exits 3."""
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
STORES = ["PostgreSQL", "Caffeine", "Redis", "MongoDB", "Elasticsearch"]
COLS = ["a silent wrong answer", "the store absent at start", "a write outside the transaction", "a default that does nothing", "a cost that grows"]
FEATURE = re.compile(r"\b(?:powerful|fast|scalable|flexible|rich|robust|easy|modern|blazing|real-time|instant|smart|seamless|best|better|faster|right tool)\b", re.I)
XFAM_S4B_U23 = {
    "S4B: best database / right tool (U23)": (r"\bbest database\b|\bright tool for the job\b|\bNoSQL is (?:faster|better)\b|\bSQL (?:doesn't|does not|can't|cannot) scale\b|\buse \w+ for \w+\b", None),
    "S4B: a vector store promise (flag 10)": (r"\bvector (?:store|database|search)\b(?![^.;]*\bthis course does not build\b)", None),
}
RANK = re.compile(r"\b(?:wins?|beats?|better than|worse than)\b", re.I)
REF = re.compile(r"`unit(\d\d)/([a-z0-9]+)`")
NUM = re.compile(r"(?<![\w.])\d+(?![\w])")
# the shipped table's resolved cells, by (store, column): the captures this course printed for them
KNOWN = {
    ("PostgreSQL", "a cost that grows"): ["unit01/statements", "unit18/oneread", "unit18/rename"],
    ("Caffeine", "a silent wrong answer"): ["unit12/stale"], ("Caffeine", "a default that does nothing"): ["unit10/nonames"],
    ("Caffeine", "a cost that grows"): ["unit12/stampede"],
    ("Redis", "a silent wrong answer"): ["unit16/dropped"], ("Redis", "the store absent at start"): ["unit14/absent"],
    ("Redis", "a write outside the transaction"): ["unit17/otherholder"], ("Redis", "a default that does nothing"): ["unit15/stale"],
    ("MongoDB", "a silent wrong answer"): ["unit19/silent"], ("MongoDB", "the store absent at start"): ["unit18/absent"],
    ("MongoDB", "a write outside the transaction"): ["unit20/notone"], ("MongoDB", "a default that does nothing"): ["unit20/noindex"],
    ("MongoDB", "a cost that grows"): ["unit20/shapes"],
    ("Elasticsearch", "a silent wrong answer"): ["unit21/nohit"], ("Elasticsearch", "the store absent at start"): ["unit22/absent"],
    ("Elasticsearch", "a write outside the transaction"): ["unit22/drift"], ("Elasticsearch", "a default that does nothing"): ["unit22/stale"],
    ("Elasticsearch", "a cost that grows"): ["unit21/sayso"],
}
CACHE = {}


def section(unit, cap):
    """The unit's README section for the capture (its line number and its text blocks' lines) and its receipts.md5 line, or None."""
    k = (unit, cap)
    if k in CACHE: return CACHE[k]
    d = os.path.join(REPO, "c8-unit" + unit)
    res = None
    try:
        lines = open(os.path.join(d, "README.md"), encoding="utf-8").read().split("\n")
        md5 = [l.strip() for l in open(os.path.join(d, "receipts.md5"), encoding="utf-8") if l.split()[:1] == [cap]]
    except OSError:
        lines, md5 = [], []
    for i, l in enumerate(lines):
        if re.match(r"^### \d+ · " + re.escape(cap) + r"(?![\w-])", l):
            j = i + 1; text = []; fence = False
            while j < len(lines) and not lines[j].startswith(("### ", "## ")):
                if lines[j].startswith("```"):
                    fence = lines[j].strip() == "```text" if not fence else False
                elif fence:
                    text.append(lines[j])
                j += 1
            if md5 and len(md5[0].split()) == 2 and re.fullmatch(r"[0-9a-f]{32}", md5[0].split()[1]):
                res = (i + 1, md5[0], text)
            break
    CACHE[k] = res
    return res


WORD = re.compile(r"[A-Za-z_][\w]*")


def found(block, before, x, after):
    """The capture line that printed the number x beside the cell's own word: the word before x in the cell, within forty characters
    before x on a line of the capture, or the word after x, within forty after it (the first word the cell holds on that side);
    with no word on either side, x anywhere as a number. Returns (the line, x's offset) or None."""
    wb = WORD.findall(before); wa = WORD.findall(after)
    pats = []
    if wb: pats.append(r"\b" + re.escape(wb[-1]) + r"\b.{0,40}?(?<![\w.])(" + x + r")(?![\w])")
    if wa: pats.append(r"(?<![\w.])(" + x + r")(?![\w]).{0,40}?\b" + re.escape(wa[0]) + r"\b")
    if not pats: pats.append(r"(?<![\w.])(" + x + r")(?![\w])")
    for pat in pats:
        for l in block:
            m = re.search(pat, l.strip(), re.I)
            if m: return l.strip(), m.start(1)
    return None


def klass(unit):
    u = int(unit)
    return "1-3" if u <= 17 else "4A" if u <= 20 else "4B"


def judge(store, col, cell, derive=None):
    """The reasons a cell is bad (an empty list: the cell is good)."""
    why = []
    if cell == "unmeasured":
        if (store, col) in KNOWN: why.append("unmeasured, but a capture exists for it: " + ", ".join(KNOWN[(store, col)]))
        return why
    if FEATURE.search(cell): why.append("a feature word: " + FEATURE.search(cell).group(0))
    for name, (rx, okr) in XFAM_S4B_U23.items():
        if re.search(rx, cell, re.I) and not (okr and re.search(okr, cell, re.I)): why.append("XFAM_S4B: " + name)
    if RANK.search(cell): why.append("a ranking word: " + RANK.search(cell).group(0))
    refs = list(REF.finditer(cell))
    if not refs or not cell.startswith("`unit"):
        why.append("neither unmeasured nor a capture reference")
        return why
    for n, r in enumerate(refs):
        unit, cap = r.group(1), r.group(2)
        txt = cell[r.end(): refs[n + 1].start() if n + 1 < len(refs) else len(cell)]
        if int(unit) >= 23:
            why.append("unit%s/%s: a capture of unit %s - S8.97 cites only a unit built before 23" % (unit, cap, int(unit))); continue
        if unit == "01" and cap == "alone" and col == "a cost that grows":
            why.append("unit01/alone in the cost column: it printed an exit 1 and a missing jar, never a count"); continue
        s = section(unit, cap)
        if s is None:
            why.append("unit%s/%s does not resolve (no README section \"### N · %s\" or no receipts.md5 line)" % (unit, cap, cap)); continue
        nums = NUM.findall(txt)
        if not nums and "exit" not in txt:
            why.append("unit%s/%s: no number and no exit beside it" % (unit, cap)); continue
        blk = "\n".join(s[2]); sub = []
        for m in NUM.finditer(txt):
            x = m.group(0); hit = found(s[2], txt[:m.start()], x, txt[m.end():])
            if not hit:
                why.append("unit%s/%s: %s is not a number its capture printed beside its word" % (unit, cap, x))
            else:
                l, p = hit
                sub.append("    %s <- %s" % (x, ("…" if p > 60 else "") + l[max(0, p - 60): p + 50] + ("…" if p + 50 < len(l) else "")))
        if derive is not None:
            derive.append("  unit%s/%s · class %s · c8-unit%s/README.md :%d · receipts.md5 \"%s\" · numbers %s" % (unit, cap, klass(unit), unit, s[0], s[1], " ".join(nums) or "(exit)"))
            derive.extend(sub)
        if not blk: why.append("unit%s/%s: its section holds no text block" % (unit, cap))
    return why


def parse(text, nrows=5):
    rows = [l for l in text.split("\n") if l.startswith("|")]
    if len(rows) != nrows + 2: return None
    head = [c.strip() for c in rows[0].strip().strip("|").split("|")]
    if head != ["store"] + COLS: return None
    out = []
    for r in rows[2:]:
        c = [x.strip() for x in r.strip().strip("|").split("|")]
        if len(c) != 6 or c[0] not in STORES: return None
        out.append(c)
    if nrows == 5 and [c[0] for c in out] != STORES: return None
    return out


def check(text, nrows=5, derive=False, quiet=False):
    rows = parse(text, nrows)
    if rows is None: return None
    bad = 0; meas = 0; unm = []; cls = {"1-3": 0, "4A": 0, "4B": 0}; mixed = []; lines = []
    for c in rows:
        for i, col in enumerate(COLS):
            d = [] if derive else None
            why = judge(c[0], col, c[i + 1], d)
            if c[i + 1] == "unmeasured" and not why: unm.append(c[0] + " · " + col)
            elif not why:
                meas += 1
                k = [klass(r.group(1)) for r in REF.finditer(c[i + 1])]
                cls[k[0]] += 1
                if len(set(k)) > 1: mixed.append(c[0] + " · " + col + " (" + " + ".join(dict.fromkeys(k)) + ")")
            if derive:
                lines.append("cell %s · %s: %s" % (c[0], col, "unmeasured" if c[i + 1] == "unmeasured" else "%d capture(s)" % len(REF.findall(c[i + 1]))))
                lines.extend(d)
            if why:
                bad += 1; lines.append("BAD %s · %s: %s" % (c[0], col, " | ".join(why)))
    return bad, meas, unm, cls, mixed, lines, len(rows) * 5


H2 = "| store | " + " | ".join(COLS) + " |\n|---|---|---|---|---|---|\n"


def sketch(pg, es):
    return H2 + "| PostgreSQL | " + " | ".join(pg) + " |\n| Elasticsearch | " + " | ".join(es) + " |\n"


PG = ["unmeasured"] * 4 + ["`unit18/rename`: the three tables, UPDATE 30"]
ES = ["`unit21/nohit`: veg, 0 hits", "`unit22/absent`: the JVM's exit 1", "`unit22/drift`: intx, rows 0 / index 1", "`unit22/stale`: the count that follows it -> 0", "`unit21/sayso`: _analyze \"Vegetarian\" -> 9"]


def es(cell): return ES[:0] + [cell] + ES[1:]


SELF = [  # (what the case shows, the two-row sketch, the bad count it must give)
    ("control: the two-row sketch as written", sketch(PG, ES), 0),
    ("a feature word in a cell that names its capture and its number", sketch(PG, es("`unit21/nohit`: veg, 0 hits, powerful full-text search")), 1),
    ("a capture that does not resolve", sketch(PG, es("`unit21/nohits`: veg, 0 hits")), 1),
    ("unmeasured where the checker's list holds a capture", sketch(PG, es("unmeasured")), 1),
    ("control: unmeasured where no capture exists", sketch(["unmeasured"] * 4 + PG[4:], ES), 0),
    ("a ranking word in a row", sketch(PG, es("`unit21/nohit`: veg, 0 hits, PostgreSQL wins")), 1),
    ("a capture with no number beside it", sketch(PG, es("`unit21/nohit`: veg finds nothing")), 1),
    ("a number its capture did not print", sketch(PG, es("`unit21/nohit`: veg, 7 hits")), 1),
    ("unit01/alone in the cost column (an exit 1 is not a cost)", sketch(PG[:4] + ["`unit01/alone`: exit 1"], ES), 1),
    ("a later unit's capture (S8.97)", sketch(PG, es("`unit24/dual`: rows 1")), 1),
    ("XFAM_S4B's unit 23 member in a cell", sketch(PG, es("`unit21/nohit`: veg, 0 hits; use Elasticsearch for search")), 1),
    ("the exercise's broken cell", sketch(PG, es("powerful full-text search")), 1),
]


def selftest():
    fails = []
    for what, t, want in SELF:
        r = check(t, nrows=2)
        if r is None or r[0] != want: fails.append("%s: bad %s, want %d" % (what, None if r is None else r[0], want))
    return fails


def main(argv):
    derive = "--derive" in argv
    args = [a for a in argv if a != "--derive"]
    f = selftest()
    if f:
        print("self-test FAILED: " + "; ".join(f)); return 3
    print("self-test: %d cases, each rule failing on a two-row sketch, the controls passing" % len(SELF))
    if len(args) != 1:
        print("usage: u23check.py [--derive] TABLE.md"); return 2
    try:
        text = open(args[0], encoding="utf-8").read()
    except OSError as e:
        print("cannot read the table: %s" % e); return 2
    r = check(text, derive=derive)
    if r is None:
        print("malformed: the table must be the header, the separator and five rows (%s) of five body cells" % ", ".join(STORES)); return 2
    bad, meas, unm, cls, mixed, lines, n = r
    for l in lines: print(l)
    if derive:
        print("unmeasured (%d): %s" % (len(unm), "; ".join(unm)))
        print("measured by the unit's section (the first capture of a cell): Sections 1-3 %d · Section 4 Part A %d · Section 4 Part B %d · a cell with captures of two sections: %s" % (cls["1-3"], cls["4A"], cls["4B"], "; ".join(mixed) or "none"))
    print("cells %d · measured %d · unmeasured %d · bad %d" % (n, meas, len(unm), bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

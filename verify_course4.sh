#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# verify_course4.sh — runs every command the Spring Framework Core (`c4-*`)
# READMEs give a viewer, from the clone it sits in, and says PASS/FAIL for each.
#
#   ./verify_course4.sh                 # c4-tiffinbox and every c4-unitNN folder that exists
#   ./verify_course4.sh 05 17           # only units 05 and 17 (unit numbers, not a range)
#   ./verify_course4.sh tiffinbox       # only c4-tiffinbox (the long-lived project)
#   ./verify_course4.sh tiffinbox 31 32 # the project and the two units that rewire and dissect it
#   KEEP_M2=1 ./verify_course4.sh       # keep every .m2-demo/ (and the .cp / cp.txt that point
#                                       #   into them) for a warm re-run; without it the run
#                                       #   leaves the tree exactly as it found it
#   KEEP_WORK=1 ./verify_course4.sh     # keep the scratch directory with every capture this run took
#   C4_CENTRAL_CACHE=off ./verify_course4.sh
#                                       # resolve straight from Maven Central instead of through the
#                                       #   caching proxy this script starts on 127.0.0.1:18499 (see
#                                       #   "a caching proxy of Central" below: a cold full run is ~40 cold
#                                       #   repositories, and Central answers that with HTTP 429)
#
# WHAT IS CHECKED, and how, per kind of unit:
#
#   * c4-unit01 … c4-unit12 have no receipts.sh. Their READMEs print the commands in a fenced
#     block and quote md5s in the prose. This script holds each command as the README prints it,
#     asserts the README still prints it, and runs it — three times, because every one of those
#     md5s is quoted "3/3" — keeping stdout AND stderr (the author's captures do). A capture the
#     README says went "through chain.py" / "through stamp.py" goes through the unit's OWN copy of
#     that filter before it is hashed. The md5 each capture is compared with is READ OFF THE README
#     at run time (the Nth 32-hex string after a fixed anchor), never transcribed into this file —
#     so an edited README hash is a FAIL, not a stale green line.
#   * c4-unit13 ships flip.sh instead of receipts.sh; its README commands are run directly.
#   * c4-unit14 … c4-unit32 ship receipts.sh. It is run, and PASSes only on exit 0. Then every
#     capture's md5 on receipts.sh's own output is compared with the hash the unit's README
#     publishes, its "3/3" is required (several receipts.sh print "*** DRIFTS ***" and still exit 0),
#     the exit code the README states is required, and units 31-32 are also held to receipts.md5
#     (their receipts.sh prints "DIFFERS from the published" and still exits 0 — "information, not a
#     failure" on another machine, which on THIS clone would be a quiet false green).
#   * README panels — the console output a README prints under a command — are compared line by
#     line with the capture (panel.py below: exact, then blank-collapsed, then "<- note" and "…"
#     elisions honoured, then a wrapped line as a substring). Only panels that ARE output are held.
#   * Every exercise: its start state as the README prints it, then the shipped solution file laid
#     over a COPY of the exercise (`c4-unitNN/.verify-solution/`, same depth, so the space in the
#     path and every relative path are the same) — never over the tracked file.
#   * "Reproducible offline" claims (units 01-12) are a PAIR, as in verify_course3.sh: the ordinary
#     online `verify` into the unit's own .m2-demo first, then the same with `-o`. The README prints
#     `mvn -o -B verify` bare; the only difference here is the quoted -Dmaven.repo.local the rest of
#     the README uses — a bare one would read ~/.m2, which this script never touches.
#
# RULES THIS SCRIPT KEEPS
#   1. Nothing is assumed warm. Every unit resolves into the .m2-demo its README names, so a fresh
#      clone downloads (network allowed) — that is the point of running from a fresh clone. The
#      downloads go through a local caching proxy of Central by default (C4_CENTRAL_CACHE, below);
#      every .m2-demo still starts empty and is filled by Maven's own resolver, over HTTP.
#   2. Your real ~/.m2 is never written. c4-tiffinbox's README prints plain `mvn -B clean install`;
#      here it carries -Dmaven.repo.local="c4-tiffinbox/.m2-demo" (the path the root .gitignore
#      names for it). ~/.m2/repository/com/tiffinbox is asserted unchanged at the end.
#   3. Every command is time-boxed and its whole process tree killed on timeout; after each unit
#      every JVM whose working directory is inside that unit is killed.
#   4. Ports: only 18400-18499, the fixed ones the units themselves use (18425 18431 18441 18442
#      18445-18449 18451 18452; unit 17 binds an OS-chosen loopback port). Each is asserted FREE
#      before its unit runs — a busy port is a FAIL, because the README's command cannot work — and
#      free again after. Nothing here touches 18500+.
#   5. Units never run concurrently.
#   6. Every file the run generates is removed: the run lists what git reports as ignored or
#      untracked under c4-* BEFORE it starts, and removes only what was not there — so a warm
#      author tree keeps its own captures, and a fresh clone ends byte-for-byte as it started
#      (asserted, with a content fingerprint of every tracked file under c4-*).
#   7. A claim that cannot be checked deterministically (a count of how many DISTINCT raw hashes
#      three timestamped runs happen to give) is a labelled SKIP that names what went unchecked.
#      A SKIP is never a quiet pass.
#
# FOUR READINGS THIS SCRIPT HAD TO MAKE, written down so they can be argued with:
#   a. The Section 1 exercise/ and breaks/ projects print no build line of their own. Unit 01's README
#      says the Boot project "keeps its own .m2-demo, because it resolves a parent this unit's repository
#      does not hold", and the .gitignore lists no .m2-demo for them — so they resolve into THEIR UNIT's
#      (-Dmaven.repo.local="$PWD/../.m2-demo", "$PWD/../../.m2-demo"). From unit 07 on, exercise/ keeps its
#      own (.gitignore: c4-unit0N/exercise/.m2-demo/).
#   b. c4-tiffinbox's -pl table is only true while tiffinbox-core is NOT in the local repository, so it
#      runs before `install`, as verify_course3.sh ran the same table.
#   c. A SOLUTION.md that is prose is applied only where it states the edit exactly (a shell command, a
#      named call to delete, one line to add or replace); a solution that is code to write is a SKIP.
#   d. `md5 -q` in unit 01's derivation is macOS; so is this script's target machine.
#
# REQUIRES: JDK 25 (JAVA_HOME), Apache Maven 3.9.x, python3, curl, lsof, rsync, unzip, git, and
# md5 (macOS) or md5sum. zsh is fine as your login shell; this script is bash.
#   export JAVA_HOME=/opt/homebrew/opt/openjdk@25
#   ./verify_course4.sh
# ---------------------------------------------------------------------------
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T0=$(date +%s)

# ----------------------------------------------------------------- the JDK ---
JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@25}"
if [ ! -x "$JAVA_HOME/bin/java" ]; then
  echo "verify_course4.sh needs JDK 25 and JAVA_HOME does not name one: $JAVA_HOME" >&2
  echo "  export JAVA_HOME=/opt/homebrew/opt/openjdk@25" >&2
  exit 2
fi
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"
JV="$("$JAVA_HOME/bin/java" -version 2>&1 | head -1)"
JMAJOR="$(printf '%s' "$JV" | sed -n 's/.*"\([0-9][0-9]*\).*/\1/p')"
if [ "${JMAJOR:-0}" != "25" ]; then
  echo "verify_course4.sh needs JDK 25 exactly; JAVA_HOME gives: $JV" >&2
  echo "Every unit compiles <release>25</release> and every README pins JAVA_HOME to openjdk@25." >&2
  exit 2
fi
for t in mvn python3 curl lsof rsync unzip git diff awk; do
  command -v "$t" >/dev/null 2>&1 || { echo "verify_course4.sh needs '$t' on the PATH" >&2; exit 2; }
done
MVNV="$(mvn -v 2>/dev/null | head -1)"

# ------------------------------------------------------------ the scratch ---
TAG="c4verify$$"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/c4verify.XXXXXX")"
OUT="$WORK/out.txt"
KEEP_M2="${KEEP_M2:-0}"
KEEP_WORK="${KEEP_WORK:-0}"
export REPO WORK OUT TAG

PASS=0; FAIL=0; SKIP=0; FAILED_LABELS=()
RED=''; GRN=''; YLW=''; DIM=''; OFF=''
if [ -t 1 ]; then RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; DIM=$'\033[2m'; OFF=$'\033[0m'; fi

ok()   { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$GRN" "$OFF" "$1"; }
# bad LABEL WHY [noout] — the evidence is the output's first lines, and for a Maven failure its [ERROR] lines,
# which come at the end, where the first twelve lines never reach.
bad()  { FAIL=$((FAIL+1)); FAILED_LABELS+=("$CUR_UNIT: $1"); printf '  %sFAIL%s  %s\n     %s\n' "$RED" "$OFF" "$1" "$2"
         if [ "${3:-}" != "noout" ] && [ -s "$OUT" ]; then
           sed -n '1,12p' "$OUT" | cut -c1-220 | sed 's/^/     | /'
           if grep -q '^\[ERROR\]' "$OUT"; then printf '     | … the [ERROR] lines:\n'; grep '^\[ERROR\]' "$OUT" | head -8 | cut -c1-220 | sed 's/^/     | /'; fi
         fi; }
skip() { SKIP=$((SKIP+1)); printf '  %sSKIP%s  %s %s(%s)%s\n' "$YLW" "$OFF" "$1" "$DIM" "$2" "$OFF"; }
CUR_UNIT="setup"

md5of() { if command -v md5 >/dev/null 2>&1; then md5 -q "$1"; else md5sum "$1" | cut -d' ' -f1; fi; }
md5in() { if command -v md5 >/dev/null 2>&1; then md5 -q; else md5sum | cut -d' ' -f1; fi; }
nlines() { wc -l < "$1" | tr -d ' '; }

# ---------------------------------------------------------- time-boxing ---
# kill_tree PID — the process and every descendant. A `java` started by a `bash -c` started by
# a subshell is a GREAT-grandchild; killing only the direct child would leave it holding a port.
kill_tree() { local p="$1" c; for c in $(pgrep -P "$p" 2>/dev/null); do kill_tree "$c"; done; kill -9 "$p" >/dev/null 2>&1; }

# timed SECS CMD... — stdout+stderr -> $OUT, exit code -> $RC (124 when it had to be killed).
RC=0
timed() {
  local secs="$1"; shift
  ( "$@" >"$OUT" 2>&1 </dev/null ) &
  local pid=$! waited=0 limit=$(( secs * 10 ))
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$waited" -ge "$limit" ]; then
      kill_tree "$pid"; wait "$pid" 2>/dev/null
      echo "[verify_course4.sh: killed after ${secs}s]" >>"$OUT"; RC=124; return 124
    fi
    sleep 0.1; waited=$((waited+1))
  done
  wait "$pid"; RC=$?; return $RC
}
# sh_in DIR 'COMMAND LINE' — the command exactly as a README prints it, run by bash from DIR.
sh_in() { local d="$1" c="$2"; bash -c "cd \"\$1\" || exit 97; $c" _ "$d"; }

# expect_rc LABEL SECS WANT PATTERN DIR 'CMD' — exit code WANT and (if given) PATTERN in the output
# A cold .m2-demo per unit is a lot of requests, and Maven Central answers a burst of them with HTTP 429
# ("Too Many Requests") — measured while this script was being built. That is the network, not the README:
# a command whose output says 429 and that did not do what was expected is re-run after a back-off (up to
# five times, 30 s → 5 min; C4_429_RETRIES=N changes the five), the retries are printed, and only then is the
# result judged.
C4_429_RETRIES="${C4_429_RETRIES:-5}"
central_429() { grep -qE 'status code: 429|Too Many Requests' "$OUT" 2>/dev/null; }
expect_rc() {
  local label="$1" t="$2" want="$3" pat="$4" d="$5" c="$6" try=0 wait
  timed "$t" sh_in "$d" "$c"
  # a 429 anywhere in a run that was EXPECTED to fail could be what failed it, so that is retried too
  while central_429 && { [ "$RC" -ne "$want" ] || [ "$want" -ne 0 ]; } && [ "$try" -lt "$C4_429_RETRIES" ]; do
    try=$((try+1)); wait=$(( 30 * (1 << (try-1)) )); [ "$wait" -gt 300 ] && wait=300
    printf '  %s(Maven Central answered 429 Too Many Requests; retry %d of %d in %ds)%s\n' "$DIM" "$try" "$C4_429_RETRIES" "$wait" "$OFF"
    sleep "$wait"; timed "$t" sh_in "$d" "$c"
  done
  if central_429 && { [ "$RC" -ne "$want" ] || [ "$want" -ne 0 ]; }; then
    bad "$label" "Maven Central kept answering 429 Too Many Requests through $C4_429_RETRIES retries — the network, not the README; not verified"; return 1; fi
  if [ "$RC" -eq 124 ]; then bad "$label" "timed out after ${t}s"; return 1; fi
  if [ "$RC" -ne "$want" ]; then bad "$label" "exit $RC, expected $want"; return 1; fi
  if [ -n "$pat" ] && ! grep -qE -- "$pat" "$OUT"; then bad "$label" "exit $RC as expected, but no output line matches: $pat"; return 1; fi
  ok "$label"; return 0
}
expect_ok() { local l="$1" t="$2" p="$3" d="$4" c="$5"; expect_rc "$l" "$t" 0 "$p" "$d" "$c"; }

is()    { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "expected [$3], got [$2]" noout; fi; }
has()   { if grep -qE -- "$2" "${3:-$OUT}"; then ok "$1"; else bad "$1" "no line matches: $2"; fi; }
hasF()  { if grep -qF -- "$2" "${3:-$OUT}"; then ok "$1"; else bad "$1" "no line contains: $2"; fi; }
hasnt() { if grep -qE -- "$2" "${3:-$OUT}"; then bad "$1" "a line matches what must be absent: $2"; else ok "$1"; fi; }

# ------------------------------------------------------- reading the README ---
# rfile NN -> the README a check reads. NN is a unit number, `tiffinbox`, or a path under REPO.
rfile() { case "$1" in tiffinbox) echo "$REPO/c4-tiffinbox/README.md" ;; [0-9][0-9]) echo "$REPO/c4-unit$1/README.md" ;; *) echo "$REPO/$1" ;; esac; }
# rhash NN ANCHOR [N] -> the Nth (default 1st) 32-hex md5 that follows the first occurrence of the
# fixed string ANCHOR in that README — on the same line or later. READ AT RUN TIME, never copied here.
rhash() {
  python3 - "$(rfile "$1")" "$2" "${3:-1}" <<'PY'
import re, sys
# blanks and line breaks collapsed on both sides, so an anchor survives the README re-wrapping a paragraph
t = re.sub(r"\s+", " ", open(sys.argv[1], encoding="utf-8").read()); a = re.sub(r"\s+", " ", sys.argv[2]); n = int(sys.argv[3])
i = t.find(a)
if i < 0: sys.exit(0)
h = re.findall(r"(?<![0-9a-f])[0-9a-f]{32}(?![0-9a-f])", t[i + len(a):])
print(h[n - 1] if len(h) >= n else "")
PY
}
# rgives NN 'COMMAND' — does the README still print this command, verbatim, at the start of a line
# of a fenced block or inline in backticks? (A trailing `# comment` on that line is allowed.)
rgives() {
  python3 - "$(rfile "$1")" "$2" <<'PY'
import re, sys
w = lambda x: re.sub(r"[ \t]+", " ", x.strip())   # a README may align its columns: blank runs collapsed
t = open(sys.argv[1], encoding="utf-8").read().split("\n"); c = w(sys.argv[2])
for l in t:
    s = w(l)
    if s == c or s.startswith(c + " ") or ("`" + c + "`") in w(l) or s.startswith("$ " + c):
        sys.exit(0)
sys.exit(1)
PY
}
# The panel matcher. A README panel is the console output printed in a fenced block; every line of
# it must be found in the capture. Rules, in order: exact (trailing blanks ignored); blank runs
# collapsed; a line ending "<- note" by the part before the arrow; a line with an elision (… or ...)
# by its fragments, in order, inside one line; a 20+ character line as a substring (a wrapped line).
cat > "$WORK/panel.py" <<'PY'
import re, sys
readme, mode, anchor, capture = sys.argv[1:5]
skip = re.compile(sys.argv[5]) if len(sys.argv) > 5 and sys.argv[5] else None
lines = open(readme, encoding="utf-8").read().split("\n")
blocks, cur, start = [], None, None
for i, l in enumerate(lines):
    if l.startswith("```"):
        if cur is None: cur, start = [], i
        else: blocks.append((start, cur)); cur = None
    elif cur is not None:
        cur.append(l)
panel = None
if mode == "in":
    panel = next((b for s, b in blocks if any(anchor in l for l in b)), None)
elif mode == "after":
    at = next((i for i, l in enumerate(lines) if anchor in l), None)
    if at is not None: panel = next((b for s, b in blocks if s > at), None)
if not panel:
    print("the README has no panel for the anchor %r" % anchor); sys.exit(3)
cap = [l.rstrip() for l in open(capture, encoding="utf-8", errors="replace").read().split("\n")]
col = lambda s: re.sub(r"[ \t]+", " ", s.strip())
capc = set(col(l) for l in cap)
ELI = re.compile(r"…|\.\.\.")
missing, checked, abridged = [], 0, []
for raw in panel:
    l = raw.rstrip(); t = l.strip()
    if not t or t.startswith("$ ") or ELI.fullmatch(t) or (skip and skip.search(l)): continue
    checked += 1
    if l in cap or col(l) in capc: continue
    if "<-" in l:
        head = l.split("<-")[0].rstrip()
        if not head.strip(): continue
        if any(c.startswith(head) or col(c).startswith(col(head)) for c in cap): continue
    if ELI.search(t):
        frags = [f.strip() for f in ELI.split(t) if f.strip()]
        def inorder(c):
            p = 0
            for f in frags:
                q = c.find(f, p)
                if q < 0: return False
                p = q + len(f)
            return True
        if frags and any(inorder(c) for c in cap): continue
    if len(t) >= 12 and any(t in c or col(t) in col(c) for c in cap): continue
    # a README line that drops columns but keeps the rest in order (reported, not hidden)
    toks = t.split()
    def subseq(c):
        j = 0
        for x in c.split():
            if j < len(toks) and x == toks[j]: j += 1
        return j == len(toks)
    if len(toks) >= 3 and any(subseq(c) for c in cap): abridged.append(l); continue
    # a README line that joins two capture lines (the program wraps a long value onto the next line)
    if any(col(cap[k] + " " + cap[k + 1]) == col(t) for k in range(len(cap) - 1)): abridged.append(l); continue
    # a README line that names a class without its package ("Caused by: NoSuchBeanDefinitionException: …")
    unpkg = lambda x: re.sub(r"\b(?:[a-z][a-z0-9_]*\.)+(?=[A-Z])", "", col(x))
    if len(t) >= 12 and any(unpkg(t) in unpkg(c) for c in cap): abridged.append(l); continue
    missing.append(l)
if missing:
    print("%d of the panel's %d line(s) are not in the capture:" % (len(missing), checked))
    for m in missing[:6]: print("README: " + m)
    sys.exit(1)
print("%d panel line(s), every one in the capture%s" % (checked,
      (" — %d of them re-flowed or with a column the README drops" % len(abridged)) if abridged else ""))
PY
# panel LABEL NN MODE ANCHOR CAPTURE [SKIP_REGEX] — MODE `in` (the block containing ANCHOR) or
# `after` (the first block after the line containing ANCHOR).
panel() {
  local label="$1" r; r="$(rfile "$2")"
  if [ ! -f "$5" ]; then bad "$label" "no capture to compare with: $5" noout; return 1; fi
  python3 "$WORK/panel.py" "$r" "$3" "$4" "$5" "${6:-}" >"$WORK/panel.msg" 2>&1
  local rc=$?
  if [ "$rc" -eq 0 ]; then ok "$label ($(cat "$WORK/panel.msg"))"
  else bad "$label" "$(head -1 "$WORK/panel.msg")" noout; sed -n '2,7p' "$WORK/panel.msg" | cut -c1-200 | sed 's/^/     | /'; fi
}

# ------------------------------------------------------ the three-run rule ---
# cap3 TAG FILTER DIR 'CMD' — CMD run three times from DIR, stdout and stderr together, each time-
# boxed. FILTER is `none` or the path of the python filter the README names (the unit's chain.py or
# stamp.py). Leaves $WORK/TAG.{1,2,3}.out and sets:
#   C_RCS   the three exit codes, e.g. "1 1 1"      C_MD5  md5 of run 1's capture
#   C_SAME  yes if the three captures are identical   C_LINES  lines in run 1's capture
#   C_FRC   the filter's exit code on run 1 (chain.py/stamp.py exit 2 rather than hand back a wrong receipt)
cap3() {
  local tag="$1" filt="$2" d="$3" c="$4" i rcs=""
  C_FRC=0; C_TAG="$tag"
  for i in 1 2 3; do
    timed 240 sh_in "$d" "$c"
    rcs="$rcs $RC"
    cp "$OUT" "$WORK/$tag.$i.raw"
    if [ "$filt" = none ]; then cp "$WORK/$tag.$i.raw" "$WORK/$tag.$i.out"
    else python3 "$filt" "$WORK/$tag.$i.raw" >"$WORK/$tag.$i.out" 2>"$WORK/$tag.$i.ferr"; [ "$i" = 1 ] && C_FRC=$?; fi
  done
  C_RCS="${rcs# }"; C_MD5="$(md5of "$WORK/$tag.1.out")"; C_LINES="$(nlines "$WORK/$tag.1.out")"
  if cmp -s "$WORK/$tag.1.out" "$WORK/$tag.2.out" && cmp -s "$WORK/$tag.2.out" "$WORK/$tag.3.out"; then C_SAME=yes; else C_SAME=no; fi
  cp "$WORK/$tag.1.out" "$OUT"
}
# claim3 LABEL WANT_RC WANT_MD5 [WANT_LINES] — the trio every README capture line states:
# the exit code, three identical runs, the md5 (and, where the README says it, the line count).
# WANT_MD5 `-` means the README quotes no hash for this capture: exit code and 3/3 only.
# WANT_MD5 `~` means the README says this raw form carries a clock and is NOT reproducible: exit code only.
claim3() {
  local label="$1" want="$2" md5="$3" lines="${4:-}" why=""
  [ "$C_RCS" = "$want $want $want" ] || why="exit codes [$C_RCS], the README says $want"
  [ -z "$why" ] && [ "$md5" != "~" ] && [ "$C_SAME" != yes ] && why="the three runs are NOT byte-identical (the README says 3/3): md5s $(for i in 1 2 3; do md5of "$WORK/$C_TAG.$i.out" | cut -c1-8; done | tr '\n' ' ')"
  [ -z "$why" ] && [ "$C_FRC" != 0 ] && why="the unit's own filter exited $C_FRC: $(head -1 "$WORK/$C_TAG.1.ferr" 2>/dev/null)"
  [ -z "$why" ] && [ -z "$md5" ] && why="the README no longer quotes an md5 at this anchor"
  [ -z "$why" ] && [ "$md5" != "-" ] && [ "$md5" != "~" ] && [ "$C_MD5" != "$md5" ] && why="md5 $C_MD5, the README says $md5"
  [ -z "$why" ] && [ -n "$lines" ] && [ "$C_LINES" != "$lines" ] && why="$C_LINES output lines, the README says $lines"
  if [ -z "$why" ]; then ok "$label"; else bad "$label" "$why"; fi
}

# ------------------------------------------------------------------- ports ---
port_busy()      { lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; }
port_who()       { lsof -nP -iTCP:"$1" -sTCP:LISTEN 2>/dev/null | awk 'NR==2 {print $1" pid "$2}'; }
wait_port_free() { local i; for i in $(seq 1 60);  do port_busy "$1" || return 0; sleep 0.25; done; return 1; }
wait_port_up()   { local i; for i in $(seq 1 160); do port_busy "$1" && return 0; sleep 0.25; done; return 1; }
# ports_free_before LABEL PORT... — returns 1 (and FAILs) when any is taken: the unit cannot run.
ports_free_before() {
  local label="$1" p busy=""; shift
  for p in "$@"; do port_busy "$p" && busy="$busy $p($(port_who "$p"))"; done
  if [ -z "$busy" ]; then ok "$label: port(s) $* free before it runs"; return 0; fi
  bad "$label: port(s) $* free before it runs" "already listening:$busy — the README's commands cannot bind it" noout; return 1
}
ports_free_after() {
  local label="$1" p busy=""; shift
  for p in "$@"; do wait_port_free "$p" || busy="$busy $p($(port_who "$p"))"; done
  if [ -z "$busy" ]; then ok "$label: port(s) $* free again afterwards"; else bad "$label: port(s) $* free again afterwards" "still listening:$busy" noout; fi
}
# every JVM whose working directory is DIR or below it — Maven's own, receipts.sh's, the servers'.
jvms_under() {
  local d="$1" pid cwd
  for pid in $(pgrep -x java 2>/dev/null); do
    cwd="$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | head -1)"
    case "$cwd" in "$d"|"$d"/*) echo "$pid" ;; esac
  done
}
reap_unit() { local d="$1" p left; left="$(jvms_under "$d" | tr '\n' ' ')"
  for p in $left; do kill -9 "$p" >/dev/null 2>&1; done
  pkill -9 -f "$TAG" >/dev/null 2>&1
  if [ -z "$left" ]; then ok "no JVM is still running from $(basename "$d")/"; else bad "no JVM is still running from $(basename "$d")/" "killed left-over JVM pid(s): $left" noout; fi; }

# ---------------------------------------------------------------- offline ---
# offline_pair LABEL DIR — README: "`mvn -o -B verify` after one warm build: BUILD SUCCESS, exit 0".
# Online first into DIR/.m2-demo, then -o against the same repository.
# REPO_EXPR (3rd arg) is the repository as the shell sees it from DIR: $PWD/.m2-demo (default), or
# $PWD/../.m2-demo for the Section 1 exercises and breaks, which the README says use "this unit's".
offline_pair() {
  local label="$1" d="$2" r="${3:-\$PWD/.m2-demo}"
  expect_ok "$label: mvn -B verify, online first, into $r" 900 'BUILD SUCCESS' "$d" \
      "mvn -B -Dmaven.repo.local=\"$r\" verify" || return 1
  expect_ok "$label: mvn -o -B verify — BUILD SUCCESS offline, exit 0" 900 'BUILD SUCCESS' "$d" \
      "mvn -o -B -Dmaven.repo.local=\"$r\" verify"
}

# ------------------------------------------------------- the build lines ---
# Section 1-2 READMEs (units 01-12) print these two, in this order.
MVN_PKG='mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package'
MVN_CP='mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime'
# Section 3-5 READMEs (units 13-30) print these two.
MVN_COMPILE='mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile'
MVN_CPTXT='mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath'
# build12 LABEL NN DIR — the two lines, from DIR (the unit, its exercise, a break or a solution copy).
# build12 LABEL NN DIR [REPO_EXPR] — for the unit itself the README's two lines are asserted to be
# printed (NN given); for an exercise/break (NN = -) the same two lines with the repository it uses.
build12() {
  local label="$1" n="$2" d="$3" r="${4:-\$PWD/.m2-demo}" pkg cpl
  pkg="mvn -B -Dmaven.repo.local=\"$r\" clean package"
  cpl="mvn -B -q -Dmaven.repo.local=\"$r\" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime"
  if [ "$n" != "-" ]; then
    rgives "$n" "$pkg" || bad "$label: the README still prints: $pkg" "not found" noout
    rgives "$n" "$cpl" || bad "$label: the README still prints: $cpl" "not found" noout
  fi
  expect_ok "$label: $pkg" 900 'BUILD SUCCESS' "$d" "$pkg" || return 1
  expect_ok "$label: dependency:build-classpath -> .cp" 600 '' "$d" "$cpl" || return 1
  if [ -s "$d/.cp" ]; then return 0; fi
  bad "$label: .cp written" "the build-classpath line exited 0 and wrote no .cp" noout; return 1
}
build35() {
  local label="$1" d="$2" n="${3:-}"
  if [ -n "$n" ]; then
    rgives "$n" "$MVN_COMPILE" || bad "$label: the README still prints: $MVN_COMPILE" "not found" noout
    rgives "$n" "$MVN_CPTXT" || bad "$label: the README still prints: $MVN_CPTXT" "not found" noout
  fi
  expect_ok "$label: $MVN_COMPILE" 900 '' "$d" "$MVN_COMPILE" || return 1
  expect_ok "$label: dependency:build-classpath -> cp.txt" 600 '' "$d" "$MVN_CPTXT" || return 1
  [ -s "$d/cp.txt" ] && return 0
  bad "$label: cp.txt written" "the build-classpath line exited 0 and wrote no cp.txt" noout; return 1
}
JCP='java -cp "target/classes:$(cat .cp)"'          # the java line of units 01-12
JCPT='java -cp "target/classes:$(cat cp.txt)"'      # the java line the Section 3-5 exercise READMEs print

# --------------------------------------------------------- solution copies ---
# solution_copy NN — c4-unitNN/.verify-solution: the exercise, copied beside itself (same depth, the
# same space in the path), sharing its .m2-demo by symlink, with every shipped solution file that is
# not prose laid over the file of the same name. The tracked exercise is never edited.
# Sets S (the copy) and SOL_APPLIED. Build the exercise FIRST: its .m2-demo, if it keeps one, is then shared.
solution_copy() {
  local n="$1" src="$REPO/c4-unit$1/exercise" dst="$REPO/c4-unit$1/.verify-solution" f b t applied=""
  rm -rf "$dst"; mkdir -p "$dst"
  rsync -a --exclude .m2-demo --exclude target --exclude '.r-*' --exclude .cp --exclude cp.txt --exclude 'cp-*.txt' "$src/" "$dst/"
  [ -d "$src/.m2-demo" ] && ln -s "$src/.m2-demo" "$dst/.m2-demo"
  for f in "$src"/solution/*; do
    b="$(basename "$f")"; case "$b" in *.md) continue ;; esac
    t="$(cd "$dst/src" && find . -name "$b" -type f | head -1)"
    [ -n "$t" ] && cp "$f" "$dst/src/$t" && applied="$applied src/${t#./}"
  done
  SOL_APPLIED="${applied# }"; S="$dst"
}

# ---------------------------------------------------------- tree snapshot ---
# What git calls ignored or untracked under c4-*, one entry per line — taken before and after.
extras() { ( cd "$REPO" && git status --porcelain --ignored --untracked-files=normal -- 'c4-*' 2>/dev/null | sed -E -n 's/^(!!|[?][?]) //p' | LC_ALL=C sort ); }
# A content fingerprint of every TRACKED file under c4-* (the run must not change one byte of them).
tracked_fp() { ( cd "$REPO" && git ls-files -z -- 'c4-*' | xargs -0 shasum 2>/dev/null | shasum | cut -d' ' -f1 ); }
# rblock NN MODE ANCHOR — print a README's fenced block (MODE in|after, as for `panel`).
rblock() {
  python3 - "$(rfile "$1")" "$2" "$3" <<'PY'
import sys
lines = open(sys.argv[1], encoding="utf-8").read().split("\n"); mode, a = sys.argv[2], sys.argv[3]
blocks, cur = [], None
for i, l in enumerate(lines):
    if l.startswith("```"):
        if cur is None: cur, s = [], i
        else: blocks.append((s, cur)); cur = None
    elif cur is not None: cur.append(l)
if mode == "in":
    b = next((b for s, b in blocks if any(a in l for l in b)), [])
else:
    at = next((i for i, l in enumerate(lines) if a in l), None)
    b = next((b for s, b in blocks if at is not None and s > at), [])
print("\n".join(b))
PY
}
# the Class-Path of a manifest, continuation lines unwrapped
mf_classpath() { python3 -c '
import sys
v, on = "", False
for l in open(sys.argv[1]).read().split("\n"):
    l = l.rstrip("\r")
    if l.startswith("Class-Path:"): v, on = l[len("Class-Path:"):].strip(), True
    elif on and l.startswith(" "): v += l[1:]
    else: on = False
print(v)' "$1"; }
# dependency:tree lines (every coordinate line, in order)
tree_lines() { grep -E '^\[INFO\] .*:(jar|pom):' "$1" | sed 's/[[:space:]]*$//'; }
# unit selection
UNITS=("$@")
for u in ${UNITS[@]+"${UNITS[@]}"}; do
  case "$u" in
    tiffinbox) ;;
    0[1-9]|[12][0-9]|3[0-2]) [ -d "$REPO/c4-unit$u" ] || { echo "unknown unit: $u (no c4-unit$u/ in $REPO)" >&2; exit 2; } ;;
    *) echo "unknown unit: $u (use two digits, 01-32, or 'tiffinbox')" >&2; exit 2 ;;
  esac
done
want() { [ ${#UNITS[@]} -eq 0 ] && return 0; local u; for u in "${UNITS[@]}"; do [ "$u" = "$1" ] && return 0; done; return 1; }
unit() {  # unit NN "title" -> U, CUR_UNIT, a header; or 1 to skip the block
  want "$1" || return 1
  [ -d "$REPO/c4-unit$1" ] || return 1
  CUR_UNIT="c4-unit$1"; U="$REPO/c4-unit$1"
  printf '\n%sc4-unit%s%s  %s\n' "$DIM" "$1" "$OFF" "$2"
  cd "$U" || return 1
}
end_unit() {  # end_unit DIR PORT... — nothing of this unit may still be listening or running
  local d="$1"; shift
  [ $# -gt 0 ] && ports_free_after "$CUR_UNIT" "$@"
  reap_unit "$d"
  cd "$REPO" || true
}

# c3 LABEL NN TAG FILTER DIR 'CMD' — the README (NN; `-` for none) must still print CMD; then cap3.
c3() {
  local label="$1" n="$2" tag="$3" filt="$4" d="$5" c="$6"
  C_TAG="$tag"
  if [ "$n" != "-" ] && ! rgives "$n" "$c"; then
    bad "$label" "the README no longer prints this command: $c" noout; C_RCS="x x x"; C_SAME=no; C_MD5=""; C_LINES=0; C_FRC=0
    : >"$WORK/$tag.1.out"; return 1
  fi
  cap3 "$tag" "$filt" "$d" "$c"
}
# rticks NN ANCHOR N — the Nth `backticked` span after ANCHOR (newlines inside it become one blank)
rticks() {
  python3 - "$(rfile "$1")" "$2" "${3:-1}" <<'PY'
import re, sys
t = re.sub(r"\s+", " ", open(sys.argv[1], encoding="utf-8").read()); a = re.sub(r"\s+", " ", sys.argv[2]); n = int(sys.argv[3])
i = t.find(a)
if i < 0: sys.exit(0)
q = re.findall(r"`([^`]+)`", t[i + len(a):])
print(re.sub(r"\s+", " ", q[n - 1]).strip() if len(q) >= n else "")
PY
}
# hasC LABEL TEXT [FILE] — TEXT (blanks collapsed) inside one line of FILE (blanks collapsed); failing
# that, its words in order inside one line (a README quote that drops a column, e.g. "(your code)") —
# which the PASS line then says.
hasC() {
  local label="$1" txt="$2" f="${3:-$OUT}" r show
  show="$(printf '%s' "$txt" | tr -s ' ' | sed 's/^ //' | cut -c1-150)"
  if [ -z "$txt" ]; then bad "$label" "the README no longer has the text this check reads" noout; return 1; fi
  python3 -c '
import re, sys
c = lambda s: re.sub(r"\s+", " ", s).strip()
t = c(sys.argv[1]); w = t.split(" ")
lines = [c(l) for l in open(sys.argv[2], errors="replace")]
if any(t in l for l in lines): sys.exit(0)
def sub(l):
    j = 0
    for x in l.split(" "):
        if j < len(w) and x == w[j]: j += 1
    return j == len(w)
sys.exit(4 if len(w) >= 3 and any(sub(l) for l in lines) else 1)' "$txt" "$f"
  r=$?
  if [ "$r" = 0 ]; then ok "$label: $show"
  elif [ "$r" = 4 ]; then ok "$label: $show (the README drops a word the line carries)"
  else bad "$label: $show" "not in the capture" noout; fi
}
# chain_is LABEL CAPTURE TYPE... — the exception types, in order, heading "Exception in thread" / "Caused by:" lines
chain_is() {
  local label="$1" f="$2"; shift 2
  local got; got="$(grep -oE '^(Exception in thread "main" |Caused by: )[A-Za-z0-9_.$]+' "$f" | sed -E 's/^(Exception in thread "main" |Caused by: )//' | tr '\n' ' ')"
  is "$label" "${got% }" "$*"
}
# same_file LABEL A B — the shipped solution did not touch B (A is the exercise's copy)
same_file() { if cmp -s "$2" "$3"; then ok "$1"; else bad "$1" "$(basename "$3") differs from the exercise's" noout; fi; }

# ------------------------------------------------ a caching proxy of Central ---
# Every unit resolves into its own cold .m2-demo, so a full run is ~40 cold local repositories — tens of
# thousands of requests to Maven Central in 25 minutes. Central blocks an IP that does that ("Your ip has
# exceeded rate limits", HTTP 429; measured while this script was being built), and Sonatype's answer is "not
# to retry harder" but to put a caching proxy in front of it. So by default every `mvn` this run starts —
# including the ones inside the units' own receipts.sh — resolves through a small caching proxy on
# 127.0.0.1:18499 (MAVEN_ARGS=-s <settings with one mirror, id "central">). Nothing about the check changes: each unit's
# .m2-demo still starts EMPTY and is filled over HTTP by Maven's own resolver; the proxy only makes the
# second unit's request for spring-core-7.0.9.jar a local one.
#   C4_CENTRAL_CACHE=off      go straight to Central, as a viewer's single unit would
#   C4_CENTRAL_CACHE=<dir>    keep the cache there (default: ${TMPDIR:-/tmp}/c4verify-central-cache,
#                             kept between runs, so a re-run asks Central only for metadata)
#   C4_CENTRAL_SEEDS=<roots>  newline-separated local repositories to serve released artifacts from before
#                             asking Central (read only; checksums are recomputed from the bytes).
#                             Metadata (maven-metadata.xml) is always asked of Central first.
# When Central refuses (429) or cannot be reached, the proxy asks Google's public mirror of Central
# (maven-central.storage-download.googleapis.com) for the same path; the summary line counts each source.
C4_CENTRAL_CACHE="${C4_CENTRAL_CACHE:-${TMPDIR:-/tmp}/c4verify-central-cache}"
CACHE_PORT=18499
CACHE_PID=""
cat > "$WORK/central_cache.py" <<'PY'
import hashlib, http.server, os, sys, tempfile, threading, urllib.error, urllib.request
port, cache, log = int(sys.argv[1]), sys.argv[2], sys.argv[3]
seeds = [s for s in sys.argv[4:] if s and os.path.isdir(s)]
UP = "https://repo.maven.apache.org/maven2/"
# Google's public mirror of Maven Central: asked only when Central itself refuses (429) or cannot be reached.
MIRROR = "https://maven-central.storage-download.googleapis.com/maven2/"
lock = threading.Lock(); meta_mem = {}
def note(src, rel):
    with lock, open(log, "a") as f: f.write("%s %s\n" % (src, rel))
def store(rel, b):
    p = os.path.join(cache, rel); os.makedirs(os.path.dirname(p), exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(p)); os.write(fd, b); os.close(fd); os.replace(tmp, p)
def fetch(base, rel):
    try:
        with urllib.request.urlopen(urllib.request.Request(base + rel, headers={"User-Agent": "c4verify-cache"}), timeout=90) as r:
            return 200, r.read()
    except urllib.error.HTTPError as e:
        return e.code, b""
    except Exception:
        return 502, b""
def upstream(rel):
    code, b = fetch(UP, rel)
    if code in (429, 502, 503):
        mcode, mb = fetch(MIRROR, rel)
        if mcode == 200: return 200, mb, "mirror"
    return code, b, "central"
LOCAL_ONLY = ("com/tiffinbox/",)   # the course's own artifacts: never on Central, so never asked of it
def lookup(rel):
    if rel.startswith(LOCAL_ONLY): note("local-404", rel); return 404, b""
    base, algo = rel, None
    for a in ("sha1", "md5", "sha256", "sha512"):
        if rel.endswith("." + a): base, algo = rel[:-len(a) - 1], a
    meta = os.path.basename(base).startswith("maven-metadata")
    if meta:                                   # metadata: Central first (once per run), seeds only as a fallback
        if rel in meta_mem: note("cache", rel); return 200, meta_mem[rel]
        code, b, via = upstream(rel)
        if code == 200: meta_mem[rel] = b; note(via, rel); return 200, b
        for s in seeds:
            sp = os.path.join(s, os.path.dirname(base), "maven-metadata-central.xml")
            if os.path.isfile(sp):
                b = open(sp, "rb").read()
                if algo: b = hashlib.new(algo, b).hexdigest().encode()
                note("seed-metadata-central-said-%d" % code, rel); return 200, b
        note("central-%d" % code, rel); return code, b""
    p = os.path.join(cache, rel)
    if os.path.isfile(p): note("cache", rel); return 200, open(p, "rb").read()
    for s in seeds:
        sp = os.path.join(s, base)
        if os.path.isfile(sp):
            b = open(sp, "rb").read()
            if algo: b = hashlib.new(algo, b).hexdigest().encode()
            store(rel, b); note("seed", rel); return 200, b
    code, b, via = upstream(rel)
    if code == 200: store(rel, b); note(via, rel)
    else: note("central-%d" % code, rel)
    return code, b
class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def serve(self, body):
        rel = self.path.split("?")[0]
        if not rel.startswith("/maven2/") or ".." in rel:
            self.send_response(404); self.send_header("Content-Length", "0"); self.end_headers(); return
        code, b = lookup(rel[len("/maven2/"):])
        self.send_response(code); self.send_header("Content-Length", str(len(b))); self.end_headers()
        if body and b: self.wfile.write(b)
    def do_GET(self): self.serve(True)
    def do_HEAD(self): self.serve(False)
http.server.ThreadingHTTPServer(("127.0.0.1", port), H).serve_forever()
PY
start_central_cache() {
  [ "$C4_CENTRAL_CACHE" = off ] && return 0
  if port_busy "$CACHE_PORT"; then
    echo "verify_course4.sh: port $CACHE_PORT (the Central cache) is busy: $(port_who "$CACHE_PORT"); free it or set C4_CENTRAL_CACHE=off" >&2; exit 2
  fi
  mkdir -p "$C4_CENTRAL_CACHE"
  local seeds=() s
  while IFS= read -r s; do [ -n "$s" ] && seeds+=("$s"); done <<<"${C4_CENTRAL_SEEDS:-}"
  python3 "$WORK/central_cache.py" "$CACHE_PORT" "$C4_CENTRAL_CACHE" "$WORK/central-cache.log" ${seeds[@]+"${seeds[@]}"} \
      >"$WORK/central-cache.err" 2>&1 </dev/null &
  CACHE_PID=$!
  wait_port_up "$CACHE_PORT" || { echo "verify_course4.sh: the Central cache did not start: $(cat "$WORK/central-cache.err")" >&2; exit 2; }
  cat >"$WORK/c4-settings.xml" <<XML
<settings>
  <mirrors>
    <mirror><id>central</id><mirrorOf>*</mirrorOf><url>http://127.0.0.1:$CACHE_PORT/maven2</url></mirror>
  </mirrors>
</settings>
XML
  export MAVEN_ARGS="${MAVEN_ARGS:+$MAVEN_ARGS }-s $WORK/c4-settings.xml"
}
stop_central_cache() { [ -n "$CACHE_PID" ] && { kill "$CACHE_PID" >/dev/null 2>&1; wait "$CACHE_PID" 2>/dev/null; CACHE_PID=""; }; return 0; }
central_cache_summary() {
  [ "$C4_CENTRAL_CACHE" = off ] && { echo "Maven resolution: straight to Central (C4_CENTRAL_CACHE=off)"; return; }
  [ -s "$WORK/central-cache.log" ] || { echo "Maven resolution: through the cache on 127.0.0.1:$CACHE_PORT — no requests"; return; }
  awk '{c[$1]++; n++} END {printf "Maven resolution: %d requests through the cache on 127.0.0.1:'"$CACHE_PORT"' —", n; for (k in c) printf " %s %d", k, c[k]; printf "\n"}' "$WORK/central-cache.log"
}
# as_central FILE — Maven names a repository "id (url)"; with the cache on, a line that names Central names the
# cache's URL instead. The one README line that quotes it (c4-tiffinbox's -pl [ERROR]) is compared through this.
as_central() { sed "s#http://127.0.0.1:$CACHE_PORT/maven2#https://repo.maven.apache.org/maven2#g" "$1"; }

# -------------------------------------------------------- what we start from ---
ALL_PORTS="18425 18431 18441 18442 18445 18446 18447 18448 18449 18451 18452"
extras >"$WORK/extras.before"
FP_BEFORE="$(tracked_fp)"
m2home_state() { if [ -e "$HOME/.m2/repository/com/tiffinbox" ]; then find "$HOME/.m2/repository/com/tiffinbox" | LC_ALL=C sort | md5in; else echo absent; fi; }
M2HOME_BEFORE="$(m2home_state)"
# remove_new_extras — everything git reports as ignored/untracked under c4-* that was NOT there when
# the run started. KEEP_M2=1 keeps the scratch repositories and the class-path files that name them.
remove_new_extras() {
  extras >"$WORK/extras.now"
  LC_ALL=C comm -13 "$WORK/extras.before" "$WORK/extras.now" | while IFS= read -r p; do
    [ -n "$p" ] || continue
    if [ "$KEEP_M2" = 1 ]; then
      case "$p" in *.m2-demo/|*.m2-demo|*/.cp|*/cp.txt|*/cp-el.txt|*/cp-noel.txt) continue ;; esac
    fi
    case "$p" in c4-*) rm -rf "${REPO:?}/$p" ;; esac
  done
}
all_c4_jvms() { local d; for d in "$REPO"/c4-*; do [ -d "$d" ] && jvms_under "$d"; done; }
cleanup() {
  stop_central_cache
  local p; for p in $(all_c4_jvms); do kill -9 "$p" >/dev/null 2>&1; done
  pkill -9 -f "$TAG" >/dev/null 2>&1
  rm -rf "$REPO"/c4-unit*/.verify-solution 2>/dev/null
  remove_new_extras
  if [ "$KEEP_WORK" = 1 ]; then echo "captures kept in $WORK" >&2; else rm -rf "$WORK"; fi
}
trap cleanup EXIT
trap 'exit 130' INT TERM

printf 'verify_course4.sh — %s\n' "$JV"
printf '                   %s\n' "$MVNV"
printf 'repo: %s\n' "$REPO"
printf 'local repositories: each unit'"'"'s own .m2-demo, the path its README prints (never ~/.m2)\n'
case "$REPO" in *" "*) printf 'the path above contains a space — the quoting every README asks for is being exercised\n' ;; esac
[ "$KEEP_M2" = 1 ] && printf '%sKEEP_M2=1 — the .m2-demo directories are kept%s\n' "$YLW" "$OFF"
start_central_cache
if [ "$C4_CENTRAL_CACHE" = off ]; then printf 'Maven resolution: straight to Central (C4_CENTRAL_CACHE=off)\n'
else printf 'Maven resolution: every .m2-demo starts empty and fills through a caching proxy of Central on 127.0.0.1:%s\n' "$CACHE_PORT"
     printf '                  cache %s%s\n' "$C4_CENTRAL_CACHE" "$([ -n "${C4_CENTRAL_SEEDS:-}" ] && printf ', seeded read-only from %s local repositor(ies)' "$(grep -c . <<<"$C4_CENTRAL_SEEDS")")"; fi
created_by_run() { ! grep -qxF -- "$1" "$WORK/extras.before"; }

# ============================================================ c4-tiffinbox ===
# The long-lived project. Its README is two READMEs: the Course 3 one, carried over verbatim
# ("# c3-tiffinbox — TiffinBox, split into modules"), then two Course 4 sections. Every command in
# both halves is a command a viewer is given in c4-tiffinbox/, so both are run — against the
# project as it is NOW, i.e. after unit 31 rewired it onto the container.
# The only difference from the README's own lines: -Dmaven.repo.local="$PWD/.m2-demo" (the path
# the root .gitignore names for this project), because the README's bare `mvn` would write ~/.m2.
if want tiffinbox && [ -d "$REPO/c4-tiffinbox" ]; then
  CUR_UNIT="c4-tiffinbox"; TB="$REPO/c4-tiffinbox"; U="$TB"
  M2TB='-Dmaven.repo.local="$PWD/.m2-demo"'
  printf '\n%sc4-tiffinbox%s  the long-lived project (the carried Course 3 README, then the Course 4 sections)\n' "$DIM" "$OFF"
  cd "$TB" || exit 2
  TBPORTS=1; ports_free_before "c4-tiffinbox" 18425 18431 || TBPORTS=0

  # ---- the rule, grepped exactly as the README does
  timed 30 sh_in "$TB" 'grep -rl "com.sun.net.httpserver" tiffinbox-*/src; grep -rl "java.sql" tiffinbox-*/src'
  cp "$OUT" "$WORK/tb-grep.out"
  panel 'grep -rl "com.sun.net.httpserver" / "java.sql" tiffinbox-*/src -> the three files the README prints' \
        tiffinbox in 'tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java' "$WORK/tb-grep.out"
  is "…and nothing else: web holds the HTTP, core holds the SQL (3 lines)" "$(nlines "$WORK/tb-grep.out")" "3"

  expect_ok "mvn -version -> 'Java version: 25.0.4.1' (the README's comment on that line)" 60 'Java version: 25\.0\.4\.1' "$TB" 'mvn -version'

  # ---- Build
  expect_ok "mvn -B clean package (3 modules)" 900 'BUILD SUCCESS' "$TB" "mvn -B $M2TB clean package"
  sed -E 's/\[ *[0-9]+\.[0-9]+ s\]/[  n.nnn s]/' "$OUT" >"$WORK/tb-build.out"
  is "…'Sixteen goals run' (the --- goal lines Maven prints)" "$(grep -c '^\[INFO\] --- ' "$WORK/tb-build.out" | tr -d ' ')" "16"
  panel "…the reactor summary, in dependency order (timings masked to n.nnn, as the README does)" \
        tiffinbox in 'Reactor Summary for TiffinBox 1.0.0:' "$WORK/tb-build.out"

  # ---- the manifest and target/lib
  expect_ok "unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF" 60 \
      '^Main-Class: com.tiffinbox.web.TiffinBoxServer' "$TB" 'unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF'
  cp "$OUT" "$WORK/tb-mf.out"; rblock tiffinbox after 'unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar' >"$WORK/tb-mf.readme"
  is "…its Class-Path is the one the README prints" "$(mf_classpath "$WORK/tb-mf.out")" "$(mf_classpath "$WORK/tb-mf.readme")"
  expect_ok "ls tiffinbox-web/target/lib" 30 '' "$TB" 'ls tiffinbox-web/target/lib'
  rblock tiffinbox after 'ls tiffinbox-web/target/lib' >"$WORK/tb-lib.readme"
  is "…the jars the README lists, and only those" "$(LC_ALL=C sort "$OUT" | tr '\n' ' ')" "$(grep -v '^$' "$WORK/tb-lib.readme" | LC_ALL=C sort | tr '\n' ' ')"

  # ---- "Read this first": the Course 3 sections' outputs were re-captured against this project as it now is
  # ("15 jars at run time, a Spring subtree in the dependency tree"), and "the project as Course 3 left it is
  # frozen in ../c4-unit31/before/; run a command there to see Course 3's output" — held against the output
  # blocks of c3-tiffinbox/README.md, Course 3's own README, which is frozen.
  NJ="$(python3 -c 'import re,sys; t=re.sub(r"\s+"," ",open(sys.argv[1]).read()); m=re.search(r"\((\d+) jars at run time", t); print(m.group(1) if m else "")' "$(rfile tiffinbox)")"
  is "'Read this first': '${NJ:-?} jars at run time' (tiffinbox-web/target/lib)" "$(ls "$TB/tiffinbox-web/target/lib" 2>/dev/null | wc -l | tr -d ' ')" "${NJ:-the README gives no number}"
  HB="$REPO/c4-unit31/before"
  if grep -qF 'frozen in `../c4-unit31/before/`; run a command there to see Course 3' "$(rfile tiffinbox)"; then
    RB='-Dmaven.repo.local="$PWD/../.m2-demo"'    # c4-unit31/.m2-demo: the repository unit 31 builds before/ into
    if expect_ok "'Read this first': in ../c4-unit31/before/, mvn -B clean package" 900 'BUILD SUCCESS' "$HB" "mvn -B $RB clean package"; then
      timed 60 sh_in "$HB" 'unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF'; cp "$OUT" "$WORK/tb-before-mf.out"
      rblock c3-tiffinbox/README.md after 'unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar' >"$WORK/c3-mf.readme"
      is "…there, the manifest's Class-Path is Course 3's (c3-tiffinbox/README.md)" "$(mf_classpath "$WORK/tb-before-mf.out")" "$(mf_classpath "$WORK/c3-mf.readme")"
      is "…there, ls tiffinbox-web/target/lib is Course 3's" "$(ls "$HB/tiffinbox-web/target/lib" | LC_ALL=C sort | tr '\n' ' ')" \
         "$(rblock c3-tiffinbox/README.md after 'ls tiffinbox-web/target/lib' | grep -v '^$' | LC_ALL=C sort | tr '\n' ' ')"
      expect_ok "…there, mvn -B dependency:tree" 900 'BUILD SUCCESS' "$HB" "mvn -B $RB dependency:tree"
      is "…is Course 3's tree" "$(tree_lines "$OUT" | tr '\n' '|')" \
         "$(rblock c3-tiffinbox/README.md in '[INFO] com.tiffinbox:tiffinbox-parent:pom:1.0.0' >"$WORK/r"; tree_lines "$WORK/r" | tr '\n' '|')"
    fi
  else
    bad "'Read this first': '… frozen in ../c4-unit31/before/; run a command there to see Course 3's output'" \
        "the README no longer says so — and its Course 3 outputs are then checked against this folder alone" noout
  fi

  # ---- Run (port 18425): the server, the six curls, POST /shutdown
  if [ "$TBPORTS" = 1 ]; then
    ( cd "$TB/tiffinbox-web" && exec java -Djava.util.logging.config.file=logging.properties -jar target/tiffinbox-web-1.0.0.jar ) \
        >"$WORK/tb-srv.log" 2>&1 </dev/null &
    SRV=$!
    if wait_port_up 18425; then
      sleep 0.5
      panel "cd tiffinbox-web && java -Djava.util.logging.config.file=logging.properties -jar … -> the four lines the README prints" \
            tiffinbox in 'TiffinBox listening on http://127.0.0.1:18425' "$WORK/tb-srv.log"
      : >"$WORK/tb-curl.out"
      for c in 'curl -s http://127.0.0.1:18425/customers' 'curl -s http://127.0.0.1:18425/dashboard' \
               'curl -s http://127.0.0.1:18425/kitchen' 'curl -s http://127.0.0.1:18425/revenue' \
               "curl -s -o /dev/null -w '%{http_code}\\n' http://127.0.0.1:18425/pauses" \
               "curl -s -w ' %{http_code}\\n' http://127.0.0.1:18425/shutdown"; do
        rgives tiffinbox "$c" || bad "the README still prints: $c" "no such line in c4-tiffinbox/README.md" noout
        sh_in "$TB" "$c" >>"$WORK/tb-curl.out" 2>&1; [ -n "$(tail -c1 "$WORK/tb-curl.out")" ] && echo >>"$WORK/tb-curl.out"
      done
      rblock tiffinbox in '"customers":4,"monthRevenue":24300' | grep -v '^$' >"$WORK/tb-curl.readme"
      if diff "$WORK/tb-curl.readme" "$WORK/tb-curl.out" >"$WORK/tb-curl.diff"; then
        ok "the six curls (four routes, 404 /pauses, 405 GET /shutdown) print exactly the README's six lines"
      else bad "the six curls print exactly the README's six lines" "diff README vs run: $(head -4 "$WORK/tb-curl.diff" | tr '\n' ' ' | cut -c1-300)" noout; fi
      C="$(curl -s -m 10 -X POST http://127.0.0.1:18425/shutdown)"
      is "curl -s -X POST http://127.0.0.1:18425/shutdown -> {\"stopping\":true}" "$C" '{"stopping":true}'
      for _ in $(seq 1 60); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.25; done
      if kill -0 "$SRV" 2>/dev/null; then bad "the JVM exits on its own after POST /shutdown" "still running 15 s later" noout; kill_tree "$SRV"
      else wait "$SRV"; is "…the JVM exits on its own, exit 0" "$?" "0"; fi
    else
      cp "$WORK/tb-srv.log" "$OUT"; bad "java -jar target/tiffinbox-web-1.0.0.jar" "nothing listened on 18425 within 40 s"; kill_tree "$SRV"
    fi
    wait_port_free 18425 && ok "port 18425 free again after the server" || bad "port 18425 free again" "still listening" noout
  else
    skip "java -jar … and the six curls" "port 18425 was busy before the run — that is already a FAIL above"
  fi

  rgives tiffinbox 'java -jar target/tiffinbox-web-1.0.0.jar 9090' && \
    skip "'pass another as the first argument: java -jar target/tiffinbox-web-1.0.0.jar 9090'" \
         "9090 is outside the 18400-18499 range this run may bind; the same positional-port argument is run below with 18431"

  # ---- the selector table. These are only true while tiffinbox-core is NOT in the local repository,
  # so they run BEFORE `install` (verify_course3.sh ran them in the same place, for the same reason).
  rm -rf "$TB/.m2-demo/com/tiffinbox"
  expect_rc "mvn -B clean package -pl tiffinbox-web (no -am) -> BUILD FAILURE, exit 1" 900 1 'BUILD FAILURE' "$TB" \
      "mvn -B $M2TB clean package -pl tiffinbox-web"
  as_central "$OUT" >"$WORK/tb-pl-errors.out"
  panel "…and the three [ERROR] lines the README prints$([ "$C4_CENTRAL_CACHE" != off ] && echo " (the cache's URL read as Central's)")" \
        tiffinbox in '[ERROR] Failed to execute goal on project tiffinbox-web' "$WORK/tb-pl-errors.out"
  expect_rc "mvn -q -B -pl tiffinbox-web exec:exec before install -> 'without the install the reactor cannot find tiffinbox-core'" 900 1 \
      'tiffinbox-core:jar:1.0.0' "$TB" "mvn -q -B $M2TB -pl tiffinbox-web exec:exec"
  expect_ok "mvn -B dependency:tree -pl tiffinbox-web -> BUILD SUCCESS, exit 0" 900 'BUILD SUCCESS' "$TB" "mvn -B $M2TB dependency:tree -pl tiffinbox-web"
  cp "$OUT" "$WORK/tb-treepl.out"
  hasF "…one [WARNING] above the tree: The POM for com.tiffinbox:tiffinbox-core:jar:1.0.0 is missing" \
       '[WARNING] The POM for com.tiffinbox:tiffinbox-core:jar:1.0.0 is missing, no dependency information available' "$WORK/tb-treepl.out"
  is "…and the tree is exactly the README's (core drawn flat)" "$(tree_lines "$WORK/tb-treepl.out" | tr '\n' '|')" \
     "$(rblock tiffinbox in '[WARNING] The POM for com.tiffinbox:tiffinbox-core' >"$WORK/r"; tree_lines "$WORK/r" | tr '\n' '|')"
  hasnt "…'h2 and the whole Spring subtree disappear from the picture'" 'com\.h2database:h2|org\.springframework' "$WORK/tb-treepl.out"
  expect_ok "mvn -B clean package -pl tiffinbox-core -> BUILD SUCCESS" 900 'BUILD SUCCESS' "$TB" "mvn -B $M2TB clean package -pl tiffinbox-core"
  hasnt "…and no reactor summary is printed at all" 'Reactor Summary'
  expect_ok "mvn -B clean package -pl tiffinbox-web -am -> BUILD SUCCESS" 900 'BUILD SUCCESS' "$TB" "mvn -B $M2TB clean package -pl tiffinbox-web -am"
  RS_AM="$(sed -n '/Reactor Summary/,/BUILD/p' "$OUT" | grep -oE '^\[INFO\] [A-Za-z ]+ \.+ (SUCCESS|FAILURE|SKIPPED)' | tr '\n' '|')"
  RS_ALL="$(sed -n '/Reactor Summary/,/BUILD/p' "$WORK/tb-build.out" | grep -oE '^\[INFO\] [A-Za-z ]+ \.+ (SUCCESS|FAILURE|SKIPPED)' | tr '\n' '|')"
  is "…3 modules built, the same reactor summary (timings aside) as the whole build — 'IS the whole build'" "$RS_AM" "$RS_ALL"

  # ---- versions live in one place
  expect_ok "mvn -B dependency:tree (whole project)" 900 'BUILD SUCCESS' "$TB" "mvn -B $M2TB dependency:tree"
  cp "$OUT" "$WORK/tb-tree.out"
  is "…the tree is exactly the README's" "$(tree_lines "$WORK/tb-tree.out" | tr '\n' '|')" \
     "$(rblock tiffinbox in '[INFO] com.tiffinbox:tiffinbox-parent:pom:1.0.0' >"$WORK/r"; tree_lines "$WORK/r" | tr '\n' '|')"
  # "The parent's <dependencyManagement> decides `a`, `b` … and — through the imported Spring Framework BOM —
  # every spring-* version; its <pluginManagement> decides the four plugin versions." Every name is read off
  # the README and looked up in the parent's <dependencyManagement>; the BOM must be an import there.
  python3 - "$(rfile tiffinbox)" "$TB/pom.xml" >"$WORK/tb-vers.txt" <<'PY'
import re, sys
t = re.sub(r"\s+", " ", open(sys.argv[1], encoding="utf-8").read())
i = t.find("The parent's `<dependencyManagement>` decides"); j = t.find("its `<pluginManagement>` decides", i)
seg = t[i:j] if i >= 0 and j > i else ""
names = [q for q in re.findall(r"`([^`]+)`", seg) if not q.startswith("<") and "*" not in q]
m = re.search(r"its `<pluginManagement>` decides the (\w+) plugin versions", t)
word = m.group(1) if m else "?"
pom = re.sub(r"<!--.*?-->", "", open(sys.argv[2]).read(), flags=re.S)
dm = re.search(r"<dependencyManagement>(.*?)</dependencyManagement>", pom, re.S)
dm = dm.group(1) if dm else ""
pm = re.search(r"<pluginManagement>(.*?)</pluginManagement>", pom, re.S)
pm = pm.group(1) if pm else ""
missing = [n for n in names if "<artifactId>%s</artifactId>" % n not in dm]
bom_said = "Spring Framework BOM" in seg
bom_there = bool(re.search(r"<artifactId>spring-framework-bom</artifactId>.*?<scope>import</scope>", dm, re.S))
nplug = len(re.findall(r"<plugin>", pm))
words = {"one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6}
print("names=%s" % " ".join(names))
print("missing=%s" % " ".join(missing))
print("bom=%s" % ("ok" if (not bom_said or bom_there) else "said-not-there"))
print("plugins=%s/%s" % (words.get(word, word), nplug))
PY
  VN="$(sed -n 's/^names=//p' "$WORK/tb-vers.txt")"
  if [ -n "$VN" ] && [ -z "$(sed -n 's/^missing=//p' "$WORK/tb-vers.txt")" ] && grep -qx 'bom=ok' "$WORK/tb-vers.txt"; then
    ok "'The parent's <dependencyManagement> decides $VN$(grep -q 'Spring Framework BOM' "$(rfile tiffinbox)" && echo ' and — through the imported Spring Framework BOM — every spring-* version')' (read off the parent pom)"
  else bad "'The parent's <dependencyManagement> decides …' (the names the README gives)" "$(tr '\n' ' ' <"$WORK/tb-vers.txt")" noout; fi
  P="$(sed -n 's/^plugins=//p' "$WORK/tb-vers.txt")"
  is "…'its <pluginManagement> decides the four plugin versions' (README's number / plugins in the parent)" "${P%%/*}" "${P##*/}"
  # counted with the XML comments removed (core's pom says "No <version>" in a comment) and required to
  # sit inside <parent>: a <version> anywhere else would be a dependency's or a plugin's.
  pom_versions_outside_parent() { python3 -c '
import re, sys
t = re.sub(r"<!--.*?-->", "", open(sys.argv[1]).read(), flags=re.S)
t = re.sub(r"<parent>.*?</parent>", "", t, flags=re.S)
print(len(re.findall(r"<version>", t)))' "$1"; }
  is "No child POM contains a <version> for a dependency or a plugin (outside <parent>, comments aside: core/web)" \
     "$(pom_versions_outside_parent "$TB/tiffinbox-core/pom.xml")/$(pom_versions_outside_parent "$TB/tiffinbox-web/pom.xml")" "0/0"
  expect_ok "javap -v -cp tiffinbox-core/target/classes com.tiffinbox.Dashboard | grep -E 'major|minor'" 60 'minor version: 0' \
      "$TB" "javap -v -cp tiffinbox-core/target/classes com.tiffinbox.Dashboard | grep -E 'major|minor'"
  has "…major version: 69, minor 0 — no preview bit" 'major version: 69'

  # ---- install, then exec:exec (needs -pl, needs the sibling in a repository)
  expect_ok "mvn -B clean install (tiffinbox-core lands in the scratch local repository)" 900 'BUILD SUCCESS' "$TB" "mvn -B $M2TB clean install"
  expect_rc "mvn -B exec:exec without -pl -> The parameter 'executable' is missing or invalid" 600 1 \
      "The parameter 'executable' is missing or invalid" "$TB" "mvn -B $M2TB exec:exec"
  if [ "$TBPORTS" = 1 ] && ! port_busy 18425; then
    ( cd "$TB" && exec bash -c "mvn -q -B $M2TB -pl tiffinbox-web exec:exec" ) >"$WORK/tb-exec.log" 2>&1 </dev/null &
    EX=$!
    if wait_port_up 18425; then
      sleep 0.5; cp "$WORK/tb-exec.log" "$OUT"
      has "mvn -q -B -pl tiffinbox-web exec:exec -> the same server, started by Maven" 'TiffinBox listening on http://127\.0\.0\.1:18425'
      C="$(curl -s -m 10 -X POST http://127.0.0.1:18425/shutdown)"
      is "…and POST /shutdown stops it: {\"stopping\":true}" "$C" '{"stopping":true}'
    else cp "$WORK/tb-exec.log" "$OUT"; bad "mvn -q -B -pl tiffinbox-web exec:exec" "nothing listened on 18425 within 40 s"; fi
    for _ in $(seq 1 60); do kill -0 "$EX" 2>/dev/null || break; sleep 0.25; done
    kill_tree "$EX"; wait "$EX" 2>/dev/null
    wait_port_free 18425 && ok "port 18425 free again after exec:exec" || bad "port 18425 free again after exec:exec" "still listening" noout
  else skip "mvn -q -B -pl tiffinbox-web exec:exec" "port 18425 is busy"; fi
  # README "Verified": "Offline receipt after one warm build: mvn -o -B verify → BUILD SUCCESS, exit 0, three runs."
  offline_pair "c4-tiffinbox" "$TB"
  for i in 2 3; do expect_ok "…mvn -o -B verify, offline run $i of 3" 900 'BUILD SUCCESS' "$TB" "mvn -o -B $M2TB verify"; done
  skip "'The receipt: the split changed nothing observable' — md5 $(rhash tiffinbox 'six captures, one hash') 6 of 6" \
       "no command is given; it compares c2-capstone with c3-tiffinbox, Course 3's receipt, not anything in this folder"

  # ---- "Course 4 starts here (added 2026-09-16)". Its three claims are "here" — the five sources hash to
  # fdb1643d…, Wiring.java is copied in, cmp-identical to c3-unit28's, and the ledger re-derives 18·4·3·0·0.
  # Where "here" is, is decided by the README: if the section carries a note that it is historical and names
  # ../c4-unit31/before/, the claims are checked THERE and the note's own claims about this folder are checked
  # here; without such a note the claims are about this folder and are checked in it. So a README that loses
  # the note (regresses to the old text) is held to the old text, and FAILs.
  SRC5='for f in Customer CustomerRepository Dashboard Database OrderQueue; do md5 -q $f.java; done | sort | md5 -q'
  awk '/^## Course 4 starts here/{f=1} /^## Course 4 — rewired/{f=0} f' "$(rfile tiffinbox)" >"$WORK/tb-c4sec.md"
  H5="$(rhash tiffinbox 'still hash to `')"
  TBSUM="$(sh_in "$TB/tiffinbox-core/src/main/java/com/tiffinbox" "$SRC5" 2>/dev/null)"
  if grep -q 'Historical' "$WORK/tb-c4sec.md" && grep -qF '../c4-unit31/before/' "$WORK/tb-c4sec.md"; then
    HB="$REPO/c4-unit31/before"
    ok "'Course 4 starts here' carries its note: historical, and 'run its checks there' — ../c4-unit31/before/"
    is "…the note: 'they now hash to … here' (the five sources in c4-tiffinbox/tiffinbox-core)" "$TBSUM" "$(rhash tiffinbox 'they now hash to')"
    expect_ok "…the note: 'onlyannotations.py shows the change is annotations only' (before/ -> c4-tiffinbox, core)" 60 \
        'set aside, in order \.+ 0$' "$REPO" 'python3 c4-unit31/onlyannotations.py c4-unit31/before/tiffinbox-core/src/main/java/com/tiffinbox c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox'
    expect_ok "…in ../c4-unit31/before/: 'the five carried sources still hash to $H5'" 30 "^$H5\$" \
        "$HB/tiffinbox-core/src/main/java/com/tiffinbox" "$SRC5"
    expect_ok "…in ../c4-unit31/before/: Wiring.java is in tiffinbox-core, cmp-identical to c3-unit28's ('Verified with cmp: identical')" 30 '' "$REPO" \
        'cmp c3-unit28/src/main/java/com/tiffinbox/wiring/Wiring.java c4-unit31/before/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java'
    expect_ok "…in ../c4-unit31/before/: the ledger re-derives (sh ../../c4-unit01/ledger.sh …/wiring/Wiring.java)" 60 '' "$HB" \
        'sh ../../c4-unit01/ledger.sh tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java'
    cp "$OUT" "$WORK/tb-ledger-before.out"
    panel "…and prints the section's panel, 18 · 4 · 3 · 0 · 0" tiffinbox after 'The ledger, re-derived here rather than remembered' "$WORK/tb-ledger-before.out"
    expect_rc "…'not in this one': here the same ledger exits 2, nothing to count" 60 2 'nothing to count' "$TB" \
        'sh ../c4-unit01/ledger.sh tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java'
  else
    WHY=""
    [ "$TBSUM" = "$H5" ] || WHY="$WHY the five sources hash $TBSUM, not $H5;"
    [ -f "$TB/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java" ] || WHY="$WHY tiffinbox-core has no wiring/Wiring.java to be cmp-identical to c3-unit28's;"
    sh_in "$TB" 'sh ../c4-unit01/ledger.sh tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java' >"$WORK/tb-ledger.out" 2>&1
    L="$?"; [ "$L" = 0 ] || WHY="$WHY the ledger it quotes (18/4/3/0/0) exits $L here: $(head -1 "$WORK/tb-ledger.out");"
    if [ -z "$WHY" ]; then ok "'Course 4 starts here': the five sources hash as quoted, Wiring.java is here, the ledger re-derives here"
    else bad "'Course 4 starts here' (2026-09-16), no historical note: 'the five carried sources still hash to fdb1643d here', 'Wiring.java … copied here', and its ledger panel" \
             "${WHY# } — stale since unit 31's rewire; the README's own 'Course 4 — rewired' section below it says Wiring.java is gone" noout; fi
  fi

  # ---- "Course 4 — rewired (capstone)"
  is "rewired: Wiring.java is gone from both modules" "$(find "$TB" -name Wiring.java -not -path '*/.m2-demo/*' | wc -l | tr -d ' ')" "0"
  is "…TiffinBoxApp carries @Configuration @ComponentScan @PropertySource" \
     "$(grep -cE '^@(Configuration|ComponentScan|PropertySource)' "$TB/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java" | tr -d ' ')" "3"
  is "…tiffinbox.properties holds the JDBC URL, cooks, days and port" \
     "$(grep -oE '^tiffinbox\.[a-z-]+' "$TB/tiffinbox-web/src/main/resources/tiffinbox.properties" | tr '\n' ' ')" \
     "tiffinbox.jdbc-url tiffinbox.cooks tiffinbox.days tiffinbox.port "
  is "…the core module now depends on spring-context and jakarta.annotation-api" \
     "$(grep -cE '<artifactId>(spring-context|jakarta.annotation-api)</artifactId>' "$TB/tiffinbox-core/pom.xml" | tr -d ' ')" "2"
  rgives tiffinbox 'mvn -q -DskipTests package' && rgives tiffinbox 'java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431' \
    || bad "the README still prints the two run lines" "not found verbatim" noout
  expect_ok "mvn -q -DskipTests package (rewired)" 900 '' "$TB" "mvn -q $M2TB -DskipTests package"
  if [ "$TBPORTS" = 1 ] && ! port_busy 18431; then
    ( cd "$TB" && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431 ) >"$WORK/tb-18431.log" 2>&1 </dev/null &
    SRV=$!
    if wait_port_up 18431; then
      sleep 0.5; cp "$WORK/tb-18431.log" "$OUT"
      has "java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431 -> listening on 18431 (the port argument wins)" 'TiffinBox listening on http://127\.0\.0\.1:18431'
      is "…GET /kitchen on 18431" "$(curl -s -m 10 http://127.0.0.1:18431/kitchen)" '{"ordersCooked":120,"ordersValue":24300}'
      is "…POST /shutdown" "$(curl -s -m 10 -X POST http://127.0.0.1:18431/shutdown)" '{"stopping":true}'
    else cp "$WORK/tb-18431.log" "$OUT"; bad "java -jar … 18431" "nothing listened on 18431 within 40 s"; fi
    for _ in $(seq 1 60); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.25; done
    if kill -0 "$SRV" 2>/dev/null; then kill_tree "$SRV"; bad "…the JVM exits on its own after POST /shutdown" "still running 15 s later" noout
    else wait "$SRV"; is "…the JVM exits on its own, exit 0" "$?" "0"; fi
  else skip "java -jar … 18431" "port 18431 is busy"; fi
  end_unit "$TB" 18425 18431
  # 80 MB nobody else reads, and unit 31's exercise rsyncs this folder: gone now unless kept or not ours.
  [ "$KEEP_M2" = 1 ] || { created_by_run "c4-tiffinbox/.m2-demo/" && rm -rf "$TB/.m2-demo"; }
fi

# ======================================================= Sections 1 and 2 ===
# Units 01-12: no receipts.sh. Each README prints the build lines and the java lines in a fenced
# block and quotes the md5s in its prose, "3/3". Section 1 (01-06): exercise/ and breaks/ resolve into
# THIS UNIT's repository (unit 01: "The Boot project keeps its own .m2-demo, because it resolves a parent
# this unit's repository does not hold") — the .gitignore has no .m2-demo for them. Section 2 (07-12):
# exercise/ has its own (.gitignore: c4-unit0N/exercise/.m2-demo/).
R1='$PWD/../.m2-demo'        # an exercise/ of Section 1, and a solution copy beside it
R2='$PWD/../../.m2-demo'     # a breaks/<name>/ of Section 1

# exercise12 NN REPO_EXPR — build the exercise (and a solution copy) the way the unit builds itself.
# Leaves E (the exercise) and S (the solution copy, built) set.
exercise12() {
  local n="$1" r="$2"
  E="$REPO/c4-unit$n/exercise"
  build12 "exercise/" - "$E" "$r" || return 1
  solution_copy "$n"
  printf '  %s(exercise/solution/ laid over a copy: %s)%s\n' "$DIM" "$SOL_APPLIED" "$OFF"
  build12 "exercise/ + solution/ (copy)" - "$S" "$r"
}
end_solution() { rm -rf "$REPO/c4-unit$1/.verify-solution"; }

# =============================================================== c4-unit01 ===
if unit 01 "why a container at all"; then
  SRC5='for f in Customer CustomerRepository Dashboard Database OrderQueue; do md5 -q $f.java; done | sort | md5 -q'
  H5="$(rhash 01 'It gives `')"
  rgives 01 "$SRC5" || bad "the README still prints the derivation" "not found: $SRC5" noout
  # "It gives `H` in `P1`, in `P2` (…) and in the frozen `P3` — three places, one value." The places are READ OFF
  # THE SENTENCE (a backticked path; "…/.../…" is a wildcard), so the sentence is held to whatever it names.
  python3 - "$(rfile 01)" "$REPO" >"$WORK/u01-places.txt" <<'PY'
import glob, os, re, sys
t = re.sub(r"\s+", " ", open(sys.argv[1], encoding="utf-8").read()); repo = sys.argv[2]
i = t.find("It gives `"); j = t.find("three places, one value", i)
seg = t[i:j] if i >= 0 and j > i else ""
for q in re.findall(r"`([^`]+)`", seg):
    if "/" not in q: continue
    pat = os.path.join(glob.escape(repo), q.replace("...", "**"))
    hits = [h for h in sorted(glob.glob(pat, recursive=True)) if os.path.isfile(os.path.join(h, "Customer.java"))]
    print("%s\t%s" % (q, hits[0] if hits else ""))
PY
  is "…the sentence names three places ('three places, one value')" "$(grep -c . "$WORK/u01-places.txt" | tr -d ' ')" "3"
  while IFS="$(printf '\t')" read -r PL PD; do
    if [ -z "$PD" ]; then bad "…the five sources in $PL -> $H5" "no such folder with the five sources in this clone" noout; continue; fi
    expect_ok "…the five carried sources, derived as printed, in $PL -> $H5" 30 "^$H5\$" "$PD" "$SRC5"
  done <"$WORK/u01-places.txt"
  TBS="$(sh_in "$REPO/c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox" "$SRC5" 2>/dev/null)"
  TBQ="$(rticks 01 'whose copies now hash' 1)"
  TBQ="${TBQ%…}"
  is "…'c4-tiffinbox, whose copies now hash ${TBQ:-?}…' (a prefix, as the README quotes it)" "${TBS:0:${#TBQ}}" "${TBQ:-the README quotes no hash here}"
  expect_ok "'Since the capstone': c4-tiffinbox's copies differ only by annotations and imports (onlyannotations.py: 0 code lines, exit 0)" 60 \
      'set aside, in order \.+ 0$' "$REPO" 'python3 c4-unit31/onlyannotations.py c4-unit01/src/main/java/com/tiffinbox c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox'

  # ---- the command block, as printed, in order
  BOXES='java -cp "target/classes:$(cat .cp)" com.tiffinbox.SameThreeBoxes'
  expect_ok "c4-unit01: $MVN_PKG" 900 'BUILD SUCCESS' "$U" "$MVN_PKG"
  # the block must WRITE .cp (its own build-classpath line, as units 02-12 print it) before its first java line
  # READS it — a line elsewhere that writes some other .cp (the break's, below) does not count
  CPORDER="$(rblock 01 in "$BOXES" | python3 -c '
import re, sys
w = lambda x: re.sub(r"\s+", " ", x.strip())
L = [w(l) for l in sys.stdin.read().split("\n")]
wr = next((i for i, l in enumerate(L) if l == w(sys.argv[1])), -1)
rd = next((i for i, l in enumerate(L) if l.startswith(w(sys.argv[2]))), -1)
print("ok" if 0 <= wr < rd else "write=%d read=%d" % (wr, rd))' "$MVN_CP" "$BOXES")"
  if [ "$CPORDER" = ok ]; then
    ok "the README block writes .cp (its dependency:build-classpath line) before its first java line reads it"
    expect_ok "c4-unit01: $MVN_CP" 600 '' "$U" "$MVN_CP"
  else
    if [ -e "$U/.cp" ]; then EVID="(this tree has a .cp left by an earlier run; a fresh clone has none — .cp is .gitignored)"
    else timed 60 sh_in "$U" "$BOXES"; EVID="on this fresh clone the line exits $RC: $(grep -m1 -E 'No such file|NoClassDefFoundError' "$OUT" | cut -c1-120)"; fi
    bad "README block, in order: 'mvn … clean package' then '$BOXES'" \
        "no line of unit 01's block writes .cp before it is read ($CPORDER; units 02-12 print 'dependency:build-classpath -Dmdep.outputFile=.cp' for it); $EVID" noout
    expect_ok "(to check the rest) .cp written with the line units 02-12 print" 600 '' "$U" "$MVN_CP"
  fi
  c3 "java … SameThreeBoxes -> exit 0, 3/3" 01 u01-boxes none "$U" "$BOXES"; claim3 "java … SameThreeBoxes -> exit 0, 3/3" 0 -
  c3 "java … ContextReport" 01 u01-cr none "$U" "$JCP com.tiffinbox.ContextReport"
  claim3 "java … ContextReport -> exit 0, 3/3, the md5 the README quotes ('the same hash this unit's own ContextReport produces')" 0 "$(rhash 01 'and it was run: exit 0, md5 `')"
  c3 "java … ContextReport --stable" 01 u01-crs none "$U" "$JCP com.tiffinbox.ContextReport --stable"; claim3 "java … ContextReport --stable -> exit 0, 3/3" 0 -
  c3 "sh ledger.sh" 01 u01-ledger none "$U" 'sh ledger.sh'
  claim3 "sh ledger.sh -> exit 0, 3/3, md5 of .r-ledger{1,2,3}" 0 "$(rhash 01 '`.r-ledger{1,2,3}`')"
  hasC "…the row the README names (TiffinBoxConfig.java exists here)" "$(rticks 01 '`.r-ledger{1,2,3}`' 2)" "$WORK/u01-ledger.1.out"
  c3 "ledger against c4-unit31/before" 01 u01-ledgertb none "$U" '(cd ../c4-unit31/before && sh ../../c4-unit01/ledger.sh tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java)'
  claim3 "(cd ../c4-unit31/before && sh ../../c4-unit01/ledger.sh …) -> exit 0, 3/3, md5 of .r-ledger-tb{1,2,3}" 0 "$(rhash 01 '`.r-ledger-tb{1,2,3}`')"
  has "…the same row at 0" 'places that order is written down \.+ 0$' "$WORK/u01-ledgertb.1.out"
  diff "$WORK/u01-ledger.1.out" "$WORK/u01-ledgertb.1.out" >"$WORK/u01-ledger.diff"
  is "…'diff of the two reports exactly that one line'" "$(grep -c '^[<>]' "$WORK/u01-ledger.diff" | tr -d ' ')/$(grep -c '^[<>].*places that order is written down' "$WORK/u01-ledger.diff" | tr -d ' ')" "2/2"
  # the break's capture: the block must PRODUCE breaks/one-bean-deleted/.r-cb1.out before chain.py reads it
  B1="$U/breaks/one-new-deleted"; B2="$U/breaks/one-bean-deleted"
  SCRIPT_MADE=""
  CHAINCMD='python3 chain.py breaks/one-bean-deleted/.r-cb1.out'
  BRK='(cd breaks/one-bean-deleted && mvn -B -q -Dmaven.repo.local="$PWD/../../.m2-demo" clean package dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime \
   && java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport > .r-cb1.out 2>&1; echo "exit $?")'
  rgives 01 "$CHAINCMD" || bad "the README still prints: $CHAINCMD" "not found" noout
  CBORDER="$(rblock 01 in "$CHAINCMD" | python3 -c '
import re, sys
b = re.sub(r"\\\n\s*", " ", sys.stdin.read()).split("\n")
wr = next((i for i, l in enumerate(b) if re.search(r">\s*\.r-cb1\.out", l) and "one-bean-deleted" in l), -1)
rd = next((i for i, l in enumerate(b) if l.strip().startswith(sys.argv[1])), -1)
print("ok" if 0 <= wr < rd else "write=%d read=%d" % (wr, rd))' "$CHAINCMD")"
  if [ "$CBORDER" = ok ]; then
    ok "the README block writes breaks/one-bean-deleted/.r-cb1.out before '$CHAINCMD' reads it"
    if python3 -c '
import re, sys
n = lambda x: re.sub(r"\s+", " ", re.sub(r"\\\n", " ", x)).strip()
sys.exit(0 if n(sys.argv[1]) in n(open(sys.argv[2]).read()) else 1)' "$BRK" "$(rfile 01)"; then
      expect_ok "README: (cd breaks/one-bean-deleted && mvn … clean package dependency:build-classpath … && java … ContextReport > .r-cb1.out 2>&1; echo \"exit \$?\") -> 'exit 1: the break'" \
          900 '^exit 1$' "$U" "$BRK"
    else
      bad "the README's break line is the one this script runs" "the README's line differs from: $BRK — the rest of this unit's break checks use what the README prints" noout
      expect_ok "(the README's break line, as this script knew it)" 900 '^exit 1$' "$U" "$BRK"
    fi
    has "…the compiler saw nothing wrong: mvn clean package exited 0 and java ran (the capture holds its exception)" \
        '^Exception in thread "main" ' "$B2/.r-cb1.out"
  else
    if [ -f "$B2/.r-cb1.out" ]; then EVID="(this tree has one from an earlier run)"
    else timed 60 sh_in "$U" "$CHAINCMD"; EVID="on this fresh clone: exit $RC, $(tail -1 "$OUT" | cut -c1-140)"; fi
    bad "README: $CHAINCMD" "breaks/one-bean-deleted/.r-cb1.out is .gitignored (c4-unit01/breaks/one-bean-deleted/.r-*) and no line of the block creates it first ($CBORDER); $EVID" noout
    expect_ok "(to check the rest) the break built and its ContextReport captured, as the author did" 900 '^exit 1$' "$U" "$BRK"
    SCRIPT_MADE="c4-unit01/breaks/one-bean-deleted/.cp"   # written by this script's stand-in, not by a README line
  fi
  expect_ok "README: $CHAINCMD" 60 '' "$U" "$CHAINCMD"
  cp "$OUT" "$WORK/u01-cbchain.out"
  chain_is "…java … ContextReport in the break: UnsatisfiedDependencyException -> Caused by: NoSuchBeanDefinitionException (not a compile error)" \
      "$WORK/u01-cbchain.out" org.springframework.beans.factory.UnsatisfiedDependencyException org.springframework.beans.factory.NoSuchBeanDefinitionException
  # everything the block wrote must be covered by .gitignore — .cp is "machine-local by construction and must
  # never be committed" (the .gitignore's own words)
  NU="$( (cd "$REPO" && git status --porcelain --untracked-files=normal -- c4-unit01) | sed -n 's/^?? //p' | grep -vxF -f "$WORK/extras.before" \
        | grep -vxF "${SCRIPT_MADE:-/nothing/}" | tr '\n' ' ')"
  if [ -z "$NU" ]; then ok "…and everything the README's block wrote is covered by .gitignore (git status shows nothing new)"
  else bad "…and everything the README's block wrote is covered by .gitignore" "git status shows new untracked: $NU" noout; fi

  # ---- the two deletions, side by side
  expect_rc "breaks/one-new-deleted: mvn clean compile -> exit 1, BUILD FAILURE" 900 1 'BUILD FAILURE' "$B1" "mvn -B -Dmaven.repo.local=\"$R2\" clean compile"
  has "…2 compile errors" '^\[INFO\] 2 errors'

  # ---- the exercise
  if exercise12 01 "$R1"; then
    cap3 u01-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean: ContextReport -> exit 0, 3/3" 0 -
    panel "…and says what the README prints" 01 in 'beans(app)=3' "$WORK/u01-exs.1.out"
    cap3 u01-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 01 'and it was run: exit 0, md5 `')"
    hasC "…End state" "$(rticks 01 '**End state:**' 2)" "$WORK/u01-exsol.1.out"
    hasC "…End state" "$(rticks 01 '**End state:**' 3)" "$WORK/u01-exsol.1.out"
  fi
  end_solution 01
  # ---- reproducible offline
  offline_pair "c4-unit01" "$U"
  offline_pair "exercise/" "$U/exercise" "$R1"
  offline_pair "breaks/one-bean-deleted/" "$B2" "$R2"
  offline_pair "boot-in-ninety-seconds/ (its own .m2-demo)" "$U/boot-in-ninety-seconds"
  expect_rc "breaks/one-new-deleted/ offline: exit 1 — 'it is the break, and it is supposed to'" 900 1 'cannot find symbol' "$B1" \
      "mvn -o -B -Dmaven.repo.local=\"$R2\" verify"
  hasnt "…and for its compile errors, not for a missing artifact" 'offline mode|Cannot access|Could not resolve'
  end_unit "$U"
fi

# =============================================================== c4-unit02 ===
if unit 02 "beans, definitions and the context"; then
  build12 "c4-unit02" 02 "$U"
  c3 "java … Definitions" 02 u02-def none "$U" 'java -cp "target/classes:src/main/resources:$(cat .cp)" com.tiffinbox.Definitions'
  claim3 'java -cp "target/classes:src/main/resources:$(cat .cp)" com.tiffinbox.Definitions -> exit 0, 3/3' 0 -
  panel "…the recipe and the eight lines of XML fill DIFFERENT fields of one BeanDefinition" 02 in 'THE RECIPE' "$WORK/u02-def.1.out"
  c3 "java … ContextReport" 02 u02-cr none "$U" "$JCP com.tiffinbox.ContextReport"; claim3 "java … ContextReport -> exit 0, 3/3" 0 -
  c3 "java … ContextReport --stable" 02 u02-crs none "$U" "$JCP com.tiffinbox.ContextReport --stable"; claim3 "java … ContextReport --stable -> exit 0, 3/3" 0 -
  c3 "java … BreakMissingName" 02 u02-miss "$U/chain.py" "$U" "$JCP com.tiffinbox.BreakMissingName"
  claim3 "java … BreakMissingName -> exit 1, 3/3, the failure receipt's md5 (through the unit's chain.py)" 1 "$(rhash 02 'hashable with no masking, md5 `')"
  hasC "…exception type and first line" "Exception in thread \"main\" $(rblock 02 in 'exception type' | sed -n 's/^exception type *//p'): $(rblock 02 in 'exception type' | sed -n 's/^first line *//p')" "$WORK/u02-miss.1.out"
  if exercise12 02 "$R1"; then
    cap3 u02-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean: ContextReport -> exit 0, 3/3" 0 -
    hasnt "…no warning" 'WARN' "$WORK/u02-exs.1.raw"
    has "…and lists a bean called theDashboard" '^  theDashboard ' "$WORK/u02-exs.1.out"
    cap3 u02-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 02 '**End state:**')"
    has "…End state: the beans(app)=5 block contains dashboard" '^  dashboard ' "$WORK/u02-exsol.1.out"
    has "…beans(app)=5" '^beans\(app\)=5$' "$WORK/u02-exsol.1.out"
  fi
  end_solution 02
  offline_pair "c4-unit02" "$U"; offline_pair "exercise/" "$U/exercise" "$R1"
  end_unit "$U"
fi

# =============================================================== c4-unit03 ===
if unit 03 "dependency injection: constructor, setter, field"; then
  build12 "c4-unit03" 03 "$U"
  c3 "java … ThreeInjectionPoints" 03 u03-three none "$U" "$JCP com.tiffinbox.ThreeInjectionPoints"
  claim3 "java … ThreeInjectionPoints -> exit 0, 3/3" 0 -
  panel "…AFTER / DURING construction, as the README prints them" 03 in 'AFTER the container' "$WORK/u03-three.1.out"
  c3 "java … ContextReport" 03 u03-cr none "$U" "$JCP com.tiffinbox.ContextReport"; claim3 "java … ContextReport -> exit 0, 3/3" 0 -
  c3 "java … BreakFieldUsedTooEarly" 03 u03-npe "$U/chain.py" "$U" "$JCP com.tiffinbox.BreakFieldUsedTooEarly"
  claim3 "java … BreakFieldUsedTooEarly -> exit 1, 3/3 byte-identical, md5 (through chain.py)" 1 "$(rhash 03 'byte-identical, md5 `')"
  chain_is "…a three-link chain" "$WORK/u03-npe.1.out" org.springframework.beans.factory.BeanCreationException \
      org.springframework.beans.BeanInstantiationException java.lang.NullPointerException
  hasC "…and the last link names the field" "$(rblock 03 in 'Caused by        java.lang.NullPointerException:' | tail -1)" "$WORK/u03-npe.1.out"
  if exercise12 03 "$R1"; then
    cap3 u03-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean: ContextReport -> exit 0, 3/3" 0 -
    panel "…a kitchen sized for zero, four customers" 03 in 'sizer.cooksNeeded()                    0' "$WORK/u03-exs.1.out"
    cap3 u03-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 03 '**End state:**')"
    hasC "…End state" "$(rticks 03 '**End state:**' 1)" "$WORK/u03-exsol.1.out"
  fi
  end_solution 03
  offline_pair "c4-unit03" "$U"; offline_pair "exercise/" "$U/exercise" "$R1"
  end_unit "$U"
fi

# =============================================================== c4-unit04 ===
if unit 04 "component scanning and stereotypes"; then
  build12 "c4-unit04" 04 "$U"
  c3 "java … scan.WhatTheScannerReads" 04 u04-scan none "$U" "$JCP com.tiffinbox.scan.WhatTheScannerReads"
  claim3 "java … scan.WhatTheScannerReads -> exit 0, 3/3" 0 -
  panel "…REFRESH loads only what it instantiates; REGISTERED, sorted" 04 in 'REFRESH - and the only classes' "$WORK/u04-scan.1.out"
  hasnt "…CsvMenuRepository never prints (the scanner read its bytes; the JVM never loaded it)" 'CLASS LOADED +CsvMenuRepository' "$WORK/u04-scan.1.out"
  is "…ReportBuilder does not print at refresh, and does once it is asked for" \
     "$(awk '/CLASS LOADED +ReportBuilder/{r=NR} /^NOW ask for the lazy one/{a=NR} END{print (r>a && a>0) ? "after the ask" : "r=" r " a=" a}' "$WORK/u04-scan.1.out")" "after the ask"
  c3 "java … ContextReport" 04 u04-cr none "$U" "$JCP com.tiffinbox.ContextReport"; claim3 "java … ContextReport -> exit 0, 3/3" 0 -
  has "…reportBuilder's row reads (not built)" '^  reportBuilder .*\(not built\)' "$WORK/u04-cr.1.out"
  BW="$U/breaks/one-segment-wrong"
  build12 "breaks/one-segment-wrong" - "$BW" "$R2"
  cap3 u04-wrong "$U/chain.py" "$BW" "$JCP com.tiffinbox.ContextReport"
  claim3 "breaks/one-segment-wrong: ContextReport -> exit 1, 3/3, md5 (through chain.py)" 1 "$(rhash 04 '(exit 1, 3/3, md5')"
  BWS="$(rblock 04 in 'beans(app)=4      ->' | grep -- '->')"
  has "…the unit itself: ${BWS%% *}" "^$(printf '%s' "${BWS%% *}" | sed 's/[()]/\\&/g')\$" "$WORK/u04-cr.1.out"
  has "…one letter wrong: ${BWS##* }" "^$(printf '%s' "${BWS##* }" | sed 's/[()]/\\&/g')\$" "$WORK/u04-wrong.1.out"
  hasF "…NoSuchBeanDefinitionException: No bean named 'reportBuilder' available" "NoSuchBeanDefinitionException: No bean named 'reportBuilder' available" "$WORK/u04-wrong.1.out"
  hasnt "…'The context refreshed. Nothing was logged.'" '^(WARNING|SEVERE|INFO): ' "$WORK/u04-wrong.1.raw"
  # the module-path probe
  rgives 04 'cd modpath && sh run.sh' || bad "the README still prints: cd modpath && sh run.sh" "not found" noout
  expect_ok "cd modpath && sh run.sh -> exit 0 ('3 of 3 byte-identical: yes')" 300 '^3 of 3 byte-identical: yes, all exit 0$' "$U" 'cd modpath && sh run.sh'
  cp "$OUT" "$WORK/u04-mod.out"
  HM="$(rhash 04 'output lines, md5 `')"
  is "…each of the three runs: exit 0, md5 $HM, 6 output lines" \
     "$(grep -cE "^run [123]  exit 0  md5 $HM  6 output lines\$" "$WORK/u04-mod.out" | tr -d ' ')" "3"
  panel "…and the six lines are the README's" 04 in 'module of this class : tiffinbox.scan' "$U/modpath/.r-mod1.out"
  expect_ok "…the three menu/*.java under modpath/src are byte-identical to the project's (cmp, all three)" 30 '' "$U" \
      'for f in CsvMenuRepository JdbcMenuRepository MenuRepository; do cmp modpath/src/com/tiffinbox/menu/$f.java src/main/java/com/tiffinbox/menu/$f.java || exit 1; done'
  is "…modpath/src/module-info.java carries exports and no opens" \
     "$([ "$(grep -cE '^[[:space:]]*exports ' "$U/modpath/src/module-info.java")" -gt 0 ] && echo exports)/$(grep -cE '^[[:space:]]*opens ' "$U/modpath/src/module-info.java" | tr -d ' ') opens" "exports/0 opens"
  skip "the module table's rows 2-6 (CGLIB in a module with no opens, --add-opens …=ALL-UNNAMED / =spring.core, opens, class path)" \
       "the README says so itself: that failing probe 'was run in the author's scratch module path, not here' — nothing shipped to run"
  if exercise12 04 "$R1"; then
    cap3 u04-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean and ContextReport EXITS 2, 3/3" 2 -
    panel "…with the diagnostic the README prints" 04 in 'beans of type MenuRepository           0' "$WORK/u04-exs.1.out"
    cap3 u04-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 04 '**End state:**')"
    hasC "…End state" "$(rticks 04 '**End state:**' 1)" "$WORK/u04-exsol.1.out"
    hasC "…End state" "$(rticks 04 '**End state:**' 2)" "$WORK/u04-exsol.1.out"
  fi
  end_solution 04
  offline_pair "c4-unit04" "$U"; offline_pair "exercise/" "$U/exercise" "$R1"
  offline_pair "breaks/one-segment-wrong/ ('it builds and verifies perfectly')" "$BW" "$R2"
  end_unit "$U"
fi

# =============================================================== c4-unit05 ===
if unit 05 "@Configuration and @Bean"; then
  build12 "c4-unit05" 05 "$U"
  c3 "java … AbA" 05 u05-aba none "$U" "$JCP com.tiffinbox.AbA"
  claim3 "java … AbA -> exit 0, 3/3, the unmasked md5 the README quotes" 0 "$(rhash 05 'byte-identical on three runs — md5')"
  panel "…A / B / A-prime as the README prints them" 05 in '[A ] as written' "$WORK/u05-aba.1.out" 'back to true, and back to one object'
  is "…@Bean body ran counts from BEFORE refresh: A = 1, B = 3" "$(grep -oE '@Bean body ran +[0-9]+' "$WORK/u05-aba.1.out" | awk '{print $NF}' | head -2 | tr '\n' ' ')" "1 3 "
  c3 "java … AbA --stable" 05 u05-abas none "$U" "$JCP com.tiffinbox.AbA --stable"
  claim3 "java … AbA --stable -> exit 0, 3/3, the masked md5" 0 "$(rhash 05 'change at all: `')"
  c3 "java … ContextReport" 05 u05-cr none "$U" "$JCP com.tiffinbox.ContextReport"; claim3 "java … ContextReport -> exit 0, 3/3" 0 -
  c3 "java … ContextReport --stable" 05 u05-crs none "$U" "$JCP com.tiffinbox.ContextReport --stable"; claim3 "java … ContextReport --stable -> exit 0, 3/3" 0 -
  HC='java -XX:+UnlockExperimentalVMOptions -XX:hashCode=0 -cp "target/classes:$(cat .cp)" com.tiffinbox.AbA'
  c3 "hashCode=0 AbA" 05 u05-abah none "$U" "$HC"
  claim3 "$HC -> exit 0, 3/3, 'completely different values'" 0 "$(rhash 05 'prints completely different values')"
  c3 "hashCode=0 AbA --stable" 05 u05-abahs none "$U" "$HC --stable"
  claim3 "… --stable under the flag -> the SAME masked md5 as without it" 0 "$(rhash 05 'change at all: `')"
  expect_rc "-XX:hashCode=0 WITHOUT the unlock flag -> the JVM refuses to start, exit 1" 60 1 "Improperly specified VM option 'hashCode=0'" "$U" \
      'java -XX:hashCode=0 -cp "target/classes:$(cat .cp)" com.tiffinbox.AbA'
  timed 120 sh_in "$U" "$JCP com.tiffinbox.ContextReport 2>'$WORK/u05-stderr' >/dev/null; $JCP com.tiffinbox.AbA 2>>'$WORK/u05-stderr' >/dev/null"
  is "CGLIB on JDK 25: exit 0, no --add-opens, 'nothing on stderr' (ContextReport and AbA)" "$RC/$(wc -c <"$WORK/u05-stderr" | tr -d ' ') bytes" "0/0 bytes"
  skip "the three CGLIB limits (final @Configuration class, final @Bean method, no visible constructor)" "no probe for them ships in this unit; the table is prose"
  if exercise12 05 "$R1"; then
    cap3 u05-exs none "$E" "$JCP com.tiffinbox.ContextReport --stable"
    claim3 "exercise/ starts clean: ContextReport --stable -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 05 'exercise/.r-start{1,2,3}')"
    panel "…two pools where the app thinks it has one" 05 in 'dataSource() == dataSource()           false' "$WORK/u05-exs.1.out"
    cap3 u05-exsol none "$S" "$JCP com.tiffinbox.ContextReport --stable"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 05 '`distinct DataSource objects 1`, md5')"
    for k in 1 2 3; do hasC "…End state" "$(rticks 05 '**End state:**' $k)" "$WORK/u05-exsol.1.out"; done
    same_file "…'without touching Pool'" "$E/src/main/java/com/tiffinbox/Pool.java" "$S/src/main/java/com/tiffinbox/Pool.java"
  fi
  end_solution 05
  offline_pair "c4-unit05" "$U"; offline_pair "exercise/" "$U/exercise" "$R1"
  end_unit "$U"
fi

# =============================================================== c4-unit06 ===
if unit 06 "ambiguity: @Primary, @Qualifier and bean collections"; then
  build12 "c4-unit06" 06 "$U"
  c3 "java … ThreeWaysOut" 06 u06-three none "$U" "$JCP com.tiffinbox.ThreeWaysOut"; claim3 "java … ThreeWaysOut -> exit 0, 3/3" 0 -
  panel "…when you want all of them, ask for all of them" 06 in 'List<OrderQueue>.size()' "$WORK/u06-three.1.out"
  c3 "java … PrimaryPicks" 06 u06-pp none "$U" "$JCP com.tiffinbox.PrimaryPicks"
  claim3 "java … PrimaryPicks -> exit 0, 3/3, md5, 13 output lines" 0 "$(rhash 06 '`.r-pp{1,2,3}.out`, md5 `')" 13
  panel "…A / B / A' rows" 06 in '[A ] no @Primary' "$WORK/u06-pp.1.out"
  is "…'The capture's own first line says the one thing this program silences'" "$(head -1 "$WORK/u06-pp.1.out" | tr -s ' ' | sed 's/ *$//')" \
     "$(rticks 06 'the one thing this program silences:' 1)"
  c3 "java … ContextReport" 06 u06-cr none "$U" "$JCP com.tiffinbox.ContextReport"; claim3 "java … ContextReport -> exit 0, 3/3" 0 -
  c3 "java … BreakAmbiguous" 06 u06-amb "$U/chain.py" "$U" "$JCP com.tiffinbox.BreakAmbiguous"
  claim3 "java … BreakAmbiguous (no tie-breaker) -> exit 1, 3/3, md5 (through chain.py)" 1 "$(rhash 06 'no tie-breaker exit 1')"
  hasC "…the sentence" "$(rblock 06 in 'no tie-breaker' | sed -n '3,4p' | sed 's/^ *//' | tr '\n' ' ')" "$WORK/u06-amb.1.out"
  has "…thrown from resolveNotUnique" 'resolveNotUnique' "$WORK/u06-amb.1.out"
  BP="$U/breaks/primary-on-both"
  build12 "breaks/primary-on-both" - "$BP" "$R2"
  cap3 u06-both "$U/chain.py" "$BP" "$JCP com.tiffinbox.BreakAmbiguous"
  claim3 "breaks/primary-on-both: BreakAmbiguous -> exit 1, 3/3, md5 (through chain.py)" 1 "$(rhash 06 '@Primary on BOTH exit 1')"
  hasC "…a different sentence from the same exception type" "$(rblock 06 in '@Primary on BOTH' | sed -n '9,10p' | sed 's/^ *//' | tr '\n' ' ')" "$WORK/u06-both.1.out"
  has "…thrown from determinePrimaryCandidate" 'determinePrimaryCandidate' "$WORK/u06-both.1.out"
  if exercise12 06 "$R1"; then
    cap3 u06-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean: ContextReport -> exit 0, 3/3" 0 -
    panel "…two rails, the monitor watching one" 06 in 'List<OrderQueue> injected size         1' "$WORK/u06-exs.1.out"
    cap3 u06-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 06 '**End state:**')"
    hasC "…End state" "$(rticks 06 '**End state:**' 1)" "$WORK/u06-exsol.1.out"
  fi
  end_solution 06
  offline_pair "c4-unit06" "$U"; offline_pair "exercise/" "$U/exercise" "$R1"; offline_pair "breaks/primary-on-both/" "$BP" "$R2"
  end_unit "$U"
fi

# =============================================================== c4-unit07 ===
if unit 07 "the bean lifecycle, step by step"; then
  build12 "c4-unit07" 07 "$U"
  c3 "java … LifecycleRail" 07 u07-rail none "$U" "$JCP com.tiffinbox.LifecycleRail"
  claim3 "java … LifecycleRail -> exit 0, 3/3, md5, 30 output lines" 0 "$(rhash 07 '`.r-rail{1,2,3}.out`, md5 `')" 30
  panel "…17 starting, 3 closing, 20 in total — counted by the instrument" 07 in 'callbacks while STARTING' "$WORK/u07-rail.1.out"
  c3 "java … ThrowInACallback" 07 u07-throw "$U/chain.py" "$U" "$JCP com.tiffinbox.ThrowInACallback"
  claim3 "java … ThrowInACallback -> exit 0, 3/3, md5, 30 output lines (through chain.py)" 0 "$(rhash 07 '`.r-throw{1,2,3}.out`, md5 `')" 30
  # the README's table is a summary of the capture's four blocks: derive the same table from the capture
  python3 - "$WORK/u07-throw.1.out" >"$WORK/u07-table.got" <<'PY'
import re, sys
names = {"[nothing throws]": "nothing throws", "[stove constructor]": "throws in the constructor",
         "[stove @PostConstruct]": "throws in @PostConstruct", "[stove initMethod]": "throws in the initMethod"}
cur = None
for l in open(sys.argv[1]):
    l = l.rstrip("\n")
    if l in names: cur = names[l]; row = [cur]
    elif cur and l.startswith("  ran ("): row.append(re.match(r"  ran \((\d+)\)", l).group(1))
    elif cur and "the bean that failed was cleaned up" in l: row.append(l.split()[-1])
    elif cur and "the bean that had FINISHED was cleaned up" in l: row.append(l.split()[-1]); print(" ".join(row)); cur = None
PY
  rblock 07 in 'nothing throws                   7' | grep -E '^(nothing|throws)' | sed -E 's/ {2,}/ /g; s/ +$//' >"$WORK/u07-table.readme"
  if diff "$WORK/u07-table.readme" "$WORK/u07-table.got" >/dev/null; then ok "…the README's table (callbacks that ran / failed bean cleaned up / FINISHED bean cleaned up) is the capture's, row for row"
  else bad "…the README's table is the capture's, row for row" "README: $(tr '\n' '|' <"$WORK/u07-table.readme")  capture: $(tr '\n' '|' <"$WORK/u07-table.got")" noout; fi
  for k in constructor '@PostConstruct' initMethod; do
    hasC "…failure receipt, $k" "$(rblock 07 in '  @PostConstruct : ' | grep -E "^  $k +: " | sed -E 's/^  [^:]+ : //')" "$WORK/u07-throw.1.out"
  done
  c3 "java … ContextReport" 07 u07-cr none "$U" "$JCP com.tiffinbox.ContextReport"
  claim3 "java … ContextReport -> exit 0, 3/3, cr md5, 19 output lines" 0 "$(rhash 07 '`cr` md5 `')" 19
  panel "…excluded 5, and the claims" 07 in 'excluded 5 infrastructure bean definitions' "$WORK/u07-cr.1.out"
  cap3 u07-crs none "$U" "$JCP com.tiffinbox.ContextReport --stable"
  claim3 "java … ContextReport --stable -> exit 0, 3/3, crs md5, 19 output lines (the README quotes it; its block prints no --stable line)" 0 "$(rhash 07 '`cr` md5 `' 2)" 19
  if exercise12 07 '$PWD/.m2-demo'; then
    cap3 u07-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean: ContextReport -> exit 0, 3/3, start-state md5" 0 "$(rhash 07 'Start state md5 `')"
    panel "…it did not know its own name when it opened" 07 in 'what it knew its name to be' "$WORK/u07-exs.1.out"
    cap3 u07-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 07 'run by the author: md5 `')"
    has "…End state: true" '^  it knew its own name when it opened +true$' "$WORK/u07-exsol.1.out"
  fi
  end_solution 07
  offline_pair "c4-unit07" "$U"; offline_pair "exercise/" "$U/exercise"
  end_unit "$U"
fi

# =============================================================== c4-unit08 ===
if unit 08 "four ways to initialise and destroy"; then
  build12 "c4-unit08" 08 "$U"
  c3 "java … FourWays" 08 u08-four none "$U" "$JCP com.tiffinbox.FourWays"
  claim3 "java … FourWays -> exit 0, 3/3, md5, 38 output lines" 0 "$(rhash 08 '`.r-four{1,2,3}.out`, md5 `')" 38
  panel "…the order, both ways, from one capture" 08 in '1  named      constructor' "$WORK/u08-four.1.out"
  panel "…a destroy callback never runs for a prototype" 08 in 'initialise callbacks the container ran on each PROTOTYPE' "$WORK/u08-four.1.out"
  panel "…close() inferred, unless the bean is also a DisposableBean" 08 in 'close() inferred on the AutoCloseable bean' "$WORK/u08-four.1.out"
  panel "…the container closes the kitchen rail" 08 in 'the kitchen rail, which has been AutoCloseable' "$WORK/u08-four.1.out"
  c3 "java … NeverClosed" 08 u08-nohook none "$U" "$JCP com.tiffinbox.NeverClosed"
  claim3 "java … NeverClosed -> exit 0, 3/3, md5, 3 output lines" 0 "$(rhash 08 '[no close(), no shutdown hook]')" 3
  panel "…no @PreDestroy line" 08 in '[no close(), no shutdown hook]' "$WORK/u08-nohook.1.out"
  c3 "java … NeverClosed --hook" 08 u08-hook none "$U" "$JCP com.tiffinbox.NeverClosed --hook"
  claim3 "java … NeverClosed --hook -> exit 0, 3/3, md5, 5 output lines" 0 "$(rhash 08 '[with registerShutdownHook()]')" 5
  panel "…the hook runs @PreDestroy and close()" 08 in '[with registerShutdownHook()]' "$WORK/u08-hook.1.out"
  hasnt "…'Nothing is logged in either'" '^(WARNING|SEVERE|INFO): ' "$WORK/u08-nohook.1.raw"
  hasnt "…(and not with --hook either)" '^(WARNING|SEVERE|INFO): ' "$WORK/u08-hook.1.raw"
  c3 "java … ContextReport" 08 u08-cr none "$U" "$JCP com.tiffinbox.ContextReport"
  claim3 "java … ContextReport -> exit 0, 3/3, cr md5, 20 output lines" 0 "$(rhash 08 '`cr` md5 `')" 20
  panel "…the receipt" 08 in 'perUse                       prototype' "$WORK/u08-cr.1.out"
  cap3 u08-crs none "$U" "$JCP com.tiffinbox.ContextReport --stable"
  claim3 "java … ContextReport --stable -> exit 0, 3/3, crs md5, 20 output lines" 0 "$(rhash 08 '`cr` md5 `' 2)" 20
  c3 "sh lifecycle-rows.sh" 08 u08-rows none "$U" 'sh lifecycle-rows.sh'
  claim3 "sh lifecycle-rows.sh -> exit 0, 3/3, md5, 7 output lines" 0 "$(rhash 08 '    kitchen.close();')" 7
  panel "…the two lifecycle steps, derived out of the wiring file" 08 in 'what this section can take off that file' "$WORK/u08-rows.1.out"
  c3 "the anchor's ledger" 08 u08-ledger none "$U" 'sh ../c4-unit01/ledger.sh ../c4-unit31/before/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java'
  claim3 "sh ../c4-unit01/ledger.sh ../c4-unit31/before/…/Wiring.java -> exit 0, 3/3, md5, 6 output lines ('the same hash the first section recorded')" 0 \
      "$(rhash 08 '$ sh ../c4-unit01/ledger.sh ../c4-unit31/before')" 6
  panel "…18 / 4 / 3 / 0 / 0" 08 in '$ sh ../c4-unit01/ledger.sh ../c4-unit31/before' "$WORK/u08-ledger.1.out"
  expect_rc "…and against ../c4-tiffinbox the ledger now exits 2 with 'nothing to count'" 60 2 'nothing to count' "$U" \
      'sh ../c4-unit01/ledger.sh ../c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java'
  if exercise12 08 '$PWD/.m2-demo'; then
    cap3 u08-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean: ContextReport -> exit 0, 3/3, start-state md5" 0 "$(rhash 08 'Start state md5 `')"
    panel "…two destroy hooks, zero that will run" 08 in 'freezer scope in the definition' "$WORK/u08-exs.1.out"
    cap3 u08-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 08 'run by the author: md5 `')"
    hasC "…End state" "$(rticks 08 '**End state:**' 1)" "$WORK/u08-exsol.1.out"
    has "…'destroy method recorded in the definition' still (inferred) — the row that does not move" \
        '^  destroy method recorded in the definition \(inferred\)$' "$WORK/u08-exsol.1.out"
    same_file "…'without touching Freezer.java'" "$E/src/main/java/com/tiffinbox/Freezer.java" "$S/src/main/java/com/tiffinbox/Freezer.java"
  fi
  end_solution 08
  offline_pair "c4-unit08" "$U"; offline_pair "exercise/" "$U/exercise"
  end_unit "$U"
fi

# =============================================================== c4-unit09 ===
if unit 09 "scopes and the injection trap"; then
  build12 "c4-unit09" 09 "$U"
  c3 "java … OneTripForEver" 09 u09-aba none "$U" "$JCP com.tiffinbox.OneTripForEver"
  claim3 "java … OneTripForEver -> exit 0, 3/3, the unmasked md5, 25 output lines" 0 "$(rhash 09 'Unmasked `.r-aba{1,2,3}.out`, md5 `')" 25
  c3 "java … OneTripForEver --stable" 09 u09-abas none "$U" "$JCP com.tiffinbox.OneTripForEver --stable"
  claim3 "java … OneTripForEver --stable -> exit 0, 3/3, the masked md5" 0 "$(rhash 09 'Masked `.r-abas{1,2,3}.out`, md5 `')"
  panel "…A / B / A' (masked), and 4 DeliveryRun objects in total" 09 in '[A ] DeliveryRun run' "$WORK/u09-abas.1.out"
  c3 "java … WhatScopeSays" 09 u09-scope none "$U" "$JCP com.tiffinbox.WhatScopeSays"
  claim3 "java … WhatScopeSays -> exit 0, 3/3, md5, 9 output lines" 0 "$(rhash 09 '`.r-scope{1,2,3}.out`, md5 `')" 9
  panel "…getScope()=\"\" and isSingleton()=true" 09 in 'what the DEFINITION says' "$WORK/u09-scope.1.out"
  panel "…the subclass does not cache a prototype" 09 in 'the configuration subclass, asked the same question twice' "$WORK/u09-scope.1.out"
  c3 "java … ContextReport" 09 u09-cr none "$U" "$JCP com.tiffinbox.ContextReport"
  claim3 "java … ContextReport -> exit 0, 3/3, cr md5, 18 output lines" 0 "$(rhash 09 '`cr` md5 `')" 18
  panel "…the receipt" 09 in 'deliveryRun   prototype' "$WORK/u09-cr.1.out"
  cap3 u09-crs none "$U" "$JCP com.tiffinbox.ContextReport --stable"
  claim3 "java … ContextReport --stable -> exit 0, 3/3, crs md5, 18 output lines" 0 "$(rhash 09 '`cr` md5 `' 2)" 18
  if exercise12 09 '$PWD/.m2-demo'; then
    cap3 u09-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean: ContextReport -> exit 0, 3/3, start-state md5" 0 "$(rhash 09 'Start state md5 `')"
    hasC "…it says" "$(rticks 09 '`exercise/` starts clean and `ContextReport` says' 1)" "$WORK/u09-exs.1.out"
    cap3 u09-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 09 'run by the author: md5 `')"
    has "…End state: trip one == trip two  false" '^  trip one == trip two +false$' "$WORK/u09-exsol.1.out"
    same_file "…'without touching DeliveryRun.java'" "$E/src/main/java/com/tiffinbox/DeliveryRun.java" "$S/src/main/java/com/tiffinbox/DeliveryRun.java"
  fi
  end_solution 09
  offline_pair "c4-unit09" "$U"; offline_pair "exercise/" "$U/exercise"
  end_unit "$U"
fi

# =============================================================== c4-unit10 ===
if unit 10 "circular dependencies: bandage and cure"; then
  build12 "c4-unit10" 10 "$U"
  c3 "java … FourAnswers" 10 u10-four "$U/chain.py" "$U" "$JCP com.tiffinbox.FourAnswers"
  claim3 "java … FourAnswers -> exit 0, 3/3, md5, 36 output lines (through chain.py)" 0 "$(rhash 10 '`.r-four{1,2,3}.out`, md5 `')" 36
  panel "…five answers to one cycle" 10 in '[1] both sides through the constructor' "$WORK/u10-four.1.out"
  c3 "java … BreakTheCycle" 10 u10-cyc0 none "$U" "$JCP com.tiffinbox.BreakTheCycle"
  claim3 "java … BreakTheCycle -> exits 1, on purpose, 3 of 3 (raw form: timestamped, not claimed identical)" 1 "~"
  CYC='java -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakTheCycle > .r-cyc1.raw 2>&1 ; python3 chain.py .r-cyc1.raw'
  c3 "the README's chain line" 10 u10-cyc none "$U" "$CYC"
  claim3 "java … BreakTheCycle > .r-cyc1.raw 2>&1 ; python3 chain.py .r-cyc1.raw -> 3/3, md5, 10 output lines" 0 "$(rhash 10 '`.r-cyc{1,2,3}.out`, md5 `')" 10
  panel "…three links, the useful one is the third" 10 in '... 2 log lines elided' "$WORK/u10-cyc.1.out"
  RAWD="$(for i in 1 2 3; do md5of "$WORK/u10-cyc0.$i.raw"; done | sort -u | wc -l | tr -d ' ')"
  skip "'Its raw form gives 2 distinct values across three runs'" \
       "timing, not code: the JUL header's clock second decides it (this run: $RAWD distinct); unit 11's README says the count 'is itself not a fact'"
  c3 "java … ContextReport" 10 u10-cr none "$U" "$JCP com.tiffinbox.ContextReport"
  claim3 "java … ContextReport -> exit 0, 3/3, cr md5, 18 output lines" 0 "$(rhash 10 '`cr` md5 `')" 18
  panel "…the cure, as a property of the graph" 10 in 'beans that point back at something pointing at them 0' "$WORK/u10-cr.1.out"
  cap3 u10-crs none "$U" "$JCP com.tiffinbox.ContextReport --stable"
  claim3 "java … ContextReport --stable -> exit 0, 3/3, crs md5, 18 output lines" 0 "$(rhash 10 '`cr` md5 `' 2)" 18
  if exercise12 10 '$PWD/.m2-demo'; then
    cap3 u10-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean: ContextReport -> exit 0, 3/3, start-state md5" 0 "$(rhash 10 'Start state md5 `')"
    hasC "…it says" "$(rticks 10 '`exercise/` starts clean and `ContextReport` says' 1)" "$WORK/u10-exs.1.out"
    cap3 u10-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 10 'run by the author: md5 `')"
    has "…End state: 0" '^  beans that point back at something pointing at them 0$' "$WORK/u10-exsol.1.out"
    has "…with billFor(\"Ravi\") still 340, in both states" '^  billing\.billFor\("Ravi"\) +340$' "$WORK/u10-exsol.1.out"
    has "…(and 340 before the fix too)" '^  billing\.billFor\("Ravi"\) +340$' "$WORK/u10-exs.1.out"
  fi
  end_solution 10
  offline_pair "c4-unit10" "$U"; offline_pair "exercise/ ('The exercise's cycle builds and verifies green')" "$U/exercise"
  end_unit "$U"
fi

# =============================================================== c4-unit11 ===
if unit 11 "BeanFactoryPostProcessor vs BeanPostProcessor"; then
  build12 "c4-unit11" 11 "$U"
  c3 "java … WhichHookDoINeed" 11 u11-hooks none "$U" "$JCP com.tiffinbox.WhichHookDoINeed"
  claim3 "java … WhichHookDoINeed -> exit 0, 3/3, md5, 18 output lines" 0 "$(rhash 11 '`.r-hooks{1,2,3}.out`, md5 `')" 18
  panel "…the two phases, in order" 11 in 'refresh() begins' "$WORK/u11-hooks.1.out"
  panel "…the first hook changed a description" 11 in 'kitchenPrices, lazy in the description' "$WORK/u11-hooks.1.out"
  panel "…the second hook changed an instance" 11 in 'the class your name points at' "$WORK/u11-hooks.1.out"
  c3 "java … BreakEarlyReference" 11 u11-break0 none "$U" "$JCP com.tiffinbox.BreakEarlyReference"
  claim3 "java … BreakEarlyReference -> exit 0 ('started, and nothing threw'), 3 of 3 (raw form: timestamped)" 0 "~"
  BM='java -Duser.language=en -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakEarlyReference > .r-breakm1.raw 2>&1 ; python3 stamp.py .r-breakm1.raw'
  c3 "the README's stamp line" 11 u11-breakm none "$U" "$BM"
  claim3 "java -Duser.language=en … > .r-breakm1.raw 2>&1 ; python3 stamp.py .r-breakm1.raw -> 3/3, md5, 10 output lines" 0 \
      "$(rhash 11 '`.r-breakm{1,2,3}.out`, md5 `')" 10
  panel "…the WARNING shown, not cropped, and the count over a named filter" 11 in '<timestamp> org.springframework.context.support' "$WORK/u11-breakm.1.out"
  for lw in 'de WARNUNG:' 'fr AVERTISSEMENT:'; do
    lc="${lw%% *}"; w="${lw#* }"
    cap3 "u11-loc$lc" "$U/stamp.py" "$U" "java -Duser.language=$lc -cp \"target/classes:\$(cat .cp)\" com.tiffinbox.BreakEarlyReference"
    claim3 "the locale table, $lc: masked md5, 3/3" 0 "$(rhash 11 "$lc      $w")"
    has "…the level word the JVM printed is $w" "^$w " "$WORK/u11-loc$lc.1.out"
    has "…and the filter's own count is 2" '^\.\.\. 2 log timestamps masked' "$WORK/u11-loc$lc.1.out"
  done
  is "the locale table, en: the masked md5 is the breakm hash" "$(rhash 11 'en      WARNING:')" "$(md5of "$WORK/u11-breakm.1.out")"
  RAWD="$(for i in 1 2 3; do md5of "$WORK/u11-break0.$i.raw"; done | sort -u | wc -l | tr -d ' ')"
  skip "the table's 'raw, same 3 runs: 2 distinct' column" "timing, not code (this run: $RAWD distinct raw value(s)); the README itself goes on to say the count 'is itself not a fact'"
  c3 "java … ContextReport" 11 u11-cr none "$U" "$JCP com.tiffinbox.ContextReport"
  claim3 "java … ContextReport -> exit 0, 3/3, cr md5, 20 output lines" 0 "$(rhash 11 '`cr` md5 `')" 20
  panel "…lazy=true and (not built) are the first hook's edit" 11 in 'eveningPrices   singleton' "$WORK/u11-cr.1.out"
  cap3 u11-crs none "$U" "$JCP com.tiffinbox.ContextReport --stable"
  claim3 "java … ContextReport --stable -> exit 0, 3/3, crs md5, 20 output lines" 0 "$(rhash 11 '`cr` md5 `' 2)" 20
  if exercise12 11 '$PWD/.m2-demo'; then
    EXM='java -Duser.language=en -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport'
    cap3 u11-exs none "$E" "$EXM"
    claim3 "exercise/ starts clean: ContextReport -> exit 0, 3 of 3 (raw form: timestamped, the README hashes it masked)" 0 "~"
    panel "…one price list got past the freezer" 11 in 'price lists the hook handed back changed 1 of 2' "$WORK/u11-exs.1.out"
    HX="$(rhash 11 'Start state, masked and language-pinned, md5 `')"
    for i in 1 2 3; do python3 "$E/stamp.py" "$WORK/u11-exs.$i.raw" >"$WORK/u11-exs-own.$i" 2>/dev/null; done
    GX="$(md5of "$WORK/u11-exs-own.1")"
    if [ "$GX" = "$HX" ]; then ok "…the start state, masked with the stamp.py shipped in exercise/, language-pinned -> md5 $HX"
    else bad "…the start state, masked with the stamp.py shipped IN exercise/ (python3 stamp.py), language-pinned -> md5 $HX" \
             "md5 $GX. exercise/stamp.py is the pre-2026-09-20 filter the unit's own stamp.py documents as fixed: it rewrites ContextReport's row '$(grep -m1 '^sort ' "$WORK/u11-exs.1.raw")' into '$(grep -m1 '<timestamp> java.lang.String' "$WORK/u11-exs-own.1")' and counts $(grep -oE '^\.\.\. [0-9]+ log timestamps' "$WORK/u11-exs-own.1") masked; cmp exercise/stamp.py stamp.py: $(cmp -s "$E/stamp.py" "$U/stamp.py" && echo same || echo differ)" noout; fi
    for i in 1 2 3; do python3 "$U/stamp.py" "$WORK/u11-exs.$i.raw" >"$WORK/u11-exs-unit.$i" 2>/dev/null; done
    is "…the same start state masked with the UNIT's stamp.py (../stamp.py) -> the README's md5, 3/3" \
       "$(for i in 1 2 3; do md5of "$WORK/u11-exs-unit.$i"; done | sort -u | tr '\n' ' ')" "$HX "
    cap3 u11-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 11 'run by the author: md5 `')"
    has "…End state: 2 of 2" '^  price lists the hook handed back changed 2 of 2$' "$WORK/u11-exsol.1.out"
    has "…and (none)" '^  the ones it did not +\(none\)$' "$WORK/u11-exsol.1.out"
  fi
  end_solution 11
  offline_pair "c4-unit11" "$U"; offline_pair "exercise/" "$U/exercise"
  end_unit "$U"
fi

# =============================================================== c4-unit12 ===
if unit 12 "Aware interfaces, @Order and @DependsOn"; then
  build12 "c4-unit12" 12 "$U"
  c3 "java … WhatOrderOrders" 12 u12-order none "$U" "$JCP com.tiffinbox.WhatOrderOrders"
  claim3 "java … WhatOrderOrders -> exit 0, 3/3, md5, 18 output lines" 0 "$(rhash 12 '`.r-order{1,2,3}.out`, md5 `')" 18
  panel "…four rows, one moves" 12 in '[A ] no @Order anywhere' "$WORK/u12-order.1.out"
  c3 "java … InvisibleOrder" 12 u12-invis "$U/chain.py" "$U" "$JCP com.tiffinbox.InvisibleOrder"
  claim3 "java … InvisibleOrder -> exit 0, 3/3, md5, 18 output lines (through chain.py)" 0 "$(rhash 12 '`.r-invis{1,2,3}.out`, md5 `')" 18
  panel "…the order nothing in the code says" 12 in '[1] seeder declared first' "$WORK/u12-invis.1.out"
  c3 "java … AwareOrNot" 12 u12-aware none "$U" "$JCP com.tiffinbox.AwareOrNot"
  claim3 "java … AwareOrNot -> exit 0, 3/3, md5, 10 output lines" 0 "$(rhash 12 '`.r-aware{1,2,3}.out`, md5 `')" 10
  panel "…outside a container only the constructor version is still an object" 12 in 'inside a container' "$WORK/u12-aware.1.out"
  c3 "java … BreakDeclarationOrder" 12 u12-decl "$U/chain.py" "$U" "$JCP com.tiffinbox.BreakDeclarationOrder"
  claim3 "java … BreakDeclarationOrder -> exit 1, 3/3, md5, 14 output lines (through chain.py)" 1 "$(rhash 12 '`.r-decl{1,2,3}.out`, md5 `')" 14
  chain_is "…the whole chain kept: BeanCreationException -> BeanInstantiationException -> JdbcSQLSyntaxErrorException" "$WORK/u12-decl.1.out" \
      org.springframework.beans.factory.BeanCreationException org.springframework.beans.BeanInstantiationException org.h2.jdbc.JdbcSQLSyntaxErrorException
  hasC "…the receipt's first line" "$(rblock 12 in "Error creating bean with name 'revenueBoard'" | grep "^Error creating bean")" "$WORK/u12-decl.1.out"
  c3 "java … ContextReport" 12 u12-cr none "$U" "$JCP com.tiffinbox.ContextReport"
  claim3 "java … ContextReport -> exit 0, 3/3, cr md5, 19 output lines" 0 "$(rhash 12 '`cr` md5 `')" 19
  panel "…the receipt" 12 in 'checks the opening routine was handed  3' "$WORK/u12-cr.1.out"
  cap3 u12-crs none "$U" "$JCP com.tiffinbox.ContextReport --stable"
  claim3 "java … ContextReport --stable -> exit 0, 3/3, crs md5, 19 output lines" 0 "$(rhash 12 '`cr` md5 `' 2)" 19
  if exercise12 12 '$PWD/.m2-demo'; then
    cap3 u12-exs none "$E" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/ starts clean and ContextReport EXITS 2, 3/3, start-state md5" 2 "$(rhash 12 'Start state md5 `')"
    panel "…the guard fires" 12 in 'ContextReport: no @Order found on any startup check' "$WORK/u12-exs.1.out"
    cap3 u12-exsol none "$S" "$JCP com.tiffinbox.ContextReport"
    claim3 "exercise/solution/ -> exit 0, 3/3, md5 the README quotes" 0 "$(rhash 12 'run by the author: md5 `')"
    hasC "…End state" "$(rticks 12 '**End state:**' 1)" "$WORK/u12-exsol.1.out"
    has "…'order the container BUILT them [power, water, gas]' before and after" '^  order the container BUILT them +\[power, water, gas\]$' "$WORK/u12-exsol.1.out"
  fi
  end_solution 12
  offline_pair "c4-unit12" "$U"; offline_pair "exercise/" "$U/exercise"
  end_unit "$U"
fi

# ================================================== Sections 3 to 6: receipts.sh ===
# run_receipts NN [SECS] — ./receipts.sh from the unit; PASS only on exit 0. Output kept as $WORK/rNN.out.
run_receipts() {
  local n="$1" t="${2:-1800}"
  expect_ok "c4-unit$n/receipts.sh -> exit 0" "$t" '' "$REPO/c4-unit$n" './receipts.sh'
  local rc=$RC
  cp "$OUT" "$WORK/r$n.out"
  if grep -q 'DRIFTS\|DIFFERS from the published' "$WORK/r$n.out"; then
    bad "…and not one capture drifts or differs from what is published" "$(grep 'DRIFTS\|DIFFERS' "$WORK/r$n.out" | head -3 | tr -s ' ' | tr '\n' '|')" noout
  else ok "…and not one capture it prints drifts across its three runs"; fi
  # everything receipts.sh writes must be covered by .gitignore (a viewer's `git status` stays clean)
  local nu; nu="$( (cd "$REPO" && git status --porcelain --untracked-files=normal -- "c4-unit$n") | sed -n 's/^?? //p' | grep -vxF -f "$WORK/extras.before" | tr '\n' ' ')"
  if [ -z "$nu" ]; then ok "…and everything it wrote is covered by .gitignore (git status shows nothing new)"
  else bad "…and everything it wrote is covered by .gitignore" "git status shows new untracked: $nu" noout; fi
  return $rc
}
# rcap NN NAME ANCHOR EXIT 'README COMMAND' [RUNS]
#   receipts.sh's own line for capture NAME must carry the md5 the README quotes after ANCHOR, say 3/3
#   (RUNS=1: a one-shot capture such as since.sh), and — where the README states one — the exit code.
#   'README COMMAND' (or -) must still be printed by the README AND be what receipts.sh runs, so the
#   hash a viewer is shown belongs to the command a viewer is given.
rcap() {
  local n="$1" name="$2" anchor="$3" want="$4" cmd="$5" runs="${6:-3}" line h rh why="" lbl
  line="$(grep -E "^  $name +(OUTPUT +|TRIO +)?md5 [0-9a-f]{32}" "$WORK/r$n.out" | head -1 | tr -s ' ')"
  rh="$(rhash "$n" "$anchor")"
  h="$(printf '%s' "$line" | grep -oE '[0-9a-f]{32}' | head -1)"
  [ -n "$line" ] || why="receipts.sh printed no md5 line for $name"
  [ -z "$why" ] && [ -z "$rh" ] && why="the README quotes no md5 after: $anchor"
  [ -z "$why" ] && [ "$h" != "$rh" ] && why="receipts.sh gives md5 $h; the README quotes $rh"
  [ -z "$why" ] && [ "$runs" = 3 ] && ! printf '%s' "$line" | grep -qE ' 3/3( |$)' && why="not 3/3:$line"
  [ -z "$why" ] && [ "$want" != "-" ] && ! printf '%s' "$line" | grep -qE "exit $want( |$)" && why="the README says exit $want; receipts.sh:$line"
  if [ -z "$why" ] && [ "$cmd" != "-" ]; then
    rgives "$n" "$cmd" || why="the README no longer prints: $cmd"
    [ -z "$why" ] && ! python3 -c '
import re, sys
c = lambda s: re.sub(r"\s+", " ", s)
sys.exit(0 if c(sys.argv[1]) in c(open(sys.argv[2]).read()) else 1)' "$cmd" "$REPO/c4-unit$n/receipts.sh" && why="receipts.sh does not run the README's command: $cmd"
  fi
  lbl="receipts.sh .r-$name: md5 ${h:-?} = the README's${want:+, exit $want}$([ "$runs" = 3 ] && echo ', 3/3')"
  [ "$want" = "-" ] && lbl="receipts.sh .r-$name: md5 ${h:-?} = the README's$([ "$runs" = 3 ] && echo ', 3/3')"
  [ "$cmd" != "-" ] && lbl="$lbl ($cmd)"
  if [ -z "$why" ]; then ok "$lbl"; else bad "$lbl" "$why" noout; fi
}
# rpub NN NAME [ANCHOR] — units 31-32: receipts.sh compares every capture with receipts.md5 and prints
# "DIFFERS from the published" yet still exits 0, so "= published" is required here; with ANCHOR, the
# README's quoted hash must be receipts.md5's too.
rpub() {
  local n="$1" name="$2" anchor="${3:-}" line pub rh why=""
  line="$(grep -E "^  $name +md5 [0-9a-f]{32}" "$WORK/r$n.out" | head -1 | tr -s ' ')"
  pub="$(awk -v k="$name" '$1 == k {print $2}' "$REPO/c4-unit$n/receipts.md5")"
  [ -n "$line" ] || why="receipts.sh printed no line for $name"
  [ -z "$why" ] && ! printf '%s' "$line" | grep -q '= published' && why="not '= published':$line"
  if [ -z "$why" ] && [ -n "$anchor" ]; then
    rh="$(rhash "$n" "$anchor")"
    [ "$rh" = "$pub" ] || why="the README quotes ${rh:-nothing} after '$anchor'; receipts.md5 says $pub"
  fi
  if [ -z "$why" ]; then ok "receipts.sh .r-$name: md5 $pub, 3/3, = receipts.md5$([ -n "$anchor" ] && echo ' = the README')"
  else bad "receipts.sh .r-$name: = receipts.md5$([ -n "$anchor" ] && echo ' = the README')" "$why" noout; fi
}
# the Section 3-5 exercise READMEs print the two build lines, then one java line with the class path inline
build_ex35() {
  local n="$1" d="$REPO/c4-unit$1/exercise"
  rgives "c4-unit$n/exercise/README.md" "$MVN_COMPILE" && rgives "c4-unit$n/exercise/README.md" "$MVN_CPTXT" \
    || bad "exercise/README.md still prints the two build lines" "not found" noout
  build35 "exercise/" "$d"
}
xrun() {  # xrun LABEL WANT_RC SAVE_AS DIR 'CMD' — one run of an exercise command, its output kept
  local label="$1" want="$2" save="$3" d="$4" c="$5"
  timed 240 sh_in "$d" "$c"; cp "$OUT" "$WORK/$save"
  if [ "$RC" = "$want" ]; then ok "$label -> exit $want"; else bad "$label" "exit $RC, expected $want"; fi
}
CPV='CP="target/classes:$(cat cp.txt)"; '    # the README's own line, before every "$CP" command

# =============================================================== c4-unit13 ===
if unit 13 "externalized configuration and the Environment (flip.sh, no receipts.sh)"; then
  for c in "$MVN_COMPILE" "$MVN_CPTXT" 'CP="target/classes:$(cat cp.txt)"'; do rgives 13 "$c" || bad "the README still prints: $c" "not found" noout; done
  build35 "c4-unit13" "$U"
  # "Quote -Dmaven.repo.local="$PWD/.m2-demo". The path above this folder contains a space, and an
  # unquoted expansion is split by bash." — a claim about the reader's shell, so it is run under bash.
  case "$U" in
    *" "*) expect_rc "the README's warning: UNquoted, -Dmaven.repo.local=\$PWD/.m2-demo is split by bash in a path with a space" 300 1 '' "$U" \
               'mvn -q -Dmaven.repo.local=$PWD/.m2-demo compile' ;;
    *) skip "the README's warning about an unquoted -Dmaven.repo.local" "this clone's path has no space, so there is nothing for bash to split" ;;
  esac
  c3 "java -cp \"\$CP\" com.tiffinbox.Sources" - u13-files none "$U" "${CPV}java -cp \"\$CP\" com.tiffinbox.Sources"
  rgives 13 'java -cp "$CP" com.tiffinbox.Sources' || bad "the README still prints: java -cp \"\$CP\" com.tiffinbox.Sources" "not found" noout
  claim3 "java -cp \"\$CP\" com.tiffinbox.Sources -> .r-files.out md5, exit 0, 3 of 3" 0 "$(rhash 13 '`.r-files.out` · md5')"
  expect_ok "./flip.sh -> exit 0, 'THE WINNER MOVED'" 600 'THE WINNER MOVED' "$U" './flip.sh'
  cp "$OUT" "$WORK/u13-flip.out"
  is "…A / B / A' md5s are the README's (A' a real third run, equal to A)" \
     "$(grep -E "^(A |B |A')  ?md5 " "$WORK/u13-flip.out" | grep -oE '[0-9a-f]{32}' | tr '\n' ' ')" \
     "$(rhash 13 'compile fails. A') $(rhash 13 'compile fails. A' 2) $(rhash 13 'compile fails. A' 3) "
  if git -C "$REPO" diff --quiet -- c4-unit13/src; then ok "…and flip.sh put TiffinBoxConfig.java back (git diff: clean)"
  else bad "…flip.sh put TiffinBoxConfig.java back" "git diff shows c4-unit13/src changed" noout; fi
  c3 "Sources sysprop" - u13-sysprop none "$U" "${CPV}java -cp \"\$CP\" com.tiffinbox.Sources sysprop"
  rgives 13 'java -cp "$CP" com.tiffinbox.Sources sysprop' || bad "the README still prints: java -cp \"\$CP\" com.tiffinbox.Sources sysprop" "not found" noout
  claim3 "java -cp \"\$CP\" com.tiffinbox.Sources sysprop -> .r-sysprop.out md5, exit 0, 3 of 3" 0 "$(rhash 13 '`.r-sysprop.out` · md5')"
  expect_ok "./flip.sh sysprop -> exit 0" 600 '' "$U" './flip.sh sysprop'
  cp "$OUT" "$WORK/u13-flipsys.out"
  is "…A / B / A' md5s are the README's" \
     "$(grep -E "^(A |B |A')  ?md5 " "$WORK/u13-flipsys.out" | grep -oE '[0-9a-f]{32}' | tr '\n' ' ')" \
     "$(rhash 13 'does not move.** A') $(rhash 13 'does not move.** A' 2) $(rhash 13 'does not move.** A' 3) "
  panel "…and it says the two answers separately: THE WINNER DID NOT MOVE" 13 in '-> THE WINNER DID NOT MOVE' "$WORK/u13-flipsys.out"
  git -C "$REPO" diff --quiet -- c4-unit13/src && ok "…and put the file back again" || bad "…flip.sh sysprop put the file back" "git diff shows a change" noout
  for g in 'java -cp "$CP" com.tiffinbox.Sources --key=tiffinbox.db.url' 'java -cp "$CP" com.tiffinbox.Sources --nope'; do
    rgives 13 "$g" || bad "the README still prints: $g" "not found" noout
    expect_rc "guard: $g -> exit 2" 120 2 '' "$U" "${CPV}$g"
  done
  expect_rc "guard (the README's table): '--key= with no name' -> exit 2" 120 2 '' "$U" "${CPV}java -cp \"\$CP\" com.tiffinbox.Sources --key="
  expect_ok "ERRATA: 'TIFFINBOX_COOKS=4 outranks both files' (systemEnvironment, row 2)" 120 'WINNER +env.getProperty\(tiffinbox.cooks\) = 4$' "$U" \
      "${CPV}TIFFINBOX_COOKS=4 java -cp \"\$CP\" com.tiffinbox.Sources --key=tiffinbox.cooks"
  E="$U/exercise"
  if build_ex35 13; then
    X='java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Sources --key=tiffinbox.cooks'
    rgives c4-unit13/exercise/README.md "$X" || bad "exercise/README.md still prints: $X" "not found" noout
    xrun "exercise: $X" 0 u13-ex "$E" "$X"
    has "…a quarter-staffed kitchen: rails-two's one cook is winning" 'WINNER +env.getProperty\(tiffinbox.cooks\) = 1$' "$WORK/u13-ex"
    XS='java -Dtiffinbox.cooks=4 -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Sources --key=tiffinbox.cooks'
    rgives c4-unit13/exercise/solution/SOLUTION.md "$XS" || bad "SOLUTION.md still prints: $XS" "not found" noout
    xrun "solution: $XS" 0 u13-exsol "$E" "$XS"
    panel "…the row to look at, as SOLUTION.md prints it" c4-unit13/exercise/solution/SOLUTION.md in 'systemProperties               tiffinbox.cooks=4' "$WORK/u13-exsol"
    has "…and the winner is 4" 'WINNER +env.getProperty\(tiffinbox.cooks\) = 4$' "$WORK/u13-exsol"
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit14 ===
if unit 14 "@Value, SpEL and type conversion"; then
  build35 "c4-unit14" "$U" 14
  if run_receipts 14; then
    rcap 14 name-right '`.r-name-right.out` · md5' 0 'java -cp "$CP" com.tiffinbox.TheName right'
    rcap 14 name-wrong '`.r-name-wrong.out` · md5' 1 'java -cp "$CP" com.tiffinbox.TheName wrong'
    rcap 14 ph-default '# .r-ph-default.out' 0 'java -cp "$CP" com.tiffinbox.ThePlaceholder withDefault'
    rcap 14 ph-literal '# .r-ph-literal.out' 0 'java -cp "$CP" com.tiffinbox.ThePlaceholder noConfigurer'
    rcap 14 ph-named '# trio' 1 'java -cp "$CP" com.tiffinbox.ThePlaceholder configured'
    panel "…the derived count: zero mentions inside the exception chain" 14 in '=> mentions inside the exception chain' "$WORK/r14.out"
    panel ".r-name-right.out is the README's panel" 14 in 'config=RightName' "$U/.r-name-right.out"
    panel ".r-name-wrong.out: the bean IS here, and the chain never names it" 14 in 'conversion service beans in this context: [myConversionService]' "$U/.r-name-wrong.out"
    has "the table, withDefault: starts, the bean holds VEG" '^STARTED\. the bean holds: \[VEG\]$' "$U/.r-ph-default.out"
    hasF "…noConfigurer: starts, the bean holds the literal text \${tiffinbox.mael}" 'STARTED. the bean holds: [${tiffinbox.mael}]' "$U/.r-ph-literal.out"
    hasF "…configured: Could not resolve placeholder 'tiffinbox.mael'" "Could not resolve placeholder 'tiffinbox.mael'" "$U/.r-ph-named.out"
  fi
  is "…'0 #{ in the sources' (SpEL is not taught here)" "$(grep -rl '#{' "$U/src" 2>/dev/null | wc -l | tr -d ' ')" "0"
  E="$U/exercise"
  if build_ex35 14; then
    X='java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.TiffinBoxConfig'
    rgives c4-unit14/exercise/README.md "$X" || bad "exercise/README.md still prints: $X" "not found" noout
    xrun "exercise starts: the kitchen cannot read the spice level" 1 u14-ex "$E" "$X"
    hasF "…'no matching editors or conversion strategy found'" 'no matching editors or conversion strategy found' "$WORK/u14-ex"
    solution_copy 14; printf '  %s(solution/: %s)%s\n' "$DIM" "$SOL_APPLIED" "$OFF"
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution: extra-hot becomes a Spice" 0 u14-exsol "$S" "$X"
      has "…Order[… spice=EXTRA_HOT]" 'spice=EXTRA_HOT\]' "$WORK/u14-exsol"
      sed -i.bak 's/^tiffinbox.spice=.*/tiffinbox.spice=nuclear/' "$S/src/main/resources/order.properties" && rm -f "$S/src/main/resources/order.properties.bak"
      expect_ok "…'Change the file to tiffinbox.spice=nuclear and run again' (recompile)" 600 '' "$S" "$MVN_COMPILE"
      xrun "…a bad value" 1 u14-exnuc "$S" "$X"
      has "…'name what was typed and what is allowed': nuclear, and the legal values" 'nuclear.*EXTRA_HOT|EXTRA_HOT.*nuclear' "$WORK/u14-exnuc"
    fi
    end_solution 14
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit15 ===
if unit 15 "profiles: only one bean gets created"; then
  build35 "c4-unit15" "$U" 15
  if run_receipts 15; then
    rcap 15 prof-inmemory '`.r-prof-inmemory.out` · md5' 0 'java -cp "$CP" com.tiffinbox.ContextReport in-memory'
    rcap 15 prof-jdbc '`.r-prof-jdbc.out` · md5' - -
    rcap 15 prof-none '`.r-prof-none.out` · md5' 0 'java -cp "$CP" com.tiffinbox.ContextReport ""'
    rcap 15 break-plain 'trio md5' 1 'java -cp "$CP" com.tiffinbox.NobodyChose plain'
    rcap 15 fix-fallback '`.r-fix-fallback.out` · md5' 0 'java -cp "$CP" com.tiffinbox.NobodyChose fallback'
    panel ".r-prof-inmemory.out: definition=false for the losing rail" 15 in 'active   [in-memory]     default [default]' "$U/.r-prof-inmemory.out"
    panel ".r-prof-none.out: neither exists" 15 in 'active   []     default [default]' "$U/.r-prof-none.out"
    panel ".r-break-plain.out: thrown type and cause" 15 in "UnsatisfiedDependencyException: Error creating bean with name 'desk'" "$U/.r-break-plain.out"
    is "…'Swap the profile and the two rows swap' (jdbc: jdbcRail defined, inMemoryRail not)" \
       "$(grep -E '^  (inMemoryRail|jdbcRail) +definition=' "$U/.r-prof-jdbc.out" | awk '{print $1"="$2}' | tr '\n' ' ')" \
       "inMemoryRail=definition=false jdbcRail=definition=true "
    is "…definitions among the watched rails, per profile: 1 / 1 / 0" \
       "$(grep -E '^    prof-(inmemory|jdbc|none) ' "$WORK/r15.out" | awk '{print $2}' | tr '\n' ' ')" "1 1 0 "
  fi
  E="$U/exercise"
  if build_ex35 15; then
    D='java -cp "$CP" com.tiffinbox.Desk'
    for c in "$D" "$D in-memory" 'java -cp "$CP" com.tiffinbox.ContextReport in-memory'; do
      rgives c4-unit15/exercise/README.md "$c" || bad "exercise/README.md still prints: $c" "not found" noout; done
    xrun "exercise starts: the desk cannot choose (java … Desk)" 1 u15-ex "$E" "${CPV}$D"
    hasF "…NoUniqueBeanDefinitionException, the exception unit 06 met" 'NoUniqueBeanDefinitionException' "$WORK/u15-ex"
    solution_copy 15; printf '  %s(solution/: %s)%s\n' "$DIM" "$SOL_APPLIED" "$OFF"
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution: java … Desk in-memory — one rail" 0 u15-exsol1 "$S" "${CPV}$D in-memory"
      xrun "solution: java … Desk — 'must fail'" 1 u15-exsol2 "$S" "${CPV}$D"
      panel "…with the failure SOLUTION.md prints" c4-unit15/exercise/solution/SOLUTION.md in "UnsatisfiedDependencyException: Error creating bean with name 'desk'" "$WORK/u15-exsol2"
      xrun "solution: java … ContextReport in-memory" 0 u15-exsol3 "$S" "${CPV}java -cp \"\$CP\" com.tiffinbox.ContextReport in-memory"
      has "…definition AND instantiated: inMemoryRail true, jdbcRail false" '^  jdbcRail +definition=false +instantiated=false' "$WORK/u15-exsol3"
    fi
    end_solution 15
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit16 ===
if unit 16 "validation with Jakarta Bean Validation"; then
  for c in 'mvn -q      -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp-noel.txt dependency:build-classpath' \
           'mvn -q -Pel -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp-el.txt   dependency:build-classpath' \
           'mvn -q      -Dmaven.repo.local="$PWD/.m2-demo" compile'; do
    rgives 16 "$c" || bad "the README still prints: $c" "not found" noout
    expect_ok "$c" 900 '' "$U" "$c"
  done
  is "…cp-noel.txt has no EL implementation, cp-el.txt has one (-Pel is the one flag between them)" \
     "$(grep -c 'expressly\|jakarta.el' "$U/cp-noel.txt" | tr -d ' ')/$([ "$(tr ':' '\n' <"$U/cp-el.txt" | grep -c 'expressly')" -gt 0 ] && echo el)" "0/el"
  expect_ok "'jakarta.validation-api arrives transitively at 3.1.1 … Read it off dependency:tree'" 900 'jakarta\.validation:jakarta\.validation-api:jar:3\.1\.1:compile' "$U" \
      'mvn -B -Dmaven.repo.local="$PWD/.m2-demo" dependency:tree'
  is "…'and is deliberately not declared in the POM' (no <artifactId>jakarta.validation-api</artifactId>)" \
     "$(grep -c '<artifactId>jakarta.validation-api</artifactId>' "$U/pom.xml" | tr -d ' ')" "0"
  if run_receipts 16; then
    rcap 16 el-ok '`.r-el-ok.out` · md5' 0 'java -cp "$EL" com.tiffinbox.CheckAnOrder'
    rcap 16 boundary '`.r-boundary.out` · md5' 0 'java -cp "$EL" com.tiffinbox.AtTheBoundary'
    rcap 16 el-none '# .r-el-none.out' 1 'java -cp "$NOEL" com.tiffinbox.CheckAnOrder'
    rcap 16 el-spring '# .r-el-spring.out' 1 'java -cp "$NOEL" com.tiffinbox.SpringWired'
    rcap 16 ip-noel '# .r-ip-noel.out' 0 'java -cp "$NOEL" com.tiffinbox.TheInterpolator param'
    rcap 16 ip-el '# .r-ip-el.out' 0 'java -cp "$EL"   com.tiffinbox.TheInterpolator param'
    rcap 16 ip-right '# .r-ip-right.out' 0 'java -cp "$EL"   com.tiffinbox.TheInterpolator default'
    has "…'Rows 1 and 2 are byte-identical' — checked by receipts.sh" 'ip-noel and ip-el are BYTE-IDENTICAL' "$WORK/r16.out"
    panel ".r-el-ok.out: three violations, sorted by path" 16 in 'violations=3' "$U/.r-el-ok.out"
    panel ".r-boundary.out: the class name is the proof" 16 in 'the class I wrote : com.tiffinbox.AtTheBoundary$Kitchen' "$U/.r-boundary.out"
    panel ".r-el-none.out: HV000183 at startup" 16 in 'jakarta.validation.ValidationException: HV000183: Unable to initialize' "$U/.r-el-none.out"
    panel ".r-el-spring.out: a cancelled refresh and a four-link ladder" 16 in 'about to refresh' "$U/.r-el-spring.out"
    panel ".r-ip-noel.out: HV000185, ignorable, not silent" 16 in 'WARN: HV000185' "$U/.r-ip-noel.out"
    hasF "the table: ParameterMessageInterpolator, EL absent -> '… got \${validatedValue}'" 'portions must be at least 1, got ${validatedValue}' "$U/.r-ip-noel.out"
    hasF "…EL present -> the same" 'portions must be at least 1, got ${validatedValue}' "$U/.r-ip-el.out"
    hasF "…default interpolator, EL present -> '… got 0'" 'portions must be at least 1, got 0' "$U/.r-ip-right.out"
  fi
  # the ERRATA cite source lines; a line number is a claim that rots silently, so it is read
  is "ERRATA: 'static @Bean, AtTheBoundary.java:35-37' is the MethodValidationPostProcessor" \
     "$(sed -n '35p' "$U/src/main/java/com/tiffinbox/AtTheBoundary.java" | grep -c '@Bean static MethodValidationPostProcessor' | tr -d ' ')" "1"
  is "…'and @Valid on the parameter (line 28)'" "$(sed -n '28p' "$U/src/main/java/com/tiffinbox/AtTheBoundary.java" | grep -c '(@Valid ' | tr -d ' ')" "1"
  E="$U/exercise"
  if build_ex35 16; then
    X='java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.CheckADelivery'
    rgives c4-unit16/exercise/README.md "$X" || bad "exercise/README.md still prints: $X" "not found" noout
    xrun "exercise starts: exit 0, the violation detected" 0 u16-ex "$E" "$X"
    hasF "…and the customer reads a dollar sign" 'this one has ${validatedValue}' "$WORK/u16-ex"
    hasF "…and stderr already names the problem (HV000185)" 'HV000185: Message contains EL expression: ${validatedValue}' "$WORK/u16-ex"
    # SOLUTION.md, fix 1: the -Pel class path, and the .messageInterpolator(...) call deleted
    FIX1='mvn -q -Pel -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp-el.txt dependency:build-classpath'
    rgives c4-unit16/exercise/solution/SOLUTION.md "$FIX1" || bad "SOLUTION.md still prints: $FIX1" "not found" noout
    solution_copy 16
    sed -i.bak 's/\.messageInterpolator(new ParameterMessageInterpolator())//' "$S/src/main/java/com/tiffinbox/CheckADelivery.java" && rm -f "$S"/src/main/java/com/tiffinbox/*.bak
    if build35 "SOLUTION.md fix 1 (copy): the interpolator call deleted" "$S" && expect_ok "…$FIX1" 600 '' "$S" "$FIX1"; then
      xrun "fix 1: run with the EL class path" 0 u16-fix1 "$S" 'java -cp "target/classes:$(cat cp-el.txt)" com.tiffinbox.CheckADelivery'
      hasC "…the message reads as SOLUTION.md says" "$(rticks c4-unit16/exercise/solution/SOLUTION.md 'interpolator runs. Then `${validatedValue}` resolves and the message reads' 1)" "$WORK/u16-fix1"
    fi
    end_solution 16
    solution_copy 16
    FIX2="$(rblock c4-unit16/exercise/solution/SOLUTION.md in '@Max(value = 12' | head -1)"
    python3 - "$S/src/main/java/com/tiffinbox/Delivery.java" "$FIX2" <<'PY'
import re, sys
p, new = sys.argv[1], sys.argv[2].strip()
s = open(p).read()
s2 = re.sub(r"@Max\(value = 12, message = \"[^\"]*\"\)", lambda m: new, s, count=1)
open(p, "w").write(s2)
PY
    if build35 "SOLUTION.md fix 2 (copy): $FIX2" "$S"; then
      xrun "fix 2: the same interpolator, no EL, no extra jar" 0 u16-fix2 "$S" "$X"
      has "…'a run may carry at most 12 boxes'" 'a run may carry at most 12 boxes$' "$WORK/u16-fix2"
    fi
    end_solution 16
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit17 ===
if unit 17 "resources and the ResourceLoader"; then
  build35 "c4-unit17" "$U" 17
  if run_receipts 17; then
    rcap 17 three '`.r-three.out` · md5' 0 'java -cp "$CP" com.tiffinbox.ThreePlaces'
    rcap 17 ide '# .r-ide.out' 0 'java -cp "src/main/java:$CP" com.tiffinbox.WorksInTheIde'
    rcap 17 artefact '# .r-artefact.out' 1 'java -cp "$CP"               com.tiffinbox.WorksInTheIde'
    panel ".r-three.out: three prefixes, one loader, identical bytes" 17 in 'classpath:  class path resource [menu.csv]' "$U/.r-three.out"
    panel "…'in the jar: specials.csv=0 menu.csv=1', derived off the built jar" 17 in 'in the jar:  specials.csv=0  menu.csv=1' "$WORK/r17.out"
    has "the table: source root on the class path -> exists() true" '^exists\(\) +: true$' "$U/.r-ide.out"
    has "…target/classes only -> exists() false, then FileNotFoundException" 'FileNotFoundException' "$U/.r-artefact.out"
    is "ERRATA: 'the capture (.r-ide.out) and the file say 39' bytes" \
       "$(sed -n 's/^bytes *: *//p' "$U/.r-ide.out")/$(wc -c <"$U/src/main/java/com/tiffinbox/specials.csv" | tr -d ' ')" "39/39"
    has "…'java listeners left behind by this unit: 0'" 'java listeners left behind by this unit: 0$' "$WORK/r17.out"
    JT='jar tf target/c4-unit17-1.0.0.jar | grep csv'
    rgives 17 "$JT" || bad "the README still prints: $JT" "not found" noout
    expect_ok "$JT -> menu.csv, and no specials.csv" 60 'menu\.csv' "$U" "$JT"
    hasnt "…specials.csv is not in the artefact" 'specials' "$OUT"
  fi
  E="$U/exercise"
  if build_ex35 17; then
    CP17='CP="target/classes:$(cat cp.txt)"; '
    xrun "exercise: java -cp \"src/main/java:\$CP\" com.tiffinbox.Menu (the IDE's class path)" 0 u17-ide "$E" "${CP17}java -cp \"src/main/java:\$CP\"     com.tiffinbox.Menu"
    xrun "exercise: java -cp \"\$CP\" com.tiffinbox.Menu (the class path you ship) — 'Two runs, one file, two answers'" 1 u17-ship "$E" "${CP17}java -cp \"\$CP\"               com.tiffinbox.Menu"
    expect_ok "SOLUTION.md §1: mvn -q … package -DskipTests" 600 '' "$E" 'mvn -q -Dmaven.repo.local="$PWD/.m2-demo" package -DskipTests'
    expect_rc "…jar tf target/c4-unit17-exercise-1.0.0.jar | grep csv -> 'Nothing' (grep exit 1)" 60 1 '' "$E" 'jar tf target/c4-unit17-exercise-1.0.0.jar | grep csv'
    solution_copy 17
    ( cd "$S" && mkdir -p src/main/resources/com/tiffinbox && mv src/main/java/com/tiffinbox/menu.csv src/main/resources/com/tiffinbox/menu.csv )
    if build35 "SOLUTION.md §2 on a copy (mkdir -p …; mv in place of git mv)" "$S"; then
      xrun "…the IDE's class path" 0 u17-sol1 "$S" "${CP17}java -cp \"src/main/java:\$CP\" com.tiffinbox.Menu"
      xrun "…the class path you ship" 0 u17-sol2 "$S" "${CP17}java -cp \"\$CP\" com.tiffinbox.Menu"
      is "…and 'both runs agree'" "$(md5of "$WORK/u17-sol1")" "$(md5of "$WORK/u17-sol2")"
    fi
    end_solution 17
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit18 ===
if unit 18 "MessageSource: one bill, two languages"; then
  build35 "c4-unit18" "$U" 18
  if run_receipts 18; then
    rcap 18 en-machine '`.r-en-machine.out` · md5' 0 'java -Duser.language=en -Duser.country=US -cp "$CP" com.tiffinbox.Bills'
    rcap 18 it-machine '# .r-it-machine.out' 0 'java -Duser.language=it -Duser.country=IT -cp "$CP" com.tiffinbox.Bills'
    rcap 18 it-fixed '`.r-it-fixed.out` · md5' 0 'java -Duser.language=it -Duser.country=IT -cp "$CP" com.tiffinbox.Bills --no-system-fallback'
    rcap 18 code-default '`.r-code-default.out` · md5' 0 'java -Duser.language=en -Duser.country=US -cp "$CP" com.tiffinbox.Bills --code-as-default'
    panel ".r-en-machine.out: one key, two languages, the silent fallback" 18 in 'bill.total   en  -> Total for Ravi: 340 rupees' "$U/.r-en-machine.out"
    panel ".r-code-default.out: the key on a customer's bill" 18 in 'bill.missing     -> "bill.missing"' "$U/.r-code-default.out"
    has "THE BREAK, checked by receipts.sh: en_US machine -> 'Total for Ravi: 340 rupees'" '^    on an en_US machine : Total for Ravi: 340 rupees$' "$WORK/r18.out"
    has "…it_IT machine -> 'Totale per Ravi: 340 rupie'" '^    on an it_IT machine : Totale per Ravi: 340 rupie$' "$WORK/r18.out"
    has "ERRATA: 'On an Italian machine the English customer gets Italian too'" '^  bill\.total   en  -> Totale per Ravi' "$U/.r-it-machine.out"
  fi
  is "ERRATA: 'Bills --no-system-fallback (a program argument, receipts.sh:34)'" \
     "$(sed -n '34p' "$U/receipts.sh" | grep -c 'com.tiffinbox.Bills --no-system-fallback$' | tr -d ' ')" "1"
  expect_ok "ERRATA: '-DnoSysFallback=1 does nothing' (same output as without it)" 120 '' "$U" \
      "${CPV}java -Duser.language=it -Duser.country=IT -DnoSysFallback=1 -cp \"\$CP\" com.tiffinbox.Bills"
  [ -f "$U/.r-it-machine.out" ] && is "…byte-identical to .r-it-machine.out" "$(md5of "$OUT")" "$(md5of "$U/.r-it-machine.out")"
  E="$U/exercise"
  if build_ex35 18; then
    N='java -cp "$CP" com.tiffinbox.Notices'
    xrun "exercise: en_US" 0 u18-en "$E" "${CPV}java -Duser.language=en -Duser.country=US -cp \"\$CP\" com.tiffinbox.Notices"
    xrun "exercise: es_ES" 0 u18-es "$E" "${CPV}java -Duser.language=es -Duser.country=ES -cp \"\$CP\" com.tiffinbox.Notices"
    is "…'Before the change these two disagree: the second prints Spanish at a French customer'" \
       "$(grep -c 'fr -> Your order is ready, Amelie' "$WORK/u18-en")/$(grep -c 'fr -> Tu pedido' "$WORK/u18-es")" "1/1"
    solution_copy 18
    FX="$(rblock c4-unit18/exercise/solution/SOLUTION.md in 'setFallbackToSystemLocale(false)' | head -1 | sed 's/^ *//')"
    sed -i.bak "s|^\( *\)ms.setDefaultEncoding(\"UTF-8\");|&\\
\1$FX|" "$S/src/main/java/com/tiffinbox/Notices.java" && rm -f "$S"/src/main/java/com/tiffinbox/*.bak
    if build35 "SOLUTION.md on a copy: $FX" "$S"; then
      xrun "…en_US" 0 u18-sol-en "$S" "${CPV}java -Duser.language=en -Duser.country=US -cp \"\$CP\" com.tiffinbox.Notices"
      xrun "…es_ES" 0 u18-sol-es "$S" "${CPV}java -Duser.language=es -Duser.country=ES -cp \"\$CP\" com.tiffinbox.Notices"
      is "…'After the change they agree': French falls to the base bundle on both machines" \
         "$(grep -h 'fr ->' "$WORK/u18-sol-en" "$WORK/u18-sol-es" | sort -u | tr -s ' ')" " fr -> Your order is ready, Amelie"
    fi
    end_solution 18
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit19 ===
if unit 19 "what a proxy actually is"; then
  build35 "c4-unit19" "$U" 19
  if run_receipts 19; then
    rcap 19 by-hand '# .r-by-hand.out' 0 'java -cp "$CP" com.tiffinbox.ByHand'
    rcap 19 springs '# .r-springs.out' 0 'java -cp "$CP" com.tiffinbox.SpringsVersion'
    rcap 19 no-interface '# .r-no-interface.out' 1 'java -cp "$CP" com.tiffinbox.NoInterface'
    panel ".r-by-hand.out: a proxy by hand, java.lang.reflect only" 19 in 'the class I wrote : com.tiffinbox.KitchenRail' "$U/.r-by-hand.out"
    panel ".r-no-interface.out: no interface, no proxy" 19 in 'is not an interface' "$U/.r-no-interface.out"
    has "…'no AspectJ (receipts.sh counts: 0 jars)'" "AspectJ jars on this unit's class path: 0$" "$WORK/r19.out"
    has "…'the class it hands back has the identical name'" "hand-rolled and Spring's proxy class names: IDENTICAL" "$WORK/r19.out"
  fi
  E="$U/exercise"
  if build_ex35 19; then
    for h in 23 12; do rgives c4-unit19/exercise/README.md "$JCPT com.tiffinbox.ClosingTime $h" || bad "exercise/README.md still prints: … ClosingTime $h" "not found" noout; done
    xrun "exercise starts: ClosingTime 23 still cooks (no proxy yet)" 0 u19-ex "$E" "$JCPT com.tiffinbox.ClosingTime 23"
    solution_copy 19
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution: ClosingTime 23" 0 u19-sol23 "$S" "$JCPT com.tiffinbox.ClosingTime 23"
      has "…'must say closed'" '^at 23:00 -> closed$' "$WORK/u19-sol23"
      has "…'the real rail, called directly: it must still cook, at any hour'" 'the real rail, called directly -> cooking for Ravi' "$WORK/u19-sol23"
      xrun "solution: ClosingTime 12" 0 u19-sol12 "$S" "$JCPT com.tiffinbox.ClosingTime 12"
      has "…'must cook'" '^at 12:00 -> cooking for Ravi$' "$WORK/u19-sol12"
      same_file "…'without editing KitchenRail'" "$E/src/main/java/com/tiffinbox/KitchenRail.java" "$S/src/main/java/com/tiffinbox/KitchenRail.java"
    fi
    end_solution 19
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit20 ===
if unit 20 "aspects, join points, pointcuts, advice"; then
  build35 "c4-unit20" "$U" 20
  if run_receipts 20; then
    rcap 20 four-words '# .r-four-words.out' 0 'java -cp "$CP" com.tiffinbox.FourWords'
    rcap 20 switches-on '# .r-switches-on.out' - 'java -cp "$CP" com.tiffinbox.WhatItSwitchesOn'
    rcap 20 no-weaver 'trio md5' 1 -
    rcap 20 no-match '# .r-no-match.out' 0 'java -cp "$CP" com.tiffinbox.NoMatch'
    rcap 20 early '`.r-early.out`' - -
    rgives 20 'java -cp "$CP" com.tiffinbox.EarlyBean' || bad "the README still prints: java -cp \"\$CP\" com.tiffinbox.EarlyBean" "not found" noout
    expect_ok "…the README's EarlyBean command, through jul.sh as it says, gives .r-early.out's bytes" 120 '' "$U" \
        "${CPV}java -cp \"\$CP\" com.tiffinbox.EarlyBean 2>&1 | ./jul.sh"
    is "…md5 $(rhash 20 '`.r-early.out`')" "$(md5of "$OUT")" "$(rhash 20 '`.r-early.out`')"
    panel ".r-four-words.out: four words, each on the thing it names" 20 in 'the bean I got : jdk.proxy2' "$U/.r-four-words.out"
    panel ".r-switches-on.out: one bean added, none removed" 20 in 'your beans, in both runs' "$U/.r-switches-on.out"
    panel ".r-no-weaver.out: the bean the annotation adds is the one the missing jar kills" 20 in "Error creating bean with name 'org.springframework.aop.config.internalAutoProxyCreator'" "$U/.r-no-weaver.out" '^trio md5'
    panel ".r-no-weaver-plain.out: without the annotation the aspect class itself fails" 20 in "Error creating bean with name 'auditAspect'" "$U/.r-no-weaver-plain.out"
    panel ".r-no-match.out: one letter, exit 0, advice never runs" 20 in 'pointcut      : execution(* com.tiffinbox.Billing.prise(..))' "$U/.r-no-match.out"
    panel ".r-early.out: the detector's blind spot" 20 in 'matches BillingService.price? true' "$U/.r-early.out"
  fi
  E="$U/exercise"
  if build_ex35 20; then
    rgives c4-unit20/exercise/README.md "$JCPT com.tiffinbox.Receipt" || bad "exercise/README.md still prints: … Receipt" "not found" noout
    xrun "exercise starts: the receipt log never writes" 0 u20-ex "$E" "$JCPT com.tiffinbox.Receipt"
    has "…'look at bean class': a plain class, so nothing was attached" '^bean class : com\.tiffinbox\.BillingService$' "$WORK/u20-ex"
    has "…receipts logged: 0" '^receipts logged: 0$' "$WORK/u20-ex"
    solution_copy 20
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution: the pointcut fixed" 0 u20-sol "$S" "$JCPT com.tiffinbox.Receipt"
      has "…'show the class name change': a proxy now" '^bean class : jdk\.proxy[0-9]*\.\$Proxy' "$WORK/u20-sol"
      has "…and the receipt is logged" '^receipts logged: 1$' "$WORK/u20-sol"
    fi
    end_solution 20
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit21 ===
if unit 21 "@Before, @After and @Around"; then
  build35 "c4-unit21" "$U" 21
  if run_receipts 21; then
    rcap 21 in-order '`.r-in-order.out` md5' 0 'java -cp "$CP" com.tiffinbox.InOrder'
    rcap 21 three-powers 'com.tiffinbox.ThreePowers` · md5' - 'java -cp "$CP" com.tiffinbox.ThreePowers'
    rcap 21 forgot 'com.tiffinbox.ForgotProceed` · md5' - 'java -cp "$CP" com.tiffinbox.ForgotProceed'
    rcap 21 timing 'com.tiffinbox.Timing` · masked md5' - 'java -cp "$CP" com.tiffinbox.Timing'
    is ".r-in-order.out: @Around (entering) -> @Before -> the method -> @AfterReturning -> @After -> @Around (leaving)" \
       "$(sed -n '2,7p' "$U/.r-in-order.out" | sed -E 's/^ +//; s/ +/ /g; s/\(the real method ran for Ravi\)/method/' | tr '\n' '>')" \
       "@Around (entering)>@Before>method>@AfterReturning>@After>@Around (leaving)>"
    has "…'Make the call throw and @AfterThrowing takes @AfterReturning's place'" '^    @AfterThrowing$' "$U/.r-in-order.out"
    has ".r-three-powers.out: skip the call -> -1" 'caller got: -1$' "$U/.r-three-powers.out"
    has "…change the arguments -> the method runs for SOMEBODY ELSE" 'the real method ran for SOMEBODY ELSE' "$U/.r-three-powers.out"
    has "…change the return value -> 340 becomes 680" 'caller got: 680$' "$U/.r-three-powers.out"
    is ".r-forgot.out: the README's four rows (int loud; Integer, String, void silent)" \
       "$(grep -A1 'return type' "$U/.r-forgot.out" | grep -v '^--' | paste - - | sed -E 's/ +/ /g' | awk '{print $3, ($0 ~ /AopInvocationException: Null return value from advice does not match primitive return type/) ? "loud" : (($0 ~ /nothing reported a problem/) ? "silent" : "?")}' | tr '\n' ',')" \
       "int: loud,Integer: silent,String: silent,void: silent,"
    has "…'prints three runs' raw values and fails if they ever come out identical'" '^  distinct durations: [2-9]' "$WORK/r21.out"
  fi
  E="$U/exercise"
  if build_ex35 21; then
    rgives c4-unit21/exercise/README.md "$JCPT com.tiffinbox.Discount" || bad "exercise/README.md still prints: … Discount" "not found" noout
    xrun "exercise starts: the student pays full price" 0 u21-ex "$E" "$JCPT com.tiffinbox.Discount"
    has "…student-Asha pays 340" '^student-Asha pays 340$' "$WORK/u21-ex"
    solution_copy 21
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution" 0 u21-sol "$S" "$JCPT com.tiffinbox.Discount"
      has "…'student-Asha pays 306'" '^student-Asha pays 306$' "$WORK/u21-sol"
      has "…'and Ravi still pays 340'" '^Ravi +pays 340$' "$WORK/u21-sol"
      same_file "…'BillingService must not change'" "$E/src/main/java/com/tiffinbox/BillingService.java" "$S/src/main/java/com/tiffinbox/BillingService.java"
    fi
    end_solution 21
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit22 ===
if unit 22 "pointcut expressions in depth"; then
  build35 "c4-unit22" "$U" 22
  if run_receipts 22; then
    rcap 22 matrix '`.r-matrix.out` md5' - 'java -cp "$CP" com.tiffinbox.Matrix'
    rcap 22 static-or-rt 'com.tiffinbox.StaticOrRuntime` · md5' - 'java -cp "$CP" com.tiffinbox.StaticOrRuntime'
    rcap 22 dollar-star 'com.tiffinbox.DollarStar` · md5' - 'java -cp "$CP" com.tiffinbox.DollarStar'
    rcap 22 named 'com.tiffinbox.Named` · md5' - 'java -cp "$CP" com.tiffinbox.Named'
    panel ".r-matrix.out: every form, against the same three methods" 22 in 'price  refund dishes' "$U/.r-matrix.out"
    panel ".r-static-or-rt.out: the right-hand column is the test" 22 in 'args(String)                        checked at run time' "$U/.r-static-or-rt.out"
    has "…'\$* as a nested-type wildcard matches nothing (asserted: advice ran 0)'" 'wildcard: advice ran 0$' "$WORK/r22.out"
  fi
  E="$U/exercise"
  if build_ex35 22; then
    rgives c4-unit22/exercise/README.md "$JCPT com.tiffinbox.OnlyRefunds" || bad "exercise/README.md still prints: … OnlyRefunds" "not found" noout
    xrun "exercise starts: the rule audits every call in the package" 0 u22-ex "$E" "$JCPT com.tiffinbox.OnlyRefunds"
    has "…audited calls: 3 (want 1)" '^audited calls: 3 ' "$WORK/u22-ex"
    solution_copy 22
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution" 0 u22-sol "$S" "$JCPT com.tiffinbox.OnlyRefunds"
      has "…only refund(): audited calls: 1" '^audited calls: 1 ' "$WORK/u22-sol"
      has "…'menu must come back as its plain class, not a proxy'" '^menu bean +: com\.tiffinbox\.MenuService$' "$WORK/u22-sol"
    fi
    end_solution 22
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit23 ===
if unit 23 "JDK proxies vs CGLIB, and the self-invocation trap"; then
  build35 "c4-unit23" "$U" 23
  if run_receipts 23; then
    rcap 23 jdk '`.r-jdk.out`' - 'java -cp "$CP" com.tiffinbox.TwoMechanisms'
    rcap 23 cglib '`.r-cglib.out`' - 'java -cp "$CP" com.tiffinbox.TwoMechanisms force'
    rcap 23 ways-out '`.r-ways-out.out`' - 'java -cp "$CP" com.tiffinbox.WaysOut'
    panel ".r-jdk.out: A — the default setting" 23 in '  proxyTargetClass = false' "$U/.r-jdk.out"
    panel "…the one WARNING, about the PUBLIC final method" 23 in 'Public final method [...FinalBilling' "$U/.r-jdk.out"
    panel ".r-ways-out.out: three ways out, each run, each priced" 23 in '1. extract to a second bean' "$U/.r-ways-out.out"
    has "…'Flip proxyTargetClass and exactly one row moves' (receipts.sh counts it)" 'rows that moved when proxyTargetClass flipped: 1$' "$WORK/r23.out"
    has "…A' after the flip is identical to A" "A' \(default again, after the flip\): identical to A" "$WORK/r23.out"
  fi
  E="$U/exercise"
  if build_ex35 23; then
    rgives c4-unit23/exercise/README.md "$JCPT com.tiffinbox.Checkout" || bad "exercise/README.md still prints: … Checkout" "not found" noout
    xrun "exercise starts: the aspect never sees checkout's items" 0 u23-ex "$E" "$JCPT com.tiffinbox.Checkout"
    has "…advice ran 0" 'advice ran 0 ' "$WORK/u23-ex"
    solution_copy 23
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution: extract a second bean" 0 u23-sol "$S" "$JCPT com.tiffinbox.Checkout"
      has "…'Advice must run once per item' (2 items)" 'advice ran 2 +\(want 2\)$' "$WORK/u23-sol"
      is "…'the real way — extract a second bean — not with self-injection or AopContext'" \
         "$(grep -c 'AopContext\|currentProxy' "$S/src/main/java/com/tiffinbox/Checkout.java" | tr -d ' ')" "0"
    fi
    end_solution 23
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit24 ===
if unit 24 "AOP's limits, and AspectJ"; then
  build35 "c4-unit24" "$U" 24
  rgives 24 'CP="target/classes:$(cat cp.txt)"; AJ=$(tr '"':'"' '"'\n'"' < cp.txt | grep aspectjweaver)' \
    || bad "the README still prints the CP/AJ line" "not found" noout
  expect_ok "AJ=\$(tr ':' '\\n' < cp.txt | grep aspectjweaver) names one jar, in this unit's own .m2-demo" 30 '/\.m2-demo/org/aspectj/aspectjweaver/1\.9\.25\.1/aspectjweaver-1\.9\.25\.1\.jar$' \
      "$U" "tr ':' '\\n' < cp.txt | grep aspectjweaver"
  if run_receipts 24; then
    rcap 24 proxies 'com.tiffinbox.ProxyLimits` · md5' - 'java -cp "$CP" com.tiffinbox.ProxyLimits'
    rcap 24 no-agent '# .r-no-agent.out' - 'java -cp "$CP" com.tiffinbox.Limits'
    rcap 24 woven '# .r-woven.out' - 'java -javaagent:"$AJ" -cp "$CP" com.tiffinbox.Limits'
    rcap 24 both 'java -javaagent:"$AJ" -cp "$CP" com.tiffinbox.ProxyLimits` · md5' - 'java -javaagent:"$AJ" -cp "$CP" com.tiffinbox.ProxyLimits'
    rcap 24 wrong-pkg '# .r-wrong-pkg.out' 0 -
    rcap 24 woven-info '(`.r-woven-info.out`' - -
    rcap 24 wrong-info '(`.r-wrong-info.out`' - -
    panel ".r-proxies.out: the limits, gathered" 24 in "Spring's proxies:" "$U/.r-proxies.out"
    panel ".r-both.out: weave it or proxy it — never both" 24 in 'one price() from outside            : advice ran 3' "$U/.r-both.out"
    panel ".r-woven-info.out: -showWeaveInfo names what it wove" 24 in 'weaveinfo at com/tiffinbox/Kitchen.java' "$U/.r-woven-info.out"
    # the README's table, read off the README and held against receipts.sh's own derived rows
    python3 - "$(rfile 24)" >"$WORK/u24-table.readme" <<'PY'
import re, sys
t = open(sys.argv[1], encoding="utf-8").read()
rows = {"Spring's proxies": "proxies", "plain `new`, no agent": "no-agent", "plain `new`, **with the agent**": "woven"}
for l in t.split("\n"):
    for k, v in rows.items():
        if l.startswith("| " + k + " |"):
            cells = [re.sub(r"[*]", "", c).strip() for c in l.strip("|").split("|")[1:4]]
            print(v, " ".join(re.match(r"\d+", c).group(0) for c in cells))
PY
    grep -E '^  (proxies|no-agent|woven) +outside' "$WORK/r24.out" | awk '{print $1, $3, $5, $7}' >"$WORK/u24-table.got"
    if diff "$WORK/u24-table.readme" "$WORK/u24-table.got" >/dev/null; then ok "…the README's outside/inside/final table is receipts.sh's (proxies 1 0 0 · no agent 0 0 0 · agent 1 2 1)"
    else bad "…the README's outside/inside/final table is receipts.sh's" "README: $(tr '\n' '|' <"$WORK/u24-table.readme") receipts: $(tr '\n' '|' <"$WORK/u24-table.got")" noout; fi
    is "…'four WARNING lines — three naming sun.misc.Unsafe, one asking you to report it'" \
       "$(grep -c '^WARNING' "$U/.r-woven.out" | tr -d ' ')/$(grep -c '^WARNING.*sun\.misc\.Unsafe' "$U/.r-woven.out" | tr -d ' ')/$(grep -c '^WARNING: Please consider reporting' "$U/.r-woven.out" | tr -d ' ')" "4/3/1"
    has "…'the warnings on stderr are identical to the working run's'" 'working weave vs wrong package: IDENTICAL' "$WORK/r24.out"
    skip "'834 Spring classes in a Spring run' (what the weaver would examine without the include line)" "no command in the unit reproduces that count"
  fi
  E="$U/exercise"
  if build_ex35 24; then
    PX='AJ=$(tr '"':'"' '"'\n'"' < cp.txt | grep aspectjweaver); java -javaagent:"$AJ" -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Proof'
    rgives c4-unit24/exercise/README.md 'java -javaagent:"$AJ" -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Proof' || bad "exercise/README.md still prints the Proof line" "not found" noout
    xrun "exercise starts: the agent is on, the warnings print" 0 u24-ex "$E" "$PX"
    has "…and priceTwice() ran the advice 0 times — decide from the number" 'priceTwice\(\): advice ran 0 ' "$WORK/u24-ex"
    solution_copy 24
    if build35 "exercise/ + solution/aop.xml (copy)" "$S"; then
      xrun "solution" 0 u24-sol "$S" "$PX"
      has "…'until priceTwice() runs the advice twice'" 'priceTwice\(\): advice ran 2 ' "$WORK/u24-sol"
      has "…'make the weaver TELL you': a weaveinfo line" ' weaveinfo ' "$WORK/u24-sol"
      is "…'The warnings will not change either way'" "$(grep '^WARNING' "$WORK/u24-ex" | sed 's/(file:[^)]*)//' | md5in)" "$(grep '^WARNING' "$WORK/u24-sol" | sed 's/(file:[^)]*)//' | md5in)"
    fi
    end_solution 24
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit25 ===
if unit 25 "the event publisher: delete a dependency"; then
  build35 "c4-unit25" "$U" 25
  if run_receipts 25; then
    rcap 25 before 'com.tiffinbox.Coupled` · md5' - 'java -cp "$CP" com.tiffinbox.Coupled'
    rcap 25 after 'com.tiffinbox.Decoupled` · md5' - 'java -cp "$CP" com.tiffinbox.Decoupled'
    rcap 25 break 'com.tiffinbox.Decoupled break` · md5' - 'java -cp "$CP" com.tiffinbox.Decoupled break'
    rcap 25 handled 'com.tiffinbox.Decoupled handled` · md5' - 'java -cp "$CP" com.tiffinbox.Decoupled handled'
    panel ".r-before.out: a dependency that feels necessary" 25 in '[kitchen] cooking for Ravi' "$U/.r-before.out"
    panel ".r-after.out: the edge deleted, synchronous" 25 in '[kitchen] publish returned' "$U/.r-after.out"
    panel ".r-break.out: a listener you did not write fails your order" 25 in 'an order for nobody:' "$U/.r-break.out"
    panel ".r-handled.out: the remedy — one bean" 25 in '[handler] a listener failed' "$U/.r-handled.out"
    has "…'every mention of SmsNotifier gone from Kitchen (asserted: 0 mentions)'" 'mentions of SmsNotifier inside the new Kitchen: 0$' "$WORK/r25.out"
  fi
  E="$U/exercise"
  if build_ex35 25; then
    LX='sed -n '"'"'/class Kitchen/,/^    }/p'"'"' src/main/java/com/tiffinbox/Loyalty.java | grep -c LoyaltyBook'
    rgives c4-unit25/exercise/README.md "$LX" || bad "exercise/README.md still prints the sed | grep -c line" "not found" noout
    xrun "exercise starts" 0 u25-ex "$E" "$JCPT com.tiffinbox.Loyalty"
    has "…the kitchen's own dependencies: [loyaltyBook]" '\(yours\): \[loyaltyBook\]' "$WORK/u25-ex"
    solution_copy 25
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution" 0 u25-sol "$S" "$JCPT com.tiffinbox.Loyalty"
      has "…'Prove it with Edges — the kitchen's own dependencies must print []'" '\(yours\): \[\] ' "$WORK/u25-sol"
      has "…'and the points must still be 34'" '^  points: 34 ' "$WORK/u25-sol"
      expect_rc "…$LX  # must print 0" 30 1 '^0$' "$S" "$LX"
    fi
    end_solution 25
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit26 ===
if unit 26 "conditional, ordered and async listeners"; then
  build35 "c4-unit26" "$U" 26
  if run_receipts 26; then
    rcap 26 conditions 'com.tiffinbox.Conditions` · md5' - 'java -cp "$CP" com.tiffinbox.Conditions'
    rcap 26 params '(`.params/`, the build setting Spring Boot turns on) · md5' - -
    rcap 26 ordered 'com.tiffinbox.Ordered` · md5' - 'java -cp "$CP" com.tiffinbox.Ordered'
    rcap 26 async 'com.tiffinbox.AsyncListener` · md5' - 'java -cp "$CP" com.tiffinbox.AsyncListener'
    rcap 26 noenable '(`AsyncListener noenable` · md5' - -
    panel ".r-conditions.out: the documentation's first example throws" 26 in 'parameter names for reflection (-parameters)? false' "$U/.r-conditions.out"
    panel ".r-ordered.out: the same annotation, a different list" 26 in 'run 1: sms loyalty receipt' "$U/.r-ordered.out"
    panel ".r-async.out: @Async on a listener, observed" 26 in '  publishing on main' "$U/.r-async.out"
    panel ".r-noenable.out: no @EnableAsync, runs on main" 26 in '@Async on the listener, but NO @EnableAsync' "$U/.r-noenable.out"
    is "…'1 entry in spring-core 6.0.23, 0 in 6.1.0' (.r-reader-since.out)" \
       "$(sed -n 's/^  spring-core \([0-9.]*\): LocalVariableTableParameterNameDiscoverer entries = \([0-9]*\)$/\1=\2/p' "$U/.r-reader-since.out" | tr '\n' ' ')" "6.0.23=1 6.1.0=0 "
  fi
  E="$U/exercise"
  if build_ex35 26; then
    rgives c4-unit26/exercise/README.md "$JCPT com.tiffinbox.BigOrders" || bad "exercise/README.md still prints: … BigOrders" "not found" noout
    xrun "exercise starts: 'the kitchen falls over on the first order'" 1 u26-ex "$E" "$JCPT com.tiffinbox.BigOrders"
    hasF "…SpelEvaluationException" 'SpelEvaluationException' "$WORK/u26-ex"
    solution_copy 26
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution" 0 u26-sol "$S" "$JCPT com.tiffinbox.BigOrders"
      has "…'a 900 order gets the call, a 340 order does not'" '^  manager calls: 1 +\(want 1\)$' "$WORK/u26-sol"
      same_file "…'without touching the build file'" "$E/pom.xml" "$S/pom.xml"
    fi
    end_solution 26
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit27 ===
if unit 27 "@Async and the TaskExecutor"; then
  build35 "c4-unit27" "$U" 27
  if run_receipts 27; then
    rcap 27 threads 'com.tiffinbox.WhoseThread` · md5' - 'java -cp "$CP" com.tiffinbox.WhoseThread'
    rcap 27 pools 'com.tiffinbox.Pools` · md5' - 'java -cp "$CP" com.tiffinbox.Pools'
    rcap 27 failure 'com.tiffinbox.Failures` · md5' - 'java -cp "$CP" com.tiffinbox.Failures'
    rcap 27 handler 'com.tiffinbox.Failures handler` · md5' - 'java -cp "$CP" com.tiffinbox.Failures handler'
    panel ".r-threads.out: whose thread is this?" 27 in '[caller] on main' "$U/.r-threads.out"
    panel ".r-pools.out: the default is not a pool" 27 in 'the default (no executor bean)' "$U/.r-pools.out"
    panel ".r-failure.out: the caller never knows" 27 in '[caller] burn() returned' "$U/.r-failure.out"
  fi
  E="$U/exercise"
  if build_ex35 27; then
    rgives c4-unit27/exercise/README.md "$JCPT com.tiffinbox.Receipts" || bad "exercise/README.md still prints: … Receipts" "not found" noout
    xrun "exercise starts: every receipt gets a brand-new thread" 0 u27-ex "$E" "$JCPT com.tiffinbox.Receipts"
    has "…30 receipts on 30 distinct threads" '30 receipts on 30 distinct threads' "$WORK/u27-ex"
    solution_copy 27
    if build35 "exercise/ + solution/ (copy)" "$S"; then
      xrun "solution" 0 u27-sol "$S" "$JCPT com.tiffinbox.Receipts"
      has "…'30 receipts must run on 3 distinct threads' named receipts-" '30 receipts on 3 distinct threads .*receipts-<n>' "$WORK/u27-sol"
    fi
    end_solution 27
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit28 ===
if unit 28 "@Scheduled: fixed rate vs fixed delay vs cron"; then
  build35 "c4-unit28" "$U" 28
  if run_receipts 28; then
    rcap 28 shapes 'com.tiffinbox.RateVsDelay` · masked md5' - 'java -cp "$CP" com.tiffinbox.RateVsDelay'
    rcap 28 cron 'com.tiffinbox.CronNext` · md5' - 'java -cp "$CP" com.tiffinbox.CronNext'
    panel ".r-shapes.out: three ways to say 'every 300 ms', the shape hashed" 28 in 'fixedRate  = 300, job 200 ms' "$U/.r-shapes.out"
    panel ".r-cron.out: computed, never waited for" 28 in 'computed from 2026-09-25T12:00 FRIDAY' "$U/.r-cron.out"
    skip "the raw gaps panel (run 1: [304, 300, 300] …)" "durations: 'they wobble, which is exactly why no single one is quoted as a fact' — the shape above is what is held"
  fi
  E="$U/exercise"
  if build_ex35 28; then
    XC="$JCPT com.tiffinbox.CronNext \"0 15 11 * * *\""
    rgives c4-unit28/exercise/README.md "$XC" || bad "exercise/README.md still prints: $XC" "not found" noout
    xrun "exercise starts: '0 15 11 * * *'" 0 u28-ex "$E" "$XC"
    has "…'customers are getting reminders on Sunday'" 'SUNDAY$' "$WORK/u28-ex"
    XS="$JCPT com.tiffinbox.CronNext \"0 15 11 * * MON-FRI\""
    rgives c4-unit28/exercise/solution/SOLUTION.md "$XS" || bad "SOLUTION.md still prints: $XS" "not found" noout
    xrun "SOLUTION.md: '0 15 11 * * MON-FRI'" 0 u28-sol "$E" "$XS"
    is "…'Monday, Tuesday, Wednesday and Thursday at 11:15'" \
       "$(grep -oE 'next -> [0-9-]+T11:15 +[A-Z]+DAY' "$WORK/u28-sol" | awk '{print $NF}' | tr '\n' ' ')" "MONDAY TUESDAY WEDNESDAY THURSDAY "
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit29 ===
if unit 29 "scheduling pitfalls: one thread, every job"; then
  build35 "c4-unit29" "$U" 29
  rgives 29 './receipts.sh' || bad "the README still prints ./receipts.sh in its command block" "not found" noout
  if run_receipts 29; then
    rcap 29 starved 'com.tiffinbox.Starved` · md5' - -
    rcap 29 hung 'com.tiffinbox.Hung` · md5' - -
    rcap 29 wrapped 'com.tiffinbox.WrappedOrNot` · md5' - -
    panel ".r-starved.out: the default is one thread" 29 in 'threads that ran both jobs, one thread' "$U/.r-starved.out"
    panel ".r-hung.out: a job that never returns" 29 in 'one report that never returns' "$U/.r-hung.out"
    panel ".r-wrapped.out: the same exception, with and without Spring's wrapper" 29 in "through Spring's @Scheduled" "$U/.r-wrapped.out"
    skip "the raw-numbers panel (counts 13 vs 13, longest gaps 856 vs 108 ms …)" "'printed so you can see the wobble, never quoted as facts' — the computed verdicts above are what is held"
  fi
  E="$U/exercise"
  if build_ex35 29; then
    rgives c4-unit29/exercise/README.md "$JCPT com.tiffinbox.Heartbeat" || bad "exercise/README.md still prints: … Heartbeat" "not found" noout
    xrun "exercise starts" 0 u29-ex "$E" "$JCPT com.tiffinbox.Heartbeat"
    panel "…'beats in 0.7 s: 2 - dead'" c4-unit29/exercise/README.md after 'com.tiffinbox.Heartbeat' "$WORK/u29-ex"
    is "…SOLUTION.md's stack line 'at com.tiffinbox.Heartbeat.beat(Heartbeat.java:15)' names beat()" \
       "$(sed -n '15p' "$E/src/main/java/com/tiffinbox/Heartbeat.java" | grep -c 'static void beat()' | tr -d ' ')" "1"
    skip "SOLUTION.md (the exception kept in the future; a catch-and-log wrapper)" "the solution is code to write, not a file or a one-line edit — nothing shipped to lay over the exercise"
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit30 ===
if unit 30 "core resilience annotations in Framework 7"; then
  build35 "c4-unit30" "$U" 30
  rgives 30 './receipts.sh' || bad "the README still prints ./receipts.sh in its command block" "not found" noout
  if run_receipts 30; then
    rcap 30 where 'com.tiffinbox.WhereItLives` · md5' - -
    rcap 30 since '`./since.sh` · md5' - - 1
    rcap 30 attempts 'com.tiffinbox.Attempts` · md5' - -
    rcap 30 bill 'com.tiffinbox.TheBill` · md5' - -
    rcap 30 limit 'com.tiffinbox.Limit` · md5' - -
    panel ".r-where.out: where it lives, read off each class" 30 in '@Retryable               from spring-context-7.0.9.jar' "$U/.r-where.out"
    panel ".r-since.out: since when" 30 in 'spring-context 6.2.19: 0 entries' "$U/.r-since.out"
    panel ".r-attempts.out: attempts, counted" 30 in 'fails twice, then works - called through the bean:' "$U/.r-attempts.out"
    panel ".r-bill.out: the break — the bill" 30 in 'one order of 340: paid after 3 attempts' "$U/.r-bill.out"
    panel ".r-limit.out: two burners, six cooks" 30 in 'six cooks at once, no limit' "$U/.r-limit.out"
  fi
  E="$U/exercise"
  if build_ex35 30; then
    rgives c4-unit30/exercise/README.md "$JCPT com.tiffinbox.TheBill" || bad "exercise/README.md still prints: … TheBill" "not found" noout
    xrun "exercise starts" 0 u30-ex "$E" "$JCPT com.tiffinbox.TheBill"
    panel "…'charged 1020 for one order'" c4-unit30/exercise/README.md after 'com.tiffinbox.TheBill' "$WORK/u30-ex"
    KEY="$(rblock c4-unit30/exercise/solution/SOLUTION.md in 'String key = ' | head -1 | sed -E 's/^ +//; s/ +\/\/.*$//')"
    solution_copy 30
    sed -i.bak "s|String key = UUID.randomUUID().toString();|$KEY|" "$S/src/main/java/com/tiffinbox/TheBill.java" && rm -f "$S"/src/main/java/com/tiffinbox/*.bak
    if grep -qF "$KEY" "$S/src/main/java/com/tiffinbox/TheBill.java" && build35 "SOLUTION.md on a copy: $KEY" "$S"; then
      xrun "…the key made from the order" 0 u30-sol "$S" "$JCPT com.tiffinbox.TheBill"
      panel "…'charged 340 for one order', as SOLUTION.md prints it" c4-unit30/exercise/solution/SOLUTION.md in 'charged 340 for one order' "$WORK/u30-sol"
    else bad "SOLUTION.md's one line, laid over a copy" "could not apply: $KEY" noout; fi
    end_solution 30
  fi
  end_unit "$U"
fi

# =============================================================== c4-unit31 ===
if unit 31 "capstone: TiffinBox as a Spring application"; then
  if ports_free_before "c4-unit31" 18441 18442 18445 18446 18447 18448 18449; then
    if run_receipts 31; then
      rpub 31 before
      rpub 31 after '(`.r-after.out`'
      rpub 31 one-new '`.r-one-new.out`'
      rpub 31 identical '(`.r-identical.out`'
      rpub 31 second-wiring '`.r-second-wiring.out`'
      rpub 31 ledger-before '(`.r-ledger-before.out`'
      rpub 31 ledger-after '(`.r-ledger-after.out`'
      rpub 31 ledger-project '`.r-ledger-project.out`'
      rpub 31 ledger-one-new '(`.r-ledger-one-new.out`'
      rpub 31 objects '`.r-objects.out`'
      rpub 31 order '(`.r-order.out`'
      rpub 31 no-db '(`.r-no-db.out`'
      rpub 31 break-diff '(`.r-break-diff.out`'
      rpub 31 kitchens '`.r-kitchens.out`'
      is "…receipts.md5 lists exactly the captures receipts.sh printed" \
         "$(awk '{print $1}' "$U/receipts.md5" | sort | tr '\n' ' ')" "$(grep -E '^  [a-z-]+ +md5 [0-9a-f]{32}' "$WORK/r31.out" | awk '{print $1}' | sort | tr '\n' ' ')"
      panel ".r-ledger-before.out: the old ledger, re-derived" 31 in 'and what starting it costs, counted out of the source:' "$U/.r-ledger-before.out"
      panel ".r-second-wiring.out: the wiring nobody counted" 31 in 'hand-written constructions, counted per file' "$U/.r-second-wiring.out"
      panel ".r-objects.out: the objects, measured (and the checker caught)" 31 in 'classes compared: Customer CustomerRepository' "$U/.r-objects.out"
      panel ".r-ledger-after.out: delete it" 31 in 'ledger: no ../c4-tiffinbox' "$U/.r-ledger-after.out"
      panel ".r-ledger-project.out: counted over the whole project" 31 in 'the classes the container builds' "$U/.r-ledger-project.out"
      panel ".r-order.out: who decides the order now" 31 in 'class path: tiffinbox-web first' "$U/.r-order.out"
      panel ".r-identical.out: one hash for the seven responses" 31 in 'the seven responses (status, content type, body)' "$U/.r-identical.out"
      panel ".r-after.out: the seven responses" 31 in 'GET   /customers  ->' "$U/.r-after.out"
      panel ".r-no-db.out: it refuses to start and names the chain" 31 in "cancelling refresh attempt: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'tiffinBoxServer'" "$U/.r-no-db.out"
      panel ".r-break-diff.out: one new, as a diff" 31 in '@@ -46,3 +46,4 @@' "$U/.r-break-diff.out"
      panel ".r-kitchens.out: A, B, A'" 31 in 'A  the rewired anchor' "$U/.r-kitchens.out"
      panel ".r-ledger-one-new.out: two rows move back" 31 in 'hand-written constructions of those classes ......................... 9 -> 1' "$U/.r-ledger-one-new.out"
    fi
    # ---- the exercise: its README's commands, verbatim, on a copy it makes itself (my-tiffinbox)
    E="$U/exercise"
    RS='rsync -a --exclude target ../../c4-tiffinbox/ my-tiffinbox/'
    BLD='(cd my-tiffinbox && mvn -q -Dmaven.repo.local=../../.m2-demo -DskipTests package)'
    RUN='java -Dtiffinbox.days=7 -jar my-tiffinbox/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18449'
    for c in "$RS" "$BLD" "$RUN" 'curl -s http://127.0.0.1:18449/config' 'curl -s http://127.0.0.1:18449/kitchen' 'curl -s -X POST http://127.0.0.1:18449/shutdown'; do
      rgives c4-unit31/exercise/README.md "$c" || bad "exercise/README.md still prints: $c" "not found" noout
    done
    MYT_NEW=0; [ -e "$E/my-tiffinbox" ] || MYT_NEW=1
    expect_ok "exercise: $RS" 300 '' "$E" "$RS"
    cp "$E/solution/TiffinBoxServer.java" "$E/my-tiffinbox/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java"
    printf '  %s(solution/TiffinBoxServer.java copied into my-tiffinbox, as the README tells you to edit it)%s\n' "$DIM" "$OFF"
    expect_ok "exercise: $BLD — 'reuses the jars receipts.sh fetched' (c4-unit31/.m2-demo)" 900 '' "$E" "$BLD"
    ( cd "$E" && exec bash -c "$RUN" ) >"$WORK/u31-ex.log" 2>&1 </dev/null &
    SRV=$!
    if wait_port_up 18449; then
      : >"$WORK/u31-ex.out"
      for c in 'curl -s http://127.0.0.1:18449/config' 'curl -s http://127.0.0.1:18449/kitchen' 'curl -s -X POST http://127.0.0.1:18449/shutdown'; do
        sh_in "$E" "$c" >>"$WORK/u31-ex.out" 2>&1; echo >>"$WORK/u31-ex.out"; done
      panel "…with -Dtiffinbox.days=7: /config, /kitchen and /shutdown print what SOLUTION.md prints" c4-unit31/exercise/solution/SOLUTION.md in '{"cooks":3,"days":7}' "$WORK/u31-ex.out"
    else cp "$WORK/u31-ex.log" "$OUT"; bad "exercise: $RUN" "nothing listened on 18449 within 40 s"; fi
    for _ in $(seq 1 60); do kill -0 "$SRV" 2>/dev/null || break; sleep 0.25; done
    if kill -0 "$SRV" 2>/dev/null; then kill_tree "$SRV"; bad "…the server exits after POST /shutdown" "still running 15 s later" noout
    else wait "$SRV"; is "…the server exits after POST /shutdown, exit 0" "$?" "0"; fi
    [ "$MYT_NEW" = 1 ] && rm -rf "$E/my-tiffinbox"
  fi
  end_unit "$U" 18441 18442 18445 18446 18447 18448 18449
fi

# =============================================================== c4-unit32 ===
if unit 32 "what's next: the magic, explained"; then
  if ports_free_before "c4-unit32" 18451 18452; then
    if run_receipts 32; then
      rpub 32 mechanisms '`.r-mechanisms.out`'
      rpub 32 takeout '(`.r-takeout.out`'
      is "…receipts.md5 lists exactly the captures receipts.sh printed" \
         "$(awk '{print $1}' "$U/receipts.md5" | sort | tr '\n' ' ')" "$(grep -E '^  [a-z-]+ +md5 [0-9a-f]{32}' "$WORK/r32.out" | awk '{print $1}' | sort | tr '\n' ' ')"
      panel ".r-mechanisms.out: every name, printed by the application itself" 32 in 'the capstone, asked what it is made of:' "$U/.r-mechanisms.out"
      panel ".r-takeout.out: each hook, taken out" 32 in 'without ConfigurationClassPostProcessor: the context started' "$U/.r-takeout.out"
    fi
  fi
  end_unit "$U" 18451 18452
fi

# =============================================================== teardown ===
cd "$REPO" || exit 2
CUR_UNIT="teardown"
printf '\n%steardown%s\n' "$DIM" "$OFF"
for p in $(all_c4_jvms); do kill -9 "$p" >/dev/null 2>&1; done
rm -rf "$REPO"/c4-unit*/.verify-solution 2>/dev/null
remove_new_extras
extras >"$WORK/extras.after"
if [ "$KEEP_M2" = 1 ]; then
  grep -vE '(\.m2-demo/?|/\.cp|/cp\.txt|/cp-el\.txt|/cp-noel\.txt)$' "$WORK/extras.before" >"$WORK/eb"
  grep -vE '(\.m2-demo/?|/\.cp|/cp\.txt|/cp-el\.txt|/cp-noel\.txt)$' "$WORK/extras.after"  >"$WORK/ea"
else cp "$WORK/extras.before" "$WORK/eb"; cp "$WORK/extras.after" "$WORK/ea"; fi
if cmp -s "$WORK/eb" "$WORK/ea"; then
  ok "git reports the same ignored/untracked entries under c4-* as before the run ($(nlines "$WORK/ea")) — every generated file removed"
else
  bad "every generated file removed" "left behind: $(LC_ALL=C comm -13 "$WORK/eb" "$WORK/ea" | head -8 | tr '\n' ' ') gone: $(LC_ALL=C comm -23 "$WORK/eb" "$WORK/ea" | head -4 | tr '\n' ' ')" noout
fi
FP_AFTER="$(tracked_fp)"
is "every tracked file under c4-* is byte-for-byte as the run found it" "$FP_AFTER" "$FP_BEFORE"
is "~/.m2/repository/com/tiffinbox is as it was (nothing of ours reached your real repository)" "$(m2home_state)" "$M2HOME_BEFORE"
LEFT="$(all_c4_jvms | tr '\n' ' ')"
is "no JVM is running from any c4-* folder" "${LEFT:-none}" "none"
BUSY=""; for p in $ALL_PORTS; do port_busy "$p" && BUSY="$BUSY $p"; done
is "ports $ALL_PORTS are all free" "${BUSY:-none}" "none"

stop_central_cache

# ------------------------------------------------------------------ report ---
printf '\n---------------------------------------------\n'
central_cache_summary
if [ ${#UNITS[@]} -eq 0 ]; then
  UNCHECKED=""
  for d in "$REPO"/c4-*/; do
    n="$(basename "$d")"
    case "$n" in c4-unit0[1-9]|c4-unit[12][0-9]|c4-unit3[0-2]|c4-tiffinbox) ;; *) UNCHECKED="$UNCHECKED $n" ;; esac
  done
  if [ -n "$UNCHECKED" ]; then printf '%snot covered by this script yet:%s%s\n' "$YLW" "$OFF" "$UNCHECKED"
  else printf 'not covered by this script yet: nothing — c4-tiffinbox and all 32 units of Course 4 are covered.\n'; fi
fi
T1=$(date +%s)
printf 'wall time %dm%02ds\n' $(( (T1-T0)/60 )) $(( (T1-T0)%60 ))
printf '%sPASS %d%s   %sFAIL %d%s   %sSKIP %d%s\n' "$GRN" "$PASS" "$OFF" "$RED" "$FAIL" "$OFF" "$YLW" "$SKIP" "$OFF"
if [ "$FAIL" -gt 0 ]; then
  printf 'failed:\n'; for l in "${FAILED_LABELS[@]}"; do printf '  - %s\n' "$l"; done
  exit 1
fi
if [ ${#UNITS[@]} -ne 0 ] && [ $((PASS+FAIL+SKIP)) -eq 0 ]; then
  printf '%sno checks ran for:%s %s\n' "$YLW" "$OFF" "${UNITS[*]}" >&2; exit 2
fi
printf 'all green.\n'
exit 0

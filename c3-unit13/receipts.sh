#!/bin/bash
# receipts.sh - regenerate every number and every failure message this unit puts on a slide.
#
# This unit's subject is the OUTPUT, so almost everything below is a captured message rather
# than a count - but every count beside one is derived by this same run (wc -l over the block
# above it, grep -c over the report above it), never typed.
#
#   ./receipts.sh            run every block
#   ./receipts.sh messages   run one block
#
# Three rules every receipts.sh in this section now follows:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE - appended to the .out file before it is
#      hashed, so the md5 on a slide covers the number on the slide.
#   2. EVERY MAVEN RUN RECORDS ITS EXIT CODE, printed beside the md5 (contract 8.5). The
#      `unsafe` block needs both exit codes, because "0 warnings" is also what a build that
#      died before a test ran would print.
#   3. A COUNT'S LABEL NAMES WHAT WAS COUNTED. "1 of 3 messages contain the list" used to
#      be a grep -c over LINES, so a message that printed the roster on two lines would
#      have read as "2 of 3". It now tests each message once.
#
# Isolated: -Dmaven.repo.local="$PWD/.m2-demo" (quoted - this tree's path can contain a space).

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")

# how many lines of a message this unit keeps on screen before the counted elision starts.
# It appears ONCE, here; every "N lines elided" below is arithmetic over it and over the
# message's own real length.
KEEP=9

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }

hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block()   { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }
clean() { sed -E -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                 -e "s#${PWD}/#<project>/#g" \
                 -e 's#[^ ]*/c3-unit13/#<project>/#g' \
                 -e 's#/Users/[^/]*/#<home>/#g'; }

# Pull one failure's whole message out of a Results: block: from its own [ERROR]   Class.method
# marker up to the next marker. Deterministic whatever order the classes ran in.
msg() { awk -v k="$1" '
  $0 ~ "^\\[ERROR\\]   " k ":" {p=1; print; next}
  p && /^\[ERROR\]   [A-Za-z]/ {p=0}
  p && /^\[INFO\]/ {p=0}
  p {print}' "$2"; }

BREAK_OUT=.r-break-raw.out
BREAK_RC=0
run_break_once() {
  [ -s "$BREAK_OUT" ] && return 0
  ( cd breaks/three-messages && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../../.r-three.raw 2>&1 ); BREAK_RC=$?
  [ "$BREAK_RC" -ne 0 ] || die "breaks/three-messages passed - there are no failure messages to compare"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-three.raw | clean > "$BREAK_OUT"
  [ -s "$BREAK_OUT" ] || die "no Results: block - the break did not compile"
  rm -f .r-three.raw
}

run_messages() {
  block "messages - one bug, three assertions, three amounts of help"
  run_break_once
  {
    echo '--- 1. Java assert keyword ---'
    msg 'ThreeMessagesTest.bareAssert' "$BREAK_OUT"
    echo '--- 2. JUnit assertTrue ---'
    msg 'ThreeMessagesTest.junitAssertTrue' "$BREAK_OUT"
    echo '--- 3. AssertJ ---'
    msg 'ThreeMessagesTest.assertJChain' "$BREAK_OUT"
  } > .r-messages.out
  for k in bareAssert junitAssertTrue assertJChain; do
    msg "ThreeMessagesTest.$k" "$BREAK_OUT" | grep -q . \
      || die "no message captured for $k - the three-way comparison is incomplete"
  done
  # DERIVED: how much does each failure actually SAY? Strip the [ERROR] Class.method:NN
  # marker off the front of each message and count what is left, in characters.
  for k in bareAssert junitAssertTrue assertJChain; do
    printf '%-16s %s characters of message\n' "$k" \
      "$(msg "ThreeMessagesTest.$k" "$BREAK_OUT" \
          | sed -E '1s/^\[ERROR\]   [A-Za-z]+\.[a-zA-Z]+:[0-9]+ ?//' \
          | tr -d '\n' | wc -c | tr -d ' ')" >> .r-messages.out
  done
  # DERIVED: and how many of the three MESSAGES name the roster the code actually had?
  # Each message is tested once, as a whole, so a roster printed across two lines counts once.
  named=0
  for k in bareAssert junitAssertTrue assertJChain; do
    msg "ThreeMessagesTest.$k" "$BREAK_OUT" | tr '\n' ' ' \
      | grep -q '"Ravi", "Meera", "Sunil"' && named=$((named+1))
  done
  printf '%s of 3 messages contain the actual list\n' "$named" >> .r-messages.out
  cat .r-messages.out
  printf 'md5 %s  exit %s\n' "$(hash_of .r-messages.out)" "$BREAK_RC"
}

run_source() {
  block "source - the shipped-source panel's line numbers, and its two counted elisions"
  SRC=src/test/java/com/tiffinbox/RosterAssertionsTest.java
  [ -f "$SRC" ] || die "$SRC is not here - the source panel quotes a file this project does not have"
  # The three groups of that file slide 3 keeps on screen, in the file's own numbering. The
  # boundaries appear ONCE, here; both "N lines elided" counts are wc -l over the gaps between
  # them, so a wrong count on that panel cannot agree with this hash.
  G1_END=35; G2_START=38; G2_END=44; G3_START=68
  # The panel prints those numbers in its gutter. If they are no longer these lines, every
  # number on the panel is wrong, so the anchors fail loudly rather than counting the wrong gap.
  anchor() { [ "$(sed -n "${1}p" "$SRC")" = "$2" ] \
    || die "line $1 of $SRC is not \"$2\" any more - the source panel's gutter numbers are stale"; }
  anchor "$G1_END"   '    }'
  anchor "$G2_START" '    @Test'
  anchor "$G2_END"   '    }'
  anchor "$G3_START" '    @Test'
  gap() { sed -n "$(( $1 + 1 )),$(( $2 - 1 ))p" "$SRC"; }
  {
    printf -- '--- elided between line %s and line %s ---\n' "$G1_END" "$G2_START"
    gap "$G1_END" "$G2_START"
    printf -- '--- elided between line %s and line %s ---\n' "$G2_END" "$G3_START"
    gap "$G2_END" "$G3_START"
  } > .r-source.out
  [ -s .r-source.out ] || die "neither gap had any content - the panel elides nothing"
  # DERIVED: each count is wc -l over the very lines printed above it, inside the bytes the
  # md5 covers, and the file's own length is beside them.
  printf 'elided after line %s: %s lines; elided after line %s: %s lines; the file is %s lines\n' \
    "$G1_END" "$(gap "$G1_END" "$G2_START" | wc -l | tr -d ' ')" \
    "$G2_END" "$(gap "$G2_END" "$G3_START" | wc -l | tr -d ' ')" \
    "$(wc -l < "$SRC" | tr -d ' ')" >> .r-source.out
  cat .r-source.out
  printf 'md5 %s  no build - this block reads the shipped source\n' "$(hash_of .r-source.out)"
}

run_records() {
  block "records - assertEquals is not useless; it just cannot name the field"
  run_break_once
  # the recursive message, trimmed to KEEP lines of content after its own [ERROR] marker
  msg 'RecordMessagesTest.assertJRecursive' "$BREAK_OUT" > .r-recursive.raw
  total=$(( $(wc -l < .r-recursive.raw | tr -d ' ') - 1 ))
  [ "$total" -gt 0 ] || die "the recursive comparison produced no message at all"
  {
    echo '--- JUnit assertEquals on two records ---'
    msg 'RecordMessagesTest.junitAssertEqualsOnRecords' "$BREAK_OUT"
    echo '--- AssertJ usingRecursiveComparison, the difference it found ---'
    sed -n "1,$((KEEP + 1))p" .r-recursive.raw
  } > .r-records.out
  # DERIVED: the trim above is a counted elision (contract 9), and BOTH halves of the count
  # come from this run - the message's real length, and the number of lines actually kept.
  shown=$(( $(sed -n "1,$((KEEP + 1))p" .r-recursive.raw | wc -l | tr -d ' ') - 1 ))
  printf '... %s configuration lines elided ...\n' "$(( total - shown ))" >> .r-records.out
  printf 'the recursive message runs to %s lines; the %s above are the ones about your data\n' \
    "$total" "$shown" >> .r-records.out
  cat .r-records.out
  rm -f .r-recursive.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-records.out)" "$BREAK_RC"
}

run_softly() {
  block "softly - a chain stops at the first; SoftAssertions reports every one"
  run_break_once
  {
    echo '--- three assertThat statements in a row ---'
    msg 'SoftlyTest.hardChainStopsAtTheFirst' "$BREAK_OUT"
    echo '--- the same three, softly ---'
    msg 'SoftlyTest.softlyCollectsThemAll' "$BREAK_OUT"
  } > .r-softly.out
  [ -s .r-softly.out ] || die "neither SoftlyTest message was captured"
  # DERIVED: count the "expected:" lines each style produced, out of this same capture,
  # and the length of each message, so a panel that trims one can say what it cut.
  printf 'the chain reported %s problem(s) in %s line(s); softly reported %s in %s line(s)\n' \
    "$(msg 'SoftlyTest.hardChainStopsAtTheFirst' "$BREAK_OUT" | grep -c 'expected:')" \
    "$(msg 'SoftlyTest.hardChainStopsAtTheFirst' "$BREAK_OUT" | wc -l | tr -d ' ')" \
    "$(msg 'SoftlyTest.softlyCollectsThemAll' "$BREAK_OUT" | grep -c 'expected:')" \
    "$(msg 'SoftlyTest.softlyCollectsThemAll' "$BREAK_OUT" | wc -l | tr -d ' ')" >> .r-softly.out
  cat .r-softly.out
  printf 'md5 %s  exit %s\n' "$(hash_of .r-softly.out)" "$BREAK_RC"
}

run_unsafe() {
  block "unsafe - what SoftAssertions costs you on JDK 25, and the one flag that answers it"
  # The agent path is absolute and moves with the clone; mask it but KEEP the version, which
  # is the evidence.
  "${MVN[@]}" test > .r-u1.raw 2>&1; rc1=$?
  [ "$rc1" -eq 0 ] || die "mvn test exited $rc1 - a warning count over a build that did not run is not a receipt"
  grep '^WARNING:' .r-u1.raw \
    | sed -E 's|\(file:[^)]*/([^/)]*\.jar)\)|(<repo>/\1)|' | clean > .r-unsafe.out
  [ -s .r-unsafe.out ] || die "no WARNING: lines at all - the before state of this beat is gone"
  "${MVN[@]}" test -DargLine='--sun-misc-unsafe-memory-access=allow' > .r-u2.raw 2>&1; rc2=$?
  # The flag must SILENCE the warnings, not kill the build: assert the same tests still ran.
  [ "$rc2" -eq 0 ] || die "the run with --sun-misc-unsafe-memory-access=allow exited $rc2"
  ran1=$(grep -E '^\[INFO\] Tests run:' .r-u1.raw | tail -1 | sed -E 's/.*Tests run: ([0-9]+).*/\1/')
  ran2=$(grep -E '^\[INFO\] Tests run:' .r-u2.raw | tail -1 | sed -E 's/.*Tests run: ([0-9]+).*/\1/')
  [ -n "$ran1" ] && [ -n "$ran2" ] && [ "$ran1" = "$ran2" ] \
    || die "the two runs did not execute the same number of tests ($ran1 vs $ran2)"
  with_flag=$(grep -c '^WARNING:' .r-u2.raw || true)
  # DERIVED both ways, from two runs of this same project, each with its test count beside it.
  printf 'without the flag: %s WARNING lines; with --sun-misc-unsafe-memory-access=allow: %s; %s tests ran either way\n' \
    "$(grep -c '^WARNING:' .r-unsafe.out)" "$with_flag" "$ran1" >> .r-unsafe.out
  # DERIVED, and it must be able to DISAGREE: the old form of this line printed the words
  # "is not in this pom" unconditionally, so declaring byte-buddy in pom.xml left both the
  # line and this block's md5 unchanged. Count the declaration instead, the way run_version
  # already does, and the number moves the hash the moment the pom does.
  coord=$("${MVN[@]}" dependency:tree 2>&1 | grep -oE 'net\.bytebuddy:byte-buddy:jar:[0-9.]+' | head -1)
  [ -n "$coord" ] || die "the tree named no byte-buddy - the jar in WARNING line 2 is unaccounted for"
  printf 'and the jar named in line 2 appears %s time(s) in this pom: %s\n' \
    "$(grep -c '<artifactId>byte-buddy</artifactId>' pom.xml)" "$coord" >> .r-unsafe.out
  cat .r-unsafe.out
  rm -f .r-u1.raw .r-u2.raw
  printf 'md5 %s  exit %s then %s\n' "$(hash_of .r-unsafe.out)" "$rc1" "$rc2"
}

run_version() {
  block "version - what the pin resolved to, and what came with it"
  "${MVN[@]}" dependency:tree > .r-ver.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "dependency:tree exited $rc"
  grep -oE '(org\.assertj|net\.bytebuddy):[a-z-]+:jar:[0-9][^:]*' .r-ver.raw | sort -u > .r-version.out
  [ -s .r-version.out ] || die "the tree named neither assertj nor byte-buddy"
  # DERIVED: this pom names ONE assertj version and zero bytebuddy versions.
  printf 'this pin puts %s artifact(s) on the test classpath; pom.xml names %s of them\n' \
    "$(wc -l < .r-version.out | tr -d ' ')" \
    "$(grep -cE '<artifactId>(assertj-core|byte-buddy)</artifactId>' pom.xml)" >> .r-version.out
  cat .r-version.out
  rm -f .r-ver.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-version.out)" "$rc"
}

run_release() {
  block "release - why this pom pins 3.27.7 and not the version Central labels <release>"
  META=central/assertj-core-maven-metadata.xml
  LIST=central/assertj-core-listing.html
  # NO NETWORK. Both files are the authoring-time version sweep (contract 1a), fetched from
  # repo1.maven.org on 2026-09-15 and shipped verbatim in central/. A metadata curl is NOT in
  # this unit's tier, so the receipt reads the bytes that were quoted instead of re-fetching.
  [ -f "$META" ] || die "$META is missing - the <release> claim has no evidence to stand on"
  [ -f "$LIST" ] || die "$LIST is missing - the two publication dates have no evidence to stand on"
  grep -o '<version>[^<]*</version>' "$META" | sed -E 's|</?version>||g' > .r-vlist.raw
  n=$(wc -l < .r-vlist.raw | tr -d ' ')
  [ "$n" -gt 1 ] || die "the metadata carries no version list - there is nothing to read instead of the field"
  rel=$(grep -o '<release>[^<]*</release>' "$META" | sed -E 's|</?release>||g')
  last=$(tail -1 .r-vlist.raw)
  [ -n "$rel" ] || die "the metadata carries no <release> field"
  # DERIVED: the newest GA is the last entry carrying NO qualifier - read off the LIST, which is
  # the rule (contract 3a). The pin is then checked against it, so a stale pom fails loudly.
  ga=$(grep -E '^[0-9]+(\.[0-9]+)*$' .r-vlist.raw | tail -1)
  pinned=$(sed -n '\|<artifactId>assertj-core</artifactId>|,\|</dependency>|p' pom.xml \
             | grep -o '<version>[^<]*</version>' | sed -E 's|</?version>||g' | head -1)
  [ "$pinned" = "$ga" ] || die "pom.xml pins $pinned but the newest GA in the list is $ga"
  [ "$rel" != "$ga" ] || die "<release> and the newest GA are the same version - this unit's whole trap is gone"
  # DERIVED: the first place the file disagrees with a plain text sort. Found, never typed.
  pair=$(awk 'NR>1 && (prev "") > ($0 "") { print "entry " NR-1 " is " prev " and entry " NR " is " $0; exit } { prev=$0 }' .r-vlist.raw)
  [ -n "$pair" ] || die "the version list IS in text order - the slide's reason for reading the list is wrong"
  LC_ALL=C sort .r-vlist.raw | cmp -s - .r-vlist.raw \
    && die "LC_ALL=C sort reproduces the file exactly - the list is text-sorted after all"
  # DERIVED: and it is not in publication order either. Both dates come out of the listing.
  pubdate() { grep -oE "title=\"$1/\">[^<]*</a>[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}" "$LIST" \
                | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tail -1; }
  d_rel=$(pubdate "$rel"); d_ga=$(pubdate "$ga")
  [ -n "$d_rel" ] && [ -n "$d_ga" ] || die "the listing has no publication date for $rel or $ga"
  gap=$(awk -v a="$d_rel" -v b="$d_ga" 'BEGIN{split(a,x,"-");split(b,y,"-");
        m=(y[1]-x[1])*12+(y[2]-x[2]); if (y[3]+0 < x[3]+0) m--; print m}')
  [ "$gap" -gt 0 ] || die "$rel is not older than $ga - the ten-months sentence is stale"
  # DERIVED: what the ordering actually is. Every 3.x entry sits before every 4.x entry, so the
  # major number decides it first - which is why a 4.x milestone outranks the 3.x GA.
  last3=$(grep -n '^3\.' .r-vlist.raw | tail -1 | cut -d: -f1)
  first4=$(grep -n '^4\.' .r-vlist.raw | head -1 | cut -d: -f1)
  [ -n "$last3" ] && [ -n "$first4" ] && [ "$last3" -lt "$first4" ] \
    || die "the 3.x and 4.x entries are interleaved - the major number does not decide the order"
  {
    printf -- '--- what the <release> field actually is ---\n'
    printf 'the list holds %s versions; <release> is %s and the last entry of the list is %s\n' "$n" "$rel" "$last"
    printf -- '--- what the order is not, and what it is ---\n'
    printf 'not text order: %s, and LC_ALL=C sort of the list does not reproduce the file\n' "$pair"
    printf 'not publication order: %s was published %s and %s on %s, %s months later\n' \
      "$rel" "$d_rel" "$ga" "$d_ga" "$gap"
    printf 'it is version order, major first: the last 3.x entry is at %s and the first 4.x at %s\n' "$last3" "$first4"
    printf -- '--- so read the list, never the field ---\n'
    printf 'newest GA in the list: %s; pom.xml pins: %s\n' "$ga" "$pinned"
  } > .r-release.out
  cat .r-release.out
  rm -f .r-vlist.raw
  printf 'md5 %s  no build - this block reads central/, fetched 2026-09-15 and shipped verbatim\n' "$(hash_of .r-release.out)"
}

run_solution() {
  block "solution - the exercise, all three states, actually run"
  ( cd exercise && rm -rf target \
      && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-s1.raw 2>&1 ); rc1=$?
  [ "$rc1" -ne 0 ] || die "the exercise start state passed - it is supposed to fail on a typo"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-s1.raw | clean > .r-solution.out
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  # step 1: the AssertJ chain, typo still in place
  sed -e 's|import static org.junit.jupiter.api.Assertions.assertTrue;|import static org.assertj.core.api.Assertions.assertThat;|' \
      -e 's|assertTrue(roster().stream().anyMatch(c -> c.name().equals("Suneel")));|assertThat(roster()).extracting(Customer::name).contains("Suneel");|' \
      exercise/src/test/java/com/tiffinbox/RosterTest.java > .sol/src/test/java/com/tiffinbox/RosterTest.java
  grep -q 'assertThat(roster())' .sol/src/test/java/com/tiffinbox/RosterTest.java \
    || die "the step-1 sed did not apply - the middle state would be the same as the first"
  ( cd .sol && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-s2.raw 2>&1 ); rc2=$?
  [ "$rc2" -ne 0 ] || die "step 1 passed - the typo is supposed to still be there"
  sed -n '/^\[INFO\] Results:/,/^\[ERROR\] Tests run:/p' .r-s2.raw | clean >> .r-solution.out
  # step 2: the shipped answer
  cp exercise/solution/RosterTest.java .sol/src/test/java/com/tiffinbox/RosterTest.java
  ( cd .sol && rm -rf target && mvn -B -Dmaven.repo.local="$REPO" test > ../.r-s3.raw 2>&1 ); rc3=$?
  [ "$rc3" -eq 0 ] || die "the shipped answer exited $rc3"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-s3.raw | clean >> .r-solution.out
  [ -s .r-solution.out ] || die "none of the three states produced a report"
  # DERIVED: what each of the three states reported, read off the three reports above
  states=$(grep -E 'Tests run: [0-9]+, Failures: [0-9]+' .r-solution.out | grep -v -- ' -- in ' \
    | sed -E 's|.*Tests run: ([0-9]+), Failures: ([0-9]+).*|\1 test/\2 failure|' | tr '\n' ' ')
  printf 'the three states in order: %s\n' "$states" >> .r-solution.out
  cat .r-solution.out
  rm -rf .sol .r-s1.raw .r-s2.raw .r-s3.raw
  printf 'md5 %s  exit %s then %s then %s\n' "$(hash_of .r-solution.out)" "$rc1" "$rc2" "$rc3"
}

run_offline() {
  block "offline - contract 1c, after one warm build"
  "${MVN[@]}" -o test > .r-off.raw 2>&1; rc=$?
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc - this unit does not build offline"
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-off.raw | clean > .r-offline.out
  [ -s .r-offline.out ] || die "the offline run printed no Tests run: line"
  cat .r-offline.out
  rm -f .r-off.raw
  printf 'md5 %s  exit %s\n' "$(hash_of .r-offline.out)" "$rc"
}

rm -f "$BREAK_OUT"
ALL=(messages source records softly unsafe version release solution offline)
TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")
for t in "${TARGETS[@]}"; do "run_$t"; done
rm -f "$BREAK_OUT"

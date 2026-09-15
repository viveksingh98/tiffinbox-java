#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh levels     run one block
#
# Three rules this file inherits from the testing section, and they are why it looks like this:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE. Every count is appended to the .out file
#      before that file is hashed, so the md5 on a slide covers the number on the slide.
#      A wrong derived number moves the hash; that is the whole point of taking one.
#   2. A BLOCK THAT CANNOT MEASURE MUST NOT PRINT. Every run records its exit code, every
#      derived value is checked, and a block with nothing to measure calls die() instead
#      of printing a confident zero.
#   3. EVERY BLOCK MEASURES ITS OWN RUN. No block reads back something an earlier run left
#      on disk, and no block prints an exit code it typed rather than took from $?.
#
# And one that is this unit's own: A LOG LINE CARRIES A CLOCK. Every capture here is put
# through mask_time() before it is hashed, and every slide that quotes a hash shows that
# filter beside it. An unmasked log line cannot be byte-identical twice and must never be
# pinned to a slide.

set -u
set -o pipefail
cd "$(dirname "$0")" || exit 1

export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"

REPO="$PWD/.m2-demo"
MVN=(mvn -B -Dmaven.repo.local="$REPO")

die() { printf '\nRECEIPT FAILED (%s): %s\n' "${BLOCK:-?}" "$1" >&2; exit 1; }

hash_of() { md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1; }
block() { BLOCK="${1%% *}"; printf '\n=== %s ===\n' "$1"; }

# Logback's default pattern stamps HH:mm:ss.SSS on every line and slf4j-simple stamps
# nothing. Mask the clock, mask this clone's path, and keep every version number - the
# versions are the evidence.
mask_time() { sed -E -e 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /' \
                     -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                     -e "s#${PWD}/#<project>/#g" \
                     -e 's#[^ ]*/c3-unit19/#<project>/#g' \
                     -e 's#/Users/[^/]*/#<home>/#g'; }

# The kitchen's own output, and nothing else: Maven's [INFO]/[WARNING] scaffolding is not
# the lesson and its goal lines move with the plugin versions.
kitchen_lines() { grep -E 'tiffinbox|^placing |^orders cooked|^kitchen value|^SLF4J' ; }

# A count's label must name what it counted (the testing section's row-11 defect). A
# javadoc sentence mentioning println is not a call site, so every source count below
# drops comment lines first.
code_only() { grep -vE '^[[:space:]]*(\*|//|/\*)' "$1"; }

# Run the forked JVM once. $1 = directory, rest = extra -D flags. Writes .r-run.raw.
run_kitchen() {   # $1 = dir, $@ = extra args
  local dir="$1"; shift
  ( cd "$dir" && "${MVN[@]}" -q "$@" compile exec:exec ) > .r-run.raw 2>&1
  return $?
}

# ---------------------------------------------------------------- bridge ----
# Three classpaths, ONE source tree. The identity is hashed, not asserted.
run_bridge() {
  block "bridge - the same source, three bindings"
  local here swap none
  here=$(cd src/main/java              && find . -name '*.java' | sort | xargs md5 -q | md5 -q)
  swap=$(cd swap/src/main/java         && find . -name '*.java' | sort | xargs md5 -q | md5 -q)
  none=$(cd breaks/no-binding/src/main/java && find . -name '*.java' | sort | xargs md5 -q | md5 -q)
  [ -n "$here" ] && [ -n "$swap" ] && [ -n "$none" ] || die "one of the three source trees hashed to nothing"
  [ "$here" = "$swap" ] && [ "$here" = "$none" ] \
    || die "the three projects do not share a source tree: $here / $swap / $none"

  run_kitchen .                 ; local rc1=$?
  cp .r-run.raw .r-b1.raw
  run_kitchen swap              ; local rc2=$?
  cp .r-run.raw .r-b2.raw
  run_kitchen breaks/no-binding ; local rc3=$?
  cp .r-run.raw .r-b3.raw

  { printf 'logback-classic 1.6.3\n'; kitchen_lines < .r-b1.raw | mask_time
    printf 'slf4j-simple 2.0.19\n';   kitchen_lines < .r-b2.raw | mask_time
    printf 'no binding at all\n';     kitchen_lines < .r-b3.raw | mask_time
  } > .r-bridge.out

  local n1 n2 n3
  n1=$(kitchen_lines < .r-b1.raw | grep -c 'orders cooked')
  n2=$(kitchen_lines < .r-b2.raw | grep -c 'orders cooked')
  n3=$(kitchen_lines < .r-b3.raw | grep -c 'orders cooked')
  # The whole lesson: state 3 must be SILENT and still succeed. If it crashed, there is
  # no lesson here, only a broken build.
  [ "$rc3" -eq 0 ] || die "the no-binding run exited $rc3 - the point is that it does NOT fail"
  [ "$n3" -eq 0 ]  || die "the no-binding run printed the kitchen line $n3 time(s) - something bound"
  [ "$n1" -eq 1 ] && [ "$n2" -eq 1 ] || die "a bound run did not print 'orders cooked' exactly once ($n1/$n2)"

  { printf 'the three src/main/java trees hash to: %s (identical: yes)\n' "$here"
    printf "'orders cooked' lines: logback %d, slf4j-simple %d, no binding %d\n" "$n1" "$n2" "$n3"
    printf 'exit codes: logback %d, slf4j-simple %d, no binding %d\n' "$rc1" "$rc2" "$rc3"
  } >> .r-bridge.out

  cat .r-bridge.out
  printf 'md5 %s  exit %d then %d then %d\n' "$(hash_of .r-bridge.out)" "$rc1" "$rc2" "$rc3"
}

# ---------------------------------------------------------------- levels ----
# One word in one XML file, two outputs, and the CLASSES DID NOT MOVE. The third hash is
# the one that makes this a proof rather than a demonstration.
run_levels() {
  block "levels - INFO and DEBUG out of the same .class files"
  "${MVN[@]}" -q clean compile > .r-lv0.raw 2>&1; local rcc=$?
  [ "$rcc" -eq 0 ] || die "clean compile exited $rcc"
  local before after
  before=$(find target/classes -name '*.class' | sort | xargs md5 -q | md5 -q)
  [ -n "$before" ] || die "target/classes holds no .class files"

  "${MVN[@]}" -q exec:exec > .r-lv1.raw 2>&1; local rc1=$?
  "${MVN[@]}" -q -Dlogback.config=logback-debug.xml exec:exec > .r-lv2.raw 2>&1; local rc2=$?
  after=$(find target/classes -name '*.class' | sort | xargs md5 -q | md5 -q)
  [ "$rc1" -eq 0 ] && [ "$rc2" -eq 0 ] || die "a level run failed: $rc1 / $rc2"

  { printf 'root level INFO   (src/main/resources/logback.xml)\n'; kitchen_lines < .r-lv1.raw | mask_time
    printf 'root level DEBUG  (-Dlogback.configurationFile=logback-debug.xml)\n'; kitchen_lines < .r-lv2.raw | mask_time
  } > .r-levels.out

  local i1 i2 d1 d2
  i1=$(kitchen_lines < .r-lv1.raw | grep -c ' INFO ');  d1=$(kitchen_lines < .r-lv1.raw | grep -c ' DEBUG ')
  i2=$(kitchen_lines < .r-lv2.raw | grep -c ' INFO ');  d2=$(kitchen_lines < .r-lv2.raw | grep -c ' DEBUG ')
  [ "$d1" -eq 0 ] || die "the INFO run printed $d1 DEBUG line(s) - the level did nothing"
  [ "$d2" -gt 0 ] || die "the DEBUG run printed no DEBUG line - the -D never reached the fork"
  [ "$before" = "$after" ] || die "target/classes changed between the two runs - something recompiled"

  # the one word that differs between the two config files, counted rather than claimed
  local diffwords
  diffwords=$(diff <(tr -s ' \n' '\n' < src/main/resources/logback.xml | grep -E 'level=') \
                   <(tr -s ' \n' '\n' < logback-debug.xml              | grep -E 'level=') \
              | grep -c '^[<>]')
  { printf 'INFO run:  %d INFO line(s), %d DEBUG line(s)\n' "$i1" "$d1"
    printf 'DEBUG run: %d INFO line(s), %d DEBUG line(s)\n' "$i2" "$d2"
    printf 'level= attributes that differ between the two config files: %d\n' "$diffwords"
    printf 'md5 of target/classes before the two runs: %s\n' "$before"
    printf 'md5 of target/classes after  the two runs: %s\n' "$after"
    printf 'the classes were recompiled between the two outputs: no\n'
  } >> .r-levels.out

  cat .r-levels.out
  printf 'md5 %s  exit %d then %d\n' "$(hash_of .r-levels.out)" "$rc1" "$rc2"
}

# ------------------------------------------------------------------ tree ----
# Never assert a transitive version. Print it. (STYLE-CONTRACT 3b.)
#
# -Dverbose and NO -Dincludes, deliberately: -Dincludes collapses the losing node, and the
# losing node is the lesson. The grep below is the named filter, and the two counts under
# the panel say how many rows it kept out of how many the tree printed.
run_tree() {
  block "tree - which slf4j-api did you actually get"
  "${MVN[@]}" dependency:tree -Dverbose > .r-t1.raw 2>&1; local rc1=$?
  ( cd swap && "${MVN[@]}" dependency:tree -Dverbose ) > .r-t2.raw 2>&1; local rc2=$?
  [ "$rc1" -eq 0 ] && [ "$rc2" -eq 0 ] || die "a dependency:tree run failed: $rc1 / $rc2"

  # THE ROW FILTER, AND WHY IT IS NOT TRUSTED. Maven indents the descendants of a LAST
  # child with three spaces and no pipe, so a filter anchored on '+- ', '\- ' or '|  '
  # never sees them. It cost this block a row: it reported 29 over a tree that printed 30,
  # and in swap/ the row it could not see was an slf4j-api node - dropped underneath an
  # elision line that said it had cut "everything that is not logback or slf4j". An
  # elision count that is wrong is worse than no elision count, so the filter below takes
  # any indent, and printed_of() counts the goal's own output independently to check it.
  rows_of()  { grep -E '^\[INFO\] ([+\\| ]+[-\\+] |com\.tiffinbox:)' "$1" | sed 's/^\[INFO\] //'; }
  keep_of()  { rows_of "$1" | grep -E 'logback|slf4j|^com\.tiffinbox:'; }
  printed_of() { awk '/^\[INFO\] --- dependency:.*:tree \(default-cli\)/{on=1;next}
                      on && /^\[INFO\] -{10,}/{on=0}
                      on && /^\[INFO\] ./ && !/Download(ing|ed) /{n++}
                      END{print n+0}' "$1"; }

  local all1 kept1 all2 kept2 printed1 printed2
  all1=$(rows_of .r-t1.raw | grep -c .);  kept1=$(keep_of .r-t1.raw | grep -c .)
  all2=$(rows_of .r-t2.raw | grep -c .);  kept2=$(keep_of .r-t2.raw | grep -c .)
  [ "$kept1" -gt 0 ] && [ "$kept2" -gt 0 ] || die "the grep kept no rows from one of the trees"
  printed1=$(printed_of .r-t1.raw); printed2=$(printed_of .r-t2.raw)
  [ "$all1" -eq "$printed1" ] && [ "$all2" -eq "$printed2" ] \
    || die "the row filter saw $all1 and $all2 rows where dependency:tree printed $printed1 and $printed2 - a row the filter cannot see is a row the elision count below would lie about"

  { printf 'this project - logback-classic declared, slf4j-api NOT declared\n'
    keep_of .r-t1.raw
    printf '... %d of %d tree rows elided: everything that is not logback or slf4j ...\n' "$(( all1 - kept1 ))" "$all1"
    printf 'swap/ - slf4j-simple declared, slf4j-api NOT declared\n'
    keep_of .r-t2.raw
    printf '... %d of %d tree rows elided: everything that is not logback or slf4j ...\n' "$(( all2 - kept2 ))" "$all2"
  } > .r-tree.out

  local v1 v2 omitted declared
  v1=$(grep -oE '^\[INFO\] \|  \\- org\.slf4j:slf4j-api:jar:[0-9][^:]*' .r-t1.raw | head -1 | sed 's/.*://')
  v2=$(grep -oE '^\[INFO\] \|  \\- org\.slf4j:slf4j-api:jar:[0-9][^:]*' .r-t2.raw | head -1 | sed 's/.*://')
  omitted=$(grep -oE '\(org\.slf4j:slf4j-api:jar:[0-9][^:]*' .r-t1.raw | head -1 | sed 's/.*://')
  declared=$(grep -c '<artifactId>slf4j-api</artifactId>' pom.xml)
  [ -n "$v1" ] && [ -n "$v2" ] || die "no resolved slf4j-api node in one of the two trees"
  [ -n "$omitted" ] || die "no omitted slf4j-api node - the two paths no longer disagree, so there is no lesson here"
  [ "$declared" -eq 0 ] || die "pom.xml declares slf4j-api $declared time(s); the lesson says it does not"
  [ "$omitted" != "$v1" ] || die "the omitted version equals the resolved one; re-read the tree"

  { printf 'slf4j-api on this classpath ......... %s\n' "$v1"
    printf 'slf4j-api the OTHER path offered ... %s, omitted for conflict\n' "$omitted"
    printf 'slf4j-api in swap/ ................. %s\n' "$v2"
    printf 'times slf4j-api is declared in pom.xml: %d\n' "$declared"
    printf 'the version that won is the newer one: %s\n' "$( [ "$v1" = "$( printf '%s\n%s\n' "$v1" "$omitted" | sort -V | tail -1 )" ] && echo yes || echo no )"
  } >> .r-tree.out

  cat .r-tree.out
  printf 'md5 %s  exit %d then %d\n' "$(hash_of .r-tree.out)" "$rc1" "$rc2"
}

# --------------------------------------------------------------- println ----
# The break: four things a println cannot be given later. Each one is a COUNT.
run_println() {
  block "println - what the same kitchen loses"
  run_kitchen breaks/println-only                                ; local rp1=$?
  cp .r-run.raw .r-p1.raw
  ( cd breaks/println-only && "${MVN[@]}" -q -Dlogback.config=logback-debug.xml exec:exec ) > .r-p2.raw 2>&1
  local rp2=$?
  [ "$rp1" -eq 0 ] && [ "$rp2" -eq 0 ] || die "a println run failed: $rp1 / $rp2"

  { printf 'println, default run\n';                         kitchen_lines < .r-p1.raw | mask_time
    printf 'println, the SAME switch that moved Logback\n';   kitchen_lines < .r-p2.raw | mask_time
  } > .r-println.out

  local a b lvl src lines
  a=$(kitchen_lines < .r-p1.raw | grep -c .)
  b=$(kitchen_lines < .r-p2.raw | grep -c .)
  lvl=$(kitchen_lines < .r-p1.raw | grep -cE ' (TRACE|DEBUG|INFO|WARN|ERROR) ')
  src=$(kitchen_lines < .r-p1.raw | grep -c 'tiffinbox')
  [ "$a" -gt 0 ] || die "the println run printed nothing at all"
  [ "$a" -eq "$b" ] || die "the switch moved the println count $a -> $b; it is not supposed to be able to"
  # the same two files, one call style: count the call sites rather than describing them
  local pl lg
  pl=$(code_only breaks/println-only/src/main/java/com/tiffinbox/kitchen/KitchenLog.java | grep -c 'System.out.println')
  lg=$(code_only              src/main/java/com/tiffinbox/kitchen/KitchenLog.java | grep -c 'LOG.log(')
  [ "$pl" -eq "$lg" ] || die "the two KitchenLog files have $pl println(s) against $lg LOG.log call(s) - not the same program"

  { printf 'lines printed: default %d, with -Dlogback.configurationFile=logback-debug.xml %d\n' "$a" "$b"
    printf 'of those %d lines, %d carry a level word and %d name a source\n' "$a" "$lvl" "$src"
    printf 'call sites: %d System.out.println here against %d LOG.log(...) in this unit\n' "$pl" "$lg"
    printf 'a switch that moved the logging output moved the println output by: %d line(s)\n' "$(( b - a ))"
  } >> .r-println.out

  cat .r-println.out
  printf 'md5 %s  exit %d then %d\n' "$(hash_of .r-println.out)" "$rp1" "$rp2"
}

# ------------------------------------------------------------- nobinding ----
run_nobinding() {
  block "nobinding - the warning SLF4J prints, verbatim"
  run_kitchen breaks/no-binding; local rc=$?
  [ "$rc" -eq 0 ] || die "the no-binding run exited $rc - the lesson is that it does not fail"
  grep -E '^SLF4J' .r-run.raw | mask_time > .r-nobinding.out
  local w k
  w=$(grep -cE '^SLF4J' .r-run.raw)
  k=$(grep -cE '^[0-9]{2}:[0-9]{2}|tiffinbox - ' .r-run.raw)
  [ "$w" -eq 3 ] || die "SLF4J printed $w warning line(s), not 3 - the message has changed, re-read it"
  [ "$k" -eq 0 ] || die "$k kitchen line(s) reached the console with no binding"
  { printf 'SLF4J warning lines: %d\n' "$w"
    printf 'kitchen log lines that reached the console: %d\n' "$k"
    printf 'the process exit code: %d\n' "$rc"
  } >> .r-nobinding.out
  cat .r-nobinding.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-nobinding.out)" "$rc"
}

# ------------------------------------------------------------------ cost ----
# What a switched-off DEBUG call costs, COUNTED (contract 2d).
run_cost() {
  block "cost - a switched-off DEBUG call, counted not timed"
  "${MVN[@]}" test -Dtest=ArgumentCostTest > .r-c.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "ArgumentCostTest exited $rc"
  { grep -E 'cost \| ' .r-c.raw | mask_time
    grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-c.raw | mask_time
  } > .r-cost.out
  local calls ran reported concat param
  calls=$(code_only src/test/java/com/tiffinbox/ArgumentCostTest.java | grep -oE 'CALLS = [0-9_]+' | head -1 | tr -cd '0-9')
  ran=$(grep -oE '^\[INFO\] Tests run: [0-9]+' .r-c.raw | tail -1 | tr -cd '0-9')
  reported=$(grep -cE 'cost \| ' .r-c.raw)
  concat=$(grep -E 'cost \| concatenated'  .r-c.raw | grep -oE '[0-9]+ render' | tr -cd '0-9')
  param=$(grep -E 'cost \| parameterised .* DEBUG off' .r-c.raw | grep -oE '[0-9]+ render' | tr -cd '0-9')
  [ -n "$calls" ] && [ "$calls" -gt 0 ] || die "could not read CALLS out of ArgumentCostTest.java"
  [ "$ran" = "3" ] || die "$ran test(s) ran, not 3 - the three assertions are the receipt"
  [ "$reported" -eq 3 ] || die "$reported cost line(s) reached the log, not 3"
  [ "$concat" = "$calls" ] || die "the concatenated form rendered $concat time(s) against CALLS=$calls"
  [ "$param" = "0" ] || die "the parameterised form rendered $param time(s) with the level off"
  { printf 'CALLS, read out of the test source: %s\n' "$calls"
    printf 'renders with DEBUG off: concatenated %s, parameterised %s\n' "$concat" "$param"
    printf 'the ratio the placeholder bought you, on this run: %s to %s\n' "$concat" "$param"
    printf 'every number above is read back out of a line the test logged AFTER its own assertion\n'
  } >> .r-cost.out
  cat .r-cost.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-cost.out)" "$rc"
}

# --------------------------------------------------------------- release ----
# The <release> trap, derived from the two Central files in central/, with NO network.
run_release() {
  block "release - what Maven Central's <release> field actually names"
  local md dir
  md=central/slf4j-api-maven-metadata.xml
  dir=central/slf4j-api-directory-listing.html
  [ -f "$md" ] && [ -f "$dir" ] || die "central/ is missing - see central/README.md"

  local total rel last ga relpub gapub days months pinned
  total=$(grep -c '<version>' "$md")
  rel=$(grep -oE '<release>[^<]*' "$md" | sed 's/<release>//')
  last=$(grep -oE '<version>[^<]*</version>' "$md" | sed 's/<[^>]*>//g' | tail -1)
  ga=$(grep -oE '<version>[^<]*</version>' "$md" | sed 's/<[^>]*>//g' \
       | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
  [ "$total" -gt 0 ] && [ -n "$rel" ] && [ -n "$last" ] && [ -n "$ga" ] || die "could not parse $md"

  datefor() { sed 's/<[^>]*>/ /g' "$dir" | grep -E "(^| )$1/ " | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1; }
  relpub=$(datefor "$rel"); gapub=$(datefor "$ga")
  [ -n "$relpub" ] && [ -n "$gapub" ] || die "no publication date for $rel or $ga in the directory listing"
  # -u and an explicit 00:00:00, deliberately: BSD `date -j -f '%Y-%m-%d'` fills the
  # missing time from the CURRENT clock in LOCAL time, so a pair of dates that straddles a
  # daylight-saving change comes out one hour short and integer division loses a whole day.
  # Measured: the local form printed 975 for a gap that is 976 days.
  epoch() { date -j -u -f '%Y-%m-%d %H:%M:%S' "$1 00:00:00" +%s; }
  days=$(( ( $(epoch "$gapub") - $(epoch "$relpub") ) / 86400 ))
  months=$(( days / 30 ))
  pinned=$(grep -A1 '<artifactId>slf4j-jdk-platform-logging</artifactId>' pom.xml \
           | grep -oE '<version>[^<]*' | sed 's/<version>//' | head -1)
  [ -n "$pinned" ] || die "could not read the slf4j version this pom pins"

  # the three things that make the field neither "newest GA" nor "newest published"
  [ "$rel" = "$last" ] || die "<release> ($rel) is not the last entry of the list ($last) - re-read 3a"
  [ "$rel" != "$ga" ]  || die "<release> and the newest GA agree here; this artifact no longer shows the trap"
  [ "$days" -gt 0 ]    || die "the GA is not newer than the <release> entry; the trap has changed shape"

  { printf 'org.slf4j:slf4j-api, read from central/ with no network\n'
    printf '  versions in the list ............ %s\n' "$total"
    printf '  <release> field says ............ %s, published %s\n' "$rel" "$relpub"
    printf '  last entry of the version list .. %s  (the same string: yes)\n' "$last"
    printf '  newest GA ....................... %s, published %s\n' "$ga" "$gapub"
    printf '  the GA is NEWER than the field by %s days (%s months)\n' "$days" "$months"
    printf '  so the field is neither newest-GA nor newest-published\n'
    printf '  this pom pins .................. %s\n' "$pinned"
  } > .r-release.out
  cat .r-release.out
  printf 'md5 %s  (no build)\n' "$(hash_of .r-release.out)"
}

# -------------------------------------------------------------- solution ----
run_solution() {
  block "solution - the exercise answer, run"
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  # the STARTING state must really be silent, or the exercise has no beginning
  ( cd .sol && "${MVN[@]}" -q compile exec:exec ) > .r-s0.raw 2>&1; local rc0=$?
  local w0 k0
  w0=$(grep -cE '^SLF4J' .r-s0.raw); k0=$(grep -c 'tiffinbox - ' .r-s0.raw)
  [ "$rc0" -eq 0 ] || die "the untouched exercise exited $rc0"
  [ "$w0" -eq 3 ] || die "the untouched exercise printed $w0 SLF4J warning(s), not 3"
  [ "$k0" -eq 0 ] || die "the untouched exercise already logged $k0 line(s) - it is not a start state"

  cp exercise/solution/pom.xml .sol/pom.xml
  mkdir -p .sol/src/main/resources && cp exercise/solution/logback.xml .sol/src/main/resources/logback.xml
  ( cd .sol && "${MVN[@]}" -q compile exec:exec ) > .r-s1.raw 2>&1; local rc1=$?
  [ "$rc1" -eq 0 ] || die "the answer exited $rc1"

  kitchen_lines < .r-s1.raw | mask_time > .r-solution.out
  local w1 d1 i1 javadiff
  w1=$(grep -cE '^SLF4J' .r-s1.raw)
  d1=$(grep -c ' DEBUG ' .r-s1.raw); i1=$(grep -c ' INFO ' .r-s1.raw)
  javadiff=$(diff -r exercise/src/main/java .sol/src/main/java | grep -c . )
  [ "$w1" -eq 0 ] || die "the answer still prints $w1 SLF4J warning(s)"
  [ "$d1" -eq 3 ] && [ "$i1" -eq 2 ] || die "the answer printed $d1 DEBUG / $i1 INFO line(s), not 3 / 2"
  [ "$javadiff" -eq 0 ] || die "the answer changed $javadiff line(s) of src/main/java - it is not supposed to touch Java at all"

  { printf 'SLF4J warnings: %d -> %d\n' "$w0" "$w1"
    printf 'kitchen log lines: %d -> %d (%d DEBUG, %d INFO)\n' "$k0" "$(( d1 + i1 ))" "$d1" "$i1"
    printf 'lines of src/main/java the answer changed: %d\n' "$javadiff"
  } >> .r-solution.out
  cat .r-solution.out
  printf 'md5 %s  exit %d then %d\n' "$(hash_of .r-solution.out)" "$rc0" "$rc1"
  rm -rf .sol
}

# --------------------------------------------------------------- offline ----
run_offline() {
  block "offline - the contract's 1c receipt"
  "${MVN[@]}" test > /dev/null 2>&1 || die "the warm-up build failed; there is nothing to go offline with"
  "${MVN[@]}" -o test > .r-o.raw 2>&1; local rc=$?
  grep -E '^\[INFO\] Tests run:|^\[INFO\] BUILD' .r-o.raw | mask_time > .r-offline.out
  [ "$rc" -eq 0 ] || die "mvn -o test exited $rc"
  grep -q 'BUILD SUCCESS' .r-offline.out || die "no BUILD SUCCESS in the offline run"
  printf 'offline: yes (-o), after one warm build of the same lifecycle\n' >> .r-offline.out
  cat .r-offline.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-offline.out)" "$rc"
}

ALL=(bridge levels tree println nobinding cost release solution offline)
if [ $# -eq 0 ]; then set -- "${ALL[@]}"; fi
for b in "$@"; do
  case "$b" in
    bridge|levels|tree|println|nobinding|cost|release|solution|offline) "run_$b" ;;
    *) printf 'unknown block: %s\nblocks: %s\n' "$b" "${ALL[*]}" >&2; exit 2 ;;
  esac
done
printf '\n'

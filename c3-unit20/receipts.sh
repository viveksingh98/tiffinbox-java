#!/bin/bash
# receipts.sh - regenerate every number this unit puts on a slide.
#
#   ./receipts.sh            run every block
#   ./receipts.sh roll       run one block
#
# The four rules this section works to:
#
#   1. A DERIVED LINE IS PART OF THE CAPTURE. Every count is appended to the .out file
#      before that file is hashed, so a wrong derived number moves the hash.
#   2. A BLOCK THAT CANNOT MEASURE MUST NOT PRINT. Every run records its exit code and
#      every derived value is checked; a block with nothing to measure calls die().
#   3. EVERY BLOCK MEASURES ITS OWN RUN. Nothing is read back off disk from an earlier one.
#   4. A LOG LINE CARRIES A CLOCK. Everything hashed here goes through mask_time() first,
#      and every slide quoting a hash shows that filter.
#
# And one that is this unit's own: A FILE SIZE IS NOT A CONSTANT. The rolling block prints
# per-file byte sizes OUTSIDE the hash, and hashes only the file names and the line counts.

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

mask_time() { sed -E -e 's/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} /<time> /' \
                     -e 's/, Time elapsed: [0-9.]+ s//' -e 's/ -- Time elapsed: [0-9.]+ s//' \
                     -e "s#${PWD}/#<project>/#g" \
                     -e 's#[^ ]*/c3-unit20/#<project>/#g' \
                     -e 's#/Users/[^/]*/#<home>/#g'; }

# Only the kitchen's own lines. Maven's scaffolding is not the lesson.
kitchen_lines() { grep -E ' kitchen ' ; }

# A count's label must name what it counted. Two passes, because one is not enough:
# drop whole comment lines, AND strip a trailing // comment - the second one is not
# optional, and this block found out the hard way. `log.info("both tickets done");
# // no orderId in the MDC on this thread` made a grep for a logging call passing an
# order id report 1 when the truth is 0, and the printf beside it had a typed 0.
code_only() { grep -vE '^[[:space:]]*(\*|//|/\*)' "$1" | sed -E 's#[[:space:]]*//.*$##'; }

# Run one project's main in a fresh JVM. $1 = dir, $2 = main class (or "" for the pom's).
run_main() {
  local dir="$1" cls="${2:-}"
  if [ -n "$cls" ]; then
    ( cd "$dir" && "${MVN[@]}" -q -Drun.class="$cls" compile exec:exec ) > .r-run.raw 2>&1
  else
    ( cd "$dir" && "${MVN[@]}" -q compile exec:exec ) > .r-run.raw 2>&1
  fi
  return $?
}

# --------------------------------------------------------------- appenders ----
# One event, two destinations, and the file is the proof - not the build result.
run_appenders() {
  block "appenders - one event, two destinations"
  rm -rf target/logs
  run_main . com.tiffinbox.kitchen.KitchenMdc; local rc=$?
  [ "$rc" -eq 0 ] || die "the run exited $rc"
  [ -f target/logs/kitchen.log ] || die "no target/logs/kitchen.log - the FILE appender never wrote"

  { printf 'console\n';               kitchen_lines < .r-run.raw       | mask_time
    printf 'target/logs/kitchen.log\n'; kitchen_lines < target/logs/kitchen.log | mask_time
  } > .r-appenders.out

  local con fil refs same
  con=$(kitchen_lines < .r-run.raw | grep -c .)
  fil=$(kitchen_lines < target/logs/kitchen.log | grep -c .)
  refs=$(grep -c '<appender-ref' src/main/resources/logback.xml)
  same=$(diff <(kitchen_lines < .r-run.raw | mask_time) \
              <(kitchen_lines < target/logs/kitchen.log | mask_time) > /dev/null && echo yes || echo no)
  [ "$con" -gt 0 ] || die "the console capture is empty"
  [ "$con" -eq "$fil" ] || die "console $con line(s) against file $fil - the two appenders disagree"
  [ "$refs" -eq 2 ] || die "logback.xml attaches $refs appender(s) to the root, not 2"
  { printf 'lines on the console: %d ; lines in the file: %d\n' "$con" "$fil"
    printf 'appender-ref elements under <root>: %d\n' "$refs"
    printf 'the two renderings are identical once the clock is masked: %s\n' "$same"
  } >> .r-appenders.out
  cat .r-appenders.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-appenders.out)" "$rc"
}

# ----------------------------------------------------------------- pattern ----
# Every token of the pattern, matched against the line it produced.
run_pattern() {
  block "pattern - the layout, token by token, against one real line"
  rm -rf target/logs
  run_main . com.tiffinbox.kitchen.KitchenMdc; local rc=$?
  [ "$rc" -eq 0 ] || die "the run exited $rc"
  # THE LINE IS SELECTED BY POSITION, NOT BY CONTENT. This used to be
  # `kitchen_lines < ... | head -1`, i.e. grep ' kitchen ', which meant the %logger{1}
  # check below looked for the very string the line had been selected by - one of six
  # checks that could not fail. Take the file's first line and let every token be a real
  # question about it.
  local line
  line=$(head -1 target/logs/kitchen.log)
  [ -n "$line" ] || die "the log file is empty"

  local pat
  pat=$(grep -A1 'name="PATTERN"' src/main/resources/logback.xml | grep -oE 'value="[^"]*"' | sed 's/value="//; s/"$//')
  [ -n "$pat" ] || die "could not read the PATTERN property out of logback.xml"

  { printf 'pattern: %s\n' "$pat"
    printf 'one line: %s\n' "$(printf '%s' "$line" | mask_time)"
  } > .r-pattern.out

  # each token, and the field it actually produced in that line
  check() {  # $1 = token, $2 = an ERE the produced field must match
    grep -qF -- "$1" <<<"$pat" || die "the pattern no longer contains $1"
    if grep -qE -- "$2" <<<"$line"; then printf '  %-18s -> matched %s\n' "$1" "$2"
    else die "$1 is in the pattern but nothing in the line matches $2"; fi
  }
  { check '%d{HH:mm:ss.SSS}' '^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} '
    check '[%thread]'        '\[(cook-[0-9]+|main)\]'
    check '%-5level'         'INFO '
    check '%logger{1}'       ' kitchen '
    check '%X{orderId:-}'    '(A-4417|B-9082)'
    check '%msg%n'           '- (accepted|cooking|packed) for '
  } >> .r-pattern.out

  local tokens
  tokens=$(grep -oE '%[-{}A-Za-z0-9:.]+' <<<"$pat" | grep -c .)
  # %msg and %n are two tokens and one check: %n IS the line boundary, so the only way to
  # see it is that there is a next line at all.
  printf 'tokens in the pattern: %d ; checked against this line: 6 groups (%%msg and %%n are one)\n' \
    "$tokens" >> .r-pattern.out
  [ "$tokens" -eq 7 ] || die "the pattern has $tokens token(s); the block checks 7"
  cat .r-pattern.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-pattern.out)" "$rc"
}

# --------------------------------------------------------------------- mdc ----
run_mdc() {
  block "mdc - one id on every line of one request, and on no other"
  run_main . com.tiffinbox.kitchen.KitchenMdc; local rc=$?
  [ "$rc" -eq 0 ] || die "the run exited $rc"
  kitchen_lines < .r-run.raw | mask_time > .r-mdc.out

  local a b none total puts
  a=$(grep -c ' A-4417 - ' .r-run.raw)
  b=$(grep -c ' B-9082 - ' .r-run.raw)
  none=$(kitchen_lines < .r-run.raw | grep -cE ' kitchen  - ')
  total=$(kitchen_lines < .r-run.raw | grep -c .)
  # the id is never an argument to a logging call - that is the whole point
  puts=$(code_only src/main/java/com/tiffinbox/kitchen/KitchenMdc.java | grep -c 'MDC.put(')
  [ "$total" -eq $(( a + b + none )) ] || die "the three id groups do not add up to $total lines"
  [ "$a" -eq "$b" ] || die "the two orders wrote $a and $b lines; the demo is meant to be symmetric"
  [ "$none" -eq 1 ] || die "$none line(s) carried no id, expected exactly 1"
  [ "$puts" -eq 1 ] || die "$puts MDC.put() call(s) in the source, expected exactly 1"
  local calls passing
  calls=$(code_only src/main/java/com/tiffinbox/kitchen/KitchenMdc.java | grep -c 'log\.info(')
  passing=$(code_only src/main/java/com/tiffinbox/kitchen/KitchenMdc.java | grep 'log\.info(' | grep -c 'orderId')
  [ "$calls" -gt 0 ] || die "no logging call sites found in KitchenMdc.java"
  [ "$passing" -eq 0 ] || die "$passing logging call site(s) pass the order id as an argument; the lesson says none do"
  { printf 'lines carrying A-4417: %d ; B-9082: %d ; no id at all: %d ; total: %d\n' "$a" "$b" "$none" "$total"
    printf 'MDC.put() calls in KitchenMdc.java: %d\n' "$puts"
    printf 'log.info(...) call sites: %d ; of those, sites passing an order id: %d\n' "$calls" "$passing"
  } >> .r-mdc.out
  cat .r-mdc.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-mdc.out)" "$rc"
}

# ----------------------------------------------------------------- handoff ----
# The break: an id that does not travel, and then one that travels to the wrong request.
run_handoff() {
  block "handoff - the id at a thread boundary (the break)"
  run_main breaks/mdc-lost; local rc=$?
  [ "$rc" -eq 0 ] || die "the break exited $rc - it is supposed to run and be WRONG, not fail"
  kitchen_lines < .r-run.raw | mask_time > .r-handoff.out

  # state 1: every cooking line lost the id. state 2: Bela's line carries Arun's id.
  local s1 s2 lost wrong
  s1=$(grep -n 'state 1' .r-run.raw | cut -d: -f1)
  s2=$(grep -n 'state 2' .r-run.raw | cut -d: -f1)
  [ -n "$s1" ] && [ -n "$s2" ] || die "could not find the two state markers in the capture"
  lost=$(sed -n "${s1},${s2}p" .r-run.raw | grep -c 'pool-1-thread-1.*kitchen \.\.\. - cooking')
  wrong=$(sed -n "${s2},\$p" .r-run.raw | grep -c 'pool-1-thread-1.*A-4417 - cooking Bela')
  [ "$lost" -eq 2 ] || die "state 1 lost the id on $lost cooking line(s), expected 2"
  [ "$wrong" -eq 1 ] || die "state 2 mislabelled $wrong line(s), expected exactly 1"
  { printf 'state 1 - cooking lines that reached the pool with NO id: %d of 2\n' "$lost"
    printf "state 2 - cooking lines labelled with another request's id: %d of 2\n" "$wrong"
    printf 'the process exit code, in both states: %d\n' "$rc"
    printf 'nothing threw, nothing was dropped, and one line is now a confident lie\n'
  } >> .r-handoff.out
  cat .r-handoff.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-handoff.out)" "$rc"
}

# -------------------------------------------------------------------- pool ----
run_pool() {
  block "pool - the same hand-off, carried properly"
  run_main . com.tiffinbox.kitchen.KitchenPool; local rc=$?
  [ "$rc" -eq 0 ] || die "the run exited $rc"
  kitchen_lines < .r-run.raw | mask_time > .r-pool.out

  local right stale endline
  right=$(grep -c -e 'pool-1-thread-1.*A-4417 - cooking Arun' -e 'pool-1-thread-1.*B-9082 - cooking Bela' .r-run.raw)
  stale=$(grep -c 'pool-1-thread-1.*A-4417 - cooking Bela' .r-run.raw)
  endline=$(grep -cE 'pool-1-thread-1.* kitchen  - end of service' .r-run.raw)
  [ "$right" -eq 2 ] || die "$right of 2 cooking lines carried their own request's id"
  [ "$stale" -eq 0 ] || die "$stale line(s) still carry a stale id"
  [ "$endline" -eq 1 ] || die "the no-context task did not come back clean"
  { printf "cooking lines carrying their OWN request's id: %d of 2\n" "$right"
    printf 'cooking lines carrying a stale id: %d\n' "$stale"
    printf 'tasks submitted with an empty MDC that came back with an empty MDC: %d of 1\n' "$endline"
  } >> .r-pool.out
  cat .r-pool.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-pool.out)" "$rc"
}

# -------------------------------------------------------------------- roll ----
# The same driver, the same line count, two configurations.
run_roll() {
  block "roll - a rolling policy that does not roll, and the element that fixes it"
  rm -rf target/logs breaks/no-roll/target/logs
  run_main breaks/no-roll; local rc1=$?
  run_main . com.tiffinbox.kitchen.KitchenRoll; local rc2=$?
  [ "$rc1" -eq 0 ] && [ "$rc2" -eq 0 ] || die "a rolling run failed: $rc1 / $rc2"

  local askedA fA lA askedB fB lB oldest inc
  askedA=$(grep -oE 'wrote [0-9]+ slip' breaks/no-roll/target/logs/kitchen.log | tail -1 | tr -cd '0-9')
  askedB=$(grep -hoE 'wrote [0-9]+ slip' target/logs/* | tail -1 | tr -cd '0-9')
  [ -n "$askedA" ] && [ "$askedA" = "$askedB" ] \
    || die "the two runs did not write the same number of lines ($askedA / $askedB)"
  fA=$(ls -1 breaks/no-roll/target/logs | wc -l | tr -d ' ')
  fB=$(ls -1 target/logs | wc -l | tr -d ' ')
  lA=$(cat breaks/no-roll/target/logs/* | wc -l | tr -d ' ')
  lB=$(cat target/logs/* | wc -l | tr -d ' ')
  oldest=$(head -1 "target/logs/$(ls -1 target/logs | grep -E '\.[0-9]+\.log$' | sort -t. -k2,2n | tail -1)" \
           | grep -oE 'slip [0-9]+')
  inc=$(grep -c '<checkIncrement>' src/main/resources/logback.xml)
  [ "$fA" -eq 1 ] || die "the tutorial configuration produced $fA file(s) - it rolled, so there is no break"
  [ "$fB" -gt 1 ] || die "the fixed configuration produced $fB file(s) - it did not roll"
  [ "$inc" -eq 1 ] || die "the fixed logback.xml declares checkIncrement $inc time(s)"
  [ "$lB" -lt "$lA" ] || die "the rolled tree kept $lB line(s) against $lA - nothing was discarded"

  { printf 'maxFileSize is 1KB in BOTH configurations. Same driver, same %s lines asked for.\n' "$askedA"
    printf 'breaks/no-roll  (no <checkIncrement>)   files: %d   lines on disk: %d\n' "$fA" "$lA"
    printf 'this project    (<checkIncrement>0 ms)  files: %d   lines on disk: %d\n' "$fB" "$lB"
    printf 'file names after the roll: %s\n' "$(ls -1 target/logs | tr '\n' ' ')"
    printf 'oldest line still on disk: %s (of %s written)\n' "$oldest" "$askedA"
    printf 'lines the window discarded: %d\n' "$(( lA - lB ))"
  } > .r-roll.out
  cat .r-roll.out
  # A SIZE IS NOT A CONSTANT (contract 2g, C2 finding #3): printed, never hashed.
  printf 'outside the hash, because a byte size is not a constant: %s\n' \
    "$(ls -l target/logs | awk 'NR>1{printf "%s:%s ", $9,$5}')"
  printf 'md5 %s  exit %d then %d\n' "$(hash_of .r-roll.out)" "$rc1" "$rc2"
}

# -------------------------------------------------------------------- gate ----
# WHY it does not roll, read out of the jar rather than asserted.
run_gate() {
  block "gate - the default that makes a 1KB roller not roll"
  "${MVN[@]}" -q dependency:build-classpath -Dmdep.outputFile=.r-cp.txt > /dev/null 2>&1 \
    || die "could not build the classpath"
  local core
  core=$(tr ':' '\n' < .r-cp.txt | grep 'logback-core' | head -1)
  [ -n "$core" ] || die "no logback-core on the classpath"

  rm -rf .gate && mkdir -p .gate
  cat > .gate/Gate.java <<'JAVA'
import ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy;
import ch.qos.logback.core.util.FixedIntervalInvocationGate;

/** Read the two defaults out of the jar on the classpath. Nothing here is typed twice. */
public class Gate {
    public static void main(String[] a) throws Exception {
        Object inc = FixedIntervalInvocationGate.class.getField("DEFAULT_INCREMENT").get(null);
        long max = SizeBasedTriggeringPolicy.DEFAULT_MAX_FILE_SIZE;
        System.out.println("SizeBasedTriggeringPolicy asks a FixedIntervalInvocationGate before it stats the file");
        System.out.println("FixedIntervalInvocationGate.DEFAULT_INCREMENT = " + inc);
        System.out.println("SizeBasedTriggeringPolicy.DEFAULT_MAX_FILE_SIZE = " + max + " bytes");
    }
}
JAVA
  javac -cp "$core" -d .gate .gate/Gate.java > .r-g.raw 2>&1 || die "Gate.java did not compile against $core"
  java -cp ".gate:$core" Gate >> .r-g.raw 2>&1; local rc=$?
  [ "$rc" -eq 0 ] || die "Gate exited $rc"

  sed -E 's#[^ ]*/logback-core#logback-core#' .r-g.raw > .r-gate.out
  local inc jar
  inc=$(grep -oE 'DEFAULT_INCREMENT = .*' .r-g.raw | sed 's/DEFAULT_INCREMENT = //')
  jar=$(basename "$core")
  [ -n "$inc" ] || die "could not read DEFAULT_INCREMENT"
  case "$inc" in *minute*) : ;; *) die "DEFAULT_INCREMENT is now '$inc'; the break may no longer exist" ;; esac
  { printf 'read from %s on this classpath, not from documentation\n' "$jar"
    printf 'so the file size is checked at most once every: %s\n' "$inc"
    printf 'a run that finishes faster than that never has its size checked, and never rolls\n'
  } >> .r-gate.out
  cat .r-gate.out
  printf 'md5 %s  exit %d\n' "$(hash_of .r-gate.out)" "$rc"
  rm -rf .gate
}

# ---------------------------------------------------------------- solution ----
run_solution() {
  block "solution - the exercise answer, run"
  rm -rf .sol && cp -R exercise .sol && rm -rf .sol/solution .sol/target
  ( cd .sol && "${MVN[@]}" -q compile exec:exec ) > .r-s0.raw 2>&1; local rc0=$?
  [ "$rc0" -eq 0 ] || die "the untouched exercise exited $rc0"
  [ -d .sol/target/logs ] || die "the untouched exercise wrote no log directory"
  local f0 l0
  f0=$(ls -1 .sol/target/logs | wc -l | tr -d ' '); l0=$(cat .sol/target/logs/* | wc -l | tr -d ' ')
  [ "$f0" -eq 1 ] || die "the untouched exercise produced $f0 file(s) - it already rolls, so it is not a start state"

  cp exercise/solution/logback.xml .sol/src/main/resources/logback.xml
  rm -rf .sol/target/logs
  ( cd .sol && "${MVN[@]}" -q compile exec:exec ) > .r-s1.raw 2>&1; local rc1=$?
  [ "$rc1" -eq 0 ] || die "the answer exited $rc1"
  local f1 l1 oldest
  f1=$(ls -1 .sol/target/logs | wc -l | tr -d ' '); l1=$(cat .sol/target/logs/* | wc -l | tr -d ' ')
  oldest=$(head -1 ".sol/target/logs/$(ls -1 .sol/target/logs | grep -E '\.[0-9]+\.log$' | sort -t. -k2,2n | tail -1)" \
           | grep -oE 'slip [0-9]+')
  [ "$f1" -gt "$f0" ] || die "the answer produced $f1 file(s), no more than the start state"
  [ "$l1" -lt "$l0" ] || die "the answer kept $l1 line(s) of $l0 - nothing was discarded"

  { printf 'start state: %d file(s), %d line(s) on disk\n' "$f0" "$l0"
    printf 'answer:      %d file(s), %d line(s) on disk\n' "$f1" "$l1"
    printf 'oldest line the window still holds: %s\n' "$oldest"
    printf 'lines rolled off the end and deleted: %d of %d\n' "$(( l0 - l1 ))" "$l0"
  } > .r-solution.out
  cat .r-solution.out
  printf 'md5 %s  exit %d then %d\n' "$(hash_of .r-solution.out)" "$rc0" "$rc1"
  rm -rf .sol
}

# ----------------------------------------------------------------- offline ----
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

ALL=(appenders pattern mdc handoff pool roll gate solution offline)
if [ $# -eq 0 ]; then set -- "${ALL[@]}"; fi
for b in "$@"; do
  case "$b" in
    appenders|pattern|mdc|handoff|pool|roll|gate|solution|offline) "run_$b" ;;
    *) printf 'unknown block: %s\nblocks: %s\n' "$b" "${ALL[*]}" >&2; exit 2 ;;
  esac
done
printf '\n'

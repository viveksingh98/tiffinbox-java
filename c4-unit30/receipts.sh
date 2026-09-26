#!/bin/bash
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"
# cap NAME CLASS: three runs, BOTH streams through jul.sh, hashed; any drift stops the receipts
cap() {
  for i in 1 2 3; do java -cp "$CP" "com.tiffinbox.$2" 2>&1 | ./jul.sh > ".r-$1.$i"; done
  h=$(md5 -q ".r-$1.1"); [ "$h" = "$(md5 -q ".r-$1.2")" ] && [ "$h" = "$(md5 -q ".r-$1.3")" ] && ok=3/3 || ok="*** DRIFTS ***"
  mv ".r-$1.1" ".r-$1.out"; rm -f ".r-$1.2" ".r-$1.3"; printf "  %-9s md5 %s  %s\n" "$1" "$h" "$ok"
  [ "$ok" = 3/3 ] || exit 1
}
cap where WhereItLives
cap attempts Attempts
cap bill TheBill
cap limit Limit
./since.sh > .r-since.out; printf "  %-9s md5 %s\n" since "$(md5 -q .r-since.out)"
echo
W=.r-where.out; A=.r-attempts.out; B=.r-bill.out; L=.r-limit.out; S=.r-since.out
[ "$(grep -c 'from spring-context-7.0.9.jar' $W)" = 3 ] && echo "  all three annotations load from spring-context-7.0.9.jar - no new dependency" || exit 1
grep -q '^  spring-context 6.2.19: 0 entries' $S && grep -q '^  spring-context 7.0.9: [1-9][0-9]* entries' $S && echo "  since 7: none of it in spring-context 6.2.19, the last 6.2" || exit 1
grep -q 'maxRetries = 3   -> 4 attempts in all' $W && grep -q 'delay      = 1000 MILLISECONDS' $W && echo "  defaults, read off the annotation: 3 retries (4 attempts), 1000 ms apart" || exit 1
grep -q 'policy = BLOCK' $W && echo "  @ConcurrencyLimit when full: BLOCK (read off the annotation)" || exit 1
grep -q '^    -> paid after 3 attempts$' $A && echo "  maxRetries = 2: failed, failed, succeeded - 3 attempts" || exit 1
grep -q 'the caller gets IllegalStateException: gateway timeout on attempt 3   (earlier failures attached: 0, cause: null)' $A \
  && echo "  all failing: the caller gets the LAST exception; the first two are not attached" || exit 1
# RED 2026-09-26 #3: every failure IS published - a listener sees all three, the last marked exhausted.
sed -n '/fails every time/,/caller gets/p' $A > .r-events.tmp
[ "$(grep -c '\[event\] gateway timeout on attempt' .r-events.tmp)" = 3 ] \
  && grep -q '\[event\] retries exhausted - RetryException, cause: gateway timeout on attempt 3, earlier failures attached: 2' .r-events.tmp \
  && echo "  ...but Spring published an event per failure (3), then one 'exhausted' event carrying all of them - a listener sees them" || { rm -f .r-events.tmp; echo "  *** retry-event claim failed ***"; exit 1; }
rm -f .r-events.tmp
grep -q 'after 1 attempt(s) - no retry at all' $A && echo "  called from inside the class: 1 attempt, no retry" || exit 1
grep -q '^  charged 1020 for one order   (3 x 340)$' $B && echo "  the break: charged 1020 for one order of 340" || exit 1
grep -q 'no limit            : at most 6 cooking at once, 6 of 6 cooked' $L && grep -q '@ConcurrencyLimit(2): at most 2 cooking at once, 6 of 6 cooked' $L \
  && echo "  @ConcurrencyLimit(2): 2 at once instead of 6, and all 6 still cooked" || exit 1
[ "$(grep -c 'WARNING\|SEVERE' .r-where.out .r-attempts.out .r-bill.out .r-limit.out | awk -F: '{s+=$2} END {print s}')" = 0 ] && echo "  no WARNING or SEVERE line in any capture" || exit 1

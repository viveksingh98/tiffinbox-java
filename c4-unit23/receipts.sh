#!/bin/bash
# Every capture this unit's README quotes. stdout AND stderr, JUL timestamp headers masked and
# counted, every WARNING kept - because in this unit a warning's presence and absence are both claims.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"
cap() { nm=$1; shift; ec=0
  for i in 1 2 3; do { "$@" 2>&1; } | ./jul.sh > ".r-$nm.$i" || true; done
  "$@" >/dev/null 2>&1 || ec=$?
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] && ok=3/3 || ok="*** DRIFTS ***"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; echo "$ec" > ".r-$nm.exit"
  printf "  %-12s md5 %s  %s  exit %s\n" "$nm" "$h" "$ok" "$ec"; }
cap jdk        java -cp "$CP" com.tiffinbox.TwoMechanisms
cap cglib      java -cp "$CP" com.tiffinbox.TwoMechanisms force
# A' (contract 2c): back to A AFTER B. If A' equals A, the flip moved the row - not the second run.
{ java -cp "$CP" com.tiffinbox.TwoMechanisms 2>&1; } | ./jul.sh > .r-jdk-again.out || true
[ "$(md5 -q .r-jdk-again.out)" = "$(md5 -q .r-jdk.out)" ] && echo "  A' (default again, after the flip): identical to A" \
  || { echo "  *** A' differs from A ***"; exit 1; }
cap ways-out   java -cp "$CP" com.tiffinbox.WaysOut

echo
# THE A/B: exactly one row may differ between the two mechanisms.
n=$(diff <(grep -v 'proxyTargetClass' .r-jdk.out) <(grep -v 'proxyTargetClass' .r-cglib.out) 2>/dev/null | grep -c '^<' || true)
echo "  rows that moved when proxyTargetClass flipped: $n"
[ "$n" = "1" ] || { echo "  *** expected exactly one ***"; exit 1; }
for f in jdk cglib; do
  t=$(grep 'INSIDE' .r-$f.out | grep -o 'advice ran [0-9]*')
  echo "  $f: the internal call -> $t"; [ "$t" = "advice ran 0" ] || { echo "  *** trap did not hold ***"; exit 1; }
done
# Count EVERY warning, not warnings containing words I guessed. If the only warning in the whole run is
# the one about the final method, then the self-invocation trap produced none - a claim this can FAIL.
all=$(grep -c '^WARNING' .r-jdk.out || true); fin=$(grep -c '^WARNING: Public final method .*\$FinalBilling\.price' .r-jdk.out || true)
quiet=$(grep -c '^WARNING.*QuietFinalBilling' .r-jdk.out || true)
echo "  WARNING lines in the whole run: $all, of which about the PUBLIC final method: $fin, about the non-public one: $quiet"
[ "$all" = "1" ] && [ "$fin" = "1" ] && [ "$quiet" = "0" ] \
  && grep -q 'final, and NOT public               : advice ran 0' .r-jdk.out \
  && echo "  -> a PUBLIC final method gets one warning; a non-public final one and self-invocation get NONE" \
  || { echo "  *** warning count changed - re-read the capture ***"; exit 1; }
# @Proxyable (new in 7): one interface bean asks for a subclass, under the DEFAULT setting
grep -q 'interface bean, @Proxyable(TARGET_CLASS) -> .*PerBeanBilling\$\$SpringCGLIB\$\$<n>' .r-jdk.out \
  && echo "  @Proxyable(TARGET_CLASS): that one interface bean became a subclass without the global flag" \
  || { echo "  *** @Proxyable row changed ***"; exit 1; }
w=$(grep -o 'advice ran [0-9]*' .r-ways-out.out | sort -u)
[ "$w" = "advice ran 2" ] && echo "  all three ways out: advice ran 2 (the two inner calls)" || { echo "  *** a way out failed: $w ***"; exit 1; }

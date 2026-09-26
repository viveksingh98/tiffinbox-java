#!/bin/bash
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
  printf "  %-10s md5 %s  %s  exit %s\n" "$nm" "$h" "$ok" "$ec"; }
cap before  java -cp "$CP" com.tiffinbox.Coupled
cap after   java -cp "$CP" com.tiffinbox.Decoupled
cap break   java -cp "$CP" com.tiffinbox.Decoupled break
cap handled java -cp "$CP" com.tiffinbox.Decoupled handled
echo
b=$(grep 'depends on' .r-before.out | sed 's/.*(yours): //;s/ .*//'); a=$(grep 'depends on' .r-after.out | sed 's/.*(yours): //;s/ .*//')
echo "  kitchen's own dependencies: before $b  after $a"
[ "$b" = "[smsNotifier]" ] && [ "$a" = "[]" ] || { echo "  *** the edge was not deleted ***"; exit 1; }
n=$(sed -n '/class Kitchen/,/^    }/p' src/main/java/com/tiffinbox/Decoupled.java | grep -c SmsNotifier || true)
echo "  mentions of SmsNotifier inside the new Kitchen: $n"; [ "$n" = "0" ] || exit 1
awk '/publishing|cooking/{p=NR} /publish returned/{r=NR} /\[sms|\[receipt/{l=NR} END{exit !(l<r)}' .r-after.out \
  && echo "  every listener ran BEFORE 'publish returned' -> the publisher waits (synchronous)" || { echo "  *** not synchronous ***"; exit 1; }
grep -q '\[caller \] got IllegalStateException' .r-break.out && ! sed -n '/nobody:/,$p' .r-break.out | grep -q '\[sms' \
  && echo "  the listener's exception reached the caller, and the SMS listener never ran" || { echo "  *** break claim fails ***"; exit 1; }
# The remaining edge is NAMED (RED 2026-09-26 #10): the context itself, handed over as the publisher.
grep -q "(yours): \[\]   (Spring's own: \[org.springframework.context.annotation.AnnotationConfigApplicationContext@<id>\]" .r-after.out \
  && echo "  the one edge left is Spring's own: the application context, given to the kitchen as its publisher" \
  || { echo "  *** the remaining edge changed ***"; exit 1; }
# THE REMEDY (RED #17): one bean - a multicaster with an error handler. The SMS still goes out; the caller sees nothing.
sed -n '/with an error handler/,$p' .r-handled.out > .r-handled-tail.tmp
grep -q '\[handler\] a listener failed: receipt printer refused nobody' .r-handled-tail.tmp && grep -q '\[sms    \] your order is in, nobody' .r-handled-tail.tmp \
  && grep -q '\[caller \] no exception' .r-handled-tail.tmp \
  && echo "  with an error handler on the multicaster: failure handled, the SMS still sent, the caller unaware" \
  || { rm -f .r-handled-tail.tmp; echo "  *** remedy claim fails ***"; exit 1; }
rm -f .r-handled-tail.tmp


#!/bin/sh
# Every capture this unit's README quotes, three runs each.
#
# THE RULE IS NOT "did three runs agree?". That question says YES to a capture carrying a
# wall-clock timestamp whenever three runs land in the same second, and this section caught it
# doing exactly that twice. The question asked here is the one luck cannot answer:
#
#   does the capture contain a timestamp at all?
#     no  -> hash the OUTPUT; three runs must agree.
#     yes -> the output is not hashable. Hash the TRIO: exit code, exception type, first line of
#            the message -- and die rather than emit a trio with no exception to identify.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt \
                     dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"
TS='[A-Z][a-z][a-z] [ 0-9][0-9], [0-9]{4} [0-9:]+ (AM|PM)|[0-9]{2}:[0-9]{2}:[0-9]{2}'

cap() { nm=$1; shift
  ec=0
  for i in 1 2 3; do
    { "$@" 2>&1; } > ".r-$nm.$i" || ec=$?          # the exit code of the RUN, not of a later command
  done
  echo "$ec" > ".r-$nm.exit"
  n=$(grep -cE "$TS" ".r-$nm.1" || true)
  if [ "$n" -eq 0 ]; then
    h=$(md5 -q ".r-$nm.1")
    if [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ]
      then ok="3/3"; else ok="*** DRIFTS ***"; fi
    mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
    printf "  %-13s OUTPUT md5 %s  %s  exit %s\n" "$nm" "$h" "$ok" "$ec"
  else
    for i in 1 2 3; do
      line=$(grep -m1 -oE '[a-z][a-zA-Z.]*(Exception|Error): .*' ".r-$nm.$i" || true)
      [ -n "$line" ] || { echo "  $nm: CANNOT RECEIPT -- timestamped and no exception line"; exit 1; }
      printf '%s\n%s\n' "$ec" "$line" > ".t-$nm.$i"
    done
    h=$(md5 -q ".t-$nm.1")
    if [ "$h" = "$(md5 -q ".t-$nm.2")" ] && [ "$h" = "$(md5 -q ".t-$nm.3")" ]
      then ok="3/3"; else ok="*** DRIFTS ***"; fi
    mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3" ".t-$nm.2" ".t-$nm.3"
    printf "  %-13s TRIO   md5 %s  %s  exit %s   (%s timestamp line(s): output not hashable)\n" \
           "$nm" "$h" "$ok" "$ec" "$n"
  fi
}

cap in-order      java -cp "$CP" com.tiffinbox.InOrder
cap three-powers  java -cp "$CP" com.tiffinbox.ThreePowers
cap forgot        java -cp "$CP" com.tiffinbox.ForgotProceed

# Timing: the raw values differ every run BY DESIGN, so the output is masked and the MASKED form hashed.
for i in 1 2 3; do java -cp "$CP" com.tiffinbox.Timing 2>&1 | tee ".r-timing-raw.$i" | ./ms.sh > ".r-timing.$i"; done
h=$(md5 -q .r-timing.1); [ "$h" = "$(md5 -q .r-timing.2)" ] && [ "$h" = "$(md5 -q .r-timing.3)" ] && ok=3/3 || ok="*** DRIFTS ***"
mv .r-timing.1 .r-timing.out; rm -f .r-timing.2 .r-timing.3
printf "  %-13s OUTPUT md5 %s  %s  (masked)\n" "timing" "$h" "$ok"

# DERIVED, not asserted.
echo
echo "  raw durations across three runs (they must differ, or the lesson is fake):"
for i in 1 2 3; do printf "    run %s: %s\n" "$i" "$(grep -o 'took [0-9.]* ms' .r-timing-raw.$i | sed 's/took //;s/ ms//' | paste -sd' ' -)"; done
d=$(cat .r-timing-raw.* | grep -o 'took [0-9.]* ms' | sort -u | wc -l | tr -d ' ')
[ "$d" -ge 2 ] && echo "  distinct durations: $d  -> a single duration is not a fact" || { echo "  *** durations identical ***"; exit 1; }
[ "$(grep -c "AopInvocationException" .r-forgot.out)" = 1 ] && [ "$(grep -c "nothing reported a problem" .r-forgot.out)" = 3 ] \
  && sed -n '/return type Integer:/{n;p;}' .r-forgot.out | grep -q "caller got: null" \
  && echo "  forgot proceed: loud ONLY for int; Integer, String and void are silent (Integer -> null)" || { echo "  *** forgot-proceed shape changed ***"; exit 1; }
if sed -n '/skip the call/,/change the arguments/p' .r-three-powers.out | grep -q "the real method ran"; then
  echo "  *** skip ran the method ***"; exit 1
else
  echo "  skip the call: the real method line is ABSENT -> it never ran"
fi

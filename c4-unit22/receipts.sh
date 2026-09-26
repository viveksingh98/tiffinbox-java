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

cap matrix        java -cp "$CP" com.tiffinbox.Matrix
cap static-or-rt  java -cp "$CP" com.tiffinbox.StaticOrRuntime
cap dollar-star   java -cp "$CP" com.tiffinbox.DollarStar
cap named         java -cp "$CP" com.tiffinbox.Named

# DERIVED, not asserted.
echo
a=$(grep '^  args(String) ' .r-matrix.out | awk '{print $NF}')
x=$(grep '^  execution(\* \*(String))' .r-matrix.out | awk '{print $NF}')
echo "  control bean 'menu' proxied?   args(String): $a    execution(* *(String)): $x"
[ "$a" = "P" ] && [ "$x" = "." ] && echo "  -> same intent, and only the runtime-checked one proxies a bean it never advises" \
                                 || { echo "  *** the blind-spot claim does not hold ***"; exit 1; }
d=$(grep 'DollarStar\$\*' .r-dollar-star.out | grep -o 'advice ran [0-9]*')
echo "  \$* wildcard: $d"; [ "$d" = "advice ran 0" ] || { echo "  *** \$* matched something ***"; exit 1; }
w=$(grep '^  execution(\* com.tiffinbox.\*.\*(..))  ' .r-matrix.out | awk '{print $4}')
echo "  widest wildcard advised the control method dishes(): $w"; [ "$w" = "RAN" ] || { echo "  *** too-wide claim fails ***"; exit 1; }

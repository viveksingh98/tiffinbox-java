#!/bin/sh
# Every capture this unit's README quotes. The EL layer is absent by default and added by -Pel, so
# "with" and "without" are one flag apart.
#
# THE RULE IS NOT "did three runs agree?" -- that question says yes to a timestamped capture
# whenever three runs land in the same second, and this section caught it doing exactly that.
# Everything here goes through jul.sh, which removes the two things that are not properties of the
# code and says how many of each it removed.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp-noel.txt ] || mvn -q      -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp-noel.txt dependency:build-classpath >/dev/null 2>&1
[ -f cp-el.txt   ] || mvn -q -Pel -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp-el.txt   dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
NOEL="target/classes:$(cat cp-noel.txt)"
EL="target/classes:$(cat cp-el.txt)"

cap() { nm=$1; shift
  ec=0
  for i in 1 2 3; do { "$@" 2>&1; } | ./jul.sh > ".r-$nm.$i" || true; done
  "$@" >/dev/null 2>&1 || ec=$?
  echo "$ec" > ".r-$nm.exit"
  h=$(md5 -q ".r-$nm.1")
  if [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ]
    then ok="3/3"; else ok="*** DRIFTS ***"; fi
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  printf "  %-12s md5 %s  %s  exit %s\n" "$nm" "$h" "$ok" "$ec"
}

echo "A  no EL implementation, default interpolator"
cap el-none   java -cp "$NOEL" com.tiffinbox.CheckAnOrder
echo "B  EL present"
cap el-ok     java -cp "$EL"   com.tiffinbox.CheckAnOrder
echo "C  no EL, Spring-wired -- refresh is cancelled"
cap el-spring java -cp "$NOEL" com.tiffinbox.SpringWired
echo "D/E  the break: same interpolator, EL absent then present"
cap ip-noel   java -cp "$NOEL" com.tiffinbox.TheInterpolator param
cap ip-el     java -cp "$EL"   com.tiffinbox.TheInterpolator param
echo "   and the correct answer"
cap ip-right  java -cp "$EL"   com.tiffinbox.TheInterpolator default
echo "the boundary"
cap boundary  java -cp "$EL"   com.tiffinbox.AtTheBoundary

echo
# THE UNIT'S CENTRAL PROOF, checked rather than claimed: D and E must be byte-identical.
if [ "$(md5 -q .r-ip-noel.out)" = "$(md5 -q .r-ip-el.out)" ]; then
  echo "  ip-noel and ip-el are BYTE-IDENTICAL -> the EL jar made no difference; the interpolator did."
else
  echo "  *** ip-noel and ip-el DIFFER -- the unit's central claim does not hold on this machine ***"
  exit 1
fi
# DERIVED: is the break actually silent? (It is not, and the unit says so.)
echo "  HV000185 warnings in the break capture: $(grep -c 'HV000185' .r-ip-noel.out)"

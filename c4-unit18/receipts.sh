#!/bin/sh
# Every capture this unit's README quotes.
#
# THE LOCALE IS PASSED AS ITS OWN LITERAL FLAG, twice, on every line below. The author's shell is
# zsh, which does NOT word-split an unquoted expansion, so a `for loc in "it IT"; do … -Duser.language=$1`
# loop silently passes "it IT" as ONE argument and produces a malformed locale. The first attempt at
# this unit's finding did exactly that, showed English in both columns, and would have shipped as
# "the default locale does not matter".
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt \
                     dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"
TS='[0-9]{2}:[0-9]{2}:[0-9]{2}'

cap() { nm=$1; shift
  ec=0
  for i in 1 2 3; do { "$@" 2>&1; } > ".r-$nm.$i" || true; done
  "$@" >/dev/null 2>&1 || ec=$?
  echo "$ec" > ".r-$nm.exit"
  n=$(grep -cE "$TS" ".r-$nm.1" || true)
  [ "$n" -eq 0 ] || { echo "  $nm: NOT HASHABLE -- $n timestamp-shaped line(s)"; exit 1; }
  h=$(md5 -q ".r-$nm.1")
  if [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ]
    then ok="3/3"; else ok="*** DRIFTS ***"; fi
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  printf "  %-12s md5 %s  %s  exit %s\n" "$nm" "$h" "$ok" "$ec"
}

cap en-machine  java -Duser.language=en -Duser.country=US -cp "$CP" com.tiffinbox.Bills
cap it-machine  java -Duser.language=it -Duser.country=IT -cp "$CP" com.tiffinbox.Bills
cap it-fixed    java -Duser.language=it -Duser.country=IT -cp "$CP" com.tiffinbox.Bills --no-system-fallback
cap code-default java -Duser.language=en -Duser.country=US -cp "$CP" com.tiffinbox.Bills --code-as-default

echo
# THE BREAK, CHECKED RATHER THAN CLAIMED: the German line must differ between the two machines.
de_en=$(grep 'bill.total   de' .r-en-machine.out | sed 's/.*-> //;s/ *<-.*//')
de_it=$(grep 'bill.total   de' .r-it-machine.out | sed 's/.*-> //;s/ *<-.*//')
de_fx=$(grep 'bill.total   de' .r-it-fixed.out   | sed 's/.*-> //;s/ *<-.*//')
echo "  asking for German, and changing NOTHING but the JVM default locale:"
echo "    on an en_US machine : $de_en"
echo "    on an it_IT machine : $de_it"
echo "    it_IT, fallback off : $de_fx"
[ "$de_en" != "$de_it" ] || { echo "  *** the two machines agree -- the finding does not hold here ***"; exit 1; }
[ "$de_en" = "$de_fx" ]  || { echo "  *** turning the fallback off did not restore the base bundle ***"; exit 1; }
echo "  => the machine chose the customer's language, and setFallbackToSystemLocale(false) stops it."

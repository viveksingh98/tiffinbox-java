#!/bin/sh
# A/B/A' on ONE thing: the order of the two @PropertySource lines in TiffinBoxConfig.java.
#
# A  = the file as shipped (rails-one declared first, rails-two second)
# B  = the two lines swapped, nothing else touched
# A' = swapped back and RE-RUN -- not A's output reused. Two captures cannot tell you the swap
#      caused anything; three can, and the third has to be a real run or it is a copy.
#
# Usage:  ./flip.sh            the file sources alone -- the swap MOVES THE WINNER
#         ./flip.sh sysprop    a JVM system property also set -- the swap moves the stack and
#                              the WINNER line does not move at all. That is the break beat:
#                              the line you were watching stayed still while everything under
#                              it changed, and a viewer would have concluded the swap did nothing.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first -- a bare java here is 23.0.1}"
CFG=src/main/java/com/tiffinbox/TiffinBoxConfig.java
ONE='@PropertySource("classpath:rails-one.properties")'
TWO='@PropertySource("classpath:rails-two.properties")'
MODE=${1:-}
# Receipts are named per MODE. They were not, once: running ./flip.sh and then ./flip.sh sysprop
# wrote both modes to .r-flip-A.out, so the second run silently destroyed the first run's evidence
# and only one of the two sets of hashes the README quotes could exist on disk at a time.
TAG=${MODE:-files}

restore() { cp "$CFG.orig" "$CFG" 2>/dev/null && rm -f "$CFG.orig"; }
trap restore EXIT INT TERM          # the file goes back even if a compile fails
cp "$CFG" "$CFG.orig"

# The classpath is built once; swapping two annotations cannot change it.
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt \
                     dependency:build-classpath >/dev/null 2>&1
CP="target/classes:$(cat cp.txt)"

run() {   # $1 = label
  mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
  java -cp "$CP" com.tiffinbox.Sources $MODE > ".r-flip-$TAG-$1.out" 2>&1
  echo "$?" > ".r-flip-$TAG-$1.exit"
  # the FIRST @PropertySource ANNOTATION -- not the import line, which also contains the word
  printf '%s  declared first: %s\n' "$1" \
     "$(grep -m1 '^@PropertySource' "$CFG" | sed 's/.*classpath://;s/".*//')"
  grep -E 'class path resource|WINNER' ".r-flip-$TAG-$1.out" | sed 's/^/     /'
}

swap() {  # put the two annotation lines in the order named: $1 first
  if [ "$1" = "two" ]; then
    printf '%s\n%s\n' "$TWO" "$ONE" > .lines
  else
    printf '%s\n%s\n' "$ONE" "$TWO" > .lines
  fi
  awk '/@PropertySource\("classpath:rails-(one|two)\.properties"\)/ {
         if (!done) { while ((getline l < ".lines") > 0) print l; close(".lines"); done=1 }
         next } { print }' "$CFG" > "$CFG.new" && mv "$CFG.new" "$CFG"
  rm -f .lines
}

echo "mode: ${MODE:-file sources only (no JVM system property)}"
swap one ; run A
swap two ; run B
swap one ; run "A-prime"

a=$(md5 -q ".r-flip-$TAG-A.out"); b=$(md5 -q ".r-flip-$TAG-B.out"); c=$(md5 -q ".r-flip-$TAG-A-prime.out")
echo
echo "A  md5 $a"
echo "B  md5 $b"
echo "A' md5 $c"
[ "$a" = "$c" ] || { echo "A' DID NOT REPRODUCE A -- something other than the swap is moving."; exit 1; }
[ "$a" = "$b" ] && echo "A and B are IDENTICAL: the swap changed nothing in this mode." \
                || echo "A and B DIFFER: the swap is the only edit, so the swap did it."

# THE QUESTION THAT MATTERS, asked separately -- because "the output changed" and "the answer
# changed" are different claims, and this unit exists because they can come apart.
wa=$(grep WINNER ".r-flip-$TAG-A.out"); wb=$(grep WINNER ".r-flip-$TAG-B.out")
echo
echo "  A  $wa"
echo "  B  $wb"
if [ "$wa" = "$wb" ]; then
  echo "  -> THE WINNER DID NOT MOVE. The stack reordered underneath a line that stayed still."
  echo "     A viewer watching only that line would have concluded the swap did nothing."
else
  echo "  -> THE WINNER MOVED. The swap changed the value the application actually reads."
fi

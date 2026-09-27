#!/bin/bash
# Course 5 · Unit 02's receipts: the project start.spring.io generated on 2026-09-27 (generated/, committed with the
# exact request in generated/REQUEST.txt — no step here calls the site), its parent opened, the test it ships, and the
# one request that makes a project Maven cannot build (breaks/release-suffix/). Every number the video says asserted.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
M2="$PWD/.m2-demo"
die() { echo "  *** $* ***"; exit 1; }
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
  if [ -z "$pub" ]; then note="(no published hash)"; elif [ "$pub" = "$h" ]; then note="= published"; else note="DIFFERS from the published $pub"; fi
  printf '  %-8s md5 %s  3/3  %s\n' "$nm" "$h" "$note"; }

rm -rf generated/target   # a previous run's build output is not something the generator handed over
files() { printf 'the generator handed over %s files:\n' "$(cd generated && find . -type f ! -name REQUEST.txt -not -path './target/*' | wc -l | tr -d ' ')"
  (cd generated && find . -type f ! -name REQUEST.txt -not -path './target/*' | sed 's|^\./||' | sort | sed 's/^/  /')
  printf 'the parent it names: %s\n' "$(sed -n '/<parent>/,/<\/parent>/p' generated/pom.xml | grep -oE '<(artifactId|version)>[^<]+' | sed 's/<[a-zA-Z]*>//' | paste -sd' ' -)"
  printf 'its own dependencies: %s\n' "$(sed -n '/<dependencies>/,/<\/dependencies>/p' generated/pom.xml | grep -o '<artifactId>[^<]*' | sed 's/<artifactId>//' | paste -sd' ' -)"
  printf 'java.version it asked for: %s\n' "$(grep -o '<java.version>[^<]*' generated/pom.xml | sed 's/<java.version>//')"; }
cap files files

parent() { (cd generated && mvn -q -B -Dmaven.repo.local="$M2" help:effective-pom -Doutput="$PWD/../.effective.xml" > /dev/null 2>&1) || { echo "effective-pom failed"; return; }
  E=.effective.xml
  printf 'the effective POM - the generated pom.xml with everything its parent adds - is %s lines\n' "$(wc -l < $E | tr -d ' ')"
  printf '  dependency versions the parent decides for you ................ %s\n' "$(sed -n '/<dependencyManagement>/,/<\/dependencyManagement>/p' $E | grep -c '<dependency>')"
  printf '  <parameters>true</parameters> (the compiler keeps parameter names) %s\n' "$(grep -c '<parameters>true</parameters>' $E)"
  printf '  <goal>repackage</goal> (the executable-jar step, configured) ..... %s\n' "$(grep -c '<goal>repackage</goal>' $E)"
  rm -f $E; }
cap parent parent

tests() { (cd generated && mvn -B -Dmaven.repo.local="$M2" test 2>&1) | grep -E '^\[(INFO|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' | tail -1
  printf 'what the one test checks: %s\n' "$(grep -A2 '@Test' generated/src/test/java/com/tiffinbox/TiffinboxApplicationTests.java | tr -s ' \t\n' ' ')"; }
cap tests tests

# The break: the request that used the metadata's own id, bootVersion=4.1.1.RELEASE. The error names a URL and the
# local repository path; the path is masked. Maven's exit code is taken before any filter.
release() { (cd breaks/release-suffix && mvn -q -B -Dmaven.repo.local="$M2" validate > ../../.r-release.raw 2>&1); ec=$?
  awk '/^\[FATAL\] Non-resolvable parent POM/ { i = index($0, " (absent)") + 8; printf "%s … [+%d chars]\n", substr($0, 1, i), length($0) - i; exit }' .r-release.raw
  printf '… %s more line(s) of Maven output elided …\nexit %s\n' "$(( $(wc -l < .r-release.raw) - 1 ))" "$ec"; }
cap release release

echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
x files '^the generator handed over 10 files:$'; x files '^the parent it names: spring-boot-starter-parent 4\.1\.1$'
x files '^its own dependencies: spring-boot-starter spring-boot-starter-test$'; x files '^java.version it asked for: 25$'
echo "  10 files; parent spring-boot-starter-parent 4.1.1; two starters; Java 25 (the site's default was 17 - REQUEST.txt)"
x parent 'decides for you \.+ 1911$'; x parent 'parameter names\) [0-9]+$'; grep -qE 'parameter names\) 0$' .r-parent.out && die "parent: -parameters absent"
x parent 'configured\) \.+ [1-9]'
grep -q 'spring-boot-maven-plugin' generated/pom.xml || die "the generated pom no longer declares spring-boot-maven-plugin"
grep -q 'spring-boot-maven-plugin' ../c5-tiffinbox/pom.xml ../c5-tiffinbox/tiffinbox-web/pom.xml && die "c5-tiffinbox now declares spring-boot-maven-plugin"
echo "  the parent decides 1911 versions, switches -parameters on, and configures repackage - which runs only where the plugin"
echo "  is DECLARED: the generated pom declares it, TiffinBox does not (its jar stays thin until unit 13)"
x tests 'Tests run: 1, Failures: 0, Errors: 0, Skipped: 0$'; x tests 'void contextLoads\(\) \{ \}'
echo "  the generated test: one test, and it checks only that a context starts"
x release 'Non-resolvable parent POM'; x release '4\.1\.1\.RELEASE'; x release '^exit 1$'
echo "  bootVersion=4.1.1.RELEASE: a project Maven cannot resolve (exit 1)"

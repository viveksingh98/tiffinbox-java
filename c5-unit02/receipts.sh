#!/bin/bash
# Course 5 · "Anatomy of a Generated Project" — the receipts. What start.spring.io returned on 2026-09-27: two requests,
# both zips kept as fetched in site/ beside the site's machine-readable version list (generated/ is the first zip,
# unpacked; generated/REQUEST.txt records both requests, their UTC time and the zips' md5s). No step here calls the site.
# Then: the parent opened, the jar its plugin builds, the test it ships, the one request that makes a project Maven
# cannot build, and the exercise, solved. Every number the video says is asserted at the bottom, and a capture whose md5
# differs from receipts.md5 stops the run (contract §R.2). A deliberate change is re-published with REPUBLISH=1.
set -e
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@25}"; export PATH="$JAVA_HOME/bin:$PATH"   # JDK 25 (§8.2, §R.9)
cd "$(dirname "$0")"
M2="$PWD/.m2-demo"          # the one local repository every step reads and fills (exercise/README.md reads it too)
W="$PWD/.r-work"            # scratch copies of ../c5-unit01/after; never built in place
die() { echo "  *** $* ***"; exit 1; }
"$JAVA_HOME/bin/java" -version 2>&1 | grep -q 'version "25' || die "JAVA_HOME is not a JDK 25: $JAVA_HOME"

# Three runs, hashed; a drift stops the receipts. A hash that differs from receipts.md5 is printed first, with the usual
# reasons, and then stops them too: a published capture changes on purpose (REPUBLISH=1), never by accident.
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
  if [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"; return; fi
  if [ -z "$pub" ]; then printf '  %-9s md5 %s  3/3  (no published hash)\n' "$nm" "$h"
  else printf '  %-9s md5 %s  3/3  DIFFERS from the published %s (a different JDK, Maven, Boot or c5-tiffinbox?)\n' "$nm" "$h" "$pub"; fi
  [ -n "$REPUBLISH" ] || die "$nm does not match receipts.md5"; }

rm -rf generated/target "$W"   # a previous run's build output is not something the generator handed over

# What the site returned, kept: the version list it publishes, both zips, and how they differ.
site() { J=site/metadata-client.json
  d=$(grep -o '"bootVersion":{[^]]*' "$J" | grep -o '"default":"[^"]*"' | cut -d'"' -f4)
  pat='{"id":"'"$(echo "$d" | sed 's/\./\\./g')"'","name":"[^"]*"}'   # a variable: bash 3.2 mis-parses \" in "$(…)"
  e=$(grep -o "$pat" "$J" | sed 's/{"id":"\([^"]*\)","name":"\([^"]*\)"}/id \1 · name \2/')
  printf "the site's machine-readable version list, %s:\n" "$J"
  printf '  Boot, its default:  %s\n' "$e"
  jv=$(grep -o '"javaVersion":{[^]]*' "$J")
  printf '  Java, its default:  %s · offered: %s\n' "$(echo "$jv" | grep -o '"default":"[^"]*"' | cut -d'"' -f4)" "$(echo "$jv" | grep -o '"id":"[^"]*"' | cut -d'"' -f4 | paste -sd' ' -)"; }
cap site site

fetches() { A=site/tiffinbox.zip; B=site/tiffinbox-bootVersion-4.1.1.RELEASE.zip
  for z in "$A" "$B"; do h=$(md5 -q "$z")
    printf '%-44s md5 %s  %s\n' "$z" "$h" "$(grep -q "$h" generated/REQUEST.txt && echo '= recorded in REQUEST.txt' || echo 'NOT in REQUEST.txt')"; done
  la=$(unzip -Z1 "$A" | grep -v '/$' | sed 's|^[^/]*/||' | sort); lb=$(unzip -Z1 "$B" | grep -v '/$' | sed 's|^[^/]*/||' | sort)
  ra=$(unzip -Z1 "$A" | head -1); rb=$(unzip -Z1 "$B" | head -1)
  [ "$la" = "$lb" ] && printf 'the two zips hold the same %s files; the ones that differ:' "$(echo "$la" | wc -l | tr -d ' ')" || printf 'the two zips hold different file lists'
  for f in $la; do cmp -s <(unzip -p "$A" "$ra$f") <(unzip -p "$B" "$rb$f") || printf ' %s' "$f"; done; echo
  dl=$(diff <(unzip -p "$A" "${ra}pom.xml") <(unzip -p "$B" "${rb}pom.xml") | grep -E '^[<>]' | tr -d '\t')
  printf '  pom.xml, lines changed: %s - %s\n' "$(echo "$dl" | grep -c '^<')" "$(echo "$dl" | sed 's/^< //; s/^> /-> /' | paste -sd' ' -)"
  n=0; for f in $la; do cmp -s <(tr -d '\r' < "generated/$f") <(unzip -p "$A" "$ra$f" | tr -d '\r') && n=$((n + 1)); done
  printf 'generated/ against the first zip: %s of %s files the same (line endings aside - see README)\n' "$n" "$(echo "$la" | wc -l | tr -d ' ')"
  printf 'breaks/release-suffix/pom.xml against the second zip'"'"'s pom.xml: %s\n' "$(cmp -s breaks/release-suffix/pom.xml <(unzip -p "$B" "${rb}pom.xml") && echo 'the same' || echo 'DIFFERENT')"; }
cap fetches fetches

files() { printf 'the generator handed over %s files:\n' "$(cd generated && find . -type f ! -name REQUEST.txt -not -path './target/*' | wc -l | tr -d ' ')"
  (cd generated && find . -type f ! -name REQUEST.txt -not -path './target/*' | sed 's|^\./||' | sort | sed 's/^/  /')
  printf 'the parent it names: %s\n' "$(sed -n '/<parent>/,/<\/parent>/p' generated/pom.xml | grep -oE '<(artifactId|version)>[^<]+' | sed 's/<[a-zA-Z]*>//' | paste -sd' ' -)"
  printf 'its own dependencies: %s\n' "$(sed -n '/<dependencies>/,/<\/dependencies>/p' generated/pom.xml | grep -o '<artifactId>[^<]*' | sed 's/<artifactId>//' | paste -sd' ' -)"
  printf 'java.version it asked for: %s\n' "$(grep -o '<java.version>[^<]*' generated/pom.xml | sed 's/<java.version>//')"; }
cap files files

parent() { (cd generated && mvn -q -B -Dmaven.repo.local="$M2" help:effective-pom -Doutput="$PWD/../.effective.xml" > /dev/null 2>&1) || { echo "effective-pom failed"; return; }
  E=.effective.xml
  printf 'the effective POM - the generated pom.xml with everything its parent adds - is %s lines\n' "$(wc -l < $E | tr -d ' ')"
  printf '  managed artifacts - each one'"'"'s version picked by the parent ...... %s\n' "$(sed -n '/<dependencyManagement>/,/<\/dependencyManagement>/p' $E | grep -c '<dependency>')"
  printf '  <parameters>true</parameters> (the compiler keeps parameter names) %s\n' "$(grep -c '<parameters>true</parameters>' $E)"
  printf '  <goal>repackage</goal> (the executable-jar step, configured) ..... %s\n' "$(grep -c '<goal>repackage</goal>' $E)"
  rm -f $E; }
cap parent parent

# Configured is not bound: where spring-boot-maven-plugin is DECLARED, what the generated jar then holds and starts with,
# and TiffinBox's jar - same parent, plugin not declared - built as shipped from a copy of ../c5-unit01/after.
# labels name TiffinBox, never the frozen folder (its name carries a unit number, contract §R.4)
bind() { for f in "generated/pom.xml|generated/pom.xml" "TiffinBox's root pom.xml|../c5-unit01/after/pom.xml" "TiffinBox's web pom.xml|../c5-unit01/after/tiffinbox-web/pom.xml"; do
    printf 'spring-boot-maven-plugin declared in %-40s %s\n' "${f%%|*}:" "$(grep -c '<artifactId>spring-boot-maven-plugin</artifactId>' "${f#*|}")"; done
  (cd generated && mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1) || { echo "generated build failed"; return; }
  G=generated/target/tiffinbox-0.0.1-SNAPSHOT.jar
  printf 'the generated jar'"'"'s manifest: %s\n' "$(unzip -p $G META-INF/MANIFEST.MF | tr -d '\r' | grep -E '^(Main-Class|Start-Class):' | paste -sd' ' -)"
  (cd generated && mvn -q -B -Dmaven.repo.local="$M2" dependency:list -DincludeScope=runtime -Dsort=true -DoutputFile="$PWD/../.r-deps.txt" > /dev/null 2>&1) || { echo "dependency:list failed"; return; }
  deps=$(grep -E ':(compile|runtime)( |$)' .r-deps.txt | sed 's/^ *//; s/ .*//' | awk -F: '{ print $2 "-" $4 ".jar" }' | sort)
  inside=$(unzip -Z1 $G | grep '^BOOT-INF/lib/.*\.jar$' | sed 's|^BOOT-INF/lib/||' | sort)
  nd=$(echo "$deps" | wc -l | tr -d ' '); ni=$(echo "$inside" | wc -l | tr -d ' ')
  both=$(comm -12 <(echo "$deps") <(echo "$inside") | wc -l | tr -d ' ')
  printf 'the generated jar holds %s jars in BOOT-INF/lib/: %s of its %s run-time dependencies, and %s more: %s\n' "$ni" "$both" "$nd" "$((ni - both))" "$(comm -13 <(echo "$deps") <(echo "$inside") | paste -sd' ' -)"
  out=$(comm -23 <(echo "$deps") <(echo "$inside"))
  printf '  left out: %s - their manifests say: %s\n' "$(echo "$out" | paste -sd' ' -)" "$(for j in $out; do
      p=$(grep -E ":${j%-*}:jar:" .r-deps.txt | sed 's/^ *//; s/ .*//' | awk -F: '{ gsub(/\./, "/", $1); print $1 "/" $2 "/" $4 "/" $2 "-" $4 ".jar" }')
      unzip -p "$M2/$p" META-INF/MANIFEST.MF | tr -d '\r' | grep '^Spring-Boot-Jar-Type:'; done | sort -u | paste -sd' ' -)"
  rm -f .r-deps.txt
  (cd generated/target && java -jar tiffinbox-0.0.1-SNAPSHOT.jar > "$PWD/../../.r-run.log" 2>&1); ec=$?
  printf 'java -jar on the generated jar: exit %s · lines reading "Started TiffinboxApplication": %s\n' "$ec" "$(grep -c 'Started TiffinboxApplication in' .r-run.log)"
  rm -rf generated/target "$W"; mkdir -p "$W"; rsync -a --exclude target ../c5-unit01/after/ "$W/shipped/"
  (cd "$W/shipped" && mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1) || { echo "c5-tiffinbox build failed"; return; }
  T="$W/shipped/tiffinbox-web/target"
  printf 'TiffinBox'"'"'s jar, built as shipped: %s · jars inside it: %s · jars in lib/ beside it: %s\n' \
    "$(unzip -p "$T/tiffinbox-web-1.0.0.jar" META-INF/MANIFEST.MF | tr -d '\r' | grep -E '^(Main-Class|Start-Class):' | paste -sd' ' -)" \
    "$(unzip -Z1 "$T/tiffinbox-web-1.0.0.jar" | grep -c '\.jar$' || true)" "$(ls "$T/lib" | grep -c '\.jar$')"
  rm -rf "$W"; }
cap bind bind

tests() { (cd generated && mvn -B -Dmaven.repo.local="$M2" test 2>&1) | grep -E '^\[(INFO|ERROR)\] Tests run: [0-9]+, Failures: [0-9]+, Errors: [0-9]+, Skipped: [0-9]+$' | tail -1
  printf 'what the one test checks: %s\n' "$(grep -A2 '@Test' generated/src/test/java/com/tiffinbox/TiffinboxApplicationTests.java | tr -s ' \t\n' ' ')"; }
cap tests tests

# The break, as A/B/A': the first request's project (bootVersion=4.1.1), the second's (the site's id, 4.1.1.RELEASE -
# its pom differs in that one line, see `fetches`), then the first again. Kept from each run: the exit code, taken before
# any filter; from B also its [FATAL] line up to "(absent)". The rest of that line describes the local cache - "could not
# find" on a first run, "a previous attempt … was cached" on the next, and offline mode says something else again - so it
# is cut, and the capture is the same cold, warm or offline. Maven's full output for B stays in .r-release.raw, unhashed.
release() { R="$PWD/.r-release.raw"
  (cd generated && mvn -q -B -Dmaven.repo.local="$M2" validate > /dev/null 2>&1); a=$?
  (cd breaks/release-suffix && mvn -q -B -Dmaven.repo.local="$M2" validate > "$R" 2>&1); b=$?
  (cd generated && mvn -q -B -Dmaven.repo.local="$M2" validate > /dev/null 2>&1); a2=$?
  printf 'A   generated/              bootVersion=4.1.1           mvn validate: exit %s\n' "$a"
  printf 'B   breaks/release-suffix/  bootVersion=4.1.1.RELEASE   mvn validate: exit %s\n' "$b"
  awk '/^\[FATAL\] Non-resolvable parent POM/ { i = index($0, " (absent)"); if (i) print "    " substr($0, 1, i + 8) " … [rest of line cut: it describes the local cache]"; else print "    [FATAL] line without (absent)"; exit }' "$R"
  printf 'A′  generated/, run again   bootVersion=4.1.1           mvn validate: exit %s\n' "$a2"; }
cap release release

# The exercise, solved on a copy: ../c5-unit01/after as shipped, then the same with its <h2.version> line deleted - the
# command exercise/README.md gives. Building both also fills .m2-demo with everything that README's commands read.
exercise() { rm -rf "$W"; mkdir -p "$W"
  rsync -a --exclude target ../c5-unit01/after/ "$W/start/"; rsync -a --exclude target ../c5-unit01/after/ "$W/solved/"
  grep -v '<h2.version>' ../c5-unit01/after/pom.xml > "$W/solved/pom.xml"
  for d in start solved; do (cd "$W/$d" && mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1); ec=$?
    v=$(grep -o '<h2.version>[^<]*' "$W/$d/pom.xml" | sed 's/<h2.version>//'); [ -n "$v" ] || v="(line deleted)"
    printf '%-7s pom.xml <h2.version>: %-15s build exit %s · lib/ holds: %s\n' "$d" "$v" "$ec" "$(ls "$W/$d/tiffinbox-web/target/lib" 2>/dev/null | grep '^h2-' | paste -sd' ' -)"; done
  printf "Boot's own BOM, spring-boot-dependencies-4.1.1.pom, line %s\n" "$(grep -n '<h2.version>' "$M2/org/springframework/boot/spring-boot-dependencies/4.1.1/spring-boot-dependencies-4.1.1.pom" | sed 's/:[[:space:]]*/: /')"
  rm -rf "$W"; }
cap exercise exercise
rm -rf generated/target .r-run.log

echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
x site '^  Boot, its default:  id 4\.1\.1\.RELEASE · name 4\.1\.1$'; x site '^  Java, its default:  17 · offered: 27 25 21 17$'
echo "  the site's list: Boot's default is id 4.1.1.RELEASE, name 4.1.1; Java's default is 17 (the request asked for 25)"
x fetches '^site/tiffinbox\.zip +md5 9749d87153c3906da902bd04091d654d  = recorded in REQUEST\.txt$'
x fetches '^site/tiffinbox-bootVersion-4\.1\.1\.RELEASE\.zip +md5 e49c1b51bbbd70580121140471acf45b  = recorded in REQUEST\.txt$'
x fetches '^the two zips hold the same 10 files; the ones that differ: HELP\.md pom\.xml$'
x fetches '^  pom\.xml, lines changed: 1 - <version>4\.1\.1</version> -> <version>4\.1\.1\.RELEASE</version>$'
x fetches '^generated/ against the first zip: 10 of 10 files the same'; x fetches "second zip's pom\.xml: the same$"
echo "  asked twice, both kept: the zips match REQUEST.txt's md5s, generated/ is the first, the break's pom is the second's"
x files '^the generator handed over 10 files:$'; x files '^the parent it names: spring-boot-starter-parent 4\.1\.1$'
x files '^its own dependencies: spring-boot-starter spring-boot-starter-test$'; x files '^java\.version it asked for: 25$'
echo "  10 files; parent spring-boot-starter-parent 4.1.1; two starters; Java 25"
eff=$(sed -n 's/.* is \([0-9][0-9]*\) lines$/\1/p' .r-parent.out); [ "${eff:-0}" -gt 10000 ] || die "parent: the effective POM is not past ten thousand lines (${eff:-none})"
x parent 'picked by the parent \.+ 1911$'; x parent 'parameter names\) [1-9][0-9]*$'; x parent 'configured\) \.+ [1-9][0-9]*$'
echo "  the effective POM is $eff lines: 1911 managed artifacts, -parameters on, repackage configured"
x bind 'declared in generated/pom\.xml: +1$'; x bind "declared in TiffinBox's root pom\\.xml: +0\$"; x bind "declared in TiffinBox's web pom\\.xml: +0\$"
x bind "^the generated jar's manifest: Main-Class: org\.springframework\.boot\.loader\.launch\.JarLauncher Start-Class: com\.tiffinbox\.TiffinboxApplication$"
x bind '^the generated jar holds 20 jars in BOOT-INF/lib/: 19 of its 21 run-time dependencies, and 1 more: spring-boot-jarmode-tools-4\.1\.1\.jar$'
x bind '^  left out: spring-boot-starter-4\.1\.1\.jar spring-boot-starter-logging-4\.1\.1\.jar - their manifests say: Spring-Boot-Jar-Type: dependencies-starter$'
x bind '^java -jar on the generated jar: exit 0 · lines reading "Started TiffinboxApplication": 1$'
x bind "^TiffinBox's jar, built as shipped: Main-Class: com\.tiffinbox\.web\.TiffinBoxServer · jars inside it: 0 · jars in lib/ beside it: [1-9][0-9]*$"
echo "  declared in 1 of the 2 projects: there the jar starts through Boot's launcher and holds 19 of its 21 dependencies"
echo "  (the 2 starters left out); TiffinBox's jar keeps its own Main-Class and holds 0 jars"
x tests 'Tests run: 1, Failures: 0, Errors: 0, Skipped: 0$'; x tests 'void contextLoads\(\) \{ \}'
echo "  the generated test: one test, and it checks only that a context starts"
x release '^A   generated/ .*mvn validate: exit 0$'; x release '^B   breaks/release-suffix/ +bootVersion=4\.1\.1\.RELEASE +mvn validate: exit 1$'
x release '^    \[FATAL\] Non-resolvable parent POM .*spring-boot-starter-parent:pom:4\.1\.1\.RELEASE \(absent\) … '
x release '^A′  generated/, run again .*mvn validate: exit 0$'
echo "  A/B/A': bootVersion=4.1.1 resolves (exit 0), the site's id 4.1.1.RELEASE does not (exit 1), 4.1.1 again (exit 0)"
x exercise '^start   pom\.xml <h2\.version>: 2\.5\.250 .*build exit 0 · lib/ holds: h2-2\.5\.250\.jar$'
x exercise '^solved  pom\.xml <h2\.version>: \(line deleted\) .*build exit 0 · lib/ holds: h2-2\.4\.240\.jar$'
x exercise "^Boot's own BOM, spring-boot-dependencies-4\.1\.1\.pom, line [0-9]+: <h2\.version>2\.4\.240</h2\.version>$"
echo "  the exercise: delete TiffinBox's <h2.version> line and lib/ holds Boot's h2-2.4.240.jar; the build still passes"

if [ -n "$REPUBLISH" ]; then
  for n in site fetches files parent bind tests release exercise; do echo "$n $(md5 -q ".r-$n.out")"; done > receipts.md5
  echo "  receipts.md5 re-published - now regenerate README.md's blocks from the .r-*.out captures"
fi
echo "c5-unit02 receipts: exit 0"

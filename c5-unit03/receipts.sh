#!/bin/bash
# Course 5 · Unit 03's receipts: what a starter contains (a jar with no classes, and a POM), the tree one web starter
# brings, the old web starter's own deprecation line, and the break — a Jackson family split by pinning one member —
# measured on TiffinBox as unit 01 left it (../c5-unit01/after) and fixed (after/, the anchor as this unit leaves it).
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
M2="$PWD/.m2-demo"
JOPTS="-Duser.language=en -Duser.country=US"
die() { echo "  *** $* ***"; exit 1; }
mvnq() { mvn -q -B -Dmaven.repo.local="$M2" "$@"; }
build() { (cd "$1" && mvnq -DskipTests clean package) || die "build failed: $1"; }
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
  if [ -z "$pub" ]; then note="(no published hash)"; elif [ "$pub" = "$h" ]; then note="= published"; else note="DIFFERS from the published $pub"; fi
  printf '  %-10s md5 %s  3/3  %s\n' "$nm" "$h" "$note"; }
BEFORE=../c5-unit01/after; AFTER=after

# A starter, opened: fetch the jar and the old web starter's POM into .jars/ (resolution only; nothing runs).
rm -rf .jars; (cd web && mvnq dependency:copy -Dartifact=org.springframework.boot:spring-boot-starter:4.1.1 -DoutputDirectory=../.jars \
  && mvnq dependency:copy -Dartifact=org.springframework.boot:spring-boot-starter-web:4.1.1:pom -DoutputDirectory=../.jars) > /dev/null || die "could not resolve the starters"
starter() { printf 'spring-boot-starter-4.1.1.jar - every entry:\n'
  unzip -Z1 .jars/spring-boot-starter-4.1.1.jar | sed 's/^/  /'
  printf '.class files in it: %s\n' "$(unzip -Z1 .jars/spring-boot-starter-4.1.1.jar | grep -c '\.class$' || true)"
  printf 'spring-boot-starter-web-4.1.1.pom, its own description:\n  %s\n' "$(grep -o '<description>[^<]*' .jars/spring-boot-starter-web-4.1.1.pom | sed 's/<description>//')"; }
cap starter starter

# The web starter's tree: compile scope only (the project has no test dependency at all).
tree() { (cd web && mvn -B -Dmaven.repo.local="$M2" dependency:tree 2>&1) | grep -E '^\[INFO\] ([|+\\ ]+[-\\] |com\.tiffinbox)' | sed 's/^\[INFO\] //'
  (cd web && mvn -B -Dmaven.repo.local="$M2" dependency:tree 2>&1) | grep -cE '^\[INFO\] [|+\\ ]+[-\\] ' | sed 's/^/jars in the tree: /'; }
cap tree tree

# The break and the fix: which Jackson versions TiffinBox actually runs with, and the seven responses after the fix.
build "$BEFORE"; build "$AFTER"
jackson() { for t in "unit 01 (jackson-databind pinned alone)|$BEFORE" "unit 03 (jackson-2-bom.version set)|$AFTER"; do
    printf '%s: %s\n' "${t%%|*}" "$(ls "${t#*|}"/tiffinbox-web/target/lib | grep '^jackson-' | paste -sd' ' -)"; done; }
cap jackson jackson
serve() { java $JOPTS -jar "$AFTER/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" 18541 > .r-serve.log 2>&1 & pid=$!
  for i in $(seq 1 60); do curl -s -o /dev/null "http://127.0.0.1:18541/kitchen" && break; sleep 0.25; done
  ../c4-unit31/curlset.sh 18541 | grep ' -> ' | md5 -q | sed 's/^/the seven responses after the fix: md5 /'
  wait "$pid"; echo "server exit $?"; }
cap responses serve

echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
x starter '^\.class files in it: 0$'; [ "$(grep -c '^  ' .r-starter.out)" -le 6 ] || die "starter: more entries than a manifest and two notices"
x starter 'deprecated in favor of spring-boot-starter-webmvc'
echo "  a starter jar holds no class at all; the old web starter's own POM says it is deprecated"
x tree '^com\.tiffinbox:c5-unit03-web:jar:1\.0\.0$'; x tree 'tools\.jackson\.core:jackson-databind:jar:3\.'; x tree 'com\.fasterxml\.jackson\.core:jackson-annotations:jar:2\.'
x tree 'spring-boot-starter-tomcat'; x tree '^jars in the tree: [0-9]+$'
echo "  one web starter: $(grep -o '[0-9]*$' .r-tree.out | tail -1) jars; Jackson 3 (tools.jackson) with the 2.x annotations"
x jackson '^unit 01 \(jackson-databind pinned alone\): jackson-annotations-2\.21\.jar jackson-core-2\.21\.5\.jar jackson-databind-2\.22\.2\.jar$'
x jackson '^unit 03 \(jackson-2-bom\.version set\): jackson-annotations-2\.22\.jar jackson-core-2\.22\.2\.jar jackson-databind-2\.22\.2\.jar$'
x responses 'md5 115c36bac276128e245ca57df11c2891$'; x responses '^server exit 0$'
echo "  the break: databind 2.22.2 beside core 2.21.5; the fix moves the family together - and the seven responses are unchanged"

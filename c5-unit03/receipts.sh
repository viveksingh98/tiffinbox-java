#!/bin/bash
# Course 5 · Starters, opened. What a starter contains (a jar with no classes, and a POM) · the tree one web starter
# brings · how the old web starter says it is deprecated, beside the relocation Maven would have printed · what the
# Jackson 3 that starter brings does to Course 2's own Jackson examples · the break: a Jackson family split by pinning
# one member, fixed with a property that only steers Boot's list because TiffinBox INHERITS it.
# TiffinBox is measured as unit 01 left it (../c5-unit01/after, copied to target/before and built there, so these
# receipts never write into another unit's folder) and as this unit leaves it (after/, the frozen anchor).
#   ./receipts.sh             every capture three times; dies on drift, on a failed check, or on a published-md5 mismatch
#   ./receipts.sh --publish   the same, then writes receipts.md5 from these captures (only when the video changes)
set -e
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd "$(dirname "$0")"
PUBLISH=; [ "${1:-}" = "--publish" ] && PUBLISH=1
M2="$PWD/.m2-demo"
JOPTS="-Duser.language=en -Duser.country=US"
DEP=org.apache.maven.plugins:maven-dependency-plugin:3.10.0   # the version Boot 4.1.1's parent manages, named in full
die() { echo "  *** $* ***"; exit 1; }
mvnq() { mvn -q -B -Dmaven.repo.local="$M2" "$@"; }
rm -f .r-md5.new
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  if [ -n "$PUBLISH" ]; then echo "$nm $h" >> .r-md5.new; note="(publishing)"
  else pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
    [ -n "$pub" ] || die "$nm: receipts.md5 has no published hash for this capture"
    if [ "$pub" != "$h" ]; then
      printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
      die "$nm is not the capture the video shows - suspect an edited file here, another JDK or Maven, or a version resolved differently; compare .r-$nm.out with README.md"
    fi; note="= published"; fi
  printf '  %-10s md5 %s  3/3  %s\n' "$nm" "$h" "$note"; }

# ---- resolution (nothing below this block touches the network) -------------------------------------------------------
# The core starter's jar and the old web starter's POM (to open them), every jar of the one-starter web tree (so the
# starters it names sit in .m2-demo), and the two Jackson generations Course 2's examples are compiled against.
rm -rf .jars; mkdir -p .jars
(cd web && mvnq dependency:copy -Dartifact=org.springframework.boot:spring-boot-starter:4.1.1 -DoutputDirectory=../.jars \
  && mvnq dependency:copy -Dartifact=org.springframework.boot:spring-boot-starter-web:4.1.1:pom -DoutputDirectory=../.jars \
  && mvnq dependency:resolve) > /dev/null || die "could not resolve the starters"
for a in com.fasterxml.jackson.core:jackson-databind:2.22.2 com.fasterxml.jackson.core:jackson-core:2.22.2 \
         com.fasterxml.jackson.core:jackson-annotations:2.22; do
  (cd web && mvnq dependency:copy -Dartifact="$a" -DoutputDirectory=../.jars/jackson2) > /dev/null || die "could not resolve $a"; done
for a in tools.jackson.core:jackson-databind:3.1.5 tools.jackson.core:jackson-core:3.1.5 \
         com.fasterxml.jackson.core:jackson-annotations:2.21; do
  (cd web && mvnq dependency:copy -Dartifact="$a" -DoutputDirectory=../.jars/jackson3) > /dev/null || die "could not resolve $a"; done
# Maven's own relocation, for comparison: two tiny POMs placed in .m2-demo, as `mvn install` would place them.
for a in old-starter new-starter; do mkdir -p "$M2/com/example/$a/1.0"; cp "harness/relocation/$a-1.0.pom" "$M2/com/example/$a/1.0/"; done
# "Before" is unit 01's frozen tree: copied here, built here.
rm -rf target/before; mkdir -p target; rsync -a --exclude target ../c5-unit01/after/ target/before/

# ---- A starter, opened ---------------------------------------------------------------------------------------------
starter() { printf 'spring-boot-starter-4.1.1.jar - every entry:\n'
  unzip -Z1 .jars/spring-boot-starter-4.1.1.jar | sed 's/^/  /'
  printf '.class files in it: %s\n' "$(unzip -Z1 .jars/spring-boot-starter-4.1.1.jar | grep -c '\.class$' || true)"
  printf 'spring-boot-starter-web-4.1.1.pom, its own description:\n  %s\n' "$(grep -o '<description>[^<]*' .jars/spring-boot-starter-web-4.1.1.pom | sed 's/<description>//')"; }
cap starter starter

# Every Boot starter jar this unit's repository holds, and the .class files in each (not only the one opened above).
starters() { printf 'every Boot starter jar in .m2-demo, and the .class files in it:\n'
  n=0; k=0
  for j in $(cd "$M2/org/springframework/boot" && find . -name 'spring-boot-starter*.jar' | awk -F/ '{ print $NF "\t" $0 }' | LC_ALL=C sort | cut -f2); do
    c=$(unzip -Z1 "$M2/org/springframework/boot/$j" | grep -c '\.class$' || true)
    printf '  %-46s %s\n' "${j##*/}" "$c"; n=$((n+1)); [ "$c" = 0 ] || k=$((k+1)); done
  printf 'starter jars: %s · with a .class file: %s\n' "$n" "$k"; }
cap starters starters

# ---- The web starter's tree (compile scope only: the project has no test dependency at all) -------------------------
tree() { (cd web && mvn -B -Dmaven.repo.local="$M2" dependency:tree 2>&1) > target/tree.log || true
  grep -E '^\[INFO\] ([|+\\ ]+[-\\] |com\.tiffinbox)' target/tree.log | sed 's/^\[INFO\] //'
  printf 'jars in the tree: %s\n' "$(grep -cE '^\[INFO\] [|+\\ ]+[-\\] ' target/tree.log || true)"; }
cap tree tree

# ---- Deprecated in words, or relocated: what each prints in a build -------------------------------------------------
relocate() {
  (cd harness/relocation/uses-old-starter && mvn -B -Dmaven.repo.local="$M2" "$DEP:tree" 2>&1) > target/reloc.log || true
  grep -E '^\[INFO\] com\.tiffinbox' target/reloc.log | sed 's/^\[INFO\] //'
  grep -E '^\[WARNING\] ' target/reloc.log | LC_ALL=C sort -u
  grep -E '^\[INFO\] [|+\\ ]+[-\\] ' target/reloc.log | sed 's/^\[INFO\] //'
  (cd harness/relocation/uses-starter-web && mvn -B -Dmaven.repo.local="$M2" "$DEP:tree" 2>&1) > target/web.log || true
  grep -E '^\[INFO\] com\.tiffinbox' target/web.log | sed 's/^\[INFO\] //'
  grep -E '^\[INFO\] [-\\]- ' target/web.log | sed 's/^\[INFO\] //'
  printf 'in that whole build: [WARNING] lines %s · lines containing "deprecated" %s · %s\n' \
    "$(grep -c '^\[WARNING\]' target/web.log || true)" "$(grep -ci 'deprecated' target/web.log || true)" "$(grep -o 'BUILD [A-Z]*' target/web.log)"; }
cap relocate relocate

# ---- Course 2's own Jackson examples, compiled against Jackson 2 and against Jackson 3 ------------------------------
# All five of Course 2's Jackson sources are read from Course 2's folder, never copied into this one, plus this unit's
# two small files (harness/course2: JsonOops's strict read on its own, and the LocalDate of Course 2's closing card).
# The Jackson 3 copies differ ONLY in package names (the sed below; the annotations package does not move), and the
# capture counts the lines that move changed, so you can see nothing else did. JsonOops.java is compiled on its own:
# it holds the lenient line. The last line checks that nothing else in Course 2's folder changes behaviour.
C2=../c2-unit29/src/main/java/com/tiffinbox
cps() { ls .jars/jackson$1/*.jar | paste -sd: -; }
course2() { rm -rf target/course2
  for v in 2 3; do d=target/course2/jackson$v; mkdir -p "$d/src"
    for f in "$C2"/*.java harness/course2/*.java; do
      if [ $v = 2 ]; then cp "$f" "$d/src/"
      else sed -e 's/com\.fasterxml\.jackson\.databind/tools.jackson.databind/g' -e 's/com\.fasterxml\.jackson\.core/tools.jackson.core/g' "$f" > "$d/src/${f##*/}"; fi
    done
    javac -d "$d/classes" -cp "$(cps $v)" $(ls "$d"/src/*.java | grep -v '/JsonOops\.java$') > "$d/javac-rest.out" 2>&1
    echo $? > "$d/javac-rest.exit"
  done
  moved=$(for f in target/course2/jackson2/src/*.java; do diff "$f" "target/course2/jackson3/src/${f##*/}" || true; done | grep '^>' || true)
  printf 'the package move changed %s lines in %s files; lines that are not an import: %s\n' \
    "$(printf '%s\n' "$moved" | grep -c '^>' || true)" "$(ls target/course2/jackson2/src/*.java | wc -l | tr -d ' ')" \
    "$(printf '%s\n' "$moved" | grep '^>' | grep -vc '^> import ' || true)"
  for v in 2 3; do java $JOPTS -cp "target/course2/jackson$v/classes:$(cps $v)" com.tiffinbox.Strict; done
  for v in 2 3; do d=target/course2/jackson$v; db=$(ls .jars/jackson$v | grep '^jackson-databind')
    if javac -d "$d/oops" -cp "$d/classes:$(cps $v)" "$d/src/JsonOops.java" > "$d/javac.out" 2>&1; then
      printf "Course 2's JsonOops.java with %s: javac exit 0 · it runs: %s\n" "$db" \
        "$(java $JOPTS -cp "$d/oops:$d/classes:$(cps $v)" com.tiffinbox.JsonOops | tail -1)"
    else rc=$?
      printf "Course 2's JsonOops.java with %s: javac exit %s · %s · %s · %s · %s\n" "$db" "$rc" \
        "$(grep -o 'error: .*' "$d/javac.out" | head -1)" "$(grep 'symbol:' "$d/javac.out" | sed 's/^ *//; s/  */ /g' | head -1)" \
        "$(grep 'location:' "$d/javac.out" | sed 's/^ *//; s/  */ /g' | head -1)" "$(tail -1 "$d/javac.out")"
    fi; done
  for v in 2 3; do java $JOPTS -cp "target/course2/jackson$v/classes:$(cps $v)" com.tiffinbox.Dates; done
  for v in 2 3; do java $JOPTS -cp "target/course2/jackson$v/classes:$(cps $v)" com.tiffinbox.Json > "target/course2/json$v.out" 2>&1; done
  printf "the rest of Course 2's Jackson files - %s - javac exit %s on Jackson 2, %s on Jackson 3 · Json's whole output, 2 against 3: %s\n" \
    "$(ls "$C2"/*.java | sed 's|.*/||' | grep -vE '^(Customer|JsonOops)\.java$' | paste -sd, - | sed 's/,/, /g')" \
    "$(cat target/course2/jackson2/javac-rest.exit)" "$(cat target/course2/jackson3/javac-rest.exit)" \
    "$(cmp -s target/course2/json2.out target/course2/json3.out && echo identical || echo DIFFERENT)"; }
cap course2 course2

# ---- The break and the fix: A / B / A′ (A′ = A, built again) -------------------------------------------------------
BEFORE=target/before; AFTER=after
build() { (cd "$1" && mvn -B -Dmaven.repo.local="$M2" -DskipTests clean package 2>&1) > target/build.log || true
  grep -q 'BUILD SUCCESS' target/build.log || echo "BUILD FAILED: $1"; }
jackson() { for t in "A|$BEFORE|before the fix (jackson-databind pinned alone)" "B|$AFTER|after the fix (jackson-2-bom.version set)" \
                     "A′|$BEFORE|before the fix, built again"; do
    IFS='|' read -r lab dir what <<< "$t"; build "$dir"
    printf '%s  %s: %s · build warnings %s\n' "$lab" "$what" "$(ls "$dir/tiffinbox-web/target/lib" | grep '^jackson-' | paste -sd' ' -)" \
      "$(grep -c '^\[WARNING\]' target/build.log || true)"; done; }
cap jackson jackson

# Why the property works: Boot's list INHERITED (TiffinBox's way) against the same list IMPORTED. A / B / A′.
steer() { for t in "A|inherits-parent" "B|imports-bom" "A′|inherits-parent"; do IFS='|' read -r lab p <<< "$t"
    (cd "harness/$p" && mvn -B -Dmaven.repo.local="$M2" "$DEP:tree" 2>&1) > target/steer.log || true
    printf '%s  %s · %s -> %s\n' "$lab" "$(grep -E '^\[INFO\] com\.tiffinbox' target/steer.log | sed 's/^\[INFO\] //')" \
      "$(grep -o '<jackson-2-bom.version>[^<]*</jackson-2-bom.version>' "harness/$p/pom.xml")" \
      "$(grep -oE 'com\.fasterxml\.jackson\.core:jackson-databind:jar:[^ ]+' target/steer.log | head -1)"; done; }
cap steer steer

# The seven responses, both sides of the fix: nothing complained, and nothing changed.
serve() { printf '%s  %s: ' "$1" "$2"
  java $JOPTS -jar "$3/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" "$4" > "target/serve-$4.log" 2>&1 & pid=$!
  for i in $(seq 1 60); do curl -s -o /dev/null "http://127.0.0.1:$4/kitchen" && break; sleep 0.25; done
  ../c4-unit31/curlset.sh "$4" | grep ' -> ' > "target/responses-$4.txt"
  printf '%s lines  md5 %s  ' "$(wc -l < "target/responses-$4.txt" | tr -d ' ')" "$(md5 -q "target/responses-$4.txt")"
  wait "$pid"; echo "server exit $?"; }
responses() { serve A "before the fix (the split family)" "$BEFORE" 18540; serve B "after the fix (one family)" "$AFTER" 18541; }
cap responses responses

# ---- every number the video speaks, asserted -------------------------------------------------------------------------
echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
[ "$(sed -n '2,5p' .r-starter.out | paste -sd' ' -)" = "  META-INF/   META-INF/MANIFEST.MF   META-INF/LICENSE.txt   META-INF/NOTICE.txt" ] \
  && [ "$(sed -n 6p .r-starter.out)" = ".class files in it: 0" ] || die "starter: not exactly a folder, a manifest, a licence and a notice, and 0 classes"
x starter 'deprecated in favor of spring-boot-starter-webmvc\)$'
x starters '^starter jars: 6 · with a \.class file: 0$'
[ "$(grep -cE '^  spring-boot-starter[a-z-]*-4\.1\.1\.jar +0$' .r-starters.out)" = 6 ] || die "starters: six rows of 0 expected"
echo "  a starter jar holds a folder, a manifest, a licence and a notice - 0 classes; all 6 Boot starters in .m2-demo: 0"
x tree '^com\.tiffinbox:one-starter-web:jar:1\.0\.0$'; x tree '^jars in the tree: 39$'
x tree '\\- tools\.jackson\.core:jackson-databind:jar:3\.1\.5:compile$'
x tree 'com\.fasterxml\.jackson\.core:jackson-annotations:jar:2\.21:compile$'; x tree 'spring-boot-starter-tomcat:jar:4\.1\.1'
echo "  one web starter: 39 jars; Jackson 3.1.5 (tools.jackson) with the 2.x annotations"
x relocate '^\[WARNING\] The artifact com\.example:old-starter:jar:1\.0 has been relocated to com\.example:new-starter:jar:1\.0: deprecated in favor of new-starter$'
x relocate '^\\- com\.example:new-starter:jar:1\.0:compile$'; x relocate '^\\- org\.springframework\.boot:spring-boot-starter-web:jar:4\.1\.1:compile$'
x relocate '^in that whole build: \[WARNING\] lines 0 · lines containing "deprecated" 0 · BUILD SUCCESS$'
echo "  a relocated POM: Maven warns and swaps in the new artifact; spring-boot-starter-web: 0 warnings, 0 mentions"
x course2 '^the package move changed [0-9]+ lines in 7 files; lines that are not an import: 0$'
x course2 "^the rest of Course 2's Jackson files - Json\\.java, MapperCost\\.java, Unchecked\\.java - javac exit 0 on Jackson 2, 0 on Jackson 3 · Json's whole output, 2 against 3: identical$"
x course2 '^Jackson 2\.22\.2  new ObjectMapper\(\): FAIL_ON_UNKNOWN_PROPERTIES true  an unknown field -> UnrecognizedPropertyException$'
x course2 '^Jackson 3\.1\.5  new ObjectMapper\(\): FAIL_ON_UNKNOWN_PROPERTIES false  an unknown field -> read Ravi -> 7200$'
x course2 "^Course 2's JsonOops\.java with jackson-databind-2\.22\.2\.jar: javac exit 0 · it runs: lenient mapper: Ravi -> 7200$"
x course2 "^Course 2's JsonOops\.java with jackson-databind-3\.1\.5\.jar: javac exit 1 · error: cannot find symbol · symbol: method configure\(DeserializationFeature,boolean\) · location: class ObjectMapper · 1 error$"
x course2 '^Jackson 2\.22\.2  a LocalDate, no extra module -> InvalidDefinitionException$'
x course2 '^Jackson 3\.1\.5  a LocalDate, no extra module -> \{"name":"Ravi","from":"2026-09-27"\}$'
echo "  Course 2's examples on Jackson 3: the unknown field is read, the lenient line does not compile, LocalDate needs no module"
x jackson '^A  before the fix \(jackson-databind pinned alone\): jackson-annotations-2\.21\.jar jackson-core-2\.21\.5\.jar jackson-databind-2\.22\.2\.jar · build warnings 0$'
x jackson '^B  after the fix \(jackson-2-bom\.version set\): jackson-annotations-2\.22\.jar jackson-core-2\.22\.2\.jar jackson-databind-2\.22\.2\.jar · build warnings 0$'
x jackson '^A′  before the fix, built again: jackson-annotations-2\.21\.jar jackson-core-2\.21\.5\.jar jackson-databind-2\.22\.2\.jar · build warnings 0$'
x steer '^A  com\.tiffinbox:inherits-parent:jar:1\.0\.0 · <jackson-2-bom\.version>2\.22\.2</jackson-2-bom\.version> -> com\.fasterxml\.jackson\.core:jackson-databind:jar:2\.22\.2:compile$'
x steer '^B  com\.tiffinbox:imports-bom:jar:1\.0\.0 · <jackson-2-bom\.version>2\.22\.2</jackson-2-bom\.version> -> com\.fasterxml\.jackson\.core:jackson-databind:jar:2\.21\.5:compile$'
x steer '^A′  com\.tiffinbox:inherits-parent:jar:1\.0\.0 · <jackson-2-bom\.version>2\.22\.2</jackson-2-bom\.version> -> com\.fasterxml\.jackson\.core:jackson-databind:jar:2\.22\.2:compile$'
x responses '^A  before the fix \(the split family\): 7 lines  md5 115c36bac276128e245ca57df11c2891  server exit 0$'
x responses '^B  after the fix \(one family\): 7 lines  md5 115c36bac276128e245ca57df11c2891  server exit 0$'
echo "  the break: databind 2.22.2 beside core 2.21.5, 0 warnings, twice; the property moves all three to 2.22 - because"
echo "  TiffinBox inherits Boot's list (imported, the same property leaves databind on 2.21.5); 7 responses, one md5, both sides"
if [ -n "$PUBLISH" ]; then mv .r-md5.new receipts.md5; echo "  receipts.md5 written"; fi

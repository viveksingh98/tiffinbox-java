#!/bin/bash
# Course 5 · Unit 04's receipts: one annotation (@EnableAutoConfiguration) on TiffinBox, and what it did — counted,
# entry by entry against the imports file, traced to the row-2 hook by taking that hook out, and counted again on the
# smallest web application. "before" is ../c5-unit03/after (the anchor as unit 03 left it); after/ is this unit's frozen
# copy of the anchor. Every number the video says asserted.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
M2="$PWD/.m2-demo"
JOPTS="-Duser.language=en -Duser.country=US"
die() { echo "  *** $* ***"; exit 1; }
build() { (cd "$1" && mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package) || die "build failed: $1"; }
jars() { echo "$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$1"/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"; }
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
  if [ -z "$pub" ]; then note="(no published hash)"; elif [ "$pub" = "$h" ]; then note="= published"; else note="DIFFERS from the published $pub"; fi
  printf '  %-9s md5 %s  3/3  %s\n' "$nm" "$h" "$note"; }
# Boot's own log lines (time, pid) are not part of any claim here: drop them, and count what was dropped.
quiet() { awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { b++; next } /^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9][0-9][0-9][0-9] / { j++; next } /^(INFO|WARNING): / { j++; next } { print }
               END { printf "… %d Boot log line(s), %d JUL line(s) elided …\n", b, j }'; }
BEFORE=../c5-unit03/after; AFTER=after

build "$BEFORE"; build "$AFTER"
rm -rf .harness; "$JAVA_HOME/bin/javac" -cp "$(jars "$AFTER")" -d .harness harness/com/tiffinbox/harness/AutoConfig.java
count() { for t in "$BEFORE|18542" "$AFTER|18543"; do java $JOPTS -cp ".harness:$(jars "${t%|*}")" com.tiffinbox.harness.AutoConfig count "${t#*|}" 2>&1 | quiet; done; }
cap count count
path() { java $JOPTS -cp ".harness:$(jars "$AFTER")" com.tiffinbox.harness.AutoConfig path 18544 2>&1 | quiet
         java $JOPTS -cp ".harness:$(jars "$AFTER")" com.tiffinbox.harness.AutoConfig sba 18545 2>&1 | quiet; }
cap path path
(cd webapp && mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime) || die "webapp build failed"
web() { (cd webapp && java $JOPTS -cp "target/classes:$(cat .cp)" com.tiffinbox.webapp.CountApp 2>&1) | quiet; }
cap web web
serve() { java $JOPTS -jar "$AFTER/tiffinbox-web/target/tiffinbox-web-1.0.0.jar" 18546 > .r-serve.log 2>&1 & pid=$!
  for i in $(seq 1 60); do curl -s -o /dev/null "http://127.0.0.1:18546/kitchen" && break; sleep 0.25; done
  ../c4-unit31/curlset.sh 18546 | grep ' -> ' | md5 -q | sed 's/^/the seven responses with auto-configuration on: md5 /'
  wait "$pid"; echo "server exit $?"; }
cap responses serve

echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
x count '^@EnableAutoConfiguration on TiffinBoxApp: false$'; x count '^@EnableAutoConfiguration on TiffinBoxApp: true$'
x count 'definitions in all: 12 · yours 6 · listed auto-configuration classes registered 0 · everything else 6$'
listed=$(grep -m1 -o 'classes the imports files list: [0-9]*' .r-count.out | grep -o '[0-9]*$'); reg=$(awk '/TiffinBoxApp: true/{f=1} f && /^    registered /' .r-count.out | wc -l | tr -d ' ')
[ "$listed" = 12 ] || die "count: expected 12 listed classes on TiffinBox's class path, got $listed"
x count "yours 6 · listed auto-configuration classes registered $reg · "
echo "  one annotation: 12 -> $(grep -o 'definitions in all: [0-9]*' .r-count.out | tail -1 | grep -o '[0-9]*$') definitions; the file lists 12, $reg registered, $((12 - reg)) not used"
x path '@Import\(AutoConfigurationImportSelector\)$'; x path 'is a DeferredImportSelector: true$'
x path 'without ConfigurationClassPostProcessor: definitions [0-9]+ · auto-configuration classes 0$'
x path '@SpringBootApplication carries: \[SpringBootConfiguration, EnableAutoConfiguration, ComponentScan\]$'
echo "  the path: @Import(AutoConfigurationImportSelector), a deferred import; without the row-2 hook, 0 auto-configuration"
x web 'imports files [0-9]+ · classes listed [0-9]+ · bean definitions [0-9]+$'
echo "  the smallest web app: $(grep -o 'imports files .*' .r-web.out)"
x responses 'md5 115c36bac276128e245ca57df11c2891$'; x responses '^server exit 0$'
echo "  and the seven responses are unchanged"

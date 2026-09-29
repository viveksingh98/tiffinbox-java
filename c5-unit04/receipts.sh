#!/bin/bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
# Course 5 · Auto-Configuration, Mechanism First — this unit's receipts. One annotation (@EnableAutoConfiguration) on
# TiffinBox, and what it did: counted; compared definition by definition ("added, not edited"); the imports file printed
# as it ships, each entry marked registered or not beside Boot's OWN condition verdict; traced to the row-2 hook by taking
# that hook out (A/B/A': three runs of one program, with a class loader that writes down who opens the file); the
# annotations opened; @SpringBootApplication swapped in (it fails - the break); the smallest web application counted.
# "before" is ../c5-unit03/after (the anchor as unit 03 left it), COPIED to .harness/before and built there, so this unit
# never writes into another unit's folder; after/ is this unit's frozen copy of the anchor.
# Every number the video speaks is asserted below, and cap() dies when a capture differs from receipts.md5.
# Ports (contract §R.10, 18542-18549): count 18542/18543 · hook 18544 · swap 18545 · serve 18546 · exercise 18547 ·
# defs 18548 · web 18549. Maven runs offline when .m2-demo already holds everything, and resolves once if it does not.
set -e
cd "$(dirname "$0")"
M2="$PWD/.m2-demo"
JOPTS="-Duser.language=en -Duser.country=US"
die() { echo "  *** $* ***"; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 expected, found: $(java -version 2>&1 | head -1)"
mvnq() { mvn -o -q -B -Dmaven.repo.local="$M2" "$@" > /dev/null 2>&1 || mvn -q -B -Dmaven.repo.local="$M2" "$@"; }
build() { (cd "$1" && mvnq -DskipTests clean package) || die "build failed: $1"; }
jars() { echo "$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$1"/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"; }
# cap NAME CMD...: three runs, one md5 or nothing. A capture that differs from the published receipts.md5 is printed
# first (so you can see which), and then the script DIES: the panel on screen is not what this machine produced.
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  if [ ! -f receipts.md5 ]; then printf '  %-9s md5 %s  3/3  (no receipts.md5 here: nothing published to compare)\n' "$nm" "$h"; return; fi
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5)
  if [ "$pub" = "$h" ]; then printf '  %-9s md5 %s  3/3  = published\n' "$nm" "$h"; return; fi
  printf '  %-9s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "${pub:-(none)}"
  die "$nm is not the capture the video shows - suspect the JDK, the Boot version, a port, or an edited source; diff .r-$nm.out with the panel"; }
# Boot's own log lines (they carry a time and a pid) are not part of any claim here: drop them, and count what was dropped.
quiet() { awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { b++; next } /^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9][0-9][0-9][0-9] / { j++; next } /^(INFO|WARNING): / { j++; next } { print }
               END { printf "… %d Boot log line(s), %d JUL line(s) elided …\n", b, j }'; }
BEFORE=.harness/before; AFTER=after; SWAP=.harness/swap
IMPORTS=META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports

rm -rf .harness; mkdir -p "$BEFORE" "$SWAP"
rsync -a --exclude target ../c5-unit03/after/ "$BEFORE"/
rsync -a --exclude target "$AFTER"/ "$SWAP"/
cp breaks/springbootapplication/TiffinBoxApp.java "$SWAP"/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
# before and after are one annotation apart and nothing else: every file identical but TiffinBoxApp.java, and there the
# only lines of code added are the import and @EnableAutoConfiguration (its comment lines aside; nothing removed).
APPJ=tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
[ "$(diff -rq -x target -x README.md "$BEFORE" "$AFTER" | wc -l | tr -d ' ')" = 1 ] || die "before and after differ beyond $APPJ"
[ "$(diff "$BEFORE/$APPJ" "$AFTER/$APPJ" | grep '^[<>]' | grep -v '^> *\*' | tr '\n' '|')" = \
  "> import org.springframework.boot.autoconfigure.EnableAutoConfiguration;|> @EnableAutoConfiguration|" ] || die "$APPJ: more changed than one annotation"
build "$BEFORE"; build "$AFTER"; build "$SWAP"
javac -cp "$(jars "$AFTER")" -d .harness harness/com/tiffinbox/harness/AutoConfig.java
harness() { t=$1; shift; java $JOPTS -cp ".harness:$(jars "$t")" com.tiffinbox.harness.AutoConfig "$@"; }

count() { harness "$BEFORE" count 18542 2>&1 | quiet; harness "$AFTER" count 18543 2>&1 | quiet; }
cap count count
imports() { unzip -p "$AFTER"/tiffinbox-web/target/lib/spring-boot-autoconfigure-4.1.1.jar "$IMPORTS"; }
cap imports imports
# added: every definition of the run WITHOUT the annotation, compared field by field with the run WITH it.
# the mask (the one in this unit): "read from" names the jar by its absolute path, which differs by tree; gsub keeps
# everything from the tree's own tiffinbox-web/target/ on, so the two trees compare on what they contain.
defs() { harness "$1" defs 18548 2>&1 | grep ' | ' | awk '{ gsub(/jar:file:[^!]*\/tiffinbox-web\/target\//, "jar:file:<tree>/tiffinbox-web/target/"); print }'; }
added() { defs "$BEFORE" > .harness/defs.before; defs "$AFTER" > .harness/defs.after; imports > .harness/imports.list
  awk -F' [|] ' -v L=.harness/imports.list '
    BEGIN { while ((getline l < L) > 0) listed[l] = 1 }
    FNR == NR { old[$1] = $0; b++; next }
    { a++; if ($1 in old) { seen[$1] = 1; if (old[$1] == $0) same++; else changed++ }
           else { fresh++; kind[$2]++; if ($2 == "configuration class" && ($1 in listed)) named++ } }
    END { for (n in old) if (!(n in seen)) gone++
          printf "definitions: before %d · after %d\n", b, a
          printf "the %d from before, compared field by field after: identical %d · changed %d · gone %d\n", b, same, changed, gone
          printf "new %d: configuration classes %d (named in the file %d · imported by those %d) · @Bean methods %d · registered by code %d\n",
                 fresh, kind["configuration class"], named, kind["configuration class"] - named, kind["@Bean method"], kind["registered by code"] }' \
    .harness/defs.before .harness/defs.after; }
cap added added
hook() { for r in "kept A" "removed B" "kept A′"; do harness "$AFTER" hook "${r% *}" 18544 "${r#* }" 2>&1 | quiet; done; }
cap hook hook
opened() { harness "$AFTER" opened 2>&1; }
cap opened opened
# the break: the one-annotation TiffinBoxApp, run exactly as TiffinBox always runs, port first. Hashed: the trio (exit
# code · the exception's type · the first line of Boot's description), never the raw log, which carries times and paths.
swap() { ec=0; java $JOPTS -jar "$SWAP"/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18545 > .harness/swap.log 2>&1 || ec=$?
  echo "exit $ec"
  grep -m1 -o 'APPLICATION FAILED TO START' .harness/swap.log || echo "(no failure banner)"
  grep -m1 -oE 'org\.springframework\.[A-Za-z.]+Exception' .harness/swap.log || echo "(no exception type)"
  grep -m1 '^Parameter 0 of constructor' .harness/swap.log || echo "(no description line)"; }
cap swap swap
(cd webapp && mvnq -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime) || die "webapp build failed"
web() { (cd webapp && java $JOPTS -cp "target/classes:$(cat .cp)" com.tiffinbox.webapp.CountApp 2>&1) | quiet; }
cap web web
serve() { java $JOPTS -jar "$AFTER"/tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18546 > .r-serve.log 2>&1 & pid=$!
  for i in $(seq 1 60); do curl -s -o /dev/null "http://127.0.0.1:18546/kitchen" && break; sleep 0.25; done
  ../c4-unit31/curlset.sh 18546 | grep ' -> ' > .harness/responses.txt
  echo "the responses with auto-configuration on: $(wc -l < .harness/responses.txt | tr -d ' ') · md5 $(md5 -q .harness/responses.txt)"
  wait "$pid"; echo "server exit $?"; }
cap responses serve

echo
# x NAME LINE: that exact line is in the capture. n NAME COUNT PATTERN: the pattern matches exactly COUNT lines.
x() { grep -qxF -- "$2" ".r-$1.out" || die "$1: expected the line [$2]"; }
n() { c=$(grep -cE -- "$3" ".r-$1.out" || true); [ "$c" = "$2" ] || die "$1: expected $2 line(s) matching /$3/, found $c"; }
x count '@EnableAutoConfiguration on TiffinBoxApp: false'
x count '  definitions in all: 12 · yours 6 · listed auto-configuration classes registered 0 · everything else 6'
x count "  classes the imports files list: 12 · in Boot's report 0: unconditional 0 · guarded by a condition 0 (held 0 · failed 0)"
x count '@EnableAutoConfiguration on TiffinBoxApp: true'
x count '  definitions in all: 55 · yours 6 · listed auto-configuration classes registered 9 · everything else 40'
x count "  classes the imports files list: 12 · in Boot's report 12: unconditional 6 · guarded by a condition 6 (held 3 · failed 3)"
x count '  of the 0 unconditional, with a condition on one of their own @Bean methods: 0'
x count '  of the 6 unconditional, with a condition on one of their own @Bean methods: 5'
n count 12 '^    not used    not evaluated     [A-Za-z]+AutoConfiguration$'
n count 6 '^    registered  unconditional     [A-Za-z]+AutoConfiguration$'
n count 3 '^    registered  condition held    [A-Za-z]+AutoConfiguration$'
n count 3 '^    not used    condition failed  (SpringApplicationAdminJmx|MessageSource|Jmx)AutoConfiguration$'
n count 0 '^    not used    unconditional'
n count 2 '^  JSON mapper beans, type com\.fasterxml\.jackson\.databind\.ObjectMapper: 0$'
n count 2 '^  JSON mapper beans, type tools\.jackson\.databind\.ObjectMapper: not on the class path$'
echo "  one annotation: definitions 12 -> 55 (yours 6 both times); the file lists 12: 9 registered, 3 not used"
echo "  Boot's own report on the 12: unconditional 6 (all 6 registered; 5 guard a @Bean method) · guarded 6 (held 3, failed 3); JSON mappers: 0"
[ "$(wc -l < .r-imports.out | tr -d ' ')" = 12 ] || die "imports: expected the file's 12 lines"
n imports 12 '^org\.springframework\.boot\.autoconfigure\.[a-z]+\.[A-Za-z]+AutoConfiguration$'
[ "$(sed 's/.*\.//' .r-imports.out)" = "$(awk '/TiffinBoxApp: true$/{f=1} f && /^    (registered|not used) /{print $NF}' .r-count.out)" ] \
  || die "imports: the file's lines are not the count's rows, in the same order"
echo "  the file as it ships: 12 fully-qualified lines, the same 12 rows, in the same order, as the marks beside them"
x added 'definitions: before 12 · after 55'
x added 'the 12 from before, compared field by field after: identical 12 · changed 0 · gone 0'
x added 'new 43: configuration classes 17 (named in the file 9 · imported by those 8) · @Bean methods 14 · registered by code 12'
# "everything else 40" (count), named: the container's own 6 from before, plus the new ones that are not the 9 listed.
set -- $(sed -n 's/^new \([0-9]*\): configuration classes [0-9]* (named in the file \([0-9]*\) · imported by those \([0-9]*\)) · @Bean methods \([0-9]*\) · registered by code \([0-9]*\)$/\1 \2 \3 \4 \5/p' .r-added.out)
own=$(awk '/TiffinBoxApp: false$/{f=1} f && /definitions in all/{print $NF; exit}' .r-count.out)
rest=$(awk '/TiffinBoxApp: true$/{f=1} f && /definitions in all/{print $NF; exit}' .r-count.out)
[ $# = 5 ] && [ "$1" = $((55 - 12)) ] && [ "$2" = 9 ] && [ "$own" = 6 ] && [ "$rest" = 40 ] && [ $((own + $3 + $4 + $5)) = "$rest" ] \
  || die "added: the new ones ($*) do not name count's everything else ($own before, $rest after)"
echo "  added, not edited: 43 new, the 12 from before identical field by field; everything else $rest = $own as before + $3 + $4 + $5"
n hook 1 '^A   hook kept     definitions 55 · yours 6 · tiffinbox\.days 30 · listed registered 9 · imports file opened 1x$'
n hook 1 '^B   hook removed  definitions 6 · yours 1 · tiffinbox\.days null · listed registered 0 · imports file opened 0x$'
n hook 1 '^A′  hook kept     definitions 55 · yours 6 · tiffinbox\.days 30 · listed registered 9 · imports file opened 1x$'
n hook 2 '^      when it was opened: yours already registered 6 · the stack from the hook down, 11 frames:$'
n hook 2 '^        ConfigurationClassPostProcessor\.postProcessBeanDefinitionRegistry$'
n hook 2 '^        ConfigurationClassParser\$DeferredImportSelectorHandler\.process$'
n hook 2 '^        AutoConfigurationImportSelector\.getCandidateConfigurations$'
n hook 2 '^        ImportCandidates\.load$'
echo "  A/B/A': the hook kept, taken out, kept - yours 6/1/6, days 30/null/30, registered 9/0/9, the file opened 1/0/1"
echo "  who opened it: AutoConfigurationImportSelector, called from the hook through the parser's deferred step, yours 6 already in"
x opened '@EnableAutoConfiguration carries 6: java.lang.annotation 4 [Target, Retention, Documented, Inherited] · Spring 2 [AutoConfigurationPackage, Import(AutoConfigurationImportSelector)]'
x opened 'AutoConfigurationImportSelector is a DeferredImportSelector: true'
x opened '@SpringBootApplication carries 7: java.lang.annotation 4 [Target, Retention, Documented, Inherited] · Spring 3 [SpringBootConfiguration, EnableAutoConfiguration, ComponentScan]'
x opened '@SpringBootConfiguration carries 5: java.lang.annotation 3 [Target, Retention, Documented] · Spring 2 [Configuration, Indexed]'
x opened "@SpringBootApplication's @ComponentScan: basePackages [] · basePackageClasses []"
echo "  @SpringBootApplication: 7 = Java's 4 + Spring's 3; @SpringBootConfiguration carries @Configuration; its scan names no package"
x swap 'exit 1'
x swap 'APPLICATION FAILED TO START'
x swap 'org.springframework.beans.factory.UnsatisfiedDependencyException'
x swap "Parameter 0 of constructor in com.tiffinbox.web.TiffinBoxServer required a bean of type 'com.tiffinbox.CustomerRepository' that could not be found."
echo "  the swap: exit 1 - the scan starts at com.tiffinbox.web and never finds com.tiffinbox.CustomerRepository"
for j in "autoconfigure 12" "http-converter 1" "jackson 1" "servlet 5" "tomcat 5" "webmvc 6"; do
  n web 1 "^  spring-boot-${j% *}-4\.1\.1\.jar +${j#* } classes listed$"; done
x web '  imports files 6 · classes listed 30 · bean definitions 145'
x web "  Boot's jars on the class path 14: starters 6, classes in them 0 · code modules 8, with an imports file 6"
x web '  code modules without one: spring-boot-4.1.1.jar, spring-boot-web-server-4.1.1.jar'
x web "  Boot's report on the 30: unconditional 6 · guarded by a condition 24 (held 11 · failed 13) · registered 17"
x web '  JSON mapper beans, type tools.jackson.databind.ObjectMapper: [jacksonJsonMapper] -> tools.jackson.databind.json.JsonMapper'
x web '  JSON mapper beans, type com.fasterxml.jackson.databind.ObjectMapper: not on the class path'
echo "  the smallest web app: 6 files of the 8 code modules, 30 classes listed (24 guarded), 145 definitions, one JSON mapper"
x responses 'the responses with auto-configuration on: 7 · md5 115c36bac276128e245ca57df11c2891'
x responses 'server exit 0'
echo "  and the seven responses are unchanged"

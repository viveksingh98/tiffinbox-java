#!/bin/bash
# Course 5 · Unit 01's receipts. TiffinBox as Course 4 left it (../c4-tiffinbox, frozen) and as Course 5 starts it
# (after/: Boot's parent and SpringApplication.run), built and run in ONE run on ONE machine. Every number the video
# says is asserted below, and every capture must hash to its line in receipts.md5 - a differing hash stops the run.
export JAVA_HOME=/opt/homebrew/opt/openjdk@25        # JDK 25.0.4.1 on the author's Mac: point it at your JDK 25
export PATH="$JAVA_HOME/bin:$PATH"
set -e
cd "$(dirname "$0")"
exec 3>&1                                            # die() speaks to the terminal even inside a redirected capture
die() { echo "  *** $* ***" >&3; exit 1; }
[ -x "$JAVA_HOME/bin/java" ] || die "no JDK at $JAVA_HOME - edit the export line at the top"
M2="$PWD/.m2-demo"
JOPTS="-Duser.language=en -Duser.country=US"   # harness JVMs only: JUL's two-line header is locale-dependent
# clean, always: copy-dependencies never deletes, so a lib/ built before a version change keeps BOTH versions.
# Offline first (a warm .m2-demo needs no network); Maven resolves online only if something is missing.
build() { (cd "$1" && { mvn -q -o -Dmaven.repo.local="$M2" -DskipTests clean package > /dev/null 2>&1 \
                        || mvn -q -Dmaven.repo.local="$M2" -DskipTests clean package; }) || die "build failed: $1"; }
jars() { echo "$1/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$1"/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"; }
# "after" is this unit's own frozen copy of ../c5-tiffinbox as unit 01 left it: later units keep changing the anchor,
# and these receipts must keep measuring unit 01's change (Course 4's lesson: unit 31 broke units 01 and 08's commands).
B=../c4-tiffinbox; A=after; WEB=tiffinbox-web/src/main/java/com/tiffinbox/web
listeners() { lsof -nP -iTCP:"$1" -sTCP:LISTEN -t 2>/dev/null | wc -l | tr -d ' '; }
# Serve a build exactly as the last course documented it - in the project's tiffinbox-web/target, the command
# `java -jar tiffinbox-web-1.0.0.jar <port>` - print that command, run Course 4's comparison set, and require the
# server gone after POST /shutdown. The server's own log is kept beside the captures, never hashed.
serve() { dir=$1; port=$2; log="$PWD/.r-serve-$3.log"
  printf '$ java -jar tiffinbox-web-1.0.0.jar %s\n' "$port"
  (cd "$dir/tiffinbox-web/target" && exec java -jar tiffinbox-web-1.0.0.jar "$port") > "$log" 2>&1 & pid=$!
  for i in $(seq 1 60); do curl -s -o /dev/null "http://127.0.0.1:$port/kitchen" && break; sleep 0.25; done
  ../c4-unit31/curlset.sh "$port"
  for i in $(seq 1 40); do kill -0 "$pid" 2>/dev/null || break; sleep 0.25; done
  kill -0 "$pid" 2>/dev/null && { kill "$pid"; die "the server on $port was still running after POST /shutdown"; }
  wait "$pid" && ec=0 || ec=$?
  [ "$(listeners "$port")" = 0 ] || die "something still listens on $port"
  printf '  (server exit %s, 0 listeners left)\n' "$ec"; }
# Three runs, hashed; a drift stops the receipts; each hash compared with receipts.md5, and a mismatch stops them too.
unpub=""
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
  if [ -z "$pub" ]; then printf '  %-10s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpub="$unpub $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-10s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-10s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm differs from receipts.md5. Suspect the machine before the code: another JDK, Maven or locale, a busy port, or edited sources. Compare .r-$nm.out with its block in README.md"; fi; }
# THE MASK (declared in README.md). Boot's log line is "<ISO time> <LEVEL> <pid> --- [<thread>] <logger> : <message>".
# The time token, the pid token and the two start-up durations are REPLACED IN PLACE with sub/gsub, so Boot's padding
# survives; the pid-and-path of "Starting ..." goes the same way. JUL's two-line records (plain Spring, no config
# file) lose their locale-dependent header line. Both are counted on a last line.
mask() { awk '
  /^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9][0-9][0-9][0-9] [0-9:]+ (AM|PM) / { jul++; next }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/ {
      sub(/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9:.]+([-+][0-9][0-9]:[0-9][0-9]|Z)/, "<time>")
      sub(/ [0-9]+ --- \[/, " <pid> --- ["); t++ }
  { gsub(/in [0-9.]+ seconds \(process running for [0-9.]+\)/, "in <s> seconds (process running for <s>)")
    gsub(/with PID [0-9]+ \([^)]*\)/, "with PID <pid> (<path>)"); print }
  END { printf "… %d JUL header line(s) elided; %d Boot line(s) with time and pid masked …\n", jul, t }'; }

echo "building: Course 4's TiffinBox (frozen) and Course 5's"
build "$B"; build "$A"

# The run command, and the seven answers. Both projects on the same port, one after the other, so the two captures
# can be compared byte for byte: the command line and the answers.
cap before serve "$B" 18521 before
cap after  serve "$A" 18521 after
identical() { printf 'the command, both times (each project, in its tiffinbox-web/target):\n'
  for r in "Course 4, a context you build|before" "Course 5, SpringApplication.run|after"; do
    printf '  %-34s %s\n' "${r%%|*}" "$(grep '^\$ ' ".r-${r#*|}.out")"; done
  printf 'the seven responses (status, content type, body), hashed on their own:\n'
  for r in "Course 4, a context you build|before" "Course 5, SpringApplication.run|after"; do
    printf '  %-34s %s lines  md5 %s\n' "${r%%|*}" "$(grep -c ' -> ' ".r-${r#*|}.out")" "$(grep ' -> ' ".r-${r#*|}.out" | md5 -q)"; done; }
cap identical identical

# What changed in the source tree: every file both trees carry, compared; the changed ones, diffed (git's diff, -U0).
# In the two POMs, comment and blank lines are not shown - and counted.
hunk() { git diff --no-index --no-color -U0 "$B/$1" "$A/$1" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' || true; }
changes() { n=0; changed=""
  for f in $(cd "$A" && git ls-files . 2>/dev/null | grep -v '^README.md$' || find . -type f -not -path '*/target/*' -not -name README.md | sed 's|^\./||'); do
    [ -f "$B/$f" ] || { changed="$changed $f(new)"; continue; }; n=$((n+1)); cmp -s "$B/$f" "$A/$f" || changed="$changed $f"; done
  printf 'files compared (README aside): %s · changed:%s\n' "$n" "$changed"
  for f in pom.xml tiffinbox-web/pom.xml; do
    all=$(hunk "$f"); code=$(echo "$all" | grep -vE -e '^[-+][[:space:]]*$' -e '^[-+][[:space:]]*<!--' -e '-->[[:space:]]*$' || true)
    printf '%s, every changed line but comments and blanks (%s of those not shown):\n' "$f" \
      "$(( $(echo "$all" | grep -c .) - $(echo "$code" | grep -c .) ))"
    echo "$code"; done
  printf 'TiffinBoxServer.java, every changed line:\n'; hunk "$WEB/TiffinBoxServer.java"; }
cap changes changes

rm -rf .harness; "$JAVA_HOME/bin/javac" -cp "$(jars "$A")" -d .harness $(find harness -name '*.java')
beans() { java $JOPTS -cp ".harness:$(jars "$A")" com.tiffinbox.harness.WhatBootAdded context 18523 2>&1 | mask
          java $JOPTS -cp ".harness:$(jars "$A")" com.tiffinbox.harness.WhatBootAdded boot 18524 2>&1 | mask; }
cap beans beans

# SpringApplication's second list: what it holds before run(), each name looked up in the class path's
# META-INF/spring.factories files; the two entries the video names; and the bean name that initializer registers.
factories() { lib="$A/tiffinbox-web/target/lib"
  for j in "$lib"/*.jar; do unzip -p "$j" META-INF/spring.factories 2>/dev/null || true; done > .r-fac-files
  java $JOPTS -cp ".harness:$(jars "$A")" com.tiffinbox.harness.WhatRunLoads > .r-fac-run 2>&1 || true
  printf 'what a new SpringApplication(TiffinBoxApp.class) holds before run(), each looked up in META-INF/spring.factories:\n'
  for what in initializers listeners; do n=0; f=0
    for c in $(grep "^$what (" .r-fac-run | cut -d: -f2-); do n=$((n+1))
      awk -v c="$c" '{ sub(/[ \t]*,?[ \t]*\\?[ \t]*\r?$/, ""); sub(/^.*=/, ""); if ($0 == c) hit = 1 } END { exit !hit }' .r-fac-files && f=$((f+1)); done
    printf '  %-13s %s held · %s of %s named in a spring.factories file on the class path\n' "$what" "$n" "$f" "$n"; done
  printf 'two of those entries, as the files write them:\n'
  for e in "spring-boot-autoconfigure-4.1.1.jar|ApplicationContextInitializer=|SharedMetadataReaderFactoryContextInitializer" \
           "spring-boot-4.1.1.jar|ApplicationListener=|LoggingApplicationListener"; do
    IFS='|' read -r jar key cls <<< "$e"
    unzip -p "$lib/$jar" META-INF/spring.factories | grep -nE "$key|$cls" | sed "s|^\([0-9]*\):|  $jar, line \1: |"; done
  printf 'the bean name that initializer registers (javap -constants):\n'
  printf '  SharedMetadataReaderFactoryContextInitializer.%s\n' "$("$JAVA_HOME/bin/javap" -constants -cp "$lib/spring-boot-autoconfigure-4.1.1.jar" \
    org.springframework.boot.autoconfigure.SharedMetadataReaderFactoryContextInitializer | grep -o 'BEAN_NAME = "[^"]*"')"
  rm -f .r-fac-files .r-fac-run; }
cap factories factories

# Who closes the context at exit - the second line of Course 4's main. TiffinBox plus one Goodbye bean (outside
# com.tiffinbox), then System.exit(0): its @PreDestroy prints only if a shutdown hook closes the context.
hook() { printf 'TiffinBox + one Goodbye bean, then System.exit(0) - nobody calls close():\n'
  for r in "new AnnotationConfigApplicationContext(...)|context" \
           "new AnnotationConfigApplicationContext(...).registerShutdownHook()|hook" \
           "SpringApplication.run(...)|boot"; do
    IFS='|' read -r label way <<< "$r"
    java $JOPTS -cp ".harness:$(jars "$A")" com.tiffinbox.harness.WhoCloses "$way" 18526 > .r-hook-run 2>&1 && ec=0 || ec=$?
    printf '  %-66s exit %s · @PreDestroy %s\n' "$label" "$ec" "$(grep -qx 'goodbye: @PreDestroy ran' .r-hook-run && echo ran || echo 'did not run')"
    [ "$(listeners 18526)" = 0 ] || die "something still listens on 18526"; done
  rm -f .r-hook-run; }
cap hook hook

price() { lb=$(ls "$B"/tiffinbox-web/target/lib | sort); la=$(ls "$A"/tiffinbox-web/target/lib | sort)
  printf 'jars the application needs at run time: %s -> %s\n' "$(echo "$lb" | wc -l | tr -d ' ')" "$(echo "$la" | wc -l | tr -d ' ')"
  printf '  added:   %s\n' "$(comm -13 <(echo "$lb" | sed 's/-[0-9][0-9.]*\.jar$//') <(echo "$la" | sed 's/-[0-9][0-9.]*\.jar$//') | paste -sd' ' -)"
  printf '  version moved: %s\n' "$(comm -12 <(echo "$lb" | sed 's/-[0-9][0-9.]*\.jar$//') <(echo "$la" | sed 's/-[0-9][0-9.]*\.jar$//') | while read -r j; do
      vb=$(echo "$lb" | grep -E "^$j-[0-9]"); va=$(echo "$la" | grep -E "^$j-[0-9]"); [ "$vb" = "$va" ] || printf '%s -> %s  ' "$vb" "$va"; done)"
  printf '  Jackson in Course 5'"'"'s lib: %s\n' "$(echo "$la" | grep '^jackson-' | paste -sd' ' -)"
  for t in "Course 4|$B" "Course 5|$A"; do printf 'MethodParameters attributes in OrderQueue.class (%s): %s\n' "${t%%|*}" \
      "$("$JAVA_HOME/bin/javap" -v -cp "${t#*|}/tiffinbox-core/target/classes" com.tiffinbox.OrderQueue | grep -c MethodParameters)"; done; }
cap price price

# The break, A / B / A' / C / D. A' is A re-run (contract §R.1); C and D are further variants and say so. Every run is
# the whole command a viewer types in that project's tiffinbox-web/target, printed before it runs - and the port comes
# first, because main still copies its first argument into tiffinbox.port (D shows what a flag in front of it does).
logging() { jul="-Djava.util.logging.config.file=../logging-debug.properties"
  for r in "A  Course 4's jar, with the last course's Java logging file|$B|$jul|" \
           "B  Course 5's jar, the same flag and the same file|$A|$jul|" \
           "A' Course 4's jar again: A, re-run|$B|$jul|" \
           "C  Course 5's jar, Boot's logging.level property, after the port|$A||--logging.level.tiffinbox=debug"; do
    IFS='|' read -r label dir flag arg <<< "$r"
    cmd="java${flag:+ $flag} -jar tiffinbox-web-1.0.0.jar 18525${arg:+ $arg}"
    printf '%s\n  $ %s\n' "$label" "$cmd"
    (cd "$dir/tiffinbox-web/target" && exec $cmd) > .r-log-run 2>&1 & pid=$!
    for i in $(seq 1 60); do curl -s -o /dev/null http://127.0.0.1:18525/kitchen && break; sleep 0.25; done
    curl -s -X POST http://127.0.0.1:18525/shutdown > /dev/null; wait "$pid" && ec=0 || ec=$?
    printf '  exit %s · route DEBUG lines %s · banner %s\n' "$ec" "$(grep -c 'route [A-Z]* /' .r-log-run)" \
      "$(grep -q ':: Spring Boot ::' .r-log-run && echo "printed ($(grep -o 'v[0-9.]*' .r-log-run | head -1))" || echo "none")"
    if grep -q 'route GET /customers' .r-log-run; then grep -m1 'route GET /customers' .r-log-run | mask | head -1 | sed 's/^/  first route line: /'
    else echo "  first route line: (none)"; fi
    [ "$(listeners 18525)" = 0 ] || die "something still listens on 18525"; done
  cmd="java -jar tiffinbox-web-1.0.0.jar --logging.level.tiffinbox=debug"
  printf "D  Course 5's jar, the same property with no port in front of it\n  \$ %s\n" "$cmd"
  (cd "$A/tiffinbox-web/target" && exec $cmd) > .r-log-run 2>&1 & pid=$!
  for i in $(seq 1 80); do kill -0 "$pid" 2>/dev/null || break; sleep 0.25; done
  kill -0 "$pid" 2>/dev/null && { kill "$pid"; die "D was still running after 20 s - it should fail at start-up"; }
  wait "$pid" && ec=0 || ec=$?
  printf '  exit %s · %s\n' "$ec" "$(grep -m1 -o 'java.lang.NumberFormatException: For input string: "[^"]*"' .r-log-run || echo '(no NumberFormatException)')"
  rm -f .r-log-run; }
cap logging logging

echo
# ---- the checks. Each one reads a line the program computed, never a label receipts.sh prints unconditionally, and
# ---- each is tagged with the spoken words it pays for (contract §R.2).
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
c() { grep -cE -- "$2" ".r-$1.out" || true; }
# "Fourteen files compared, three changed" · "Boot's parent" · "the Spring version list it imported goes" · "one starter"
x changes '^files compared \(README aside\): 14 · changed: pom.xml tiffinbox-web/pom.xml tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java$'
x changes '^\+    <artifactId>spring-boot-starter-parent</artifactId>$'; x changes '^\+    <version>4\.1\.1</version>$'
x changes '^-        <artifactId>spring-framework-bom</artifactId>$'
x changes '^-    <maven\.compiler\.release>25</maven\.compiler\.release>$'; x changes '^\+    <java\.version>25</java\.version>$'
[ "$(sed -n '/^tiffinbox-web\/pom.xml/,/^TiffinBoxServer/p' .r-changes.out | grep -c '^+ *<artifactId>')" = 1 ] \
  && x changes '^\+      <artifactId>spring-boot-starter</artifactId>$' || die "changes: the web POM must gain exactly one dependency, the starter"
# "one line where two used to be" (main), and Boot's first move "replaces both lines"
[ "$(sed -n '/^TiffinBoxServer.java/,$p' .r-changes.out | grep -c '^-        ')" = 2 ] \
  && [ "$(sed -n '/^TiffinBoxServer.java/,$p' .r-changes.out | grep -c '^+        ')" = 1 ] || die "changes: main must lose two lines and gain one"
x changes '^-        context\.registerShutdownHook\(\);$'; x changes '^\+        SpringApplication\.run\(TiffinBoxApp\.class, args\);$'
echo "  14 files compared, 3 changed: Boot's parent in, the Framework BOM out, one starter in; main: 2 lines out, 1 in"
# "The run command doesn't change" · "the seven requests ... one hash" (and the exercise's end state, 115c36ba...)
cmp -s .r-before.out .r-after.out || die "before/after: the same command must give a byte-identical capture"
# (the command lines themselves are echoes of what serve() ran; the published md5 pins them. What can fail is the
#  behaviour: each server must have listened on the port its command gave - the positional port still works.)
for s in before after; do grep -q 'TiffinBox listening on http://127\.0\.0\.1:18521$' ".r-serve-$s.log" \
  || die "$s: the server did not listen on the port its command gave"; done
[ "$(awk '/ md5 /{print $NF}' .r-identical.out | sort -u | wc -l | tr -d ' ')" = 1 ] && [ "$(c identical ' 7 lines  md5 ')" = 2 ] \
  || die "identical: the seven responses changed"
x identical ' 7 lines  md5 115c36bac276128e245ca57df11c2891$'
grep -q '^  (server exit 0, 0 listeners left)$' .r-after.out || die "Course 5's server did not stop cleanly"
echo "  the same command both ways; the seven responses hash to one md5 (115c36ba...) before and after"
# "your six beans" · "three property sources" · "not one auto-configuration class" · "one new definition ... says Boot"
[ "$(c beans '^  your definitions \(6\): \[customerRepository, dashboard, database, orderQueue, tiffinBoxApp, tiffinBoxServer\]$')" = 2 ] || die "beans: yours must be the same six both ways"
[ "$(c beans '^  auto-configuration definitions \(type name contains AutoConfiguration\): 0$')" = 2 ] || die "beans: no auto-configuration either way"
[ "$(c beans "^  Spring's own definitions \(named org\.springframework\.context\.\*\): 5$")" = 2 ] || die "beans: Spring's own five, both ways"
x beans "^  Boot's own definitions \(named org\.springframework\.boot\.\*\): 0 \[\]$"
x beans "^  Boot's own definitions \(named org\.springframework\.boot\.\*\): 1 \[org\.springframework\.boot\.autoconfigure\.internalCachingMetadataReaderFactory\]$"
[ "$(c beans '^  any other definitions: 0$')" = 2 ] || die "beans: every definition must land in a named group"
srcs() { grep '^  property sources, in the order they are asked: ' .r-beans.out | sed -n "$1p" | sed 's/^.*asked: \[//; s/\]$//' | awk -F', ' '{ for (i = 1; i <= NF; i++) print $i }'; }
[ "$(srcs 1 | wc -l | tr -d ' ')" = 3 ] || die "beans: the old way asks three property sources"
[ "$(comm -13 <(srcs 1 | sort) <(srcs 2 | sort) | paste -sd' ' -)" = "applicationInfo commandLineArgs configurationProperties random" ] \
  && [ "$(comm -23 <(srcs 1 | sort) <(srcs 2 | sort) | wc -l | tr -d ' ')" = 0 ] || die "beans: Boot must add exactly four property sources and drop none"
echo "  the same six beans both ways, 0 auto-configuration; Boot's one definition; 3 property sources -> 3 + 4 new"
# "a banner, with the version on it" · "a time, a level and a process id" (Boot's padding kept by the mask)
x beans '^ :: Spring Boot :: +\(v4\.1\.1\)$'
x beans '^<time>  INFO <pid> --- \[           main\] tiffinbox                                : orders cooked:  120$'
# "SpringApplication reads a second list ... one initializer listed there adds exactly that name" · the listener
x factories '^  initializers +5 held · 5 of 5 named in a spring\.factories file'; x factories '^  listeners +7 held · 7 of 7 named in a spring\.factories file'
x factories '^  spring-boot-autoconfigure-4\.1\.1\.jar, line [0-9]+: org\.springframework\.boot\.autoconfigure\.SharedMetadataReaderFactoryContextInitializer,\\$'
x factories '^  spring-boot-4\.1\.1\.jar, line [0-9]+: org\.springframework\.boot\.context\.logging\.LoggingApplicationListener,\\$'
bn=$(grep -o 'BEAN_NAME = "[^"]*"' .r-factories.out | cut -d'"' -f2)
[ -n "$bn" ] && grep -qF "(named org.springframework.boot.*): 1 [$bn]" .r-beans.out || die "factories: the initializer's BEAN_NAME must be the one definition Boot added"
echo "  SpringApplication's 5 initializers and 7 listeners all come from spring.factories; one initializer is Boot's definition"
# "Plain context: silence. With the hook: it runs. Under Boot, no hook line of yours: it runs."
x hook '^  new AnnotationConfigApplicationContext\(\.\.\.\) +exit 0 · @PreDestroy did not run$'
x hook '^  new AnnotationConfigApplicationContext\(\.\.\.\)\.registerShutdownHook\(\) +exit 0 · @PreDestroy ran$'
x hook '^  SpringApplication\.run\(\.\.\.\) +exit 0 · @PreDestroy ran$'
echo "  at System.exit: no hook, no @PreDestroy; registerShutdownHook() or SpringApplication.run, it runs"
# "Fifteen jars become twenty-six" · "eleven more jars" · "Six jars changed version" · "databind 2.22.2, core and annotations 2.21"
x price 'jars the application needs at run time: 15 -> 26$'
[ "$(grep '^  added:' .r-price.out | cut -d: -f2 | wc -w | tr -d ' ')" = 11 ] || die "price: eleven jars added"
x price '^  added: .*logback-classic.*snakeyaml spring-boot spring-boot-autoconfigure spring-boot-starter spring-boot-starter-logging$'
[ "$(grep '^  version moved:' .r-price.out | grep -o '\.jar -> ' | wc -l | tr -d ' ')" = 6 ] || die "price: six versions moved"
x price "^  Jackson in Course 5's lib: jackson-annotations-2\.21\.jar jackson-core-2\.21\.5\.jar jackson-databind-2\.22\.2\.jar$"
x price 'OrderQueue.class \(Course 4\): 0$'; x price 'OrderQueue.class \(Course 5\): 3$'
echo "  the price: 15 -> 26 jars (11 added), 6 versions moved (Jackson split 2.22.2 / 2.21), -parameters on (0 -> 3)"
# "five route lines" · "zero ... exit code zero" · "again: five" · "after the port: five again" · "a flag in front crashes startup"
[ "$(grep -o 'route DEBUG lines [0-9]*' .r-logging.out | awk '{print $NF}' | paste -sd' ' -)" = "5 0 5 5" ] || die "logging: expected A 5 / B 0 / A' 5 / C 5"
[ "$(c logging '^  exit 0 · route DEBUG lines')" = 4 ] || die "logging: A, B, A' and C must exit 0 - the break is silent"
[ "$(sed -n 2,4p .r-logging.out)" = "$(sed -n 10,12p .r-logging.out)" ] || die "logging: A' must repeat A line for line"
# (A, B and A' print one command, and C prints the port first: echoes of the commands run, pinned by the published
#  md5 rather than checked here - a check may never match a line receipts.sh prints unconditionally.)
x logging '^  first route line: <time> DEBUG <pid> --- \[           main\] tiffinbox                                : route GET /customers -> customers\(\)$'
x logging '^  exit 1 · java\.lang\.NumberFormatException: For input string: "--logging\.level\.tiffinbox=debug"$'
echo "  the break: the JUL file gives 5 route lines on Course 4, 0 on Boot (exit 0), 5 on Course 4 again;"
echo "             Boot's logging.level gives 5 after the port, and exit 1 (NumberFormatException) in front of it"
[ -z "$unpub" ] || die "no published hash for:$unpub - copy the md5s above into receipts.md5, then run again"
echo "c5-unit01: every capture 3/3 and = published; every spoken number asserted"

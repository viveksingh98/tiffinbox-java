#!/bin/bash
# Receipts for "@Conditional and the Condition Evaluation Report" (Course 5 · Section 1). Every number the video says
# is asserted at the bottom by a check that can fail. Five captures, each run three times and hashed:
#   report    TiffinBox's own jar: the flag alone (it becomes the port, and fails), then the port first and --debug:
#             where the report lands in the run, its four lists counted, and the file's twelve classes filed from
#             them (unconditional · matched · did not match)
#   backoff   A Boot alone · B plus one Executor bean of yours · C plus mode=force · A' = A, re-run: which Executor
#             beans exist, and where twenty @Async calls ran
#   defaults  D plain Spring (the last course) · E Boot on a JVM told it has two processors: two defaults Boot flips
#   why       B's own report: the lines that say why Boot's pool backed off, both branches
#   typos     three misspellings: a wrong value something converts (loud), a wrong key (silent - and the report
#             never names it), a wrong value on a key no class binds (silent)
# TiffinBox is the anchor as ../c5-unit04/after left it, COPIED into .harness/anchor and built there: this script never
# writes into another unit's folder, and nothing in the anchor changes. Masks (sub/gsub only; README.md declares each):
# Boot's log prefix is cut before a message that is kept; durations become <s>; PrintFlagsFinal's column padding is
# squeezed; the harness prints thread names with their trailing number as #.
set -e
cd "$(dirname "$0")"
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M2="$PWD/.m2-demo"
die() { echo "  *** $* ***"; exit 1; }
java -version 2>&1 | grep -q 'version "25' || die "JDK 25 needed; JAVA_HOME gives: $(java -version 2>&1 | head -1)"

# ---- build: a copy of TiffinBox, then the harness --------------------------------------------------------------------
rm -rf .harness; mkdir -p .harness/anchor
cp -R ../c5-unit04/after/. .harness/anchor/
rm -rf .harness/anchor/target .harness/anchor/tiffinbox-core/target .harness/anchor/tiffinbox-web/target
APP=.harness/anchor
WEB=$APP/tiffinbox-web/target
build() { (cd "$APP" && mvn "$@" -q -B -Dmaven.repo.local="$M2" -DskipTests clean package); }
build -o || build || die "build failed: TiffinBox, copied from ../c5-unit04/after"
AC=$(ls "$WEB"/lib/spring-boot-autoconfigure-*.jar)
JARS="$WEB/tiffinbox-web-1.0.0.jar:$(ls "$WEB"/lib/*.jar | paste -sd: -)"
printf '%s\n' "$JARS" > .harness/classpath                  # exercise/README.md builds its CP from this file
javac -cp "$JARS" -d .harness/classes $(find harness -name '*.java' | sort) || die "the harness did not compile"
CP=".harness/classes:$JARS"
H=com.tiffinbox.harness.Conditions

# run [JVM flags] -- PORT SETUP [Boot flags]: print the whole command as you would type it, run it, keep the exit code.
run() { local jv=""; while [ "$1" != "--" ]; do jv="$jv$1 "; shift; done; shift
  echo "\$ java ${jv}-cp \"\$CP\" $H $*"
  ec=0; java $jv -cp "$CP" "$H" "$@" > .harness/run.raw 2>&1 || ec=$?; }
# Log lines are not claims here: dropped and counted. One is kept - the INFO Spring logs when @Async finds no executor it
# can use - with everything before its message cut by sub(): time, pid, thread, logger.
quiet() { awk '
  /No task executor bean found for async processing/ { s = $0; sub(/^.*No task executor/, "INFO  No task executor", s); print s; next }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/     { n++; next }
  /^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]+ \[/      { n++; next }
  /^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9][0-9][0-9][0-9] / { n++; next }
  /^(INFO|WARNING|SEVERE): /                         { n++; next }
  { print }
  END { printf "… %d log line(s) elided …\n", n }' .harness/run.raw; }
# Cut a long line after a marker; the rest is counted on the line itself.
cutat() { awk -v m="$1" '{ i = index($0, m); if (i) { k = i + length(m) - 1; printf "%s … [+%d chars]\n", substr($0, 1, k), length($0) - k } else print }'; }
# The report's sections: print the lines of one (p positive · n negative · x exclusions · u unconditional classes).
section() { awk -v want="$2" '/^Positive matches:$/ { s = "p"; next } /^Negative matches:$/ { s = "n"; next }
  /^Exclusions:$/ { s = "x"; next } /^Unconditional classes:$/ { s = "u"; next }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { s = "" } s == want' "$1"; }
# Its lists, counted: how many it has; entries at the report's first indent (three spaces) under Positive and Negative
# matches; excluded classes (four spaces, "None" when there are none); the class names (four spaces) under Unconditional.
lists() { echo "the report's $(grep -cE '^(Positive matches|Negative matches|Exclusions|Unconditional classes):$' "$1") lists: positive matches $(section "$1" p | grep -c '^   [A-Za-z]') · negative matches $(section "$1" n | grep -c '^   [A-Za-z]') · exclusions $(section "$1" x | grep -E '^    [A-Za-z]' | grep -vc '^    None$') · unconditional classes $(section "$1" u | grep -c '^    [a-z]')"; }
# The report text alone: from its title to the next log line.
body() { awk '/^CONDITIONS EVALUATION REPORT$/ { f = 1 } f && /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { exit } f' .harness/run.raw; }
# meta KEY FIELD: that field of KEY's entry in Boot's own metadata files (META-INF/spring-configuration-metadata.json,
# in every jar on TiffinBox's class path; pretty-printed, one field per line), or "none" when the entry has no such field.
meta() { local j out=""
  for j in "$WEB"/lib/*.jar; do
    unzip -l "$j" META-INF/spring-configuration-metadata.json > /dev/null 2>&1 || continue
    out="$out$(unzip -p "$j" META-INF/spring-configuration-metadata.json | awk -v k="\"name\": \"$1\"," -v f="\"$2\": " '
      index($0, k) { e = 1; next }
      e && index($0, f) { s = substr($0, index($0, f) + length(f)); sub(/,$/, "", s); gsub(/"/, "", s); print s; exit }
      e && /^    }/ { print "none"; exit }')"
  done
  echo "${out:-not in any metadata file}"; }

cap() { local nm=$1 h pub; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1")
  [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs (diff .r-$nm.1 .r-$nm.2 .r-$nm.3)"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2> /dev/null || true)
  if [ -z "$pub" ]; then printf '  %-8s md5 %s  3/3  (no published hash)\n' "$nm" "$h"; unpublished="$unpublished $nm"
  elif [ "$pub" = "$h" ]; then printf '  %-8s md5 %s  3/3  = published\n' "$nm" "$h"
  else printf '  %-8s md5 %s  3/3  DIFFERS from the published %s\n' "$nm" "$h" "$pub"
    die "$nm is not the published capture - suspect a different JDK, Boot or Maven, or this machine; diff .r-$nm.out against its block in README.md"; fi; }

# ---- report: TiffinBox's own jar, the port first (its main still reads args[0] as the port), then Boot's flag -------
report() { local bad="java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --debug" R=.harness/report.raw pid rc=0 i=0 stop listed un ma no
  local cmd="java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18551 --debug"
  # First the flag alone: main copies args[0] into tiffinbox.port, so "--debug" becomes the port. It fails before the
  # server opens anything (the int conversion is in the constructor), so no port is bound.
  echo "\$ $bad"
  (cd "$APP" && exec $bad) > "$R" 2>&1 || rc=$?
  echo "exit $rc · $(grep -m1 '^Caused by: java.lang.NumberFormatException' "$R")"
  rc=0
  echo "\$ $cmd"
  (cd "$APP" && exec $cmd) > "$R" 2>&1 & pid=$!
  until grep -q 'Started TiffinBoxServer' "$R" || [ $i -ge 120 ]; do sleep 0.25; i=$((i + 1)); done
  stop=$(curl -s --max-time 5 -X POST http://127.0.0.1:18551/shutdown)
  i=0; while kill -0 "$pid" 2> /dev/null && [ $i -lt 80 ]; do sleep 0.25; i=$((i + 1)); done
  kill "$pid" 2> /dev/null && echo "(the server did not stop by itself: killed)"
  wait "$pid" || rc=$?
  awk '/TiffinBox listening on / { s = $0; sub(/^.* : /, "", s); printf "line %-4d %s\n", NR, s }
       /^CONDITIONS EVALUATION REPORT$/ { printf "line %-4d %s\n", NR, $0 }
       /Started TiffinBoxServer in / { s = $0; sub(/^.* : /, "", s); gsub(/[0-9]+\.[0-9]+/, "<s>", s); printf "line %-4d %s\n", NR, s }' "$R"
  lists "$R"
  listed=$(unzip -p "$AC" META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports | grep -v '^#' | grep . | sed 's/.*\.//' | sort)
  un=$(section "$R" u | awk '/^    [a-z]/ { s = $1; sub(/^.*\./, "", s); print s }' | sort)
  ma=$(section "$R" p | awk '/^   [A-Za-z]+ matched:$/ { print $1 }' | sort)
  no=$(section "$R" n | awk '/^   [A-Za-z]+:$/ { s = $1; sub(/:$/, "", s); print s }' | sort)
  echo "the file's $(echo "$listed" | grep -c .) classes, as the report files them (each name without \"AutoConfiguration\"):"
  printf '  %-13s %d  %s\n' "unconditional" "$(echo "$un" | grep -c .)" "$(echo $un | sed 's/AutoConfiguration//g')"
  printf '  %-13s %d  %s\n' "matched" "$(echo "$ma" | grep -c .)" "$(echo $ma | sed 's/AutoConfiguration//g')"
  printf '  %-13s %d  %s\n' "did not match" "$(echo "$no" | grep -c .)" "$(echo $no | sed 's/AutoConfiguration//g')"
  echo "  registered    $(( $(echo "$un" | grep -c .) + $(echo "$ma" | grep -c .) ))  = the unconditional ones + the ones that matched"
  if [ "$(printf '%s\n' $un $ma $no | sort)" = "$listed" ]; then echo "  do these three groups name exactly the file's classes? yes"; else echo "  do these three groups name exactly the file's classes? NO"; fi
  echo "a default Boot flips, in the report's own words:"
  awk '/^   AopAutoConfiguration.ClassProxyingConfiguration matched:$/ { f = 1 } f && !NF { exit } f' "$R"
  echo "POST /shutdown -> $stop · exit $rc"; }
cap report report

# ---- backoff: A / B / C / A' ------------------------------------------------------------------------------------------
backoff() { echo "A   Boot alone";                                 run -- 18552 boot; quiet
            echo "B   plus one Executor bean of yours";            run -- 18553 kitchen; quiet
            echo "C   plus --spring.task.execution.mode=force";    run -- 18554 kitchen --spring.task.execution.mode=force; quiet
            echo "A′  A, re-run";                                  run -- 18552 boot; quiet; }
cap backoff backoff

# ---- defaults: D plain Spring, E two processors ---------------------------------------------------------------------
defaults() { echo "D   plain Spring, no Boot: TiffinBox as the last course ran it"; run -- 18555 plain; quiet
  echo "E   Boot alone, on a JVM told it has two processors"; run -XX:ActiveProcessorCount=2 -- 18556 boot; quiet
  echo "that JVM's flag, as it read it: $(java -XX:ActiveProcessorCount=2 -XX:+PrintFlagsFinal -version 2> /dev/null | awk '$2 == "ActiveProcessorCount" { s = $0; gsub(/ +/, " ", s); sub(/^ /, "", s); print s }')"
  echo "Boot's own metadata: spring.task.execution.pool.core-size defaults to $(meta spring.task.execution.pool.core-size defaultValue) · spring.task.execution.thread-name-prefix to $(meta spring.task.execution.thread-name-prefix defaultValue)"; }
cap defaults defaults

# ---- why: B's report ----------------------------------------------------------------------------------------------------
why() { run -- 18557 kitchen --debug; lists .harness/run.raw
  awk '/^   TaskExecutorConfigurations.TaskExecutorConfiguration:$/ { f = 1 } f && !NF { exit } f' .harness/run.raw | cutat "kitchenExecutor"; }
cap why why

# ---- typos: three misspellings (the exit code is java's, taken before any filter) -------------------------------------
typos() { echo "1   a wrong VALUE, on a key a class binds to a type"
  run -- 18558 kitchen --spring.task.execution.mode=forced
  echo "exit $ec · Boot's failure report (its Description and Action, blank lines dropped):"
  awk '/^Description:$/ { f = 1; next } f && NF' .harness/run.raw | cutat "(caused by" | sed 's/^/  /'
  echo "    the same kind of mistake, where a @Value field converts the value:"
  run -- 18558 boot --tiffinbox.days=thirty
  echo "exit $ec · $(grep -m1 '^Caused by: org.springframework.beans.TypeMismatchException' .harness/run.raw)"
  echo "2   a wrong KEY"
  run -- 18558 kitchen --spring.task.execution.mod=force
  echo "exit $ec · WARN lines $(grep -c ' WARN ' .harness/run.raw) · $(grep '^Executor beans' .harness/run.raw)"
  run -- 18558 kitchen --spring.task.execution.mod=force --debug; body > .harness/typo.report
  echo "its report names the key you typed on $(grep -cE 'execution\.mod([^e]|$)' .harness/typo.report) lines · the key you meant: $(grep -m1 -o "did not find property 'spring.task.execution.mode'" .harness/typo.report)"
  run -- 18558 kitchen --debug; body > .harness/notypo.report
  echo "the report with the typo: md5 $(md5 -q .harness/typo.report) · without it: md5 $(md5 -q .harness/notypo.report)"
  echo "3   a wrong VALUE, on a key no class binds"
  run -- 18558 boot --spring.aop.proxy-target-class=ture
  echo "exit $ec · WARN lines $(grep -c ' WARN ' .harness/run.raw) · $(grep '^@Async bean' .harness/run.raw)"
  run -- 18558 boot --spring.aop.proxy-target-class=ture --debug
  echo "its report: $(grep -m1 "found different value in property 'spring.aop.proxy-target-class'" .harness/run.raw | sed 's/^ *- //')"
  echo "which class binds each key - the sourceType in Boot's own metadata files:"
  echo "  spring.task.execution.mode      $(meta spring.task.execution.mode sourceType | sed 's/.*\.//')"
  echo "  spring.aop.proxy-target-class   $(meta spring.aop.proxy-target-class sourceType)"; }
cap typos typos

# ---- every number the video says, asserted ---------------------------------------------------------------------------
echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
blk() { awk -v a="$2" -v b="$3" 'index($0, a) == 1 { f = 1; next } b != "" && index($0, b) == 1 { f = 0 } f' ".r-$1.out"; }

x report '^\$ java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar --debug$'
x report '^exit 1 · Caused by: java\.lang\.NumberFormatException: For input string: "--debug"$'
x report '^\$ java -jar tiffinbox-web/target/tiffinbox-web-1\.0\.0\.jar 18551 --debug$'
l1=$(awk '/^line [0-9]+ +TiffinBox listening on http:\/\/127\.0\.0\.1:18551$/ { print $2 }' .r-report.out)
l2=$(awk '/^line [0-9]+ +CONDITIONS EVALUATION REPORT$/ { print $2 }' .r-report.out)
l3=$(awk '/^line [0-9]+ +Started TiffinBoxServer in <s> seconds/ { print $2 }' .r-report.out)
[ -n "$l1" ] && [ -n "$l2" ] && [ -n "$l3" ] && [ "$l1" -lt "$l2" ] && [ "$l2" -lt "$l3" ] || die "report: expected listening < report < Started, got '$l1' '$l2' '$l3'"
x report '^the report.s 4 lists: positive matches 15 · negative matches 13 · exclusions 0 · unconditional classes 6$'
x report "^the file's 12 classes, as the report files them"
x report '^  unconditional +6  [A-Za-z]'; x report '^  matched +3  [A-Za-z]'; x report '^  did not match +3  [A-Za-z]'
x report '^  registered +9  '; x report "^  do these three groups name exactly the file's classes\? yes$"
x report '^      - @ConditionalOnBooleanProperty \(spring\.aop\.proxy-target-class=true\) matched \(OnPropertyCondition\)$'
x report '^POST /shutdown -> \{"stopping":true\} · exit 0$'
echo "  report: the flag first - exit 1, NumberFormatException for \"--debug\" · the port first: TiffinBox listening (line $l1) before the report (line $l2), before Started (line $l3); 4 lists: 15 / 13 / 0 / 6; of 12: 6 unconditional + 3 matched = 9, 3 did not"

A_POOL='^Executor beans: applicationTaskExecutor \(a ThreadPoolTaskExecutor, core pool size 8\)$'
A_ASYNC='^@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 8 threads, named task-#$'
NOEXEC='^INFO  No task executor bean found for async processing: no bean of type TaskExecutor and no bean named .taskExecutor. either$'
TWENTY='· 20 calls ran on 20 threads, named SimpleAsyncTaskExecutor-#$'
blk backoff "A   " "B   " | grep -qE "$A_POOL" || die "backoff A: Boot's pool, core 8"
blk backoff "A   " "B   " | grep -qE "$A_ASYNC" || die "backoff A: 20 calls on 8 task- threads"
blk backoff "B   " "C   " | grep -qE '^Executor beans: kitchenExecutor \(a ThreadPoolExecutor, core pool size 3\)$' || die "backoff B: yours alone, three threads"
[ "$(blk backoff "B   " "C   " | grep -cE "$NOEXEC")" = 1 ] || die "backoff B: exactly one 'No task executor bean found' line"
blk backoff "B   " "C   " | grep -qE "^@Async bean: CGLIB subclass of AsyncKitchen $TWENTY" || die "backoff B: 20 calls on 20 new threads"
blk backoff "C   " "A′  " | grep -qE '^Executor beans: applicationTaskExecutor \(a ThreadPoolTaskExecutor, core pool size 8\), kitchenExecutor \(a ThreadPoolExecutor, core pool size 3\)$' || die "backoff C: both"
blk backoff "C   " "A′  " | grep -qE "$A_ASYNC" || die "backoff C: 20 calls back on 8 task- threads"
[ "$(blk backoff "A   " "B   ")" = "$(blk backoff "A′  " "")" ] || die "backoff: A' is not A"
echo "  backoff: A pool core 8, 20 calls on 8 threads · B yours (core 3) alone, 20 calls on 20 new threads, 1 INFO line · C both, 8 threads · A' = A, line for line"

x defaults '^Executor beans: none$'; x defaults "$NOEXEC"; x defaults "^@Async bean: JDK proxy $TWENTY"
x defaults '^\$ java -XX:ActiveProcessorCount=2 -cp "\$CP" com\.tiffinbox\.harness\.Conditions 18556 boot$'
blk defaults "E   " "that JVM" | grep -qE "$A_POOL" || die "defaults E: still core 8 on two processors"
blk defaults "E   " "that JVM" | grep -qE "$A_ASYNC" || die "defaults E: still 8 threads on two processors"
x defaults '^that JVM.s flag, as it read it: int ActiveProcessorCount = 2 \{product\} \{command line\}$'
x defaults 'core-size defaults to 8 · spring\.task\.execution\.thread-name-prefix to task-$'
echo "  defaults: plain Spring - no executor bean, a JDK proxy, 20 calls on 20 new threads · two processors: still core 8, 8 threads (Boot's metadata: 8)"

x why '^\$ java -cp "\$CP" com\.tiffinbox\.harness\.Conditions 18557 kitchen --debug$'
x why '^the report.s 4 lists: positive matches 12 · negative matches 12 · exclusions 0 · unconditional classes 6$'
x why "^         - AnyNestedCondition 0 matched 2 did not; .*@ConditionalOnProperty \(spring\.task\.execution\.mode=force\) did not find property 'spring\.task\.execution\.mode'; .*found beans of type 'java\.util\.concurrent\.Executor' kitchenExecutor … \[\+[0-9]+ chars\]$"
echo "  why: 12 / 12 / 0 / 6 with your bean; two nested conditions, 0 matched: mode=force, or no Executor of yours - and it names kitchenExecutor"

x typos '^exit 1 · Boot.s failure report'
x typos "^  Failed to bind properties under 'spring\.task\.execution\.mode' to org\.springframework\.boot\.autoconfigure\.task\.TaskExecutionProperties\\\$Mode:$"
x typos '^      Value: "forced"$'; x typos '^      Origin: "spring\.task\.execution\.mode" from property source "commandLineArgs"$'
[ "$(awk '/The following values are valid:$/ { f = 1; next } f && /^      [A-Z]+$/ { n++ } f && !/^      [A-Z]+$/ { exit } END { print n + 0 }' .r-typos.out)" = 2 ] || die "typos: expected two valid values"
x typos '^      AUTO$'; x typos '^      FORCE$'
x typos "^exit 1 · Caused by: org\.springframework\.beans\.TypeMismatchException: Failed to convert value of type 'java\.lang\.String' to required type 'int'"
x typos '^exit 0 · WARN lines 0 · Executor beans: kitchenExecutor \(a ThreadPoolExecutor, core pool size 3\)$'
x typos "^its report names the key you typed on 0 lines · the key you meant: did not find property 'spring\.task\.execution\.mode'$"
t1=$(awk -F'md5 ' '/^the report with the typo: md5 / { print substr($2, 1, 32) }' .r-typos.out); t2=$(awk -F'md5 ' '/^the report with the typo: md5 / { print substr($3, 1, 32) }' .r-typos.out)
[ ${#t1} = 32 ] && [ "$t1" = "$t2" ] || die "typos: the report with the typo is not byte for byte the report without it ($t1 / $t2)"
x typos '^exit 0 · WARN lines 0 · @Async bean: JDK proxy · 20 calls ran on 8 threads, named task-#$'
x typos "^its report: @ConditionalOnBooleanProperty \(spring\.aop\.proxy-target-class=true\) found different value in property 'spring\.aop\.proxy-target-class' \(OnPropertyCondition\)$"
x typos '^  spring\.task\.execution\.mode +TaskExecutionProperties$'; x typos '^  spring\.aop\.proxy-target-class +none$'
echo "  typos: a wrong value converted - exit 1, two valid values (a @Value int: exit 1 too) · a wrong key - exit 0, 0 WARN, the report never names it and hashes the same · =ture - exit 0, 0 WARN, a JDK proxy; no class binds that key"
[ -z "$unpublished" ] || die "no published hash for:$unpublished - add the md5s above to receipts.md5 once the captures are checked"

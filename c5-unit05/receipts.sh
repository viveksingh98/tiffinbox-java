#!/bin/bash
# Course 5 · Unit 05's receipts: why 9 of 12 applied — the condition evaluation report, read. One bean of yours makes
# Boot's executor back off (A), a property brings it back beside yours (A'), and the two misspellings: a wrong VALUE fails
# loudly, a wrong KEY is silent and only the report shows it. Runs TiffinBox as unit 04 left it (../c5-unit04/after);
# this unit changes nothing in the anchor. Every number the video says asserted.
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
M2="$PWD/.m2-demo"
JOPTS="-Duser.language=en -Duser.country=US"
die() { echo "  *** $* ***"; exit 1; }
APP=../c5-unit04/after
(cd "$APP" && mvn -q -B -Dmaven.repo.local="$M2" -DskipTests clean package) || die "build failed: $APP"
CP="$APP/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls "$APP"/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"
rm -rf .harness; "$JAVA_HOME/bin/javac" -cp "$CP" -d .harness harness/demo/KitchenExecutorConfig.java harness/com/tiffinbox/harness/Conditions.java
run() { java $JOPTS -cp ".harness:$CP" com.tiffinbox.harness.Conditions "$@"; }
cap() { nm=$1; shift
  for i in 1 2 3; do "$@" > ".r-$nm.$i" 2>&1 || true; done
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] || die "$nm drifts across three runs"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"
  pub=$(awk -v n="$nm" '$1 == n { print $2 }' receipts.md5 2>/dev/null || true)
  if [ -z "$pub" ]; then note="(no published hash)"; elif [ "$pub" = "$h" ]; then note="= published"; else note="DIFFERS from the published $pub"; fi
  printf '  %-8s md5 %s  3/3  %s\n' "$nm" "$h" "$note"; }
# Every line Boot logs starts with a time and a pid: dropped from the captures here, and counted.
quiet() { awk '/^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T/ { b++; next } { print } END { printf "… %d Boot log line(s) elided …\n", b }'; }
# Cut a long line after a marker; the rest counted on the line itself.
cutat() { awk -v m="$1" '{ i = index($0, m); if (i) { n = i + length(m) - 1; printf "%s … [+%d chars]\n", substr($0, 1, n), length($0) - n } else print }'; }

# A / B / A': Boot's executor, yours, and both.
backoff() { echo "A  TiffinBox alone:";                          run boot 18551 2>&1 | quiet
            echo "B  plus one Executor bean of yours:";          run mine 18552 2>&1 | quiet
            echo "A' plus --spring.task.execution.mode=force:";  run mine 18553 --spring.task.execution.mode=force 2>&1 | quiet; }
cap backoff backoff

# The report, with and without your bean: its size, and the lines that answer "why".
report() { for m in boot mine; do
    run $m 18554 --debug > .r-report-$m.raw 2>&1 || true
    pos=$(awk '/^Positive matches:/{p=1;next} /^Negative matches:/{p=0} p && /^   [A-Za-z]/' .r-report-$m.raw | wc -l | tr -d ' ')
    neg=$(awk '/^Negative matches:/{n=1;next} /^(Exclusions|Unconditional classes):/{n=0} n && /^   [A-Za-z]/' .r-report-$m.raw | wc -l | tr -d ' ')
    printf '%s: CONDITIONS EVALUATION REPORT - positive matches %s, negative matches %s\n' "$m" "$pos" "$neg"; done
  echo "why Boot's executor is absent in 'mine' (the report's own lines):"
  awk '/^   TaskExecutorConfigurations.TaskExecutorConfiguration:$/{f=1} f{print} f && /^$/{exit}' .r-report-mine.raw | head -4 | cutat "(spring.task.execution.mode=force)"
  echo "a default Boot flips, as the report states it:"
  awk '/^   AopAutoConfiguration.ClassProxyingConfiguration matched:$/{f=1} f{print} f && /^$/{exit}' .r-report-boot.raw | head -3
  rm -f .r-report-*.raw; }
cap report report

# The two misspellings: the exit code is java's, taken before any filter.
typos() { run mine 18555 --spring.task.execution.mode=forced > .r-typo.raw 2>&1; ec=$?
  echo "a wrong VALUE, --spring.task.execution.mode=forced: exit $ec"
  echo "  Boot's failure report (its Description and Action, blank lines dropped):"
  awk '/^Description:$/{f=1;next} f && NF' .r-typo.raw | cutat "(caused by" | sed 's/^/  /'
  run mine 18556 --spring.task.execution.mod=force > .r-typo.raw 2>&1; ec=$?
  echo "a wrong KEY, --spring.task.execution.mod=force: exit $ec · WARN lines $(grep -c ' WARN ' .r-typo.raw)"
  grep '^Executor beans' .r-typo.raw | sed 's/^/  /'; rm -f .r-typo.raw; }
cap typos typos

echo
x() { grep -qE -- "$2" ".r-$1.out" || die "$1: expected /$2/"; }
x backoff '^Executor beans: \[applicationTaskExecutor\] · applicationTaskExecutor is a ThreadPoolTaskExecutor, core pool size 8$'
x backoff '^Executor beans: \[kitchenExecutor\]$'
x backoff '^Executor beans: \[applicationTaskExecutor, kitchenExecutor\] · applicationTaskExecutor is a ThreadPoolTaskExecutor, core pool size 8$'
echo "  A: Boot's pool (core 8) · B: yours only · A': both, with mode=force"
x report '^boot: CONDITIONS EVALUATION REPORT - positive matches [0-9]+, negative matches [0-9]+$'; x report '^mine: '
x report 'Did not match:'; x report 'spring.task.execution.mode=force'; x report 'ClassProxyingConfiguration matched:'; x report 'spring.aop.proxy-target-class=true'
echo "  the report: $(grep -o 'positive matches [0-9]*, negative matches [0-9]*' .r-report.out | paste -sd'|' - | sed 's/|/ -> /')"
x typos '^a wrong VALUE, --spring.task.execution.mode=forced: exit 1$'; x typos "Failed to bind properties under 'spring.task.execution.mode'"; x typos 'Value: "forced"'; x typos '^      FORCE$'
x typos '^a wrong KEY, --spring.task.execution.mod=force: exit 0 · WARN lines 0$'; x typos '^  Executor beans: \[kitchenExecutor\]$'
echo "  a wrong value: exit 1 and a failure report that lists AUTO and FORCE · a wrong key: exit 0, no warning, Boot's executor still absent"

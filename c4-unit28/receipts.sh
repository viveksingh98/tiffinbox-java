#!/bin/bash
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"
for i in 1 2 3; do java -cp "$CP" com.tiffinbox.RateVsDelay 2>&1 | ./jul.sh | tee ".r-shapes-raw.$i" | ./gaps.sh > ".r-shapes.$i"; done
h=$(md5 -q .r-shapes.1); [ "$h" = "$(md5 -q .r-shapes.2)" ] && [ "$h" = "$(md5 -q .r-shapes.3)" ] && ok=3/3 || ok="*** DRIFTS ***"
mv .r-shapes.1 .r-shapes.out; rm -f .r-shapes.2 .r-shapes.3
printf "  %-8s md5 %s  %s  (raw gaps masked)\n" shapes "$h" "$ok"
for i in 1 2 3; do java -cp "$CP" com.tiffinbox.CronNext > ".r-cron.$i" 2>&1; done
h=$(md5 -q .r-cron.1); [ "$h" = "$(md5 -q .r-cron.2)" ] && [ "$h" = "$(md5 -q .r-cron.3)" ] && ok=3/3 || ok="*** DRIFTS ***"
mv .r-cron.1 .r-cron.out; rm -f .r-cron.2 .r-cron.3; printf "  %-8s md5 %s  %s\n" cron "$h" "$ok"
echo
echo "  raw gaps, three runs (printed, never spoken):"
for i in 1 2 3; do grep -o 'starts: \[[0-9, ]*\]' ".r-shapes-raw.$i" | sed 's/starts: //' | paste -sd' ' - | sed "s/^/    run $i: /"; done
[ "$(grep -c 'every gap within 40 ms' .r-shapes.out)" = "3" ] && echo "  all three shapes hold: rate ~ period, delay ~ period + work, overrun rate ~ work" || { echo "  *** a shape failed ***"; exit 1; }
grep -q 'at most 1 running at once' .r-shapes.out && echo "  the overrunning rate never overlapped: at most 1 running at once" || exit 1
grep -q 'SATURDAY\|SUNDAY' .r-cron.out && { echo "  *** cron fired on a weekend ***"; exit 1; } || echo "  cron: the next four firings skip the weekend (computed, not waited for)"

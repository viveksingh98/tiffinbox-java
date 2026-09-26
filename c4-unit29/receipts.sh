#!/bin/bash
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"
# cap NAME CLASS [MASK]: three runs, BOTH streams through jul.sh; MASK drops the raw line from what is hashed
cap() {
  for i in 1 2 3; do java -cp "$CP" "com.tiffinbox.$2" 2>&1 | ./jul.sh > ".r-$1-raw.$i"; grep -v '^  raw (printed' ".r-$1-raw.$i" > ".r-$1.$i"; done
  h=$(md5 -q ".r-$1.1"); [ "$h" = "$(md5 -q ".r-$1.2")" ] && [ "$h" = "$(md5 -q ".r-$1.3")" ] && ok=3/3 || ok="*** DRIFTS ***"
  mv ".r-$1.1" ".r-$1.out"; rm -f ".r-$1.2" ".r-$1.3"; printf "  %-8s md5 %s  %s\n" "$1" "$h" "$ok"
  [ "$ok" = 3/3 ] || exit 1
}
cap starved Starved
cap wrapped WrappedOrNot
cap hung Hung
echo
echo "  raw numbers, three runs (printed, never spoken):"
for i in 1 2 3; do grep '^  raw (printed' ".r-starved-raw.$i" | sed "s/^  raw (printed, never spoken): /    run $i: /"; done
S=.r-starved.out; T=.r-wrapped.out; H=.r-hung.out
[ "$(grep -c 'No TaskScheduler/ScheduledExecutorService bean found' $S)" = 1 ] && echo "  pitfall one: Spring said, at INFO, that it found no scheduler - once, for the default only" || exit 1
grep -q 'one thread (the default): 1 \[pool-<n>-thread-<n>\]' $S && grep -q 'a pool of two           : 2 \[kitchen-sched-<n>\]' $S \
  && echo "  the default ran both jobs on 1 thread; the sized pool used 2" || exit 1
grep -q 'counting cannot see the problem' $S && echo "  the check COUNT was about the same either way - counting cannot see it" || exit 1
grep -q 'the report STARVED the check' $S && grep -q 'the check kept its rhythm' $S && echo "  the longest GAP can: starved on one thread, steady on two" || exit 1
grep -q 'caught up in a burst' $S && grep -q 'back-to-back, pool of two       : none' $S && echo "  the missed checks ran back-to-back afterwards (one thread only)" || exit 1
[ "$(grep -c '^SEVERE: Unexpected error occurred in scheduled task' $T)" = 1 ] && echo "  pitfall two, through Spring: exactly one SEVERE line for the one bad run" || exit 1
grep -q 'thread: pool-<n>-thread-<n>   runs in 0.7 s: MORE than 3 - it kept going' $T && echo "  ... and Spring's schedule kept firing (on a JDK pool-<n>-thread-<n>)" || exit 1
grep -q '^  thread: pool-<n>-thread-<n>   runs in 0.7 s: 2   printed while it ran: nothing   future done? true$' $T \
  && echo "  the SAME kind of JDK thread, no wrapper: dead after run 2, nothing printed (measured), future done" || exit 1
grep -q 'by 0.6 s: \([0-9]*\)   by 2.6 s: \1   -> the check has STOPPED' $H && [ "$(grep -cE '^(WARNING|SEVERE)' $H)" = 0 ] \
  && echo "  a job that never returns: the order check STOPS (same count at 0.6 s and 2.6 s), nothing logged" || { echo "  *** hung claim failed ***"; exit 1; }

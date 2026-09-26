#!/bin/bash
set -e
cd "$(dirname "$0")"
: "${JAVA_HOME:?export JAVA_HOME=/opt/homebrew/opt/openjdk@25 first}"
[ -f cp.txt ] || mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath >/dev/null 2>&1
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
CP="target/classes:$(cat cp.txt)"
cap() { nm=$1; shift; ec=0
  for i in 1 2 3; do { "$@" 2>&1; } | ./jul.sh > ".r-$nm.$i" || true; done
  "$@" >/dev/null 2>&1 || ec=$?
  h=$(md5 -q ".r-$nm.1"); [ "$h" = "$(md5 -q ".r-$nm.2")" ] && [ "$h" = "$(md5 -q ".r-$nm.3")" ] && ok=3/3 || ok="*** DRIFTS ***"
  mv ".r-$nm.1" ".r-$nm.out"; rm -f ".r-$nm.2" ".r-$nm.3"; echo "$ec" > ".r-$nm.exit"
  printf "  %-10s md5 %s  %s  exit %s\n" "$nm" "$h" "$ok" "$ec"; }
cap threads  java -cp "$CP" com.tiffinbox.WhoseThread
cap pools    java -cp "$CP" com.tiffinbox.Pools
cap failure  java -cp "$CP" com.tiffinbox.Failures
cap handler  java -cp "$CP" com.tiffinbox.Failures handler
echo
awk '/\[caller\] cook\(\) returned/{r=NR} /\[cook \]/{c=NR} END{exit !(r<c)}' .r-threads.out && echo "  cook() returned BEFORE the cooking line printed (latched)" || { echo "  *** not async ***"; exit 1; }
grep -q '\[inner\] on main' .r-threads.out && echo "  self-invocation ran on main - the trap, again" || exit 1
d=$(grep 'the default' .r-pools.out | grep -o '[0-9]* distinct' | awk '{print $1}'); s=$(grep 'ThreadPool' .r-pools.out | grep -o '[0-9]* distinct' | awk '{print $1}')
echo "  default: $d threads for 20 tasks (not a pool)   sized pool: $s"; [ "$d" = "20" ] && [ "$s" = "2" ] || exit 1
grep -q '^SEVERE: Unexpected exception occurred invoking async method' .r-failure.out && grep -q 'does not know' .r-failure.out \
  && echo "  void @Async that throws: SEVERE in the log, caller unaware" || exit 1
grep -q 'price().get() threw ExecutionException, cause IllegalStateException' .r-failure.out && echo "  CompletableFuture: get() throws ExecutionException, and the cause is reachable from code" || exit 1
grep -q '\[caller\] IllegalArgumentException: Invalid return type for async method (only Future and void supported)' .r-threads.out \
  && echo "  @Async on a String-returning method: the call throws IllegalArgumentException - void or Future only" || exit 1
# the INFO line is logged on the FIRST async call, not at startup (RED #7): it comes after "[caller] on main"
awk '/\[caller\] on main/{c=NR} /No task executor bean found/{i=NR} END{exit !(c && i>c)}' .r-threads.out \
  && echo "  the 'no task executor' INFO line appears at the first async call, not at startup" || exit 1
grep -q '\[handler\] burn() threw' .r-handler.out && ! grep -q '^SEVERE' .r-handler.out && echo "  with a handler: caught in code, no SEVERE" || exit 1

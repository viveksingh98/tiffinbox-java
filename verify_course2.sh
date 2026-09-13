#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# verify_course2.sh — runs every command the Core Java II (`c2-*`) READMEs give
# a viewer, and says PASS/FAIL for each one.
#
#   ./verify_course2.sh              # every c2-* folder that exists
#   ./verify_course2.sh 09 14        # only those units
#   ./verify_course2.sh capstone     # only the capstone
#   SKIP_SLOW=1 ./verify_course2.sh  # skip the ~50 s and deadlock demos
#
# It walks only the folders that are actually present, so it stays green as
# new units land. Long demos are time-boxed and their JVMs killed; ports and
# stray processes are asserted free before it exits.
#
# Requires JDK 25 (compact source files, JEP 512 + preview StructuredTaskScope).
#   JAVA_HOME=/opt/homebrew/opt/openjdk@25 ./verify_course2.sh
# ---------------------------------------------------------------------------
set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@25}"
if [ ! -x "$JAVA_HOME/bin/java" ]; then
  if command -v java >/dev/null 2>&1; then JAVA_HOME="$(dirname "$(dirname "$(command -v java)")")"
  else echo "no JDK found: set JAVA_HOME to a JDK 25+"; exit 2; fi
fi
export JAVA_HOME
JAVA="$JAVA_HOME/bin/java"
JAVAC="$JAVA_HOME/bin/javac"
JAVAP="$JAVA_HOME/bin/javap"
JCMD="$JAVA_HOME/bin/jcmd"

JV="$("$JAVA" -version 2>&1 | head -1)"
case "$JV" in
  *'"2'[5-9]* | *'"'[3-9][0-9]*) : ;;
  *) echo "WARNING: need JDK 25+, found: $JV" ;;
esac

# Unique tag so we can always find and kill our own JVMs, never the user's.
TAG="c2verify$$"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/c2verify.XXXXXX")"
OUT="$WORK/out.txt"
PORT="${PORT:-18425}"
SKIP_SLOW="${SKIP_SLOW:-0}"

PASS=0; FAIL=0; SKIP=0; FAILED_LABELS=()
RED=''; GRN=''; YLW=''; DIM=''; OFF=''
if [ -t 1 ]; then RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; DIM=$'\033[2m'; OFF=$'\033[0m'; fi

cleanup() {
  pkill -9 -f "$TAG" >/dev/null 2>&1
  rm -rf "$WORK"
  # never leave build output, heap dumps or H2 files behind
  find "$REPO" -maxdepth 2 -type d -name out -path '*/c2-*' -exec rm -rf {} + 2>/dev/null
  rm -rf "$REPO"/c2-*/dump.hprof "$REPO"/c2-*/*.mv.db "$REPO"/c2-*/*.trace.db 2>/dev/null
  rm -rf "$REPO"/c2-capstone/target 2>/dev/null
}
trap cleanup EXIT INT TERM

ok()   { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$GRN" "$OFF" "$1"; }
bad()  { FAIL=$((FAIL+1)); FAILED_LABELS+=("$1"); printf '  %sFAIL%s  %s\n     %s\n' "$RED" "$OFF" "$1" "$2";
         sed -n '1,12p' "$OUT" 2>/dev/null | sed 's/^/     | /'; }
skip() { SKIP=$((SKIP+1)); printf '  %sSKIP%s  %s %s(%s)%s\n' "$YLW" "$OFF" "$1" "$DIM" "$2" "$OFF"; }

# run CMD... with a wall-clock limit; stdout+stderr -> $OUT; returns exit code
# (124 if it had to be killed). Kills the whole process group of the child.
RC=0
timed() {
  local secs="$1"; shift
  ( "$@" >"$OUT" 2>&1 ) &
  local pid=$! waited=0 limit=$(( secs * 10 ))
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$waited" -ge "$limit" ]; then
      pkill -9 -P "$pid" >/dev/null 2>&1; kill -9 "$pid" >/dev/null 2>&1
      pkill -9 -f "$TAG" >/dev/null 2>&1
      wait "$pid" 2>/dev/null; RC=124; return 124
    fi
    sleep 0.1; waited=$((waited+1))
  done
  wait "$pid"; RC=$?; return $RC
}

# expect_ok  LABEL TIMEOUT PATTERN CMD...   exit 0 and PATTERN in the output
expect_ok() {
  local label="$1" t="$2" pat="$3"; shift 3
  timed "$t" "$@"
  if [ "$RC" -eq 124 ]; then bad "$label" "timed out after ${t}s (expected it to finish)"; return; fi
  if [ "$RC" -ne 0 ]; then bad "$label" "exit $RC, expected 0"; return; fi
  if [ -n "$pat" ] && ! grep -qE "$pat" "$OUT"; then bad "$label" "expected output matching: $pat"; return; fi
  ok "$label"
}

# expect_fail LABEL TIMEOUT PATTERN CMD...  non-zero exit and PATTERN present
expect_fail() {
  local label="$1" t="$2" pat="$3"; shift 3
  timed "$t" "$@"
  if [ "$RC" -eq 124 ]; then bad "$label" "timed out after ${t}s (expected it to fail fast)"; return; fi
  if [ "$RC" -eq 0 ]; then bad "$label" "exit 0, expected a failure"; return; fi
  if [ -n "$pat" ] && ! grep -qE "$pat" "$OUT"; then bad "$label" "expected error matching: $pat"; return; fi
  ok "$label (fails on purpose)"
}

# expect_any  LABEL TIMEOUT PATTERN CMD...  either exit code (race demos)
expect_any() {
  local label="$1" t="$2" pat="$3"; shift 3
  timed "$t" "$@"
  if [ "$RC" -eq 124 ]; then bad "$label" "timed out after ${t}s"; return; fi
  if [ -n "$pat" ] && ! grep -qE "$pat" "$OUT"; then bad "$label" "expected output matching: $pat"; return; fi
  ok "$label"
}

want() {  # unit filter
  [ ${#UNITS[@]} -eq 0 ] && return 0
  local u; for u in "${UNITS[@]}"; do [ "$u" = "$1" ] && return 0; done; return 1
}
unit() {  # unit NN  -> cd into c2-unitNN, or skip the section
  local n="$1"
  want "$n" || return 1
  [ -d "$REPO/c2-unit$n" ] || { return 1; }
  printf '\n%sc2-unit%s%s  %s\n' "$DIM" "$n" "$OFF" "$2"
  cd "$REPO/c2-unit$n" || return 1
  rm -rf out
  return 0
}
port_free() {
  if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then return 1; fi
  return 0
}

UNITS=("$@")

printf 'verify_course2.sh — %s\n' "$JV"
printf 'repo: %s\n' "$REPO"
[ "$SKIP_SLOW" = "1" ] && printf '%sSKIP_SLOW=1 — the 50 s pool run and the deadlock demo are skipped%s\n' "$YLW" "$OFF"

# ---------------------------------------------------------------- unit 01 ---
if unit 01 "Stack vs heap"; then
  expect_ok "java StackVsHeap.java" 60 'same object\? true' "$JAVA" StackVsHeap.java
  "$JAVAC" -d out MemoryMap.java >/dev/null 2>&1
  expect_ok "javac -d out MemoryMap.java && java -Xmx64m -cp out MemoryMap" 60 'Max heap: +64 MB' \
      "$JAVA" -Xmx64m -cp out MemoryMap
  expect_ok "java Deep.java (StackOverflowError, depth varies)" 90 'stack overflowed after [0-9]+ calls' \
      "$JAVA" Deep.java
  expect_ok "java -Xss256k Deep.java (fixed depth)" 90 'stack overflowed after [0-9]+ calls' \
      "$JAVA" -Xss256k Deep.java
fi

# ---------------------------------------------------------------- unit 02 ---
if unit 02 "Heap limits and OutOfMemoryError"; then
  "$JAVAC" -d out Overflow.java OrderHistory.java BoundedHistory.java Hold.java >/dev/null 2>&1
  expect_fail "javac -d out Overflow.java && java -Xmx16m -cp out Overflow" 120 \
      'OutOfMemoryError: Java heap space' "$JAVA" -Xmx16m -cp out Overflow
  expect_fail "java -Xmx64m -cp out OrderHistory (leak -> OOM on day 4)" 180 \
      'OutOfMemoryError' "$JAVA" -Xmx64m -cp out OrderHistory
  expect_ok "java -Xmx64m -cp out BoundedHistory (the fix)" 180 \
      'history holds 10 orders' "$JAVA" -Xmx64m -cp out BoundedHistory
  expect_fail "java -Xmx16m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dump.hprof -cp out Overflow" 120 \
      'Heap dump file created' "$JAVA" -Xmx16m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dump.hprof -cp out Overflow
  rm -f dump.hprof
  # live JVM inspection: start Hold, read it with jcmd, then always kill it
  "$JAVA" "-D$TAG=hold" -Xms64m -Xmx64m -cp out Hold >"$WORK/hold.log" 2>&1 &
  HOLD=$!; sleep 2
  if kill -0 "$HOLD" 2>/dev/null; then
    "$JCMD" "$HOLD" VM.flags >"$OUT" 2>&1
    grep -q 'MaxHeapSize=67108864' "$OUT" && ok "jcmd <pid> VM.flags -> -XX:MaxHeapSize=67108864" \
      || bad "jcmd <pid> VM.flags" "MaxHeapSize=67108864 not found"
    "$JCMD" "$HOLD" GC.heap_info >"$OUT" 2>&1
    grep -q 'garbage-first heap' "$OUT" && ok "jcmd <pid> GC.heap_info -> garbage-first heap" \
      || bad "jcmd <pid> GC.heap_info" "no 'garbage-first heap' line"
  else bad "java -Xms64m -Xmx64m -cp out Hold &" "it exited before jcmd could read it"; fi
  kill -9 "$HOLD" >/dev/null 2>&1; wait "$HOLD" 2>/dev/null
  pgrep -f "$TAG=hold" >/dev/null 2>&1 && bad "Hold cleanup" "a Hold JVM survived" || ok "Hold JVM killed, nothing left running"
fi

# ---------------------------------------------------------------- unit 03 ---
if unit 03 "Garbage collection"; then
  expect_ok "java Reachability.java" 120 'after System.gc\(\):' "$JAVA" Reachability.java
  expect_ok "java -XX:+DisableExplicitGC Reachability.java" 120 'after System.gc\(\):' \
      "$JAVA" -XX:+DisableExplicitGC Reachability.java
  expect_ok "java -Xlog:gc Reachability.java" 120 'Pause Young|Pause Full' "$JAVA" -Xlog:gc Reachability.java
  "$JAVA" "-D$TAG=sleeper" -Xmx64m Sleeper.java >"$WORK/sleeper.log" 2>&1 &
  SL=$!; sleep 3
  if kill -0 "$SL" 2>/dev/null; then
    "$JCMD" "$SL" GC.heap_info >"$OUT" 2>&1
    grep -q 'garbage-first heap' "$OUT" && ok "jcmd <pid> GC.heap_info on the running Sleeper" \
      || bad "jcmd <pid> GC.heap_info (Sleeper)" "no 'garbage-first heap' line"
    "$JCMD" "$SL" GC.run >"$OUT" 2>&1
    grep -qi 'Command executed successfully' "$OUT" && ok "jcmd <pid> GC.run" \
      || bad "jcmd <pid> GC.run" "GC.run did not report success"
  else bad "java -Xmx64m Sleeper.java &" "it exited before jcmd could read it"; fi
  kill -9 "$SL" >/dev/null 2>&1; wait "$SL" 2>/dev/null
  pgrep -f "$TAG=sleeper" >/dev/null 2>&1 && bad "Sleeper cleanup" "a Sleeper JVM survived" || ok "Sleeper JVM killed"
fi

# ---------------------------------------------------------------- unit 04 ---
if unit 04 "Reference types"; then
  expect_ok "java Weak.java"        60 'weak after gc: null'          "$JAVA" Weak.java
  expect_ok "java WeakCache.java"   60 'after key = null \+ gc: 0'    "$JAVA" WeakCache.java
  expect_ok "java NoSleep.java (honesty demo: looked too early)" 60 'after key = null \+ gc: 1' "$JAVA" NoSleep.java
  expect_ok "java InternedKey.java" 60 'literal key cache: 1'         "$JAVA" InternedKey.java
  expect_ok "java Bounded.java"     60 'Sam, Ravi, Nina'              "$JAVA" Bounded.java
fi

# ---------------------------------------------------------------- unit 05 ---
if unit 05 "JIT and escape analysis"; then
  expect_ok "java Escape.java"                        120 'checksum:' "$JAVA" Escape.java
  expect_ok "java -XX:-DoEscapeAnalysis Escape.java"  180 'round 6: allocated 46875 KB' "$JAVA" -XX:-DoEscapeAnalysis Escape.java
  expect_ok "java -Xint Escape.java"                  300 'round 6: allocated 46875 KB' "$JAVA" -Xint Escape.java
  expect_ok "java -XX:TieredStopAtLevel=1 Escape.java" 180 'round 6: allocated 46875 KB' "$JAVA" -XX:TieredStopAtLevel=1 Escape.java
fi

# ---------------------------------------------------------------- unit 06 ---
if unit 06 "Type erasure"; then
  expect_ok "java SameClass.java"   60 'same class\?      true' "$JAVA" SameClass.java
  expect_ok "java InnerStatic.java" 60 'created: 2'             "$JAVA" InnerStatic.java
  expect_ok "javac -d out Customer.java Bills.java" 60 '' "$JAVAC" -d out Customer.java Bills.java
  expect_ok "javap -s -p out/Bills.class (erased descriptor)" 60 '\(Ljava/util/List;\)I' "$JAVAP" -s -p out/Bills.class
  expect_ok "javac -d out ByBill.java" 60 '' "$JAVAC" -d out ByBill.java
  expect_ok "javap -v -p out/ByBill.class (ACC_BRIDGE)" 60 'ACC_BRIDGE' "$JAVAP" -v -p out/ByBill.class
  expect_fail "javac -d out NewT.java"      60 'error' "$JAVAC" -d out NewT.java
  expect_fail "javac -d out ListOfInt.java" 60 'error' "$JAVAC" -d out ListOfInt.java
  expect_fail "javac -d out TDotClass.java" 60 'error' "$JAVAC" -d out TDotClass.java
  expect_ok   "javac -Xlint:unchecked -d out Pollution.java" 60 'unchecked' "$JAVAC" -Xlint:unchecked -d out Pollution.java
  expect_fail "java -cp out Pollution"      60 'ClassCastException' "$JAVA" -cp out Pollution
fi

# ---------------------------------------------------------------- unit 07 ---
if unit 07 "Generic classes"; then
  expect_ok   "java Repo.java"            60 '' "$JAVA" Repo.java
  expect_fail "javac -d out StaticT.java" 60 'non-static type variable' "$JAVAC" -d out StaticT.java
  expect_ok   "javac -d out StaticFix.java" 60 '' "$JAVAC" -d out StaticFix.java
  expect_fail "javac -d out WrongId.java" 60 'int cannot be converted to String' "$JAVAC" -d out WrongId.java
fi

# ---------------------------------------------------------------- unit 08 ---
if unit 08 "Bounded types"; then
  expect_ok "java Bounded.java" 60 'biggest bill:' "$JAVA" Bounded.java
  expect_ok "javac -d out Bounded.java" 60 '' "$JAVAC" -d out Bounded.java
  expect_ok "javap -s -p out/Bounded.class (erases to the first bound)" 60 'Ljava/lang/Comparable;' "$JAVAP" -s -p out/Bounded.class
  expect_fail "javac -d out BareT.java"         60 'cannot find symbol'  "$JAVAC" -d out BareT.java
  expect_fail "javac -d out NotComparable.java" 60 'incompatible bounds' "$JAVAC" -d out NotComparable.java
  expect_fail "javac -d out Order.java"         60 'interface expected here' "$JAVAC" -d out Order.java
fi

# ---------------------------------------------------------------- unit 09 ---
if unit 09 "Wildcards and PECS"; then
  expect_ok "java Wildcards.java" 60 'veg only total: 220' "$JAVA" Wildcards.java
  expect_fail "javac -d out Invariant.java" 60 'List<VegMeal> cannot be converted to List<Meal>' "$JAVAC" -d out Invariant.java
  expect_fail "javac -Xdiags:verbose -d out AddToExtends.java" 60 'no suitable method found for add' \
      "$JAVAC" -Xdiags:verbose -d out AddToExtends.java
  expect_ok   "javac -d out ArrayStore.java (compiles clean)" 60 '' "$JAVAC" -d out ArrayStore.java
  expect_fail "java -cp out ArrayStore"     60 'ArrayStoreException' "$JAVA" -cp out ArrayStore
  expect_fail "javac -d out NoWild.java (the same ledger without wildcards)" 60 \
      'List<Object> cannot be converted to List<Integer>' "$JAVAC" -d out NoWild.java
fi

# ---------------------------------------------------------------- unit 10 ---
if unit 10 "Generic methods and Class<T> tokens"; then
  expect_ok   "java GenericMethods.java"    60 '' "$JAVA" GenericMethods.java
  expect_fail "javac -d out Witness.java"   60 'Object cannot be converted to String' "$JAVAC" -d out Witness.java
  expect_ok   "javac -d out WitnessFixed.java" 60 '' "$JAVAC" -d out WitnessFixed.java
  expect_ok   "java -cp out WitnessFixed"   60 '' "$JAVA" -cp out WitnessFixed
  expect_fail "javac -d out DiamondMiss.java" 60 'Object cannot be converted to int' "$JAVAC" -d out DiamondMiss.java
  expect_ok   "javac -d out WrongToken.java" 60 '' "$JAVAC" -d out WrongToken.java
  expect_fail "java -cp out WrongToken"     60 'ClassCastException' "$JAVA" -cp out WrongToken
  expect_ok   "javac -d out PlainCast.java" 60 '' "$JAVAC" -d out PlainCast.java
  expect_fail "java -cp out PlainCast"      60 'ClassCastException' "$JAVA" -cp out PlainCast
fi

# ---------------------------------------------------------------- unit 11 ---
if unit 11 "Threads"; then
  expect_ok "java States.java"      90 'TERMINATED' "$JAVA" States.java
  expect_ok "java Cooks.java"       90 '24300'      "$JAVA" Cooks.java
  expect_ok "java StartVsRun.java"  90 'TERMINATED' "$JAVA" StartVsRun.java
  expect_ok "java Daemon.java"      90 ''           "$JAVA" Daemon.java
  expect_fail "java StartTwice.java" 90 'IllegalThreadStateException' "$JAVA" StartTwice.java
fi

# ---------------------------------------------------------------- unit 12 ---
if unit 12 "Race conditions"; then
  expect_ok "java LostUpdate.java (value differs every run)"        120 'actual: +[0-9]+' "$JAVA" LostUpdate.java
  expect_ok "java VolatileNotEnough.java (volatile is not atomic)"  120 'volatile counter: [0-9]+' "$JAVA" VolatileNotEnough.java
  expect_ok "java Synced.java"                                      120 'actual: +2000000' "$JAVA" Synced.java
  expect_ok "java Interleave.java"                                  120 '' "$JAVA" Interleave.java
  expect_ok "javac -d out Counter.java"                             60  '' "$JAVAC" -d out Counter.java
  expect_ok "javap -c -p -cp out Counter (getstatic/iadd/putstatic)" 60 'iadd' "$JAVAP" -c -p -cp out Counter
  expect_fail "java BadMonitor.java" 60 'IllegalMonitorStateException' "$JAVA" BadMonitor.java
fi

# ---------------------------------------------------------------- unit 13 ---
if unit 13 "Executors and Future"; then
  expect_ok "java Pool.java"       120 'month total: +243000' "$JAVA" Pool.java
  expect_ok "java InvokeAll.java"  120 'Ravi +-> 7200'       "$JAVA" InvokeAll.java
  expect_ok "java Names.java"      120 'pool-1-thread-1'     "$JAVA" Names.java
  expect_fail "java PoolOops.java" 120 'RejectedExecutionException' "$JAVA" PoolOops.java
fi

# ---------------------------------------------------------------- unit 14 ---
if unit 14 "Locks, atomics and concurrent collections"; then
  expect_ok "java Atomics.java"  120 '' "$JAVA" Atomics.java
  expect_ok "java Revenue.java"  120 '' "$JAVA" Revenue.java
  expect_ok "java Snapshot.java" 120 '' "$JAVA" Snapshot.java
  expect_ok "java TryLock.java"  120 '' "$JAVA" TryLock.java
  expect_any "java NaturalRace.java (honesty demo: may or may not throw)" 120 '' "$JAVA" NaturalRace.java
  expect_ok "javac -d out Deadlock.java" 60 '' "$JAVAC" -d out Deadlock.java
  if [ "$SKIP_SLOW" = "1" ]; then skip "java -cp out Deadlock" "SKIP_SLOW=1"
  else
    "$JAVA" "-D$TAG=deadlock" -cp out Deadlock >"$WORK/dead.log" 2>&1 &
    DL=$!; sleep 4
    if kill -0 "$DL" 2>/dev/null; then
      "$JCMD" "$DL" Thread.print >"$OUT" 2>&1
      grep -q 'Found one Java-level deadlock' "$OUT" \
        && ok "java -cp out Deadlock + jcmd <pid> Thread.print -> Found one Java-level deadlock" \
        || bad "jcmd <pid> Thread.print (Deadlock)" "no 'Found one Java-level deadlock' line"
    else bad "java -cp out Deadlock" "it exited — a deadlock demo must hang"; fi
    kill -9 "$DL" >/dev/null 2>&1; wait "$DL" 2>/dev/null
    sleep 0.5
    pgrep -f "$TAG=deadlock" >/dev/null 2>&1 \
      && bad "Deadlock cleanup" "the deadlocked JVM survived kill -9" \
      || ok "deadlocked JVM killed, nothing left running"
  fi
fi

# ---------------------------------------------------------------- unit 15 ---
if unit 15 "Virtual threads"; then
  expect_ok "java Waiters.java"  180 'completed:         10000' "$JAVA" Waiters.java
  expect_ok "java Probe15.java"  120 'isDaemon:' "$JAVA" Probe15.java
  expect_ok "java Ghost.java"    120 'main is done' "$JAVA" Ghost.java
  expect_ok "java -Djdk.virtualThreadScheduler.parallelism=4 -Djdk.virtualThreadScheduler.maxPoolSize=4 Carriers.java" 180 '' \
      "$JAVA" -Djdk.virtualThreadScheduler.parallelism=4 -Djdk.virtualThreadScheduler.maxPoolSize=4 Carriers.java
  expect_ok "java -Djdk.virtualThreadScheduler.parallelism=1 -Djdk.virtualThreadScheduler.maxPoolSize=1 Pinning.java (JEP 491)" 180 \
      'all finished: +true' \
      "$JAVA" -Djdk.virtualThreadScheduler.parallelism=1 -Djdk.virtualThreadScheduler.maxPoolSize=1 Pinning.java
  expect_fail "java VirtualOops.java" 120 'Exception|Error' "$JAVA" VirtualOops.java
  if [ "$SKIP_SLOW" = "1" ]; then skip "java PoolWaiters.java" "SKIP_SLOW=1 — this one takes ~50 s"
  else expect_ok "java PoolWaiters.java (~50 s on purpose)" 180 'completed:         10000' "$JAVA" PoolWaiters.java; fi
fi

# ---------------------------------------------------------------- unit 16 ---
if unit 16 "CompletableFuture"; then
  expect_ok   "java Compose.java" 120 'month total: +24300' "$JAVA" Compose.java
  expect_ok   "java Recover.java" 120 'orTimeout:' "$JAVA" Recover.java
  expect_fail "java CfOops.java"  120 'CompletionException' "$JAVA" CfOops.java
  expect_fail "java NoUnwrap.java (honesty demo: getCause() is null)" 120 'NullPointerException' "$JAVA" NoUnwrap.java
fi

# ---------------------------------------------------------------- unit 17 ---
if unit 17 "Structured concurrency and scoped values"; then
  expect_ok "java --enable-preview Scope.java"     120 '' "$JAVA" --enable-preview Scope.java
  expect_ok "java --enable-preview ScopeFail.java" 120 'scope cancelled\? true' "$JAVA" --enable-preview ScopeFail.java
  expect_ok "java --enable-preview Scoped.java"    120 '' "$JAVA" --enable-preview Scoped.java
  expect_ok "java SvOnly.java (ScopedValue is final, no flag)" 120 '' "$JAVA" SvOnly.java
  expect_ok "javac --enable-preview --release 25 -d out Scope.java" 120 '' \
      "$JAVAC" --enable-preview --release 25 -d out Scope.java
  expect_ok "java --enable-preview -cp out Scope" 120 '' "$JAVA" --enable-preview -cp out Scope
  expect_fail "java -cp out Scope (no --enable-preview: refuses to run)" 60 'Preview features are not enabled' "$JAVA" -cp out Scope
fi

# ---------------------------------------------------------------- unit 18 ---
if unit 18 "Order queue"; then
  expect_ok   "java Pipeline.java"  180 '24300' "$JAVA" Pipeline.java
  expect_fail "java QueueOops.java" 120 'IllegalStateException: Queue full' "$JAVA" QueueOops.java
fi

# --------------------------------------------------------------- capstone ---
if want capstone && [ -d "$REPO/c2-capstone" ]; then
  printf '\n%sc2-capstone%s  TiffinBox server (Maven, H2, Jackson, virtual threads)\n' "$DIM" "$OFF"
  cd "$REPO/c2-capstone" || exit 1
  if ! command -v mvn >/dev/null 2>&1; then
    skip "mvn -q package" "Maven is not installed"
  else
    if ! port_free; then
      bad "port $PORT" "something is already listening on $PORT — set PORT=<free port>"
    else
      expect_ok "mvn -q package (downloads H2 + Jackson on the first run)" 600 '' \
          mvn -q -B package
      expect_ok "mvn -q dependency:copy-dependencies" 600 '' mvn -q -B dependency:copy-dependencies
      CP="target/classes:target/dependency/*"
      "$JAVA" "-D$TAG=server" --enable-preview -cp "$CP" com.tiffinbox.TiffinBoxServer "$PORT" \
          >"$WORK/server.log" 2>&1 &
      SV=$!
      up=0
      for _ in $(seq 1 100); do
        if curl -s -m 2 "http://127.0.0.1:$PORT/customers" >"$OUT" 2>&1; then up=1; break; fi
        kill -0 "$SV" 2>/dev/null || break
        sleep 0.3
      done
      if [ "$up" -ne 1 ]; then
        cp "$WORK/server.log" "$OUT" 2>/dev/null
        bad "java --enable-preview -cp 'target/classes:target/dependency/*' com.tiffinbox.TiffinBoxServer $PORT" \
            "the server never answered on 127.0.0.1:$PORT"
      else
        grep -q 'TiffinBox listening' "$WORK/server.log" \
          && ok "server start banner (orders cooked / routes mapped / listening)" \
          || bad "server start banner" "no 'TiffinBox listening' line"
        for route in /customers /dashboard /kitchen /revenue; do
          curl -s -m 5 "http://127.0.0.1:$PORT$route" >"$OUT" 2>&1
          if [ -s "$OUT" ] && ! grep -q '"error"' "$OUT"; then ok "GET $route -> JSON"
          else bad "GET $route" "empty body or an error object"; fi
        done
        curl -s -m 5 "http://127.0.0.1:$PORT/shutdown" >"$OUT" 2>&1
        grep -q 'stopping' "$OUT" && ok "GET /shutdown -> {\"stopping\":true}" || bad "GET /shutdown" "no stopping response"
      fi
      # the server must be gone and the port free no matter what happened above
      for _ in $(seq 1 40); do kill -0 "$SV" 2>/dev/null || break; sleep 0.25; done
      kill -9 "$SV" >/dev/null 2>&1; wait "$SV" 2>/dev/null
      pkill -9 -f "$TAG=server" >/dev/null 2>&1
      sleep 1
      if port_free; then ok "port $PORT free again, no server process left"
      else bad "port $PORT" "still in LISTEN after shutdown"; fi
    fi
  fi
  rm -rf target
fi

# ------------------------------------------------------------------ report ---
cd "$REPO"
printf '\n---------------------------------------------\n'
# Units that have landed since this script was last extended: say so instead of
# quietly passing, so nobody mistakes "not checked" for "checked and green".
if [ ${#UNITS[@]} -eq 0 ]; then
  UNCHECKED=""
  for d in "$REPO"/c2-*/; do
    n="$(basename "$d")"
    case "$n" in
      c2-unit0[1-9]|c2-unit1[0-8]|c2-capstone) continue ;;
      *) UNCHECKED="$UNCHECKED $n" ;;
    esac
  done
  [ -n "$UNCHECKED" ] && printf '%snot covered by this script yet:%s%s\n' "$YLW" "$OFF" "$UNCHECKED"
fi
printf '%sPASS %d%s   %sFAIL %d%s   %sSKIP %d%s\n' "$GRN" "$PASS" "$OFF" "$RED" "$FAIL" "$OFF" "$YLW" "$SKIP" "$OFF"
if [ "$FAIL" -gt 0 ]; then
  printf 'failed:\n'
  for l in "${FAILED_LABELS[@]}"; do printf '  - %s\n' "$l"; done
  exit 1
fi
printf 'all green.\n'
exit 0

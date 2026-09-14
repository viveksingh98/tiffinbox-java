#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# verify_course2.sh — runs every command the Core Java II (`c2-*`) READMEs give
# a viewer, and says PASS/FAIL for each one.
#
#   ./verify_course2.sh              # every c2-* folder that exists
#   ./verify_course2.sh 09 14        # only those units
#   ./verify_course2.sh capstone     # only the capstone (that is unit 42's code)
#   SKIP_SLOW=1 ./verify_course2.sh  # skip every demo that is slow on purpose
#
# It walks only the folders that are actually present, so it stays green as
# new units land. Long demos are time-boxed and their JVMs killed; ports and
# stray processes are asserted free before it exits.
#
# Requires JDK 25 (compact source files, JEP 512 + preview StructuredTaskScope).
#   JAVA_HOME=/opt/homebrew/opt/openjdk@25 ./verify_course2.sh
#
# JAVA_HOME is not decoration: a default shell on this Mac gives Maven JDK 26, and
# the capstone's `--enable-preview` build then fails with `invalid source release 25`.
# The script exports it for every `mvn` and `java` it runs.
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
export WORK REPO      # the `bash -c` helpers below build broken variants inside $WORK
OUT="$WORK/out.txt"
PORT="${PORT:-18425}"
SKIP_SLOW="${SKIP_SLOW:-0}"

PASS=0; FAIL=0; SKIP=0; FAILED_LABELS=()
RED=''; GRN=''; YLW=''; DIM=''; OFF=''
if [ -t 1 ]; then RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; DIM=$'\033[2m'; OFF=$'\033[0m'; fi

cleanup() {
  pkill -9 -f "$TAG" >/dev/null 2>&1
  rm -rf "$WORK"
  # never leave build output, heap dumps, databases, images or recordings behind
  for d in out o2 cout nd fake app plugins mods mods2 mods2-min modsonly modsd bad1 bad2 \
           plainout cp-out image2 imagex dist dmgout lib target data; do
    find "$REPO" -maxdepth 2 -type d -name "$d" -path '*/c2-*' -exec rm -rf {} + 2>/dev/null
  done
  find "$REPO" -maxdepth 2 -type d -name out -path '*/c2-*/*' -exec rm -rf {} + 2>/dev/null
  rm -rf "$REPO"/c2-unit20/sealed/out "$REPO"/c2-unit20/sealed/out2 2>/dev/null
  rm -f  "$REPO"/c2-*/*.class "$REPO"/c2-*/*/*.class 2>/dev/null
  rm -f  "$REPO"/c2-*/dump.hprof "$REPO"/c2-*/*.mv.db "$REPO"/c2-*/*.trace.db 2>/dev/null
  rm -f  "$REPO"/c2-*/*.jfr "$REPO"/c2-*/threads.json "$REPO"/c2-*/server.log "$REPO"/c2-*/cp.txt \
         "$REPO"/c2-*/mf.txt 2>/dev/null
  rm -rf "$REPO"/c2-unit25/tiffinbox-* "$REPO"/c2-unit26/tiffinbox-* "$REPO"/c2-unit26/menus 2>/dev/null
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
# the same question about any port: 0 = something is LISTENing on it
port_busy() { lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; }
wait_port_free() { local i; for i in $(seq 1 60); do port_busy "$1" || return 0; sleep 0.25; done; return 1; }
wait_port_up()   { local i; for i in $(seq 1 120); do port_busy "$1" && return 0; sleep 0.25; done; return 1; }

# jlink/jpackage need a JDK with a jmods/ directory. Homebrew's openjdk@25 prefix is a
# shim whose jmods live one level down, so find the real home or say why we skipped.
JMODS_HOME=""
if   [ -d "$JAVA_HOME/jmods" ]; then JMODS_HOME="$JAVA_HOME"
elif [ -d "$JAVA_HOME/libexec/openjdk.jdk/Contents/Home/jmods" ]; then
  JMODS_HOME="$JAVA_HOME/libexec/openjdk.jdk/Contents/Home"
fi
export JMODS_HOME    # unit 33 reaches for it from inside `bash -c` too

# Unit 42's code is the capstone, and unit 43 points every command at it, so both
# need the same jar. Build it at most once per run.
CAPJAR="$REPO/c2-capstone/target/c2-capstone-1.0.0.jar"
capstone_jar() {
  [ -f "$CAPJAR" ] && return 0
  command -v mvn >/dev/null 2>&1 || return 1
  ( cd "$REPO/c2-capstone" && mvn -B -q clean package ) >"$WORK/capbuild.log" 2>&1
  [ -f "$CAPJAR" ]
}

UNITS=("$@")
# A filter that matches nothing used to run zero checks and still print "all green."
# Reject anything this script cannot run, so a typo fails instead of faking a pass.
# (verify_course1.sh takes `unit09`; this script takes `09`.)
if [ ${#UNITS[@]} -ne 0 ]; then
  for u in "${UNITS[@]}"; do
    case "$u" in
      capstone|42) ;;   # unit 42 has no c2-unit42/ on purpose: its code IS c2-capstone
      [0-9][0-9]) [ -d "$REPO/c2-unit$u" ] || { echo "unknown unit: $u (no c2-unit$u/ in $REPO)" >&2; exit 2; } ;;
      *) echo "unknown unit: $u (use two digits, e.g. 09, or 'capstone')" >&2; exit 2 ;;
    esac
  done
fi

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

# ---------------------------------------------------------------- unit 19 ---
if unit 19 "Contracts: equals, hashCode and the key that vanished"; then
  expect_ok   "java EqualsOnly.java"   90 'HashSet of records size *: 1'  "$JAVA" EqualsOnly.java
  expect_ok   "java BrokenKey.java"    90 'containsKey\(ravi\): *false'   "$JAVA" BrokenKey.java
  expect_ok   "java TreeContract.java" 90 'TreeSet size: *1'              "$JAVA" TreeContract.java
  expect_fail "java SortContract.java" 90 'Comparison method violates its general contract' \
      "$JAVA" SortContract.java
  expect_ok   "java Hunt.java (measures TimSort MIN_MERGE)" 180 'first size that ever throws.*: 32' \
      "$JAVA" Hunt.java
  expect_ok   "java Guards.java"       90 'assertions enabled: *false'    "$JAVA" Guards.java
  expect_fail "java -ea Guards.java"   90 'AssertionError: menu slot out of range: 3' \
      "$JAVA" -ea Guards.java
  expect_fail "java Boxing.java (NPE on an unboxed null)" 90 \
      'NullPointerException: Cannot invoke "java.lang.Integer.intValue\(\)"' "$JAVA" Boxing.java
  expect_fail "java -XX:AutoBoxCacheMax=10000 Boxing.java (cache widened, still NPEs)" 90 \
      'c == d : true' "$JAVA" -XX:AutoBoxCacheMax=10000 Boxing.java
  expect_ok   "javac -Xlint:all -d out Boxing.java (silent)" 90 '' "$JAVAC" -Xlint:all -d out Boxing.java
fi

# ---------------------------------------------------------------- unit 20 ---
if unit 20 "Immutability and the defensive copy you forgot"; then
  expect_ok "java Leaky.java"      90 'safe, getter add: UnsupportedOperationException' "$JAVA" Leaky.java
  expect_ok "java CopyVsView.java" 90 'duplicate element: VEG'      "$JAVA" CopyVsView.java
  expect_ok "java ArrayRecord.java" 90 'SafeWeek after both *: \[2, 2, 2, 2, 2, 2, 2\]' "$JAVA" ArrayRecord.java
  expect_ok "java Deep.java"       90 'add -> UnsupportedOperationException' "$JAVA" Deep.java
  expect_ok "java Gap.java (the gap is 31^n, not a constant)" 90 '4 components : .*gap 923521' "$JAVA" Gap.java
  # compact and canonical constructors compile to the same bytecode
  expect_ok "javac -d cout Ctors.java && javap -c -p: compact == canonical bytecode" 120 '^0$' \
      bash -c '"$JAVA_HOME/bin/javac" -d cout Ctors.java >/dev/null 2>&1 &&
        "$JAVA_HOME/bin/javap" -c -p "cout/Ctors\$Compact.class"   | sed -n "/Compact(java.lang.String, int);/,/return/p"   | tail -n +2 > cout/a.txt &&
        "$JAVA_HOME/bin/javap" -c -p "cout/Ctors\$Canonical.class" | sed -n "/Canonical(java.lang.String, int);/,/return/p" | tail -n +2 > cout/b.txt &&
        diff cout/a.txt cout/b.txt >/dev/null; echo $?'
  rm -rf cout
  expect_fail "cd bad && javac -d . Bad.java (assign to a final field)" 90 \
      'cannot assign a value to final variable meals' bash -c 'cd bad && "$JAVA_HOME/bin/javac" -d . Bad.java'
  rm -f bad/*.class
  # the MatchException needs a real two-step compile: build v1, then swap in v2 without rebuilding the caller
  expect_ok "sealed step 1: javac v1 + app/Pricing, java -cp out Pricing" 120 'fee: *20' \
      bash -c 'cd sealed && rm -rf out out2 && mkdir -p out out2 &&
        "$JAVA_HOME/bin/javac" -implicit:none -d out v1/Meal.java v1/Veg.java v1/NonVeg.java &&
        "$JAVA_HOME/bin/javac" -implicit:none -cp out -d out app/Pricing.java &&
        "$JAVA_HOME/bin/java" -cp out Pricing'
  expect_fail "sealed step 2: rebuild only the library -> MatchException at run time" 120 \
      'java.lang.MatchException' \
      bash -c 'cd sealed && "$JAVA_HOME/bin/javac" -implicit:none -d out v2/Meal.java v2/Veg.java v2/NonVeg.java v2/Vegan.java &&
        "$JAVA_HOME/bin/java" -cp out Pricing'
  expect_ok "sealed: java -cp out Probe reads the MatchException (message null, 2 frames)" 120 'frames: *2' \
      bash -c 'cd sealed && "$JAVA_HOME/bin/javac" -implicit:none -cp out -d out app/Probe.java &&
        "$JAVA_HOME/bin/java" -cp out Probe'
  expect_fail "sealed step 3: recompile the caller -> switch does not cover all inputs" 120 \
      'does not cover all possible input values' \
      bash -c 'cd sealed && "$JAVA_HOME/bin/javac" -implicit:none -cp out -d out2 app/Pricing.java'
  rm -rf sealed/out sealed/out2
fi

# ---------------------------------------------------------------- unit 21 ---
if unit 21 "Money, overflow and the bill that was wrong"; then
  expect_fail "java Overflow.java (int paise overflows at hood 884)" 90 \
      'ArithmeticException: integer overflow' "$JAVA" Overflow.java
  expect_ok   "java Money.java"    90 'BigDecimal total = 3603.00' "$JAVA" Money.java
  expect_fail "java Rounding.java" 90 'Non-terminating decimal expansion' "$JAVA" Rounding.java
fi

# ---------------------------------------------------------------- unit 22 ---
if unit 22 "Strings under the hood: concat, interning, Unicode"; then
  expect_ok "javac -d . Concat.java && javap -c -p Concat.class (invokedynamic)" 120 \
      'makeConcatWithConstants' \
      bash -c '"$JAVA_HOME/bin/javac" -d . Concat.java && "$JAVA_HOME/bin/javap" -c -p Concat.class'
  expect_ok "javac -d . Loop.java && javap -c -p Loop.class (indy inside the loop)" 120 \
      'invokedynamic' \
      bash -c '"$JAVA_HOME/bin/javac" -d . Loop.java && "$JAVA_HOME/bin/javap" -c -p Loop.class'
  expect_ok "java --add-opens java.base/java.lang=ALL-UNNAMED Compact.java" 90 'coder=0 \(LATIN1\)' \
      "$JAVA" --add-opens java.base/java.lang=ALL-UNNAMED Compact.java
  expect_fail "java Compact.java (no --add-opens: the module wall)" 90 \
      'InaccessibleObjectException' "$JAVA" Compact.java
  expect_ok "java --add-opens … -XX:-CompactStrings Compact.java (bytes=8)" 90 'bytes=8' \
      "$JAVA" --add-opens java.base/java.lang=ALL-UNNAMED -XX:-CompactStrings Compact.java
  expect_ok "java -Xms1g -Xmx1g -XX:+UseSerialGC Heap.java (compact strings on)" 240 'used heap: *81 MB' \
      "$JAVA" -Xms1g -Xmx1g -XX:+UseSerialGC Heap.java
  expect_ok "java -Xms1g -Xmx1g -XX:+UseSerialGC -XX:-CompactStrings Heap.java" 240 'used heap: *112 MB' \
      "$JAVA" -Xms1g -Xmx1g -XX:+UseSerialGC -XX:-CompactStrings Heap.java
  expect_ok "java Intern.java"  90 'a == folded +\("Ra" \+ "vi"\) +: true' "$JAVA" Intern.java
  expect_ok "java Emoji.java"   90 'codePointCount\(0, length\(\)\) *: 1'   "$JAVA" Emoji.java
  expect_ok "java -Duser.language=en -Duser.country=US Locales.java" 90 '' \
      "$JAVA" -Duser.language=en -Duser.country=US Locales.java
  expect_ok "java -Duser.language=tr -Duser.country=TR Locales.java (the Turkish i)" 90 '' \
      "$JAVA" -Duser.language=tr -Duser.country=TR Locales.java
  expect_ok "java NumFmt.java (the verified negative: en-IN == en-US grouping)" 90 '2,148,120' "$JAVA" NumFmt.java
  expect_ok "java Timing.java (part C is the fixed part: 633x)" 240 'same string\? *: true' "$JAVA" Timing.java
  rm -f ./*.class
fi

# ---------------------------------------------------------------- unit 23 ---
if unit 23 "Collections beyond List and Map: Deque, PriorityQueue, EnumMap"; then
  expect_ok   "java Shapes.java (three different orders out of a PriorityQueue)" 90 \
      'EnumSet class *: java.util.RegularEnumSet' "$JAVA" Shapes.java
  expect_fail "java OrderRail.java (the loop everybody writes first)" 90 \
      'ConcurrentModificationException' "$JAVA" OrderRail.java
  expect_ok   "java CmeSilent.java (2nd-from-last removal throws nothing)" 90 \
      "'Sunil' was never visited *: true" "$JAVA" CmeSilent.java
  expect_ok   "java Sequenced.java" 90 'Arrays.mismatch' "$JAVA" Sequenced.java
  expect_ok   "java EnumHash.java (evidence only, never a slide)" 90 '' "$JAVA" EnumHash.java
  expect_ok   "javap java.util.Stack (extends Vector, synchronized pop)" 90 'extends java.util.Vector' \
      "$JAVAP" java.util.Stack
fi

# ---------------------------------------------------------------- unit 24 ---
if unit 24 "Class loading: how a .class becomes a Class"; then
  rm -rf out fake o2 app plugins nd
  expect_ok "javac -d out Kitchen.java Diner.java Menu.java Lazy.java Loaders.java Lookup.java" 120 '' \
      "$JAVAC" -d out Kitchen.java Diner.java Menu.java Lazy.java Loaders.java Lookup.java
  expect_ok "java -cp out Diner (before deleting Kitchen.class)" 90 '2. Meera served' "$JAVA" -cp out Diner
  rm -f out/Kitchen.class
  expect_fail "rm out/Kitchen.class && java -cp out Diner (loaded on first use, not at start)" 90 \
      'NoClassDefFoundError: Kitchen' "$JAVA" -cp out Diner
  expect_ok "java -cp out Loaders (app -> platform -> null)" 90 "Loaders' module *: null" "$JAVA" -cp out Loaders
  expect_fail "javac -d fake fakesrc/java/lang/String.java (refused without --patch-module)" 90 \
      'package exists in another module' "$JAVAC" -d fake fakesrc/java/lang/String.java
  expect_ok "javac --patch-module java.base=fakesrc -d fake fakesrc/…/String.java" 120 '' \
      "$JAVAC" --patch-module java.base=fakesrc -d fake fakesrc/java/lang/String.java
  # the security boundary: a fake java.lang.String on the class path changes nothing
  expect_ok "java -cp fake:out Loaders == java -cp out Loaders (the fake String is ignored)" 120 '^same$' \
      bash -c 'a=$("$JAVA_HOME/bin/java" -cp fake:out Loaders 2>&1 | md5); b=$("$JAVA_HOME/bin/java" -cp out Loaders 2>&1 | md5);
        [ "$a" = "$b" ] && echo same || { echo "differ: $a vs $b"; exit 1; }'
  expect_ok "java -cp out Lazy (Menu wakes at print 4, not print 2)" 90 '2. Menu.MAX_MEALS = 3' "$JAVA" -cp out Lazy
  expect_ok "javap -c -p out/Lazy.class (ldc constant-folded vs getstatic)" 90 'getstatic' "$JAVAP" -c -p out/Lazy.class
  expect_ok "java -Xlog:class+load=info:stdout:none -cp out Lazy" 120 'source: ' \
      "$JAVA" -Xlog:class+load=info:stdout:none -cp out Lazy
  expect_ok "javac -d out Lookup.java && java -cp out Lookup (checked, recoverable)" 120 \
      'the program carries on' \
      bash -c '"$JAVA_HOME/bin/javac" -d out Lookup.java && "$JAVA_HOME/bin/java" -cp out Lookup'
  expect_ok "javac -d o2 Config.java Boot.java && java -cp o2 Boot (EIIE then NoClassDefFoundError)" 120 \
      'attempt 2 -> java.lang.NoClassDefFoundError: Could not initialize class Config' \
      bash -c '"$JAVA_HOME/bin/javac" -d o2 Config.java Boot.java && "$JAVA_HOME/bin/java" -cp o2 Boot'
  expect_ok "java -Dtiffinbox.limit=3 -cp o2 Boot (the same class, initialised fine)" 90 'limit 3' \
      "$JAVA" -Dtiffinbox.limit=3 -cp o2 Boot
  expect_ok "javac -d app Special.java Plugins.java; javac -cp app -d plugins SeasonalMenu.java; java -cp app Plugins plugins" 180 \
      'same Class object *: false' \
      bash -c 'mkdir -p app plugins &&
        "$JAVA_HOME/bin/javac" -d app Special.java Plugins.java &&
        "$JAVA_HOME/bin/javac" -cp app -d plugins SeasonalMenu.java &&
        "$JAVA_HOME/bin/java" -cp app Plugins plugins'
  expect_fail "javac -d nd NoDelegate.java && java -cp nd NoDelegate (defineClass refuses java.*)" 120 \
      'SecurityException: Prohibited package name: java.lang' \
      bash -c '"$JAVA_HOME/bin/javac" -d nd NoDelegate.java && "$JAVA_HOME/bin/java" -cp nd NoDelegate'
  rm -rf out fake o2 app plugins nd
fi

# ---------------------------------------------------------------- unit 25 ---
if unit 25 "Byte and character streams: InputStream, Reader, buffers"; then
  expect_ok   "java Streams.java"  120 'month total: *24300' "$JAVA" Streams.java
  expect_ok   "java Serial.java (14 bytes as CSV vs 117 serialized)" 120 '117 bytes' "$JAVA" Serial.java
  expect_ok   "java Counted.java (106 write calls raw vs 1 buffered)" 120 '106' "$JAVA" Counted.java
  expect_ok   "java Silent.java (three failures that do not announce themselves)" 120 'suppressed\[0\]' "$JAVA" Silent.java
  expect_fail "java WrongCharset.java (leaves its temp dir behind on purpose)" 120 \
      'MalformedInputException: Input length = 1' "$JAVA" WrongCharset.java
  rm -rf tiffinbox-charset-*
  if [ "$SKIP_SLOW" = "1" ]; then skip "java FourWays.java" "SKIP_SLOW=1 — writes a 50 MB file, takes ~1 min"
  else expect_ok "java FourWays.java (~1 min on purpose: 52,428,800 bytes read four ways)" 300 \
      'checksum 3463577600' "$JAVA" FourWays.java; fi
  rm -rf tiffinbox-fourways-* ./*.class
fi

# ---------------------------------------------------------------- unit 26 ---
if unit 26 "NIO.2 deep-dive: walk, WatchService and channels"; then
  expect_ok   "java Walk.java (walk counts directories too: 8 entries, 67 bytes)" 120 \
      'cleaned up: *true' "$JAVA" Walk.java
  expect_ok   "java Watch.java (~5 s: macOS gets PollingWatchService)" 180 \
      'watcher closed, directory removed' "$JAVA" Watch.java
  expect_ok   "java Channels.java (pos/limit/cap across allocate -> read -> flip)" 120 \
      'mapped 31 bytes, first line: Ravi,2,120,VEG' "$JAVA" Channels.java
  expect_fail "java Missing.java (NoSuchFileException, relative to where you run it)" 120 \
      'NoSuchFileException: menus/week-9.csv' "$JAVA" Missing.java
  # the 50 MB four-way capture this unit shows lives in the streams unit's folder
  if [ -f "$REPO/c2-unit25/FourWays.java" ]; then
    ok "../c2-unit25/FourWays.java is where this unit's Slide 5 says it is"
  else
    bad "../c2-unit25/FourWays.java" "the file Slide 5 runs from here is missing"
  fi
  rm -rf tiffinbox-*  menus
fi

# ---------------------------------------------------------------- unit 27 ---
if unit 27 "Sockets: a TCP order line for TiffinBox"; then
  P27=8123
  if port_busy "$P27"; then
    bad "port $P27" "something is already listening on $P27 — this unit's demos all bind it"
  else
    expect_ok "java SocketFacts.java (ServerSocket is not a Socket; close() ends accept())" 120 \
        '' "$JAVA" SocketFacts.java
    wait_port_free "$P27" || bad "port $P27 after SocketFacts" "still in LISTEN"
    expect_ok "java BrokenPipe.java (setSoLinger -> RST -> Broken pipe)" 120 \
        'Broken pipe' "$JAVA" BrokenPipe.java
    wait_port_free "$P27" || bad "port $P27 after BrokenPipe" "still in LISTEN"
    # pane A: the server; pane B: the client. The client's CLOSE stops the server.
    "$JAVA" "-D$TAG=orderline" OrderLine.java >"$WORK/orderline.log" 2>&1 &
    OL=$!
    if wait_port_up "$P27"; then
      expect_ok "java OrderLine.java & then java OrderClient.java" 120 \
          'CLOSE +<- +BYE' "$JAVA" OrderClient.java
      for _ in $(seq 1 40); do kill -0 "$OL" 2>/dev/null || break; sleep 0.25; done
      grep -q '24300' "$WORK/orderline.log" && ok "OrderLine's own log books 24300 and exits by itself" \
        || bad "java OrderLine.java" "the server did not book 24300"
    else
      bad "java OrderLine.java &" "the server never came up on $P27"
    fi
    kill -9 "$OL" >/dev/null 2>&1; wait "$OL" 2>/dev/null
    wait_port_free "$P27" || bad "port $P27 after OrderLine/OrderClient" "still in LISTEN"
    # NoNewline needs a live OrderLine; it sends CLOSE at the end, so it is always last
    "$JAVA" "-D$TAG=orderline2" OrderLine.java >"$WORK/orderline2.log" 2>&1 &
    OL2=$!
    if wait_port_up "$P27"; then
      expect_ok "with an OrderLine up: java NoNewline.java (12 bytes, no \\n -> read timeout)" 120 \
          'SocketTimeoutException: Read timed out' "$JAVA" NoNewline.java
    else
      bad "java OrderLine.java & (for NoNewline)" "the server never came up on $P27"
    fi
    for _ in $(seq 1 40); do kill -0 "$OL2" 2>/dev/null || break; sleep 0.25; done
    kill -9 "$OL2" >/dev/null 2>&1; wait "$OL2" 2>/dev/null
    pkill -9 -f "$TAG=orderline" >/dev/null 2>&1
    if wait_port_free "$P27"; then ok "port $P27 free again, no order line left running"
    else bad "port $P27" "still in LISTEN after the socket demos"; fi
    # and with nothing listening at all
    expect_fail "java OrderDown.java (nothing listening: Connection refused)" 120 \
        'ConnectException: Connection refused' "$JAVA" OrderDown.java
  fi
fi

# ---------------------------------------------------------------- unit 28 ---
if unit 28 "HttpClient: calling APIs from Java"; then
  expect_fail "javac -d out NoImport.java (HttpClient is not in java.base)" 120 \
      'cannot find symbol' "$JAVAC" -d out NoImport.java
  P28=8234
  if port_busy "$P28"; then
    bad "port $P28" "something is already listening on $P28 — jwebserver needs it"
  elif [ ! -x "$JAVA_HOME/bin/jwebserver" ]; then
    skip "jwebserver -p $P28 -d www" "jwebserver is not in this JDK"
  else
    "$JAVA_HOME/bin/jwebserver" -p "$P28" -d "$PWD/www" >"$WORK/jweb.log" 2>&1 &
    JW=$!
    if wait_port_up "$P28"; then
      expect_ok "java ApiCall.java (200, HTTP_1_1, 307 bytes, then a 404 that does not throw)" 120 \
          'status: *200' "$JAVA" ApiCall.java
      expect_ok "java AsyncCalls.java (four sendAsync joined with allOf)" 120 \
          '24300' "$JAVA" AsyncCalls.java
    else
      cp "$WORK/jweb.log" "$OUT" 2>/dev/null
      bad "jwebserver -p $P28 -d www" "it never started listening"
    fi
    kill -9 "$JW" >/dev/null 2>&1; wait "$JW" 2>/dev/null
    if wait_port_free "$P28"; then ok "jwebserver killed by PID, port $P28 free"
    else bad "port $P28" "jwebserver is still listening"; fi
  fi
  # Timeout.java brings its own server up on 8456 and is expected to fail
  if port_busy 8456; then
    bad "port 8456" "something is already listening on 8456 — Timeout.java binds it"
  else
    expect_fail "java Timeout.java (500 ms request timeout against a server that sleeps)" 180 \
        'HttpTimeoutException' "$JAVA" Timeout.java
    wait_port_free 8456 || bad "port 8456" "still in LISTEN after Timeout.java"
  fi
  rm -rf out
fi

# ---------------------------------------------------------------- unit 29 ---
if unit 29 "JSON without Spring: Jackson via Maven"; then
  if ! command -v mvn >/dev/null 2>&1; then
    skip "mvn -q compile exec:java" "Maven is not installed"
  else
    expect_ok "mvn -q compile exec:java (write / pretty / read, month total 24300)" 600 \
        'month total: 24300' mvn -q -B compile exec:java
    expect_ok "mvn -q compile exec:java -Dexec.mainClass=com.tiffinbox.JsonOops" 600 \
        'lenient mapper: Ravi -> 7200' mvn -q -B compile exec:java -Dexec.mainClass=com.tiffinbox.JsonOops
    expect_ok "java hand-rolled/HandRolled.java (the hook: dies twice on field order)" 120 \
        'as the last unit sent it -> 7200' "$JAVA" hand-rolled/HandRolled.java
    expect_ok "mvn -q compile dependency:build-classpath -Dmdep.outputFile=cp.txt" 600 '' \
        mvn -q -B compile dependency:build-classpath -Dmdep.outputFile=cp.txt
    if [ -f cp.txt ]; then
      expect_ok "javac -Xlint:unchecked … Unchecked.java (warning on line 11)" 120 'unchecked conversion' \
          bash -c '"$JAVA_HOME/bin/javac" -Xlint:unchecked -cp "target/classes:$(cat cp.txt)" -d target/classes src/main/java/com/tiffinbox/Unchecked.java'
      expect_fail "java -cp … com.tiffinbox.Unchecked (List.class -> ClassCastException)" 120 \
          'ClassCastException' \
          bash -c '"$JAVA_HOME/bin/java" -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Unchecked'
      # breaks/ is outside src/main/java on purpose: a deliberately-broken file inside
      # the source root would fail `mvn compile` for the whole unit.
      expect_fail "cd breaks && javac … NoBraces.java (drop the braces: TypeReference is abstract)" 120 \
          'NoBraces.java:7: error: TypeReference is abstract; cannot be instantiated' \
          bash -c 'cd breaks && "$JAVA_HOME/bin/javac" -cp "../target/classes:$(cat ../cp.txt)" -d "$WORK/nobraces" NoBraces.java'
      expect_ok "javap -v -p target/classes/com/tiffinbox/Json\$1.class (the signature erasure keeps)" 120 \
          'Signature:' \
          bash -c '"$JAVA_HOME/bin/javap" -v -p "target/classes/com/tiffinbox/Json\$1.class" | grep Signature:'
    fi
    rm -f cp.txt
    rm -rf target
  fi
fi

# ---------------------------------------------------------------- unit 30 ---
if unit 30 "A tiny HTTP server: jdk.httpserver on virtual threads"; then
  P30=8345
  if port_busy "$P30"; then
    bad "port $P30" "something is already listening on $P30 — every demo in this unit binds it"
  else
    if ! command -v mvn >/dev/null 2>&1; then
      skip "mvn -q compile exec:java (TiffinServer)" "Maven is not installed"
    else
      expect_ok "mvn -q compile dependency:build-classpath -Dmdep.outputFile=cp.txt" 600 '' \
          mvn -q -B compile dependency:build-classpath -Dmdep.outputFile=cp.txt
      if [ -f cp.txt ]; then
        "$JAVA" "-D$TAG=tiffinserver" -cp "target/classes:$(cat cp.txt)" TiffinServer >"$WORK/ts.log" 2>&1 &
        TS=$!
        if wait_port_up "$P30"; then
          grep -q "8345" "$WORK/ts.log" && ok "TiffinBox answering HTTP on $P30" \
            || bad "TiffinServer start banner" "no 'answering HTTP on 8345' line"
          curl -s -m 5 "http://127.0.0.1:$P30/customers" >"$OUT" 2>&1
          grep -q '"veg"' "$OUT" && ok "GET /customers -> JSON with the \"veg\" key (@JsonProperty)" \
            || bad "GET /customers" "no JSON body with a veg key"
          curl -s -m 5 -i "http://127.0.0.1:$P30/customers/ravi" >"$OUT" 2>&1
          grep -qi 'content-length: 61' "$OUT" && ok "GET /customers/ravi -> Content-length: 61" \
            || bad "GET /customers/ravi" "expected Content-length: 61"
          curl -s -m 5 -i "http://127.0.0.1:$P30/customers/nobody" >"$OUT" 2>&1
          grep -q '404' "$OUT" && ok "GET /customers/nobody -> 404 with a JSON body" \
            || bad "GET /customers/nobody" "expected a 404"
          grep -q 'virtual=true' "$WORK/ts.log" && ok "every request ran on a virtual thread (virtual=true)" \
            || bad "TiffinServer request log" "no virtual=true line"
        else
          cp "$WORK/ts.log" "$OUT" 2>/dev/null
          bad "java -cp … TiffinServer" "the server never answered on $P30"
        fi
        kill -9 "$TS" >/dev/null 2>&1; wait "$TS" 2>/dev/null
        pkill -9 -f "$TAG=tiffinserver" >/dev/null 2>&1
        wait_port_free "$P30" || bad "port $P30 after TiffinServer" "still in LISTEN"
      fi
      rm -f cp.txt; rm -rf target
    fi
    expect_ok "java BindTwice.java (binds 8345 twice: the real BindException)" 120 \
        'BindException: Address already in use' "$JAVA" BindTwice.java
    wait_port_free "$P30" || bad "port $P30 after BindTwice" "still in LISTEN"
    expect_ok "java Shutdown.java (System.exit skips finally; the shutdown hook runs)" 120 \
        'hook: 8345 released' "$JAVA" Shutdown.java
    wait_port_free "$P30" || bad "port $P30 after Shutdown" "still in LISTEN"
    expect_ok "java OrderIds.java (new Random(42) twice -> the same id; SecureRandom does not)" 120 \
        'ORD-359D41BAF78A' "$JAVA" OrderIds.java
    # NoExecutor never exits on its own: start it, prove one thread serves everything, kill it
    "$JAVA" "-D$TAG=noexec" NoExecutor.java >"$WORK/noexec.log" 2>&1 &
    NE=$!
    if wait_port_up "$P30"; then
      curl -s -m 5 "http://127.0.0.1:$P30/plain" >"$OUT" 2>&1
      grep -q '"ok":true' "$OUT" && ok "java NoExecutor.java -> GET /plain answers" \
        || bad "GET /plain (NoExecutor)" 'expected {"ok":true}'
      curl -s -m 5 -i "http://127.0.0.1:$P30/zero" >"$OUT" 2>&1
      grep -qi 'transfer-encoding: chunked' "$OUT" \
        && ok "GET /zero -> sendResponseHeaders(200, 0) means chunked" \
        || bad "GET /zero" "expected Transfer-encoding: chunked"
      code=$(curl -s -o /dev/null -m 5 -w '%{http_code}' "http://127.0.0.1:$P30/none" 2>/dev/null)
      [ "$code" = "204" ] && ok "GET /none -> sendResponseHeaders(204, -1) means no body at all" \
        || bad "GET /none" "expected 204, got $code"
      # Two /slow at once. The server's own log is block-buffered into a file, so the
      # proof is taken from the client: both answers arrive, and the pair takes about
      # twice one handler's 1.2 s because request two never starts until one finishes.
      # wait on THESE two curls only — a bare `wait` would block on the NoExecutor
      # JVM, which by design never exits on its own.
      T0=$(date +%s)
      curl -s -m 15 "http://127.0.0.1:$P30/slow" >"$WORK/slow1" 2>&1 & C1=$!
      curl -s -m 15 "http://127.0.0.1:$P30/slow" >"$WORK/slow2" 2>&1 & C2=$!
      wait "$C1" "$C2" 2>/dev/null
      EL=$(( $(date +%s) - T0 ))
      BOTH="$(cat "$WORK/slow1" "$WORK/slow2" 2>/dev/null | tr -d '\n')"
      if [ "$EL" -ge 2 ] && printf '%s' "$BOTH" | grep -q '"handled":1' \
         && printf '%s' "$BOTH" | grep -q '"handled":2'; then
        ok "two /slow at once take ${EL}s for 2 x 1.2 s — no executor means one thread, queued"
      else
        printf '%s\n' "$BOTH" >"$OUT"
        bad "NoExecutor /slow" "expected handled:1 and handled:2 serialised (took ${EL}s)"
      fi
    else
      cp "$WORK/noexec.log" "$OUT" 2>/dev/null
      bad "java NoExecutor.java &" "it never came up on $P30"
    fi
    kill -9 "$NE" >/dev/null 2>&1; wait "$NE" 2>/dev/null
    pkill -9 -f "$TAG=noexec" >/dev/null 2>&1
    if wait_port_free "$P30"; then ok "port $P30 free again, no HTTP demo left running"
    else bad "port $P30" "still in LISTEN after the unit 30 demos"; fi
  fi
fi

# ---------------------------------------------------------------- unit 31 ---
if unit 31 "The module system: module-info.java explained"; then
  rm -rf mods plainout modsonly lib mf.txt bad1 bad2
  expect_ok "javac -d mods --module-source-path src \$(find src -name '*.java')" 180 '' \
      bash -c '"$JAVA_HOME/bin/javac" -d mods --module-source-path src $(find src -name "*.java")'
  expect_ok "java --module-path mods -m tiffinbox.app/com.tiffinbox.app.Main" 120 'Ravi -> 5400' \
      "$JAVA" --module-path mods -m tiffinbox.app/com.tiffinbox.app.Main
  expect_ok "javac -d plainout plain/Legacy.java && java -cp plainout … (module: null)" 120 \
      'this class module: null' \
      bash -c '"$JAVA_HOME/bin/javac" -d plainout plain/Legacy.java && "$JAVA_HOME/bin/java" -cp plainout com.tiffinbox.legacy.Legacy'
  expect_ok "jdeps --list-deps plainout" 120 'java.net.http' "$JAVA_HOME/bin/jdeps" --list-deps plainout
  expect_ok "jar --create … && java --module-path lib --describe-module legacy (automatic)" 180 'automatic' \
      bash -c 'mkdir -p lib && "$JAVA_HOME/bin/jar" --create --file lib/legacy.jar -C plainout . &&
        "$JAVA_HOME/bin/java" --module-path lib --describe-module legacy'
  expect_ok "Automatic-Module-Name in the manifest renames it to tiffinbox.legacy" 180 'tiffinbox.legacy' \
      bash -c 'printf "Automatic-Module-Name: tiffinbox.legacy\n" > mf.txt &&
        "$JAVA_HOME/bin/jar" --create --file lib/legacy.jar --manifest mf.txt -C plainout . &&
        "$JAVA_HOME/bin/java" --module-path lib --describe-module tiffinbox.legacy'
  expect_ok "java --module-path mods --describe-module tiffinbox.api" 120 'exports com.tiffinbox.api' \
      "$JAVA" --module-path mods --describe-module tiffinbox.api
  expect_fail "javac … --module-source-path src-nonexported (1 error: does not export it)" 180 \
      'does not export' \
      bash -c '"$JAVA_HOME/bin/javac" -d bad1 --module-source-path src-nonexported $(find src-nonexported -name "*.java")'
  expect_fail "javac … --module-source-path src-norequires (4 errors: does not read it)" 180 \
      'does not read' \
      bash -c '"$JAVA_HOME/bin/javac" -d bad2 --module-source-path src-norequires $(find src-norequires -name "*.java")'
  expect_fail "java --module-path modsonly -m tiffinbox.app/… (FindException)" 120 \
      'FindException: Module tiffinbox.api not found' \
      bash -c 'rm -rf modsonly && mkdir -p modsonly && cp -R mods/tiffinbox.app modsonly/ &&
        "$JAVA_HOME/bin/java" --module-path modsonly -m tiffinbox.app/com.tiffinbox.app.Main'
  rm -rf mods plainout modsonly lib mf.txt bad1 bad2
fi

# ---------------------------------------------------------------- unit 32 ---
if unit 32 "Modules in practice: exports, requires, ServiceLoader"; then
  rm -rf mods2 mods2-min cp-out
  expect_ok "javac -d mods2 --module-source-path s2 \$(find s2 -name '*.java')" 180 '' \
      bash -c '"$JAVA_HOME/bin/javac" -d mods2 --module-source-path s2 $(find s2 -name "*.java")'
  expect_ok "java --module-path mods2 -m tiffinbox.app/com.tiffinbox.app.Pay (ServiceLoader finds 2)" 120 \
      'gateways found: 2' "$JAVA" --module-path mods2 -m tiffinbox.app/com.tiffinbox.app.Pay
  expect_ok "copy only api+app into mods2-min -> gateways found: 0, no recompile, no crash" 120 \
      'gateways found: 0' \
      bash -c 'rm -rf mods2-min && mkdir -p mods2-min && cp -R mods2/tiffinbox.api mods2/tiffinbox.app mods2-min/ &&
        "$JAVA_HOME/bin/java" --module-path mods2-min -m tiffinbox.app/com.tiffinbox.app.Pay'
  expect_fail "java --module-path mods2 -m …/Reflect (InaccessibleObjectException)" 120 \
      'InaccessibleObjectException' "$JAVA" --module-path mods2 -m tiffinbox.app/com.tiffinbox.app.Reflect
  expect_ok "… --add-opens tiffinbox.api/com.tiffinbox.api=tiffinbox.app (fix 1 of 3)" 120 \
      'field value: *NON_VEG' \
      "$JAVA" --add-opens tiffinbox.api/com.tiffinbox.api=tiffinbox.app --module-path mods2 -m tiffinbox.app/com.tiffinbox.app.Reflect
  expect_ok "no module system at all: javac -d cp-out … && java -cp cp-out … (fix 3 of 3)" 180 \
      'field value: *NON_VEG' \
      bash -c '"$JAVA_HOME/bin/javac" -d cp-out $(find s2/tiffinbox.api/com -name "*.java") s2/tiffinbox.app/com/tiffinbox/app/Reflect.java &&
        "$JAVA_HOME/bin/java" -cp cp-out com.tiffinbox.app.Reflect'
  # the breaks/ variants are swapped in on a COPY, so the shipped tree is never edited
  expect_ok "breaks/opens-fix/module-info.java recompiled -> field value: NON_VEG (fix 2 of 3)" 240 \
      'field value: *NON_VEG' \
      bash -c 'W="$WORK/u32-opens"; rm -rf "$W"; mkdir -p "$W"; cp -R s2 "$W/s2";
        cp breaks/opens-fix/module-info.java "$W/s2/tiffinbox.api/module-info.java";
        "$JAVA_HOME/bin/javac" -d "$W/mods" --module-source-path "$W/s2" $(cd "$W" && find s2 -name "*.java" | sed "s|^|$W/|") &&
        "$JAVA_HOME/bin/java" --module-path "$W/mods" -m tiffinbox.app/com.tiffinbox.app.Reflect'
  expect_fail "breaks/requires-not-transitive/module-info.java -> the two Pay.java errors" 240 \
      'module tiffinbox.app does not read it' \
      bash -c 'W="$WORK/u32-nt"; rm -rf "$W"; mkdir -p "$W"; cp -R s2 "$W/s2";
        cp breaks/requires-not-transitive/module-info.java "$W/s2/tiffinbox.api/module-info.java";
        "$JAVA_HOME/bin/javac" -d "$W/mods" --module-source-path "$W/s2" $(cd "$W" && find s2 -name "*.java" | sed "s|^|$W/|")'
  expect_fail "breaks/private-constructor/CardGateway.java -> provider ctor is not public" 240 \
      'the no arguments constructor of the service implementation is not public' \
      bash -c 'W="$WORK/u32-pc"; rm -rf "$W"; mkdir -p "$W"; cp -R s2 "$W/s2";
        cp breaks/private-constructor/CardGateway.java "$W/s2/tiffinbox.card/com/tiffinbox/card/CardGateway.java";
        "$JAVA_HOME/bin/javac" -d "$W/mods" --module-source-path "$W/s2" $(cd "$W" && find s2 -name "*.java" | sed "s|^|$W/|")'
  expect_ok "breaks/provider-factory/CardGateway.java -> a public static provider() is the 2nd form" 240 \
      'gateways found: 2' \
      bash -c 'W="$WORK/u32-pf"; rm -rf "$W"; mkdir -p "$W"; cp -R s2 "$W/s2";
        cp breaks/provider-factory/CardGateway.java "$W/s2/tiffinbox.card/com/tiffinbox/card/CardGateway.java";
        "$JAVA_HOME/bin/javac" -d "$W/mods" --module-source-path "$W/s2" $(cd "$W" && find s2 -name "*.java" | sed "s|^|$W/|") &&
        "$JAVA_HOME/bin/java" --module-path "$W/mods" -m tiffinbox.app/com.tiffinbox.app.Pay'
  rm -rf mods2 mods2-min cp-out
fi

# ---------------------------------------------------------------- unit 33 ---
if unit 33 "jlink and jpackage: ship TiffinBox as a runtime image"; then
  rm -rf mods2 image2 imagex dist dmgout plainout lib modsd
  # s2/ must be a byte-for-byte copy of unit 32's, or the md5 identity claim is empty
  if [ -d "$REPO/c2-unit32/s2" ]; then
    if diff -r "$REPO/c2-unit32/s2" s2 >/dev/null 2>&1; then
      ok "c2-unit33/s2 is byte-for-byte c2-unit32/s2 (diff -r empty)"
    else bad "c2-unit33/s2 vs c2-unit32/s2" "diff -r is not empty — the md5 identity claim breaks"; fi
  fi
  expect_ok "javac -d mods2 --module-source-path s2 \$(find s2 -name '*.java')" 180 '' \
      bash -c '"$JAVA_HOME/bin/javac" -d mods2 --module-source-path s2 $(find s2 -name "*.java")'
  expect_ok "java --module-path mods2 -m tiffinbox.app/com.tiffinbox.app.Pay" 120 'gateways found: 2' \
      "$JAVA" --module-path mods2 -m tiffinbox.app/com.tiffinbox.app.Pay
  if [ -z "$JMODS_HOME" ]; then
    skip "jlink --module-path \"\$JAVA_HOME/jmods:mods2\" …" "this JDK ships no jmods/ (a JRE, or a Homebrew shim)"
    skip "./image2/bin/tiffinbox" "no jmods, so there is no image to run"
  else
    expect_ok "jlink --add-modules … --launcher tiffinbox=… --output image2" 300 '' \
        "$JAVA_HOME/bin/jlink" --module-path "$JMODS_HOME/jmods:mods2" \
          --add-modules tiffinbox.app,tiffinbox.card,tiffinbox.wallet \
          --launcher tiffinbox=tiffinbox.app/com.tiffinbox.app.Pay \
          --output image2 --strip-debug --no-header-files --no-man-pages
    expect_ok "./image2/bin/tiffinbox (same output as the module-path run)" 120 'gateways found: 2' \
        ./image2/bin/tiffinbox
    expect_ok "jlink --add-modules tiffinbox.app alone -> gateways found: 0" 300 'gateways found: 0' \
        bash -c 'rm -rf imagex && "$JAVA_HOME/bin/jlink" --module-path "$JMODS_HOME/jmods:mods2" \
            --add-modules tiffinbox.app --launcher t=tiffinbox.app/com.tiffinbox.app.Pay \
            --output imagex --strip-debug --no-header-files --no-man-pages >/dev/null 2>&1 && ./imagex/bin/t'
    expect_fail "jlink --add-modules Legacy over a plain class dir -> FindException" 300 \
        'Module Legacy not found' \
        bash -c 'rm -rf imagex plainout && "$JAVA_HOME/bin/javac" -d plainout plain/Legacy.java &&
          "$JAVA_HOME/bin/jlink" --module-path "$JMODS_HOME/jmods:plainout" --add-modules Legacy --output imagex'
    expect_fail "jlink over an automatic module -> automatic module cannot be used with jlink" 300 \
        'automatic module cannot be used with jlink' \
        bash -c 'rm -rf imagex lib && mkdir -p lib && "$JAVA_HOME/bin/jar" --create --file lib/legacy.jar -C plainout . &&
          "$JAVA_HOME/bin/jlink" --module-path "$JMODS_HOME/jmods:lib" --add-modules legacy --output imagex'
    if [ "$SKIP_SLOW" = "1" ]; then
      skip "jpackage --type app-image --name TiffinBox --dest dist" "SKIP_SLOW=1 — jpackage takes ~30 s"
    else
      expect_ok "jpackage --type app-image --name TiffinBox --dest dist (~30 s)" 420 '' \
          "$JAVA_HOME/bin/jpackage" --type app-image --name TiffinBox \
            --module-path "$JMODS_HOME/jmods:mods2" --module tiffinbox.app/com.tiffinbox.app.Pay \
            --add-modules tiffinbox.app,tiffinbox.card,tiffinbox.wallet --dest dist
      [ -d dist/TiffinBox.app ] && ok "dist/TiffinBox.app exists (codesign reports adhoc — not distributable)" \
        || bad "jpackage app-image" "dist/TiffinBox.app was not produced"
    fi
    skip "jpackage --type dmg --dest dmgout" "always skipped — a dmg build takes minutes and ships nothing new"
  fi
  # the split package: overlay breaks/split-package/ onto a copy of s2/
  expect_fail "breaks/split-package/ -> a package cannot live in two modules" 240 \
      'reads package com.tiffinbox.api from both tiffinbox.api and tiffinbox.extra' \
      bash -c 'W="$WORK/u33-split"; rm -rf "$W"; mkdir -p "$W"; cp -R s2 "$W/s2";
        cp -R breaks/split-package/tiffinbox.extra "$W/s2/tiffinbox.extra";
        cp breaks/split-package/tiffinbox.app/module-info.java "$W/s2/tiffinbox.app/module-info.java";
        "$JAVA_HOME/bin/javac" -d "$W/mods" --module-source-path "$W/s2" $(cd "$W" && find s2 -name "*.java" | sed "s|^|$W/|")'
  rm -rf mods2 image2 imagex dist dmgout plainout lib modsd
fi

# ---------------------------------------------------------------- unit 34 ---
if unit 34 "SQL in 15 minutes: TiffinBox tables in H2"; then
  if ! command -v mvn >/dev/null 2>&1; then skip "mvn -q compile exec:java -Dexec.mainClass=Sql101" "Maven is not installed"
  else
    expect_ok "mvn -q compile exec:java -Dexec.mainClass=Sql101" 600 'new order id: 7' \
        mvn -q -B compile exec:java -Dexec.mainClass=Sql101
    grep -q '23505' "$OUT" && ok "the duplicate email really raises SQLState 23505 (UQ_CUSTOMER_EMAIL)" \
      || bad "Sql101 duplicate-email demo" "no 23505 in the output"
    rm -rf data target
  fi
fi

# ---------------------------------------------------------------- unit 35 ---
if unit 35 "JDBC: connect, query, map rows to records"; then
  if ! command -v mvn >/dev/null 2>&1; then skip "mvn -q compile exec:java -Dexec.mainClass=Connect" "Maven is not installed"
  else
    expect_ok "mvn -q compile exec:java -Dexec.mainClass=Connect" 600 '' \
        mvn -q -B compile exec:java -Dexec.mainClass=Connect
    expect_ok "… -Duser.timezone=America/New_York (the timestamp beat is zone-independent)" 600 '' \
        mvn -q -B compile exec:java -Dexec.mainClass=Connect -Dexec.args= -Duser.timezone=America/New_York
    rm -rf data target
  fi
fi

# ---------------------------------------------------------------- unit 36 ---
if unit 36 "Transactions, savepoints and batches"; then
  if ! command -v mvn >/dev/null 2>&1; then skip "mvn -q compile exec:java -Dexec.mainClass=Tx" "Maven is not installed"
  else
    expect_ok "mvn -q compile exec:java -Dexec.mainClass=Tx" 600 '' \
        mvn -q -B compile exec:java -Dexec.mainClass=Tx
    grep -q '23506' "$OUT" && ok "the rollback is proved by a real foreign-key failure (SQLState 23506)" \
      || bad "Tx rollback demo" "no 23506 in the output"
    rm -rf data target
  fi
fi

# ---------------------------------------------------------------- unit 37 ---
if unit 37 "Connection pools: close() that gives it back"; then
  if ! command -v mvn >/dev/null 2>&1; then skip "mvn -q compile exec:java -Dexec.mainClass=Pool" "Maven is not installed"
  else
    expect_ok "mvn -q compile exec:java -Dexec.mainClass=Pool" 600 '' \
        mvn -q -B compile exec:java -Dexec.mainClass=Pool
    expect_ok "mvn -q dependency:build-classpath -Dmdep.outputFile=cp.txt" 600 '' \
        mvn -q -B compile dependency:build-classpath -Dmdep.outputFile=cp.txt
    if [ -f cp.txt ]; then
      expect_ok "java -cp \"target/classes:\$(cat cp.txt)\" Pool (with Hikari's own banner)" 180 '' \
          bash -c '"$JAVA_HOME/bin/java" -cp "target/classes:$(cat cp.txt)" Pool'
      # a pool of one, borrowed and never returned: the timeout figure moves every run
      expect_any "java -cp … PoolOops (a pool of one, never returned: ~2000 ms timeout)" 180 \
          'onnection is not available|SQLTransientConnectionException' \
          bash -c '"$JAVA_HOME/bin/java" -cp "target/classes:$(cat cp.txt)" PoolOops'
    fi
    rm -f cp.txt; rm -rf data target
  fi
fi

# ---------------------------------------------------------------- unit 38 ---
if unit 38 "TiffinBox on a real database: the JDBC repository"; then
  if ! command -v mvn >/dev/null 2>&1; then skip "mvn -q compile exec:java -Dexec.mainClass=RepoDemo" "Maven is not installed"
  else
    expect_ok "mvn -q compile exec:java -Dexec.mainClass=RepoDemo" 600 'count now: *4' \
        mvn -q -B compile exec:java -Dexec.mainClass=RepoDemo
    grep -q 'rs.wasNull() = true' "$OUT" && ok "revenueWithoutCoalesce: getLong returns 0 with wasNull() true" \
      || bad "RepoDemo wasNull beat" "expected 'rs.wasNull() = true'"
    grep -q 'SQLState 42S22' "$OUT" && ok "the renamed column is translated, cause kept (SQLState 42S22)" \
      || bad "RepoDemo exception translation" "expected SQLState 42S22"
    rm -rf data target
  fi
fi

# ---------------------------------------------------------------- unit 39 ---
if unit 39 "Reflection: inspecting classes at run time"; then
  rm -rf out
  expect_ok "javac -d out Customer.java Reflect.java Oops.java" 120 '' \
      "$JAVAC" -d out Customer.java Reflect.java Oops.java
  expect_ok "java -cp out Reflect" 120 '' "$JAVA" -cp out Reflect
  expect_ok "java --add-opens java.base/java.lang=ALL-UNNAMED -cp out Reflect (the module-wall fix)" 120 '' \
      "$JAVA" --add-opens java.base/java.lang=ALL-UNNAMED -cp out Reflect
  expect_any "java -cp out Oops (the failures)" 120 '' "$JAVA" -cp out Oops
  expect_fail "cd compact && java Compact.java (a record in a compact file is Compact\$Customer)" 120 \
      'ClassNotFoundException: Customer' bash -c 'cd compact && "$JAVA_HOME/bin/java" Compact.java'
  rm -rf out
fi

# ---------------------------------------------------------------- unit 40 ---
if unit 40 "Annotations: define, read and process them"; then
  rm -rf out
  expect_ok "javac -d out *.java && java -cp out MiniFramework" 180 'routes: 3 of 4 methods' \
      bash -c '"$JAVA_HOME/bin/javac" -d out *.java && "$JAVA_HOME/bin/java" -cp out MiniFramework'
  grep -q '24300' "$OUT" && ok "GET /revenue -> 24300 through the reflective dispatcher" \
    || bad "MiniFramework dispatch" "no 24300 in the output"
  # each break/ folder replaces one top-level file; build the mix in the scratch dir
  expect_ok "break1/Route.java (@Retention(CLASS)) -> routes: 0 of 4 methods" 180 'routes: 0 of 4 methods' \
      bash -c 'W="$WORK/u40-b1"; rm -rf "$W"; mkdir -p "$W"; cp *.java "$W"/; cp break1/Route.java "$W"/Route.java;
        "$JAVA_HOME/bin/javac" -d "$W/out" "$W"/*.java && "$JAVA_HOME/bin/java" -cp "$W/out" MiniFramework'
  expect_fail "break1-naive/ (the same change, without the null check) -> NullPointerException" 180 \
      'NullPointerException' \
      bash -c 'W="$WORK/u40-b1n"; rm -rf "$W"; mkdir -p "$W"; cp *.java "$W"/;
        cp break1-naive/Route.java break1-naive/MiniFramework.java "$W"/;
        "$JAVA_HOME/bin/javac" -d "$W/out" "$W"/*.java && "$JAVA_HOME/bin/java" -cp "$W/out" MiniFramework'
  expect_fail "break2/Handlers.java (@Route on a field) -> @Target does its job at compile time" 180 \
      'annotation interface not applicable to this kind of declaration' \
      bash -c 'W="$WORK/u40-b2"; rm -rf "$W"; mkdir -p "$W"; cp *.java "$W"/; cp break2/Handlers.java "$W"/Handlers.java;
        "$JAVA_HOME/bin/javac" -d "$W/out" "$W"/*.java'
  rm -rf out
fi

# ---------------------------------------------------------------- unit 41 ---
if unit 41 "Stream gatherers: custom pipeline steps"; then
  expect_ok "java Gather.java (windowFixed / windowSliding / scan / fold -> 24300)" 120 '24300' \
      "$JAVA" Gather.java
  expect_ok "java Custom.java (an integrator returning false short-circuits)" 120 '' "$JAVA" Custom.java
  expect_ok "java ParProbe.java (ofSequential really refuses to parallelise)" 180 '' "$JAVA" ParProbe.java
  expect_ok "javap java.util.stream.Gatherers (five factories, no preview marker)" 120 'windowFixed' \
      "$JAVAP" java.util.stream.Gatherers
  expect_ok "java --enable-preview Gather.java (the flag is ignored: gatherers went final in 24)" 120 '24300' \
      "$JAVA" --enable-preview Gather.java
fi

# ------------------------------------------------------ unit 42 · capstone ---
# Unit 42 has no c2-unit42/ folder on purpose: its code IS the capstone, and both
# the script and the deck say so ("Code for this unit: tiffinbox-java/c2-capstone").
if { want capstone || want 42; } && [ -d "$REPO/c2-capstone" ]; then
  printf '\n%sc2-capstone%s  unit 42 — TiffinBox server (Maven, H2, Jackson, virtual threads)\n' "$DIM" "$OFF"
  cd "$REPO/c2-capstone" || exit 1
  if ! command -v mvn >/dev/null 2>&1; then
    skip "mvn -B clean package" "Maven is not installed"
  else
    if ! port_free; then
      bad "port $PORT" "something is already listening on $PORT — set PORT=<free port>"
    else
      expect_ok "mvn -B clean package (first run downloads H2 + Jackson)" 900 'BUILD SUCCESS' \
          mvn -B clean package
      if [ -f "$CAPJAR" ]; then
        expect_ok "unzip -p target/c2-capstone-1.0.0.jar META-INF/MANIFEST.MF" 60 \
            'Main-Class: com.tiffinbox.TiffinBoxServer' \
            bash -c 'unzip -p target/c2-capstone-1.0.0.jar META-INF/MANIFEST.MF'
        grep -q 'Class-Path: lib/' "$OUT" && ok "the manifest's Class-Path points at lib/ (the jar is runnable)" \
          || bad "MANIFEST.MF Class-Path" "no 'Class-Path: lib/' line"
        expect_fail "java -jar … without --enable-preview (Dashboard is a preview class)" 120 \
            'Preview features are not enabled' \
            "$JAVA" -jar "$CAPJAR"
      fi
      # start it exactly the way the README does: from the jar, with the logging config
      "$JAVA" "-D$TAG=server" --enable-preview -Djava.util.logging.config.file=logging.properties \
          -jar "$CAPJAR" "$PORT" >"$WORK/server.log" 2>&1 &
      SV=$!
      up=0
      for _ in $(seq 1 200); do
        if curl -s -m 2 "http://127.0.0.1:$PORT/customers" >"$OUT" 2>&1; then up=1; break; fi
        kill -0 "$SV" 2>/dev/null || break
        sleep 0.3
      done
      if [ "$up" -ne 1 ]; then
        cp "$WORK/server.log" "$OUT" 2>/dev/null
        bad "java --enable-preview -jar target/c2-capstone-1.0.0.jar $PORT" \
            "the server never answered on 127.0.0.1:$PORT"
      else
        grep -q 'TiffinBox listening' "$WORK/server.log" \
          && ok "server start banner (orders cooked / kitchen value / routes mapped / listening)" \
          || bad "server start banner" "no 'TiffinBox listening' line"
        grep -q 'orders cooked: *120' "$WORK/server.log" \
          && ok "orders cooked: 120 — the rail is drained before the port opens" \
          || bad "orders cooked" "expected 120 slips cooked at start-up"
        grep -q 'kitchen value: *24300' "$WORK/server.log" \
          && ok "kitchen value: 24300 (no MessageFormat grouping separator)" \
          || bad "kitchen value" "expected 24300, unseparated"
        for route in /customers /dashboard /kitchen /revenue; do
          curl -s -m 5 "http://127.0.0.1:$PORT$route" >"$OUT" 2>&1
          if [ -s "$OUT" ] && ! grep -q '"error"' "$OUT"; then ok "GET $route -> JSON"
          else bad "GET $route" "empty body or an error object"; fi
        done
        curl -s -m 5 "http://127.0.0.1:$PORT/dashboard" >"$OUT" 2>&1
        grep -q '"monthRevenue":24300' "$OUT" && ok "GET /dashboard -> monthRevenue 24300 (StructuredTaskScope)" \
          || bad "GET /dashboard" "expected monthRevenue 24300"
        code=$(curl -s -o /dev/null -m 5 -w '%{http_code}' "http://127.0.0.1:$PORT/pauses" 2>/dev/null)
        [ "$code" = "404" ] && ok "GET /pauses -> 404 (no such route)" || bad "GET /pauses" "expected 404, got $code"
        # the verb is part of the route key: GET /shutdown is a 405, POST /shutdown stops it
        curl -s -m 5 "http://127.0.0.1:$PORT/shutdown" >"$OUT" 2>&1
        grep -q 'method not allowed' "$OUT" \
          && ok "GET /shutdown -> 405 (wrong verb, @Route method() is load-bearing)" \
          || bad "GET /shutdown" "expected {\"error\":\"method not allowed\"}"
        expect_ok "for i in 1..6: java -cp 'target/lib/*' breaks/MapOrder.java (Map.of order flips)" 240 \
            'ordersCooked' \
            bash -c 'for i in 1 2 3 4 5 6; do "$JAVA_HOME/bin/java" -cp "target/lib/*" breaks/MapOrder.java || exit 1; done'
        curl -s -m 5 -X POST "http://127.0.0.1:$PORT/shutdown" >"$OUT" 2>&1
        grep -q 'stopping' "$OUT" && ok "POST /shutdown -> {\"stopping\":true}" || bad "POST /shutdown" "no stopping response"
      fi
      # the server must be gone and the port free no matter what happened above
      for _ in $(seq 1 40); do kill -0 "$SV" 2>/dev/null || break; sleep 0.25; done
      kill -9 "$SV" >/dev/null 2>&1; wait "$SV" 2>/dev/null
      pkill -9 -f "$TAG=server" >/dev/null 2>&1
      if port_free; then ok "port $PORT free again, no server process left"
      else bad "port $PORT" "still in LISTEN after shutdown"; fi
      expect_fail "mvn -B -f breaks/pom-broken.xml clean package (two dashes in an XML comment)" 300 \
          'Non-parseable POM' mvn -B -f breaks/pom-broken.xml clean package
    fi
  fi
fi

# ---------------------------------------------------------------- unit 43 ---
if unit 43 "Watching it run: JFR, jcmd and jshell"; then
  P43=18543
  [ -x watch.sh ] && ok "watch.sh is executable" || bad "watch.sh" "not executable (chmod +x watch.sh)"
  expect_ok "bash -n watch.sh (the script parses)" 60 '' bash -n watch.sh
  if ! command -v mvn >/dev/null 2>&1; then
    skip "the whole unit" "Maven is not installed and everything here points at ../c2-capstone"
  elif ! capstone_jar; then
    bad "../c2-capstone build" "could not produce $CAPJAR, which every command in this unit needs"
  elif port_busy "$P43"; then
    bad "port $P43" "something is already listening on $P43 — this unit's server binds it"
  else
    rm -f tiffinbox.jfr threads.json server.log v.jfr p.jfr
    # 1 — record from the first instruction
    ( cd "$REPO/c2-capstone" && "$JAVA" "-D$TAG=obs" --enable-preview \
        "-XX:StartFlightRecording=name=tiffinbox,filename=$PWD/../c2-unit43/tiffinbox.jfr,settings=profile,+jdk.VirtualThreadStart#enabled=true" \
        -Djava.util.logging.config.file=logging.properties \
        -jar target/c2-capstone-1.0.0.jar "$P43" ) >"$WORK/obs.log" 2>&1 &
    OB=$!
    if wait_port_up "$P43"; then
      OBPID="$(pgrep -f "$TAG=obs" | head -1)"
      grep -q 'Started recording' "$WORK/obs.log" && ok "-XX:StartFlightRecording started a recording at JVM start" \
        || bad "StartFlightRecording" "no 'Started recording' line"
      # 2 — real load, in the BACKGROUND. The three questions below are only
      # interesting while the server is busy: an idle server has no virtual
      # threads to find. (The unit uses 20,000; 4,000 fills a recording faster.)
      ( "$JAVA" "-D$TAG=load" Load.java "$P43" 4000 200 ) >"$WORK/load.log" 2>&1 &
      LD=$!
      if [ -n "$OBPID" ]; then
        # wait until the scheduler has actually stolen some work, like watch.sh does
        for _ in $(seq 1 160); do
          ST=$("$JCMD" "$OBPID" Thread.vthread_scheduler 2>/dev/null | grep -o 'steals = [0-9]*' | grep -o '[0-9]*')
          [ -n "${ST:-}" ] && [ "$ST" -gt 500 ] && break
          kill -0 "$LD" 2>/dev/null || break
          sleep 0.25
        done
        # 3 — ask the live process three questions
        "$JCMD" "$OBPID" Thread.print >"$OUT" 2>&1
        grep -q '"ForkJoinPool-1-worker' "$OUT" \
          && ok "jcmd <pid> Thread.print -> the carriers (and no virtual threads)" \
          || bad "jcmd Thread.print" "no ForkJoinPool-1-worker line"
        # a dump is an instant and a request here is well under a millisecond, so
        # take a few and keep the one that caught virtual threads mounted
        VT=0
        for _ in 1 2 3 4 5 6; do
          "$JCMD" "$OBPID" Thread.dump_to_file -overwrite -format=json "$WORK/threads.json" >"$OUT" 2>&1
          n=$(grep -c '"virtual": true' "$WORK/threads.json" 2>/dev/null || echo 0)
          if [ "${n:-0}" -gt "$VT" ]; then VT=$n; cp "$WORK/threads.json" threads.json 2>/dev/null; fi
          [ "$VT" -gt 0 ] && break
          kill -0 "$LD" 2>/dev/null || break
        done
        [ "$VT" -gt 0 ] \
          && ok "jcmd <pid> Thread.dump_to_file -format=json -> $VT virtual threads (Thread.print has none)" \
          || bad "jcmd Thread.dump_to_file" "no virtual threads in any of the JSON dumps"
        "$JCMD" "$OBPID" Thread.vthread_scheduler >"$OUT" 2>&1
        grep -q 'parallelism' "$OUT" && ok "jcmd <pid> Thread.vthread_scheduler -> the ForkJoinPool behind them" \
          || bad "jcmd Thread.vthread_scheduler" "no parallelism line"
      else bad "pgrep the server" "could not find the recording JVM's pid"; fi
      # the load must finish before the recording is stopped
      wait "$LD" 2>/dev/null
      grep -q 'distinct bodies: 1' "$WORK/load.log" \
        && ok "java Load.java $P43 4000 200 -> every response byte-identical (distinct bodies: 1)" \
        || { cp "$WORK/load.log" "$OUT" 2>/dev/null; bad "java Load.java" "expected 'distinct bodies: 1'"; }
      if [ -n "$OBPID" ]; then
        "$JCMD" "$OBPID" JFR.stop name=tiffinbox >"$OUT" 2>&1
        grep -qi 'stopped\|written' "$OUT" && ok "jcmd <pid> JFR.stop name=tiffinbox" \
          || bad "jcmd JFR.stop" "the recording was not stopped"
      fi
      curl -s -m 10 -X POST "http://127.0.0.1:$P43/shutdown" >/dev/null 2>&1
    else
      cp "$WORK/obs.log" "$OUT" 2>/dev/null
      bad "java -XX:StartFlightRecording … -jar … $P43" "the server never came up"
    fi
    for _ in $(seq 1 60); do kill -0 "$OB" 2>/dev/null || break; sleep 0.25; done
    kill -9 "$OB" >/dev/null 2>&1; wait "$OB" 2>/dev/null
    pkill -9 -f "$TAG=obs" >/dev/null 2>&1
    if wait_port_free "$P43"; then ok "port $P43 free again, the recording JVM is gone"
    else bad "port $P43" "still in LISTEN after POST /shutdown"; fi
    # 4 — read the recording back
    if [ -s tiffinbox.jfr ]; then
      expect_ok "jfr summary tiffinbox.jfr | grep ThreadStart" 180 'jdk.VirtualThreadStart' \
          bash -c '"$JAVA_HOME/bin/jfr" summary tiffinbox.jfr | grep ThreadStart'
      expect_ok "jfr view allocation-by-class tiffinbox.jfr" 180 'Allocation Pressure|byte\[\]' \
          bash -c '"$JAVA_HOME/bin/jfr" view --width 62 allocation-by-class tiffinbox.jfr'
    else bad "tiffinbox.jfr" "the recording file is empty or missing"; fi
    # 5 — jshell on the compiled classes, no main and no server
    expect_ok "jshell -q --class-path 'target/classes:target/lib/*' ../c2-unit43/probe.jsh" 300 \
        'uses preview features of Java SE 25' \
        bash -c 'cd "$REPO/c2-capstone" && "$JAVA_HOME/bin/jshell" -q --class-path "target/classes:target/lib/*" ../c2-unit43/probe.jsh'
    if [ "$SKIP_SLOW" = "1" ]; then
      skip "java -XX:StartFlightRecording … StackChunks.java virtual|platform" "SKIP_SLOW=1 — two 40,000-task runs"
      skip "./watch.sh $P43" "SKIP_SLOW=1 — the full 20,000-request cycle takes ~1 min"
    else
      expect_ok "java -XX:StartFlightRecording=filename=v.jfr … StackChunks.java virtual" 300 '' \
          "$JAVA" "-XX:StartFlightRecording=filename=v.jfr,settings=profile" StackChunks.java virtual
      expect_ok "java -XX:StartFlightRecording=filename=p.jfr … StackChunks.java platform" 300 '' \
          "$JAVA" "-XX:StartFlightRecording=filename=p.jfr,settings=profile" StackChunks.java platform
      if [ -s v.jfr ] && [ -s p.jfr ]; then
        # grep the FULL class name: a bare `grep StackChunk` also matches this
        # program's own lambdas (StackChunks$$Lambda.0x…), which do reach the table.
        "$JAVA_HOME/bin/jfr" view allocation-by-class v.jfr 2>/dev/null | grep -qF 'jdk.internal.vm.StackChunk' \
          && ok "v.jfr has jdk.internal.vm.StackChunk (a virtual thread's stack, copied to the heap)" \
          || bad "v.jfr StackChunk" "no jdk.internal.vm.StackChunk row in the virtual-thread recording"
        "$JAVA_HOME/bin/jfr" view allocation-by-class p.jfr 2>/dev/null | grep -qF 'jdk.internal.vm.StackChunk' \
          && bad "p.jfr StackChunk" "platform threads should not allocate StackChunks" \
          || ok "p.jfr has no jdk.internal.vm.StackChunk row (platform threads keep their stacks)"
      fi
      # watch.sh is the whole unit in one script; it checks the port, kills by PID and proves it is free
      if port_busy "$P43"; then bad "port $P43 before watch.sh" "not free"
      else
        expect_ok "./watch.sh $P43 (~1 min: record -> 20,000 requests -> jcmd -> stop -> lsof)" 420 \
            'port '"$P43"' free' ./watch.sh "$P43"
        pkill -9 -f "c2-capstone-1.0.0.jar $P43" >/dev/null 2>&1
        if wait_port_free "$P43"; then ok "watch.sh left no process and no bound port behind"
        else bad "port $P43 after watch.sh" "still in LISTEN"; fi
      fi
    fi
    rm -f tiffinbox.jfr threads.json server.log v.jfr p.jfr
  fi
fi

# ---------------------------------------------------------------- unit 44 ---
if unit 44 "What's next: the closing panel of Course 2"; then
  expect_ok "java -Xmx64m Finale.java (the -Xmx64m is required: it prints the ceiling)" 180 \
      '64 MB' "$JAVA" -Xmx64m Finale.java
  grep -q '810' "$OUT" && ok "the kitchen total 810 is one day of 24300, fixed by arithmetic" \
    || bad "Finale kitchen total" "expected 810"
  rm -f ./*.csv ./*.class
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
      c2-unit0[1-9]|c2-unit[1-3][0-9]|c2-unit4[0-4]|c2-capstone) continue ;;
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
# A filtered run that ran nothing at all — a c2-unit folder that exists but has no
# block here yet — is not a pass either; the unfiltered run says so via the
# "not covered by this script yet" list above.
if [ ${#UNITS[@]} -ne 0 ] && [ $((PASS+FAIL+SKIP)) -eq 0 ]; then
  printf '%sno checks ran for:%s %s\n' "$YLW" "$OFF" "${UNITS[*]}" >&2
  exit 2
fi
printf 'all green.\n'
exit 0

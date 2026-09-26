# Unit 27 — @Async and the TaskExecutor

Course 4 · Section 5 · *Events, Async and Scheduling*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates everything and **asserts** each claim. Thread names are compared by **prefix**,
never by number (contract §2g); `T.name()` masks the counter.

## Whose thread is this?

`java -cp "$CP" com.tiffinbox.WhoseThread` · md5 `17892a8f8785650d042ae3d53f8e7dc0`

```
  [caller] on main
INFO: No task executor bean found for async processing: no bean of type TaskExecutor and no bean named 'taskExecutor' either
  [caller] cook() returned
  [cook ] cooking for Ravi on SimpleAsyncTaskExecutor-<n>
self-invocation:
  [inner] on main
an @Async method that returns a String:
  [caller] IllegalArgumentException: Invalid return type for async method (only Future and void supported): class java.lang.String
```

`cook()` returns **before** it cooks (a latch, not a sleep — asserted). The `INFO` line is logged at the **first
async call**, not at startup (asserted: it follows `[caller] on main`). And two limits, both measured: called
from inside the same bean, `@Async` runs **on main** — the self-invocation trap from the AOP section, again —
and on a method that returns a plain `String`, the **call itself throws**: `@Async` takes `void` or a `Future`.
It also needs `@EnableAsync` on the configuration (unit 26 measured what happens without it).

## The default is not a pool

`java -cp "$CP" com.tiffinbox.Pools` · md5 `c3acc522d9594973455f1f4dff80c252`

```
  the default (no executor bean)     20 tasks -> 20 distinct threads   e.g. SimpleAsyncTaskExecutor-<n> [platform]
  ThreadPoolTaskExecutor, 2 threads  20 tasks ->  2 distinct threads   e.g. kitchen-<n> [platform]
  virtual threads                    20 tasks -> 20 distinct threads   e.g. vkitchen-<n> [virtual]
```

With no executor bean, Spring says so (`No task executor bean found`) and uses `SimpleAsyncTaskExecutor`: a
**new platform thread for every task** — 20 for 20, asserted. A sized `ThreadPoolTaskExecutor` holds it to 2.
Virtual threads are one-per-task **by design** — cheap, and the 2026 default worth reaching for.

## The break — and the skeleton had it half wrong

`java -cp "$CP" com.tiffinbox.Failures` · md5 `96618788069757af1c77c44ad0640c51`

```
INFO: No task executor bean found for async processing: no bean of type TaskExecutor and no bean named 'taskExecutor' either
  [caller] burn() returned - the caller does not know
SEVERE: Unexpected exception occurred invoking async method: public void com.tiffinbox.Failures$Kitchen.burn()
java.lang.IllegalStateException: the oven caught fire

  [caller] price().get() threw ExecutionException, cause IllegalStateException: price failed
```

A `void @Async` that throws is **not unlogged** — `SEVERE` says so. What is true: **the caller never knows**.
Two ways back into code: return a `CompletableFuture` (`get()` throws `ExecutionException`, and the real exception is its cause), or install an
`AsyncUncaughtExceptionHandler` — `java -cp "$CP" com.tiffinbox.Failures handler` · md5 `ce14e8e88a1938b5de1a3bdf9514d0f1`.

## Files

`T` · `WhoseThread` · `Pools` · `Failures` · `jul.sh` · `receipts.sh` · `exercise/`

# Unit 29 — Scheduling Pitfalls: One Thread, Every Job

Course 4 · Section 5 · *Events, Async and Scheduling*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
./receipts.sh        # three runs of each program, hashed, and every claim below asserted
```

## Pitfall one — the default is one thread

`java -cp "$CP" com.tiffinbox.Starved` · md5 `13ab6f53f868929d1a9de23adf007a8b` · 3 of 3 (raw line masked)

```
INFO: No TaskScheduler/ScheduledExecutorService bean found for scheduled processing
  threads that ran both jobs, one thread (the default): 1 [pool-<n>-thread-<n>]
  threads that ran both jobs, a pool of two           : 2 [kitchen-sched-<n>]
  the same 1.2 s: an 800 ms report beside a 100 ms order check
    check count, one thread vs pool of two     : about the same -> counting cannot see the problem
    longest gap between checks, one thread     : 600 ms or more -> the report STARVED the check
    longest gap between checks, pool of two    : 200 ms or less -> the check kept its rhythm
    checks run back-to-back, one thread        : 5 or more -> the missed checks caught up in a burst
    checks run back-to-back, pool of two       : none
… 1 JUL timestamp line(s) elided …
```

Raw numbers from three runs — printed so you can see the wobble, never quoted as facts:

```
run 1: counts 13 vs 13, longest gaps 856 vs 108 ms, back-to-back 7 vs 0
run 2: counts 13 vs 13, longest gaps 857 vs 110 ms, back-to-back 7 vs 0
run 3: counts 12 vs 13, longest gaps 852 vs 110 ms, back-to-back 7 vs 0
```

With no scheduler bean, Spring says so — at **INFO**, once — and runs every `@Scheduled` method on **one
thread**. One slow job holds that thread, and every other job waits behind it. The fix is one bean: a
`ThreadPoolTaskScheduler` with a pool size.

**The first version of this program was wrong, and the way it was wrong is the lesson.** It *counted* order
checks, got the same count both ways, and printed "the report starved it" anyway, because the verdict was a
string, not a computation. A fixed-rate task that misses its slots **catches up in a burst** afterwards, so
the count recovers and hides the starvation. What does not recover is the **rhythm**: the longest gap between
two checks. Every verdict above is now computed from the numbers.

## Pitfall two — the same exception, two schedulers

`java -cp "$CP" com.tiffinbox.TwoSchedulers` · md5 `8423ed52e8d681b5134e5d640509dc93` · 3 of 3

```
Spring's @Scheduled, throwing on run 2:
INFO: No TaskScheduler/ScheduledExecutorService bean found for scheduled processing
SEVERE: Unexpected error occurred in scheduled task
java.lang.IllegalStateException: the till jammed on run 2
	at com.tiffinbox.TwoSchedulers.tick(TwoSchedulers.java:16)
	…
  runs in 0.7 s: MORE than 3 - it kept going
the JDK's scheduleAtFixedRate, the same job:
  runs in 0.7 s: 2   (and nothing was printed)   future done? true
… 2 JUL timestamp line(s) elided …
```

- **Spring's `@Scheduled`** catches the exception, logs it at **SEVERE**, and keeps the schedule alive.
  Ignorable — but not silent.
- **The JDK's `scheduleAtFixedRate`**, the same job: the schedule is **dead after run 2**, nothing is printed,
  and the future says it is done. The "job that stopped weeks ago and nobody noticed" is real — for code that
  uses the JDK's scheduler directly. The exercise finds where that exception went.

The course skeleton pinned this pitfall on Spring. The measurement moved it to the right scheduler.

## Not measured here — named, and where it is fixed

**Two instances of the app, one schedule each:** the job runs twice. That is the duplicate-job problem, and
it is fixed with a shared lock in the Spring Batch and Scheduling course.

## Files

`Starved` · `TwoSchedulers` · `jul.sh` · `receipts.sh` · `exercise/`

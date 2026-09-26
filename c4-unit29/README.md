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

## Pitfall one, to the end — a job that never returns

`java -cp "$CP" com.tiffinbox.Hung` · md5 `4c71d6b7b56da04e8cf0de1ce8c0db25` · 3 of 3

```
INFO: No TaskScheduler/ScheduledExecutorService bean found for scheduled processing
  one report that never returns, on the default single thread:
    order checks by 0.6 s: 3   by 2.6 s: 3   -> the check has STOPPED
… 1 JUL timestamp line(s) elided …
```

A slow job only **delays** the other jobs — they catch up. A job that **never returns** holds the one default
thread for ever: the order check stops, and nothing is logged (asserted: the same count at 0.6 s and 2.6 s, no
WARNING or SEVERE). *That* is the "stopped weeks ago, nothing failed" story for Spring's own scheduler.

## Pitfall two — the same exception, with and without Spring's wrapper

`java -cp "$CP" com.tiffinbox.WrappedOrNot` · md5 `0a9e5352eaced7705e8d4a6855d46103` · 3 of 3

```
through Spring's @Scheduled (your job inside Spring's catch-and-log wrapper), throwing on run 2:
INFO: No TaskScheduler/ScheduledExecutorService bean found for scheduled processing
SEVERE: Unexpected error occurred in scheduled task
java.lang.IllegalStateException: the till jammed on run 2

  thread: pool-<n>-thread-<n>   runs in 0.7 s: MORE than 3 - it kept going
the same job on the JDK's scheduleAtFixedRate directly - no wrapper:
  thread: pool-<n>-thread-<n>   runs in 0.7 s: 2   printed while it ran: nothing   future done? true
… 2 JUL timestamp line(s) elided …
```

With no scheduler bean, Spring's default **is** a JDK single-thread scheduled executor — both rows ran on a
`pool-<n>-thread-<n>` thread. What differs is one wrapper:

- **Through `@Scheduled`**, Spring runs your job inside a catch-and-log wrapper (`DelegatingErrorHandlingRunnable`
  in the stack trace): the exception is logged at **SEVERE** and the schedule keeps going. Ignorable — but not
  silent.
- **The JDK's `scheduleAtFixedRate` called directly**, the same job: the schedule is **dead after run 2**,
  **nothing is printed** (measured: stdout and stderr captured while it ran), and the future says it is done.
  The exercise finds where that exception went.

*This unit first framed pitfall two as "two different schedulers" (`TwoSchedulers`). The section's RED review
showed the variable is the wrapper, not the scheduler; the program was renamed and re-measured.*

## Not measured here — named, and where it is fixed

**Two instances of the app, one schedule each:** the job runs twice. That is the duplicate-job problem, and
it is fixed with a shared lock in the Spring Batch and Scheduling course.

## Files

`Starved` · `Hung` · `WrappedOrNot` · `jul.sh` · `receipts.sh` · `exercise/`

# Unit 28 — @Scheduled: Fixed Rate vs Fixed Delay vs Cron

Course 4 · Section 5 · *Events, Async and Scheduling*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

**This unit is the course's measurement auditor.** No duration is ever stated as a fact. The programs print the
raw gaps; `gaps.sh` masks and counts them; the **shape** — each line's verdict — is what is hashed and asserted.

## Three ways to say "every 300 ms" — for a job that takes 200 ms

`java -cp "$CP" com.tiffinbox.RateVsDelay` · masked md5 `2009904f1048d9042777c19bcb4f472c` · 3 of 3

```
  fixedRate  = 300, job 200 ms   gaps between starts: [<gaps>]   -> every gap within 40 ms of 300
  fixedDelay = 300, job 200 ms   gaps between starts: [<gaps>]   -> every gap within 40 ms of 500
  fixedRate  = 300, job 500 ms   gaps between starts: [<gaps>]   -> every gap within 40 ms of 500, at most 1 running at once
  the same, a POOL OF 4 threads  gaps between starts: [<gaps>]   -> every gap within 40 ms of 500, at most 1 running at once
  fixedRate  = 300 WITHOUT @EnableScheduling   firings in 1 s: 0
… 3 JUL timestamp line(s) elided …
… 4 line(s) of raw gaps masked …
```

Raw gaps from three runs — they wobble, which is exactly why no single one is quoted as a fact:

```
run 1: [304, 300, 300] [508, 510, 510] [500, 500, 500] [500, 500, 500]
run 2: [306, 296, 304] [510, 510, 510] [500, 500, 500] [500, 500, 500]
run 3: [305, 296, 304] [510, 510, 510] [500, 500, 500] [500, 500, 500]
```

- **fixed rate** — starts every period, whatever the job takes.
- **fixed delay** — waits the period **after the job ends**: period + work.
- **the break: fixed rate with a 500 ms job** — fixed rate **never runs a job on top of itself**, so the
  rate **silently becomes the job's duration**: at most 1 running at once (asserted). **Not because of one
  thread:** on a `ThreadPoolTaskScheduler` of **4** the shape is identical (asserted). *(An earlier version of
  this README said "on one thread"; the section's RED review measured the pool of 4.)*
- **`@EnableScheduling` is required.** Without it, `@Scheduled` fires **0** times in 1 s and nothing is logged
  (asserted: the only INFO lines come from the runs that had it).

Jobs spin on the clock rather than sleeping, so closing the context never interrupts one mid-sleep — the
first probe logged a `SEVERE InterruptedException` at shutdown, which was noise, not evidence.

## Cron — computed, never waited for

`java -cp "$CP" com.tiffinbox.CronNext` · md5 `2b7b99cc1518d172cf0c0b38ae21418b`

```
  "0 30 11 * * MON-FRI", computed from 2026-09-25T12:00 FRIDAY:
    next -> 2026-09-28T11:30  MONDAY
    next -> 2026-09-29T11:30  TUESDAY
    next -> 2026-09-30T11:30  WEDNESDAY
    next -> 2026-10-01T11:30  THURSDAY
  the same rule on a server in UTC: next -> 2026-09-28T11:30 UTC  = 2026-09-28T17:00 in Kolkata
```

Spring's six fields: **second minute hour day-of-month month day-of-week**. A video cannot wait for 11:30 on a Monday. `CronExpression.next()` is deterministic, and it is what you actually
need to check. The weekend skip is visible (asserted). **And the rule is read in a time zone** — the server's,
unless `@Scheduled(cron = …, zone = …)` says otherwise: the same rule on a UTC server fires at **17:00 in
Kolkata** (asserted).

## Files

`Firings` · `RateVsDelay` · `CronNext` · `gaps.sh` · `jul.sh` · `receipts.sh` · `exercise/`

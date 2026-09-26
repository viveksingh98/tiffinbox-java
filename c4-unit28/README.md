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

`java -cp "$CP" com.tiffinbox.RateVsDelay` · masked md5 `341ee0ce4dccc4d11e960f72ce052d4d` · 3 of 3

```
  fixedRate  = 300, job 200 ms   gaps between starts: [<gaps>]   -> every gap within 40 ms of 300
  fixedDelay = 300, job 200 ms   gaps between starts: [<gaps>]   -> every gap within 40 ms of 500
  fixedRate  = 300, job 500 ms   gaps between starts: [<gaps>]   -> every gap within 40 ms of 500, at most 1 running at once
… 3 line(s) of raw gaps masked …
```

Raw gaps from three runs — they wobble, which is exactly why no single one is quoted as a fact:

```
run 1: [301, 299, 297] [502, 505, 503] [500, 500, 500]
run 2: [301, 300, 299] [504, 503, 506] [500, 503, 502]
run 3: [288, 302, 298] [503, 507, 505] [502, 500, 500]
```

- **fixed rate** — starts every period, whatever the job takes.
- **fixed delay** — waits the period **after the job ends**: period + work.
- **the break: fixed rate with a 500 ms job** — the scheduler cannot overlap it on one thread, so the rate
  **silently becomes the job's duration**: at most 1 running at once (asserted).

Jobs spin on the clock rather than sleeping, so closing the context never interrupts one mid-sleep — the
first probe logged a `SEVERE InterruptedException` at shutdown, which was noise, not evidence.

## Cron — computed, never waited for

`java -cp "$CP" com.tiffinbox.CronNext` · md5 `107979cd55c05c16a478f9c0b8a26df3`

```
  "0 30 11 * * MON-FRI", computed from 2026-09-25T12:00 FRIDAY:
    next -> 2026-09-28T11:30  MONDAY
    next -> 2026-09-29T11:30  TUESDAY
    next -> 2026-09-30T11:30  WEDNESDAY
    next -> 2026-10-01T11:30  THURSDAY
```

A video cannot wait for 11:30 on a Monday. `CronExpression.next()` is deterministic, and it is what you actually
need to check. The weekend skip is visible (asserted).

## Files

`Firings` · `RateVsDelay` · `CronNext` · `gaps.sh` · `jul.sh` · `receipts.sh` · `exercise/`

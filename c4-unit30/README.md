# Unit 30 — Core Resilience Annotations in Framework 7

Course 4 · Section 5 · *Events, Async and Scheduling*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
./receipts.sh        # three runs of each program, hashed, and every claim below asserted
```

**This is Course 4's designated re-cut unit** (style contract §3d): its subject is an API that arrived in the
current major version, so it is written to be re-recorded when that API settles. Everything else in the course is
written to outlive a version bump.

## Where it lives, and since when

`java -cp "$CP" com.tiffinbox.WhereItLives` · md5 `901efdddc1746d9cf0202e4e9eed4661` · 3 of 3

```
  @Retryable               from spring-context-7.0.9.jar   (package org.springframework.resilience.annotation)
  @ConcurrencyLimit        from spring-context-7.0.9.jar   (package org.springframework.resilience.annotation)
  @EnableResilientMethods  from spring-context-7.0.9.jar   (package org.springframework.resilience.annotation)
  @Retryable with nothing set, read off the annotation:
    maxRetries = 3   -> 4 attempts in all
    delay      = 1000 MILLISECONDS, multiplier = 1.0, jitter = 0
  @ConcurrencyLimit when full, read off the annotation: policy = BLOCK
… 0 JUL timestamp line(s) elided …
```

`./since.sh` · md5 `463fb38b533283ad9990cd511a52fcc0`

```
  spring-context 6.2.19: 0 entries under org/springframework/resilience/
  spring-context 7.0.9: 27 entries under org/springframework/resilience/
```

The jar is read off each class, not off a slide: `spring-context`, the dependency this course has had since its
first unit. **No new dependency.** And `since.sh` counts the package in the last 6.2 jar, 6.2.19: none of it is there. *(First counted in 6.2.12;
the section's RED review pointed out 6.2.13-6.2.19 exist.)*

## Attempts, counted

`java -cp "$CP" com.tiffinbox.Attempts` · md5 `3ecb460ddca12f22553a06c32c522c3c` · 3 of 3

```
  fails twice, then works - called through the bean:
    attempt 1 failed
      [event] gateway timeout on attempt 1
    attempt 2 failed
      [event] gateway timeout on attempt 2
    attempt 3 succeeded
    -> paid after 3 attempts
  fails every time - called through the bean:
    attempt 1 failed
      [event] gateway timeout on attempt 1
    attempt 2 failed
      [event] gateway timeout on attempt 2
    attempt 3 failed
      [event] gateway timeout on attempt 3
      [event] retries exhausted - RetryException, cause: gateway timeout on attempt 3, earlier failures attached: 2
    -> the caller gets IllegalStateException: gateway timeout on attempt 3   (earlier failures attached: 0, cause: null)
  fails twice, then works - called from INSIDE the class:
    attempt 1 failed
    -> IllegalStateException after 1 attempt(s) - no retry at all
… 0 JUL timestamp line(s) elided …
```

- `maxRetries = 2` means **three attempts** in all. The default, with nothing set, is three retries: **four**.
- When every attempt fails, the caller gets **the last exception, unwrapped**, with the first two not attached.
  **They are not lost:** Spring publishes a `MethodRetryEvent` for every failure, and one more when retries are
  exhausted — a `RetryException` whose cause is the last failure and which carries the earlier two (asserted).
  A plain `@EventListener`, the tool from the start of this section, sees all of them.
- `maxRetries` counts **retries**. The separate Spring Retry library's `@Retryable` names its setting
  `maxAttempts` and counts the first call too — which is exactly how these two numbers get mixed up.
- With nothing set: `multiplier = 1.0` (the delay does not grow) and `jitter = 0` (no randomness). The
  annotation also takes `includes` / `excludes` — which exceptions are worth retrying at all. That is the knob
  the break below needed.
- Called from inside its own class, the retry **never happens**. The proxy is not in that call — the trap from
  the AOP section, back again.

## The break — the bill

`java -cp "$CP" com.tiffinbox.TheBill` · md5 `20100704612ca5c86f3b6ac20f3fd61b` · 3 of 3

```
  one order of 340: paid after 3 attempts
  charged 1020 for one order   (3 x 340)
… 0 JUL timestamp line(s) elided …
```

The gateway takes the money and **then** times out — the charge went through, the reply was lost. `@Retryable`
does exactly what it was told and charges again. The method returns `paid`, nothing is logged, and the customer
paid three times. **A retry policy is a correctness decision:** retry only what is safe to repeat, or make the
repeat harmless. The exercise does the second.

## @ConcurrencyLimit — two burners, six cooks

`java -cp "$CP" com.tiffinbox.Limit` · md5 `99456395d494f8cfdd5bdaa9e9112fad` · 3 of 3

```
  six cooks at once, no limit            : at most 6 cooking at once, 6 of 6 cooked
  six cooks at once, @ConcurrencyLimit(2): at most 2 cooking at once, 6 of 6 cooked
… 0 JUL timestamp line(s) elided …
```

The limit caps how many callers are **inside** the method at once. The rest are not refused — they wait
(`policy = BLOCK`, the default, read off the annotation), so all six still cook.

## Where this goes next

Retry storms, backoff and jitter across services: the Microservices and Spring Cloud course. The standalone
Spring Retry library, and how it differs from these core annotations: the Also in the Spring Family course.

## Files

`WhereItLives` · `Attempts` · `TheBill` · `Limit` · `since.sh` · `jul.sh` · `receipts.sh` · `exercise/`

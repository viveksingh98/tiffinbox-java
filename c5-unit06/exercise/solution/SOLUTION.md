# Solution

Measured 2026-09-29 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1), after `../receipts.sh` had passed, by running
`../README.md`'s block **exactly as written** from `c5-unit06/exercise/` in a clean shell (`env -i HOME="$HOME" bash
--noprofile --norc`, so nothing but the block's own two `export` lines chose the JDK, and no variable of the author's
could become a sixth place). The block's own last line printed the starting state:

```
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
the bean's own field: OrderQueue.cooks = 3
```

## Two answers — only the `java …` line changes, in front of the class name

The same block, its last line replaced by each of these in turn (the four lines above it unchanged):

```bash
TIFFINBOX_COOKS=5 java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18669 2>&1 | grep -E '^KEY |^the bean'
java -Dtiffinbox.cooks=5 -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18669 2>&1 | grep -E '^KEY |^the bean'
```

```
KEY tiffinbox.cooks -> WINNER 5 · from source 4 of 7, systemEnvironment
the bean's own field: OrderQueue.cooks = 5
KEY tiffinbox.cooks -> WINNER 5 · from source 3 of 7, systemProperties
the bean's own field: OrderQueue.cooks = 5
```

1. **An environment variable**, `TIFFINBOX_COOKS=5` in front of the command. `TIFFINBOX_COOKS` is the upper-case,
   underscore spelling of `tiffinbox.cooks`; the `systemEnvironment` source (number 4) answers the key with it, and it
   ranks above the file (number 6). Which spellings reach which key is the next unit's subject.
2. **A system property**, `-Dtiffinbox.cooks=5` **before** `-cp` (or before `-jar`): Java itself sets it, and
   `systemProperties` (number 3) ranks above the variable and the file.

Neither edits a file, and TiffinBox's arguments are still exactly `--tiffinbox.port=18669`. Each run stopped its own
server (the harness closes the context): 0 listeners on 18669 afterwards.

## The tempting wrong answer — the break's second silent one

```bash
java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18669 -Dtiffinbox.cooks=5 2>&1 | grep -E '^KEY |^the bean|^non-option|WARN'
```

```
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
the bean's own field: OrderQueue.cooks = 3
non-option arguments Boot kept: [-Dtiffinbox.cooks=5]
```

It breaks the rule (it adds to TiffinBox's arguments), and it does not work either: a `-D` after the class name — or after
the jar — is an argument to the program, not an option to Java. Boot keeps it as a non-option argument, nothing reads it,
and no `WARN` line appears (the `grep` above would have kept one). Still three cooks.

## A third source, for the curious

Two is not the limit. Boot also reads a whole JSON document from one variable:

```bash
SPRING_APPLICATION_JSON='{"tiffinbox":{"cooks":5}}' java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18669 2>&1 | grep -E '^KEY |^the bean'
```

```
KEY tiffinbox.cooks -> WINNER 5 · from source 3 of 8, spring.application.json
the bean's own field: OrderQueue.cooks = 5
```

It adds a property source of its own, `spring.application.json` — 8 sources instead of 7 — and, measured, puts it at
number 3, **above** `systemProperties`. The video's ladder does not include it; the exercise accepts it, because its
winner line names a third source.

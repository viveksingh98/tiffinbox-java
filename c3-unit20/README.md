# c3-unit20 — appenders, patterns, rolling and MDC

Course 3 · Build & Test Like a Pro · Section 4 "Logging & Honest Measurement".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`, the value this course has carried since the Gradle
section. Everything this unit adds is in `com/tiffinbox/kitchen/`.

**Every Maven command carries `-Dmaven.repo.local="$PWD/.m2-demo"` with the quotes**; this
tree's path contains a space. Nothing here touches `~/.m2` or `~/.gradle`.

## One event, two destinations

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -q compile exec:exec
```

The console shows seven lines. So does `target/logs/kitchen.log`, character for character
once the clock is masked — `./receipts.sh appenders` diffs the two and says so. **An
appender is a destination, the root logger can hold more than one, and neither the code nor
the level knows how many there are.**

## The pattern, token by token

```
%d{HH:mm:ss.SSS} [%thread] %-5level %logger{1} %X{orderId:-} - %msg%n
```

`./receipts.sh pattern` reads that string out of `logback.xml`, takes one real line out of
the log file, and checks each token against the field it produced — so the decoding on the
slide is a match the block performed, not a caption someone wrote:

```
pattern: %d{HH:mm:ss.SSS} [%thread] %-5level %logger{1} %X{orderId:-} - %msg%n
one line: <time> [cook-1] INFO  kitchen A-4417 - accepted for Arun (240 rupees)
  %d{HH:mm:ss.SSS}   -> matched ^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} 
  [%thread]          -> matched \[(cook-[0-9]+|main)\]
  %-5level           -> matched INFO 
  %logger{1}         -> matched  kitchen 
  %X{orderId:-}      -> matched (A-4417|B-9082)
  %msg%n             -> matched - (accepted|cooking|packed) for 
tokens in the pattern: 7 ; checked against this line: 6 groups (%msg and %n are one)
```

That block is the whole of what `./receipts.sh pattern` writes into the capture it hashes —
nothing above is trimmed, which is why the `pattern:` and `one line:` labels are on it. The
timestamp is masked to `<time>` by the receipt itself, because a clock reading is the one
thing in that line that cannot be the same twice.

## Which lines belong to *this* order

```
./receipts.sh mdc
```

```
<time> [cook-1] INFO  kitchen A-4417 - accepted for Arun (240 rupees)
<time> [cook-2] INFO  kitchen B-9082 - accepted for Bela (200 rupees)
<time> [cook-1] INFO  kitchen A-4417 - cooking for Arun (240 rupees)
<time> [cook-2] INFO  kitchen B-9082 - cooking for Bela (200 rupees)
<time> [cook-1] INFO  kitchen A-4417 - packed for Arun (240 rupees)
<time> [cook-2] INFO  kitchen B-9082 - packed for Bela (200 rupees)
<time> [main] INFO  kitchen  - both tickets done
lines carrying A-4417: 3 ; B-9082: 3 ; no id at all: 1 ; total: 7
MDC.put() calls in KitchenMdc.java: 1
log.info(...) call sites: 2 ; of those, sites passing an order id: 0
```

Read the last line twice. **Not one logging call passes the order id.** It is put into the
MDC once, per thread, and `%X{orderId:-}` in the layout does the rest.

The two cooks are **not racing** — two semaphores hand control back and forth, so the six
lines interleave the same way every run. A concurrency demonstration whose output changes
between runs cannot be shown as fixed, and this unit does not pretend otherwise: what is
being taught is which id lands on which line, not who wins.

## The break — an id at a thread boundary

```
./receipts.sh handoff
```

```
<time> [main] INFO  kitchen ... - --- state 1: hand the work over and hope ---
<time> [main] INFO  kitchen A-4417 - accepted Arun
<time> [pool-1-thread-1] INFO  kitchen ... - cooking Arun
... 2 lines elided: the same pair again for Bela, with the same empty id ...
<time> [main] INFO  kitchen ... - --- state 2: copy the map in, forget to take it out ---
<time> [main] INFO  kitchen A-4417 - accepted Arun
<time> [pool-1-thread-1] INFO  kitchen A-4417 - cooking Arun
<time> [main] INFO  kitchen B-9082 - accepted Bela
<time> [pool-1-thread-1] INFO  kitchen A-4417 - cooking Bela
state 1 - cooking lines that reached the pool with NO id: 2 of 2
state 2 - cooking lines labelled with another request's id: 1 of 2
the process exit code, in both states: 0
nothing threw, nothing was dropped, and one line is now a confident lie
```

State 1 loses the id: the MDC is thread-local and the pool thread never had it. **State 2
is worse** — somebody "fixed" one code path by copying the map in and never clearing it, so
the pooled thread hands Arun's order id to Bela's line. Nothing throws. Every search you run
afterwards gives you a confident wrong answer.

`./receipts.sh pool` is the repair, in `Mdc.carrying`: capture on the calling thread,
install or clear on the pool thread, and take it off in a `finally`.

## Rolling — and the reason a 1 KB roller does not roll

The configuration in `breaks/no-roll/src/main/resources/logback.xml` is the one every
tutorial shows, copied exactly. It does not roll.

```
./receipts.sh roll
```

```
maxFileSize is 1KB in BOTH configurations. Same driver, same 60 lines asked for.
breaks/no-roll  (no <checkIncrement>)   files: 1   lines on disk: 61
this project    (<checkIncrement>0 ms)  files: 4   lines on disk: 48
file names after the roll: kitchen.1.log kitchen.2.log kitchen.3.log kitchen.log 
oldest line still on disk: slip 0013 (of 60 written)
lines the window discarded: 13
```

Why, read out of the jar rather than out of a blog post:

```
./receipts.sh gate
```

```
SizeBasedTriggeringPolicy asks a FixedIntervalInvocationGate before it stats the file
FixedIntervalInvocationGate.DEFAULT_INCREMENT = 1 minutes
SizeBasedTriggeringPolicy.DEFAULT_MAX_FILE_SIZE = 10485760 bytes
```

**Once a minute.** `SizeBasedTriggeringPolicy` does not call `File.length()` on every event
— it asks a gate first, and that gate's default increment is one minute. A run that finishes
in less than a minute never has its size checked and never rolls, and nothing in the log,
the status output or the exit code says so. `<checkIncrement>` is the element that changes it.

And the second half of the receipt is the one nobody puts on a slide: **48 lines of the 61
are all that survived.** A rolling appender is a bounded buffer. It deletes.

The per-file byte sizes are printed **outside** the hash, with the reason on screen: a size
is not a constant.

## Every block

| Block | What it measures |
|---|---|
| `appenders` | console and file line counts, and that the two renderings are identical |
| `pattern` | each layout token against the field it produced in one real line |
| `mdc` | one id per request, none on the thread that has no request |
| `handoff` | the break: the id lost, then the id attached to the wrong request |
| `pool` | the repair, and the pooled thread coming back clean |
| `roll` | the same driver under two configurations: file counts and lines kept |
| `gate` | the one-minute default, read out of `logback-core-1.6.3.jar` |
| `solution` | the exercise, both states |
| `offline` | `mvn -o test` after one warm build (contract §1c) |

`./receipts.sh` runs all nine. Every count is appended into the `.out` file **before** it is
hashed, so a wrong number moves the hash.

## Teardown

```
rm -rf target .m2-demo .r-*.out .r-*.raw .r-cp.txt .sol .gate
rm -rf breaks/*/target exercise/target
```

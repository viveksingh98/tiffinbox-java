# c3-unit21 — structured logging

Course 3 · Build & Test Like a Pro · Section 4 "Logging & Honest Measurement".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, Apple silicon, on 2026-09-15.
Needs **`jq`** on the PATH (measured here with jq 1.8.1); `receipts.sh` refuses to run without it.

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`. **Every Maven command carries
`-Dmaven.repo.local="$PWD/.m2-demo"` with the quotes**; this tree's path contains a space.

## One run, two encodings

`src/main/resources/logback.xml` attaches **both** a pattern layout and a
`LogstashEncoder` to the same `<root>`, so every event lands in both files. That is the
design of the whole unit: if the two forms came from two runs, any difference between the
answers could be blamed on the runs rather than on the encoding.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" -q compile exec:exec
./receipts.sh both
```

```
lines in the text log ....... 8
JSON objects in the JSON log  6
the difference ............. 2, and every one of them is a stack-trace line
```

Six events. Eight lines. The text log is **line-oriented and the events are not**.

## One question, asked of both

> *Every event for order **B-9082** at level WARN or above.*

```
./receipts.sh query
```

```
the question: every event for order B-9082 at WARN or above

jq -c 'select(.orderId=="B-9082" and .level_value>=30000)'
{"@timestamp":"<time>","@version":"1","message":"kitchen is behind - 12 slips waiting","logger_name":"kitchen","thread_n ...
{"@timestamp":"<time>","@version":"1","message":"could not cook","logger_name":"kitchen","thread_name":"main","level":"E ...

grep B-9082 target/logs/kitchen.log | grep -E 'WARN|ERROR'
<time> WARN  kitchen A-4417 - short on rice, splitting the rest of order B-9082 to tomorrow
<time> WARN  kitchen B-9082 - kitchen is behind - 12 slips waiting
<time> ERROR kitchen B-9082 - could not cook

jq matched ................. 2 event(s)
grep matched ............... 3 line(s)
of those, belonging to a DIFFERENT order: 1
stack-trace lines the grep dropped: 2 (they carry no level and no id)
the grep answer is wrong in both directions at once: it includes 1 line(s) that are not
B-9082's, and excludes 2 line(s) that are
```

**The grep answer is wrong in both directions at once.** It includes a line that belongs to
order A-4417 — whose message happens to *mention* B-9082 — and it excludes the two lines of
the stack trace, which carry neither a level nor an id. A field has a name and a boundary;
a substring has neither.

Which hits are false is decided by the **id field at its position in the layout**
(`$4`), not by looking for a particular order — so the count survives changing the data.

## The delimiter is not yours alone

```
./receipts.sh truncate
```

```
the layout is  ... %X{orderId:-} - %msg%n  , so " - " separates the id from the message
the message logged, read out of the JSON: kitchen is behind - 12 slips waiting
the same message, cut out of the text log on that separator: kitchen is behind
characters logged: 36 ; characters the split returned: 17 ; lost: 19
```

Nothing is wrong with that message. **A text layout has no way to say where a field ends**,
so any separator you pick is a separator your data is allowed to contain.

## Fields, and the one that is not there

```
./receipts.sh fields
```

```
events: 6 ; carrying an orderId key: 5 ; with no such key at all: 1
MDC.put() calls in the source: 2
times orderId is named inside the JSON appender element: 0
times orderId is named inside the TEXT appender element: 1  (%X{orderId:-}, the layout token)
```

Every MDC entry becomes a top-level key **with no encoder configuration at all** — zero
mentions of `orderId` inside the JSON appender. And an event with nothing in the MDC has no
`orderId` key, rather than an empty one: `jq 'has("orderId")'` can ask that question, and no
grep can.

## What it costs — the honest other half

```
./receipts.sh cost
```

```
+- net.logstash.logback:logstash-logback-encoder:jar:9.0:compile
|  \- tools.jackson.core:jackson-databind:jar:3.0.1:compile
|     +- com.fasterxml.jackson.core:jackson-annotations:jar:2.20:compile
|     \- tools.jackson.core:jackson-core:jar:3.0.1:compile

jackson rows the encoder brought in: 3
  under tools.jackson.* (Jackson 3) ......... 2
  under com.fasterxml.jackson.* (Jackson 2) . 1  <- the annotations, still on the old groupId
bytes per event: text 81, JSON 222 (6 events)
that is the trade: 141 extra bytes an event, and a field a machine can name
```

Two things worth knowing before you add this to a real project. **Jackson 3 arrives under a
groupId you may never have typed** — `tools.jackson.core` — while its annotations still come
from Jackson 2's `com.fasterxml.jackson.core`. A project already on Jackson 2 therefore gets
Jackson 3 *beside* it rather than in a version fight with it, because the groupId changed.
And the JSON log is **roughly two and three-quarter times as wide per event**. That is the price of
the structure, and it is paid in storage and in readability at a console.

The rule that falls out of both halves: **the console is for you and the aggregator is for
the machine — so ship both, and do not ask one format to be good at the other's job.**

## Every block

| Block | What it measures |
|---|---|
| `both` | the same six events in both encodings; text lines against JSON objects |
| `query` | one question, two tools: jq's answer, grep's answer, and how grep is wrong twice |
| `fields` | MDC entries as keys; the absent key; zero encoder configuration |
| `truncate` | the layout's own delimiter inside a message, in characters lost |
| `cost` | three extra jars, two Jackson groupIds, and bytes per event |
| `solution` | the exercise, before and after |
| `offline` | `mvn -o test` after one warm build (contract §1c) |

`./receipts.sh` runs all seven. Every count is appended into the `.out` file **before** it
is hashed. Both clocks are masked first — the text layout's `HH:mm:ss.SSS` and the JSON
encoder's ISO-8601 `@timestamp`, which also carries this machine's UTC offset.

## Teardown

```
rm -rf target .m2-demo .r-*.out .r-*.raw .r-cp.txt .sol exercise/target
```

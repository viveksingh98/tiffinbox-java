# c3-unit28 — what's next: the container, industrialised

Course 3 · Build & Test Like a Pro · Section 5 "Ship the Artifact" · **the last unit of the
course.**
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, 8-core / 16 GB Apple silicon,
on 2026-09-15, with `gaps` and `ship` re-measured on 2026-09-19 — see *The four holes* and
*The chain, run* below for what moved and why.

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`. They have been carried, unchanged, since the start of
this course.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh
```

**There is no exercise in this unit.** Every other unit in the course ships one; the finale's
task is the hand-off.

## Every count here is re-read, never remembered

`./receipts.sh counts` **imports** `~/Desktop/PromptVidya-Automation/java3_series.py` — the
single source of these facts — and prints what it finds:

```
units in this course ............... 28
sections in this course ............ 5
  1. Maven, Properly                  01-06  (6 units)
  2. Gradle Beside It                 07-10  (4 units)
  3. Testing That Earns Trust         11-18  (8 units)
  4. Logging & Honest Measurement     19-22  (4 units)
  5. Ship the Artifact                23-28  (6 units)
units accounted for by the five sections: 28
```

A finale that types its own unit count is the failure mode of every roadmap video on the
internet. This one asserts, inside the script, that the five sections account for every
unit — and stops if they do not.

## The four holes — three closed, one handed on

The last course's finale named four things its capstone did not have, and those four are its
own words, in its own order, off its own closing slide. `./receipts.sh gaps` counts an
artifact for each — and prints nothing for the one this course does not close:

```
the last course finale named four holes in the capstone. Each one, against a file:

  1  "no tests - and the build says so"
     unit directories in this course ................ 28
     of those, carrying a src/test tree ............. 18
     units shipping a receipts.sh that runs them .... 22

  2  "one hand-wired main"
     files that write that startup order down ....... 0   <- the one still open

  3  "one pom.xml, and nothing but you runs it"
     pom.xml files in the long-lived project ........ 3   (a parent and its modules)
     workflow files shipped ......................... 1

  4  "a bundle only YOUR machine will run"
     reachability metadata files shipped ............ 3
     build profiles here that consume them .......... 1   <- the other half
     that profile's unit deletes them and builds again: the build stays green, and
     the binary stops. The ledger counts files behind a hole, so it does not move.

  and one it DEFERRED on purpose rather than confessed - "a backend behind
  System.Logger". Not a hole; a choice it declared. Paid anyway:
     logback configurations shipped ................. 7

holes the last course named .......... 4
holes with an artifact behind them ... 3
holes handed to the next course ...... 1   (hole 2 - see the next block)
```

The fourth hole's second line is the one that changed. Those three descriptors sat in the
repository for a whole cut with **nothing that read them** — which is why the row used to
end in a sentence rather than a count, and why the slide called it half an answer. The
closed-world unit's `native` profile reads them now: it builds the image, deletes the
descriptors, builds again to `BUILD SUCCESS` and gets a binary that dies. **The ledger
above still says 4 / 3 / 1**, because it counts holes with a file behind them and this one
always had three — the hedge moved, not the arithmetic, and the block prints that itself.

**Every count above excludes generated paths** — `target/`, `build/`, `out/` — so the ledger
does not move when you build the project. It *is* still a snapshot: it moves when a unit is
added, renamed or removed, and the block says so in its own output.

## The chain, run — not claimed

`./receipts.sh ship` does not assert that the course worked. It runs it:

```
the chain, run end to end, on this machine, today:

  1  mvn package                                    exit 0   Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
       application jar + 1 dependency jar(s) beside it
  2  java -jar <the jar>                            exit 0
       customers=4 monthRevenue=24300 cooked=120 cookedValue=24300
       ... 1 more line(s) elided
  3  java -XX:AOTMode=record  ...                   exit 0
     java -XX:AOTMode=create  ...                   exit 0
  4  java -XX:AOTCache=<cache> ...                  exit 0
       classes loaded 2079, of those out of the cache 2071
  5  jlink --add-modules java.base,java.sql         exit 0
       5 of this JDK 69 modules
  6  <the image>/bin/java ...                       exit 0
       customers=4 monthRevenue=24300 cooked=120 cookedValue=24300
       ... 1 more line(s) elided

steps in the chain .................. 6
commands those steps ran ............ 7   (step 3 is two)
exit codes captured ................. 7
commands that exited 0 .............. 7
the two runs printed the same answer: yes

And the step that is NOT in this chain, left out on purpose: a native binary. It
needs a second JDK this chain does not, and the unit that owns it builds one.
```

The same four customers, the same month's revenue, out of a jar and out of a 36 MB runtime
image that contains five of this JDK's sixty-nine modules.

**The chain stops at the runtime image on purpose.** Every command above runs on a stock
JDK 25, so anyone who can run this repository reproduces all seven exit codes. A native
image needs a second JDK and takes minutes, so it lives in the closed-world unit — which
builds one, breaks it on purpose, and skips cleanly when no GraalVM is present.

## The one gap this course leaves

`src/main/java/com/tiffinbox/wiring/Wiring.java`. Read it — it is short — and then read what
it costs:

```
lines in startEverything(), comments and blanks removed ... 18
objects constructed with new .............................. 4
configuration values held as constants beside them ........ 3
places that order is written down ......................... 0
things that check it ...................................... 0
```

**Every line of that file is correct.** It is readable, it is tested, and it is the last
thing in this project that a person has to keep in their head. Move two lines and it still
compiles — `WiringOrderTest` is what happens when you do:

```
- theWiringAsWrittenWorks
- readingBeforeTheDatabaseIsSeededFails
- theRailMustBeClosedBeforeItsCountersMeanAnything
Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
```

Three tests to say out loud what nothing else in the language or the build tool says: this
order is load-bearing. That is the problem a container solves, and it is the only one this
course leaves open.

## Receipts

| Block | What it proves |
|---|---|
| `counts` | every number on a slide, imported from `java3_series.py` on the day |
| `gaps` | the four holes the last course named — three against a counted artifact, one handed on |
| `wiring` | the one gap left, counted out of the source, with a test for each ordering rule |
| `ship` | the chain — jar, run, AOT cache, runtime image, run again — six steps, seven captured exit codes, seven zeros |
| `offline` | `mvn -o test` after a warm `package` |

**Not hashed, and it says so:** every byte size — the jar, the AOT cache and the runtime
image (C2 finding #3).

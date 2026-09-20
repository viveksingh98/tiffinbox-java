# c4-unit08 — four ways to initialise and destroy

Course 4 · Spring Framework Core · Section 2 "Lifecycle and Scope".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-19.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.FourWays
java -cp "target/classes:$(cat .cp)" com.tiffinbox.NeverClosed           # the break
java -cp "target/classes:$(cat .cp)" com.tiffinbox.NeverClosed --hook    # one line different
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
sh lifecycle-rows.sh                                                     # what this section takes off the wiring file
sh ../c4-unit01/ledger.sh ../c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `FourWays.java` | one bean with **all four** initialise hooks and **all four** destroy hooks, plus a prototype and the real `OrderQueue`. Every number at the foot of its output is derived from the list the beans themselves appended to |
| `NeverClosed.java` | the break. A context created and never closed — which is what every `main` that ends with a blank line does. Run it twice; `--hook` is the one-line difference |
| `lifecycle-rows.sh` | which rows of the hand-wiring ledger **this section** moves, derived out of the wiring file by shape rather than by method name, and it exits 2 rather than print a confident zero |
| `chain.py` | the `Caused by:`-chain filter, carried unchanged from Section 1 |
| `exercise/` | a walk-in freezer that is never emptied |

`ledger.sh` is **not** copied here. It ships in `c4-unit01` and is run from where it ships, so
the repository holds one copy of the measuring script and the anchor stays exactly as the last
course left it.

## The order, both ways, from one capture

```
  1  named      constructor                      (1) the object exists
  2  named      @PostConstruct                   (2) jakarta.annotation
  3  named      InitializingBean.afterProperties (3) a Spring interface
  4  named      @Bean(initMethod) open()         (4) a name in the description
...
  18  named      @PreDestroy                      (1) jakarta.annotation
  19  named      DisposableBean.destroy           (2) a Spring interface
  20  named      @Bean(destroyMethod) shut()      (3) a name in the description
```

`.r-four{1,2,3}.out`, md5 `26cbc2f2def67af7afc2a8b70772f1ac`, exit 0, 3/3, 38 output lines.
The whole 38 lines are the structure case (contract §9): the ordered sequence *is* the lesson,
so it is kept complete and the trim happens around it.

**Why four.** `@PostConstruct` is a standard annotation and does not mention Spring.
`InitializingBean` is a Spring interface and couples your class to the framework.
`@Bean(initMethod = ...)` puts the callback's name in the description, which is the only one of
the three that works on **a class you do not own**. And the constructor is not a lifecycle hook
at all — it is the one moment when the container has done nothing to the object yet.

## Three things measured here that most tutorials get wrong

**1. A destroy callback never runs for a prototype. Not once, not ever.**

```
initialise callbacks the container ran on each PROTOTYPE   3
destroy    callbacks the container ran on the PROTOTYPES   0
```

Both derived from the same list. The container builds a prototype, runs every initialise hook
on it, hands it over, and **keeps no reference to it** — so there is nothing for it to call a
destroy callback on, and it never claimed there would be. `ContextReport` says the same thing
from the other side: `prototypes registered for destruction  0`.

**2. `close()` is inferred when nobody names a destroy method — unless the bean is also a
`DisposableBean`.**

```
close() inferred on the AutoCloseable bean                 1
close() inferred when the bean is ALSO a DisposableBean     0
```

Two beans, one difference. A `@Bean` definition's `destroyMethodName` defaults to the literal
`(inferred)`, and inference finds a public no-argument `close()`. But the inference is
**switched off** the moment the class implements `DisposableBean` — the container takes the
interface as your answer and stops looking. So adding `DisposableBean` for one reason silently
removes a `close()` that was being called for another. Nothing is logged.

**3. The kitchen rail has been closeable since the last Java course, and the container closes it.**

```
the kitchen rail, which has been AutoCloseable since the last Java course
  destroy method recorded in its definition     (inferred)
  orders cooked BEFORE the context closed       1
  one more order placed AFTER the context closed, cooked  0
  so the container ran close() on it            true
```

That last line is not read off a log. `OrderQueue.close()` puts a poison pill on the rail for
every cook and waits for them; if the container called it, a cook is no longer there to take
an order placed afterwards. **One number tells the two cases apart.**

This is the line the build course put on screen as a comment:

```
  // 4. the kitchen rail. Needs nothing above it, and must be CLOSED before anyone
  //    reads its counters - which is a lifecycle rule living in a comment.
```

## The break: the callback that never runs, with exit 0 and nothing logged

```
$ java -cp … com.tiffinbox.NeverClosed
[no close(), no shutdown hook]
  @PostConstruct  the freezer is on
  the application did its work and main() is about to return
```
md5 `187460062fd5b60524bd3b06731be667`, exit **0**, 3/3, 3 output lines.

```
$ java -cp … com.tiffinbox.NeverClosed --hook
[with registerShutdownHook()]
  @PostConstruct  the freezer is on
  the application did its work and main() is about to return
  @PreDestroy     the freezer was emptied
  close()         the door is shut
```
md5 `83077e9768d7e34de185a8e63d18e1d8`, exit **0**, 3/3, 5 output lines.

**Both exit 0. Nothing is logged in either.** The difference is two lines of output and a
resource that was or was not released — which is why "it ran and came back clean" is not
evidence of anything.

## What this section takes off the wiring file

```
$ sh lifecycle-rows.sh
what this section can take off that file, counted out of the source:
  lines in startEverything(), comments and blanks removed ... 18
  of those, lifecycle steps a container can own ............. 2
  they are:
    db.createAndSeed();
    kitchen.close();
  comment lines stating WHEN something may happen ........... 2
```
md5 `45738cf7a0bc195032599e86b82ab0db`, exit 0, 3/3, 7 output lines.

And the anchor's own ledger, re-derived today with the script that ships in the first unit,
against the wiring file unchanged:

```
$ sh ../c4-unit01/ledger.sh ../c4-tiffinbox/…/wiring/Wiring.java
  lines in startEverything(), comments and blanks removed ... 18
  objects constructed with new .............................. 4
  configuration values held as constants beside them ........ 3
  places that order is written down ......................... 0
  things that check it ...................................... 0
```
md5 `decf86d7b4ca9aa5105c6d6e757dc4cb`, exit 0, 3/3, 6 output lines — **the same hash the
first section recorded for the same script against the same file**, which is how this folder
proves it changed nothing in the anchor.

## The receipt

```
beans(app)=6
  ...
  perUse                       prototype  com.tiffinbox.FourWays$PerUse  (not built)  factory=@Bean  lazy=false
claims
  named:    init / destroy in the description open / shut
  inferred: init / destroy in the description null / (inferred)
  perUse:   scope in the definition      "prototype"  isSingleton=false
  hooks Rail.java declares by itself     4
  prototypes registered for destruction  0
```

`cr` md5 `3efd6b9bb7ffde319cfc463aecdb3e8d`, `crs` `d46dc6e7f451d9bd2047f8824fe8ac8d`,
exit 0, 3/3 each, 20 output lines each.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project and for
`exercise/`.

## Exercise

`exercise/` starts clean and `ContextReport` says:

```
  freezer scope in the definition        "prototype"  isSingleton=false
  destroy method recorded in the definition (inferred)
  destroy hooks the freezer declares     2
  destroy hooks the container WILL run on it 0
```

Two hooks on the class, `(inferred)` in the definition, and **zero** of them will ever run.
**End state:** `destroy hooks the container WILL run on it  2`, without touching
`Freezer.java`. Answer in `exercise/solution/`, run by the author: md5
`331296c643e379209de9c23d31c68699`, exit 0, 3/3. Start state md5
`e668bb903e54d2d1a42a1dc3619123f1`, exit 0, 3/3.

Note which row **does not move**: `destroy method recorded in the definition` says `(inferred)`
in both states. The definition was always willing; the scope was what made it moot.

# c4-unit01 — why a container at all

Course 4 · Spring Framework Core · Section 1 "The Container" · **the first unit of the course.**
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-16.

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`. That is not the hash of any one file, and the derivation is
printed here so it can be re-run rather than trusted:

```
for f in Customer CustomerRepository Dashboard Database OrderQueue; do md5 -q $f.java; done | sort | md5 -q
```

It gives `fdb1643d622615f3c331d75deaebb9da` in `c4-unit01/src/main/java/com/tiffinbox/`, in
`c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/` and in the frozen
`c3-tiffinbox/.../com/tiffinbox/` — three places, one value. They have been carried, unchanged,
since the first course, and **this unit does not touch them.** That is the point: the container takes the
construction, not the objects.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
java -cp "target/classes:$(cat .cp)" com.tiffinbox.SameThreeBoxes
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport --stable
sh ledger.sh
(cd ../c4-tiffinbox && sh ../c4-unit01/ledger.sh tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java)
python3 chain.py breaks/one-bean-deleted/.r-cb1.out
```

`ledger.sh` ships **here and only here**, and the run against `c4-tiffinbox` executes it from
here rather than copying it in — so there is exactly one copy of it in the repo, the anchor
project stays exactly as the previous course left it, and two runs of "the same script" cannot
quietly stop being the same script. `chain.py` ships in every unit that hashes a capture it
produced, this one included. Both ledger runs are saved:
`.r-ledger{1,2,3}` (`2de66c732bc0748ced1ca1c1e05075eb`, `places that order is written down 1`)
and `.r-ledger-tb{1,2,3}` (`decf86d7b4ca9aa5105c6d6e757dc4cb`, the same row at `0`) — exit 0,
3/3 each, and `diff` of the two reports exactly that one line.

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. The export is line 1 of every panel in this course for that reason.

## What is in here

| Path | What it is |
|---|---|
| `SameThreeBoxes.java` | the hand-written scanner and the container, **one program, one capture** |
| `TiffinBoxConfig.java` | the description — four `@Bean` methods, and the file the previous course's ledger said did not exist |
| `ContextReport.java` | this unit's receipt. Sorted, filtered, `--stable`-maskable, and it **dies** rather than print a confident zero |
| `ledger.sh` | the five `Wiring.java` counts, **derived** from the file every run |
| `wiring/Wiring.java` | carried in byte-identically from the previous course's finale, so the ledger has something real to count |
| `boot-in-ninety-seconds/` | the destination. **The only Spring Boot in this course** |
| `breaks/one-new-deleted/` | one `new` removed from the hand-written wiring — the compiler's verdict |
| `breaks/one-bean-deleted/` | one `@Bean` removed from the description — **the container's verdict, and it is not a compile error** |
| `exercise/` | two objects still built by hand; move them, and prove it with `ContextReport` |

## The two deletions, side by side — this is the unit's real lesson

Deleting one line from the hand-written wiring and deleting the equivalent line from the
description are **not** the same experience, and the difference is the whole course:

```
breaks/one-new-deleted    mvn clean compile   exit 1   2 compile errors, BUILD FAILURE
breaks/one-bean-deleted   mvn clean package   exit 0   the compiler sees nothing wrong
                          java … ContextReport exit 1  UnsatisfiedDependencyException
                                                       -> Caused by: NoSuchBeanDefinitionException
```

You traded a compile error for a runtime error. That trade is real, it is a cost, and it is
why the rest of this course is about proving **which object you actually got** rather than
about whether the thing started.

## Every count here is derived, never remembered

`./ledger.sh` re-derives the five counts with the same `awk` and `grep` the previous course
used, so they are comparable — and it **exits 2** rather than print a zero it could not
measure. Run against the long-lived project as the previous course left it, the fourth row
reads `0`. Run here, where `TiffinBoxConfig.java` exists, it reads `1`. The previous course's
slide said *"add one and this line moves"*. It moved.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0 — for this project, for
`exercise/`, for `breaks/one-bean-deleted/` and for `boot-in-ninety-seconds/`. The Boot
project keeps **its own** `.m2-demo`, because it resolves a parent this unit's repository does
not hold. `breaks/one-new-deleted/` exits 1 offline as well: it is the break, and it is
supposed to.

## Exercise

`exercise/` starts clean and `ContextReport` says:

```
beans(app)=3
  beans of type Dashboard                0
  dashboard.load().customers()           no Dashboard bean - still built by hand
  @Bean methods in the description       2
```

Move the two objects still built by hand in `Wiring.startEverything()` into the description.
**End state:** `ContextReport` says `beans(app)=5` and `dashboard.load().customers()  4`.
The answer is in `exercise/solution/`, and it was run: exit 0, md5 `01b54839ab292c83ea1ee4a4a733abf7`,
3/3 — the same hash this unit's own `ContextReport` produces.

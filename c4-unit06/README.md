# c4-unit06 — ambiguity: @Primary, @Qualifier and bean collections

Course 4 · Spring Framework Core · Section 1 "The Container".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-16.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ThreeWaysOut
java -cp "target/classes:$(cat .cp)" com.tiffinbox.PrimaryPicks        # A / B / A' in one run
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
java -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakAmbiguous      # exits 1, on purpose
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `Rails.java` | TiffinBox's **two** order rails — the kitchen rail and the delivery rail — and the three ways out |
| `ThreeWaysOut.java` | `@Qualifier`, the injected `List`, and the injected `Map`, all printed |
| `PrimaryPicks.java` | **A / B / A′ in one program, one session**: two configuration classes one `@Primary` token apart, opened `NoPrimary` → `OnePrimary` → `NoPrimary` |
| `BreakAmbiguous.java` | one slot, two candidates, no tie-breaker |
| `breaks/primary-on-both/` | `@Primary` on **both** candidates |
| `chain.py` | the `Caused by:`-chain filter. It keeps every `Caused by:` line plus the first frame under each and **derives** every elision count, including the two-line `java.util.logging` record of a cancelled refresh, which it names in the capture instead of dropping silently. It matches that record on Spring's own message text, never on an English month name or the word `WARNING:` — both of which JUL localises, so the old filter let a timestamp through under a German or French locale while the derived frame counts stayed identical and nothing flagged it. Every other `WARNING:` line is **shown, not cropped**, the JDK's `sun.misc.Unsafe` and CGLIB integrity warnings included. It **exits 2** if the input records a cancelled refresh and it removed none of it |
| `exercise/` | a monitor that is handed one rail and told it has them all |

## A / B / A′ for `@Primary`, and why it is one program rather than three captures

`PrimaryPicks` holds **two** configuration classes — `NoPrimary` and `OnePrimary` — and they
differ by exactly the `@Primary` token. Nothing else on either page is different: same two
rails, same cook counts, same injection point naming neither. Its `main` opens the first, then
the second, then the first again, **in one JVM**, and prints `[B]` in full followed by three
A/B/A′ rows:

```
[A ] no @Primary              rails 2  @Primary 0  NoUniqueBeanDefinitionException  expected single matching bean but found 2: kitchenRail,deliveryRail
[B ] @Primary on kitchenRail  rails 2  @Primary 1  started, and it named nothing    true / false
[A'] @Primary removed again   rails 2  @Primary 0  NoUniqueBeanDefinitionException  expected single matching bean but found 2: kitchenRail,deliveryRail
```

`.r-pp{1,2,3}.out`, md5 `af799f4f86c13be3c77ddc8467f5fc0a`, exit 0, 3/3, 13 output lines.
**One capture, one hash.** A′ reproducing A is something you read off the screen; the earlier
draft ran case B from a separate Maven project in a scratchpad and printed **A's own md5 for
A′**, which turns the third capture into a restatement of the first — the one thing the
three-capture form exists to prevent. `rails 2` on all three rows is the nothing-else-touched
evidence, and `@Primary 0 / 1 / 0` is read off `getBeanDefinition(name).isPrimary()`.

A and A′ do not start, and their rows are still derived: a failed refresh leaves the bean
**definitions** registered, so the `@Primary` count comes off the same definitions, and the
container's own answer comes off the exception object. The **exit-1** receipt for that failure
lives where it is honest — `BreakAmbiguous`, which does not catch it (below).

The capture's own first line says the one thing this program silences:
`jul off  the container's own WARNING for the cancelled refreshes - a duplicate of the
exception printed below, plus a timestamp`. A cancelled refresh is logged through
`java.util.logging` with a timestamp, and that timestamp is the only token here that cannot be
reproduced; the same exception is printed below it, from the object that was caught. Where the
JUL record *is* the lesson it stays on screen with its timestamp chipped as varying.

## Why two rails and not a "primary" and a "fallback"

The kitchen rail cooks; the delivery rail carries. Both are `OrderQueue`, both are legitimately
wanted, and **neither is the default** — which is what gives the unit its tension. With a
default-and-fallback pair, `@Primary` looks obviously right and there is nothing to teach. Here
it is the weakest of the three answers, and the unit says so.

## Two failure receipts from one exception type, and the sentence tells you which rule you tripped

```
no tie-breaker
  exit 1 · org.springframework.beans.factory.NoUniqueBeanDefinitionException
  No qualifying bean of type 'com.tiffinbox.OrderQueue' available:
  expected single matching bean but found 2: kitchenRail,deliveryRail
  md5 f35033563f290b58e5c584c97a6c4e5a   (3/3)

@Primary on BOTH
  exit 1 · org.springframework.beans.factory.NoUniqueBeanDefinitionException
  No qualifying bean of type 'com.tiffinbox.OrderQueue' available:
  more than one 'primary' bean found among candidates: [kitchenRail, deliveryRail]
  md5 d906f4b6eeeafb368c86112d754ef230   (3/3)
```

Same type, two different sentences, thrown from two different methods
(`resolveNotUnique` and `determinePrimaryCandidate`). **The message names both candidates every
time**, which is why a failure outranks any success as evidence: no amount of misconfiguration
produces that sentence by accident.

## The answer most tutorials never mention

```
List<OrderQueue>.size()         2
Map<String, OrderQueue> keys    [deliveryRail, kitchenRail]
```

When you want all of them, ask for all of them. The `Map` key is the bean name, which is the
same name `@Qualifier` uses — one naming scheme, two uses.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project, for
`exercise/` and for `breaks/primary-on-both/`.

## Exercise

`exercise/` starts clean and `ContextReport` says:

```
  beans of type OrderQueue               2
    their names, sorted                  deliveryRail, kitchenRail
  List<OrderQueue> injected size         1
```

Two rails exist and the monitor is watching one. Nothing is logged. **End state:**
`List<OrderQueue> injected size  2`, md5 `c61a6dadf726bbdde4ee4131e4293169`, 3/3.
Answer in `exercise/solution/`.

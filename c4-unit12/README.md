# c4-unit12 — Aware interfaces, @Order and @DependsOn

Course 4 · Spring Framework Core · Section 2 "Lifecycle and Scope".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-19.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.WhatOrderOrders           # A / B / A' in one run
java -cp "target/classes:$(cat .cp)" com.tiffinbox.InvisibleOrder
java -cp "target/classes:$(cat .cp)" com.tiffinbox.AwareOrNot
java -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakDeclarationOrder     # exits 1, on purpose
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `StartupCheck.java` · `Checks.java` | the three things TiffinBox will not open without — power, water, gas — and the routine that runs them. `NoOrder` and `Ordered` differ by exactly three `@Order` tokens; the methods are in the same order in both |
| `WhatOrderOrders.java` | **A / B / A′ in one program, one JVM, one session**, and the unit stands on the two rows that do **not** move |
| `InvisibleOrder.java` | the order the container cannot work out because nothing says it: a seeder and a revenue board that never reference each other. Three configurations, one difference each |
| `AwareOrNot.java` | the same job done two ways, and the difference measured outside a container |
| `BreakDeclarationOrder.java` | the failure receipt, uncaught, exit 1 |
| `chain.py` | the `Caused by:`-chain filter, carried unchanged from Section 1 |
| `exercise/` | an opening routine that runs the checks in whatever order it was handed them |

## A / B / A′ — and `@Order` does not order what the internet says it orders

```
[A ] no @Order anywhere
  order the container BUILT them   [power, water, gas]
  order in the injected List       [power, water, gas]
  order getBeanNamesForType gives  [power, water, gas]
  @Order values on the definitions power=none  water=none  gas=none

[B ] @Order(3) @Order(1) @Order(2), methods NOT moved
  order the container BUILT them   [power, water, gas]
  order in the injected List       [water, gas, power]
  order getBeanNamesForType gives  [power, water, gas]
  @Order values on the definitions power=3  water=1  gas=2

[A'] no @Order anywhere, again
  order the container BUILT them   [power, water, gas]
  order in the injected List       [power, water, gas]
  order getBeanNamesForType gives  [power, water, gas]
  @Order values on the definitions power=none  water=none  gas=none
```

`.r-order{1,2,3}.out`, md5 `7c7d22f698d56c933373844e75567f8f`, exit 0, 3/3, 18 output lines.

**Four rows. One moves.**

- **`@Order` does not change the order the container builds things in.** `[power, water, gas]`
  in all three columns. Creation order followed the order the methods appear in the file, and
  three annotations saying otherwise changed nothing about it.
- **`@Order` does not change what `getBeanNamesForType` hands back.** Same three names, same
  order, all three columns.
- **What `@Order` sorts is the collection the container hands you** — the injected `List`, and
  that is the only row that moved.
- **`@Order values on the definitions` is the nothing-else-was-touched evidence.** It goes
  `none/none/none → 3/1/2 → none/none/none`, read off each definition's own factory method, so
  the B column proves the annotations really are there and A′ proves they really went away.

If you need a thing built before another thing, `@Order` is not the tool and it will not tell
you so. The tool is below.

## The order nothing in the code says, and the one annotation that says it

```
[1] seeder declared first, nothing written down
  built in this order    [seeder, revenueBoard]
  month revenue the board read   24300
  dependsOn recorded on revenueBoard  null

[2] ONE method moved down the file, nothing else
  built in this order    []
  refresh                REFUSED
  root of the chain      org.h2.jdbc.JdbcSQLSyntaxErrorException
  its first line         Table "CUSTOMER" not found (this database is empty); SQL statement:

[3] the same file, plus @DependsOn("seeder")
  built in this order    [seeder, revenueBoard]
  month revenue the board read   24300
  dependsOn recorded on revenueBoard  [seeder]
```

`.r-invis{1,2,3}.out`, md5 `48781cc74ed83b3c5b22b4bb876cc580`, exit 0, 3/3, 18 output lines,
through `chain.py`.

The revenue board reads through the repository. The seeder fills the database. **Neither
references the other**, so as far as the container can see they are unrelated and either may
be built first — and in case `[1]` the right thing happened for no reason anybody wrote down.
Move one method down the file and the application stops working.

`@DependsOn` is the only thing in this unit that changes creation order, and what it declares
is exactly the dependency the parameter list could not: *this bean needs that bean to have
happened*, where "happened" is a side effect rather than a value.

> **A measurement hazard worth recording, because the first version of this demo did not
> break.** All three cases originally shared one `jdbc:h2:mem:` URL, so case `[1]` seeded the
> database and case `[2]` read a table that was already there. The break silently did not
> break. Each case now has its own in-memory database. **A demo that shares state between its
> own cases is not three captures; it is one.**

## The failure receipt (contract §2e)

```
exit 1
org.springframework.beans.factory.BeanCreationException
Error creating bean with name 'revenueBoard' defined in com.tiffinbox.InvisibleOrder$BoardFirst: Failed to instantiate [com.tiffinbox.InvisibleOrder$RevenueBoard]: Factory method 'revenueBoard' threw exception with message: Table "CUSTOMER" not found (this database is empty); SQL statement:
```

`.r-decl{1,2,3}.out`, md5 `c77d25e7013e38eb6b44fe8aded183c9`, exit **1**, 3/3, 14 output lines,
through `chain.py`. The whole `Caused by:` chain is kept —
`BeanCreationException` → `BeanInstantiationException` → `JdbcSQLSyntaxErrorException` — with
the frames between elided and counted.

## Aware interfaces: what they cost, measured outside the container

```
inside a container
  ApplicationContextAware + BeanNameAware   reachesForTheContext -> power
  a constructor parameter                   handed -> power

the same two objects, constructed by hand — which is what a test does
  new IsHandedWhatItNeeds(new Power())      handed -> power
  new ReachesForTheContext().describe()     java.lang.NullPointerException

interfaces the container-reaching class had to implement  2
interfaces the constructor version had to implement       0
```

`.r-aware{1,2,3}.out`, md5 `cdc80b522b4d5055bf6a012f025f90d3`, exit 0, 3/3, 10 output lines.

Inside a container the two are indistinguishable. **Outside one, only the second is still an
object.** That is the whole argument, and it is not about style: an `*Aware* class cannot be
constructed and used without something to hand it a container, which means it cannot be
exercised without one either.

The `*Aware*` interfaces are not deprecated and they are not a mistake — the framework's own
infrastructure uses them constantly, because infrastructure genuinely does need the container.
Application beans almost never do. When you reach for one, the question to ask is whether a
constructor parameter would have done.

## The receipt

```
claims
  order the container BUILT them         [power, water, gas]
  order in the injected List             [water, gas, power]
  order getBeanNamesForType gives        [power, water, gas]
  @Order values on the definitions       power=3  water=1  gas=2
  checks the opening routine was handed  3
```

`cr` md5 `eba50e499cedbefeea0a45517ac2d719`, `crs` `6e73fe145121ec489f68dd02ed49995b`,
exit 0, 3/3 each, 19 output lines each.

The report **dies rather than print a confident answer** if it finds no `@Order` on any check:
a units-of-ordering receipt that quietly reports "no ordering" when the annotations have been
deleted is not a receipt. That guard is what the exercise's start state fires.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project and for
`exercise/`.

## Exercise

`exercise/` starts clean and `ContextReport` **exits 2**:

```
  order the container BUILT them         [power, water, gas]
  order in the injected List             [power, water, gas]
  order getBeanNamesForType gives        [power, water, gas]
ContextReport: no @Order found on any startup check, in the unit whose subject is @Order. …
```

The water has to be on before the gas, and the gas before the extractor fan. **End state:**
`order in the injected List  [water, gas, power]`, and the report exits 0. Answer in
`exercise/solution/`, run by the author: md5 `c3563e1797375c62fb496e1d64497e06`, exit 0, 3/3.
Start state md5 `be7d27bb8a0972dc09dea5396d1bdc39`, exit **2**, 3/3.

Note which row **does not move**: `order the container BUILT them` is `[power, water, gas]`
before and after. The fix changes the order things are *used* in, not the order they are
*made* in — and if what you needed was the second one, this exercise's answer is the wrong
tool and `@DependsOn` is the right one.

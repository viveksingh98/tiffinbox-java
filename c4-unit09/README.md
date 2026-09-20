# c4-unit09 — scopes and the injection trap

Course 4 · Spring Framework Core · Section 2 "Lifecycle and Scope".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-19.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.OneTripForEver            # A / B / A' in one run
java -cp "target/classes:$(cat .cp)" com.tiffinbox.OneTripForEver --stable   # the hashable form
java -cp "target/classes:$(cat .cp)" com.tiffinbox.WhatScopeSays
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `DeliveryRun.java` | one driver's trip out of the kitchen. Created when a van leaves, it accumulates the stops made on that trip, and it is finished when the van comes back. **Nothing about it is shareable** |
| `Dispatch.java` | the two desks, one difference, and the difference is at the **injection point** — `DeliveryRun run` against `ObjectProvider<DeliveryRun> runs` |
| `OneTripForEver.java` | **A / B / A′ in one program, one JVM, one session.** `--stable` masks through the same `mask()` the report advertises |
| `WhatScopeSays.java` | the two questions this unit has to answer before it can be believed: why the definition says `""` where the report says `singleton`, and what the configuration subclass does with a **prototype** method |
| `chain.py` | the `Caused by:`-chain filter, carried unchanged from Section 1 |
| `exercise/` | the same desk, and the task is the one in the course's style contract |

## A / B / A′ — one prototype, injected once

```
[A ] DeliveryRun run
  trip one == trip two                 true
  identityHashCode of the two          @<id>  @<id>
  stops on the object trip two returned [Ravi, Meera]
  scope in the definition              "prototype"   isSingleton=false
  the container is holding a singleton called deliveryRun  false

[B ] ObjectProvider<DeliveryRun> runs
  trip one == trip two                 false
  identityHashCode of the two          @<id>  @<id>
  stops on the object trip two returned [Meera]
  ...

[A'] DeliveryRun run
  trip one == trip two                 true
  ...
DeliveryRun objects this JVM constructed in total  4
```

Unmasked `.r-aba{1,2,3}.out`, md5 `65e4076f2a5fc48b8ccb9fa223c1bc32`, exit 0, 3/3, 25 output
lines. Masked `.r-abas{1,2,3}.out`, md5 `edbc34ba6fa9e687eda192c617b65ec5`, exit 0, 3/3.

**Three captures, one program, one JVM, one session.** A′ reproducing A is something you read
off the screen, not a hash comparison — the third run is the same program executed once more
and it costs nothing.

**The unmasked capture is 3/3 on this machine and that does not make it portable.** HotSpot's
default `identityHashCode` generator is a fixed-seed thread-local sequence, so a deterministic
single-threaded program reproduces its hash codes across JVM restarts; one JVM flag changes
every value. Only the masked form goes anywhere near a slide, and the mask is printed by the
program, every run, as its first line.

**The row that carries the lesson is not the `==`.** It is
`stops on the object trip two returned`: in case A the second trip's object already has the
first trip's stop on it, because it *is* the first trip's object. A boolean says the objects
are the same; that list says what being the same **does to your data**.

`scope in the definition "prototype"` is identical in all three columns. **Nothing about the
prototype changed.** The bean that was wrong was the singleton holding it, and the fix is at
the injection point.

## Why this is the course's cleanest instance of its own rule

The context starts. Nothing is logged. `beans(app)` is right, the scope in the definition is
right, `isSingleton` is `false`, and `getBeanNamesForType` finds exactly the bean you declared.
**Every check a working developer would reach for reports that the configuration is correct.**
The only thing that finds it is an identity across two calls.

## Two answers Section 1 left looking contradictory, reconciled

```
what the DEFINITION says, and what the CONTAINER answers
  oneForEver   getScope()=""           isSingleton()=true   isPrototype()=false
  onePerTrip   getScope()="prototype"  isSingleton()=false  isPrototype()=true
```

The definitions unit printed `scope=(default)` for a bean the report called `singleton`, and
both were right: **`getScope()` returns the empty string when nobody named a scope**, and
`isSingleton()` is the container resolving that empty string. One is what you wrote; the other
is what it means.

```
the configuration subclass, asked the same question twice
  singleton method called twice -> same object true  |  prototype method called twice -> same object false
  the class holding those methods   com.tiffinbox.WhatScopeSays$Config$$SpringCGLIB$$0
```

`.r-scope{1,2,3}.out`, md5 `13b6f83c733fa5d367299ae6ce5cf83f`, exit 0, 3/3, 9 output lines.

The configuration unit drew the generated subclass with one arrow labelled **"already have
one"**, and that arrow is drawn unconditionally. **It is true for a singleton and false for a
prototype.** The subclass does not cache; it asks the container, and the container's answer
depends on the scope. A viewer who memorised that diagram has to be told this here, on screen,
rather than finding it out in production.

## The three ways out, and what each costs

| | what you write | what it costs |
|---|---|---|
| `ObjectProvider<T>` | a parameter type | your class now names a Spring type. It is an interface, it is trivially faked in a test, and it is the one this unit teaches |
| a lookup method | an abstract method plus an annotation | the container has to **subclass your class** to implement it, which brings in every limit a generated subclass has. Named here, not taught — the mechanism belongs to the section that owns generated classes |
| asking the context | a field and a `getBean` call | your class now needs a container to do its job at all, which is the trade the unit on ordering measures |

## The receipt

```
beans(app)=3
  deliveryRun   prototype  com.tiffinbox.DeliveryRun  (not built)   factory=@Bean  lazy=false
  ...
claims
  deliveryRun scope in the definition    "prototype"  isSingleton=false
  container holds a singleton for it     false
  trip one == trip two                   true
  stops on the object trip two returned  [Ravi, Meera]
  DeliveryRun objects this JVM built     1
  prototype definitions in this context  1
```

`cr` md5 `24ad0cbb3408c8c87bf52fd0accf3c63`, `crs` `d768b6dd575b052ef7cd08916acc76a3`,
exit 0, 3/3 each, 18 output lines each.

**The `(not built)` marker is load-bearing in this unit and it was not put there for this
unit.** It exists because the report must not instantiate what it is reporting on — a rule the
report learned the hard way one section ago. A prototype is *never* in the singleton store, so
the marker is not saying "nobody has asked yet"; it is saying **there is no such object for the
container to be holding, and there never will be**. The report reads its class through
`getType(name)` and says so.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project and for
`exercise/`.

## Exercise

`exercise/` starts clean and `ContextReport` says `trip one == trip two  true`.
**End state:** `false`, **without touching `DeliveryRun.java`**. Answer in
`exercise/solution/`, run by the author: md5 `71d6239595120ccb5613d5f73c3b28cd`, exit 0, 3/3.
Start state md5 `c0c9f10c3793544bfb774fa624110030`, exit 0, 3/3.

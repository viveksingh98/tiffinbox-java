# c4-unit10 — circular dependencies: bandage and cure

Course 4 · Spring Framework Core · Section 2 "Lifecycle and Scope".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-19.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.FourAnswers        # five cases, one JVM
java -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakTheCycle      # exits 1, on purpose
java -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakTheCycle > .r-cyc1.raw 2>&1 ; python3 chain.py .r-cyc1.raw
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `Cycle.java` | the billing desk and the delivery desk, in four wirings: both through constructors, one side `@Lazy`, both through setters, and the cure |
| `FourAnswers.java` | all of it in one JVM, so "it starts" and "it is fixed" are visibly different claims. Includes `[3b]`, the same setter cycle with one switch flipped on the container |
| `BreakTheCycle.java` | the failure receipt, **uncaught**, so the exit code is the container's and the whole `Caused by:` chain is on screen |
| `chain.py` | the `Caused by:`-chain filter, carried unchanged from Section 1. Keeps every `Caused by:` line plus the first frame under each and **derives** every elision count |
| `exercise/` | two desks that point at each other and a context that starts anyway |

## Five answers to one cycle

```
[1] both sides through the constructor
  refresh                 REFUSED
  thrown                  org.springframework.beans.factory.UnsatisfiedDependencyException
  root of the chain       org.springframework.beans.factory.BeanCurrentlyInCreationException
  its first line          Error creating bean with name 'billingDesk': Requested bean is currently in creation: Is there an unresolvable circular reference or an asynchronous initialization dependency?

[2] one side marked @Lazy
  refresh                 started
  billingDesk.getClass()  com.tiffinbox.Cycle$BillingDesk
  what is IN its field    com.tiffinbox.Cycle$DeliveryDesk$$SpringCGLIB$$0
  beans in the cycle      deliveryDesk->billingDesk

[3] one side through a setter
  refresh                 started
  its setter field == the other bean   true
  and that one points back at this one true
  beans in the cycle      setterBilling->setterDelivery  setterDelivery->setterBilling

[4] the cure: extract what both of them wanted
  refresh                 started
  beans in the cycle      billing->tariff  delivery->tariff

[3b] the same setter cycle, with setAllowCircularReferences(false)
  the default this container ships with   isAllowCircularReferences=true
  refresh                 REFUSED
  root of the chain       org.springframework.beans.factory.BeanCurrentlyInCreationException
```

`.r-four{1,2,3}.out`, md5 `485fe74d1aa55173d42188747bdadbc8`, exit 0, 3/3, 36 output lines,
through `chain.py`.

## What "Spring refuses circular references by default" actually means, measured

```
the default this container ships with   isAllowCircularReferences=true
```

**Spring Framework 7.0.9 does not refuse circular references by default.** What refuses is a
**constructor** cycle, and it refuses because it structurally cannot be resolved: neither
object can be constructed without the other already existing. A **setter** cycle starts
perfectly on the shipped defaults — case `[3]` above — and the two beans really do point at
each other, proved both directions in one capture.

The switch that refuses it is `setAllowCircularReferences(false)`, and it is a property of
**the container you are holding**, not of the framework. Flipped, the same setter cycle gives
the same `BeanCurrentlyInCreationException` the constructor cycle gave.

## The failure receipt (contract §2e), and the whole chain

```
exit 1
org.springframework.beans.factory.UnsatisfiedDependencyException
Error creating bean with name 'billingDesk' defined in com.tiffinbox.Cycle$BothConstructors: Unsatisfied dependency expressed through method 'billingDesk' parameter 0: …
```

`.r-cyc{1,2,3}.out`, md5 `cfe3d5c6ea00db75182abbf7d591c167`, exit **1**, 3/3, 10 output lines,
through `chain.py`. Its raw form gives **2 distinct values** across three runs, because a
cancelled refresh is logged through `java.util.logging` first and that record carries a
timestamp — so the hash is over the filtered form, and the filter names and counts what it
removed:

```
... 2 log lines elided: the container's own timestamped record of the cancelled refresh, which this capture already carries as the exception ...
Exception in thread "main" org.springframework.beans.factory.UnsatisfiedDependencyException: …
	at org.springframework.beans.factory.support.ConstructorResolver.createArgumentArray(ConstructorResolver.java:804)
	... 16 frames elided ...
Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: …
	at org.springframework.beans.factory.support.ConstructorResolver.createArgumentArray(ConstructorResolver.java:804)
	... 15 frames elided ...
Caused by: org.springframework.beans.factory.BeanCurrentlyInCreationException: Error creating bean with name 'billingDesk': Requested bean is currently in creation: Is there an unresolvable circular reference or an asynchronous initialization dependency?
	at org.springframework.beans.factory.support.DefaultSingletonBeanRegistry.beforeSingletonCreation(DefaultSingletonBeanRegistry.java:541)
	... 9 frames elided ...
```

**Three links, and the useful one is the third.** The first line names a bean; the last names
the shape. Cropping this to its own first eight lines throws away the only sentence in it that
says what went wrong.

## `@Lazy` is a bandage, and here is the bandage

```
  billingDesk.getClass()  com.tiffinbox.Cycle$BillingDesk
  what is IN its field    com.tiffinbox.Cycle$DeliveryDesk$$SpringCGLIB$$0
```

The class you hold is the class you wrote. **The class inside its field is not.** `@Lazy` at an
injection point does not break the cycle — it defers one side of it by putting a stand-in
object in the field, so the container's own dependency record now shows only one arrow
(`deliveryDesk->billingDesk`) while your objects still point at each other. The graph looks
acyclic and the cycle is still there. That is precisely what a bandage is.

The generated class name is masked in any hashed capture and is never read aloud as a fact;
what it says out loud is *the class in that field is not the one you wrote*. What that stand-in
can and cannot do is the aspects section's subject, and this unit does not open it.

## "Setter injection also works" — what it gives up

Case `[3]` starts. It is also the case where the injection unit's verdict still stands: a
setter-injected field cannot be `final`, and there is a window in which the object exists and
the field does not. So "it works" buys you a started context at the cost of the one guarantee
that made constructor injection worth preferring. **It is not a fix. It is a different set of
risks, chosen silently.**

## The cure, as a property of the graph

```
claims
  beans that point back at something pointing at them 0
  billing and delivery hold the SAME tariff true
  billing.billFor("Ravi")                340
  delivery.chargeFor("Ravi")             40
  what tariff depends on                 [cycle.Cured]
```

`cr` md5 `2bb145b0e5f4f95db8c0f8ab7af92b22`, `crs` `f4cbd5dc3c67408c2288520fee4f9fa4`,
exit 0, 3/3 each, 18 output lines each.

The count is derived off the container's own dependency bookkeeping, not off a diagram: a bean
is in a cycle when something it depends on depends on it back. **Zero** is the receipt, and the
two desks never wanted each other — they wanted the numbers.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project and for
`exercise/`. **The exercise's cycle builds and verifies green.** The failure is not in the
build; it is in the graph, and in this unit it is not even a failure.

## Exercise

`exercise/` starts clean and `ContextReport` says
`beans that point back at something pointing at them  2`.
**End state:** `0`, with `billFor("Ravi")` still `340`. Answer in `exercise/solution/`, run by
the author: md5 `86a543695b63b5a65c753adf4d764440`, exit 0, 3/3. Start state md5
`a9a20ff4335e9f3f3d304c5d0ceb3d92`, exit 0, 3/3.

Note which row **does not move**: the bill is `340` in both states. The application was never
wrong. That is why nothing told you.

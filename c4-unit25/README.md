# Unit 25 — The Event Publisher: Delete a Dependency

Course 4 · Section 5 · *Events, Async and Scheduling*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates everything and **asserts** each claim below.

## Before — a dependency that feels necessary

`java -cp "$CP" com.tiffinbox.Coupled` · md5 `22ca3bd26bea8d49f57f741e13872f7e`

```
  [kitchen] cooking for Ravi
  [sms    ] your order is in, Ravi
  beans kitchen depends on (yours): [smsNotifier]   (Spring's own: [], 1 configuration class excluded)
```

The kitchen holds the SMS notifier and calls it — so every new reaction to an order (a receipt, loyalty points)
means editing the kitchen again. (It can still be tested with a stub; Course 3 showed how. The cost is what the
kitchen has to know, not whether it can be tested.)

## After — the edge deleted

`java -cp "$CP" com.tiffinbox.Decoupled` · md5 `d763074f735a46491ff207b0a7d087fb`

```
  [kitchen] cooking for Ravi  (on main)
  [receipt] Ravi owes 340  (on main)
  (on main)  [sms    ] your order is in, Ravi
  [kitchen] publish returned
  beans kitchen depends on (yours): []   (Spring's own: [org.springframework.context.annotation.AnnotationConfigApplicationContext@<id>], 1 configuration class excluded)
```

The field, the constructor parameter and every mention of `SmsNotifier` are gone from `Kitchen` (asserted:
0 mentions). The kitchen publishes an `OrderPlaced` — **a plain record, no framework base class** — and the
container's own dependency record shows the edge gone (`[smsNotifier]` → `[]`, asserted). **One edge remains, and it
is Spring's own: the application context itself**, handed to the kitchen as its `ApplicationEventPublisher`
(asserted). `Edges` reads injected dependencies only — a `ctx.getBean(...)` lookup inside the kitchen would
not show up — which is why the unit also counts `SmsNotifier` mentions in the class.

**And it is synchronous.** Every listener runs on `main` **before** `publish returned` (asserted): the
publisher waits for all of them.

## The break — a listener you did not write can fail your order

`java -cp "$CP" com.tiffinbox.Decoupled break` · md5 `562ad4789f54bff75f0f18869058bc91`

```
an order for nobody:
  [kitchen] cooking for nobody  (on main)
  [receipt] nobody owes 340  (on main)
  [caller ] got IllegalStateException: receipt printer refused nobody
```

The receipt listener throws, **the exception reaches the kitchen's caller**, and the SMS listener after it
**never runs** (both asserted). Deleting the dependency did not delete the coupling of failure.

## The remedy — one bean

`java -cp "$CP" com.tiffinbox.Decoupled handled` · md5 `d995ef4acbdefe3b63be9ad0841ca9dc`

```
  [kitchen] cooking for nobody  (on main)
  [receipt] nobody owes 340  (on main)
  [handler] a listener failed: receipt printer refused nobody
  (on main)  [sms    ] your order is in, nobody
  [kitchen] publish returned
  [caller ] no exception
```

A bean named `applicationEventMulticaster` — a `SimpleApplicationEventMulticaster` with an error handler —
turns a failing listener into a handled report: the SMS still goes out and the caller sees no exception
(asserted). Whether you *want* that is a decision: now nobody upstream hears about the refused receipt unless
the handler tells them.

## Files

`OrderPlaced` · `SmsNotifier` · `Coupled` · `Decoupled` · `Edges` · `jul.sh` · `receipts.sh` · `exercise/`

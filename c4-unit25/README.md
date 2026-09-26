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

`java -cp "$CP" com.tiffinbox.Coupled` · md5 `229b9d97f594d65f52e45484c42e61a6`

```
  [kitchen] cooking for Ravi
  [sms    ] your order is in, Ravi
  beans kitchen depends on (yours): [smsNotifier]   (0 of Spring's own, 1 configuration class excluded)
```

The kitchen holds the SMS notifier and calls it. It cannot be built, tested or changed without a phone gateway.

## After — the edge deleted

`java -cp "$CP" com.tiffinbox.Decoupled` · md5 `3bff238a3a923899163539000b21b06d`

```
  [kitchen] cooking for Ravi  (on main)
  [receipt] Ravi owes 340  (on main)
  (on main)  [sms    ] your order is in, Ravi
  [kitchen] publish returned
  beans kitchen depends on (yours): []   (1 of Spring's own, 1 configuration class excluded)
```

The field, the constructor parameter and every mention of `SmsNotifier` are gone from `Kitchen` (asserted:
0 mentions). The kitchen publishes an `OrderPlaced` — **a plain record, no framework base class** — and the
container's own dependency record shows the edge gone (`[smsNotifier]` → `[]`, asserted).

**And it is synchronous.** Every listener runs on `main` **before** `publish returned` (asserted): the
publisher waits for all of them.

## The break — a listener you did not write can fail your order

`java -cp "$CP" com.tiffinbox.Decoupled break` · md5 `5ec6f0f73f9dc0f3a702efd631241902`

```
an order for nobody:
  [kitchen] cooking for nobody  (on main)
  [receipt] nobody owes 340  (on main)
  [caller ] got IllegalStateException: receipt printer refused nobody
```

The receipt listener throws, **the exception reaches the kitchen's caller**, and the SMS listener after it
**never runs** (both asserted). Deleting the dependency did not delete the coupling of failure.

## Files

`OrderPlaced` · `SmsNotifier` · `Coupled` · `Decoupled` · `Edges` · `jul.sh` · `receipts.sh` · `exercise/`

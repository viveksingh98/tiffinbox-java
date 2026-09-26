# Unit 26 — Conditional, Ordered and Async Listeners

Course 4 · Section 5 · *Events, Async and Scheduling*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates everything and **asserts** each claim below.

## The break — the documentation's first example

`java -cp "$CP" com.tiffinbox.Conditions` · md5 `e30587dd8e36492fc579c2237a2eedb5`

```
  parameter names for reflection (-parameters)? false
  the name e in the class file's debug table?   true
  Spring 7's reader of that debug table present? false
  ByName   total 900  -> SpelEvaluationException: EL1007E: Property or field 'total' cannot be found on null
  ByName   total 340  -> SpelEvaluationException: EL1007E: Property or field 'total' cannot be found on null
  ByA0     total 900  -> ran
  ByA0     total 340  -> did not run
  ByArgs   total 900  -> ran
  ByArgs   total 340  -> did not run
  ByEvent  total 900  -> ran
  ByEvent  total 340  -> did not run
```

`condition = "#e.total > 500"` names the parameter. **Maven does not pass `-parameters` by default**, so the
name is not available to reflection. It **is** in the class file — in the debug table (`LocalVariableTable`),
read here with Spring's own ASM — but the class that read that table,
`LocalVariableTableParameterNameDiscoverer`, is gone from Spring 7. `receipts.sh` counts it: **1** entry in
`spring-core` 6.0.23, **0** in 6.1.0 (`.r-reader-since.out`). So since 6.1, `#e` is null and the condition
**throws on every publish** — even the one it should simply skip. `#a0`, `#root.args[0]` and
`#root.event.payload` work regardless; the reference documentation says so too, in the same table.
*(Corrected 2026-09-26 after the section's RED review: this README first said the name was not in the class
file at all.)*

**B — the same sources compiled with `-parameters`** (`.params/`, the build setting Spring Boot turns on) ·
md5 `43c00512b829766289dce40aeccf964c`: `ByName total 900 -> ran`, `total 340 -> did not run` (asserted). The plain build
above is A and A′.

## @Order — the same annotation, a different list

`java -cp "$CP" com.tiffinbox.Ordered` · md5 `157c5bef41dfad9d87ca7d821cea2c61`

```
  run 1: sms loyalty receipt
  run 2: sms loyalty receipt
  run 3: sms loyalty receipt
  without @Order: receipt sms loyalty
```

`sms loyalty receipt` in 3 of 3 runs (asserted), whatever order the methods are written in — the same rule
that sorted an injected list in the lifecycle section. **Without `@Order`** the same three listeners ran
`receipt sms loyalty` (asserted: not the numbered sequence) — whatever this build happened to do; nothing
promises it.

## @Async on a listener — observed

`java -cp "$CP" com.tiffinbox.AsyncListener` · md5 `3ab2fbba1a13d71b7c02a38fc33f03c1`

```
  publishing on main
  [sync ] on main
INFO: No task executor bean found for async processing: no bean of type TaskExecutor and no bean named 'taskExecutor' either
  publish returned
  [async] on SimpleAsyncTaskExecutor-<n>   (after publish returned)
an async listener throws:
  [sync ] on main
  publish returned - the caller never heard
  [async] on SimpleAsyncTaskExecutor-<n>   (after publish returned)
SEVERE: Unexpected exception occurred invoking async method: public void com.tiffinbox.AsyncListener$Listeners.async(com.tiffinbox.OrderPlaced) throws java.lang.InterruptedException
java.lang.IllegalStateException: async listener refused nobody
```

`@Async` needs a second annotation: `@EnableAsync` on the configuration. **Without it**
(`AsyncListener noenable` · md5 `c309a34badd5984c0ca1d7aae8adb96e`) the "async" listener runs on `main`, **before**
`publish returned`, and nothing is logged (asserted):

```
  @Async on the listener, but NO @EnableAsync on the configuration:
  publishing on main
  [sync ] on main
  [async] on main   (BEFORE publish returned - it ran synchronously)
  publish returned
```

With it, the async listener runs on `SimpleAsyncTaskExecutor-<n>` **after** `publish returned` — made deterministic
with a latch, not a sleep, so the order is a fact and not a race. When it throws, the **caller never hears**;
Spring logs it at `SEVERE`. Ignorable, not silent. Configuring that executor is the next unit.

## Files

`OrderPlaced` · `Conditions` · `Ordered` · `AsyncListener` · `jul.sh` · `receipts.sh` · `exercise/`

**Named, not covered here:** `@TransactionalEventListener` — a listener that runs only after the publishing
transaction commits. It needs transactions, which arrive with the data courses.

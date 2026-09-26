# Unit 26 — Conditional, Ordered and Async Listeners

Course 4 · Section 5 · *Events, Async and Scheduling*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates everything and **asserts** each claim below.

## The break — the condition the documentation uses

`java -cp "$CP" com.tiffinbox.Conditions` · md5 `dc5bc2beca259e4816ca8f44473f8bde`

```
  parameter names in the class file (-parameters)? false
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
name is not in the class file, `#e` is null, and the condition **throws on every publish** — even the one it
should simply skip. `#a0`, `#root.args[0]` and `#root.event.payload` work regardless. Spring Boot turns
`-parameters` on for you, which is why tutorials "just work"; this course has no Boot.

## @Order — the same annotation, a different list

`java -cp "$CP" com.tiffinbox.Ordered` · md5 `c51a4c67871bdd24f5869838f2609057` — `sms loyalty receipt` in 3 of 3 runs
(asserted), whatever order the methods are written in. The same rule that sorted an injected list in the
lifecycle section.

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

The async listener runs on `SimpleAsyncTaskExecutor-<n>` **after** `publish returned` — made deterministic
with a latch, not a sleep, so the order is a fact and not a race. When it throws, the **caller never hears**;
Spring logs it at `SEVERE`. Ignorable, not silent. Configuring that executor is the next unit.

## Files

`OrderPlaced` · `Conditions` · `Ordered` · `AsyncListener` · `jul.sh` · `receipts.sh` · `exercise/`

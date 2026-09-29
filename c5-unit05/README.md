# c5-unit05 — @Conditional and the Condition Evaluation Report

Course 5 · Spring Boot · Section 1 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-29.
Runs TiffinBox as the previous unit left it: `receipts.sh` copies `../c5-unit04/after` into `.harness/anchor` and builds it
there, so it never writes into another unit's folder, and nothing in the anchor changes. The two beans this unit adds
live in `harness/demo/`, outside `com.tiffinbox`, so TiffinBox's own scan never sees them.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # 5 captures, 3 runs each; every number the video says is asserted; a published-md5 mismatch stops it
```

The build tries `mvn -o` first (this unit's `.m2-demo`) and resolves from Maven Central only if that fails.

## The commands — whole, as the video shows them, port first

- **TiffinBox's own jar**, run in TiffinBox's folder: `java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18551 --debug`.
  TiffinBox's `main` still copies `args[0]` into `tiffinbox.port`, so Boot's flag goes **after** the port — with `--debug`
  first, `main` tries to read `--debug` as the port and the JVM exits 1 (`NumberFormatException`).
- **The harness**: `java -cp "$CP" com.tiffinbox.harness.Conditions <port> <setup> [Boot flags…]`, setup `plain` (TiffinBox
  in a plain Spring context, as the last course ran it), `boot` (under Boot, as the last video left it) or `kitchen` (`boot`
  plus `demo.KitchenExecutorConfig`). After `./receipts.sh`: `CP=".harness/classes:$(cat .harness/classpath)"`. Every
  setup adds `demo.AsyncKitchenConfig` — `@EnableAsync` and one `@Async` bean reached through an interface — and prints
  which `Executor` beans exist, the `@Async` bean's class, and where twenty `@Async` calls ran.
- **Ports** 18551-18559 (contract §R.10): 18551 the jar · 18552 A and A′ · 18553 B · 18554 C · 18555 D · 18556 E ·
  18557 B's report · 18558 the misspellings · 18559 the exercise. Runs are sequential; nothing else uses these ports.

## Masks — `sub`/`gsub` only, never an awk field reassigned

1. Boot's log prefix (time, level, pid, thread, logger) is cut with `sub()` before a message that is **kept**: the `line N`
   rows of `report`, and the `INFO  No task executor bean found …` line in `backoff` and `defaults`.
2. The two durations in `Started TiffinBoxServer in … seconds (process running for …)` become `<s>` (`gsub`).
3. `-XX:+PrintFlagsFinal`'s column padding is squeezed to single spaces (`gsub`) in `defaults`.
4. Thread names: the harness prints a name's trailing number as `#` (`String.replaceAll`) — the claim is the name's shape
   and the count of distinct threads, never which number a thread got.
5. Every other log line is dropped and counted on the capture's own line (`… N log line(s) elided …`); a long line is
   cut after a marker with the rest counted on it (`… [+N chars]`).

## 1 · The report, and why nine of the file's twelve

(`.r-report.out` `5a2b47e0a707a34ee41db395d3c8beb4`)

```
$ java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --debug
exit 1 · Caused by: java.lang.NumberFormatException: For input string: "--debug"
$ java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18551 --debug
line 17   TiffinBox listening on http://127.0.0.1:18551
line 22   CONDITIONS EVALUATION REPORT
line 159  Started TiffinBoxServer in <s> seconds (process running for <s>)
the report's 4 lists: positive matches 15 · negative matches 13 · exclusions 0 · unconditional classes 6
the file's 12 classes, as the report files them (each name without "AutoConfiguration"):
  unconditional 6  ApplicationAvailability ConfigurationProperties Lifecycle ProjectInfo PropertyPlaceholder Ssl
  matched       3  Aop TaskExecution TaskScheduling
  did not match 3  Jmx MessageSource SpringApplicationAdminJmx
  registered    9  = the unconditional ones + the ones that matched
  do these three groups name exactly the file's classes? yes
a default Boot flips, in the report's own words:
   AopAutoConfiguration.ClassProxyingConfiguration matched:
      - @ConditionalOnMissingClass did not find unwanted class 'org.aspectj.weaver.Advice' (OnClassCondition)
      - @ConditionalOnBooleanProperty (spring.aop.proxy-target-class=true) matched (OnPropertyCondition)
POST /shutdown -> {"stopping":true} · exit 0
```

The report is logged as the context finishes starting — after TiffinBox's `@PostConstruct` has opened the server — and
before `Started`. It keeps four lists. Its own **Unconditional classes** list answers the question the last video left:
of the twelve classes the imports file names, **6 carry no class-level condition** and always register, **3 matched**
their conditions, **3 did not** — 6 + 3 is the 9 registered. Course 4's "most of them guarded by conditions" is, for
this file, **half** (the receipts check that the three groups name exactly the file's twelve). Some of the six unconditional
classes still guard individual beans (`ApplicationAvailabilityAutoConfiguration#applicationAvailability` is a positive
match of its own): "unconditional" is about the class. And the report states a default Course 4 published the other
way: class-based proxies, `spring.aop.proxy-target-class=true`, matched because nobody set it.

## 2 · One bean of yours — A, B, C, A′

(`.r-backoff.out` `118289f432e4c9bc0f857490325c5c12`)

```
A   Boot alone
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18552 boot
Executor beans: applicationTaskExecutor (a ThreadPoolTaskExecutor, core pool size 8)
@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 8 threads, named task-#
… 7 log line(s) elided …
B   plus one Executor bean of yours
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18553 kitchen
Executor beans: kitchenExecutor (a ThreadPoolExecutor, core pool size 3)
INFO  No task executor bean found for async processing: no bean of type TaskExecutor and no bean named 'taskExecutor' either
@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 20 threads, named SimpleAsyncTaskExecutor-#
… 7 log line(s) elided …
C   plus --spring.task.execution.mode=force
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18554 kitchen --spring.task.execution.mode=force
Executor beans: applicationTaskExecutor (a ThreadPoolTaskExecutor, core pool size 8), kitchenExecutor (a ThreadPoolExecutor, core pool size 3)
@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 8 threads, named task-#
… 7 log line(s) elided …
A′  A, re-run
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18552 boot
Executor beans: applicationTaskExecutor (a ThreadPoolTaskExecutor, core pool size 8)
@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 8 threads, named task-#
… 7 log line(s) elided …
```

**A** Boot alone: Boot's pool, core 8; twenty `@Async` calls share eight `task-` threads. **B** one plain `Executor` bean
of yours (a pool of three): Boot's pool backs off — and `@Async` does not use yours either. Twenty calls get twenty
brand-new `SimpleAsyncTaskExecutor` threads, plain Spring's default, and Spring says why in one INFO line: it looks for a
bean of type `TaskExecutor`, or a bean named `taskExecutor`, and `kitchenExecutor` is neither. (In A, `@Async` reaches
Boot's pool through an `AsyncConfigurer` Boot registers — A's report lists
`TaskExecutorConfigurations.AsyncConfigurerConfiguration matched` — and that sits inside the configuration that backs
off in B, so it goes with the pool.) **C** `--spring.task.execution.mode=force`, the report's other branch: both executors,
and `@Async` is back on Boot's eight threads. **A′** is A re-run — the same command, the same lines (`receipts.sh`
compares the two blocks line for line).

## 3 · Two defaults Boot flips — D plain Spring, E two processors

(`.r-defaults.out` `1aed37f9d2c48169eb50154e009a44fd`)

```
D   plain Spring, no Boot: TiffinBox as the last course ran it
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18555 plain
Executor beans: none
INFO  No task executor bean found for async processing: no bean of type TaskExecutor and no bean named 'taskExecutor' either
@Async bean: JDK proxy · 20 calls ran on 20 threads, named SimpleAsyncTaskExecutor-#
… 8 log line(s) elided …
E   Boot alone, on a JVM told it has two processors
$ java -XX:ActiveProcessorCount=2 -cp "$CP" com.tiffinbox.harness.Conditions 18556 boot
Executor beans: applicationTaskExecutor (a ThreadPoolTaskExecutor, core pool size 8)
@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 8 threads, named task-#
… 7 log line(s) elided …
that JVM's flag, as it read it: int ActiveProcessorCount = 2 {product} {command line}
Boot's own metadata: spring.task.execution.pool.core-size defaults to 8 · spring.task.execution.thread-name-prefix to task-
```

**D** is TiffinBox in a plain Spring context (Course 4's `TiffinBoxApp` without the `@EnableAutoConfiguration` Course 5
added): no executor bean at all, the `@Async` interface bean gets the JDK's proxy, and twenty calls get twenty new
threads. Under Boot (A) the same bean is a CGLIB subclass and the calls share a pool of eight. **E** tells the JVM it has
two processors: still core 8 — a fixed default (Boot's own metadata file says `defaultValue` 8), not the processor count.

## 4 · The report says why

(`.r-why.out` `fd4a1911fd998c73fe076cceb0d2ecf4`)

```
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18557 kitchen --debug
the report's 4 lists: positive matches 12 · negative matches 12 · exclusions 0 · unconditional classes 6
   TaskExecutorConfigurations.TaskExecutorConfiguration:
      Did not match:
         - AnyNestedCondition 0 matched 2 did not; NestedCondition on TaskExecutorConfigurations.OnExecutorCondition.ModelCondition @ConditionalOnProperty (spring.task.execution.mode=force) did not find property 'spring.task.execution.mode'; NestedCondition on TaskExecutorConfigurations.OnExecutorCondition.ExecutorBeanCondition @ConditionalOnMissingBean (types: java.util.concurrent.Executor; SearchStrategy: all) found beans of type 'java.util.concurrent.Executor' kitchenExecutor … [+49 chars]
```

The back-off is not a plain `@ConditionalOnMissingBean` in 4.1.1: it is `AnyNestedCondition` — two branches, either
would do: `spring.task.execution.mode=force`, or no `Executor` bean of yours. Neither held. The line is cut **after
`kitchenExecutor`**, so both branches — and the bean the second one found — are on screen; the counted tail is
` (TaskExecutorConfigurations.OnExecutorCondition)`.

## 5 · The break — three misspellings

(`.r-typos.out` `4c6a33148adc195adeb3108fdc04719a`)

```
1   a wrong VALUE, on a key a class binds to a type
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18558 kitchen --spring.task.execution.mode=forced
exit 1 · Boot's failure report (its Description and Action, blank lines dropped):
  Failed to bind properties under 'spring.task.execution.mode' to org.springframework.boot.autoconfigure.task.TaskExecutionProperties$Mode:
      Property: spring.task.execution.mode
      Value: "forced"
      Origin: "spring.task.execution.mode" from property source "commandLineArgs"
      Reason: failed to convert java.lang.String to org.springframework.boot.autoconfigure.task.TaskExecutionProperties$Mode (caused by … [+134 chars]
  Action:
  Update your application's configuration. The following values are valid:
      AUTO
      FORCE
    the same kind of mistake, where a @Value field converts the value:
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18558 boot --tiffinbox.days=thirty
exit 1 · Caused by: org.springframework.beans.TypeMismatchException: Failed to convert value of type 'java.lang.String' to required type 'int'; For input string: "thirty"
2   a wrong KEY
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18558 kitchen --spring.task.execution.mod=force
exit 0 · WARN lines 0 · Executor beans: kitchenExecutor (a ThreadPoolExecutor, core pool size 3)
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18558 kitchen --spring.task.execution.mod=force --debug
its report names the key you typed on 0 lines · the key you meant: did not find property 'spring.task.execution.mode'
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18558 kitchen --debug
the report with the typo: md5 e90bc664eeb26e98ad4af01e6b79eaff · without it: md5 e90bc664eeb26e98ad4af01e6b79eaff
3   a wrong VALUE, on a key no class binds
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18558 boot --spring.aop.proxy-target-class=ture
exit 0 · WARN lines 0 · @Async bean: JDK proxy · 20 calls ran on 8 threads, named task-#
$ java -cp "$CP" com.tiffinbox.harness.Conditions 18558 boot --spring.aop.proxy-target-class=ture --debug
its report: @ConditionalOnBooleanProperty (spring.aop.proxy-target-class=true) found different value in property 'spring.aop.proxy-target-class' (OnPropertyCondition)
which class binds each key - the sourceType in Boot's own metadata files:
  spring.task.execution.mode      TaskExecutionProperties
  spring.aop.proxy-target-class   none
```

1. **A wrong value where something converts it** is loud: `TaskExecutionProperties` — a properties class, one Boot fills
   from your settings — binds `spring.task.execution.mode` to an enum, and Boot's failure report names the property, the
   value, its origin and the valid values. A `@Value` field that converts to `int` is just as loud
   (`--tiffinbox.days=thirty`, exit 1): the rule is *converted*, not *bound by `@ConfigurationProperties`*.
2. **A wrong key** is silent: exit 0, no warning, Boot's pool still out. The report of that run is byte for byte the
   report without the typo (the two md5s above); it says the key you meant is missing and never names the key you typed.
3. **A wrong value on a key no class binds** is silent too: `spring.aop.proxy-target-class=ture` exits 0 with no warning,
   and the `@Async` bean is a JDK proxy again. A condition compares the text (`found different value`), nothing converts
   it, and Boot's own metadata files give that key no `sourceType` — no class binds it.

## Exercise

`exercise/README.md` — B starts and is wrong: make twenty `@Async` calls run on the kitchen's three threads, changing only
`exercise/demo/KitchenExecutorConfig.java`. Three answers, each run with the README's commands exactly as written, in
`exercise/solution/`.

## Found on the way

- `harness/demo/KitchenExecutorConfig` was first called `KitchenExecutor`. Boot refused to start: the configuration class
  was itself a bean named `kitchenExecutor`, and so was its `@Bean` method — *"A bean with that name has already been
  defined and overriding is disabled"*. Plain Spring allows overriding by default and would have let the second definition
  replace the first silently; Boot turns it off (`spring.main.allow-bean-definition-overriding=false`). Not captured by
  `receipts.sh` — a note from building the harness, not a claim the video makes.
- Wrapping the kitchen's pool in Spring's `TaskExecutorAdapter` does route the `@Async` calls to it — and the JVM then never
  exits: `TaskExecutorAdapter` has no `close()` or `shutdown()`, so its three threads outlive the context (measured: the
  run had to be killed, exit 143). `exercise/solution/typed/` uses a `ThreadPoolTaskExecutor`, which the context shuts down.

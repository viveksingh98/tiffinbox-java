# c5-unit05 — @Conditional and the Condition Evaluation Report

Course 5 · Spring Boot · Section 1 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-27.
Runs TiffinBox as unit 04 left it (`../c5-unit04/after/`, auto-configuration on); this unit changes nothing in the anchor.
The one bean of "yours" lives in `harness/demo/`, outside `com.tiffinbox`, so TiffinBox's scan never sees it.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # 3 runs each, every number asserted
```

## One bean of yours, and Boot backs off — A, B, A′

(`.r-backoff.out` `60f331b65978f0d4565c1516e1887ba6`)

```
A  TiffinBox alone:
Executor beans: [applicationTaskExecutor] · applicationTaskExecutor is a ThreadPoolTaskExecutor, core pool size 8
… 7 Boot log line(s) elided …
B  plus one Executor bean of yours:
Executor beans: [kitchenExecutor]
… 7 Boot log line(s) elided …
A' plus --spring.task.execution.mode=force:
Executor beans: [applicationTaskExecutor, kitchenExecutor] · applicationTaskExecutor is a ThreadPoolTaskExecutor, core pool size 8
… 7 Boot log line(s) elided …
```

## The report says why

`--debug` prints the CONDITIONS EVALUATION REPORT; counted here, and the lines that answer the question kept
(`.r-report.out` `b7b5331a9f1f3aed13e57c460a8e0130`):

```
boot: CONDITIONS EVALUATION REPORT - positive matches 15, negative matches 13
mine: CONDITIONS EVALUATION REPORT - positive matches 12, negative matches 12
why Boot's executor is absent in 'mine' (the report's own lines):
   TaskExecutorConfigurations.TaskExecutorConfiguration:
      Did not match:
         - AnyNestedCondition 0 matched 2 did not; NestedCondition on TaskExecutorConfigurations.OnExecutorCondition.ModelCondition @ConditionalOnProperty (spring.task.execution.mode=force) … [+343 chars]

a default Boot flips, as the report states it:
   AopAutoConfiguration.ClassProxyingConfiguration matched:
      - @ConditionalOnMissingClass did not find unwanted class 'org.aspectj.weaver.Advice' (OnClassCondition)
      - @ConditionalOnBooleanProperty (spring.aop.proxy-target-class=true) matched (OnPropertyCondition)
```

The back-off is not a plain `@ConditionalOnMissingBean` in 4.1.1: it is a nested condition, and one branch is
`spring.task.execution.mode=force` — which is exactly what A′ set. And the report states a default that Course 4
published the other way: class-based proxies (`spring.aop.proxy-target-class=true`, matched because nobody set it).

## The break — two misspellings, two very different failures

(`.r-typos.out` `e8923188d5c52635bd0f951d2b0d9830`)

```
a wrong VALUE, --spring.task.execution.mode=forced: exit 1
  Boot's failure report (its Description and Action, blank lines dropped):
  Failed to bind properties under 'spring.task.execution.mode' to org.springframework.boot.autoconfigure.task.TaskExecutionProperties$Mode:
      Property: spring.task.execution.mode
      Value: "forced"
      Origin: "spring.task.execution.mode" from property source "commandLineArgs"
      Reason: failed to convert java.lang.String to org.springframework.boot.autoconfigure.task.TaskExecutionProperties$Mode (caused by … [+134 chars]
  Action:
  Update your application's configuration. The following values are valid:
      AUTO
      FORCE
a wrong KEY, --spring.task.execution.mod=force: exit 0 · WARN lines 0
  Executor beans: [kitchenExecutor]
```

A wrong **value** is bound to an enum, so Boot refuses to start and its failure report lists the valid values. A wrong
**key** is just a property nobody reads: exit 0, no warning — and the only witness is the report above.

## Found on the way

`harness/demo/KitchenExecutorConfig` was first called `KitchenExecutor`. Boot refused to start: the configuration class
was itself a bean named `kitchenExecutor`, and so was its `@Bean` method — *"A bean with that name has already been
defined and overriding is disabled"*. Plain Spring allows overriding by default and would have let the second
definition replace the first silently; Boot turns it off (`spring.main.allow-bean-definition-overriding=false`).

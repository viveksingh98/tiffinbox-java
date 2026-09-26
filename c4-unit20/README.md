# Unit 20 — Aspects, Join Points, Pointcuts, Advice

Course 4 · Section 4 · *AOP*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9,
AspectJ **1.9.25.1**.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates every capture and **asserts** every claim below. *(Revised 2026-09-26 after the
section's RED review: the plain-class-name detector has a blind spot, AspectJ is named, and Spring's own bean
counts are no longer printed.)*

## Four words, each on the thing it names

`AuditAspect.java` carries all four in eight lines: the **aspect** is the class, the **pointcut** is the
string inside `@Before`, the **advice** is the method, the **join point** is the parameter — the call
that actually happened.

```
java -cp "$CP" com.tiffinbox.FourWords     # .r-four-words.out  7b65dbabd726e3006085598fc184a713  exit 0
```
```
the bean I got : jdk.proxy2.$Proxy<n>
  [advice] join point : Billing.price(..)
  [advice] arguments  : [Ravi]
  [advice] target     : com.tiffinbox.BillingService
  -> 340
```

## What `@EnableAspectJAutoProxy` switches on — one bean

```
java -cp "$CP" com.tiffinbox.WhatItSwitchesOn   # .r-switches-on.out  ed6db885f9c4374b6b5a61efb7920282
```
```
your beans, in both runs : [auditAspect, billing]  (identical)
added by one annotation:
  + org.springframework.aop.config.internalAutoProxyCreator
removed: 0
```

Your two beans are identical in both runs; the annotation adds exactly one definition (asserted). How many
**internal** definitions Spring registers is a property of the Spring version, so no total is printed.

The configuration class's own bean is excluded from the diff — its name differs between the two runs
for a reason unrelated to the annotation, and the first version of this program reported it as a change.
Its `die` guard caught that.

## Why AspectJ enters the pom here

**AspectJ** is the original aspect library for Java. Spring AOP borrows two things from it — the
annotations (`@Aspect`, `@Before`, `@Around`) and the pointcut language with its parser — and builds its own
proxies instead of using AspectJ's weaver (unit 24 uses the weaver). All of it ships in `aspectjweaver`: this
unit **does not compile** without it. Remove it from the run-time class path only:

```
trio md5 9b6ab9940eb038c01004d271c99680d5  exit 1
Error creating bean with name 'org.springframework.aop.config.internalAutoProxyCreator'
Caused by: java.lang.NoClassDefFoundError: org/aspectj/lang/annotation/Pointcut
```

**The one bean the annotation adds is the one bean the missing jar kills first** (asserted, by exact name).
It is not the only thing that needs the library: run the configuration **without** the annotation and the
aspect class itself fails to load (`.r-no-weaver-plain.out`, receipted by its trio):

```
Error creating bean with name 'auditAspect' defined in com.tiffinbox.WhatItSwitchesOn$Without
Caused by: java.lang.NoClassDefFoundError: org/aspectj/lang/JoinPoint
```

## The break — a pointcut that matches nothing

```
java -cp "$CP" com.tiffinbox.NoMatch        # .r-no-match.out  6b506f39c18bf582b1eba432fa8b6fe4  exit 0
```
```
pointcut      : execution(* com.tiffinbox.Billing.prise(..))
the bean I got: com.tiffinbox.BillingService
price         : 340
advice ran    : 0 time(s)
```

One letter. Compiles, starts, exit 0, advice never runs. **The detector: the bean's own class name** —
visible before you call anything. Spring only proxies a bean some advisor *could* match, so a plain class
name means **no advice was attached**. The usual reason is a rule that matched nothing, as here. (The
converse is not safe for runtime-checked pointcuts such as `args()` — unit 22.)

**The detector's blind spot — a bean built too early.** `java -cp "$CP" com.tiffinbox.EarlyBean` · `.r-early.out`
`e5b58fad8796e961d303024462a9b8ac` · 3 of 3 (timestamps elided by `jul.sh`):

```
pointcut      : execution(* com.tiffinbox.Billing.price(..))
matches BillingService.price? true
WARNING: Bean 'earlyBean.Cfg' of type [com.tiffinbox.EarlyBean$Cfg$$SpringCGLIB$$0] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying). Is this bean getting eagerly injected/applied to a currently created BeanPostProcessor [needsBilling]? Check the corresponding BeanPostProcessor declaration and its dependencies/advisors. If this bean does not have to be post-processed, declare it with ROLE_INFRASTRUCTURE.
WARNING: Bean 'billing' of type [com.tiffinbox.BillingService] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying). Is this bean getting eagerly injected/applied to a currently created BeanPostProcessor [needsBilling]? Check the corresponding BeanPostProcessor declaration and its dependencies/advisors. If this bean does not have to be post-processed, declare it with ROLE_INFRASTRUCTURE.
the bean I got: com.tiffinbox.BillingService
price         : 340
advice ran    : 0 time(s)
… 2 JUL timestamp line(s) elided …
```

The rule is spelled right and matches — the pointcut says so itself. But a `PriorityOrdered`
`BeanPostProcessor` needs a `Billing`, so `billing` is built before the auto-proxy creator exists (unit 11's
early bean). Plain class, advice 0 — and a `WARNING` names `billing` (a second names the configuration class that built it): *not eligible for auto-proxying*. So when
a class name is plain, check the rule first, then search the log for that warning.

## Files

`Billing` · `BillingService` · `AuditAspect` · `FourWords` · `WhatItSwitchesOn` · `NoMatch` · `EarlyBean` · `jul.sh` · `receipts.sh` · `exercise/`

# Unit 20 — Aspects, Join Points, Pointcuts, Advice

Course 4 · Section 4 · *AOP*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9,
AspectJ **1.9.25.1**.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates every capture and **asserts** the two claims below.

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
java -cp "$CP" com.tiffinbox.WhatItSwitchesOn   # .r-switches-on.out  f5397d04b557244c053579160ce239ae
```
```
bean definitions WITHOUT the annotation : 7
bean definitions WITH it                : 8
added by one annotation:
  + org.springframework.aop.config.internalAutoProxyCreator
```

The configuration class's own bean is excluded from the diff — its name differs between the two runs
for a reason unrelated to the annotation, and the first version of this program reported it as a change.
Its `die` guard caught that.

## Why AspectJ enters the pom here

`@Aspect`, `@Before` and `@Around` live in `aspectjweaver` — this unit **does not compile** without it.
And remove it from the run-time class path only:

```
trio md5 9b6ab9940eb038c01004d271c99680d5  exit 1
Error creating bean with name 'org.springframework.aop.config.internalAutoProxyCreator'
Caused by: java.lang.NoClassDefFoundError: org/aspectj/lang/annotation/Pointcut
```

**The one bean the annotation adds is the one bean the missing jar kills.** `receipts.sh` asserts it.

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

One letter. Compiles, starts, exit 0, advice never runs. **The detector: the bean's own class name.**
Spring only proxies a bean some advisor *could* match, so a plain class name means your pointcut
matched nothing. (The converse is not safe for runtime-checked pointcuts such as `args()` — unit 22.) — visible before you call anything.

## Files

`Billing` · `BillingService` · `AuditAspect` · `FourWords` · `WhatItSwitchesOn` · `NoMatch` · `receipts.sh` · `exercise/`

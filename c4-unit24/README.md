# Unit 24 — AOP's Limits, and AspectJ

Course 4 · Section 4 · *AOP* — and this unit closes it. **Verified on JDK 25.0.4.1**, Maven 3.9.16,
Spring Framework 7.0.9, AspectJ 1.9.25.1.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"; AJ=$(tr ':' '\n' < cp.txt | grep aspectjweaver)
```

`./receipts.sh` regenerates every capture and **asserts** both claims below.

## The limits, gathered — Spring's proxies

`java -cp "$CP" com.tiffinbox.ProxyLimits` · md5 `e16454e4f2ded90099f0e7ca2e359c99`

Outside call **1** · the call from inside the object **0** · the same method declared `final` **0**.
And an object made with `new` is never a bean, so no proxy ever stands in front of it.

## Weaving — the same aspect, compiled into the classes as they load

```
java -cp "$CP" com.tiffinbox.Limits                        # .r-no-agent.out 734b8eaa0ea36e83e53fef19350ebf94
java -javaagent:"$AJ" -cp "$CP" com.tiffinbox.Limits       # .r-woven.out    96cc2c3b1ae073230f6f72709dc55c5f
```

| | outside | inside | final |
|---|---|---|---|
| Spring's proxies | 1 | 0 | 0 |
| plain `new`, no agent | 0 | 0 | 0 |
| plain `new`, **with the agent** | **1** | **2** | **1** |

One JVM flag, no Spring at all, and every limit is gone: the inside call, the `final` method, and an object
Spring never created. **The aspect class did not change** — the same `@Aspect` Spring used.
`META-INF/aop.xml` names the aspect and limits weaving to `com.tiffinbox..*`.

**What it prints, every run:** three `sun.misc.Unsafe::objectFieldOffset` warnings naming AspectJ's
weaver, *"will be removed in a future release"*. Not Course 3's `Dynamic loading of agents` warning — that
one comes from an agent attached at run time, and this one is attached at startup, which is exactly the fix
Course 3 taught. The jar path in them is masked by `mask.sh` and counted.

## The break — one letter in aop.xml

```
java -javaagent:"$AJ" -Dorg.aspectj.weaver.loadtime.configuration=META-INF/aop-wrong.xml \
     -cp "$CP" com.tiffinbox.Limits                          # .r-wrong-pkg.out a048b8a8beb4a56d7216dd2bd092180a
```

`tiffinbx` for `tiffinbox`. The agent loads, weaves nothing: **0 · 0 · 0, exit 0**. And the warnings on
stderr are **identical** to the working run's (asserted) — so the only output you get cannot tell a weave that
worked from one that did nothing.

## Files

`Kitchen` · `FinalKitchen` · `Counter` · `ProxyLimits` · `Limits` · `META-INF/aop.xml` · `META-INF/aop-wrong.xml` · `mask.sh` · `receipts.sh` · `exercise/`

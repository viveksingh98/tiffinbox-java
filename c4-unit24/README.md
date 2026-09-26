# Unit 24 — AOP's Limits, and AspectJ

Course 4 · Section 4 · *AOP* — and this unit closes it. **Verified on JDK 25.0.4.1**, Maven 3.9.16,
Spring Framework 7.0.9, AspectJ 1.9.25.1.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"; AJ=$(tr ':' '\n' < cp.txt | grep aspectjweaver)
```

`./receipts.sh` regenerates every capture and **asserts** every claim below. *(Re-captured 2026-09-26 after the
section's RED review: `price()` now reads a field, and three captures were added.)*

## The limits, gathered — Spring's proxies

`java -cp "$CP" com.tiffinbox.ProxyLimits` · md5 `6770b5c4706dc4735a3eb5b785b3ff6e`

```
WARNING: Public final method [public final int com.tiffinbox.FinalKitchen.price(java.lang.String)] cannot get proxied via CGLIB, consider removing the final marker or using interface-based JDK proxies.
Spring's proxies:
  one price() from outside            : advice ran 1
  priceTwice(), two calls INSIDE      : advice ran 0
  the same price(), declared final    : advice ran 0, then NullPointerException: Cannot invoke "java.util.Map.get(Object)" because "this.menu" is null
… 1 JUL timestamp line(s) elided, 0 jar path(s) masked, 0 loader id(s) masked …
```

- Outside call **1** · the call from inside the object **0**.
- **The `final` method is worse than "no advice".** The call *does* reach the proxy — the caller holds the
  proxy — but a proxy is a subclass and cannot override a `final` method, so the original code runs **on the
  proxy object itself**, whose fields were never set. Advice 0, then `NullPointerException` on `this.menu`.
  For a **public** `final` method Spring's WARNING says only "cannot get proxied". The same class
  (`CglibAopProxy`, 7.0.9) logs, at DEBUG, for a **non-public** `final` method, what happens next: *calls will
  NOT be routed to the target instance and might lead to NPEs against uninitialized fields in the proxy
  instance* — which is exactly what the capture shows. Unit 23 measured that the non-public case gets no
  WARNING at all.
- And an object made with `new` is never a bean, so no proxy ever stands in front of it.

## Weaving — the same aspect, compiled into the classes as they load

```
java -cp "$CP" com.tiffinbox.Limits                        # .r-no-agent.out a27428f2b4b4f97bc40bda37528f4e4b
java -javaagent:"$AJ" -cp "$CP" com.tiffinbox.Limits       # .r-woven.out    73f2d1a5f4a68e7eca64570ccde8084f
```

| | outside | inside | final |
|---|---|---|---|
| Spring's proxies | 1 | 0 | 0, then NPE |
| plain `new`, no agent | 0 | 0 | 0 |
| plain `new`, **with the agent** | **1** | **2** | **1** |

One JVM flag, no Spring at all, and every limit is gone: the inside call, the `final` method, and an object
Spring never created. **The aspect class did not change** — the same `@Aspect` Spring used.
`META-INF/aop.xml` names the aspect and limits weaving to `com.tiffinbox..*` — without that line the weaver
examines every library class on the class path as it loads (834 Spring classes in a Spring run; it never sees
the JDK's own classes).

**What it prints, every run:** four `WARNING` lines — three naming `sun.misc.Unsafe`, one asking you to
report it to AspectJ's maintainers — *"will be removed in a future release"*. Not Course 3's `Dynamic loading of agents` warning — that
one comes from an agent attached at run time, and this one is attached at startup, which is exactly the fix
Course 3 taught. The jar path in them is masked by `mask.sh` and counted.

**In a Spring app: weave it or proxy it — never both.** The same flag on the Spring version
(`java -javaagent:"$AJ" -cp "$CP" com.tiffinbox.ProxyLimits` · md5 `77cb3e11437ef3e7f5fb1566e19ba565`):

```
Spring's proxies:
  one price() from outside            : advice ran 3
  priceTwice(), two calls INSIDE      : advice ran 2
  the same price(), declared final    : advice ran 1, then NullPointerException: Cannot invoke "java.util.Map.get(Object)" because "this.menu" is null
```

One call from outside ran the advice **three times** — woven into `Kitchen`, woven into the proxy class Spring
generated (it is in `com.tiffinbox` too), and run again by the proxy. Nothing warns you.

## The break — one letter in aop.xml

```
java -javaagent:"$AJ" -Dorg.aspectj.weaver.loadtime.configuration=META-INF/aop-wrong.xml \
     -cp "$CP" com.tiffinbox.Limits                          # .r-wrong-pkg.out 964c5dda5f15285e87356ba8bfcec92c
```

`tiffinbx` for `tiffinbox`. The agent loads, weaves nothing: **0 · 0 · 0, exit 0**. And the warnings on
stderr are **identical** to the working run's (asserted) — so the **default** output cannot tell a weave that
worked from one that did nothing.

**Ask the weaver instead.** One option, `<weaver options="-showWeaveInfo">` (`aop-info.xml`,
`aop-wrong-info.xml`), and it reports every method it wove:

```
[AppClassLoader@<id>] weaveinfo at com/tiffinbox/Kitchen.java:8::0 Join point 'method-execution(int com.tiffinbox.Kitchen.price(java.lang.String))'
[AppClassLoader@<id>] weaveinfo at com/tiffinbox/FinalKitchen.java:8::0 Join point 'method-execution(int com.tiffinbox.FinalKitchen.price(java.lang.String))'
```

Two `weaveinfo` lines when it worked (`.r-woven-info.out` `7ed26e5f109af12c7117652c890ea0f9`); **zero** with the
wrong package (`.r-wrong-info.out` `964c5dda5f15285e87356ba8bfcec92c` — byte-identical to the quiet wrong run). Asserted.

## Files

`Kitchen` · `FinalKitchen` · `Counter` · `ProxyLimits` · `Limits` · `META-INF/aop.xml` · `aop-wrong.xml` · `aop-info.xml` · `aop-wrong-info.xml` · `mask.sh` · `receipts.sh` · `exercise/`

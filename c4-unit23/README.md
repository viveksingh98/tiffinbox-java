# Unit 23 — JDK Proxies vs CGLIB, and the Self-Invocation Trap

Course 4 · Section 4 · *AOP*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9, AspectJ 1.9.25.1.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates everything and **asserts** each claim. Captures keep stderr: in this unit the
presence of one warning and the absence of another are both evidence.

## Two mechanisms — A/B on one attribute

`java -cp "$CP" com.tiffinbox.TwoMechanisms` · `.r-jdk.out` `fb91060363fe91779eade81a2e729415`
`java -cp "$CP" com.tiffinbox.TwoMechanisms force` · `.r-cglib.out` `a08b9f30cfb1eb64ef2f1a12cde0423a`
*(Re-captured 2026-09-26 after the section's RED review: two rows added — a non-public `final` method, and
`@Proxyable`.)*

```
  proxyTargetClass = false
  WARNING: Public final method [public final int com.tiffinbox.TwoMechanisms$FinalBilling.price(java.lang.String)] cannot get proxied via CGLIB, consider removing the final marker or using interface-based JDK proxies.
    interface-typed bean -> jdk.proxy2.$Proxy<n>
    class-typed bean     -> com.tiffinbox.TwoMechanisms$ClassBilling$$SpringCGLIB$$<n>
    interface bean, @Proxyable(TARGET_CLASS) -> com.tiffinbox.TwoMechanisms$PerBeanBilling$$SpringCGLIB$$<n>
    one price() from outside            : advice ran 1
    priceTwice() = 680, calls price() twice INSIDE : advice ran 0
    price() on the class bean           : advice ran 1
    the same price(), declared final    : advice ran 0   (bean: com.tiffinbox.TwoMechanisms$FinalBilling$$SpringCGLIB$$<n>)
    final, and NOT public               : advice ran 0   (bean: com.tiffinbox.TwoMechanisms$QuietFinalBilling$$SpringCGLIB$$<n>)
```

Flip `proxyTargetClass` and **exactly one row moves** (asserted): the interface-typed bean becomes CGLIB too.
That is the **default**: an interface bean gets the JDK's proxy unless you say otherwise — globally with
`proxyTargetClass`, or **per bean** with `@Proxyable(ProxyType.TARGET_CLASS)` (new in Spring Framework 7; the
`PerBeanBilling` row is a subclass under the default setting, asserted).

## The trap — survives the flip, and says nothing

`priceTwice()` calls `price()` twice **inside the object**. It returns 680, the aspect is registered, the
bean is a proxy — and the advice runs **zero** times, under **both** mechanisms (asserted). The call never
leaves the object, so it never passes the proxy. Forcing CGLIB does not fix it.

**Spring prints no warning about it** — the run's only `WARNING` is about the **public** `final` method
(asserted by counting *every* warning, not by searching for guessed words).

## final — warned only when it is public, and never harmless

`FinalBilling.price` is identical to `ClassBilling.price` except for `final`. The bean **is** proxied, and
advice ran **0**. Spring warns once, at startup:

```
WARNING: Public final method [...FinalBilling.price(java.lang.String)] cannot get proxied via CGLIB,
consider removing the final marker or using interface-based JDK proxies.
```

`QuietFinalBilling.price` is `FinalBilling.price` with one difference — it is **not public** — and it gets
**no warning at all** (asserted: 1 WARNING in the run, 0 naming it). And "no advice" is not the whole story: a
proxy cannot override a `final` method, so the original code runs **on the proxy object**, whose fields were
never set. These methods return a constant, so nothing breaks here; unit 24's `final` method reads a field and
throws `NullPointerException`.

*A first draft measured a method named `finalPrice`, which the rule never matched — so its zero proved
nothing about `final`. And the warning above was first missed because the reading command filtered out
`WARNING` lines. Both fixed.*

## Three ways out — each run, each priced

`java -cp "$CP" com.tiffinbox.WaysOut` · `.r-ways-out.out` `6c561661cd09c0f615e38a97fd610f31`

```
  1. extract to a second bean   : advice ran 2   cost: one more class - and the design is better for it
  2. self-injection             : advice ran 2   cost: a bean that depends on itself
  3. AopContext.currentProxy()  : advice ran 2   cost: Spring inside your business code, and exposeProxy must be on
```

## Files

`Billing` · `Counted` · `TwoMechanisms` · `WaysOut` · `jul.sh` · `receipts.sh` · `exercise/`

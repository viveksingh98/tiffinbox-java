# Unit 19 — What a Proxy Actually Is

Course 4 · Section 4 · *AOP*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates every capture and checks the two claims below instead of stating them.

## A proxy, by hand — `java.lang.reflect` only

You have not written one of these before in this track: nothing in the first three courses calls
`newProxyInstance`. It is built here, on the reflection you already know.

```
java -cp "$CP" com.tiffinbox.ByHand        # .r-by-hand.out  9d3c7966ac64a8d8dc6bb325bc97e5a4  exit 0
```
```
the class I wrote : com.tiffinbox.KitchenRail
the class I got   : jdk.proxy1.$Proxy<n>
same class?         false
is it a Rail?       true
  [before] place(Ravi)
  [after ] returned "cooking for Ravi"
```

Something ran before and after your method, and `KitchenRail` does not know it exists.
`$Proxy<n>` is masked by the program: the number is a counter, not a fact.

## The same thing, asked of Spring

```
java -cp "$CP" com.tiffinbox.SpringsVersion   # .r-springs.out  eb226b71deb3dff9bbcb9dc3f5738da2  exit 0
```

`ProxyFactory` is in `spring-aop`, which `spring-context` already brings — **no AspectJ** (`receipts.sh`
counts: 0 jars). And the class it hands back has the **identical** name, which `receipts.sh` asserts.

*A trap worth knowing:* a proxy of a **package-private** interface must live in that interface's
package, so its name changes (`com.tiffinbox.$Proxy0`). The variable is the interface's visibility,
not who built the proxy. This unit's first draft got that wrong.

## The break — no interface, no proxy

```
java -cp "$CP" com.tiffinbox.NoInterface   # .r-no-interface.out  b0647d1e9b89a2a689d7c04d6124a113  exit 1
```
```
java.lang.IllegalArgumentException: com.tiffinbox.NoInterface$LonelyRail is not an interface
```

The JDK can only proxy an **interface**. That one limit is why Spring carries a second mechanism.

## Files

`Rail` · `KitchenRail` · `ByHand` · `SpringsVersion` · `NoInterface` · `receipts.sh` · `exercise/`

# Unit 21 — @Before, @After and @Around

Course 4 · Section 4 · *AOP*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9, AspectJ 1.9.25.1.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates everything and **asserts** each claim below.

## The order they fire in — one call

`java -cp "$CP" com.tiffinbox.InOrder` · `.r-in-order.out` md5 `00304eaef02b1132e20606dce5bedd63` · exit 0

`@Around (entering)` → `@Before` → the method → `@AfterReturning` → `@After` → `@Around (leaving)`.
**`@After` fires after `@AfterReturning`**, not before. Make the call throw and `@AfterThrowing` takes
`@AfterReturning`'s place — a real exception, not a claim.

## Three things only @Around can do — each one run

`java -cp "$CP" com.tiffinbox.ThreePowers` · md5 `216641762609b6051085eca4c7f8bd87`

- **skip the call** → caller gets `-1`, and the real method's line is **absent** (asserted)
- **change the arguments** → the method runs for **SOMEBODY ELSE**
- **change the return value** → `340` becomes `680`

## The break — @Around that forgets proceed()

`java -cp "$CP" com.tiffinbox.ForgotProceed` · md5 `682e45ea990f94c684c64014898da9b5`

| return type | what the caller sees |
|---|---|
| `int` | `AopInvocationException: Null return value from advice does not match primitive return type` |
| `String` | `null` — nothing reported a problem |
| `void` | nothing — nothing reported a problem |

The method never ran in any of the three. **Only the primitive one is loud**, and that is luck.

## Timing — and the number is never the lesson

`java -cp "$CP" com.tiffinbox.Timing` · masked md5 `fd6cd873cff7e915e419ac7f20327099`

The aspect sees the signature, the arguments and the return value. The duration differs every run, and
the first call is many times slower than the third — `receipts.sh` prints three runs' raw values and
fails if they ever come out identical. `ms.sh` masks and **counts** the values so the rest is hashable.

## Files

`Billing` · `BillingService` · `InOrder` · `ThreePowers` · `ForgotProceed` · `Timing` · `ms.sh` · `receipts.sh` · `exercise/`

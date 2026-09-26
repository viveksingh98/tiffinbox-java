# Unit 22 — Pointcut Expressions in Depth

Course 4 · Section 4 · *AOP*. **Verified on JDK 25.0.4.1**, Maven 3.9.16, Spring Framework 7.0.9, AspectJ 1.9.25.1.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates everything and **asserts** the three claims below.

## Every form, against the same three methods — proved by what runs

`price`, `refund` (carries `@Audited`) and `Menu.dishes` — **the control, which most rules must not touch**.

`java -cp "$CP" com.tiffinbox.Matrix` · `.r-matrix.out` md5 `95790eca50610c9604177198b278226b`

```
  pointcut                                                   price  refund dishes   billing menu
                                                                                      (P = proxied)
  execution(* com.tiffinbox.Billing.price(..))               RAN    -      -        P .
  execution(* com.tiffinbox.Billing.*(..))                   RAN    RAN    -        P .
  within(com.tiffinbox.BillingService)                       RAN    RAN    -        P .
  @annotation(com.tiffinbox.Audited)                         -      RAN    -        P .
  args(String)                                               RAN    RAN    -        P P
  execution(* *(String))                                     RAN    RAN    -        P .
  bean(billing)                                              RAN    RAN    -        P .
  execution(* com.tiffinbox.*.*(..)) && !@annotation(com.tiffinbox.Audited) RAN    -      RAN      P P
  execution(* com.tiffinbox.*.*(..))                         RAN    RAN    RAN      P P
```

## The detector's blind spot — static versus runtime

Two units ago the rule was: **a plain class name means nothing matched.** That still holds. The
converse does not. `args(String)` and `execution(* *(String))` say the same thing — yet `args`
**proxies the control bean** and never advises it (`P` in the `menu` column, asserted).

`java -cp "$CP" com.tiffinbox.StaticOrRuntime` · md5 `ab6023079ada6ea49e35b1890e478b53`

```
  args(String)             checked at run time: true   MenuService methods that COULD match: equals(Object)
  execution(* *(String))   checked at run time: false  MenuService methods that COULD match: none
```

`args` is checked **at run time**, so the proxy is built for any method that *could* receive a String —
and `equals(Object)` could. `isRuntime()` tells you which kind you wrote.

## The break — one character, both directions

- **Too narrow:** `$*` as a nested-type wildcard matches nothing (asserted: advice ran 0), while `$Rail`,
  `.Rail` and `.*` all match. `java -cp "$CP" com.tiffinbox.DollarStar` · md5 `4ad1015669c96672a3c9772024781014`
- **Too wide:** `execution(* com.tiffinbox.*.*(..))` advises the control method `dishes()` (asserted).

## Named pointcuts

`java -cp "$CP" com.tiffinbox.Named` · md5 `feee5e72a4659505c2327cd35713e1ac` — the rule written once, referred to by
two pieces of advice. Change it in one place and both follow.

## Files

`Audited` · `Billing` · `BillingService` · `Menu` · `MenuService` · `Matrix` · `StaticOrRuntime` · `DollarStar` · `Named` · `receipts.sh` · `exercise/`

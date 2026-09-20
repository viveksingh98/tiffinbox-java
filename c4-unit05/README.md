# c4-unit05 — @Configuration and @Bean

Course 4 · Spring Framework Core · Section 1 "The Container".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-16.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.AbA
java -cp "target/classes:$(cat .cp)" com.tiffinbox.AbA --stable
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport --stable
java -XX:+UnlockExperimentalVMOptions -XX:hashCode=0 -cp "target/classes:$(cat .cp)" com.tiffinbox.AbA
java -XX:+UnlockExperimentalVMOptions -XX:hashCode=0 -cp "target/classes:$(cat .cp)" com.tiffinbox.AbA --stable
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `AbA.java` | **A / B / A-prime in one program, one session.** Three captures, one attribute apart |
| `ProxiedConfig.java` | case A — `proxyBeanMethods` at its default |
| `PlainConfig.java` | case B — the same file with **one attribute** flipped |
| `Pool.java` | `org.h2.jdbcx.JdbcDataSource` — a third-party class you cannot annotate. **That is why `@Bean` exists** |
| `ContextReport.java` | the receipt, with the identity, the class name and the two counts |
| `exercise/` | a context that starts and hands back a new pool on every call |

## CGLIB on JDK 25 — measured before this was written

**Exit 0, no `--add-opens`, no warning, nothing on stderr.** The `@Configuration` subclass is
generated at runtime and the class name proves it. Three limits, all measured, all with
their real first line:

| What | Exception | First line |
|---|---|---|
| `final` `@Configuration` class | `BeanDefinitionParsingException` | `@Configuration class '…' may not be final. Remove the final modifier to continue.` |
| `final` `@Bean` method | `BeanDefinitionParsingException` | `@Bean method 'pool' must not be private or final; change the method's modifiers to continue.` |
| no visible constructor | `BeanDefinitionStoreException` → `IllegalArgumentException` | `Could not enhance configuration class […]` → `No visible constructors in class …` |

The one place it does need a flag is a **named module with no `opens`** — that is the previous
unit's measurement, and it is where the reflection unit's promise comes due.

## A / B / A-prime

```
[A ] as written            proxyBeanMethods = true (the default)
  config.getClass()            com.tiffinbox.ProxiedConfig$$SpringCGLIB$$0
  dataSource() == dataSource()  true
  beans of type DataSource      1   <- UNCHANGED. This is a count of DEFINITIONS, not of objects
  distinct DataSource objects   1
[B ] ONE attribute flipped proxyBeanMethods = false
  config.getClass()            com.tiffinbox.PlainConfig
  dataSource() == dataSource()  false
  beans of type DataSource      1   <- UNCHANGED
  distinct DataSource objects   3
[A'] back to A, re-run     proxyBeanMethods = true
  ... back to true, and back to one object
```

**`beans of type DataSource` is 1 in both cases and it is not the differentiator.** A
`getBeanNamesForType` count counts *definitions*. What changed is how many objects exist, and
how many times your method body ran. Those are three different claims and this unit labels all
three, because conflating them is the defect.

And the third one is now **measured** rather than re-encoded. It used to read
`(a == b ? 1 : 2)`, which is the identity row above it spelled differently: it could not
disagree with that row and it could not exceed two. It is now an **identity set**
(`Collections.newSetFromMap(new IdentityHashMap<>())`) over every `DataSource` the container is
holding plus the two the method handed back — so in case B it reads **3**, one per invocation,
which is the real shape of `proxyBeanMethods = false`. That it equals `@Bean body ran  3` is a
cross-check between two counters that do not share a line of code.

## Two claims, two windows, and the brief says which

- `@Bean body ran` in `AbA` counts from **before** refresh: A = 1, B = 3.
- `@Bean body ran` in `ContextReport` counts from **after** refresh: A = 0, B = 2.

Both are true. In case A the two calls run your body **zero** extra times, because the proxy
hands back the bean it already has.

## identityHashCode: reproducible here, and portable nowhere

The unmasked `AbA` capture is byte-identical on three runs — md5
`5df5ca4e05f418c016fe3c98da1fb3c7`. **That is not evidence it travels.** The same program under
`-XX:+UnlockExperimentalVMOptions -XX:hashCode=0` prints completely different values —
`145f668d832dde80199d2039a7882236`, saved as `.r-abah{1,2,3}` — while the masked form does not
change at all: `c366deb24dc545c233baa94a8707ccc6` in `.r-abas{1,2,3}` **and** in
`.r-abahs{1,2,3}`, the same hash with the flag and without it. Both counter-examples ship, so
the portability claim is a pair of files rather than a sentence. A capture that
reproduces three times on one machine is not thereby portable, which is exactly why `--stable`
exists and why the mask is printed.

Two notes on the flags and the mask, both of which were wrong before this pass. `-XX:hashCode`
is an **experimental** option: without `-XX:+UnlockExperimentalVMOptions` **before** it the JVM
refuses to start (`Improperly specified VM option 'hashCode=0'`, exit 1), so the unlock flag is
part of the command. And `AbA` had **no `--stable` flag at all**, so the masked hash this
section quotes could not be regenerated from the shipped folder; `AbA --stable` now exists and
masks through `ContextReport.mask()` — the same mask the report prints — rather than through a
second, private one.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project and for
`exercise/`.

## Exercise

`exercise/` starts clean and `ContextReport --stable` says (saved, `exercise/.r-start{1,2,3}`,
md5 `68f083ed755f47c648baf0afef6789c7`, exit 0, 3/3):

```
  dataSource() == dataSource()           false
  @Bean body ran (your code)             2 time(s)
  distinct DataSource objects            3
```

Two pools, two sets of connections, one application that thinks it has one pool. Make it one,
**without touching `Pool` or the `@Bean` method body.** **End state:** `dataSource() ==
dataSource()  true`, `@Bean body ran  0 time(s)` and `distinct DataSource objects  1`, md5
`b896c301d885cc31ed9706970263056d`, exit 0, 3/3. Answer in `exercise/solution/`.

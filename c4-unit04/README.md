# c4-unit04 — component scanning and stereotypes

Course 4 · Spring Framework Core · Section 1 "The Container".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-16.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.scan.WhatTheScannerReads
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `scan/ScanConfig.java` | two base packages and one `excludeFilter` |
| `scan/WhatTheScannerReads.java` | the stereotypes opened up **by reflection, not asserted**, and the scan with the load events visible |
| `menu/JdbcMenuRepository.java`, `menu/CsvMenuRepository.java` | identical `@Repository` classes. One becomes a bean; one does not |
| `kitchen/BillingService.java`, `kitchen/ReportBuilder.java` | a `@Service` with a required dependency, and a `@Lazy @Component` |
| `chain.py` | the `Caused by:`-chain filter. It keeps every `Caused by:` line plus the first frame under each and **derives** every elision count, including the two-line `java.util.logging` record of a cancelled refresh, which it names in the capture instead of dropping silently. It matches that record on Spring's own message text, never on an English month name or the word `WARNING:` — both of which JUL localises. Every other `WARNING:` line is **shown, not cropped**. It **exits 2** if the input records a cancelled refresh and it removed none of it. **It ships here now**: this unit hashes a capture it produced (`903600f0…`) and used to quote that hash without shipping the filter |
| `modpath/` | the module-path probe: **the same scan, inside a named module**. `sh run.sh` compiles `src/module-info.java` + four sources into module `tiffinbox.scan`, then runs the line the module slide shows, three times, and compares the three captures. Its `module-info.java` carries `exports` and **no `opens`** — deliberately: `ModConfig` declares no `@Bean` methods, so the container never enhances it, and `opens` is the directive the *other* half of that slide is about |
| `breaks/one-segment-wrong/` | one letter changed in a base package |
| `exercise/` | a filter that excludes by annotation instead of by type |

Every scanned class carries a `static { System.out.println("CLASS LOADED …"); }`. **That is the
instrument.** A static initialiser runs the first time the JVM loads its class, so the lines that
appear — and the lines that do not — are the measurement.

## The scanner does not use reflection, and here is the proof

```
REFRESH - and the only classes the JVM loads are the ones it instantiates
  CLASS LOADED  JdbcMenuRepository
  CLASS LOADED  BillingService
REGISTERED (sorted, ours only)
    billingService
    jdbcMenuRepository
    reportBuilder
    scanConfig
```

`CsvMenuRepository` never prints. It wears `@Repository`, the scanner read its annotations and
the filter rejected it — **and the JVM never loaded the class.** If the scanner used
`Class.forName`, that line would be on screen. It is not, because the scanner reads the
`.class` bytes.

`ReportBuilder` also never prints at refresh, and its row reads `(not built)`: registered, not
loaded. Ask for it and the line appears. Note the nuance: `getType("reportBuilder")` resolves
the class **without initialising it**, which is why the report can print the type and still
leave the static block un-run.

## The break — this is the course's thesis in its purest form

One letter in a base package. `com.tiffinbox.kitchen` becomes `com.tiffinbox.kitchens`:

```
beans(app)=4      ->   beans(app)=2
```

The context refreshed. Nothing was logged. `BillingService` — which has a **required**
constructor dependency — simply does not exist, so nothing complained. The only thing that
caught it was `ContextReport` asking a named question, and then it threw
`NoSuchBeanDefinitionException: No bean named 'reportBuilder' available` (exit 1, 3/3, md5
`903600f0d000ad86365787af103be40f`). **Startup was never the evidence.**

## The module question, measured — and the earlier claim is SPLIT, not corrected

A previous course's slide, rendered, says this in full:

> Your Spring and Jackson apps always worked **because they were never in a module** —
> `setAccessible` starts failing the day you write `module-info.java`.

**That sentence is true**, and this unit is not correcting it — it is **splitting** it. It is
about `setAccessible` reaching a private member. A component scan is a different operation: it
reads `.class` bytes and never loads the class. The line between the two is the thing nobody
draws, and it is what the table below draws. Measured on Spring Framework 7.0.9 and JDK 25:
scanning needs `exports`; generating a CGLIB subclass needs `opens`.

(That Course 2 video is **built and not uploaded** — `upload_state_java2.json` has entries `01`
through `31` and no entry for unit 32, so it carries no `video_id`. Nothing here calls it
published.)

| What was run | Result |
|---|---|
| component scan inside a **named module**, package `exports`-ed | **works** — `named module? true`, 7 definitions, exit 0, 3/3 |
| CGLIB enhancement of a `@Configuration` class in a module with no `opens` | **fails**: `CodeGenerationException: java.lang.IllegalAccessException-->module tiffinbox.closed does not open com.tiffinbox.closed to module spring.core` |
| the same, with `--add-opens …=ALL-UNNAMED` | **still exit 1** — the requester is a *named* module |
| the same, with `--add-opens …=spring.core` | exit 0, 3/3 |
| the same, with `opens com.tiffinbox.closed;` in `module-info.java` | exit 0, 3/3 |
| everything above, on the **class path** | exit 0, no flag, 3/3 |

So: scanning needs `exports`; **byte-code generation needs `opens`**; and the escape-hatch flag
has to name `spring.core`, not `ALL-UNNAMED`. Three states, one command apart.

### Row 1 of that table ships here, so you can re-run it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd modpath && sh run.sh
```

`run.sh` needs `../.cp`, written by the two Maven lines at the top of this file, and it puts those
same jars on the **module path** — Spring Framework 7 ships automatic modules, which is the only
reason `requires spring.context` resolves. It then runs, three times:

```
java --module-path "out:$CP" -m tiffinbox.scan/com.tiffinbox.scan.ModConfig
```

```
  CLASS LOADED  JdbcMenuRepository
  CLASS LOADED  CsvMenuRepository
module of this class : tiffinbox.scan
named module?        : true
beans registered     : 7
jdbcMenuRepository   : true
```

Exit **0**, **6** output lines, md5 `fd2ffdf97c36abbfb4db195f23577cdf`, **3 of 3** byte-identical —
re-measured 2026-09-17, and again from a second directory whose path contains a space, same md5.
`run.sh` compares the three captures itself and **exits 1** rather than print a hash it did not check.

**Why there is no `opens` line in `modpath/src/module-info.java`, and why adding one would be a
lie.** Asked in the same module, `AnnotationConfigApplicationContext` hands back
`com.tiffinbox.scan.ModConfig` — the class as written, **not** a `$$SpringCGLIB$$` subclass — because
`ModConfig` declares no `@Bean` methods, so there is nothing to intercept and the container never
reflects into this package. Add one `@Bean` method to a configuration class in this same module,
change nothing else, and the same `exports`-only descriptor fails at exit 1 with
`module tiffinbox.scan does not open com.tiffinbox.scan to module spring.core`. That is the split this
unit teaches, and it is why the shipped descriptor stops at `exports`: the scan does not need
`opens`, and the subclass cannot do without it.

The three `menu/*.java` files under `modpath/src/` are byte-identical to this project's own
(`cmp modpath/src/com/tiffinbox/menu/X.java src/main/java/com/tiffinbox/menu/X.java` → exit 0, all
three), so the module runs the same classes the class-path demo above scanned.

**Not shipped, and the slide says so on the panel itself:** the *failing* probe — a
`@Configuration` class with `@Bean` methods in a module that exports and does not open — was run in
the author's scratch module path, not here.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project, for
`exercise/` **and for `breaks/one-segment-wrong/`** — which is the point of that break: it
builds and verifies perfectly.

## Exercise

`exercise/` starts clean and `ContextReport` **exits 2** with a diagnostic rather than printing
a confident zero:

```
  beans of type MenuRepository           0
ContextReport: no bean of type MenuRepository. The context refreshed and printed nothing, so the
only thing that can tell you is a named question like this one. Check the base packages and the
exclude filters.
```

One filter is excluding more than somebody meant. **End state:** `beans of type MenuRepository
1` and `of which, names  jdbcMenuRepository`, exit 0, md5
`c52dc7e812ffc26ef8b27b7ed638164b`, 3/3. Answer in `exercise/solution/`.

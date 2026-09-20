# c4-unit03 — dependency injection: constructor, setter, field

Course 4 · Spring Framework Core · Section 1 "The Container".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-16.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ThreeInjectionPoints
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
java -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakFieldUsedTooEarly   # exits 1, on purpose
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `ThreeInjectionPoints.java` | all three styles in one context, and **what each object could see while it was being built** |
| `BreakFieldUsedTooEarly.java` | a field-injected collaborator used from the object's own constructor |
| `ContextReport.java` | the receipt, with the during-construction row added |
| `chain.py` | the `Caused by:`-chain filter. It keeps every `Caused by:` line plus the first frame under each and **derives** every elision count, including the two-line `java.util.logging` record of a cancelled refresh, which it names in the capture instead of dropping silently. It matches that record on Spring's own message text, never on an English month name or the word `WARNING:` — both of which JUL localises, so the old filter let a timestamp through under a German or French locale while the derived frame counts stayed identical and nothing flagged it. Every other `WARNING:` line is **shown, not cropped**, the JDK's `sun.misc.Unsafe` and CGLIB integrity warnings included. It **exits 2** if the input records a cancelled refresh and it removed none of it |
| `exercise/` | a context that starts and sizes the kitchen for nobody |

## The answer to the question the reflection unit left open

The previous Java course put `@Autowired private CustomerRepository repo;` on screen with three
red crosses — *no `new`, no factory, yet at run time that field holds an object* — and stopped
there. Here is the whole answer, measured:

```
AFTER the container is finished with each object
  constructor   repo=set  final=yes
  setter        repo=set  final=no
  field         repo=set  final=no
DURING construction - what the object itself could see
  constructor   repo=set   <- it was an argument. It could not be otherwise
  field         repo=null  <- the container had not written it yet
```

All three work. The difference is **when**, and the field case has a window in which the object
exists and the field does not. That window is what the break lands in.

## Failure receipt — a three-link chain, and the last link names the field

```
exit code        1
exception type   org.springframework.beans.factory.BeanCreationException
Caused by        org.springframework.beans.BeanInstantiationException
Caused by        java.lang.NullPointerException:
                 Cannot invoke "com.tiffinbox.CustomerRepository.findAll()" because "this.repo" is null
```

Three runs, byte-identical, md5 `a7d5d44e33e5e2c5dff714747efa69b8`. The whole chain is kept and
the frames between the links are elided with a **derived** count — `chain.py` counts them.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project and for
`exercise/`.

## Exercise

`exercise/` starts clean — exit 0 — and `ContextReport` says:

```
  sizer.cooksNeeded()                    0
  customers in the repository            4
```

Four customers in the database and a kitchen sized for zero. Fix it **by changing how the
collaborator arrives**, not by adding a null check. **End state:** `sizer.cooksNeeded()  4`,
md5 `8754dc14a0c78510f9eafe56e9038460`, 3/3. Answer in `exercise/solution/`.

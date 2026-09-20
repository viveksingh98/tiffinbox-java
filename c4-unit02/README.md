# c4-unit02 — beans, definitions and the context

Course 4 · Spring Framework Core · Section 1 "The Container".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-16.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:src/main/resources:$(cat .cp)" com.tiffinbox.Definitions
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport --stable
java -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakMissingName    # exits 1, on purpose
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `Definitions.java` | a `BeanDefinition` read off the registry — class, scope, factory method, lazy flag — beside the object it produces |
| `ContextReport.java` | the receipt, and **this is the unit that builds it on screen**. Its two honesty rules are printed above the list, every run |
| `BreakMissingName.java` | one transposed letter in a bean name. The first failure receipt of the course |
| `legacy/applicationContext.xml` | eight lines from 2010, really loaded, **read only**. The XML appears here and nowhere else in the course, and you never write one |
| `chain.py` | the `Caused by:`-chain filter. It keeps every `Caused by:` line plus the first frame under each and **derives** every elision count, including the two-line `java.util.logging` record of a cancelled refresh, which it names in the capture instead of dropping silently. It matches that record on Spring's own message text, never on an English month name or the word `WARNING:` — both of which JUL localises, so the old filter let a timestamp through under a German or French locale while the derived frame counts stayed identical and nothing flagged it. Every other `WARNING:` line is **shown, not cropped**, the JDK's `sun.misc.Unsafe` and CGLIB integrity warnings included. It **exits 2** if the input records a cancelled refresh and it removed none of it |
| `exercise/` | a context that starts and lists the wrong bean name |

## The thing the XML beat actually shows — and it is not "the same shape"

Loading both contexts and printing the same four fields gives this, and the interesting part is
the **difference**:

```
THE RECIPE  (annotated context, definitions only - nothing built yet)
  database             class=(null - a @Bean method makes it)   factoryMethod=database
THE SAME FOUR FIELDS, OFF EIGHT LINES OF XML FROM 2010
  database             class=com.tiffinbox.Database             factoryMethod=-
```

The two spellings converge on **one structure** — a `BeanDefinition` — and they fill *different
fields of it*. The annotated one has no class name at all, because a `@Bean` method is what
produces the object; the XML one names the class and has no factory method. That is a better
beat than "identical", and it is what the capture actually says.

## `ContextReport` is built here, and it has five rules, not four

It **sorts** (registration order follows scan order and is filesystem-dependent) · it counts
**your** beans, not Spring's, and prints the filter · `--stable` is the hashable form and the
mask is printed · it is content, not scaffolding · and **it does not instantiate what it is
reporting on** — reading a bean's runtime class with `getBean(name)` builds every lazy bean in
the context, so the report would change the thing it measures. That fifth rule was learned by
watching it happen.

## Failure receipt

```
exit code        1
exception type   org.springframework.beans.factory.NoSuchBeanDefinitionException
first line       No bean named 'dashbaord' available
```

Stable across three runs, hashable with no masking, md5 `f3583dbae21df36720049e8707316268`.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project and for
`exercise/`.

## Exercise

`exercise/` starts clean — exit 0, no warning — and `ContextReport` lists a bean called
`theDashboard`. Make it list one called `dashboard`, **without renaming the method**.
**End state:** the `beans(app)=5` block contains `dashboard`, md5
`6eae149912a937ce1cf9592e1bd2c199`, 3/3. Answer in `exercise/solution/`.

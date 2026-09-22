# Unit 15 — Profiles: Only One Bean Gets Created

Course 4 · Section 3 · *Configuration and Environment*.
**Verified on JDK 25.0.4.1**, Apache Maven 3.9.16, Spring Framework 7.0.9, macOS 27.0.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates every capture below and prints its hash.

## The claim, and the column it took to prove it

```
java -cp "$CP" com.tiffinbox.ContextReport in-memory
```

`.r-prof-inmemory.out` · md5 `ea8ac72af3ab76f3d4ef08a7eec8feb3` · exit 0 · 3 of 3.

```
active   [in-memory]     default [default]
…
the two rails, asked separately:
  inMemoryRail   definition=true   instantiated=true
  jdbcRail       definition=false  instantiated=false  <- the container never received a recipe for this
definitions among the 2 watched rails: 1
```

**`definition=false`.** The losing rail is not a bean that exists and goes unused — the registry
never received a recipe for it. `@Profile` is read while the container is reading your description,
so the decision happens before anything could be built.

Swap the profile and the two rows swap (`.r-prof-jdbc.out` · md5 `43ebb467d9c3a323376c67ef85c8d829`).

## RULE 6, and this unit is what forced it

Sections 1-2 built the `ContextReport` on five rules. Rule 5 reads `containsSingleton` — and
**`containsSingleton` answers `false` for both "no definition" and "a definition nothing built".**
With one column, this unit's entire claim would have been unprovable by its own receipt.

So the report prints `containsBeanDefinition` **beside** `containsSingleton`, always. A check that
cannot distinguish is this course's recurring defect; here it was caught on the instrument rather
than in the lesson.

The report also **dies** (exit 2) if both watched rails turn out to be defined, because a capture in
which `@Profile` excluded nothing cannot demonstrate that `@Profile` excludes anything.

## Nobody chose

```
java -cp "$CP" com.tiffinbox.ContextReport ""
```

`.r-prof-none.out` · md5 `50c0a162300640f4251e66449d7a7b99` · exit 0 · 3 of 3.

```
active   []     default [default]
  inMemoryRail   definition=false  instantiated=false
  jdbcRail       definition=false  instantiated=false
definitions among the 2 watched rails: 0
```

**Neither exists.** There is no implicit fallback. `default` on that first line is the *default
profile name*, not a bean that exists by default — the report prints `active` and `default` side by
side precisely because those are two different things wearing one word.

## The break

```
java -cp "$CP" com.tiffinbox.NobodyChose plain
```

trio md5 `c93e8836f3c51cb87fc0ebdb334e638a` · **exit 1** · 3 of 3.

```
UnsatisfiedDependencyException: Error creating bean with name 'desk' …
Caused by: NoSuchBeanDefinitionException: No qualifying bean of type 'com.tiffinbox.Rail' available
```

The thrown type is `UnsatisfiedDependencyException`; `NoSuchBeanDefinitionException` is its **cause**.
Receipted as a trio rather than as output because Spring logs a `WARNING` carrying a wall-clock
timestamp on this path.

## The fix, and what it is not

```
java -cp "$CP" com.tiffinbox.NobodyChose fallback
```

`.r-fix-fallback.out` · md5 `5d4152853e24b2b8273f96ebfa35180e` · exit 0 · 3 of 3.

`@Profile("default")` — a bean that exists when nobody chose. **Not `@Primary`**: `@Primary` breaks a
tie, and here there is no tie, there is nothing to tie. **Not a fourth annotation**, and not an `if`
inside a factory.

## Why it is the "jdbc" rail and not the "production" rail

`@Profile("jdbc")`, `JdbcRail`, and nowhere on screen does the word production appear. H2 is what
Course 2 shipped and what this course carries; whether it is what you would run a business on is a
different question asked in a different course, and a profile called `prod` would have answered it
by accident.

## Files

| file | what it is |
|---|---|
| `Rail` · `InMemoryRail` · `JdbcRail` | two implementations, one slot |
| `TiffinBoxConfig.java` | the description — no `if`, no factory, no runtime flag |
| `ContextReport.java` | the receipt, now with rule 6 and a `die` when `@Profile` excluded nothing |
| `NobodyChose.java` | the break and its fix, nothing caught |
| `receipts.sh` | every capture, three runs, hashed by timestamp-presence rather than by luck |
| `exercise/` | a test suite that passes against the wrong rail |

# c4-unit07 — the bean lifecycle, step by step

Course 4 · Spring Framework Core · Section 2 "Lifecycle and Scope".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-19.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.LifecycleRail
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ThrowInACallback   # four cases, one JVM
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `Kitchen.java` | the TiffinBox kitchen wired up as an **instrument**: it implements every callback the container offers and does nothing else. Not a design to copy — it exists so the order can be read off one capture instead of described |
| `Trace.java` | the instrument's recorder. The step number is the size of the list at the time, so **the count of callbacks is derived by the run** and never typed. Recording is always on; printing is not, so `ContextReport` can open a context and count without the rail's output landing inside the receipt |
| `KitchenConfig.java` | the description. The kitchen's two **named** callbacks live here, not in the class — `initMethod = "lightTheStoves"`, `destroyMethod = "lockUp"`, both strings. `RailProbe` is the `BeanPostProcessor` that brackets everything, and it is on the rail only so the order is complete |
| `LifecycleRail.java` | the whole rail in one capture, with the starting / closing / total counts derived by `Trace` |
| `ThrowInACallback.java` | the break: one callback throws, four cases in one JVM, and the question is which of the remaining callbacks still run |
| `chain.py` | the `Caused by:`-chain filter, carried unchanged from Section 1. It removes the container's own timestamped record of a cancelled refresh, **names and counts** what it removed, matches that record on Spring's own message text rather than on an English month name or the word `WARNING:`, and exits 2 if the input records a cancelled refresh and it removed none of it |
| `exercise/` | a kitchen that opens itself in its constructor |

## The rail, and the number the roadmap got wrong

The skeleton records the roadmap's guess at **eleven** callbacks. Derived from the capture:

```
callbacks while STARTING  17
callbacks while CLOSING   3
callbacks in total        20   (counted by the instrument, not typed)
```

`.r-rail{1,2,3}.out`, md5 `c302ca86bb0f5dea20386fd6e803384d`, exit 0, 3/3, 30 output lines.
Every number above is printed by the object the callbacks happened to. Nothing in this folder
states a callback count that `Trace` did not count.

Three things in that order are worth knowing and are not folklore:

1. **Nine `*Aware` setters fire before any of the four initialise hooks**, and they fire in one
   block — three from the bean factory (`BeanNameAware`, `BeanClassLoaderAware`,
   `BeanFactoryAware`) and six from the context.
2. **`BeanPostProcessor.postProcessBeforeInitialization` fires BEFORE `@PostConstruct`** in
   this configuration, at step 12 against step 13 — because `@PostConstruct` *is itself* a
   before-initialisation post-processor, and which side of yours it lands on is decided by
   post-processor ordering rather than by any rule about annotations.
3. **`SmartInitializingSingleton.afterSingletonsInstantiated` is last, after the closing
   bracket** — it is the only starting callback that waits for every *other* singleton.

## The break: which callbacks still run when one throws

```
                         callbacks that ran   the failed bean cleaned up   the FINISHED bean cleaned up
nothing throws                   7                     n/a                            true
throws in the constructor        3                     false                          true
throws in @PostConstruct         4                     false                          true
throws in the initMethod         5                     false                          true
```

`.r-throw{1,2,3}.out`, md5 `5f52591739d68c0d37ebba08be735289`, exit 0, 3/3, 30 output lines,
through `chain.py` (which names and counts the log lines it removed).

**The answer is not the one most viewers guess.** A bean whose initialisation throws is
**never registered for destruction**, so its own `@PreDestroy` and `destroy()` never run — the
object exists, it may already hold a file handle or a connection, and nothing will ever close
it. Meanwhile a bean that had *finished* is destroyed correctly, every time, in all three
failing cases. That asymmetry is the whole reason to know this: **anything that acquires a
resource belongs in a callback that cannot fail after the acquisition**, or in a constructor
that acquires nothing.

The failure receipt, all three cases (contract §2e):

```
exit 0 (the program catches it, so it can run four cases in one JVM)
org.springframework.beans.factory.BeanCreationException
  constructor : Error creating bean with name 'stove' defined in com.tiffinbox.ThrowInACallback$Config: Failed to instantiate [com.tiffinbox.ThrowInACallback$Stove]: Factory method 'stove' threw exception with message: the gas is off — stove constructor cannot finish
  @PostConstruct : Error creating bean with name 'stove': Invocation of init method failed
  initMethod   : Error creating bean with name 'stove' defined in com.tiffinbox.ThrowInACallback$Config: the gas is off — stove initMethod cannot finish
```

**Same exception type, three different sentences, and the sentence tells you which phase you
were in.** `Invocation of init method failed` is the one that means "your object was built and
then something you wrote threw".

## The receipt

```
excluded 5 infrastructure bean definitions by that filter
claims
  callbacks recorded while starting      17
  init method in the description         lightTheStoves
  destroy method in the description      lockUp
  callbacks named by Kitchen.java        15
  kitchen.customers()                    4
```

`cr` md5 `5885321b6bb0b60f6514ef51b144f1f7`, `crs` (`--stable`)
`3bd21de4c5fdd5b65ce526ae2b0785e9`, exit 0, 3/3 each, 19 output lines each.

**`excluded 5`, where the last section's captures said 4.** That is not a regression: this
project holds `jakarta.annotation-api:3.0.0`, which registers one more infrastructure
definition — and the beans unit already said on screen that the number moves when you add a
*dependency*, not only when you bump the framework. It is a count over a named filter, printed
with its filter, which is the only form this course allows.

`callbacks named by Kitchen.java  15` is derived off the class — the Spring interfaces it
implements plus its annotated methods. The other five of the twenty are named elsewhere: two
in the description, two on the post-processor, and the constructor.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project and for
`exercise/`.

## Exercise

`exercise/` starts clean and `ContextReport` says:

```
  what it knew its name to be at that moment (not set yet)
  it knew its own name when it opened    false
```

The kitchen opens itself in its constructor, which is the one moment when the container has
done nothing to the object yet. **End state:** `true`, with the same code doing the same work.
Answer in `exercise/solution/`, run by the author: md5 `069f2dfc672570deea60d57f4ed138cd`,
exit 0, 3/3. Start state md5 `b22489daf302216c1b6162c0578d4483`, exit 0, 3/3.

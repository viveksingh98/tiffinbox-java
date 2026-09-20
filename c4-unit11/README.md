# c4-unit11 — BeanFactoryPostProcessor vs BeanPostProcessor

Course 4 · Spring Framework Core · Section 2 "Lifecycle and Scope".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Framework 7.0.9**, macOS 27.0,
8-core / 16 GB Apple silicon, on 2026-09-19.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
mvn -B -q -Dmaven.repo.local="$PWD/.m2-demo" dependency:build-classpath -Dmdep.outputFile=.cp -DincludeScope=runtime
java -cp "target/classes:$(cat .cp)" com.tiffinbox.WhichHookDoINeed
java -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakEarlyReference
java -Duser.language=en -cp "target/classes:$(cat .cp)" com.tiffinbox.BreakEarlyReference > .r-breakm1.raw 2>&1 ; python3 stamp.py .r-breakm1.raw
java -cp "target/classes:$(cat .cp)" com.tiffinbox.ContextReport
```

A bare `java` on this Mac is **23.0.1** and a bare `mvn` resolves **Java 26.0.2.1** — both
measured. That is why the export is line 1.

## What is in here

| Path | What it is |
|---|---|
| `PriceList.java` · `FrozenPriceList.java` | what a meal costs, and the same thing with the door shut. `FrozenPriceList` is a **hand-written substitution**, not an interception — no generated class, nothing wrapping a method call |
| `TwoHooks.java` | the two hooks. `EditsTheDescriptions` is handed the bean factory and edits **descriptions**; `SeesEveryObject` is handed each object and edits **instances** |
| `WhichHookDoINeed.java` | the two phases in the order they happened, printed by the things they happened to |
| `BreakEarlyReference.java` | the break: a post-processor that takes a bean as a parameter, and the bean that consequently escaped the queue |
| `stamp.py` | the timestamp mask, for a capture whose log line **is** the lesson. Matched on structure, never on an English word; it counts what it masked, into the capture, and exits 2 if it masked nothing while a log record was present |
| `chain.py` | the `Caused by:`-chain filter, carried unchanged from Section 1 |
| `exercise/` | the same freezer, and one price list that got past it |

## The two phases, in the order they happened

```
refresh() begins
   1  BeanFactoryPostProcessor runs   PriceList objects that exist right now: 0 of 2 defined   (filter: getBeanNamesForType(PriceList), allowEagerInit=false)
   2    it reads a description        scope="" lazy=false
   3    it EDITS two descriptions     kitchenPrices lazy -> true, eveningPrices primary -> true
   4    @Bean eveningPrices() body runs
   5  BeanPostProcessor sees        eveningPrices : PriceList
   6    it hands back a DIFFERENT object for eveningPrices
```

`.r-hooks{1,2,3}.out`, md5 `de64427b2c42ab0b76937bfd4c714697`, exit 0, 3/3, 18 output lines.
The ordered sequence is the structure case (contract §9) and is kept complete.

**That is the whole unit and it is one number.** At step 1 the count of `PriceList` objects in
existence is **zero**, and it is a count over a named filter with `allowEagerInit=false` so
asking the question does not create the answer. The first hook runs in a world where the
descriptions exist and **no bean does**. The second hook cannot run until a bean exists,
because a bean is what it is handed.

Everything else follows:

| | `BeanFactoryPostProcessor` | `BeanPostProcessor` |
|---|---|---|
| what it is handed | the whole bean **factory** | one **object**, and its name |
| when | once, before any application bean is built | twice per bean, as each is built |
| what it can change | the **description** — scope, lazy, primary, the class name, the property values, whether the definition exists at all | the **object** — it can configure it, or hand back a different one |
| what it cannot do | know what any object will turn out to be | change a scope, add a bean, or affect anything already built |
| which one you need | "every bean of this kind should be *declared* differently" | "every bean of this kind should be *treated* differently" |

## Proof that the first one changed a description

```
after refresh
  kitchenPrices, lazy in the description   true   built yet: false
  eveningPrices, primary in the description true
```

Nothing in `TwoHooks.Config` says `lazy` or `primary`. The hook wrote both, before any of
these objects existed — and `built yet: false` is the consequence: nobody asked for
`kitchenPrices`, so its `@Bean` body never ran at all. **A description edited at startup
changes what gets built, which is something no amount of post-processing an instance can do.**

## Proof that the second one changed an instance

```
  the class your name points at            com.tiffinbox.FrozenPriceList
  it is still a PriceList                  true
  writing to it                           UnsupportedOperationException: the price list was frozen at startup
```

The class name is not the one the `@Bean` method returned. **A `BeanPostProcessor` is allowed
to hand back a different object**, and that single fact is what every startup-time feature you
will ever meet is built on.

This one **substitutes**; it does not intercept. There is no generated class here and nothing
wraps a method call — adding behaviour around every call to an object is a different mechanism
with its own section, and this unit does not open it.

## The break: a bean that escaped the queue, with exit 0

```
<timestamp> org.springframework.context.support.PostProcessorRegistrationDelegate$BeanPostProcessorChecker postProcessAfterInitialization
WARNING: Bean 'baselinePrices' of type [com.tiffinbox.PriceList] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying). Is this bean getting eagerly injected/applied to a currently created BeanPostProcessor [auditor]? …

refresh                started, and nothing threw
  kitchenPrices    FrozenPriceList                    frozen
  baselinePrices   PriceList                          WRITABLE — it never went through the freezer
  price lists that went through the post-processor   1 of 2
```

`.r-breakm{1,2,3}.out`, md5 `ac7a944a44329bedf1cc42883cdfc6c2`, exit **0**, 3/3, 10 output
lines, through `stamp.py` with the JVM's language pinned.

A post-processor has to exist before the beans it processes, so **anything it takes as a
parameter is built early** — before the rest of the post-processors are in place. That bean
then misses the treatment every other bean of its type got. The container says so and carries
on.

**Two things about that warning are worth being exact about.** It is logged at **`WARNING`**,
not at `INFO` — measured on 7.0.9, and the skeleton says `INFO`. And it names the
post-processor that caused it, in brackets, every time. So this is not a silent failure; it is
an **ignorable** one, in a wall of startup output, with exit code 0 and a consequence nothing
will mention again. The thing that finds it is the last line: a count over a named filter.

### Why this capture is masked and its language is pinned

The log line **is** the lesson here, so it is shown, not cropped — which is this track's
standing rule and is why `chain.py` deliberately does not touch it. What cannot reproduce is
the timestamp, so `stamp.py` masks that and prints how many it masked.

That leaves one more thing, and it is measured rather than assumed:

```
locale  level word printed   masked md5                          N     raw, same 3 runs   filter count
en      WARNING:            ac7a944a44329bedf1cc42883cdfc6c2    3/3   2 distinct         2
de      WARNUNG:            0dcd34bb93b8e65dd82d47285fb8f920    3/3   2 distinct         2
fr      AVERTISSEMENT:      678d01cf7c9f93e2336d9f6702301b8a    3/3   2 distinct         2
```

Nine runs, three per locale, all on disk as `.r-loc{en,de,fr}{1,2,3}`. **The raw form is not reproducible in
any locale** — two distinct values over three runs in each — so no raw hash is quoted as a fact.

**`java.util.logging` translates the level word itself**, as the middle column shows, so the line's own text differs by machine and no mask can fix that without
deleting the word the viewer needs. Hence the pinned language on the hashable command, stated
on the slide. **The filter's own count is 2 in all three locales**, which is what would flag a
filter that had quietly stopped matching: the previous section shipped a filter that a German
JVM defeated while every derived count stayed identical, and nothing noticed.

The **raw** capture is kept on screen unhashed. It gives 2 distinct values over three runs on
one pass and 1 on another, depending on whether the runs land inside the same second — so how
many distinct values you get is itself not a fact, and the register records *not reliably one*
rather than a number.

## The receipt

```
beans(app)=5
  eveningPrices   singleton  com.tiffinbox.FrozenPriceList              factory=@Bean  lazy=false
  kitchenPrices   singleton  com.tiffinbox.PriceList  (not built)       factory=@Bean  lazy=true
  ...
claims
  kitchenPrices lazy in the description  true
    and nobody asked for it, so it is    not built
  eveningPrices primary in the description true
  the class the name eveningPrices reaches com.tiffinbox.FrozenPriceList
  price lists the hook handed back changed 1 of 1 built  (of 2 defined)
  edits made before any PriceList existed 3
```

`cr` md5 `3b19a2e021903b0a907cd83c8e9cfe63`, `crs` `455ab18e0febf7e3719691fe9eafca7b`,
exit 0, 3/3 each, 20 output lines each.

`lazy=true` and `(not built)` on the `kitchenPrices` row are **the first hook's edit, visible
in the report**, and the report counts only the price lists that already exist — asking
`getBean` there would build the lazy one and the receipt would then be describing a context it
had changed.

## Reproducible offline

`mvn -o -B verify` after one warm build: `BUILD SUCCESS`, exit 0, for this project and for
`exercise/`.

## Exercise

`exercise/` starts clean and `ContextReport` says:

```
  price lists the hook handed back changed 1 of 2
  the ones it did not                    baselinePrices
```

**End state:** `2 of 2` and `(none)`. Answer in `exercise/solution/`, run by the author: md5
`c13bd7c8dde37706132ef42a39297b9a`, exit 0, 3/3. Start state, masked and language-pinned, md5
`20b2e62eaefb17dc487f9bc1b7169545`, exit 0, 3/3; its raw form is deliberately not hashed.

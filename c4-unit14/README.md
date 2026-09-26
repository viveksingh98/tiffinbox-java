# Unit 14 — @Value, SpEL and Type Conversion

Course 4 · Section 3 · *Configuration and Environment*.
**Verified on JDK 25.0.4.1**, Apache Maven 3.9.16, Spring Framework 7.0.9, macOS 27.0.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

A bare `java` here is **23.0.1** and a bare `mvn` resolves **26.0.2.1**; quote
`-Dmaven.repo.local="$PWD/.m2-demo"` because the path above this folder contains a space.

`./receipts.sh` regenerates every capture below and prints its hash.

## 1 — A string in a file becomes a typed object, and you wrote the piece that does it

```
java -cp "$CP" com.tiffinbox.TheName right
```

`.r-name-right.out` · md5 `e55c78e50b2bdb6bddd112febe2fd3fc` · exit 0 · 3 of 3.

```
config=RightName   the conversion service bean is called conversionService
conversion service beans in this context: [conversionService]
Kitchen[cooks=4, rail=kitchen, meal=NON_VEG]
```

The file says `non-veg`. The field is a `MealType`. `MealTypeConverter` is the piece in between, and
`cooks=4` is there to show what needs no help at all: Spring has always known how to make an `int`
out of `"4"`.

## 2 — THE FINDING: that bean's NAME is a contract

```
java -cp "$CP" com.tiffinbox.TheName wrong
```

`.r-name-wrong.out` · md5 `a9c14e345de3ba2c1fc00e6f3dc2d80a` · **exit 1** · 3 of 3.

The same converter, the same registration, one method renamed `myConversionService`:

```
conversion service beans in this context: [myConversionService]      <- it IS here
Exception in thread "main" …UnsatisfiedDependencyException: Error creating bean with name 'kitchen'
Caused by: …ConversionNotSupportedException: Failed to convert value of type 'java.lang.String' …
Caused by: java.lang.IllegalStateException: Cannot convert value of type 'java.lang.String' to
           required type 'com.tiffinbox.MealType': no matching editors or conversion strategy found
```

**The container looks that bean up by a well-known name.** `receipts.sh` derives the number that
makes the point:

```
  "onversionService" in the whole name-wrong capture: 2
  ...printed by this program itself:                   2
  => mentions inside the exception chain:              0
```

**Zero.** The failure is loud, three links deep, and it never once names the thing that caused it.
"No matching conversion strategy found" sends you to inspect a converter that is perfectly correct.

`Kitchen` is `@Lazy` in **both** configurations, and that is a choice about evidence rather than
about laziness: without it the misnamed run dies inside `refresh()`, before the bean list can be
printed, and the one sentence the failing run most needs to say — *the bean is here, it is just not
called what the container looks for* — could never be shown.

This is unit 06's rule with no `@Qualifier` in sight: **a bean name is a contract.**

## 3 — The break, and there are TWO silent failures in it

One typo. The file spells it `tiffinbox.meal`; the placeholder says `tiffinbox.mael`.

| | placeholder | configurer | exit | what happens |
|---|---|---|---|---|
| `withDefault` | `${tiffinbox.mael:VEG}` | none | **0** | starts, bean holds `VEG`, nothing logged |
| `noConfigurer` | `${tiffinbox.mael}` | none | **0** | starts, bean holds the **literal text** `${tiffinbox.mael}` |
| `configured` | `${tiffinbox.mael}` | registered | **1** | `Could not resolve placeholder 'tiffinbox.mael'` |

```
java -cp "$CP" com.tiffinbox.ThePlaceholder withDefault     # .r-ph-default.out  700eb594d24a187f77317d8398f106ff
java -cp "$CP" com.tiffinbox.ThePlaceholder noConfigurer    # .r-ph-literal.out  55aefce980f7ef711261e2088d95c9a9
java -cp "$CP" com.tiffinbox.ThePlaceholder configured      # trio               3a579f9f2cd167609b4e93a867d137d6
```

**Deleting the default did not make the failure loud — it made it a different silent failure.**
Row 2 is the one nobody warns you about: with no `PropertySourcesPlaceholderConfigurer` in the
context, Spring still resolves placeholders — with a **lenient** default resolver — and an unresolvable
one is left as its own text and injected. For a `String` field that starts and runs. For a converted type
the failure is a `ConversionFailedException` whose message shows the unresolved `${tiffinbox.mael}`, so the
misspelt key is visible. *(Corrected 2026-09-26 after the section's RED review: this paragraph first said the
converted type gave the same `no matching editors` message as §2 — that message appears only when no converter
is registered at all. The video's slide 6 chip repeats the old claim.)*

The third row is the fix, and it names the key.

**`PropertySourcesPlaceholderConfigurer` must be declared `static`, and unit 11 is why:** it is a
`BeanFactoryPostProcessor`, the hook that runs before any of your beans exist, so the container has
to create it without building the configuration class that declares it.

`.r-ph-named` is receipted as a **trio** (exit code · exception type · first line) rather than as
output, because Spring logs a `WARNING` with a wall-clock timestamp on that path. `receipts.sh`
decides that by looking for a timestamp, not by checking whether three runs happened to agree.

## Files

| file | what it is |
|---|---|
| `MealTypeConverter.java` | the converter you write, and it fails readably — the value as typed, how it was read, the legal values (a converter is never told the key) |
| `TiffinBoxConfig.java` | two configurations differing by ONE thing: the `@Bean` method's name |
| `TheName.java` | right vs wrong name, nothing caught, so the exit code is the real one |
| `ThePlaceholder.java` | the three placeholder cases |
| `Kitchen.java` | one bean, three values, one of which needs your converter |
| `MealType.java` | carried in from Course 2, unaltered |
| `receipts.sh` | every capture, three runs, hashed by the rule that cannot be fooled by luck |
| `exercise/` | a spice level the kitchen cannot read |

## SpEL, and how little of it is here

`${…}` is a property placeholder. `#{…}` is SpEL — an expression language the container evaluates.
**This unit does not teach SpEL at all, despite its title** (the section's RED review counted: 0 spoken
mentions, 0 `#{` in the sources) — `@Value("#{2 * 3}")` is the smallest example; the Spring reference's
`@Value` section covers it. **Unit 16 shows `${…}` again, evaluated by a
completely different engine** (Jakarta EL, inside a validation message), and says so, because
meeting the same syntax twice in one section and not being told they are different engines is how
people end up believing Spring evaluates constraint messages.

## ERRATA — after the section's RED review (2026-09-26)

The video for this unit is live. These corrections were measured after it was published; the RED report and
BLUE's re-runs are in `spring-core/_briefs/RED-S3-2026-09-26.md` (course folder).

- **With no `PropertySourcesPlaceholderConfigurer`, `${…}` is still resolved** — by a lenient default resolver.
  The configurer makes a *missing* placeholder fail instead of being injected as text (fixed in §Row 2 above).
- **"It has to be static"** is strong advice, not a rule: a non-static configurer still resolves, and Spring
  logs an INFO about it (`ThePlaceholder.java` says so). The hook it relies on was unit 11, not "last time".
- **The slide-6 chip is wrong** about the converted type (see §Row 2). The slide-2 panel line "through field
  'meal'" came from the probe; this unit's capture says "through method 'kitchen' parameter 2".
- The misnamed-bean failure appears at `getBean`, after startup, **because `Kitchen` is `@Lazy`** — eager, the
  context would refuse to start.
- **SpEL is not taught here**, despite the title (see §SpEL).

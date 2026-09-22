# Unit 16 — Validation with Jakarta Bean Validation

Course 4 · Section 3 · *Configuration and Environment*.
**Verified on JDK 25.0.4.1**, Apache Maven 3.9.16, Spring Framework 7.0.9,
Hibernate Validator 9.1.3.Final, macOS 27.0.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q      -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp-noel.txt dependency:build-classpath
mvn -q -Pel -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp-el.txt   dependency:build-classpath
mvn -q      -Dmaven.repo.local="$PWD/.m2-demo" compile
NOEL="target/classes:$(cat cp-noel.txt)"
EL="target/classes:$(cat cp-el.txt)"
```

**The EL layer is absent by default and added by `-Pel`.** One flag between "with" and "without" is
what makes the pair a measurement instead of two stories. `./receipts.sh` regenerates everything.

`jakarta.validation-api` arrives **transitively at 3.1.1** and is deliberately not declared in the
POM — declaring it would pin a version this unit did not choose. Read it off `dependency:tree`.

## 1 — The Validator, called directly

```
java -cp "$EL" com.tiffinbox.CheckAnOrder
```

`.r-el-ok.out` · md5 `bcbefb51313ceb672f09a4917672062e` · exit 0 · 3 of 3.

```
violations=3
address | invalid=[x] | address must be 2 to 40 characters
customer | invalid=[] | customer must not be blank
portions | invalid=[0] | portions must be at least 1, got 0
```

No web layer, no Boot, no controller. Constraints on a record's components, and each violation
printed as **property path · invalid value · message**. The set comes back unordered; sorting by
path is what makes two runs comparable. The program exits **2** if it does not get exactly three
violations, because a capture from an order that stopped being bad is not evidence.

## 2 — At the boundary, and the class name is the proof

```
java -cp "$EL" com.tiffinbox.AtTheBoundary
```

`.r-boundary.out` · md5 `d5e7b242e7d27f4f2ed21723907ee1d7` · exit 0 · 3 of 3.

```
the class I wrote : com.tiffinbox.AtTheBoundary$Kitchen
the class I got   : com.tiffinbox.AtTheBoundary$Kitchen$$SpringCGLIB$$<n>
same class?         false
a good order  -> cooking 2 for Ravi
a bad order   -> ConstraintViolationException, 3 violation(s), thrown before the method body ran
```

**Something is standing in front of your bean**, intercepting the call and checking the argument.
This unit does not explain what that something is — it prints its name and tells you there is a
whole section about it. The sequence number is masked because it is a counter, not a fact.

## 3 — Without an EL implementation: LOUD, and at STARTUP

`hibernate-validator-9.1.3.Final.pom` declares `jakarta.el-api` as **`provided` + `optional`**, so
nothing brings an EL implementation transitively. What that costs is not what you would guess.

```
java -cp "$NOEL" com.tiffinbox.CheckAnOrder      # .r-el-none.out   6a49b7adb3000a4f091cccb57b07bafe  exit 1
```

It throws inside `Validation.buildDefaultValidatorFactory` — **no validation ever runs**:

```
jakarta.validation.ValidationException: HV000183: Unable to initialize 'jakarta.el.ExpressionFactory'.
  Check that you have the EL dependencies on the classpath, or use ParameterMessageInterpolator instead
```

And with Spring owning the factory it is worse, which is the point:

```
java -cp "$NOEL" com.tiffinbox.SpringWired       # .r-el-spring.out  608c0a83f7331b23e0b01c2d775c3f6b  exit 1
```

```
about to refresh                          <- prints
                                          <- "REFRESHED" never does
WARNING: Exception encountered during context initialization - cancelling refresh attempt: …
Caused by: jakarta.validation.ValidationException: HV000183: …
Caused by: java.lang.NoClassDefFoundError: jakarta/el/ELManager
Caused by: java.lang.ClassNotFoundException: jakarta.el.ELManager
```

**A cancelled refresh. A dead application at startup**, with the best four-link `Caused by:` ladder
in this section. Nothing about a missing EL implementation is quiet or late.

## 4 — The break: `${…}` versus `{…}`

`HV000183` ends with *"or use ParameterMessageInterpolator instead"*. Take the library at its word:

```
java -cp "$NOEL" com.tiffinbox.TheInterpolator param   # .r-ip-noel.out  96120eec979f218ef9bf45a63ea8b9b6  exit 0
java -cp "$EL"   com.tiffinbox.TheInterpolator param   # .r-ip-el.out    96120eec979f218ef9bf45a63ea8b9b6  exit 0
java -cp "$EL"   com.tiffinbox.TheInterpolator default # .r-ip-right.out f95f1e75b36d34557bd07670e6a0e5ea  exit 0
```

| interpolator | EL jar | exit | the message your customer reads |
|---|---|---|---|
| `ParameterMessageInterpolator` | absent | 0 | `portions must be at least 1, got ${validatedValue}` |
| `ParameterMessageInterpolator` | **present** | 0 | `portions must be at least 1, got ${validatedValue}` |
| default | present | 0 | `portions must be at least 1, got 0` |

`{value}` is a **message parameter** and Hibernate Validator fills it in itself. `${validatedValue}`
is an **EL expression** and needs an implementation. They look alike and they are nothing alike.

**Rows 1 and 2 are byte-identical — the same md5, `96120eec979f218ef9bf45a63ea8b9b6`.** `receipts.sh`
checks that equality and fails if it ever stops holding, because it is the unit's central proof:
the EL jar made no difference, the **interpolator** did. A claim settled by two hashes rather than
by a sentence.

**It is not silent. It is ignorable, and that is a different thing:**

```
WARN: HV000185: Message contains EL expression: ${validatedValue}, which is not supported by the
selected message interpolator
```

Exit 0, and a warning naming the exact problem, on a line nobody reads, while a dollar sign and a
brace go to a paying customer. **Same shape as unit 11's break** — the information was in the log,
correct and specific, and it changed nothing.

*(An earlier draft of this README and of the section brief said "nothing logged". That was wrong,
and wrong because the commands used to read the captures were written with `2>/dev/null` while the
saved files contained the warning all along. A capture you hashed is not a capture you read.)*

## Files

| file | what it is |
|---|---|
| `TiffinBoxOrder.java` | constraints on a record's components — read `portions`' message |
| `CheckAnOrder.java` | the Validator, called directly, exiting 2 if the bad order stops being bad |
| `SpringWired.java` | the same missing jar with Spring owning the factory |
| `TheInterpolator.java` | the break, three ways |
| `AtTheBoundary.java` | `@Validated`, and the class name that proves a proxy is doing it |
| `jul.sh` | masks the two things that are not properties of the code, and counts them |
| `receipts.sh` | every capture, three runs, plus the byte-identity check |
| `exercise/` | a message with a dollar sign in it |

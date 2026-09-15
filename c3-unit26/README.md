# c3-unit26 — static analysis: Spotless, Checkstyle, Error Prone

Course 3 · Build & Test Like a Pro · Section 5 "Ship the Artifact".
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16**, macOS 27.0, 8-core / 16 GB Apple silicon,
on 2026-09-15, against **Error Prone 2.50.0**, **NullAway 0.14.1**, **Spotless 3.10.2** and
**Checkstyle 14.1.0** (plugin 3.6.0).

`src/main/java/com/tiffinbox/` holds the same five carried classes —
`fdb1643d622615f3c331d75deaebb9da`. **They are not modified by this unit, and two of the
three defects it finds are in them.**

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh
```

## Ten flags, or Error Prone does not run at all

Error Prone is not a separate program. It **replaces javac's own compiler class**, so it
needs to reach into `jdk.compiler`'s internals — and since the module system, `jdk.compiler`
does not export them. Without `.mvn/jvm.config` this exact project dies:

```
java.lang.IllegalAccessError: class com.google.errorprone.BaseErrorProneJavaCompiler (in
unnamed module @<id>) cannot access class com.sun.tools.javac.api.BasicJavacTask (in module
jdk.compiler) because module jdk.compiler does not export com.sun.tools.javac.api to unnamed
module @<id>
```

and Maven then tells you:

```
[ERROR] COMPILATION ERROR :
[ERROR] An unknown compilation problem occurred
exit 1
```

With the file:

```
lines in .mvn/jvm.config ......... 10
  of those, add-exports .......... 8
  of those, add-opens ............ 2
exit 0, and Error Prone produced 3 finding(s)
```

**`.mvn/jvm.config` is taught material, not setup trivia.** It cannot be a `<compilerArg>`:
Maven reads it *before* it starts its own JVM, and a flag that changes what the JVM may
access has to exist before the JVM does.

Two things about that file that cost real time:

- **It has no comment syntax.** Every line is handed to the JVM as an argument. A `#` on its
  own line becomes a main class and you get `Could not find or load main class #`.
- **Maven finds `.mvn/` by walking *up* and stops at the first one.** That is why
  `breaks/no-jvm-config/` ships an **empty** `.mvn/jvm.config` rather than none: without it,
  the break would inherit this unit's ten flags and pass. A build that works because a
  directory above it was configured is a build that stops working the day somebody moves it.

## Three findings. Green build.

```
com/tiffinbox/OrderQueue.java:[27,28] [FutureReturnValueIgnored] Return value of methods returning Future must be checked...
com/tiffinbox/OrderQueue.java:[30,27] [ReferenceEquality] Comparison using reference equality instead of value equality
com/tiffinbox/quality/MealPlan.java:[30,29] [ReferenceEquality] Comparison using reference equality instead of value equality

findings ............................ 3
  in code carried from Course Two ... 2
  in code written for this unit ..... 1
Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
exit code ........................... 0
```

**Two of the three are in the TiffinBox code the viewer wrote themselves**, in an earlier
course, and every test passes. Error Prone reports **warnings** by default. *"We run Error
Prone"* and *"Error Prone stops us"* are two different sentences.

## The red build — and the finding you did not want

`mvn -Pstrict compile` adds `-Xep:ReferenceEquality:ERROR` and nothing else:

```
com/tiffinbox/OrderQueue.java:[30,27] [ReferenceEquality] ...
com/tiffinbox/quality/MealPlan.java:[30,29] [ReferenceEquality] ...
exit 1
ReferenceEquality errors ............ 2 across 2 file(s)
```

Now read the two lines:

```
OrderQueue.java:30   if (o == CLOSED) {
MealPlan.java:30     return c.mealType() == "VEGAN";
```

`MealPlan` compares a string that came out of a database with a literal — a bug that is
true today only because both happen to be the same interned object. `OrderQueue` compares
against a **sentinel**: one private object, created once, whose whole purpose is to be
recognised by identity. Value equality would be *wrong* there.

**The answer is not to switch the check off.** It is
`@SuppressWarnings("ReferenceEquality")` on that one method with the reason in a comment —
a code review that happened once instead of every time. `exercise/solution/OrderQueue.java`
is that suppression, written out.

*(A note on counting: Maven prints each compilation ERROR twice — once where it happens and
once in the failure summary — so a bare `grep -c` over the log answers 4 for two findings.
`receipts.sh` deduplicates and says so.)*

## NullAway — and the silence that is not a pass

```
com/tiffinbox/quality/MealPlan.java:[40,16] [NullAway] unboxing of a @Nullable expression 'grams'
exit 1
lines of Java the check needed ...... 0   (no annotations were added to make it fire)
```

`Map.get` returns null for a key that is not there, the method's return type is `int`, and
the next thing that happens is an unboxing `NullPointerException`. javac is required to
accept it. The test suite never calls it with a missing key.

And the misconfiguration, which matters as much as the check:

```
java.lang.IllegalStateException: DO NOT report an issue to Error Prone for this crash!
NullAway configuration is incorrect. Must either specify annotated packages, using the
-XepOpt:NullAway:AnnotatedPackages=[...] flag, or pass -XepOpt:NullAway:OnlyNullMarked ...
[ERROR] An unknown compilation problem occurred
exit 1
```

**That is the same sentence Maven printed for the missing `jvm.config`, for a completely
different cause.** When Error Prone dies, Maven tells you nothing — so read the lines
*above* the Maven error, every time.

## Spotless — the only one that changes your files

```
mvn spotless:check
      src/test/java/com/tiffinbox/MealPlanTest.java
      src/main/java/com/tiffinbox/quality/MealPlan.java
  Run 'mvn spotless:apply' to fix these violations.
  exit 1
```

`receipts.sh` runs `spotless:apply` in a **copy**, so the shipped sources keep their
violation and the demonstration stays runnable:

```
files it changed .................. 2
import lines before ............... 3
import lines after ................ 3   (none added, none removed - reordered)
non-import lines that differ ...... 0
carried Course Two sources it touched: 0
```

Two goals rather than one, and the split is the point: **`check` is what CI runs, `apply` is
what you run.**

## Checkstyle — the flag that does nothing

```
mvn checkstyle:check ..................................... exit 0
mvn -Dcheckstyle.failOnViolation=true checkstyle:check ... exit 0
mvn -Dcheckstyle.fail=true checkstyle:check .............. exit 1
```

The middle one is the trap, and Maven says so in its own words:

```
[WARNING] checkstyle:check violations detected but failOnViolation set to false
```

**Explicit plugin `<configuration>` beats a user property.** Writing
`<failOnViolation>false</failOnViolation>` makes `-Dcheckstyle.failOnViolation` unreachable
for ever; writing `<failOnViolation>${checkstyle.fail}</failOnViolation>` keeps the switch.
The difference is invisible until the day you need the gate.

All four violations are `JavadocType` on the carried `Customer` record — **4 of 4 in code
this unit did not write, and does not touch.**

## Which one would have caught the bug?

| Tool | What it reads | What it can catch | What it cannot |
|---|---|---|---|
| **Spotless** | the bytes of your file | nothing about behaviour — but it ends the argument | any bug at all |
| **Checkstyle** | the parse tree, against rules you wrote | shape: missing javadoc, star imports, empty catch | anything that needs to know what a value *is* |
| **Error Prone** | the **typed** tree, inside javac | `==` on strings, an ignored `Future`, hundreds more | anything that needs to know whether a value is null |
| **NullAway** | the same tree, plus a null-ness analysis | exactly the null dereference above | everything Error Prone's other checks do |

Only the last two would have caught either real defect. Only the last one catches the null.

## Exercise — `exercise/`

See `exercise/README.md`. **Start state:** `mvn -Pnullaway clean compile` exits **1**.
**End state:** `-Pnullaway` and `-Pstrict` both exit **0**, tests still green, without
deleting a check or widening a profile. Answers: `exercise/solution/MealPlan.java` and
`exercise/solution/OrderQueue.java` — the shipped sources stay exactly as they are.

## Receipts

| Block | What it proves |
|---|---|
| `jvmconfig` | ten flags, or Error Prone does not run — exit 1, then exit 0 |
| `warnings` | three real findings and `BUILD SUCCESS`, exit 0 |
| `strict` | the red build, and the finding that is correct about the syntax and wrong about the code |
| `nullaway` | the null bug as a red build, and the misconfiguration that looks like the other failure |
| `spotless` | check, then apply, in a copy |
| `checkstyle` | the `-D` that is silently ignored, and the one that is not |
| `solution` | the exercise, start state asserted before it is answered |
| `offline` | `mvn -o test` after a warm **`verify`** — Spotless and Checkstyle resolve there, not at `test` |

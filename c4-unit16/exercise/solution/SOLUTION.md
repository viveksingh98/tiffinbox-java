# Solution

Both fixes work. **State which you picked and why** — that is the exercise, not the edit.

## Fix 1 — bring an EL implementation

```
mvn -q -Pel -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp-el.txt dependency:build-classpath
```

and delete the `.messageInterpolator(new ParameterMessageInterpolator())` line, so the default
interpolator runs. Then `${validatedValue}` resolves and the message reads
`a run may carry at most 12 boxes, this one has 20`.

**Cost:** `jakarta.el-api` 6.0.1 and `expressly` 6.0.0 on the class path, and an expression language
evaluating strings from your constraint annotations. That is fine when the strings are yours. It is
worth a thought when a message could ever be assembled from something a user typed.

## Fix 2 — stop writing EL in messages

```java
@Max(value = 12, message = "a run may carry at most {value} boxes")
```

`{value}` is a message **parameter** — the constraint's own attribute, filled in by Hibernate
Validator with no EL anywhere. Works with `ParameterMessageInterpolator`, works without the jars.

**Cost:** you cannot name the offending value. The customer is told the limit but not what they
asked for, and "at most 12" is a less useful sentence than "at most 12, you asked for 20".

## The half people skip

Before either fix, `stderr` already said:

```
WARN: HV000185: Message contains EL expression: ${validatedValue}, which is not supported by the
selected message interpolator
```

Correct, specific, names the expression and the interpolator — and it changed nothing, because it
scrolled past. **Ignorable is not the same as silent**, and a class of bug that only announces
itself on a line nobody reads is the reason this course keeps saying a green run is not evidence.

# Unit 24 — Exceptions: When Things Go Wrong

**What this unit teaches:** An exception is an object that climbs the call chain: read the trace, catch what you can handle, throw your own.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit24`), in the order below.

### java Trace.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** read the stack trace bottom-up: `main` → `averagePerMeal` → `average`.

```console
$ java Trace.java
Exception in thread "main" java.lang.ArithmeticException: / by zero
	at Trace.average(Trace.java:8)
	at Trace.averagePerMeal(Trace.java:5)
	at Trace.main(Trace.java:2)
```

Exit code: `1` (non-zero — the failure is the point).

### java Catch.java

`try / catch / finally` — the program survives.

```console
$ java Catch.java
No meals today: / by zero
Report closed
Program continues
```

### java Throw.java

`throw` your own, and catch two types in one block.

```console
$ java Throw.java
veg x 2 = 240
non-veg x 1 = 150
Skipped: unknown meal type: vge
Skipped: Index 3 out of bounds for length 3
```

### java FixChecked.java

The checked exception handled with `try/catch`.

```console
$ java FixChecked.java
1 customers on file
```

### java BreakChecked.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** a checked exception that is neither caught nor declared.

```console
$ java BreakChecked.java
BreakChecked.java:2: error: unreported exception IOException; must be caught or declared to be thrown
    var lines = Files.readAllLines(Path.of("customers.csv"));
                                  ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

### Notes

- `FixChecked.java` writes and then reads `customers.csv` in this folder; it is git-ignored. Delete it with `rm customers.csv` if you want a clean slate.

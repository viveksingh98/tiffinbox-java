# Unit 36 — Debugging in IntelliJ

**What this unit teaches:** Breakpoints, Frames and Variables, step over vs step into — hunting a real off-by-one instead of guessing.

**You need:** JDK 25 (`java.lang.IO` is an ordinary class, JEP 512). Verified on JDK 25.0.4.1. These files declare `package com.tiffinbox;`, so the single-file launcher refuses them (`java MonthReport.java` → `end of path to source file does not match its package name`) — compile with `-d` as shown.

Run everything from this folder (`cd unit36`), in the order below.

### javac -d out MonthReport.java Billing.java

The FIXED report — the loop total and the formula agree.

```console
$ javac -d out MonthReport.java Billing.java && java -cp out com.tiffinbox.MonthReport
September total: 7200
Formula says:    7200
```

### javac -g -d out/buggy buggy/MonthReport.java Billing.java — **supposed to be wrong**

> **This one is supposed to give the wrong answer — that is the lesson.** the same file with Unit 09's boundary bug (`day < daysInMonth`, 29 rounds). It compiles and runs; the number is just wrong — that is what you debug. `-g` keeps the variable names the debugger shows.

```console
$ javac -g -d out/buggy buggy/MonthReport.java Billing.java && java -cp out/buggy com.tiffinbox.MonthReport
September total: 6960
Formula says:    7200
```

### Notes

- In IntelliJ: drop `buggy/MonthReport.java` and `Billing.java` into a project, set a breakpoint on the `total +=` line, press Debug, and watch `total` climb to 6960 while `day` stops at 29.
- `out/` is git-ignored; `rm -rf out` resets the unit.

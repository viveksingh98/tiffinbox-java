# Unit 09 — Loops: Doing It 30 Times

**What this unit teaches:** The `for` header in three parts, the `<` vs `<=` boundary trap, `while`, `break`/`continue` and loop scope.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit09`), in the order below.

### java MonthLoop.java

The 30-day loop — `<=` vs `<` decides 30 rounds or 29.

```console
$ java MonthLoop.java
30-day bill: 7200
```

### java Wallet.java

`while` — you do not know the count in advance.

```console
$ java Wallet.java
8 days of tiffin, 80 left
```

### java SkipSundays.java

`continue` skips Sundays, `break` stops at the budget.

```console
$ java SkipSundays.java
Budget alert on day 24
Total so far: 5040
```

### java WeekPreview.java

The enhanced `for` over an array.

```console
$ java WeekPreview.java
Mon: tiffin delivered
Tue: tiffin delivered
Wed: tiffin delivered
Thu: tiffin delivered
Fri: tiffin delivered
Sat: tiffin delivered
Sun: tiffin delivered
```

### java BreakScope.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** the loop variable does not exist after the loop.

```console
$ java BreakScope.java
BreakScope.java:6: error: cannot find symbol
    IO.println("Stopped on day " + day);
                                   ^
  symbol:   variable day
  location: class BreakScope
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

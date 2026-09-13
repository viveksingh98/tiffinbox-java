# Unit 06 — Operators and Expressions: Ravi's Monthly Bill

**What this unit teaches:** Operators are the verbs of an expression: arithmetic, `%`, precedence, comparison, `&&`/`||` and integer division.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit06`), in the order below.

### java Bill.java

Ravi's bill, weeks and leftover days, the 10% discount, and two booleans.

```console
$ java Bill.java
Monthly bill: 7200
Full weeks: 4
Leftover days: 2
After 10% off: 6480
Regular: true, big spender: true
```

### java Shortcuts.java

`+=`, `-=`, `++` — the shorthand forms.

```console
$ java Shortcuts.java
Bill: 7000, meals: 3
```

### java Skipped.java

Integer division truncates to `0.0` until one side is a `double`.

```console
$ java Skipped.java
Skipped: 0.0%
Skipped: 23.333333333333332%
Skipped: 23.3%
```

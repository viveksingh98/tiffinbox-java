# Unit 03 — Your First Program: Hello, TiffinBox

**What this unit teaches:** Read a Java program line by line, run it from the terminal, and meet the classic `public static void main` form.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit03`), in the order below.

### java Hello.java

The compact JDK 25 form.

```console
$ java Hello.java
Hello, TiffinBox!
```

### java Hello.java (from `classic/`)

The same program in the classic `public class` + `public static void main` form.

```console
$ cd classic
$ java Hello.java
Hello, TiffinBox!
```

### java Hello.java (from `broken/`) — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** the missing semicolon.

```console
$ cd broken
$ java Hello.java
Hello.java:2: error: ';' expected
    IO.println("Hello, TiffinBox!")
                                   ^
1 error
error: compilation failed
```

Exit code: `1` (non-zero — the failure is the point).

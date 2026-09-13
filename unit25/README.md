# Unit 25 — Custom Exceptions and Clean Error Handling

**What this unit teaches:** An exception with TiffinBox's name on it, the cause chain, try-with-resources, and why swallowing is a bug.

**You need:** JDK 25 (compact source files + `IO.println`, JEP 512). Verified on JDK 25.0.4.1.

Run everything from this folder (`cd unit25`), in the order below.

### java CustomException.java

`class TiffinBoxException extends RuntimeException`, thrown by the setter.

```console
$ java CustomException.java
Rejected: meals a day must be 1 to 3, got -5
Ravi still eats 2
```

### java Resource.java

Try-with-resources closes the log even when the body throws.

```console
$ java Resource.java
log opened
log: Ravi delivered
log closed
Rejected: meals a day must be 1 to 3, got 9
```

### java Swallow.java — **supposed to be wrong**

> **This one is supposed to give the wrong answer — that is the lesson.** an empty `catch` block: the failure vanishes, the program lies and exits 0. That silence is the bug.

```console
$ java Swallow.java
Bill for Ravi: 7200
```

### java Cause.java — **supposed to fail**

> **This one is supposed to fail — that is the lesson.** wrapping the original exception as the cause, so both halves print.

```console
$ java Cause.java
Exception in thread "main" Cause$TiffinBoxException: no meals recorded for Sunil
	at Cause.averagePerMeal(Cause.java:8)
	at Cause.main(Cause.java:2)
Caused by: java.lang.ArithmeticException: / by zero
	at Cause.averagePerMeal(Cause.java:6)
	at Cause.main(Cause.java:2)
	at java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:104)
	at java.base/java.lang.reflect.Method.invoke(Method.java:565)
	at jdk.compiler/com.sun.tools.javac.launcher.SourceLauncher.execute(SourceLauncher.java:256)
	at jdk.compiler/com.sun.tools.javac.launcher.SourceLauncher.run(SourceLauncher.java:138)
	at jdk.compiler/com.sun.tools.javac.launcher.SourceLauncher.main(SourceLauncher.java:76)
```

Exit code: `1` (non-zero — the failure is the point).

# Unit 02 — Install JDK 25 and IntelliJ (Mac + Windows)

**What this unit teaches:** Install JDK 25 and IntelliJ, then prove the toolchain works with a first-run check.

**You need:** JDK 25 on your PATH. Verified on JDK 25.0.4.1. (`Main.java` is the classic form IntelliJ generates, so it also runs on JDK 21+.)

Run everything from this folder (`cd unit02`), in the order below.

### java -version

The install check — any 25.x line means the JDK is on your PATH.

```console
$ java -version
openjdk version "25.0.4.1" 2026-08-18
OpenJDK Runtime Environment Homebrew (build 25.0.4.1)
OpenJDK 64-Bit Server VM Homebrew (build 25.0.4.1, mixed mode, sharing)
```

### java Main.java

The sample program IntelliJ writes, with the text changed to `Hello, TiffinBox!`.

```console
$ java Main.java
Hello, TiffinBox!
```

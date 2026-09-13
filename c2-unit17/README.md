# c2-unit17 — Structured Concurrency and Scoped Values (JDK 25.0.4.1)
`StructuredTaskScope` is a **preview API in Java 25 (JEP 505)** — every command that touches it needs `--enable-preview`.
Single file: `java --enable-preview Scope.java` · `java --enable-preview ScopeFail.java` · `java --enable-preview Scoped.java`.
Compiled: `javac --enable-preview --release 25 -d out Scope.java` then `java --enable-preview -cp out Scope` (the flag is needed at **both** steps).
`ScopedValue` is final in Java 25 (JEP 506) and needs no flags at all: `java SvOnly.java`.

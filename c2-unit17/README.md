# c2-unit17 — Structured Concurrency and Scoped Values (JDK 25.0.4.1)

What it teaches: tasks forked inside a `try`-block are joined before that block exits — no leaked
threads, no orphaned work — and `ScopedValue` carries per-request context into them without a
`ThreadLocal`.

`StructuredTaskScope` is a **preview API in Java 25 (JEP 505)**, so every command that touches it
needs `--enable-preview`. `ScopedValue` is final in Java 25 (JEP 506) and needs no flag at all.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
```

## Run the single files

```bash
java --enable-preview Scope.java
```
```
subtasks forked: 4
Meera -> 4500
Priya -> 3600
Ravi -> 7200
Sunil -> 9000
scope closed: every subtask has finished
```
(each run also prints `Note: Scope.java uses preview features of Java SE 25.` on stderr — that is
javac, not your code.)

```bash
java --enable-preview ScopeFail.java
```
```
join threw:    java.util.concurrent.StructuredTaskScope$FailedException
because:       java.util.NoSuchElementException: no price card for Kiran
Kiran subtask: FAILED
Ravi subtask:  UNAVAILABLE   <- cancelled, not waited for
scope cancelled? true
```
It **exits 0** — the failure is caught and reported. One subtask failing cancels its siblings;
`UNAVAILABLE` is the proof that Ravi's fork was never waited for.

```bash
java --enable-preview Scoped.java
```
```
bound in main before where(): false
bill for Ravi on a virtual thread
pause check for Ravi on a virtual thread
bound in main after  where(): false
```

```bash
java SvOnly.java            # no flag: ScopedValue is final in 25
```
```
current customer: Ravi
bound outside? false
```

## Compiled, not single-file — the flag is needed at BOTH steps

```bash
javac --enable-preview --release 25 -d out Scope.java
java  --enable-preview -cp out Scope
```

Leave the flag off the `java` step and the class will not even load:

```
Error: LinkageError occurred while loading main class Scope
	java.lang.UnsupportedClassVersionError: Preview features are not enabled for Scope
	(class file version 69.65535). Try running with '--enable-preview'
```

`--release 25` matters too: a preview class file is stamped with the exact JDK that built it, so
JDK 26 will not run it and JDK 25 will not run a 26 one. That is the deal with preview APIs.

Check everything in this folder at once: `../verify_course2.sh 17`

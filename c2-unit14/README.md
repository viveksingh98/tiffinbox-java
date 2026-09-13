# c2-unit14 — Locks, Atomics and Concurrent Collections (JDK 25.0.4.1)
Run the four compact source files directly: `java Atomics.java` · `java Revenue.java` · `java Snapshot.java` · `java TryLock.java` (no flags).
Deadlock demo (classic class): `javac -d out Deadlock.java && java -cp out Deadlock` — it hangs on purpose.
In a second shell: `jcmd <pid> Thread.print` shows `Found one Java-level deadlock`, then ALWAYS `kill -9 <pid>` and confirm with `pgrep -fl "cp out Deadlock"`.
`java NaturalRace.java` is the honesty demo — the same bug with no baton, which does NOT throw on every run.

# c2-unit11 — Threads: Two Cooks in One Kitchen

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`); all five are compact source files, no flags:
- `java States.java` — thread lifecycle read from `main`: `NEW` / `TIMED_WAITING` / `BLOCKED` / `TERMINATED` (6 runs, byte-identical; the `CountDownLatch` + two `Thread.sleep` calls only stabilise the *observation*).
- `java Cooks.java` — two named platform threads, `join()` before the first print: morning `11700`, evening `12600`, total `24300` (6 runs, byte-identical, md5 `50cc0ae3`).
- `java StartVsRun.java` — `run()` executes on `main` and leaves the thread `NEW`; `start()` runs it on `cook-2` and leaves it `TERMINATED` (5 runs, byte-identical). `java Daemon.java` — the JVM exits with the daemon `kettle` still looping (5 runs, byte-identical).
- `java StartTwice.java` — fails on purpose: `IllegalThreadStateException` at `Thread.java:1416` / `StartTwice.java:6` (5 runs, byte-identical; the JDK line number is a 25.0.4.1 capture — re-run on JDK 27).

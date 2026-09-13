# c2-unit12 — Race Conditions, synchronized and the Memory Model

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`):
- `java LostUpdate.java` — the race. **8 runs gave 8 different values** (1026861 · 1809196 · 1790150 · 846568 · 1314415 · 1059108 · 1558679 · 1027929); never `2000000`, never the same twice. Nothing to pin — that is the lesson.
- `java VolatileNotEnough.java` — `static volatile int` still loses updates: 6 runs, 6 different values (1348199 · 1332974 · 1120292 · 1054827 · 1143250 · 1154426). `volatile` = visibility, not atomicity.
- `java Synced.java` — `synchronized (counterLock)` fixes it: **6 runs byte-identical**, `actual:   2000000` every time. · `java Interleave.java` — `Semaphore` baton forces one order so the log is stable: 6 runs byte-identical (md5 `a06e61b082486a34e3b0312cc46e62b9`). · `javac -d out Counter.java && javap -c -p -cp out Counter` — `getstatic` / `iconst_1` / `iadd` / `putstatic`.
- `java BadMonitor.java` — fails on purpose: `IllegalMonitorStateException: current thread is not owner` at `BadMonitor.main(BadMonitor.java:5)`; 5 runs byte-identical. Fix: `synchronized (counterLock) { counterLock.wait(); }`.

# c2-unit15 — Virtual Threads: A Million Waiters (JDK 25.0.4.1)
No flags: `java Waiters.java` · `java PoolWaiters.java` (takes about 50 s on purpose) · `java Probe15.java` · `java Ghost.java` · `java VirtualOops.java` (throws on purpose).
Carrier count pinned so your numbers match mine: `java -Djdk.virtualThreadScheduler.parallelism=4 -Djdk.virtualThreadScheduler.maxPoolSize=4 Carriers.java`
JEP 491 proof, one carrier for the whole JVM: `java -Djdk.virtualThreadScheduler.parallelism=1 -Djdk.virtualThreadScheduler.maxPoolSize=1 Pinning.java` — prints `all finished: true` on JDK 24+; on Java 21/22 the same file prints `all finished: false`.
The two `about N s` lines in `Waiters` / `PoolWaiters` are clocks and they move; the `completed: 10000` line above each is the fixed one.

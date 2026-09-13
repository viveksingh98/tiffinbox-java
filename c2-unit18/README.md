# c2-unit18 — TiffinBox Order Queue: Producers, Consumers, BlockingQueue (JDK 25.0.4.1)
Run the two compact source files directly, no flags: `java Pipeline.java` · `java QueueOops.java`.
`Pipeline.java` — one producer, a `LinkedBlockingQueue`, three cooks on `Executors.newVirtualThreadPerTaskExecutor()`, a `CLOSED` poison pill per cook and a `CountDownLatch(3)`; prints `120 / 120 / true / 3` and the four anchor totals summing to `24300`, byte-identical on every run (6/6, md5 `a846b7b6…`).
`QueueOops.java` — an `ArrayBlockingQueue<String>(2)`: `offer` drops silently, then `add` on line 11 throws `IllegalStateException: Queue full` and the JVM exits 1 (6/6 byte-identical, md5 `5d1d2085…`).
Per-cook counts are deliberately never printed — that split differs on every run; the per-customer totals are fixed by arithmetic.

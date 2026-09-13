# c2-unit13 — Executors, Thread Pools and Future

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`); all four are compact source files, no flags:
- `java Pool.java` — 40 customers billed in a fixed pool of 4; results collected with `Future.get()`, sorted, then printed. 6 runs byte-identical (md5 `55946c77935b727594d3648d7a3f24e8`): `customers billed: 40`, `distinct pool threads: 4`, `month total: 243000`.
- `java InvokeAll.java` — `invokeAll` blocks until all four tasks finish and returns the futures in task-list order: `Ravi -> 7200` / `Meera -> 4500` / `Sunil -> 9000` / `Priya -> 3600`. 6 runs byte-identical.
- `java Names.java` — cross-check that a fixed pool of 4 really creates 4 threads: `[pool-1-thread-1 … -4]` plus `cores: 8` (core count is this Mac's — yours will differ). 6 runs byte-identical.
- `java PoolOops.java` — fails on purpose: a swallowed `ArithmeticException` surfaces only as `ExecutionException` on `get()`, then a submit after `close()` throws `RejectedExecutionException` at `PoolOops.main(PoolOops.java:17)`. 6 runs: the three teaching lines byte-identical; the rejection message differs only in `@` object hash codes and the lambda's hex class name.

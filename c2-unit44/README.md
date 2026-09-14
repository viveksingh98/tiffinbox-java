# c2-unit44 — What's Next: Build & Test Like a Pro, Then Spring (JDK 25.0.4.1)
Run: `java -Xmx64m Finale.java` — one compact source file, the `-Xmx64m` flag is required so the heap line prints `64 MB` on every machine.
`Finale.java` — the closing panel of Course 2: `main` is six `IO.println` lines, one per section you finished — heap ceiling, a generic signature next to its erased bytecode form, four virtual threads joined through `invokeAll`, a CSV written and read back, `Order`'s record components via reflection, and `Gatherers.windowFixed(2)`.
Every number is fixed by arithmetic, not by timing: the kitchen total `810` is one day of the four anchor customers (Ravi 2×120 · Meera 1×150 · Sunil 3×100 · Priya 1×120) — exactly one thirtieth of the order rail's `24300`.
Verified on JDK 25.0.4.1 (`/opt/homebrew/opt/openjdk@25`): **6 runs, byte-identical**, md5 `55eb095d09181185ff28e5fc98721f6f`. Re-capture on JDK 27 — line 2 prints the JVM's own erasure output.

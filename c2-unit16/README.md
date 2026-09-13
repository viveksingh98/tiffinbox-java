# c2-unit16 — CompletableFuture: Composing Async Work (JDK 25.0.4.1)
Run the compact source files directly, no flags: `java Compose.java` · `java Recover.java` · `java CfOops.java`.
`Compose.java` → `all four stages done: true`, four sorted bills, `month total: 24300` (deterministic: `allOf().join()` then `Collections.sort`).
`CfOops.java` exits with status 1 on purpose — an unjoined failed stage stays silent until `join()` throws `CompletionException`.
`NoUnwrap.java` is the honesty demo: `ex.getCause()` is null on the `orTimeout` path, so it dies with a `NullPointerException` — that is why `unwrap` exists.

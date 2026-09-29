# Solution — make @Async take your executor

**Why B is wrong.** The INFO line Spring logs in B says it:
`No task executor bean found for async processing: no bean of type TaskExecutor and no bean named 'taskExecutor' either`.
`@Async`'s default lookup (Spring Framework's, not Boot's) takes the one bean of type `TaskExecutor`, or else a bean named
`taskExecutor`. `kitchenExecutor` is a plain `java.util.concurrent.Executor` with another name, so Spring falls back to a
`SimpleAsyncTaskExecutor`: one new thread per call. (In A, `@Async` reached Boot's pool through an `AsyncConfigurer` Boot
registers itself; it sits inside the configuration that backs off in B, so it went with the pool.)

**Three answers.** Each file below was copied over `exercise/demo/KitchenExecutorConfig.java`, and `exercise/README.md`'s
commands were run exactly as written — in zsh, from the unit's folder, `./receipts.sh` included (it passed each time:
five captures `= published`). Measured 2026-09-29, JDK 25.0.4.1, Spring Boot 4.1.1. The last command printed:

| file | what it changes | the last command's two lines |
|---|---|---|
| `exercise/demo/KitchenExecutorConfig.java` (as shipped) | nothing — this is B | `Executor beans: kitchenExecutor (a ThreadPoolExecutor, core pool size 3)` · `@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 20 threads, named SimpleAsyncTaskExecutor-#` |
| `named/demo/KitchenExecutorConfig.java` | 1 · the name: the `@Bean` method is `taskExecutor()` | `Executor beans: taskExecutor (a ThreadPoolExecutor, core pool size 3)` · `@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 3 threads, named kitchen-#` |
| `typed/demo/KitchenExecutorConfig.java` | 2 · the type: a `ThreadPoolTaskExecutor` (Spring's `TaskExecutor`), core = max = 3, prefix `kitchen-` | `Executor beans: kitchenExecutor (a ThreadPoolTaskExecutor, core pool size 3)` · `@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 3 threads, named kitchen-#` |
| `configurer/demo/KitchenExecutorConfig.java` | 3 · say it outright: the class implements `AsyncConfigurer` | `Executor beans: kitchenExecutor (a ThreadPoolExecutor, core pool size 3)` · `@Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 3 threads, named kitchen-#` |

In all four runs Boot's pool stays out (`applicationTaskExecutor` is absent): one `Executor` bean of yours is enough for
that, whatever its name or type.

**A trap on the way to answer 2, measured.** Wrapping the JDK pool in Spring's `TaskExecutorAdapter` also routes the calls
(`20 calls ran on 3 threads, named kitchen-#`) — and then the JVM never exits. `TaskExecutorAdapter` has no `close()` or
`shutdown()` (javap, spring-core 7.0.9), so the context cannot shut the pool down, and its three non-daemon threads keep
the process alive; the run had to be killed (exit 143). A `ThreadPoolTaskExecutor` is shut down by the context on close.

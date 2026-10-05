# Solution — one variable, `SPRING_THREADS_VIRTUAL_ENABLED`

The switch is the property `spring.threads.virtual.enabled`. From the shell it is the variable
`SPRING_THREADS_VIRTUAL_ENABLED`: the key in upper case, its dots turned into underscores — the same shape as the
property-sources lesson's `TIFFINBOX_COOKS`. Written in front of the command, it reaches that one run only. From
`c5-unit18/`, after `exercise/README.md`'s commands:

```bash
cd .harness/mine/after && SPRING_THREADS_VIRTUAL_ENABLED=true java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" threads.VThreads --tiffinbox.port=18899
```

(Still in `.harness/mine/after` from the README's last command? Then drop the `cd .harness/mine/after && `.)

## Measured — `exercise/README.md` run exactly as written, then the line above (2026-10-05)

In a clean shell — `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash`: no variable of
mine, Homebrew's `bin` for `mvn` and `openssl` — from `c5-unit18/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo`.
The README's eight lines ran as written; the last one's two streams were saved to files (standard output: Boot's log, 18
lines, not shown here). The token file: `-rw-------`, 33 bytes (32 hex characters and a newline), never printed.

The README's last line — the switch not set. Standard error, whole:

```
the switch, as the environment holds it: spring.threads.virtual.enabled = (not set)
Boot's executor, the bean applicationTaskExecutor: org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor
20 tasks -> distinct threads 8 · virtual [false]
  daemon [false] · names task-1 … task-8
Boot's scheduler, the bean taskScheduler: org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler
  job a, its first 3 firings -> distinct threads 1 · job b, its first 3 firings -> distinct threads 1
  the 6 firings -> distinct threads 1 · used by both jobs 1 · virtual [false] · daemon [false] · names scheduling-1
the context's beans of type java.util.concurrent.Executor: 2 · applicationTaskExecutor taskScheduler
TiffinBox's own executors, read through private fields (this harness's trick, reflection):
  TiffinBox's HttpServer executor: java.util.concurrent.ThreadPerTaskExecutor
  TiffinBox's OrderQueue executor: java.util.concurrent.ThreadPerTaskExecutor
```

The line above, with the variable — the switch on. Standard error, whole:

```
the switch, as the environment holds it: spring.threads.virtual.enabled = true · from systemEnvironment
Boot's executor, the bean applicationTaskExecutor: org.springframework.core.task.SimpleAsyncTaskExecutor
20 tasks -> distinct threads 20 · virtual [true]
  daemon [true] · names task-1 … task-20
Boot's scheduler, the bean taskScheduler: org.springframework.scheduling.concurrent.SimpleAsyncTaskScheduler
  job a, its first 3 firings -> distinct threads 3 · job b, its first 3 firings -> distinct threads 3
  the 6 firings -> distinct threads 6 · used by both jobs 0 · virtual [true] · daemon [true] · names scheduling-2 scheduling-3 scheduling-4 scheduling-5 scheduling-6 scheduling-7
the context's beans of type java.util.concurrent.Executor: 2 · applicationTaskExecutor taskScheduler
TiffinBox's own executors, read through private fields (this harness's trick, reflection):
  TiffinBox's HttpServer executor: java.util.concurrent.ThreadPerTaskExecutor
  TiffinBox's OrderQueue executor: java.util.concurrent.ThreadPerTaskExecutor
```

Twenty tasks on twenty threads, every one virtual; the switch came from `systemEnvironment` — the variable, not a flag; and
TiffinBox's own server executor is the class it was: `java.util.concurrent.ThreadPerTaskExecutor`. Both runs exited 0 and
left 18899 free.

`receipts.sh`'s `exercise` capture runs the same eight README lines and this solution's line, exactly as written, three times
(`.r-exercise.out`); its checks fail if a line the README calls **Done** is missing from the solution's run, or from this file.

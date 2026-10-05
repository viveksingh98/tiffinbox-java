# c5-unit18 — Virtual Threads in Boot

Course 5 · Spring Boot · Section 3 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-10-05.
TiffinBox has run on virtual threads since the Core Java II capstone: its own code builds three executors, every one
`Executors.newVirtualThreadPerTaskExecutor()`. Boot has one switch for virtual threads, `spring.threads.virtual.enabled`
(default `false`). This unit flips it and measures what moves: two bean methods behind one bean name, picked by a condition;
Boot's executor (twenty tasks on eight platform threads, then on twenty virtual threads); Boot's scheduler (six firings on one
shared thread, then on six virtual threads); whether Boot's threads are daemons. And what does not move: TiffinBox's own
executors, read before and after, the context's two executor beans (both Boot's), the seven responses, and the two Java
threads a thread dump of TiffinBox lists as not daemons.

**No anchor change (brief ⚑7).** `c5-tiffinbox` is not touched, and this unit freezes no `after/`. Every run uses a **copy** of
the frozen tree — `../c5-unit13/after/`, TiffinBox as the executable-jar lesson left it (the anchor today) — at
`.harness/after/`, built there, clean and offline. Nothing here writes into another unit's folder. Every number the video
speaks is asserted; three runs per capture; and no capture, no README and no slide holds the demo token (masked, and counted:
*The demo token*).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 5 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) `receipts.sh` **dies**
when a capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can see which one moved
(tested 2026-10-05: with `own`'s published hash altered by one character, the run printed `own … DIFFERS from the published aeee8dbf…`, stopped with exit 1 and released its lock; `receipts.md5` was restored). A whole run takes about 1 min 15 s on the author's Mac (one build, then 5 captures × 3; the exercise capture
builds its own copy each time).

**The repository.** Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the script): a copy of
`../c5-unit13/.m2-demo`, plus the Section 3 seed `spring-boot/_research/m2-seed-s3/`, copied with `rsync --ignore-existing` and
**without its `com/tiffinbox/`** (locally installed TiffinBox jars, markers naming no repository). The seed added nothing the
copy lacked. Every `_remote.repositories` marker says `central`. Nothing was downloaded. The build prints
`built .harness/after · offline: yes` (or `no - …`) on the terminal; the exercise's README builds with `mvn -o` too.

## No anchor change — and why

The switch stays off in TiffinBox, because nothing of TiffinBox's would change (this unit's `switch` and `alive` captures:
its executors and its responses are the same both ways), and because the next lesson's AOT processing would freeze it (*For
the next units*, below: measured by hand). The roadmap's line for this unit — "the request thread name printed before and
after" — is answered with TiffinBox's own server, as the brief decided: its executor is `ThreadPerTaskExecutor` before and
after. An embedded Tomcat's request threads are Course 6's (Spring Web MVC, its embedded Tomcat lesson), named on a chip.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token (the secrets lesson). Every run starts in `.harness/after`, which holds a
config tree, `secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is
fake and looks it — where the frozen tree's README puts a token; `receipts.sh` writes it when it runs (`.harness/` is
git-ignored). The token never reaches a command line: the seven requests read it from the file (`$CURLSET PORT TOKENFILE`).
Every capture is masked — the token becomes `[masked: the 26-character token]` (`gsub`) — and `receipts.sh` counts the raw token
in each run's own output **before** masking (`.harness/raw-*`: 0 in all 15 capture runs), then in every capture, this README,
the exercise, the harness and `receipts.md5`: 0. The builder counts it again in the script, the deck and the prompter: 0. The
exercise's own runs use a token of their own (`openssl rand -hex 16`), which nothing prints.

## The folders, the variables and the ports

- `.harness/after/` — the copy of the frozen tree, built clean; its README's extract command, run as written, unpacks its jar
  into `tiffinbox-web/target/extracted/` (a thin jar and `lib/`, 31 jars); its `secrets/` is the token's config tree. Every
  run starts here.
- `.harness/classes/` — the harness, `harness/threads/VThreads.java`, compiled against the extracted jars. Package `threads`,
  outside `com.tiffinbox`, so TiffinBoxApp's component scan never finds it; its `Jobs` configuration lives in the harness's own
  class, and no `@Bean` method is involved. It starts TiffinBox's context (`TiffinBoxApp` + `Jobs`), prints its findings to
  standard error (standard output is Boot's log), closes the context and returns. It reads two private fields by reflection —
  `TiffinBoxServer.server` and `OrderQueue.executor` — which is the harness's own trick, not something TiffinBox offers.
- `.harness/mine/` — the exercise's copy (`exercise/README.md` builds it; `receipts.sh` runs that README, so it rebuilds it).
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson (Course 4's seven requests,
  POST /shutdown with the token's header read from a file) — its folder carries a unit number, so no slide prints the path;
  `$pid` = the java process `receipts.sh` started. Every other command is printed whole.
- Ports (brief ⚑10, 18890-18899, checked free with `lsof` before anything is wiped, 18425 too): `decides` A and A′ 18890, B 18891 ·
  `switch` A and A′ 18892, B 18893 · `alive` A 18894, B 18895 · the exercise 18899 (its README's own port). 18896-18898 unused.

## Masks, filters and hygiene — every one, declared

1. **Paths and the token:** in every line of every capture (`gsub()`, the patterns escaped as literals): the demo token →
   `[masked: the 26-character token]`; this folder's absolute path → `…`, also in its URL-encoded form; the folder above it →
   `…/..`; the home folder → `~`. A last check fails if any capture still holds `/Users/`, `/private/` or `/home/`, and the
   builder refuses a capture that holds a unit number.
2. **Nothing else is masked, because nothing else printed varies.** Thread names are printed as sorted sets: `task-1 … task-8`,
   `task-1 … task-20`, `scheduling-1`, `scheduling-2 … scheduling-7` — the same in every run measured (3/3 per capture, and six
   more runs by hand for the virtual scheduler). Which job ran on which thread does move from run to run, so the harness never
   prints it. Thread ids, PIDs and timings are never printed. (The brief planned a mask for the scheduler's thread numbers; the
   measurement made it unnecessary.)
3. **Boot's log** is counted, never printed whole: its line count (172 with `--debug`, 176 with the switch on; 18 in a harness
   run), its WARN and ERROR lines. From the `--debug` report, `decides` prints the two blocks of the bean methods named
   `applicationTaskExecutor…` (whole, in whichever section they sit), every `OnThreadingCondition` line counted with the block it
   sits in, and the methods it matched.
4. **javap:** only each bean method's signature (packages cut by `gsub`) and the values of its `@Bean` and
   `@ConditionalOnThreading`; javap's other lines are counted (168).
5. **The thread dump** (`jcmd "$pid" Thread.print`, taken once `main` has returned — the dump is polled until no thread is named
   `main`, because TiffinBox listens before `main` returns): only the Java threads (a `#<number>` after the name) without the
   word `daemon`, their names sorted and counted, and the HTTP-Dispatcher's frame from `sun.net.httpserver` (the JDK version and
   the line number cut by `sub`). The daemon threads are not counted: their number moves with the virtual threads' carriers.
6. **The exercise's setup lines** (seven of the README's eight) are counted, not printed: they name the frozen tree's folder,
   which carries a unit number. They run exactly as written.
7. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS` and `MAVEN_ARGS` before it runs anything — so `SPRING_THREADS_VIRTUAL_ENABLED` reaches only the run that writes it
   in front of its command (the exercise's solution); it refuses to run twice at once in this folder (`.r-lock`), or with a
   `secrets/` in this folder.

**Interrupted.** `receipts.sh`'s exit trap stops the JVM it started in the background, if one still runs, and drops the
lock — on a failed check and on Ctrl-C alike (a background job of a non-interactive shell ignores the terminal's Ctrl-C).
Every command in the trap is guarded, so `set -e` cannot end it early, and `$pid` is cleared after every reap; the harness runs
are started in the background too, so a hung one can be stopped (60 s). Tested 2026-10-05: `SIGINT` sent to the script's
process group the moment `decides` A's JVM listened on 18890 → `receipts.sh` exited 130; 5 s later nothing listened on
18890-18899, no java process ran a TiffinBox jar or the harness, and `.r-lock` was gone. Tested again with the harness running: `SIGINT` the moment `switch` B's run listened on 18893 → exit 130, the same clean state.


## 1 · own — the threads TiffinBox starts itself

`.r-own.out` `feee8dbf9ba5e483e7dbb57d4ea178c1` — 11 lines

```
TiffinBox as the executable-jar lesson froze it (the anchor today) - a copy, .harness/after, built clean:
$ cd .harness/after && grep -rno --include='*.java' 'Executors\.[A-Za-z]*()' .
  ./tiffinbox-core/src/main/java/com/tiffinbox/Dashboard.java:40:Executors.newVirtualThreadPerTaskExecutor()
  ./tiffinbox-core/src/main/java/com/tiffinbox/OrderQueue.java:24:Executors.newVirtualThreadPerTaskExecutor()
  ./tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java:194:Executors.newVirtualThreadPerTaskExecutor()
  executors: 3 · each one newVirtualThreadPerTaskExecutor: 3
$ cd .harness/after && grep -rnoE --include='*.java' 'Thread\.of[A-Za-z]*\(\)|new Thread\(' .
  ./tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java:152:Thread.ofPlatform()
  threads started by hand: 1 · a platform thread among them: 1
$ cd .harness/after && grep -rlE --include='*.java' 'org\.springframework\.(scheduling|core\.task)|@Async|@Scheduled' .
  files that name Spring's task or scheduling packages, @Async or @Scheduled: 0 · Java files searched: 10
```

Three executors, every one the JDK's virtual-thread executor: Dashboard's (inside a method), OrderQueue's and the server's
(fields). One platform thread started by hand — `Thread.ofPlatform().start(this::stop)`, the stop after POST /shutdown — which is
not an executor. No file names Spring's task or scheduling packages, `@Async` or `@Scheduled`: TiffinBox never asks Spring for a
thread.

## 2 · decides — the switch, its default, and the condition that reads it (A/B/A′)

`.r-decides.out` `74ed2a4dc9e9178a07792cd8346c3149` — 53 lines

```
the switch in Boot's own metadata (META-INF/spring-configuration-metadata.json, in the jars the frozen tree's jar carries):
  spring.threads.virtual.enabled · in spring-boot-autoconfigure-4.1.1.jar · type java.lang.Boolean · defaultValue false
  its description: Whether to use virtual threads.
  properties in those metadata files with "virtual" in their name: 1 · spring.threads.virtual.enabled
the bean methods that build the bean named applicationTaskExecutor, read from Boot's class file (javap: each method's
signature, packages cut, and the values of its @Bean and @ConditionalOnThreading; javap's other lines not shown):
$ cd .harness/after && javap -v -cp tiffinbox-web/target/extracted/lib/spring-boot-autoconfigure-4.1.1.jar 'org.springframework.boot.autoconfigure.task.TaskExecutorConfigurations$TaskExecutorConfiguration'
  SimpleAsyncTaskExecutor applicationTaskExecutorVirtualThreads(SimpleAsyncTaskExecutorBuilder) · @Bean(["applicationTaskExecutor"]) · @ConditionalOnThreading(VIRTUAL)
  ThreadPoolTaskExecutor applicationTaskExecutor(ThreadPoolTaskExecutorBuilder) · @Bean(["applicationTaskExecutor"]) · @ConditionalOnThreading(PLATFORM)
  javap printed 168 lines; the class's methods, its constructor aside: 2, each one above
the run command the frozen tree's README gives: java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
A - the switch not set (Boot's default) · that command, from .harness/after, its port 18431 made 18890, --debug after it:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18890 --debug
  listens on: 127.0.0.1:18890 · WARN lines 0 · ERROR lines 0
$ $CURLSET 18890 .harness/after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: 172 lines · the report's blocks for the two bean methods named applicationTaskExecutor:
   TaskExecutorConfigurations.TaskExecutorConfiguration#applicationTaskExecutor matched:
      - @ConditionalOnThreading found PLATFORM (OnThreadingCondition)
   TaskExecutorConfigurations.TaskExecutorConfiguration#applicationTaskExecutorVirtualThreads:
      Did not match:
         - @ConditionalOnThreading did not find VIRTUAL (OnThreadingCondition)
  OnThreadingCondition lines in the report: 4 · each under a bean method of TaskExecutorConfigurations or TaskSchedulingConfigurations: 4
  bean methods it matched: 3 · applicationTaskExecutor simpleAsyncTaskExecutorBuilder simpleAsyncTaskSchedulerBuilder
B - the same command, the switch on after --debug, port 18891:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18891 --debug --spring.threads.virtual.enabled=true
  listens on: 127.0.0.1:18891 · WARN lines 0 · ERROR lines 0
$ $CURLSET 18891 .harness/after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: 176 lines · the report's blocks for the two bean methods named applicationTaskExecutor:
   TaskExecutorConfigurations.TaskExecutorConfiguration#applicationTaskExecutor:
      Did not match:
         - @ConditionalOnThreading did not find PLATFORM (OnThreadingCondition)
   TaskExecutorConfigurations.TaskExecutorConfiguration#applicationTaskExecutorVirtualThreads matched:
      - @ConditionalOnThreading found VIRTUAL (OnThreadingCondition)
  OnThreadingCondition lines in the report: 6 · each under a bean method of TaskExecutorConfigurations or TaskSchedulingConfigurations: 6
  bean methods it matched: 3 · applicationTaskExecutorVirtualThreads simpleAsyncTaskExecutorBuilderVirtualThreads simpleAsyncTaskSchedulerBuilderVirtualThreads
A' - A re-run:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18890 --debug
  listens on: 127.0.0.1:18890 · WARN lines 0 · ERROR lines 0
$ $CURLSET 18890 .harness/after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: 172 lines · the report's blocks for the two bean methods named applicationTaskExecutor:
   TaskExecutorConfigurations.TaskExecutorConfiguration#applicationTaskExecutor matched:
      - @ConditionalOnThreading found PLATFORM (OnThreadingCondition)
   TaskExecutorConfigurations.TaskExecutorConfiguration#applicationTaskExecutorVirtualThreads:
      Did not match:
         - @ConditionalOnThreading did not find VIRTUAL (OnThreadingCondition)
  OnThreadingCondition lines in the report: 4 · each under a bean method of TaskExecutorConfigurations or TaskSchedulingConfigurations: 4
  bean methods it matched: 3 · applicationTaskExecutor simpleAsyncTaskExecutorBuilder simpleAsyncTaskSchedulerBuilder
```

The switch is one property in Boot's metadata, `java.lang.Boolean`, default `false` — the only one with "virtual" in its name
in the jars TiffinBox carries. Boot reads it with a condition on a `@Bean` method (Course 4's mechanism): two methods of
`TaskExecutorConfigurations$TaskExecutorConfiguration` build the bean named `applicationTaskExecutor`, one
`@ConditionalOnThreading(PLATFORM)` (a `ThreadPoolTaskExecutor`), one `(VIRTUAL)` (a `SimpleAsyncTaskExecutor`). TiffinBox's own
jar with `--debug`: A (not set) — the platform method matched, the virtual one did not; B (on) — the reverse; A′ = A, line for
line (asserted). Every `OnThreadingCondition` line of the report sits under a bean method of Boot's task configurations (4 of 4,
6 of 6: the counts differ — *Found on the way*). Three methods matched each way — the executor and two builders. And the seven responses: `115c36ba…` every run.

## 3 · switch — what the switch reaches, and what it leaves alone (A/B/A′)

`.r-switch.out` `997ffe69e8eed1bed2d470200d6d1323` — 47 lines

```
the harness's class path, from the frozen tree's own jar - its README's extract command, run as written in .harness/after:
$ cd .harness/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  tiffinbox-web/target/extracted: lib tiffinbox-web-1.0.0.jar · lib/: 31 jars
the README's class-path command, the harness's classes (.harness/classes) in front, its main class threads.VThreads:
  java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
A - the switch not set (Boot's default):
$ cd .harness/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" threads.VThreads --tiffinbox.port=18892
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
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18892 now: 0
B - the switch on:
$ cd .harness/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" threads.VThreads --tiffinbox.port=18893 --spring.threads.virtual.enabled=true
the switch, as the environment holds it: spring.threads.virtual.enabled = true · from commandLineArgs
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
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18893 now: 0
A' - A re-run:
$ cd .harness/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" threads.VThreads --tiffinbox.port=18892
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
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18892 now: 0
```

The harness's class path comes from the frozen tree's own jar: its README's extract command, run as written, and its README's
class-path command with `../classes` in front and the harness as the main class. **Boot's executor:** A `ThreadPoolTaskExecutor`
— twenty 100 ms tasks on 8 platform threads, not daemons, `task-1 … task-8`; B `SimpleAsyncTaskExecutor` — 20 virtual threads,
daemons, `task-1 … task-20`; A′ = A. **Boot's scheduler** (it exists because the harness's `Jobs` enables scheduling — TiffinBox
schedules nothing): A `ThreadPoolTaskScheduler` — each job's first three firings on one thread, `scheduling-1`, used by both
jobs; B `SimpleAsyncTaskScheduler` — six firings on six virtual threads, none shared. **What stays:** the context's beans of type
`Executor` — 2, `applicationTaskExecutor taskScheduler`, both Boot's — and TiffinBox's own executors, read through private fields:
`java.util.concurrent.ThreadPerTaskExecutor` (the class behind `Executors.newVirtualThreadPerTaskExecutor()`), all three runs.
The third executor, Dashboard's, lives inside a method, where no field reaches it.

## 4 · alive — what holds TiffinBox's JVM open

`.r-alive.out` `f2a16bdbc033d89b11d4321035de631a` — 21 lines

```
Boot's own metadata (META-INF/spring-configuration-metadata.json), its entry for spring.main.keep-alive:
  spring.main.keep-alive · in spring-boot-4.1.1.jar · defaultValue false
  its description: Whether to keep the application alive even if there are no more non-daemon threads.
A - the switch not set · the frozen tree's run command, from .harness/after, its port 18431 made 18894:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18894
  listens on: 127.0.0.1:18894 · WARN lines 0 · ERROR lines 0
$ jcmd "$pid" Thread.print     ($pid: the java process this script started)
  Java threads that are not daemons: 2 · "DestroyJavaVM" "HTTP-Dispatcher"
  "HTTP-Dispatcher", its frame from the JDK's HTTP server (version and line cut): sun.net.httpserver.ServerImpl$Dispatcher.run(jdk.httpserver)
$ $CURLSET 18894 .harness/after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B - the switch on, port 18895:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18895 --spring.threads.virtual.enabled=true
  listens on: 127.0.0.1:18895 · WARN lines 0 · ERROR lines 0
$ jcmd "$pid" Thread.print     ($pid: the java process this script started)
  Java threads that are not daemons: 2 · "DestroyJavaVM" "HTTP-Dispatcher"
  "HTTP-Dispatcher", its frame from the JDK's HTTP server (version and line cut): sun.net.httpserver.ServerImpl$Dispatcher.run(jdk.httpserver)
$ $CURLSET 18895 .harness/after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

TiffinBox's own jar, A not set and B on: the Java threads a thread dump lists as not daemons are the same two — `DestroyJavaVM`
(the JVM's own, waiting once `main` has returned) and `HTTP-Dispatcher` (its frame: `sun.net.httpserver.ServerImpl$Dispatcher.run`,
the JDK's HTTP server). Core Java II's rule, quoted on screen: the machine never waits for daemons, and every virtual thread is
one. So the switch's daemons (the `switch` capture: Boot's task threads `daemon [false]` → `daemon [true]`) cannot change what
holds TiffinBox open. Boot's metadata describes `spring.main.keep-alive` — "Whether to keep the application alive even if there
are no more non-daemon threads." — default `false`. It is **not measured here**, and nothing is claimed about its behaviour.

## 5 · exercise — the README's commands, then the solution's

`.r-exercise.out` `0a9c1a2df733e778392eabd664dd78b1` — 31 lines

```
exercise/README.md's commands, run exactly as written from this folder:
  its first 7 lines - copy the frozen tree to .harness/mine/after, build it offline, extract its jar, compile the harness, write a token:
  exit 0 · printed: 0 line(s) · the token: 33 bytes, -rw------- · .harness/mine/classes: 3 classes
  its last line:
$ cd .harness/mine/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" threads.VThreads --tiffinbox.port=18899
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
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18899 now: 0
the solution's command (exercise/solution/SOLUTION.md), run exactly as written:
$ cd .harness/mine/after && SPRING_THREADS_VIRTUAL_ENABLED=true java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" threads.VThreads --tiffinbox.port=18899
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
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18899 now: 0
```

`exercise/README.md`'s eight lines run exactly as written (seven counted, the last printed): a copy of the frozen tree at
`.harness/mine/after`, built offline, unpacked, the harness compiled, a token of its own; the switch not set → 8 threads. Then
`exercise/solution/SOLUTION.md`'s line, exactly as written: `SPRING_THREADS_VIRTUAL_ENABLED=true` in front of the same command →
`= true · from systemEnvironment`, 20 virtual threads, and TiffinBox's server executor unchanged. The three lines the README
calls **Done** are checked against this capture and against SOLUTION.md.

## Exercise

`exercise/README.md` — **Your turn:** switch virtual threads on with an environment variable, count the threads twenty tasks
used, then name TiffinBox's server executor. The README builds `.harness/mine` (a copy of the frozen tree, offline), runs the
harness once with the switch not set (`20 tasks -> distinct threads 8 · virtual [false]`), and asks for the switch on with no
command-line flag. Done is three lines of the harness's output:

```
the switch, as the environment holds it: spring.threads.virtual.enabled = true · from systemEnvironment
20 tasks -> distinct threads 20 · virtual [true]
  TiffinBox's HttpServer executor: java.util.concurrent.ThreadPerTaskExecutor
```

Run exactly as written in a clean shell (`env -i`, only `HOME` and a system `PATH` with Homebrew's `bin`):
`exercise/solution/SOLUTION.md` (the variable `SPRING_THREADS_VIRTUAL_ENABLED`, the property-sources lesson's shape).

## Found on the way

- **The switch freezes under AOT, both ways** — a side measurement for the next lesson, by hand (*For the next units*).
- **"HTTP-Dispatcher, its only non-daemon thread" (brief) is two threads, counted:** `DestroyJavaVM` is a non-daemon Java
  thread too — the JVM's own, waiting once `main` has returned. `receipts.sh` takes the dump only once no thread is named
  `main` (it polls): TiffinBox's server listens during the context's refresh, before `run` returns, so a dump taken the moment
  it listens could still list `main`.
- **Boot's pool threads are not daemons.** Switch not set, the 8 `task-` threads and `scheduling-1` are platform threads with
  `daemon [false]`; switched on, every thread of Boot's that the harness saw is a virtual daemon. (The harness closes its
  context before it returns, so nothing here tests what those threads would hold open.)
- **The virtual scheduler's names are stable as a set** (`scheduling-2 … scheduling-7` in every run); only the pairing of job and
  thread moves. With the switch on, `scheduling-1` ran none of the six recorded firings; what it is was not measured.
- **The report's asymmetry:** 4 `OnThreadingCondition` lines with the switch not set, 6 with it on. In A, the two
  `…BuilderVirtualThreads` methods come after their platform twins, whose beans already exist: they fail on
  `@ConditionalOnMissingBean`, and the report gives that reason only. In B, the platform twins come first and fail on the
  threading condition itself (their `@ConditionalOnMissingBean` matched).
- **`spring.threads.virtual.enabled` is the only property with "virtual" in its name** in the metadata of the jars TiffinBox
  carries (4 metadata files). Here, every condition that reads it sits in Boot's task configurations (`decides`); other
  starters, not on this class path, were not looked at.
- **Unit 13's script says "the last course" for Course 3** ("The last course defined a fat jar", and three more lines): the
  last course before Course 5 is Course 4; the fat-jar definition is Course 3 unit 23's. Not this unit's to change — for RED.

## For the next units — 19 — and for RED

**Unit 19 (AOT): the switch is decided at build time, in both directions.** Measured by hand on 2026-10-05, 3 runs each (not a
capture of this unit; unit 19 re-measures). Two copies of the frozen tree under `.harness/aotprobe/` (git-ignored, wiped by the
next `receipts.sh`), each built with Boot's parent's `native` profile, which runs `spring-boot:4.1.1:process-aot`:

```
mvn -o -B -Pnative -Dmaven.repo.local=<this unit's .m2-demo> -DskipTests clean package                       # "built off"
mvn -o -B -Pnative -Dmaven.repo.local=<…> -DskipTests "-Dspring-boot.aot.jvmArguments=-Dspring.threads.virtual.enabled=true" clean package   # "built on"
```

The generated `TaskExecutorConfigurations__BeanDefinitions.java` names `applicationTaskExecutorVirtualThreads` only in the copy
built on. Each jar extracted as the frozen tree's README says, then `aot-side/AotSwitch.java` (TiffinBoxApp's context, main
class TiffinBoxServer so the generated initializer is found; it prints Boot's executor and the threads twenty tasks ran on),
from the copy's folder: `java -Dspring.aot.enabled=<false|true> -cp "<classes>:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" threads.AotSwitch --tiffinbox.port=18896 [--spring.threads.virtual.enabled=true]`:

```
[built off] aot false · switch (not set) · applicationTaskExecutor ThreadPoolTaskExecutor · 20 tasks -> distinct threads 8 · virtual [false]
[built off] aot false · switch true · applicationTaskExecutor SimpleAsyncTaskExecutor · 20 tasks -> distinct threads 20 · virtual [true]
[built off] aot true · switch (not set) · applicationTaskExecutor ThreadPoolTaskExecutor · 20 tasks -> distinct threads 8 · virtual [false]
[built off] aot true · switch true · applicationTaskExecutor ThreadPoolTaskExecutor · 20 tasks -> distinct threads 8 · virtual [false]
[built on] aot false · switch (not set) · applicationTaskExecutor ThreadPoolTaskExecutor · 20 tasks -> distinct threads 8 · virtual [false]
[built on] aot false · switch true · applicationTaskExecutor SimpleAsyncTaskExecutor · 20 tasks -> distinct threads 20 · virtual [true]
[built on] aot true · switch (not set) · applicationTaskExecutor SimpleAsyncTaskExecutor · 20 tasks -> distinct threads 20 · virtual [true]
[built on] aot true · switch true · applicationTaskExecutor SimpleAsyncTaskExecutor · 20 tasks -> distinct threads 20 · virtual [true]
```

- Under `-Dspring.aot.enabled=true`, the switch at run time is **read and ignored**: the environment says `true` and the executor
  is the pool (built off); the environment says *not set* and the executor is virtual (built on). Without
  `spring.aot.enabled`, the same jars follow the switch at run time.
- The brief's probe measured the first direction only (`aot=true … ThreadPoolTaskExecutor · virtual flag true`); the second
  is new. `-Dspring-boot.aot.jvmArguments=…` is the property that carried the switch into `process-aot` here.
- TiffinBox's own executors are untouched either way (plain JDK calls, no bean) — not re-measured under AOT.
- Ports: the side measurement used 18896 (this unit's range).

**RED:** the brief's "two jobs share `scheduling-1` off; on, each firing gets its own virtual thread" holds (1 thread, used by
both; 6 threads, 0 shared). "20 tasks on 8 platform threads, then 20 virtual" holds. "HTTP-Dispatcher, its only non-daemon
thread" is two (above). The brief's planned `scheduler` capture is a slice of `switch` (one A/B/A′ for all three observers).

# c5-unit06 — Property Sources and Their Precedence

Course 5 · Spring Boot · Section 2 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-29.
One key, `tiffinbox.cooks`, set in five places at once, and the property source that answers. Then what TiffinBox's own
`@PropertySource` file costs — it ranks last, and it arrives too late for the keys Boot reads first — and the change that
retires it: the file renamed `application.properties`, `@PropertySource` and the port bridge deleted. **The run command
changes here, for the first time in Course 5.**

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it. "Before" is `../c5-unit04/after/` (the
anchor as the last unit left it), **copied** to `.harness/before/` and built there, so this unit never writes into another
unit's folder. Clean builds, offline first; every number the video speaks is asserted; three runs per capture.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) `receipts.sh`
**dies** when a capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can see which one
moved. The builds try `mvn -o` against this unit's `.m2-demo` first and resolve from Maven Central only if that fails.

## The harness — TiffinBox's own `main`, watched

`harness/com/tiffinbox/harness/` holds two plain classes, **no annotations**, so TiffinBox's `@ComponentScan("com.tiffinbox")`
(which registers annotated classes only) never picks them up. Neither copies TiffinBox's start-up: each calls the tree's
own `TiffinBoxServer.main(args)` — bridge or no bridge, whatever that tree's `main` does — inside Boot's
`SpringApplication.withHook(…)`, whose run listener is handed the context `main` starts.

- `Winner <key> <the arguments TiffinBox's main gets>` — after start-up, walks the live `Environment`'s property sources
  **in order** and prints what each holds for the key (with Boot's `Origin` where the source tracks one), the first source
  that holds it, the bean field the key ends up in (read off the live bean), and the arguments Boot kept as non-option
  arguments. Then it closes the context, which stops TiffinBox's server.
- `When <key,key> <the arguments TiffinBox's main gets>` — reads the keys at five steps of `SpringApplication.run` and
  prints them after start-up: *environment prepared* (Boot's own listeners for that step have run; the harness's is added
  after them) · *context loaded* (the last step before refresh) · *refresh: row-2 step begins* and *done* (the two callbacks
  of a definition-registry hook handed straight to the context — the container runs such hooks **before** the ones it finds
  as beans, `ConfigurationClassPostProcessor` among those, and calls the second callback after every definition-registry
  hook has run) · *context refreshed*. At each step: each key's value, the number of property sources, and whether
  `System.getLogger("tiffinbox")` — the logger TiffinBoxServer writes its route lines through — would log DEBUG.

**`$BEFORE` and `$AFTER`** are the harness's classes plus that tree's jars (`tiffinbox-web-1.0.0.jar` and `lib/*.jar`);
`receipts.sh` writes them to `.harness/before.classpath` and `.harness/after.classpath`. Every command below is printed
exactly as it runs: `receipts.sh` passes it to `eval`, so those two variables expand when it runs. The jar runs (`java -jar
tiffinbox-web-1.0.0.jar …`) are started in that tree's `tiffinbox-web/target`.

The small files: `places/application.properties` is Boot's own file for the "before" tree (`tiffinbox.cooks=4`), put on
the class path by `-cp "$BEFORE:places"`. `late/tiffinbox-file/tiffinbox.properties` is TiffinBox's own file plus two
lines, and `late/boot-file/application.properties` is those two lines alone; each folder goes first on the class path, and
`When` prints which file the class path gives for each name. `outside/` holds `application.properties` (8) and
`config/application.properties` (9): Boot reads `./` and `./config/` from the **working directory** — the folder the
java command is started from, which need not be the jar's.

**Ports** (Section 2 brief ⚑11: 18660-18669): stack and ladder 18660 · A and A′ 18661 · B's bare number 18662 (never bound)
· late 18663 · the bridge's positional 18664 (never bound) and its flag 18665 · serve 18666 and 18667 · outside and ignored
18668 · the exercise 18669. **B binds 18425**, the file's port, by design — that is the break. `receipts.sh` first checks
that nothing listens on 18425 or on any of its own ports, and stops B at once (`POST /shutdown`, about a second).

## Masks, filters and hygiene — every one, declared

1. Boot's own log lines (each starts with an ISO timestamp and carries a pid) are dropped from a harness report and
   counted; so are the lines printed before the report (the banner and its blank lines): the last line of each report says
   how many of each (`… elided: N log line(s) of Boot's, and M line(s) printed before the report …`).
2. In `ignored`, TiffinBox's `orders cooked:` log message is kept with everything before it cut by `sub()` (time, level,
   pid, thread, logger).
3. `change` shows every changed code line (git's diff, `-U0`); comment and blank lines are counted on the header line, not
   shown.
4. No token is masked inside a kept line: nothing in these captures carries a time, a pid or an absolute path.
5. Hygiene: `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS` and `JDK_JAVA_OPTIONS`
   before it runs anything — a variable of yours would otherwise become a sixth place. It also refuses to run twice at
   once in this folder (`.r-lock`): two runs share `.harness/` and the ports.

## 1 · One key, five places

`.r-stack.out` `8e7a890bbdf7854dfdf4ac6e3c1b6992`

```
$ TIFFINBOX_COOKS=5 java -Dtiffinbox.cooks=6 -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660 --tiffinbox.cooks=7
exit 0
KEY tiffinbox.cooks -> WINNER 7 · from source 2 of 8, commandLineArgs
   1 configurationProperties    7   (Boot's view over the sources below it)
   2 commandLineArgs            7
   3 systemProperties           6
   4 systemEnvironment          5   origin: System Environment Property "TIFFINBOX_COOKS"
   5 random                     -
   6 Config resource 'class path resource [application.properties]' via location 'optional:classpath:/' 4   origin: class path resource [application.properties] - 2:17
   7 applicationInfo            -
   8 class path resource [tiffinbox.properties] 3
the bean's own field: OrderQueue.cooks = 7
non-option arguments Boot kept: [18660]
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

Seven on the command line, six as a system property, five in an environment variable, four in Boot's own file, three in
TiffinBox's. The live `Environment` has **8** property sources: **5** hold the key; the first, `configurationProperties`,
is Boot's view over the sources below it (it answers with whatever they hold: here 7, the winner); `random` and
`applicationInfo` hold nothing for it. The command line answers, and the bean's own field says the same: 7. TiffinBox's
`@PropertySource` file is **8 of 8** — last. The last course's order still holds *inside* the list — system properties,
then environment variables, then your file (C4/32: "The first one that has the key answers") — and Boot adds the command
line above it and its own file between the variables and yours (`receipts.sh` checks all five positions). The bare
`18660` is a non-option argument: Boot keeps it, and in this tree `main`'s bridge reads it.

## 2 · The ladder — the top place taken away, one at a time

`.r-ladder.out` `6a46bf68545b4f7975cc2caba35c78ee`

```
A   five places
$ TIFFINBOX_COOKS=5 java -Dtiffinbox.cooks=6 -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660 --tiffinbox.cooks=7
  exit 0 · KEY tiffinbox.cooks -> WINNER 7 · from source 2 of 8, commandLineArgs
  the bean's own field: OrderQueue.cooks = 7
    the command-line flag taken away
$ TIFFINBOX_COOKS=5 java -Dtiffinbox.cooks=6 -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660
  exit 0 · KEY tiffinbox.cooks -> WINNER 6 · from source 3 of 8, systemProperties
  the bean's own field: OrderQueue.cooks = 6
    the system property taken away
$ TIFFINBOX_COOKS=5 java -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660
  exit 0 · KEY tiffinbox.cooks -> WINNER 5 · from source 4 of 8, systemEnvironment
  the bean's own field: OrderQueue.cooks = 5
    the environment variable taken away
$ java -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660
  exit 0 · KEY tiffinbox.cooks -> WINNER 4 · from source 6 of 8, Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
  the bean's own field: OrderQueue.cooks = 4
    Boot's file taken away: TiffinBox's own file alone
$ java -cp "$BEFORE" com.tiffinbox.harness.Winner tiffinbox.cooks 18660
  exit 0 · KEY tiffinbox.cooks -> WINNER 3 · from source 7 of 7, class path resource [tiffinbox.properties]
  the bean's own field: OrderQueue.cooks = 3
A′  A, re-run
$ TIFFINBOX_COOKS=5 java -Dtiffinbox.cooks=6 -cp "$BEFORE:places" com.tiffinbox.harness.Winner tiffinbox.cooks 18660 --tiffinbox.cooks=7
  exit 0 · KEY tiffinbox.cooks -> WINNER 7 · from source 2 of 8, commandLineArgs
  the bean's own field: OrderQueue.cooks = 7
```

7 → 6 → 5 → 4 → 3, each answered by the next place down, and the bean's field equal to the winner every time. With Boot's
file gone TiffinBox's file finally answers — from source 7 of 7, last again. A′ is A re-run: the same command, the same
lines (`receipts.sh` compares the two blocks).

## 3 · Last, and too late

`.r-late.out` `622e616707fec849b1467b0166995769`

```
late/tiffinbox-file/tiffinbox.properties is TiffinBox's own file plus the two lines of late/boot-file/application.properties: yes
$ java -cp "late/tiffinbox-file:$BEFORE" com.tiffinbox.harness.When logging.level.tiffinbox,spring.main.banner-mode 18663
exit 0 · route DEBUG lines 0 · banner lines 1 · WARN lines 0 · ERROR lines 0
step of SpringApplication.run logging.level.tiffinbox   spring.main.banner-mode   sources  logger tiffinbox logs DEBUG
environment prepared          -                         -                         6        no
context loaded                -                         -                         6        no
refresh: row-2 step begins    -                         -                         6        no
refresh: row-2 step done      debug                     off                       7        no
context refreshed             debug                     off                       7        no
where each value was found, after refresh:
  logging.level.tiffinbox  <-  class path resource [tiffinbox.properties]
  spring.main.banner-mode  <-  class path resource [tiffinbox.properties]
the file the class path gives for tiffinbox.properties: late/tiffinbox-file/tiffinbox.properties
the file the class path gives for application.properties: none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
$ java -cp "late/boot-file:$BEFORE" com.tiffinbox.harness.When logging.level.tiffinbox,spring.main.banner-mode 18663
exit 0 · route DEBUG lines 5 · banner lines 0 · WARN lines 0 · ERROR lines 0
step of SpringApplication.run logging.level.tiffinbox   spring.main.banner-mode   sources  logger tiffinbox logs DEBUG
environment prepared          debug                     off                       7        yes
context loaded                debug                     off                       7        yes
refresh: row-2 step begins    debug                     off                       7        yes
refresh: row-2 step done      debug                     off                       8        yes
context refreshed             debug                     off                       8        yes
where each value was found, after refresh:
  logging.level.tiffinbox  <-  Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
  spring.main.banner-mode  <-  Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
the file the class path gives for tiffinbox.properties: tiffinbox-web-1.0.0.jar!/tiffinbox.properties
the file the class path gives for application.properties: late/boot-file/application.properties
… elided: 12 log line(s) of Boot's, and 0 line(s) printed before the report (the banner and its blank lines) …
```

The same two lines — `logging.level.tiffinbox=debug` (a logging level decides how much a logger prints; DEBUG is the most)
and `spring.main.banner-mode=off` — in two places. **In TiffinBox's own file** the `Environment` ends up holding both, yet
**0** route DEBUG lines print, the banner prints anyway, exit 0, and **0** WARN lines. `When` shows why: when Boot prepares
the environment — the step at which its logging listener sets the levels; the banner is decided before refresh too — TiffinBox's
file is not there (6 sources). It arrives **inside refresh, in the row-2 step** (6 → 7): the configuration-class
post-processor reads `@PropertySource` there. (The last section took that hook out — `../c5-unit04/`, `.r-hook.out`, B —
and TiffinBox's file was never read: `tiffinbox.days null`.) By then the level is set, and it never changes: DEBUG stays
"no". **In Boot's file** the two keys are there from the first step, DEBUG is on from the first step, **5** route lines, no
banner. TiffinBox's file loses twice: last, and too late.

## 4 · The bridge — and the crash it keeps

`.r-bridge.out` `6571008b3e225005c868166f92b4014a`

```
$ java -cp "$BEFORE" com.tiffinbox.harness.Winner tiffinbox.port 18664 --tiffinbox.port=18665
exit 0
KEY tiffinbox.port -> WINNER 18665 · from source 2 of 7, commandLineArgs
   1 configurationProperties    18665   (Boot's view over the sources below it)
   2 commandLineArgs            18665
   3 systemProperties           18664
   4 systemEnvironment          -
   5 random                     -
   6 applicationInfo            -
   7 class path resource [tiffinbox.properties] 18425
the bean's own field: TiffinBoxServer.port = 18665 · its server's socket: 127.0.0.1:18665
non-option arguments Boot kept: [18664]
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
the same tree's own jar, in its tiffinbox-web/target, a flag first and no port:
$ java -jar tiffinbox-web-1.0.0.jar --debug
exit 1 · Caused by: java.lang.NumberFormatException: For input string: "--debug" · listening lines 0
```

The old `main` copied its first argument into the system property `tiffinbox.port` — the bridge Course 4 needed so that
`java -jar … <port>` kept working. Under Boot a system property ranks below the command line: given both, the flag wins
(18665), and the server's socket says so. The bridge's only other effect is the crash: with a flag first and no port flag,
it copies `--debug` into the port, and start-up dies before anything listens (exit 1).

## 5 · The change

`.r-change.out` `62351f0d0b93939bc83c95569bd6a7b0`

```
files, README aside: the previous tree 14 · after/ 14 · in both 13: identical 11, changed 2
  only before: tiffinbox-web/src/main/resources/tiffinbox.properties
  only after:  tiffinbox-web/src/main/resources/application.properties
  the same bytes under the new name: yes
TiffinBoxApp.java, every changed line but comments and blanks (9 of those not shown):
-import org.springframework.context.annotation.PropertySource;
-@PropertySource("classpath:tiffinbox.properties")
TiffinBoxServer.java, every changed line but comments and blanks (0 of those not shown):
-        if (args.length > 0) {
-            System.setProperty("tiffinbox.port", args[0]);   // the same command line as before
-        }
```

Fourteen files each side (README aside): eleven identical, one renamed byte for byte (`tiffinbox.properties` →
`application.properties`), two changed — `TiffinBoxApp` loses `@PropertySource` and its import (its Javadoc is updated,
counted), `main` loses the three bridge lines. Nothing is added.

## 6 · The new command — and where the moved file ranks

`.r-serve.out` `f10bde48d09c1d92d8c95907e0683e8a`

```
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18666
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ java -jar tiffinbox-web-1.0.0.jar --debug --tiffinbox.port=18667
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  the condition report printed: 1 time(s)
the anchor README's logging command:
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18666 --logging.level.tiffinbox=debug
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  route DEBUG lines 5
```

The run command becomes `java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=<port>`, and the seven responses of
`../c4-unit31/curlset.sh` still hash to `115c36bac276128e245ca57df11c2891`. `--debug` may come first now (the condition
report prints once). The third run is the logging command `../c5-tiffinbox/README.md` now documents.

`.r-outside.out` `a6eaad66f3931e107a1dd79e8805bd9f`

```
from this folder: no application.properties here, and no config/ folder
$ java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18668
exit 0
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
   1 configurationProperties    3   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.properties]' via location 'optional:classpath:/' 3   origin: class path resource [application.properties] from tiffinbox-web-1.0.0.jar - 3:17
   7 applicationInfo            -
the bean's own field: OrderQueue.cooks = 3
non-option arguments Boot kept: []
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
from outside/: application.properties (tiffinbox.cooks=8) and config/application.properties (tiffinbox.cooks=9)
$ cd outside && java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18668
exit 0
KEY tiffinbox.cooks -> WINNER 9 · from source 6 of 9, Config resource 'file [config/application.properties]' via location 'optional:file:./config/'
   1 configurationProperties    9   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'file [config/application.properties]' via location 'optional:file:./config/' 9   origin: URL [file:config/application.properties] - 1:17
   7 Config resource 'file [application.properties]' via location 'optional:file:./' 8   origin: URL [file:application.properties] - 1:17
   8 Config resource 'class path resource [application.properties]' via location 'optional:classpath:/' 3   origin: class path resource [application.properties] from tiffinbox-web-1.0.0.jar - 3:17
   9 applicationInfo            -
the bean's own field: OrderQueue.cooks = 9
non-option arguments Boot kept: []
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

The moved file answers from source **6 of 7** — only `applicationInfo`, which never holds TiffinBox's keys, ranks below it.
Two files in the working directory outrank it without a rebuild: `./application.properties` (8) above the packaged one
(3), and `./config/application.properties` (9) above both — 9 sources in that run. `./` is where the java command starts
(here `outside/`, while the jar stays in `after/`), not the jar's folder. (The brief's probe counted 10 with the "before"
tree plus `places/`, where TiffinBox's `@PropertySource` file is a tenth source; this run is on the new anchor, which has
no such file.)

## 7 · The break — the old command still starts, on the wrong port

`.r-break.out` `ec5412569c92f07b3e8616f86fc0d3ef`

```
A   the new command
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18661
  the process listens on: 127.0.0.1:18661 · listeners on 18662: 0
  POST /shutdown -> {"stopping":true} · exit 0 · WARN lines 0 · ERROR lines 0
B   the old command: the port as a bare argument
$ java -jar tiffinbox-web-1.0.0.jar 18662
  the process listens on: 127.0.0.1:18425 · listeners on 18662: 0
  POST /shutdown -> {"stopping":true} · exit 0 · WARN lines 0 · ERROR lines 0
A′  A, re-run
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18661
  the process listens on: 127.0.0.1:18661 · listeners on 18662: 0
  POST /shutdown -> {"stopping":true} · exit 0 · WARN lines 0 · ERROR lines 0
```

**A** the new command listens on 18661, as asked. **B** the command the last course documented — the port as a bare first
argument — exits 0 with no WARN line and listens on **18425**, the file's port; nothing listens on 18662. A bare number
names no property, so nothing reads it, and nothing says so. **A′** is A re-run: the same lines (`receipts.sh` compares
them). The port is what the operating system says the process listens on (`lsof -p <pid>`), not TiffinBox's own log line.

`.r-ignored.out` `efa5b915b4261dcfe394809389b2d12f`

```
C   -D typed after the jar
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18668 -Dtiffinbox.days=7
  listens on 127.0.0.1:18668 · orders cooked:  120 · exit 0 · WARN lines 0 · ERROR lines 0
D   the same -D before -jar
$ java -Dtiffinbox.days=7 -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18668
  listens on 127.0.0.1:18668 · orders cooked:  28 · exit 0 · WARN lines 0 · ERROR lines 0
C, asked through the harness:
$ java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.days --tiffinbox.port=18668 -Dtiffinbox.days=7
  exit 0 · KEY tiffinbox.days -> WINNER 30 · from source 6 of 7, Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
  the bean's own field: TiffinBoxServer.days = 30
  non-option arguments Boot kept: [-Dtiffinbox.days=7]
```

**C** and **D** (variants, labelled so): a `-D` typed after the jar is an argument to TiffinBox, not an option to Java.
`tiffinbox.days` stays 30 — 120 orders, 0 WARN lines. The same `-D` before `-jar` is a system property: 7 days, 28
orders. The harness shows why C is silent: Boot kept `-Dtiffinbox.days=7` as a non-option argument, and nothing reads it.
(`days` rather than `cooks` here because TiffinBox's own log line shows it: 4 customers × days = orders cooked.)

## Exercise

`exercise/README.md` — five cooks, without editing a file and without touching TiffinBox's arguments, from two different
property sources. Measured answers, run exactly as written in a clean shell, in `exercise/solution/SOLUTION.md`
(`systemEnvironment` and `systemProperties`; the tempting `-D` after the class name stays at 3; `SPRING_APPLICATION_JSON` is
a third source, which Boot places **above** `systemProperties`).

## Found on the way

- **One argument that looked like two.** While authoring, a zsh one-liner passed `"--debug --tiffinbox.port=18667"` as a
  single argument (zsh does not split an unquoted `$args`). TiffinBox started with exit 0 and listened on **18425** — the
  flag did not reach `tiffinbox.port`, and nothing warned. That run bound 127.0.0.1:18425 for about two minutes before it
  was stopped with `POST /shutdown`; nothing else was listening there. `receipts.sh` is bash and quotes each command
  through `eval`. Not captured by `receipts.sh` — a note, not a claim the video makes.
- `SpringApplication.withHook` lets a harness watch an unmodified `main`. The Section 2 probe copied the bridge into its
  harness and switched it with a flag; running each tree's own `main` removes that copy from the evidence.

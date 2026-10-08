# c5-unit27 — CLI, Banners and Application Arguments

Course 5 · Spring Boot · Section 5, its first unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, GraalVM CE
25.3.4.1** (native-image 25.0.4.1), 2026-10-08. The port typed the way Courses 2 to 4 typed it — `java -jar … 18431`, a bare
number after the jar — started TiffinBox somewhere else without a word: Boot makes a property only of an argument that starts
with `--` (`--name=value`, or `--name` alone, bound as empty), and hands every other argument to the application's runners, where nothing in TiffinBox reads it. This unit measures what Boot hands a
runner, prints the order of Boot's hooks from one run, gives TiffinBox a refusal at the first of them (A/B/A′), shows why a runner
is too late for it (C), catches the property-sources lesson's silent `-D` (D), proves the refusal never prints a value typed after
a space (E, a planted canary; E′, a number after an option's bare name), measures five exit codes, prints a banner from the jar's manifest, and re-checks the AOT jar and the
native binary.

**The anchor changes (brief ⚑2, ⚑3, ⚑4):**
- `BareArgumentGuard.java` (new, `tiffinbox-web`, package `com.tiffinbox.web`, 61 lines that are code — 57 when the unit was first published): **`class BareArgumentGuard
  implements ApplicationListener<ApplicationEnvironmentPreparedEvent>`**. It reads the bare arguments with Boot's own
  `new DefaultApplicationArguments(event.getArgs()).getNonOptionArgs()`; on a start that has one it throws `BareArguments`, a
  `RuntimeException` that implements `ExitCodeGenerator` (**2**). The description places every bare argument by position
  (`argument N of M`) and prints it **only when it is 1-5 digits and does not follow an option's bare name** (a port typed the
  old way; the action then names `--tiffinbox.port=<that number>`; a number after `--tiffinbox.shutdown-token` may be a PIN, so it
  is `(not shown)` — the first published guard printed it twice, as the argument and in the action: RED C5-S5 #10, fixed by BLUE); an argument that starts with `-D` is `starts with -D (not shown)` (action: `Java's -D options go
  before -jar; after it, give a setting as --name=value.`); anything else is `(not shown)` (action: `Give a setting as --name=value,
  in one argument.`). The loop mirrors Spring's parser: a lone `--` ends the options (measured with `DefaultApplicationArguments` on
  `--`, `--a=1`, `x`: non-option `[--a=1, x]`).
- `BareArgumentAnalyzer.java` (new, 9 code lines): `AbstractFailureAnalyzer<BareArgumentGuard.BareArguments>`, the exception's
  description and action as Boot's `FailureAnalysis`.
- `tiffinbox-web/src/main/resources/META-INF/spring.factories`: **the key `org.springframework.context.ApplicationListener` added**
  (the guard), the analyzer appended to the `FailureAnalyzer` key, and the comment rewritten for both keys (3 comment lines → 6).
- `TiffinBoxApp.java`: **the Javadoc sentence only — RED C5-S2 #8, closed.** A `@PropertySource` file "ranks below every source
  Boot adds but one - default properties, set in code, which Boot keeps last". Measured here (`change`, the harness's `Sources`):
  9 of 9 without default properties, 9 of 10 with them, `defaultProperties` 10th. Its code is unchanged (`change`).
- The anchor `README.md`: the unit section, and **five history notes** the guard made false — unit 01's "the run command is
  unchanged … `18431`", unit 06's "the old command still starts, and says nothing", Course 3's Run note and its "pass another as the
  first argument", and Course 4's `… jar 18431` — each now says the bare number is refused since this change (exit 2).
- **Not edited:** `tiffinbox-core` (0 files differ), `TiffinBoxServer.java`, `PortTakenFailureAnalyzer.java`, `ActuatorRoutes.java`,
  `KitchenHealthIndicator.java`, `KitchenMetrics.java`, `Route.java`, `application.yaml`, both POMs (`change`).

`c5-tiffinbox` and this unit's `after/` hold the change, and nothing else (`diff -rq -x target ../c5-tiffinbox after` is empty).
**Units 28 and 29 start from `after/`** (see the last section).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 12 captures, 3 runs each; every spoken number asserted; 0 raw tokens, 0 canaries; a published-md5 mismatch stops it
```

**Runs of record after BLUE (2026-10-09, RED C5-S5 #10 #11 #3 #14; `args`, `change`, `canary` republished; the anchor's guard changed):** **1,339 s under `./receipts.sh`** (/bin/bash 3.2.57, exit 0, all 12 = published, every check passed; a second 3.2 pass, begun as an interrupt test whose SIGINT never reached it, also exit 0, all 12 = published); **1,884 s under `bash receipts.sh`** (Homebrew bash 5.3.9, exit 0, all 12 = published); **1,229 s from a sealed fresh clone** (`git clone` of commit `0aaac65`, `env -i`, `HOME` with only `.mavenrc` and a `settings.xml` mirroring to a `file://` copy of the four units' `.m2-demo`, proxies at 127.0.0.1:9; bash 5.3.9): exit 0, all 12 = published, two pre-capture builds `offline: no`, 679 artifacts all from the `file://` copy, the native plugin's metadata zip read from `.m2-demo` (`file:`), `.m2-demo` 1,856 files. Load averages 110-300 (three other units alongside; no "never listened" in any run). Interrupt test (own process group, SIGINT once 19060 listened): exit 130, 0 processes left, 18425, 8080 and 19060-19069 free, no `.r-lock`, no partial capture, the published captures unchanged. The earlier runs below are of the tree before BLUE.

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Runs of record
(2026-10-08):** **629 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0, all 12 captures = published, every check passed);
**605 s under `bash receipts.sh`** (Homebrew bash 5.3.9, this folder, exit 0) before the banner capture gained the manifest's two lines
(the eleven other hashes unchanged; `banner` published from a 3.2 run, 3/3); and **668 s under `bash receipts.sh` from a sealed
clone** (below), all 12 = published. Load averages about 3-4. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first, so you can
see which one moved). One native build per capture run (three per receipt), each judged against a bound (1 minute or more, under 20
minutes); its seconds go to the terminal only.
Published hashes: bare `eda2ef010df751fc37cd5889acd7dd9e` · refuse `0feab6e83260e48233c2ae90179f6af1` · args `5397379dd5b3ac5a75052460bf60c45c` · order `8c8dcf359ccb8dcc921f5734f95d5744` · change `e95eee9009fd315f9e0ec6368ae4248a` · late `e9d4ddba52457decc01063116539c2f3` · dashd `ed91e0f98817dbc1383b7ec82af47ad7` · canary `2e8bf188c907fc4c28f340a11e61095f` · codes `5a4a7b3f5bf58fc84a74b25ec91a7821` · banner `0f360a15e032bba6b6a277fbcf3da720` · native `6d5dd86e51a516f4e87f5024319f2b88` · exercise `024bbc20aad6a2237c0553e25c3523cb`

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else. It refuses a variable that does not name a
`bin/native-image`, and one whose `native-image --version` is not `native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`. The
GraalVM's folder is never printed: every capture masks it as `$GRAALVM_HOME`. Only `native` needs it. **Without a GraalVM**
(`GRAALVM_HOME` not set) `receipts.sh` still runs: it fills `.m2-demo`, makes every capture but `native` — the exercise's included —
each checked against `receipts.md5`, then stops where the native build would start, naming this section (exit 1).

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded for this unit from
`../../spring-boot/_research/m2-seed-s5/` **less `com/tiffinbox/`** (5,568 files; the brief's seed rule, S5.3 — never Maven Central
first). **Nothing was downloaded** for this unit: every build said `offline: yes`, the native-profile ones and the class-path line's
dependency plugin included. GraalVM's native plugin reads its metadata repository (`graalvm-reachability-metadata-1.1.8-repository.zip`,
3,362,517 bytes) from `$M2` — and when the zip is not there it downloads one from GitHub, even under `-o` — so (1) the first build is
the README's native install, which fills `.m2-demo` on a fresh clone; (2) a native-profile build while the zip is missing goes to
Maven Central at once; (3) the first build's products are checked; (4) every build's log is searched for the plugin's own download
line — found, the run stops. At run time nothing leaves 127.0.0.1.

**From a clone, sealed (2026-10-08, brief S5.2).** The repository was cloned (`git clone` of the local repository at this unit's commit) into an empty folder — nothing git
ignores: no `.m2-demo`, no `.harness/`, no `.r-*`; `README.md` is the only file changed since, by this paragraph and the runs-of-record
note. `bash receipts.sh` (Homebrew bash 5.3.9) ran under `env -i`, with a `HOME` whose `.mavenrc` points Maven's `user.home` there
(Java reads `user.home` from the account, not from `$HOME`) and every Java proxy property at a port that refuses (127.0.0.1:9), and
whose Maven settings send every repository to a `file://` copy of Central's files made from `.m2-demo` (4,164 files: TiffinBox's
own installs, `_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out,
`maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same
refusing port; `GRAALVM_HOME` set. **Exit 0 after 668 s** — all 12 captures = published, every spoken number asserted, 0 raw demo
tokens, 0 canaries in any log. Two builds said `offline: no` — the first (GraalVM's metadata repository was not in the empty
`.m2-demo`) and the class-path line's pre-capture build (Maven's dependency plugin) — and between them took 679 files, every one from
the `file://` copy, 0 from anywhere else; every capture's build said `offline: yes`; `.m2-demo` ended with 1,856 files; 0 lines of the
native plugin's metadata download in any build log. (**Found on the way:** without that pre-capture build, the first capture to run
the class-path line would print `offline: no` on a fresh clone, and its hash would move — the earlier revision of this script did not
have it; the in-folder runs never showed it, because the seed already held the plugin.)

## The demo token — fake, and never printed; the canary — planted, and counted

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it.
The token never reaches a command line: the seven requests and `harness/shutdown.sh` read it from the file. Every capture is masked
— the token becomes `[masked: the 26-character token]` — and `receipts.sh` counts the raw token in each run's own output **before**
masking (`.harness/raw-*`: 0 in all 36 capture runs); in **the log of every start that ended by itself** — a refusal, a failure, a
harness's exit: standard output and error, 0 each (36 in the runs of record); in **the log of every TiffinBox that served** — the
token, the shutdown header's name `X-Shutdown-Token` in any case, and the canary: 0, 0 and 0 each (48); then in every capture, this
README, the exercise, the harness, `receipts.md5`, the anchor README, the two new classes, `spring.factories`, `TiffinBoxApp.java`,
and the **bytes of the binary**: 0 each. The builder counts the token and the canary again in the script, the deck and the prompter: 0.

**The canary** (`planted-canary-value`, not a secret: a value the checks look for) is passed after a space,
`--tiffinbox.shutdown-token planted-canary-value` (`canary`, E): a bare argument. Its count in each run's log is 0, and **1 in the
command that carried it** — the same counter, on a text that holds it, so the check can tell. A last check fails if the canary is in
any capture line other than its two `$` lines. **Planted faults, each run once (2026-10-08, S5.18):** a copy of the published
captures with (1) the canary written into a log line of `canary` → `the canary reached a capture outside its command line`; (2) `late`'s
listening count made 0 → `late: it listened`; (3) `order`'s runner swapped above TiffinBox's listening line → `order: the hooks, in
order`; (4) `dashd`'s description made to print the `-D` → `dashd: placed, not shown`. Each check died on its fault, and passed on
the published captures.

## The folders, the variables and the ports

- `.harness/before/` and `.harness/after/` — the previous tree (`../c5-unit26/after`) and `after/`, copied (for `change`);
  `.harness/after/` is built with the README's native install (the run's first build) and extracted to compile the harness.
- `.harness/prev/` — the previous tree, built the README's plain way and extracted (`bare`, `args`, `late`, `dashd`, `canary`).
  `.harness/serve/` — `after/`, built with the README's class-path line (`mvn -B package dependency:build-classpath
  -Dmdep.outputFile=target/classpath.txt`, offline) and extracted (`refuse`, `args`, `order`, `change`'s `Sources`, `late`, `dashd`,
  `canary`, `codes`, `banner`). `.harness/nat/` — `after/`, the README's two native lines (`native`). The exercise: `.harness/mine/`.
- **The harness** (`harness/probe/cli/`, the course's, never TiffinBox's; outside `com.tiffinbox`; compiled into `.harness/hc`):
  `Report` — a runner (`ApplicationRunner`) joined by `--spring.main.sources`: it prints the option names (sorted), the non-option
  arguments, `tiffinbox.days`'s values and the argument count, and with `--probe.exit=N` ends the run through
  `SpringApplication.exit(context, () -> N)` and `System.exit`; `LateGuard` — the same check as a runner, throwing an
  `ExitCodeGenerator` exception (2) and naming no argument; `Order` — a listener for every event, printing one line each on standard
  output (an availability event with its state), named in **its own** `harness/order/META-INF/spring.factories`, copied to
  `.harness/ho` and joined to `order`'s class path only; `Sources` — a `@Configuration` with one `@PropertySource` file
  (`harness/probe/sources.properties`), started by Boot without a web server, printing the environment's sources in order, without
  and with default properties set in code. `harness/shutdown.sh` and `harness/seven.sh`: the failure lesson's.
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`; `$M2` = this unit's `.m2-demo`; `$GRAALVM_HOME` = the GraalVM; `$pid` = the
  process id `receipts.sh` kept when it started the JVM it then sends SIGTERM (`codes`). Every other command is printed whole.
- **The class-path layouts** (S4.18): the executable jar (`java -jar`, Boot's launcher) in `bare`, `refuse`, `dashd`, `canary`,
  `codes`, `banner`; the extracted jar with `-cp` and the harness in `args`, `order`, `late`, `codes` (3); the build's folders
  (`target/classes` + `classpath.txt`) in `banner` and the exercise; the AOT jar and the binary in `native`.
- **Ports** (brief ⚑1, 19060-19069, checked free with `lsof` before anything is wiped; 18425 and 8080 too, and never bound): `refuse`
  A 19060 · `bare` and `refuse` B 19061 (`TIFFINBOX_PORT`) and **19062, the bare argument: never bound** · `args` 19063 · `order`
  19064 · `late` 19065 · `dashd` 19066 · `canary` 19067 · `codes` 19068 · `banner`, `native` and the exercise 19069. `change`'s runs
  open no port.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM and the token** (`gsub()`, literals escaped), in every line: the token → `[masked: the 26-character token]`;
   the GraalVM's folder → `$GRAALVM_HOME`; this folder's absolute path → `…` (also URL-encoded; this masks the config tree's path in
   `Sources`' line, S5.13); the folder above → `…/..`; the home folder → `~`; the user name → `<user>`. A last check fails if any
   capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line, a log
   time, a thread number or a stack frame.
2. **A start that ended by itself** (`ended()`, then `fails()` or `quits()`) is read after it exited, never printed whole: its exit
   code; its shape (`SHAPEAWK`, the failure lesson's: `APPLICATION FAILED TO START`, frames, `Caused by:` and folded frames counted;
   WARN/ERROR/DEBUG lines from their level on, a WARN cut after its exception's class; each exception's first line; Boot's hint; the
   analysis from `Description:` on); **how far the start got** — the banner's `:: Spring Boot ::` line and `TiffinBox listening`,
   counted (`heard`); for a harness's exit, its own `harness: ` lines; then the token and the canary, raw. **Never a line total**
   (S5.30).
3. **A running TiffinBox's log** (`.harness/run.out`, `run.err`) is read after it stopped: Boot's first line cut before ` with PID`;
   TiffinBox's `orders cooked:` line from its message on (`dashd`); the harness's lines; the banner — the non-blank lines before Boot's
   first log line, counted, and a `title=` line shown; `order`'s marks — the harness's `hook:` lines, the banner, TiffinBox's listening
   line, the runner's line and Boot's Started line, numbered in the order the output holds them (one stream: standard output).
4. **The guard's and the analyzer's code** — lines that are neither comment nor blank; `spring.factories` — before and after, code
   lines, and its comment lines counted; `TiffinBoxApp.java` — `diff -U0` hunks without the file lines (no Javadoc header reaches a
   slide, S5.25), and its code compared.
5. **Spring's AOT metadata** (`reachability-metadata.json`) through a filter: the `spring.factories` resource and the reflection
   entries of the guard, the analyzer and the port analyzer. **Maven's and native-image's logs**: each build's `offline`/`exit` line;
   native-image's goal, GraalVM, Java, warnings (URL cut), stages, warning count and result, the rest counted.
6. **No duration is captured.**
7. **Hygiene:** the S5.15 loop, verbatim from the failure lesson's receipts — every `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`,
   `SERVER_*`, `LOGGING_*` variable, `DEBUG`, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS`,
   `NATIVE_IMAGE_OPTIONS` unset (`sed -E`), a canary planted under each name first and the run stopped if one survives;
   `TIFFINBOX_PORT` is set again only on the one command that shows it; `127.0.0.1` first in `no_proxy`/`NO_PROXY`; one run at a time
   (`.r-lock`); no `secrets/` here, no `secrets/`, `tiffinbox-local.yaml`, `banner.txt` or `target/` in `after/`.

**Interrupted.** `receipts.sh`'s exit trap stops the processes it started in the background — a serving TiffinBox (`$pid`) and a start
expected to end by itself (`$fpid`) — if they still run, then `sweep()`s this run's process group for anything of this run (a
TiffinBox JVM by its jar, by `com.tiffinbox.web.TiffinBoxServer` on a class path or a folder run, the harness's `Sources`, a binary,
native-image's driver or builder) — TERM, then KILL after 5 s; after an interrupt it deletes the capture runs left unfinished
(`.r-NAME.1-3`), then drops the lock. **Tested 2026-10-08 on the final script**, `receipts.sh` as a job of its own process group (job
control on) and `SIGINT` sent to the whole group 25 s after `bare` was published, during `refuse` (in the group: 4 processes — the
script, its subshell, a TiffinBox JVM and the `sleep` of a poll): **exit 130**; 5 s later 0 processes in the group, 0 TiffinBox JVMs
under this unit's `.harness/`; 18425, 8080 and 19060-19069 free; `.r-lock` gone; 0 unfinished capture files.

## 1 · bare — the previous tree, the old command

The previous tree (`../c5-unit26/after`), built the README's plain way and extracted; the README's old command with the port in `TIFFINBOX_PORT` (19061) and a bare `19062`: it listens on 19061 only, nothing listens on 19062, and it serves the seven `115c36ba…`. Nothing in its log says the number was ignored.

`.r-bare.out` · md5 `eda2ef010df751fc37cd5889acd7dd9e` · 3 of 3

```
the previous tree (the anchor as the failure lesson left it), copied to .harness/prev with a config tree, built the
README's plain way and extracted; then the README's old command - the port in TIFFINBOX_PORT (19061), a bare 19062:
$ cd .harness/prev && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/prev && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  extracted: exit 0 · its lib/ holds 46 jars
$ cd .harness/prev && TIFFINBOX_PORT=19061 java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 19062
  listens on: 127.0.0.1:19061
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19061/actuator/health/readiness
  {"status":"UP"} 200
  listening on 19062: 0
$ $CURLSET 19061 .harness/prev/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · refuse — the break (A/B/A′): a bare argument

after/, built with the README's class-path line (offline) and extracted. **A** — the README's run line, 19060: the seven. **B** — the README's old command (19061 in the variable, a bare 19062): exit 2, `APPLICATION FAILED TO START 1`, 0 frames, the banner's line 0, `TiffinBox listening` 0, Description `TiffinBox reads no bare arguments: argument 1 of 1 is 19062.`, Action `To set the port, give it as an option: --tiffinbox.port=19062.`; neither port listens afterwards. **A′** — A's command again: the seven.

`.r-refuse.out` · md5 `0feab6e83260e48233c2ae90179f6af1` · 3 of 3

```
after/, copied to .harness/serve with a config tree, built with the README's class-path line (offline) and extracted:
$ cd .harness/serve && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  built after/ · offline: yes · exit 0
  tiffinbox-web/target/classpath.txt: written
$ cd .harness/serve && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  extracted: exit 0 · its lib/ holds 46 jars
A - after/, the README's run line, port 19060:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19060
  listens on: 127.0.0.1:19060
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19060/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19060 .harness/serve/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - after/, the README's old command: the port in TIFFINBOX_PORT (19061), a bare 19062:
$ cd .harness/serve && TIFFINBOX_PORT=19061 java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 19062
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 1 of 1 is 19062.
  Action:
  To set the port, give it as an option: --tiffinbox.port=19062.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19061 0 · 19062 0
A' - A again:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19060
  listens on: 127.0.0.1:19060
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19060/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19060 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · args — what Boot hands a runner

The harness's `Report` joined to the previous tree (its extracted jar, `../hc`), with `--tiffinbox.days=10` and a bare `19062`: `/kitchen` answers 40 orders (the option became a property), and 19062 has no listener **while TiffinBox runs** (counted before the stop: a count after it could not fail — RED C5-S5 #11); after POST /shutdown its line — option names `[spring.main.sources, tiffinbox.days, tiffinbox.port]`, non-option `[19062]`, `tiffinbox.days [10]`, 4 source arguments. Then after/, options only, `--probe.exit=3`: exit 3, `SpringApplication.exit returned 3` — after `TiffinBox listening` (1).

`.r-args.out` · md5 `5397379dd5b3ac5a75052460bf60c45c` · 3 of 3

```
the harness's Report (a runner) joined to the previous tree - the README's exploded run, ../hc on the class path - with
two options and a bare number, port 19063:
$ cd .harness/prev && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19063 --spring.main.sources=probe.cli.Report --tiffinbox.days=10 19062
  listens on: 127.0.0.1:19063
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19063/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19063/kitchen
  {"ordersCooked":40,"ordersValue":8100} 200
  listening on 19062, while TiffinBox runs: 0
$ harness/shutdown.sh 19063 .harness/prev/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19063 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  harness: option names [spring.main.sources, tiffinbox.days, tiffinbox.port] · non-option arguments [19062] · tiffinbox.days [10] · source arguments 4
after/ - the same runner, options only, and --probe.exit=3 (Report ends the start through SpringApplication.exit):
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19063 --spring.main.sources=probe.cli.Report --tiffinbox.days=10 --probe.exit=3
  exit 3
  harness: option names [probe.exit, spring.main.sources, tiffinbox.days, tiffinbox.port] · non-option arguments [] · tiffinbox.days [10] · source arguments 4
  harness: SpringApplication.exit returned 3
  its log: the banner's :: Spring Boot :: line 1 · TiffinBox listening 1
  its log: APPLICATION FAILED TO START 0 · stack frames 0 · the demo token 0
  listening now: 19063 0
```

## 4 · order — Boot's hooks, in order

after/ with the harness's `Order` (named in its own `spring.factories`, `../ho`) and `Report` as the one runner, port 19064; the seven; then the marks, read from the run's standard output after it stopped, numbered in the order the output holds them: 14, from `ApplicationStartingEvent` to `ContextClosedEvent` — environment prepared (2) before the banner (3), TiffinBox listening (6) inside the refresh, before `ContextRefreshedEvent` (7), the runner (11) after liveness and before ready (12).

`.r-order.out` · md5 `8c8dcf359ccb8dcc921f5734f95d5744` · 3 of 3

```
after/ with the harness's witness - Order, named in its own spring.factories (../ho on the class path) - and its Report as
the one runner; port 19064:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc:../ho" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19064 --spring.main.sources=probe.cli.Report
  listens on: 127.0.0.1:19064
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19064/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19064 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the start, read from its output after it stopped - each hook's line, in order:
  1 hook: ApplicationStartingEvent
  2 hook: ApplicationEnvironmentPreparedEvent
  3 the banner
  4 hook: ApplicationContextInitializedEvent
  5 hook: ApplicationPreparedEvent
  6 TiffinBox listening - its @PostConstruct, in the refresh
  7 hook: ContextRefreshedEvent
  8 Boot's Started line
  9 hook: ApplicationStartedEvent
  10 hook: AvailabilityChangeEvent CORRECT
  11 the runner (the harness's Report)
  12 hook: ApplicationReadyEvent
  13 hook: AvailabilityChangeEvent ACCEPTING_TRAFFIC
  14 hook: ContextClosedEvent
```

## 5 · change — the previous tree against after/

Five paths differ: the README, the two new classes, `TiffinBoxApp.java`, `spring.factories`. The guard's 61 code lines and the analyzer's 9, whole; `spring.factories` before and after (one key → two; comments 3 → 6); `TiffinBoxApp.java`'s `diff -U0` hunk (two lines out, two in) and its code the same; the README's lines added and removed (counted, not shown); `tiffinbox-core` 0 files differ, and nine other files byte for byte the same. Then the sentence measured: the harness's `Sources`, without and with default properties — 9 of 9, 9 of 10, `defaultProperties` 10th (the config tree's path masked).

`.r-change.out` · md5 `e95eee9009fd315f9e0ec6368ae4248a` · 3 of 3

```
the previous tree against after/, both copied under .harness/ - the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: BareArgumentAnalyzer.java
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: BareArgumentGuard.java
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java differ
  Files .harness/before/tiffinbox-web/src/main/resources/META-INF/spring.factories and .harness/after/tiffinbox-web/src/main/resources/META-INF/spring.factories differ
  tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentGuard.java - new; its lines that are neither comment nor blank: 61
    package com.tiffinbox.web;
    import org.springframework.boot.DefaultApplicationArguments;
    import org.springframework.boot.ExitCodeGenerator;
    import org.springframework.boot.context.event.ApplicationEnvironmentPreparedEvent;
    import org.springframework.context.ApplicationListener;
    import java.util.ArrayList;
    import java.util.LinkedHashSet;
    import java.util.List;
    import java.util.Set;
    class BareArgumentGuard implements ApplicationListener<ApplicationEnvironmentPreparedEvent> {
        @Override
        public void onApplicationEvent(ApplicationEnvironmentPreparedEvent event) {
            List<String> bare = new DefaultApplicationArguments(event.getArgs()).getNonOptionArgs();
            if (!bare.isEmpty()) {
                throw new BareArguments(event.getArgs());
            }
        }
        static final class BareArguments extends RuntimeException implements ExitCodeGenerator {
            private final String description;
            private final String action;
            BareArguments(String[] args) {
                super("TiffinBox reads no bare arguments");
                List<String> found = new ArrayList<>();
                Set<String> actions = new LinkedHashSet<>();
                boolean options = true;                          // Spring's parser: a lone "--" ends the options
                boolean named = false;                           // the argument before was "--name" alone: this one may be its value
                for (int i = 0; i < args.length; i++) {
                    String a = args[i], at = "argument " + (i + 1) + " of " + args.length;
                    boolean value = named;
                    named = false;
                    if (options && a.startsWith("--")) {
                        options = !a.equals("--");
                        named = options && !a.contains("=");
                        continue;                                // an option: Boot made it a property
                    }
                    if (!value && a.matches("[0-9]{1,5}")) {
                        found.add(at + " is " + a);
                        actions.add("To set the port, give it as an option: --tiffinbox.port=" + a + ".");
                    } else if (a.startsWith("-D")) {
                        found.add(at + " starts with -D (not shown)");
                        actions.add("Java's -D options go before -jar; after it, give a setting as --name=value.");
                    } else {
                        found.add(at + " (not shown)");
                        actions.add("Give a setting as --name=value, in one argument.");
                    }
                }
                this.description = "TiffinBox reads no bare arguments: " + String.join("; ", found) + ".";
                this.action = String.join(" ", actions);
            }
            String description() {
                return description;
            }
            String action() {
                return action;
            }
            @Override
            public int getExitCode() {
                return 2;
            }
        }
    }
  tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java - new; its lines that are neither comment nor blank: 9
    package com.tiffinbox.web;
    import org.springframework.boot.diagnostics.AbstractFailureAnalyzer;
    import org.springframework.boot.diagnostics.FailureAnalysis;
    class BareArgumentAnalyzer extends AbstractFailureAnalyzer<BareArgumentGuard.BareArguments> {
        @Override
        protected FailureAnalysis analyze(Throwable rootFailure, BareArgumentGuard.BareArguments cause) {
            return new FailureAnalysis(cause.description(), cause.action(), cause);
        }
    }
  tiffinbox-web/src/main/resources/META-INF/spring.factories - its lines that are neither comment nor blank, before then after:
    before org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.PortTakenFailureAnalyzer
    after  org.springframework.context.ApplicationListener=com.tiffinbox.web.BareArgumentGuard
    after  org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.PortTakenFailureAnalyzer,com.tiffinbox.web.BareArgumentAnalyzer
  tiffinbox-web/src/main/resources/META-INF/spring.factories - its comment lines: before 3, after 6
  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java - the hunks (diff -U0, without its two file lines):
    @@ -18,2 +18,2 @@
    - * later, during refresh: it ranks below every source Boot adds, and it arrives after Boot has read keys such as
    - * logging.level.tiffinbox and spring.main.banner-mode.
    + * later, during refresh: it ranks below every source Boot adds but one - default properties, set in code, which Boot
    + * keeps last - and it arrives after Boot has read keys such as logging.level.tiffinbox and spring.main.banner-mode.
  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java - its lines that are neither comment nor blank, against the previous tree's: the same
  README.md - the anchor's README: lines added 78, removed 4 - its new section and five history notes (not shown)
  tiffinbox-core against the previous tree's (diff -rq -x target): 0 files differ
  TiffinBoxServer.java against the previous tree's, byte for byte: the same
  PortTakenFailureAnalyzer.java against the previous tree's, byte for byte: the same
  ActuatorRoutes.java against the previous tree's, byte for byte: the same
  KitchenHealthIndicator.java against the previous tree's, byte for byte: the same
  KitchenMetrics.java against the previous tree's, byte for byte: the same
  Route.java against the previous tree's, byte for byte: the same
  tiffinbox-web/src/main/resources/application.yaml against the previous tree's, byte for byte: the same
  tiffinbox-web/pom.xml against the previous tree's, byte for byte: the same
  pom.xml against the previous tree's, byte for byte: the same
the Javadoc's sentence, measured - the harness's Sources (a configuration class, one @PropertySource file, no web server) on
after/'s extracted class path, from .harness/serve and its config tree; without default properties, then with them:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" probe.cli.Sources --probe.defaults=no
  harness: default properties not set · sources 9: 1 configurationProperties · 2 commandLineArgs · 3 systemProperties · 4 systemEnvironment · 5 random · 6 Config tree '…/.harness/serve/./secrets' · 7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) · 8 applicationInfo · 9 class path resource [probe/sources.properties]
  harness: the @PropertySource file ranks 9 of 9 · probe.key = from the @PropertySource file
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" probe.cli.Sources --probe.defaults=yes
  harness: default properties set · sources 10: 1 configurationProperties · 2 commandLineArgs · 3 systemProperties · 4 systemEnvironment · 5 random · 6 Config tree '…/.harness/serve/./secrets' · 7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) · 8 applicationInfo · 9 class path resource [probe/sources.properties] · 10 defaultProperties
  harness: the @PropertySource file ranks 9 of 10 · probe.key = from the @PropertySource file
```

## 6 · late — C (labelled): the same check as a runner

The harness's `LateGuard` (a runner) joined to the previous tree with a bare 19062: exit 2, 21 frames, `Application run failed`, no analysis, the banner and **1 `TiffinBox listening` line, before the failure** — the port was open. The same runner joined to after/: the anchor's listener refuses first (exit 2, 0 frames, 0 banner, 0 listening; `argument 3 of 3 is 19062.`).

`.r-late.out` · md5 `e9d4ddba52457decc01063116539c2f3` · 3 of 3

```
C (labelled) - the same check as a runner: the harness's LateGuard joined to the previous tree, a bare number, port 19065:
$ cd .harness/prev && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19065 --spring.main.sources=probe.cli.LateGuard 19062
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 21 = 21 · Caused by: 0 · frames folded as common 0
  ERROR o.s.boot.SpringApplication: Application run failed
  probe.cli.LateGuard$Refused: a runner refused 1 bare argument(s)
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  its log: the banner's :: Spring Boot :: line 1 · TiffinBox listening 1
  its standard error: 0 lines · the demo token in its log: 0
  in its log, TiffinBox's listening line comes before Boot's Application run failed: yes
  listening now: 19065 0 · 19062 0
the same runner joined to after/ - the anchor's guard runs first:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19065 --spring.main.sources=probe.cli.LateGuard 19062
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 3 of 3 is 19062.
  Action:
  To set the port, give it as an option: --tiffinbox.port=19062.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19065 0 · 19062 0
```

## 7 · dashd — D (labelled): a -D option after the jar

The previous tree, `--tiffinbox.port=19066 -Dtiffinbox.days=10`: it serves, `/kitchen` 120 orders, its log `orders cooked:  120` — the days dropped without a word. after/, the same line: exit 2, `argument 2 of 2 starts with -D (not shown).` and the action `Java's -D options go before -jar; after it, give a setting as --name=value.` after/, the README's line with the `-D` before `-jar`: 40.

`.r-dashd.out` · md5 `ed91e0f98817dbc1383b7ec82af47ad7` · 3 of 3

```
D (labelled) - a -D option after the jar: the previous tree, the README's line, port 19066:
$ cd .harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19066 -Dtiffinbox.days=10
  listens on: 127.0.0.1:19066
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19066/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19066/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
$ harness/shutdown.sh 19066 .harness/prev/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19066 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: orders cooked:  120
after/ - the same line:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19066 -Dtiffinbox.days=10
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 2 of 2 starts with -D (not shown).
  Action:
  Java's -D options go before -jar; after it, give a setting as --name=value.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19066 0
after/ - the README's line with the -D before -jar:
$ cd .harness/serve && java -Dtiffinbox.days=10 -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19066
  listens on: 127.0.0.1:19066
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19066/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19066/kitchen
  {"ordersCooked":40,"ordersValue":8100} 200
$ harness/shutdown.sh 19066 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19066 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: orders cooked:  40
```

## 8 · canary — E (labelled): a value typed after a space

`--tiffinbox.shutdown-token planted-canary-value` after the README's run line, port 19067. The previous tree: exit 1 — Boot binds an empty token (`Value: ""`, `must not be blank`) and never prints the canary. after/: exit 2, `argument 3 of 3 (not shown).`, `Give a setting as --name=value, in one argument.` The canary: 1 in each command, 0 in each log. E′ (labelled): the same line with `48213` — a number, as a PIN would be — after `--tiffinbox.shutdown-token`: exit 2, `argument 3 of 3 (not shown).`, the action names no port, and the number is in the command once and in the analysis 0 times. (The guard before BLUE printed it twice: `argument 3 of 3 is 48213.` and `--tiffinbox.port=48213.` — measured on HEAD `1c6de0d`'s after/, 2 copies in the analysis; the check above counts 0, so it can tell.)

`.r-canary.out` · md5 `2e8bf188c907fc4c28f340a11e61095f` · 3 of 3

```
E (labelled) - a value typed after a space: the README's run line, port 19067, then --tiffinbox.shutdown-token and a
planted canary (not a token) as the next argument. The previous tree:
$ cd .harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19067 --tiffinbox.shutdown-token planted-canary-value
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.UnsatisfiedDependencyException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
      Property: tiffinbox.shutdownToken
      Value: ""
      Origin: "tiffinbox.shutdown-token" from property source "commandLineArgs"
      Reason: must not be blank
  Action:
  Update your application's configuration
  its log: the banner's :: Spring Boot :: line 1 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  the canary: in the command above 1 · in its log (standard output and error) 0
  listening now: 19067 0
after/:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19067 --tiffinbox.shutdown-token planted-canary-value
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 3 of 3 (not shown).
  Action:
  Give a setting as --name=value, in one argument.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  the canary: in the command above 1 · in its log (standard output and error) 0
  listening now: 19067 0
E' (labelled) - a number typed after a space, as a PIN would be (48213): after/, the same line:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19067 --tiffinbox.shutdown-token 48213
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 3 of 3 (not shown).
  Action:
  Give a setting as --name=value, in one argument.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  the number: in the command above 1 · in the analysis (Description: to its end) 0
  listening now: 19067 0
```

## 9 · codes — the exit codes, each measured

after/ on 19068: **0** after the seven (POST /shutdown); **1** a second start on the held port (the failure lesson's analysis); **2** a bare 19062; **3** the harness's `Report`, `--probe.exit=3`; **143** SIGTERM (`kill $pid`). The last line collects the five from the runs above it, never typed. DevTools' restart exit 1 is the DevTools lesson's capture (not re-run).

`.r-codes.out` · md5 `5a4a7b3f5bf58fc84a74b25ec91a7821` · 3 of 3

```
0 - after/, the README's run line, port 19068; POST /shutdown is the seventh request:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19068
  listens on: 127.0.0.1:19068
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19068/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19068 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
1 - a failed start: the same line while the first one holds the port (the failure lesson's analysis):
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19068
  listens on: 127.0.0.1:19068
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19068/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19068
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  TiffinBox could not listen on 127.0.0.1:19068: something else already listens there.
  Action:
  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.
  its log: the banner's :: Spring Boot :: line 1 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
$ $CURLSET 19068 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 - a bare argument: the README's run line and a bare 19062:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19068 19062
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 2 of 2 is 19062.
  Action:
  To set the port, give it as an option: --tiffinbox.port=19062.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
3 - the harness's Report, options only, --probe.exit=3: SpringApplication.exit with a generator that returns 3:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19068 --spring.main.sources=probe.cli.Report --probe.exit=3
  exit 3
  harness: option names [probe.exit, spring.main.sources, tiffinbox.port] · non-option arguments [] · tiffinbox.days null · source arguments 3
  harness: SpringApplication.exit returned 3
  its log: the banner's :: Spring Boot :: line 1 · TiffinBox listening 1
  its log: APPLICATION FAILED TO START 0 · stack frames 0 · the demo token 0
143 - SIGTERM: the README's run line, then kill:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19068
  listens on: 127.0.0.1:19068
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19068/actuator/health/readiness
  {"status":"UP"} 200
$ kill $pid    # SIGTERM, to the JVM this script started
  exit 143
  listening now: 19068 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the five, as measured above: POST /shutdown 0 · a failed start 1 · a bare argument 2 · SpringApplication.exit 3 · SIGTERM 143
```

## 10 · banner — the README's banner file

The README's `printf` line writes `banner.txt` in after/'s folder. The jar: `title=[TiffinBox Web] version=[1.0.0] boot=[4.1.1]`, and the jar's manifest `Implementation-Title: TiffinBox Web`, `Implementation-Version: 1.0.0`; `target/classes` holds no manifest. The folders (the README's class-path line): `title=[] version=[] boot=[4.1.1]`, and Boot's first line without `v1.0.0`. Boot's own banner: its `:: Spring Boot ::` line 1. `banner-mode=off`: 0 lines before the first log line. Each run serves the seven.

`.r-banner.out` · md5 `0f360a15e032bba6b6a277fbcf3da720` · 3 of 3

```
after/'s folder (.harness/serve), the README's banner file:
$ cd .harness/serve && printf '%s\n' 'title=[${application.title}] version=[${application.version}] boot=[${spring-boot.version}]' > banner.txt
  title=[${application.title}] version=[${application.version}] boot=[${spring-boot.version}]
the jar - the README's banner line, port 19069:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19069 --spring.banner.location=file:banner.txt
  listens on: 127.0.0.1:19069
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19069/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19069 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the banner: title=[TiffinBox Web] version=[1.0.0] boot=[4.1.1]
  lines before Boot's first log line, not blank: 1
  the banner's :: Spring Boot :: line: 0
  where the jar's title and version are written - its manifest, read with unzip (the two lines):
$ cd .harness/serve && unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF | grep -E '^Implementation-(Title|Version):'
  Implementation-Title: TiffinBox Web
  Implementation-Version: 1.0.0
  the folders' manifest: tiffinbox-web/target/classes/META-INF/MANIFEST.MF does not exist
the folders - the README's class-path line (the build wrote tiffinbox-web/target/classpath.txt):
$ cd .harness/serve && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19069 --spring.banner.location=file:banner.txt
  listens on: 127.0.0.1:19069
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19069/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19069 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the banner: title=[] version=[] boot=[4.1.1]
  lines before Boot's first log line, not blank: 1
  the banner's :: Spring Boot :: line: 0
the jar with Boot's own banner - the README's run line:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19069
  listens on: 127.0.0.1:19069
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19069/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19069 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  lines before Boot's first log line, not blank: 7
  the banner's :: Spring Boot :: line: 1
the jar, banner-mode off - the README's line:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19069 --spring.main.banner-mode=off
  listens on: 127.0.0.1:19069
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19069/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19069 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  lines before Boot's first log line, not blank: 0
  the banner's :: Spring Boot :: line: 0
```

## 11 · native — the AOT jar and the binary (S5.14)

after/, the README's two native lines, offline: 8 of 8 stages, inside the bound, `Mach-O 64-bit executable`, 0 token bytes. Spring's AOT metadata: `spring.factories` registered, and the guard, its analyzer and the port analyzer each `allDeclaredConstructors`. The AOT jar with a bare 19062: exit 2, the two sentences, 0 frames, never bound; without it: `Starting AOT-processed TiffinBoxServer v1.0.0`, the seven. The binary with a bare 19062: the same refusal; with the README's banner line: `title=[] version=[] boot=[4.1.1]`, its first line without a version, the seven.

`.r-native.out` · md5 `6d5dd86e51a516f4e87f5024319f2b88` · 3 of 3

```
after/, copied to .harness/nat with a config tree; the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 154 lines - not shown):
    --- native:1.1.8:compile-no-fork (default-cli) @ tiffinbox-web ---
    Found GraalVM installation from GRAALVM_HOME variable.
    Java version: 25.0.4.1+1, vendor version: GraalVM CE 25.3.4.1+1.1
    Warning: Using a deprecated option --no-fallback from 'META-INF/native-image/com.tiffinbox/tiffinbox-web/native-image.properties' in '…'. No effect, no replacement available
    Warning: Option 'FallbackThreshold' is deprecated and might be removed in a future release: It no longer has any effect, and no replacement is available. Please refer to the GraalVM release notes.
    Warning: Option 'DynamicProxyConfigurationResources' is deprecated and might be removed in a future release: This can be caused by a proxy-config.json file in your META-INF directory. Consider including proxy configuration in the reflection section of reachability-metadata.json instead.. Please refer to the GraalVM release notes.
    [1/8] Initializing...
    [2/8] Performing analysis...
    [3/8] Building universe...
    [4/8] Parsing methods...
    [5/8] Inlining methods...
    [6/8] Compiling methods...
    [7/8] Laying out methods...
    [8/8] Creating image...
    The build process encountered 3 warnings.
    BUILD SUCCESS
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
what Spring's AOT step wrote for the binary - .harness/nat's reachability-metadata.json (process-aot), through a filter:
  the resource META-INF/spring.factories: yes
  reflection entries for com.tiffinbox.web.BareArgumentGuard: 1 · allDeclaredConstructors
  reflection entries for com.tiffinbox.web.BareArgumentAnalyzer: 1 · allDeclaredConstructors
  reflection entries for com.tiffinbox.web.PortTakenFailureAnalyzer: 1 · allDeclaredConstructors
the AOT jar - the README's AOT line, port 19069, and a bare 19062:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19069 19062
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 2 of 2 is 19062.
  Action:
  To set the port, give it as an option: --tiffinbox.port=19062.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19069 0 · 19062 0
the AOT jar - the README's AOT line, as written:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19069
  listens on: 127.0.0.1:19069
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19069/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19069 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the binary - the README's line, port 19069, and a bare 19062:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19069 19062
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 2 of 2 is 19062.
  Action:
  To set the port, give it as an option: --tiffinbox.port=19062.
  its log: the banner's :: Spring Boot :: line 0 · TiffinBox listening 0
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19069 0 · 19062 0
the binary - the README's banner line, the README's banner file written beside it:
$ cd .harness/nat && printf '%s\n' 'title=[${application.title}] version=[${application.version}] boot=[${spring-boot.version}]' > banner.txt
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19069 --spring.banner.location=file:banner.txt
  listens on: 127.0.0.1:19069
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19069/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19069 .harness/nat/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the banner: title=[] version=[] boot=[4.1.1]
  lines before Boot's first log line, not blank: 1
  the banner's :: Spring Boot :: line: 0
```

## 12 · exercise — the exercise, run as written

exercise/README.md's commands, then SOLUTION.md's one line, exactly as written: the jar prints `TiffinBox version=[1.0.0]`, the folders `TiffinBox version=[]`; nothing listens on 19069 afterwards; its own token 0 times in either log.

`.r-exercise.out` · md5 `024bbc20aad6a2237c0553e25c3523cb` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 5 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  exit 0 · printed: 0 line(s)
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ M="$PWD/.m2-demo" H="$PWD/harness" && cd .harness/mine/after && printf '%s\n' 'TiffinBox version=[${application.version}]' > tiffinbox-web/src/main/resources/banner.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt && for w in jar folders; do if [ $w = jar ]; then java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19069 > $w.log 2>&1 & else java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19069 > $w.log 2>&1 & fi; for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19069/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; "$H/shutdown.sh" 19069 secrets/tiffinbox/shutdown-token > /dev/null; wait; done; echo "the jar: $(grep -m1 '^TiffinBox version=' jar.log) · the folders: $(grep -m1 '^TiffinBox version=' folders.log)"
the jar: TiffinBox version=[1.0.0] · the folders: TiffinBox version=[]
  exit 0 · listening on 19069 now: 0
  its logs (.harness/mine/after/jar.log, folders.log): its own token 0 times · X-Shutdown-Token 0 times
```


## Exercise

**Your turn:** add a banner that prints TiffinBox's version, then start the jar and the folder run, and see which one knows it.
(Brief: "…Which one knows it?" — the spoken beat carries no question mark, the builder's rule.) `exercise/README.md` has the
commands; done is the line `the jar: TiffinBox version=[1.0.0] · the folders: TiffinBox version=[]` — a typed version prints
`[1.0.0]` twice and does not pass (measured once by hand: `exercise/solution/SOLUTION.md`).

## RE-MEASURE — the brief's items this unit settles

| Item (brief) | The probe | This unit (receipts, 2026-10-08) |
|---|---|---|
| 1 · the guard in the **binary** | not built | **exit 2, 0 frames, 0 banner, never bound** (19069 and 19062 free); without the argument, the seven (`native`) |
| 2 · the binary's banner on today's tree | 10-06, unit 20's tree | **`title=[] version=[] boot=[4.1.1]`**, and its first line has no `v1.0.0` (`native`) |
| 3 · the guard **with the analyzer** on the AOT jar | the listener only | **exit 2, the two sentences, 0 frames**; Spring's AOT step registers the guard and the analyzer (`allDeclaredConstructors`) and `spring.factories` |
| The bare port (READ FIRST 2) | 19201 / 19202 | **19061 listens, 19062 has no listener**, the seven (`bare`) |
| The runner after the port (R2) | log line 17 vs 19 | **ordered, not counted:** in one run's output TiffinBox's listening line is mark 6, the runner mark 11, ready 12 (`order`); `args`' exit 3 after `TiffinBox listening 1` |
| The parked guard (R3) | exit 2, 1 listening line, 21 frames | **the same** (`late`); joined to after/, the listener refuses first |
| NEW 1 (listener + analyzer) | exit 2, 0 frames, 14 lines | **exit 2, `APPLICATION FAILED TO START 1`, 0 frames, 0 banner, 0 listening** (`refuse` B); no line total (S5.30) |
| NEW 3 (`-D`, the canary) | `orders cooked: 120`; echoing guard logged the canary once | **120, then exit 2 `starts with -D (not shown)`, then 40 with `-D` before `-jar`** (`dashd`); **the canary 0 in each log** (`canary`) |
| Exit codes | 0 · 1 · 2 · 3 · 143 | **the same, each from its own run** (`codes`) |
| Banners (jar, folders, off) | `version=[1.0.0]` / `version=[]` / 0 lines | **the same, plus the manifest's two lines and no manifest under `target/classes`** (`banner`) |
| RED C5-S2 #8 | 9 of 9; 9 of 10 | **the same, re-measured** (`change`, harness `Sources`) |

## Found on the way

- **Spring's own parser ends the options at a lone `--`.** `DefaultApplicationArguments` on `--`, `--a=1`, `x` gives no option and
  non-option `[--a=1, x]` (measured with the anchor's jars, Spring 7.0.9). The guard's loop mirrors it, so a `--name=value` after `--`
  is placed as a bare argument, as Boot sees it.
- **Boot itself never printed the canary**: on the previous tree, `--tiffinbox.shutdown-token planted-canary-value` binds an empty
  token (`Value: ""`, `must not be blank`, exit 1) and the canary goes to the runners' list — unread. A guard that echoed its bare
  list would have been the first thing to print it (the brief's probe measured exactly that).
- **A runner's exit is after the port** even when the runner ends the run cleanly: `args`' `--probe.exit=3` run logged
  `TiffinBox listening` once before `SpringApplication.exit returned 3`.
- **The folders' run says less about itself**: Boot's first line is `Starting TiffinBoxServer using Java 25.0.4.1` without
  `v1.0.0` — the same manifest the banner reads; so is the binary's (`Starting AOT-processed TiffinBoxServer using …`).
- **Readiness comes after the runners**: `order`'s marks put liveness `CORRECT` before the runner and readiness
  `ACCEPTING_TRAFFIC` after it.

## For units 28 and 29 — Section 5, and RED

**Units 28 and 29 start from `../c5-unit27/after`** (= `../c5-tiffinbox` now; `diff -rq -x target` empty). What you can rely on:
- **No bare argument reaches a guarded tree** (⚑18): every harness and receipt passes options only, or it is refused — exit 2,
  before the banner and any port, in the jar, the AOT jar and the binary. A `-D` goes before `-jar`.
- **`spring.factories` holds two keys** (`ApplicationListener`, `FailureAnalyzer` with two analyzers); Spring's AOT step registers all
  three classes.
- **The binary's banner and first line carry no version**; the jar's do (`v1.0.0`).
- **The seed:** `.m2-demo` = `_research/m2-seed-s5/` less `com/tiffinbox/` (5,568 files before this unit's own installs).
- **Ports:** 27 used 19060-19069; nothing of this unit listens after it ends. 28 owns 19140-19149, 29 19150-19159.

**For RED:** the guard's message wording (positions are 1-based over all arguments, options included); whether `canary` (E, receipt
only) earns its spoken sentence; units 21-26's terminal notes about the anchor now read "not … yet" (S5.26, LOW, terminal only).

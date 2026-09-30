# c5-unit10 — Profiles, Groups and spring.config.import

Course 5 · Spring Boot · Section 2 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-30.
TiffinBox had one profile, `rush`, written as a second document in `application.yaml`. This unit composes its
configuration from four sources — the base document, the rush document, a profile with a file of its own (`audit`:
TiffinBox's logging at debug), and a developer's own file that `application.yaml` imports — with a group, `lunch`, that
switches both profiles on. Then it measures how Boot ranks the four, printed off the running application rather than
drawn: the group expanded in Boot's own log line, the audit's logging key working from a profile file, the import absent
and present, the whole stack at once (and the profiles named the other way round), a misspelt profile that starts without
a word, and two mistakes that stop the start. Two more captures answer the questions the stack raises: with both profiles
as FILES, the order you name them in decides (`lastwins`), and an import declared inside a profile's own file ranks above
the profiles (`profimport`).

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it. "Before" is `../c5-unit09/after/` (the
anchor as the last unit left it), **copied** to `.harness/before/`: its files are compared, never run, and this unit never
writes into another unit's folder. Clean builds, offline first; every number the video speaks is asserted; three runs per
capture.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 10 captures, 3 runs each; every spoken number asserted; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) `receipts.sh`
**dies** when a capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can see which one
moved (tested: with `change`'s published hash altered by one character, the run printed `change … DIFFERS from the
published 5e79a4ac…`, stopped with exit 1 and released its lock; `receipts.md5` was restored). A whole run takes about
2 min 10 s on the author's Mac.

**The repository.** Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the commands): a copy of
`../c5-unit09/.m2-demo`, unchanged. This unit needs no artifact the previous one did not, and after a full run no file in
`.m2-demo` is newer than the run's start (measured). The tree build falls back to Maven Central only if the offline build
fails, and it prints `built after · offline: yes` (or `no - …`) on the terminal, so a run that went online is never
silent. Offline re-run of the frozen tree: `mvn -o -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" verify` → BUILD
SUCCESS.

## The anchor change

One file changed, two new (README aside), and no Java — `change`, below, shows every changed line:
- `tiffinbox-web/src/main/resources/application.yaml` gains two keys in its first document, written after the `tiffinbox:`
  block so every line the earlier units quote keeps its number (`cooks` is still `4:10`; the rush document's `cooks` moves
  from line 19 to line 29):
  - `spring.profiles.group.lunch: rush,audit` — a profile group: `--spring.profiles.active=lunch` switches on `lunch`,
    `rush` and `audit`, and Boot's INFO line lists all three.
  - `spring.config.import: optional:file:./tiffinbox-local.yaml` — a developer's own settings, from the folder TiffinBox
    starts in. `optional:` makes a missing file no error.
- `tiffinbox-web/src/main/resources/application-audit.yaml` (new) — the profile `audit`, a file of its own with one key:
  `logging.level.tiffinbox: debug`.
- `.gitignore` (new, at the anchor's root) — `tiffinbox-local.yaml`, at any depth under the anchor.

The four sources, as brief ⚑8 names them: `rush` stays the `---` document the YAML unit wrote, `audit` is a file, `lunch`
groups them, and the import is optional and git-ignored. The startup log still prints the meal-types list alone, never the
record. The run command is unchanged, and the seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891` — with no profile, with the anchor README's logging and rush commands, and with
`--spring.profiles.active=lunch` (`serve`).

## The harness — TiffinBox's own `main`, and its Environment printed

`harness/com/tiffinbox/harness/` holds two plain classes. Neither carries a class-level annotation, so TiffinBox's
`@ComponentScan("com.tiffinbox")` never picks one up. Neither copies TiffinBox's start-up: `Run.tiffinbox` calls the tree's
own `TiffinBoxServer.main(args)` inside Boot's `SpringApplication.withHook(…)`, whose run listener is handed the context
`main` starts; if `main` throws, the harness prints the exception's type and rethrows it, so the exit code is the one
TiffinBox's own run gives. `receipts.sh` compiles it with `javac -parameters` against `after/`'s jars, into
`.harness/classes`. Nothing in it prints the record whole — only the values a line names.

- `Stack <key> <TiffinBox's arguments>` — first, before anything starts (so a failed start shows it too), which
  `application.yaml` and `application-audit.yaml` the class path gives, and whether the working folder holds
  `tiffinbox-local.yaml`. Then it runs `main` and prints: the Environment's active profiles; how many property sources the
  Environment held when the context was prepared (**before refresh**, the step in which the container builds the beans),
  whether one of them came from `application-audit.yaml`, and whether the list after refresh is the same; then the key's
  stack — the `WINNER` (what the Environment answers) and the source it came from, then **every** property source in order,
  with what it holds for the key under that exact name and Boot's `Origin`; then `OrderQueue.cooks`, the field the key ends
  up in. It closes the context, which stops TiffinBox's server.

**`$AFTER`** is the harness's classes plus `after/`'s jars (`tiffinbox-web-1.0.0.jar` and `lib/*.jar`); `receipts.sh`
writes it to `.harness/after.classpath`. Every command is printed exactly as it runs: `receipts.sh` passes it to `eval`, so
`$AFTER` — and `$M2`, this unit's `.m2-demo` — expand when it runs. A harness command runs from this folder (which must hold
no `tiffinbox-local.yaml`: `receipts.sh` refuses to run if it does), or from `local/` when it starts `cd local &&` — the
folder TiffinBox starts in is the folder the import looks in. The jar runs (`serve`) start in `after/tiffinbox-web/target`.

**The demo files.** `local/tiffinbox-local.yaml` is a developer's file (`tiffinbox.cooks: 4`). A folder put in front of
`$AFTER` on a class path holds one file that the class path then gives **instead of** the copy packaged in TiffinBox's jar
(the harness's `the class path gives:` line names the file it got): `required/application.yaml` (the anchor's, with
`optional:` taken off the import — line 21) · `inprofile/application-audit.yaml` (the anchor's, plus
`spring.profiles.active: rush`, lines 6-8) · `twofiles/application-audit.yaml` (the anchor's, plus `tiffinbox.cooks: 7`) and,
beside it, `twofiles/application-rush.yaml` (`tiffinbox.cooks: 6` — rush as a file too; the jar's rush document is still
read) · `profimport/application-audit.yaml` (the anchor's, plus `spring.config.import:
optional:file:./profimport/audit-import.yaml`, lines 6-8) and the file it imports, `profimport/audit-import.yaml`
(`tiffinbox.cooks: 9`, read from this folder). `files` diffs each against the file it stands in for, or prints it whole.

**Ports** (Section 2 brief ⚑11: 18700-18709): serve 18700 · group 18701 · import 18702 · stack 18703 · break 18704 · loud
18705 (its first two runs never bind) · lastwins 18706 · profimport 18707 · the exercise 18709. Every command names its port; `receipts.sh` first checks that
nothing listens on 18425 or on any of its ports.

## Masks, filters and hygiene — every one, declared

1. Boot's own log lines (each starts with an ISO timestamp and carries a pid) are dropped from a harness report and
   counted; so are the lines between the harness's first line and its report (the banner and its blank lines): the last
   line of each report says how many of each (`… elided: N log line(s) of Boot's, and M line(s) printed before the report …`).
2. A kept log message loses its prefix (time, level, pid, thread, logger) through `sub()` — Boot's profile line
   (`The following …` / `No active profile set …`) and TiffinBox's meal-types line.
3. `route DEBUG lines` counts TiffinBox's own route lines at DEBUG (`route GET /… -> …()`, one per route) in the run's raw
   output; the lines themselves are among the elided log lines.
4. A failed start shows its exit code, its WARN, ERROR, banner (`:: Spring Boot ::`) and `listening` line counts, the files
   line, then Boot's own failure report (`APPLICATION FAILED TO START` to the end of its Action) **without its blank lines
   and its rows of asterisks** — or, when Boot printed no report, the exception's own line and the run's last two
   `Caused by:` lines, a `[jar:file:…]` or `[file:…]` location in them cut to `[…]` by `gsub()` — then the exception the
   harness names, then a counted line: `… N more line(s) of this run's output not shown …`. The first ERROR line of both
   failures here is printed before Boot's logging is set up, in logback's default format with a time
   (`HH:mm:ss.SSS [main] ERROR …`): it is counted, never shown.
5. `change` shows every changed **code** line: each changed file's comments (lines starting `#`) and blank lines are
   dropped from both versions before git diffs them (`-U0`), and the header line counts the changed lines that were
   dropped. New files are printed whole, numbered. `git check-ignore -v` separates its answer with a tab; `gsub()` turns
   it into three spaces.
6. Hygiene: `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS` and `MAVEN_ARGS` before it runs anything — a variable of yours would otherwise become a property source, or
   a flag. It refuses to run twice at once in this folder (`.r-lock`), to run with a `tiffinbox-local.yaml` in this folder,
   or without `local/tiffinbox-local.yaml`.

**Interrupted.** `receipts.sh`'s exit trap stops the JVM it started in the background, if one still runs, and drops the
lock — on a failed check and on Ctrl-C alike (a background job of a non-interactive shell ignores the terminal's Ctrl-C).
Tested 2026-09-30, the driver in the foreground, `SIGINT` sent to the script's process group the moment `serve`'s first
JVM (port 18700) started: `receipts.sh` exited 130, and 5 s later no JVM for 18700 was running, nothing listened on 18700,
and `.r-lock` was gone. The port check names the way out if a run is ever interrupted some other way: `curl -X POST
http://127.0.0.1:<port>/shutdown`.

## 1 · The change — the group, the import, the audit's file, and git

`.r-change.out` `4e79a4acbb8274a2e0b100675f8cb8ae`

```
files, README aside: the previous tree 16 · after/ 18 · in both 16: identical 15, changed 1
  only before: (none)
  only after:  .gitignore tiffinbox-web/src/main/resources/application-audit.yaml
application.yaml, every changed line but comments and blanks (4 of those not shown):
+spring:
+  profiles:
+    group:
+      lunch: rush,audit
+  config:
+    import: optional:file:./tiffinbox-local.yaml
new: .gitignore, whole
  1 | # A developer's own settings, imported by application.yaml (optional:file:./tiffinbox-local.yaml): never committed.
  2 | tiffinbox-local.yaml
new: tiffinbox-web/src/main/resources/application-audit.yaml, whole
  1 | # The profile "audit": a file of its own, read only while "audit" is active. Boot reads it while it prepares the
  2 | # environment, before the container starts - so a logging key works here.
  3 | logging:
  4 |   level:
  5 |     tiffinbox: debug
a throwaway git repository holding after/.gitignore and an empty tiffinbox-local.yaml:
$ git check-ignore -v tiffinbox-local.yaml
.gitignore:2:tiffinbox-local.yaml   tiffinbox-local.yaml
$ git status --porcelain --ignored
?? .gitignore
!! tiffinbox-local.yaml
```

`application.yaml` gains six code lines (the four comment lines are counted, not shown); the audit's file holds one key
path; `.gitignore` names the developer's file. In a throwaway repository (`.harness/git`, a fresh `git init`, holding
`after/.gitignore` and an empty `tiffinbox-local.yaml`), git reports the file ignored by `.gitignore` line 2 — `!!` — and
offers only the `.gitignore` itself (`??`).

## 2 · The group — one flag, three profiles, and the late key landed

`.r-group.out` `8f31bce48b0d37e79f5dce462e0d0b4d`

```
no profile
$ java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18701
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: []
before refresh: 7 property sources · one from application-audit.yaml among them: false · after refresh: 7, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
   1 configurationProperties    3   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   7 applicationInfo            -
the bean's own field: OrderQueue.cooks = 3
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
lunch, the group
$ java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18701 --spring.profiles.active=lunch
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 3 profiles are active: "lunch", "rush", "audit"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: [lunch, rush, audit]
before refresh: 9 property sources · one from application-audit.yaml among them: true · after refresh: 9, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 6 · from source 7 of 9, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
   1 configurationProperties    6   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' -
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
   8 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   9 applicationInfo            -
the bean's own field: OrderQueue.cooks = 6
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

With `lunch`: Boot's INFO line lists three profiles, the stack gains two config sources (the audit's file at 6, the rush
document at 7) and answers 6 from the rush document; the audit's logging key turns on TiffinBox's 5 route lines — 0 with
no profile. The audit's source is already in the Environment when the context is prepared, before refresh, and the list
is the same after it. This is where the logging key an earlier unit put in a `@PropertySource` file (0 route lines: read
during refresh, too late) belongs.

## 3 · The import — absent, then present

`.r-import.out` `d97b994bdd590f34c9b0b8e9d39299d0`

```
A   this folder: no tiffinbox-local.yaml
$ java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18702
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: []
before refresh: 7 property sources · one from application-audit.yaml among them: false · after refresh: 7, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
   1 configurationProperties    3   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   7 applicationInfo            -
the bean's own field: OrderQueue.cooks = 3
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
B   local/: a tiffinbox-local.yaml, cooks: 4
$ cd local && java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18702
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: present
active profiles: []
before refresh: 8 property sources · one from application-audit.yaml among them: false · after refresh: 8, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 4 · from source 6 of 8, Config resource 'file [tiffinbox-local.yaml]' via location 'optional:file:./tiffinbox-local.yaml'
   1 configurationProperties    4   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'file [tiffinbox-local.yaml]' via location 'optional:file:./tiffinbox-local.yaml' 4   origin: URL [file:tiffinbox-local.yaml] - 3:10
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   8 applicationInfo            -
the bean's own field: OrderQueue.cooks = 4
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18702
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: []
before refresh: 7 property sources · one from application-audit.yaml among them: false · after refresh: 7, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
   1 configurationProperties    3   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   7 applicationInfo            -
the bean's own field: OrderQueue.cooks = 3
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

A: no `tiffinbox-local.yaml` where TiffinBox starts — exit 0, no WARN, 7 sources, none for the file: `optional:` at work.
B: the same command from `local/` — 8 sources; the file's source sits at 6, directly above the base document (7) — the
document that declares the import (line 21, before the `---`) — and answers 4 (origin `URL [file:tiffinbox-local.yaml] - 3:10`: a path relative to the working folder).
A′ = A, line for line.

## 4 · The stack — all four sources at once

`.r-stack.out` `c8f2320541cc792f16fb15f6815de40a`

```
lunch, from local/: every source TiffinBox's configuration is composed from
$ cd local && java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18703 --spring.profiles.active=lunch
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 3 profiles are active: "lunch", "rush", "audit"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: present
active profiles: [lunch, rush, audit]
before refresh: 10 property sources · one from application-audit.yaml among them: true · after refresh: 10, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 6 · from source 7 of 10, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
   1 configurationProperties    6   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' -
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
   8 Config resource 'file [tiffinbox-local.yaml]' via location 'optional:file:./tiffinbox-local.yaml' 4   origin: URL [file:tiffinbox-local.yaml] - 3:10
   9 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
  10 applicationInfo            -
the bean's own field: OrderQueue.cooks = 6
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
the same two profiles, named the other way round: audit,rush
$ cd local && java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18703 --spring.profiles.active=audit,rush
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 2 profiles are active: "audit", "rush"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: present
active profiles: [audit, rush]
before refresh: 10 property sources · one from application-audit.yaml among them: true · after refresh: 10, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 6 · from source 7 of 10, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
   1 configurationProperties    6   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' -
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
   8 Config resource 'file [tiffinbox-local.yaml]' via location 'optional:file:./tiffinbox-local.yaml' 4   origin: URL [file:tiffinbox-local.yaml] - 3:10
   9 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
  10 applicationInfo            -
the bean's own field: OrderQueue.cooks = 6
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

`lunch`, started from `local/`: 10 property sources, 4 of them config files, in this order — the audit's file (6, no
cooks), the rush document (7, 6), the local file (8, 4), the base document (9, 3). The first that holds the key answers: 6.
The import, declared in the base document, ranks above that document and below both profile sources. Named the other way
round (`audit,rush`), Boot's line lists two profiles, and the stack from `KEY` to the bean's field is the same, row for row:
**here the order does not matter** — the audit's file ranks above both documents of `application.yaml` either way. With two
profile FILES it does: section 5.

## 5 · Two profile files — the last one you name wins

`.r-lastwins.out` `7e26cb9ac6d8d5e39226952e62e6c765`

```
twofiles/ in front of after/'s jar: application-rush.yaml (cooks: 6) beside application-audit.yaml (cooks: 7)
A   rush,audit
$ java -cp "twofiles:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18706 --spring.profiles.active=rush,audit
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 2 profiles are active: "rush", "audit"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- twofiles/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: [rush, audit]
before refresh: 10 property sources · one from application-audit.yaml among them: true · after refresh: 10, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 7 · from source 6 of 10, Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/'
   1 configurationProperties    7   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' 7   origin: class path resource [application-audit.yaml] - 7:10
   7 Config resource 'class path resource [application-rush.yaml]' via location 'optional:classpath:/' 6   origin: class path resource [application-rush.yaml] - 3:10
   8 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
   9 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
  10 applicationInfo            -
the bean's own field: OrderQueue.cooks = 7
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
B   audit,rush: the same two names, the other way round
$ java -cp "twofiles:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18706 --spring.profiles.active=audit,rush
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 2 profiles are active: "audit", "rush"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- twofiles/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: [audit, rush]
before refresh: 10 property sources · one from application-audit.yaml among them: true · after refresh: 10, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 6 · from source 6 of 10, Config resource 'class path resource [application-rush.yaml]' via location 'optional:classpath:/'
   1 configurationProperties    6   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application-rush.yaml]' via location 'optional:classpath:/' 6   origin: class path resource [application-rush.yaml] - 3:10
   7 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' 7   origin: class path resource [application-audit.yaml] - 7:10
   8 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
   9 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
  10 applicationInfo            -
the bean's own field: OrderQueue.cooks = 6
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
A′  A, re-run
$ java -cp "twofiles:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18706 --spring.profiles.active=rush,audit
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 2 profiles are active: "rush", "audit"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- twofiles/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: [rush, audit]
before refresh: 10 property sources · one from application-audit.yaml among them: true · after refresh: 10, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 7 · from source 6 of 10, Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/'
   1 configurationProperties    7   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' 7   origin: class path resource [application-audit.yaml] - 7:10
   7 Config resource 'class path resource [application-rush.yaml]' via location 'optional:classpath:/' 6   origin: class path resource [application-rush.yaml] - 3:10
   8 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
   9 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
  10 applicationInfo            -
the bean's own field: OrderQueue.cooks = 7
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

`twofiles/` in front of `after/`'s jar gives rush a file of its own (`cooks: 6`) beside the audit's (`cooks: 7`). **A** —
`--spring.profiles.active=rush,audit`: the audit's file ranks first (source 6) and answers 7; the rush file sits at 7, the
rush document at 8, the base document at 9. **B** — `audit,rush`: the two files swap places, and the rush file answers 6.
**A′** — A re-run, line for line. Between two profile files, the one named last ranks first — the brief's 7 vs 6, measured
in the shape it holds for (RED #25).

## 6 · An import declared inside a profile's own file

`.r-profimport.out` `013ab180397836803a3eb761db25feaa`

```
profimport/: the audit's file, plus spring.config.import: optional:file:./profimport/audit-import.yaml (cooks: 9); lunch on
$ java -cp "profimport:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18707 --spring.profiles.active=lunch
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 3 profiles are active: "lunch", "rush", "audit"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- profimport/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: [lunch, rush, audit]
before refresh: 10 property sources · one from application-audit.yaml among them: true · after refresh: 10, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 9 · from source 6 of 10, Config resource 'file [profimport/audit-import.yaml]' via location 'optional:file:./profimport/audit-import.yaml'
   1 configurationProperties    9   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'file [profimport/audit-import.yaml]' via location 'optional:file:./profimport/audit-import.yaml' 9   origin: URL [file:profimport/audit-import.yaml] - 3:10
   7 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' -
   8 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
   9 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
  10 applicationInfo            -
the bean's own field: OrderQueue.cooks = 9
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

`profimport/`'s audit file adds `spring.config.import: optional:file:./profimport/audit-import.yaml`, and that file holds
`cooks: 9`. With `lunch` on, the import's source sits at 6 — **above** the audit's own file (7) and the rush document (8) —
and answers 9. So where an import ranks depends on where it is declared: in the base document it ranks above that document
and below the profiles (`stack`); inside a profile's file, above the profiles. `optional:` moves no rank (RED #26).

## 7 · The break — a profile's name, misspelt

`.r-break.out` `7d47af2b93d265ffb92c9eb5f15ba5a5`

```
A   lunch
$ java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18704 --spring.profiles.active=lunch
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 3 profiles are active: "lunch", "rush", "audit"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: [lunch, rush, audit]
before refresh: 9 property sources · one from application-audit.yaml among them: true · after refresh: 9, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 6 · from source 7 of 9, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
   1 configurationProperties    6   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' -
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
   8 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   9 applicationInfo            -
the bean's own field: OrderQueue.cooks = 6
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
B   lnch: one letter missing
$ java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18704 --spring.profiles.active=lnch
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: The following 1 profile is active: "lnch"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: [lnch]
before refresh: 7 property sources · one from application-audit.yaml among them: false · after refresh: 7, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
   1 configurationProperties    3   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   7 applicationInfo            -
the bean's own field: OrderQueue.cooks = 3
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18704 --spring.profiles.active=lunch
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 5 · Boot: The following 3 profiles are active: "lunch", "rush", "audit"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: [lunch, rush, audit]
before refresh: 9 property sources · one from application-audit.yaml among them: true · after refresh: 9, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 6 · from source 7 of 9, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
   1 configurationProperties    6   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' -
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 29:10
   8 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   9 applicationInfo            -
the bean's own field: OrderQueue.cooks = 6
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

A (`lunch`): 6, 5 route lines. B (`lnch`): exit 0, 0 WARN, 0 ERROR; Boot's INFO line lists `"lnch"` as active, the harness
reads `[lnch]` — and nothing is composed for it: 7 sources, 1 config file (the base document), 3 cooks, 0 route lines. A′ =
A, line for line. The run happens in this folder, without the local file, so B's answer is the base document's.

## 8 · Two mistakes that stop the start, and one that waits

`.r-loud.out` `11890468727b063b2c5974ff545a2692`

```
required/: the import without optional:, and no tiffinbox-local.yaml in this folder
$ java -cp "required:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18705
  exit 1 · WARN lines 0 · ERROR lines 1 · banner lines 0 · listening lines 0
  the class path gives: application.yaml <- required/application.yaml · application-audit.yaml <- tiffinbox-web-1.0.0.jar!/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
  APPLICATION FAILED TO START
  Description:
  Config data resource 'file [tiffinbox-local.yaml]' via location 'file:./tiffinbox-local.yaml' does not exist
  Action:
  Check that the value 'file:./tiffinbox-local.yaml' at class path resource [application.yaml] - 21:13 is correct, or prefix it with 'optional:'
  the exception TiffinBox's main threw: org.springframework.boot.context.config.ConfigDataResourceNotFoundException
  … 9 more line(s) of this run's output not shown: Boot's log, blank lines, rows of asterisks, stack frames …
inprofile/: spring.profiles.active inside the audit's own file, lunch on
$ java -cp "inprofile:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18705 --spring.profiles.active=lunch
  exit 1 · WARN lines 0 · ERROR lines 1 · banner lines 0 · listening lines 0
  the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- inprofile/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
  org.springframework.boot.context.config.InvalidConfigDataPropertyException: Property 'spring.profiles.active' imported from location 'class path resource [application-audit.yaml]' is invalid in a profile specific resource [origin: class path resource [application-audit.yaml] - 8:13]
  the exception TiffinBox's main threw: org.springframework.boot.context.config.InvalidConfigDataPropertyException
  … 36 more line(s) of this run's output not shown: Boot's log, blank lines, rows of asterisks, stack frames …
the same inprofile/ file, no profile
$ java -cp "inprofile:$AFTER" com.tiffinbox.harness.Stack tiffinbox.cooks --tiffinbox.port=18705
exit 0 · WARN lines 0 · ERROR lines 0 · route DEBUG lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application-audit.yaml <- inprofile/application-audit.yaml · the working folder's tiffinbox-local.yaml: absent
active profiles: []
before refresh: 7 property sources · one from application-audit.yaml among them: false · after refresh: 7, the same list in the same order: true
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
   1 configurationProperties    3   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   7 applicationInfo            -
the bean's own field: OrderQueue.cooks = 3
… elided: 8 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

`required/` (the anchor's import without `optional:`, no file in this folder): exit 1 with Boot's failure report —
`does not exist`, and an Action that names the declaration, `class path resource [application.yaml] - 21:13`, and says
`prefix it with 'optional:'`. `inprofile/` with `lunch`: exit 1, no report — the exception's own line names the property,
the file and `8:13`. Both fail before the banner (0 banner lines). The same `inprofile/` file with no profile starts (exit
0): the audit's file is never read (`one from application-audit.yaml among them: false`), so the mistake waits for the day
the profile is switched on.

## 9 · The jar: the seven responses, unchanged

`.r-serve.out` `1c5c09a0a27b1165524c192a5e67d756`

```
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18700
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  TiffinBox's log: meal types:     [VEG, NON_VEG, VEGAN] · Boot: No active profile set, falling back to 1 default profile: "default"
the logging flag after/README.md gives, after the port: --logging.level.tiffinbox=debug
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18700 --logging.level.tiffinbox=debug
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  route DEBUG lines 5
the lunch-rush flag after/README.md gives, after the port: --spring.profiles.active=rush
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18700 --spring.profiles.active=rush
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  Boot: The following 1 profile is active: "rush" · route DEBUG lines 0
the group's flag after/README.md gives, after the port: --spring.profiles.active=lunch
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18700 --spring.profiles.active=lunch
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  Boot: The following 3 profiles are active: "lunch", "rush", "audit" · route DEBUG lines 5
```

`after/`'s jar, run as the anchor README runs it, four ways: plain, and with the three flags `after/README.md` gives —
read from the file, not typed here: `--logging.level.tiffinbox=debug` (5 route DEBUG lines), the profile `rush` (0), and
the group `lunch` (three profiles, 5 route DEBUG lines — the audit's key). The seven
responses hash to `115c36ba…` every time: the anchor change changed nothing a client sees.

## 10 · The demo files, against the files they stand in for

`.r-files.out` `15f6a2db032e4e9ff83be9d5d07b53b0`

```
required/application.yaml, against after/'s application.yaml:
  21c21
  <     import: optional:file:./tiffinbox-local.yaml
  ---
  >     import: file:./tiffinbox-local.yaml
inprofile/application-audit.yaml, against after/'s application-audit.yaml:
  5a6,8
  > spring:
  >   profiles:
  >     active: rush
twofiles/application-audit.yaml, against after/'s application-audit.yaml:
  5a6,7
  > tiffinbox:
  >   cooks: 7
twofiles/application-rush.yaml, whole - after/ has no such file (its rush is a document in application.yaml):
  1 | # The profile "rush" as a file of its own, beside the audit's. application.yaml's rush document is still read too.
  2 | tiffinbox:
  3 |   cooks: 6
profimport/application-audit.yaml, against after/'s application-audit.yaml:
  5a6,8
  > spring:
  >   config:
  >     import: optional:file:./profimport/audit-import.yaml
profimport/audit-import.yaml, whole - the file profimport/'s audit file imports:
  1 | # Imported by profimport/application-audit.yaml - an import declared inside a profile's own file.
  2 | tiffinbox:
  3 |   cooks: 9
local/tiffinbox-local.yaml, whole - after/ has no such file (its .gitignore keeps one out of git):
  1 | # A developer's own settings. application.yaml imports ./tiffinbox-local.yaml from the folder TiffinBox starts in.
  2 | tiffinbox:
  3 |   cooks: 4
```

## Exercise

`exercise/README.md` — in a copy of `after/` (under `.harness/mine`), give the audit's file a `tiffinbox.cooks` of your own,
activate `lunch`, predict the winner, then run `Stack` (port 18709) and check the source. Measured answers, run exactly as
written in a clean shell, in `exercise/solution/SOLUTION.md`: as shipped, `WINNER 6` from the rush document; with
`cooks: 7` appended to the audit's file, `WINNER 7 · from source 6 of 9`, `application-audit.yaml`, `7:10`.

## Found on the way

- **The brief's "last active profile wins (`rush,audit` vs `audit,rush`: 7 vs 6)" holds between two profile FILES, not
  for the anchor's shape.** With `rush` a document and `audit` a file (⚑8), the order changes nothing (`stack`: the same
  rows); with rush a file too, it decides (`lastwins`: 7, then 6, then 7).
- **An import ranks by where it is declared.** In the base document: above that document, below the profiles (`stack`).
  Inside a profile's own file: above the profiles (`profimport`).
- **A missing non-optional import declared in the file is located.** The probe imported from the command line and got an
  Action without a position; declared in `application.yaml`, the Action reads `at class path resource [application.yaml] -
  21:13`.
- **`spring.profiles.active` in a profile file is loud only once that profile is on.** With no profile the file is never
  read, and TiffinBox starts (`loud`, third run).
- **Both loud mistakes fail before the banner** (0 banner lines), and neither binds the port (0 listening lines).
- **`before refresh` equals `after refresh` in every run here**: nothing in TiffinBox adds a property source during
  refresh any more — the `@PropertySource` that did was retired in this section.
- **The probe's `3:13` is `8:13` here** — the same key, appended to the anchor's five-line audit file.

## For the next unit (secrets)

- It starts from `after/`. `spring.config.import` is one string today; a second location (the brief's
  `optional:configtree:./secrets/`) makes it a list or a comma string — re-measure where each import ranks: here the one
  import sits directly above the base document and below both profile sources (`stack`).
- The audit profile turns the `tiffinbox` logger to DEBUG. TiffinBox's one DEBUG call site today is the route line (5 lines
  at start); a DEBUG line that names the token would print it whenever `lunch` or `audit` is on.
- `Stack` prints a key's value from every source that holds it, and its `WINNER`: never point it at the token's key. It
  prints no record whole. (The previous unit's `Serve`/`Start` print the record whole — with a token component, that is
  the token. The secrets lesson later gave the record its own `toString()`, `[not shown]` in the token's place.)
- `tiffinbox-local.yaml` is git-ignored at any depth under the anchor: a developer's own token could live there, as a
  plain file.

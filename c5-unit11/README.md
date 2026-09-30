# c5-unit11 — Secrets: What Not to Commit

Course 5 · Spring Boot · Section 2 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-30.
Until now anyone who could reach TiffinBox's port could stop it: POST /shutdown asked for nothing. This unit gives
TiffinBox a secret with a job — `tiffinbox.shutdown-token`, required, asked for in an `X-Shutdown-Token` header — and
measures where such a secret may live: not in git (a deleted token is still in the history), not on the command line
(`ps` prints it), not in the environment (`ps eww` prints it), but in a config tree — one file, readable by its owner
alone, that neither `ps` shows. Then the leak nobody looks for: a validation rule on the token itself prints the token in
Boot's failure report, into the application's log. The fix is measured and landed.

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it. "Before" is `../c5-unit10/after/` (the
anchor as the last unit left it), **copied** to `.harness/before/`: its files are compared, never run, and this unit never
writes into another unit's folder. Clean builds, offline first; every number the video speaks is asserted; three runs per
capture; and **no capture, no README and no slide holds a demo token** (masked, and counted: see *The demo tokens*).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) `receipts.sh`
**dies** when a capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can see which one
moved (tested: with `change`'s published hash altered by one character, the run printed `change … DIFFERS from the
published aba369b8…`, stopped with exit 1 and released its lock; `receipts.md5` was restored). A whole run takes about
70 s on the author's Mac.

**The repository.** Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the commands): a copy of
`../c5-unit10/.m2-demo`, unchanged. This unit needs no artifact the previous one did not (the new constraint,
`@AssertTrue`, is in the `jakarta.validation-api` jar the record already used), and after a full run of `receipts.sh` no
file in `.m2-demo` is newer than the run's start (measured). The tree build falls back to Maven Central only if the offline build
fails. Offline re-run of the frozen tree: `mvn -o -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" verify` → BUILD
SUCCESS.

## The anchor change

Four files changed, none new (README aside) — `change`, below, shows every changed code line:
- `tiffinbox-core/…/TiffinBoxProperties.java` — the record gains `@NotBlank String shutdownToken` (the key
  `tiffinbox.shutdown-token`), and its length rule, 16 characters or more, as a yes-or-no method:
  `@AssertTrue(message = "tiffinbox.shutdown-token must be 16 characters or more") public boolean
  isShutdownTokenLongEnough()`. Not `@Size(min = 16)` on the token: the break (below) measures why.
- `tiffinbox-web/…/TiffinBoxServer.java` — POST /shutdown answers `403 {"error":"forbidden"}`, and the server keeps
  running, unless the request's `X-Shutdown-Token` header holds the token; the comparison is `MessageDigest.isEqual`, and
  nothing logs the header or the token.
- `tiffinbox-web/src/main/resources/application.yaml` — `spring.config.import` becomes a list:
  `optional:file:./tiffinbox-local.yaml` (unit 10's), then `optional:configtree:./secrets/` — a config tree: a folder in
  which each file's path is a key and its content the value; `secrets/tiffinbox/shutdown-token` is
  `tiffinbox.shutdown-token`. Optional, so a missing folder is no error; the record's `@NotBlank` makes the missing token
  loud instead.
- `.gitignore` (the anchor's) — gains `secrets/`.

**The run command is unchanged, but TiffinBox no longer starts without a token** (`required`), and **Course 4's seven
requests no longer stop it** (`door`: the POST gets 403, and the seven hash to `11bbc19ca107097dfd6477aa7fb0246b`). From
this unit on, the comparison set is **`curlset.sh PORT TOKENFILE`** (this folder): `../c4-unit31/curlset.sh` with one
change — the POST carries the header, read from a file (or from standard input with `-`), never from a command line.
With it the seven hash to `115c36bac276128e245ca57df11c2891` again: plain, and with the anchor README's logging, rush and
lunch commands (`serve`). The anchor README's own new commands — make a token, stop with the header — run in `serve` too.

## The demo tokens — fake, and never printed

Three demo tokens, defined once, at the top of `receipts.sh`: **26 characters** (TiffinBox's token in every run that
starts), **15** (one short of the length rule: the break) and **22** (a developer's token in `tiffinbox-local.yaml`:
`ranks`). They are fake, and meant to look it: they guard nothing but a demo server on 127.0.0.1 that every capture
stops. `receipts.sh` writes them into files under `.harness/` (git-ignored) when it runs; every command passes them as
`"$TOKEN"`, expanded only when the command runs, so no printed command holds one.

**Every capture is masked:** each token becomes `[masked: the 26-character token]` (or 15, or 22) by `gsub()`, in every
line. Where a token leaked — `ps`, `ps eww`, `git show`, the failure report — the capture shows the masked line **and a
count of the raw copies in the run's own output**, taken before masking. `receipts.sh`'s first check counts **0** raw
copies of the three tokens in every `.r-*.out`, this README, the exercise and `receipts.md5`; the deck's builder checks the
script, the slides and the prompter the same way. The exercise and the anchor README's commands make a random token
(`openssl rand -hex 16`) that nothing prints.

## The harness — lengths, never values

`harness/com/tiffinbox/harness/` holds two plain classes, neither with a class-level annotation (TiffinBox's
`@ComponentScan("com.tiffinbox")` never picks one up). `Run.tiffinbox` calls the tree's own `TiffinBoxServer.main(args)`
inside Boot's `SpringApplication.withHook(…)`; if `main` throws, the harness names the exception's type and rethrows it,
so the exit code is TiffinBox's own. `receipts.sh` compiles it with `javac -parameters` against `after/`'s jars.

- `Token <TiffinBox's arguments>` — what the working folder holds (`tiffinbox-local.yaml`, `secrets/`), then, once
  TiffinBox has started: the active profiles; the stack for `tiffinbox.shutdown-token` — the `WINNER` and the source it
  came from, then every property source in order with what it holds for the key and Boot's `Origin`; then the token the
  record holds. **Every value is printed as its length alone** — `(26 characters)` — never the value, and the record is
  never printed whole: a record's own `toString()` prints every component, the token included. It closes the context,
  which stops TiffinBox's server.

The previous units' `Serve` and `Start` printed the record whole; they are not used here. Unit 10's `Stack` prints a key's
values; it is not used here either.

**`$AFTER`** is the harness's classes plus `after/`'s jars; `receipts.sh` writes it to `.harness/after.classpath`.

## The folders the runs start in, and the commands

`application.yaml` imports `./tiffinbox-local.yaml` and `./secrets/` from the folder TiffinBox starts in, so every run
here starts in a folder under `.harness/` that `receipts.sh` makes fresh, and says so: `cd .harness/<folder> && java -jar
../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar …`. Every command is printed exactly as it runs (`receipts.sh`
passes it to `eval`).
- `empty/` — nothing (`required`; the command-line and environment runs of `where`).
- `tree/` — a config tree, `secrets/tiffinbox/shutdown-token`: the 26-character token and a newline, `-rw-------`, in
  `drwx------` folders (`door`, `where`, `break` A and A′, `serve`).
- `short/` — the same, with the 15-character token (`break` B and C).
- `both/` — the tree with the 26-character token, and a `tiffinbox-local.yaml` holding the 22-character one, written under
  the usual umask (022) as an editor would: `-rw-r--r--` (`ranks`).
- `anchor/` — made by the anchor README's own command, a random token (`serve`).
- `sized/` (a build, `.harness/sized`) — a copy of `after/` whose record is `sized/TiffinBoxProperties.java`: the length
  rule as `@Size(min = 16)` on the token itself. `files` diffs it against `after/`'s.
- `gitdemo/` — `git`'s throwaway repository, a repository of its own. Never this one.

**Ports** (Section 2 brief ⚑11: 18710-18719): door 18710 · required 18711 (never binds) · where 18712 · ranks 18713 ·
break 18714 (B and C never bind) · serve 18715 · the exercise 18719. `receipts.sh` first checks that nothing listens on
18425 or on any of its ports, and that each port is free again after its run.

## Masks, filters and hygiene — every one, declared

1. **The tokens:** every copy of the three demo tokens becomes `[masked: the N-character token]`, and this folder's
   absolute path becomes `…`, in every line of every capture (`gsub()`, the patterns escaped as literals). Counts of raw
   copies are taken from each run's own output before masking.
2. Boot's own log lines (each starts with an ISO timestamp and carries a pid) are dropped from the harness report and
   counted; so are the lines between the harness's first line and its report (the banner): the report's last line says how
   many of each. A kept log message loses its prefix (time, level, pid, thread, logger) through `sub()` — Boot's profile
   line.
3. A failed start shows its exit code, its WARN, ERROR, banner (`:: Spring Boot ::`) and `listening` line counts, the size
   of each stream, the level and logger of the line that logs Boot's failure report (read off it by `match()`: its time and
   pid are never printed), then the report itself (`APPLICATION FAILED TO START` to its end) **without its blank lines and
   its rows of asterisks**, then a counted line: `… N more line(s) of this run's output not shown …`.
4. `ps eww` prints a process's command line and then its whole environment — which is this shell's, and yours. `where`
   prints only its words that start `TIFFINBOX_`; the count of raw token copies covers the whole output.
5. `route DEBUG lines` counts TiffinBox's own route lines at DEBUG; the lines themselves are not shown.
6. `change` shows every changed **code** line: comments (Java: `/* */` blocks and lines starting `*` or `//`; YAML and
   `.gitignore`: lines starting `#`) and blank lines are dropped from both versions before git diffs them (`-U0`), and each
   header counts the changed lines that were dropped. `git check-ignore -v` separates its answer with a tab; `gsub()` turns
   it into three spaces.
7. `git` runs with a fixed author, committer and date (`demo`, 2026-09-30 12:00 UTC) and without your git configuration
   (`GIT_CONFIG_GLOBAL=/dev/null`, `GIT_CONFIG_NOSYSTEM=1`), so its commit hashes are the same on every run.
8. Hygiene: `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS` and `MAVEN_ARGS` before it runs anything — a variable of yours would otherwise become a property source
   (`required` prints the count left: 0). It refuses to run twice at once in this folder (`.r-lock`), or with a `secrets/`
   in this folder.

## 1 · The change — the token, its rule, the 403, the imports, and git

`.r-change.out` `aba369b922ebe2493894634217f8b2e2`

```
files, README aside: the previous tree 18 · after/ 18 · in both 18: identical 14, changed 4
  only before: (none)
  only after:  (none)
.gitignore, every changed line but comments and blanks (1 of those not shown):
+secrets/
TiffinBoxProperties.java, every changed line but comments and blanks (9 of those not shown):
+import jakarta.validation.constraints.AssertTrue;
-                                  @NotNull @Min(1) Integer port, @NotEmpty List<MealType> mealTypes) {
+                                  @NotNull @Min(1) Integer port, @NotEmpty List<MealType> mealTypes,
+                                  @NotBlank String shutdownToken) {
+    @AssertTrue(message = "tiffinbox.shutdown-token must be 16 characters or more")
+    public boolean isShutdownTokenLongEnough() {
+        return shutdownToken == null || shutdownToken.isBlank() || shutdownToken.length() >= 16;
+    }
TiffinBoxServer.java, every changed line but comments and blanks (11 of those not shown):
+import java.nio.charset.StandardCharsets;
+import java.security.MessageDigest;
+    private final byte[] shutdownToken;
+        this.shutdownToken = settings.shutdownToken().getBytes(StandardCharsets.UTF_8);
-        Method handler = routes.get(exchange.getRequestMethod() + " " + path);
+        String key = exchange.getRequestMethod() + " " + path;
+        Method handler = routes.get(key);
+        if (key.equals("POST /shutdown") && !holdsToken(exchange)) {   // the server keeps running
+            respond(exchange, 403, ordered("error", "forbidden"));
+            return;
+        }
+    private boolean holdsToken(HttpExchange exchange) {
+        String sent = exchange.getRequestHeaders().getFirst("X-Shutdown-Token");
+        return sent != null && MessageDigest.isEqual(sent.getBytes(StandardCharsets.UTF_8), shutdownToken);
+    }
application.yaml, every changed line but comments and blanks (9 of those not shown):
-    import: optional:file:./tiffinbox-local.yaml
+    import:
+      - optional:file:./tiffinbox-local.yaml
+      - optional:configtree:./secrets/
a throwaway git repository holding after/.gitignore, an empty tiffinbox-local.yaml and an empty secrets/tiffinbox/shutdown-token:
$ git check-ignore -v secrets/tiffinbox/shutdown-token tiffinbox-local.yaml
.gitignore:4:secrets/   secrets/tiffinbox/shutdown-token
.gitignore:2:tiffinbox-local.yaml   tiffinbox-local.yaml
$ git status --porcelain --ignored
?? .gitignore
!! secrets/
!! tiffinbox-local.yaml
```

Four files, none new. The record's token is `@NotBlank`, and its length rule is a method; the server's check sits in
`handle`, before any route runs; the import is a list of two; `.gitignore` gains `secrets/`. In a throwaway repository
holding `after/.gitignore`, git ignores both places a developer's secret could sit as a file.

## 2 · The door — Course 4's seven requests, then this unit's

`.r-door.out` `45ba7f187c6b140a06c8ea284c1d035f`

```
the token, in a config tree in tree/: -rw------- 27 bytes secrets/tiffinbox/shutdown-token
$ cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18710
  listens on: 127.0.0.1:18710 · WARN lines 0 · ERROR lines 0
Course 4's seven requests, as they stand - no header:
$ ../c4-unit31/curlset.sh 18710
POST  /shutdown   -> 403 application/json  {"error":"forbidden"}
  the seven responses: 7 lines · md5 11bbc19ca107097dfd6477aa7fb0246b
  2 s after that POST /shutdown: the JVM is still running · listening on 18710: 1 process(es)
this unit's seven requests - the same seven, the last one with the token in its header, read from the tree's file:
$ ./curlset.sh 18710 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  the first six responses of the two sets: identical
  the token, raw, in this run's whole output: 0 (standard output 18 lines · standard error 0 lines)
```

Without the header, POST /shutdown answers **403**, and two seconds later the JVM is still running and still listening.
With the header — read from the tree's file by `curlset.sh` — it answers **200**, the seven hash to `115c36ba…` as before,
and the JVM exits 0. The first six responses are the same in both sets. The token appears 0 times in the run's output.

## 3 · Required — no token anywhere

`.r-required.out` `058c08ac010bed2f4c675077bdd32bc7`

```
empty/ holds 0 file(s) · TIFFINBOX_ variables in this script's environment: 0
$ cd .harness/empty && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18711
  exit 1 · WARN lines 1 · ERROR lines 1 · banner lines 1 · listening lines 0
  standard output 35 lines · standard error 0 lines · the report: logged at ERROR by o.s.b.d.LoggingFailureAnalysisReporter
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
      Property: tiffinbox.shutdownToken
      Value: "null"
      Reason: must not be blank
  Action:
  Update your application's configuration
  … 27 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
```

The config tree is `optional:`, so a missing `secrets/` is no error; the record's `@NotBlank` then stops the start, before
the port opens (0 listening lines), with the unit-09 report: the property (the Java component's name,
`tiffinbox.shutdownToken`), `Value: "null"`, and the rule. Standard error is empty: Boot logs the report on standard output.

## 4 · Git keeps what you delete

`.r-git.out` `9c6697301cf51cf74bd02693de98d163`

```
a throwaway repository of its own, in .harness/gitdemo (which this repository ignores):
$ git init -q -b main
$ printf 'tiffinbox:\n  cooks: 3\n' > application.yaml && git add application.yaml && git commit -q -m 'config'
$ printf '  shutdown-token: %s\n' "$TOKEN" >> application.yaml && git commit -q -am 'make it start'
$ sed -i '' '/shutdown-token/d' application.yaml && git commit -q -am 'remove the token'
$ git log --oneline
94aac5d remove the token
7d2d4f9 make it start
24381a3 config
$ git grep -c "$TOKEN" HEAD; echo "exit $?"
exit 1
$ grep -c "$TOKEN" application.yaml; echo "exit $?"
0
exit 1
$ git log -S "$TOKEN" --oneline
94aac5d remove the token
7d2d4f9 make it start
$ git show HEAD~1:application.yaml
tiffinbox:
  cooks: 3
  shutdown-token: [masked: the 26-character token]
commits in the history: 3 · commits git log -S names: 2 · the token, raw, in HEAD's files: 0 · in HEAD~1's application.yaml: 1
```

HEAD holds the token 0 times — the working file too (`grep -c` → 0) — yet `git log -S` names the **2** commits whose
changes added or removed it, and `git show HEAD~1:application.yaml` prints the file as it was, token included (masked
here). Deleting is not removing: a committed token is in every clone of the history.

## 5 · Who can read it — the command line, the environment, a config tree

`.r-where.out` `20a55d26690c88c2a45b25d9d321f4fb`

```
the command line
$ cd .harness/empty && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712 --tiffinbox.shutdown-token="$TOKEN"
  listens on: 127.0.0.1:18712 · WARN lines 0 · ERROR lines 0
  $ ps -o command= -p "$pid"
  java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712 --tiffinbox.shutdown-token=[masked: the 26-character token]
  $ ps eww -o command= -p "$pid"     (its words that start TIFFINBOX_)
  (none)
$ ./curlset.sh 18712 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
an environment variable
$ cd .harness/empty && TIFFINBOX_SHUTDOWNTOKEN="$TOKEN" java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712
  listens on: 127.0.0.1:18712 · WARN lines 0 · ERROR lines 0
  $ ps -o command= -p "$pid"
  java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712
  $ ps eww -o command= -p "$pid"     (its words that start TIFFINBOX_)
  TIFFINBOX_SHUTDOWNTOKEN=[masked: the 26-character token]
$ ./curlset.sh 18712 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the same variable, the other spelling
$ cd .harness/empty && TIFFINBOX_SHUTDOWN_TOKEN="$TOKEN" java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712
  listens on: 127.0.0.1:18712 · WARN lines 0 · ERROR lines 0
  $ ps -o command= -p "$pid"
  java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712
  $ ps eww -o command= -p "$pid"     (its words that start TIFFINBOX_)
  TIFFINBOX_SHUTDOWN_TOKEN=[masked: the 26-character token]
$ ./curlset.sh 18712 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
a config tree: secrets/tiffinbox/shutdown-token, in the folder TiffinBox starts in
$ cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712
  listens on: 127.0.0.1:18712 · WARN lines 0 · ERROR lines 0
  $ ps -o command= -p "$pid"
  java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18712
  $ ps eww -o command= -p "$pid"     (its words that start TIFFINBOX_)
  (none)
$ ./curlset.sh 18712 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the config tree's file:
  -rw------- 27 bytes secrets/tiffinbox/shutdown-token · its folders: drwx------ secrets drwx------ secrets/tiffinbox · its last byte: \n
  the token: 26 characters · the header curlset.sh sends: the file's first line, 26 characters
who printed the token, raw:
  the token was in           ps -o command=  ps eww   POST /shutdown, the header from the tree's file
  the command line           1               1        200
  TIFFINBOX_SHUTDOWNTOKEN    0               1        200
  TIFFINBOX_SHUTDOWN_TOKEN   0               1        200
  a config tree              0               0        200
```

The same 26-character token in three places, each run then stopped by this unit's seven (the header read from `tree/`'s
file — so a 200 means the token TiffinBox bound **is** that one). On the command line, `ps` prints the whole command line,
token included (1). In the environment — either spelling, `TIFFINBOX_SHUTDOWNTOKEN` or `TIFFINBOX_SHUTDOWN_TOKEN`; both
bind — plain `ps` shows nothing, and `ps eww` prints it (1). **Measured as the same user only.** In a config tree, neither
shows it. The file is 27 bytes, its last byte a newline; the header carries the file's first line, 26 characters; the door
opens: Boot dropped the newline (the probe's "trimmed", re-measured end to end).

## 6 · Two imports, ranked — and a developer's token in a plain file

`.r-ranks.out` `0c5315219ad09252dad53300629892aa`

```
both/: -rw------- 27 bytes secrets/tiffinbox/shutdown-token · -rw-r--r-- 52 bytes tiffinbox-local.yaml
  tiffinbox-local.yaml, whole:
    1 | tiffinbox:
    2 |   shutdown-token: [masked: the 22-character token]
$ cd .harness/both && java -cp "$AFTER" com.tiffinbox.harness.Token --tiffinbox.port=18713 --spring.profiles.active=lunch
exit 0 · WARN lines 0 · ERROR lines 0 · Boot: The following 3 profiles are active: "lunch", "rush", "audit"
the working folder: tiffinbox-local.yaml present · secrets/ present
active profiles: [lunch, rush, audit]
KEY tiffinbox.shutdown-token -> WINNER (26 characters) · from source 8 of 11, Config tree '…/.harness/both/./secrets'
   1 configurationProperties    (26 characters)   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application-audit.yaml]' via location 'optional:classpath:/' -
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) -
   8 Config tree '…/.harness/both/./secrets' (26 characters)   origin: file […/.harness/both/./secrets/tiffinbox/shutdown-token] - 1:1
   9 Config resource 'file [tiffinbox-local.yaml]' via location 'optional:file:./tiffinbox-local.yaml' (22 characters)   origin: URL [file:tiffinbox-local.yaml] - 2:19
  10 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) -
  11 applicationInfo            -
the record's token: (26 characters)
… elided: 13 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

With `lunch` on, from `both/`: the two profile sources rank 6 and 7; the config tree, the later import, ranks 8, above
`tiffinbox-local.yaml` at 9; the base document is 10. The first that holds the key answers: **the tree's token (26
characters) wins over the local file's (22)**, and the record holds 26 characters. Both imports sit below the profiles
and above the document that imports them. (Unit 10 measured the single import directly above document #0; it still is —
the new import sits above it.) The local file is git-ignored, but it is a plain file, `-rw-r--r--`: a token there is one
more copy on disk.

## 7 · The leak nobody expects — A/B/A′ on `sized/`, then C on `after/`

`.r-break.out` `ac564c2ecf342ccf8e224c1bb4975c69`

```
A   26 characters · sized/: a copy of after/ whose length rule is @Size(min = 16) on the token itself
  the token's file: -rw------- 27 bytes secrets/tiffinbox/shutdown-token
$ cd .harness/tree && java -jar ../sized/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18714
  listens on: 127.0.0.1:18714 · WARN lines 0 · ERROR lines 0
$ ./curlset.sh 18714 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  the token, raw, in this run's whole output: 0 (standard output 18 lines · standard error 0 lines)
B   15 characters · the same jar
  the token's file: -rw------- 16 bytes secrets/tiffinbox/shutdown-token
$ cd .harness/short && java -jar ../sized/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18714
  exit 1 · WARN lines 1 · ERROR lines 1 · banner lines 1 · listening lines 0
  standard output 36 lines · standard error 0 lines · the report: logged at ERROR by o.s.b.d.LoggingFailureAnalysisReporter
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
      Property: tiffinbox.shutdownToken
      Value: "[masked: the 15-character token]"
      Origin: file […/.harness/short/./secrets/tiffinbox/shutdown-token] - 1:1
      Reason: size must be between 16 and 2147483647
  Action:
  Update your application's configuration
  … 27 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
  the token, raw, in this run's whole output: 1 · on standard output 1 · on standard error 0
A′  A, re-run
  the token's file: -rw------- 27 bytes secrets/tiffinbox/shutdown-token
$ cd .harness/tree && java -jar ../sized/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18714
  listens on: 127.0.0.1:18714 · WARN lines 0 · ERROR lines 0
$ ./curlset.sh 18714 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  the token, raw, in this run's whole output: 0 (standard output 18 lines · standard error 0 lines)
C   15 characters · after/, as shipped: the length rule is a yes-or-no method, isShutdownTokenLongEnough()
  the token's file: -rw------- 16 bytes secrets/tiffinbox/shutdown-token
$ cd .harness/short && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18714
  exit 1 · WARN lines 1 · ERROR lines 1 · banner lines 1 · listening lines 0
  standard output 35 lines · standard error 0 lines · the report: logged at ERROR by o.s.b.d.LoggingFailureAnalysisReporter
  APPLICATION FAILED TO START
  Description:
  Binding to target com.tiffinbox.TiffinBoxProperties failed:
      Property: tiffinbox.shutdownTokenLongEnough
      Value: "false"
      Reason: tiffinbox.shutdown-token must be 16 characters or more
  Action:
  Update your application's configuration
  … 27 more line(s) of this run's output not shown: the banner, Boot's log, the blank lines and the stack frames …
  the token, raw, in this run's whole output: 0 · on standard output 0 · on standard error 0
```

**A** (26 characters, `sized/`, the rule as `@Size(min = 16)` on the token): TiffinBox starts, the seven hash to
`115c36ba…`, the token is printed 0 times. **B** (15 characters): exit 1 before listening, and Boot's report prints the
token whole — `Value:` (masked here), with the file it came from, `Origin: file […/secrets/tiffinbox/shutdown-token] -
1:1`. The raw count is **1, on standard output; standard error holds 0 lines**: the report is a log event at **ERROR**
(`o.s.b.d.LoggingFailureAnalysisReporter`), so it goes wherever the application's log goes. **A′** is A, line for line.
**C** (`after/` as shipped, the same 15 characters; labelled C per §R.1): exit 1, and the report names the method —
`Property: tiffinbox.shutdownTokenLongEnough` · `Value: "false"` · the message — with no `Origin` line, and the token
0 times.

## 8 · The jar: the anchor README's commands, and the seven responses

`.r-serve.out` `a86cd47a1cbe3fa7fb0c6a7ade7e7d1f`

```
the anchor README's commands, on this unit's port, in a fresh folder, anchor/ - its token random, as the README makes it
$ cd .harness/anchor && mkdir -p secrets/tiffinbox && (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)
  exit 0 · -rw------- 33 bytes secrets/tiffinbox/shutdown-token · printed: 0 line(s)
$ cd .harness/anchor && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715
  listens on: 127.0.0.1:18715 · WARN lines 0 · ERROR lines 0
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18715/shutdown
{"error":"forbidden"} 403
  1 s later: the JVM is still running
$ cd .harness/anchor && { printf 'X-Shutdown-Token: '; head -n 1 secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18715/shutdown
{"stopping":true} 200
  exit 0
  the token, raw, in this run's whole output: 0
plain
$ cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715
  listens on: 127.0.0.1:18715 · WARN lines 0 · ERROR lines 0
$ ./curlset.sh 18715 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  Boot: No active profile set, falling back to 1 default profile: "default" · route DEBUG lines 0
  the token, raw, in this run's whole output: 0 (standard output 18 lines · standard error 0 lines)
the anchor README's logging command
$ cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715 --logging.level.tiffinbox=debug
  listens on: 127.0.0.1:18715 · WARN lines 0 · ERROR lines 0
$ ./curlset.sh 18715 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  Boot: No active profile set, falling back to 1 default profile: "default" · route DEBUG lines 5
  the token, raw, in this run's whole output: 0 (standard output 23 lines · standard error 0 lines)
the lunch rush alone
$ cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715 --spring.profiles.active=rush
  listens on: 127.0.0.1:18715 · WARN lines 0 · ERROR lines 0
$ ./curlset.sh 18715 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  Boot: The following 1 profile is active: "rush" · route DEBUG lines 0
  the token, raw, in this run's whole output: 0 (standard output 18 lines · standard error 0 lines)
the group, lunch: the audit's logging at debug
$ cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18715 --spring.profiles.active=lunch
  listens on: 127.0.0.1:18715 · WARN lines 0 · ERROR lines 0
$ ./curlset.sh 18715 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  Boot: The following 3 profiles are active: "lunch", "rush", "audit" · route DEBUG lines 5
  the token, raw, in this run's whole output: 0 (standard output 23 lines · standard error 0 lines)
```

The anchor README's commands, on this unit's port: the token made by `openssl rand -hex 16` (33 bytes with its newline,
`-rw-------`, nothing printed); POST /shutdown without the header → `{"error":"forbidden"} 403`, the JVM still running;
with the header, piped from the file → `{"stopping":true} 200`, exit 0. Then the seven, four ways: `115c36ba…` every time.
With `lunch` on — the audit's logging at DEBUG — 5 route lines, and the token 0 times in the run's whole output (hazard:
TiffinBox's only DEBUG call is the route line, and nothing logs the record).

## 9 · The demo files, against the files they stand in for

`.r-files.out` `28e42107af138bdfd15137ea6db79b66`

```
sized/TiffinBoxProperties.java, against after/'s TiffinBoxProperties.java:
  3d2
  < import jakarta.validation.constraints.AssertTrue;
  7a7
  > import jakarta.validation.constraints.Size;
  28,29c28,29
  <  * logs the record. The token's length rule is a yes-or-no method, not a constraint on the token itself: a failure report
  <  * prints the value of the property that broke a rule, so a rule on the token would print the token.
  ---
  >  * logs the record. The token's length rule is a constraint on the token itself, {@code @Size(min = 16)} - the obvious
  >  * way to write it.
  42,48c42
  <                                   @NotBlank String shutdownToken) {
  < 
  <     /** The token's length rule. A failure report prints what this returns - false - and never the token. */
  <     @AssertTrue(message = "tiffinbox.shutdown-token must be 16 characters or more")
  <     public boolean isShutdownTokenLongEnough() {
  <         return shutdownToken == null || shutdownToken.isBlank() || shutdownToken.length() >= 16;
  <     }
  ---
  >                                   @NotBlank @Size(min = 16) String shutdownToken) {
curlset.sh, against ../c4-unit31/curlset.sh:
  2,3c2,4
  < # The comparison set (brief ⚑2): one request per layer the rewire touched. Status, content type, body.
  < # Loopback only. $1 = port.
  ---
  > # This unit's comparison set: ../c4-unit31/curlset.sh with ONE change - POST /shutdown carries the X-Shutdown-Token
  > # header. The token is the first line of the file $2 names (a config tree's file; - reads standard input, first), handed
  > # to curl on its standard input: it is never on a command line, curl's or this script's. Loopback only. $1 = port.
  7a9
  > if [ "$2" = - ]; then IFS= read -r tok; else IFS= read -r tok < "$2"; fi
  14c16,17
  < req POST /shutdown
  ---
  > out=$(printf 'X-Shutdown-Token: %s\n' "$tok" | curl -s -o "$T" -w '%{http_code} %{content_type}' -H @- -X POST "$B/shutdown")
  > printf '%-5s %-11s -> %s  %s\n' POST /shutdown "$out" "$(cat "$T")"
```

`sized/` differs from `after/`'s record in the length rule alone (and the comment that describes it). `curlset.sh`
differs from Course 4's in its comment and the POST alone: the token is read first (from the file, or from standard
input), then handed to curl on curl's standard input (`-H @-`).

## Exercise

`exercise/README.md` — in `.harness/mine`, with a token of your own (`openssl rand -hex 16`), start TiffinBox with the
token in `TIFFINBOX_SHUTDOWNTOKEN` (port 18719); this unit's seven stop it: `POST  /shutdown   -> 200 application/json
{"stopping":true}`. Move the token into a config tree file, newline included, start with no `TIFFINBOX_` variable, and
POST /shutdown must still answer 200. Measured answers, run exactly as written in a clean shell, in
`exercise/solution/SOLUTION.md`: the file `-rw------- 33 bytes`, 0 `TIFFINBOX_` words in `ps eww`, the same 200 line, and
the token 0 times in either round's log.

## Found on the way

- **The failure report goes to standard output, not standard error.** The brief's "into every log that collects stderr"
  does not hold: the report is a log event at ERROR from `o.s.b.d.LoggingFailureAnalysisReporter`, on standard output;
  standard error is empty in every failed start here. It goes wherever the application's log goes.
- **The leak reaches the recommended place.** From a config tree, B's `Origin` names the tree's file: the tree keeps the
  token out of `ps` and git, and the report still prints it. The probe measured the command line.
- **⚑9's open fix, measured:** a constraint on a `boolean` method (`@AssertTrue`) — the report prints what the method
  returned (`false`), names the method as the property, and has no `Origin` line. `@NotBlank` stays on the token: its
  failure prints `null` (missing) — never a token.
- **`ps eww` prints the command line too**, so a command-line token shows in both columns (1 and 1).
- **`curlset.sh` takes no token argument.** The probe's version took it as `$2`, which `ps` would print while it runs.
- **Import order, re-measured with the list:** the later import (the tree, 8) ranks above the earlier (the local file, 9);
  both below the profile sources (6, 7) and above the base document (10).

## For the next unit, and for RED

- Unit 12's C check points at `c5-unit04/after` (brief/FACTORY-NEXT). `c5-unit11/after` now **requires a token** to
  start: a C run on it needs a `secrets/` (or a variable) in the folder it starts in, or it exits 1 with `must not be
  blank` — and its seven need this folder's `curlset.sh` with a token file. The starter itself (`c5-unit12/`) never
  touches the anchor (⚑10).
- **Every later receipt and verify script that stops TiffinBox** must use `c5-unit11/curlset.sh PORT TOKENFILE` (brief
  ⚑9's cost); `c4-unit31/curlset.sh` now leaves the server running (and `seven()`-style waits would time out).
- Open for RED: the record keeps its default `toString()`, which prints the token; nothing in TiffinBox logs the record,
  and the harness never prints it — a masked `toString()` was not decided by the brief, so it was not added. `ps eww` is
  measured as the same user only. Only the nested config-tree form is measured (the dotted file name is not).

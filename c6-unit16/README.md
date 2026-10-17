# c6-unit16 — ProblemDetail and RFC 9457

Course 6 · Spring Web MVC · Section 3 (Errors Done Right), its third unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), **GraalVM CE 25.3.4.1** (native-image 25.0.4.1), **Docker on OrbStack**,
2026-10-17. Until this unit TiffinBox said "no" in four shapes: Boot's error body with its four keys for every error Spring MVC decided,
the advice's and the 403's `{"error":…}`, the validation method's bare field map, and a 409 with no body. This unit gives them one: a
**problem detail** — RFC 9457's, the internet standard for an error's shape (a `type`, a `title`, the `status`, a `detail`, the `instance`,
and **extension members** of the application's own), written as `application/problem+json`. One key, `spring.mvc.problemdetails.enabled:
true`, hands Spring MVC's own errors to Boot's `ProblemDetailsExceptionHandler`; TiffinBox's own handler and its 400, 403 and 409 return
`ProblemDetail`s. It measures what moved (the seven, by two lines), who answers (read off the running application), what every client
gets, what the key cost (the reasons left the log), what it does not reach (a route's unexpected 500), the ways not taken, and that the
jar, the AOT jar, the native binary and the image all serve it.

**The anchor changes (brief ⚑2, ⚑4).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and
`diff -rq -x target ../c6-tiffinbox after/` is empty at this unit's commit. "Before" is `../c6-unit15/after` — the exception-handler
lesson's frozen tree, which `c6-tiffinbox` equalled before this unit. Both trees are read and copied under `.harness/`, never built in
place. Three files changed, besides the anchor's README — none new (`change`):

- `tiffinbox-web/src/main/resources/application.yaml` — 98 lines → 106: under `spring:` in the first document, a five-line comment and
  `mvc: problemdetails: enabled: true`, its last line on **line 64**, above the `---` on line 99 (R.87's check, in `change`).
- `TiffinBoxErrors.java` — 28 → 30 lines (14 → 15 of code): the handler returns a `ProblemDetail` —
  `ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage())`, `setTitle("Customer not found")`, `setProperty("name",
  e.name())` — and its `@ResponseStatus` line is gone (the status is the problem detail's); the Javadoc says so.
- `TiffinBoxServer.java` — 274 → 296 lines (140 → 155 of code): the 400 is `problem(HttpStatus.BAD_REQUEST, invalid(errors))` — a
  `ProblemDetail` whose detail is `the customer breaks N rule(s)`, title `Invalid customer`, member `errors` the `TreeMap` of fields; the 409
  `a customer named X already exists`; the 403 `the shutdown token is missing or wrong`; `shutdown()` returns `ResponseEntity<?>`; two
  helpers, `problem(…)`; the Javadoc paragraphs on the 409's "no body", the 400's map and the missing `BindingResult` rewritten.

The POMs, the Dockerfile and `compose.yaml` are unchanged — 23 of the tree's 27 files byte for byte — and the jar holds the same 56
libraries and the same 9 `com/tiffinbox/web` classes.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`; on OrbStack `orb start` is tried once if it does not), with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native
build per `forms` run (three per receipt); its seconds, and the 20-minute bound, go to the terminal only. **Start it in a process
group of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a group, and one
run's clean-up would stop the other's JVMs (R.94).

**Runs of record (2026-10-17, this script as committed):** **1,054 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with HOME and a
plain PATH, this folder, its own process group, `.m2-demo` re-seeded from `_research/m2-seed-s3/` alone: all 9 captures 3/3, every check
passed, then — as designed for a first run — "no published hash", the nine hashes put into `receipts.md5`); **1,074 s under `bash
receipts.sh`** (Homebrew bash 5.3.9, re-seeded: exit 0, all 9 = published, every check passed); **1,071 s under `./receipts.sh` again**
(re-seeded: exit 0, all 9 = published) — and a fourth full run under /bin/bash 3.2 (a SIGINT test whose detector missed the builder ran to
the end: exit 0, all 9 = published). The native builds 133-142 s each. **A sealed fresh clone**: `git clone` of tiffinbox-java at 7832ef6,
this unit's and the anchor's 43 files put in as git would take them (0 differing from the working tree); `env -i`, a `HOME` of its own whose
`.mavenrc` points every Java proxy at a refusing port, Maven settings sending every repository to a `file://` copy of Central's files made
from `_research/m2-seed-s3/` (4,360 files), the proxy variables at the same refusing port, `GRAALVM_HOME`, `DOCKER_CONFIG=~/.docker`,
`/bin/bash` 3.2, a process group of its own: **exit 0, all 9 = published, every check passed, 1,079 s; 526 artifacts, every one from the
`file://` copy** (0 from anywhere else); its first build said `offline: no`, as a fresh clone's must, and every capture's build `offline:
yes`. This README's prose (the run facts, these lines) was completed after the sealed run; nothing it reads (`mine()`) changed. **A last run on the finished files** (this README, the anchor's, everything as committed): `bash receipts.sh`, re-seeded, exit 0, all 9 = published, 1,058 s. **The
exercise as viewers run it** — see "Found on the way".

Published hashes: change `73f2b4cbc9034ae442af03dd6231c9d7` · seven `866b3671d38c87261d02e74e4056d396` · own `3cf9bfad986dbd50dc4c6165ea626b20` · accept `e004c39074b159966cbe1e0cdfc2af38` · flag `3eb13a29caed61a55dc0f3396fd250b3` · edges `f9155b1023741b0c9fb345c1213ba90d` · losers `6d7a8e5c44abb4dc34adf390195d2c30` · exercise `f31329abbd2b7fe21030f45314b8b11d` · forms `792c63543cd8f3bd6c69519ae39c9b20`.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but twelve, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.mvc.problemdetails.enabled=false
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.mvc.log-resolved-exception=true
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.web.error.include-message=always
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.mvc.problemdetail.enabled=true
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.mvc.problem-details.enabled=true
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" harness/probe/web/Boom.java harness/probe/web/ValidIn.java harness/probe/web/Who.java
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/customers/Nobody
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:18431/customers/Nobody
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:18431/customers/Nobody
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
```

The first two are the anchor's run line and its class-path line with `-Duser.language=en -Duser.country=US` after `java` — asserted to be
exactly that — and every java line a capture starts takes the same two options in the same place (`at()`; a last check refuses any
capture's java line without them). The next five are the first with one option more, each asserted to be exactly that: the key off for
one run (`flag` B), Spring MVC's `log-resolved-exception` (`flag` C), Boot's `include-message` (`edges`, joined to the class-path line),
and the key's two misspellings (`losers`): singular, as the class is named, and with a dash. The javac line compiles the course's harness,
the three files of `harness/probe/web`, against after/'s extracted jar, with `-parameters`. The three Accept lines are the anchor's new
line — `curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/customers/Nobody`, this unit's, in its
README's own section: the exception-handler lesson's line with curl's Content-Type printed — with one `Accept` header each: a browser's type
alone, XML alone, and a browser's whole header (Chrome's). The last is the request-body lesson's POST line with curl's Content-Type
printed. Every other request is one of those with its path or its body swapped: `tq` (the anchor's new line, a path, an optional Accept),
`pq` (the POST line, a body; a form's Content-Type for the 415), `xq` (the secrets lesson's POST /shutdown without the token, Content-Type
printed). The bodies are read off the anchor's README lines — Asha's (the request-body lesson), Mohan's two point seven meals (the
Jackson lesson), the four broken rules (the validation lesson) — and two are made from Asha's and asserted: cut after its first key
(`{"name":`, JSON nobody can read) and its meal type's key misspelt (`"mealTyp"`).

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script still fills `.m2-demo`, makes the eight other captures, each checked against `receipts.md5`,
then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s3/` alone — 5,837 files, no `com/tiffinbox` — and re-seeded so before each run of record.
**Nothing was downloaded** for this unit: every build said `offline: yes`, the native plugin read its metadata repository from `.m2-demo`,
and every native build log holds 0 lines of the plugin's own download. A fresh clone's `.m2-demo` is empty (git ignores it): the first
build — `after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven Central and says `offline: no`; every capture's
build then says `offline: yes`. **Docker:** no pull — `docker build` prints its `load metadata` line and the base image's digest, and
`its lines that say pull: 0`. The image (`tiffinbox-problem:1.0.0`) and the container (`tiffinbox-problem`) are this script's own
names, checked absent first and removed on every exit; the build cache is not pruned (`.dockerignore` keeps `secrets/` out of every
build context). **At run time** every request goes to `127.0.0.1`.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, mounted read-only into the container (`:ro`), and sent only by `../c5-unit11/curlset.sh` and
`harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so
are the log of every JVM that served, the container's log (`docker logs`), every file this unit ships, the binary's bytes, and every
blob of the image (`docker save`, each gzip layer unpacked; `forms`): 0 everywhere. The header's name, `X-Shutdown-Token`, is counted
too: 0 in every log. No capture of this unit sends a secret anywhere else, so no canary is needed (S3.10): every exception message
here — Spring MVC's, Jackson's, `CustomerNotFound`'s, `Boom`'s fixed one — holds what a client sent in its path or body, never a header,
and `include-message` (`edges`) is shown on `Boom`'s fixed message. The exercise makes a token of its own (`openssl rand -hex 13`),
counted 0 times in its own log and never printed.

## The locale — pinned per JVM

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S3.1, RED B2 #111), and `Who`
prints the JVM's locale (`en_US`). Hibernate Validator's messages are in the 400's `errors` member (`must not be blank`, …), and Spring's
problem-detail details (`Failed to convert …`, `No static resource …`), Jackson's messages in WARN lines and Boot's Whitelabel page are
English text a JVM in another language could word otherwise. The binary takes no JVM options (its line has none: `at()` checks); the
image runs the jar on Linux with no locale set. A last check refuses any capture whose java line lacks the two options.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`). `.harness/before`, `.harness/after` — the two trees, copied, each with
  a config tree, built and extracted (`change`); `.harness/sub` — after/ with `harness/subclass/TiffinBoxErrors.java` in place of its
  advice and application.yaml's key block deleted (`losers`); `.harness/nokey` — after/ with the key block deleted alone (`losers`: the
  previous lesson's `application.yaml`, byte for byte — checked); `.harness/nat` — after/'s native build, and `.harness/natb` — the
  previous tree built with the native profile, for its AOT metadata (`forms`); `.harness/hc` — the harness's classes; `.harness/mine` —
  the exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`), joined by `--spring.main.sources` on
  the extracted jar's class path: `Who` reads the running application as text — `/probe/who/advice`: the `ResponseEntityExceptionHandler`
  beans; the `ExceptionHandlerExceptionResolver`'s advice cache in the order it asks, each advice's type and order and its
  `@ExceptionHandler` methods (its own and those it inherits, with how many exception types each takes); for seven exception types the
  method each advice resolves it to (the resolver's own `resolveMethodByExceptionType`); the JVM's locale — and `/probe/who/problem`:
  Spring's `ProblemDetail` class, its instance fields in declaration order and what `ProblemDetail.forStatus(HttpStatus.NOT_FOUND)`
  holds before anything is set. `Boom` — `/probe/boom` throws `IllegalStateException("the kitchen is on fire")`, an error nobody
  handles. `ValidIn` — `POST /probe/valid`, a `@Valid @RequestBody Customer` with no `BindingResult` beside it.
  `harness/subclass/TiffinBoxErrors.java` — the advice, `final`, extending Spring MVC's `ResponseEntityExceptionHandler`, its handler
  after/'s. `harness/exercise/application.yaml` — after/'s without the key (= the previous tree's, checked) — and
  `harness/exercise/tiffinbox-local.yaml` — a developer's own file with the key misspelt. `harness/shutdown.sh` — POST `/shutdown` with
  the token read from its file (the binding lesson's, unchanged).
- **Ports** (brief ⚑1, 19450-19459): after/'s jar 19450 · the previous tree 19451 · after/ with the harness joined 19452 · the previous
  tree with the harness 19453 · the subclass copy 19454 · the key-less copy 19455 · the AOT jar 19456 · the image 19457 · the binary
  19458 · the exercise 19459. All ten, 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free
  first; a run that listens on 8080 or 35729 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character
   token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole
   word → `<user>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, the GraalVM's folder, a unit
   number, Boot's process line, a log time, an unmasked timestamp, a `GMT`, `CET` or `CEST` date, a date in Java's `Date` form, a thread
   number, a stack frame, a whole HTML page (`<html>` or `<!doctype`), a `sha256:` ID other than the base image's digest, `:8080` or
   `:35729`, a carriage return, or a command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — both forms — in every answer printed and in the seven, which are hashed after it. **A problem detail carries no
   timestamp**: the mask runs on after/'s seven too and prints the lines it changed — 0 (the previous tree's: 2) — and its form, `none`.
3. **Boot's Whitelabel page and Tomcat's** (`pagef`, S3.6, S3.11): an HTML answer is printed as Boot's Whitelabel page's `<h1>` and error
   line, its `created` date — written in the JVM's time zone — masked and its paragraph counted; any other page (Tomcat's own `%2F` 400) as
   its `<h1>` and its length, never shown; curl's status and `Content-Type` follow. Checked on two planted pages before any capture.
4. **A problem detail is printed as the answer's bytes** — never re-ordered, never through a JSON pretty-printer (S3.16): its key order
   (the four standard ones alphabetical, then the extension members) and the missing `type` are read off the answer.
5. **Log lines** (`logl`, `recs`): from their logger on, as the log prints the logger — `.m.m.a.ExceptionHandlerExceptionResolver`,
   `.w.s.m.s.DefaultHandlerExceptionResolver` and `o.s.web.servlet.PageNotFound` are **Spring MVC's**; `o.a.c.c.C.[.[.[/].[dispatcherServlet]`
   is **Tomcat's**; `ProblemDetailsExceptionHandler`, `BasicErrorController` and the Whitelabel page are **Boot's**; Boot's first line is
   cut before ` with PID`. Every request a capture asks (`rq`) ends its answer's last line with `· WARN lines it added: N · ERROR lines:
   M`, and each WARN or ERROR record follows: its level, logger and message, then the exception line under it; its stack frames bounded
   ("over 40") and its other lines counted, none shown (checked on a planted log first).
6. **Spring's AOT metadata** (`aotcmp`): the two trees' `reachability-metadata.json`, compared — reflection entries counted, the types only
   one of them registers named, with what each registers; the file itself is not printed.
7. **The native build's lines**, **`docker build --progress=plain`**, **inside the container** and **on this Mac**: as the
   exception-handler lesson's receipts declare them (warnings' file URLs → `…`; step numbers and timings cut; `/proc/net/tcp` LISTEN rows;
   `lsof` by pid, the address column alone).
8. **A URL that holds a character the shell reads** is single-quoted on the command line, so the printed command is the one that ran.
9. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes"). **The
   subclass's answers against after/'s**: the six answer lines of each block, compared in the capture ("the same").

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the
exercise's shell `$xpid` with every process under it — `killtree`), sweeps its own process group for any TiffinBox JVM, binary or
`native-image` left, removes the container and the image, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes
`.r-lock`. The published captures are untouched. No `wait` in the script, its checks or the exercise is bare (S3.9; a check refuses one).

**Measured** on this script (2026-10-17), started as a terminal starts its foreground job (SIGINT at its default, a process group of its
own — from a script, `python3` with `signal.signal(signal.SIGINT, signal.SIG_DFL)` and `os.setpgrp()`): SIGINT to its process group during
the native build (555 s in, native-image's builder running for 20 s — 5 processes in the group, 2 of them java): **exit 130** 0.2 s
later; 5 s later 0 processes in the group, 0 anywhere naming this folder, no image builder left; 19450-19459, 8080, 18425 and 35729 free;
no `tiffinbox-problem` container or image, no `.r-lock`, no unfinished capture run; the published captures unchanged (md5 of all nine,
before and after).

## 1 · change — one key, a problem detail of TiffinBox's own, and the 400, 403 and 409

Both trees copied under `.harness/`, built with the README's line (offline) and extracted; the harness compiled against after/'s jar
(this unit's `javac` line, `-parameters`: three classes). **Four files differ** — the anchor's `README.md`, `TiffinBoxErrors.java`,
`TiffinBoxServer.java`, `application.yaml` — and none is new; 23 of 27 byte for byte. `application.yaml` 98 → 106: the diff whole, the
key's line **64**, the first `---` at **99** — in the first document (R.87). **Boot's own metadata** for the key, read off
`spring-boot-webmvc-4.1.1.jar`: `Boolean`, default **false**, "Whether RFC 9457 Problem Details support should be enabled." — and for
`spring.mvc.log-resolved-exception`, default false. `TiffinBoxErrors.java` 28 → 30 lines, its code lines' diff whole: `@ResponseStatus`,
the `Map` and its imports out, `ProblemDetail notFound(…)` with its title and `name` member in. `TiffinBoxServer.java` 274 → 296,
`ProblemDetail` named 0 → 6, `"forbidden"` 1 → 0 — its code lines' diff whole. The jar: 56 libraries, 9 web classes, the same names.

`.r-change.out` · md5 `73f2b4cbc9034ae442af03dd6231c9d7` · 3 of 3

```
the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):
$ cd .harness/before && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
both jars extracted (the README's line) - the class path the harness runs on:
$ cd .harness/before && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
$ cd .harness/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against after/'s own jar - with -parameters:
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" harness/probe/web/Boom.java harness/probe/web/ValidIn.java harness/probe/web/Who.java
  exit 0 · its classes: probe/web/Boom.class probe/web/ValidIn.class probe/web/Who.class
the files that differ, and the files only one tree has:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
  Files .harness/before/tiffinbox-web/src/main/resources/application.yaml and .harness/after/tiffinbox-web/src/main/resources/application.yaml differ
  after/'s files: 27 · byte for byte the previous tree's: 23 · new: 0 · those that differ: 4
  application.yaml: 98 lines -> 106 · the diff (diff -U0, its file names cut) - whole:
    @@ -56,0 +57,8 @@
    +  # Course 6: Spring MVC's own errors - no route (404), a verb no route takes (405), a request it cannot read or convert (400),
    +  # a type the client does not accept (406), a body type it cannot read (415) - answered as problem details: RFC 9457's shape,
    +  # application/problem+json, by Boot's ProblemDetailsExceptionHandler, an advice Boot asks before TiffinBox's own, where Boot's
    +  # error controller wrote its four keys. A route's unexpected exception is still Boot's /error body. Above the "---": below
    +  # it, only the rush profile would answer this way.
    +  mvc:
    +    problemdetails:
    +      enabled: true
  the key spring.mvc.problemdetails.enabled: true - its line: 64 · the first document ends at line 99 (---) · in the first document: yes
  Boot's own metadata for it, and for the key that logs what a resolver resolved (spring-boot-webmvc-4.1.1.jar, META-INF/spring-configuration-metadata.json):
  spring.mvc.problemdetails.enabled - type Boolean · default false · Whether RFC 9457 Problem Details support should be enabled.
  spring.mvc.log-resolved-exception - type Boolean · default false · Whether to enable warn logging of exceptions resolved by a "HandlerExceptionResolver", except for "DefaultHandlerExceptionResolver".
  TiffinBoxErrors.java: 28 lines -> 30 · its lines that are neither comment nor blank: 14 -> 15 · naming ProblemDetail: 0 -> 3 · @ResponseStatus: 1 -> 0
  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: 4 · lines out: 5 · in: 6 - whole:
    @@ -2,0 +3 @@
    +import org.springframework.http.ProblemDetail;
    @@ -4 +4,0 @@
    -import org.springframework.web.bind.annotation.ResponseStatus;
    @@ -6 +5,0 @@
    -import java.util.Map;
    @@ -10,3 +9,5 @@
    -    @ResponseStatus(HttpStatus.NOT_FOUND)
    -    Map<String, String> notFound(CustomerNotFound e) {
    -        return Map.of("error", e.getMessage());
    +    ProblemDetail notFound(CustomerNotFound e) {
    +        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
    +        problem.setTitle("Customer not found");
    +        problem.setProperty("name", e.name());
    +        return problem;
  TiffinBoxServer.java: 274 lines -> 296 · its lines that are neither comment nor blank: 140 -> 155 · naming ProblemDetail: 0 -> 6 · naming "forbidden": 1 -> 0
  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: 6 · lines out: 4 · in: 19 - whole:
    @@ -6,0 +7 @@
    +import org.springframework.http.ProblemDetail;
    @@ -67 +68 @@
    -            return ResponseEntity.badRequest().body(fieldMessages(errors));
    +            return problem(HttpStatus.BAD_REQUEST, invalid(errors));
    @@ -73 +74 @@
    -                return ResponseEntity.status(HttpStatus.CONFLICT).build();
    +                return problem(HttpStatus.CONFLICT, "a customer named " + customer.name() + " already exists");
    @@ -103 +104 @@
    -    ResponseEntity<Map<String, Object>> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token) {
    +    ResponseEntity<?> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token) {
    @@ -105 +106 @@
    -            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ordered("error", "forbidden"));
    +            return problem(HttpStatus.FORBIDDEN, "the shutdown token is missing or wrong");
    @@ -109,0 +111,14 @@
    +    private static ResponseEntity<ProblemDetail> problem(HttpStatus status, String detail) {
    +        return problem(status, ProblemDetail.forStatusAndDetail(status, detail));
    +    }
    +    private static ResponseEntity<ProblemDetail> problem(HttpStatus status, ProblemDetail problem) {
    +        return ResponseEntity.status(status).body(problem);
    +    }
    +    private static ProblemDetail invalid(BindingResult errors) {
    +        Map<String, String> fields = fieldMessages(errors);
    +        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST,
    +                "the customer breaks " + fields.size() + (fields.size() == 1 ? " rule" : " rules"));
    +        problem.setTitle("Invalid customer");
    +        problem.setProperty("errors", fields);
    +        return problem;
    +    }
  README.md - the anchor's README: lines added 89, removed 21 - its new section and the history notes the change made false (not shown)
the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes
the classes in the jar's com/tiffinbox/web: 9 -> 9 · the same names: yes
```

## 2 · seven — the comparison set on both trees, and who answers

**The seven**, each tree on a fresh JVM: the previous tree `87ca7efc…` (the mask changed 2 lines), one WARN — Spring MVC's
`DefaultHandlerExceptionResolver`, the 405; after/ **`466c20ed7e0d5439cb052f32ce09de1b`**, the mask changed **0** lines (`its form:
none` — a problem detail carries no timestamp), one WARN — Spring MVC's **`PageNotFound`**, the same 405. **The lines that moved**,
compared in the capture: **2 (5 and 6)**, both shown before and after; 5 byte for byte (1-4, 7). **Who answers** (`Who` joined): 1
`ResponseEntityExceptionHandler` bean, Boot's `problemDetailsExceptionHandler`; the advice cache 2 — `ProblemDetailsExceptionHandler`
at order **0**, its one `handleException` inherited from `ResponseEntityExceptionHandler`, taking **20** exception types, then
`TiffinBoxErrors` at 2147483647; for seven exception types, which advice's method takes each (Spring MVC's five → Boot's
`handleException`; `CustomerNotFound` → ours; `IllegalStateException` → none). **Spring's `ProblemDetail` class**: 6 instance fields —
`type`, `title`, `status`, `detail`, `instance`, `properties` — and a fresh one for a 404 holds `type: null`, `title: Not Found`. The
previous tree with `Who`: 0 such beans, one advice.

`.r-seven.out` · md5 `866b3671d38c87261d02e74e4056d396` · 3 of 3

```
the seven - the previous tree, the README's run line, port 19451, a fresh JVM:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19451
  listens on: 127.0.0.1:19451 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19451/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19451 .harness/before/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
the seven - after/, the README's run line, port 19450, a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450
  listens on: 127.0.0.1:19450 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19450/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19450 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  the timestamps the mask hid, their form: none
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the lines that moved - the previous tree's seven against after/'s, masked, line for line:
  lines that differ: 2 (5 6) · the same, byte for byte: 5 (1 2 3 4 7)
    line 5, the previous tree: GET   /nowhere    -> 404 application/json  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"}
    line 5, after/:            GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
    line 6, the previous tree: GET   /shutdown   -> 405 application/json  {"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"}
    line 6, after/:            GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
who answers - after/ with the harness's Who joined, port 19452 - read off the running application:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19452 --spring.main.sources=probe.web.Who
  listens on: 127.0.0.1:19452 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19452/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19452/probe/who/advice
  the ResponseEntityExceptionHandler beans: 1
    problemDetailsExceptionHandler - org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 2
    1 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0
        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types
    2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpMessageNotReadableException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentNotValidException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: none
  the JVM's locale: en_US
   200 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19452/probe/who/problem
  ProblemDetail's instance fields, in the order the class declares them: 6 - type (URI), title (String), status (int), detail (String), instance (URI), properties (Map)
  ProblemDetail.forStatus(HttpStatus.NOT_FOUND), nothing else set - type: null · title: Not Found · status: 404 · detail: null · instance: null · properties: null
   200 · WARN lines it added: 0 · ERROR lines: 0
$ harness/shutdown.sh 19452 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19452 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the previous tree with Who joined, port 19453:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19453 --spring.main.sources=probe.web.Who
  listens on: 127.0.0.1:19453 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19453/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19453/probe/who/advice
  the ResponseEntityExceptionHandler beans: 0
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 1
    1 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: TiffinBoxErrors: none
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: TiffinBoxErrors: none
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: TiffinBoxErrors: none
  a HttpMessageNotReadableException, each advice's method for it, in that order: TiffinBoxErrors: none
  a MethodArgumentNotValidException, each advice's method for it, in that order: TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: TiffinBoxErrors: none
  the JVM's locale: en_US
   200 · WARN lines it added: 0 · ERROR lines: 0
$ harness/shutdown.sh 19453 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19453 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · own — TiffinBox's own refusals, then and now

The same seven requests on each tree — a path nobody maps, a name nobody has, the validation lesson's body that breaks four rules, Asha's body
with its meal type's key misspelt, POST /shutdown without the token, Asha twice. **The previous tree: four shapes** — Boot's four keys
(`/nowhere`), `{"error":…}` (the 404 and the 403), the field map (both 400s), and a 409 with no body and no Content-Type. **after/: every
refusal a problem detail**, `application/problem+json` — `/nowhere`'s from Boot's handler, Nobody's with `"name":"Nobody"`, `the customer
breaks 4 rules` with its `errors`, the typo's `1 rule` (`{"mealType":"must not be null"}`: unknown properties are still ignored), the 403's
`the shutdown token is missing or wrong`, the 409's `a customer named Asha already exists`; 201 for the first Asha. 0 WARN, 0 ERROR on
both trees.

`.r-own.out` · md5 `3cf9bfad986dbd50dc4c6165ea626b20` · 3 of 3

```
the previous tree - a path nobody maps, a name nobody has, a body that breaks four rules, a misspelt key, POST /shutdown without the token, a new customer twice - port 19451:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19451
  listens on: 127.0.0.1:19451 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19451/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19451/nowhere
  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19451/customers/Nobody
  {"error":"no customer named Nobody"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19451/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19451/customers
  {"mealType":"must not be null"} 400 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X POST http://127.0.0.1:19451/shutdown
  {"error":"forbidden"} 403 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19451/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19451/customers
   409 · Content-Type: [] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19451 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19451 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after/ - the same seven requests, port 19450:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450
  listens on: 127.0.0.1:19450 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19450/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19450/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19450/customers
  {"detail":"the customer breaks 1 rule","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must not be null"}} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X POST http://127.0.0.1:19450/shutdown
  {"detail":"the shutdown token is missing or wrong","instance":"/shutdown","status":403,"title":"Forbidden"} 403 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"detail":"a customer named Asha already exists","instance":"/customers","status":409,"title":"Conflict"} 409 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19450 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19450 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · accept — what a client that accepts something else gets

`/customers/Nobody` for three clients, each sent by curl (no browser ran; S3.12): `Accept: text/html`, `Accept: application/xml`, and
Chrome's whole header; then `/nowhere` for `text/html`. **after/: all four problem details, `application/problem+json`, 0 WARN 0 ERROR** —
the 404 for every client. **The previous tree** (the exception-handler lesson's C, re-measured): only HTML → Boot's Whitelabel 500, only XML
→ an empty 500, each 1 WARN (`Failure in @ExceptionHandler …#notFound`, `No acceptable representation`) and 1 ERROR (Tomcat's); Chrome's →
`{"error":…}` JSON 404; `/nowhere` for HTML → the Whitelabel 404.

`.r-accept.out` · md5 `e004c39074b159966cbe1e0cdfc2af38` · 3 of 3

```
after/ - a name nobody has, asked by three clients, each sent by curl: one that accepts only HTML (a browser's type), one that accepts only XML, and a browser's whole Accept header (Chrome's); then a path nobody maps, for HTML - port 19450:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450
  listens on: 127.0.0.1:19450 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19450/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19450/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19450 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19450 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the previous tree - the same four, port 19451:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19451
  listens on: 127.0.0.1:19451 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19451/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19451/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 1
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)
      org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation
      its stack frames: over 40, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: com.tiffinbox.web.CustomerNotFound: no customer named Nobody] with root cause
      com.tiffinbox.web.CustomerNotFound: no customer named Nobody
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19451/customers/Nobody
   500 · Content-Type: [] · WARN lines it added: 1 · ERROR lines: 1
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)
      org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation
      its stack frames: over 40, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: com.tiffinbox.web.CustomerNotFound: no customer named Nobody] with root cause
      com.tiffinbox.web.CustomerNotFound: no customer named Nobody
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19451/customers/Nobody
  {"error":"no customer named Nobody"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19451/nowhere
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Found, status=404). · its created date: masked · its paragraphs: 1, not shown · then curl's: 404 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 2
$ harness/shutdown.sh 19451 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19451 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · flag — the key on, off, on (A/B/A′); C, labelled — log-resolved-exception

Nine requests per run, each with the WARN and ERROR lines it added: `/nowhere`, GET /shutdown, `?mealType=veg`, the body cut after its first key
(`{"name":`), two point seven meals, a form's Content-Type (415), `Accept: application/xml` on `/customers` (406), Nobody, the four-rule body.
**A** (after/): all problem details; **1 WARN in nine**, GET /shutdown's — `PageNotFound`; the unreadable body and 2.7 → `"detail":"Failed to
read request"`, 0 WARN: Jackson's reason in neither the answer nor the log; the 406 now has a body. **B** (`--spring.mvc.problemdetails.enabled=false`,
this unit's line): Spring MVC's seven → Boot's four keys (the 406 empty, no Content-Type), **6 WARN**, each `DefaultHandlerExceptionResolver`'s
with the reason inside (`JSON parse error: Unexpected end-of-input …`, `Cannot coerce Floating-point value (2.7) …`); Nobody and the
four-rule 400 still problem details — TiffinBox's own. **A′** = A, line for line (checked in the capture). **C (labelled)**
(`--spring.mvc.log-resolved-exception=true`): the same answers, **9 WARN** — one `ExceptionHandlerExceptionResolver` `Resolved […]` per
resolved exception, the reason inside: `/nowhere` 1, GET /shutdown **2** (`PageNotFound` and the resolver), Nobody 1 (`CustomerNotFound`), the
method's own 400 0 (a return value, no exception).

`.r-flag.out` · md5 `3eb13a29caed61a55dc0f3396fd250b3` · 3 of 3

```
A - after/, the README's run line, port 19450 - nine requests: Spring MVC's own errors, then TiffinBox's own two:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450
  listens on: 127.0.0.1:19450 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19450/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/shutdown
  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"} 405 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19450/customers?mealType=veg'
  {"detail":"Failed to convert 'mealType' with value: 'veg'","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19450/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"detail":"Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported.","instance":"/customers","status":415,"title":"Unsupported Media Type"} 415 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19450/customers
  {"detail":"Acceptable representations: [application/json, application/*+json].","instance":"/customers","status":406,"title":"Not Acceptable"} 406 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19450/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19450 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19450 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - after/ with the key off for this run (this unit's line), port 19450:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450 --spring.mvc.problemdetails.enabled=false
  listens on: 127.0.0.1:19450 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19450/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/nowhere
  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/shutdown
  {"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"} 405 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19450/customers?mealType=veg'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19450/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected end-of-input within/between Object entries]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.7) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"timestamp":"…","status":415,"error":"Unsupported Media Type","path":"/customers"} 415 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotSupportedException: Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19450/customers
   406 · Content-Type: [] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19450/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 6 · ERROR lines: 0
$ harness/shutdown.sh 19450 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19450 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450
  listens on: 127.0.0.1:19450 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19450/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/shutdown
  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"} 405 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19450/customers?mealType=veg'
  {"detail":"Failed to convert 'mealType' with value: 'veg'","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19450/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"detail":"Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported.","instance":"/customers","status":415,"title":"Unsupported Media Type"} 415 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19450/customers
  {"detail":"Acceptable representations: [application/json, application/*+json].","instance":"/customers","status":406,"title":"Not Acceptable"} 406 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19450/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19450 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19450 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - A with Spring MVC's log-resolved-exception on for this run (this unit's line), port 19450:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450 --spring.mvc.log-resolved-exception=true
  listens on: 127.0.0.1:19450 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19450/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Resolved [org.springframework.web.servlet.resource.NoResourceFoundException: No static resource nowhere for request '/nowhere'.]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/shutdown
  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"} 405 · Content-Type: [application/problem+json] · WARN lines it added: 2 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
      its stack frames: 0, its other lines: 0 - none shown
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19450/customers?mealType=veg'
  {"detail":"Failed to convert 'mealType' with value: 'veg'","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19450/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected end-of-input within/between Object entries]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.7) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"detail":"Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported.","instance":"/customers","status":415,"title":"Unsupported Media Type"} 415 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotSupportedException: Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19450/customers
  {"detail":"Acceptable representations: [application/json, application/*+json].","instance":"/customers","status":406,"title":"Not Acceptable"} 406 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Resolved [com.tiffinbox.web.CustomerNotFound: no customer named Nobody]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19450/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 9 · ERROR lines: 0
$ harness/shutdown.sh 19450 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19450 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · edges — what the key does not reach

after/ with the harness's `Boom` joined: `/probe/boom` → **Boot's `/error` body**, `{"timestamp":"…","status":500,…}` (masked), and 1 ERROR —
Tomcat's, `IllegalStateException: the kitchen is on fire`; for `text/html`, Boot's Whitelabel 500; `/customers/a%2Fb` → **Tomcat's own HTML
400** (its `<h1>`: `HTTP Status 400 – Bad Request`), 0 log lines; `/nowhere` → the problem detail. Then with Boot's
`spring.web.error.include-message=always` (this unit's line's option): the 500 gains `"message":"the kitchen is on fire"`, and `/nowhere`'s
problem detail is **the same bytes** (compared in the capture): the `spring.web.error.*` keys change Boot's body, never a problem detail.

`.r-edges.out` · md5 `f9155b1023741b0c9fb345c1213ba90d` · 3 of 3

```
after/ with the harness's Boom joined - a route that throws what nobody handles - port 19452:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19452 --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19452 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19452/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19452/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19452/probe/boom
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19452/customers/a%2Fb
  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 400 – Bad Request · 431 characters, not shown · then curl's: 400 · Content-Type: [text/html;charset=utf-8] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19452/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19452 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19452 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the same, with Boot's include-message key on for this run (this unit's line's option), port 19452:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19452 --spring.main.sources=probe.web.Boom --spring.web.error.include-message=always
  listens on: 127.0.0.1:19452 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19452/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19452/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","message":"the kitchen is on fire","path":"/probe/boom"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19452/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19452 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19452 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
a path nobody maps, without the key and with it, the same bytes: yes
```

## 7 · losers — the ways not taken

**No `BindingResult`** (the harness's `ValidIn`, a `@Valid @RequestBody Customer` alone, joined to after/): the four-rule body →
`{"detail":"Invalid request content.",…,"title":"Bad Request"}` — Boot's handler, no field named; TiffinBox's own route → the same body's
`errors`. **The Framework's way** — a copy whose advice is `harness/subclass/TiffinBoxErrors.java`, `final class TiffinBoxErrors extends
ResponseEntityExceptionHandler`, with the key's block deleted (both diffs whole): 1 `ResponseEntityExceptionHandler` bean, `tiffinBoxErrors`
— Boot's backs off — and 1 advice holding both handlers; **six answers, line for line the same as after/'s** (compared in the capture).
**No key** — a copy with the block deleted (its `application.yaml` the previous tree's, byte for byte): `/nowhere` and the type mismatch
Boot's four keys (the latter with its WARN), Nobody still a problem detail — two shapes for 4xx. **The key misspelt, singular**
(`--spring.mvc.problemdetail.enabled=true`): Boot's four keys, 0 WARN, **0 log lines naming it**. **With a dash**
(`--spring.mvc.problem-details.enabled=true`): a problem detail — Boot's relaxed binding drops the dash.

`.r-losers.out` · md5 `6d7a8e5c44abb4dc34adf390195d2c30` · 3 of 3

```
after/ with the harness's Who and ValidIn joined, port 19452 - the advice cache, six answers, then a body checked with no BindingResult beside it:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19452 --spring.main.sources=probe.web.Who,probe.web.ValidIn
  listens on: 127.0.0.1:19452 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19452/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19452/probe/who/advice
  the ResponseEntityExceptionHandler beans: 1
    problemDetailsExceptionHandler - org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 2
    1 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0
        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types
    2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpMessageNotReadableException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentNotValidException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: none
  the JVM's locale: en_US
   200 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19452/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19452/shutdown
  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"} 405 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19452/customers?mealType=veg'
  {"detail":"Failed to convert 'mealType' with value: 'veg'","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19452/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19452/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19452/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19452/probe/valid
  {"detail":"Invalid request content.","instance":"/probe/valid","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19452 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19452 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the copy whose advice extends ResponseEntityExceptionHandler, with no key - its two changed files - built the same way, port 19454:
$ diff -U0 after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java .harness/sub/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java
  @@ -6,0 +7 @@
  +import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;
  @@ -9,9 +10,4 @@
  - * Course 6: TiffinBox's answers to its own exceptions, written once. {@code @RestControllerAdvice} is Spring MVC's
  - * {@code @ControllerAdvice} - a component whose exception handlers serve every controller - plus {@code @ResponseBody}: a
  - * handler's return value is the answer's body, written by the same message converters as a route's. Spring MVC's
  - * ExceptionHandlerExceptionResolver, the first of the three resolvers in its composite, finds the handler by the exception's type.
  - * Since Course 6's ProblemDetail lesson a handler answers with a ProblemDetail - RFC 9457's shape, the internet standard for an
  - * error: a title, the status, a detail, the instance (the request's path, which Spring MVC fills in) and members of TiffinBox's
  - * own - which Spring MVC writes as application/problem+json whatever the client accepts, so a client that accepts only HTML or XML
  - * gets it too. The status is the problem detail's own. Boot's ProblemDetailsExceptionHandler (spring.mvc.problemdetails.enabled,
  - * application.yaml) answers Spring MVC's own exceptions the same way; it is asked first.
  + * The course's harness: the way not taken. TiffinBox's advice as Spring MVC's own ResponseEntityExceptionHandler - the class
  + * whose one exception handler answers Spring MVC's own exceptions as problem details - extended, with no key in application.yaml.
  + * Boot's ProblemDetailsExceptionHandler, which is that class too, then backs off: there is one ResponseEntityExceptionHandler, and
  + * one advice. The handler for CustomerNotFound is TiffinBox's, as in after/.
  @@ -20 +16 @@
  -final class TiffinBoxErrors {
  +final class TiffinBoxErrors extends ResponseEntityExceptionHandler {
$ diff -U0 after/tiffinbox-web/src/main/resources/application.yaml .harness/sub/tiffinbox-web/src/main/resources/application.yaml
  @@ -57,8 +56,0 @@
  -  # Course 6: Spring MVC's own errors - no route (404), a verb no route takes (405), a request it cannot read or convert (400),
  -  # a type the client does not accept (406), a body type it cannot read (415) - answered as problem details: RFC 9457's shape,
  -  # application/problem+json, by Boot's ProblemDetailsExceptionHandler, an advice Boot asks before TiffinBox's own, where Boot's
  -  # error controller wrote its four keys. A route's unexpected exception is still Boot's /error body. Above the "---": below
  -  # it, only the rush profile would answer this way.
  -  mvc:
  -    problemdetails:
  -      enabled: true
$ cd .harness/sub && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy · offline: yes · exit 0
$ cd .harness/sub && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
$ cd .harness/sub && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19454 --spring.main.sources=probe.web.Who
  listens on: 127.0.0.1:19454 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19454/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19454/probe/who/advice
  the ResponseEntityExceptionHandler beans: 1
    tiffinBoxErrors - com.tiffinbox.web.TiffinBoxErrors
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 1
    1 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: TiffinBoxErrors: handleException
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: TiffinBoxErrors: handleException
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: TiffinBoxErrors: handleException
  a HttpMessageNotReadableException, each advice's method for it, in that order: TiffinBoxErrors: handleException
  a MethodArgumentNotValidException, each advice's method for it, in that order: TiffinBoxErrors: handleException
  an IllegalStateException, each advice's method for it, in that order: TiffinBoxErrors: none
  the JVM's locale: en_US
   200 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19454/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19454/shutdown
  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"} 405 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19454/customers?mealType=veg'
  {"detail":"Failed to convert 'mealType' with value: 'veg'","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19454/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19454/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19454/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19454 .harness/sub/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19454 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the six answers, the copy's against after/'s, line for line: the same
the copy with no key - after/'s application.yaml without the key's block, the previous lesson's file byte for byte - built the same way, port 19455:
  the copy's application.yaml against the previous tree's: the same, byte for byte
$ cd .harness/nokey && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy · offline: yes · exit 0
$ cd .harness/nokey && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19455
  listens on: 127.0.0.1:19455 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19455/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19455/nowhere
  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19455/customers?mealType=veg'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19455/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19455 .harness/nokey/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19455 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the copy with no key, the key misspelt on the run line - singular, as the class is named (this unit's line), port 19455:
$ cd .harness/nokey && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19455 --spring.mvc.problemdetail.enabled=true
  listens on: 127.0.0.1:19455 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19455/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19455/nowhere
  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
  its log's lines that name problemdetail: 0
$ harness/shutdown.sh 19455 .harness/nokey/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19455 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the copy with no key, the key written with a dash (this unit's line), port 19455:
$ cd .harness/nokey && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19455 --spring.mvc.problem-details.enabled=true
  listens on: 127.0.0.1:19455 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19455/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19455/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19455 .harness/nokey/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19455 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 8 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s 7 lines and then `exercise/solution/SOLUTION.md`'s 4, read from the files and run in **one** shell a viewer could
have: `env -i` (HOME and the PATH the script was started with), `/bin/bash --noprofile --norc`, started in this folder. The README's last
line builds the copy (no key in its `application.yaml`, the key misspelt in its `tiffinbox-local.yaml`), starts it on 19459, asks for
`/nowhere`, stops it, waits for its JVM (`wait "$p"`) and prints **`nowhere: 404 · Content-Type: application/json`** — 0 WARN, 0 ERROR, 0
lines naming the key; the solution's — its two exports, the `sed` that makes `problemdetail:` `problemdetails:`, the README's last line again —
**`nowhere: 404 · Content-Type: application/problem+json`**. Each block exits 0 and leaves the shell in this unit's folder; the copy's own
token 0 times in its log; 19459 free after; the fixed file printed whole.

`.r-exercise.out` · md5 `f31329abbd2b7fe21030f45314b8b11d` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ cp harness/exercise/application.yaml .harness/mine/after/tiffinbox-web/src/main/resources/application.yaml && cp harness/exercise/tiffinbox-local.yaml .harness/mine/after/tiffinbox-local.yaml
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19459 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19459/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o /dev/null -w '%{http_code} · Content-Type: %{content_type}' http://127.0.0.1:19459/nowhere); ../../../harness/shutdown.sh 19459 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "nowhere: $s")
  exit 0 · what they printed:
    nowhere: 404 · Content-Type: application/json
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · lines that name problemdetail: 0 · listening on 19459 now: 0
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ f=.harness/mine/after/tiffinbox-local.yaml && sed 's/^    problemdetail:$/    problemdetails:/' "$f" > "$f.new" && mv "$f.new" "$f"
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19459 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19459/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o /dev/null -w '%{http_code} · Content-Type: %{content_type}' http://127.0.0.1:19459/nowhere); ../../../harness/shutdown.sh 19459 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "nowhere: $s")
  exit 0 · what they printed:
    nowhere: 404 · Content-Type: application/problem+json
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19459 now: 0
  the copy's tiffinbox-local.yaml now, whole:
    # A developer's own settings: TiffinBox's application.yaml imports this file (optional:file:./tiffinbox-local.yaml) from the folder
    # TiffinBox starts in. This one asks Boot to answer Spring MVC's own errors as problem details.
    spring:
      mvc:
        problemdetails:
          enabled: true
  the copy's application.yaml against after/'s: without the key
```

## 9 · forms — every form serves it (⚑7, R.103)

**The native build** of after/ (`.harness/nat`, the README's two Maven lines, offline): exit 0, `BUILD SUCCESS`, 8 of 8 stages, 0 lines of the
plugin's own download; Mach-O on this Mac, 0 bytes of the token. **Spring's AOT step, on both trees**: **666 reflection entries → 670** — the
four new ones Boot's `ProblemDetailsExceptionHandler`, `WebMvcAutoConfiguration$ProblemDetailsErrorHandlingConfiguration`,
`MessageSourceAware` and `ResponseEntityExceptionHandler` (its `handleException`); no entry differs; 26 resource entries, the same. No hint was
added. **Four forms** — the jar (19450), the AOT jar (19456), the binary (19458), the image (published on 127.0.0.1:19457, 18425 inside):
each on loopback only, the seven `466c20ed…` with the mask changing 0 lines, exit 0; then, on a second start of each, Nobody's problem
detail for curl's own Accept and for only HTML, the four-rule 400 with its `errors`, the 403 and — after a 201 for Asha — the 409 problem
details: 4 of 4 each. The image: built from after/'s Dockerfile, 0 lines that say pull, its layers 0 bytes of the token; `docker port`
`18425/tcp -> 127.0.0.1:19457` alone.

`.r-forms.out` · md5 `792c63543cd8f3bd6c69519ae39c9b20` · 3 of 3

```
the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 199 lines - not shown):
    --- native:1.1.8:compile-no-fork (default-cli) @ tiffinbox-web ---
    Found GraalVM installation from GRAALVM_HOME variable.
    Java version: 25.0.4.1+1, vendor version: GraalVM CE 25.3.4.1+1.1
    Warning: Using a deprecated option --no-fallback from 'META-INF/native-image/com.tiffinbox/tiffinbox-web/native-image.properties' in '…'. No effect, no replacement available
    Warning: Using a deprecated option --enable-http from 'META-INF/native-image/org.springframework/spring-web/native-image.properties' in '…'. Use reachability metadata instead. Add this entry to META-INF/native-image/reachability-metadata.json:
    Warning: Using a deprecated option --enable-https from 'META-INF/native-image/org.springframework/spring-web/native-image.properties' in '…'. Use reachability metadata instead. Add this entry to META-INF/native-image/reachability-metadata.json:
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
    The build process encountered 5 warnings.
    BUILD SUCCESS
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
what Spring's AOT step registered - the previous tree built with the README's native-profile line too (.harness/natb), then its metadata against after/'s:
$ cd .harness/natb && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built the previous tree, the profile native · offline: yes · exit 0
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json) - the previous tree's against after/'s: reflection entries 666 -> 670 · types only the previous tree registers: none · only after/: org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler, org.springframework.boot.webmvc.autoconfigure.WebMvcAutoConfiguration$ProblemDetailsErrorHandlingConfiguration, org.springframework.context.MessageSourceAware, org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler · entries that differ: 0
    org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler - 0 methods ()
    org.springframework.boot.webmvc.autoconfigure.WebMvcAutoConfiguration$ProblemDetailsErrorHandlingConfiguration - 0 methods ()
    org.springframework.context.MessageSourceAware - 0 methods ()
    org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler - 1 method (handleException(Exception, WebRequest))
  resource entries: 26 -> 26 · the same: yes
1 the jar - .harness/after, the README's run line, port 19450:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450
  listens on: 127.0.0.1:19450 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19450/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19450 (http) with context path '/'
$ $CURLSET 19450 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  the timestamps the mask hid, their form: none
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then a name nobody has (curl's own Accept, and only HTML), a body that breaks four rules, POST /shutdown without the token and a new customer twice, on a second start of the jar:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19450
  listens on: 127.0.0.1:19450 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19450/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19450/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19450/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X POST http://127.0.0.1:19450/shutdown
  {"detail":"the shutdown token is missing or wrong","instance":"/shutdown","status":403,"title":"Forbidden"} 403 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19450/customers
  {"detail":"a customer named Asha already exists","instance":"/customers","status":409,"title":"Conflict"} 409 · Content-Type: [application/problem+json]
$ harness/shutdown.sh 19450 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19450 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19456:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19456
  listens on: 127.0.0.1:19456 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19456/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19456 (http) with context path '/'
$ $CURLSET 19456 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  the timestamps the mask hid, their form: none
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the same six, on a second start of the AOT jar:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19456
  listens on: 127.0.0.1:19456 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19456/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19456/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19456/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19456/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X POST http://127.0.0.1:19456/shutdown
  {"detail":"the shutdown token is missing or wrong","instance":"/shutdown","status":403,"title":"Forbidden"} 403 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19456/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19456/customers
  {"detail":"a customer named Asha already exists","instance":"/customers","status":409,"title":"Conflict"} 409 · Content-Type: [application/problem+json]
$ harness/shutdown.sh 19456 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19456 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19458:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19458
  listens on: 127.0.0.1:19458 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19458/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19458 (http) with context path '/'
$ $CURLSET 19458 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  the timestamps the mask hid, their form: none
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the same six, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19458
  listens on: 127.0.0.1:19458 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19458/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19458/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19458/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19458/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X POST http://127.0.0.1:19458/shutdown
  {"detail":"the shutdown token is missing or wrong","instance":"/shutdown","status":403,"title":"Forbidden"} 403 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19458/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19458/customers
  {"detail":"a customer named Asha already exists","instance":"/customers","status":409,"title":"Conflict"} 409 · Content-Type: [application/problem+json]
$ harness/shutdown.sh 19458 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19458 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19457:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-problem:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-problem:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-problem --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19457:18425 tiffinbox-problem:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19457/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19457
  on this Mac, listening on port 19457: 127.0.0.1:19457
$ $CURLSET 19457 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-problem
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then the same six, on a second container of the image - TiffinBox listens on 18425 inside it:
$ cd .harness/after && docker run -d --name tiffinbox-problem --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19457:18425 tiffinbox-problem:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19457/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19457
  on this Mac, listening on port 19457: 127.0.0.1:19457
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19457/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19457/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19457/customers
  {"detail":"the customer breaks 4 rules","instance":"/customers","status":400,"title":"Invalid customer","errors":{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"}} 400 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X POST http://127.0.0.1:19457/shutdown
  {"detail":"the shutdown token is missing or wrong","instance":"/shutdown","status":403,"title":"Forbidden"} 403 · Content-Type: [application/problem+json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19457/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19457/customers
  {"detail":"a customer named Asha already exists","instance":"/customers","status":409,"title":"Conflict"} 409 · Content-Type: [application/problem+json]
$ harness/shutdown.sh 19457 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-problem
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times
four forms, one tree: the seven (masked) 4 of 4 times 466c20ed7e0d5439cb052f32ce09de1b, the timestamp mask changing 0 lines · a name nobody has - curl's own Accept, and only HTML - 404 and the name, a problem detail: 8 of 8 · four rules broken, a problem detail with its errors: 4 of 4 · POST /shutdown without the token, a 403 problem detail: 4 of 4 · a new customer, 201: 4 of 4 · the same again, a 409 problem detail: 4 of 4
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
```


## Exercise

**Your turn:** the README's copy still answers a missing path with Boot's four keys. Find the misspelt key, fix it, and read the content
type. `exercise/README.md` has the commands (copy `after/`, put the harness's `application.yaml` — no key — and `tiffinbox-local.yaml`
— the key misspelt — in place, give the copy a token of its own); its last line, in a subshell, builds the copy offline, starts it on
19459 from the copy's folder, asks for `/nowhere`, stops it, waits for its JVM and prints — as shipped — `nowhere: 404 · Content-Type:
application/json`. Done is `nowhere: 404 · Content-Type: application/problem+json`. Measured answer: `exercise/solution/SOLUTION.md` (the
README's two `export` lines, the line that makes `problemdetail:` `problemdetails:` — idempotent — and the README's last line again),
run in the same shell. Run `./receipts.sh` once first on a fresh clone.

## The anchor's README — what this unit changed in it

`../c6-tiffinbox/README.md` (= `after/README.md`) gains its `## Course 6 · unit 16` section (after unit 15's, before Course 5's README
begins) with the anchor's new line, `curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/customers/Nobody`,
and **22 history notes amended in place**, each an *(Course 6, unit 16: …)* note — found by grepping the README for `no body`,
`forbidden`, `WARN`, `include-`, `Whitelabel`, `four keys`, `Boot's body`, `"timestamp"`, `field map`, `each field`, `409`, `406`, `415`,
`405` (S2.22), each hit read:
- the embedded-Tomcat section's seven (`/nowhere`'s Boot JSON 404) and its unit 06 note (GET /shutdown's Boot 405, `87ca7efc…`) → both problem details, `466c20ed…`, the mask 0;
- the request-mapping section's verbs (the 406 empty; one WARN per 405 and 406) → the 406 a problem detail with no WARN, GET /shutdown's 405 one WARN, `PageNotFound`;
- the request-mapping section's seven ("the seven log one WARN line, GET /shutdown's") → `466c20ed…`, that WARN `PageNotFound`'s;
- the path-variable section's `/customers/Nobody` (after unit 15's note) → the problem detail with `name`;
- the path-variable section's `?mealType=veg` (400, one DHER WARN) → a problem detail, no WARN;
- the request-body section's 415 (Boot's body, one WARN) → a problem detail, no WARN;
- the request-body section's "What doesn't fit" (after unit 09's note) → `Failed to read request`, no WARN, the reason in neither place;
- the Jackson section's "Refused, and logged once" → not logged since;
- the response section's 409 "no body, `ResponseEntity.status(HttpStatus.CONFLICT).build()`" → a problem detail;
- the response section's `shutdown()` signature → `ResponseEntity<?>`, the 403 a problem detail;
- the response section's "`201`, then `409`, no body" → the 409 a problem detail;
- the response section's "The 403's bytes are the same — `{"error":"forbidden"} 403`" → a problem detail;
- the response section's "the bodiless 409 says `Content-Length: 0`" → the 409 has a body;
- the validation section's "the 400's body is a map" → a `ProblemDetail`, the map its `errors`;
- the validation section's "A 400 that names each field" → the same four fields inside a problem detail;
- the validation section's "Without the `BindingResult`" (Boot's body, one WARN) → Boot's handler's `Invalid request content.`, no WARN (`ValidIn`);
- the validation section's "Boot's error keys" (`include-binding-errors` on the copy) → that answer is Boot's problem detail; `include-message` changes the 500, never a problem detail;
- the exception-handler section's "What it costs, for now" (only-HTML/only-XML 500) → the 404 problem detail for all three headers;
- the exception-handler section's "Every form still serves" (Nobody for only HTML Boot's 500 page) → a 404 problem detail in every form;
- Course 5's secrets section's `403 {"error":"forbidden"}` → a 403 problem detail;
- Course 5's secrets section's "without the header, `{"error":"forbidden"} 403`" → the problem detail, whole;
- the capstone's run section's GET /shutdown 405 (after unit 06's note) → a problem detail.
Left as they were, and still true (each read): the embedded-Tomcat section's server lines; the request-mapping section's 9 mappings; every
`Whitelabel` line about a tree before this one (history: Boot's page still answers a 500 for HTML, `edges`); the path-variable section's
`%2F` (Tomcat's page, unchanged, `edges`) and its missing-header 400 (`MissingRequestHeaderException`, not measured here); the validation
section's method-validation lines (`HandlerMethodValidationException`, not measured here); every form's statuses (each still holds; the
bodies are new, and the new section says so); Course 5's sections other than the two `forbidden` lines. `c6-tiffinbox/README.md`: 89 lines added, 21 removed (`change`).

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-17) |
|---|---|---|---|
| 4 | 16's tree in all four forms, with the 403 and 409 bodies | s16n (no 403/409 change), no image | **all four: the seven `466c20ed…` (mask 0), Nobody's problem detail for curl's Accept and only HTML, the 400 with `errors`, 403, 201, 409 — 4 of 4; AOT 666 → 670; no hint; 0 tokens in the binary and the image** (`forms`) |
| 5 | the seven `466c20ed…` on 16/after; lines 5-6; the WARN logger | s16, s16r, s16b, s16n | **`466c20ed7e0d5439cb052f32ce09de1b`, lines 5 and 6 only, mask 2 → 0; WARN DHER → `PageNotFound`** (`seven`) |
| 6 | 16's break B (`--…enabled=false` on 16/after) | the flag flipped on, on 12/after | **Boot's four keys for Spring MVC's seven 4xx, 6 WARN (DHER, reasons inside), the 406 empty; Nobody and the 400 still problem details; A′ = A** (`flag`) |
| 7 | 16's exercise (a misspelt key: silent?) | not run | **a dash is not silent — Boot's relaxed binding reads `problem-details` (`losers`); the singular `problemdetail` is: Boot's four keys, 0 log lines; the exercise uses it** (`exercise`, `losers`) |
| 8 | the typo (`mealTyp`) still 12's 400, inside a problem detail | not run on s16 | **`the customer breaks 1 rule`, `{"mealType":"must not be null"}`** (`own`) |
| 13 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: `application/json`, then `application/problem+json`; SOLUTION twice: the same** (`exercise`, and below) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **The brief's exercise break does not break.** `spring.mvc.problem-details.enabled=true` (with a dash) on a key-less copy answers problem
  details: Boot's relaxed binding drops the dash (`losers`, measured also in a `tiffinbox-local.yaml` while designing the exercise). The
  silent misspelling is a missing letter — `problemdetail`, the class's name — : Boot's four keys, 0 WARN, 0 log lines naming it.
- **`type` is null, not `about:blank`** (brief ⚑4 loser D, READ FIRST 8: "unset is about:blank"): in Framework 7
  `ProblemDetail.forStatus(…)` leaves `type` null (`Who`), and Jackson writes no key; `about:blank` is RFC 9457's reading of a missing
  `type`. The voice says "the standard reads a missing type as about blank".
- **`log-resolved-exception` logs a 404 once, a 405 twice** (brief ⚑5: "logs every 404 and every 405 twice"): `/nowhere` 1, Nobody 1,
  GET /shutdown 2 (`PageNotFound` + the resolver); TiffinBox's own 400 — a return value, no exception — 0 (`flag` C).
- **The subclass stays `final`** (brief ⚑4 loser A: "the class can no longer be final"): `final class TiffinBoxErrors extends
  ResponseEntityExceptionHandler` builds, starts and answers the same bytes (`losers`).
- **The handler drops `@ResponseStatus`** (not in the brief): a `ProblemDetail` return value carries its status.
- **A browser's whole Accept header now gets a problem detail** (the previous tree: `{"error":…}` JSON; the tree before it, Boot's
  Whitelabel 404) — `accept`.
- **AOT: 666 → 670 reflection entries**, the four new ones Boot's handler, its configuration class, `MessageSourceAware` and
  `ResponseEntityExceptionHandler.handleException` — registered by Spring's AOT step itself; the binary serves every problem detail with
  no hint (RE-MEASURE 4).

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block runs alone (`cap()` a no-op, the build skipped) on copies of
  the published captures with one thing changed per plant (`plants.py`, this unit's scratch folder) — **40 plants, 40 stops under /bin/bash
  3.2 and 40 under bash 5.3**, each naming its own check; the unplanted copies pass. Twenty-eight change one line of a capture (the seven's
  mask count, its logger, the lines that moved, Boot's order, `type: null`; the 409, the typo's rule count, `forbidden`; the XML client's
  404; the previous tree's 500s; A's WARN count, B's total, A′, C's 405; the 500's message, the same-bytes line; the subclass's sameness, the
  singular key's silence, the dash, `ValidIn`'s detail; the exercise's two lines; forms' 4 of 4, the AOT count, the image's loopback, the
  binary's 409; the key's line, the metadata default, the file counts); three plant a hygiene fault in a capture (an absolute path, a whole
  Tomcat page, an unpinned java line); nine change a shipped file (a bare `wait` in the exercise; Boot 3's error key in this README; the key in
  the exercise's `application.yaml`; the plural in its `tiffinbox-local.yaml`; a second option on this README's B line; the anchor's new line
  in after/'s README; a raw token count; the spoken exercise line).
- **Three filters fail on planted inputs inside the script itself**, before any capture: the page filter (a planted Whitelabel page and a
  planted Tomcat page, `<!doctype html>` first — Tomcat's own 400 starts so, and the exception-handler lesson's filter would have printed
  it whole), the record filter, and docker build's.
- **The brief's exercise broke nothing.** The first design (`spring.mvc.problem-details.enabled` in a developer's `tiffinbox-local.yaml`, the
  copy's own key removed) answered problem details on its first run: Boot's relaxed binding drops the dash (and, measured while designing,
  reads `problemDetails` too). The exercise uses the singular `problemdetail` — the class's own name, the misspelling a reader of this
  lesson would make — which Boot ignores without a line. `losers` keeps both on screen.
- **The exercise as viewers run it**, beyond the capture: README then SOLUTION, then SOLUTION again, in one `env -i` `zsh -f` shell →
  `application/json`, `application/problem+json`, `application/problem+json`, each exit 0, the shell left in `c6-unit16/`, the key fixed once;
  the README's last line alone in an `env -i` `/bin/bash` shell without the exports — its `java` 23.0.1 — ends with `exit 1` and prints no
  line; 19459 free after each.
- **The probe's sketch and this tree agree** (brief READ FIRST 8-10; S3 notes Steps 3, 5, 7): the seven `466c20ed…`, lines 5 and 6, the mask
  0; Boot's handler at order 0; 0 WARN for each 400, the 406 and the 415, `PageNotFound` for the 405; `Failed to read request`; `Invalid
  request content.`; the subclass byte-identical; the 500 untouched; the binary with no hint — each now a line of this unit's own captures,
  with the 403 and 409 bodies the probe's binary never carried.

## For unit 17 — and RED

- **Read `../c6-unit16/after`** (= `../c6-tiffinbox` at Section 3's end, by copy or harness; never change it). `application.yaml`'s first
  document holds `spring.mvc.problemdetails.enabled: true` (line 64; the `---` at 99). `TiffinBoxErrors` — `@RestControllerAdvice`, final,
  package-private, one handler `ProblemDetail notFound(CustomerNotFound e)` (404, title `Customer not found`, member `name`), **no
  `@ResponseStatus`**. `TiffinBoxServer` (296 lines): the 400/403/409 are `ResponseEntity<ProblemDetail>` via `problem(…)`; `shutdown()`
  returns `ResponseEntity<?>`.
- **The seven** on this tree: `466c20ed7e0d5439cb052f32ce09de1b` (masked; the mask changes **0** lines — keep running it and printing the
  count, R.88), **1 WARN**, Spring MVC's **`o.s.web.servlet.PageNotFound`** (`Request method 'GET' is not supported`) — not DHER.
- **The advice cache** (copy this unit's `Who`: it walks inherited `@ExceptionHandler` methods and names the `ResponseEntityExceptionHandler`
  beans): 2 advices — **Boot's `ProblemDetailsExceptionHandler` at order 0** (`handleException`, 20 exception types), then `TiffinBoxErrors`
  at 2147483647. A catch-all at the default order sorts **after Boot's** for Spring MVC's own exceptions (they stay problem details) but
  can still take `CustomerNotFound` if it is found before `TiffinBoxErrors` (the probe: the joined source first) — measure it; ordered
  `HIGHEST_PRECEDENCE`, it beats Boot's too.
- **What logs at INFO on this tree:** each 400 Spring MVC decides, the 406 and the 415 — **0 WARN**; the 405 — 1 (`PageNotFound`); Nobody
  and `/nowhere` — 0; a route's unexpected exception (`Boom`) — 1 ERROR, Tomcat's (`o.a.c.c.C.[.[.[/].[dispatcherServlet]`), and Boot's
  `/error` body with a timestamp (mask it), the Whitelabel page for `text/html`. So a catch-all's "silence" must be counted against these
  numbers, not the previous tree's.
- **A filter's exception** never reaches either advice: expect Boot's `/error` 500 (timestamp) — the probe's `ResponseStatusException(403)`
  thrown in a filter was a 500; with a resolving filter handing it to `handlerExceptionResolver`, Boot's handler (an
  `ErrorResponseException` is one of its 20 types) should answer `403 application/problem+json` — measure on 16/after.
- **A committed answer:** the probe saw 1 WARN `ProblemDetailsExceptionHandler : Response already committed. Ignoring` with the key on — Boot's
  logger now, not DHER; measure it.
- **Lines and helpers to reuse:** `tq` (the anchor's new line with Content-Type printed, a path, an Accept), `pq`, `xq`; the three Accept
  lines; `pagef` (now handles `<!doctype html>`, Tomcat's own pages, by their `<h1>`); `recs`; `rq`; `nokey` (deletes the key's block —
  17 can build a key-less copy for a labelled C). Problem-detail lines are printed raw: never through `sortj`.
- **Not measured here, named only:** a `type` URI per problem (left unset; `type` null); a catch-all (17's subject); concurrent duplicate
  POSTs (the probe's 409s, cited).
- **Ports** 19450-19459 are this unit's; 17 has 19460-19469. The image `tiffinbox-problem:1.0.0` / container `tiffinbox-problem` are this
  unit's names. Native builds here took about 2.5 minutes each (terminal only).

# c6-unit15 — @ExceptionHandler and @RestControllerAdvice

Course 6 · Spring Web MVC · Section 3 (Errors Done Right), its second unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), **GraalVM CE 25.3.4.1** (native-image 25.0.4.1), **Docker on OrbStack**,
2026-10-17. Until this unit a name nobody has was Spring's `ResponseStatusException`: a 404 and Boot's error body —
`{"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"}` — which names no customer and gives no reason, with nothing
in the log. This unit throws an exception of TiffinBox's own, `CustomerNotFound`, and answers it once, in a class of TiffinBox's own: an
**exception handler** — a method Spring MVC calls with the exception a route threw, whose return value is the answer — in a **controller
advice**, `TiffinBoxErrors`, whose handlers serve every controller. It measures the answer (404 and `{"error":"no customer named Nobody"}`),
who gives it (Spring MVC's first exception resolver, and its advice cache, read off the running application), which handler wins when
several could (the course's harness), that the status is the handler's to name, what a client that accepts something else gets — and that
every form, the jar, the AOT jar, the native binary and the image, serves it.

**The anchor changes (brief ⚑2, ⚑3).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and
`diff -rq -x target ../c6-tiffinbox after/` is empty at this unit's commit. "Before" is `../c6-unit12/after` — the validation lesson's frozen
tree, which `c6-tiffinbox` equalled at 45edeba. Both trees are read and copied under `.harness/`, never built in place. Two Java files are
new in `tiffinbox-web/src/main/java/com/tiffinbox/web/`, one changed, besides the anchor's README:

```java
final class CustomerNotFound extends RuntimeException {
    private final String name;
    CustomerNotFound(String name) {
        super("no customer named " + name);
        this.name = name;
    }
    String name() {
        return name;
    }
}

@RestControllerAdvice
final class TiffinBoxErrors {
    @ExceptionHandler(CustomerNotFound.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    Map<String, String> notFound(CustomerNotFound e) {
        return Map.of("error", e.getMessage());
    }
}
```

(`CustomerNotFound.java`, 19 lines, 11 of code; `TiffinBoxErrors.java`, 28 lines, 14 of code — each with a Javadoc that says what it does and,
for the advice, what a client that accepts only HTML or XML gets) — and `TiffinBoxServer.java`, 273 lines → 274: `GET /customers/{name}`'s
`.orElseThrow(() -> new CustomerNotFound(name))` where it threw `new ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " +
name)`, that import out, and two Javadoc paragraphs that say who answers now. The anchor's `README.md`: its unit section, and in place the
history notes the change made false (below, "The anchor's README"). The POMs, `application.yaml`, the Dockerfile and `compose.yaml` are
unchanged — 23 of the tree's 27 files byte for byte — and the jar holds the same 56 libraries; its `com/tiffinbox/web` classes 7 → 9
(`change`).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 6 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`; on OrbStack `orb start` is tried once if it does not), with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native
build per `forms` run (three per receipt); its seconds, and the 20-minute bound, go to the terminal only — a hashed line must not move
with the machine's load. **Start it in a process group of its own** (a terminal's foreground job is one): two receipts started as
background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94).

**Runs of record (2026-10-17, this script as committed):** **1,086 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with HOME and a
plain PATH, this folder, its own process group, `.m2-demo` re-seeded from `_research/m2-seed-s3/` alone: every check passed, all 6
captures 3/3 — five = published, `exercise` "no published hash" as designed, its hash then put into `receipts.md5`; the native builds 168,
204 and 221 s) and **978 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same, re-seeded: exit 0, all 6 = published, every check
passed; 168, 174 and 177 s). **A sealed fresh clone**: `git clone` of tiffinbox-java at 6c0a92d, this unit's and the anchor's 65 files put in as git would take them (0 differing from the working tree); `env -i`, a `HOME` of its own whose `.mavenrc` points every Java proxy at a refusing port, Maven settings sending every repository to a `file://` copy of Central's files made from this unit's `.m2-demo` (4,372 files), the proxy variables at the same refusing port, `GRAALVM_HOME`, `DOCKER_CONFIG=~/.docker`, `/bin/bash` 3.2, a process group of its own: exit 0, all 6 = published, every check passed; **526 artifacts, every one from the `file://` copy** (0 from anywhere else), GraalVM's metadata repository from `file:` too; its first build said `offline: no`, as a fresh clone's must, and every capture's build `offline: yes`. **How the hashes were made:** three development runs (bash 5.3), then a first run of record
under /bin/bash 3.2 (959 s) whose six hashes went into `receipts.md5` and a second under bash 5.3 (1,216 s, all 6 = published) — then the
exercise was run as viewers run it (below), its SOLUTION run twice in one shell added the missing line twice and the build failed while the
last line still printed a stale `status:` (Found on the way); the exercise's last line and SOLUTION were fixed, the `exercise` hash
re-made (`d19bc08c…` → `6c598c97…`), and both bashes run again (above); the other five hashes did not move. **The exercise as viewers run
it**, beyond the capture: README then SOLUTION, then SOLUTION again, in one `env -i` `zsh -f` shell → `status: 200 …`, `status: 404 …`,
`status: 404 …`, each exit 0, the shell left in `c6-unit15/`, the line in the copy once; the README's last line alone in an `env -i`
`/bin/bash` shell without the exports — its `java` 23.0.1 — ends with `exit 1` and prints no line; SOLUTION alone in such a shell → `status:
404 …` (its exports first), exit 0; 19449 free after each.

Published hashes: change `5c6f2e2bae7175560cee262e7020c733` · notfound `3084642c563d0e7025760de5f5b8a255` · precedence `f44a39216cbe803da323d54b66ad5e2b` · status `52072794da8e0cba66fd1016aa3b1389` · exercise `6c598c975e990cf1557ac24582017eda` · forms `c9a8aa1b6a07298a983a7c46b9656721`.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but six, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" harness/probe/web/AdviceFirst.java harness/probe/web/AdviceWide.java harness/probe/web/Prec.java harness/probe/web/Who.java
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/customers/Nobody
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:18431/customers/Nobody
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:18431/customers/Nobody
```

The first two are the anchor's run line and its class-path line with `-Duser.language=en -Duser.country=US` after `java` — asserted to be
exactly that — and every java line a capture starts takes the same two options in the same place (`at()`, which must give these two lines
back; a last check refuses any capture's java line without them). The third compiles the course's harness, the four files of
`harness/probe/web`, against after/'s extracted jar, with `-parameters`; the script asserts it names those four and nothing else. The last
three are the anchor README's new line — the path-variable lesson's one-customer line with the name `Nobody` — with curl's `Content-Type`
printed (`[]` when there is none) and one `Accept` header each: a browser's type alone (`text/html`), XML alone, and a browser's whole header
(Chrome's, as RED B1 #83 sent it) — each asserted to be that line with exactly those two changes. Every other request is the one-customer
line with its path swapped (`bc`), and it sends curl's own `Accept: */*`.

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script still fills `.m2-demo`, makes the five other captures, each checked against `receipts.md5`,
then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s3/` alone — 5,837 files, no `com/tiffinbox` — and re-seeded so before each run of record.
**Nothing was downloaded** for this unit: every build said `offline: yes`, the native plugin read its metadata repository from `.m2-demo`,
and every native build log holds 0 lines of the plugin's own download (`Downloaded GraalVM reachability metadata repository from http`,
`Failed to download from http`). A fresh clone's `.m2-demo` is empty (git ignores it): the first build — `after/`'s `mvn -B -Pnative install`,
before any capture — fills it from Maven Central and says `offline: no`; every capture's build then says `offline: yes`. **Docker:** no pull
— `docker build` prints its `load metadata` line and the base image's digest, and `its lines that say pull: 0`. The image
(`tiffinbox-advice:1.0.0`) and the container (`tiffinbox-advice`) are this script's own names, checked absent first and removed on every
exit; the build cache is not pruned (`.dockerignore` keeps `secrets/` out of every build context). **At run time** every request goes to
`127.0.0.1`.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, mounted read-only into the container (`:ro`), and sent only by `../c5-unit11/curlset.sh` and
`harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so
are the log of every JVM that served (at DEBUG in `notfound` too), the container's log (`docker logs`), every file this unit ships, the
binary's bytes, and every blob of the image (`docker save`, each gzip layer unpacked; `forms`): 0 everywhere. The header's name,
`X-Shutdown-Token`, is counted too: 0 in every log. No capture of this unit sends a secret anywhere else, so no canary is needed (S3.10):
`CustomerNotFound`'s message holds the name a client sent, never a header. The exercise makes a token of its own (`openssl rand -hex 13`),
counted 0 times in its own log and never printed.

## The locale — pinned per JVM

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S3.1, RED B2 #111), and `Who`
prints the JVM's locale (`en_US`). On macOS the JVM takes the Mac's first language, not `LC_ALL` (measured by RED B2: `LC_ALL=de_DE.UTF-8`
→ `en_US`), and Spring's, Jackson's and Tomcat's messages in this unit's log lines, and Boot's Whitelabel page, are English text a JVM in
another language could word otherwise. The binary takes no JVM options (its line has none: `at()` checks); the image runs the jar on Linux
with no locale set. A last check refuses any capture whose java line lacks the two options (the extract line, `-Djarmode=tools`, prints
nothing a locale changes).

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`). `.harness/before`, `.harness/after` — the two trees, copied, each with
  a config tree, built and extracted (`change`); `.harness/plant` — after/ with its handler's `@ResponseStatus` line deleted (`status` B);
  `.harness/nat` — after/'s native build, and `.harness/natb` — the previous tree built with the native profile, for its AOT metadata
  (`forms`); `.harness/hc` — the harness's classes, compiled against after/'s own jar with `-parameters`; `.harness/mine` — the exercise's
  copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`), joined by `--spring.main.sources` on
  the extracted jar's class path: `Who` reads the running application as text (`/probe/who/advice`: the annotations `@RestControllerAdvice`
  carries; the `HandlerExceptionResolver` beans in the order the `DispatcherServlet` sorts them, and the composite's resolvers; the
  `ExceptionHandlerExceptionResolver`'s advice cache in the order it asks — each advice's type, its order, its `@ExceptionHandler` methods,
  the types each takes and its `@ResponseStatus` — and, for five exception types, the method each advice resolves it to, by the resolver's
  own `resolveMethodByExceptionType`; the JVM's locale); `Prec` (four routes throwing `IllegalArgumentException`, `NumberFormatException`,
  `IllegalStateException`, `UnsupportedOperationException`, and a handler of its own for `IllegalStateException`); `AdviceWide` (an advice
  at the default order: `IllegalArgumentException`, `NumberFormatException`, `IllegalStateException`, each 400); `AdviceFirst` (ordered
  `Ordered.HIGHEST_PRECEDENCE`, one handler for any `RuntimeException`, no status). Each handler's answer names itself (`{"who":…}`).
  `harness/exercise/TiffinBoxErrors.java` — the exercise's copy of the advice, `status` B's copy byte for byte (checked);
  `harness/shutdown.sh` — POST `/shutdown` with the token read from its file (the binding lesson's, copied unchanged).
- **Ports** (brief ⚑1, 19440-19449): after/'s jar 19440 · the previous tree 19441 · after/ with the harness joined 19442 · the copy whose
  handler names no status 19443 · the AOT jar 19444 · the image 19447 · the binary 19448 · the exercise 19449; 19445 and 19446 are not used.
  All ten, 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked free first; a run that listens on
  8080 or 35729 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character
   token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole
   word → `<user>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, the GraalVM's folder, a unit
   number, Boot's process line, a log time, an unmasked timestamp, a `GMT`, `CET` or `CEST` date, a date in Java's `Date` form, a thread
   number, a stack frame, a whole HTML page, a `sha256:` ID other than the base image's digest, `:8080` or `:35729`, a carriage return, or a
   command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — both forms — in every answer printed and in the seven, which are hashed after it (two lines changed: `/nowhere`'s and GET
   /shutdown's); its form printed beside the seven (`tsform`: every digit → `d`, the zone kept, `Z`). At DEBUG, `timestamp=…,` in the map
   Spring MVC logs.
3. **Boot's Whitelabel page** (`pagef`, S3.6, S3.11): an HTML answer is printed as its `<h1>` and its error line (`There was an unexpected
   error (type=…, status=…).`); its `created` date — written in the JVM's time zone — is masked, and its paragraph counted, never shown; curl's
   status and `Content-Type` follow. A page of another shape is counted, never shown. Checked on two planted pages before any capture.
4. **Log lines** (`logl`, `recs`, `dbg`): from their logger on, as the log prints the logger — `.m.m.a.ExceptionHandlerExceptionResolver`,
   `.w.s.m.a.ResponseStatusExceptionResolver`, `s.w.s.m.m.a.RequestMappingHandlerMapping`, `m.m.a.RequestResponseBodyMethodProcessor`,
   `o.s.w.s.m.m.a.HttpEntityMethodProcessor` and `o.s.web.servlet.DispatcherServlet` are **Spring MVC's**; `o.a.c.c.C.[.[.[/].[dispatcherServlet]`
   is **Tomcat's**; `BasicErrorController`, `DefaultErrorAttributes` and the Whitelabel page are **Boot's**; Boot's first line is cut before
   ` with PID`. Every request a capture asks (`rq`) ends its answer's last line with `· WARN lines it added: N · ERROR lines: M` — the lines
   the log gained between two points where it stopped growing — and each WARN or ERROR record follows: its level, logger and message, then
   the exception line under it; its stack frames bounded ("over 40") and its other lines counted, none shown (checked on a planted log first).
   At DEBUG (`dreq`) every line a request added is printed, counted.
5. **Spring's AOT metadata** (`aotcmp`): the two trees' `reachability-metadata.json`, compared — reflection entries counted, the types only
   one of them registers (named, with what each registers), each entry that differs, the resource entries; the file itself is not printed.
6. **The native build's lines**: its plugin goals, the GraalVM line, the Java version, each `Warning:` — the file a warning names
   (`in 'file:…'`, or `in 'null'`) → `in '…'` — the eight stages cut after their name, the warnings count and `BUILD SUCCESS`; the rest
   counted, never shown.
7. **`docker build --progress=plain`** through a filter: its `load metadata` line, its `FROM` line (the base image's digest), its naming
   line, step numbers and timings cut (checked on a planted log first); lines that say pull, counted; the rest bounded ("fewer than 300").
8. **Inside the container**: `/proc/net/tcp` and `tcp6`, LISTEN rows only, the address decoded. **On this Mac**: `lsof` by pid (or by
   port, for Docker's forwarder), the address column alone — never a command name (R.18).
9. **A URL that holds a character the shell reads** (`;`, `?`, `&`, `*`, `{`, `}`, a space) is single-quoted on the command line, so the
   printed command is the one that ran; the Accept headers are single-quoted on their lines.
10. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the
exercise's shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox JVM,
binary or `native-image` left, removes the container and the image, deletes the capture runs it had not finished (`.r-NAME.1-3`), and
removes `.r-lock`. The published captures are untouched. No `wait` in the script, its checks or the exercise is bare: each names its pid
(S3.9; a check refuses a bare one).

**Measured** on this script (2026-10-17), started as a terminal starts its foreground job (SIGINT at its default, a process group of its
own — from a script, `python3` with `signal.signal(signal.SIGINT, signal.SIG_DFL)` and `os.setpgrp()` before it runs `./receipts.sh`):
SIGINT to its process group during the native build (347 s in, native-image's builder running for 25 s — 5 processes in the group, 2 of
them java): **exit 130** 0.3 s later; 5 s later 0 processes in the group and 0 anywhere naming this folder, no image builder left;
19440-19449, 8080, 18425 and 35729 free; no `tiffinbox-advice` container or image, no `.r-lock`, no unfinished capture run; the published
captures unchanged.

## 1 · change — the exception, the advice, and the throw

Both trees copied under `.harness/`, built with the README's line (offline) and extracted; the harness compiled against after/'s jar (this
unit's `javac` line, `-parameters`: four classes). **Two files differ — the anchor's `README.md` and `TiffinBoxServer.java` — and two are
new**, `CustomerNotFound.java` and `TiffinBoxErrors.java`; 23 of after/'s 27 files are byte for byte the previous tree's.
**`TiffinBoxServer.java` 273 → 274 lines**, its code lines 141 → 140: `ResponseStatusException` named 2 → 0 (its import and its one use),
`CustomerNotFound` 0 → 1 — the diff whole, two hunks: the import out, the throw changed. The two new files' code lines, whole: 11 and 14. The
jar: 56 libraries, the same names; `BOOT-INF/classes/com/tiffinbox/web` 7 classes → 9, the two new ones.

`.r-change.out` · md5 `5c6f2e2bae7175560cee262e7020c733` · 3 of 3

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
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" harness/probe/web/AdviceFirst.java harness/probe/web/AdviceWide.java harness/probe/web/Prec.java harness/probe/web/Who.java
  exit 0 · its classes: probe/web/AdviceFirst.class probe/web/AdviceWide.class probe/web/Prec.class probe/web/Who.class
the files that differ, and the files only one tree has:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: CustomerNotFound.java
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: TiffinBoxErrors.java
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
  after/'s files: 27 · byte for byte the previous tree's: 23 · new: 2 · those that differ: 2
  TiffinBoxServer.java: 273 lines -> 274 · its lines that are neither comment nor blank: 141 -> 140 · naming ResponseStatusException: 2 -> 0, of them imports: 1 -> 0 · naming CustomerNotFound: 0 -> 1
  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: 2 · lines out: 2 · in: 1 - whole:
    @@ -17 +16,0 @@
    -import org.springframework.web.server.ResponseStatusException;
    @@ -63 +62 @@
    -                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " + name));
    +                .orElseThrow(() -> new CustomerNotFound(name));
  CustomerNotFound.java - new: 19 lines · its lines that are neither comment nor blank: 11 - whole:
    package com.tiffinbox.web;
    final class CustomerNotFound extends RuntimeException {
        private final String name;
        CustomerNotFound(String name) {
            super("no customer named " + name);
            this.name = name;
        }
        String name() {
            return name;
        }
    }
  TiffinBoxErrors.java - new: 28 lines · its lines that are neither comment nor blank: 14 - whole:
    package com.tiffinbox.web;
    import org.springframework.http.HttpStatus;
    import org.springframework.web.bind.annotation.ExceptionHandler;
    import org.springframework.web.bind.annotation.ResponseStatus;
    import org.springframework.web.bind.annotation.RestControllerAdvice;
    import java.util.Map;
    @RestControllerAdvice
    final class TiffinBoxErrors {
        @ExceptionHandler(CustomerNotFound.class)
        @ResponseStatus(HttpStatus.NOT_FOUND)
        Map<String, String> notFound(CustomerNotFound e) {
            return Map.of("error", e.getMessage());
        }
    }
  README.md - the anchor's README: lines added 63, removed 3 - its new section and the history notes the change made false (not shown)
the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes
the classes in the jar's com/tiffinbox/web: 7 -> 9 · only after/'s: CustomerNotFound.class TiffinBoxErrors.class · only the previous tree's: none
```

## 2 · notfound — the answer, and who gives it

**The seven**, on a fresh JVM of after/: `87ca7efc…` (masked), as on every tree since the request-mapping lesson — none of them asks for a
name — and one WARN line in that run's log, Spring MVC's `DefaultHandlerExceptionResolver` for GET /shutdown's 405. Then, on a second start, curl's own `Accept: */*`: **`/customers/Nobody` → `{"error":"no customer named Nobody"} 404`**,
`/customers/Sunil%20K` → `{"error":"no customer named Sunil K"} 404` (the path variable decoded), Ravi 200 — each with 0 WARN and 0 ERROR
lines. **The previous tree**, the same three: Boot's body, `{"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"}`,
the second with the path as sent, `Sunil%20K` — no name, no reason, 0 and 0. **Who answers** (the harness's `Who`): `@RestControllerAdvice`
carries `@ControllerAdvice` and `@ResponseBody`; the `DispatcherServlet` asks 2 `HandlerExceptionResolver` beans — Boot's
`DefaultErrorAttributes`, then Spring MVC's composite, whose 3 resolvers are `ExceptionHandlerExceptionResolver`,
`ResponseStatusExceptionResolver` and `DefaultHandlerExceptionResolver`, in that order; the first's advice cache holds one advice,
`TiffinBoxErrors`, at order 2147483647 (`Ordered.LOWEST_PRECEDENCE`, the default), its one handler `notFound` taking `CustomerNotFound`
with `NOT_FOUND`. **At DEBUG** (the embedded-Tomcat lesson's line): 7 lines — `Using @ExceptionHandler
com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)`, the map written by `RequestResponseBodyMethodProcessor` (`given [*/*]`),
`Resolved [com.tiffinbox.web.CustomerNotFound: no customer named Nobody]`, `Completed 404 NOT_FOUND` — and no error dispatch; the previous
tree's 9: `ResponseStatusExceptionResolver` resolved the `ResponseStatusException`, then the container's `"ERROR" dispatch for GET "/error"`
mapped to Boot's `BasicErrorController#error`, whose body `HttpEntityMethodProcessor` wrote.

`.r-notfound.out` · md5 `3084642c563d0e7025760de5f5b8a255` · 3 of 3

```
the seven - after/, the README's run line, port 19440, a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19440
  listens on: 127.0.0.1:19440 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19440 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
after/ - a second start, port 19440: a name nobody has (the anchor's new line), a name with a space, then Ravi:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19440
  listens on: 127.0.0.1:19440 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Nobody
  {"error":"no customer named Nobody"} 404 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Sunil%20K
  {"error":"no customer named Sunil K"} 404 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19440 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19440 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the previous tree - the same three, port 19441:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19441
  listens on: 127.0.0.1:19441 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19441/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19441/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19441/customers/Sunil%20K
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Sunil%20K"} 404 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19441/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19441 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19441 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
who answers - after/ with the harness's Who joined, port 19442 - read off the running application:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19442 --spring.main.sources=probe.web.Who
  listens on: 127.0.0.1:19442 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/who/advice
  @RestControllerAdvice - the annotations it carries (java.lang.annotation's left out): @ControllerAdvice @ResponseBody
  the HandlerExceptionResolver beans, in the order the DispatcherServlet asks them: 2
    1 errorAttributes - org.springframework.boot.webmvc.error.DefaultErrorAttributes
    2 handlerExceptionResolver - org.springframework.web.servlet.handler.HandlerExceptionResolverComposite
        2.1 org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver
        2.2 org.springframework.web.servlet.mvc.annotation.ResponseStatusExceptionResolver
        2.3 org.springframework.web.servlet.mvc.support.DefaultHandlerExceptionResolver
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 1
    1 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound - takes CustomerNotFound · @ResponseStatus: NOT_FOUND
  a CustomerNotFound, each advice's method for it, in that order: TiffinBoxErrors: notFound
  an IllegalArgumentException, each advice's method for it, in that order: TiffinBoxErrors: none
  a NumberFormatException, each advice's method for it, in that order: TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: TiffinBoxErrors: none
  an UnsupportedOperationException, each advice's method for it, in that order: TiffinBoxErrors: none
  the JVM's locale: en_US
   200 · WARN lines it added: 0 · ERROR lines: 0
$ harness/shutdown.sh 19442 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19442 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
who resolved it, at DEBUG - the embedded-Tomcat lesson's line (Boot's web group at DEBUG): after/, port 19440:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19440 --logging.level.web=debug
  listens on: 127.0.0.1:19440 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Nobody
  {"error":"no customer named Nobody"} 404
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 7:
    o.s.web.servlet.DispatcherServlet: GET "/customers/Nobody", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#customer(String)
    .m.m.a.ExceptionHandlerExceptionResolver: Using @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)
    m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    m.m.a.RequestResponseBodyMethodProcessor: Writing [{error=no customer named Nobody}]
    .m.m.a.ExceptionHandlerExceptionResolver: Resolved [com.tiffinbox.web.CustomerNotFound: no customer named Nobody]
    o.s.web.servlet.DispatcherServlet: Completed 404 NOT_FOUND
$ harness/shutdown.sh 19440 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19440 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the previous tree, the same line, port 19441:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19441 --logging.level.web=debug
  listens on: 127.0.0.1:19441 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19441/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19441/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 9:
    o.s.web.servlet.DispatcherServlet: GET "/customers/Nobody", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#customer(String)
    .w.s.m.a.ResponseStatusExceptionResolver: Resolved [org.springframework.web.server.ResponseStatusException: 404 NOT_FOUND "no customer named Nobody"]
    o.s.web.servlet.DispatcherServlet: Completed 404 NOT_FOUND
    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=404, error=Not Found, path=/customers/Nobody}]
    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 404
$ harness/shutdown.sh 19441 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19441 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · precedence — which handler wins (the course's harness)

**`Prec` and `AdviceWide` joined** (with `Who`): the advice cache lists `AdviceWide`, then `TiffinBoxErrors`, both at 2147483647 — two at
the same order, in the order the cache holds them (the joined source's first, here); `Who`'s table shows which method each advice resolves
each type to. `/probe/prec/iae` → `AdviceWide: IllegalArgumentException` 400; **`nfe` → `AdviceWide: NumberFormatException`** — inside one
advice, the nearest type, though `IllegalArgumentException`'s handler would take it too; **`ise` → `Prec, the controller's own handler`** —
before `AdviceWide`'s `IllegalStateException` handler; **`uoe`, no handler → Boot's 500 and 1 ERROR line**, Tomcat's, its trace over 40
frames. TiffinBox's own: `/customers/Nobody` still `TiffinBoxErrors`' 404; and `?mealType=veg` → `AdviceWide: IllegalArgumentException`
400 with 0 WARN lines, where after/ alone answers it with Spring MVC's `DefaultHandlerExceptionResolver` and one WARN (the path-variable
lesson's) — a broad handler takes more than its name says. **`AdviceFirst` joined too** (`Ordered.HIGHEST_PRECEDENCE`, −2147483648): 3
advices, it first; `iae`, `nfe`, `uoe`, `/customers/Nobody` and `?mealType=veg` → **`{"who":"AdviceFirst: RuntimeException"} 200`** —
across advices, order before nearness, and a handler that names no status answers 200; `ise` still the controller's own 400. 0 WARN and 0
ERROR lines in that run.

`.r-precedence.out` · md5 `f44a39216cbe803da323d54b66ad5e2b` · 3 of 3

```
after/ with the harness's Who, Prec and AdviceWide joined, port 19442 - AdviceWide at the default order:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19442 --spring.main.sources=probe.web.Who,probe.web.Prec,probe.web.AdviceWide
  listens on: 127.0.0.1:19442 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/who/advice
  @RestControllerAdvice - the annotations it carries (java.lang.annotation's left out): @ControllerAdvice @ResponseBody
  the HandlerExceptionResolver beans, in the order the DispatcherServlet asks them: 2
    1 errorAttributes - org.springframework.boot.webmvc.error.DefaultErrorAttributes
    2 handlerExceptionResolver - org.springframework.web.servlet.handler.HandlerExceptionResolverComposite
        2.1 org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver
        2.2 org.springframework.web.servlet.mvc.annotation.ResponseStatusExceptionResolver
        2.3 org.springframework.web.servlet.mvc.support.DefaultHandlerExceptionResolver
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 2
    1 probe.web.AdviceWide · its order: 2147483647
        @ExceptionHandler iae - takes IllegalArgumentException · @ResponseStatus: BAD_REQUEST
        @ExceptionHandler ise - takes IllegalStateException · @ResponseStatus: BAD_REQUEST
        @ExceptionHandler nfe - takes NumberFormatException · @ResponseStatus: BAD_REQUEST
    2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound - takes CustomerNotFound · @ResponseStatus: NOT_FOUND
  a CustomerNotFound, each advice's method for it, in that order: AdviceWide: none · TiffinBoxErrors: notFound
  an IllegalArgumentException, each advice's method for it, in that order: AdviceWide: iae · TiffinBoxErrors: none
  a NumberFormatException, each advice's method for it, in that order: AdviceWide: nfe · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: AdviceWide: ise · TiffinBoxErrors: none
  an UnsupportedOperationException, each advice's method for it, in that order: AdviceWide: none · TiffinBoxErrors: none
  the JVM's locale: en_US
   200 · WARN lines it added: 0 · ERROR lines: 0
  the harness's Prec - four routes, each throwing one exception; its own handler takes IllegalStateException:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/prec/iae
  {"who":"AdviceWide: IllegalArgumentException"} 400 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/prec/nfe
  {"who":"AdviceWide: NumberFormatException"} 400 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/prec/ise
  {"who":"Prec, the controller's own handler: IllegalStateException"} 400 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/prec/uoe
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/prec/uoe"} 500 · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.UnsupportedOperationException: not supported] with root cause
      java.lang.UnsupportedOperationException: not supported
      its stack frames: over 40, its other lines: 2 - none shown
  TiffinBox's own routes - a name nobody has; a meal type that is not one (the path-variable lesson's 400):
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/customers/Nobody
  {"error":"no customer named Nobody"} 404 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19442/customers?mealType=veg'
  {"who":"AdviceWide: IllegalArgumentException"} 400 · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19442 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19442 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
AdviceFirst joined too - ordered first (Ordered.HIGHEST_PRECEDENCE), one handler for any RuntimeException, no status - port 19442:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19442 --spring.main.sources=probe.web.Who,probe.web.Prec,probe.web.AdviceWide,probe.web.AdviceFirst
  listens on: 127.0.0.1:19442 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/who/advice
  @RestControllerAdvice - the annotations it carries (java.lang.annotation's left out): @ControllerAdvice @ResponseBody
  the HandlerExceptionResolver beans, in the order the DispatcherServlet asks them: 2
    1 errorAttributes - org.springframework.boot.webmvc.error.DefaultErrorAttributes
    2 handlerExceptionResolver - org.springframework.web.servlet.handler.HandlerExceptionResolverComposite
        2.1 org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver
        2.2 org.springframework.web.servlet.mvc.annotation.ResponseStatusExceptionResolver
        2.3 org.springframework.web.servlet.mvc.support.DefaultHandlerExceptionResolver
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 3
    1 probe.web.AdviceFirst · its order: -2147483648
        @ExceptionHandler any - takes RuntimeException · @ResponseStatus: none
    2 probe.web.AdviceWide · its order: 2147483647
        @ExceptionHandler iae - takes IllegalArgumentException · @ResponseStatus: BAD_REQUEST
        @ExceptionHandler ise - takes IllegalStateException · @ResponseStatus: BAD_REQUEST
        @ExceptionHandler nfe - takes NumberFormatException · @ResponseStatus: BAD_REQUEST
    3 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound - takes CustomerNotFound · @ResponseStatus: NOT_FOUND
  a CustomerNotFound, each advice's method for it, in that order: AdviceFirst: any · AdviceWide: none · TiffinBoxErrors: notFound
  an IllegalArgumentException, each advice's method for it, in that order: AdviceFirst: any · AdviceWide: iae · TiffinBoxErrors: none
  a NumberFormatException, each advice's method for it, in that order: AdviceFirst: any · AdviceWide: nfe · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: AdviceFirst: any · AdviceWide: ise · TiffinBoxErrors: none
  an UnsupportedOperationException, each advice's method for it, in that order: AdviceFirst: any · AdviceWide: none · TiffinBoxErrors: none
  the JVM's locale: en_US
   200 · WARN lines it added: 0 · ERROR lines: 0
  the harness's Prec - four routes, each throwing one exception; its own handler takes IllegalStateException:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/prec/iae
  {"who":"AdviceFirst: RuntimeException"} 200 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/prec/nfe
  {"who":"AdviceFirst: RuntimeException"} 200 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/prec/ise
  {"who":"Prec, the controller's own handler: IllegalStateException"} 400 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/probe/prec/uoe
  {"who":"AdviceFirst: RuntimeException"} 200 · WARN lines it added: 0 · ERROR lines: 0
  TiffinBox's own routes - a name nobody has; a meal type that is not one (the path-variable lesson's 400):
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19442/customers/Nobody
  {"who":"AdviceFirst: RuntimeException"} 200 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19442/customers?mealType=veg'
  {"who":"AdviceFirst: RuntimeException"} 200 · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19442 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19442 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · status — the status is the handler's (A/B/A′); C and D, labelled — what a client that accepts something else gets

**A** — after/: `/customers/Nobody` → 404, Ravi 200. **B** — a copy of after/ whose handler names no status: one line out of
`TiffinBoxErrors.java`, `@ResponseStatus(HttpStatus.NOT_FOUND)` (`diff -U0`, one hunk), built the same way — `{"error":"no customer named
Nobody"} 200`; the exercise's copy, `harness/exercise/TiffinBoxErrors.java`, is this copy's file byte for byte. **A′** = A, on a fresh JVM:
the same, line for line. **C (labelled)** — A, asked by three clients, each sent by curl (no browser ran; S3.12): **`Accept: text/html`** → Boot's
Whitelabel page, **500**; **`Accept: application/xml`** → **500**, no body, no `Content-Type`; each adds **1 WARN** — Spring MVC's
`ExceptionHandlerExceptionResolver`, `Failure in @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)`, the exception
under it `org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation` — and **1 ERROR**, Tomcat's, the
`CustomerNotFound` itself; **a browser's whole Accept header** (Chrome's, which ends `*/*;q=0.8`) → `{"error":"no customer named Nobody"} 404
· Content-Type: [application/json]`, 0 and 0. The handler's map is written like a route's answer, by content negotiation, and TiffinBox's
converters write JSON only. **D (labelled)** — the previous tree, the same three: the Whitelabel page **404**, an empty **404**, and the
Whitelabel page 404 for the browser's whole header — 0 WARN, 0 ERROR. So the advice turned two 404s into 500s for clients that accept only
HTML or only XML, and gave a browser JSON where it had Boot's page. *ProblemDetail and RFC 9457* is the lesson that answers every client.

`.r-status.out` · md5 `52072794da8e0cba66fd1016aa3b1389` · 3 of 3

```
A - after/, the README's run line, port 19440 - a name nobody has, then Ravi:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19440
  listens on: 127.0.0.1:19440 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Nobody
  {"error":"no customer named Nobody"} 404 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19440 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19440 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - a copy of after/ whose handler names no status - its one changed line - then built the same way, port 19443:
$ diff -U0 after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java .harness/plant/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java
  @@ -24 +23,0 @@
  -    @ResponseStatus(HttpStatus.NOT_FOUND)
  the exercise's copy (harness/exercise/TiffinBoxErrors.java) is this copy's file, byte for byte: yes
$ cd .harness/plant && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy · offline: yes · exit 0
$ cd .harness/plant && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19443
  listens on: 127.0.0.1:19443 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19443/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19443/customers/Nobody
  {"error":"no customer named Nobody"} 200 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19443/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19443 .harness/plant/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19443 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19440
  listens on: 127.0.0.1:19440 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Nobody
  {"error":"no customer named Nobody"} 404 · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19440 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19440 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - A asked by three clients, each sent by curl: one that accepts only HTML (a browser's type), one that accepts only XML, and a browser's whole Accept header (Chrome's) - port 19440:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19440
  listens on: 127.0.0.1:19440 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19440/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 1
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)
      org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation
      its stack frames: over 40, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: com.tiffinbox.web.CustomerNotFound: no customer named Nobody] with root cause
      com.tiffinbox.web.CustomerNotFound: no customer named Nobody
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19440/customers/Nobody
   500 · Content-Type: [] · WARN lines it added: 1 · ERROR lines: 1
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in @ExceptionHandler com.tiffinbox.web.TiffinBoxErrors#notFound(CustomerNotFound)
      org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation
      its stack frames: over 40, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: com.tiffinbox.web.CustomerNotFound: no customer named Nobody] with root cause
      com.tiffinbox.web.CustomerNotFound: no customer named Nobody
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19440/customers/Nobody
  {"error":"no customer named Nobody"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 2
$ harness/shutdown.sh 19440 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19440 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
D (labelled) - the previous tree, the same three, port 19441:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19441
  listens on: 127.0.0.1:19441 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19441/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19441/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Found, status=404). · its created date: masked · its paragraphs: 1, not shown · then curl's: 404 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19441/customers/Nobody
   404 · Content-Type: [] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19441/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Found, status=404). · its created date: masked · its paragraphs: 1, not shown · then curl's: 404 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19441 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19441 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s 7 lines and then `exercise/solution/SOLUTION.md`'s 4, read from the files and run in **one** shell a viewer could
have: `env -i` (HOME and the PATH the script was started with), `/bin/bash --noprofile --norc`, started in this folder. The README's last
line builds the copy (the harness's advice in place, one line short), starts it on 19449, asks for Nobody, stops it, waits for its JVM
(`wait $!`) and prints **`status: 200 · body: {"error":"no customer named Nobody"}`**; the solution's — its two exports, the line that puts
`@ResponseStatus(HttpStatus.NOT_FOUND)` back after the handler's `@ExceptionHandler` line, and the README's last line again —
**`status: 404 · body: {"error":"no customer named Nobody"}`**, and the copy's `TiffinBoxErrors.java` is after/'s again, byte for byte. Each
block exits 0 and leaves the shell in this unit's folder; the copy's own token 0 times in its log; 0 WARN and 0 ERROR lines; 19449 free
after.

`.r-exercise.out` · md5 `6c598c975e990cf1557ac24582017eda` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ cp harness/exercise/TiffinBoxErrors.java .harness/mine/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && rm -f ../got.json && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19449 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19449/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' http://127.0.0.1:19449/customers/Nobody); ../../../harness/shutdown.sh 19449 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "status: $s · body: $(cat ../got.json)")
  exit 0 · what they printed:
    status: 200 · body: {"error":"no customer named Nobody"}
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19449 now: 0
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ f=.harness/mine/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java && { grep -q '@ResponseStatus(HttpStatus.NOT_FOUND)' "$f" || { awk '{ print } $0 == "    @ExceptionHandler(CustomerNotFound.class)" { print "    @ResponseStatus(HttpStatus.NOT_FOUND)" }' "$f" > "$f.new" && mv "$f.new" "$f"; }; }
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && rm -f ../got.json && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19449 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19449/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' http://127.0.0.1:19449/customers/Nobody); ../../../harness/shutdown.sh 19449 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "status: $s · body: $(cat ../got.json)")
  exit 0 · what they printed:
    status: 404 · body: {"error":"no customer named Nobody"}
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19449 now: 0
  the copy's TiffinBoxErrors.java against after/'s now: the same, byte for byte
```

## 6 · forms — every form serves it (⚑7, R.103)

**The native build** of after/ (`.harness/nat`, the README's two Maven lines, offline): exit 0, `BUILD SUCCESS`, 8 of 8 stages, 0 lines of
the plugin's own download; Mach-O on this Mac, 0 bytes of the token. **Spring's AOT step, on both trees** (the previous tree built with the
README's native-profile line, `.harness/natb`): **665 reflection entries → 666** — the one new entry `com.tiffinbox.web.TiffinBoxErrors`,
its one method `notFound(CustomerNotFound)`; no entry differs; `CustomerNotFound` needs no entry of its own; 26 resource entries, the same.
No hint was added. **Four forms** — the jar (19440), the AOT jar (19444), the binary (19448), the image (published on 127.0.0.1:19447, 18425
inside): each listening on loopback only, the seven `87ca7efc…` (masked), exit 0; then, on a second start of each, **`/customers/Nobody` →
404 and the name**, `Sunil%20K` → 404 and the name, Ravi 200, `/customers/Nobody` for a client that accepts only HTML → Boot's 500 page —
the cost ships in every form — and POST /shutdown without the token 403 — 4 of 4 each. The image: built from after/'s Dockerfile, 0 lines
that say pull, its layers 0 bytes of the token; `docker port` `18425/tcp -> 127.0.0.1:19447` alone.

`.r-forms.out` · md5 `c9a8aa1b6a07298a983a7c46b9656721` · 3 of 3

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
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json) - the previous tree's against after/'s: reflection entries 665 -> 666 · types only the previous tree registers: none · only after/: com.tiffinbox.web.TiffinBoxErrors · entries that differ: 0
    com.tiffinbox.web.TiffinBoxErrors - 1 method (notFound(CustomerNotFound))
  resource entries: 26 -> 26 · the same: yes
1 the jar - .harness/after, the README's run line, port 19440:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19440
  listens on: 127.0.0.1:19440 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19440 (http) with context path '/'
$ $CURLSET 19440 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then a name nobody has, a name with a space, Ravi, the first for a client that accepts only HTML, and POST /shutdown without the token, on a second start of the jar:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19440
  listens on: 127.0.0.1:19440 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Nobody
  {"error":"no customer named Nobody"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Sunil%20K
  {"error":"no customer named Sunil K"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19440/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19440/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8]
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19440/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19440 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19440 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19444:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19444
  listens on: 127.0.0.1:19444 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19444/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19444 (http) with context path '/'
$ $CURLSET 19444 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the same five, on a second start of the AOT jar:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19444
  listens on: 127.0.0.1:19444 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19444/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19444/customers/Nobody
  {"error":"no customer named Nobody"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19444/customers/Sunil%20K
  {"error":"no customer named Sunil K"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19444/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19444/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8]
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19444/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19444 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19444 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19448:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19448
  listens on: 127.0.0.1:19448 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19448/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19448 (http) with context path '/'
$ $CURLSET 19448 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the same five, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19448
  listens on: 127.0.0.1:19448 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19448/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19448/customers/Nobody
  {"error":"no customer named Nobody"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19448/customers/Sunil%20K
  {"error":"no customer named Sunil K"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19448/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19448/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8]
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19448/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19448 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19448 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19447:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-advice:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-advice:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-advice --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19447:18425 tiffinbox-advice:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19447/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19447
  on this Mac, listening on port 19447: 127.0.0.1:19447
$ $CURLSET 19447 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-advice
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then the same five, on a second container of the image - TiffinBox listens on 18425 inside it:
$ cd .harness/after && docker run -d --name tiffinbox-advice --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19447:18425 tiffinbox-advice:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19447/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19447
  on this Mac, listening on port 19447: 127.0.0.1:19447
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19447/customers/Nobody
  {"error":"no customer named Nobody"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19447/customers/Sunil%20K
  {"error":"no customer named Sunil K"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19447/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19447/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8]
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19447/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19447 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-advice
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times
four forms, one tree: the seven (masked) 4 of 4 times 87ca7efc8584dcccd40e6b956db1de9b · a name nobody has, 404 and the name 4 of 4 · a name with a space, 404 and the name 4 of 4 · Ravi 200 4 of 4 · the name nobody has for a client that accepts only HTML, Boot's 500 page 4 of 4 · POST /shutdown without the token 403 4 of 4
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
```

## Exercise

**Your turn:** the README's request for a missing customer answers two hundred. Find the handler's missing line, add it, and ask again.
`exercise/README.md` has the commands (copy `after/`, put the harness's copy of the advice in its place — one line short — give the copy a
token of its own); its last line, in a subshell, builds the copy offline, starts it on 19449, asks for a customer nobody has, stops it,
waits for its JVM and prints — as shipped — `status: 200 · body: {"error":"no customer named Nobody"}`. Done is `status: 404 · body:
{"error":"no customer named Nobody"}`. Measured answer: `exercise/solution/SOLUTION.md` (the README's two `export` lines, the
`@ResponseStatus(HttpStatus.NOT_FOUND)` line put back, the README's last line again), run in the same shell. Run `./receipts.sh` once
first on a fresh clone.

## The anchor's README — what this unit changed in it

`../c6-tiffinbox/README.md` (= `after/README.md`) gains its `## Course 6 · unit 15` section (before Course 5's README begins) with the
anchor's new line, `curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Nobody`, and three history notes amended in place, each
an *(Course 6, unit 15: …)* note — found by grepping the README for `ResponseStatusException`, `Nobody`, `no reason`, `404`, `names no` (S2.22):
- the path-variable section's `GET /customers/{name}` bullet: "a name nobody has throws Spring's `ResponseStatusException` with 404" →
  `CustomerNotFound` since, answered by `TiffinBoxErrors`;
- the same section's "`/customers/Nobody` → 404, Boot's body … no reason in the body" → `{"error":"no customer named Nobody"} 404` since;
- the response section's "Statuses by accident": "TiffinBox's own route, Spring's `ResponseStatusException`: 404 and Boot's body" →
  `CustomerNotFound` since, the advice's body.
Left as they were, and still true (each read): the request-mapping section's `/nowhere` 404 (Boot's body: no route, no advice); the WARN
lines for each 400, 405, 406 and 415 (Spring MVC's `DefaultHandlerExceptionResolver`: the advice takes none of them); `{"error":"forbidden"}`
(the 403, the method's own); the path-variable section's timer line for `/customers/Nobody` (`uri="/customers/{name}"`, 404 — Boot's timer
tags the advice's 404 the same, a terminal check of this unit, not a capture); every form's `/customers/Nobody` 404 (the status holds; the
body is new, and the new section says so). `c6-tiffinbox/README.md`: 63 lines added, 3 removed (`change`).

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-17) |
|---|---|---|---|
| 2 | 15's advice in the AOT jar, the binary and the image | s15 on the jar only | **all four forms: 404 and the name, `Sunil K` too, Ravi 200, only-HTML 500, 403; the seven `87ca7efc…`; AOT 665 → 666, `TiffinBoxErrors` the new entry; no hint** (`forms`) |
| 3 | 15's break B (no `@ResponseStatus` → 200) on the anchor's handler | `AdviceFirst` only | **a copy of after/ with the one line out → `{"error":"no customer named Nobody"} 200`; A′ = A** (`status`) |
| 13 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: `status: 200`, then `status: 404`, the same body** (`exercise`) |
| — | the probe's precedence on the anchor's own advice | s15 + the harness | **nearest type, the controller's own first, no handler → 500; ordered first → 200 for five** (`precedence`) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **"A `Map` body … breaks browsers"** (brief READ FIRST 6, ⚑3) is **scoped to clients that accept only HTML or only XML**. A real browser's
  whole Accept header — Chrome's, sent by curl — ends `*/*;q=0.8`, and Spring MVC's content negotiation finds JSON acceptable: **404 JSON**
  (`status` C). The previous tree gave that header Boot's Whitelabel 404 (`status` D), because Boot's error controller has an HTML method for
  a request that accepts `text/html`; the advice answers on the request itself, with no error dispatch. The voice says "a client that only
  reads HTML", never "a browser".
- **A broad handler steals a 400** (not in the brief): with `AdviceWide` joined, `?mealType=veg` — Spring MVC's
  `MethodArgumentTypeMismatchException` — answered `AdviceWide: IllegalArgumentException` 400, and its WARN line went silent (0, where after/
  alone logs 1). Shown in `precedence`, not spoken: the catch-all is *Error-Handling Traps*' subject.
- **`CustomerNotFound` is 19 lines, 11 of code** (the brief: 7): it keeps a `name()` accessor, unused here, for *ProblemDetail and RFC 9457*'s
  `name` extension, and a Javadoc.
- **Spring's AOT step registers the advice by itself**: 665 → 666, `TiffinBoxErrors` with `notFound(CustomerNotFound)`; the binary answers
  the 404 with no hint (RE-MEASURE 2: the probe had no image and no AOT comparison).
- **D (labelled) is added**: the previous tree under the same three Accept headers — the "before" C needs.

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block runs alone, under /bin/bash 3.2, on copies of the published captures with one thing changed per plant (`plants.py`, this
  unit's scratch folder) — **71 plants, 71 stops**, each naming its own check; the unplanted copies pass. Four change a command line in the
  script and in its README alike, so that the derivation check alone must stop the run (an Accept line with a second header, the javac line
  with a fifth file, the anchor's new line with another name, the pinned run line with another option); three plant Boot 3's error key where
  S3.21 forbids it (SOLUTION.md, after/, this README); one a bare `wait` in the exercise (S3.9); one an unpinned java line (S3.1); one a
  Whitelabel date left unmasked; one a whole HTML page; one a bind on 35729; the rest change one line of a capture each.
- **Three filters fail on planted inputs inside the script itself**, before any capture: the Whitelabel filter (a planted page and a page of
  another shape), the record filter (a planted WARN with 45 frames and an ERROR with 3), and docker build's.
- **A first development run** printed `a IllegalArgumentException` in `Who`'s table; the harness now picks `an` before a vowel. The page
  filter counted curl's status into a page's length on its planted check, and stopped the run; it counts the page alone now.
- **The exercise's SOLUTION, run twice in one shell, broke the build and still printed a status** (a viewer test, not a capture): the line
  that puts `@ResponseStatus` back was appended a second time — `ResponseStatus is not a repeatable annotation interface`, Maven's
  compilation error — and the README's last line went on past the failed build: `wait $!` with no JVM started waits for nothing and
  returns 0, so `status:  · body: …` came out of the previous run's file. Now the line deletes `../got.json` first, saves the JVM's pid
  (`p=$!`) and waits for `"$p"` — empty when the build failed, so `wait` fails (bash 3.2 and 5.3: exit 1; zsh: 127) and nothing is printed —
  and SOLUTION adds the line only when it is not there. Measured: SOLUTION twice → `status: 404 …` twice, the line once.
- **The probe's sketch and this tree agree** (brief READ FIRST 6, 7; S3 notes Step 4): 404 with the name, 0 WARN; the seven `87ca7efc…`;
  the advice cache's tie listed in the order found; nearest type inside one advice; the controller's own first; order across advices, 200
  without a status; `Failure in @ExceptionHandler` for HTML and XML — each now a line of this unit's own captures.

## For unit 16 — and RED

- **Start from `../c6-unit15/after`** (= `../c6-tiffinbox`). `TiffinBoxServer` (274 lines, final, `@RestController`): `GET /customers/{name}`
  → `repo.findByName(name).orElseThrow(() -> new CustomerNotFound(name))`; the 403 `{"error":"forbidden"}` and the empty 409 are unchanged,
  the method's 400 is still the `TreeMap` field map. **`CustomerNotFound`** — package-private, final, `extends RuntimeException`, message
  `no customer named X`, **`String name()`** (for the `name` extension). **`TiffinBoxErrors`** — `@RestControllerAdvice`, final,
  package-private, one handler `notFound(CustomerNotFound)`, `@ResponseStatus(HttpStatus.NOT_FOUND)`, returns `Map.of("error",
  e.getMessage())`; Spring's AOT step registers it (665 → 666 reflection entries; the binary serves it, no hint).
- **The seven** on this tree: `87ca7efc8584dcccd40e6b956db1de9b` (masked, 2 lines changed by the mask, 1 WARN — the 405,
  `DefaultHandlerExceptionResolver`). The advice cache: 1 advice, `TiffinBoxErrors`, 2147483647; the composite's resolvers 3, EHER first;
  no `ResponseEntityExceptionHandler` bean (the harness's `Who` reads the resolvers and the cache: copy it; it takes `CustomerNotFound` by
  name, `Class.forName`). With `spring.mvc.problemdetails.enabled: true` Boot's `ProblemDetailsExceptionHandler` should sit at order 0,
  before `TiffinBoxErrors` (the probe's; measure it on 16's tree).
- **What 16 inherits and must fix, named:** `Accept: text/html` and `Accept: application/xml` on `/customers/Nobody` → 500, 1 WARN
  (`ExceptionHandlerExceptionResolver`, `Failure in @ExceptionHandler`, `HttpMediaTypeNotAcceptableException: No acceptable
  representation`) + 1 ERROR (Tomcat's, `CustomerNotFound`) each, in every form; Chrome's whole header → 404 JSON. 16's `ProblemDetail`
  (`application/problem+json`) should end both 500s — re-measure all three headers, and say what a browser gets now.
- **Lines and helpers to reuse:** this unit's three Accept lines (`L_HTML`, `L_XML`, `L_CHROME`: the one-customer line with
  `-w ' %{http_code} · Content-Type: [%{content_type}]\n'` and one header); `pagef` (the Whitelabel page by its `<h1>` and error line, the
  `created` date masked); `recs` (a WARN/ERROR record, its exception line, frames over 40); `rq` (WARN and ERROR counted per request). The
  anchor README's new line: `curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Nobody` → `{"error":"no customer named Nobody"}
  404`. A problem detail's body sorts its keys itself (the probe): print it raw, never through `sortj`.
- **The exercise's copy** (`harness/exercise/TiffinBoxErrors.java`) is this tree's advice without its status line; if 16 changes
  `TiffinBoxErrors`, this unit's exercise still builds its own copy of `../c6-unit15/after` and is unaffected.
- **Native:** the native builds here took about 3 to 5 minutes each (terminal only, never hashed). The image `tiffinbox-advice:1.0.0` and
  the container `tiffinbox-advice` are this unit's names — take your own. Ports 19440-19449 are this unit's; 16 has 19450-19459.
- **The anchor README** got this unit's section and three history notes amended in place (each *(Course 6, unit 15: …)*). For RED: check
  them against `notfound`, and check that no other line names `ResponseStatusException` as TiffinBox's (grep: only the history notes and the
  previous tree's DEBUG lines do).

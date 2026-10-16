# c6-unit10 — Responses: ResponseEntity and Status Codes

Course 6 · Spring Web MVC · Section 2 (Controllers and Binding), its fifth unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5, H2 2.5.250), **GraalVM CE 25.3.4.1** (native-image
25.0.4.1), **Docker on OrbStack**, 2026-10-14. Until this unit TiffinBox answered a new customer with 200 — what Spring MVC answers for a
route that returns its body alone — a name already taken with Boot's 500 and an ERROR line with a trace of over 50 frames, and a stop
without the token with a 403 it set on the servlet response itself. This unit says each status on purpose: **201 Created** with a
**`Location`** header you can follow, **409 Conflict** for a name that is taken — decided by the database's own code, H2's SQLSTATE
`23505`, never by the exception's class — and the 403 as the method's own return value, a **`ResponseEntity`**: Spring's type for a
whole answer, its status, its headers and its body, as one return value. It measures where the Location's host comes from (the request's
`Host` header), what a ResponseEntity changes in the answer's headers (one with a body is flushed as it is written, so it goes out
chunked, with no `Content-Length`; the bodiless 409 says `Content-Length: 0`), and four ways a
route can say "no such customer" by accident.

**The anchor changes (brief ⚑2, ⚑11).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and
`diff -rq -x target ../c6-tiffinbox after/` is empty at this unit's commit — the next chain unit moves the anchor on. "Before" is
`../c6-unit09/after` — the Jackson lesson's frozen tree, BLUE A's, which `c6-tiffinbox` equalled at 50be3a0. Both trees are read and
copied under `.harness/`, never built in place. The change is one Java file, `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java`
(215 lines → 241):

```java
    @PostMapping("/customers")
    ResponseEntity<Customer> add(@RequestBody Customer customer) throws SQLException {
        try {
            repo.add(customer);
        } catch (SQLException e) {
            if (NAME_TAKEN.equals(e.getSQLState())) {          // "23505": H2's code for a name its unique index already holds
                return ResponseEntity.status(HttpStatus.CONFLICT).build();
            }
            throw e;                                         // 23502, a column left empty - the same exception class - stays a 500
        }
        URI location = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{name}")
                .buildAndExpand(customer.name()).toUri();
        return ResponseEntity.created(location).body(customer);
    }

    @PostMapping("/shutdown")
    ResponseEntity<Map<String, Object>> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token) {
        if (!holdsToken(token)) {                    // the server keeps running
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ordered("error", "forbidden"));
        }
        Thread.ofPlatform().start(context::close);
        return ResponseEntity.ok(ordered("stopping", true));
    }
```

(the two comments on the right are this README's, not the file's) — its imports (`HttpServletResponse` out; `ResponseEntity`,
`ServletUriComponentsBuilder`, `java.net.URI`, `java.sql.SQLException` in), the constant `NAME_TAKEN = "23505"`, and the Javadoc
paragraph and method comments that say how — and the anchor's `README.md`: its unit section, and in place the history notes the change
made false (the 403 by `response.setStatus`, `shutdown(String,HttpServletResponse)` and its resolver, "200 and the record", a taken name's
500, the new customer's 200 in two forms paragraphs, the empty name's 200, the shutdown answer's `Content-Length: 17`) plus the two notes
that still said graceful shutdown "is not what lets it out" (made false by `../c6-unit06/`'s re-made `stop`). The POMs, `application.yaml`,
`CustomerRepository`, the Dockerfile and `compose.yaml` are unchanged — 23 of the tree's 25 files byte for byte — and the jar holds the
same 56 libraries (`entity`).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 7 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`; on OrbStack `orb start` is tried once if it does not), with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native
build per `forms` run (three per receipt); its seconds, and the 20-minute bound, go to the terminal only — a hashed line must not move
with the machine's load. **Start it in a process group of its own** (a terminal's foreground job is one): two receipts started as
background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (brief S2.4).

**Runs of record (2026-10-14/15, this script as committed):** **1,689 s under `bash receipts.sh`** (Homebrew bash 5.3.9, this folder, its
own process group: exit 0, all 7 = published, every check passed; the native builds 448, 374 and 237 s, load averages up to 37, the other
units' video builds running beside it), **1,007 s under `./receipts.sh`** (/bin/bash 3.2.57: exit 0, all 7 = published, every check
passed, no shell error; 145, 151 and 244 s) and **1,729 s from a sealed fresh clone** (`git clone` of tiffinbox-java at 50be3a0, this
unit's and the anchor's 57 files put in as git would take them; `env -i`, a `HOME` of its own whose `.mavenrc` points every Java proxy at a
refusing port, Maven settings sending every repository to a `file://` copy of Central's files made from this unit's `.m2-demo` — 4,372
files — the proxy variables at the same refusing port, `GRAALVM_HOME`, `DOCKER_CONFIG=~/.docker`, `/bin/bash` 3.2, a process group of its
own: exit 0, all 7 = published; **526 artifacts, every one from the `file://` copy**; its first build said `offline: no`, as a fresh
clone's must, and every capture's build `offline: yes`). Before each run in this folder, `.m2-demo` was re-seeded from
`_research/m2-seed-s2/` alone: every build said `offline: yes`. **The first runs** — 977 s under `bash receipts.sh` (it made the published
hashes and stopped on "no published hash", as designed), 1,840 s under `./receipts.sh` and a first sealed clone — reproduced the same seven
hashes, but under /bin/bash 3.2 their checks printed a shell error ("Found on the way"); the script was fixed, and every run above was
made again with it. **The exercise as viewers run it**, beyond the capture: the README's last line alone in an `env -i` `/bin/bash` shell
without the exports — its `java` 23.0.1 — ends with `exit 1` and prints no line (`wait $!` hands back the JVM's exit code), the shell left
in `c6-unit10/`; README then SOLUTION in one `env -i` `zsh -f` shell → `fetch: 000 · got: none`, then `fetch: 200 · got: Sunil K`,
exit 0, the shell in `c6-unit10/`; 19399 free after.

Published hashes: entity `f3be88a8f6cf1d5b161406bbb0d4b4f9` · created `47d313fb1d9fae8142b3bc58399d03c5` · host `b6d96f9264bd660596a95a08b88f98cd` · conflict `3b655558511e10177ec89c3ef28470f1` · statuses `3324c81c4081cd48946da299fa1b18bc` · exercise `0cf643f6316a6b293cab5fc9e96c5e9b` · forms `5904505ab1e7b3efdeb3d7f09faa52ca`.

**BLUE B (2026-10-16), after RED B1 rows 71-80:** `host` gains E (labelled: `--spring.main.cloud-platform=kubernetes` → the
forwarded headers read, `https://kitchen.localhost/customers/Asha`) and Boot's metadata line says "no default value"; `receipts.sh` removes
`KUBERNETES_SERVICE_HOST`/`_PORT` with the other variables; `conflict` pins the JVM's locale on every run line and prints it, and prints the
409's headers (`Content-Length: 0`); `entity` changes only by the anchor README's line counts (10/after's README: the static-files 404,
the forwarded headers, "chunked" scoped to answers with a body). Changed: entity `b967352f…` → `f3be88a8…`, host `7d658053…` → `b6d96f92…`,
conflict `9dbf9e6c…` → `3b655558…`; created, statuses, exercise and forms byte for byte the same. **Runs of record:** `./receipts.sh`
(/bin/bash 3.2.57, `.m2-demo` re-seeded from `_research/m2-seed-s2/`, its own process group, `env -i`) 1,264 s — the seven captures 3/3,
every check passed, then "no published hash" as designed (receipts.md5 emptied first); `bash receipts.sh` (5.3.9, re-seeded) 2,165 s —
exit 0, all 7 = published.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but nine, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.main.cloud-platform=kubernetes
curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Host: kitchen.localhost' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'X-Forwarded-Host: kitchen.localhost' -H 'X-Forwarded-Proto: https' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -o /dev/null -D - -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -o /dev/null -D - -X POST http://127.0.0.1:18431/shutdown
curl -s -o /dev/null -w '%{http_code} · Allow: [%header{allow}]\n' -X OPTIONS http://127.0.0.1:18431/customers
curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:18431/customers/Nobody
javap -c -p -cp tiffinbox-web/target/extracted/lib/spring-webmvc-7.0.9.jar org.springframework.web.servlet.mvc.method.annotation.HttpEntityMethodProcessor org.springframework.web.servlet.mvc.method.annotation.RequestResponseBodyMethodProcessor
```

The first is the anchor's run line with the JVM's locale pinned before `-jar` — asserted to be that line with `-Duser.language=en
-Duser.country=US` added and nothing else — and `conflict` runs every JVM with it: H2 writes its messages in the JVM's locale, and on macOS
the JVM takes the Mac's first language, not `LC_ALL` (measured, RED B1 #72: a JVM started as German prints `NULL nicht zulässig für Feld
"MEAL_TYPE"` before the English line, and `conflict`'s hash and checks would fail). The second is the anchor's run line with Boot told it
runs on Kubernetes (`host` E, labelled). The third is the anchor README's new line (the request-body lesson's POST, its answer's Location
printed) with a `Host` header of the client's (`host` B); the script asserts it is that line with `-H 'Host: kitchen.localhost'` added and
nothing else. The fourth adds the two headers a proxy — a server in front that passes requests on — adds instead (`host` C and E,
labelled), asserted the same way. The fifth and sixth print an answer's status line and headers — the request-body lesson's POST and the
secrets lesson's POST /shutdown without the token, each with `-o /dev/null -D -` for its `-w` and nothing else, asserted (`created`,
`entity`, `conflict`). The seventh asks a path which verbs it takes (`created`, on `/customers` and on a Location). The eighth prints an
answer's status, `Content-Type` and `Content-Length` (`statuses`). The ninth
reads the two return-value handlers' bytecode out of after/'s own `spring-webmvc` jar, from `.harness/after` (`entity`). Every POST a
capture sends is a line of these shapes — `plc` (the anchor's Location line), `lc` (any line of that shape), `pc` (the request-body
lesson's), each with its port, path and body swapped, the body single-quoted as the README writes it.

**`kitchen.localhost`, not `kitchen.example`** (the brief's B): `check_unit6.py` refuses any URL a viewer sees that is not loopback, and
B's answer prints the Location whole; RFC 6761 reserves `.localhost` for loopback names. The Location B gets is printed, never followed:
a last check fails any capture that runs a command with a URL that is not `127.0.0.1`'s.

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script still fills `.m2-demo`, makes the six other captures, each checked against `receipts.md5`,
then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s2/` alone — 5,837 files, no `com/tiffinbox` (a stale install would satisfy `-pl tiffinbox-web
native:compile-no-fork`) — and re-seeded so before each run of record. **Nothing was downloaded** for this unit: every build said
`offline: yes`, the native plugin read its metadata repository from `.m2-demo` (`file:`), and every native build log holds 0 lines of the
plugin's own download (`Downloaded GraalVM reachability metadata repository from http`, `Failed to download from http`). A fresh clone's
`.m2-demo` is empty (git ignores it): the first build — `after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven
Central and says `offline: no`; every capture's build then says `offline: yes`. The install writes `com/tiffinbox` into this unit's
`.m2-demo` — fine here, and never copied into a seed. **Docker:** no pull — `docker build` prints its `load metadata` line and the base
image's digest, and `its lines that say pull: 0`. The image (`tiffinbox-status:1.0.0`) and the container (`tiffinbox-status`) are this
script's own names, checked absent first and removed on every exit; the build cache is not pruned (`.dockerignore` keeps `secrets/` out
of every build context, so it holds no token). **At run time** every request goes to `127.0.0.1`; host B's `kitchen.localhost` is a
header's value, sent to `127.0.0.1`, and the Location it comes back in is never asked.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, mounted read-only into the container (`:ro`), and sent only by `../c5-unit11/curlset.sh` and
`harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so
are the log of every JVM that served (at DEBUG in `entity` too), the container's log (`docker logs`), every file this unit ships, the
binary's bytes, and every blob of the image (`docker save`, each gzip layer unpacked; `forms`): 0 everywhere. The header's name,
`X-Shutdown-Token`, is counted too: 0 in every log. No capture runs at TRACE, so the two loggers `application.yaml` holds at INFO
(`Http11InputBuffer`, `HandlerMethod`) are kept and not re-measured: this change removes a parameter, it adds none. The exercise makes a
token of its own (`openssl rand -hex 13`: 26 hexadecimal digits), counted 0 times in its own log and never printed.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`). `.harness/before`, `.harness/after` — the two trees, copied, each with
  a config tree, built and extracted (`entity`); `.harness/plant` — after/ with the catch's one line testing the exception's class
  (`conflict` C); `.harness/nat` — after/'s native build (`forms`); `.harness/hc` — the harness's classes, compiled against after/'s own
  jar with `-parameters`; `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`), joined by `--spring.main.sources` on
  the extracted jar's class path, each route returning its type (brief S2.15): `harness/probe/web/Statuses.java` — four ways to answer a
  name, each through TiffinBox's own `CustomerRepository.findByName` (an `Optional`): `ResponseEntity.of(…)` (`/probe/statuses/of/{name}`),
  the customer or `null` (`/probe/statuses/null/{name}`), the `Optional` itself (`/probe/statuses/optional/{name}`); a POST with
  `@ResponseStatus(HttpStatus.CREATED)` that answers the body it was given (`/probe/statuses/annotated`); and a POST whose Location is built
  by `fromCurrentRequest()` (`/probe/statuses/where`) — neither stores anything. `harness/shutdown.sh` — POST `/shutdown` with the token
  read from its file (the binding lesson's, copied unchanged): it prints the answer's `Content-Length` too.
- **Ports** (brief ⚑1, 19390-19399): after/'s jar 19390 · the previous tree 19391 · after/ with the harness joined 19392 · the planted
  copy 19393 · the AOT jar 19394 · the image 19397 · the binary 19398 · the exercise 19399; 19395 and 19396 are never bound. 18425
  (TiffinBox's default) and 8080 (Tomcat's) are checked free and never bound on this Mac (18425 only inside the container); a run that
  listens on 8080 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character
   token]` (its length read off the token); the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above → `…/..`; home →
   `~`; the user name, as a whole word → `<user>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`,
   `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line, a log time, an unmasked timestamp, a `GMT` date, a thread
   number, a stack frame, a `sha256:` ID other than the base image's digest, `:8080`, a carriage return, or a command with a URL that is
   not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — both forms — in every answer printed and in the seven, which are hashed after it (two lines changed: `/nowhere`'s
   and GET /shutdown's). **Its form** (`tsform`), where a capture names it: the date and time, every digit → `d`, the zone kept (`Z`).
3. **An answer's headers** (`hdr`): the status line in brackets (Tomcat ends it with a space: no reason phrase), then each header, name
   and value — the `Date` header's value → `…`, the carriage returns curl keeps dropped. Checked on a planted answer before any capture.
4. **The `Allow` header** (`ropt`): its verbs sorted, and `(the verbs sorted)` printed after it — Spring MVC lists them in the order it
   met the matching methods, and that order moved between two runs here (`POST,GET,HEAD,OPTIONS`, then `GET,HEAD,POST,OPTIONS`).
5. **Log lines** (`logl`, `erec`, `dbg`): from their logger on, as the log prints the logger (`o.s.web.servlet.DispatcherServlet`,
   `s.w.s.m.m.a.RequestMappingHandlerMapping`, `m.m.a.RequestResponseBodyMethodProcessor` and `o.s.w.s.m.m.a.HttpEntityMethodProcessor`
   are Spring MVC's; `o.a.c.c.C.[.[.[/].[dispatcherServlet]` Tomcat's; `o.s.boot.*` Boot's — read off the log, never typed); an identity
   hash after `@` → `@…`; in an ERROR record, H2's constraint and index names — the quoted string after `violation: ` — → `"…"`, and the
   record's next line (the SQL statement, H2's error code at its end) is printed, its stack frames bounded ("over 50, not shown"). A
   request's lines are those the log gained between two points where it stopped growing (`wans`, `erec`, `dreq`): each answer's last line
   ends with `· WARN lines it added: N`; at DEBUG (`dreq`) every line it gained is printed, counted.
6. **javap** (`flushes`): the calls to `ServletServerHttpResponse.flush` inside each class's `handleReturnValue`, counted; the bytecode
   itself is not printed.
7. **The native build's lines**: its plugin goals, the GraalVM line, the Java version, each `Warning:` — the file a warning names
   (`in 'file:…'`, or `in 'null'`) → `in '…'` — the eight stages cut after their name, the warnings count and `BUILD SUCCESS`; the rest
   counted, never shown.
8. **`docker build --progress=plain`** through a filter: its `load metadata` line, its `FROM` line (the base image's digest), its naming
   line, step numbers and timings cut (checked on a planted log first); lines that say pull, counted; the rest bounded ("fewer than 300").
9. **Inside the container**: `/proc/net/tcp` and `tcp6`, LISTEN rows only, the address decoded. **On this Mac**: `lsof` by pid (or by
   port, for Docker's forwarder), the address column alone — never a command name (R.18).
10. **A URL that holds a character the shell reads** (`;`, `?`, `&`, `*`, `{`, `}`, a space) is single-quoted on the command line, and
    every JSON body is single-quoted, so the printed command is the one that ran. A Location is followed only when it is on `127.0.0.1`.
11. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the
exercise's shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox JVM,
binary or `native-image` left, removes the container and the image, deletes the capture runs it had not finished (`.r-NAME.1-3`), and
removes `.r-lock`. The published captures are untouched.

**Measured** on this script (2026-10-15), started as a terminal starts its foreground job (SIGINT at its default, a process group of its
own — from a script, `python3 -c 'import os, signal, sys; signal.signal(signal.SIGINT, signal.SIG_DFL); os.setpgrp();
os.execvp(sys.argv[1], sys.argv[1:])' ./receipts.sh`): SIGINT to its process group during the native build (389 s in, native-image's
builder running for 25 s — 5 processes in the group, 2 of them java): **exit 130** 0.3 s later; 5 s later 0 processes in the group and 0
anywhere naming this folder, no image builder left; 19390-19399, 8080 and 18425 free; no container, no image, no `.r-lock`, no unfinished
capture run; the published captures unchanged.

## 1 · entity — the change, and who writes each answer

Both trees copied under `.harness/`, built with the README's line (offline) and extracted; the harness compiled against after/'s jar.
**Two files differ** — `README.md` and `TiffinBoxServer.java` — and 23 of the tree's 25 are byte for byte the previous tree's;
`TiffinBoxServer.java` goes **215 → 241 lines**, its code lines (neither comment nor blank) 116 → 127, and of them, imports left out:
**naming a ResponseEntity 0 → 6, the servlet response (`HttpServletResponse`, `setStatus`) 2 → 0, a SQLSTATE 0 → 1**. The code lines'
`diff -U0`, whole: 10 hunks, 9 lines out, 20 in — `add` returns `ResponseEntity<Customer>` (the try, the SQLSTATE test,
`status(HttpStatus.CONFLICT).build()`, the Location, `created(location).body(customer)`), `shutdown` returns
`ResponseEntity<Map<String, Object>>` (`status(HttpStatus.FORBIDDEN).body(…)`, `ok(…)`), `response.setStatus(403)` out. The jar: 56
libraries, the same names. **The seven**, on a fresh JVM of after/: `87ca7efc…`, the POST line `200 application/json {"stopping":true}`.
Then each tree with Boot's `web` group at DEBUG (the embedded-Tomcat lesson's line): **the same POST** — the request-body lesson's — is
**200 before, 201 after**, six lines each: `Mapped to com.tiffinbox.web.TiffinBoxServer#add(Customer)`, the body read by
`RequestResponseBodyMethodProcessor` on both, and **written by `RequestResponseBodyMethodProcessor` before, by `HttpEntityMethodProcessor`
after**, then `Completed 200 OK` / `Completed 201 CREATED`. **POST /shutdown without the token** is `{"error":"forbidden"} 403` on both —
the same bytes — five lines each: `Mapped to …#shutdown(String, HttpServletResponse)` before, `…#shutdown(String)` after, written by the
same two processors. **Its headers are not the same:** `Content-Length: 21` before, `Transfer-Encoding: chunked` after; and POST /shutdown
with the token, `harness/shutdown.sh`, prints `Content-Length: 17` before and `none` after. **javap**, after/'s `spring-webmvc-7.0.9.jar`:
`HttpEntityMethodProcessor.handleReturnValue` calls `ServletServerHttpResponse.flush` twice, `RequestResponseBodyMethodProcessor`'s never —
an answer with a body, flushed as it is written, is committed before its length is known, so it goes out chunked; the bodiless 409 says
`Content-Length: 0` (`conflict`).

`.r-entity.out` · md5 `f3be88a8f6cf1d5b161406bbb0d4b4f9` · 3 of 3

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
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Statuses.java
  exit 0
the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
  after/'s files: 25 · byte for byte the previous tree's: 23 · those above differ: 2
  TiffinBoxServer.java: 215 lines -> 241 · its lines that are neither comment nor blank: 116 -> 127, of them - imports left out - naming a ResponseEntity: 0 -> 6 · the servlet response (HttpServletResponse, setStatus): 2 -> 0 · a SQLSTATE (getSQLState()): 0 -> 1
  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: 10 · lines out: 9 · in: 20 - whole:
    @@ -3 +2,0 @@
    -import jakarta.servlet.http.HttpServletResponse;
    @@ -6,0 +6 @@
    +import org.springframework.http.ResponseEntity;
    @@ -14,0 +15 @@
    +import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
    @@ -20,0 +22 @@
    +import java.net.URI;
    @@ -22,0 +25 @@
    +import java.sql.SQLException;
    @@ -29,0 +33 @@
    +    private static final String NAME_TAKEN = "23505";
    @@ -58,3 +62,12 @@
    -    Customer add(@RequestBody Customer customer) throws Exception {
    -        repo.add(customer);
    -        return customer;
    +    ResponseEntity<Customer> add(@RequestBody Customer customer) throws SQLException {
    +        try {
    +            repo.add(customer);
    +        } catch (SQLException e) {
    +            if (NAME_TAKEN.equals(e.getSQLState())) {
    +                return ResponseEntity.status(HttpStatus.CONFLICT).build();
    +            }
    +            throw e;
    +        }
    +        URI location = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{name}")
    +                .buildAndExpand(customer.name()).toUri();
    +        return ResponseEntity.created(location).body(customer);
    @@ -84,2 +97 @@
    -    Map<String, Object> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token,
    -                                 HttpServletResponse response) {
    +    ResponseEntity<Map<String, Object>> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token) {
    @@ -87,2 +99 @@
    -            response.setStatus(403);
    -            return ordered("error", "forbidden");
    +            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ordered("error", "forbidden"));
    @@ -91 +102 @@
    -        return ordered("stopping", true);
    +        return ResponseEntity.ok(ordered("stopping", true));
  README.md - the anchor's README: lines added 98, removed 12 - its new section and the history notes the change made false (not shown)
the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes
the seven - after/, the README's run line, port 19390, a fresh JVM:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
before - the previous tree, the README's line with Boot's web group at DEBUG (the embedded-Tomcat lesson's), port 19391 - a new customer, then POST /shutdown without the token:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19391 --logging.level.web=debug
  listens on: 127.0.0.1:19391 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19391/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19391/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 6:
    o.s.web.servlet.DispatcherServlet: POST "/customers", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#add(Customer)
    m.m.a.RequestResponseBodyMethodProcessor: Read "application/json;charset=UTF-8" to [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]
    m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    m.m.a.RequestResponseBodyMethodProcessor: Writing [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]
    o.s.web.servlet.DispatcherServlet: Completed 200 OK
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19391/shutdown
  {"error":"forbidden"} 403
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 5:
    o.s.web.servlet.DispatcherServlet: POST "/shutdown", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#shutdown(String, HttpServletResponse)
    m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    m.m.a.RequestResponseBodyMethodProcessor: Writing [{error=forbidden}]
    o.s.web.servlet.DispatcherServlet: Completed 403 FORBIDDEN
$ curl -s -o /dev/null -D - -X POST http://127.0.0.1:19391/shutdown
  status line: [HTTP/1.1 403 ]
  Content-Type: application/json
  Content-Length: 21
  Date: …
$ harness/shutdown.sh 19391 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19391 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, the same line, port 19390:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390 --logging.level.web=debug
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 6:
    o.s.web.servlet.DispatcherServlet: POST "/customers", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#add(Customer)
    m.m.a.RequestResponseBodyMethodProcessor: Read "application/json;charset=UTF-8" to [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]
    o.s.web.servlet.DispatcherServlet: Completed 201 CREATED
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19390/shutdown
  {"error":"forbidden"} 403
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 5:
    o.s.web.servlet.DispatcherServlet: POST "/shutdown", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#shutdown(String)
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{error=forbidden}]
    o.s.web.servlet.DispatcherServlet: Completed 403 FORBIDDEN
$ curl -s -o /dev/null -D - -X POST http://127.0.0.1:19390/shutdown
  status line: [HTTP/1.1 403 ]
  Content-Type: application/json
  Transfer-Encoding: chunked
  Date: …
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
javap - the two return-value handlers, as after/'s spring-webmvc jar holds them (this unit's line, from .harness/after):
$ cd .harness/after && javap -c -p -cp tiffinbox-web/target/extracted/lib/spring-webmvc-7.0.9.jar org.springframework.web.servlet.mvc.method.annotation.HttpEntityMethodProcessor org.springframework.web.servlet.mvc.method.annotation.RequestResponseBodyMethodProcessor
  exit 0 · in each class's handleReturnValue, the calls to ServletServerHttpResponse.flush - HttpEntityMethodProcessor: 2 · RequestResponseBodyMethodProcessor: 0
```


## 2 · created — 201 and a Location you can follow

After/, the README's run line. **Asha** (the anchor README's new line: the request-body lesson's POST, its answer's Location printed) →
**`201 · Location: [http://127.0.0.1:19390/customers/Asha]`**; the binding lesson's one-customer line with that URL → **200**, Asha.
**Sunil K** → `…/customers/Sunil%20K` — encoded — and that URL → **200**, Sunil K. **OPTIONS** on `/customers` → `Allow: GET,HEAD,OPTIONS,POST`;
on Sunil K's Location → `GET,HEAD,OPTIONS` (the verbs sorted: Spring MVC's order moved between two runs). **A 201's headers** (Ira):
`[HTTP/1.1 201 ]`, `Location`, `Content-Type: application/json`, `Transfer-Encoding: chunked`, `Date` (masked). **The empty name** — the
request-body lesson's body nothing checks — → **201**, its Location `http://127.0.0.1:19390/customers/`, and that URL → **404**: no
mapping takes `/customers/`. `/customers` lists 8 — the seed's four and the four POSTed here. 0 WARN lines throughout.

`.r-created.out` · md5 `47d313fb1d9fae8142b3bc58399d03c5` · 3 of 3

```
after/, the README's run line, port 19390 - a new customer, this unit's line in the anchor's README (its Location printed), then the Location followed:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19390/customers/Asha] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
  a name with a space, the same line - and its Location followed:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19390/customers/Sunil%20K] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/Sunil%20K
  {"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"} 200 · WARN lines it added: 0
  the verbs each path takes - OPTIONS on /customers, then on that Location:
$ curl -s -o /dev/null -w '%{http_code} · Allow: [%header{allow}]\n' -X OPTIONS http://127.0.0.1:19390/customers
  200 · Allow: [GET,HEAD,OPTIONS,POST] (the verbs sorted)
$ curl -s -o /dev/null -w '%{http_code} · Allow: [%header{allow}]\n' -X OPTIONS http://127.0.0.1:19390/customers/Sunil%20K
  200 · Allow: [GET,HEAD,OPTIONS] (the verbs sorted)
  a third name - the answer's status line and headers (this unit's line):
$ curl -s -o /dev/null -D - -H 'Content-Type: application/json' --data '{"name":"Ira","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  status line: [HTTP/1.1 201 ]
  Location: http://127.0.0.1:19390/customers/Ira
  Content-Type: application/json
  Transfer-Encoding: chunked
  Date: …
  a body nothing checks yet - the request-body lesson's empty name - the same line, and its Location followed:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19390/customers
  {"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"} 201 · Location: [http://127.0.0.1:19390/customers/] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/"} 404 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers
  [{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"},{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"},{"name":"Ira","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"},{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"},{"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}] 200 · WARN lines it added: 0
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 3 · host — the Location, and the request's Host header (A/B/A′ + C, D, E)

Boot's metadata (`spring-boot-web-server-4.1.1.jar`) for `server.forward-headers-strategy`: a `ForwardHeadersStrategy`, **no default
value** — unset is not `NONE`: Boot deduces the strategy from the cloud platform it detects (E),
"Strategy for handling X-Forwarded-* headers." **A** — after/, the anchor's Location line: `Location: [http://127.0.0.1:19390/customers/Asha]`,
followed → 200. **B** — this unit's line, the same with `-H 'Host: kitchen.localhost'`, on a fresh JVM: **`Location:
[http://kitchen.localhost/customers/Asha]`** — the Host header's name, no port — printed, never followed; Asha is stored all the same
(`/customers/Asha` → 200 on 127.0.0.1). **A′** — A again on a fresh JVM: **line for line A**. **C** (labelled) — this unit's line with
`X-Forwarded-Host: kitchen.localhost` and `X-Forwarded-Proto: https`: the Location is **unchanged** — the forwarded headers are ignored
**here**, on no cloud platform. **D** (labelled) — the previous tree, the same line: **`200 · Location: []`** — no Location at all. **E**
(labelled) — C's line on after/ started with `--spring.main.cloud-platform=kubernetes`: **`Location: [https://kitchen.localhost/customers/Asha]`**
— on Kubernetes Boot reads the forwarded headers (and so it does when `KUBERNETES_SERVICE_HOST` and `KUBERNETES_SERVICE_PORT` are set, as in
every pod: RED B1 #71's probe; the script removes both from its environment, so C cannot flip under a Kubernetes CI runner). Printed, never
followed.

`.r-host.out` · md5 `b6d96f9264bd660596a95a08b88f98cd` · 3 of 3

```
  Boot's metadata (spring-boot-web-server-4.1.1.jar) - server.forward-headers-strategy · its type: ServerProperties$ForwardHeadersStrategy · no default value · its description: Strategy for handling X-Forwarded-* headers.
A - after/, the README's run line, port 19390 - this unit's line in the anchor's README:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19390/customers/Asha] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - this unit's line: the same with -H 'Host: kitchen.localhost', on a fresh JVM, port 19390 (its Location printed, never followed):
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Host: kitchen.localhost' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://kitchen.localhost/customers/Asha] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19390/customers/Asha] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - this unit's line with -H 'X-Forwarded-Host: kitchen.localhost' -H 'X-Forwarded-Proto: https', on a fresh JVM, port 19390:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'X-Forwarded-Host: kitchen.localhost' -H 'X-Forwarded-Proto: https' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19390/customers/Asha] · WARN lines it added: 0
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
D (labelled) - the previous tree, the README's run line, port 19391 - the same line as A:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19391
  listens on: 127.0.0.1:19391 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19391/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19391/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · Location: [] · WARN lines it added: 0
$ harness/shutdown.sh 19391 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19391 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
E (labelled) - C's line on after/ with Boot told it runs on Kubernetes (the run line with --spring.main.cloud-platform=kubernetes), on a fresh JVM, port 19390 (its Location printed, never followed):
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390 --spring.main.cloud-platform=kubernetes
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'X-Forwarded-Host: kitchen.localhost' -H 'X-Forwarded-Proto: https' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [https://kitchen.localhost/customers/Asha] · WARN lines it added: 0
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 4 · conflict — 409 by the database's code (before/A/C/A′)

Every JVM here starts with the pinned run line, and the capture prints the locale first (`user.language = en`, `user.country = US`): H2's
messages follow the JVM's locale. **Before** — the previous tree: a new name → `200 · Location: []`; Ravi, a name the seed holds → **Boot's 500**, and Tomcat's ERROR line
`… threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: Unique index or primary key
violation: "…"`, H2's code **`[23505-250]`**, a trace of over 50 frames (not shown); the misspelt key (`mealTyp`) → **Boot's 500**, the
**same exception class**, `NULL not allowed for column "MEAL_TYPE"`, **`[23502-250]`**, over 50 frames; 0 WARN, 2 ERROR. **A** — after/:
Asha → 201 and her Location; **Asha again → `409`, no body**, 0 WARN — and again with its headers printed: `[HTTP/1.1 409 ]`,
**`Content-Length: 0`**, not chunked (a bodiless ResponseEntity is not flushed early); **Ravi → `409`**, and `/customers/Ravi` → the seed's Ravi, unchanged
(2 meals at 120, not the posted 1 at 99); the misspelt key → **still H2's 23502, Tomcat's ERROR line, Boot's 500** — and no `Unique index`
line anywhere in A's log; 0 WARN, 1 ERROR. **C** (labelled) — a copy of after/ whose catch tests the exception's class
(`e instanceof java.sql.SQLIntegrityConstraintViolationException`, its one line, `diff -U0`), built the same way: a new name 201, Ravi 409,
**the misspelt key → `409`** — called a conflict — nothing stored (`/customers/Rohan` → 404), and **0 ERROR lines**: the typo's cause is gone
from the log. **A′** — line for line A.

`.r-conflict.out` · md5 `3b655558511e10177ec89c3ef28470f1` · 3 of 3

```
the JVM's locale on this capture's run lines - pinned before -jar, as each line below shows (H2 writes its messages in it):
$ java -Duser.language=en -Duser.country=US -XshowSettings:properties -version
  user.country = US
  user.language = en
before - the previous tree, the pinned run line, port 19391 - a new name, a taken name, a misspelt key, each POSTed with its Location printed:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19391
  listens on: 127.0.0.1:19391 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19391/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19391/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Ravi","mealsPerDay":1,"pricePerMeal":99,"mealType":"VEGAN"}' http://127.0.0.1:19391/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500 · Location: []
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: Unique index or primary key violation: "…"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23505-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19391/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500 · Location: []
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19391 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19391 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A - after/, the pinned run line, port 19390:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19390/customers/Asha] · WARN lines it added: 0
  the same name again, then its status line and headers (this unit's line), then a name the database already had:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
   409 · Location: [] · WARN lines it added: 0
$ curl -s -o /dev/null -D - -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  status line: [HTTP/1.1 409 ]
  Content-Length: 0
  Date: …
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Ravi","mealsPerDay":1,"pricePerMeal":99,"mealType":"VEGAN"}' http://127.0.0.1:19390/customers
   409 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0
  a misspelt key:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19390/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500 · Location: []
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - a copy of after/ whose catch tests the exception's class instead of its SQLSTATE - its one changed line, then built the same way, port 19393:
$ diff -U0 after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java .harness/plant/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
  @@ -146 +146 @@
  -            if (NAME_TAKEN.equals(e.getSQLState())) {
  +            if (e instanceof java.sql.SQLIntegrityConstraintViolationException) {
$ cd .harness/plant && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the planted copy · offline: yes · exit 0
$ cd .harness/plant && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19393
  listens on: 127.0.0.1:19393 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19393/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19393/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19393/customers/Asha] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Ravi","mealsPerDay":1,"pricePerMeal":99,"mealType":"VEGAN"}' http://127.0.0.1:19393/customers
   409 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19393/customers
   409 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19393/customers/Rohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Rohan"} 404 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19393 .harness/plant/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19393 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19390/customers/Asha] · WARN lines it added: 0
  the same name again, then its status line and headers (this unit's line), then a name the database already had:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
   409 · Location: [] · WARN lines it added: 0
$ curl -s -o /dev/null -D - -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  status line: [HTTP/1.1 409 ]
  Content-Length: 0
  Date: …
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Ravi","mealsPerDay":1,"pricePerMeal":99,"mealType":"VEGAN"}' http://127.0.0.1:19390/customers
   409 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0
  a misspelt key:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19390/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500 · Location: []
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```


## 5 · statuses — a name nobody has, four ways; a 201 by annotation; a Location with the query

After/ with the harness's `Statuses` joined; this unit's status, type and length line. **A name nobody has:** TiffinBox's own
`/customers/Nobody` (the binding lesson's `ResponseStatusException`) → **404 and Boot's body**, `application/json`, no `Content-Length`;
`ResponseEntity.of(…)` with the empty `Optional` → **404, no body** (`Content-Length: [0]`, no type); the customer or `null` → **200, no body**
(`Content-Length: [0]`); the `Optional` itself → **200, `null`** (`application/json`, 4 bytes). **Ravi**, the same four → 200 and the record
each — `Content-Length: [67]`, but **`[]` for `ResponseEntity.of`**: a ResponseEntity's answer with a body is flushed as it is written,
so it is chunked (the 404 `ResponseEntity.of` gives for Nobody has no body, and says `Content-Length: [0]`). **`@ResponseStatus(HttpStatus.CREATED)`**
on a POST → **201, `Location: []`**. **A query string on the request:** the harness's route, `fromCurrentRequest()` →
`Location: [http://127.0.0.1:19392/probe/statuses/where/Lata?via=app]` — **the query carried along**; TiffinBox's `POST /customers?via=app`
(`fromCurrentRequestUri()`) → `…/customers/Lata`, followed → 200. 0 WARN, 0 ERROR.

`.r-statuses.out` · md5 `3324c81c4081cd48946da299fa1b18bc` · 3 of 3

```
after/ with the harness's Statuses joined, port 19392 - a name nobody has, then Ravi, asked four ways (this unit's status, type and length line):
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19392 --spring.main.sources=probe.web.Statuses
  listens on: 127.0.0.1:19392 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19392/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:19392/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} · 404 · Content-Type: [application/json] · Content-Length: [] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:19392/probe/statuses/of/Nobody
   · 404 · Content-Type: [] · Content-Length: [0] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:19392/probe/statuses/null/Nobody
   · 200 · Content-Type: [] · Content-Length: [0] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:19392/probe/statuses/optional/Nobody
  null · 200 · Content-Type: [application/json] · Content-Length: [4] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:19392/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · Content-Length: [67] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:19392/probe/statuses/of/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · Content-Length: [] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:19392/probe/statuses/null/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · Content-Length: [67] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}] · Content-Length: [%header{content-length}]\n' http://127.0.0.1:19392/probe/statuses/optional/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · Content-Length: [67] · WARN lines it added: 0
  a 201 by annotation (@ResponseStatus(HttpStatus.CREATED)), POSTed with its Location printed:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}' http://127.0.0.1:19392/probe/statuses/annotated
  {"name":"Lata","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"} 201 · Location: [] · WARN lines it added: 0
  a query string on the request - the harness's route builds its Location with fromCurrentRequest(), TiffinBox's with fromCurrentRequestUri():
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}' 'http://127.0.0.1:19392/probe/statuses/where?via=app'
  {"name":"Lata","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19392/probe/statuses/where/Lata?via=app] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}' 'http://127.0.0.1:19392/customers?via=app'
  {"name":"Lata","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19392/customers/Lata] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19392/customers/Lata
  {"name":"Lata","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"} 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19392 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19392 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 6 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s seven lines, then `SOLUTION.md`'s three, read from the files and run as written, one after the other in ONE shell a
viewer could have (`env -i`, `/bin/bash --noprofile --norc`, started in this folder). As shipped: **`POST: 201 · Location:
http://127.0.0.1:19399/customers/Sunil%20K · fetch: 000 · got: none`** — curl refused the URL with a raw space — the shell back in this
folder, 0 WARN lines, 19399 free; the solution's line (the fetch's URL made `"$l"`, the Location): **`POST: 201 · Location:
http://127.0.0.1:19399/customers/Sunil%20K · fetch: 200 · got: Sunil K`**, the shell in this folder, 0 WARN lines, 19399 free; the copy's
own token 0 times in each log.

`.r-exercise.out` · md5 `0cf643f6316a6b293cab5fc9e96c5e9b` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
  $ (cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19399 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19399/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o /dev/null -H 'Content-Type: application/json' --data '{"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}' http://127.0.0.1:19399/customers; l=$(grep -i '^location:' ../head.txt | sed 's/^[^:]*: *//' | tr -d '\r'); rm -f ../got.json; f=$(curl -s -o ../got.json -w '%{http_code}' 'http://127.0.0.1:19399/customers/Sunil K'); ../../../harness/shutdown.sh 19399 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && g=$(grep -o '"name":"[^"]*"' ../got.json 2> /dev/null | sed 's/^"name":"//; s/"$//') && echo "POST: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · Location: ${l:-none} · fetch: $f · got: ${g:-none}")
  exit 0 · what they printed:
    POST: 201 · Location: http://127.0.0.1:19399/customers/Sunil%20K · fetch: 000 · got: none
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19399 now: 0
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ (cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19399 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19399/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o /dev/null -H 'Content-Type: application/json' --data '{"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}' http://127.0.0.1:19399/customers; l=$(grep -i '^location:' ../head.txt | sed 's/^[^:]*: *//' | tr -d '\r'); rm -f ../got.json; f=$(curl -s -o ../got.json -w '%{http_code}' "$l"); ../../../harness/shutdown.sh 19399 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && g=$(grep -o '"name":"[^"]*"' ../got.json 2> /dev/null | sed 's/^"name":"//; s/"$//') && echo "POST: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · Location: ${l:-none} · fetch: $f · got: ${g:-none}")
  exit 0 · what they printed:
    POST: 201 · Location: http://127.0.0.1:19399/customers/Sunil%20K · fetch: 200 · got: Sunil K
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19399 now: 0
```


## 7 · forms — every form says the same statuses (⚑16, R.40, S2.20)

After/ copied to `.harness/nat`, the README's two Maven lines offline, `$GRAALVM_HOME` naming the GraalVM: **8 of 8 stages, 0 metadata
downloads, offline: yes** (its seconds and the 20-minute bound in the terminal only); a Mach-O binary, 0 token bytes. Spring's AOT metadata
names `com.tiffinbox.Customer` (fields, constructors, 4 methods) — the routes name it, `ResponseEntity<Customer>` among them. Then four
forms, each on a fresh start: **the jar** (19390), **the AOT jar** (19394), **the binary** (19398) — each listening on `127.0.0.1` alone
(read off its pid), Boot's started line, **the seven `87ca7efc…`**, exit 0, the token 0 times in its log; **the image** (after/'s
Dockerfile, the README's build line with this script's tag, 0 pulls, its 11 layers 0 tokens; the README's run line with your user,
published on `127.0.0.1:19397` alone, `[::]:18425` inside) — the seven, `docker wait` 0. On a second start of each: **Asha → 201, a
Location on 127.0.0.1 and that form's own port, followed → 200; Asha again → 409; POST /shutdown without the token → 403** — 4 of 4. In
the image the Location names `127.0.0.1:19397`, the port this Mac published, while TiffinBox listens on 18425 inside: the request's host.

`.r-forms.out` · md5 `5904505ab1e7b3efdeb3d7f09faa52ca` · 3 of 3

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
what Spring's AOT step registered for the native build - the record a route reads and the routes return:
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json): reflection entries naming com.tiffinbox.Customer: 1 - all declared fields · all declared constructors · 4 methods (mealType mealsPerDay name pricePerMeal)
1 the jar - .harness/after, the README's run line, port 19390:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19390 (http) with context path '/'
$ $CURLSET 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then a new customer, the same name again and POST /shutdown without the token, on a second start of the jar:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19390
  listens on: 127.0.0.1:19390 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19390/customers/Asha]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19390/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19390/customers
   409 · Location: []
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19390/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19390 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19390 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19394:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19394
  listens on: 127.0.0.1:19394 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19394/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19394 (http) with context path '/'
$ $CURLSET 19394 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the same three, on a second start of the AOT jar:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19394
  listens on: 127.0.0.1:19394 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19394/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19394/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19394/customers/Asha]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19394/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19394/customers
   409 · Location: []
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19394/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19394 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19394 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19398:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19398
  listens on: 127.0.0.1:19398 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19398/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19398 (http) with context path '/'
$ $CURLSET 19398 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the same three, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19398
  listens on: 127.0.0.1:19398 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19398/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19398/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19398/customers/Asha]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19398/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19398/customers
   409 · Location: []
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19398/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19398 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19398 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19397:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-status:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-status:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-status --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19397:18425 tiffinbox-status:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19397/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19397
  on this Mac, listening on port 19397: 127.0.0.1:19397
$ $CURLSET 19397 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-status
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then the same three, on a second container of the image - TiffinBox listens on 18425 inside it:
$ cd .harness/after && docker run -d --name tiffinbox-status --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19397:18425 tiffinbox-status:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19397/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19397
  on this Mac, listening on port 19397: 127.0.0.1:19397
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19397/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19397/customers/Asha]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19397/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19397/customers
   409 · Location: []
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19397/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19397 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-status
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times
four forms, one tree: the seven (masked) 4 of 4 times 87ca7efc8584dcccd40e6b956db1de9b · a new customer, 201 and a Location on 127.0.0.1 and the form's own port 4 of 4, the Location followed 200 4 of 4 · the same name again 409 4 of 4 · POST /shutdown without the token 403 4 of 4
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
```


## Exercise

**Your turn:** post a customer whose name has a space, then fetch it. The README's fetch fails; use the Location header instead.
`exercise/README.md` has the commands (copy `after/` with a token of its own, build the jar offline); its last line, in a subshell,
starts TiffinBox on 19399, POSTs Sunil K, reads the answer's Location into `l`, fetches the customer by the URL typed with a raw space,
stops TiffinBox, waits for its JVM and prints — as shipped — `POST: 201 · Location: http://127.0.0.1:19399/customers/Sunil%20K · fetch:
000 · got: none` (curl refuses a URL with a raw space: nothing is sent). Done is `POST: 201 · Location:
http://127.0.0.1:19399/customers/Sunil%20K · fetch: 200 · got: Sunil K`. Measured answer: `exercise/solution/SOLUTION.md` (the README's
two `export` lines, then the same line with the fetch's URL made `"$l"`), run in the same shell. Run `./receipts.sh` once first on a
fresh clone.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-14) |
|---|---|---|---|
| 10 | 409 by SQLSTATE 23505; 23502 left at 500 | a JDBC probe only | **a taken name → 409, no body, 0 WARN, 0 ERROR; the misspelt key → H2's 23502, 500; one exception class for both** (`conflict` before, A, A′); **a copy that tests the class answers the misspelt key 409, 0 ERROR** (`conflict` C) |
| 11 | the Location's Host echo and X-Forwarded on 10's tree | s12h | **`Host: kitchen.localhost` → `Location: [http://kitchen.localhost/customers/Asha]`, no port; `X-Forwarded-Host`/`-Proto` ignored here; Boot's `server.forward-headers-strategy` no default value — on Kubernetes they are read (E)** (`host`); **the image's Location names the published 127.0.0.1:19397, TiffinBox listening on 18425 inside** (`forms`) |
| 13 | (for 12) `before` on `10/after`: 201, stored | storage measured with `Unchecked` (200) | **the empty name → 201, its Location `…/customers/` a 404; listed** (`created`) |
| 15 | the image of every chain unit | once, on the chain end | **built from after/'s Dockerfile, 0 pulls, its layers 0 tokens, `127.0.0.1:19397` alone, the seven `87ca7efc…`, 201 + Location, 409, 403, `docker wait` 0** (`forms`) |
| 16 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: fetch `000` (the raw space), then `200`, `Sunil K`** (`exercise`) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **`fromCurrentRequestUri()`, not `fromCurrentRequest()`** (⚑11 named the latter): `fromCurrentRequest()` carries the request's query string
  into the Location — `POST /probe/statuses/where?via=app` → `…/where/Lata?via=app` — so a "correct Location" (the brief's own definition:
  points at the new resource) is built from the request's URI alone: TiffinBox's `POST /customers?via=app` → `…/customers/Lata` (`statuses`).
  Both read the host the same way.
- **A ResponseEntity changes the answer's headers.** Spring MVC's `HttpEntityMethodProcessor` flushes the answer it writes (javap: 2 calls
  to `ServletServerHttpResponse.flush` in its `handleReturnValue`; `RequestResponseBodyMethodProcessor`'s: 0), so an answer with a body goes
  out `Transfer-Encoding: chunked`, with no `Content-Length` — a bodiless one is not: the 409 says `Content-Length: 0` (`conflict`), and so
  does `ResponseEntity.of`'s 404 (`statuses`): the 403's 21 and the shutdown answer's 17 are gone (`entity`), and
  `ResponseEntity.of` for Ravi is chunked where the other routes say 67 (`statuses`). The bytes are the same, and so are the seven
  (`87ca7efc…`): they print status, type and body. Boot's own error body for a name nobody has carries no `Content-Length` either
  (`/customers/Nobody`, `Content-Length: []`, `statuses`).
- **Nothing checks a body yet, and the Location shows it**: the empty name is created, 201, and its Location ends `/customers/` — a path none
  of TiffinBox's routes takes; the static files row (`/**`) does, and finds no file: 404 (`created`). *Validation on the Way In* refuses that body; its `before` is this.
- **"Catching the class would call a misspelt key a conflict"** (⚑11) is a capture now, not an argument (`conflict` C) — and the typo's
  real cause leaves the log with it (`ERROR lines: 0`).
- **`@ResponseStatus(CREATED)`** (⚑11's loser B, unmeasured in the brief): 201, no Location (`statuses`).
- **The Allow header's order moves between runs** (`POST,GET,HEAD,OPTIONS`, then `GET,HEAD,POST,OPTIONS`): sorted in every capture that
  prints it.
- **The 409 has no body** (`ResponseEntity.status(CONFLICT).build()`): one return type for the route; an error body with a reason is *ProblemDetail
  and RFC 9457*'s subject.

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block run alone on copies of the published captures, one line
  changed per plant (`plants.py`, this unit's scratch folder) — **84 plants, 84 stops**, each naming its check; the unplanted copies pass.
  Six of them change a command line in the script and in its README alike, so that the derivation checks alone must stop the run: B and
  C are the anchor's Location line with one header, or two, added and nothing else; the two header lines are the anchor's POSTs with
  `-o /dev/null -D -` for their `-w`; the anchor's Location line is the request-body lesson's POST with the Location printed; the
  exercise's solution is the README's last line with the fetch's URL made `"$l"`. The header filter (`hdr`: a `Date` value, a carriage
  return) and the docker-build filter are shown failing on planted inputs inside the script itself, before any capture.
- **`fromCurrentRequest()` carries the query string into the Location.** Measured on a probe before the anchor changed: the brief's
  builder answered `POST /customers?via=app` with `Location: …/customers/Lata?via=app`. The anchor builds it with `fromCurrentRequestUri()`;
  the harness keeps the other for the comparison (`statuses`).
- **A ResponseEntity's answer goes out chunked.** First seen as `harness/shutdown.sh`'s `Content-Length: none` on after/, where the previous
  tree printed 17; then measured three ways: the 403's headers (`Content-Length: 21` → `Transfer-Encoding: chunked`, `entity`), javap's
  flush calls (2 in `HttpEntityMethodProcessor.handleReturnValue`, 0 in `RequestResponseBodyMethodProcessor`'s), and `ResponseEntity.of`
  for Ravi with no length beside the other routes' 67 (`statuses`).
- **The Allow header's order moves between runs** of the same tree: `POST,GET,HEAD,OPTIONS` in the probe, `GET,HEAD,POST,OPTIONS` in the
  first development run — so `created` prints it sorted (`ropt`) and says so.
- **The empty name's Location is a 404** — found while asking what an unchecked body's 201 looks like (`created`'s last POST): `…/customers/`,
  a path none of TiffinBox's routes takes (the static files row does, and finds no file). It is *Validation on the Way In*'s `before`.
- **Two /bin/bash 3.2 traps**, caught by the checks-only run on the first development captures — under 3.2 alone it stopped at "the 201's
  header line must be …": in `${x/pattern/replacement}` a `/` inside a quoted pattern still ends the pattern, and a quoted replacement keeps
  its quotes inside a quoted expansion. Both derivations put the pattern and the replacement in variables and assign the result.
- **The first run of record stopped 9 s in**, at its pre-build: the harness's file list and a curl prefix were both named `HW`, so `javac`
  was handed curl's options (`error: invalid flag: '`); nothing had started, nothing was left. Renamed (`HDX`, `HWX`); the script's
  top-level names were then listed, and no other is assigned twice by mistake. `.m2-demo` was re-seeded from the seed before the restart.
- **The first runs under /bin/bash 3.2 printed a shell error from the checks** — `./receipts.sh` and the sealed clone both said `command
  substitution: … syntax error near unexpected token 'newline'`, eight lines, then exit 0: the forms check found each form's block with a
  `case` inside `$( )`, which bash 3.2 cannot parse, so the block ran to the capture's end — a weaker check that still passed. Fixed with
  label triples (`'1 the jar:19390:2 the AOT jar'`, …); the checks-only harness now fails on any shell error in its unplanted run; and every
  run of record was made again with the fixed script (below) — the captures, which come before the checks, were byte for byte the same.
- **The anchor README's graceful-shutdown notes.** The embedded-Tomcat section's and the request-mapping section's notes still said graceful
  shutdown "is not what lets it out" after `../c6-unit06/`'s `stop` was re-made with the answer held in flight (graceful: answered every
  run; immediate: none) — corrected in place with this unit's notes, citing that capture.
- **How the hashes were made:** two development passes (a copy of this script running each capture once, `.r-dev.sh`, deleted), then the
  first runs of record: `bash receipts.sh` made the published hashes and stopped on "no published hash", as designed; `./receipts.sh` and a
  sealed clone reproduced every one — and printed the shell error above; then, with the fix, `bash receipts.sh`, `./receipts.sh` and a
  sealed clone again, all = published. `created`, `host`, `conflict`, `exercise` and `forms` are also byte for byte the development
  passes' — so each of those hashes was made by two scripts' runs at different times.

## For units 11 and 12 — and RED

- **Start from `../c6-unit10/after`** (= `../c6-tiffinbox`). `TiffinBoxServer` is still a `final` `@RestController` (never `@Validated`:
  brief S2.19), 241 lines, seven request mappings: `GET /customers` (`@RequestParam(required = false) MealType`), `GET /customers/{name}`
  (a name nobody has → `ResponseStatusException` 404), **`POST /customers`** — `ResponseEntity<Customer> add(@RequestBody Customer customer)
  throws SQLException`: `repo.add`, then **201**, the record and a **`Location`** built by `ServletUriComponentsBuilder.fromCurrentRequestUri()
  .path("/{name}").buildAndExpand(name).toUri()`; a `SQLException` whose `getSQLState()` is **`23505`** (`NAME_TAKEN`) → **409, no body**
  (`ResponseEntity.status(HttpStatus.CONFLICT).build()`); any other `SQLException` is thrown on → Spring MVC's 500 — `/revenue`,
  `/dashboard`, `/kitchen`, and **`POST /shutdown`** — `ResponseEntity<Map<String, Object>> shutdown(@RequestHeader(name =
  "X-Shutdown-Token", required = false) String token)`: 403 `{"error":"forbidden"}` / 200 `{"stopping":true}`, both by return value; no
  route takes `HttpServletResponse` any more. `CustomerRepository` (80 lines), the POMs, `application.yaml` (the Jackson key at 54-56, the
  first `---` at 91, the two TRACE-leak loggers at INFO under `logging:`) and the jar's 56 libraries are 09's, unchanged.
- **The anchor README's line** for a POST is now the request-body lesson's with its Location printed: `curl -s -w ' %{http_code} ·
  Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha",…}' http://127.0.0.1:18431/customers`.
  Its answers: `{…} 201 · Location: [http://127.0.0.1:<port>/customers/Asha]`; a 409 has an empty body, so its line starts with the
  space: `' 409 · Location: []'`. The request-body lesson's line (`-w ' %{http_code}\n'`) is still there and prints `{…} 201`.
- **What a POST does on this tree, measured:** a new name → 201 + Location (`%20` for a space), the Location followed → 200; the same
  name again, or a seed name → 409, 0 WARN, 0 ERROR, the row unchanged; **the empty name** (`{"name":"",…,"mealType":"LUNCH"}`) → **201**, its
  Location `…/customers/` → **404** (none of TiffinBox's routes takes it; the static files row does, and finds no file) — **12's `before`**: nothing checks a body yet; the misspelt key (`mealTyp`) → H2's
  23502, Tomcat's ERROR line, over 50 frames, Boot's 500 — 12's validation should turn it into a field error before the insert; `2.7` →
  400 (09's key). A duplicate is a valid body: after 12's validation it should still reach the unique index and stay a 409 — 12's to
  measure, not measured here.
- **ResponseEntity answers with a body have no `Content-Length`:** `HttpEntityMethodProcessor` flushes them as they are written (javap: 2
  calls in `handleReturnValue`), so the 201, the 403 and POST /shutdown's 200 go out `Transfer-Encoding: chunked`; the bodiless 409 says
  `Content-Length: 0` (`conflict`, its headers captured since BLUE B);
  `harness/shutdown.sh` prints `Content-Length: none` on this tree where 09's printed 17. The GET routes keep their length (`/customers/Ravi`
  67). The seven print no headers: `87ca7efc8584dcccd40e6b956db1de9b` (masked) in all four forms — run them first, on a fresh JVM (S2.11).
- **For 11 (XML on a copy of `10/after`):** a ResponseEntity's body goes through the same message converters — `HttpEntityMethodProcessor`
  writes it with them (`entity`, DEBUG: `Using 'application/json', given [*/*] and supported [application/json, application/*+json]`) — so
  with `jackson-dataformat-xml` on the copy's class path, a POST with `Accept: application/xml` should get its 201 body as XML and the same
  Location: **not measured here**. The 409 has no body, so nothing to negotiate. The Allow header's verbs come in an order that moves between
  runs: sort them (`ropt`, README.md, Masks).
- **For 12 (validation, the next anchor change):** `add` returns `ResponseEntity<Customer>`; a 400 with a `{field: message}` body is
  another body type, so its signature changes again — measure what Spring's AOT step registers for the new return type (here `Customer`
  is registered: by the `@RequestBody` parameter, `GET /customers/{name}` and `ResponseEntity<Customer>`; `forms`, the AOT metadata) and
  keep a record returned by its type (S2.15). Keep the SQLSTATE test for 23505 after the validation; re-measure the misspelt key (23502 →
  a field error) and the empty name (201 → 400) as 12's `before` → `after`. `fromCurrentRequestUri()`, not `fromCurrentRequest()`: the
  latter carries the request's query string into the Location (measured, `statuses`).
- **Hosts on screen:** `check_unit6.py` fails any non-loopback URL a viewer sees — a Location built from a client's `Host` header is one;
  this unit uses `kitchen.localhost` (RFC 6761: loopback), prints it, never follows it, and a last check refuses any captured command whose
  URL is not `127.0.0.1`'s.
- **/bin/bash 3.2, two traps met here:** in `${var/pattern/replacement}` a `/` inside a quoted pattern still ends the pattern, and a quoted
  replacement keeps its quotes when the whole expansion is quoted — put the pattern and the replacement in variables and assign the result
  (`t=${x/"$P"/$R}`). Both were caught by the checks-only run before the first run of record. And a top-level variable name used twice (the
  harness's file list and a curl prefix, both `HW`) killed the first run of record at its pre-build, nothing left: grep the top-level
  assignments before a run.
- **Native:** no hint in the tree; Spring's AOT metadata names `Customer` (fields, constructors, 4 methods); the native builds here took 144,
  151 and 231 s under `bash receipts.sh` (terminal only). The image `tiffinbox-status:1.0.0` and the container `tiffinbox-status` are this
  unit's names — take your own. Ports 19390-19399 are this unit's; 11 has 19400-19409, 12 has 19410-19419.
- **The interrupt test** starts the receipts as a terminal starts its foreground job — `python3 -c 'import os, signal, sys;
  signal.signal(signal.SIGINT, signal.SIG_DFL); os.setpgrp(); os.execvp(sys.argv[1], sys.argv[1:])' ./receipts.sh` — and waits for
  native-image's builder by `vminvocation.args`, never by its main class.
- **The anchor README** got this unit's section, eleven history notes amended in place (each `*(Course 6, unit 10: …)*`), and two corrections
  that were owed since BLUE A re-made the request-mapping lesson's `stop`: the notes in the embedded-Tomcat and request-mapping sections
  that still said graceful shutdown "is not what lets it out" now cite that capture — graceful shutdown is what guarantees the reply. For
  RED: check them against `../c6-unit06/.r-stop.out`.

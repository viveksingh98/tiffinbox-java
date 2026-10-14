# c6-unit09 — Jackson in Spring

Course 6 · Spring Web MVC · Section 2 (Controllers and Binding), its fourth unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), **GraalVM CE 25.3.4.1** (native-image 25.0.4.1),
**Docker on OrbStack**, 2026-10-14. Until this unit a customer POSTed with `"mealsPerDay":2.7` was stored with 2 meals — 200, and not a
word in the log: Jackson's own default reads a number with a decimal point into a whole-number field by dropping the fraction. This unit
reads the JSON mapper Boot built off the running application — one bean, `jacksonJsonMapper`, whose 120 features of eight kinds are all a
plain `JsonMapper`'s — then flips its defaults one at a time (Boot's defaults for Jackson 2, a naming strategy, `@JsonProperty`, a
customizer bean), measures the three differences Core Java II's posted correction names, and changes the one that dropped the fraction.

**The anchor changes (brief ⚑2, ⚑10).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and
`diff -rq -x target ../c6-tiffinbox after/` is empty. "Before" is `../c6-unit08/after` — the request-body lesson's frozen tree, which
`c6-tiffinbox` equalled at 3ff5e21. Both trees are read and copied under `.harness/`, never built in place. The change: one key in
`tiffinbox-web/src/main/resources/application.yaml`'s **first document**, under `spring:`, above the `---` (lines 54-56; the first
`---` is line 84), with four comment lines above it —

```yaml
  jackson:
    deserialization:
      accept-float-as-int: false
```

— and the anchor's `README.md` (its unit section, and the two history notes the change made false: the request-body section's "`2.7`
meals a day is stored as 2", in its text and in its forms paragraph). The POMs, the Java sources, `spring.factories`, the Dockerfile and
`compose.yaml` are unchanged — 23 of the tree's 25 files byte for byte — and the jar holds the same 56 libraries (`float`). Per the brief,
unknown properties stay ignored and a missing `int` stays a 400: both are measured here (`float` A) and kept; refusing unknown properties
is measured too (`custom` B), and turns a misspelt key into Boot's opaque 400.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 10 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`; on OrbStack `orb start` is tried once if it does not), with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native
build per `forms` run (three per receipt), judged against a bound (under 20 minutes); its seconds go to the terminal only. **Start it
in a process group of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a
group, and one run's clean-up would stop the other's JVMs (Section 1's finding, brief S2.4).

**Runs of record (2026-10-14, this script as committed):** **927 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, its own
process group, exit 0, all 10 = published, every check passed; the three native builds 145, 154 and 148 s) and **1,129 s under `bash
receipts.sh`** (Homebrew bash 5.3.9, the same; 190, 213 and 206 s). The hashes were made by one pass of each capture of a development
copy of this script (since deleted), and both runs of record reproduced every one of them 3/3. And **1,087 s from a sealed fresh clone under `./receipts.sh`** (/bin/bash 3.2.57): `git clone` of the local repository (HEAD 3ff5e21) with `c6-unit09` and `c6-tiffinbox` put in from the working tree as git would take them (63 files, 0 differences; the clone's status the same three lines as the repository's) — nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*` — run under `env -i`, with a `HOME` whose `.mavenrc` points Maven's `user.home` there and every Java proxy property at a port that refuses (127.0.0.1:9), and whose Maven settings send every repository to a `file://` copy of Central's files made from `.m2-demo` (4,372 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out, `maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same refusing port; `GRAALVM_HOME` set; `DOCKER_CONFIG=~/.docker`; `PATH` Homebrew's and the system's — the exercise's `env -i` shell got the same; its own process group. Exit 0, all 10 = published, every check passed (native builds 178, 198 and 193 s). One pre-capture build said `offline: no` — after/'s native install, the empty `.m2-demo` holding nothing yet — and every capture's build said `offline: yes`. The clone's `.m2-demo` ended with 526 artifact files (jars, POMs and the metadata zip; TiffinBox's own installs left out), and its `_remote.repositories` entries name one repository, 526 of 526 `sealed` — the `file://` copy — 0 another; the native plugin's metadata download lines: 0; `github` in the run's logs: 15 lines — 14 artifact paths under `com/github/` fetched from the `file://` copy, and native-image's printed link to its own build-output documentation, never fetched. **Interrupted** (below): exit
130, nothing left. **The exercise as viewers run it** is the `exercise` capture itself — `exercise/README.md`, then `SOLUTION.md`, in one
`env -i` `/bin/bash --noprofile --norc` shell, the shell in `c6-unit09/` after each — and, by hand, the same two blocks pasted into one
`env -i` `zsh -f` shell: `exit 1 · its last cause: java.lang.IllegalStateException: Constant named 'snake_case' not found · Ravi's keys: none`, then `exit 0 · its last cause: none · Ravi's keys: name meals_per_day price_per_meal meal_type`, the shell in `c6-unit09/` after each, 19389 free; and `SOLUTION.md` alone in a new `env -i` bash shell, whose bare `java` is 23.0.1: the same Done line (its two `export` lines first).

Published hashes: float `f08cf638c7c4659a2781b9d64d5a9fd9` · bean `f7e490c5d39662adaa3e85ec20f24ad3` · order `7a542be0166a3bdaf9024bec02c45c3b` · defaults `6f3fe38967ed820d36cf5db0b06ce6f7` · naming `d5dffbb22565e401cb71c868f9d91cb9` · rename `611fdf960fb0247dab3e12236435d27a` · custom `9ac43e337e896ffda8dc500144714368` · three `23abe156f9977545f3c37ab1fcde63ef` · exercise `eda8a8107ea9104461c29a8f44e30446` · forms `189197547757f0df221c0ec1583a5d11`.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but four, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.jackson.deserialization.accept-float-as-int=true
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.jackson.use-jackson2-defaults=true
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.jackson.property-naming-strategy=SNAKE_CASE
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.jackson.property-naming-strategy=snake_case
```

The first turns the anchor's key back on for one run (`float` B, and the third start of the AOT jar and of the binary in `forms`); the
second is Boot's switch to the defaults it used with Jackson 2 (`defaults` B, and the seven under it); the third is a naming strategy
(`naming` B) and the fourth the same word in lower case (`naming` C, labelled — and the exercise's broken line); the script asserts the
fourth is the third with the constant's case changed and nothing else. Each option also runs on the harness's class-path line (`hcp`:
the README's class-path line, the harness's classes added, joined by `--spring.main.sources`, the option after). The anchor README's new
line — `curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,…}'
http://127.0.0.1:18431/customers` — is the request-body lesson's POST with the name and the meals changed and nothing else (asserted);
every POST a capture sends is that line's shape (`pc`: its port, its path and its body swapped, the body single-quoted as the README
writes it).

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script still fills `.m2-demo`, makes the nine other captures, each checked against `receipts.md5`,
then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from the previous unit's `.m2-demo`
(`../c6-unit08/.m2-demo`, its `com/tiffinbox` left out: a stale install would satisfy `-pl tiffinbox-web native:compile-no-fork`)
and `../../spring-web-mvc/_research/m2-seed-s2/` — together exactly the S2 seed: 5,837 files, `diff -rq` against it 0 differences,
no `com/tiffinbox`. **Nothing was downloaded** for this unit: every build said `offline: yes`, the native plugin read its metadata
repository from `.m2-demo` (`file:`), and every native build log holds 0 lines of the plugin's own download (`Downloaded GraalVM
reachability metadata repository from http`, `Failed to download from http`). A fresh clone's `.m2-demo` is empty (git ignores it):
the first build — `after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven Central and says `offline: no`; every
capture's build then says `offline: yes`. The install writes `com/tiffinbox` into this unit's `.m2-demo` — fine here, and never copied
into a seed. **Docker:** no pull — `docker build` prints its `load metadata` line and the base image's digest, and `its lines that say
pull: 0`. The image (`tiffinbox-json:1.0.0`) and the container (`tiffinbox-json`) are this script's own names, checked absent first and
removed on every exit; the build cache is not pruned (`.dockerignore` keeps `secrets/` out of every build context, so it holds no token).

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, mounted read-only into the container (`:ro`), and sent only by `../c5-unit11/curlset.sh` and
`harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so
are the log of every JVM that served, the log of every start that failed (`naming` C), the container's log (`docker logs`), every file
this unit ships, the binary's bytes, and every blob of the image (`docker save`, each gzip layer unpacked; `forms`): 0 everywhere. The
exercise makes a token of its own (`openssl rand -hex 13`: 26 hexadecimal digits), counted 0 times in its own log and never printed.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`). `.harness/before`, `.harness/after` — the two trees, copied, each with
  a config tree, built and extracted (`float`); `.harness/plant` — after/ with the key's three lines moved under the second document's
  `spring:` (`float` C); `.harness/nat` — after/'s native build (`forms`); `.harness/hc` — the harness's classes, compiled against after/'s
  own jar with `-parameters`; `.harness/three` — the correction's third difference, compiled (`three`); `.harness/mine` — the exercise's
  copy.
- **The harness** — the course's, never TiffinBox's (package `probe.json`, outside `com.tiffinbox`), each class joined by
  `--spring.main.sources` on the extracted jar's class path, each route returning its type, never `Object` (brief S2.15):
  `harness/probe/json/Mapper.java` (`/probe/mapper`: the beans of type `JsonMapper` and of Jackson 3's `ObjectMapper`; whether the JSON
  converter's mapper is Boot's bean `jacksonJsonMapper`; Actuator's own mapper, its `EndpointJsonMapper`; the modules registered on
  Boot's mapper and on a plain `JsonMapper.builder().build()`; the naming strategy of each; every constant of eight feature kinds —
  `MapperFeature`, `DeserializationFeature`, `SerializationFeature`, `DateTimeFeature`, `EnumFeature`, `JsonNodeFeature`,
  `StreamReadFeature`, `StreamWriteFeature` — read back with `isEnabled` from Boot's mapper and the plain one, and each that differs; the
  eight this lesson names, from all three mappers. `/probe/mapper/all`: every feature of Boot's mapper, one per line, for comparing two
  runs); `harness/probe/json/Order.java` (a record `Plate(zeta, alpha, mid)`, a class `Tray` with the same three public fields, a
  `LinkedHashMap` they are put in in that order, and `com.tiffinbox.Customer`'s components read off the class, beside the same names
  sorted); `harness/probe/json/Rename.java` (a record `Meals(String name, @JsonProperty("meals") int mealsPerDay)`, written and read back);
  `harness/probe/json/Strict.java` (one `JsonMapperBuilderCustomizer` bean: `builder.enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)`);
  `harness/probe/json/Dates.java` (a record `When(LocalDate, LocalDateTime, Duration)` with fixed values, written by Boot's mapper and by a
  plain one, with the plain one's module count); `harness/three/Configure2.java` (Core Java II's `new ObjectMapper().configure(…)` line,
  its imports Jackson 3's — meant not to compile, compiled alone) and `harness/three/Configure3.java` (the same setting on Jackson 3's
  builder); `harness/shutdown.sh` (POST `/shutdown` with the token read from its file — the binding lesson's, copied unchanged).
- **Ports** (brief ⚑1, 19380-19389): after/'s jar 19380 · the previous tree 19381 · after/ with the harness joined 19382 · the AOT jar
  19384 · the image 19387 · the binary 19388 · the exercise 19389; 19383, 19385 and 19386 are never bound. 18425 (TiffinBox's default)
  and 8080 (Tomcat's) are checked free and never bound on this Mac (18425 only inside the container); a run that listens on 8080 is
  killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character
   token]` (its length read off the token); the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above → `…/..`; home →
   `~`; the user name, as a whole word → `<user>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`,
   `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line, a log time, an unmasked timestamp, a thread number, a stack
   frame, a `sha256:` ID other than the base image's digest, `:8080` or a carriage return.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — both forms — in every answer printed and in the seven, which are hashed after it (two lines changed: `/nowhere`'s
   and GET /shutdown's). **Its form** (`tsform`), where a capture names it: every digit of the unmasked timestamp → `d`, each distinct form
   with its count (`"timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2`) — the time itself never reaches a capture.
3. **WARN and ERROR lines** (`logl`, `erec`, `fails`): from their level and logger on, as the log prints the logger
   (`.w.s.m.s.DefaultHandlerExceptionResolver` is Spring MVC's; `o.a.c.c.C.[.[.[/].[dispatcherServlet]` Tomcat's; `o.s.boot.*` Boot's —
   read off the log, never typed); an identity hash after `@` → `@…`; in an ERROR record, H2's constraint and index names — the quoted
   string after `violation: ` — → `"…"`, and the record's next line (the SQL statement, H2's error code at its end) is printed, its stack
   frames bounded ("over 50, not shown"). A request's lines are those the log gained between two points where it stopped growing (`wans`,
   `erec`: each answer's last line ends with `· WARN lines it added: N`, and each such line follows). A failed start (`fails`, `naming` C):
   Boot's failure analysis counted, its stack frames bounded ("over 100, not shown"), its `Caused by:` lines counted and the last one
   printed whole, its WARN and ERROR lines, a WARN cut after the exception's name (`… attempt: <class> …`).
4. **The harness's long answers** (`rqf`): `/probe/mapper` through a declared filter (an extended regular expression, printed) — "N of the
   answer's M lines shown, the other K not". `/probe/mapper/all` is never printed: its 120 lines are saved and compared (`feats`, `fdiff`:
   the count of features whose value differs, then each, A's value → B's).
5. **The YAML** (`code`): its lines that are neither comment nor blank, diffed with `diff -U1` (file names cut); its comment lines counted.
   **Where the key sits** (`kplace`): the top-level key its block is under, its three lines' numbers, the first `---`'s, and "in the first
   document" — yes only when the three follow each other under `spring:`, above that `---`. Shown failing on two planted copies: before any
   capture, the lines moved under `tiffinbox:`; in `float`, under the second document's `spring:` (the profile `rush`'s) — and C runs that
   copy.
6. **Boot's metadata** (`bmeta`): the entry for a key in `spring-boot-jackson-4.1.1.jar`'s `META-INF/spring-configuration-metadata.json`
   (the jar whose metadata declares `spring.jackson.*`) — its type, its default, its description, verbatim.
7. **The native build's lines**: its plugin goals, the GraalVM line, the Java version, each `Warning:` — the file a warning names
   (`in 'file:…'`, or `in 'null'`) → `in '…'` — the eight stages cut after their name, the warnings count and `BUILD SUCCESS`; the rest
   counted, never shown.
8. **`docker build --progress=plain`** through a filter: its `load metadata` line, its `FROM` line (the base image's digest), its naming
   line, step numbers and timings cut (checked on a planted log first); lines that say pull, counted; the rest bounded ("fewer than 300").
9. **Inside the container**: `/proc/net/tcp` and `tcp6`, LISTEN rows only, the address decoded. **On this Mac**: `lsof` by pid (or by
   port, for Docker's forwarder), the address column alone — never a command name (R.18).
10. **A URL that holds a character the shell reads** (`;`, `?`, `&`, `*`, `{`, `}`) is single-quoted on the command line, and every JSON
    body is single-quoted, so the printed command is the one that ran.
11. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes"); in
    `defaults` also their saved feature lists ("0 of 120 differ").

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, `$fpid`, and
the exercise's shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox
JVM, binary or `native-image` left, removes the container and the image, deletes the capture runs it had not finished (`.r-NAME.1-3`),
and removes `.r-lock`. The published captures are untouched.

**Measured** on this script (2026-10-14), started as a terminal starts its foreground job (SIGINT at its default, a process group of its own — from a script, `python3 -c 'import os, signal, sys; signal.signal(signal.SIGINT, signal.SIG_DFL); os.setpgrp(); os.execvp(sys.argv[1], sys.argv[1:])' ./receipts.sh`): SIGINT to its process group during the native build (420 s in, native-image's builder running for 25 s — 5 processes in the group, 2 of them java): **exit 130** 0.2 s later; 5 s later 0 processes in the group and 0 anywhere naming this folder, no image builder left; 19380-19389, 8080 and 18425 free; no container, no image, no `.r-lock`, no unfinished capture run; the published captures unchanged.

## 1 · float — the previous tree against after/, and two point seven meals a day (A/B/C/A′)

Both trees copied under `.harness/`, built with the README's line (offline) and extracted; the harness compiled against after/'s jar.
**Two files differ** — `README.md` and `application.yaml` — and 23 of the tree's 25 are byte for byte the previous tree's; the YAML's
code lines go 47 → 50, **three in, none out**, right after Compose's `enabled: false` and before `logging:`; four comment lines above
them. **Where the key sits** (`kplace`): `jackson:` line 54, under `spring:` (line 23), the first `---` line 84 — **in the first document:
yes**; a planted copy, the three lines moved under the second document's `spring:` (the profile `rush`'s): **no**. Boot's metadata for
`spring.jackson.deserialization`: a map of Jackson's `DeserializationFeature` to a boolean, no default. The jar: 56 libraries, the same
names. **Before** — the previous tree — `"mealsPerDay":2.7` → **200, stored as 2**, 0 WARN, read back with 2. **A** — after/ — **400**,
Boot's body, and one WARN line of Spring MVC's `DefaultHandlerExceptionResolver` with Jackson's reason, ``Cannot coerce Floating-point value
(2.7) to `int` value``; `/customers/Mohan` → 404, nothing stored. With it, one POST each, a name of its own: **`2.0` → 400** and a
**price of `110.5` → 400** (the same reason: the key judges how a number is written); **`"2"` → 200, read as 2**; an unknown property
(`loyaltyPoints`) → **200, ignored**; no `mealsPerDay` → **400** (``Cannot map `null` into type `int` ``: `FAIL_ON_NULL_FOR_PRIMITIVES`,
on); a misspelt key (`mealTyp`) → ignored, so the meal type reaches H2 as `NULL`: **H2's 23502 in Tomcat's ERROR line, Boot's 500**, a
trace of over 50 frames (not shown). 4 WARN lines (one per 400), 1 ERROR. **B** — this unit's line, the key turned back on by a flag →
stored as 2 again. **C** (labelled) — the planted copy, built and run with the README's line: its key below the `---`, **a plain run
stores 2** — S1-R.87's fault, measured. **A′** — A again on a fresh JVM: **line for line A** (`asame`).

`.r-float.out` · md5 `f08cf638c7c4659a2781b9d64d5a9fd9` · 3 of 3

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
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/json/Mapper.java harness/probe/json/Order.java harness/probe/json/Rename.java harness/probe/json/Strict.java harness/probe/json/Dates.java
  exit 0
the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/src/main/resources/application.yaml and .harness/after/tiffinbox-web/src/main/resources/application.yaml differ
  after/'s files: 25 · byte for byte the previous tree's: 23 · those above differ: 2
  application.yaml - its lines that are neither comment nor blank: 47 -> 50 · their diff (diff -U1, its file names cut) - hunks: 1 · lines out: 0 · in: 3 - whole:
    @@ -27,2 +27,5 @@
           enabled: false
    +  jackson:
    +    deserialization:
    +      accept-float-as-int: false
     logging:
  its comment lines: 37 -> 41 · those right above the key: 4 (not shown)
  README.md - the anchor's README: lines added 62, removed 2 - its new section and the history notes the change made false (not shown)
where the key sits - after/'s application.yaml:
  jackson: line 54, under spring: (line 23) · deserialization: line 55 · accept-float-as-int: false line 56 · the first "---" line 84 · in the first document: yes
  a planted copy, the three lines moved under the second document's spring: (the profile rush's): jackson: line 84, under spring: (line 83) · deserialization: line 85 · accept-float-as-int: false line 86 · the first "---" line 81 · in the first document: no
  Boot's metadata (spring-boot-jackson-4.1.1.jar) - spring.jackson.deserialization · its type: java.util.Map<tools.jackson.databind.DeserializationFeature,java.lang.Boolean> · its default: none · its description: Jackson on/off features that affect the way Java objects are deserialized.
the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes
before - the previous tree, the README's run line, port 19381 - two point seven meals a day (this unit's line in the anchor's README):
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19381
  listens on: 127.0.0.1:19381 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19381/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19381/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19381/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ harness/shutdown.sh 19381 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19381 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A - after/, the README's run line, port 19380:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.7) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/customers/Mohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Mohan"} 404 · WARN lines it added: 0
  what the key refuses with it, and what it leaves alone - one POST each, a name of its own:
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Nisha","mealsPerDay":2.0,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.0) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Raj","mealsPerDay":2,"pricePerMeal":110.5,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (110.5) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Om","mealsPerDay":"2","pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"name":"Om","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}' http://127.0.0.1:19380/customers
  {"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Tara","pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot map `null` into type `int` (set `DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES` to 'false' to allow)]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 4 · ERROR lines: 1
$ harness/shutdown.sh 19380 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19380 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - this unit's line: the README's run line with --spring.jackson.deserialization.accept-float-as-int=true, port 19380:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380 --spring.jackson.deserialization.accept-float-as-int=true
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ harness/shutdown.sh 19380 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19380 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - a copy of after/ with the key's three lines under the second document's spring: (the planted copy above: the profile rush's), built the same way, the README's run line, port 19380:
  its application.yaml: jackson: line 84, under spring: (line 83) · deserialization: line 85 · accept-float-as-int: false line 86 · the first "---" line 81 · in the first document: no
$ cd .harness/plant && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the planted copy · offline: yes · exit 0
$ cd .harness/plant && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ harness/shutdown.sh 19380 .harness/plant/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19380 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.7) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/customers/Mohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Mohan"} 404 · WARN lines it added: 0
  what the key refuses with it, and what it leaves alone - one POST each, a name of its own:
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Nisha","mealsPerDay":2.0,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.0) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Raj","mealsPerDay":2,"pricePerMeal":110.5,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (110.5) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Om","mealsPerDay":"2","pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"name":"Om","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}' http://127.0.0.1:19380/customers
  {"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Tara","pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot map `null` into type `int` (set `DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES` to 'false' to allow)]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 4 · ERROR lines: 1
$ harness/shutdown.sh 19380 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19380 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```


## 2 · bean — Boot's mapper, read off the running application

The harness's `Mapper` on each tree's class-path line. **One bean of type `JsonMapper`, `jacksonJsonMapper`**
(`tools.jackson.databind.json.JsonMapper`) — the only bean of Jackson 3's `ObjectMapper` type too; **the JSON converter's mapper is that
very bean**; **Actuator's mapper (`endpointJsonMapper`, an `EndpointJsonMapper`) is another object**; Boot's mapper has **two modules**
registered (`JacksonComponentModule`, `JacksonMixinModule`), a plain `JsonMapper.builder().build()` none; no naming strategy on any.
**120 features read** — every constant of eight kinds (`MapperFeature` 31, `DeserializationFeature` 28, `SerializationFeature` 17,
`DateTimeFeature` 15, `EnumFeature` 9, `JsonNodeFeature` 6, `StreamReadFeature` 7, `StreamWriteFeature` 7) — against the plain mapper:
**before, 0 differ** — Boot's defaults are Jackson 3's own, on Boot 4.1.1; **after, 1 differs**: `ACCEPT_FLOAT_AS_INT`, false on Boot's
mapper, true on the plain one and on Actuator's. The eight this lesson names, from all three mappers: sorting on, creator properties
first, map entries not ordered by key, unknown properties allowed, null for primitives refused, floats accepted as ints (before),
trailing tokens refused, dates not as timestamps. (The format-specific read and write features of the JSON factory are not among the
kinds read.)

`.r-bean.out` · md5 `f7e490c5d39662adaa3e85ec20f24ad3` · 3 of 3

```
before - the previous tree (its application.yaml names no spring.jackson key: Boot's defaults), the README's class-path line with the harness's Mapper joined, port 19381:
$ cd .harness/before && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19381 --spring.main.sources=probe.json.Mapper
  listens on: 127.0.0.1:19381 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19381/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19381/probe/mapper
  beans of type JsonMapper: 1 - jacksonJsonMapper (tools.jackson.databind.json.JsonMapper) · of type ObjectMapper, Jackson 3's: 1 - jacksonJsonMapper
  the JSON converter's mapper (JacksonJsonHttpMessageConverter): Boot's bean jacksonJsonMapper itself: yes
  Actuator's mapper (the bean endpointJsonMapper, an EndpointJsonMapper): Boot's bean itself: no
  modules registered - Boot's mapper: 2 (JacksonComponentModule, JacksonMixinModule) · a plain JsonMapper (JsonMapper.builder().build()): 0
  property naming - Boot's mapper: none · Actuator's: none · a plain one: none
  features read: 120 - every constant of 8 kinds (MapperFeature 31, DeserializationFeature 28, SerializationFeature 17, DateTimeFeature 15, EnumFeature 9, JsonNodeFeature 6, StreamReadFeature 7, StreamWriteFeature 7) · Boot's mapper and a plain one differ in: 0
  the 8 this lesson names - Boot's mapper · a plain one · Actuator's:
    MapperFeature.SORT_PROPERTIES_ALPHABETICALLY: true · true · true
    MapperFeature.SORT_CREATOR_PROPERTIES_FIRST: true · true · true
    SerializationFeature.ORDER_MAP_ENTRIES_BY_KEYS: false · false · false
    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES: false · false · false
    DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES: true · true · true
    DeserializationFeature.ACCEPT_FLOAT_AS_INT: true · true · true
    DeserializationFeature.FAIL_ON_TRAILING_TOKENS: true · true · true
    DateTimeFeature.WRITE_DATES_AS_TIMESTAMPS: false · false · false
   200
$ harness/shutdown.sh 19381 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19381 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, this lesson's key in its application.yaml, the same line, port 19382:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Mapper
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/mapper
  beans of type JsonMapper: 1 - jacksonJsonMapper (tools.jackson.databind.json.JsonMapper) · of type ObjectMapper, Jackson 3's: 1 - jacksonJsonMapper
  the JSON converter's mapper (JacksonJsonHttpMessageConverter): Boot's bean jacksonJsonMapper itself: yes
  Actuator's mapper (the bean endpointJsonMapper, an EndpointJsonMapper): Boot's bean itself: no
  modules registered - Boot's mapper: 2 (JacksonComponentModule, JacksonMixinModule) · a plain JsonMapper (JsonMapper.builder().build()): 0
  property naming - Boot's mapper: none · Actuator's: none · a plain one: none
  features read: 120 - every constant of 8 kinds (MapperFeature 31, DeserializationFeature 28, SerializationFeature 17, DateTimeFeature 15, EnumFeature 9, JsonNodeFeature 6, StreamReadFeature 7, StreamWriteFeature 7) · Boot's mapper and a plain one differ in: 1
    DeserializationFeature.ACCEPT_FLOAT_AS_INT - Boot's mapper: false · a plain one: true
  the 8 this lesson names - Boot's mapper · a plain one · Actuator's:
    MapperFeature.SORT_PROPERTIES_ALPHABETICALLY: true · true · true
    MapperFeature.SORT_CREATOR_PROPERTIES_FIRST: true · true · true
    SerializationFeature.ORDER_MAP_ENTRIES_BY_KEYS: false · false · false
    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES: false · false · false
    DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES: true · true · true
    DeserializationFeature.ACCEPT_FLOAT_AS_INT: false · true · true
    DeserializationFeature.FAIL_ON_TRAILING_TOKENS: true · true · true
    DateTimeFeature.WRITE_DATES_AS_TIMESTAMPS: false · false · false
   200
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 3 · order — the order Jackson writes properties in

The harness's `Order`, after/: a record `Plate(zeta, alpha, mid)` → **`{"zeta":"z","alpha":1,"mid":"m"}`, declared order**; a class
`Tray` with the same three public fields → **`{"alpha":1,"mid":"m","zeta":"z"}`, sorted**; a `LinkedHashMap` they are put in in that
order → **`zeta alpha mid`, its own order**; `com.tiffinbox.Customer`'s components as the record declares them — `name mealsPerDay
pricePerMeal mealType` — beside the same names sorted (`mealType mealsPerDay name pricePerMeal`); `/customers/Ravi` → declared order.
With `bean`'s three switches — `SORT_PROPERTIES_ALPHABETICALLY` true, `SORT_CREATOR_PROPERTIES_FIRST` true (a record's components are its
canonical constructor's parameters, written first, as declared), `ORDER_MAP_ENTRIES_BY_KEYS` false — that is why TiffinBox's JSON, records
and `LinkedHashMap`s, never moved when Jackson 3 began writing it.

`.r-order.out` · md5 `7a542be0166a3bdaf9024bec02c45c3b` · 3 of 3

```
after/ with the harness's Order joined, port 19382 - a record of the harness's own, a class with the same three fields, a map they are put in that order, then TiffinBox's own record:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Order
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/order/record
  {"zeta":"z","alpha":1,"mid":"m"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/order/class
  {"alpha":1,"mid":"m","zeta":"z"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/order/map
  {"zeta":"z","alpha":1,"mid":"m"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/order/customer
  com.tiffinbox.Customer's components, in the order the record declares them: name mealsPerDay pricePerMeal mealType · the same names sorted: mealType mealsPerDay name pricePerMeal
   200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 4 · defaults — Boot's defaults for Jackson 2, by flag (A/B/A′)

Boot's metadata for `spring.jackson.use-jackson2-defaults`: a boolean, **default false**, "Whether to configure Jackson 3 with the same
defaults as Spring Boot previously used for Jackson 2." **A** — after/ with the harness's `Mapper` and `Order`: Boot's 120 features saved
(not printed); the class sorted; no `mealsPerDay` → 400 (``Cannot map `null` into type `int` ``), its timestamp's form `…Z`; text after the
JSON → 400 (``Unrecognized token 'extra'``). **B** — the same with this unit's flag: **13 of the 120 features differ from A's**, each
listed — sorting off, null for primitives allowed, trailing tokens allowed, UTC written as an offset, and nine more; unknown properties,
the key's own feature and dates as numbers do not move. The class keeps its **declared order**; no `mealsPerDay` → **200, stored as 0**,
read back; text after the JSON → **200**; `2.7` → **still 400** — the key in `application.yaml` wins over the flag's defaults; that answer's
timestamp ends **`+dd:dd`**. Then **the seven** under the flag, on a fresh JVM (the README's run line with it): **`87ca7efc…` — the same,
under the timestamp mask**, whose two hidden timestamps end `+dd:dd`: unmasked, the flag changes what TiffinBox's errors say. **A′** —
line for line A, its features 0 of 120 apart from A's.

`.r-defaults.out` · md5 `6f3fe38967ed820d36cf5db0b06ce6f7` · 3 of 3

```
  Boot's metadata (spring-boot-jackson-4.1.1.jar) - spring.jackson.use-jackson2-defaults · its type: java.lang.Boolean · its default: false · its description: Whether to configure Jackson 3 with the same defaults as Spring Boot previously used for Jackson 2.
A - after/ with the harness's Mapper and Order joined, port 19382 - Boot's mapper as this lesson leaves it:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Mapper,probe.json.Order
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/mapper/all
  saved, not shown: 120 features, each one's name and value · its status: 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/order/class
  {"alpha":1,"mid":"m","zeta":"z"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Tara","pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19382/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot map `null` into type `int` (set `DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES` to 'false' to allow)]
  that answer's timestamp, its form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×1
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} extra' http://127.0.0.1:19382/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unrecognized token 'extra': was expecting (JSON String, Number, Array, Object or token 'null', 'true' or 'false')]
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, with this unit's flag on the harness's class-path line: --spring.jackson.use-jackson2-defaults=true, port 19382:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Mapper,probe.json.Order --spring.jackson.use-jackson2-defaults=true
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/mapper/all
  saved, not shown: 120 features, each one's name and value · its status: 200
  features whose value differs from A's: 13 of 120
    MapperFeature.USE_GETTERS_AS_SETTERS: false -> true
    MapperFeature.ALLOW_FINAL_FIELDS_AS_MUTATORS: false -> true
    MapperFeature.DETECT_PARAMETER_NAMES: true -> false
    MapperFeature.SORT_PROPERTIES_ALPHABETICALLY: true -> false
    MapperFeature.FIX_FIELD_NAME_UPPER_CASE_PREFIX: true -> false
    DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES: true -> false
    DeserializationFeature.FAIL_ON_TRAILING_TOKENS: true -> false
    SerializationFeature.FAIL_ON_EMPTY_BEANS: false -> true
    DateTimeFeature.ONE_BASED_MONTHS: true -> false
    DateTimeFeature.WRITE_UTC_AS_OFFSET: false -> true
    EnumFeature.READ_ENUMS_USING_TO_STRING: true -> false
    EnumFeature.WRITE_ENUMS_USING_TO_STRING: true -> false
    JsonNodeFeature.STRIP_TRAILING_BIGDECIMAL_ZEROES: false -> true
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/order/class
  {"zeta":"z","alpha":1,"mid":"m"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Tara","pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19382/customers
  {"name":"Tara","mealsPerDay":0,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/customers/Tara
  {"name":"Tara","mealsPerDay":0,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} extra' http://127.0.0.1:19382/customers
  {"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19382/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.7) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
  that answer's timestamp, its form: "timestamp":"dddd-dd-ddTdd:dd:dd.ddd+dd:dd" ×1
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the seven, on a fresh JVM - this unit's line (the README's run line with the flag), port 19380:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380 --spring.jackson.use-jackson2-defaults=true
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19380 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.ddd+dd:dd" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Mapper,probe.json.Order
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/mapper/all
  saved, not shown: 120 features, each one's name and value · its status: 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/order/class
  {"alpha":1,"mid":"m","zeta":"z"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Tara","pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19382/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot map `null` into type `int` (set `DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES` to 'false' to allow)]
  that answer's timestamp, its form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×1
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} extra' http://127.0.0.1:19382/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unrecognized token 'extra': was expecting (JSON String, Number, Array, Object or token 'null', 'true' or 'false')]
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes · its features against A's: 0 of 120 differ
```


## 5 · naming — a naming strategy (A/B/C/A′)

Boot's metadata for `spring.jackson.property-naming-strategy`: a string, no default, "One of the constants on Jackson's
PropertyNamingStrategies. Can also be a fully-qualified class name of a PropertyNamingStrategy implementation." **A** — the seven on the
README's run line: `87ca7efc…`. **B** — `SNAKE_CASE`: the seven's md5 moves, and **one line differs from A's** — line 1, `/customers`,
its keys `meals_per_day`, `price_per_meal`, `meal_type` (`name` unchanged); `/revenue`, `/dashboard` and `/kitchen` are maps, and keep
their keys; the error bodies too. On the harness's class-path line with the same flag: Boot's mapper's naming `SnakeCaseStrategy`,
**Actuator's none**; the `Rename` record still writes `meals` — an explicit `@JsonProperty` name beats the strategy. **C** (labelled) —
the same word in lower case, `snake_case`: **exit 1**, nothing listened; **no failure analysis** (`APPLICATION FAILED TO START`: 0),
**over 100 stack frames**, 7 `Caused by:` lines, Boot's `Application run failed` at ERROR, and the last cause **`java.lang.IllegalStateException:
Constant named 'snake_case' not found`** — Boot hands the word to Jackson as a constant's name, exactly. **A′** — line for line A.

`.r-naming.out` · md5 `d5dffbb22565e401cb71c868f9d91cb9` · 3 of 3

```
  Boot's metadata (spring-boot-jackson-4.1.1.jar) - spring.jackson.property-naming-strategy · its type: java.lang.String · its default: none · its description: One of the constants on Jackson's PropertyNamingStrategies. Can also be a fully-qualified class name of a PropertyNamingStrategy implementation.
A - after/, the README's run line, port 19380 - the seven:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19380 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - this unit's line: the README's run line with --spring.jackson.property-naming-strategy=SNAKE_CASE, port 19380 - the seven:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380 --spring.jackson.property-naming-strategy=SNAKE_CASE
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19380 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 436e808235dc96197fca4581bc725f7e
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the lines that differ from A's seven: 1 - 1c1:
    < GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
    > GET   /customers  -> 200 application/json  [{"name":"Meera","meals_per_day":1,"price_per_meal":150,"meal_type":"NON_VEG"},{"name":"Priya","meals_per_day":1,"price_per_meal":120,"meal_type":"VEGAN"},{"name":"Ravi","meals_per_day":2,"price_per_meal":120,"meal_type":"VEG"},{"name":"Sunil","meals_per_day":3,"price_per_meal":100,"meal_type":"VEG"}]
  then the same flag on the harness's class-path line, Mapper and Rename joined, port 19382:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Mapper,probe.json.Rename --spring.jackson.property-naming-strategy=SNAKE_CASE
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/mapper
  property naming - Boot's mapper: SnakeCaseStrategy · Actuator's: none · a plain one: none
  features read: 120 - every constant of 8 kinds (MapperFeature 31, DeserializationFeature 28, SerializationFeature 17, DateTimeFeature 15, EnumFeature 9, JsonNodeFeature 6, StreamReadFeature 7, StreamWriteFeature 7) · Boot's mapper and a plain one differ in: 1
  (the filter: lines that match /^property naming|differ in/ - 2 of the answer's 17 lines shown, the other 15 not)
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/rename
  {"name":"Ravi","meals":2} 200
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - this unit's line with the constant in lower case: --spring.jackson.property-naming-strategy=snake_case, port 19380:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380 --spring.jackson.property-naming-strategy=snake_case
  exit 1 · its log, read after it exited - Boot's failure analysis (APPLICATION FAILED TO START): 0 · stack frames: over 100, not shown · Caused by lines: 7
    WARN ConfigServletWebServerApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.UnsatisfiedDependencyException …
    ERROR o.s.boot.SpringApplication: Application run failed
  the last Caused by line: Caused by: java.lang.IllegalStateException: Constant named 'snake_case' not found
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19380 0
A' - A again, on a fresh JVM:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19380 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```


## 6 · rename — @JsonProperty on a record component

The harness's `Rename`: a record `Meals(String name, @JsonProperty("meals") int mealsPerDay)` — the annotation from
`com.fasterxml.jackson.annotation`, the one jar both Jacksons read. Written: **`{"name":"Ravi","meals":2}`**. Read: `{"meals":3}` →
**3**, 0 WARN. Its Java name, `{"mealsPerDay":3}` → **400**, one WARN line, ``Cannot map `null` into type `int` ``: `mealsPerDay` is now an
unknown property — ignored — and `meals`, the int, is missing.

`.r-rename.out` · md5 `611fdf960fb0247dab3e12236435d27a` · 3 of 3

```
after/ with the harness's Rename joined - a record of its own, Meals(String name, @JsonProperty("meals") int mealsPerDay) - port 19382:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Rename
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/rename
  {"name":"Ravi","meals":2} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Ravi","meals":3}' http://127.0.0.1:19382/probe/rename
  {"name":"Ravi","meals":3} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Ravi","mealsPerDay":3}' http://127.0.0.1:19382/probe/rename
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/rename"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot map `null` into type `int` (set `DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES` to 'false' to allow)]
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 7 · custom — a JsonMapperBuilderCustomizer bean (A/B/A′)

**A** — after/ with the harness's `Mapper`: one feature differs from a plain mapper's (the key's); `FAIL_ON_UNKNOWN_PROPERTIES` false on
Boot's, the plain one's and Actuator's; `loyaltyPoints` → 200, dropped; the misspelt `mealTyp` → H2's 23502, 500. **B** — the harness's
`Strict` joined too, one `JsonMapperBuilderCustomizer` bean (`builder.enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)`): **two
features differ** now; `FAIL_ON_UNKNOWN_PROPERTIES` **true on Boot's mapper, false on the plain one and on Actuator's** — a customizer
shapes Spring's mapper, not Actuator's (`bean`: Actuator's `endpointJsonMapper` is another object); `loyaltyPoints` → **400**, one WARN line, `Unrecognized property "loyaltyPoints" (class com.tiffinbox.Customer),
not marked as ignorable`; the misspelt `mealTyp` → **400** the same way, not H2's 500; `/customers/Rohan` → 404, nothing stored. The
reason is only in the WARN line — Boot's body names none — which is why the anchor keeps unknown properties ignored (⚑10, its loser C).
**A′** — line for line A.

`.r-custom.out` · md5 `9ac43e337e896ffda8dc500144714368` · 3 of 3

```
A - after/ with the harness's Mapper joined, port 19382:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Mapper
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/mapper
  features read: 120 - every constant of 8 kinds (MapperFeature 31, DeserializationFeature 28, SerializationFeature 17, DateTimeFeature 15, EnumFeature 9, JsonNodeFeature 6, StreamReadFeature 7, StreamWriteFeature 7) · Boot's mapper and a plain one differ in: 1
    DeserializationFeature.ACCEPT_FLOAT_AS_INT - Boot's mapper: false · a plain one: true
    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES: false · false · false
  (the filter: lines that match /^features read|^  DeserializationFeature\.FAIL_ON_UNKNOWN_PROPERTIES|^  [A-Za-z]+\.[A-Z_]+ - Boot/ - 3 of the answer's 17 lines shown, the other 14 not)
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}' http://127.0.0.1:19382/customers
  {"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19382/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the harness's Strict joined too (a JsonMapperBuilderCustomizer bean: builder.enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)), port 19382:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Mapper,probe.json.Strict
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/mapper
  features read: 120 - every constant of 8 kinds (MapperFeature 31, DeserializationFeature 28, SerializationFeature 17, DateTimeFeature 15, EnumFeature 9, JsonNodeFeature 6, StreamReadFeature 7, StreamWriteFeature 7) · Boot's mapper and a plain one differ in: 2
    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES - Boot's mapper: true · a plain one: false
    DeserializationFeature.ACCEPT_FLOAT_AS_INT - Boot's mapper: false · a plain one: true
    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES: true · false · false
  (the filter: lines that match /^features read|^  DeserializationFeature\.FAIL_ON_UNKNOWN_PROPERTIES|^  [A-Za-z]+\.[A-Z_]+ - Boot/ - 4 of the answer's 18 lines shown, the other 14 not)
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}' http://127.0.0.1:19382/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unrecognized property "loyaltyPoints" (class com.tiffinbox.Customer), not marked as ignorable]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19382/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unrecognized property "mealTyp" (class com.tiffinbox.Customer), not marked as ignorable]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/customers/Rohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Rohan"} 404 · WARN lines it added: 0
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Mapper
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/mapper
  features read: 120 - every constant of 8 kinds (MapperFeature 31, DeserializationFeature 28, SerializationFeature 17, DateTimeFeature 15, EnumFeature 9, JsonNodeFeature 6, StreamReadFeature 7, StreamWriteFeature 7) · Boot's mapper and a plain one differ in: 1
    DeserializationFeature.ACCEPT_FLOAT_AS_INT - Boot's mapper: false · a plain one: true
    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES: false · false · false
  (the filter: lines that match /^features read|^  DeserializationFeature\.FAIL_ON_UNKNOWN_PROPERTIES|^  [A-Za-z]+\.[A-Z_]+ - Boot/ - 3 of the answer's 17 lines shown, the other 14 not)
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}' http://127.0.0.1:19382/customers
  {"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19382/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```


## 8 · three — the correction's three differences, on Spring's mapper

The correction posted under Core Java II's Jackson video names three things that work differently on Boot 4.1's Jackson 3 (its text read
from `c2u29_correction.py` by the builder): "unknown properties no longer fail by default", `ObjectMapper.configure(DeserializationFeature,
...)` "no longer compiles", "java.time dates need no extra module". After/ with the harness's `Dates`: **1** — `loyaltyPoints`, Core Java
II's own unknown field, in a new customer → **200, dropped**, 0 WARN; **2** — `When(LocalDate, LocalDateTime, Duration)` written by Boot's
mapper → **`{"day":"2026-10-14","at":"2026-10-14T12:30:00","took":"PT25M"}`**, and by a plain `JsonMapper` → the same, **0 modules
registered on it**; **3** — Core Java II's line (`harness/three/Configure2.java`: `new ObjectMapper().configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES,
false)`, Jackson 3's imports) compiled against after/'s jar → **exit 1, `cannot find symbol … method configure(DeserializationFeature,boolean)
… location: class ObjectMapper`**; the same setting on Jackson 3's builder (`Configure3.java`) compiles, and prints `false`. All three agree
with the posted comment: no new comment is needed (ledger C6-30).

`.r-three.out` · md5 `23abe156f9977545f3c37ab1fcde63ef` · 3 of 3

```
the three differences the correction comment names, on Spring's mapper - after/ with the harness's Dates joined, port 19382:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19382 --spring.main.sources=probe.json.Dates
  listens on: 127.0.0.1:19382 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/actuator/health/readiness
  {"status":"UP"} 200
1 an unknown property - Core Java II's own unknown field, loyaltyPoints, in a new customer:
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}' http://127.0.0.1:19382/customers
  {"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
2 java.time with no module registered - the harness's Dates.When(LocalDate, LocalDateTime, Duration), written by Boot's mapper (Spring MVC's converter), then by a plain JsonMapper:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/dates
  {"day":"2026-10-14","at":"2026-10-14T12:30:00","took":"PT25M"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19382/probe/dates/plain
  {"day":"2026-10-14","at":"2026-10-14T12:30:00","took":"PT25M"} · modules registered on it: 0
   200
$ harness/shutdown.sh 19382 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19382 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 Core Java II's line, as that lesson wrote it (harness/three/Configure2.java, its two lines):
    14:        ObjectMapper lenient = new ObjectMapper()
    15-                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
$ javac -d .harness/three -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/three/Configure2.java
  exit 1 · what it printed:
    harness/three/Configure2.java:15: error: cannot find symbol
                    .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
                    ^
      symbol:   method configure(DeserializationFeature,boolean)
      location: class ObjectMapper
    1 error
  and Jackson 3's way - its builder (harness/three/Configure3.java, its three lines):
    12:        JsonMapper lenient = JsonMapper.builder()
    13-                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
    14-                .build();
$ javac -d .harness/three -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/three/Configure3.java
  exit 0 · what it printed: 0 lines
$ java -cp ".harness/three:.harness/after/tiffinbox-web/target/extracted/lib/*" probe.three.Configure3
  exit 0 · what it printed: false
```


## 9 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s seven lines, then `SOLUTION.md`'s three, read from the files and run as written, one after the other in ONE shell a
viewer could have (`env -i`, `/bin/bash --noprofile --norc`, started in this folder). As shipped: **`exit 1 · its last cause:
java.lang.IllegalStateException: Constant named 'snake_case' not found · Ravi's keys: none`**, the shell back in this folder, 19389 free;
the solution's line (`SNAKE_CASE`): **`exit 0 · its last cause: none · Ravi's keys: name meals_per_day price_per_meal meal_type`**, the shell
in this folder, 0 WARN lines, 19389 free; the copy's own token 0 times in each log.

`.r-exercise.out` · md5 `eda8a8107ea9104461c29a8f44e30446` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
  $ (cd .harness/mine/after && rm -f ../ravi.json && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19389 --spring.jackson.property-naming-strategy=snake_case > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19389/actuator/health/readiness)" = 200 ] && break; kill -0 $! 2> /dev/null || break; sleep 0.25; done; curl -s -o ../ravi.json http://127.0.0.1:19389/customers/Ravi; ../../../harness/shutdown.sh 19389 secrets/tiffinbox/shutdown-token > /dev/null; wait $!; e=$?; k=$(grep -o '"[A-Za-z_]*":' ../ravi.json 2> /dev/null | tr -d '":' | paste -sd' ' -); c=$(grep '^Caused by: ' ../run.log | tail -1 | sed 's/^Caused by: //'); echo "exit $e · its last cause: ${c:-none} · Ravi's keys: ${k:-none}")
  exit 0 · what they printed:
    exit 1 · its last cause: java.lang.IllegalStateException: Constant named 'snake_case' not found · Ravi's keys: none
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · listening on 19389 now: 0
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ (cd .harness/mine/after && rm -f ../ravi.json && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19389 --spring.jackson.property-naming-strategy=SNAKE_CASE > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19389/actuator/health/readiness)" = 200 ] && break; kill -0 $! 2> /dev/null || break; sleep 0.25; done; curl -s -o ../ravi.json http://127.0.0.1:19389/customers/Ravi; ../../../harness/shutdown.sh 19389 secrets/tiffinbox/shutdown-token > /dev/null; wait $!; e=$?; k=$(grep -o '"[A-Za-z_]*":' ../ravi.json 2> /dev/null | tr -d '":' | paste -sd' ' -); c=$(grep '^Caused by: ' ../run.log | tail -1 | sed 's/^Caused by: //'); echo "exit $e · its last cause: ${c:-none} · Ravi's keys: ${k:-none}")
  exit 0 · what they printed:
    exit 0 · its last cause: none · Ravi's keys: name meals_per_day price_per_meal meal_type
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19389 now: 0
```


## 10 · forms — every form follows the key (⚑16, R.40, S2.20)

After/ copied to `.harness/nat`, the README's two Maven lines offline, `$GRAALVM_HOME` naming the GraalVM: **8 of 8 stages, under 20
minutes, 0 metadata downloads, offline: yes**; a Mach-O binary, 0 token bytes. Spring's AOT metadata names `com.tiffinbox.Customer`
(fields, constructors, 4 methods); the key sits in the first document of the YAML the native build read. Then four forms, each on a fresh
start: **the jar** (19380), **the AOT jar** (19384), **the binary** (19388) — each listening on `127.0.0.1` alone (read off its pid),
Boot's started line, **the seven `87ca7efc…`**, exit 0, the token 0 times in its log; **the image** (after/'s Dockerfile, the README's
build line with this script's tag, 0 pulls, its 11 layers 0 tokens; the README's run line with your user, published on `127.0.0.1:19387`
alone, `[::]:18425` inside) — the seven, `docker wait` 0. On a second start of each: a new customer → 200 and read back; **two point seven
meals → 400, then 404 — refused in all four**. On a third start of the AOT jar and of the binary, this unit's flag: **stored as 2** —
Boot reads `spring.jackson.*` when TiffinBox starts, under Spring's AOT step too.

`.r-forms.out` · md5 `189197547757f0df221c0ec1583a5d11` · 3 of 3

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
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: under 20 minutes · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
what Spring's AOT step registered for the native build - the record a route reads and the routes return:
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json): reflection entries naming com.tiffinbox.Customer: 1 - all declared fields · all declared constructors · 4 methods (mealType mealsPerDay name pricePerMeal)
  the key, in the application.yaml the native build read (.harness/nat's): in the first document: yes
1 the jar - .harness/after, the README's run line, port 19380:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19380 (http) with context path '/'
$ $CURLSET 19380 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then a new customer and two point seven meals, on a second start of the jar:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19380
  listens on: 127.0.0.1:19380 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19380/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19380/customers/Mohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Mohan"} 404
$ harness/shutdown.sh 19380 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19380 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19384:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19384
  listens on: 127.0.0.1:19384 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19384/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19384 (http) with context path '/'
$ $CURLSET 19384 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then a new customer and two point seven meals, on a second start of the AOT jar:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19384
  listens on: 127.0.0.1:19384 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19384/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19384/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19384/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19384/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19384/customers/Mohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Mohan"} 404
$ harness/shutdown.sh 19384 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19384 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  and on a third, the key turned back on by this unit's flag:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19384 --spring.jackson.deserialization.accept-float-as-int=true
  listens on: 127.0.0.1:19384 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19384/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19384/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19384/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ harness/shutdown.sh 19384 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19384 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19388:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19388
  listens on: 127.0.0.1:19388 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19388/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19388 (http) with context path '/'
$ $CURLSET 19388 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then a new customer and two point seven meals, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19388
  listens on: 127.0.0.1:19388 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19388/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19388/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19388/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19388/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19388/customers/Mohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Mohan"} 404
$ harness/shutdown.sh 19388 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19388 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  and on a third, the key turned back on by this unit's flag:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19388 --spring.jackson.deserialization.accept-float-as-int=true
  listens on: 127.0.0.1:19388 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19388/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19388/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19388/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ harness/shutdown.sh 19388 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19388 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19387:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-json:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-json:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-json --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19387:18425 tiffinbox-json:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19387/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19387
  on this Mac, listening on port 19387: 127.0.0.1:19387
$ $CURLSET 19387 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-json
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then a new customer and two point seven meals, on a second container of the image:
$ cd .harness/after && docker run -d --name tiffinbox-json --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19387:18425 tiffinbox-json:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19387/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19387
  on this Mac, listening on port 19387: 127.0.0.1:19387
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19387/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19387/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19387/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19387/customers/Mohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Mohan"} 404
$ harness/shutdown.sh 19387 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-json
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times
four forms, one tree: the seven (masked) 4 of 4 times 87ca7efc8584dcccd40e6b956db1de9b · a new customer (POSTed, then read back) 8 of 8 · two point seven meals refused 4 of 4, then not found 4 of 4 · the key turned back on by the flag, two point seven stored as 2 4 of 4 (the AOT jar and the binary, POSTed, then read back)
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
```


## Exercise

**Your turn:** the README's run should write snake-case keys but never starts. Read the last cause, fix the value, name the changed
keys. `exercise/README.md` has the commands (copy `after/` with a token of its own, build the jar offline); its last line, in a
subshell, starts TiffinBox on 19389 with `--spring.jackson.property-naming-strategy=snake_case`, asks for Ravi, stops TiffinBox, waits
for its JVM and prints — as shipped — `exit 1 · its last cause: java.lang.IllegalStateException: Constant named 'snake_case' not found ·
Ravi's keys: none`. Done is `exit 0 · its last cause: none · Ravi's keys: name meals_per_day price_per_meal meal_type`, and the three
changed keys named (`mealsPerDay`, `pricePerMeal`, `mealType`). Measured answer: `exercise/solution/SOLUTION.md` (the README's two
`export` lines, then the same line with `SNAKE_CASE`), run in the same shell. Run `./receipts.sh` once first on a fresh clone.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-14) |
|---|---|---|---|
| 9 | 09's key **in YAML**, its line number against the `---`, in all four forms | as a flag, on the JVM jar, the AOT jar and the binary | **in the first document, line 56 against the `---` at 84** (`float`; two planted copies caught, one run: C stores 2); **`2.7` → 400 in the jar, the AOT jar, the binary and the image** (`forms`), and the flag turns it back on in the AOT jar and the binary (read at start) |
| 15 | the image of every chain unit | once, on the chain end | **built from after/'s Dockerfile, 0 pulls, its layers 0 tokens, `127.0.0.1:19387` alone, the seven `87ca7efc…`, a new customer, `2.7` refused, `docker wait` 0** (`forms`) |
| 16 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: exit 1 and the last cause, then `meals_per_day price_per_meal meal_type`** (`exercise`) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **`use-jackson2-defaults` flips 13 features, not three** (the brief's READ FIRST 7 and its hazard "say only those three"). The probe read
  seven features; this unit reads all 120 of eight kinds, and 13 change: `USE_GETTERS_AS_SETTERS`, `ALLOW_FINAL_FIELDS_AS_MUTATORS`,
  `DETECT_PARAMETER_NAMES`, `SORT_PROPERTIES_ALPHABETICALLY`, `FIX_FIELD_NAME_UPPER_CASE_PREFIX`, `FAIL_ON_NULL_FOR_PRIMITIVES`,
  `FAIL_ON_TRAILING_TOKENS`, `FAIL_ON_EMPTY_BEANS`, `ONE_BASED_MONTHS`, `WRITE_UTC_AS_OFFSET`, `READ_ENUMS_USING_TO_STRING`,
  `WRITE_ENUMS_USING_TO_STRING`, `STRIP_TRAILING_BIGDECIMAL_ZEROES` (`defaults` B). Unknown properties, the key's own feature and dates as
  numbers do not. The voice says thirteen, and shows four.
- **The flag changes what TiffinBox answers**: an error body's timestamp ends `+00:00` instead of `Z` (`WRITE_UTC_AS_OFFSET`). The seven
  match only under the timestamp mask (`87ca7efc…` both ways); said so.
- **"A Jackson 3 mapper with defaults of its own"** (the brief's spine): Boot's mapper equals `JsonMapper.builder().build()` on all 120
  features read (`bean` before) — Boot adds two modules (`JacksonComponentModule`, `JacksonMixinModule`) and no feature. Boot's defaults
  here are Jackson 3's own; the voice says so, scoped "on Boot four point one".
- **The key judges how a number is written**: `2.0` is refused too; a whole number sent as text, `"2"`, is still read (`float` A). So a
  client that writes `2.0` for an `int` gets a 400 here.
- **`spring.jackson.*` is read when TiffinBox starts, under AOT too**: a run-time flag on the AOT jar and the binary changes the feature
  (`forms`), unlike `spring.threads.virtual.enabled` (fixed at build, Section 1's finding).

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block run alone on copies of the published captures, one line
  changed per plant (`plants.py`, this unit's scratch folder) — **77 plants, 77 stops**, each naming its check; the unplanted copies pass. The YAML's place
  check is shown failing inside the run itself: on a planted copy before any capture (the key under `tiffinbox:`) and in `float` (under the
  second document's `spring:`, which C also runs). The exercise's `SOLUTION.md` export checks are the request-mapping lesson's, verbatim
  (shown failing there).
- **`use-jackson2-defaults` flips 13 features, not 3.** The brief, from the probe's seven features, said three and asked for those three
  alone; reading all 120 of eight kinds (`/probe/mapper/all`, A against B) finds thirteen. Boot's own code (its
  `JacksonAutoConfiguration`) calls Jackson's `MapperBuilder.configureForJackson2()` and then switches four features back off (javap,
  while probing; the capture is the 13). The voice says thirteen and shows four; the README lists all 13.
- **Boot's defaults are Jackson 3's.** Against a plain `JsonMapper.builder().build()`, Boot's `jacksonJsonMapper` differs in 0 of the 120
  features on the previous tree: the request-body lesson's finding about one feature (`FAIL_ON_UNKNOWN_PROPERTIES`) holds for every
  feature read. Boot adds two modules, no feature.
- **The flag reaches TiffinBox's answers through its errors.** Under `use-jackson2-defaults` an error body's timestamp ends `+00:00`, not
  `Z` (`WRITE_UTC_AS_OFFSET`): the seven still hash to `87ca7efc…`, but only under the timestamp mask — said on screen.
- **`2.0` is refused too.** `ACCEPT_FLOAT_AS_INT` off refuses a number written with a decimal point, whatever its value; `"2"` — a whole
  number as text — is still read. A client that writes `2.0` for an `int` gets a 400 from the anchor now.
- **The key is read at start under AOT.** The AOT jar and the binary refuse `2.7` with the key, and store 2 with this unit's flag on a third
  start (`forms`): `spring.jackson.*` is bound when TiffinBox starts, unlike `spring.threads.virtual.enabled`, which Spring's AOT step fixes
  at build (Section 1).
- **The first run of record died before it began:** `receipts.sh` had been written without its execute bit, and `./receipts.sh` answered
  `Permission denied` (nothing started, nothing left). `chmod +x`; the runs of record are of the executable script.
- **The anchor README's history notes** — two, each amended in place (*Course 6, unit 09*): the request-body section's "**`2.7` meals a day
  is stored as 2**" and its forms paragraph's "`2.7` meals stored as 2". Grepped for `2.7`, `stored as 2`, `accept-float`, `spring.jackson`,
  `first document`, `application.yaml` and `Jackson`: no other note is made false by one key in the YAML.
- **How the hashes were made:** one pass of each capture by a development copy of this script (one run each, `.r-dev.sh`, deleted), its
  md5s published, then reproduced 3/3 by the runs of record — so each published hash was made by two scripts' runs at different times.

## For unit 10 — and RED

- **Start from `../c6-unit09/after`** (= `../c6-tiffinbox`). The Java sources are 08's: `TiffinBoxServer` is a `final` `@RestController`
  (never `@Validated` on it: brief S2.19) with seven request mappings — `GET /customers` (`@RequestParam(required = false) MealType`),
  `GET /customers/{name}` (a name nobody has → `ResponseStatusException` 404), **`POST /customers`** (`Customer add(@RequestBody Customer
  customer)`: `repo.add(customer)`, then `return customer` — 200 and the record), `/revenue`, `/dashboard`, `/kitchen`
  (`Map<String, Object>`, `LinkedHashMap`s), `POST /shutdown` (`@RequestHeader(name = "X-Shutdown-Token", required = false)`, the 403 by
  `response.setStatus(403)`). `TiffinBoxServer.java` 215 lines, `CustomerRepository.java` 80; the jar's 56 libraries.
- **`application.yaml`'s first document holds `spring.jackson.deserialization.accept-float-as-int: false`** — lines 54-56, under
  `spring:`, the first `---` at line 84, four comment lines above it. A unit that edits the YAML above line 84 re-checks where the key
  sits (`kplace` here; S1-R.87): a copy with the key under the second document's `spring:` stores 2.7 as 2 on a plain run (`float` C).
- **What a POST does on this tree, measured:** the request-body lesson's Asha → 200 and the record; `2.7`, `2.0`, a price of `110.5` → 400
  + 1 WARN each (``Cannot coerce Floating-point value (…) to `int` value``), nothing stored; `"2"` → 2; an unknown property → ignored;
  no `mealsPerDay` → 400 + 1 WARN; a misspelt key (`mealTyp`) → ignored, H2's 23502, Tomcat's ERROR line, Boot's 500, over 50 frames. A
  taken name is 23505, a 500 — the request-body lesson's measurement, not re-run here. 10's 409 by SQLSTATE 23505 leaves 23502 at 500
  (the brief's ⚑11).
- **The seven are unchanged: `87ca7efc8584dcccd40e6b956db1de9b`** (masked; two lines change under the mask), in all four forms. Run them
  first, on a fresh JVM (S2.11). Their two error timestamps end `Z` (`dddd-dd-ddTdd:dd:dd.dddZ`); `--spring.jackson.use-jackson2-defaults=true`
  makes them `+00:00` — `tsmask` hides both forms.
- **Boot's mapper, as this unit read it** (`harness/probe/json/Mapper.java`): one `JsonMapper` bean, `jacksonJsonMapper`, the JSON
  converter's own; Actuator's `endpointJsonMapper` another object, which `spring.jackson.*` keys and a `JsonMapperBuilderCustomizer` do
  not reach; 2 modules; 120 features of eight kinds, all a plain `JsonMapper.builder().build()`'s but `ACCEPT_FLOAT_AS_INT`. Copy the
  harness (and `/probe/mapper/all` for before/after comparisons) rather than typing a feature's value.
- **Error bodies change with the mapper:** Boot's error answers are maps written by Boot's mapper, so a `spring.jackson.*` key that
  changes serialization changes them too (`defaults` B: the timestamp's form). Whether a `ResponseEntity` body goes through the same
  converter is 10's to measure: not measured here.
- **Native:** no hint in the tree; Spring's AOT metadata names `Customer`; `spring.jackson.*` is read when TiffinBox starts, under AOT
  too (a run-time flag changed the AOT jar and the binary here); native builds here: see "Runs of record". The image `tiffinbox-json:1.0.0`
  and the container `tiffinbox-json` are this unit's names — take your own.
- **The interrupt test** starts the receipts as a terminal starts its foreground job — `python3 -c 'import os, signal, sys;
  signal.signal(signal.SIGINT, signal.SIG_DFL); os.setpgrp(); os.execvp(sys.argv[1], sys.argv[1:])' ./receipts.sh` — and waits for
  native-image's builder by `vminvocation.args`, never by its main class.
- **A script written by an editor may lose its mode**: `receipts.sh` must be executable (`./receipts.sh` → "Permission denied" otherwise;
  this unit's first run of record hit it — "Found on the way").
- **Ports 19380-19389 are this unit's;** 10 has 19390-19399. Per the brief, **RED part A (units 06-09) runs now**, on 19660-19679, and
  10 starts from BLUE A's frozen `09/after`.
- **Not done here (for RED):** the brief's hazard "use-jackson2-defaults flips three features … say only those three" is overturned —
  thirteen, measured (`defaults`; "LINES OVERTURNED"); the brief is not edited by this unit. The parent POM's `<description>` still says
  "the router" (stale since the request-mapping lesson; carried from 08's hand-off, not this unit's change).

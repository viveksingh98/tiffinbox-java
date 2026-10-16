# c6-unit12 — Validation on the Way In

Course 6 · Spring Web MVC · Section 2 (Controllers and Binding), its seventh unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5, Hibernate Validator 9.1.3.Final, H2 2.5.250), **GraalVM CE
25.3.4.1** (native-image 25.0.4.1), **Docker on OrbStack**, 2026-10-15. Until this unit nothing checked a request body's values: the
request-body lesson's empty name — zero meals, a price of −5, the meal type `LUNCH` — was created, 201, with a Location that is a 404, and a
misspelt key reached H2 as a missing meal type, H2's 23502 and Boot's 500. This unit puts the rules on the record — Bean Validation's
**constraints** on `Customer`'s four components — and has Spring MVC check every body against them on its way in: `@Valid` on the body, a
**`BindingResult`** beside it, and a **400** that names each broken field and its rule. It measures who does the checking (Boot's adapter
around the one validator Boot builds — Spring Framework Core's kind of `Validator`, now called by the web layer), what a typo and an unknown
property get, which validation runs where (Spring MVC's own, Boot's post-processor's subclass, and a final class that cannot start), what
Boot's own error keys add, and that every form — the jar, the AOT jar, the native binary, the image — validates.

**The anchor changes (brief ⚑2, ⚑12).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and
`diff -rq -x target ../c6-tiffinbox after/` is empty at this unit's commit — `c6-tiffinbox` is Section 2's end. "Before" is
`../c6-unit10/after` — the response lesson's frozen tree, which `c6-tiffinbox` equalled at fb9fae2. Both trees are read and copied under
`.harness/`, never built in place. Two Java files change, besides the anchor's README. `tiffinbox-core/src/main/java/com/tiffinbox/Customer.java`
(8 lines → 27):

```java
public record Customer(@NotBlank String name,
                       @Min(1) @Max(3) int mealsPerDay,
                       @Min(1) int pricePerMeal,
                       @NotNull @Pattern(regexp = "VEG|NON_VEG|VEGAN") String mealType) {
```

(its five imports, `jakarta.validation.constraints.*`, and a Javadoc paragraph that says what checks them and what never is) — and
`tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java` (241 lines → 273):

```java
    @PostMapping("/customers")
    ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors) throws SQLException {
        if (errors.hasErrors()) {
            return ResponseEntity.badRequest().body(fieldMessages(errors));
        }
        try {
            repo.add(customer);
        } catch (SQLException e) {
            if (NAME_TAKEN.equals(e.getSQLState())) {
                return ResponseEntity.status(HttpStatus.CONFLICT).build();
            }
            throw e;
        }
        …
    }

    private static Map<String, String> fieldMessages(BindingResult errors) {
        var out = new TreeMap<String, String>();
        for (FieldError e : errors.getFieldErrors()) {
            out.put(e.getField(), e.getDefaultMessage());
        }
        return out;
    }
```

(the 201 and its Location are the response lesson's, unchanged) — its imports (`jakarta.validation.Valid`, `BindingResult`, `FieldError`,
`TreeMap`), a class Javadoc paragraph, the method's Javadoc and the line of the request-body paragraph that said nothing checks the values
— and the anchor's `README.md`: its unit section, and in place the history notes the change made false (`add(Customer)` at TRACE and at
DEBUG, the empty name's 201, the misspelt key's 500, its signature in the request-body and response sections). The POMs, `application.yaml`,
`CustomerRepository`, the Dockerfile and `compose.yaml` are unchanged — 22 of the tree's 25 files byte for byte — and the jar holds the same
56 libraries (`constraints`).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`; on OrbStack `orb start` is tried once if it does not), with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native
build per `forms` run (three per receipt); its seconds, and the 20-minute bound, go to the terminal only — a hashed line must not move
with the machine's load. **Start it in a process group of its own** (a terminal's foreground job is one): two receipts started as
background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (brief S2.4).

**Runs of record (2026-10-15, this script as committed):** **1,333 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, its own
process group: exit 0, all 9 = published, every check passed, no shell error; the native builds 240, 245 and 242 s), **2,226 s under
`bash receipts.sh`** (Homebrew bash 5.3.9: exit 0, all 9 = published, every check passed; 536, 439 and 287 s, load averages up to 33 with
other units' work beside it) and **994 s from a sealed fresh clone** (`git clone` of tiffinbox-java at 86973fc, this unit's and the
anchor's 61 files put in as git would take them; `env -i`, a `HOME` of its own whose `.mavenrc` points every Java proxy at a refusing port,
Maven settings sending every repository to a `file://` copy of Central's files made from this unit's `.m2-demo` — 4,372 files — the proxy
variables at the same refusing port, `GRAALVM_HOME`, `DOCKER_CONFIG=~/.docker`, `/bin/bash` 3.2, a process group of its own: exit 0, all 9
= published; **526 artifacts, every one from the `file://` copy**; its first build said `offline: no`, as a fresh clone's must, and every
capture's build `offline: yes`). Before each run in this folder, `.m2-demo` was re-seeded from `_research/m2-seed-s2/` alone: every build
said `offline: yes`. **How the hashes were made:** four development passes (a copy of this script making some captures, `.r-dev.sh`,
deleted) — the first stopped at `keys`, whose raw printing of Boot's `errors` array drifted across its three runs (Found on the way) — then
a first full run, `bash receipts.sh`: eight captures made what are now their published hashes, and the checks stopped at `methods`'
trace bound (a validation failure's trace has 47 frames; the check said "over 50"); the bound is 40 now, `methods` was re-made with it,
and the nine hashes went into `receipts.md5`; every run above reproduced all nine. **The exercise as viewers run it**, beyond the capture:
the README's last line alone in an `env -i` `/bin/bash` shell without the exports — its `java` 23.0.1 — ends with `exit 1` and prints no
line (`wait $!` hands back the JVM's exit code), the shell left in `c6-unit12/`; README then SOLUTION in one `env -i` `zsh -f` shell →
`status: 400 · errors: 0 · fields: none`, then `status: 400 · errors: 3 · fields: mealType mealsPerDay name`, exit 0, the shell in
`c6-unit12/`; 19419 free after.

Published hashes: constraints `8e7805da2887176afca6b9e6c5741d87` · before `22bd0e1900e0c9afeb5000f7484f0ee1` · answer `1a73e0b318bd819abd5ec3a61e4f25f0` · validator `060e76f14c40c9ba09676596b4227ce5` · typo `903c3a4f3a0b8b145309cbc4ea9b1219` · methods `4d9a71a70b84e2260d13416b8b4f9454` · keys `6d0ef1e3a8ea9d5fc6ac53e70ce698d4` · exercise `594149d2f82aeb0ffda3dc8edea9bd97` · forms `4b00fb78db2650322ff4db515bec11e2`.

**BLUE B (2026-10-16), after RED B2 rows 111, 112, 114, 116, 120:** every java line a capture starts pins the JVM's locale,
`-Duser.language=en -Duser.country=US` after `java` (`at()`; README.md "The commands this unit adds"), so all nine captures but `exercise`
changed: constraints `e24ca7b9…` → `8e7805da…`, before `2ec05efc…` → `22bd0e19…`, answer `3b3298b3…` → `1a73e0b3…`, validator `7678c730…` →
`060e76f1…`, typo `75eb21c6…` → `903c3a4f…`, methods `2ce5659a…` → `4d9a71a7…` (with C, labelled: a copy not final, `@Validated` → 500),
keys `fdebc5f0…` → `6d0ef1e3…`, forms `4f0628b3…` → `4b00fb78…`; exercise `594149d2…` unchanged. **Runs of record:** `./receipts.sh`
(/bin/bash 3.2.57, `.m2-demo` re-seeded from `_research/m2-seed-s2/`, `env -i`, its own process group) 2,220 s — 9 captures 3/3, every
check passed, "no published hash" as designed; `bash receipts.sh` (5.3.9, re-seeded) 1,089 s — exit 0, all 9 = published; **a sealed
fresh clone** (`git clone` at 3973f94, this unit's, `c6-unit10`'s and the anchor's 93 files put in as git would take them, a `HOME` of its
own whose `.mavenrc` points every Java proxy at a refusing port, Maven's mirror a `file://` copy of Central made from `.m2-demo` — 4,372
files — `/bin/bash` 3.2, its own group) 964 s — exit 0, all 9 = published, its first build `offline: no` as a fresh clone's must;
**SIGINT** to the run's process group 20 s into the native build: exit 130, 0 processes left in the group, no native-image or TiffinBox
process, 18425, 8080 and 19410-19419 free, no `tiffinbox-valid` container or image, no `.r-lock`, no unfinished run files.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but six, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.web.error.include-binding-errors=always
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.web.error.include-exception=true
curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Accept-Language: de' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:18431/customers
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" harness/probe/web/MethodFinal.java harness/probe/web/MethodPlain.java harness/probe/web/MethodValidated.java harness/probe/web/Unbound.java harness/probe/web/Who.java
```

**The JVM's locale is pinned on every java line this unit runs** (RED B2 #111). The first two lines are the anchor's run line and its
class-path line with `-Duser.language=en -Duser.country=US` after `java` — asserted to be exactly that — and every java line a capture
starts takes the same two options in the same place (`at()`, which must give these two lines back): Hibernate Validator writes its
messages in the JVM's locale when a request names none (H2 its own, in `before`), and on macOS the JVM takes the Mac's first language,
**not** `LC_ALL` (measured: `LANG`/`LC_ALL=de_DE.UTF-8` → `en_US`; a JVM started `-Duser.language=de -Duser.country=DE` → `darf nicht
leer sein`, `muss größer-gleich 1 sein`; `-Duser.country=IN` → `en_IN`, English; `-Duser.country=GB` → `en_GB`, English). So a Mac set to
English (India) — this one's region — or to German makes the same captures. The binary takes no JVM options: its messages were fixed when
it was built, and it answers English (measured on this tree's binary, from a request that asks for German, and from a build whose builder
JVM ran German: `NATIVE_IMAGE_OPTIONS=-J-Duser.language=de -J-Duser.country=DE` → the same four English messages). The image runs the jar
on Linux with no locale set, so it is not this Mac's. The next two are the anchor's run line with one of Boot's error keys each (`keys`, `methods`); the script asserts each is that line with
its one option and nothing else, and passes the option to the class-path line too (`methods`, where the harness joins). The fifth is the
anchor README's new line — the response lesson's Location line with the request-body lesson's empty name as its body — with a client's
`Accept-Language: de` header (`validator`), asserted the same way. The sixth compiles the course's harness, the five files of
`harness/probe/web`, against after/'s extracted jar, with `-parameters` (S2.16); the script asserts it names those five and nothing else.
Every POST a capture sends is a line of the anchor README's shapes — `plc` (the Location line), `lc` (any line of that shape), `pc` (the
request-body lesson's) — each with its port, path and body swapped, the body single-quoted as the README writes it. Boot 3's name for the
first key (the same words under `server` instead of `spring.web`) is on one line of this unit, the exercise's run line, labelled there (S2.13).

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script still fills `.m2-demo`, makes the eight other captures, each checked against `receipts.md5`,
then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s2/` alone — 5,837 files, no `com/tiffinbox` (a stale install would satisfy `-pl tiffinbox-web
native:compile-no-fork`) — and re-seeded so before each run of record. **Nothing was downloaded** for this unit: every build said
`offline: yes` (the validation starter, Hibernate Validator and the Bean Validation API are TiffinBox's since Course 5), the native plugin
read its metadata repository from `.m2-demo` (`file:`), and every native build log holds 0 lines of the plugin's own download
(`Downloaded GraalVM reachability metadata repository from http`, `Failed to download from http`). A fresh clone's `.m2-demo` is empty
(git ignores it): the first build — `after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven Central and says
`offline: no`; every capture's build then says `offline: yes`. The install writes `com/tiffinbox` into this unit's `.m2-demo` — fine
here, and never copied into a seed. **Docker:** no pull — `docker build` prints its `load metadata` line and the base image's digest, and
`its lines that say pull: 0`. The image (`tiffinbox-valid:1.0.0`) and the container (`tiffinbox-valid`) are this script's own names,
checked absent first and removed on every exit; the build cache is not pruned (`.dockerignore` keeps `secrets/` out of every build
context, so it holds no token). **At run time** every request goes to `127.0.0.1`.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, mounted read-only into the container (`:ro`), and sent only by `../c5-unit11/curlset.sh` and
`harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so
are the log of every JVM that served or failed to start (at TRACE and DEBUG in `constraints` too), the container's log (`docker logs`),
every file this unit ships, the binary's bytes, and every blob of the image (`docker save`, each gzip layer unpacked; `forms`): 0
everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log. `constraints`' TRACE run sets one logger at TRACE,
Spring MVC's `RequestMappingHandlerMapping`, and leaves the two that `application.yaml` holds at INFO (`Http11InputBuffer`,
`HandlerMethod`) alone; this change adds a parameter, a `BindingResult`, that holds no secret, so the two are kept and not re-measured.
The exercise makes a token of its own (`openssl rand -hex 13`: 26 hexadecimal digits), counted 0 times in its own log and never printed.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`). `.harness/before`, `.harness/after` — the two trees, copied, each with
  a config tree, built and extracted (`constraints`); `.harness/plant` — after/ without the `BindingResult`: the parameter out of `add`'s
  signature and the three lines that answer from it deleted (`answer` B, `keys`); `.harness/nat` — after/'s native build, and
  `.harness/natb` — the previous tree built with the native profile, for its AOT metadata (`forms`); `.harness/hc` — the harness's
  classes, compiled against after/'s own jar with `-parameters`; `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`), joined by `--spring.main.sources` on
  the extracted jar's class path, each route naming the type it returns: `Who` reads the running application as text —
  `/probe/who/validator` (the `Validator` beans, `mvcValidator`'s class and its target, the target unwrapped, what Spring MVC's handler
  adapter binds with, the JVM's locale) and `/probe/who/proxies` (the method-validation post-processor and its exclusion filters, and for
  `TiffinBoxServer`, `TiffinBoxProperties`, `MethodPlain` and `MethodValidated`: final or not, `@Validated` or not, and the class of the
  object the context holds — a generated subclass's number masked `<n>`); `MethodPlain` (`@RequestParam @Min(1) int meals`, no
  `@Validated`), `MethodValidated` (the same route, `@Validated` on the class), `MethodFinal` (the same, on a final class); `Unbound`
  (`@Valid @RequestBody Customer` and no `BindingResult`; stores nothing — the exercise's). `harness/shutdown.sh` — POST `/shutdown` with
  the token read from its file (the binding lesson's, copied unchanged).
- **Ports** (brief ⚑1, 19410-19419): after/'s jar 19410 · the previous tree 19411 · after/ with the harness joined 19412 · the copy
  without the `BindingResult` 19413 · the AOT jar 19414 · the final class's start 19415 (it never listens) · the image 19417 · the binary
  19418 · the exercise 19419 · the `@Validated` copy (`methods` C) 19416. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free and never bound on
  this Mac (18425 only inside the container); a run that listens on 8080 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character
   token]` (its length read off the token); the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above → `…/..`; home →
   `~`; the user name, as a whole word → `<user>`; the number of a class Spring generated (`$$SpringCGLIB$$N`) → `<n>`. A last check fails if
   any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line, a log
   time, an unmasked timestamp, a `GMT` date, a thread number, a stack frame, a generated class's number, a `sha256:` ID other than the base
   image's digest, `:8080`, a carriage return, or a command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — both forms — in every answer printed and in the seven, which are hashed after it (two lines changed: `/nowhere`'s
   and GET /shutdown's). Its form, where the seven print it: the date and time, every digit → `d`, the zone kept (`Z`).
3. **Field errors, sorted.** Hibernate Validator hands its violations over as a set, and Spring MVC passes them on in that order: the order
   of the field errors in Spring MVC's WARN line and in Boot's `errors` array moved between runs here (Found on the way). So `vwarn` cuts the
   WARN line that lists them after its count (`… with 4 errors: …`) and prints the errors one a line — the field, the value it was given, the
   rule's message — sorted by field, their codes and arguments counted out, not shown; and `berr` prints Boot's body as its keys and status,
   then the `errors` array sorted by field, each entry whole, its keys sorted. Both filters say so on the line, and `vwarn` is checked on a
   planted log before any capture (two errors in the wrong order, one with a `default message [` inside its arguments). TiffinBox's own
   answer needs no filter: its map is a `TreeMap`, sorted by field.
4. **Log lines** (`logl`, `erec`, `dbg`, `reg`, `failed`): from their logger on, as the log prints the logger (`o.s.web.servlet.DispatcherServlet`,
   `s.w.s.m.m.a.RequestMappingHandlerMapping`, `m.m.a.RequestResponseBodyMethodProcessor`, `o.s.w.s.m.m.a.HttpEntityMethodProcessor` and
   `.w.s.m.s.DefaultHandlerExceptionResolver` are Spring MVC's; `o.a.c.c.C.[.[.[/].[dispatcherServlet]` Tomcat's; `o.s.boot.SpringApplication`
   Boot's, and `ConfigServletWebServerApplicationContext` is Boot's `AnnotationConfigServletWebServerApplicationContext`, its name cut to 40
   characters by Boot's log pattern — read off the log, never typed); an identity hash after `@` → `@…`; in an ERROR record, H2's constraint
   and index names — the quoted string after `violation: ` — → `"…"`, the record's next line printed when it is not blank (the SQL
   statement, H2's error code at its end), its stack frames bounded ("over 50"; the final class's "over 40") or counted, none shown. A
   request's lines are those the log gained between two points where it stopped growing (`wans`, `erec`, `dreq`): each answer's last line
   ends with `· WARN lines it added: N`; at DEBUG (`dreq`) every line it gained is printed, counted — Spring MVC cuts a body it writes at 100
   characters itself (`(truncated)...`). At TRACE (`reg`) a block's routes are sorted: the order Spring MVC registers them in is a
   reflection's.
5. **Boot's metadata** (`bmeta`): a key's type, its default, its description and, for a deprecated key, its level, its version and its
   replacement — read from the jar in after/'s extracted lib that declares it.
6. **Spring's AOT metadata** (`aotcmp`): the two trees' `reachability-metadata.json`, compared — entries counted, the types only one of them
   registers, each entry that differs and its methods that differ, `Customer`'s entry in each, the resource entries; the file itself is not
   printed.
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
os.execvp(sys.argv[1], sys.argv[1:])' ./receipts.sh`): SIGINT to its process group during the native build (554 s in, native-image's
builder running for 25 s — 5 processes in the group, 2 of them java): **exit 130** 0.5 s later; 5 s later 0 processes in the group and 0
anywhere naming this folder, no image builder left; 19410-19419, 8080 and 18425 free; no container, no image, no `.r-lock`, no unfinished
capture run; the published captures unchanged. (A first try, launched from a shell whose own command line named this folder, counted that
shell and its parent as "naming this folder"; the launch was made again from a shell that names none, above.)

## 1 · constraints — the change, registered and read

Both trees copied under `.harness/`, built with the README's line (offline) and extracted; the harness compiled against after/'s
jar (this unit's `javac` line, `-parameters`: five classes). **Three files differ** — `README.md`, `Customer.java`, `TiffinBoxServer.java` —
and 22 of the tree's 25 are byte for byte the previous tree's. **`Customer.java` 8 → 27 lines**, its code lines 6 → 14; imports left out,
**the lines naming a constraint 0 → 4, the constraints 0 → 6** — `@NotBlank` 1, `@NotNull` 1, `@Min` 2, `@Max` 1, `@Pattern` 1 — its
code lines' diff whole (one hunk: the record's line out, five imports and its four component lines in). **`TiffinBoxServer.java` 241 →
273**, code lines 127 → 141; naming **`@Valid` 0 → 1, a `BindingResult` 0 → 2, `@Validated` 0 → 0**; the diff whole: the four imports,
`add`'s signature and the `if` that answers from the `BindingResult`, and `fieldMessages`. The jar: 56 libraries, the same names. **The
seven**, on a fresh JVM of after/: `87ca7efc…`. **Registered** (the request-mapping lesson's line, Spring MVC's mapping logger at TRACE):
`{POST [/customers]}: add(Customer,BindingResult)` among TiffinBox's seven, **9 mappings** as before. **Read** (Boot's `web` group at DEBUG,
the embedded-Tomcat lesson's line): the refused body → **400** and its four fields' messages, six lines — `Mapped to
com.tiffinbox.web.TiffinBoxServer#add(Customer, BindingResult)`, the body read by `RequestResponseBodyMethodProcessor`, the method's map
written by `HttpEntityMethodProcessor` (cut at 100 characters by Spring MVC itself), `Completed 400 BAD_REQUEST`, and no exception
resolved: the method answered; the request-body lesson's POST → 201, six lines, as on the previous tree.

`.r-constraints.out` · md5 `8e7805da2887176afca6b9e6c5741d87` · 3 of 3

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
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar" harness/probe/web/MethodFinal.java harness/probe/web/MethodPlain.java harness/probe/web/MethodValidated.java harness/probe/web/Unbound.java harness/probe/web/Who.java
  exit 0 · its classes: probe/web/MethodFinal.class probe/web/MethodPlain.class probe/web/MethodValidated.class probe/web/Unbound.class probe/web/Who.class
the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java and .harness/after/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
  after/'s files: 25 · byte for byte the previous tree's: 22 · those above differ: 3
  Customer.java: 8 lines -> 27 · its lines that are neither comment nor blank: 6 -> 14, of them - imports left out - naming a constraint: 0 -> 4 · the constraints they name: @NotBlank 0 · @NotNull 0 · @Min 0 · @Max 0 · @Pattern 0 -> @NotBlank 1 · @NotNull 1 · @Min 2 · @Max 1 · @Pattern 1
  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: 1 · lines out: 1 · in: 9 - whole:
    @@ -2 +2,9 @@
    -public record Customer(String name, int mealsPerDay, int pricePerMeal, String mealType) {
    +import jakarta.validation.constraints.Max;
    +import jakarta.validation.constraints.Min;
    +import jakarta.validation.constraints.NotBlank;
    +import jakarta.validation.constraints.NotNull;
    +import jakarta.validation.constraints.Pattern;
    +public record Customer(@NotBlank String name,
    +                       @Min(1) @Max(3) int mealsPerDay,
    +                       @Min(1) int pricePerMeal,
    +                       @NotNull @Pattern(regexp = "VEG|NON_VEG|VEGAN") String mealType) {
  TiffinBoxServer.java: 241 lines -> 273 · its lines that are neither comment nor blank: 127 -> 141, of them - imports left out - naming @Valid: 0 -> 1 · a BindingResult: 0 -> 2 · @Validated: 0 -> 0
  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: 5 · lines out: 1 · in: 15 - whole:
    @@ -2,0 +3 @@
    +import jakarta.validation.Valid;
    @@ -6,0 +8,2 @@
    +import org.springframework.validation.BindingResult;
    +import org.springframework.validation.FieldError;
    @@ -28,0 +32 @@
    +import java.util.TreeMap;
    @@ -62 +66,4 @@
    -    ResponseEntity<Customer> add(@RequestBody Customer customer) throws SQLException {
    +    ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors) throws SQLException {
    +        if (errors.hasErrors()) {
    +            return ResponseEntity.badRequest().body(fieldMessages(errors));
    +        }
    @@ -103,0 +111,7 @@
    +    private static Map<String, String> fieldMessages(BindingResult errors) {
    +        var out = new TreeMap<String, String>();
    +        for (FieldError e : errors.getFieldErrors()) {
    +            out.put(e.getField(), e.getDefaultMessage());
    +        }
    +        return out;
    +    }
  README.md - the anchor's README: lines added 104, removed 11 - its new section and the history notes the change made false (not shown)
the executable jar's BOOT-INF/lib: 56 jars -> 56 · the same names: yes
the seven - after/, the README's run line, port 19410, a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410
  listens on: 127.0.0.1:19410 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19410 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
registered - after/, the request-mapping lesson's line - Spring MVC's mapping logger at TRACE, the kitchen at DEBUG - port 19410:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410 --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
  listens on: 127.0.0.1:19410 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/actuator/health/readiness
  {"status":"UP"} 200
  Spring MVC's RequestMappingHandlerMapping, its lines before Boot's started line (logger: level, message; a block's routes sorted):
    s.w.s.m.m.a.RequestMappingHandlerMapping: TRACE
      c.t.w.TiffinBoxServer:
        {GET [/customers/{name}]}: customer(String)
        {GET [/customers]}: customers(MealType)
        {GET [/dashboard]}: dashboard()
        {GET [/kitchen]}: kitchen()
        {GET [/revenue]}: revenue()
        {POST [/customers]}: add(Customer,BindingResult)
        {POST [/shutdown]}: shutdown(String)
    s.w.s.m.m.a.RequestMappingHandlerMapping: TRACE
      o.s.b.w.a.e.BasicErrorController:
        { [/error], produces [text/html]}: errorHtml(HttpServletRequest,HttpServletResponse)
        { [/error]}: error(HttpServletRequest)
    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 9 mappings in 'requestMappingHandlerMapping'
$ harness/shutdown.sh 19410 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19410 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
read - after/, the embedded-Tomcat lesson's line - Boot's web group at DEBUG - port 19410: the anchor's refused-body line, then the request-body lesson's POST:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410 --logging.level.web=debug
  listens on: 127.0.0.1:19410 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19410/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: []
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 6:
    o.s.web.servlet.DispatcherServlet: POST "/customers", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#add(Customer, BindingResult)
    m.m.a.RequestResponseBodyMethodProcessor: Read "application/json;charset=UTF-8" to [Customer[name=, mealsPerDay=0, pricePerMeal=-5, mealType=LUNCH]]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{mealType=must match "VEG|NON_VEG|VEGAN", mealsPerDay=must be greater than or equal to 1, name=must  (truncated)...]
    o.s.web.servlet.DispatcherServlet: Completed 400 BAD_REQUEST
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 6:
    o.s.web.servlet.DispatcherServlet: POST "/customers", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#add(Customer, BindingResult)
    m.m.a.RequestResponseBodyMethodProcessor: Read "application/json;charset=UTF-8" to [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]
    o.s.web.servlet.DispatcherServlet: Completed 201 CREATED
$ harness/shutdown.sh 19410 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19410 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 2 · before — what the previous tree takes

The previous tree (`../c6-unit10/after`), the README's run line. **The empty name** — the anchor README's refused-body line: an empty
name, zero meals, a price of −5, `LUNCH` — → **201**, its Location `http://127.0.0.1:19411/customers/`, and that URL → **404**: no mapping takes
`/customers/`. **The misspelt key** (`"mealTyp"`) → **500**: Tomcat's ERROR line, H2's `NULL not allowed for column "MEAL_TYPE"`, its code
`[23502-250]` on the SQL statement's line, over 50 stack frames. `/customers` lists **five**, the empty name first (H2 sorts `""` before
`Meera`). 0 WARN, 1 ERROR.

`.r-before.out` · md5 `22bd0e1900e0c9afeb5000f7484f0ee1` · 3 of 3

```
the previous tree, the README's run line, port 19411 - the anchor's refused-body line (the request-body lesson's empty name, zero meals, a price of -5, LUNCH), its Location followed; a misspelt key; then every customer:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19411
  listens on: 127.0.0.1:19411 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19411/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19411/customers
  {"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"} 201 · Location: [http://127.0.0.1:19411/customers/] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19411/customers/
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/"} 404 · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19411/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500 · Location: []
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19411/customers
  [{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"},{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19411 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19411 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 3 · answer — a 400 that names each field (A/B/A′)

**A** — after/, the README's run line: the same refused body → **`{"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or
equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400`** — four rules broken, four fields, none
twice, no WARN line; `/customers` lists the four seed customers: nothing stored. Four meals a day (Tara) → `{"mealsPerDay":"must be less than
or equal to 3"}`. Asha → 201 and her Location; Asha again → **409** — a body that keeps every rule still reaches the unique index. 0 WARN,
0 ERROR. **B** — a copy of after/ without the `BindingResult`: its `diff -U0`, one hunk — the parameter out of `add`'s signature, and the
three lines that answered from it deleted — built the same way. The same body → **Boot's 400**: `timestamp`, `status`, `error`, `path`, no
field; **one WARN line** of Spring MVC's `DefaultHandlerExceptionResolver`: `MethodArgumentNotValidException: Validation failed for argument
[0] in … TiffinBoxServer.add(com.tiffinbox.Customer) … with 4 errors`, the four printed sorted (their order moves between runs: Masks, 3),
each with the value it was given; nothing stored. **A′** — A again, on a fresh JVM: line for line A ("yes").

`.r-answer.out` · md5 `1a73e0b318bd819abd5ec3a61e4f25f0` · 3 of 3

```
A - after/, the README's run line, port 19410 - the anchor's refused-body line, then every customer:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410
  listens on: 127.0.0.1:19410 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19410/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/customers
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
  four meals a day; then a new name, and the same name again:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Tara","mealsPerDay":4,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
  {"mealsPerDay":"must be less than or equal to 3"} 400 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19410/customers/Asha] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
   409 · Location: [] · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19410 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19410 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - a copy of after/ without the BindingResult - its diff: the parameter out, and the three lines that answer from it - then built the same way, port 19413:
$ diff -U0 after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java .harness/plant/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
  @@ -159,4 +159 @@
  -    ResponseEntity<?> add(@Valid @RequestBody Customer customer, BindingResult errors) throws SQLException {
  -        if (errors.hasErrors()) {
  -            return ResponseEntity.badRequest().body(fieldMessages(errors));
  -        }
  +    ResponseEntity<?> add(@Valid @RequestBody Customer customer) throws SQLException {
$ cd .harness/plant && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy · offline: yes · exit 0
$ cd .harness/plant && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19413
  listens on: 127.0.0.1:19413 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19413/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19413/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Location: [] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MethodArgumentNotValidException: Validation failed for argument [0] in org.springframework.http.ResponseEntity<?> com.tiffinbox.web.TiffinBoxServer.add(com.tiffinbox.Customer) throws java.sql.SQLException with 4 errors: …
      the field errors it lists: 4, sorted by field (the order moves between runs) - each: its field, the value it was given, the rule's message; its codes and arguments not shown:
        mealType [LUNCH]: must match "VEG|NON_VEG|VEGAN"
        mealsPerDay [0]: must be greater than or equal to 1
        name []: must not be blank
        pricePerMeal [-5]: must be greater than or equal to 1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19413/customers
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19413 .harness/plant/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19413 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410
  listens on: 127.0.0.1:19410 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19410/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/customers
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
  four meals a day; then a new name, and the same name again:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Tara","mealsPerDay":4,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
  {"mealsPerDay":"must be less than or equal to 3"} 400 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19410/customers/Asha] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
   409 · Location: [] · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19410 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19410 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```


## 4 · validator — who checks the body

after/ with the harness's `Who` joined. **The validator Spring MVC binds a body with**, read off the running application: two beans of
Spring's `Validator` type, `defaultValidator` and `mvcValidator`, and **one** of Bean Validation's, `defaultValidator`; `mvcValidator` — the bean
Spring MVC's configuration declares — is Boot's `ValidatorAdapter`, **its target the very `defaultValidator` bean, the same object**, a
`LocalValidatorFactoryBean`, which unwraps to Hibernate Validator's `ValidatorImpl`; Spring MVC's handler adapter (`requestMappingHandlerAdapter`)
binds and validates with `mvcValidator`, the same object. Course 4's validation lesson called a `Validator` straight — "no web layer, no Boot,
no controller"; here the web layer calls Boot's. The JVM's locale: `en_US`. The refused body → the four messages in English; **the same body
from a client that sends `Accept-Language: de` → the four in German** (`muss mit "VEG|NON_VEG|VEGAN" übereinstimmen`, …): Spring's
`LocalValidatorFactoryBean` interpolates its messages in the request's locale — the JVM's when the request names none.

`.r-validator.out` · md5 `060e76f14c40c9ba09676596b4227ce5` · 3 of 3

```
after/ with the harness's Who joined, port 19412 - the validator Spring MVC binds a request's body with, read off the running application:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19412 --spring.main.sources=probe.web.Who
  listens on: 127.0.0.1:19412 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19412/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19412/probe/who/validator
  beans of Spring's Validator type (org.springframework.validation.Validator): 2 [defaultValidator, mvcValidator]
  beans of Bean Validation's Validator type (jakarta.validation.Validator): 1 [defaultValidator]
  mvcValidator, the bean Spring MVC's configuration declares: org.springframework.boot.validation.autoconfigure.ValidatorAdapter
    its target: org.springframework.validation.beanvalidation.LocalValidatorFactoryBean · the very bean defaultValidator, the same object: true
  defaultValidator, unwrapped to Bean Validation's own Validator: org.hibernate.validator.internal.engine.ValidatorImpl
  Spring MVC's handler adapter (requestMappingHandlerAdapter) binds and validates with: mvcValidator, the same object
  the JVM's locale, the one Hibernate Validator writes its messages in when a request names none: en_US
   200 · WARN lines it added: 0
  the anchor's refused-body line, then this unit's line - the same, from a client whose Accept-Language header asks for German:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19412/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Accept-Language: de' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19412/customers
  {"mealType":"muss mit \"VEG|NON_VEG|VEGAN\" übereinstimmen","mealsPerDay":"muss größer-gleich 1 sein","name":"darf nicht leer sein","pricePerMeal":"muss größer-gleich 1 sein"} 400 · Location: [] · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19412 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19412 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 5 · typo — the misspelt key, caught

after/, the README's run line. **The misspelt key** (`"mealTyp"`) → **`{"mealType":"must not be null"}` 400** — Jackson still ignores the
property it does not know, the record's meal type is `null`, and `@NotNull` refuses it before H2 is asked: no ERROR line, and
`/customers/Rohan` → 404. **An unknown property beside a full body** (`"loyaltyPoints":5`) → **201**, and Kiran is stored without it:
validation checks the record Jackson built, not the JSON that was sent. **Two point seven meals** → Boot's 400 and one WARN line, Jackson's
`Cannot coerce Floating-point value (2.7) to int` — the Jackson lesson's key, refused before any check; `/customers/Mohan` → 404. 1 WARN, 0
ERROR.

`.r-typo.out` · md5 `903c3a4f3a0b8b145309cbc4ea9b1219` · 3 of 3

```
after/, the README's run line, port 19410 - a misspelt key; a full body with a property the record does not have; two point seven meals:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410
  listens on: 127.0.0.1:19410 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19410/customers
  {"mealType":"must not be null"} 400 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/customers/Rohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Rohan"} 404 · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}' http://127.0.0.1:19410/customers
  {"name":"Kiran","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19410/customers/Kiran] · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/customers/Kiran
  {"name":"Kiran","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Location: [] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.7) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/customers/Mohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Mohan"} 404 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19410 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19410 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 6 · methods — which validation runs

Boot's metadata (`spring-boot-autoconfigure-4.1.1.jar`): `spring.web.error.include-exception`, a `Boolean`, **default false** — this unit's line
turns it on for this run, so Boot's error body names the exception that answered. after/ with the harness's `Who`, `MethodPlain` and
`MethodValidated` joined. **The beans:** one `MethodValidationPostProcessor`, Boot's `FilteredMethodValidationPostProcessor`, with **one**
exclusion filter (`EnableConfigurationPropertiesRegistrar.methodValidationExcludeFilter`, for `@ConfigurationProperties` beans);
`TiffinBoxServer` — final, no `@Validated`, the context holds the class itself; `TiffinBoxProperties` — **final and `@Validated`**, the class
itself (no subclass: the filter leaves it to Boot's binder, which checks it while binding); `MethodPlain` — itself; **`MethodValidated` —
`probe.web.MethodValidated$$SpringCGLIB$$<n>`, a subclass Spring generated**. **No `@Validated`** (`MethodPlain`): `?meals=1` → 200,
`?meals=0` → **400, `HandlerMethodValidationException`** — Spring MVC's own method validation — and no WARN line. **`@Validated` on the class**
(`MethodValidated`): `?meals=1` → 200, `?meals=0` → **500, `jakarta.validation.ConstraintViolationException`**, Tomcat's ERROR line (`meals.meals:
must be greater than or equal to 1`), over 50 frames. 0 WARN, 1 ERROR. **Who resolved the 400:** `MethodPlain` alone, Boot's `web` group at
DEBUG (the embedded-Tomcat lesson's option on the class-path line) — the same 400, and Spring MVC's `ResponseStatusExceptionResolver` logs
`Resolved [org.springframework.web.method.annotation.HandlerMethodValidationException: 400 BAD_REQUEST "Validation failure"]` at DEBUG: the
exception is a `ResponseStatusException`, and that resolver writes no WARN line (the request-mapping lesson's `DefaultHandlerExceptionResolver`
does, for the 4xx it resolves); then the error dispatch to Boot's `BasicErrorController`. **A final class** (`MethodFinal`, `@Validated`) joined alone: **exit 1**,
Boot's started line never logged, 19415 free — Boot's context's WARN line and `Application run failed`, the exception
(`BeanCreationException … Could not generate CGLIB subclass of class probe.web.MethodFinal`), and its causes, the last `Cannot subclass final
class probe.web.MethodFinal`. **C** (labelled, RED B2 #114) — so final is not the only reason TiffinBoxServer takes `@Valid` and never
`@Validated`: a copy of after/ whose class line is `@org.springframework.validation.annotation.Validated public class TiffinBoxServer {`
(not final; its one changed line, `diff -U0`), built the same way: a body that breaks one rule (`"mealType":"LUNCH"`) → **Boot's 500**,
Tomcat's ERROR line `ConstraintViolationException: add.customer.mealType: must match "VEG|NON_VEG|VEGAN"` — the `BindingResult` is there,
but the generated subclass checks the method's parameters before the method runs, so the method's readable 400 never happens; a body that
keeps every rule → 201. 0 WARN, 1 ERROR.

`.r-methods.out` · md5 `4d9a71a70b84e2260d13416b8b4f9454` · 3 of 3

```
  Boot's metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-exception · its type: Boolean · its default: false · its description: Include the "exception" attribute.
after/ with the harness's Who, MethodPlain and MethodValidated joined, and this unit's include-exception option, port 19412:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19412 --spring.main.sources=probe.web.Who,probe.web.MethodPlain,probe.web.MethodValidated --spring.web.error.include-exception=true
  listens on: 127.0.0.1:19412 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19412/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19412/probe/who/proxies
  the post-processor that adds method validation (MethodValidationPostProcessor): 1 [methodValidationPostProcessor] · its class: org.springframework.boot.validation.beanvalidation.FilteredMethodValidationPostProcessor
  the beans it is told to leave alone (MethodValidationExcludeFilter): 1 [org.springframework.boot.context.properties.EnableConfigurationPropertiesRegistrar.methodValidationExcludeFilter]
  TiffinBoxServer: final true · @Validated on the class false · the object the context holds: com.tiffinbox.web.TiffinBoxServer - a subclass Spring generated: false
  TiffinBoxProperties: final true · @Validated on the class true · the object the context holds: com.tiffinbox.TiffinBoxProperties - a subclass Spring generated: false
  MethodPlain: final false · @Validated on the class false · the object the context holds: probe.web.MethodPlain - a subclass Spring generated: false
  MethodValidated: final false · @Validated on the class true · the object the context holds: probe.web.MethodValidated$$SpringCGLIB$$<n> - a subclass Spring generated: true
   200 · WARN lines it added: 0
  a constraint on a request parameter (@Min(1) int meals), no @Validated on the class - MethodPlain:
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19412/probe/method/plain?meals=1'
  meals=1 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19412/probe/method/plain?meals=0'
  {"timestamp":"…","status":400,"error":"Bad Request","exception":"org.springframework.web.method.annotation.HandlerMethodValidationException","path":"/probe/method/plain"} 400 · WARN lines it added: 0
  the same route with @Validated on the class - MethodValidated:
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19412/probe/method/validated?meals=1'
  meals=1 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19412/probe/method/validated?meals=0'
  {"timestamp":"…","status":500,"error":"Internal Server Error","exception":"jakarta.validation.ConstraintViolationException","path":"/probe/method/validated"} 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: jakarta.validation.ConstraintViolationException: meals.meals: must be greater than or equal to 1] with root cause
    its stack frames: over 40, its other lines: 3 - none shown · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19412 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19412 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
who resolved the 400 - MethodPlain joined, Boot's web group at DEBUG (the embedded-Tomcat lesson's option), port 19412:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19412 --spring.main.sources=probe.web.MethodPlain --logging.level.web=debug
  listens on: 127.0.0.1:19412 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19412/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19412/probe/method/plain?meals=0'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/method/plain"} 400
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 9:
    o.s.web.servlet.DispatcherServlet: GET "/probe/method/plain?meals=0", parameters={masked}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to probe.web.MethodPlain#meals(int)
    .w.s.m.a.ResponseStatusExceptionResolver: Resolved [org.springframework.web.method.annotation.HandlerMethodValidationException: 400 BAD_REQUEST "Validation failure"]
    o.s.web.servlet.DispatcherServlet: Completed 400 BAD_REQUEST
    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error?meals=0", parameters={masked}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=400, error=Bad Request, path=/probe/method/plain}]
    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 400
$ harness/shutdown.sh 19412 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19412 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
a final class - the same route with @Validated, on a class that is final, MethodFinal joined, port 19415:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19415 --spring.main.sources=probe.web.MethodFinal
  exit 1 · Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · Boot's started line: 0 · listening on 19415 now: 0
  its WARN and ERROR records (logger: message), the exception under them, and every Caused by line:
    WARN ConfigServletWebServerApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'methodFinal': Could not generate CGLIB subclass of class probe.web.MethodFinal: Common causes of this problem include using a final class or a non-visible class
    ERROR o.s.boot.SpringApplication: Application run failed
    org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'methodFinal': Could not generate CGLIB subclass of class probe.web.MethodFinal: Common causes of this problem include using a final class or a non-visible class
    Caused by: org.springframework.aop.framework.AopConfigException: Could not generate CGLIB subclass of class probe.web.MethodFinal: Common causes of this problem include using a final class or a non-visible class
    Caused by: java.lang.IllegalArgumentException: Cannot subclass final class probe.web.MethodFinal
    its stack frames: over 40 - none shown
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - a copy of after/ whose TiffinBoxServer is not final and carries @Validated - its one changed line - then built the same way, port 19416: a body that breaks one rule, then a new name:
$ diff -U0 after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java .harness/val/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
  @@ -99 +99 @@
  -public final class TiffinBoxServer {
  +@org.springframework.validation.annotation.Validated public class TiffinBoxServer {
$ cd .harness/val && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the @Validated copy · offline: yes · exit 0
$ cd .harness/val && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19416
  listens on: 127.0.0.1:19416 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19416/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Gita","mealsPerDay":1,"pricePerMeal":110,"mealType":"LUNCH"}' http://127.0.0.1:19416/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500 · Location: []
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: jakarta.validation.ConstraintViolationException: add.customer.mealType: must match "VEG|NON_VEG|VEGAN"] with root cause
    its stack frames: 47, its other lines: 3 - none shown · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19416/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19416/customers/Asha] · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19416 .harness/val/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19416 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 7 · keys — Boot's error keys

Boot's metadata: **`spring.web.error.include-binding-errors`** (`spring-boot-autoconfigure-4.1.1.jar`) — "When to include "errors" attribute",
default `never`; **Boot 3's name for it** (`spring-boot-web-server-4.1.1.jar`) — the same description and default, **deprecated at level error,
since 4.0.0**, replaced by the key above. **The anchor** with the key (this unit's line): the refused body → the method's own map, unchanged —
where the method answers, Boot's error body never appears. **The copy without the `BindingResult`** (`answer` B's) with the key: Boot's body
gains `errors` — **4 entries, each with the same 8 keys** (`arguments`, `bindingFailure`, `code`, `codes`, `defaultMessage`, `field`,
`objectName`, `rejectedValue`), printed sorted by field (Masks, 3), each whole; and the same WARN line as B.

`.r-keys.out` · md5 `6d0ef1e3a8ea9d5fc6ac53e70ce698d4` · 3 of 3

```
  Boot's metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-binding-errors · its type: ErrorProperties$IncludeAttribute · its default: "never" · its description: When to include "errors" attribute.
  Boot's metadata (spring-boot-web-server-4.1.1.jar) - server.error.include-binding-errors · its type: none · its default: "never" · its description: When to include "errors" attribute. · deprecated: level error, since 4.0.0, replaced by spring.web.error.include-binding-errors
the anchor - after/, this unit's line: the README's run line with Boot's include-binding-errors key, port 19410 - the anchor's refused-body line:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410 --spring.web.error.include-binding-errors=always
  listens on: 127.0.0.1:19410 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19410/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: [] · WARN lines it added: 0
$ harness/shutdown.sh 19410 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19410 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the copy - the copy without the BindingResult (answer's B), the same line, port 19413:
$ cd .harness/plant && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19413 --spring.web.error.include-binding-errors=always
  listens on: 127.0.0.1:19413 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19413/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19413/customers
  Boot's body - its keys: error errors path status timestamp · its status 400 · then curl's: 400 · Location: []
  its errors: 4 entries, sorted by field (the order moves between runs) - each with the same 8 keys: arguments bindingFailure code codes defaultMessage field objectName rejectedValue
    {"arguments":[{"arguments":null,"code":"mealType","codes":["customer.mealType","mealType"],"defaultMessage":"mealType"},[],{"arguments":null,"codes":["VEG|NON_VEG|VEGAN"],"defaultMessage":"VEG|NON_VEG|VEGAN"}],"bindingFailure":false,"code":"Pattern","codes":["Pattern.customer.mealType","Pattern.mealType","Pattern.java.lang.String","Pattern"],"defaultMessage":"must match \"VEG|NON_VEG|VEGAN\"","field":"mealType","objectName":"customer","rejectedValue":"LUNCH"}
    {"arguments":[{"arguments":null,"code":"mealsPerDay","codes":["customer.mealsPerDay","mealsPerDay"],"defaultMessage":"mealsPerDay"},1],"bindingFailure":false,"code":"Min","codes":["Min.customer.mealsPerDay","Min.mealsPerDay","Min.int","Min"],"defaultMessage":"must be greater than or equal to 1","field":"mealsPerDay","objectName":"customer","rejectedValue":0}
    {"arguments":[{"arguments":null,"code":"name","codes":["customer.name","name"],"defaultMessage":"name"}],"bindingFailure":false,"code":"NotBlank","codes":["NotBlank.customer.name","NotBlank.name","NotBlank.java.lang.String","NotBlank"],"defaultMessage":"must not be blank","field":"name","objectName":"customer","rejectedValue":""}
    {"arguments":[{"arguments":null,"code":"pricePerMeal","codes":["customer.pricePerMeal","pricePerMeal"],"defaultMessage":"pricePerMeal"},1],"bindingFailure":false,"code":"Min","codes":["Min.customer.pricePerMeal","Min.pricePerMeal","Min.int","Min"],"defaultMessage":"must be greater than or equal to 1","field":"pricePerMeal","objectName":"customer","rejectedValue":-5}
  WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MethodArgumentNotValidException: Validation failed for argument [0] in org.springframework.http.ResponseEntity<?> com.tiffinbox.web.TiffinBoxServer.add(com.tiffinbox.Customer) throws java.sql.SQLException with 4 errors: …
      the field errors it lists: 4, sorted by field (the order moves between runs) - each: its field, the value it was given, the rule's message; its codes and arguments not shown:
        mealType [LUNCH]: must match "VEG|NON_VEG|VEGAN"
        mealsPerDay [0]: must be greater than or equal to 1
        name []: must not be blank
        pricePerMeal [-5]: must be greater than or equal to 1
$ harness/shutdown.sh 19413 .harness/plant/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19413 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 8 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s eight lines, then `exercise/solution/SOLUTION.md`'s three, read from the files and run as written, one after the other
in **one** shell a viewer could have — `env -i`, `/bin/bash --noprofile --norc`, started in this folder. The README's run, given Boot 3's key:
**`status: 400 · errors: 0 · fields: none`** — and its log names the key in 0 lines, 1 WARN line (the refused body's). The solution's, the
same line with Boot 4's name: **`status: 400 · errors: 3 · fields: mealType mealsPerDay name`**. The shell is in this unit's folder after each;
the copy's own token 0 times in each log; 19419 free.

`.r-exercise.out` · md5 `594149d2f82aeb0ffda3dc8edea9bd97` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 8 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
  $ javac -parameters -d .harness/mine/hc -cp ".harness/mine/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Unbound.java
  $ (cd .harness/mine/after && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19419 --spring.main.sources=probe.web.Unbound --server.error.include-binding-errors=always > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19419/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":110,"mealType":"LUNCH"}' http://127.0.0.1:19419/probe/unbound); ../../../harness/shutdown.sh 19419 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"field":"[^"]*"' ../got.json | wc -l | tr -d ' ') && f=$(grep -o '"field":"[^"]*"' ../got.json | sed 's/^"field":"//; s/"$//' | sort | paste -sd' ' -) && echo "status: $s · errors: $n · fields: ${f:-none}")
  exit 0 · what they printed:
    status: 400 · errors: 0 · fields: none
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1 · its lines that name the key it was given (include-binding-errors): 0 · listening on 19419 now: 0
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ (cd .harness/mine/after && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19419 --spring.main.sources=probe.web.Unbound --spring.web.error.include-binding-errors=always > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19419/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":110,"mealType":"LUNCH"}' http://127.0.0.1:19419/probe/unbound); ../../../harness/shutdown.sh 19419 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"field":"[^"]*"' ../got.json | wc -l | tr -d ' ') && f=$(grep -o '"field":"[^"]*"' ../got.json | sed 's/^"field":"//; s/"$//' | sort | paste -sd' ' -) && echo "status: $s · errors: $n · fields: ${f:-none}")
  exit 0 · what they printed:
    status: 400 · errors: 3 · fields: mealType mealsPerDay name
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1 · its lines that name the key it was given (include-binding-errors): 0 · listening on 19419 now: 0
```


## 9 · forms — every form validates (⚑16, R.40, S2.20)

**The native build** of after/ (`.harness/nat`, the README's two Maven lines, offline): exit 0, `BUILD SUCCESS`, 8 of 8 stages, 0 lines of the
plugin's own download; Mach-O on this Mac, 0 bytes of the token. **Spring's AOT step, on both trees** (the previous tree built with the
README's native-profile line, `.harness/natb`): **665 reflection entries → 665**, no type only one of them registers, **one entry differs —
`TiffinBoxServer`'s: `add(Customer)` → `add(Customer, BindingResult)`**, nothing else in it; **`Customer`'s entry is the same** (all
declared fields, all declared constructors, its 4 accessors) — the record is still registered by the signatures that name it, the
`@RequestBody` parameter and `GET /customers/{name}`'s return type, though `add` returns `ResponseEntity<?>` now; 26 resource entries, the
same. **Four forms** — the jar (19410), the AOT jar (19414), the binary (19418), the image (published on 127.0.0.1:19417, 18425 inside): each
listening on loopback only, the seven `87ca7efc…` (masked), exit 0; then, on a second start of each, **the refused body → 400 and its four
fields' messages**, Asha → 201 and a Location on that form's own port, the Location → 200, Asha again → 409, POST /shutdown without the
token → 403 — 4 of 4 each. The image: built from after/'s Dockerfile, 0 lines that say pull, its layers 0 bytes of the token; `docker port`
`18425/tcp -> 127.0.0.1:19417` alone.

`.r-forms.out` · md5 `4b00fb78db2650322ff4db515bec11e2` · 3 of 3

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
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json) - the previous tree's against after/'s: reflection entries 665 -> 665 · types only one of them registers: 0 · entries that differ: 1 - com.tiffinbox.web.TiffinBoxServer
    com.tiffinbox.web.TiffinBoxServer - its methods only before: add(Customer) · only after: add(Customer, BindingResult) · anything else that differs: no
  reflection entries naming com.tiffinbox.Customer: 1 -> 1 · the same entry: yes - all declared fields · all declared constructors · 4 methods (mealType mealsPerDay name pricePerMeal)
  resource entries: 26 -> 26 · the same: yes
1 the jar - .harness/after, the README's run line, port 19410:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410
  listens on: 127.0.0.1:19410 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19410 (http) with context path '/'
$ $CURLSET 19410 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the refused body, a new customer, the same name again and POST /shutdown without the token, on a second start of the jar:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19410
  listens on: 127.0.0.1:19410 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19410/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: []
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19410/customers/Asha]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19410/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19410/customers
   409 · Location: []
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19410/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19410 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19410 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19414:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19414
  listens on: 127.0.0.1:19414 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19414/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19414 (http) with context path '/'
$ $CURLSET 19414 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the same four, on a second start of the AOT jar:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19414
  listens on: 127.0.0.1:19414 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19414/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19414/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: []
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19414/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19414/customers/Asha]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19414/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19414/customers
   409 · Location: []
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19414/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19414 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19414 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19418:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19418
  listens on: 127.0.0.1:19418 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19418/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19418 (http) with context path '/'
$ $CURLSET 19418 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the same four, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19418
  listens on: 127.0.0.1:19418 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19418/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19418/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: []
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19418/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19418/customers/Asha]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19418/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19418/customers
   409 · Location: []
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19418/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19418 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19418 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19417:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-valid:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-valid:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-valid --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19417:18425 tiffinbox-valid:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19417/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19417
  on this Mac, listening on port 19417: 127.0.0.1:19417
$ $CURLSET 19417 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-valid
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then the same four, on a second container of the image - TiffinBox listens on 18425 inside it:
$ cd .harness/after && docker run -d --name tiffinbox-valid --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19417:18425 tiffinbox-valid:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19417/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19417
  on this Mac, listening on port 19417: 127.0.0.1:19417
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19417/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Location: []
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19417/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19417/customers/Asha]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19417/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19417/customers
   409 · Location: []
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19417/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19417 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-valid
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times
four forms, one tree: the seven (masked) 4 of 4 times 87ca7efc8584dcccd40e6b956db1de9b · the refused body 400, its four fields named 4 of 4 · a new customer, 201 and a Location on 127.0.0.1 and the form's own port 4 of 4, the Location followed 200 4 of 4 · the same name again 409 4 of 4 · POST /shutdown without the token 403 4 of 4
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
```


## Exercise

**Your turn:** this run should list every field error in Boot's own body, but nothing changes. Find why, fix the key, count the errors.
`exercise/README.md` has the commands (copy `after/` with a token of its own, build and extract the jar offline, compile the harness's
`Unbound` route with `-parameters`); its last line, in a subshell, starts TiffinBox on 19419 with the route joined and Boot's
binding-errors key as a Boot 3 tutorial names it, POSTs a body that breaks three rules to the route, stops TiffinBox, waits for its JVM and
prints — as shipped — `status: 400 · errors: 0 · fields: none`: Boot 4 reads that key under another name and ignores the old one without a
word. Done is `status: 400 · errors: 3 · fields: mealType mealsPerDay name`. Measured answer: `exercise/solution/SOLUTION.md` (the README's
two `export` lines, then the same line with the key's Boot 4 name, `--spring.web.error.include-binding-errors=always`), run in the same shell.
Run `./receipts.sh` once first on a fresh clone.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-15) |
|---|---|---|---|
| 13 | Validation in the binary of `12/after`; 3 errors; `before` on `10/after` (201, stored) | the chain-end binary; storage measured with `Unchecked` (200) | **the binary, the AOT jar, the jar and the image: the refused body → 400, its four fields** (`forms`); **4 errors for 4 broken components, none doubled — 3 for the exercise's 3** (`answer`, `keys`, `exercise`); **`before` on `10/after`: the empty name 201, its Location a 404, listed; the misspelt key 500 (23502)** (`before`) |
| 15 | the image of every chain unit | once, on the chain end | **built from after/'s Dockerfile, 0 pulls, its layers 0 tokens, `127.0.0.1:19417` alone, the seven `87ca7efc…`, the refused body 400, 201 + Location, 409, 403, `docker wait` 0** (`forms`) |
| 16 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: `errors: 0` (Boot 3's key), then `errors: 3`** (`exercise`) |
| — | the AOT metadata once `add`'s return type changes (the task) | `Customer` registered by `ResponseEntity<Customer>` among others (the response lesson's `forms`) | **665 → 665 entries, one differs (`add`'s parameters), `Customer`'s the same** (`forms`) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **`@NotNull @Pattern`, not `@NotBlank @Pattern`, on `mealType`** (⚑12's sketch): with `@NotBlank` beside `@Pattern`, an empty meal type breaks
  both, two field errors for one field, and a `{field: message}` map would keep one of them by the order Hibernate Validator happened to hand
  them over — an order measured moving between runs (below). With `@NotNull`, each value breaks at most one rule of its component. The typo's
  message is therefore `must not be null` (the brief: `must not be blank`), which says what happened: the meal type arrived as `null`.
- **B is a copy without the parameter and the three lines that answer from it** (the brief: "diff -U0: one parameter"): the method reads the
  `BindingResult`, so a copy without it that compiles loses that `if` too. One hunk, shown whole in `answer`.
- **The messages follow the request's `Accept-Language`** (not in the brief): Spring's `LocalValidatorFactoryBean` interpolates in the
  request's locale — German for `de` — and in the JVM's when the request names none (`en_US` on this Mac). The published captures send no
  `Accept-Language` but `validator`'s labelled line; every JVM's locale is pinned on its run line, `en_US`, and printed in `validator`.
- **`TiffinBoxProperties` is final and carries `@Validated`, and starts** (the brief: "on a final class @Validated stops the start"): Boot's
  `MethodValidationExcludeFilter` — one, registered for `@ConfigurationProperties` beans — keeps the record from the method-validation
  post-processor; on a settings record `@Validated` asks Boot's binder to check it (the last course's configuration-validation lesson). So the
  rule is scoped: a final **bean the post-processor proxies** (a controller, here `MethodFinal`) stops the start.
- **Which exception answered is named by Boot itself** with `spring.web.error.include-exception=true` (false by default): Spring MVC's own
  method validation is `HandlerMethodValidationException` (400, no WARN line: at DEBUG, `ResponseStatusExceptionResolver` resolves it — the class
  is a `ResponseStatusException`, javap of spring-web 7.0.9 in a probe — and that resolver logs no WARN); the post-processor's subclass throws
  `jakarta.validation.ConstraintViolationException`, which no resolver takes: Tomcat's ERROR line and Boot's 500.
- **Spring's AOT step needs no hint for the change:** `add`'s return type no longer names the record (`ResponseEntity<?>`), and the metadata
  still registers `Customer`, the same entry, from the signatures that do (S2.15 held where it matters: a record returned by type elsewhere).

## Found on the way

- **The field errors' order moves between runs.** Six fresh JVMs of a probe (the harness's `Unbound` route, the refused body, Boot's key on)
  printed the four field errors in six different orders, in Boot's `errors` array and in Spring MVC's WARN line alike; a first development
  run of `keys` that printed Boot's body raw drifted across its three runs and stopped (`keys drifts across three runs`). Hibernate Validator
  returns its violations as a set. Both filters now sort by field (Masks, 3) — and TiffinBox's own answer is a `TreeMap`.
- **Every new check fails on a planted fault first** (R.65): the checks block run alone, under /bin/bash 3.2, on copies of the published
  captures with one line changed per plant (`plants.py`, this unit's scratch folder) — **83 plants, 83 stops**, each naming its own check; the
  unplanted copies pass. Five change a command line in the script and in its README alike, so that the derivation check alone must stop the
  run (the keys' line with a second option, the German line with another header, the javac line with a sixth file, the refused body, the
  solution's line with a second change); four plant Boot 3's key where S2.13 forbids it (SOLUTION.md, after/, the exercise's prose, this
  README's prose). The field-error filter (`vwarn`) and the docker-build filter are also shown failing on planted inputs inside the script
  itself, before any capture.
- **Boot 3's key is silent.** The exercise's run with `--server`…`include-binding-errors=always` (Boot 3's name) answers the same body as no key
  at all, and its log names the key in 0 lines; Boot 4.1.1's metadata carries the old name as deprecated at level *error*, since 4.0.0.
- **Spring MVC cuts a body it logs at DEBUG at 100 characters** (`… name=must  (truncated)...`), as RED found for the request-body lesson's
  `Read` line; the method's map is cut the same way in `constraints`' DEBUG run.
- **The probe's sketch and this tree agree** (brief §Validation): `{field: message}` for every broken component, no doubles; Boot's body without
  the `BindingResult`; `HandlerMethodValidationException` 400 with no WARN; `@Validated` → 500; a final class → exit 1; `mvcValidator`'s target
  the very `defaultValidator` — each now a line of this unit's own captures.

## For unit 13 — and RED

- **Start from `../c6-unit12/after`** (= `../c6-tiffinbox`, Section 2's end). `TiffinBoxServer` is a `final` `@RestController`, never `@Validated`,
  273 lines, seven request mappings, unchanged but for `POST /customers`: `ResponseEntity<?> add(@Valid @RequestBody Customer customer,
  BindingResult errors) throws SQLException` — a body that breaks a rule → **400**, a `TreeMap` field → message (`fieldMessages`), nothing
  stored; else 201 + Location (`fromCurrentRequestUri()`), or 409 when H2's SQLSTATE is 23505. `Customer` (core) carries `@NotBlank name`,
  `@Min(1) @Max(3) mealsPerDay`, `@Min(1) pricePerMeal`, `@NotNull @Pattern(regexp = "VEG|NON_VEG|VEGAN") mealType`. The POMs,
  `application.yaml` (the Jackson key, the two TRACE-leak loggers at INFO), `CustomerRepository` and the jar's 56 libraries are 10's.
- **The anchor README's new line** is the Location line with the request-body lesson's empty name: `curl -s -w ' %{http_code} · Location:
  [%header{location}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}'
  http://127.0.0.1:18431/customers` → `{…four fields…} 400 · Location: []`.
- **What 13 meets on this tree:** this unit changes no GET route, so `?mealType=veg` is still the binding lesson's 400 (`MealType` is an
  enum, and binding asks for its exact name: `../c6-unit07/`) — a parameter's conversion, not a body's validation. In a JSON body the meal
  type is a `String` the record checks with `@Pattern` — measured here for `LUNCH` and for an empty string (`must match "VEG|NON_VEG|VEGAN"`,
  400, a field error); a lower-case `"veg"` would break the same case-sensitive pattern, not measured here. The brief's probe measured that a
  `Converter<String, MealType>` bean changes parameters only; 13 measures it on this tree. A harness route that binds a record from a query
  string with constraints on it would meet binding failures and validation errors in one `BindingResult` — not measured here.
- **Field errors come in an order that moves:** sort them before hashing (Masks, 3). Hibernate Validator's messages follow the request's
  `Accept-Language` and else the JVM's locale (`validator`: German for `de`; `en_US` here). A locale of another language would print
  other words — which is why every java line here pins `-Duser.language=en -Duser.country=US`; `en_GB`, 13's locale break, has no bundle of
  its own in Hibernate Validator and falls back to the English one — measured (RED B2 #111's probe: `-Duser.country=GB` → `en_GB`, English
  messages).
- **Boot's error keys** are `spring.web.error.*`; Boot 3's `server`-prefixed names are silent (S2.13); this unit's receipts allow the old
  name on the exercise's run line alone, and in this README only inside the pasted `keys` and `exercise` captures.
- **ResponseEntity answers still go out chunked** (`harness/shutdown.sh` prints `Content-Length: none`); the seven `87ca7efc…` (masked) in all
  four forms; the Allow header's verbs sorted; a 409 prints `   409 · Location: []`.
- **Native:** no hint in the tree; Spring's AOT metadata 665 reflection entries here, `Customer` registered; the native builds here took
  under 4 minutes each (terminal only). The image `tiffinbox-valid:1.0.0` and the container `tiffinbox-valid` are this unit's names — take your
  own. Ports 19410-19419 are this unit's; 13 has 19420-19429.
- **/bin/bash 3.2:** the two traps of the response lesson hold (a `/` inside a quoted `${x/pattern/…}` ends the pattern; no `case` inside
  `$( )`): this script's derivations put pattern and replacement in variables (`P_`, `R_`) and the forms check uses label triples.
- **The anchor README** got this unit's section and the history notes amended in place (each `*(Course 6, unit 12: …)*`): `add(Customer)`
  → `add(Customer,BindingResult)` at TRACE (three notes) and DEBUG (one), the empty name's 201 and the misspelt key's 500 (four notes), the
  signature in the request-body and response sections. For RED: check them against `constraints`, `answer` and `typo`.

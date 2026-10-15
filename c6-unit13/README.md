# c6-unit13 — Binding, Converters and Formatters

Course 6 · Spring Web MVC · Section 2 (Controllers and Binding), its eighth and last unit · Verified on **JDK 25.0.4.1, Apache Maven
3.9.16, Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5, Hibernate Validator 9.1.3.Final), 2026-10-15. A query
string is text. Since the binding lesson TiffinBox's `GET /customers` takes its meal type as a request parameter, a `MealType`, and
something turns `VEG` into one — and refuses `veg` with a 400. This unit opens that something: Spring MVC's **data binder** (the object
it makes for each request to turn the request's text into a method's values) and the **conversion service** it asks (Spring's
registry of converters and formatters — here Boot's `WebConversionService`, the bean `mvcConversionService`). Then it writes rules of
its own and measures whose rule wins: a **`Converter`** for the whole application, a **format** on one parameter (`@DateTimeFormat`) and
Boot's key for every date (`spring.mvc.format.date`), a **binder** for one controller (`@InitBinder`), a **record** bound from a query
string (no annotation, `@ModelAttribute`, `@BindParam`, and a rule beside a binding failure), and the **locale** — the language and
country a date with no format is read in, which on U.K. English turns `14/10/26` into the year twenty-six, 200, no warning.

**"Converter" means two things in Spring MVC**, and this README keeps them apart: a *message converter* reads or writes a whole body (the
request-body lesson's — Jackson's JSON converter among them, `../c6-unit08/`); a **`Converter`** — Spring's
`org.springframework.core.convert.converter.Converter` — turns one value into another for the data binder, through the conversion
service. This unit's converter is the second kind, and `converter` shows it never reaching a JSON body.

**No anchor change (brief ⚑2, ⚑14).** `anchor` is the link to `../c6-unit12/after` — the validation lesson's frozen tree, `c6-tiffinbox`
at Section 2's end — read and copied under `.harness/anchor`, never built in place. `c6-tiffinbox` is neither read nor touched here.
TiffinBox's meal types stay exact (⚑2 loser C: a strict API that writes `NON_VEG` and reads `NON_VEG` is the simpler contract). Everything
new is **the course's harness**, never TiffinBox's — `harness/probe/web`, outside `com.tiffinbox`, compiled with `-parameters` against the
anchor's own jar and joined by `--spring.main.sources` on the extracted jar's class path:

- `Who` — reads the running application, as text, for one GET route (`/probe/who/binds?route=PATH`): each parameter of the method mapped
  to it, the first of Spring MVC's argument resolvers (in the handler adapter's own order) that takes it, and, for a parameter the
  conversion service can make from a `String`, the converter that service uses for it — its own lookup (`GenericConversionService`'s
  `getConverter`, by the parameter's type and annotations), and when that converter is a formatter's parser, the `java.time` formatter
  the parser holds (read by reflection: Spring's `ParserConverter` and `TemporalAccessorParser` keep it in private fields). Then the
  service itself — the bean `mvcConversionService`, its class, and whether it is the one the adapter gives every data binder — and the
  JVM's locale.
- `MealTypeConverter` — a `@Component` that implements `Converter<String, MealType>`: trims, upper-cases (`Locale.ROOT`), looks the
  constant up; a blank value is `null` (no meal type), as Spring's own converter has it.
- `Plain` — routes with no binding rules of their own: a name, a meal type, and an order (`record Order(MealType mealType)`) read from a
  JSON body.
- `Binder` — the same name and meal type, with an `@InitBinder` method: every `String` trimmed and a blank one made `null`
  (`StringTrimmerEditor(true)`), and a `MealType` read from a short code (`v`, `nv`, `vg`) by a property editor of its own.
- `Queries` — records bound from a query string: `CustomerQuery(MealType mealType, Integer maxPrice)` with no annotation and with
  `@ModelAttribute`; `NamedQuery(@BindParam("type") MealType mealType, Integer maxPrice)`; and `CheckedQuery(MealType mealType, @Min(1)
  Integer maxPrice)`, marked `@Valid`, with a `BindingResult` beside it — its route prints each field error: its field, the value it
  was given, its code, and whether it is a binding failure or a broken rule.
- `Dates` — `LocalDate` parameters: `/probe/date` with no format (it prints the JVM's locale beside the date), `/probe/date/fmt` with
  `@DateTimeFormat(pattern = "dd/MM/yyyy")`, `/probe/date/yy` with `"dd/MM/yy"`, and `/probe/date/pattern`, which prints the JVM's locale,
  this request's locale and the short date pattern this request is read with.

No native build and no Docker: the brief keeps both to the chain units (⚑16), and this unit changes nothing in TiffinBox's own tree.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) No GraalVM and no
Docker are needed. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a
process group of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a group,
and one run's clean-up would stop the other's JVMs (brief S2.4).

**Runs of record (2026-10-15, this script as committed):** **349 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, its own
process group: exit 0, all 7 = published, every check passed, no shell error; load averages 3-7), **347 s under `bash receipts.sh`**
(Homebrew bash 5.3.9: exit 0, all 7 = published, every check passed; load averages about 4) and **357 s from a sealed fresh clone** (`git
clone` of tiffinbox-java at b0a224a, this unit's 13 files put in as git would take them, the clone's `c6-unit12/after` the working tree's to
the byte; `env -i`, a `HOME` of its own whose `.mavenrc` points every Java proxy at a refusing port, Maven settings sending every
repository to a `file://` copy of Central's files made from this unit's `.m2-demo` — 4,372 files — the proxy variables at the same refusing
port, `/bin/bash` 3.2, a process group of its own: exit 0, all 7 = published; **512 artifacts, every one from the `file://` copy**, 0 from
anywhere else, all for the anchor's first build, which said `offline: no`, as a fresh clone's must; every capture's build `offline: yes`,
0 download lines). Before each run in this folder, `.m2-demo` was re-seeded from `_research/m2-seed-s2/` alone: every build said
`offline: yes`. **The exercise as viewers run it**, beyond the capture: the README's last line alone in an `env -i` `/bin/bash` shell
without the exports — its `java` 23.0.1 — ends with `exit 1` and prints no line (`wait $!` hands back the JVM's exit code; its log:
`UnsupportedClassVersionError`), the shell left in `c6-unit13/`; README then SOLUTION in one `env -i` `zsh -f` shell → `GET
/customers?mealType=veg: 400 · customers: 0 · names: none`, then `GET /customers?mealType=veg: 200 · customers: 2 · names: Ravi Sunil`,
exit 0, the shell in `c6-unit13/`; 19429 free after.

Published hashes: default `651bfdd970e61e0bfb33db27e5f60ad8` · converter `512ea7a10ec9311ba57d8183582b8067` · format `b39dd8bc871b24026e1049e783e10013` · binder `943ea154322ce858fac654dbc51ccbbb` · record `baad567a3dd84996ffd3601262881c6b` · locale `1d9f878f49a0e26ad41a809c23ff11f8` · exercise `de0f821316619d2b9ef129492ca5a00c`.

## The commands this unit adds

`anchor/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but ten, which are this unit's, each read from
the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/*.java
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=GB -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.mvc.format.date=iso
curl -s 'http://127.0.0.1:18431/probe/who/binds?route=/customers'
curl -s -w ' %{http_code}\n' -H 'Accept-Language: en-GB' 'http://127.0.0.1:18431/probe/date?on=14/10/26'
sed -n '/^@Component/,/^}/p' harness/probe/web/MealTypeConverter.java
sed -n '/^    @InitBinder/,/^    }/p' harness/probe/web/Binder.java
grep -n 'LocalDate on)' harness/probe/web/Dates.java
grep -n '^    record ' harness/probe/web/Queries.java
```

- **The compile line** builds the harness's six classes against the anchor's extracted jar, `-parameters` so Spring MVC can read the
  routes' parameter names (brief S2.16).
- **The three run lines** are the anchor's class-path line with JVM options **before `-cp`** (brief S2.14: after the main class, the
  anchor's guard refuses them, exit 2) — U.S. English, U.K. English, and U.S. English with Boot's date format key set to `iso`; the script
  asserts each is exactly that. Each capture adds the harness's classes to the class path (`../hc`) and joins the ones it needs with
  `--spring.main.sources=…`, after the line's own options.
- **The harness's question** asks `Who` about one route (`route=` swapped per capture). **The language line** is the anchor's GET line with
  one header, `Accept-Language: en-GB` (the request's language), and another path — asserted.
- **The four source lines** print, from the harness's files, the converter's class, the binder's `@InitBinder` method, the three date
  routes' signatures and the three records' declarations.

Every other request is one of two lines of the anchor README: its GET with a meal type (`curl -s -w ' %{http_code}\n'
'http://127.0.0.1:18431/customers?mealType=VEGAN'`) with its port and path swapped, and the request-body lesson's POST (`-H
'Content-Type: application/json' --data '{"name":"Asha",…}'`) with its port, path and body swapped — each derivation asserted.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s2/` alone — 5,837 files, no `com/tiffinbox` — and re-seeded so before each run of record.
**Nothing was downloaded** for this unit: every build said `offline: yes`. A fresh clone's `.m2-demo` is empty (git ignores it): the first
build — the anchor's, before any capture — fills it from Maven Central and says `offline: no`; every capture's build then says `offline:
yes`. No Docker, no GraalVM. **At run time** every request goes to `127.0.0.1`.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input. Every
capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that served and every file this
unit ships: 0 everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log. No capture runs at TRACE, so the two
loggers the anchor's `application.yaml` holds at INFO (`Http11InputBuffer`, `HandlerMethod`) are kept and not re-measured: the harness adds
no parameter that holds a secret. The exercise makes a token of its own (`openssl rand -hex 13`: 26 hexadecimal digits), counted 0 times in
its own log and never printed.

## The folders, the names and the ports

- `anchor` — the link to `../c6-unit12/after`. `.harness/anchor` — it, copied with a config tree, built and extracted (`default`): every
  JVM here starts in it; `.harness/hc` — the harness's classes; `.harness/pre` — the pre-capture build; `.harness/mine` — the exercise's
  copy.
- **Two layouts** (R.44): the executable jar (`java -jar`, the anchor's run line) for `default`'s seven; the extracted layout (`java -cp
  …/extracted/tiffinbox-web-1.0.0.jar:…/lib/*:../hc`, the anchor's class-path line) for every run with the harness joined — the converter's
  seven among them, which hash as the jar's.
- **Ports** (brief ⚑1, 19420-19429): the seven on the jar 19420 · `default`'s class path 19421 · `converter` 19422 · `format` A and A′
  19423, B 19424 · `binder` 19425 · `record` 19426 · `locale` A, A′ and D 19427, B and C 19428 · the exercise 19429. All ten bound. 18425
  (TiffinBox's default) and 8080 (Tomcat's) are checked free and never bound; a run that listens on 8080 is killed and the script dies.

## The locale — pinned per JVM

A **locale** is a language and a country (`en_US`, `en_GB`). Java's default comes from the machine, so a capture that depends on it would
hash differently on yours. On this Mac it comes from the system's settings, not from the environment: JDK 25.0.4.1 printed
`user.language = en`, `user.country = US` (`java -XshowSettings:properties -version`, in an `env -i` shell) with no locale variable, with
`LC_ALL=C`, with `LC_ALL=de_DE.UTF-8`, with `LANG=de_DE.UTF-8` and with `LC_ALL=en_GB.UTF-8` alike (a terminal check on 2026-10-15, not a
capture) — so this script's `LC_ALL=C` does not pin Java's. Every JVM here whose answer can follow its
locale starts with `-Duser.language=… -Duser.country=…`, before `-cp`: a date read with no format (`format`, `locale`), a validation message
(Hibernate Validator writes the JVM's language when the request names none: TiffinBox's POST in `default` and `converter`), and `Who`,
which prints the JVM's locale. The binder's run and the exercise print nothing a locale changes, and carry no option. Each pinned run prints
its locale (`the JVM's locale: en_US`).

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character token]` (its
   length read off the token); this folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`. A last
   check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's process line, a log time, an
   unmasked timestamp, a `GMT` date, a ` CET `/` CEST ` zone, a thread number, an identity hash, a stack frame, `:8080`, a carriage return,
   or a command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — in every answer printed and in the seven, which are hashed after it (two lines changed: `/nowhere`'s and GET
   /shutdown's). **Its form** (`tsform`) is printed beside the seven: every digit of the date and time → `d`, the zone kept (`Z`).
3. **An identity hash** (`ihm`): the `@` and hexadecimal digits Java prints after a class's name when the object has no `toString` of its
   own (`StringToEnumConverterFactory@7d4fbc1f`) → `@…` — in `Who`'s answers and in log lines; it moves with every run.
4. **Log lines** (`logl`): from their logger on, as the log prints the logger — `.w.s.m.s.DefaultHandlerExceptionResolver` is Spring MVC's;
   Boot's own lines are labelled Boot's (`Boot's first line`, cut before ` with PID`); a Jackson message inside Spring MVC's WARN line is
   Jackson's words in Spring MVC's line. A request's WARN lines are those the log gained between two points where it stopped growing
   (`wans`): each answer's last line ends with `· WARN lines it added: N`.
5. **A WARN line that lists field errors** (`fwarn`): Spring MVC's `MethodArgumentNotValidException` line is cut after `with N errors`, and
   its field errors follow, sorted by field — each its field, the value it was given and its code (the last of its codes, the most
   general: `typeMismatch`); the other codes, its arguments and its default message are not shown.
6. **The harness's source** is printed by its own `sed`/`grep` lines (README commands above), whole for the ranges they name.
7. **A URL that holds a character the shell reads** (`;`, `?`, `&`, `*`, `{`, `}`, a space) is single-quoted on the command line, and
   every body is single-quoted, so the printed command is the one that ran.
8. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the exercise's
shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox JVM or Maven left,
deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured** on this script (2026-10-15), started as a terminal starts its foreground job (SIGINT at its default, a process group of its
own — from a script, `python3 -c 'import os, signal, sys; signal.signal(signal.SIGINT, signal.SIG_DFL); os.setpgrp();
os.execvp(sys.argv[1], sys.argv[1:])' ./receipts.sh`): SIGINT to its process group 13 s in, while the first capture's TiffinBox JVM served
on one of this unit's ports (4 processes in the group, 1 of them that JVM, 1 listener on 19420-19429): **exit 130** 0.1 s later; 5 s later
0 processes in the group and 0 anywhere naming this folder; 19420-19429, 8080 and 18425 free; no `.r-lock`, no unfinished capture run;
the published captures unchanged.

## 1 · default — TiffinBox's own rule: a meal type by its exact name

The anchor, copied, built offline and extracted; the harness's six classes compiled against its jar. **The seven**, on a fresh JVM from
the executable jar: `87ca7efc…` (masked) — Section 2's set since the request-mapping lesson. Then the class-path layout, U.S. English, the
harness's `Who` joined: `?mealType=VEG` → Ravi and Sunil; **`?mealType=veg` → 400**, Boot's error body, and one WARN line — Spring MVC's
`DefaultHandlerExceptionResolver`, `MethodArgumentTypeMismatchException … Failed to convert from type [java.lang.String] to type
[@…RequestParam com.tiffinbox.MealType] for value [veg]`; `?mealType=` → all four (an empty value is no filter). **Who binds it**, read off
the running app: the parameter `@RequestParam MealType mealType`, its argument resolver 1 of 28 (`RequestParamMethodArgumentResolver`);
from a `String` the conversion service uses **`java.lang.String -> java.lang.Enum : …StringToEnumConverterFactory`** — Spring's own
converter for every enum, which asks for the constant's exact name; the service is the bean `mvcConversionService`, **Boot's
`WebConversionService`**, the very object the adapter gives every data binder. **The same word in a JSON body** — TiffinBox's own POST, its
meal type `veg` — is not a conversion at all: the record holds its meal type as a `String` (the validation lesson's ⚑12), so the answer is
validation's, **`{"mealType":"must match \"VEG|NON_VEG|VEGAN\""}` 400 with 0 WARN lines**, beside the parameter's conversion failure:
Boot's opaque body and one WARN. One WARN in all.

`.r-default.out` · md5 `651bfdd970e61e0bfb33db27e5f60ad8` · 3 of 3

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
  and its jar extracted (the README's line) - the class path the harness runs on:
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against the anchor's own jar - with -parameters (this unit's line):
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/*.java
  exit 0 · its classes: 6 top-level - Binder Dates MealTypeConverter Plain Queries Who
the seven - the anchor, the README's run line, port 19420, a fresh JVM:
$ cd .harness/anchor && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19420
  listens on: 127.0.0.1:19420 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19420/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19420 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the anchor on its class path, U.S. English (this unit's run line), the harness's Who joined, port 19421, a fresh JVM - the meal type asked for as VEG, veg and empty (the anchor README's GET line, its value swapped), then who binds it (this unit's line):
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19421 --spring.main.sources=probe.web.Who
  listens on: 127.0.0.1:19421 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19421/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19421/customers?mealType=VEG'
  [{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19421/customers?mealType=veg'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19421/customers?mealType='
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
$ curl -s 'http://127.0.0.1:19421/probe/who/binds?route=/customers'
  GET /customers - TiffinBoxServer#customers, 1 parameter
    @RequestParam MealType mealType - its argument resolver: 1 of 28, RequestParamMethodArgumentResolver
      from a String, the conversion service uses: java.lang.String -> java.lang.Enum : org.springframework.core.convert.support.StringToEnumConverterFactory@…
  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object
  the JVM's locale: en_US
  the same word in a JSON body - TiffinBox's own POST (the anchor README's line, its meal type veg):
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"veg"}' http://127.0.0.1:19421/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\""} 400 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19421 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19421 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · converter — one Converter bean, for every route's parameters, and never a JSON body

The harness's `MealTypeConverter`, its class printed (its README line). **The seven with it joined** (the class-path layout, a fresh JVM):
`87ca7efc…`, as without it — none of the seven sends a meal type. Then a fresh JVM, the converter, `Who`, `Plain` and `Queries` joined:
**Who** — from a `String` to TiffinBox's `MealType` the conversion service now uses **`java.lang.String -> com.tiffinbox.MealType :
probe.web.MealTypeConverter@…`**, the same service object: Boot added the `Converter` bean to `mvcConversionService`, and the service finds a
converter for `MealType` itself before the one for every enum. `veg` and `Veg` → Ravi and Sunil, 0 WARN; blank → all four (the converter's
`null`); `lunch` → 400 and one WARN, the converter's own refusal in the same shape. **The same converter on the harness's routes**:
`Plain`'s `type=veg` → `type=VEG`, and a record's component (`Queries`, `mealType=veg`) → `VEG` — three controllers, TiffinBox's among
them. **JSON bodies**: TiffinBox's POST with `veg` → the same validation message (its meal type is a `String`); the harness's order — a
`MealType` component in JSON — **`veg` → 400**, and the WARN line carries Jackson's words, `JSON parse error: Cannot deserialize value of
type 'com.tiffinbox.MealType' from String "veg": not one of the values accepted for Enum class: [VEG, VEGAN, NON_VEG]` (backticks in the
original), while `VEG` → 200: Jackson reads bodies, and it did not ask the converter. Two WARN in all.

`.r-converter.out` · md5 `512ea7a10ec9311ba57d8183582b8067` · 3 of 3

```
the harness's converter, from its annotation on (this unit's line):
$ sed -n '/^@Component/,/^}/p' harness/probe/web/MealTypeConverter.java
  @Component
  public class MealTypeConverter implements Converter<String, MealType> {
  
      @Override
      public MealType convert(String source) {
          String s = source.trim();
          return s.isEmpty() ? null : MealType.valueOf(s.toUpperCase(Locale.ROOT));
      }
  }
the seven - the anchor on its class path, U.S. English, the converter joined, port 19422, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19422 --spring.main.sources=probe.web.MealTypeConverter
  listens on: 127.0.0.1:19422 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19422/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19422 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the same, a fresh JVM, the converter, Who, Plain and Queries joined, port 19422 - who binds a meal type now, then the meal type asked for as veg, Veg, empty and lunch:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19422 --spring.main.sources=probe.web.MealTypeConverter,probe.web.Who,probe.web.Plain,probe.web.Queries
  listens on: 127.0.0.1:19422 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19422/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s 'http://127.0.0.1:19422/probe/who/binds?route=/customers'
  GET /customers - TiffinBoxServer#customers, 1 parameter
    @RequestParam MealType mealType - its argument resolver: 1 of 28, RequestParamMethodArgumentResolver
      from a String, the conversion service uses: java.lang.String -> com.tiffinbox.MealType : probe.web.MealTypeConverter@…
  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object
  the JVM's locale: en_US
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19422/customers?mealType=veg'
  [{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19422/customers?mealType=Veg'
  [{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19422/customers?mealType='
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19422/customers?mealType=lunch'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [lunch]]
  the same converter on the harness's routes - a request parameter (Plain), a record's component (Queries):
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19422/probe/plain/meal?type=veg'
  type=VEG 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19422/probe/query?mealType=veg&maxPrice=130'
  query=CustomerQuery[mealType=VEG, maxPrice=130] 200 · WARN lines it added: 0
  JSON bodies - TiffinBox's own POST (its meal type a String, which the record checks), then Plain's order (its meal type a MealType), as veg and as VEG:
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"veg"}' http://127.0.0.1:19422/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\""} 400 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"mealType":"veg"}' http://127.0.0.1:19422/probe/plain/order
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/plain/order"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot deserialize value of type `com.tiffinbox.MealType` from String "veg": not one of the values accepted for Enum class: [VEG, VEGAN, NON_VEG]]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"mealType":"VEG"}' http://127.0.0.1:19422/probe/plain/order
  order=Order[mealType=VEG] 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 0
$ harness/shutdown.sh 19422 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19422 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · format — a format on one parameter, and Boot's for every date (A/B/A′)

Boot's metadata for `spring.mvc.format.date`: a `String`, no default, "Used for formatting of java.util.Date and java.time.LocalDate", and
its hint's two values, `dd/MM/yyyy` (an example) and **`iso`** ("ISO-8601 extended local date format"). The harness's three date routes.
**A** — U.S. English, `Dates` and `Who` joined: a `LocalDate` with no format gets Spring's default **formatter** — a converter that also
prints the value and can follow a locale — read off the app as `java.lang.String -> java.time.LocalDate:
…TemporalAccessorParser@…`, a parser holding **`Localized(SHORT,)`**: the short date style of whatever locale it is asked in (`locale`
reads the pattern each locale gives it); the parameter with `@DateTimeFormat` gets `java.lang.String -> @…DateTimeFormat java.time.LocalDate:
…Jsr310DateTimeFormatAnnotationFormatterFactory@…`. No format: `10/14/26` → `2026-10-14`, and the ISO form `2026-10-14` too. `dd/MM/yyyy`:
`14/10/2026` → `2026-10-14`, **the ISO form still accepted** (never "only this format"), `10/14/26` → 400 and one WARN. **B** — Boot's
key set to `iso` on the run line: the parser now holds **`Value(Year,4,10,EXCEEDS_PAD)'-'Value(MonthOfYear,2)'-'Value(DayOfMonth,2)`** —
ISO's year-month-day, the hint's "ISO-8601 extended local date format"; no format, `10/14/26` → **400**, ISO → 2026-10-14; the parameter's own pattern, `14/10/2026` →
2026-10-14 — unchanged. **A′** — A again: line for line A.

`.r-format.out` · md5 `b39dd8bc871b24026e1049e783e10013` · 3 of 3

```
  Boot's metadata (spring-boot-webmvc-4.1.1.jar) - spring.mvc.format.date · its type: String · its default: none · its description: Date format to use, for example 'dd/MM/yyyy'. Used for formatting of java.util.Date and java.time.LocalDate.
    the values its hint names: 2 · dd/MM/yyyy - Example date format. Any format supported by DateTimeFormatter.parse can be used. · iso - ISO-8601 extended local date format.
the harness's three date routes (this unit's line):
$ grep -n 'LocalDate on)' harness/probe/web/Dates.java
  25:    String plain(@RequestParam LocalDate on) {
  30:    String fmt(@RequestParam @DateTimeFormat(pattern = "dd/MM/yyyy") LocalDate on) {
  35:    String yy(@RequestParam @DateTimeFormat(pattern = "dd/MM/yy") LocalDate on) {
A - the anchor on its class path, U.S. English (this unit's run line), Dates and Who joined, port 19423 - what reads each route's date, then dates with no format, then with @DateTimeFormat(pattern = "dd/MM/yyyy"):
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19423 --spring.main.sources=probe.web.Dates,probe.web.Who
  listens on: 127.0.0.1:19423 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19423/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s 'http://127.0.0.1:19423/probe/who/binds?route=/probe/date'
  GET /probe/date - Dates#plain, 1 parameter
    @RequestParam LocalDate on - its argument resolver: 1 of 28, RequestParamMethodArgumentResolver
      from a String, the conversion service uses: java.lang.String -> java.time.LocalDate: org.springframework.format.datetime.standard.TemporalAccessorParser@…
        its parser's formatter: Localized(SHORT,)
  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object
  the JVM's locale: en_US
$ curl -s 'http://127.0.0.1:19423/probe/who/binds?route=/probe/date/fmt'
  GET /probe/date/fmt - Dates#fmt, 1 parameter
    @RequestParam @DateTimeFormat LocalDate on - its argument resolver: 1 of 28, RequestParamMethodArgumentResolver
      from a String, the conversion service uses: java.lang.String -> @org.springframework.format.annotation.DateTimeFormat java.time.LocalDate: org.springframework.format.datetime.standard.Jsr310DateTimeFormatAnnotationFormatterFactory@…
  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object
  the JVM's locale: en_US
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date?on=10/14/26'
  on=2026-10-14 · the JVM's locale: en_US 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date?on=2026-10-14'
  on=2026-10-14 · the JVM's locale: en_US 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date/fmt?on=14/10/2026'
  on=2026-10-14 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date/fmt?on=2026-10-14'
  on=2026-10-14 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date/fmt?on=10/14/26'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/date/fmt"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'on': Failed to convert value of type 'java.lang.String' to required type 'java.time.LocalDate'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam @org.springframework.format.annotation.DateTimeFormat java.time.LocalDate] for value [10/14/26]]
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19423 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19423 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same with Boot's date format set to iso (this unit's run line), Dates and Who joined, port 19424 - what reads a date with no format, then the same dates:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19424 --spring.mvc.format.date=iso --spring.main.sources=probe.web.Dates,probe.web.Who
  listens on: 127.0.0.1:19424 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19424/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s 'http://127.0.0.1:19424/probe/who/binds?route=/probe/date'
  GET /probe/date - Dates#plain, 1 parameter
    @RequestParam LocalDate on - its argument resolver: 1 of 28, RequestParamMethodArgumentResolver
      from a String, the conversion service uses: java.lang.String -> java.time.LocalDate: org.springframework.format.datetime.standard.TemporalAccessorParser@…
        its parser's formatter: Value(Year,4,10,EXCEEDS_PAD)'-'Value(MonthOfYear,2)'-'Value(DayOfMonth,2)
  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object
  the JVM's locale: en_US
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19424/probe/date?on=10/14/26'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/date"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'on': Failed to convert value of type 'java.lang.String' to required type 'java.time.LocalDate'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam java.time.LocalDate] for value [10/14/26]]
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19424/probe/date?on=2026-10-14'
  on=2026-10-14 · the JVM's locale: en_US 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19424/probe/date/fmt?on=14/10/2026'
  on=2026-10-14 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19424/probe/date/fmt?on=2026-10-14'
  on=2026-10-14 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19424/probe/date/fmt?on=10/14/26'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/date/fmt"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'on': Failed to convert value of type 'java.lang.String' to required type 'java.time.LocalDate'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam @org.springframework.format.annotation.DateTimeFormat java.time.LocalDate] for value [10/14/26]]
  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 0
$ harness/shutdown.sh 19424 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19424 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19423:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19423 --spring.main.sources=probe.web.Dates,probe.web.Who
  listens on: 127.0.0.1:19423 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19423/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s 'http://127.0.0.1:19423/probe/who/binds?route=/probe/date'
  GET /probe/date - Dates#plain, 1 parameter
    @RequestParam LocalDate on - its argument resolver: 1 of 28, RequestParamMethodArgumentResolver
      from a String, the conversion service uses: java.lang.String -> java.time.LocalDate: org.springframework.format.datetime.standard.TemporalAccessorParser@…
        its parser's formatter: Localized(SHORT,)
  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object
  the JVM's locale: en_US
$ curl -s 'http://127.0.0.1:19423/probe/who/binds?route=/probe/date/fmt'
  GET /probe/date/fmt - Dates#fmt, 1 parameter
    @RequestParam @DateTimeFormat LocalDate on - its argument resolver: 1 of 28, RequestParamMethodArgumentResolver
      from a String, the conversion service uses: java.lang.String -> @org.springframework.format.annotation.DateTimeFormat java.time.LocalDate: org.springframework.format.datetime.standard.Jsr310DateTimeFormatAnnotationFormatterFactory@…
  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object
  the JVM's locale: en_US
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date?on=10/14/26'
  on=2026-10-14 · the JVM's locale: en_US 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date?on=2026-10-14'
  on=2026-10-14 · the JVM's locale: en_US 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date/fmt?on=14/10/2026'
  on=2026-10-14 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date/fmt?on=2026-10-14'
  on=2026-10-14 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19423/probe/date/fmt?on=10/14/26'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/date/fmt"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'on': Failed to convert value of type 'java.lang.String' to required type 'java.time.LocalDate'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam @org.springframework.format.annotation.DateTimeFormat java.time.LocalDate] for value [10/14/26]]
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19423 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19423 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

## 4 · binder — one controller's own rules (`@InitBinder`), and its twin without them

`Binder`'s `@InitBinder` method, printed: `StringTrimmerEditor(true)` for every `String`, `ShortMealCodes` for `MealType` — two property
editors (the JavaBeans way to read a value from text) registered on this controller's data binder before each request. `Binder` and its
twin `Plain` on one JVM, **the converter joined too** (the anchor's class-path line; nothing here follows a locale). A name with two spaces
either side (`%20%20Ravi%20%20`): `Binder` → `[Ravi]`, `Plain` → `[  Ravi  ]`. A blank name (`%20%20`): `Binder` → 400, `Required request
parameter 'name' … is present but converted to null` (the trimmer made it `null`); `Plain` → `[  ]`. Meal types: `Binder`'s `v` → `VEG`,
and **`VEG` → 400, `not a short meal code: VEG`** — the binder's editor is asked before the conversion service, so it beats the converter in
its own controller; `Plain`'s `veg` → `VEG` (the converter), `v` → 400 (no such constant). Three WARN lines.

`.r-binder.out` · md5 `943ea154322ce858fac654dbc51ccbbb` · 3 of 3

```
the harness's binder - its @InitBinder method (this unit's line):
$ sed -n '/^    @InitBinder/,/^    }/p' harness/probe/web/Binder.java
      @InitBinder
      void rules(WebDataBinder binder) {
          binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
          binder.registerCustomEditor(MealType.class, new ShortMealCodes());
      }
Binder and its twin Plain, the converter joined too, the anchor on its class path (its README's line), port 19425, a fresh JVM - a name with two spaces either side, a blank name, then meal types:
$ cd .harness/anchor && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19425 --spring.main.sources=probe.web.Binder,probe.web.Plain,probe.web.MealTypeConverter
  listens on: 127.0.0.1:19425 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19425/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19425/probe/binder/name?name=%20%20Ravi%20%20'
  name=[Ravi] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19425/probe/plain/name?name=%20%20Ravi%20%20'
  name=[  Ravi  ] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19425/probe/binder/name?name=%20%20'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/binder/name"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MissingServletRequestParameterException: Required request parameter 'name' for method parameter type String is present but converted to null]
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19425/probe/plain/name?name=%20%20'
  name=[  ] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19425/probe/binder/meal?type=v'
  type=VEG 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19425/probe/binder/meal?type=VEG'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/binder/meal"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'type': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; not a short meal code: VEG]
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19425/probe/plain/meal?type=veg'
  type=VEG 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19425/probe/plain/meal?type=v'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/plain/meal"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'type': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [v]]
  WARN lines in this run's log, at Boot's default level: 3 · ERROR lines: 0
$ harness/shutdown.sh 19425 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19425 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · record — a record from a query string

The three records, printed. **Who binds one**: an unannotated `CustomerQuery q` → resolver **28 of 28**, `ServletModelAttributeMethodProcessor`;
`@ModelAttribute CustomerQuery q` → **7 of 28, the same class** — with no annotation, a parameter that is not a simple value is a model
attribute, taken by the last of the adapter's resolvers. Bound through its constructor: `mealType=VEG&maxPrice=130` →
`CustomerQuery[mealType=VEG, maxPrice=130]`; a missing component → `null`; `@ModelAttribute` → the same. `mealType=veg&maxPrice=abc` →
400, one WARN: **`MethodArgumentNotValidException … with 2 errors`** — both `typeMismatch`: **binding failures, though the exception's name
says "not valid"**; nothing in `CustomerQuery` is validated. **`@BindParam("type")`**: `type=VEG` fills `mealType`; `mealType=VEG` no longer
does (`null`). **A rule beside a binding failure** — `CheckedQuery`, `@Min(1)` on `maxPrice`, `@Valid`, a `BindingResult` beside it (the
route answers 200 and prints the errors): `maxPrice=0` → `field errors: 1 · maxPrice [0] Min, a rule broken`; **`mealType=veg&maxPrice=0` →
`field errors: 1 · mealType [veg] typeMismatch, a binding failure`** — the conversion failure arrives in the same `BindingResult` as
validation's errors, and with it present Spring MVC does not validate the record at all: the `0` goes unchecked. One WARN in all.

`.r-record.out` · md5 `baad567a3dd84996ffd3601262881c6b` · 3 of 3

```
the harness's three records (this unit's line):
$ grep -n '^    record ' harness/probe/web/Queries.java
  26:    record CustomerQuery(MealType mealType, Integer maxPrice) {}
  28:    record NamedQuery(@BindParam("type") MealType mealType, Integer maxPrice) {}
  30:    record CheckedQuery(MealType mealType, @Min(1) Integer maxPrice) {}
Queries and Who joined, the anchor on its class path, U.S. English, port 19426, a fresh JVM - who binds a record, with no annotation and with @ModelAttribute:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19426 --spring.main.sources=probe.web.Queries,probe.web.Who
  listens on: 127.0.0.1:19426 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19426/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s 'http://127.0.0.1:19426/probe/who/binds?route=/probe/query'
  GET /probe/query - Queries#query, 1 parameter
    CustomerQuery q - its argument resolver: 28 of 28, ServletModelAttributeMethodProcessor
  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object
  the JVM's locale: en_US
$ curl -s 'http://127.0.0.1:19426/probe/who/binds?route=/probe/query/model'
  GET /probe/query/model - Queries#model, 1 parameter
    @ModelAttribute CustomerQuery q - its argument resolver: 7 of 28, ServletModelAttributeMethodProcessor
  the conversion service: the bean mvcConversionService, org.springframework.boot.autoconfigure.web.format.WebConversionService · the one the adapter gives every data binder: yes, the same object
  the JVM's locale: en_US
  a record bound - both components, one missing, the same with @ModelAttribute, then two values that cannot become their types:
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19426/probe/query?mealType=VEG&maxPrice=130'
  query=CustomerQuery[mealType=VEG, maxPrice=130] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19426/probe/query?maxPrice=130'
  query=CustomerQuery[mealType=null, maxPrice=130] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19426/probe/query/model?mealType=VEG&maxPrice=130'
  query=CustomerQuery[mealType=VEG, maxPrice=130] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19426/probe/query?mealType=veg&maxPrice=abc'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/query"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MethodArgumentNotValidException: Validation failed for argument [0] in java.lang.String probe.web.Queries.query(probe.web.Queries$CustomerQuery) with 2 errors: …
      the field errors it lists: 2, sorted by field - each: its field, the value it was given, its code (the last of its codes); the other codes, its arguments and its default message not shown:
        maxPrice [abc]: typeMismatch
        mealType [veg]: typeMismatch
  @BindParam - a component bound from a parameter of another name:
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19426/probe/query/named?type=VEG&maxPrice=130'
  query=NamedQuery[mealType=VEG, maxPrice=130] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19426/probe/query/named?mealType=VEG&maxPrice=130'
  query=NamedQuery[mealType=null, maxPrice=130] 200 · WARN lines it added: 0
  a record with a rule, @Min(1) on maxPrice, and a BindingResult beside it - the rule broken, then a meal type that cannot become its type beside the same broken rule:
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19426/probe/query/checked?mealType=VEG&maxPrice=0'
  query=CheckedQuery[mealType=VEG, maxPrice=0] · field errors: 1 · maxPrice [0] Min, a rule broken 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19426/probe/query/checked?mealType=veg&maxPrice=0'
  query=CheckedQuery[mealType=null, maxPrice=0] · field errors: 1 · mealType [veg] typeMismatch, a binding failure 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19426 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19426 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · locale — the JVM's locale, for a date with no format (A/B/A′; C and D, labelled)

**A** — U.S. English: `Dates` prints the short date pattern this request is read with, **`M/d/yy`**; `10/14/26` → `2026-10-14`; `14/10/26`
→ 400, one WARN. **B** — U.K. English, the run line's options before `-cp`: **`dd/MM/y`** — day, month, and a one-letter year, which takes
the year as written; `10/14/26` → 400; **`14/10/26` → `on=0026-10-14`, 200, 0 WARN lines** — the year twenty-six, without a word. **A′** —
line for line A. **C (labelled)** — U.K. English, `@DateTimeFormat(pattern = "dd/MM/yy")`: `14/10/26` → `2026-10-14` (`yy`, two digits).
**D (labelled)** — a U.S. English JVM, the request naming `Accept-Language: en-GB`: this request's locale `en_GB`, `dd/MM/y`, and
`14/10/26` → **`0026-10-14`** — the default formatter reads the request's locale (Spring MVC's, from `Accept-Language`), the JVM's only
when the request names none, as curl's do here.

`.r-locale.out` · md5 `1d9f878f49a0e26ad41a809c23ff11f8` · 3 of 3

```
A - the anchor on its class path, U.S. English (this unit's run line), Dates joined, port 19427 - the short date pattern, then two dates with no format:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19427 --spring.main.sources=probe.web.Dates
  listens on: 127.0.0.1:19427 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19427/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19427/probe/date/pattern
  the JVM's locale: en_US · this request's: en_US · its short date pattern: M/d/yy 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19427/probe/date?on=10/14/26'
  on=2026-10-14 · the JVM's locale: en_US 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19427/probe/date?on=14/10/26'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/date"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'on': Failed to convert value of type 'java.lang.String' to required type 'java.time.LocalDate'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam java.time.LocalDate] for value [14/10/26]]
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19427 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19427 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, U.K. English (this unit's run line), port 19428:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=GB -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19428 --spring.main.sources=probe.web.Dates
  listens on: 127.0.0.1:19428 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19428/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19428/probe/date/pattern
  the JVM's locale: en_GB · this request's: en_GB · its short date pattern: dd/MM/y 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19428/probe/date?on=10/14/26'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/date"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'on': Failed to convert value of type 'java.lang.String' to required type 'java.time.LocalDate'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam java.time.LocalDate] for value [10/14/26]]
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19428/probe/date?on=14/10/26'
  on=0026-10-14 · the JVM's locale: en_GB 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19428 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19428 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19427:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19427 --spring.main.sources=probe.web.Dates
  listens on: 127.0.0.1:19427 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19427/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19427/probe/date/pattern
  the JVM's locale: en_US · this request's: en_US · its short date pattern: M/d/yy 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19427/probe/date?on=10/14/26'
  on=2026-10-14 · the JVM's locale: en_US 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19427/probe/date?on=14/10/26'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/date"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'on': Failed to convert value of type 'java.lang.String' to required type 'java.time.LocalDate'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam java.time.LocalDate] for value [14/10/26]]
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19427 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19427 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - U.K. English, port 19428, a fresh JVM - the route that names its pattern, dd/MM/yy:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=GB -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19428 --spring.main.sources=probe.web.Dates
  listens on: 127.0.0.1:19428 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19428/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19428/probe/date/yy?on=14/10/26'
  on=2026-10-14 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19428 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19428 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
D (labelled) - U.S. English, port 19427, a fresh JVM - the request itself in U.K. English, by its Accept-Language header (this unit's line):
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19427 --spring.main.sources=probe.web.Dates
  listens on: 127.0.0.1:19427 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19427/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Accept-Language: en-GB' http://127.0.0.1:19427/probe/date/pattern
  the JVM's locale: en_US · this request's: en_GB · its short date pattern: dd/MM/y 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Accept-Language: en-GB' 'http://127.0.0.1:19427/probe/date?on=14/10/26'
  on=0026-10-14 · the JVM's locale: en_US 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19427 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19427 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 7 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s eight lines, then `SOLUTION.md`'s three, read from the files and run as written, one after the other in ONE shell a
viewer could have (`env -i`, `/bin/bash --noprofile --norc`, started in this folder). As shipped — the converter's class compiled onto the
class path, no `--spring.main.sources`: **`GET /customers?mealType=veg: 400 · customers: 0 · names: none`**, one WARN line in its log, the
shell back in this folder, 19429 free; the solution's line (the same, `--spring.main.sources=probe.web.MealTypeConverter` added after the
port): **`GET /customers?mealType=veg: 200 · customers: 2 · names: Ravi Sunil`**, 0 WARN lines, the shell in this folder, 19429 free; the
copy's own token 0 times in each log.

`.r-exercise.out` · md5 `de0f821316619d2b9ef129492ca5a00c` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 8 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
  $ javac -parameters -d .harness/mine/hc -cp ".harness/mine/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/MealTypeConverter.java
  $ (cd .harness/mine/anchor && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19429 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19429/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' 'http://127.0.0.1:19429/customers?mealType=veg'); ../../../harness/shutdown.sh 19429 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"name":"[^"]*"' ../got.json | wc -l | tr -d ' ') && f=$(grep -o '"name":"[^"]*"' ../got.json | sed 's/^"name":"//; s/"$//' | paste -sd' ' -) && echo "GET /customers?mealType=veg: $s · customers: $n · names: ${f:-none}")
  exit 0 · what they printed:
    GET /customers?mealType=veg: 400 · customers: 0 · names: none
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1 · listening on 19429 now: 0
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ (cd .harness/mine/anchor && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19429 --spring.main.sources=probe.web.MealTypeConverter > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19429/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' 'http://127.0.0.1:19429/customers?mealType=veg'); ../../../harness/shutdown.sh 19429 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"name":"[^"]*"' ../got.json | wc -l | tr -d ' ') && f=$(grep -o '"name":"[^"]*"' ../got.json | sed 's/^"name":"//; s/"$//' | paste -sd' ' -) && echo "GET /customers?mealType=veg: $s · customers: $n · names: ${f:-none}")
  exit 0 · what they printed:
    GET /customers?mealType=veg: 200 · customers: 2 · names: Ravi Sunil
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19429 now: 0
```

## Exercise

**Your turn:** the README's run answers veg with a four hundred. Add the harness converter to its sources, ask again, and count the
customers. `exercise/README.md` has the commands (copy `anchor/` with a token of its own, build the jar offline, extract it, compile the
harness's converter); its last line, in a subshell, starts TiffinBox on 19429 with the converter's class on its class path, asks for
`?mealType=veg`, stops it, waits for its JVM and prints — as shipped — `GET /customers?mealType=veg: 400 · customers: 0 · names: none`.
Done is `GET /customers?mealType=veg: 200 · customers: 2 · names: Ravi Sunil`. Measured answer: `exercise/solution/SOLUTION.md` (the
README's two `export` lines, then the same line with `--spring.main.sources=probe.web.MealTypeConverter`), run in the same shell. Run
`./receipts.sh` once first on a fresh clone.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-15) |
|---|---|---|---|
| 14 | The converter, dates, binder and record binding on `12/after` | s12h + harness | **on `12/after`, the anchor's own jar extracted:** the converter fixes `?mealType=veg` (TiffinBox's route, a harness parameter, a record's component) and never a JSON body (`converter`); `14/10/26` under `en_GB` → `0026-10-14`, 200, 0 WARN (`locale` B); `@DateTimeFormat(pattern)` accepts ISO too; `iso` refuses `10/14/26` (`format`); the binder's editor beats the converter in its controller only (`binder`); the record's 400 is `MethodArgumentNotValidException` with two `typeMismatch` binding failures (`record`) |
| 16 | Every exercise as viewers run it (one shell; Java 23) | end states measured on sketches | **one `env -i` shell: `400 · customers: 0`, then `200 · customers: 2 · names: Ravi Sunil`** (`exercise`); see the runs of record for Java 23 and `zsh -f` |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **"A JSON body's `"veg"` is still Jackson's 400"** (brief READ FIRST 12, the unit block): on this tree **TiffinBox's own body is
  validation's 400** — `{"mealType":"must match \"VEG|NON_VEG|VEGAN\""}`, 0 WARN — because the record holds its meal type as a `String`
  since the validation lesson. Jackson's 400 is measured where a body component is a `MealType` (the harness's `Order`): there the
  converter is present and not asked. The converter reaches neither.
- **"A default date format depends on the JVM's locale"** (READ FIRST 11): sharpened — it depends on **the request's locale**, which is the
  JVM's only when the request names no language. An `en_US` JVM reads `14/10/26` as the year twenty-six for a request that sends
  `Accept-Language: en-GB` (`locale` D): a client can choose the year.
- **The record's binding failure skips validation** (beyond the brief; the validation lesson's hand-off asked what one `BindingResult`
  holds): with a `typeMismatch` present, a broken `@Min` on another component is not reported (`record`).
- **`@BindParam`** (the brief's AMENDMENT §6) renames a record's component: the component's own name then binds nothing (`null`).
- **Boot 4.1.1's conversion service** is `org.springframework.boot.autoconfigure.web.format.WebConversionService` (the class `Who` read;
  in `spring-boot-autoconfigure-4.1.1.jar`), while the `spring.mvc.format.date` key's metadata is in `spring-boot-webmvc-4.1.1.jar`
  (`format`'s `bmeta`).
- **"The short date style" is read off Spring's own parser** (beyond the brief): `Localized(SHORT,)` for a date with no format, and ISO's
  year-month-day once Boot's key says `iso` (`format`).
- **A date with a pattern refuses the U.S. short form under any locale** (`format` A: `10/14/26` → 400 with `dd/MM/yyyy`), and `yyyy` does
  not take two digits — measured as 400 for `10/14/26`; `dd/MM/yy` is the two-digit pattern (`locale` C).

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block run alone on copies of the published captures and of this
  unit's files, one fault per plant (`plants.py`, this unit's scratch folder) — **121 plants, 121 stops, each stop's message naming the
  planted check**; the unplanted copies pass under /bin/bash 3.2 and bash 5.3 with no shell error. Three plants change a command in the
  script and in its README alike (the iso line with a second option, the U.K. English line with another JVM option, the language line
  with another path), so that the derivation check alone must stop the run; three plant the exercise's preamble (S2.1): a SOLUTION.md
  without the README's two exports, with another JDK's, and both files exporting a JAVA_HOME the script does not — each refused. Three
  plants first missed and taught the suite: one changed a line no check reads (B's ISO answer beside a pattern — hashed, not spoken), one
  changed one of two locale lines in the same block, where a real fault changes both, and one aimed at A′'s parser line hit B's once
  `Who` ran in B too.
- **The first identity-hash check matched a path.** The last hygiene check first looked for `@` and hexadecimal digits after any letter or
  digit, and stopped the first development run on the exercise's printed `openjdk@25` (Homebrew's JDK folder). An identity hash follows a
  class's name, which starts with a capital letter: the mask (`ihm`, `fwarn`) and the check now look for that, and the plant of a real hash
  still stops the run.
- **The binder's `sed` range first matched the Javadoc** (`/@InitBinder/` is in the class comment too): the range now anchors on the
  method's indentation, `/^    @InitBinder/`, and the check counts the method's five lines.
- **The formatter, read rather than computed.** The first published `format` showed which parser a date gets, and `locale` the short
  date pattern the harness itself computed for the request's locale — so "Spring's formatter reads the short date style" rested on the
  harness's arithmetic. `Who` now reads the `java.time` formatter Spring's parser holds — `Localized(SHORT,)` in A and A′, ISO's
  year-month-day in B, where `Who` now runs too — and `format` was hashed again (`a2789c2a…` → `b39dd8bc…`); the other six captures, whose
  `Who` answers name no parser, stayed byte for byte the same.
- **How the hashes were made:** two development passes (a copy of this script running each capture once, `.r-dev.sh`, deleted) made the
  same seven md5s the first full run (`bash receipts.sh`, 348 s) then made 3/3 and stopped on "no published hash", as designed; those went
  into `receipts.md5`. `format`'s second hash was made by a development pass and then by a full run, which stopped on its `DIFFERS` line, as
  designed, before it went in; every run of record reproduced all seven — so each hash was made by two scripts' runs at different times.
- **The probe's sketch and this tree agree**, with the departures above: `veg` → 400 by `Enum.valueOf`'s exact name; the converter's
  parameters; the editor beating the converter in its controller; the record's two errors; `0026-10-14` under `en_GB`;
  `@DateTimeFormat(pattern)` accepting ISO; `iso` accepting ISO alone — each now a line of this unit's own captures.

## For Section 3 — and RED

- **The anchor is untouched**, and `anchor` points at `../c6-unit12/after` (= `c6-tiffinbox`, Section 2's end). Nothing here reads
  `c6-tiffinbox`.
- **Conversion failures are Boot's opaque 400** — `veg`, `lunch`, a date that does not parse, a record's `typeMismatch`: Boot's body
  (`timestamp`, `status`, `error`, `path`), the reason only in Spring MVC's WARN line (one per request). *Boot's Default Error Response* and
  *ProblemDetail and RFC 9457* own the body; *@ExceptionHandler and @RestControllerAdvice* can answer `MethodArgumentTypeMismatchException`
  and `MethodArgumentNotValidException` (the record's — a binding failure, though its name says "not valid").
- **Locale:** every JVM whose answer can follow a locale is pinned here; the validation lesson's own captures print Hibernate Validator's
  messages under the JVM's default locale unpinned (`../c6-unit12/`, its `answer` and `typo` captures: `en_US` on this Mac) — for RED part
  B, a viewer whose JVM defaults to another language with a Hibernate Validator bundle (German, say) would get other words and another md5.
- **Masks to carry:** identity hashes after a class name (`ihm`); the field-error filter (`fwarn`) for `MethodArgumentNotValidException`
  lines — codes, not default messages (Spring's `typeMismatch` message is long and English; a rule's message follows the locale).
- **Ports:** 19420-19429 are this unit's, all ten bound.
- **/bin/bash 3.2:** pattern and replacement in variables for every `${x/pattern/replacement}` (the slash trap), and no `case` inside `$( )`.

# c6-unit11 — Content Negotiation

Course 6 · Spring Web MVC · Section 2 (Controllers and Binding), its sixth unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5 — its XML module 3.1.5, Woodstox 7.1.1, stax2-api 4.2.2),
2026-10-15. Since the request-mapping lesson TiffinBox answers a request for XML with **406 Not Acceptable** and an empty body — before it,
TiffinBox's own handler sent JSON whatever the `Accept` header asked (`../c6-unit06/`, `verbs`: an XML-only Accept, `200 application/json`
before, `406` after). This unit asks TiffinBox for its answers by the **`Accept`** header — the request header that names the formats a
client takes — then adds one dependency line, Jackson's XML module, to a **copy**, and measures what changes: a seventh message converter,
the same routes answering JSON or XML by what the client asks, XML both ways (an XML body read, a `201` and its `Location` written as XML),
error bodies in XML, a browser's `Accept` header getting XML it never meant to ask for, Actuator keeping its JSON, and the `format`
parameter Boot leaves off. That is **content negotiation**: the server picking its answer's format from what the client says it takes.

**No anchor change (brief ⚑2, ⚑13).** `anchor` is the link to `../c6-unit10/after` — the responses lesson's frozen tree, JSON-only — read
and copied under `.harness/anchor`, never built in place. `c6-tiffinbox` is neither read nor touched here: the validation lesson changes it.
**The copy** is the same tree copied under `.harness/xml`, with this unit's patch, `harness/xml.patch` — one line in
`tiffinbox-web/pom.xml`, no version (Boot's parent manages it: Jackson's BOM, 3.1.5):

```
    <dependency><groupId>tools.jackson.dataformat</groupId><artifactId>jackson-dataformat-xml</artifactId></dependency>
```

No native build and no Docker: the brief keeps both to the chain units (⚑16), and nothing here changes what the binary or the image
would hold of TiffinBox's own tree.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 8 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) No GraalVM and no
Docker are needed. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a
process group of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a group,
and one run's clean-up would stop the other's JVMs (brief S2.4).

**Runs of record (2026-10-15, this script as committed):** **420 s under `bash receipts.sh`** (Homebrew bash 5.3.9, this folder, its
own process group: exit 0, all 8 = published, every check passed; load averages 3-10), **700 s under `./receipts.sh`** (/bin/bash 3.2.57:
exit 0, all 8 = published, every check passed, no shell error; load averages up to 34, another unit's builds running beside it) and
**701 s from a sealed fresh clone** (`git clone` of tiffinbox-java at fb9fae2, this unit's 9 files put in as git would take them, the
clone's `c6-unit10/after` the working tree's to the byte; `env -i`, a `HOME` of its own whose `.mavenrc` points every Java proxy at a
refusing port, Maven settings sending every repository to a `file://` copy of Central's files made from this unit's `.m2-demo` — 4,372
files — the proxy variables at the same refusing port, `/bin/bash` 3.2, a process group of its own: exit 0, all 8 = published; **516
artifacts, every one from the `file://` copy** — 512 for the anchor's first build, then the XML module's four for the copy's
(`jackson-dataformat-xml-3.1.5` and `woodstox-core-7.1.1`, `.pom` and `.jar` each); those two builds said `offline: no`, as a fresh clone's
must, and every capture's build `offline: yes`, 0 download lines). Before each run in this folder, `.m2-demo` was re-seeded from
`_research/m2-seed-s2/` alone: every build said `offline: yes`. **The exercise as viewers run it**, beyond the capture: the README's last
line alone in an `env -i` `/bin/bash` shell without the exports — its `java` 23.0.1 — ends with `exit 1` and prints no line (`wait $!`
hands back the JVM's exit code; its log: `UnsupportedClassVersionError`), the shell left in `c6-unit11/`; README then SOLUTION in one
`env -i` `zsh -f` shell → `GET /customers/Ravi: 200 · application/json · root element: none`, then `GET /customers/Ravi: 200 ·
application/xml;charset=UTF-8 · root element: Customer`, exit 0 each, the shell in `c6-unit11/`; 19409 free after, the copy's token 0
times in its log.

Published hashes: anchor `8c3f416bf55c4262614d846035b95019` · xml `36c9dd5ebf1b72aa4997ecd15ac82ca6` · accept `baf082d6e3c8c715da7d890a41a0a5c4` · shapes `0d52b87aa35591ced80cd5045c2dc0ea` · browser `8b99ad4ca60e0ae50594e6c04d1f7ef9` · actuator `9ed429a10eb3bf2bf2a790be9cd98691` · param `9556251ae208254375cd107188685f2d` · exercise `4aef7d7d923f3112d887343d4b63005e`.

## The commands this unit adds

`anchor/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but eleven, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
cd .harness/xml && patch -s -p1 < ../../harness/xml.patch && diff -U0 ../../anchor/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d
curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:18431/customers/Ravi
curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' http://127.0.0.1:18431/customers/Ravi
curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' 'http://127.0.0.1:18431/customers/Ravi?format=xml'
curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Accept: application/xml' -H 'Content-Type: application/xml' --data '<Customer><name>Asha</name><mealsPerDay>2</mealsPerDay><pricePerMeal>110</pricePerMeal><mealType>VEG</mealType></Customer>' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/xml' --data '<Customer><name>Asha</name><mealsPerDay>2</mealsPerDay><pricePerMeal>110</pricePerMeal><mealType>VEG</mealType></Customer>' http://127.0.0.1:18431/customers
curl -s http://127.0.0.1:18431/probe/formats
curl -s http://127.0.0.1:18431/probe/formats/strategies
curl -s -o /dev/null -v http://127.0.0.1:18431/customers 2>&1 | grep '^> Accept' | tr -d '\r'
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.mvc.contentnegotiation.favor-parameter=true
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.mvc.contentnegotiation.default-content-types=application/json
```

- **The patch line** makes the copy (`xml`): it applies `harness/xml.patch` in `.harness/xml` and prints the copy's web POM against the
  anchor's, `diff -U0`, its file names cut.
- **The GET line** prints an answer, then its status and its `Content-Type` (`[]` when the answer has none: an empty body). Every GET a
  capture sends is this line with its port, its path and its `Accept` value swapped — or, with no value, no `Accept` header at all (curl
  then sends its own, `*/*`: the verbose line). The second and third lines are it with a browser's `Accept` header and with a format
  parameter instead; the script asserts both are exactly that.
- **The XML POST** is the responses lesson's Location line (the anchor README's) with its JSON `Content-Type` made XML's, an `Accept:
  application/xml` added, and its body Asha's as XML elements — asserted; the next line is the same without the `Accept` header.
- **The harness's two questions** (`/probe/formats`, `xml`; `/probe/formats/strategies`, `browser` D and E, `param` C), **curl's own `Accept`** (verbose, its request's `Accept` line alone, the carriage
  return curl prints dropped: `accept`), and **two run lines**, the anchor's with one option each — `favor-parameter` (`param` B) and a
  default content type (`browser` D, run on the class path with the harness joined, the option asserted to be this line's).

**A browser's `Accept` header, typed, sent by curl.** No browser runs here (contract R.86 is the CORS and cache lessons'): the line sends
the value a browser sends when it asks for a page — HTML first, then XHTML, then XML at `q=0.9`, anything else at `q=0.8` — and
`browser` says so on its label.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s2/`
alone — 5,837 files, no `com/tiffinbox`, the XML module's four artifacts among them (`jackson-dataformat-xml-3.1.5`, `woodstox-core-7.1.1`
and their POMs; `stax2-api-4.2.2` was in Section 1's seed) — and re-seeded so before each run of record. **Nothing was downloaded** for this
unit: every build said `offline: yes`. A fresh clone's `.m2-demo` is empty (git ignores it): the first two builds — the anchor's and the
copy's, before any capture — fill it from Maven Central and say `offline: no`; every capture's build then says `offline: yes`. No Docker,
no GraalVM. **At run time** every request goes to `127.0.0.1`.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input. Every
capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that served and every file this
unit ships: 0 everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log. No capture runs at TRACE, so the two
loggers the anchor's `application.yaml` holds at INFO (`Http11InputBuffer`, `HandlerMethod`) are kept and not re-measured: the copy adds a
library, no parameter. The exercise makes a token of its own (`openssl rand -hex 13`: 26 hexadecimal digits), counted 0 times in its own log
and never printed.

## The folders, the names and the ports

- `anchor` — the link to `../c6-unit10/after`. `.harness/anchor` — it, copied with a config tree, built and extracted (`anchor`);
  `.harness/xml` — the copy, `harness/xml.patch` applied, built and extracted (`xml`); `.harness/hc` — the harness's classes, compiled
  against the anchor's own jar with `-parameters`; `.harness/pre`, `.harness/prex` — the two pre-capture builds; `.harness/mine` — the
  exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`), joined by `--spring.main.sources` on the
  extracted jar's class path: `harness/probe/web/Formats.java` names no XML class, so it compiles against the anchor and runs beside both
  trees. `/probe/formats` reads, off the running application, Spring MVC's `RequestMappingHandlerAdapter`'s message converters in order,
  which of them can write a `com.tiffinbox.Customer` for five media types (`canWrite`), the XML converter's mapper and the beans of its
  class, and Boot's own condition report (`ConditionEvaluationReport`) for every configuration whose name holds `Xml`.
  `/probe/formats/strategies` asks Spring MVC's content negotiation manager (the bean `mvcContentNegotiationManager`) which strategies
  it asks, in order, to learn what a request wants — the `Accept` header's, a query parameter's, a fixed default — and which format
  values it maps to media types.
  `/probe/formats/json` and `/probe/formats/both` return Ravi through TiffinBox's own `CustomerRepository`, one route naming `produces =
  application/json`, the other `produces = {application/json, application/xml}` (`browser` E). `harness/shutdown.sh` — POST `/shutdown`
  with the token read from its file (the binding lesson's, copied unchanged). `harness/xml.patch` — the copy's one line.
- **Ports** (brief ⚑1, 19400-19409): the anchor 19400 · the copy 19401 · the copy with the harness 19402 · the anchor with the harness
  19403 · the copy with `favor-parameter` (B, and C with the harness) 19404 · the copy with `default-content-types` and the harness 19405
  · the exercise 19409; 19406-19408 are never
  bound. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free and never bound; a run that listens on 8080 is killed and the
  script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character token]` (its
   length read off the token); this folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`. A last
   check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's process line, a log time, an
   unmasked timestamp (JSON or XML), an unmasked date on Boot's HTML error page, a `GMT` date, a ` CET `/` CEST ` zone, a thread number, a
   stack frame, `:8080`, a carriage return, or a command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `gsub`): in JSON `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…`; **in XML** `<timestamp>…</timestamp>` (S1.5's addition) — in every answer printed and in the seven, which are hashed
   after it (two lines changed: `/nowhere`'s and GET /shutdown's). **Its form** (`tsform`) is printed beside the seven: the date and time,
   every digit → `d`, the zone kept (`Z`).
3. **Boot's HTML error page** (`tsmask`): the date and time in its `<div id='created'>` → `…` — it holds this Mac's time and time zone.
   The page's `Content-Length` is never printed (it moves with the zone's name).
4. **Log lines** (`logl`): from their logger on, as the log prints the logger — `.w.s.m.s.DefaultHandlerExceptionResolver` is Spring MVC's,
   Boot's own lines are labelled Boot's (`Boot's first line`) — an identity hash after `@` → `@…`. A request's WARN lines are those the
   log gained between two points where it stopped growing (`wans`): each answer's last line ends with `· WARN lines it added: N`.
5. **curl's verbose request** (`accept`): its `> Accept` line alone (grep), its carriage return dropped (`tr`).
6. **The harness's answer** is printed whole; its condition rows are sorted by class name (a `TreeMap`), its converters in the adapter's
   order.
7. **A URL that holds a character the shell reads** (`;`, `?`, `&`, `*`, `{`, `}`, a space) is single-quoted on the command line, and
   every body is single-quoted, so the printed command is the one that ran. A Location is followed only when it is on `127.0.0.1`.
8. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the exercise's
shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox JVM or Maven left,
deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured** on this script (2026-10-15), started as a terminal starts its foreground job (SIGINT at its default, a process group of its
own — from a script, `python3 -c 'import os, signal, sys; signal.signal(signal.SIGINT, signal.SIG_DFL); os.setpgrp();
os.execvp(sys.argv[1], sys.argv[1:])' ./receipts.sh`): SIGINT to its process group 46 s in, while the first capture's TiffinBox JVM
answered (4 processes in the group, 1 of them that JVM): **exit 130** 0.3 s later; 5 s later 0 processes in the group and 0 anywhere naming
this folder; 19400-19409, 8080 and 18425 free; no `.r-lock`, no unfinished capture run; the published captures unchanged.

## 1 · anchor — today's answer to XML: 406

TiffinBox as the responses lesson left it, built offline. **The seven**, on a fresh JVM: `87ca7efc…` (masked) — as on that lesson's own
tree. Then Ravi asked for **as JSON** → 200, JSON; **as XML** → **`406`**, **an empty body** (`Content-Type: []`) and one WARN line —
Spring MVC's `DefaultHandlerExceptionResolver`, `HttpMediaTypeNotAcceptableException: No acceptable representation`; **as HTML**
(`text/html`) → 406 again, now with **Boot's own HTML error page** — the Whitelabel page, its date masked: Boot's error controller answers
a `text/html` request with that page, and for an XML-only request it writes nothing. A name nobody has, asked for as XML → **404, empty**:
the client takes XML alone, and the anchor writes none. **A body sent as XML** (this unit's XML POST) → **`415`** — `Content-Type 'application/xml;charset=UTF-8' is not supported` — so
TiffinBox neither writes nor reads XML. **The last course's scrape**, the anchor README's two lines, re-run: curl's own request →
`text/plain;version=0.0.4;charset=utf-8`; `Accept: application/openmetrics-text; version=1.0.0` → `application/openmetrics-text;version=1.0.0`
— Actuator's prometheus endpoint has chosen its format by `Accept` since the last course: content negotiation, met before. 3 WARN lines:
the two 406s and the 415.

`.r-anchor.out` · md5 `8c3f416bf55c4262614d846035b95019` · 3 of 3

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
  and its jar extracted (the README's line) - the class path the harness runs on:
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the seven - the anchor, the README's run line, port 19400, a fresh JVM (curl asks for */*):
$ cd .harness/anchor && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19400
  listens on: 127.0.0.1:19400 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19400/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19400 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the anchor again, a fresh JVM, port 19400 - one customer, asked for as JSON, as XML and as HTML (this unit's GET line, its Accept header's value swapped):
$ cd .harness/anchor && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19400
  listens on: 127.0.0.1:19400 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19400/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/json' http://127.0.0.1:19400/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19400/customers/Ravi
   · 406 · Content-Type: [] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/html' http://127.0.0.1:19400/customers/Ravi
  <html><body><h1>Whitelabel Error Page</h1><p>This application has no explicit mapping for /error, so you are seeing this as a fallback.</p><div id='created'>…</div><div>There was an unexpected error (type=Not Acceptable, status=406).</div></body></html> · 406 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
  a name nobody has, asked for as XML:
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19400/customers/Nobody
   · 404 · Content-Type: [] · WARN lines it added: 0
  a customer sent as XML (this unit's XML POST):
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Accept: application/xml' -H 'Content-Type: application/xml' --data '<Customer><name>Ira</name><mealsPerDay>1</mealsPerDay><pricePerMeal>130</pricePerMeal><mealType>VEG</mealType></Customer>' http://127.0.0.1:19400/customers
   415 · Location: [] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotSupportedException: Content-Type 'application/xml;charset=UTF-8' is not supported]
  the last course's scrape, asked for as curl asks, then for OpenMetrics (the anchor README's two lines; the page itself stays in .harness/anchor/scrape.txt, unread):
$ cd .harness/anchor && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19400/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
$ cd .harness/anchor && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' -H 'Accept: application/openmetrics-text; version=1.0.0' http://127.0.0.1:19400/actuator/prometheus
  200 application/openmetrics-text;version=1.0.0;charset=utf-8
  WARN lines in this run's log, at Boot's default level: 3 · ERROR lines: 0
$ harness/shutdown.sh 19400 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19400 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · xml — one dependency, a seventh converter

**The copy**: the patch, and `diff -U0` of the copy's web POM against the anchor's — **one hunk, one line in, none out, no version**; one
file differs, 24 of the anchor's 25 byte for byte; built offline. **BOOT-INF/lib: 56 → 59** — `jackson-dataformat-xml-3.1.5.jar`,
`stax2-api-4.2.2.jar`, `woodstox-core-7.1.1.jar` in, none out. The harness's `Formats`, joined to each tree: **message converters 6 → 7** —
the first six the same, in the same order, the sixth `JacksonJsonHttpMessageConverter [application/json, application/*+json]`, and **the
seventh `JacksonXmlHttpMessageConverter`** claiming **three media types**: `application/xml;charset=UTF-8`, `text/xml;charset=UTF-8`,
`application/*+xml;charset=UTF-8`. For a `Customer`, `application/xml` and `application/xhtml+xml` go from **0 of 6** to **1 of 7** (the
seventh: `application/*+xml` takes XHTML in); `text/html` and `text/plain` stay 0. **Why it appeared — Boot's condition report** (Course 5's
auto-configuration, its conditions): `JacksonHttpMessageConvertersConfiguration$JacksonXmlHttpMessageConverterConfiguration` **did not
match** on the anchor — `@ConditionalOnClass did not find required class 'tools.jackson.dataformat.xml.XmlMapper'` — and **matched** on
the copy: the class found, and the bean `xmlMapper`, which `JacksonAutoConfiguration$XmlConfiguration` (matched too) built. Jackson 2's
XML configuration stays unmatched on both (`com.fasterxml…XmlMapper`: Jackson 2 left the build in the request-body lesson). 3 rows on the
anchor, 8 on the copy.

`.r-xml.out` · md5 `36c9dd5ebf1b72aa4997ecd15ac82ca6` · 3 of 3

```
the copy - anchor/ copied to .harness/xml with a config tree, then this unit's patch (harness/xml.patch) and the copy's web POM against the anchor's (this unit's line):
$ cd .harness/xml && patch -s -p1 < ../../harness/xml.patch && diff -U0 ../../anchor/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d
  @@ -65,0 +66 @@
  +    <dependency><groupId>tools.jackson.dataformat</groupId><artifactId>jackson-dataformat-xml</artifactId></dependency>
$ diff -rq -x target -x secrets anchor .harness/xml
  Files anchor/tiffinbox-web/pom.xml and .harness/xml/tiffinbox-web/pom.xml differ
  the anchor's files: 25 · byte for byte the copy's: 24 · the copy's files: 25
$ cd .harness/xml && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy · offline: yes · exit 0
the executable jar's BOOT-INF/lib: the anchor's 56 jars -> the copy's 59 · only in the copy's: 3 - jackson-dataformat-xml-3.1.5.jar stax2-api-4.2.2.jar woodstox-core-7.1.1.jar · only in the anchor's: 0
  the copy's jar extracted (the README's line):
$ cd .harness/xml && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against the anchor's own jar - with -parameters:
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Formats.java
  exit 0
the anchor with the harness's Formats joined, port 19403 - its converters and Boot's conditions (this unit's line):
$ cd .harness/anchor && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19403 --spring.main.sources=probe.web.Formats
  listens on: 127.0.0.1:19403 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19403/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19403/probe/formats
  message converters: 6 - RequestMappingHandlerAdapter's, in the order it asks them
    1 ByteArrayHttpMessageConverter [application/octet-stream, */*]
    2 StringHttpMessageConverter [text/plain, */*]
    3 ResourceHttpMessageConverter [*/*]
    4 ResourceRegionHttpMessageConverter [*/*]
    5 AllEncompassingFormHttpMessageConverter [application/x-www-form-urlencoded, multipart/form-data, multipart/mixed, multipart/related]
    6 JacksonJsonHttpMessageConverter [application/json, application/*+json]
  asked of each, for a com.tiffinbox.Customer - canWrite, by media type - those that say yes:
    application/json: 1 of 6 - 6 JacksonJsonHttpMessageConverter
    application/xml: 0 of 6
    application/xhtml+xml: 0 of 6
    text/html: 0 of 6
    text/plain: 0 of 6
  Boot's condition report - the configurations whose name holds Xml: 3
    org.springframework.boot.http.converter.autoconfigure.Jackson2HttpMessageConvertersConfiguration$MappingJackson2XmlHttpMessageConverterConfiguration: did not match
      - @ConditionalOnClass did not find required class 'com.fasterxml.jackson.dataformat.xml.XmlMapper'
    org.springframework.boot.http.converter.autoconfigure.JacksonHttpMessageConvertersConfiguration$JacksonXmlHttpMessageConverterConfiguration: did not match
      - @ConditionalOnClass did not find required class 'tools.jackson.dataformat.xml.XmlMapper'
    org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration$XmlConfiguration: did not match
      - @ConditionalOnClass did not find required class 'tools.jackson.dataformat.xml.XmlMapper'
$ harness/shutdown.sh 19403 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19403 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the copy, the same, port 19402:
$ cd .harness/xml && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19402 --spring.main.sources=probe.web.Formats
  listens on: 127.0.0.1:19402 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19402/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19402/probe/formats
  message converters: 7 - RequestMappingHandlerAdapter's, in the order it asks them
    1 ByteArrayHttpMessageConverter [application/octet-stream, */*]
    2 StringHttpMessageConverter [text/plain, */*]
    3 ResourceHttpMessageConverter [*/*]
    4 ResourceRegionHttpMessageConverter [*/*]
    5 AllEncompassingFormHttpMessageConverter [application/x-www-form-urlencoded, multipart/form-data, multipart/mixed, multipart/related]
    6 JacksonJsonHttpMessageConverter [application/json, application/*+json]
    7 JacksonXmlHttpMessageConverter [application/xml;charset=UTF-8, text/xml;charset=UTF-8, application/*+xml;charset=UTF-8]
  asked of each, for a com.tiffinbox.Customer - canWrite, by media type - those that say yes:
    application/json: 1 of 7 - 6 JacksonJsonHttpMessageConverter
    application/xml: 1 of 7 - 7 JacksonXmlHttpMessageConverter
    application/xhtml+xml: 1 of 7 - 7 JacksonXmlHttpMessageConverter
    text/html: 0 of 7
    text/plain: 0 of 7
  the XML converter's mapper (7): tools.jackson.dataformat.xml.XmlMapper · beans of that class: 1 - xmlMapper
  Boot's condition report - the configurations whose name holds Xml: 8
    org.springframework.boot.http.converter.autoconfigure.Jackson2HttpMessageConvertersConfiguration$MappingJackson2XmlHttpMessageConverterConfiguration: did not match
      - @ConditionalOnClass did not find required class 'com.fasterxml.jackson.dataformat.xml.XmlMapper'
    org.springframework.boot.http.converter.autoconfigure.JacksonHttpMessageConvertersConfiguration$JacksonXmlHttpMessageConverterConfiguration: matched
      + @ConditionalOnClass found required class 'tools.jackson.dataformat.xml.XmlMapper'
      + @ConditionalOnBean (types: tools.jackson.dataformat.xml.XmlMapper; SearchStrategy: all) found bean 'xmlMapper'
    org.springframework.boot.http.converter.autoconfigure.JacksonHttpMessageConvertersConfiguration$JacksonXmlHttpMessageConverterConfiguration#jacksonXmlHttpMessageConvertersCustomizer: matched
      + @ConditionalOnMissingBean (types: org.springframework.http.converter.xml.JacksonXmlHttpMessageConverter; SearchStrategy: all) did not find any beans
    org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration$XmlConfiguration: matched
      + @ConditionalOnClass found required class 'tools.jackson.dataformat.xml.XmlMapper'
    org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration$XmlConfiguration#xmlFactory: matched
      + @ConditionalOnMissingBean (types: tools.jackson.dataformat.xml.XmlFactory; SearchStrategy: all) did not find any beans
    org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration$XmlConfiguration#xmlMapper: matched
      + @ConditionalOnMissingBean (types: tools.jackson.dataformat.xml.XmlMapper; SearchStrategy: all) did not find any beans
    org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration$XmlConfiguration#xmlMapperBuilder: matched
      + @ConditionalOnMissingBean (types: tools.jackson.dataformat.xml.XmlMapper$Builder; SearchStrategy: all) did not find any beans
    org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration$XmlConfiguration$XmlProblemDetailsConfiguration: matched
      + @ConditionalOnClass found required class 'org.springframework.http.ProblemDetail'
$ harness/shutdown.sh 19402 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19402 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · accept — the same routes, by the Accept header

The copy. **The seven**, on a fresh JVM, as curl sends them: **`87ca7efc…`** — XML present changes none of them. On a second JVM, **curl's
own `Accept` header**, read off its verbose request: **`*/*`**, anything. Then the customers: `Accept: application/xml` →
`<List><item>…</item>…</List>`, four items, `application/xml;charset=UTF-8`; `application/json` → the JSON list; **`application/xml;q=0.5,
application/json`** — XML weighted a half, JSON at the default weight, 1 — → **JSON**; `text/plain` → **406**, empty, one WARN.

`.r-accept.out` · md5 `baf082d6e3c8c715da7d890a41a0a5c4` · 3 of 3

```
the seven - the copy, the README's run line, port 19401, a fresh JVM (curl asks for */*):
$ cd .harness/xml && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19401
  listens on: 127.0.0.1:19401 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19401/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19401 .harness/xml/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the copy again, a fresh JVM, port 19401 - the customers, asked for as XML, as JSON, with XML weighted below JSON, and as plain text (this unit's GET line):
$ cd .harness/xml && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19401
  listens on: 127.0.0.1:19401 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19401/actuator/health/readiness
  {"status":"UP"} 200
  the Accept header curl sends when the command names none (curl's own request, verbose - this unit's line):
$ curl -s -o /dev/null -v http://127.0.0.1:19401/customers 2>&1 | grep '^> Accept' | tr -d '\r'
  > Accept: */*
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19401/customers
  <List><item><name>Meera</name><mealsPerDay>1</mealsPerDay><pricePerMeal>150</pricePerMeal><mealType>NON_VEG</mealType></item><item><name>Priya</name><mealsPerDay>1</mealsPerDay><pricePerMeal>120</pricePerMeal><mealType>VEGAN</mealType></item><item><name>Ravi</name><mealsPerDay>2</mealsPerDay><pricePerMeal>120</pricePerMeal><mealType>VEG</mealType></item><item><name>Sunil</name><mealsPerDay>3</mealsPerDay><pricePerMeal>100</pricePerMeal><mealType>VEG</mealType></item></List> · 200 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/json' http://127.0.0.1:19401/customers
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml;q=0.5,application/json' http://127.0.0.1:19401/customers
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/plain' http://127.0.0.1:19401/customers
   · 406 · Content-Type: [] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19401 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19401 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · shapes — XML, both ways

The copy, one fresh JVM. Ravi → `<Customer>…</Customer>`; the month's revenue → `<Map><monthRevenue>24300</monthRevenue></Map>`. **The
root element is named after the type the route returns** — `Customer customer(…)`, `Map<String, Object> revenue()`, `List<Customer>
customers(…)` in the anchor's `TiffinBoxServer` — not after the class that holds the answer (revenue's is a `LinkedHashMap`): no schema is
promised, only the type's simple name. **Error bodies follow into XML**: a name nobody has → 404 with `<Map><timestamp>…</timestamp>
<status>404</status><error>Not Found</error><path>/customers/Nobody</path></Map>` (the anchor: 404, empty); a meal type nobody serves →
400, the same shape, one WARN. **XML in**: Asha as XML, asking for XML → **201**, `Location: [http://127.0.0.1:19401/customers/Asha]` and
Asha **as XML** — a `ResponseEntity`'s body goes through the same converters, and its Location is built as before (the responses lesson's
open item, settled); that Location, asked for as XML → 200, `<Customer>`. Ira as XML **with no `Accept` header** → 201 and **JSON** back:
`Content-Type` names what you send, `Accept` what you want back. Asha again → **409**, no body (nothing to negotiate). A body cut short →
**400**, an XML error body, and Spring MVC's WARN line: `HttpMessageNotReadableException: JSON parse error: Unexpected EOF; was expecting a
close tag for element <mealsPerDay>…` — **"JSON parse error" for an XML body**: Spring's message is one for both Jackson converters. 2
WARN lines: the two 400s.

`.r-shapes.out` · md5 `0d52b87aa35591ced80cd5045c2dc0ea` · 3 of 3

```
the copy, the README's run line, port 19401 - one customer and the month's revenue, asked for as XML (this unit's GET line):
$ cd .harness/xml && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19401
  listens on: 127.0.0.1:19401 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19401/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19401/customers/Ravi
  <Customer><name>Ravi</name><mealsPerDay>2</mealsPerDay><pricePerMeal>120</pricePerMeal><mealType>VEG</mealType></Customer> · 200 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19401/revenue
  <Map><monthRevenue>24300</monthRevenue></Map> · 200 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 0
  error bodies - a name nobody has, a meal type nobody serves - asked for as XML:
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19401/customers/Nobody
  <Map><timestamp>…</timestamp><status>404</status><error>Not Found</error><path>/customers/Nobody</path></Map> · 404 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' 'http://127.0.0.1:19401/customers?mealType=veg'
  <Map><timestamp>…</timestamp><status>400</status><error>Bad Request</error><path>/customers</path></Map> · 400 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
  a customer sent as XML, asked back as XML (this unit's XML POST), then its Location, asked for as XML:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Accept: application/xml' -H 'Content-Type: application/xml' --data '<Customer><name>Asha</name><mealsPerDay>2</mealsPerDay><pricePerMeal>110</pricePerMeal><mealType>VEG</mealType></Customer>' http://127.0.0.1:19401/customers
  <Customer><name>Asha</name><mealsPerDay>2</mealsPerDay><pricePerMeal>110</pricePerMeal><mealType>VEG</mealType></Customer> 201 · Location: [http://127.0.0.1:19401/customers/Asha] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19401/customers/Asha
  <Customer><name>Asha</name><mealsPerDay>2</mealsPerDay><pricePerMeal>110</pricePerMeal><mealType>VEG</mealType></Customer> · 200 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 0
  another, sent as XML with no Accept header (this unit's XML POST without it):
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/xml' --data '<Customer><name>Ira</name><mealsPerDay>1</mealsPerDay><pricePerMeal>130</pricePerMeal><mealType>VEG</mealType></Customer>' http://127.0.0.1:19401/customers
  {"name":"Ira","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"} 201 · Location: [http://127.0.0.1:19401/customers/Ira] · WARN lines it added: 0
  the first name again, then a body cut short:
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Accept: application/xml' -H 'Content-Type: application/xml' --data '<Customer><name>Asha</name><mealsPerDay>2</mealsPerDay><pricePerMeal>110</pricePerMeal><mealType>VEG</mealType></Customer>' http://127.0.0.1:19401/customers
   409 · Location: [] · WARN lines it added: 0
$ curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Accept: application/xml' -H 'Content-Type: application/xml' --data '<Customer><name>Kiran</name><mealsPerDay>2' http://127.0.0.1:19401/customers
  <Map><timestamp>…</timestamp><status>400</status><error>Bad Request</error><path>/customers</path></Map> 400 · Location: [] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected EOF; was expecting a close tag for element <mealsPerDay><EOL> at [row,col {unknown-source}]: [1,42]]
  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 0
$ harness/shutdown.sh 19401 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19401 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · browser — the client that never asked (C, D, E — labelled)

**C**: a browser's `Accept` header, sent by curl (this unit's line). TiffinBox → **200, JSON**: it has one format, and the header's `*/*`
takes it. The copy → **200, the XML, labelled `application/xhtml+xml`**: XHTML first in the header, and the XML converter claims
`application/*+xml`. **D**: Boot's metadata for `spring.mvc.contentnegotiation.default-content-types` — "List of default content types to be
used when no specific content type is requested" — and the copy run with it set to `application/json`, the harness joined: **the key is
read** — the content negotiation manager now asks two strategies, `HeaderContentNegotiationStrategy` first, then
`FixedContentNegotiationStrategy [application/json]` — and the browser's header **still gets `application/xhtml+xml`**: the `Accept`
header's strategy answers first, and a browser's names its types. (Without the strategies D's result would be a null one that a misspelt
key, silently ignored, would give as well; the strategies make it a measured one.) **E**: the copy with the harness joined and no key — one strategy, the header's — then the harness's two routes: `produces = application/json` → the browser gets **JSON**;
`produces = {application/json, application/xml}` → **XML, labelled `application/xml`**: the route's own list leaves XHTML out, and the
header ranks XML (`q=0.9`) above anything else (`q=0.8`); the JSON-only route asked for XML → **406** (with an XML error body). 1 WARN line, that 406's.

**What a TiffinBox API should do about it (the brief's finding, measured):** keep TiffinBox JSON-only, as the brief decides (⚑13) — its
answer to a browser is JSON (C). An API that must offer XML says, route by route, what it **`produces`**: JSON only keeps browsers on JSON
and refuses XML clients (406); JSON or XML hands a browser the XML under its own label, `application/xml` (E). Boot's default content type
does not reach a browser (D). Not measured here, and not claimed: reordering the converters, a format parameter alone, or a browser of
any real make.

`.r-browser.out` · md5 `8b99ad4ca60e0ae50594e6c04d1f7ef9` · 3 of 3

```
C (labelled) - a browser's Accept header, sent by curl (this unit's line):
  the anchor, the README's run line, port 19400:
$ cd .harness/anchor && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19400
  listens on: 127.0.0.1:19400 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19400/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' http://127.0.0.1:19400/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ harness/shutdown.sh 19400 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19400 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the copy, the same line, port 19401:
$ cd .harness/xml && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19401
  listens on: 127.0.0.1:19401 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19401/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' http://127.0.0.1:19401/customers/Ravi
  <Customer><name>Ravi</name><mealsPerDay>2</mealsPerDay><pricePerMeal>120</pricePerMeal><mealType>VEG</mealType></Customer> · 200 · Content-Type: [application/xhtml+xml] · WARN lines it added: 0
$ harness/shutdown.sh 19401 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19401 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
D (labelled) - the copy with a default content type, application/json (this unit's run line's option), the harness joined, port 19405 - the strategies Spring MVC's content negotiation manager asks (this unit's line), then the browser's header again:
  Boot's metadata (spring-boot-webmvc-4.1.1.jar) - spring.mvc.contentnegotiation.default-content-types · its type: MediaType · its default: none · its description: List of default content types to be used when no specific content type is requested.
$ cd .harness/xml && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19405 --spring.main.sources=probe.web.Formats --spring.mvc.contentnegotiation.default-content-types=application/json
  listens on: 127.0.0.1:19405 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19405/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19405/probe/formats/strategies
  the content negotiation manager's strategies, in the order it asks them: 2
    1 HeaderContentNegotiationStrategy
    2 FixedContentNegotiationStrategy - its content types: [application/json]
  the format values it maps: json -> application/json · xml -> application/xml
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' http://127.0.0.1:19405/customers/Ravi
  <Customer><name>Ravi</name><mealsPerDay>2</mealsPerDay><pricePerMeal>120</pricePerMeal><mealType>VEG</mealType></Customer> · 200 · Content-Type: [application/xhtml+xml] · WARN lines it added: 0
$ harness/shutdown.sh 19405 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19405 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
E (labelled) - the copy with the harness joined and no key, port 19402 - the strategies; then the harness's two routes: one that produces JSON, one that produces JSON or XML:
$ cd .harness/xml && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19402 --spring.main.sources=probe.web.Formats
  listens on: 127.0.0.1:19402 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19402/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19402/probe/formats/strategies
  the content negotiation manager's strategies, in the order it asks them: 1
    1 HeaderContentNegotiationStrategy
  the format values it maps: json -> application/json · xml -> application/xml
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' http://127.0.0.1:19402/probe/formats/json
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' http://127.0.0.1:19402/probe/formats/both
  <Customer><name>Ravi</name><mealsPerDay>2</mealsPerDay><pricePerMeal>120</pricePerMeal><mealType>VEG</mealType></Customer> · 200 · Content-Type: [application/xml] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19402/probe/formats/json
  <Map><timestamp>…</timestamp><status>406</status><error>Not Acceptable</error><path>/probe/formats/json</path></Map> · 406 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19402 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19402 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · actuator — health keeps its JSON

Health, asked for as XML, as JSON and with a browser's `Accept` header. **As XML → 406 on both trees**: the anchor's empty, **the copy's
with an XML error body** (`<Map>…<status>406</status>…<path>/actuator/health</path></Map>`) — Boot's error controller can write XML now;
Actuator's endpoint still cannot. As JSON → 200, `application/json`; a browser's header → 200,
`application/vnd.spring-boot.actuator.v3+json`, on both: Actuator names its own types, and XML is not one of them. (The brief's ⚑2 loser
line, "Actuator answers 406 to it", holds for an XML `Accept`; a browser's gets health's JSON.)

`.r-actuator.out` · md5 `9ed429a10eb3bf2bf2a790be9cd98691` · 3 of 3

```
the anchor, the README's run line, port 19400 - health, asked for as XML, as JSON and with a browser's Accept header (this unit's GET line):
$ cd .harness/anchor && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19400
  listens on: 127.0.0.1:19400 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19400/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19400/actuator/health
   · 406 · Content-Type: [] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/json' http://127.0.0.1:19400/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' http://127.0.0.1:19400/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} · 200 · Content-Type: [application/vnd.spring-boot.actuator.v3+json] · WARN lines it added: 0
$ harness/shutdown.sh 19400 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19400 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the copy, the same three, port 19401:
$ cd .harness/xml && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19401
  listens on: 127.0.0.1:19401 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19401/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19401/actuator/health
  <Map><timestamp>…</timestamp><status>406</status><error>Not Acceptable</error><path>/actuator/health</path></Map> · 406 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/json' http://127.0.0.1:19401/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' http://127.0.0.1:19401/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} · 200 · Content-Type: [application/vnd.spring-boot.actuator.v3+json] · WARN lines it added: 0
$ harness/shutdown.sh 19401 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19401 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 7 · param — `?format=xml` (A/B/A′)

Boot's metadata: `spring.mvc.contentnegotiation.favor-parameter`, a `Boolean`, **default `false`** — "Whether a request parameter
("format" by default) should be used to determine the requested media type"; `parameter-name` has no default in the metadata — the
description above names `format`. **A**,
the copy as Boot sets it up: `/customers/Ravi?format=xml` → **JSON** (the parameter is ignored). **B**, the run line with
`favor-parameter=true`: `?format=xml` → **`<Customer>`**, `application/xml;charset=UTF-8`; `?format=json` → JSON; `?format=xml` beside
`Accept: application/json` → **XML: the parameter beats the header**; no parameter → JSON. **A′** = A, line for line. **C** (labelled),
the copy with the harness joined and the same option: the content negotiation manager asks **`ParameterContentNegotiationStrategy`
(its parameter: `format`) first, `HeaderContentNegotiationStrategy` second** — why the parameter wins — and maps the format values
`json` and `xml`.

`.r-param.out` · md5 `9556251ae208254375cd107188685f2d` · 3 of 3

```
  Boot's metadata (spring-boot-webmvc-4.1.1.jar) - spring.mvc.contentnegotiation.favor-parameter · its type: Boolean · its default: false · its description: Whether a request parameter ("format" by default) should be used to determine the requested media type.
  Boot's metadata (spring-boot-webmvc-4.1.1.jar) - spring.mvc.contentnegotiation.parameter-name · its type: String · its default: none · its description: Query parameter name to use when "favor-parameter" is enabled.
A - the copy, the README's run line, port 19401 - ?format=xml, no Accept header (this unit's line):
$ cd .harness/xml && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19401
  listens on: 127.0.0.1:19401 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19401/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' 'http://127.0.0.1:19401/customers/Ravi?format=xml'
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ harness/shutdown.sh 19401 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19401 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the copy with favor-parameter on (this unit's run line), port 19404 - ?format=xml, ?format=json, ?format=xml beside an Accept header that asks for JSON, and no parameter:
$ cd .harness/xml && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19404 --spring.mvc.contentnegotiation.favor-parameter=true
  listens on: 127.0.0.1:19404 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19404/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' 'http://127.0.0.1:19404/customers/Ravi?format=xml'
  <Customer><name>Ravi</name><mealsPerDay>2</mealsPerDay><pricePerMeal>120</pricePerMeal><mealType>VEG</mealType></Customer> · 200 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' 'http://127.0.0.1:19404/customers/Ravi?format=json'
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' -H 'Accept: application/json' 'http://127.0.0.1:19404/customers/Ravi?format=xml'
  <Customer><name>Ravi</name><mealsPerDay>2</mealsPerDay><pricePerMeal>120</pricePerMeal><mealType>VEG</mealType></Customer> · 200 · Content-Type: [application/xml;charset=UTF-8] · WARN lines it added: 0
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' http://127.0.0.1:19404/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ harness/shutdown.sh 19404 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19404 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/xml && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19401
  listens on: 127.0.0.1:19401 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19401/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' · %{http_code} · Content-Type: [%header{content-type}]\n' 'http://127.0.0.1:19401/customers/Ravi?format=xml'
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} · 200 · Content-Type: [application/json] · WARN lines it added: 0
$ harness/shutdown.sh 19401 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19401 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - the copy with favor-parameter on (B's option) and the harness joined, port 19404 - the strategies Spring MVC's content negotiation manager asks (this unit's line):
$ cd .harness/xml && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19404 --spring.main.sources=probe.web.Formats --spring.mvc.contentnegotiation.favor-parameter=true
  listens on: 127.0.0.1:19404 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19404/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19404/probe/formats/strategies
  the content negotiation manager's strategies, in the order it asks them: 2
    1 ParameterContentNegotiationStrategy - its parameter: format
    2 HeaderContentNegotiationStrategy
  the format values it maps: json -> application/json · xml -> application/xml
$ harness/shutdown.sh 19404 .harness/xml/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19404 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 8 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s seven lines, then `SOLUTION.md`'s three, read from the files and run as written, one after the other in ONE shell a
viewer could have (`env -i`, `/bin/bash --noprofile --norc`, started in this folder). As shipped: **`GET /customers/Ravi: 200 ·
application/json · root element: none`** — the line sends `Content-Type: application/xml` on a GET, which no route reads, and curl's own
`*/*` gets JSON — the shell back in this folder, 0 WARN lines, 19409 free; the solution's line (`-H 'Accept: application/xml'` in its
place): **`GET /customers/Ravi: 200 · application/xml;charset=UTF-8 · root element: Customer`**, the shell in this folder, 0 WARN lines,
19409 free; the copy's own token 0 times in each log.

`.r-exercise.out` · md5 `4aef7d7d923f3112d887343d4b63005e` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/xml/ && (cd .harness/mine/xml && patch -s -p1 < ../../../harness/xml.patch)
  $ mkdir -p .harness/mine/xml/secrets/tiffinbox && chmod 700 .harness/mine/xml/secrets .harness/mine/xml/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/xml/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/xml && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
  $ (cd .harness/mine/xml && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19409 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19409/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && t=$(curl -s -o ../got.txt -w '%{http_code} · %{content_type}' -H 'Content-Type: application/xml' http://127.0.0.1:19409/customers/Ravi); ../../../harness/shutdown.sh 19409 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && r=$(sed -n 's/^<\([A-Za-z]*\)>.*/\1/p' ../got.txt) && echo "GET /customers/Ravi: $t · root element: ${r:-none}")
  exit 0 · what they printed:
    GET /customers/Ravi: 200 · application/json · root element: none
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19409 now: 0
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ (cd .harness/mine/xml && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19409 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19409/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && t=$(curl -s -o ../got.txt -w '%{http_code} · %{content_type}' -H 'Accept: application/xml' http://127.0.0.1:19409/customers/Ravi); ../../../harness/shutdown.sh 19409 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && r=$(sed -n 's/^<\([A-Za-z]*\)>.*/\1/p' ../got.txt) && echo "GET /customers/Ravi: $t · root element: ${r:-none}")
  exit 0 · what they printed:
    GET /customers/Ravi: 200 · application/xml;charset=UTF-8 · root element: Customer
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19409 now: 0
```

## Exercise

**Your turn:** the README asks for one customer as XML but gets JSON. Find the wrong header, fix it, and read the root element.
`exercise/README.md` has the commands (copy `anchor/` with the XML patch and a token of its own, build the jar offline); its last line,
in a subshell, starts the copy on 19409, asks for Ravi with `-H 'Content-Type: application/xml'`, stops it, waits for its JVM and prints —
as shipped — `GET /customers/Ravi: 200 · application/json · root element: none`. Done is `GET /customers/Ravi: 200 ·
application/xml;charset=UTF-8 · root element: Customer`. Measured answer: `exercise/solution/SOLUTION.md` (the README's two `export`
lines, then the same line with `-H 'Accept: application/xml'`), run in the same shell. Run `./receipts.sh` once first on a fresh clone.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-15) |
|---|---|---|---|
| 12 | XML on a copy of `10/after`; the broken exercise (GET with `Content-Type: application/xml`) | the chain end's copy; the broken half not run | **on a copy of `10/after`: one line, 56 → 59 jars, converters 6 → 7, the seven `87ca7efc…`, XML by Accept, XML bodies read and written, error bodies in XML, the browser's Accept → `application/xhtml+xml`, health 406, `?format=xml` only with favor-parameter** (`xml` … `param`); **the broken half: `200 · application/json · root element: none`** (`exercise`) |
| 16 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: JSON, no root element, then `application/xml;charset=UTF-8`, `Customer`** (`exercise`) |
| — | (the responses lesson's open item) a `ResponseEntity` body and its `Location` as XML | not measured | **201, the same Location, the body as XML; the 409 has no body** (`shapes`) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **The brief's `<TreeMap>` of field messages** (`shapes`) belongs to the chain's end, where validation runs; on this unit's tree, the
  responses lesson's, there is none — an invalid XML body here is a body cut short (400, `JSON parse error` in the WARN line) or a taken
  name (409). *Validation on the Way In* brings the field messages.
- **"Actuator answers 406 to it"** (⚑2's loser A): true for an XML `Accept`; a browser's `Accept` gets health's JSON
  (`application/vnd.spring-boot.actuator.v3+json`) on both trees (`actuator`).
- **An XML `Accept` on the anchor gets empty error bodies** — `/customers/Nobody` 404, the 406s — where the copy writes `<Map>` (`anchor`,
  `shapes`): Boot's error controller writes the format the client takes, or nothing.
- **Spring MVC calls an XML body's parse failure a "JSON parse error"** (`shapes`): one message for both Jackson converters — the WARN line's
  words, not the format.
- **Boot's `default-content-types` does not reach a browser** (`browser` D): it is read — a fixed default the content negotiation manager
  asks after the `Accept` header's strategy — and its own metadata says it serves requests that name no type.
- **The root element is the route's declared type** (`<Map>` for a `LinkedHashMap` answer), not a schema: `List`, `Map`, `Customer`.

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block run alone on copies of the published captures and of this unit's files, one change per plant (`plants.py`, this
  unit's scratch folder) — **100 plants, 100 stops**, each naming its check; the unplanted copies pass under /bin/bash 3.2 and bash 5.3
  with no shell error. Two plants first passed: the condition report's outcome lines were looked for anywhere in a tree's block, and the
  same outcome stands under two configurations (the converter's and `JacksonAutoConfiguration$XmlConfiguration`) — so each
  configuration's row and the outcomes right after it are now checked together, and both plants stop.
- **curl's `*/*`, measured.** The brief's "curl's `*/*` still gets JSON" rested on curl's default header; `accept` reads it off curl's own
  verbose request (`> Accept: */*`).
- **The scrape, an earlier negotiation.** The anchor README already held the last course's two scrape lines (curl's request and an
  OpenMetrics `Accept`); re-run on the anchor, they are the mechanism this lesson opens, met before (contract §4.2).
- **D's first form proved nothing about the key.** It ran the copy's jar with `default-content-types=application/json` and showed the
  browser's answer unchanged — the same answer a misspelt key, which Boot ignores without a word, would give. The harness gained
  `/probe/formats/strategies`, and D now runs with it joined: the manager's strategies show the key read (a fixed `[application/json]`
  after the header's), so "doesn't change that" is a measurement, not a null. E prints the same list without the key (the header's
  alone), and `param` gained C (the parameter's strategy asked first). `browser` and `param` were hashed again; `xml`'s capture — the
  harness's other route — stayed byte for byte the same.
- **The first `./receipts.sh` never started**: the file was written without its execute bit (`Permission denied`, before any line of the
  script). `chmod +x`; git records the mode, so a clone runs it as `./receipts.sh`.
- **How the hashes were made:** a development pass (a copy of this script running each capture once, `.r-dev.sh`, deleted), then
  `bash receipts.sh` made the published hashes and stopped on "no published hash", as designed; `accept` gained curl's verbose line and was
  hashed again; a second development pass made `browser`'s and `param`'s with the strategies, and every run of record reproduced all
  eight — so each hash was made by two scripts' runs at different times.

## For units 12 and 13 — and RED

- **The anchor is untouched**, and `anchor` points at `../c6-unit10/after`, frozen. Nothing here reads `c6-tiffinbox`.
- **XML is one dependency line away and stays out of the anchor (⚑13).** With it: converters 6 → 7 (the seventh after JSON), 56 → 59 jars,
  Boot's `xmlMapper` bean; the seven unchanged; error bodies follow the client's format (`<Map>` in XML, empty when the client takes neither).
- **For 12 (validation):** a 400 body built by the method (`{field: message}`) goes through the same converters — an XML client would get it
  as XML on a copy; not measured here. The anchor's 400s for a JSON-refusing client are empty bodies (`anchor`'s 406 pattern).
- **For 13 (converters and formatters):** "converter" is two things in Spring MVC — a *message* converter (bodies, this unit's) and a
  `Converter` (request parameters, 13's): name which. The `format` parameter needs `favor-parameter`; `?format=xml` is ignored by default.
- **Masks to carry:** `<timestamp>…</timestamp>` in XML bodies; Boot's HTML error page's `<div id='created'>` (its date holds this Mac's
  zone: `CEST`, `CET` after the clocks change); never hash that page's `Content-Length`.
- **Ports:** 19400-19409 are this unit's (19406-19408 never bound); 12 has 19410-19419, 13 has 19420-19429.
- **/bin/bash 3.2:** the derivations keep each pattern and replacement in a variable and assign the result (`r=${x/"$P"/$R}`) — the slash
  trap; and no `case` inside `$( )` (a top-level `case` is fine).

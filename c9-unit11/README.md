# Course 9 · Unit 11 — Spring REST Docs

**Course 9's eighth change to the anchor, Section 2's fifth unit, and the anchor's first change to test scope and to the build's
documentation step.** The parent gains one property, `asciidoctor-maven-plugin.version` `3.2.0`, with its comment. The web module gains
two test-scope dependencies (`spring-restdocs-mockmvc`, REST Docs `4.0.3` from Boot's parent, and `spring-boot-starter-restdocs`),
Asciidoctor's Maven build step at `prepare-package`, the page's two sources under `src/docs/asciidoc` and one test,
`TiffinBoxRestDocsTest.thePublicReadIsDocumented`, in the default run. `before` is a link to `../c9-unit10/after` (unit 10's tree);
`after/` is a frozen copy of `../c9-tiffinbox` after this unit's change. Every number below names its tree and is read by
`harness/chk11.py` off a capture of `receipts.sh`, never typed. Chrome runs in this unit once, sealed and headless, to read the
generated pages as files. No PostgreSQL capture: H2 only.

The unit's one gloss, typed once in `harness/chk11.py`:

A snippet: one documented part of one tested request.

The hook, as the brief gives it (S2B's Unit 11 Hook line), byte for byte; it passes every gate of `harness/s911.py`:

Document a field TiffinBox never sends, and the test fails. The answer's other snippets are still written.

That second sentence is the field failure's: a field the test invents or forgets leaves the six default snippets and no
`response-fields.adoc`. A status check ahead of the document call leaves no directory at all (`status`, below).

## Runs of record

Three runs, each launched below load1 `20` (R.480) with its load printed on its first line: bash `3.2.57` (`./receipts.sh`), bash
`5.3.9` (`bash receipts.sh`), and a sealed fresh clone in a folder whose name holds a space (R.129), run from that clone. Every build
says offline: yes (`Downloading from` `0` in every Maven log). Each run ends `every capture = published (16)`, and
`check_unit9.py 11 --runlog <log>` prints the run-log gate's PASS on each (the unit gate exits `2` until unit 11's script exists, as
the prompt expects). The capture hashes are the `receipts.md5` lines; the loads are in the commit message. No clock figure of a run is a
measurement and none is said here.

## RE-MEASURE (settled first)

1. **`tests`** - the whole reactor at `mvn -o clean package`: the parent and three modules, each `SUCCESS`; `tiffinbox-web` `50` tests
   (unit 10's `49` and the one this change adds), `TiffinBoxRestDocsTest` `1` run, `0` failures, `0` skipped; `tiffinbox-client` `1`;
   the Docker-free twin the same; `verify` on the whole reactor: the five ITs, `14` tests, five `IT BINDINGS` lines, every entry on
   `127.0.0.1`. The page step's own line in the log is `asciidoctor:3.2.0:process-asciidoc (docs) @ tiffinbox-web`, bound to
   `prepare-package`. The hand-built form (`-pl tiffinbox-web -am`) prints the same web counts. `BOOT-INF/lib` `157` before and after,
   no jar name moved. The `-DskipTests` form on a scratch copy exits `0`, logs `4` include-not-found lines, and still writes a page with
   `4` unresolved includes: a build without the tests has no snippets, and its page is not documentation.
2. **`change`** - the parent's `<modules>` `3` before and `3` after; the parent pom's diff and the web pom's diff are additions only.
   The test scope the build resolved holds `spring-restdocs-mockmvc` `4.0.3`, `spring-restdocs-core` `4.0.3`, `spring-boot-restdocs` and
   `spring-boot-starter-restdocs` `4.1.3`, each in test scope; the build step's effective version is `3.2.0`, the parent's property.
3. **`pass`** - the shipped test alone (MockMvc: no socket, no HTTP client; nothing listening on 20400-21299 during or after):
   `target/generated-snippets/customer-read/` holds `8` snippets - the six defaults, `path-parameters.adoc` and `response-fields.adoc`.
   The six defaults hash as BLUE's filed run; the two that hold this test's own descriptions differ from the probe's. Its
   `http-response.adoc` documents `200 OK`, `application/json`, `Content-Length: 67` and the four members. The same request over the
   socket on 21000 (H2, no harness) answers `200` `application/json` with no Accept and with `Accept: application/json`, the body equal
   to the snippet's key for key and value, the access log holding both lines. The snippet is what MockMvc's DispatcherServlet answered;
   the socket is what Tomcat answered.
4. **`status`** - the fail mirror (the harness's class `FailureKindsProbeTest`, six failing tests, beside the shipped one): the run
   exits `1`, the two status tests fail with `AssertionError` (`Status expected:<201> but was:<200>`) and the four field tests error with
   `SnippetException`. Status check first (A): the directory is ABSENT. Document first (B): `7` files - the six defaults, the `200`
   documented, and `response-fields.adoc`, because that test documents the four real members before the status check fails. The
   package build on the same mirror stops at `test`: `target/generated-docs` is ABSENT.
5. **`field`** - never sent (`nickname` documented) and left undocumented (`mealType` left out), each in both orders: `6` files each,
   the six defaults byte-equal to the passing test's, no `response-fields.adoc`, no `path-parameters.adoc`. Never sent:
   `Fields with the following paths were not found in the payload: [nickname]`; left undocumented:
   `The following parts of the payload were not documented`. The order makes no difference to a field failure: the same six files and
   the same exception in A and B, because the failure comes from the document call itself.
6. **`accept`** - unit 10's hand-off. The generated client's Accept, read off its generated `ApiApi` source, is
   `*/*, application/problem+json`. Under MockMvc's default (no Accept) REST Docs documents `application/json`; under the generated
   client's Accept it documents `application/problem+json` for the customer's `200`; under `Accept: application/json`, `application/json`.
   The socket gives the same Content-Type for each Accept. REST Docs documents the Content-Type the answer carried to the Accept the test
   sent; the generated client sends another.
7. **`driven`** - unit 09's hand-off, a candidate, not shipped: on the driven mirror one test documents the Nobody `404` with
   `responseFields` over the members the wire carries. With `name` documented it passes and writes `7` snippets; with `name` left out it
   errors with `SnippetException` (not documented: `name`) and leaves the six defaults. The snippet documents `404 Not Found`,
   `application/problem+json`, the body equal to the wire's and to the committed file's example for that answer, its `type`
   `tag:tiffinbox.example,2026:customer-not-found`.
8. **`html`** - the shipped page (`:webfonts!:` and the local stylesheet) names `0` hosts in its bytes; the `nofonts` page
   (`:webfonts!:` alone) still names `fonts.googleapis.com` and `asciidoctor.org` in its bytes, through the default stylesheet's
   `@import` and header; the `default` page names both, and more. Asciidoctor `2.0.23` wrote them; the footer's clock is masked. The jar
   holds `0` page entries, and git ignores the page (`target/`).
9. **`sealed`** - the three pages read as `file://` in sealed headless Chrome (DevTools on 21007, the dead proxy, the resolver rules, a
   throwaway profile): the shipped page asked no socket, `seal9.py cdp` exit `0`; the `default` page asked
   `https://fonts.googleapis.com/css`, exit `1`, red in every run of record; the `nofonts` page asked no socket, exit `0`, while its bytes
   name the host. The probe's filed events go red (`1`) and an empty events file is refused (`2`). Every TCP connect in the three
   NetLogs went to `127.0.0.1`, the dead proxy included; the UDP and URL lines Chrome's own background printed are listed in `sealed`'s
   block as found, neither asserted nor said. the earlier course's TCP-only NetLog check (`c6-unit23/harness/netlog.py`, read in place) passes the default page's
   NetLog, the check that cannot fail here.
10. **`compare`** - REST Docs documents what the real build drove: `1` identifier directory, `8` snippets, the real `200`,
    `application/json` and the body. Spring doc's document on 21000 holds `13` operations, `6` with an error response, `12` whose
    success lists `*/*`. Specwire9 on its own harness-joined start: (a) `6` kinds and `9` rows, (b) `7` kinds and `10` rows, unit 10's,
    unmoved - the change adds a test, not a route; its response-media-type rows (`3`: the public read, the list and the JSON Patch, each
    `*/*` against the wire's `application/json`) are printed in `compare`'s block. The two socket tests the hand-off names,
    `CustomerPatchesTest` and `CustomerReadsTest`, are among the `5` test classes the grep finds on a real socket (`FeedTest`,
    `FullStackTest` and `IdempotencyKeyTest` beside them); they stay tests of their own, and a MockMvc test, REST Docs' included, runs the
    DispatcherServlet with no socket. One tells the surface the code exposes, the other the answer of each route a
    test drives.
11. **`committed`** - the file this build reads is unit 10's, byte for byte (`20306` B), equal to the served document with `servers`
    removed; `OpenApiSpecTest` passes in the package run and its twin.
12. **`moved`** - unit 10's nineteen requests on `before` and `after/`, each its own start: `0` moved. The web jar's md5 differs, and
    the per-entry comparison names where: the same entry names, and one CRC moved, the web module's own pom
    (`META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml`); no entry named REST Docs, Asciidoctor, JRuby or the page in either jar.
13. **The seven and the old surface** - the expected hashes on both trees, read off unit 10's values block; not witnesses for the test
    scope, only for "adding REST Docs moved no answer of TiffinBox". The S9.14 plant leaves the seven equal and moves the surface.
14. **`exercise`** - broken: the test errors with `SnippetException` (`[nickname]` not found in the payload), the six defaults on disk,
    no `response-fields.adoc`, no page - `field` seen from the learner's side; solved (the nickname line removed, the test then the shipped
    one byte for byte): the eight snippets and the page, under bash and `zsh -f`. The refused variants fail the check: the whole
    `responseFields` removed (clause 2), `nickname` marked optional (REST Docs refuses it with `FieldTypeRequiredException`: an absent
    optional field needs a type; clause 1), the test switched off (clause 1), a hand-written snippet under `target/` (clause 1), the
    broken tree as is (clause 1).

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

Six paths of `c9-tiffinbox/` change, the derived list `chk11.py static` prints: the parent `pom.xml` (one property and its comment),
`tiffinbox-web/pom.xml` (two test-scope dependencies and the build step), the new `TiffinBoxRestDocsTest.java`, the new
`src/docs/asciidoc/index.adoc` and `tiffinbox-docs.css`, and `README.md` (a header note and unit 11's card). Nothing under
`tiffinbox-web/src/main`, `tiffinbox-core/` or `tiffinbox-client/` moves. The earlier cards keep their "Not fixed here ... a driven
test (*Spring REST Docs*)" lines as dated history; the header gains a *Course 9, unit 11* note under unit 10's; unit 11's card gives
`49` as unit 10's count only. The `Dockerfile` copies the web jar alone, so the page never reaches the image. `index.adoc` is the probe's
local page, byte for byte; `tiffinbox-docs.css` is the probe's stylesheet, byte for byte.

## Which tree, which profile

`before` = unit 10's `after` (three modules, no REST Docs). `after/` = this unit's tree. Every TiffinBox start is H2 in memory on the
default profile. A start that joins the harness documents the harness's routes too, so every document claim and every socket twin is
read from a harness-free start; the second client exists only on specwire9's harness-joined start. The MockMvc runs start no server.

## Unit 11's section

The spine, against the brief: REST Docs writes what the test drove - the request, the answer and every field, as TiffinBox sent them
to MockMvc (`pass`). A failed status check ahead of the document call leaves no directory; after it, the snippets are written and the
test still fails (`status`). A field the test forgets, or invents, fails the build and leaves no field snippet, in either order
(`field`). The failure receipt is `field`. The page step runs at `prepare-package`, so a failed test stops the build before the page;
a build without the tests writes a page of unresolved includes. The exercise is the invented field.

## The captures — what each one shows

### tests, change, committed
The reactor's counts per runner, the build step's line, the test scope resolved, the file as unit 10 left it.

### pass, status, field
The code panel: the shipped test (`thePublicReadIsDocumented`) is `after/tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxRestDocsTest.java`;
the build step beside the property's comment is in `change`'s block; `http-response.adoc` whole is in `pass`'s block; each failing
test's listing sits beside its exception in `status`'s and `field`'s blocks.

### accept, driven
The three Accepts side by side, and the driven candidate.

### html, sealed
The host census per page, and the judge's host table for the shipped page and for the default page.

### compare, moved, seven, surface, inert, exercise
The two documents counted by command, the old routes on both trees, the key's census, the exercise's measured runs.

## Measured, not shipped

The six failing tests (`FailureKindsProbeTest`), the `nofonts` and `default` pages, the three Accepts (`AcceptProbeTest`), the driven
Nobody test (`DrivenErrorProbeTest`), the `-DskipTests` page. Each lives on a scratch mirror, one patch under `harness/mirror/`.

## Refused, named

`a failing test writes nothing` and `only from a test that passed` (the document-first status test writes its snippets);
`127.0.0.1 only` and `nothing left the machine` while a UDP or URL line names another host; `REST Docs never lies` (the snippet
follows the Accept the test sent); a count the print did not give; a ranking word between the two documents.

## The repository, and the network

One commit for `c9-unit11/` and the changed paths of `c9-tiffinbox/`; the only network act is the push. Every build is offline from a
copy of the Section 2 seed. The advisory read is the probe's: it cleared REST Docs `4.0.3`; the Asciidoctor Maven build step,
asciidoctorj `3.0.0` and JRuby were not read. Asciidoctorj `3.0.1` is newer and not weighed.

## The folders, the harness and the ports

`harness/`: `chk11.py`, `s911.py`, `tree11.py` (this unit's), `dur9.py`, `specwire9.py`, `seal9.py`, `cdp.mjs`, `cdp9.mjs` (copied,
md5-asserted), `mirror/{fail,accept,driven,html}.diff` (the mirrors' patches), `src/probe/{Etag,Http,Routes,Witness}.java` (unit 10's),
`src/probe/u11/U11Probe.java`. Ports: `21000` after/ harness-free, `21003` specwire9's harness-joined start, `21004` the S9.14 plant,
`21005` the driven wire, `21006` before, `21007` Chrome's DevTools, `21008` the exercise; `21001`, `21002`, `21009` never bound;
21280-21284 during `verify` only.

## Masks, filters and hygiene

The log mask (times, folders, the home, the page's footer clock, reactor times), the header mask, the HTML mask, each self-tested at
every run; every JVM stopped by its recorded pid, every Chrome by `Browser.close` and then its recorded pid; every Chrome profile
removed; every container of the ITs removed with its volumes.

## Interrupted

SIGINT, each run started by perl with the default handler for the signal, the driver stopping the run by the pid it recorded:
mid-build (the reactor build of `after/` in its page step), mid-harness (a JVM live on `21000`), mid-verify (Testcontainers alive),
mid-Chrome (the sealed Chrome's DevTools answering on `21007`), mid-mirror (the driven mirror's wire JVM on `21005`), mid-exercise (the
exercise's jar live on `21008`): each exit `130`, then no JVM and no Chrome profile, no listener in 21000-21009 or 21280-21284, no
Testcontainers container, volumes and images at the start's counts, the captures as they were, no `.r-lock` and no `.r-*.new`,
`c9-tiffinbox` equal to `after/`. Mid-container and mid-PostgreSQL do not apply (no PostgreSQL capture).

## Planted faults — each caught

In every run: the judge's planted red (the default page), the probe's filed events, the empty events file, a port the page never
asked, a non-loopback TCP connect planted in a NetLog copy, the S9.14 plant, the exercise's five refused variants, the masks' and the
listing parser's self-tests. On scratch copies of `after/` (never the anchor), one run each: the build step's version written inline, a
dependency without its test scope, the property's comment cut to one word, a `src/main` edit, the committed spec touched, a
`tiffinbox-client` edit, another test method, `49` left as the current count in the card - each `chk11.py static` exit `1`; a listing
line one byte off (a FAIL line, no traceback), an empty directory (`0 files`, never ABSENT), the shipped page's total typed above zero,
the footer's clock left unmasked, the judge's red typed green, the generated Accept one byte off, the web jar's md5 typed equal, the
hook one word changed, and four refused sentences through `s911.py` - each caught. One plant passed `chk11.py static`: a fully
qualified `@EnabledIf...` annotation on the shipped test. The `tests` capture's `Skipped` count and the exercise's switched-off variant
catch that tree; the static pattern is for RED.

## What differed from the brief

Each of the prompt's thirty flags is answered in the report to the orchestrator; the ones the runs moved or decided:
- The document-first status test writes `7` snippets, not the six the brief's line gives: it documents the four real members, so
  `response-fields.adoc` is written before its status check fails. BLUE's model documented no field there and wrote six.
- The field failure does not depend on the order: never sent and left undocumented each leave the six defaults in both orders.
- `nickname` marked optional does not pass: REST Docs refuses an absent optional field with no type (`FieldTypeRequiredException`).
- The socket-test census finds `5` classes on a real socket; the hand-off names two of them.
- The `nofonts` page's bytes also name `asciidoctor.org` (the default stylesheet's header), as RED #18 said.
- The web jar differs from unit 10's in one entry, the web module's own pom, and in no class entry.
- `index.adoc` is the probe's local page byte for byte; the shipped test's descriptions are this unit's own, so `path-parameters.adoc`
  and `response-fields.adoc` differ from the probe's while the six defaults hash the same.
- The earlier course's MockMvc lesson is not named here (its course's name is a refused call-back form in this unit's gate).
- `callpg` dropped, first in the drop order: H2 only; PostgreSQL not measured for `pass`.

## For RED

The class name `TiffinBoxRestDocsTest`; whether a documentation test belongs in the default run; the hook's second sentence scoped to
the field failure; the documented Content-Type under the generated client's Accept; the web jar's one differing entry; the
`-DskipTests` page; the driven candidate; the static check's blind spot for a fully qualified `@EnabledIf...` annotation.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:381` (documentation generated from passing tests, compared with spring doc honestly); C9-11 (the seven and the old
surface re-run at this anchor change); the Q-d hand-off (the two socket tests) is paid by `compare`. No ledger row names unit 11 (a
note for the orchestrator).

## The values the video may say

<!-- values: begin -->
```
tests: web_before=49 web_tests=50 client_tests=1 restdocs_skipped=0 its=14 it_classes=5 lib=157 reactor=4 skiptests_exit=0 skiptests_unresolved=4
change: restdocs=4.0.3 plugin=3.2.0 modules=3
pass: snippets=8 defaults_equal_blue=6 snippet_ct=application/json socket_ct=application/json
status: status_a=absent status_b_files=7
field: field_files=6 field_order_effect=none
accept: accept_none=application/json/application/json accept_generated=application/problem+json/application/problem+json accept_json=application/json/application/json
driven: driven_with_name=passed driven_without_name=SnippetException driven_type=tag:tiffinbox.example,2026:customer-not-found
html: hosts_shipped=0 bytes_shipped=3720 hosts_nofonts=2 bytes_nofonts=32645 hosts_default=3 bytes_default=32835 generator=2.0.23
sealed: chrome=158.0.8127.37 sealed_shipped=0 sealed_default=1 sealed_nofonts=0
compare: socket_tests=5 restdocs_operations=1 restdocs_snippets=8 springdoc_operations=13 springdoc_errors=6 springdoc_star=12 star_rows=3 kinds_a=6 rows_a=9 kinds_b=7 rows_b=10
committed: file_bytes=20306 spec_md5=e715f47c
moved: requests=19 moved=0 jar_entries_moved=1
seven: seven=466c20ed
surface: surface=316a9637
inert: 
exercise: broken=SnippetException solved=pass variants=5
static: xfam_s9s1_md5=1f5217a0 changed_files=6
gloss: gloss=a_snippet_one_line
spoken: hook_words=17 exercise_words=16 gloss_words=9
build: seed_files=11004 seed_bytes=876159996 central_only=0
```
<!-- values: end -->

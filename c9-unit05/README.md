# Course 9 · Unit 05 · PATCH Properly: JSON Patch and Merge Patch — evidence

Course 9's second anchor change. `before` is a link to `../c9-unit04/after` (U04's frozen anchor: Spring Boot 4.1.3, Framework
7.0.11, Tomcat 11.0.29, the key filter present and inert without its header), pinned by `harness/tree05.py` against
`../c9-unit04/receipts.md5`'s `after-tree` line. `after/` is a frozen copy of `../c9-tiffinbox` after this unit's change, pinned by
its own `after-tree` line; `diff -rq after ../c9-tiffinbox` is empty the day this unit lands. The change: `PATCH
/api/v1/customers/{name}` on JSON-P (merge patch and JSON Patch), every document the patch produces read back into the record and
checked, the rename evicting both names after the commit, JSON-P and Parsson declared directly.

The hook (S1B :333, byte for byte; the spoken line is RED's):

> Send Priya a PATCH with only her meals, and Jackson 3 refuses it: four hundred. Leave out her meal type instead, and it reads as null.

Its two sentences are true of two different routes, and the captures say which: "refuses it: four hundred" is the harness's naive
PATCH on Priya (`trap-a`, Boot's default mapper) and, beside it, TiffinBox's own create route with the same absent number
(`bodies`); "reads as null" is the record the mapper reads (`bodies`: `mealType=null`), which the create route then refuses by its
rule, and which the naive PATCH sends on to the table (a five hundred there, `trap`'s String-absent body, on Ravi). The hook says
"reads as null", never an answer code, for the second sentence.

The gloss this unit owns (SECTION SHAPE, S1B :387), one sentence on a line of its own; its first spoken use is this line:

A partial update: a change that names only the fields it changes.

## Runs of record

Three runs, each launched below load1 20 with the load printed on its first line, every build offline, `check_unit9.py 05 --runlog`
PASS on each run's log (the unit gate exits 2: no `05-*.md` script exists yet, expected):

```
bash 3.2.57  ./receipts.sh            13:12 CET, load1 3.65 at the launch (4.08 before verify) · exit 0 · "c9-unit05: every capture = published (21)"
bash 5.3.9   bash receipts.sh         13:17 CET, load1 3.90 (3.75 before verify) · exit 0 · the same
sealed clone a local git clone of HEAD c0b0e73 into ".../sealed clone/tiffinbox-java" (a path with a space), this folder's and
             c9-tiffinbox's changed files copied in, the seed copied by the receipt itself; bash 3.2.57 ./receipts.sh
                                      13:22 CET, load1 4.59 (5.24 before verify) · exit 0 · the same
every build offline: Downloading/Downloaded from 0 in each log · the ITs' log waits: none timed out
check_unit9.py 05 --runlog <log>: RESULT (run logs): PASS on each (0 grep error lines, R.166)
```

The capture hashes (`receipts.md5`), equal in all three runs:

```
before-tree 92 8761a535e4940fe7d5b0d9d0c7dea711
after-tree 94 333c596e9a2fd8c5b2485e1845bcce37
tests 8caf4cbbb3cc6285c1ec4c2c2e6888b6
bodiespg 586ba37e2492b6d8094f94535d948c37
mergepg b33f40b4d854593f188a20aa76e03a97
jsonpatchpg d68de2e1d324a027abd3fff0b1bef2e1
retrypg 24078f462fc8e787ae3d658e1a7133e5
renamepg dc65af7ce5850d3896492cdd6ffd2620
trappg ee8b901ff865d72692572203962c6d57
stalepg 56a3e1f27d85220bffc013b911eaab93
jsonp d8e9e9dfbf7919b75a267e63be87028b
bodies 4e2b5f0d9752eafa17f6b8442d9d62fc
merge c8ea4694995dff62d85764748374be1e
jsonpatch a6d972effd8e413ed3b9a94cca070974
retry cc5b0808b6b4e0693dd13819e2f5ad1b
rename eac8ba66484d6aaa949045532702c120
reader 2259e89b7a11de310f1be8a41e738516
trap 915418d61da99b6c37e90f3d4787f200
stale 6ced0ab6dd200b2e6077f105d8c0f6e8
matrix f5d168406000f7ff808d6b1b8077bcc9
moved e8ec446ac8df2629aa35891863c44fb7
inert 3843cf94e811d137222d355821e88256
exercise 80faa5dd9f3e4c91c589e523a0817b36
```

## RE-MEASURE (settled first)

1. **The trap, on the shipped tree** (PostgreSQL 18.6 first, H2 the same; the row by the second client - `psql` in the container,
   the harness's JdbcTemplate route on H2). `trap-a` (Boot's default JVM, `FAIL_ON_NULL_FOR_PRIMITIVES` printed enabled): the
   harness's naive PATCH `{"mealsPerDay":2,"mealType":"VEGAN"}` on Priya answers four hundred, "Failed to read request", and her row
   stays `Priya 1 120 VEGAN v0`, `/revenue` `24300`. `trap-b` (the attribute switched off on the command line, once, printed
   disabled): the same body answers two hundred and the second client reads `Priya 2 0 VEGAN v1`; `/revenue` `24300` → `20700` on
   both databases (a fresh seed per database: the brief's `60900 → 53700` was another tree's). The `@Valid` copy of the same route
   refuses that body first (four hundred, "the body breaks 2 rule(s)": `name`, `pricePerMeal`). `trap-a2` (a fresh JVM, the default
   again): four hundred, and the row as `trap-b` left it - the zero is the earlier write. The String-absent body
   `{"mealsPerDay":2,"pricePerMeal":150}` through the naive route answers five hundred (Boot's `/error`, `DataIntegrityViolationException`:
   the table's NOT NULL), one write statement sent and refused, Ravi's row unchanged. The trap is conditional: with the attribute
   switched off, the harness's copy wrote a price of zero; on the default the read refuses it.
2. **The four bodies** through TiffinBox's own `POST /customers` (`@Valid @RequestBody Customer`, untouched by this unit): an absent
   `mealsPerDay` and a `null` one → four hundred, "Failed to read request" (Boot's problem-details handler; Jackson 3's
   `MismatchedInputException: Cannot map null into type int`); an absent `mealType` and a `null` one → four hundred, "the customer
   breaks 1 rule", `mealType: must not be null` (the route; the record held `mealType=null`, JsonProbe's line). Write statements 0
   each. An absent number is refused at the read; an absent text field reads as null. Also printed by JsonProbe: `120.5` refused
   (`ACCEPT_FLOAT_AS_INT` disabled), an unknown member ignored (`FAIL_ON_UNKNOWN_PROPERTIES` disabled).
3. **The shipped route's answers**, equal on PostgreSQL and H2 on every HTTP column and the author (`matrix`, U03's author rule):

```
200  the route                         a merge patch; a JSON Patch; an unknown member (dropped by the read back, the row unchanged)
   400  the route                         a merge patch that is not JSON; a JSON Patch that is an object, not JSON, an unknown op,
                                          a missing value, a path to no member (checked before JSON-P applies it)
   404  TiffinBox's advice                a name nobody has (CustomerNotFound)
   409  the route                         a failed test operation; a rename to a taken name
   415  Boot's problem-details handler    application/json, with Accept-Patch naming both media types
   422  the route                         a null on a required member (removed by the merge), null or text where a number goes, a
                                          broken rule (mealsPerDay 9), a JSON Patch remove of a required member
```

   The route's own bodies carry no `type` (`about:blank`) and Framework fills `instance` with the request path on every one; no
   body names a class, Jackson's text or JSON-P's. JSON-P's words for the failed test ("The JSON Patch operation 'test' failed for
   path '/mealsPerDay' and value '9'") are in the JVM's log line the route writes, not in the body. The same broken rule answers
   four hundred on the create route and four twenty-two on the patch (RFC 5789 names four twenty-two for an unprocessable request,
   section 2.2). The shipped route answered no five hundred in any request; the harness's routes beside it did (JSON-P's parse
   error outside any catch, the unmapped read back).
4. **The rename**: on the shipped tree (U04's transaction-aware proxy on, the default) `{"name":"Mira"}` on Meera, warm first - the
   cache before the rename `customers [SimpleKey []] customer [Meera]`, after it `customers [] customer []`; then
   `GET /customers/Meera` four oh four (TiffinBox's advice), `GET /customers/Mira` two hundred, the list renamed. On the planted
   no-evict copy (the shipped class with its `@Caching` removed, the harness's plant) the old address answers two hundred from
   Caffeine (statements 0), the new one from the table, the list still holds the old name. The old address answers until the entry
   is evicted or its time to live ends; the capture prints the configured value, read back from application.yaml :159 and from the
   running cache's policy (the block below). A rename to a taken name: four oh nine, the route's; Ravi one row, Mira one row.
```
spec: maximumSize=100,recordStats,expireAfterWrite=10m · customers.expireAfterWrite PT10M customer.expireAfterWrite PT10M
```

5. **JSON-P and Parsson declared directly.** Before: both jars only through the Elasticsearch starter (the tree below, `before`
   then `after`, as `dependency:tree` printed it). After: both direct.

```
before  \- org.springframework.boot:spring-boot-starter-data-elasticsearch:jar:4.1.3:compile
           \- org.springframework.boot:spring-boot-elasticsearch:jar:4.1.3:compile
              \- co.elastic.clients:elasticsearch-rest5-client:jar:9.4.9:compile
                 +- jakarta.json:jakarta.json-api:jar:2.1.3:compile
                 \- org.eclipse.parsson:parsson:jar:1.1.9:compile
after   +- jakarta.json:jakarta.json-api:jar:2.1.3:compile
        \- org.eclipse.parsson:parsson:jar:1.1.9:compile
```

   The pin `<parsson.version>1.1.9</parsson.version>` in the parent
   (the seed holds `1.1.7` and `1.1.9`; `1.1.9` is the jar `BOOT-INF/lib` already held). `BOOT-INF/lib` `146` → `146`, no jar's name
   moved. The running JVM's provider: `org.eclipse.parsson.JsonProviderImpl` from `parsson-1.1.9.jar`; `createMergePatch` →
   `JsonMergePatchImpl`, `createPatch` → `JsonPatchImpl`.
6. **The tests per runner**: `mvn -o verify` on a copy of `after/` - the test phase on H2 `40` = U04's `28` + `12`
   (`CustomerPatchesTest`), the five ITs `14`, each on its fixed port of `127.0.0.1:21280`-`21284` (five `IT BINDINGS` lines, `0`
   entries off `127.0.0.1`), Testcontainers containers after `0`.
7. **The seven and the old surface** on `before` and `after/`, each set in its own JVM: the seven and the old surface both equal to U04's (the values block holds
   their hashes); `moved`: the old addresses' PATCH rows (`/customers`, `/customers/Ravi`, `/revenue`,
   `/shutdown`) and `OPTIONS /customers/Ravi` equal on both trees (`PATCH /customers` four-oh-five, `Allow` the set {GET, POST}).
8. **Handler methods** (one flag start): TiffinBox's `16` = the set-up's `12` + U04's `2` + U05's `2` (`CustomerPatches#merge`,
   `CustomerPatches#jsonPatch`).

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

- `pom.xml` (the parent): `<parsson.version>1.1.9</parsson.version>`, once, with its comment (S9.7). Nothing else moves: the Boot
  parent stays `4.1.3`, `tomcat.version` and `h2.version` untouched.
- `tiffinbox-web/pom.xml`: `jakarta.json:jakarta.json-api` (no version: Boot's `jakarta-json.version`, `2.1.3`) and
  `org.eclipse.parsson:parsson` (`${parsson.version}`), each with a comment line, beside the Elasticsearch starter, which stays.
- `tiffinbox-core/.../CustomerEntity.java`: `change(name, mealsPerDay, pricePerMeal, mealType)` - the entity had a setter for the meals
  alone; the route changes every member.
- `tiffinbox-core/.../CustomerRepository.java`: `update(name, change)`, inside its own `@Transactional(rollbackFor = SQLException.class)`,
  the row loaded by name from the table (never a cached record), flushed so a taken name is refused there; `@Caching` evicts every
  entry of `customers` and the old and the new name in `customer`. The class Javadoc's Course 8 unit 08 sentence ("add empties that
  cache") gains a *Course 9, unit 05* paragraph: add is no longer the only write that empties a cache.
- `tiffinbox-web/.../CustomerPatches.java` (new): the route, `final`, package-private, one handler per media type (`consumes`).
- `tiffinbox-web/src/test/.../CustomerPatchesTest.java` (new): twelve tests on the whole application, H2, over a socket.
- `README.md`: the set-up paragraph's "no PUT, PATCH or DELETE route" kept as written, with a note beginning *Course 9, unit 05*
  after U04's; a `## Course 9 · unit 05` card. U04's card's "`/customers/import` and `PATCH` are not keyed" stays (still true).
- Not changed: `TiffinBoxErrors.java` (the route builds its own problem bodies), `application*.yaml` (the route needs no key).

The hunt over `c9-tiffinbox/` (`git grep -n`): `PATCH`, `no PUT`, `partial`, `Allow:`, `handler methods`, `twelve`, `18 + 10`, `28`,
`146`, `parsson`, `JSON-P`, `jakarta.json`, `Elasticsearch client`, `evict`, `empties that cache`, `expireAfterWrite`, `after the
commit`, `Boot's mapper`, `FAIL_ON_NULL_FOR_PRIMITIVES` - each hit is history in a dated unit section, or the two sentences above
with their notes; `chk05.py static` asserts both notes.

R.211/R.331's grep (`c9-tiffinbox` in `c9-unit0{1,2,3,4}/receipts.sh`, their `harness/*`, `C9/_builders/*.py` and the Java 9 tools):

```
c9-unit01-04/receipts.sh   after/ against ../c9-tiffinbox: a NOTE since 959f6ae (never fatal); U04's end sweep compares the note at
                           the start with the note at the end - a later unit's move is not a stop
c9-unit01/receipts.sh :97  git grep at the pinned set-up commit - not the live tree
c9-unit0{1,2,3}/receipts.sh, c9-unit04 :521  find ../c9-tiffinbox -name '*.mv.db' - a sweep, not an equality
c9-unit03/receipts.sh :197-198 and harness/chk03.py :509-519   LIVE READS of ../c9-tiffinbox's main sources (setInstance;
                           ProblemDetail.forStatus… lines) - this change adds one ProblemDetail.forStatusAndDetail line
                           (CustomerPatches), so U03's `instance` view prints another line when its receipt is re-run at HEAD
c9-unit04/receipts.sh :81  git archive at the set-up commit 80f7839 - pinned
C9/_builders/clone_java9_tools.py, T/upload_java9.py      the name in a constant or a comment - no read of the tree
```

## Which tree, which profile

`before` = `../c9-unit04/after` (a link, its text exact), `after/` = this unit's frozen copy; both built offline under `.harness/`
from a `cp -c` copy of `m2-seed-c9-u04` (`10068` files). The default run (H2 in memory) and PostgreSQL 18.6 by digest (the image
U04's receipts name) through `-Dtiffinbox.jdbc-url`, the jar's own driver `postgresql-42.7.14.jar`. Every JVM prints Tomcat
`11.0.29`, Hibernate ORM `7.4.15.Final`, Boot `4.1.3`, Framework `7.0.11` and the database it answered from. Jackson: Spring MVC's
converter and Boot's mapper bean are Jackson 3 (`tools.jackson.databind.json.JsonMapper (3.1.8)`, JsonProbe's line); every body
of this unit is read and written by it.

## The captures — what each one shows

### tests — the counts per runner, the jars, the handler methods
`mvn -o clean verify` on `.harness/tests` (a copy of `after/`): Surefire's XML per class, Failsafe's per IT, the five `IT BINDINGS`
lines; `BOOT-INF/lib` before and after; the flag start's `/actuator/mappings` read by `chk05.py mappings`.

### bodies, bodiespg — the four bodies into the record
The create route, JSON, the four bodies, write statements 0 each; JsonProbe's lines from the same JVM's start.

### trap, trappg — the failure receipt
Three JVMs per database on one database each (an H2 file under `.harness/`, PostgreSQL's database kept across them), the row by the
second client and `/revenue` before and after each request.

### merge, mergepg — the shipped merge patch
On Meera: `{"mealsPerDay":2}` → two hundred, price and meal type kept, the version one higher; every refused body leaves her row as
it was. RFC 7396 :180-182 printed (in a merge patch, null removes the member) and RFC 5789 :355-356 (`Accept-Patch`).

### jsonpatch, jsonpatchpg — the shipped JSON Patch
On Meera: `replace` → two hundred; the failed `test` → four oh nine, JSON-P's words in the log line; the shape errors four hundred
with no statement; RFC 6902 :185-186, :366-367, :419-420 and RFC 5789 :292-294 printed. Beside it, the harness's route shows why the
route checks the shape itself: JSON-P's `JsonException` is one class for an unknown op, a missing value, a path to no member and a
failed test (each a four oh nine there, its message in the body), and an object in place of the array is a five hundred there.

### retry, retrypg — each patch sent twice
On Ravi, no key header: this merge patch answered two hundred twice, the row equal after both (the version `v0 → v1 → v1`: the
second wrote nothing, Hibernate's dirty check); this test-then-replace patch answered two hundred, then four oh nine, the row as
after the first. The key table holds `0` rows. RFC 5789 :132-133 is printed in the capture (the RFC's own clause on the method).
U04's key is not extended to PATCH: *Idempotency, Safety and Retries* (the lesson before) keys two POSTs; U21's lesson on the
caller's side is where a retry's second answer is the subject.

### rename, renamepg — the evicting save
Both caches' keys before and after every request (the harness's `/probe/u05/cache`, read off Caffeine's map). The order step is read
by the keys before and after each request only; U04's `order` capture holds the keys inside the transaction.

### stale, stalepg — the planted no-evict copy
The same requests on a JVM whose class path starts with `.harness/pc-noevict` (the plant's one class). `chk05.py`'s cannot-fail
detector runs the check "the old address answered two hundred" on the shipped rename's capture and shows it fails there.

### reader — readerForUpdating, weighed (H2)
The S1 probe's `/probe/reader` route on Sunil: `{"mealsPerDay":2}` two hundred, price and type kept; `{"mealType":null}` four hundred
(the probe's own rule check); `{"pricePerMeal":null}` five hundred unmapped, four twenty-two mapped; an unknown member two hundred,
nothing changed; a rename four twenty-two (the probe's own check). JsonProbe printed a record coming back from `readerForUpdating`.
Beside it, the shipped route on the same bodies: two hundred, four twenty-two, four twenty-two, two hundred, and a rename (Sunil to
Sunny) two hundred. Why it is not shipped, as measured and no more: it is Jackson's merge, not RFC 7396's - readerForUpdating set
the member to null where a merge patch removes it (the same answer for TiffinBox's four required members); JSON Patch needs JSON-P
anyway. The optional-member demonstration on a harness record: named, not shown.

### matrix — every PATCH answer and its author
`chk05.py view matrix` over the eight captures above, one row per PATCH request: status, content type, bytes, `Accept-Patch`, the
author with its evidence, `instance`, statements and writes. PostgreSQL and H2 equal row for row.

### moved — the old addresses keep their answers
U02's PATCH rows on the four old addresses and `OPTIONS /customers/Ravi`, on `before` and `after/`, each its own JVM; the new address
beside: `OPTIONS` two hundred with `Allow` {OPTIONS, PATCH} and both media types in `Accept-Patch`, `GET` four-oh-five (`Allow`
{PATCH}: no GET route there, not in this change).

### inert — the seven and the old surface
On `before` and `after/`, and the S9.14 self-test in its plant slot (a shallow-ETag filter on every path, the harness's plant): the
seven unchanged, the old surface moved, the feed answered nothing.

### exercise — under bash and zsh
`exercise/README.md`'s block (broken: four fifteen), `SOLUTION.md`'s line (solved: two hundred, her price and type kept), and the
four refused "solutions", against TiffinBox's jar alone on `20948`, `env -i`, a stale `patch.status` planted first.

## Measured, not shipped

The harness (`--spring.main.sources`, never in the jar): `probe.Witness` and `probe.Http` (statements and the request witness),
`probe.Routes` (the second client on H2), `probe.Patch` (the S1 probe's naive, naive-valid, JsonNode merge, JSON-P merge, JSON Patch,
reader and rename routes under `/probe/**`), `probe.JsonProbe` (the mapper's features and the four bodies at the start),
`probe.u05.U05Probe` (`/probe/u05/cache`, `/keys`, `/rows/{name}`, `/jsonp`), `probe.Etag` (the S9.14 plant), the flag
`spring.jackson.deserialization.fail-on-null-for-primitives=false` (`trap-b` only), the planted no-evict `CustomerRepository`, the
resolver's DEBUG line (`ExceptionHandlerExceptionResolver`, harness logging), the flag start that exposes `mappings`.

## Refused, named

Each in a code span, as the prose gate reads it: `Jackson 3 writes zero` (only with the attribute switched off); `an absent field
is null` (by type: a number is refused at the read, a text field reads as null); `a PATCH is idempotent` or `is not` (this merge
patch answered two hundred twice; this test-then-replace patch answered two hundred, then four oh nine); `Spring applies the patch`
(JSON-P's `createMergePatch` and `createPatch` did, the classes printed); a key on PATCH, and U04's key extended to PATCH (U04's
lesson, unchanged); a PATCH on the old `/customers/{name}` (it would move U02's table, its `Allow` sets, U03's rows and the old
surface); `the cache catches up`, `the window closed`, a count in the time to live's own unit; `over-posting closed` (an unknown member is dropped by the
read back - U22's allow-list); a five hundred from the shipped route (none); `readerForUpdating` as the shipped design; a line count
as a verdict; a time printed under load.

## The repository, and the network

`D` = `_deliverables/tiffinbox-java`, HEAD at the start `c0b0e73` (U03), with `959f6ae` (the receipts-note fix), `cabc6d3` (U02),
`f688858` (U01) and `a0a0151` (U04) its ancestors; `origin/main...main` = `0 0` from the local tracking ref. ONE commit for
`c9-unit05/` and `c9-tiffinbox/`'s changed paths, pushed. No network of any kind but that push: every build offline from the seed's
copy (`Downloading from` 0, `dependency:tree` included), no image pulled, the RFCs the filed copies in `docs-2026-11-23`
(`rfc5789.txt` `ad5f0682…`, `rfc6902.txt` `06962a30…`, `rfc7396.txt` `ab6d14c1…`), no advisory read or cited.

## The folders, the harness and the ports

`before` (the link), `after/` (the frozen copy) · `receipts.sh`, `receipts.md5` · `harness/` (`chk05.py`, `s905.py`, `tree05.py`,
`dur9.py`, `src/probe/{Witness,Http,Etag,Routes,Patch,JsonProbe}.java`, `src/probe/u05/U05Probe.java`) · `exercise/` (`README.md`,
`patch.sh`, `check.sh`, `SOLUTION.md`) · `README.md`. `Witness`, `Http`, `Etag` = U03's published files (its `receipts.md5`);
`Routes` = U04's; `Patch`, `JsonProbe` = the S1 probe's (`BR/instruments/probe-src/MD5SUMS`). Ports, U05's band: `20940` after/ on
H2 · `20941` PostgreSQL · `20942` after/ on PostgreSQL · `20943` the S9.14 plant · `20944` the trap's JVMs · `20945` the planted
no-evict JVM · `20946` before · `20947` asserted free · `20948` the exercise · `20949` never bound; `21280`-`21284` during `verify`
only.

## Masks, filters and hygiene

The log mask (times, the folders, the home, the user, Boot's `timestamp`) and the header mask (`Date`, the session cookie's value, a
port, `Expires`) are each self-tested on planted lines at every run. Spring MVC writes `Accept-Patch` in no fixed order from one JVM
start to the next (both orders in one run): every capture prints it as sent and as a sorted set, and the hash reads the set; the
exercise prints it sorted. Every docker call names the pinned socket; the container is removed with its volumes; images and volumes
are equal at the start and the end.

## Interrupted

SIGINT at six points of a real run of this receipt (development runs, `DEVCAPS` naming one capture, so the point comes sooner),
each run started with SIGINT reset to its default (U01's finding: a job started in the background ignores SIGINT, and bash cannot
trap a signal ignored at entry), the signal sent to the receipt's own process at a count condition on its log or Docker's state:

```
mid-build          (after/'s offline build)                                   exit 130
mid-verify         (mvn verify, a Testcontainers container alive)             exit 130
mid-container      (PostgreSQL up, before TiffinBox)                          exit 130
mid-tiffinbox-pg   (TiffinBox on 20942, PostgreSQL's JVM)                     exit 130
mid-harness        (TiffinBox on 20940, H2's JVM, the harness joined)         exit 130
mid-exercise       (the exercise's TiffinBox on 20948)                        exit 130
after each: java 0 · listeners 20940-20949 and 21280-21284 0 · c9u05-pg 0 · Testcontainers containers 0 · images 9 · volumes 315 ·
            the published captures unchanged · .r-lock gone · .r-*.new 0 · c9-tiffinbox = after/ (diff -rq empty)
```

Exit `130` is the receipt's own `INT` trap (`exit 130`); its `EXIT` trap stops every JVM of the run by its pid, removes the
Testcontainers containers by their label and the PostgreSQL container with their volumes, and drops the unfinished captures.

## Planted faults — each caught

Run on a scratch mirror of this folder (its siblings linked read-only; the mirror's receipt pointed at a socket that does not
exist, so no plant could reach a container), each made to fail first; each ended with its FAIL line, the prose gate's refusal or
the receipt's `***` line, a non-zero exit, no traceback (`plants.sh`'s own count: 68 run, 68 caught):

```
hook one byte
hook 400 in digits
hook four hundred and six
hook 'reads as null' removed
exercise one byte
exercise 415 in digits
exercise the :342 stale line
gloss one word
prose: Jackson 3 writes a price of zero.
prose: An absent field is null.
prose: A PATCH is idempotent.
prose: Spring applies the patch.
prose: The cache catches up.
prose: It returns in a second.
prose: The window closes after ten minutes.
prose: It answers 406.
prose: It answers four hundred and twenty-two.
prose: Over-posting is closed.
prose: The merge route is simpler.
prose: A PUT is idempotent.
prose: Most APIs do this.
prose: The patched customer is stored.
a duration word in the exercise
trap-b: the price not written
trap-a answering 200
trap-b printing the feature enabled
the @Valid copy answering 200
a merge null answered 200
the 415 planted 200
Accept-Patch absent from the 415
a merge answer 500 from the shipped route
the checker fed a line it cannot parse
a failed test answered 200
an unknown op answered 500
the 409's body carrying jakarta.
the retry's 409 typed 200
a key row planted
the old address 200 on the shipped route
the stale plant answering 404
expireAfterWrite printed as another value
the cannot-fail detector: the shipped rename planted stale
a matrix row's author typed wrong
a matrix row removed
the cross-database equality broken by one byte count
the PostgreSQL rows labelled H2
the second jar missing from after's tree
an IT BINDINGS line removed (4 classes)
an IT's IP 127.0.0.2
an IT's port off by one
a 147th jar in the BOOT-INF/lib listing
the seven's md5 one character off
a PATCH row moved on after vs before
the solution = the broken (solved fails)
a refused solution passing
a body stored (201)
parsson.version removed from the parent
a stale sentence left (no PUT, PATCH or DELETE route unqualified)
the old Javadoc 'add empties that cache' alone
tree05.py's hash typed wrong in receipts.md5
before's link text with a slash
before linked to ../c9-unit03/after
before a copy, not a link
one byte changed in after/ (the pin)
a placeholder in the exercise
dk() without the pinned socket
a container removed without -v
a request line carrying the key header
a request to the pause route
```

Not planted: the mask self-tests (they run planted lines at every run of record); the S9.14 plant runs in every run of record, in
its plant slot (`inert`).

## What differed from the brief

Read in: `C9/FACTORY-NEXT.md`'s `EVIDENCE 03 LANDED` (12:32), `EVIDENCE 02 LANDED`, `RECEIPTS-NOTE FIX LANDED`, `EVIDENCE 04/01
LANDED`; `git log -6`; `c9-unit03/harness/chk03.py` (the author rule), `c9-unit04/receipts.sh`, `c9-unit04/README.md`.

- Flag 1 (an anchor change): taken - the second anchor change; `before` a link, `after/` a frozen copy, one commit for both folders.
- Flag 2 (link form and pins): taken; `tree05.py` is `tree04.py`'s code with its docstring changed.
- Flag 3 (HEAD and the push): HEAD `c0b0e73`, `0 0`; the precondition "anchor check is a note" in the log: 1.
- Flag 4 (the failure receipt): `trap` (the zero written with the attribute off); `stale` is the lesson's second part.
- Flag 5 (the exercise): #37's line (its word count asserted by `chk05.py spoken`); the :342 line is not used.
- Flag 6 (the hook): byte-equal to S1B :333 (its word count asserted); its two sentences mapped to their routes above. Its one digit is Jackson's
  major, `3`; no gate refuses it.
- Flag 7 (four hundred or four twenty-two): measured on the shipped route - four twenty-two for every document after the patch that is not a valid
  customer, four hundred for a patch that is not one. The probe's harness mapped a broken rule to four hundred; the reader route
  still does (the S1 probe's code, unchanged).
- Flag 8 (where the route lives): `PATCH /api/v1/customers/{name}`; `moved` shows the old addresses unchanged. U02's printed table
  rows were not re-read line by line from `c9-unit02/README.md`: `moved` compares `before` with `after/` in this run (equal); the
  pinned sentence's facts are asserted from the capture.
- Flag 9 (PATCH and the key): named, not extended; no request of this unit carries a key header (receipts.sh's gate), the key table
  `0` rows. `CustomerPatchesTest.aPatchIsNotKeyed` sends one PATCH with a key header and asserts no key row: the test, not a capture.
- Flag 10 (JSON-P's words): in the log line `tiffinbox.patch` writes (INFO), never in the body; the route's own detail is its own sentence.
- Flag 11 (the pin): `1.1.9`, the jar `BOOT-INF/lib` already held (the seed also holds `1.1.7`: the version Maven resolves is the
  one the Elasticsearch client's POM names, printed by `dependency:tree`). The Elasticsearch client is `9.4.9` on this tree (Boot
  4.1.3), not the boundary's `9.4.8` (read on 4.1.2): a moved version, named. The copy without the Elasticsearch starter: dropped
  ("removing the starter would remove JSON Patch" is not said).
- Flag 12 (tests and verify): ONE `mvn -o clean verify` on a copy of `after/` per run (its test phase is the package-time suite: the
  same Surefire XML), not a separate `package` and `verify`: one suite per runner, counted off the XML. `before`/`after/` are built
  `-DskipTests` for their jars (U04 cited for `before`'s `28`, its README values block).
- Flag 13 (handler methods): `16` = `12` + `2` + `2` from the one flag start.
- Flag 14 (`readerForUpdating`): the five rows plus the rename on the probe's route, H2 only; the optional-member demonstration and
  the PostgreSQL half dropped first (the drop order).
- Flag 15 (lines): the rule (signature line to closing brace, non-blank, non-comment) gives naive `5`, JsonNode merge `35`, the
  shipped merge `7`, the shipped JSON Patch `13`, against the brief's `6 · 36 · 14 · 21`; the differences are the rule (no annotation
  line counted) for the first two, and the shipped design for the last two (the read back, the shape check and the answer live in
  helpers: `87` lines, counted apart). Never a verdict.
- Flag 16 (the S9.9 entry): nothing written in `dur9_allow.py`; the value is in fenced blocks and code spans only.
- Flag 17 (the order step): the keys before and after each request only; U04's `order` capture cited for inside the transaction.
- Flag eighteen (the frozen receipts): filed above. A finding beyond the prompt's list: U03's `instance` view reads `../c9-tiffinbox`'s
  live main sources; this change adds one `ProblemDetail.forStatusAndDetail` line, so U03's receipt re-run at HEAD prints a
  different `instance` capture than the one it published. Not mine to fix (U03's folder is read-only here): for the orchestrator.
- Flag nineteen (the pinned sentence and the hunt): the note added in place; U04's "PATCH not keyed" stays.
- Flag 20 (PostgreSQL's start): U04's form - the digest asserted equal to U04's `IMG=`, `--pull never`, trust on the loopback.
- Flag 21 (S9.3): every row names its author; no request targets a pause route.
- Flag 22 (the author rule): U03's `parse` / `author` / `CLASSES`, copied into `chk05.py` (the cache sub-line widened to both
  caches); the resolver witness is U03's - Spring's own DEBUG line, no observer class written.
- The route's design, decided here: the body read as `byte[]` and parsed by JSON-P (the brief said Jackson's `JsonNode` first), so a
  merge patch or JSON Patch that is not JSON is the route's own four hundred, not Spring MVC's "Failed to read request".
  `CustomerEntity` gains `change(…)` (the brief's file list did not name it: the entity had a setter for the meals alone).
  `TiffinBoxErrors` is not touched.
- The fresh seed per database: the trap's `/revenue` is `24300 → 20700` on both (BLUE's `60900 → 53700` was a tree with more rows).
- Spring MVC writes `Accept-Patch` in no fixed order from one JVM start to the next (the same class as U02's `Allow` finding): hashed as a set;
  the exercise prints it sorted.
- `retry`: the second merge patch wrote nothing (Hibernate's dirty check: the version `v0 → v1 → v1`), not "+2" as the prompt guessed.
- Dropped (the drop order): `reader`'s optional-member demonstration and its PostgreSQL half; `jsonp`'s copy without the
  Elasticsearch starter. Everything else ran, PostgreSQL and H2.

## For RED

- The hook (byte-equal; its word count in the values block): its first sentence is the harness's naive PATCH (`trap-a`) and the create route; its second is the
  mapper's read (`bodies`). On the naive PATCH the String-absent body is a five hundred (the table's NOT NULL), on Ravi in this run,
  not Priya: the README says "Priya" only for `trap`.
- The exercise: #37's line, its word count in the values block; broken four fifteen, solved two hundred; `Accept-Patch` names the fix.
- The asymmetry the lesson must carry: the same broken rule is four hundred on the create route and four twenty-two on the patch.
- The address: `PATCH /api/v1/customers/{name}`; on the old `/customers/{name}` it would have moved U02's table rows, every `Allow`
  set on that address, U03's rows and the old surface.
- PATCH is not keyed; this merge patch answered two hundred twice, this test-then-replace patch two hundred then four oh nine.
- JSON-P's words are in the log line; the body's detail is the route's own sentence.
- The stale sentence wants one S9.9 `ALLOW` entry bound to `stale`'s capture line of the configured time to live (BLUE's, after RED
  reads it), or that part of the lesson is cut: the line begins "the configured time to live (application.yaml, read back)".
- Lines per approach: `5 · 35 · 7 · 13` by the rule against the brief's `6 · 36 · 14 · 21`; the shipped methods hand the work to
  helpers (`87` lines).
- `readerForUpdating` set the member to null where a merge patch removes it; for TiffinBox's four required members the answer is the
  same; the optional-member demonstration was not shown.
- The handler counts for U06: `16` = the set-up's `12` + U04's `2` + U05's `2`; U06's hook counts "the mappings minus what U04 and U05
  added" - `12`.
- The gloss: "A partial update: a change that names only the fields it changes." (first spoken use: its own line).
- Call-backs by title (read off `java9_series.TITLES` / Course 6 / Course 8 sources): *Request Bodies and HttpMessageConverter*,
  *Jackson in Spring*, *Validation on the Way In*, *ProblemDetail and RFC 9457*, *@Cacheable, @CacheEvict, @CachePut*, *Cache
  Invalidation*, *Idempotency, Safety and Retries*, *Resources, URIs and the Method Table*, *Status Codes That Mean Something*,
  *ETags and Conditional GET*, *Input Hardening*, *Versioning Strategies*, *Documenting Errors, Examples and Security*, *API Design
  Review*. U21's title is not written in this README: the prose gate's wait-word family refuses its first word (a finding: the title
  needs a gate allowance, or the README names it by number).
- From U05 on, PATCH answers four twenty-two too; U03 (viewed before U04) calls four twenty-two "the next lesson's": a note, not a defect.
- The frozen receipts (flag eighteen) and U03's live `instance` read: the orchestrator's decision.
- RED-C9-S1 #1 (counts derived), #9 (reader weighed), #10 (trap-b the receipt), #11 (four twenty-two mapped, measured), #25 (the
  S9.9 entry, handed over), #36 (trap-a/b/a2), #37 (the exercise); BLUE C9-U04 #11 (the shape checked before `apply`; the merge
  route's parse error is the route's four hundred; no class names in `detail`; the retry hazard named).

## The ledger rows this unit pays

`$B/_briefs/TRACK-ROADMAP.md:373` (read the day this was written): "05 **PATCH Properly: JSON Patch and Merge Patch** — the
partial-update null trap reproduced." No ledger row is owned by U05. **C9-11** paid at this anchor change: the seven and the old
surface on `before` and `after/`, equal to U04's. **C9-10a** not moved: "A PATCH to slash customers answers four-oh-five, and its
Allow header names POST and GET" is still true on `after/` (`moved`). C9-4 and C9-8 (`@Version`, ETags) named for *ETags and
Conditional GET*: the version moves one per UPDATE here, no `If-Match` on PATCH. C9-2 named for *Versioning Strategies* (the
literal `/api/v1/…` mapping). C9-18 named for *Documenting Errors, Examples and Security*: the route's bodies stay `about:blank`.
C9-12 untouched.

## The values the video may say

Each read off a capture of every run of record, PostgreSQL first, H2 the same:

```
trap-a        400 "Failed to read request" · Priya 1 120 VEGAN v0 kept · /revenue 24300      (trappg, trap; the harness's naive route)
trap-b        200 · Priya 2 0 VEGAN v1 · /revenue 24300 -> 20700 (attribute off)              (trappg, trap; second client: psql / JdbcTemplate)
trap-a2       400 · the row as trap-b left it                                                (trappg, trap)
bodies        400 x4: absent/null int by the read (Boot's handler), absent/null text by the rule (the route); mealType=null read
merge         {"mealsPerDay":2} -> 200, price and meal type kept, version +1                  (mergepg, merge)
merge 415     application/json -> 415, Accept-Patch application/json-patch+json, application/merge-patch+json
jsonpatch     a failed test -> 409, the row unchanged; JSON-P's words in the log line         (jsonpatchpg, jsonpatch)
422           a null on a required member, null or text where a number goes, a broken rule
retry         merge twice 200, 200 · test-then-replace 200, then 409 · key rows 0             (retrypg, retry)
rename        old 404 (TiffinBox's advice) · new 200 · list renamed · taken name 409          (renamepg, rename)
stale         the planted copy: old 200 from Caffeine (statements 0) · expireAfterWrite=10m  (stalepg, stale)
versions      Boot 4.1.3 · Framework 7.0.11 · Tomcat 11.0.29 · Jackson 3.1.8 · Parsson 1.1.9 · jakarta.json-api 2.1.3
counts        tests 40 = 28 + 12 · ITs 14 · BOOT-INF/lib 146 -> 146 · handler methods 16 = 12 + 2 + 2
exercise      broken 415 -> solved 200, her price and meal type kept
```

<!-- values: begin -->
```
tests: tests=40 tests_u04=28 tests_k=12 its=14 it_entries=5 lib=146/146 handlers=16 handlers_setup=12 handlers_u04=2 handlers_u05=2
bodiespg: codes=400/400/400/400
mergepg: codes=200/422/422/422/422/400/200/415/404
jsonpatchpg: codes=200/409/422/422/422/400/400/400/400/400/415 harness=409/409/409/409/500
retrypg: merge_twice=200,200 testreplace_twice=200,409 versions=v0->v1->v1 second_writes=0
renamepg: codes=200/404/200/200/409
trappg: revenue=24300->20700 priya=1_120_VEGAN->2_0_VEGAN codes=400/500/400/200/400
stalepg: old=200 ttl=PT10M
jsonp: provider=org.eclipse.parsson.JsonProviderImpl pin=1.1.9
bodies: codes=400/400/400/400
merge: codes=200/422/422/422/422/400/200/415/404
jsonpatch: codes=200/409/422/422/422/400/400/400/400/400/415 harness=409/409/409/409/500
retry: merge_twice=200,200 testreplace_twice=200,409 versions=v0->v1->v1 second_writes=0
rename: codes=200/404/200/200/409
reader: reader=200/400/500/422/200/422 shipped=200/422/422/200/200
trap: revenue=24300->20700 priya=1_120_VEGAN->2_0_VEGAN codes=400/500/400/200/400
stale: old=200 ttl=PT10M
matrix: codes=200,400,404,409,415,422 rows=66 authors=Boots_problem-details_handler:2,TiffinBoxs_advice:1,the_route:23
moved: moved=0 patch_customers=405:GET,POST
inert: seven=466c20ed surface=316a9637
exercise: exercise=broken-415-FAIL,solved-200-PASS,refused-4-FAIL
static: xfam_s9s1_md5=1f5217a0 parsson_pin=1.1.9 lines=5/35/7/13
build: seed_files=10068
```
<!-- values: end -->

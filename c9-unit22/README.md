# Course 9 · Unit 22 — `Input Hardening`

```
Send TiffinBox a customer with a version of ninety-nine. It answers 201 and keeps none of the extras — and never tells you.
```

That is the old route's answer, on `before` and `after`: `POST /customers` with `version`, `admin` and `createdAt` beside the record's
four members answers `201`, the read back shows the four members and none of the extras, and the JVM's log says nothing (`drop`). This
unit's change does not touch that route; it changes the public merge patch.

Mass assignment: a body that sets fields the API never offered.

Course 9's eighteenth anchor change, Section 4's fourth. ONE line of `tiffinbox-web/src/main` moves: `CustomerPatches.readBack` reads
the document the patch made with its own strict reader, `json.readerFor(Customer.class).with(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)`,
plus its import and one sentence of the class comment; `InputHardeningTest` pins it. No pom, no `application.yaml` key, no route, no
migration and no spec byte changed. `before` is a link to `../c9-unit21/after`; `after/` is the frozen copy of `../c9-tiffinbox` after
this unit's change.

What is measured behind it, in two halves. Over-posting: on the harness's entity-bound route (a harness route that reads a body onto
`CustomerEntity`; no shipped route does) Sunil's body with Ravi's `id` overwrote Ravi's row, on H2 and on PostgreSQL 18.6, and Ravi
answers `404`; a record-reading route on the same JVM left Ravi's row untouched. The cure is the record, which TiffinBox's own routes
already read. Unknown members: the merge patch now refuses a member `Customer` lacks with `422` and names it, where it answered `200`
and dropped it - a named change of a shipped public answer (S9.37); the old `POST /customers` keeps its answers.

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first line, each ending `every capture = published (19)`,
and `check_unit9.py 22 --runlog` read on each run log (its unit gate exits `2` until this unit's script exists, as expected; the
run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder (the exercise's three refused variants run here only).
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed copy of the repository in a folder whose path holds a space (R.129),
  cloned from the local repository at `afba429` with this unit's files laid over it, and its `c9-tiffinbox` folder moved aside for the
  whole run: the static check's third run reads no anchor beside it.

The pins in `receipts.md5` were taken from a development run (`NOPIN=1`) of this same script before run 1; the three runs then had to
print the same hashes. The static check's three runs: `chk22.py static after before` printed the same output (i) as written, (ii) on a
scratch copy with a byte appended to `compose.yaml` it exits `1` and names the file, (iii) in a folder copy with no anchor folder beside
it the output is the same, and run 3 ran with the clone's anchor folder moved aside; an audit hook refuses any open of a path inside the
live anchor's folder, and both plants exit `1`.

As run (2026-11-27; each log's `check_unit9.py --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, in this folder, load `4.38 3.91 3.47` at the start; every capture = published (`19`); run-log gate PASS.
- run 2: bash `5.3.9`, in this folder, load `5.71 5.26 4.26` at the start; every capture = published (`19`); run-log gate PASS.
- run 3: bash `3.2.57`, in the sealed copy (`…/sealed clone/tiffinbox-java/c9-unit22`, its `c9-tiffinbox` moved aside), load `8.41
  5.38 4.49` at the start; every capture = published (`19`); run-log gate PASS.

These lines were written after run 3; the prose gate and the values block were run again on this README as committed.

## RE-MEASURE (settled first, each by its capture)

- **1** `advisory` — the read filed for Section 4 (`_research/docs-2026-11-27/advisories-s4probe/`), its `fetched-at.txt` naming the
  run's own day; both of the day's `MD5SUMS.txt` verified line by line; Tomcat's page `a1a756d9…` as before; OSV `0` with vulns (the
  other witness only). The pins read off the jar: Boot `4.1.3`, Framework `7.0.11`, Tomcat `11.0.29`, Jackson `3.1.8`. `BOOT-INF/lib`
  `167` = `167` by name and the four poms byte-equal: this unit adds no artifact. Verdict: no pin affected.
- **2** `before` — on `before` (U21's `after`): `application.yaml` names no `fail-on-unknown` key (the `deserialization:` map holds
  `accept-float-as-int: false` only); `readBack` reads with `json.readValue(…, Customer.class)`; `FAIL_ON_UNKNOWN_PROPERTIES` in no
  `src/main` file; the running mapper reads it back `false` (`bind`'s start line, Jackson `3.1.8`); web `85`, client `5`, ITs `14`.
- **3** `change` — the derived changed list is three paths: `CustomerPatches.java` (two code lines added, one removed: the import and
  the read), `InputHardeningTest.java` (new) and the anchor's README; the four poms, both yamls, the spec, `Dockerfile` and
  `compose.yaml` byte-equal; `tiffinbox-core/` and `tiffinbox-client/` untouched.
- **4** `census` — the controllers `17` / `11` / `1` / `5` on both trees: no route added or removed.
- **5** `drop` — the hook's request on `before` and on `after/`, each its own JVM: `201`, the `Location` of the new customer, the read
  back with the four members and none of the extras, `0` WARN lines in the log (the same grep counts `1` on a copy with one planted
  WARN line, R.566). The two trees answer byte for byte the same: the change does not reach this route.
- **6** `bind` — the harness's entity-bound route on `before`, H2 then PostgreSQL 18.6, a fresh JVM each. The entity has nine getter-visible members (`javap -p`). Sunil's body `{"id":1,"name":"Mallory"}`, the URL's
  row (row 3) at `v0` and the sent `id`'s row (row 1, Ravi) at `v0`: `200`, row 1 becomes `Mallory|3|100|VEG|v1`, Ravi answers `404` - the
  failure receipt. Priya's `id` sent to Meera while Priya's row is at `v1`: `409` (the harness's route answers `409` for any exception; the
  root is Hibernate's `StaleObjectStateException`); the same body with Priya's version `1`: `200`, row 4 overwritten. A version equal to
  the row's: accepted and incremented; a differing one: `409`, Hibernate's version check, not Jackson. `name`, `mealsPerDay`, `pricePerMeal`
  and `mealType` written; `pauses`, `updatedAt` and the unknown `admin` not written; `createdAt` not written on a customer made by `POST`
  (the column rule), the seeded rows' `createdAt` null. The running mapper's `FAIL_ON_UNKNOWN_PROPERTIES`: `false`. H2 = PostgreSQL by
  status (`norm.py statuses`), and `psql` equals the companion read on every PostgreSQL case.
- **7** `record` — the record route and the entity route on ONE JVM (`after/`), H2 then PostgreSQL 18.6. R1, Mallory's two-member body to the record route: `400` "Failed to read request", no row moved. R2, the
  same attack made whole (Ravi's `id` and version, every record member) to Sunil: `200`, Sunil's meals written, row 1 still Ravi, Ravi
  `200`, Mallory `404`. R3, Priya's `id` to Meera: `200`, row 4 still Priya. C1, the control on the same JVM - the entity route, Priya <-
  Ravi's `id`, both rows at `v0`: `200`, row 1 becomes `Mallory|1|120|VEGAN`, Ravi `404`. H2 = PostgreSQL (`norm.py rows`); `psql` equals
  the companion read `5` of `5`.
- **8** `strict` — the change's reach. The inventory, derived on `after/`: `4` `@RequestBody` routes (`TiffinBoxServer.add`, `DishWrite.add`,
  the two `CustomerPatches` routes); `readBack` has one caller (`apply`, under both PATCH routes); the shared mapper's other users write
  only. Then the 25 reach requests on `before` and `after/`, H2 and PostgreSQL: exactly `3` lines moved on each database - `PATCH` merge
  `Priya {version:99}`, `Meera {admin:true}`, `Sunil {loyaltyPoints:5}`: `200` -> `422` `application/problem+json`, detail `the patched customer cannot be
  read at <member>` for `version`, `admin`, `loyaltyPoints`. The other `22` lines byte-equal, the old `POST /customers` answers
  (the hook's, `loyaltyPoints`, the misspelt `mealTyp`, `id`), the JSON Patch, the form POST, the keyed replay and `billing-runs`
  included. H2 = PostgreSQL on both trees.
- **9** `key` — the harness's copy with the key (`after/`'s jar with `spring.jackson.deserialization.fail-on-unknown-properties=true` as
  a run flag, never the anchor; `21162`), H2 then PostgreSQL. The running mapper reads `FAIL_ON_UNKNOWN_PROPERTIES` back `true`. `10` of the `25` lines move on H2 and on
  PostgreSQL: the merge patch's three (as `strict`), and the old `POST /customers` four - `loyaltyPoints`, the hook's request and `id`
  from `201`, the misspelt `mealTyp` from `400` "the customer breaks 1 rule" (which names `mealType`) - to `400` "Failed to read request",
  which names no member; their three read-backs `200` -> `404`. That is the cost the brief names: the key is shown here, never on the anchor.
- **10** `limits` — Jackson 3's read constraints as the library defines them (`StreamReadConstraints.defaults()`, jackson-core
  `3.1.8`): nesting depth `500`, number length `1000`, string length `100000000`, name length `50000`, document length and token count
  `-1` (no limit). Boot's metadata: `server.tomcat.max-http-form-post-size` `2MB`, `server.tomcat.max-swallow-size` `2MB`,
  `server.max-http-request-header-size` `8KB`, `spring.servlet.multipart.max-file-size` `1MB`, `max-request-size` `10MB`. No request
  tried any of them; the running mapper's own constraints: not captured, not said.
- **11** `named` — not captured as its own capture: the `detail` table is `strict`'s and `key`'s lines (below). No member-naming
  handler was added (C7 (a)); the old `POST /customers` names the missing `mealType` for a misspelt `mealTyp` because Bean Validation
  does, not because anything names the unknown member.
- **12** `dev` — not captured, not said (dropped under (b′): the change has one caller, `CustomerPatches`, and no "dev" store reads
  through it).
- **13** `spec` — the committed file equals the served document; `36164` B on both trees; the operations' ids equal; the merge patch's
  `422` was documented before this unit (the document a patch makes, when it is not a valid customer); `OpenApiSpecTest` passes.
- **14** `api`, `moved`, the seven and the surface — not witnesses for the refusal (R.511): the `/api/v1/` census (`API` GETs) identical
  on both trees; the seven and the old surface equal to their expected values on both trees (the values block); two web jar entries moved, both compiled
  from `CustomerPatches.java`, the core jar `0`, `BOOT-INF/lib` `167` = `167`.
- **15** `tests` — the need-measure first: `before` plus ONLY the new test, `mvn -o test` of that class: `3` run, `1` failure
  (`aMergePatchNamingAMemberTheRecordLacksIs422`), the `mealTyp` pin green - the test sees the change and the old suite does not. Then
  `after/`'s own build: web `88` (`85` + `3`), client `5`, `0` skipped, `InputHardeningTest` `3` green; no disabling annotation, no port,
  no 4-digit literal, no header-name literal; `0` limiter refusals outside `RateLimitFilterTest`. `mvn verify`: web `88`, the five ITs
  `14` green, every binding `127.0.0.1`, no container left, nothing pulled, `0` downloads.
- **16** `exercise` — `break.sh` adds `CustomerOverwrite.java` (the body onto the entity); `check.sh` on the broken copy, bash and
  `zsh -f`: Ravi `404` and `Mallory` written, Priya `404` and `Eve` written, `FAIL (1)` and `FAIL (2)`, exit `1`; on the solved copy (the
  body read into `Customer`, the record's members copied onto the URL's row): Ravi and Priya read back unchanged, Sunil written, `PASS`.
  The refused variants (run 1): `none`, `strict` (the strict read still onto the entity) and `nowrite` each exit `1`.

## The change, file by file

- `tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerPatches.java`: `readBack` (the document the patch made, read back into the
  record before it is validated and written) now reads with `json.readerFor(Customer.class).with(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)`;
  the import `tools.jackson.databind.DeserializationFeature`; a comment line on the read and one sentence in the class comment. The
  reader is this route's own: Boot's shared `JsonMapper` is unchanged, so every other body route still ignores an unknown member.
- `tiffinbox-web/src/test/java/com/tiffinbox/web/InputHardeningTest.java` (new): three tests through MockMvc over the whole application
  on H2, no socket; its statuses are named constants and it spells no header name.
- `c9-tiffinbox/README.md`: the unit 22 card and the header note. Unit 21's card's "85" for the web module is unit 21's count (the
  note says so); the "unknown properties ignored" sentences of Course 6's units (*Jackson in Spring*) stay true of the old
  `POST /customers` and are left as written.

## Which tree, which profile

Every TiffinBox JVM runs the default profile. `drop`, `strict` (H2 half), `api`, `seven`, `surface` and `spec` run on H2 in memory,
harness-free; `bind`, `record` and `key` are harness-joined (labelled); `bind`, `record`, `strict` and `key` each run another JVM on
PostgreSQL 18.6 (`c9u22-pg`, `postgres:18-alpine` by digest, `--pull never`, `127.0.0.1:21161`, a fresh database per JVM). No dev
profile. `mvn verify`'s five ITs bring their own Testcontainers stores.

## Unit 22's section

The spine [S4B `## Unit 22`, as BLUE C9-U22 amended it] is measured as written. Over-posting on the harness's entity-bound route: Jackson
3 binds every member the entity has, through its getters onto its private fields (the entity has no setters for `id`, `name` or
`version`); another customer's `id` at the same version overwrites that customer's row; the version check stops a version that differs;
a column rule keeps `createdAt`. The failure receipt is Sunil's body `{"id":1,"name":"Mallory"}` on that route: Ravi's row becomes
`Mallory`, and Ravi answers `404` (`bind`, H2 and PostgreSQL). The cure is the record (`record`). Unknown members: the record routes drop
them; the merge patch now refuses one and names it (`strict`); the global key would refuse on the old `POST /customers` too, and its cost
is measured on the harness's copy with the key (`key`). The hazards, each with its capture: `FAIL_ON_UNKNOWN_PROPERTIES` is `false` on
the running mapper (`bind`); the private fields are written through the getters (`bind`); the key's `400` names no member and moves the
misspelt `mealTyp` answer (`key`); `createdAt` is silently not written (`bind`, C3); the `customer` cache answers after an overwrite with what it
held (`bind`'s `2b` read); the record route refuses Mallory's two-member body whole, `400` "Failed to read request" (`record` R1 - the cause
not isolated, said as the answer only); the suite before this unit does not see the change (`tests`, the need-measure).

## The captures — what each one shows

### `advisory`, `before`, `change`, `census`

The day's read, verified; `before`'s yaml and read line; the one-line change printed as a diff and the new test whole; the controllers
counted on each tree by unit 15's rule.

### `drop` (the hook's request; H2; harness-free)

```
POST /customers {"admin": true, "createdAt": "2001-…", "mealType": "VEG", "mealsPerDay": 1, "name": "Mohan", "pricePerMeal": 110, "version": 99}
  -> 201 application/json · Location …/customers/Mohan · body {"name":"Mohan","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}
GET /customers/Mohan -> 200 · {"name":"Mohan","mealsPerDay":1,"pricePerMeal":110,"mealType":"VEG"}
GET /api/v1/customers/Mohan -> 200 · ETag "v0" · the same four members
WARN lines naming the read: 0 (a copy with one planted WARN line: 1) · before -> after/: identical
```

### `bind` (the harness's entity-bound route; H2 and PostgreSQL 18.6)

The member table (`bind`; the same on H2 and PostgreSQL 18.6):

| member sent | outcome on the harness's entity-bound route | the row's version | another row? |
|---|---|---|---|
| `id` (Ravi's) + `name` to Sunil | written onto row 1: Ravi becomes `Mallory`, Ravi `404` | both `v0` | yes, row 1 |
| `id` (Priya's) to Meera, Priya at `v1` | refused, `409` (the harness's catch-all; Hibernate's version check) | URL row `v0`, sent row `v1` | no |
| `id` + `version` `1` (Priya's) to Meera | written onto row 4: Priya becomes `Eve` | sent row `v1` | yes, row 4 |
| `version` equal to the row's | accepted, then incremented by the save | `v0` | no |
| `version` differing | refused, `409` (Hibernate's version check) | `v1` | no |
| `name`, `mealsPerDay`, `pricePerMeal`, `mealType` | written | rising | no |
| `pauses`, `updatedAt` | not written | rising | no |
| `admin` (not on the entity) | not written | unchanged | no |
| `createdAt` (a `POST`-made customer) | not written (the column rule) | `v0` | no |

After the `2b` overwrite `GET /api/v1/customers/Priya` answered `404` in this order of cases (nothing had cached Priya first).

### `record` (the cure beside its control; one JVM; H2 and PostgreSQL 18.6)

```
R1 record route  Sunil <- {"id": 1, "name": "Mallory"}                              -> 400 "Failed to read request" · rows unchanged
R2 record route  Sunil <- Ravi's id + version + every record member, name Mallory -> 200 · row 1 Ravi · Ravi 200 · Mallory 404
R3 record route  Meera <- Priya's id 4 at version 0, name Eve                       -> 200 · row 4 Priya
C1 entity route  Priya <- {"id": 1, "name": "Mallory"} (the control, same JVM)      -> 200 · row 1 Mallory|1|120|VEGAN · Ravi 404
```

### `strict` (the change's reach; H2 and PostgreSQL 18.6; harness-free)

The refusal table (`before` -> `after/`, H2 = PostgreSQL; OLD = the routes of Course 6's units,
PUBLIC = under `/api/v1/`):

| request | `before` | `after/` | route |
|---|---|---|---|
| `PATCH` merge Priya `{version:99}` | `200` | `422` "… cannot be read at version" | PUBLIC |
| `PATCH` merge Meera `{admin:true}` | `200` | `422` "… cannot be read at admin" | PUBLIC |
| `PATCH` merge Sunil `{loyaltyPoints:5}` | `200` | `422` "… cannot be read at loyaltyPoints" | PUBLIC |
| `POST /customers` the hook's, `loyaltyPoints`, `id` | `201` | `201` | OLD |
| `POST /customers` misspelt `mealTyp` | `400` "the customer breaks 1 rule" | the same | OLD |
| `PATCH` JSON Patch `add /version` | `400` (the route's own path check) | the same | PUBLIC |
| the keyed pauses replay | `201`, `201`, the same body and `Location` | the same | PUBLIC |

The whole reach file's md5 is printed beside its normaliser (`norm.py reach`) in the capture; the side-by-side file is `paste` + `awk`.

### `key` (the harness's copy with the key; H2 and PostgreSQL 18.6)

```
POST /customers +loyaltyPoints:5           201                                   -> 400 "Failed to read request"
POST /customers the hook's request         201                                   -> 400 "Failed to read request"
POST /customers misspelt mealTyp           400 "the customer breaks 1 rule"      -> 400 "Failed to read request"
POST /customers +id:1                      201                                   -> 400 "Failed to read request"
GET /customers/{Lata,Mohan,Om}             200                                   -> 404
PATCH merge {version} {admin} {loyaltyPoints}  200                               -> 422 naming the member
```

### `limits`, `spec`, `moved`, `api`, `seven`, `surface` (not witnesses for the refusal)

`limits` prints the library's constraint getters and Boot's metadata lines named above. `spec`: the committed
file = the served document, `36164` B, unchanged. `moved`: the web jar `384` -> `384` entries, `2` moved, both compiled from
`CustomerPatches.java` (the class and its nested `Refused`, whose line numbers moved); the core jar `0`; `BOOT-INF/lib` `167` = `167`.
`api`, the seven and the old surface: identical on both trees - not witnesses for the refusal (R.511).

### `tests`, `harness`, `exercise`, `title`

`tests` as item 15. `harness`: the folder's files exactly; the copied instruments byte-equal; the adapted ones
with their named diffs; the static check's (ii) and (iii) and its two plants; R.564's GNU-`sed` plant counted `1`; the three frozen
receipts that read the live anchor's poms, printed (`c9-unit10` :611, `c9-unit13` :334, `c9-unit15` :396 - findings, not edits).
`exercise` as item 16. `title`: "Mass Assignment in Spring Boot: Jackson 3 Over-Posting", `54` characters by `len()`, no blocked
claim. Over-posting is the same attack as mass assignment under its other name; it is named here once.

## Measured, not shipped

The harness's entity-bound route (`harness/src/probe22/Bind.java`, the held ev22 run's, byte for byte), the record route
(`harness/src/probe22b/Rec.java`, BLUE C9-U22's, byte for byte), the harness's copy with the key (a run flag on `after/`'s jar), the
limits reader (`harness/src/probe22/Limits.java`), the need-measure's copy (`before` plus the new test), the exercise's copies and
`CustomerOverwrite.java` (`break.sh` writes it into a copy). None is in a jar or a module.

## Refused, named

Each refused by `harness/s922.py` (XU22C9) and planted in its self-test: `the key blocks over-posting` and `over-posting is blocked`
(unknown members refused is not over-posting stopped: the entity route still overwrites under the key, the held run's `bindblock`);
`the switch stops the overwrite`; `fail-on-unknown protects the entity`; the harness's catch-all `409` said as TiffinBox's answer;
`compatible under S9.37` and `nothing a client of the API sees moved` (the merge patch's answer moved, named); `TiffinBox rejects unknown
fields` (the old `POST /customers` does not); `the version cannot be over-posted` and `an over-posted id is refused` (on the entity
route both are written); `the census proves the refusal` (it is not a witness); `ignoreUnknown=false makes it strict` (BLUE measured
it inert, with its control). A count typed instead of printed.

## The repository, and the network

The advisory read of the batch day stands: Spring's, Tomcat's and OSV's pages filed under `_research/docs-2026-11-27/` cleared Boot
`4.1.3`, Framework `7.0.11`, Tomcat `11.0.29` and Jackson `3.1.8`, and this unit adds no coordinate. Nothing else was read from the
network; the only network act is the final `git push`.

## The folders, the harness and the ports

`README.md`, `receipts.sh`, `receipts.md5`, `before` (the link), `after/`, `harness/` (`bind.py`, `chk22.py`, `dur9.py`, `norm.py`,
`ops9s3.py`, `reach.py`, `rec.py`, `s922.py`, `tree22.py`, `src/probe22/Bind.java`, `src/probe22/Limits.java`, `src/probe22b/Rec.java`),
`exercise/` (`README.md`, `SOLUTION.md`, `apply.sh`, `break.sh`, `check.sh`). Ports, U22's band `21160`-`21169` (the course's one
exception to §P): `21160` `after/`, `21161` PostgreSQL, `21162` the harness's copy with the key, `21166` `before`, `21168` the record JVM
and the exercise; `21163`-`21165`, `21167`, `21169` and `21110`-`21119` never bound; `21280`-`21284` during `mvn verify` only.

## Masks, filters and hygiene

One self-tested mask: the start lines' times, the `ms` counts, timestamps, the folders, the band's ports, the PostgreSQL password in a
URL, HTTP dates, UUIDs. The normaliser (`harness/norm.py`, R.565) is printed beside every hash it makes: `statuses` keeps each case's
label and status, `rows` drops the `psql` lines and the JVM's log lines, `reach` keeps the request lines. No step that writes a capture
hides its failure (R.564): every listed capture file is asserted non-empty, the side-by-side file is made with `paste` and `awk`, and the
receipts refuse a GNU-only `sed` form (a planted line is counted `1`). Every process is stopped by its recorded pid; `c9u22-pg` removed
with `rm -fv`; images and volumes equal at the end.

## Interrupted

Not done in this unit's runs of record (the cap's drop order allows it): no SIGINT driver was run. The receipt's EXIT trap stops every
JVM it recorded, removes `c9u22-pg` and `.r-*.new` on an interrupt; that path was exercised in development (runs stopped by a gate left
no JVM, no container and no listener).

## Planted faults — each caught

`chk22.py plants` on every run of record: `40` plants caught, each a FAIL line with exit `1` and no traceback. They cover the
failure receipt typed as not written, H2 and PostgreSQL typed different, the harness's `409` left unlabelled (read as TiffinBox's,
R.567), the sent `id`'s version dropped (R.567), `before`'s mapper typed strict, the record route typed as overwriting and its control
as not, the strict read typed as moving `10` (the key's count), an empty side-by-side file (R.564), a `422` naming the wrong member, the
key typed as moving only the merge patch, the key's mapper typed off, the hook's request typed refused on `before`, the WARN grep's
positive control missing (R.566), the old POST typed as moved, another code line in `src/main`, the global key on the anchor, a pom
touched, the key typed present on `before`, the need-measure typed green, a skipped test, a refusal at the default capacity, a
header-name literal in the test, the seven's and the surface's md5 altered, the jar list typed `164`, one web jar entry typed moved, a
moved core entry, the census moved, the spec touched, the solution equal to the broken copy, the broken copy typed passing, a read
dated after the run, a request count over the cap, a refusal line, the limits read off another jar, a title over the limit, and three
unparseable listings. The static gate's own plants, R.564's GNU-`sed` plant and the prose gate's self-test (XU22C9's plants and near
misses) run at every start or in `harness`.

## What differed from the brief

- The bound design is BLUE C9-U22's (b′), per `prompts-s4/ev22-AMENDMENT-blue.md`, which rules over `ev22-prompt.md`: the strict
  reader in `CustomerPatches.readBack`, not the `application.yaml` key; "no Java in `src/main`" re-bound to that one line and its import.
- C1: (a) as re-aimed - `InputHardeningTest` pins (b′)'s `422` (red without it, the need-measure) and the `mealTyp` answer of Course
  6's units (green on both trees); `k` = `3` (a third test, a clean merge patch still `200`, keeps the route's write pinned). MockMvc, no socket.
- C2: the held run's `Bind.java` byte for byte (its named diff from `ProbeS4.java` is the held run's `bind-named-diff.txt`); `bind.py`
  adapted from the held run's by a named diff (R.567's two prints). C3: (a), a `POST`-created customer; the seeded rows' null named.
- C4: `bindblock` not re-run; the held run's six runs of it are cited; `record` is the new capture.
- C5: bound to (b′); the inventory derived and printed; `POST /dishes`, the key filter's writes and the Redis cache named out of reach
  by construction (one caller of `readBack`), not measured. C6 (`dev`): dropped, as the amendment says.
- C7: (a) not added; (c) struck. C8: the reworded line (`23` words); `check.sh` sends Ravi's `id` to Sunil and Priya's to Meera, each
  row read back; a third clause keeps the route writing (a solution that writes nothing fails); refused variants `none`, `strict`,
  `nowrite` in run 1 only (`  ~` lines, out of the hash). The exercise's tree is a copy of `after/` with the route added by `break.sh`.
- C9: (i) and (iii); (ii), the running mapper's own constraints, dropped first (not captured, not said). C10: the 2026-11-27 read stands.
- The harness's copy with the key is `after/`'s jar with the key as a run flag (the amendment's port `21162`), not a rebuilt tree: the
  running mapper reads it back `true`; BLUE's `after` (a tree with the yaml key) moved the same `10` lines (`568a6272…`'s lines).
- The record JVM (`record`) runs on `21168`, the exercise's port, before the exercise; never at the same time.
- The hook is gated as written: `s922.py` refuses its `201` in digits (U19's family) - handed to RED, never edited; it stands in a fenced
  block, and the line after it says it is the old route's answer on both trees (D9).
- `moved`: two web jar entries, not one - `CustomerPatches.class` and its nested `Refused`, whose line numbers moved with the class
  comment's new sentence.
- D19: H2 has no `psql`; the companion read is the H2 table read, and on PostgreSQL `psql` equals it every time.
- `named` is not its own capture: its `detail` table is `strict`'s and `key`'s lines.
- The third static run: the sealed clone ran with its `c9-tiffinbox` folder moved aside (run 3), beside the folder copy of (iii).
- Not captured, not said: SIGINT points (dropped by the cap's order, as unit 21); `dev`; `limits` (ii); `bindblock` (held, cited).

## For RED

- (b′) as bound: the merge patch's `200` -> `422` for a member `Customer` lacks, named under S9.37, never "compatible".
- D1: the key does not stop the overwrite (held `bindblock`); the roadmap's "then blocked" is paid as the record (the cure) plus the
  merge patch's refusal of unknown members; the card and this README say so.
- D2/D3: the old `POST /customers` answers are unmoved by (b′) (`drop`, `strict`); the global key would move `10` (`key`); Course 6's
  units' "unknown properties ignored" sentences stay true and are left as written.
- D5: the `422` names the member; the old POST's `400` for `mealTyp` names the missing `mealType` (Bean Validation), not the unknown one.
- D9: the hook's `201` is `before`'s AND `after`'s answer; the hook passes no gate as written (its `201` in digits).
- D10: the limits are the library's defaults and Boot's metadata, not the running mapper's.
- D12/D13: one test (`3` methods); the exercise's route exists only in the learner's copy.
- The record route refuses Mallory's two-member body whole (`400`, cause not isolated): the script says the answer only.
- The dropped SIGINT points; the spoken forms of `400`, `422`, `201` for the scripts stage.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:396` ("mass assignment and over-posting reproduced on TiffinBox, then blocked"), paid as the brief binds it:
reproduced on the harness's entity-bound route; blocked by the record for the members an entity has (`record`); refused on the public
merge patch for the members it lacks (`strict`). The upload limits Course 6's units carried (S6): named from Boot's metadata (`limits`),
handed to *Spring Security — complete*. **C9-11**: the seven, the surface, the spec's operations, the tests and the `/api/v1/` census on both
trees. The decision of Course 6's units (*Jackson in Spring*: unknown properties ignored on the old route) kept. No ledger edit.

## The values the video may say

Each with its capture (3/3 across the runs, H2 and PostgreSQL 18.6 where named): the merge patch's three extra-member requests `200`
-> `422` naming the member, the other `22` reach lines byte-equal (`strict`); the hook's request `201` with none of the extras on both
trees (`drop`); Sunil's body with Ravi's `id` overwrote Ravi's row, Ravi `404` (`bind`, the harness's entity-bound route); a differing
version `409` from Hibernate's version check on that route, the harness's catch-all (`bind`); the record route left Ravi's row
untouched beside the control's overwrite (`record`); the global key moves `10` of `25`, the misspelt `mealTyp`'s answer stops naming
`mealType` (`key`, the harness's copy); nesting depth `500` (`limits`, the library's default); web `85` -> `88`, client `5`, ITs `14`
(`tests`). Spoken forms for the scripts stage: "four hundred", "four twenty-two", "two oh one"; "mass assignment" glossed once.

<!-- values: begin -->
```
advisory: fetched=2026-11-27 lib=167->167 jackson=3.1.8
before: key=absent read=readValue lib=167 web=85
change: changed=3 src_main=1 code=+2-1 key=none
census: census=17/11/1/5
drop: hook=201 kept=4_members said=0 before=after
bind: receipt=Ravi_overwritten_404 version_differing=409_hibernate createdAt=not_written statuses=2310dca4 h2=pg
record: R1=400 R2=200_ravi_kept R3=200_priya_kept control=overwrite rows=de5f57c1
strict: moved=3/25 merge_extra=200->422 before=dbc7239b after=82c82d7d
key: moved=10 mealTyp=named->Failed_to_read_request loyaltyPoints=201->400 mapper=true
limits: nesting=500 string=100000000 number=1000
spec: spec=36164 ops=OPERATIONS 21 PATHS 19
moved: moved=2(CustomerPatches.java) web=384 core=41 lib=167->167
api: api=11 identical
seven: seven=466c20ed
surface: surface=316a9637
tests: need=red(1/3) web=85->88 client=5 its=14
harness: static=c1b5ed354d3f5fcac004b23f809d537f
exercise: broken=FAIL(ravi_overwritten) solved=PASS
title: title_len=54
plants: plants=40
build: seed_files=11323 seed_bytes=889446136 central_only=0
```
<!-- values: end -->

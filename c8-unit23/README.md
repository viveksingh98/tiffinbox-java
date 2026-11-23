# c8-unit23 — *Which Database, Honestly*

Course 8, Section 4's sixth unit, and **no change to the anchor** (flag 10): `before` and `after` are both links to
`../c8-unit22/after`, one tree, and `../c8-tiffinbox` equals it before and after this unit. The unit is a table, `table.md`: its rows
are the five stores this course ran — PostgreSQL, Caffeine, Redis, MongoDB, Elasticsearch — and its columns are five ways a store
failed: a silent wrong answer, the store absent at start, a write outside the transaction, a default that does nothing, a cost that
grows. Every body cell names a capture an earlier unit shipped and the number that capture printed, in its own words, or says
`unmeasured`. `harness/u23check.py` reads every cell, and five cells — one per store — are run again here on unit 22's tree.

**A failure mode as a cell** is what broke, the capture that showed it, and the number it printed: twenty-five cells, seven of them
unmeasured, PostgreSQL's row included.

Every cell's number is read off the shipped capture by its section's name when the receipt runs (S8.97): the checker opens
`../c8-unitNN/README.md`, finds the section `### N · <capture>`, finds the line `<capture> <md5>` in that unit's `receipts.md5`, and
finds each number of the cell beside its own word on a line of that section's capture block — none is typed from the plan. Which
store answered, in every line (R.392): **the checker and the shipped READMEs** (`rule`, `honest`, `feature`, `exercise`: Python alone,
no Docker, no JVM); **22/after's jar** on the unit's stores (`replay`: PostgreSQL `20621`, Redis `20622`, MongoDB `20623`,
Elasticsearch `20624`, and the harness's PostgreSQL `20626`), with three earlier units' harnesses copied from their folders and
compiled against that jar; **22/after, default run, H2, no Docker** (the seven, `20620`).

Six captures. `rule`, `honest`, `feature`, `replay` and the seven run three times inside each run of `receipts.sh` and are hashed
(`receipts.md5`); `exercise` runs once per run, and its 3/3 is across the runs of record. Every number below is asserted after its
capture by `harness/chk23.py`, re-derived from the capture's own lines or from `table.md` — never from this README's prose.

## Runs of record

Three runs of `receipts.sh` on 2026-11-23, each ending `c8-unit23: every capture = published …`, each log through
`check_unit8.py 23 --runlog` (`RESULT (run logs): PASS`; the unit gate itself exits `2` until the script stage writes unit `23`'s
script — expected). Every capture's md5 equals `receipts.md5`'s in all three; the one build offline (`offline: yes`, `Downloaded
from` `0`). The machine's three load averages at each run's start and end (the launch rule: the first below `20`, no `ffmpeg` above
`100` % CPU — another session's `ffmpeg` was alive and idle throughout, and no run waited):

| run | how | result | load at start | load at end |
|---|---|---|---|---|
| run1-bash32 | `./receipts.sh` — macOS's bash 3.2.57 | PASS | `4.86 9.04 9.69` | `4.88 7.50 8.95` |
| run2-bash53 | `bash receipts.sh` — Homebrew's bash 5.3.9 | PASS | `4.88 7.50 8.95` | `4.44 6.24 8.20` |
| run3-sealed | a sealed fresh clone in a path with a space (`sealed 23/`), `./receipts.sh`, `DOCKER_CONFIG=$HOME/.docker` | PASS | `3.98 6.02 8.07` | `4.90 5.52 7.48` |

A first set of three runs, before these, also passed (loads at their starts `6.02 8.83 10.49`, `6.48 7.74 9.74`, `9.36 10.01 10.34`);
the planted faults then found the start pins' exit swallowed by a pipe (below, "Planted faults"), the receipt was fixed, and the
three above ran on the fixed receipt. Their captures' md5s are the first set's.

## The table, cell by cell — where each number was read

`table.md` holds the table as it ships; here each cell with its source. "Line" is the section's header line in that unit's README;
"class" is the section of the course the unit belongs to (Sections 1-3 are units `01`-`17`, Section 4 Part A `18`-`20`, Part B
`21`-`22`). The checker prints the same, with each number beside the capture line that printed it (`rule`, below):

| store | column | capture | README line | the number, as the capture printed it | class |
|---|---|---|---|---|---|
| PostgreSQL | a silent wrong answer | — | — | `unmeasured` | unmeasured |
| PostgreSQL | the store absent at start | — | — | `unmeasured` | unmeasured |
| PostgreSQL | a write outside the transaction | — | — | `unmeasured` (unit 24 measures it, after this unit: never cited here, S8.97) | unmeasured |
| PostgreSQL | a default that does nothing | — | — | `unmeasured` | unmeasured |
| PostgreSQL | a cost that grows | `unit01/statements` · `unit18/oneread` · `unit18/rename` | `:80` · `:420` · `:460` | `the witness 43` beside `the witness 4`, `40` of them one SELECT per customer · `statements 1`, `JOIN in it 3`, `rows 4` · `UPDATE 30` beside `nModified 30` | 1-3 + 4A |
| Caffeine | a silent wrong answer | `unit12/stale` | `:117` | `the cached read says 2, the row now 3` | 1-3 |
| Caffeine | the store absent at start | — | — | `unmeasured` | unmeasured |
| Caffeine | a write outside the transaction | — | — | `unmeasured` | unmeasured |
| Caffeine | a default that does nothing | `unit10/nonames` | `:135` | `hitCount=4`, `missCount=1`, `cache_ lines 0` (`spring.cache.cache-names` removed) | 1-3 |
| Caffeine | a cost that grows | `unit12/stampede` | `:204` | `2 threads`, `2 in every round` | 1-3 |
| Redis | a silent wrong answer | `unit16/dropped` | `:244` | `PUBLISH -> 0`, `heard 0` | 1-3 |
| Redis | the store absent at start | `unit14/absent` | `:299` | `the JVM's exit: 1`, `health: 000` | 1-3 |
| Redis | a write outside the transaction | `unit17/otherholder` | `:189` | `deleted true`, then `EXISTS -> 0` | 1-3 |
| Redis | a default that does nothing | `unit15/stale` | `:373` | `count() 3`, `findAll()` `3 elements, 2 null` (the repository's, keyspace events off) | 1-3 |
| Redis | a cost that grows | — | — | `unmeasured` | unmeasured |
| MongoDB | a silent wrong answer | `unit19/silent` | `:333` | `groups 4`, every total `0`, `their sum 0` | 4A |
| MongoDB | the store absent at start | `unit18/absent` | `:494` | `the JVM's exit: 1`, `000`, `MongoTimeoutException 1` | 4A |
| MongoDB | a write outside the transaction | `unit20/notone` | `:290` | `count 1`, `ids [a]` under `JpaTransactionManager` | 4A |
| MongoDB | a default that does nothing | `unit20/noindex` | `:177` | `["_id_"]`, `COLLSCAN`, `totalDocsExamined 120` | 4A |
| MongoDB | a cost that grows | `unit20/shapes` | `:342` | `120` orders, `tiffinbox.customers query 120` | 4A |
| Elasticsearch | a silent wrong answer | `unit21/nohit` | `:461` | `match name veg -> 0 []` | 4B |
| Elasticsearch | the store absent at start | `unit22/absent` | `:316` | `the JVM's exit 1`, `Connection refused` | 4B |
| Elasticsearch | a write outside the transaction | `unit22/drift` | `:279` | `intx`: rows `0` / index `1` | 4B |
| Elasticsearch | a default that does nothing | `unit22/stale` | `:254` | `the count that follows it -> 0` | 4B |
| Elasticsearch | a cost that grows | `unit21/sayso` | `:487` | `-> 9` tokens for `"Vegetarian"` by `edge_ngram` | 4B |

## RE-MEASURE 8 — the five replays and their numbers (settled first)

Each replay runs on 22/after's tree, prints the cell it replays, and prints the number that cell holds; `chk23.py replay` asserts the
two equal. All five held, so no cell changed:

```text
the three tables, labelled: $ psql -c "UPDATE f3.item_allergen SET allergen = 'soya' WHERE allergen = 'soy'" -> UPDATE 30
MongoDB's half of unit18/rename, as read (not replayed here - the capture's own line, ../c8-unit18/README.md): op update · ns tiffinbox.menu · nMatched 30 · nModified 30
PROBE stale: the read, the write around the cache, the read again (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · the cached read says 2, the row now 3 (JdbcTemplate)
the JVM's exit: 1 · then curl /actuator/health on 20620: 000 · listening on 20620: 0
PROBE summeal: groups 4 · sorted by total, then _id: Meera 0 · Priya 0 · Ravi 0 · Sunil 0 · their sum 0
curl on 20624: dishes_std match name veg -> 0 []
```

## RE-MEASURE 9 and 10 — the cost cell's reading, and the checker on the shipped table (settled first)

PostgreSQL's cost cell is read off three shipped captures by name (`honest`), and `chk23.py honest` asserts the cell carries exactly
those numbers. `unit01/statements` is Spring Data JDBC's page against Spring Data JPA's page on the same PostgreSQL: the witness
(datasource-proxy on the `DataSource`) counts `43` for Spring Data JDBC's page and `4` for JPA's; C8-9's pinned counter,
`getPrepareStatementCount()`, is Hibernate's and reads `4` on the JPA side only (`0` on the JDBC side, which Hibernate never sees).
`unit01/alone` printed an exit and a missing jar, never a count, and the checker refuses it in the cost column by name:

```text
c8-unit01/README.md :80 (statements, statements afaeb0d57e9b9c65079574734aa45e29): Spring Data JDBC's page, the witness 43 · of them SELECTs from pause by customer_id 40 · its Hibernate getPrepareStatementCount() 0
c8-unit01/README.md :80 (statements): Spring Data JPA's page, the witness 4 · Hibernate getPrepareStatementCount() 4 - C8-9's pinned counter applies here, to the JPA side's 4; the JDBC witness 43 is datasource-proxy's, not Hibernate's counter
c8-unit18/README.md :420 (oneread, oneread c16a070529342c75d8f52ce9a2437e7d): PostgreSQL's four tables, one menu: statements 1 · JOIN in it 3 · rows 4
c8-unit18/README.md :460 (rename, rename 5d0b9c8a33f93596653c00e5c1173d09): the three tables, labelled: UPDATE 30 · the four tables: UPDATE 1 · MongoDB's half: one update op, nMatched 30 · nModified 30
```

The checker on the shipped table exits `0`; with one feature word in one cell it exits `1`, `bad 1`, and names the cell (`feature`):

```text
cells 25 · measured 18 · unmeasured 7 · bad 0
measured by the unit's section (the first capture of a cell): Sections 1-3 8 · Section 4 Part A 5 · Section 4 Part B 5 · a cell with captures of two sections: PostgreSQL · a cost that grows (1-3 + 4A)
the copy with the feature word: the checker's exit 1 · cells 25 · measured 17 · unmeasured 7 · bad 1
the shipped table, the same run: the checker's exit 0 · cells 25 · measured 18 · unmeasured 7 · bad 0
```

## The captures — what each one shows

### 1 · rule — the checker on the shipped table (S8.86, S8.97)

`u23check.py --derive table.md`: its self-test first (each rule failing on a two-row sketch, the controls passing), then every
cell, every capture reference with its README line and its `receipts.md5` line, and each number beside the start of the capture line
that printed it. A cell is refused for a feature word, a ranking word, a reference that does not resolve, a capture of unit `24` or beyond, a
reference with no number, a number its capture did not print beside the cell's own word, `unit01/alone` in the cost column, and
`unmeasured` where the checker's own list holds a capture for that store and column:

```text
self-test: 12 cases, each rule failing on a two-row sketch, the controls passing
cell PostgreSQL · a cost that grows: 3 capture(s)
unit01/statements · class 1-3 · c8-unit01/README.md :80 · receipts.md5 "statements afaeb0d57e9b9c65079574734aa45e29" · numbers 43 40 4
unit18/oneread · class 4A · c8-unit18/README.md :420 · receipts.md5 "oneread c16a070529342c75d8f52ce9a2437e7d" · numbers 1 3 4
unit18/rename · class 4A · c8-unit18/README.md :460 · receipts.md5 "rename 5d0b9c8a33f93596653c00e5c1173d09" · numbers 30 30
cell Elasticsearch · a silent wrong answer: 1 capture(s)
unit21/nohit · class 4B · c8-unit21/README.md :461 · receipts.md5 "nohit b102965497449670d8beff91f4f3311a" · numbers 0
unmeasured (7): PostgreSQL · a silent wrong answer; PostgreSQL · the store absent at start; PostgreSQL · a write outside the transaction; PostgreSQL · a default that does nothing; Caffeine · the store absent at start; Caffeine · a write outside the transaction; Redis · a cost that grows
cells 25 · measured 18 · unmeasured 7 · bad 0
the checker's exit: 0
```

### 2 · honest — PostgreSQL loses too: its cost cell, read (RE-MEASURE 9)

The four readings are the block in RE-MEASURE 9 above; `chk23.py honest` asserts the cost cell's `unit01/statements` numbers are
`43`, `40`, `4`, its `unit18/oneread` numbers `1`, `3`, `4`, and its `unit18/rename` numbers the three tables' `30` and MongoDB's
`30`. Spring Data JDBC's page is the one that counts `43`, beside JPA's `4` on the same database — the cost belongs to the page's
access path, and the cell says whose page it was.

### 3 · feature — a feature word in a cell (the failure receipt, R.312's negation; control: the shipped table)

```text
BAD Elasticsearch · a silent wrong answer: a feature word: powerful
the copy with the feature word: the checker's exit 1 · cells 25 · measured 17 · unmeasured 7 · bad 1
the shipped table, the same run: the checker's exit 0 · cells 25 · measured 18 · unmeasured 7 · bad 0
the copy removed: yes
```

The copy keeps the cell's capture and its number and adds the two words, so the one rule that refuses it is the feature list — the
cannot-fail detector (below) empties that list and the self-test fails.

### 4 · replay — five cells, one per store, on 22/after (RE-MEASURE 8)

**1, PostgreSQL**, `unit18/rename`'s three tables on the harness's PostgreSQL (`c8u23-pg-h`, `20626`), a fresh database: unit `18`'s
`harness/pg3.sql`, read by path, then the INSERTs unit `18`'s harness prints from 22/after's `MenuDay.forDays(30)`. MongoDB's half is
the capture's own line, read, not run again:

```text
../c8-unit18/harness/pg3.sql (read by path, md5 4d8e1a1c11427e3ccc35fd47f37a78bf), then those INSERTs, into u23ren · rows: f3.menu 30 · f3.menu_item 90 · f3.item_allergen 120 · of them soy 30
the three tables, labelled: $ psql -c "UPDATE f3.item_allergen SET allergen = 'soya' WHERE allergen = 'soy'" -> UPDATE 30
the menus that list soya now (count(DISTINCT m.id)): 30 · rows that say soy: 0
MongoDB's half of unit18/rename, as read (not replayed here - the capture's own line, ../c8-unit18/README.md): op update · ns tiffinbox.menu · nMatched 30 · nModified 30
```

**2, Caffeine**, `unit12/stale`: 22/after's jar with no profile — Caffeine in the JVM, the profile unit 12 ran — on the unit's
PostgreSQL (`20621`), with unit 12's harness. A read; a write around the cache (`JdbcTemplate.update`, one row); psql reads the row
while the JVM waits; then Caffeine's cached read again. The control in the same JVM empties the cache and writes through `add`:

```text
PROBE stale: read 1 - Ravi's meals 2
PROBE stale: JdbcTemplate.update("update customer set meals_per_day = 3 where name = 'Ravi'") -> 1 row
PROBE stale: read 2 (the cached read) - Ravi's meals 2 · repository calls 0 · prepareStatementCount 0 · returned
the receipt at pause 1, psql (a second client, PostgreSQL): Ravi's row says 3
PROBE stale control: the cache emptied, a read, add(Oscar) through the cache, a read (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · rows 4 -> 5 · Oscar in the second read: true · Ravi's meals 3
```

**3, Redis**, `unit14/absent`: 22/after under dev with PostgreSQL, a fresh MongoDB and Elasticsearch up, and Redis absent — its port
`20625`, where nothing listens. The start stops before it serves, and names the same bean unit 14's did:

```text
listening on 20625 (lsof): 0
the JVM's exit: 1 · then curl /actuator/health on 20620: 000 · listening on 20620: 0
its log: "Error creating bean with name 'tiffinBoxServer'" 2 lines · "RedisConnectionFailureException: Unable to connect to Redis" 1 · "Application run failed" 1 · "Started TiffinBoxApp" 0 · 'dishes re-indexed' 0
its first exception line: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed
```

**4, MongoDB**, `unit19/silent`: after a dev start on the four stores (a fresh database, a fresh MongoDB, the shipped index deleted
first), unit `19`'s harness on the orders that start wrote. `$sum` over a String gives zeros, no exception; the control in the same JVM
sums the numbers:

```text
the start: Successfully applied 4 migrations · dishes re-indexed: rows 10 · documents before 0 · documents after 10
PROBE summeal: the stages the template sends (toPipeline): {"$group": {"_id": "$customer", "total": {"$sum": "$mealType"}}}, {"$sort": {"total": -1}}
PROBE summeal: groups 4 · sorted by total, then _id: Meera 0 · Priya 0 · Ravi 0 · Sunil 0 · their sum 0
PROBE pipeline: groups 4 · sorted by total, then _id: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · their sum 24300
its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0 · the order the server returned groups that tie (every total 0): not printed, it is the server's
```

**5, Elasticsearch**, `unit21/nohit`, its index half by REST: a labelled scratch index `dishes_std` on the unit's Elasticsearch,
`20624`, with unit 21's `std` variant of `dish-settings.json` (the analyzer `dish` without its synonym), filled with the ten rows of
the dev start's dish table, read by psql. `veg` finds nothing there; `vegetarian` finds the vegetarian box there; the shipped index
`dishes` finds the vegetarian box for `veg`, by curl and by TiffinBox's route; then `dishes_std` is deleted:

```text
-    "analyzer": { "dish": { "type": "custom", "tokenizer": "standard", "filter": ["lowercase", "veg_syn"] } }
+    "analyzer": { "dish": { "type": "custom", "tokenizer": "standard", "filter": ["lowercase"] } }
the rows (psql, c8u23-pg, the dev start's V4): 10 · ids 1,2,3,4,5,6,7,8,9,10
curl POST /dishes_std/_bulk?refresh=true (the ten rows) -> errors false · items 10 · _cat/indices dishes_std -> dishes_std green open 1 0 10
curl on 20624: _analyze {analyzer dish, "Vegetarian Lunch Box"} on dishes_std -> 3 [vegetarian, lunch, box] · on dishes -> 4 [vegetarian, veg, lunch, box]
curl on 20624: dishes_std match name veg -> 0 []
curl on 20624: dishes_std match name vegetarian -> 1 [1] · the shipped dishes match name veg -> 1 [1]
GET /dishes/search?q=veg (TiffinBox, 20620) -> 200 [{"id":"1","name":"Vegetarian Lunch Box","fragment":["<em>Vegetarian</em> Lunch Box"]}]
DELETE /dishes_std -> acknowledged true · _cat/indices now: dishes
```

The connection witness (S8.92), folded into the tail of `replay` — the unit's Elasticsearch container, its sockets read by `cat`:

```text
its interfaces (/proc/net/dev): eth0,lo
the sockets: listening (TCP) on 9200, 9300 · connections from another local port (outbound): 0 · UDP sockets: 0
```

### 5 · seven — the comparison set on the one tree (R.363)

`before` and `after` are one tree, so the seven runs once per repetition, on `20620`, and its md5 is compared with unit 22's — read off
`../c8-unit22/README.md`'s own seven block, where before/ and after/ printed one md5:

```text
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /dishes/search?q=veg -> 404 · listens on: 127.0.0.1:20620
its log: lines naming 9200 0 · naming elasticsearch, any case 0 · naming 27017 0
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20620 now: 0
```

### 6 · exercise — run as written, in one shell, bash then zsh (R.196)

```text
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
BAD Elasticsearch · a silent wrong answer: a feature word: powerful | neither unmeasured nor a capture reference
cells 25 · measured 17 · unmeasured 7 · bad 1
check: exit 1
then the solution's lines, in the same shell - the block's exit 0:
cells 25 · measured 18 · unmeasured 7 · bad 0
check: exit 0
"unmeasured" in that cell: exit 1 · bad 1 · BAD Elasticsearch · a silent wrong answer: unmeasured, but a capture exists for it: unit21/nohit
a feature word elsewhere (the solved cell, and flexible in MongoDB's default cell): exit 1 · bad 1 · BAD MongoDB · a default that does nothing: a feature word: flexible
```

The zsh half prints the same lines. The exercise needs Python 3 alone.

## Which store, which profile, which tree

- **One tree, named once:** `../c8-unit22/after` — `before` and `after` are both links to it, its pin is unit 22's after-tree line
  (file count and hash read off `../c8-unit22/receipts.md5` by the receipt, re-derived by `harness/tree23.py`), and every replay ran
  on its jar, built offline from a copy in `.harness/`.
- **PostgreSQL:** the unit's `c8u23-pg` on `20621` (a fresh database per JVM: `u23s` for replay 2, `u23absent` for replay 3,
  `u23dev` for the dev start); **the harness's** `c8u23-pg-h` on `20626` (replay 1's three tables, a fresh database `u23ren`).
- **Caffeine:** in the JVM of replay 2, no profile — the cache unit 12 measured.
- **Redis:** the unit's `c8u23-redis` on `20622`, flushed before the dev start; absent on `20625` for replay 3.
- **MongoDB:** the unit's `c8u23-mongo` on `20623`, a standalone, a fresh container for each dev start as unit 20 found.
- **Elasticsearch:** the unit's `c8u23-es` on `20624`, by the digest, with the six settings: the shipped index `dishes` the dev start
  rebuilt, and the scratch index `dishes_std` (replay 5), deleted after.
- **The checker's captures** (`rule`, `honest`, `feature`, `exercise`) read files only: `table.md` and the shipped READMEs and
  `receipts.md5` files of units `01`-`22`.

## Refused, named

- `unit01/alone` in the cost column: it printed an exit and a missing jar, never a count — the checker refuses it by name.
- A row that ranks a store, and a cell that names which store to pick for a job — the checker's ranking list, XFAM_S4B's unit `23`
  member and this unit's own family in `harness/s823.py`.
- A capture of unit `24` or beyond in a cell (S8.97) — the checker refuses it; PostgreSQL's write cell stays `unmeasured`.
- `unmeasured` read as a pass — each `unmeasured` cell's footnote in `table.md` says only that no capture of this
  course prints it.
- The one vector sentence, in `table.md`'s footnote, byte for byte: a vector index is a kind of index this course does not build.
- Wording, per sentence, by `harness/s823.py`: the families of Part A and Part B, units `19`-`22`'s refused readings, and unit
  `23`'s, each self-tested on a plant.

## The repository, and the network

This unit changes no file of the anchor: `../c8-tiffinbox` equals `../c8-unit22/after` at the start and at the end of every run
(`diff -rq` empty, printed). The seed is `../../spring-data-beyond-jpa/_research/m2-seed-c8-s4b/` as units `21` and `22` used it; no
artifact was added. `.m2-demo` is a copy of that seed, and the one build is offline (`-o`, `maven.repo.local` absolute, `Downloaded
from` counted `0`, `.m2-demo`'s file count unchanged). No pull: the four images by their digests, present before the run; the images
list and the volume count the same at the end. No network but the loopback, and the push of this unit's commit.

## The folders, the harness and the ports

- `table.md` — the table as it ships, its footnotes, and flag 10's one sentence.
- `harness/u23check.py` — the checker, with its self-test; `harness/chk23.py` — the checks; `harness/s823.py` — the prose gate;
  `harness/tree23.py` — the tree pin, unit 10's lines; `harness/dur8.py` (unit 02's) and `harness/logback.xml` (unit 07's), byte for
  byte.
- The replays' harnesses are the earlier units' own, copied by the receipt into `.harness/` byte for byte and compiled there:
  `../c8-unit12/harness/src/probe/u12/` (replay 2), `../c8-unit18/harness/src/probe/u18/H18.java` and `harness/pg3.sql` (replay 1),
  `../c8-unit19/harness/src/probe/u19/` (replay 4); unit 21's `harness/variants.py` gives replay 5 its one change, read, not run.
- Ports, all on `127.0.0.1`: `20620` TiffinBox and the harness JVMs · `20621` the unit's PostgreSQL · `20622` the unit's Redis ·
  `20623` the unit's MongoDB · `20624` the unit's Elasticsearch · `20625` never bound (Redis absent) · `20626` the harness's
  PostgreSQL · `20627`-`20629` spare, asserted free.

## Masks, filters and hygiene — every one, declared

The receipt masks the folders and the home, the Spring and Maven times, `"took"`, `took[…]`, `"@timestamp"`, `pid`, and an object's
identity hash (unit 22's mask, its self-test run first). Unit `19`'s harness prints the order the server returned groups in; where every
total is `0` the groups tie and that order is the server's, so its line is filtered out of `replay`, and the capture says so. Every
capture is refused if it holds an absolute path, a time, a time setting, a log time, a stack frame, H2's generated database name, a raw
container port, an all-interfaces binding, the shutdown token or the PostgreSQL password; `dur8` over the captures, this README,
`table.md` and the exercise is `0`.

## Interrupted

Four SIGINT points, run after the runs of record, each by sending SIGINT to the receipt's own process group (started with SIGINT at
its default, R.410): **mid-build** (Maven building the copy of after/), **mid-replay 1** (the harness's PostgreSQL alive, its database
`u23ren` loading), **mid-replay 3** (TiffinBox's dev start with Redis absent, the four other containers up) and **mid-replay 5** (the
scratch index `dishes_std` present on the unit's Elasticsearch). Each time: the receipt's exit `130`; the trap printed `_cat/indices`
after its `DELETE` of `dishes_std` (at mid-replay 5: `dishes` alone left, before the container went); afterwards `java` processes `0`,
no `c8u23-*` container, volumes `315`, images `9`, nothing listening on `20620`-`20629`, `.r-lock` gone, no partial capture, every
`.r-*.out` unchanged (md5 before = after). The logs are the evidence agent's scratch (`sigint-build.out`, `sigint-replay1.out`,
`sigint-replay3.out`, `sigint-replay5.out`).

## Planted faults — each caught (R.65, R.226)

Run after the runs of record, never beside one, by `plants.sh` (the evidence agent's scratch) on the sealed clone's copy of this
folder; each plant judged by the gate that must refuse it, each removed after, the controls passing:

- The checker, on planted tables: a feature word in a cell; `unmeasured` in a measured cell; a cell naming unit `24`'s capture;
  `unit01/alone` in the cost column; a ranking word in a row; a cell's number its capture did not print (the rename's `30` made
  `31`); a capture that does not resolve; the slogan that names a store for a job in a cell (XFAM_S4B's unit `23` member); a malformed
  table (exit `2`). The cannot-fail detector: the checker with its feature list emptied fails its own self-test (exit `3`).
  Control: the shipped table, exit `0`.
- `chk23.py` on doctored copies: the PostgreSQL cell's rename doctored to `31` against `replay` and against `honest`; the README's
  gloss's unmeasured count doctored to one more than the checker's, against that count (S8.95). Controls: the shipped table and README pass.
- The prose gate (`s823.py`), one planted sentence each: the slogans of a store for a job, of the one tool for a job, of a winning database,
  of one kind of store beating another, of a kind of store that does not grow; flag 10's plant naming a kind of search this course
  does not build; a feature word; a singular time word; a ranking; the table read as a verdict; a typed number. Control: flag 10's one
  sentence passes. dur8 refuses the exercise's line with one of dur8's own words in place of the feature word.
- The receipt's own gates on the clone: a wrong `before` link; a wrong tree hash; a placeholder in the README; a changed
  What-it-prints line; the exercise's table equal to the shipped one. In all, `30` plants refused and `4` controls passing
  (`plants.sh`'s last line).
- **What the plants found:** the wrong tree hash first reached the end of a run. The receipt's start pins were printed through a
  pipe into `tee`, so their `die` ended the pipe's subshell and not the receipt; the end pins (not piped) refused it. The start pins
  now stop the receipt where they fail, and the three runs of record above ran on that receipt; the five receipt plants were run
  again on it and each stopped at its own gate.

## What differed from the brief

Each entry dated 2026-11-23, the evidence agent's choice where the plan left one open (Vivek was not present; nothing was asked).

- **The plan's 5 / 8 / 5 / 7 was a date-bound split.** The brief classed its cells before units `18`-`22` shipped: five measured by
  its probe, eight by a shipped capture of Sections 1-3, five by a planned capture of `18`-`20`. Every named capture is a shipped one
  now, so the checker classes a cell by its unit's section: Sections 1-3 `8`, Part A `5`, Part B `5`, and PostgreSQL's cost cell
  holds captures of two sections (its first, `unit01/statements`, counts it in 1-3). The measured / unmeasured counts are the plan's
  (`18` / `7`), derived, not carried.
- **Each cell is the capture's own words.** The plan's cells were paraphrases; the shipped cells quote the lines the captures printed,
  so that the checker finds each number beside its own word: `unit14/absent` (Redis absent) says `the JVM's exit: 1, curl /actuator/health: 000`;
  `unit18/absent` says `the JVM's exit: 1, health 000, MongoTimeoutException 1` (the plan's words about the driver were a time, and
  no number); `unit17/otherholder` gains the `EXISTS -> 0` its capture printed after A's release (the plan's cell held no number,
  which the checker refuses); `unit16/dropped` gains `PUBLISH -> 0`; `unit10/nonames` (`spring.cache.cache-names` removed) reads `hitCount=4, missCount=1, cache_ lines 0`;
  `unit20/shapes` reads `findAll(OrderRef.class) 120 orders, tiffinbox.customers query 120`; `unit21/sayso` reads `_analyze
  "Vegetarian" -> 9 tokens`. No capture printed a number other than the plan's.
- **PostgreSQL's cost cell carries the rename as the three tables' `UPDATE 30` beside MongoDB's `nModified 30`** — the capture's own
  line; the four tables' `UPDATE 1` is printed by `honest` and is not in the cell (the hook speaks the tie).
- **`nohit`'s replay is the REST half of its index.** Unit 21's `nohit` was a whole copy-tree start (the `std` copy of the anchor,
  under dev, on its own Elasticsearch); replay 5 builds the copy's index alone, by curl, from the same variant, read off unit 21's
  `harness/variants.py`, and the dev start's ten rows. RE-MEASURE 8 asks for the number: `0 []`.
- **Replay 3's bean on 22/after** is `tiffinBoxServer`, the one unit 14's log named first — the start stops at the same bean.
- **The harnesses replayed are copied by the receipt**, from the earlier units' folders into `.harness/src`, asserted byte for byte,
  and compiled against 22/after's jar — not copied into the agent's scratch: a sealed clone runs them the same way.
- **The seven's expected md5** is read off `../c8-unit22/README.md`'s seven block, the md5 its before/ and after/ lines printed; unit
  22's `receipts.md5` line for `seven` is the hash of that whole capture (two trees), not the md5 of the seven's responses.
- **No mongosh** beside replay 4: unit `19`'s capture carried one; here the harness's control in the same JVM is the negation's other half.
- **The slot map** is the brief's: `20620` TiffinBox, `20621`-`20624` the four stores, `20625` unbound, `20626` the harness's
  PostgreSQL, `20627`-`20629` spare (asserted free, never bound).
- **The sockets** are folded into `replay`'s tail, as the prompt allows, not a seventh capture.
- **The prose gate** reads `table.md`'s prose without its rows; the rows are checked by `u23check.py`, and every body cell runs
  through dur8, XFAM_S4B and this unit's family by `chk23.py static` (`0` hits).
- **The receipt runs before this README's last sections were written.** "Runs of record", "Interrupted" and "Planted faults" were
  written after the three runs from their logs; then one more whole run of `./receipts.sh` on the final README (not a run of
  record) ended `every capture = published`, and the README's own gates passed on it.

## For RED

- **A script must not rank.** No row ranks a store, no cell names a winner, and no sentence says which store to pick for what — the
  checker, XFAM_S4B and `s823.py` each refuse one form.
- **No feature word and no time.** A cell is a failure, its capture and its number; the stampede cell says `2 in every round`, never a
  time; Redis absent is an exit and a health code, never Boot's wait.
- **The hook's two thirties, as read:** the three tables' `UPDATE 30` (unit `18`'s capture, and replay 1 on 22/after) beside MongoDB's
  `nModified 30` (unit `18`'s capture, read). The four tables, in the same capture, updated `1` row — the tie is the three tables'.
- **`43` is Spring Data JDBC's page,** beside JPA's `4`, on the same PostgreSQL: the cell says whose page it was, and C8-9's counter
  is Hibernate's, so it reads the JPA side only.
- **Seven unmeasured, by name:** PostgreSQL's four (its write cell is unit 24's, after this one), Caffeine's absent and write cells,
  Redis's cost cell.

## The ledger rows this unit pays

- **The pgvector note** (`PROMISE-LEDGER-2026-11-17.md` :38-41): honoured with flag 10's one sentence, byte for byte, in
  `table.md`'s footnote and in "Refused, named" above; the receipt asserts every line of this unit's prose that names the word is
  that sentence.
- **Roadmap `:354`** ("a decision table whose cells are failure modes, not features"): the table, and the checker that refuses a
  feature word in a cell.

## The values the video may say

Every count with its capture, its unit, the tree and the store that answered. The line between the markers is the receipt's own
(`.harness/values.txt`), asserted equal at every run:

<!-- values: begin -->
the values the video may say - exercise: broken exit 1 bad 1, solved exit 0, unmeasured in that cell exit 1, a feature word elsewhere exit 1 · rule: 25 cells, 18 measured, 7 unmeasured (PostgreSQL · a silent wrong answer; PostgreSQL · the store absent at start; PostgreSQL · a write outside the transaction; PostgreSQL · a default that does nothing; Caffeine · the store absent at start; Caffeine · a write outside the transaction; Redis · a cost that grows), by section 1-3 8 / 4A 5 / 4B 5, checker exit 0 · honest: Spring Data JDBC's page the witness 43 (40 of them one SELECT per customer) beside JPA's 4 (getPrepareStatementCount 4); oneread statements 1, JOIN 3, rows 4; rename three tables UPDATE 30, MongoDB nModified 30 (the four tables UPDATE 1) · feature: powerful full-text search in the Elasticsearch silent-wrong-answer cell -> exit 1, bad 1; the shipped table exit 0 · replay (22/after): 1 PostgreSQL three tables UPDATE 30 · 2 Caffeine the cached read says 2, the row now 3 · 3 Redis absent exit 1, health 000 (Error creating bean with name 'tiffinBoxServer') · 4 MongoDB $sum over a String, groups 4, every total 0 · 5 Elasticsearch dishes_std veg 0 [] · the seven: md5 466c20ed7e0d5439cb052f32ce09de1b on the one tree
<!-- values: end -->

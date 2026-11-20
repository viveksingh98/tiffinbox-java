# c8-unit18 — *MongoDB: Documents, Not Rows*

Course 8, Section 4's first unit, and **Section 4's first change to the anchor (D1)**. `before` is a link to `../c8-unit17/after`
(unit 17's tree; the receipt pins it and asserts that pin is unit 17's own after-tree line); `after/` is this unit's tree, and
`../c8-tiffinbox` equals `after/` from this unit's commit on. **Section 4 starts here: Document and search — MongoDB under the profile
dev.** A document is one record that holds its own lists inside it, stored and read whole: TiffinBox's menu is one MongoDB document per
day, `day-1` to `day-30`, its three items inside it and each item's allergens inside the item. No table held a menu before this unit;
PostgreSQL stays the system of record (the customers, their pauses, the orders), and the menu is new data, MongoDB's alone.

Every MongoDB number below comes from two witnesses in the same run (R.423): **Java's answer** — TiffinBox's own `GET /menu/{day}` under
"dev", the harness's `MongoTemplate` (`probe.u18.H18`: `findById`, the rename's `UpdateResult`, a null id's String), or the IT's lines —
and **mongosh's view of the stored bytes or of `system.profile`**, mongosh running only in another container of the same digest with
**no network** (`--network none`, `--volumes-from` the mongod container, over mongod's unix socket; that container's interface list is
printed, `lo`) — never an exec into the mongod container (R.422). The database's name is printed by the store itself: mongosh's
`listDatabases` beside the driver's own DEBUG line `Command "insert" started on database "tiffinbox"` (R.435). PostgreSQL's side of
`oneread` and `rename` is the harness's own container on 20576, every statement logged and counted between two marker statements —
never the unit's PostgreSQL on 20571, TiffinBox's system of record (RED #21). MongoDB is **8.3.17, by the digest**
(`mongo@sha256:05b334b0…c17cd`, `--pull never`, `127.0.0.1` only, no auth, `-e GLIBC_TUNABLES=glibc.pthread.rseq=1`); PostgreSQL is
18.6 and Redis 8.10.3 by the course's digests. Every line names its tree, its profile and its store (R.392): **18/after, profile dev,
PostgreSQL + Redis + MongoDB** (`anchor`, `absent`, `twice`'s two starts); **18/after, default run, H2, no Docker** (`default`, the
seven); **the harness's** (`document`'s Java read and null id, `oneread`'s and `rename`'s Java side and their PostgreSQL tables); **a
labelled copy** (`default`'s two copies, `twice`'s copy without the reset — `harness/variants.py`).

Ten captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `exercise` and the
tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string below is asserted
after its capture by `harness/chk18.py` against a second witness of the same run. Evidence by a Claude Opus 5.5 agent on 2026-11-20,
started 00:36 CET.

## Runs of record

**Before the one-line change (the fourth run, below):** `bash receipts.sh` (Homebrew bash 5.3.9, 2026-11-20 from 01:43:38 CET, ended 01:55:01), `./receipts.sh`
(/bin/bash 3.2.57, from 01:55:01, ended 02:06:31) and a sealed fresh clone (below, at `1876867`, from 02:06:56, ended 02:18:34): each
with every capture = published (the JVM ones 3/3 inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file
count unchanged, volumes back to their count and the images unchanged (nine images, 315 volumes, at the start and the end of each),
`before/` and `after/` = their pins at the start and the end, nothing listening on 20570-20579 or 18881-18883 at the end, each log
ending with its `c8-unit18:` line; each log through `check_unit8.py 18 --runlog` — `RESULT (run logs): PASS` (the unit gate itself has
no script for this unit yet, as expected: exit 2). **Nothing was downloaded, nothing pulled.** Five runs before them shaped the receipt (a
`docker` word in a message, a mounts list in Docker's own order, a port printed raw in `default`, the exercise's JDK in an `env -i`
shell, the check's regexes); the fifth printed every capture's hash and stopped at the README's text-block check (the README was a stub
then), and the hashes went into `receipts.md5`. The interruptions and the planted faults ran after the three runs of record, alone.

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at this unit's commit (`1876867`, before the commit was
amended with these paragraphs) into a path **with a space** (`…/sealed 18/tiffinbox-java`, in the session's scratch folder), the clone's
`.m2-demo` a file copy of the seed (7,171 files), `env -i` with `HOME`, `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`
and `DOCKER_CONFIG=$HOME/.docker`; `./receipts.sh`. The clone holds no ledger beside it, so `c815` checked the sentence's md5 there (its
ok line says so). The runs ran on this README before its *Runs of record*, *Interrupted* and *Planted faults* paragraphs were written;
the prose gate, the text-block check and the values check were run again on the final README against the last run's printed lines.

**A fourth run, on the script as amended** (`./receipts.sh`, /bin/bash 3.2.57, from 02:25:57 CET, ended 02:37:33): after the three, two
interruption runs aimed at the Compose window stopped by themselves on `image`'s own 3/3 check; the second kept its iteration files,
and the line one iteration held and the others did not was the docker CLI's `write /dev/stdout: broken pipe` — `mongod --version`
piped into `head -1`, which can close the pipe before the CLI has written all of its lines. The two `| head -1` after a `dk` call
became `| sed -n 1p` (it reads to the end), nothing else of the script moved, and this run — every capture = published, the
captures' hashes unchanged, `check_unit8.py 18 --runlog` PASS — is the run of record of the script as committed; the three above ran
on the script with the race in it, and passed.

## D1 — the change, file by file, and every README/YAML/Javadoc/compose sentence it rewrote or noted (R.250)

`diff -rq before/ after/` (the receipt prints it): six files changed, four new, none gone.
- `tiffinbox-web/pom.xml` — `spring-boot-starter-data-mongodb` (compile) beside the Redis starter; `spring-boot-starter-data-mongodb-test`
  and `testcontainers-mongodb` (test scope) in the test block. Boot's parent manages every version; none is typed. The receipt lists the
  five folders the change needs in `.m2-demo` (the seed holds them) before the first build. The Testcontainers comment ("Only
  CustomerEntityRepositoryIT uses them") gains its `Course 8, unit 18` note: and `MongoDatastoreIT`.
- `tiffinbox-web/src/main/resources/application.yaml` — `spring.autoconfigure.exclude`, the three classes read off the seed's
  `spring-boot-mongodb-4.1.2.jar` and `spring-boot-data-mongodb-4.1.2.jar` (`AutoConfiguration.imports`, printed by the receipt), with a
  comment in the file's voice: why (the starter alone builds a client on the default run; the health key alone leaves it trying 27017 —
  `default`, measured), and that "dev" clears the list. `management.health.mongo.enabled` is never written (R.425, a dead name).
- `tiffinbox-web/src/main/resources/application-dev.yaml` — `spring.autoconfigure.exclude: ""` beside `cache.type: redis`, commented: the
  MongoClient, the `MongoTemplate` and Boot's MongoDB health indicator (on, as Boot ships it) back for "dev" (RE-MEASURE 1, under the real
  profile: `anchor`'s dev start, `/menu/day-19` 200, health 200).
- `compose.yaml` — the `mongo` service after `redis`, every line ⚑6's: `image: mongo:8`, `GLIBC_TUNABLES: glibc.pthread.rseq=1` (one
  sentence: this Mac's kernel, the measured start), `MONGO_INITDB_DATABASE: tiffinbox` (Boot's Compose support reads it for the database
  name; the image reads it only for its init scripts), `command: ["--unixSocketPrefix", "/data/db"]`, `"127.0.0.1:18883:27017"` (as
  18882's comment: elsewhere 18883 is only a receipt port of `../c5-unit16` and `../c5-unit17`, never an anchor file's), the digest in a comment, a `Course 8, unit 18` note in the Redis notes' voice, no `pull_policy`, no volume of ours — and what the project's `down` and `down -v` left of
  the image's two anonymous volumes, as `anchor`'s Compose window measured it. The file's first sentence ("one official Postgres image")
  gains its `Course 8, unit 18` note beside unit 11's.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/MenuDay.java` — **new**: `@Document("menu")`, a record, `@Id String id` (the day) and
  `List<MenuItem> items`, `MenuItem` a nested record (RE-MEASURE 4); its Javadoc: the section's name, the gloss, why embedded (one read;
  the rename's cost), dev-only.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/Menus.java` — **new**: `@RestController @Profile("dev")` on `MongoTemplate`;
  `reset()` = `remove(new Query(), MenuDay.class)` (a delete — never `dropCollection`, R.431), `fill(days)` = `insertAll`,
  `GET /menu/{day}` = `findById` → 200 and the document, or 404 with no body.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java` — a third provider, `ObjectProvider<Menus>`; `start()` resets
  and fills `MenuDay.forDays(days)` before the orders, unguarded (⚑7); a `Course 8, unit 18` paragraph after unit 15's in the class
  Javadoc and in `start()`'s.
- `tiffinbox-web/src/test/java/slice/MongoSlice.java` and `com/tiffinbox/web/MongoDatastoreIT.java` — **new** (⚑10, R.454's binding).
- `README.md` — this unit's own section, the header's note, and a note on the compose bullet of `c5-unit17`'s section.

**The R.250 hunt** — `harness/chk18.py r250` checks each, and the receipt prints the list:

- compose.yaml:1 "one official Postgres image" - noted (Course 8, unit 18: and MongoDB, the third)
- compose.yaml's "under "dev" Redis is required" - kept (still true); the mongo service says Mongo is required too
- tiffinbox-web/pom.xml's Testcontainers comment ("Only CustomerEntityRepositoryIT uses them") - noted (Course 8, unit 18: and MongoDatastoreIT)
- README.md's header (the data lives in PostgreSQL and Redis) - noted (Section 4's first change, this unit's note)
- README.md's compose bullet in c5-unit17's section ("one official Postgres image") - noted (Course 8, unit 18: and MongoDB)
- README.md's `mvn package still runs the 18 and needs no Docker` (units 14-17) - kept, still true (RE-MEASURE 13); this unit's section says so
- README.md's "the default run still needs no Redis" (units 14-17) - kept, still true; this unit's section adds no Docker and no MongoClient

U17's "Section 3 complete — next" hand-off is in `c8-unit17/README.md` only (frozen there), never in the anchor README: nothing to note.
No sentence in the anchor said TiffinBox's data lives in PostgreSQL and Redis alone; the header's list of changes now ends with this unit's.

## The IT's Testcontainers binding — three readings, and R.454's shape (settled first)

Testcontainers 2.0.5's `MongoDBContainer`, in its default shape, published 27017 on every interface of the host — three `mvn verify`
runs of the IT alone (`-Dtest=MongoDatastoreIT`, offline, 2026-11-20 00:43-00:45 CET, before the receipt existed — so these lines sit
in a plain block, not a capture), each reading Docker's own record of the container's bindings from inside the test
(`getContainerInfo()`, the address printed, the port masked), before the anchor's IT took R.454's shape; then the same three runs with
the shape:

```
default shape, tcb1: the container's port bindings (Docker's own record): [0.0.0.0:<port>->27017/tcp, :::<port>->27017/tcp]
default shape, tcb2: the container's port bindings (Docker's own record): [0.0.0.0:<port>->27017/tcp, :::<port>->27017/tcp]
default shape, tcb3: the container's port bindings (Docker's own record): [0.0.0.0:<port>->27017/tcp, :::<port>->27017/tcp]
R.454's shape, tcl1: the container's port bindings (Docker's own record): [127.0.0.1:<port>->27017/tcp]
R.454's shape, tcl2: the container's port bindings (Docker's own record): [127.0.0.1:<port>->27017/tcp]
R.454's shape, tcl3: the container's port bindings (Docker's own record): [127.0.0.1:<port>->27017/tcp]
```

So `MongoDatastoreIT` names the address: `.withExposedPorts(27017)` and a `withCreateContainerCmdModifier` that binds
`127.0.0.1:20578` → 27017; `@ServiceConnection` reads the mapped port and connects. On every run of record the receipt reads Docker's
list (`dk ps`, polled on a count while `verify` runs) and the IT prints its own reading — both in `anchor`, below. The other ITs
(units 07-17's) were not touched (a backlog item of its own).

## RE-MEASURE 4 — the shipped menu: names, prices and their source, allergens, and the two numbers (settled first)

The menu is the menu's own, written in `MenuDay.java`: three English dish names per meal type, one per day in turn, and one price per
meal type. Its prices are not the seed's: `V2__seed.sql` prices customers, and its two VEG customers pay two different prices, so
there is no one VEG price to derive — the menu says its own. Read off the shipped class by the harness (`H18 days`, once, outside the
captures):

```text
  PROBE days: MenuDay.forDays(30) -> 30 days, ids day-1 ... day-30
  PROBE days: items per day [3]
  PROBE days: VEG dishes [Lentil soup with bread, Spinach and cheese bake, Vegetable curry with rice] · price [110]
  PROBE days: NON_VEG dishes [Baked fish with potatoes, Egg fried rice, Grilled chicken with rice] · price [160]
  PROBE days: VEGAN dishes [Bean and tofu chili, Chickpea and tofu stew, Tofu and noodle stir-fry] · price [130]
  PROBE days: allergens on the menu, distinct 7 [celery, egg, fish, gluten, milk, mustard, soy]
  PROBE days: the allergen every VEG item carries []
  PROBE days: the allergen every NON_VEG item carries []
  PROBE days: the allergen every VEGAN item carries [soy]
```

Every VEGAN item carries soy, so `rename` renames soy to soya across every menu. `day-19` is the first turn's day. The two numbers,
read off `oneread` and `rename` below on 18/after's document: one `query` op, one document, its items and its allergens; and one
`update` op, every menu modified — beside the harness's four tables' one statement, three joins, a row per item and allergen, and
`UPDATE 1`; the three-table tie labelled.

## The section's name, and what it measured (C8-15, C8-14)

Course 7's finale, *What's Next: Not Everything Is a Relation* (`java7_series.TITLES["40"]`), named this section; the ledger's C8-15
quotes it, and this README quotes it byte for byte: "Two of its sections are called Redis as a datastore, and Document and search, and the second of those opens with MongoDB, Documents, Not Rows. That's where not everything is a relation, named here and not measured."
Its md5 is derived by `harness/chk18.py c815` from the sentence in this file, and the ledger's row is read beside it on the author's
machine (a sealed clone holds no ledger: the md5 is the check there):

```text
ok README.md quotes C8-15's sentence byte for byte (md5 e0995575970adc36d4dd7bc4fcf63ffd)
```

This unit is *MongoDB: Documents, Not Rows* (C8-14: the title Course 7's finale said, `java8_series.TITLES["18"]`, unchanged), and it
measures the half that was "named here and not measured": the menu is no table's rows — it is one document, read whole (`oneread`),
and the rename is the case where the document does not win (`rename`).

## The captures — what each one shows

### 1 · image — the digest's facts, the kernel line, the variable (⚑3, R.421; on this machine)

`dk image inspect` by the digest; then a labelled container **without** the variable: it exits 1 before it serves and prints its fatal
line, quoted whole (every field but its time; the JIRA link as the server prints it, the page unread); then the unit's container
**with** `GLIBC_TUNABLES=glibc.pthread.rseq=1`: it serves, `db.version()` answers from mongosh with no network, and its startup warning
is quoted whole — it asks for `rseq=0`, the opposite of what this machine needs (unset and `rseq=0` both stop, measured by BLUE; this
receipt shows the unset one). The setting is argued from that measured start alone. Each container's two volumes appear while it
exists and go with `rm -fv`: the count back to its baseline each time.

```text
-- the image, by its digest, on this machine (dk image inspect):
  Id sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd · Size 292228080 · Volumes {"/data/configdb":{},"/data/db":{}} · Cmd ["mongod"] · Entrypoint ["docker-entrypoint.sh"]
  images on this machine: 9 · the digest among them: 1
-- a container WITHOUT the variable, labelled (c8u18-mongo-nov, 127.0.0.1:20573, --pull never, --unixSocketPrefix /data/db): volumes before it 315
  its state: exited, exit code 1 · volumes now 317 · its Mounts: volume /data/configdb · volume /data/db
  its fatal line ("s":"F"), every field but the time:
    {"s": "F", "c": "CONTROL", "id": 12257600, "ctx": "main", "msg": "MongoDB cannot start: Linux kernel versions 6.19.0 through 7.0.13 have a known incompatibility with this version of MongoDB. See https://jira.mongodb.org/browse/SERVER-121912 for more information."}
  dk rm -fv c8u18-mongo-nov · volumes 315
-- the unit's container, WITH -e GLIBC_TUNABLES=glibc.pthread.rseq=1 (--pull never, 127.0.0.1:20573, --unixSocketPrefix /data/db):
  its state: running · volumes now 317 · its Mounts: volume /data/configdb · volume /data/db
  its startup warning id 8718500, the message whole:
    "s":"W" "c":"CONTROL" "id":8718500 "msg":"Your system has glibc support for rseq built in, which is not yet supported by tcmalloc-google and has critical performance implications. Please set the environment variable GLIBC_TUNABLES=glibc.pthread.rseq=0"
  mongosh, in a container of the digest with no network (--network none, --volumes-from c8u18-mongo, mongod's socket):
    db.version() -> 8.3.17
    that container's interfaces (its /proc/net/dev, read by mongosh): lo
    listDatabases -> admin,config,local
  mongod --version, in a container of the digest with no network: db version v8.3.17
  dk rm -fv c8u18-mongo · volumes 315
```

### 2 · anchor — the tests, the libraries, the dev shape on three stores, and the Compose window (⚑5/⚑6/⚑7, R.425, R.435; RE-MEASURE 1, 2, 3, 8, 12, 13, 14)

The tests first, once per run: `mvn package` with Docker at nothing — the tests on H2 green, no log line naming 27017 or mongo
(RE-MEASURE 13); then `mvn verify` with Docker — the container tests one more than unit 17's, `MongoDatastoreIT` (R.363: the move and
its cause, this test);
Ryuk off (`TESTCONTAINERS_RYUK_DISABLED=true`, as unit 17's receipt); the IT's container gone after; its `Ports` line (R.454); no
mongosh anywhere in the log (R.422); no Compose in a test (RE-MEASURE 8). Then the jar's libraries and after/'s dev start on the
unit's three containers, Compose off, the addresses on the command line, the database a fresh one, Redis emptied, the profiler on
before the start: the start's own lines (strict mode's `Found 0 MongoDB repository interfaces` — the next unit's repository is not
this unit's), the driver's DEBUG line naming `tiffinbox` for the delete and the insert, `system.profile`'s two ops, the documents and
`listDatabases`, the routes, the stores' versions. Then **the Compose window** — one labelled window, the receipt's only Compose run:
after/ under "dev" with Boot's Docker Compose support on, the shipped `compose.yaml`, no address key — Boot hands them over; the
database by the store (no `test`, R.435); then the project's `stop` (Boot's), `down` and `down -v`, each with its volume count.

```text
-- the tests: after/ copied to .harness/tests; mvn package with Maven's DOCKER_HOST pointed at nothing (tcp://127.0.0.1:1), offline:
$ cd .harness/tests && env DOCKER_HOST=tcp://127.0.0.1:1 env "MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8" perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local="$M2" "-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home" clean package -pl tiffinbox-web -am
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
  after it: images 9 (the same list) · volumes 315 · Testcontainers containers 0 · .m2-demo's files unchanged
  Surefire's reports, tiffinbox-web/target/surefire-reports:
    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0
      passed  aListenerHearsANewCustomer
    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0
      passed  aPathNobodyMapsIsAProblemDetail
      passed  aFailingRepositoryIsAFiveHundred
      passed  aFailingRepositoryShowsTheErrorPage
    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0
      passed  theFeedIsAnEventStream
      passed  theDashboardIsAPage
      passed  anInvalidCustomerBreaksThreeRules
      passed  theTestsRunInEnglish
      passed  anUploadAddsTheGoodRowAndNamesTheRest
      passed  shutdownIsNotAGet
      passed  customersAreJson
      passed  theFormIsAPage
      passed  aNameNobodyHasIsAProblemDetail
      passed  aFailingRepositoryLeavesNoStatus
      passed  theSliceLeavesTheDatabaseOut
      passed  sixtyOneSpacesBreakBothRules
      passed  anInvalidCustomerInGerman
      passed  aSixtyOneLetterNameIsRefused
    the fork's locale, read from the reports' properties: user.language en · user.country US · the same in every report: yes
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
  tiffinbox-web/target/surefire-reports-it: absent - no container test ran
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  the package log (RE-MEASURE 13): lines naming 27017 0 · lines naming mongo (any case) 0
-- then mvn verify, the anchor's recipe (DOCKER_HOST on the pinned socket, Ryuk off - TESTCONTAINERS_RYUK_DISABLED=true, a receipt home), offline:
$ cd .harness/tests && env "MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8" perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local="$M2" "-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home" clean verify -pl tiffinbox-web -am
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
  after it: images 9 (the same list) · volumes 315 · Testcontainers containers 0 · .m2-demo's files unchanged
  the IT's MongoDB container while verify ran, Docker's own list (dk ps, polled on a count): Ports 127.0.0.1:20578->27017/tcp · its command "docker-entrypoint.sh mongod"
  Surefire's reports, tiffinbox-web/target/surefire-reports:
    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0
      passed  aListenerHearsANewCustomer
    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0
      passed  aPathNobodyMapsIsAProblemDetail
      passed  aFailingRepositoryIsAFiveHundred
      passed  aFailingRepositoryShowsTheErrorPage
    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0
      passed  theFeedIsAnEventStream
      passed  theDashboardIsAPage
      passed  anInvalidCustomerBreaksThreeRules
      passed  theTestsRunInEnglish
      passed  anUploadAddsTheGoodRowAndNamesTheRest
      passed  shutdownIsNotAGet
      passed  customersAreJson
      passed  theFormIsAPage
      passed  aNameNobodyHasIsAProblemDetail
      passed  aFailingRepositoryLeavesNoStatus
      passed  theSliceLeavesTheDatabaseOut
      passed  sixtyOneSpacesBreakBothRules
      passed  anInvalidCustomerInGerman
      passed  aSixtyOneLetterNameIsRefused
    the fork's locale, read from the reports' properties: user.language en · user.country US · the same in every report: yes
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
  Surefire's reports, tiffinbox-web/target/surefire-reports-it:
    TEST-com.tiffinbox.CustomerEntityRepositoryIT.xml: tests 3 · failures 0 · errors 0 · skipped 0
      passed  theMigrationsAreTheSchema
      passed  theDashboardReadIsOneStatementHoweverManyCustomers
      passed  theCustomersComeTenAtATimeByKeyset
    TEST-com.tiffinbox.jdbc.CustomerAggregatesIT.xml: tests 2 · failures 0 · errors 0 · skipped 0
      passed  theSliceStartsTheJdbcLayerAndTheFixtureIsHere
      passed  theFixtureRunsAgainAndTheFirstOneIsGone
    TEST-com.tiffinbox.web.MongoDatastoreIT.xml: tests 1 · failures 0 · errors 0 · skipped 0
      passed  aDayOfTheMenuIsOneDocumentWithItsItemsInside
    TEST-com.tiffinbox.web.RedisDatastoreIT.xml: tests 3 · failures 0 · errors 0 · skipped 0
      passed  theLeaderboardIsASortedSetRedisReadsByName
      passed  theKitchenOrdersAreHashesAndTheirIndexSetsRedisReadsByName
      passed  aStoredCustomerIsOneStreamEntryRedisReadsInTheOrderWritten
    the fork's locale, read from the reports' properties: user.language en · user.country US · the same in every report: yes
    in all: 4 reports · tests 9 · failures 0 · errors 0 · skipped 0
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  Surefire's Results line: Tests run: 9, Failures: 0, Errors: 0, Skipped: 0
  MONGO IT the container's port bindings (Docker's own record): [127.0.0.1:20578->27017/tcp]
  MONGO IT day-19, through Menus: items 3 · [Chickpea and tofu stew, Grilled chicken with rice, Vegetable curry with rice]
  MONGO IT the same document, through the driver's collection: _id String · _class com.tiffinbox.web.MenuDay · items 3 · documents in menu 1
  the verify log: 'Creating container for image' 4 · 'Pulling' 0 · lines naming docker compose 0 · Testcontainers containers after it: 0
  mongosh named in the verify log: 0 · --replSet named in the IT container's command: 0
-- the jar's libraries (ls lib | wc -l), before/ and after/, and the jars after/ gained or lost (comm, by name):
  before/: 122 libraries
  after/: 129 libraries
  gained: bson-5.8.1.jar bson-record-codec-5.8.1.jar mongodb-driver-core-5.8.1.jar mongodb-driver-sync-5.8.1.jar spring-boot-data-mongodb-4.1.2.jar spring-boot-mongodb-4.1.2.jar spring-data-mongodb-5.1.2.jar · lost: 0
  the version lines off the jar names: mongodb-driver-sync-5.8.1.jar spring-boot-4.1.2.jar spring-data-jpa-4.1.2.jar spring-data-mongodb-5.1.2.jar spring-data-redis-4.1.2.jar
-- after/ under the profile dev, on PostgreSQL 18.6 + Redis 8.10.3 + MongoDB 8.3.17 (the three containers, by the digest), one start on a fresh database and an emptied Redis, Compose off:
  the overrides: --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20572 --spring.mongodb.uri=mongodb://127.0.0.1:20573/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG (the datasource from the config tree, the password never on a command line)
  redis-cli FLUSHALL (the unit's Redis) -> OK
  a fresh database on c8u18-pg: u18anchor (psql) · its URL in the config tree (0600, never printed)
  mongosh (no network): db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2) -> 1
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20572 --spring.mongodb.uri=mongodb://127.0.0.1:20573/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  the start's lines:
    (x1) Command "delete" started on database "tiffinbox"
    (x1) Command "insert" started on database "tiffinbox"
    (x1) Database: jdbc:postgresql://<the unit's>/<db>?user=tiffinbox&password=******** (PostgreSQL 18.6)
    (x1) Found 0 MongoDB repository interfaces
    (x1) Found 1 JDBC repository interface
    (x1) Found 1 JPA repository interface
    (x1) Found 1 Redis repository interface
    (x1) HHH000001: Hibernate ORM core version 7.4.13.Final
    (x4) Multiple Spring Data modules found, entering strict repository configuration mode
    (x1) tiffinbox: kitchen value:  24300
    (x1) tiffinbox: orders cooked:  120
  the MongoClient line Boot logs (its settings, masked whole - the dur8 list): 1 line
  system.profile on tiffinbox.menu after the start (mongosh, no network) - the ops in order, each with its count of documents:
    op remove, the filter {}
    op insert, ninserted 30
  mongosh: db.setProfilingLevel(0) -> 1 · db.menu.countDocuments() -> 30 · listDatabases -> admin,config,local,tiffinbox
  GET /menu/day-19 -> 200 {"id":"day-19","items":[{"mealType":"VEG","name":"Vegetable curry with rice","price":110,"allergens":["milk","mustard"]},{"mealType":"NON_VEG","name":"Grilled chicken with rice","price":160,"allergens":["celery"]},{"mealType":"VEGAN","name":"Chickpea and tofu stew","price":130,"allergens":["soy"]}]}
  GET /menu/day-31 -> 404 
  GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
  GET /dashboard -> 200
  GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300}
  GET /leaderboard -> 200 {"Sunil":9000.0,"Ravi":7200.0,"Meera":4500.0,"Priya":3600.0}
  the stores' own versions: mongosh db.version() 8.3.17 · redis-cli INFO server redis_version:8.10.3 · psql show server_version 18.6
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20570: 0
-- the Compose window: after/ under dev, Boot's Docker Compose support on, the shipped compose.yaml (cmp: after/'s), from .harness/compose-run; no spring.* address key - Boot hands them over:
  before it: listening on 18881-18883 0 · tiffinbox-dev volumes 0 · tiffinbox-dev networks 0 · volumes 319 · mongo:8 postgres:18-alpine redis:8-alpine present, on the digests (checked at the start)
$ cd .harness/compose-run && DOCKER_HOST=$DH perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "<after/'s classes>:<Maven's runtime class path for after/>" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20570 --spring.profiles.active=dev --logging.level.org.mongodb.driver.protocol.command=DEBUG
  the project's containers: tiffinbox-dev-mongo-1 127.0.0.1:18883->27017/tcp|tiffinbox-dev-postgres-1 127.0.0.1:18881->5432/tcp|tiffinbox-dev-redis-1 127.0.0.1:18882->6379/tcp
  the mongo service's container: GLIBC_TUNABLES 1 · MONGO_INITDB_DATABASE=tiffinbox 1 · its command ["--unixSocketPrefix","/data/db"] · its Mounts: volume /data/configdb · volume /data/db · volumes now 322
  the start's lines: 1 Command "delete" started on database "tiffinbox"|1 Command "insert" started on database "tiffinbox"|1 tiffinbox: orders cooked:  120
  GET /menu/day-19 -> 200 {"id":"day-19","items":[{"mealType":"VEG","name":"Vegetable curry with rice","pr…
  mongosh (no network, --volumes-from tiffinbox-dev-mongo-1): listDatabases -> admin,config,local,tiffinbox · db.menu.countDocuments() on tiffinbox -> 30 · on test -> 0
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20570: 0
  after TiffinBox stopped (Boot's own compose stop): the project's containers tiffinbox-dev-mongo-1 exited|tiffinbox-dev-postgres-1 exited|tiffinbox-dev-redis-1 exited · volumes 322 · tiffinbox-dev volumes by name: tiffinbox-dev_data · the mongo service's two (by its Mounts): present present
$ cd .harness/compose-run && docker -H "$DH" compose -p tiffinbox-dev down
  then: the project's containers 0 · its networks 0 · volumes 322 · tiffinbox-dev volumes by name: tiffinbox-dev_data · the mongo service's two: present present
$ cd .harness/compose-run && docker -H "$DH" compose -p tiffinbox-dev down -v
  then: volumes 321 · tiffinbox-dev volumes by name: 0 · the mongo service's two: present present
  the receipt removes the mongo service's two by the names its container listed (dk volume rm): volumes 319 = before the window · listening on 18881-18883: 0
```

**RE-MEASURE 3, as measured:** after Boot's `stop` the project's three containers are exited and three volumes are added
(`tiffinbox-dev_data` and the mongo service's two anonymous ones); the project's `down` removes the containers and the network and
leaves all three; a `down -v` after it removes `tiffinbox-dev_data` and leaves the mongo service's two, named only by their IDs — the
receipt removes them by the names the container listed under `Mounts`. `compose.yaml`'s comment says exactly this.

### 3 · document — the stored document beside Java's read (R.423, R.430)

mongosh prints `day-19` as stored: its items embedded, `_class` last — the type hint the mapper writes, the full class name — and `_id`
a string. Beside it the harness's `findById` reads the same three items. Then a labelled harness insert of a `MenuDay` whose id is
left null: mongosh shows an ObjectId (masked `<objectid>`), Java reads back a String of 24 hex characters; the receipt deletes that one
document (a `deleteMany` on the ObjectId type, never a drop) and the menu is back to its days.

```text
-- the shipped menu, read off after/'s MenuDay by the harness (RE-MEASURE 4):
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh18.port=20573 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u18.H18 days
  PROBE days: MenuDay.forDays(30) -> 30 days, ids day-1 ... day-30
  PROBE days: items per day [3]
  PROBE days: VEG dishes [Lentil soup with bread, Spinach and cheese bake, Vegetable curry with rice] · price [110]
  PROBE days: NON_VEG dishes [Baked fish with potatoes, Egg fried rice, Grilled chicken with rice] · price [160]
  PROBE days: VEGAN dishes [Bean and tofu chili, Chickpea and tofu stew, Tofu and noodle stir-fry] · price [130]
  PROBE days: allergens on the menu, distinct 7 [celery, egg, fish, gluten, milk, mustard, soy]
  PROBE days: the allergen every VEG item carries []
  PROBE days: the allergen every NON_VEG item carries []
  PROBE days: the allergen every VEGAN item carries [soy]
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
-- the stored document, mongosh (no network) - day-19 as after/'s start inserted it under dev:
    {
      _id: 'day-19',
      items: [
        {
          mealType: 'VEG',
          name: 'Vegetable curry with rice',
          price: 110,
          allergens: [
            'milk',
            'mustard'
          ]
        },
        {
          mealType: 'NON_VEG',
          name: 'Grilled chicken with rice',
          price: 160,
          allergens: [
            'celery'
          ]
        },
        {
          mealType: 'VEGAN',
          name: 'Chickpea and tofu stew',
          price: 130,
          allergens: [
            'soy'
          ]
        }
      ],
      _class: 'com.tiffinbox.web.MenuDay'
    }
  mongosh: its keys _id,items,_class · typeof _id string · _class com.tiffinbox.web.MenuDay
-- beside it, Java - the harness's MongoTemplate (probe.u18.H18) over the same MongoDB:
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh18.port=20573 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u18.H18 read
  PROBE read: the harness's MongoTemplate.findById("day-19", MenuDay.class), once -> one MenuDay, id day-19 · items 3 · allergens on its items 4 (distinct 4)
  PROBE read:   VEG Vegetable curry with rice 110 [milk, mustard]
  PROBE read:   NON_VEG Grilled chicken with rice 160 [celery]
  PROBE read:   VEGAN Chickpea and tofu stew 130 [soy]
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
-- a null id, the harness's (probe.u18.H18 nullid - labelled; the collection holds 30 before it):
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh18.port=20573 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u18.H18 nullid
  PROBE nullid: the harness's insert of a MenuDay with its id left null -> the id Java reads back: a String of length 24, hex digits only true
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  mongosh: the document whose _id is an ObjectId: typeof _id object · an ObjectId true · its keys _id,items,_class · _class com.tiffinbox.web.MenuDay
    printjson(_id): ObjectId(<objectid>)
  mongosh: db.menu.deleteMany({_id: {$type: "objectId"}}) -> deletedCount 1 · countDocuments() 30
```

### 4 · oneread — one whole menu: one `query` op and one document, beside one statement with three joins (R.424, R.433, the hook)

The profiler reset (level 0, `system.profile` dropped, level 2), the harness's `findById("day-19", MenuDay.class)` once, then every op
`system.profile` holds for `tiffinbox.menu`. Beside it the same thirty menus in the harness's PostgreSQL — the harness writes both
stores' menus from one list, the shipped `MenuDay.forDays(30)`: MongoDB's by TiffinBox's own start, PostgreSQL's by the INSERTs the
harness prints from it (`harness/pg4.sql` and `harness/pg3.sql` hold the schemas). The four tables — `menu`, `menu_item`, `allergen`
with a unique name, `item_allergen` — read `day-19` with one statement and three joins, a row per item and allergen (the item's row
repeated for each of its allergens); the three tables, labelled, with two joins and the same rows.

```text
-- one read of one whole menu, MongoDB (the store after/'s start filled under dev):
  mongosh (no network): db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2) -> 1
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh18.port=20573 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u18.H18 read
  PROBE read: the harness's MongoTemplate.findById("day-19", MenuDay.class), once -> one MenuDay, id day-19 · items 3 · allergens on its items 4 (distinct 4)
  PROBE read:   VEG Vegetable curry with rice 110 [milk, mustard]
  PROBE read:   NON_VEG Grilled chicken with rice 160 [celery]
  PROBE read:   VEGAN Chickpea and tofu stew 130 [soy]
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  system.profile, mongosh (no network) - every op on tiffinbox.menu since the reset:
    ops 1
    op query · ns tiffinbox.menu · command find · filter {"_id":"day-19"} · nreturned 1
  mongosh: db.setProfilingLevel(0) -> 1
-- the same menu in PostgreSQL - the harness's tables, labelled, from the same thirty menus:
  the harness's PostgreSQL (c8u18-pg-h, 20576), a fresh database u18read: harness/pg4.sql and harness/pg3.sql, then the INSERTs probe.u18.H18 printed from MenuDay.forDays(30) (sql4 247 lines, sql3 240 lines) · rows: f4.menu 30 · f4.menu_item 90 · f4.allergen 7 · f4.item_allergen 120 · f3.item_allergen 120
  the four tables (menu, menu_item, allergen, item_allergen) - day-19, between two marker statements (log_statement=all):
    $ psql -At -c "SELECT m.id, i.name, i.price, a.name FROM f4.menu m JOIN f4.menu_item i ON i.menu_id = m.id JOIN f4.item_allergen ia ON ia.item_id = i.id JOIN f4.allergen a ON a.id = ia.allergen_id WHERE m.id = 'day-19' ORDER BY i.id, a.name"
      day-19|Vegetable curry with rice|110|milk
      day-19|Vegetable curry with rice|110|mustard
      day-19|Grilled chicken with rice|160|celery
      day-19|Chickpea and tofu stew|130|soy
    rows (psql -At | wc -l): 4 · PostgreSQL's log between the markers: statements 1 · JOIN in it 3
  the three tables, labelled (menu, menu_item, item_allergen with the allergen as text) - the same read:
    $ psql -At -c "SELECT m.id, i.name, i.price, ia.allergen FROM f3.menu m JOIN f3.menu_item i ON i.menu_id = m.id JOIN f3.item_allergen ia ON ia.item_id = i.id WHERE m.id = 'day-19' ORDER BY i.id, ia.allergen"
      day-19|Vegetable curry with rice|110|milk
      day-19|Vegetable curry with rice|110|mustard
      day-19|Grilled chicken with rice|160|celery
      day-19|Chickpea and tofu stew|130|soy
    rows (psql -At | wc -l): 4 · PostgreSQL's log between the markers: statements 1 · JOIN in it 2
```

### 5 · rename — soy to soya on every menu: one `update` op over every document, beside `UPDATE 1` (the failure receipt; control `oneread`)

The harness refills the shipped menu (its labelled `remove` + `insertAll` of the same list), resets the profiler and renames with one
`updateMulti` and an array filter (`items.$[].allergens.$[x]`, x = soy). One `update` op; every menu modified. The four tables:
`UPDATE 1` — one row, and every menu then lists the new name through the joins. **The measured case where the document does not win.**
The three tables, labelled: one row per item and allergen, so the same rename is one row per menu — a tie with MongoDB's documents
(RED #1). No exception anywhere (the counts printed). The harness puts the shipped menu back after.

```text
-- the rename, MongoDB: soy -> soya on every item of every menu (the allergen every VEGAN item carries):
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh18.port=20573 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u18.H18 refill
  PROBE refill: the harness's remove(new Query()) then insertAll(MenuDay.forDays(30)) -> count 30
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  mongosh (no network): db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2) -> 1 · countDocuments({"items.allergens": "soy"}) before -> 30
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh18.port=20573 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u18.H18 rename=soy:soya
  PROBE rename: the harness's updateMulti, items.$[].allergens.$[x] = soya where x = soy -> matched 30, modified 30
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  system.profile, mongosh (no network) - every op on tiffinbox.menu since the reset:
    ops 1
    op update · ns tiffinbox.menu · nMatched 30 · nModified 30
  mongosh: db.setProfilingLevel(0) -> 1 · countDocuments({"items.allergens": "soya"}) -> 30 · countDocuments({"items.allergens": "soy"}) -> 0 · countDocuments() -> 30
-- the same rename in PostgreSQL - the harness's tables, labelled:
  the harness's PostgreSQL (c8u18-pg-h, 20576), a fresh database u18ren: harness/pg4.sql and harness/pg3.sql, then the INSERTs probe.u18.H18 printed from MenuDay.forDays(30) (sql4 247 lines, sql3 240 lines) · rows: f4.menu 30 · f4.menu_item 90 · f4.allergen 7 · f4.item_allergen 120 · f3.item_allergen 120
  the four tables: $ psql -c "UPDATE f4.allergen SET name = 'soya' WHERE name = 'soy'" -> UPDATE 1
    the menus that list soya now, through the joins (count(DISTINCT m.id)): 30 · that list soy: 0
  the three tables, labelled (one row per item and allergen, the name as text): $ psql -c "UPDATE f3.item_allergen SET allergen = 'soya' WHERE allergen = 'soy'" -> UPDATE 30
    the menus that list soya now (count(DISTINCT m.id)): 30
  no exception anywhere: lines naming an Exception or ERROR in the harness JVM's log 0 · in PostgreSQL's psql answers 0
-- the harness puts the shipped menu back (soy):
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh18.port=20573 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u18.H18 refill
  PROBE refill: the harness's remove(new Query()) then insertAll(MenuDay.forDays(30)) -> count 30
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
```

### 6 · absent — dev with no MongoDB: the start stops (the failure receipt, R.426, RE-MEASURE 9; control `anchor`'s dev start)

after/ under "dev", PostgreSQL and Redis up, MongoDB's address on 20577, where nothing listens (asserted first). The key is
`spring.mongodb.uri`, read off Boot 4.1.2's metadata — the same metadata lists `spring.data.mongodb.uri` as deprecated with it as the
replacement. The start stops: the JVM's exit, nothing on 20570, and the log's phrases counted — the shipped bean's name,
`DataAccessResourceFailureException`, `MongoTimeoutException`, `Application run failed`. Under the profile dev, Mongo is required:
without it TiffinBox does not start, and the log names the driver's exception. The driver's server-selection lines are never printed;
the capture's wall time is not printed either. Unit 14's absent Redis beside this one, in the brief's words (a plain block: a sentence, not a capture):

```
Redis's start stopped at once; this one stops once the driver gives up looking.
```

```text
-- after/ under the profile dev, PostgreSQL up (20571), Redis up (20572), MongoDB ABSENT - the address points at 20577, where nothing listens: 0
  the key's name, off Boot 4.1.2's metadata (spring-boot-mongodb-4.1.2.jar): spring.mongodb.uri · spring.data.mongodb.uri (deprecated, replacement spring.mongodb.uri)
  redis-cli FLUSHALL (the unit's Redis) -> OK
  a fresh database on c8u18-pg: u18absent (psql) · its URL in the config tree (0600, never printed)
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20572 --spring.mongodb.uri=mongodb://127.0.0.1:20577/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  the JVM's exit: 1 · GET /actuator/health on 20570 -> 000 · listening on 20570: 0
  the log's phrases, each counted: Error creating bean with name 'tiffinBoxServer' 2 · DataAccessResourceFailureException 1 · MongoTimeoutException 1 · Application run failed 1
  the bean the log names first: Error creating bean with name 'tiffinBoxServer' · the driver's server-selection lines: masked whole, never printed (the dur8 list)
```

### 7 · default — the default run builds no MongoClient (R.425, RE-MEASURE 12, 13; two labelled copies)

after/ with no profile, H2, Docker at nothing, MongoDB absent; `/actuator/beans` exposed for this run by one command-line override
(the beans read, not a harness): health, `/menu/day-19` (no bean, no route), `/dashboard`, no `menus` bean and no MongoClient bean, and
the log's lines naming 27017 or mongo. Beside it two labelled copies (`harness/variants.py`): `starteronly`, application.yaml without
the exclude — health DOWN on the default run, and the log names 27017 (Boot's MongoClient settings line, masked whole, and the driver's
monitor line); `healthkey`, without the exclude but with `management.health.mongodb.enabled: false` — health UP on the default run,
and the same lines naming 27017: the exercise's broken state. Refused, by this capture: "the default run never touches Mongo" said of
the health key alone would be false.

```text
-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), MongoDB absent; one JVM; /actuator/beans exposed for this run (a command-line override, the one beside the port):
$ cd .harness/run-h2 && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570 --management.endpoints.web.exposure.include=health,prometheus,beans
  GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
  GET /menu/day-19 -> 404 · GET /dashboard -> 200 · /actuator/beans: a bean named menus 0 · a MongoClient bean 0
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20570: 0
  its log: lines naming 27017 0 · lines naming mongo, any case 0 · of them, Boot's MongoClient settings line (its settings masked whole, the dur8 list) 0 and the driver's monitor line (Exception in monitor thread while connecting to server localhost, port 27017) 0
-- the labelled copy starteronly (harness/variants.py: after/ without application.yaml's exclude), the same run:
$ cd .harness/run-h2 && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../starteronly/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570 --management.endpoints.web.exposure.include=health,prometheus,beans
  GET /actuator/health -> 503 {"groups":["liveness","readiness"],"status":"DOWN"}
  GET /menu/day-19 -> 404 · GET /dashboard -> 200 · /actuator/beans: a bean named menus 0 · a MongoClient bean 2
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20570: 0
  its log: lines naming 27017 more than 0 · lines naming mongo, any case more than 0 · of them, Boot's MongoClient settings line (its settings masked whole, the dur8 list) one or more and the driver's monitor line (Exception in monitor thread while connecting to server localhost, port 27017) one or more
-- the labelled copy healthkey (harness/variants.py: after/ without the exclude, with management.health.mongodb.enabled: false), the same run:
$ cd .harness/run-h2 && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../healthkey/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570 --management.endpoints.web.exposure.include=health,prometheus,beans
  GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
  GET /menu/day-19 -> 404 · GET /dashboard -> 200 · /actuator/beans: a bean named menus 0 · a MongoClient bean 2
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20570: 0
  its log: lines naming 27017 more than 0 · lines naming mongo, any case more than 0 · of them, Boot's MongoClient settings line (its settings masked whole, the dur8 list) one or more and the driver's monitor line (Exception in monitor thread while connecting to server localhost, port 27017) one or more
-- the 18 under mvn -o package with Docker at nothing (anchor's tests, the same run's package log):
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

### 8 · twice — two dev starts in a row, the same documents; the copy without the reset (R.431)

after/ started twice under "dev" on the same MongoDB, nothing emptied between: the same count and the same `day-19` (its stored form's
md5) after each, one delete and one insert each time. Then the labelled copy `noreset` (`start()` without `menus.reset()`, the one
line printed as a diff), from an emptied collection (`deleteMany({})`, printed, never a drop): its first start fills; its second start's
`insertAll` meets the same ids and the store refuses it — `DuplicateKeyException` (E11000) and the start stops, the count unchanged.
The store answered with the refusal, not with a doubled count.

```text
-- two starts in a row of after/ under dev on the same MongoDB (nothing emptied between; a fresh PostgreSQL database and an emptied Redis each):
-- start 1:
  a fresh database on c8u18-pg: u18twice1 (psql) · its URL in the config tree (0600, never printed)
  redis-cli FLUSHALL (the unit's Redis) -> OK
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20572 --spring.mongodb.uri=mongodb://127.0.0.1:20573/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20570: 0
  its log: Command "delete" started 1 · Command "insert" started 1 · DuplicateKeyException 0 · E11000 0 · Application run failed 0
  mongosh (no network): countDocuments() 30 · day-19 as stored, its md5 18e392db20c1a62ff7f90a07b4f7a46f
-- start 2:
  a fresh database on c8u18-pg: u18twice2 (psql) · its URL in the config tree (0600, never printed)
  redis-cli FLUSHALL (the unit's Redis) -> OK
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20572 --spring.mongodb.uri=mongodb://127.0.0.1:20573/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20570: 0
  its log: Command "delete" started 1 · Command "insert" started 1 · DuplicateKeyException 0 · E11000 0 · Application run failed 0
  mongosh (no network): countDocuments() 30 · day-19 as stored, its md5 18e392db20c1a62ff7f90a07b4f7a46f
-- the labelled copy noreset (harness/variants.py: start() without menus.reset()), on an emptied collection:
  mongosh (no network): db.menu.deleteMany({}) -> deletedCount 30
-- the copy's start 1:
  a fresh database on c8u18-pg: u18twice1 (psql) · its URL in the config tree (0600, never printed)
  redis-cli FLUSHALL (the unit's Redis) -> OK
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../noreset/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20572 --spring.mongodb.uri=mongodb://127.0.0.1:20573/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20570: 0
  its log: Command "delete" started 0 · Command "insert" started 1 · DuplicateKeyException 0 · E11000 0 · Application run failed 0
  mongosh (no network): countDocuments() 30 · day-19 as stored, its md5 18e392db20c1a62ff7f90a07b4f7a46f
-- the copy's start 2:
  a fresh database on c8u18-pg: u18twice2 (psql) · its URL in the config tree (0600, never printed)
  redis-cli FLUSHALL (the unit's Redis) -> OK
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../noreset/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20572 --spring.mongodb.uri=mongodb://127.0.0.1:20573/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  the JVM stopped by itself: exit 1 · listening on 20570: 0
  its log: Command "delete" started 0 · Command "insert" started 1 · DuplicateKeyException 1 · E11000 3 · Application run failed 1
  mongosh (no network): countDocuments() 30 · day-19 as stored, its md5 18e392db20c1a62ff7f90a07b4f7a46f
```

### 9 · seven — the comparison set on before/ and after/ (R.363)

The default run on both trees' jars (H2; after/ on 20570, before/ on 20575 — §P's spare bound for before/, as units 13-17 did), the
seven requests of `../c5-unit11/curlset.sh`: the same answers, the md5 `../c7-unit31`'s receipt holds (`/menu` is not among the seven); and
Hibernate's schema script, byte for byte `xcheck.sql` (no JPA mapping moved).

```text
-- Hibernate's schema script over after/'s libraries without Flyway's jars (Course 7's probe.x.XMain, scripts.action=create, a file, never run):
$ cd .harness/run && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hcx:../lib-nofly/*" probe.x.XMain "${XA[@]}"
  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
-- the seven: before/'s jar, java -jar, H2 in memory (a fresh JVM), port 20575:
$ cd .harness/before && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20575
  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /menu/day-19 -> 404 · listens on: 127.0.0.1:20575
$ $CURLSET 20575 .harness/before/secrets/tiffinbox/shutdown-token
  GET /dashboard: 200
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20575 now: 0
-- the seven: after/'s jar, java -jar, H2 in memory (a fresh JVM), port 20570:
$ cd .harness/after && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20570
  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /menu/day-19 -> 404 · listens on: 127.0.0.1:20570
$ $CURLSET 20570 .harness/after/secrets/tiffinbox/shutdown-token
  GET /dashboard: 200
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20570 now: 0
  the seven, after/ against before/: lines that differ: 0
```

### 10 · exercise — run as written, in one shell, bash then zsh (R.196)

The brief's words, the line `wc -w` counts in the receipt's gate; no Docker, no MongoDB — the exercise is about the default run, which
keeps none. The broken copy of `application.yaml` (`exercise/application.yaml`: the health key, no exclude) and the solution (after/'s
own, the three-class exclude), each built offline from `.m2-demo` with `-pl tiffinbox-web -am`, started with no profile on H2: the
check is the log's count of lines naming 27017 beside health, never the exit.

```text
exercise/README.md's 9 lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:
the solution's line that differs:
  $ cp after/tiffinbox-web/src/main/resources/application.yaml "$EX/tb/tiffinbox-web/src/main/resources/application.yaml"
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
    built: 1 jar
    health: 200
    lines naming 27017 in the log: 2
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    health: 200
    lines naming 27017 in the log: 0
  the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20579 afterwards: 0 · java processes of the exercise: 0
in zsh (/bin/zsh -f) - the README's lines, the block's exit 0:
    built: 1 jar
    health: 200
    lines naming 27017 in the log: 2
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    health: 200
    lines naming 27017 in the log: 0
  the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20579 afterwards: 0 · java processes of the exercise: 0
```

## Which store, which profile, which tree

- **18/after, profile dev, PostgreSQL 18.6 (20571) + Redis 8.10.3 (20572) + MongoDB 8.3.17 (20573), Compose off:** `anchor`'s dev start,
  `absent` (MongoDB absent), `twice`'s two starts — TiffinBox's own routes, its start's lines, the driver's DEBUG lines.
- **18/after, profile dev, Boot's Compose support on the shipped `compose.yaml` (18881-18883):** `anchor`'s Compose window.
- **18/after, default run, H2, no Docker:** `default`'s first run, the seven (and before/'s), the exercise's solution.
- **The harness's (`probe.u18.H18`, after/'s classes, MongoDB 20573):** `document`'s `findById` and null id, `oneread`'s `findById`,
  `rename`'s refill and `updateMulti`. **The harness's PostgreSQL (20576):** `oneread`'s and `rename`'s four and three tables.
- **A labelled copy:** `default`'s `starteronly` and `healthkey`, `twice`'s `noreset`, the exercise's broken `application.yaml`.
- **The IT (MongoDB in Testcontainers' container, 127.0.0.1:20578):** `anchor`'s `MONGO IT` lines.

## Refused, named

- A volume for MongoDB in `compose.yaml` (⚑6): the start rebuilds the menu; a volume would keep only what the start removes.
- An exec of mongosh inside the mongod container, or Testcontainers' `.withReplicaSet()` (mongosh inside a networked container), or
  a Compose healthcheck that runs mongosh (R.422). The voice never claims mongosh is silent on a network or that its telemetry is
  switched off: the interface list is the witness; the session's own log line about telemetry is written with no network too, and is cited for nothing.
- The health key alone as the fix: `default`'s `healthkey` copy prints health UP and lines naming 27017.
- `mongo:8.0` (⚑3: a second pull, and unmeasured on this kernel).
- A Compose replica set (⚑6): no Mongo transaction ships; a replica set needs its initiate from somewhere.
- A menu named by the date ("today") — every capture reads `day-19`, a fixed id, no date (RED #9).
- A `dropCollection` in the fill, never (R.431): `reset()` deletes; `twice` and `document` empty by `deleteMany`.
- A number for the driver's wait before `absent`'s stop (the duration rule): never printed, never said.
- `management.health.mongo.enabled` (R.425): a dead name on Boot 4.1.2; never written.
- An adjective of time or cost, or a verdict, beside MongoDB or PostgreSQL (R.433): no time was measured; the numbers are counts.

## Call-backs, by title (R.224)

- Course 7's *What's Next: Not Everything Is a Relation* (`java7_series.TITLES["40"]`): the section's name, C8-15.
- Unit 14's *Redis Data Structures From Java*: the absent store's contrast (`../c8-unit14`, `absent`).
- The next two units, *Repositories, MongoTemplate and Aggregation* and *Transactions, Indexes and Embedding vs Referencing*: the
  hand-off below.

## The commands this unit adds

The viewer's mongosh, with no network, beside the Compose container (⚑4: by the image the Compose container runs, so a viewer whose
`mongo:8` pulled a newer digest still runs it):
`docker -H "$DH" run --rm --pull never --network none --volumes-from tiffinbox-dev-mongo-1 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 --entrypoint mongosh "$(docker -H "$DH" inspect -f '{{.Image}}' tiffinbox-dev-mongo-1)" --quiet 'mongodb://%2Fdata%2Fdb%2Fmongodb-27017.sock/tiffinbox' --eval 'printjson(db.menu.findOne({_id: "day-19"}))'`.

## The repository, and the network

**No network of any kind** but the final push: every build offline (`-o`, `.m2-demo` a copy of `_research/m2-seed-c8-s4/`, its file
count printed before and asserted after every build; `Downloaded from` counted, none), **no pull** (the three digests and the three
tags `compose.yaml` names asserted present before anything starts; a missing one stops the receipt with the pull printed, never run),
no fetch. mongosh runs only with no network. The Compose window's `up` pulled nothing: the tags were present on the course's digests,
and the images list is asserted unchanged at the end.

## The folders, the harness and the ports

`c8-unit18/` holds `README.md`, `receipts.sh`, `receipts.md5`, `xcheck.sql` (Course 7's capstone's, byte for byte), `before` (the
link), `after/` (the tree), `exercise/` (`README.md`, `SOLUTION.md`, `application.yaml` — the broken copy) and `harness/`:
`s818.py` (the prose gate), `chk18.py` (the checks), `tree18.py` (the pins), `variants.py` (`starteronly`, `healthkey`, `noreset` —
labelled copies of after/; the null id is a harness insert, `H18 nullid`, not a copy), `surefire.py` and `dur8.py` (unit 02's, byte
for byte), `logback.xml` (unit 07's), `pg4.sql` and `pg3.sql` (the harness's two PostgreSQL schemas), `src/probe/u18/H18.java` (the
harness JVM: the driver and a `MongoTemplate` over the unit's MongoDB, no Spring context, no web server) and `src/probe/x/XMain.java`
(Course 7's probe, for the schema script). Ports: 20570 TiffinBox after/ (and the copies) · 20571 the unit's PostgreSQL · 20572 the unit's Redis ·
20573 the unit's MongoDB (and the no-variable container's one failed start) · 20574 reserved (Elasticsearch, Part B — never bound) ·
20575 before/ for the seven · 20576 the harness's PostgreSQL · 20577 the absent store's address, asserted unbound · 20578 the IT's
MongoDB container (R.454's binding) · 20579 the exercise's TiffinBox (§P's spare, bound for the exercise: its port must differ from
the receipt's own). 18881-18883 only inside the Compose window. Every one free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masked in every capture: the folders and the home; Boot's `Started … in <t>`; Surefire's `Time elapsed`; Maven's `Total time`; the
repository scan's and the context's times; Testcontainers' `started in PT<t>S`; an ObjectId's hex (`ObjectId(<objectid>)`); pids.
**Never printed** (the dur8 list, cut at the source rather than masked): Boot's `MongoClient with metadata … created with settings …`
line (counted, its text never printed), the driver's server-selection lines and its exception's message, `system.profile`'s `millis`
and `ts`, mongod's `"t"` (the fatal line and the warning are printed field by field without it), the explain's time fields, Compose's
`Created`/`Started` lines. The hygiene check refuses any of them in any capture, and dur8 over the captures is 0.

## Interrupted

SIGINT, after the runs of record, alone, by a driver in the session's scratch folder: `receipts.sh` run with SIGINT at its default
(the perl reset, R.410, in the foreground's place), the signal sent when a named point is reached (read off the process table and
Docker's list, on a count), then what is left read. Each: exit 130, and nothing left.

```
mid-build (Maven building the trees):  kill -INT at 02:21:22 · the receipt's exit: 130
  left: java 0 · containers none of the unit's · tiffinbox-dev volumes/networks 0/0 · volumes 315 · images 9 · listeners 20570-20579 0 · 18881-18883 0 · .r-lock gone · partial captures 0
mid-verify (Surefire's fork running, the IT's MongoDB container up):  kill -INT at 02:23:04 · the receipt's exit: 130
  left: java 0 · containers none of the unit's (Testcontainers' removed by the trap) · tiffinbox-dev volumes/networks 0/0 · volumes 315 · images 9 · listeners 20570-20579 0 · 18881-18883 0 · .r-lock gone · partial captures 0
```

Not interrupted here, and so not claimed: mid-Compose-window, mid-harness, mid-fill, mid-TiffinBox on PostgreSQL, mid-`absent` — the same trap covers
them (it stops every JVM by its pid and its children, removes every container of the unit with its volumes, the Compose project and the
mongo service's two volumes by name), but no capture of those points was taken in this session's time. The two driver runs aimed at the
Compose window stopped earlier by themselves, on `image`'s own 3/3 check — the broken-pipe race above; the fix and the fourth run of
record followed, and the time left was spent on that run rather than on a third try at the window.

## The ledger rows this unit pays

- **C8-15** (Mongo half, byte-equal) — the section's name as Course 7's finale said it, and "not everything is a relation" measured by
  `oneread` and `rename` on one PostgreSQL schema (the four tables), the three-table tie beside it.
- **C8-14** — checked: this unit's title is the one Course 7's finale said (`java8_series.TITLES["18"]`, unchanged).

## RE-MEASURE — the plan's items this unit settles

- **1** — the exclude with dev's clear, under the real profile "dev": the MongoClient, `MongoTemplate` and the health indicator back,
  `/menu/day-19` 200, 3/3 (`anchor`).
- **2** — Boot's Compose support starting the shipped `mongo` service and handing TiffinBox its address: the start's lines, `/menu/day-19`
  200 (`anchor`'s window).
- **3** — what the project's `stop`, `down` and `down -v` leave of the mongo service's two anonymous volumes (`anchor`'s window; above).
- **4** — the shipped menu and its two numbers (above; `oneread`, `rename`).
- **8** — `MongoDatastoreIT` under `@ActiveProfiles("dev")`: the exclude cleared, no Compose in the test, the container tests one more (`anchor`).
- **9** — `absent`'s bean: `tiffinBoxServer` (`absent`).
- **12** — the default run's health, no Mongo lines, `/menu/day-19` 404, and the seven (`default`, `seven`).
- **13** — `mvn package` with Docker at nothing: the tests on H2 green, no line naming 27017 (`anchor`).
- **14** — the database named by the store on the shipped `compose.yaml`: `listDatabases` without `test`, the driver's line naming
  `tiffinbox` (`anchor`'s window).

## The anchor moved — the builders (R.211, R.331)

D1 changes six anchor files that earlier units' builders and receipts could name (`application.yaml`, `application-dev.yaml`,
`compose.yaml`, `TiffinBoxServer.java`, `tiffinbox-web/pom.xml`, `README.md`). The grep before the commit, over the seventeen shipped
builders (`_builders/s801.py`-`s817.py`): each names `c8-tiffinbox` only inside its "R.211 live compare" block, which diffs the live
anchor against its own pinned tree, prints a note when the anchor has moved on, and never stops (R.331: behind an existence check);
every capture each builder reads is a `c8-unitNN/` path pinned to its commit. `check_unit8.py`, `qa_java8.py` and `build_java8.py` name
`c8-tiffinbox` nowhere. The earlier receipts read their own frozen `after/` and `before/` copies or `git archive` of a pinned commit;
the ones that compare `after/` with `../c8-tiffinbox` print that the anchor has moved and go on. Nothing moves; no earlier unit
or builder is edited.

## U19 moves the anchor next

The next unit, *Repositories, MongoTemplate and Aggregation*: `OrderDocument` + `Revenue` + `OrderDocuments` under "dev", the start's
orders fill (a delete, then one document per placed order), the four totals grouped by the server beside `/kitchen`'s value, its IT
one more. Before this unit's script, the script stage's one tool line: `check_unit8.py`'s `DUR_SECTIONS = {1, 2, 3, 4}`.

## What differed from the brief

- **The IT's binding (the prompt's "Two things" (1)) — R.454's shape went in.** Testcontainers 2.0.5's default shape published the
  IT's MongoDB on every interface (0.0.0.0 and ::, three readings from inside the test, before the receipt); `MongoDatastoreIT` binds
  `127.0.0.1:20578` → 27017 (`withExposedPorts` + `withCreateContainerCmdModifier`), and the reading is taken twice on every run of
  record — the IT's own line (`getContainerInfo()`) and the receipt's `dk ps` poll while `verify` runs. The IT prints the address and
  the port.
- **The container lives in the IT, not in `MongoSlice`.** The prompt's list puts `@Container @ServiceConnection` in the slice's
  description; the anchor's form (`RedisDatastoreIT` holds its container, `RedisSlice` holds none) is kept: a `@Container` field is
  started by the JUnit extension of the test class that declares it, and a `@SpringBootConfiguration` class is not one. `MongoSlice`
  names the scan's package only, as the four slices do.
- **RE-MEASURE 4's menu is the menu's own** — three English dishes per meal type, one per day in turn; one price per meal type, VEG
  110, NON_VEG 160, VEGAN 130 (written in `MenuDay.java`), because `V2__seed.sql`'s two VEG customers pay two prices and no one price
  per meal type can be derived from it; seven distinct allergens; every vegan dish carries soy, so `rename` is soy → soya. The menu was
  designed so that `day-19`'s items carry four allergens in all (one row each on the four tables) — the shape the brief's title says;
  the numbers are read off the captures, never typed.
- **`MenuItem` is a nested record** (`MenuDay.MenuItem`), and it carries its meal type as a field, so the four tables' `menu_item` row
  and the document's item hold the same four values.
- **`/menu/{day}`'s 404 has no body** (`ResponseEntity.notFound()`), not a problem detail; the default run's `/menu/day-19` 404 is
  Spring MVC's (no route).
- **`document`'s Java witness is the harness's `findById`** (the prompt allowed it or `/menu/day-19`); `/menu/day-19`'s JSON is
  `anchor`'s, from the same start's store. The null-id document is the harness's insert into `menu` itself, removed by a `deleteMany`
  on the ObjectId type — not an emptied collection: the window needs the shipped days beside it, and the count is printed back.
- **`rename` starts and ends with the harness's refill** (`remove(new Query())` + `insertAll(MenuDay.forDays(30))`, labelled — the
  same list and the same calls the shipped start makes), so each of its three runs renames from soy and leaves soy behind.
- **`twice`'s copy answered with a refusal, not a doubled count:** with the ids the days, the copy's second start's `insertAll` meets
  existing ids — `DuplicateKeyException` (E11000), the start stops, exit 1, the count unchanged (the prompt allowed either answer).
- **`default` reads the beans through `/actuator/beans`,** exposed for that run by one command-line override; the shipped exposure
  list is unchanged.
- **`absent`'s key is `spring.mongodb.uri`** (Boot 4.1.2's metadata, printed: `spring.data.mongodb.uri` is deprecated there with it as
  the replacement).
- **The exercise needs no Docker and no MongoDB** and builds after/'s jar twice (broken, solved) from `.m2-demo`; its TiffinBox listens
  on 20579 (§P's spare, said why above). The broken file is `exercise/application.yaml`, and `chk18.py static` asserts it is after/'s
  with exactly the `healthkey` change.
- **The window's sequence is stop → `down` → `down -v` → the two anonymous volumes removed by name.** The count after `down -v`
  is not the baseline: a `down -v` run after a `down` leaves the mongo service's two anonymous volumes (their containers are gone), so
  the receipt reads their names off the container's `Mounts` while it exists and removes them; its trap does the same.
- **The unit's own PostgreSQL logs no statements** (`log_statement` stays off on 20571); only the harness's container on 20576 runs
  with `-c log_statement=all`. A fresh database per dev JVM by psql (`pgdb`) on 20571, not a `pgreset`; Redis `FLUSHALL`ed before
  each dev start, printed. The collection is reset by the start itself; `twice`'s copy empties it by `deleteMany({})`, printed.
- **The tests' command was not `-pl tiffinbox-web -am` alone with no profile flags** — `mvn verify` with `DOCKER_HOST` on the pinned
  socket, `TESTCONTAINERS_RYUK_DISABLED=true`, a receipt home for Testcontainers (as unit 17's).

## For RED

- `MenuDay`'s prices and dishes are the menu's own; the voice must say so ("the menu's own prices"), never "the customers' prices".
- The four-table row count equals the allergens on `day-19`'s items (each item's row repeated per allergen); `chk18 oneread` asserts
  the statement log's count and the joins against Java's own count of allergens, not a typed four.
- The healthkey copy's count of lines naming 27017 is two on this machine in every run (Boot's MongoClient settings line, never
  printed, and the driver's monitor line); a machine where the monitor logs again might print it more than once — the check is "more than 0".
- `system.profile`'s ops in `anchor` are counted before any route is called (the routes add `query` ops); `oneread`'s count is after
  its own reset.
- The Compose window ran three times per run of record (3/3); it is the receipt's only Compose run, and it is the only place 18881-18883
  are bound. Its `up` pulled nothing: the three tags were present on the course's digests (asserted before anything starts).
- Not measured here, and unsaid: `mongo:8.0` on this kernel; SERVER-121912's page; delivery of mongosh's logged telemetry; a Compose
  replica set; what a class rename does to `_class`.
- The other ITs (units 07-17's Postgres and Redis containers) still bind every interface (Testcontainers' default) — not touched here.
- `twice`'s copy is the only place the store refused a write; the shipped fill never meets an existing id (reset first).
- Planted here and caught (the list below), and not planted, so not claimed caught: a capture reading `/menu` with no day (no
  capture reads it; the route has no such mapping), a wrong published hash, a version claim without its line, a placeholder, a changed
  "What it prints" line, a `before` link to the wrong target — each has its gate in `receipts.sh` (the hash, the R.302 text-block check,
  the placeholder grep, the wib compare, the link's `readlink`), run on every run of record, not planted in this session.
- The three runs of record before the fix ran with a `| head -1` after a `dk run` (`mongod --version`), a race that made two runs after them
  stop on `image`'s 3/3 (*Runs of record*); the fourth run is on the committed script.

## Planted faults — each caught (R.65, R.226)

Run alone, after the three runs of record (2026-11-20 02:19 CET), by a driver in the session's scratch folder: each plant on a scratch
mirror of this folder (its prose, harness, `after/` and `exercise/` copied; nothing written into the unit), then the check that must
catch it; the controls first (each exits 0), then each plant alone (each exits 1), the mirror put back between them. Doctored
captures are Python edits of copies of the published captures.

```
-- controls (the shipped files): each check exits 0
control: the prose gate (s818)                             exit 0 (want 0)
control: chk18 static                                      exit 0 (want 0)
control: chk18 c815 (C8-15 byte for byte)                  exit 0 (want 0)
control: chk18 image on the published capture              exit 0 (want 0)
control: chk18 anchor on the published capture             exit 0 (want 0)
control: chk18 document on the published capture           exit 0 (want 0)
control: chk18 oneread on the published capture            exit 0 (want 0)
control: chk18 rename on the published capture             exit 0 (want 0)
control: chk18 absent on the published capture             exit 0 (want 0)
control: chk18 default on the published capture            exit 0 (want 0)
control: chk18 twice on the published capture              exit 0 (want 0)
-- plants (each alone, on the mirror, then the mirror put back): each check exits 1
"Mongo is faster here" in README.md (XFAM_S4)              caught - exit 1 (want 1)
"the start stops after thirty seconds" (the wait family)   caught - exit 1 (want 1)
"the default run never touches Mongo" for the health key alone caught - exit 1 (want 1)
todays menu in README.md (RED #9)                          caught - exit 1 (want 1)
C8-15's sentence off by one byte                           caught - exit 1 (want 1)
management.health.mongo.enabled in application.yaml        caught - exit 1 (want 1)
compose.yaml's mongo service without MONGO_INITDB_DATABASE caught - exit 1 (want 1)
compose.yaml's mongo service without GLIBC_TUNABLES        caught - exit 1 (want 1)
a dropCollection in Menus.reset()                          caught - exit 1 (want 1)
the IT with .withReplicaSet()                              caught - exit 1 (want 1)
the exercise's solution = broken (R.196)                   caught - exit 1 (want 1)
an Indian dish name in MenuDay                             caught - exit 1 (want 1)
rm -f without -v in receipts.sh (R.387)                    caught - exit 1 (want 1)
an exec of mongosh in the mongod container (R.422)         caught - exit 1 (want 1)
a MongoDB container without GLIBC_TUNABLES (R.421)         caught - exit 1 (want 1)
-- doctored captures (Python, on copies of the published captures): each check exits 1
oneread: query -> find in system.profile's op              caught - exit 1 (want 1)
rename: modified 30 -> 29                                  caught - exit 1 (want 1)
absent: the Error creating bean line's count -> 0          caught - exit 1 (want 1)
default: /menu/day-19 404 -> 200                           caught - exit 1 (want 1)
default: after/'s 27017 lines 0 -> 1                       caught - exit 1 (want 1)
anchor: listDatabases shows test                           caught - exit 1 (want 1)
anchor: the IT bound on 0.0.0.0                            caught - exit 1 (want 1)
image: volumes 315 after rm -> 317 (a removal without -v)  caught - exit 1 (want 1)
twice: the shipped two starts 30 and 60                    caught - exit 1 (want 1)
document: _class dropped from mongosh's keys               caught - exit 1 (want 1)
```

## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: broken: health 200, 27017 lines 2; solved: health 200, 27017 lines 0 · image: MongoDB 8.3.17 · volumes 315 -> 317 -> 315 · exit code 1 without the variable · images 9 · anchor: dev: /menu/day-19 200 (3 items) · /menu/day-31 404 · health 200 · 30 documents · tiffinbox, no test · 18 + 9 · libraries 122 -> 129 · Compose: stop +3, down +3, down -v +2 volumes · document: keys _id,items,_class · _id a String · _class com.tiffinbox.web.MenuDay · null id: ObjectId, 24 characters in Java · oneread: Mongo: 1 query op, 1 document, 3 items, 4 allergens (4 distinct) · four tables: 1 statement, 3 joins, 4 rows · three tables: 2 joins, 4 rows · rename: Mongo: 1 update op, 30 modified · four tables: UPDATE 1 · three tables: UPDATE 30 (the tie) · absent: dev, Mongo absent: exit 1 · 000 · Error creating bean with name 'tiffinBoxServer' · DataAccessResourceFailureException · MongoTimeoutException · default: default run: health 200 · /menu/day-19 404 · 27017 lines 0 · the starter alone 503 and lines naming 27017 · the health key alone 200 and lines naming 27017 · twice: two starts: 30 and 30, the same day-19 · the copy without the reset: the second start stops, DuplicateKeyException (E11000) · seven: the seven: md5 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/
<!-- values: end -->

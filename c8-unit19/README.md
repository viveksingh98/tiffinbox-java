# c8-unit19 — *Repositories, MongoTemplate and Aggregation*

Course 8, Section 4's second unit, and **Section 4's second change to the anchor (D2)**. `before` is a link to `../c8-unit18/after`
(the previous unit's tree; the receipt pins it and asserts that pin is that unit's own after-tree line); `after/` is this unit's tree, and
`../c8-tiffinbox` equals `after/` from this unit's commit on. Under the profile "dev" the start now copies the orders it places into a
MongoDB collection, `orders`, one document per order, and a new route, `GET /revenue/by-customer`, groups that copy on MongoDB's
server: **the same 120 orders, copied into Mongo, grouped by the server — 24300, as `/kitchen` prints** (RED #16's words; the numbers
are read off `anchor` and `pipeline` below). An aggregation pipeline is stages the server runs in order over a collection, each feeding
the next. PostgreSQL stays the system of record for the customers; the kitchen places the same orders as before; the collection is a
copy the start empties and refills at every start — never a fourth witness, the same orders the board and `/kitchen` already add up.

Every MongoDB number below comes from two witnesses in the same run (R.423, S8.63): **Java's answer** — TiffinBox's own
`GET /revenue/by-customer` under "dev", the harness's shipped repository and template (`probe.u19.H19`: `OrderDocuments.findByMealType`
through `MongoRepositoryFactory`, a criteria find, `MongoTemplate.aggregate`), or the IT's lines — and **mongosh's view**:
`system.profile` after a reset (the op names, `command.find`, `command.filter`, `command.pipeline`), the same pipeline run by mongosh,
`explain`, or `printjson` of a stored document. mongosh runs only in another container of the same digest with **no network**
(`--network none`, `--volumes-from` the mongod container, over mongod's unix socket; that container's interface list is printed, `lo`)
— never an exec into the mongod container (R.422). The database's name is printed by the store: `listDatabases` beside the driver's own
DEBUG line `Command "insert" started on database "tiffinbox"` (R.435), on the dev start and in the Compose window on the shipped
`compose.yaml`. MongoDB is **8.3.17, by the digest** (`mongo@sha256:05b334b0…c17cd`, `--pull never`, `127.0.0.1` only, no auth,
`-e GLIBC_TUNABLES=glibc.pthread.rseq=1`); PostgreSQL is 18.6 and Redis 8.10.3 by the course's digests. Every line names its tree, its
profile and its store (R.392): **19/after, profile dev, PostgreSQL + Redis + MongoDB** (`anchor`, `twice`'s two starts); **19/after,
default run, H2, no Docker** (`default`, the seven); **the harness's** (`finder`, `pipeline`, `field`, `silent` — over the orders the
dev start copied, on the unit's MongoDB; `field`'s and `silent`'s collection `orders_r` is the harness's copy); **a labelled
copy** (`twice`'s copy without the reset — `harness/variants.py noreset`).

Ten captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `exercise` and the
tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string below is asserted
after its capture by `harness/chk19.py` against a second witness of the same run. Evidence by a Claude Opus 5.5 agent on 2026-11-20,
started 03:33 CET.

## Runs of record

`./receipts.sh` (/bin/bash 3.2.57, 2026-11-20 from 04:23:03 CET, ended 04:30:21), `bash receipts.sh` (Homebrew bash 5.3.9, from
04:30:21, ended 04:38:15) and a sealed fresh clone (below, at `e9dd515`, from 04:38:32, ended 04:46:51): each with every capture =
published (the JVM ones 3/3 inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file count unchanged,
volumes back to their count and the images unchanged (nine images, the same 315 volumes at the start and the end of each), `before/`
and `after/` = their pins at the start and the end, nothing listening on the unit's ports at the end, each log ending with its
`c8-unit19:` line; each log through `check_unit8.py 19 --runlog` — `RESULT (run logs): PASS` (the unit gate itself has no script for
this unit yet, as expected). **Nothing was downloaded, nothing pulled.** Six runs before them shaped the receipt (a profile count that
depends on the store's history, a regex over the start's two-space log line, an unbalanced parenthesis in `explain`'s mongosh line, the
mask's word list in `explain`'s own header) and printed the hashes that went into `receipts.md5`; the planted faults ran alone before the
three runs of record, the interruptions after them.

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at this unit's commit (`e9dd515`, before the commit was
amended with these paragraphs) into a path **with a space** (`…/sealed 19/tiffinbox-java`, in the session's scratch folder), the clone's
`.m2-demo` a file copy of the seed (7,171 files), `env -i` with `HOME`, `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`
and `DOCKER_CONFIG=$HOME/.docker`; `./receipts.sh`. The runs ran on this README before its *Runs of record*, *Interrupted* and *Planted
faults* paragraphs were written; the prose gate, the text-block check and the values check were run again on the final README against
the last run's printed lines.

## D2 — the change, file by file, and every README/YAML/Javadoc/compose sentence it rewrote or noted (R.250)

Files new and changed (the receipt's own `diff -rq before/ after/`), nothing deleted; `pom.xml`, `tiffinbox-web/pom.xml`,
`application.yaml`, `application-dev.yaml`, `Menus.java` and `MenuDay.java` exactly as `c8-unit18` shipped them (`chk19 static` compares
each); no new artifact — Spring Data MongoDB 5.1.2, there since `c8-unit18`, holds `MongoRepository`, `MongoRepositoryFactory`,
`Aggregation`, `TypedAggregation` and `@EnableMongoRepositories` (the jar's own entries, printed):

- `tiffinbox-web/src/main/java/com/tiffinbox/web/OrderDocument.java` — **new**: `@Document("orders")`, a record: `@Id String id` (the
  kitchen order's id, `<Name>-<day>`, built by the same expression `KitchenOrder`'s is in `start()`), `String customer`, `String mealType`
  (the customer's own String — `Customer.mealType()` is one — stored as that String: `explain`'s and `finder`'s filter print
  `{"mealType":"VEG"}`), `int day`, `int value` (the placed order's: its meals times its price). No `@Indexed` (unit 20's). Named
  `OrderDocument`, never `KitchenOrder` (Redis's entity of the same order). A `Course 8, unit 19` Javadoc: a copy of the start's placed
  orders, PostgreSQL the system of record, why dev-only.
- `OrderDocuments.java` — **new**: `interface OrderDocuments extends MongoRepository<OrderDocument, String>` with
  `List<OrderDocument> findByMealType(String mealType)`. Its Javadoc says what `finder` measured: one `find`, filter `{mealType: …}`, the
  same find a criteria find sends.
- `Revenue.java` — **new**: `@RestController @Profile("dev")`, holding Boot's `MongoTemplate` — the orders side lives here, beside the
  route, in `Menus`' form (`reset()` = `remove(new Query(), OrderDocument.class)`, `fill()` = `insertAll`): one class owns one collection,
  as `Menus` owns `menu`. **`GET /revenue/by-customer`** answers `newAggregation(OrderDocument.class, group("customer").sum("value").as("total"),
  sort(DESC, "total"))` through `MongoTemplate.aggregate` into the nested record `Revenue.Total(@Id String customer, int total)` — the
  group's `_id` mapped to `customer` — as JSON. Typed on `OrderDocument` (the exercise's solved form). No `$match` stage (optional in the
  brief; the route groups every order). The sum is left to the receipt (`chk19.py` adds the totals beside `/kitchen`'s `ordersValue`).
- `TiffinBoxServer.java` — a fourth provider, **`ObjectProvider<Revenue>`** (a new bean rather than `Menus`' provider: `Menus` stays
  `c8-unit18`'s file, untouched); `start()` calls `reset()` once before the orders loop, keeps one `OrderDocument` per placed order inside
  the loop, and inserts them after it in one `insertAll` (`anchor`'s profile: one `remove`, one `insert` op, `ninserted` the count).
  Unguarded, in `start()` (⚑7/⚑8). A `Course 8, unit 19` paragraph after `c8-unit18`'s, in the class Javadoc and in `start()`'s.
- `src/test/java/slice/MongoSlice.java` — `@EnableMongoRepositories(basePackageClasses = OrderDocuments.class)` and a `Course 8, unit 19`
  paragraph (see *What differed*: the slice's own scan found no repository).
- `src/test/java/com/tiffinbox/web/MongoDatastoreIT.java` — a second test: `OrderDocuments` saves three orders, `findByMealType("VEG")`
  reads the two VEG ones back, the driver's collection reads `Ravi-1` raw (`_id` a String, `_class`, `mealType` the String). The move from
  `c8-unit18`'s verify count to this one's is this test alone (R.363/R.80): Surefire's reports, in `anchor`.
- `compose.yaml` — no service line changed; a `Course 8, unit 19` note in the `mongo` service's comment.
- The anchor README: its `Course 8 · unit 19` section.

The sentences D2 made incomplete, each rewritten or noted (`chk19 r250` asserts every one, on every run):

```text
ok R.250: README.md's unit 18 section, "18 + 9 since" - noted (Course 8, unit 19: 18 + 10)
ok R.250: README.md's unit 18 section, "MongoDB's alone, so nothing is written twice" - noted (the orders are, a copy)
ok R.250: README.md's unit 18 "What it does not" (/menu/day-19 404, health 200, no MongoClient) - kept, still true; unit 19's section adds /revenue/by-customer 404 and /revenue 200
ok R.250: compose.yaml's mongo note "the start fills the menu and without Mongo it stops" - kept (still true: the menu's fill comes first), a Course 8, unit 19 note beside it
ok R.250: compose.yaml's "MongoDB, the menu's store" - the note names the second collection, orders
ok R.250: TiffinBoxServer's unit 18 paragraphs (the menu, "nothing here touches MongoDB" on the default run) - kept, true; a unit 19 paragraph after each
ok R.250: MongoSlice's "it holds no repository and no document" - kept (the package still holds none), the unit 19 paragraph names the scan
ok R.250: MongoDatastoreIT's "Two witnesses in one test" - kept for its first test, a unit 19 paragraph for the second (18 + 10)
ok R.250: no quote of "Found 0 MongoDB repository interfaces" left in the anchor as a present fact
```

**R.211/R.331 — the builders.** D2 changes four anchor files an earlier builder or receipt could name (`TiffinBoxServer.java`,
`MongoDatastoreIT.java`, `compose.yaml`, `README.md`) and adds three. The grep before the commit, over the seventeen shipped builders
(`_builders/s801.py`-`s817.py`; this section's `s818.py` is not shipped yet): `TiffinBoxServer.java` is named by five of them and
`compose.yaml` by seven, `MongoDatastoreIT.java` and `MongoSlice.java` by none; each reads its unit's own `c8-unitNN/after` copy or
`git show <its pinned commit>:c8-tiffinbox/…`, and names the live `c8-tiffinbox` only inside its "R.211 live compare" block, behind an
existence check, a note and never a stop. Nothing moves; no earlier unit or builder is edited.

## RE-MEASURE 5 — the fill, the four totals and the sum beside `/kitchen` (settled first)

The fill on 19/after's shipped tree, dev, the unit's three containers: the factors read by the receipt (the customers in the fresh
database, `tiffinbox.days` in after/'s `application.yaml`), the start's own lines, the profiler's two ops on `tiffinbox.orders`, mongosh's
count and per-customer count, mongosh's pipeline, the route, `/kitchen` and the month's revenue — one run, `anchor`:

```text
    (x1) tiffinbox: kitchen value:  24300
    (x1) tiffinbox: orders cooked:  120
    op remove, the filter {}
    op insert, ninserted 120
  the factors (the receipt reads them): customers in the database 4 · tiffinbox.days in after/'s application.yaml 30
  mongosh: db.orders.countDocuments() -> 120 · per customer -> Meera 30 · Priya 30 · Ravi 30 · Sunil 30 · db.menu.countDocuments() -> 30
  mongosh: db.orders.aggregate([{$group: {_id: "$customer", total: {$sum: "$value"}}}, {$sort: {total: -1}}]) -> groups 4 · sorted by total, then _id: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · their sum 24300
  GET /revenue/by-customer -> 200 [{"customer":"Sunil","total":9000},{"customer":"Ravi","total":7200},{"customer":"Meera","total":4500},{"customer":"Priya","total":3600}]
  GET /revenue -> 200 {"monthRevenue":24300}
  GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300}
```

The four totals are each customer's meals × price × days off `V2__seed.sql` (`chk19` derives them from the file and compares; none is
typed), their sum is `/kitchen`'s `ordersValue` and the start's `kitchen value` line, and mongosh's pipeline over the stored copy gives the
same four. The probe's answer was the same four; nothing differed. Two starts in a row print the same count and the same route body
(`twice`). `GET /revenue` (the month's revenue, from the database, on every run) prints the same sum: a third route to the same number,
not a new one.

## RE-MEASURE 6 — strict mode's four modules, the lines as printed (settled first)

The dev start's repository lines, whole, the logger's prefix cut, each counted (`anchor`): four modules, each entering strict mode;
each finds one interface; JPA and Redis each print that they could not safely identify `OrderDocuments` (JDBC scans `com.tiffinbox.jdbc`
only, so it never sees it); MongoDB prints the same about Redis's `KitchenOrders`, and JPA about `KitchenOrders` and `CustomerAggregates`:

```text
  the start's repository lines, whole, as printed (each counted; the logger's prefix cut):
    (x1) Finished Spring Data repository scanning in <t>. Found 1 JDBC repository interface.
    (x1) Finished Spring Data repository scanning in <t>. Found 1 JPA repository interface.
    (x1) Finished Spring Data repository scanning in <t>. Found 1 MongoDB repository interface.
    (x1) Finished Spring Data repository scanning in <t>. Found 1 Redis repository interface.
    (x4) Multiple Spring Data modules found, entering strict repository configuration mode
    (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.jdbc.CustomerAggregates; If you want this repository to be a JPA repository, consider annotating your entities with one of these annotations: jakarta.persistence.Entity, jakarta.persistence.MappedSuperclass (preferred), or consider extending one of the following types with your repository: org.springframework.data.jpa.repository.JpaRepository
    (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders; If you want this repository to be a JPA repository, consider annotating your entities with one of these annotations: jakarta.persistence.Entity, jakarta.persistence.MappedSuperclass (preferred), or consider extending one of the following types with your repository: org.springframework.data.jpa.repository.JpaRepository
    (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments; If you want this repository to be a JPA repository, consider annotating your entities with one of these annotations: jakarta.persistence.Entity, jakarta.persistence.MappedSuperclass (preferred), or consider extending one of the following types with your repository: org.springframework.data.jpa.repository.JpaRepository
    (x1) Spring Data MongoDB - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders; If you want this repository to be a MongoDB repository, consider annotating your entities with one of these annotations: org.springframework.data.mongodb.core.mapping.Document (preferred), or consider extending one of the following types with your repository: org.springframework.data.mongodb.repository.MongoRepository
    (x1) Spring Data Redis - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments; If you want this repository to be a Redis repository, consider annotating your entities with one of these annotations: org.springframework.data.redis.core.RedisHash (preferred), or consider extending one of the following types with your repository: org.springframework.data.keyvalue.repository.KeyValueRepository
```

The test log's line, the slice's scan (`@DataMongoTest`, after `MongoSlice`'s `@EnableMongoRepositories`):

```text
  the verify log's MongoDB repository line (the slice's scan): (x1) Found 1 MongoDB repository interface
```

## The captures — what each one shows

### 1 · anchor — the tests, the libraries, the dev shape on three stores, and the Compose window (⚑8, S8.65, S8.71, S8.75; RE-MEASURE 5, 6, 12, 14)

The tests first: `mvn package` with Docker pointed at nothing, then `mvn verify` on the pinned socket — the IT's container on the
anchor's pinned binding (20578 asserted unbound before and after), its two tests' lines:

```text
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  the package log: lines naming 27017 0 · lines naming mongo (any case) 0
  before it: listening on 20578 (the anchor IT's pinned binding): 0
  the IT's MongoDB container while verify ran, Docker's own list (dk ps, polled on a count): Ports 127.0.0.1:20578->27017/tcp · its command "docker-entrypoint.sh mongod" · listening on 20578 after it: 0
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  Surefire's Results line: Tests run: 10, Failures: 0, Errors: 0, Skipped: 0
  MONGO IT orders, through OrderDocuments: count 3 · findByMealType("VEG") [Ravi-1, Sunil-1]
  MONGO IT Ravi-1, through the driver's collection: _id String · _class com.tiffinbox.web.OrderDocument · mealType VEG · value 240
  MONGO IT the container's port bindings (Docker's own record): [127.0.0.1:20578->27017/tcp]
  MONGO IT day-19, through Menus: items 3 · [Chickpea and tofu stew, Grilled chicken with rice, Vegetable curry with rice]
  MONGO IT the same document, through the driver's collection: _id String · _class com.tiffinbox.web.MenuDay · items 3 · documents in menu 1
  the verify log: 'Creating container for image' 4 · 'Pulling' 0 · lines naming docker compose 0 · Testcontainers containers after it: 0
```

The libraries (D2 adds none) and the version lines; the stored document, its keys and types; the database by the store:

```text
  before/: 129 libraries
  after/: 129 libraries
  gained: 0 · lost: 0
  the version lines off the jar names: mongodb-driver-sync-5.8.1.jar spring-boot-4.1.2.jar spring-data-jpa-4.1.2.jar spring-data-mongodb-5.1.2.jar spring-data-redis-4.1.2.jar
    (x1) HHH000001: Hibernate ORM core version 7.4.13.Final
    (x1) Database: jdbc:postgresql://<the unit's>/<db>?user=tiffinbox&password=******** (PostgreSQL 18.6)
    (x2) Command "insert" started on database "tiffinbox"
  the stores' own versions: mongosh db.version() 8.3.17 · redis-cli INFO server redis_version:8.10.3 · psql show server_version 18.6 · mongod --version, a container of the digest with no network: db version v8.3.17
  mongosh: printjson(db.orders.findOne({_id: "Ravi-19"})):
    {
      _id: 'Ravi-19',
      customer: 'Ravi',
      mealType: 'VEG',
      day: 19,
      value: 240,
      _class: 'com.tiffinbox.web.OrderDocument'
    }
  mongosh: its keys _id,customer,mealType,day,value,_class · typeof _id string · typeof mealType string · _class com.tiffinbox.web.OrderDocument
  mongosh: listDatabases -> admin,config,local,tiffinbox · that container's interfaces (its /proc/net/dev, read by mongosh): lo
```

`_class` is the type hint the mapper writes — the full class name; `_id` and `mealType` are Strings. The other routes under dev:

```text
  GET /menu/day-19 -> 200 {"id":"day-19","items":[{"mealType":"VEG","name":"Vegetable …
  GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
  GET /dashboard -> 200
```

**The Compose window (RE-MEASURE 14)** — after/ under dev with Boot's Docker Compose support on, the shipped `compose.yaml`, no
`spring.*` address key; the store names the database, the route answers the same four; then `c8-unit18`'s sequence (stop, `down`, `down -v`,
the mongo service's two anonymous volumes by the names its container listed), the count back to the window's start:

```text
  the project's containers: tiffinbox-dev-mongo-1 127.0.0.1:18883->27017/tcp|tiffinbox-dev-postgres-1 127.0.0.1:18881->5432/tcp|tiffinbox-dev-redis-1 127.0.0.1:18882->6379/tcp
  the mongo service's container: its Mounts: volume /data/configdb · volume /data/db · volumes now 321
  the start's lines: 2 Command "delete" started on database "tiffinbox"|2 Command "insert" started on database "tiffinbox"|1 tiffinbox: kitchen value:  24300|1 tiffinbox: orders cooked:  120
  GET /revenue/by-customer -> 200 [{"customer":"Sunil","total":9000},{"customer":"Ravi","total":7200},{"customer":"Meera","total":4500},{"customer":"Priya","total":3600}]
  mongosh (no network, --volumes-from tiffinbox-dev-mongo-1): listDatabases -> admin,config,local,tiffinbox · on tiffinbox: db.orders.countDocuments() -> 120 · db.menu.countDocuments() -> 30 · on test: orders -> 0
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20580: 0
  after TiffinBox stopped (Boot's own compose stop): the project's containers tiffinbox-dev-mongo-1 exited|tiffinbox-dev-postgres-1 exited|tiffinbox-dev-redis-1 exited · volumes 321
$ cd .harness/compose-run && docker -H "$DH" compose -p tiffinbox-dev down
  then: the project's containers 0 · its networks 0 · volumes 321 · tiffinbox-dev volumes by name: tiffinbox-dev_data · the mongo service's two: present present
$ cd .harness/compose-run && docker -H "$DH" compose -p tiffinbox-dev down -v
  then: volumes 320 · tiffinbox-dev volumes by name: 0 · the mongo service's two: present present
  the receipt removes the mongo service's two by the names its container listed (dk volume rm): volumes 318 = before the window · listening on 18881-18883: 0
```

RE-MEASURE 14's answer on this unit's tree: `tiffinbox`, no `test`, by `listDatabases` and the driver's line; `down -v` again leaves the
two anonymous volumes, removed by name. The window's `up` pulled nothing (the three tags asserted on the course's digests first).

### 2 · finder — a derived finder and a criteria find send the same find (S8.64; R.423)

The profiler reset by mongosh, then the harness's `OrderDocuments` — the shipped interface, through `MongoRepositoryFactory` over a
`MongoTemplate` on the unit's MongoDB, no Spring context (the factory Spring Data's own bean uses) — `findByMealType("VEG")` once, the
profile read; then a criteria find, `template.find(Query.query(Criteria.where("mealType").is("VEG")), OrderDocument.class)`, once, the
profile read again:

```text
  mongosh (no network): db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2) -> 1
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh19.port=20583 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u19.H19 finder
  PROBE finder: the harness's OrderDocuments (MongoRepositoryFactory over the template), findByMealType("VEG"), once -> 60 documents · per customer {Ravi=30, Sunil=30}
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  system.profile, mongosh (no network) - every op on tiffinbox.orders since the reset:
    ops 1
    op query · ns tiffinbox.orders · command find "orders" · filter {"mealType":"VEG"} · nreturned 60
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh19.port=20583 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u19.H19 criteria
  PROBE criteria: the harness's MongoTemplate.find(Query.query(Criteria.where("mealType").is("VEG")), OrderDocument.class), once -> 60 documents
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  system.profile again - every op on tiffinbox.orders since the reset:
    ops 2 · getmore ops 0
    op query · ns tiffinbox.orders · command find "orders" · filter {"mealType":"VEG"} · nreturned 60
    op query · ns tiffinbox.orders · command find "orders" · filter {"mealType":"VEG"} · nreturned 60
  mongosh: db.setProfilingLevel(0) -> 1
  the factors, mongosh: the customers whose orders are VEG, with their counts -> Ravi 30 · Sunil 30 · countDocuments({mealType: "VEG"}) -> 60
```

One `query` op for the derived finder, then two, the same `find` on `orders` with the same filter — the stored form of the meal type, a
String. The count is the VEG customers' days (mongosh's own count, last line; the factors off the documents' `customer` values). No
`getmore` op: the first batch held them all.

### 3 · pipeline — the hook: the four totals, grouped by the server (S8.63; RE-MEASURE 5)

The profiler reset, the harness's untyped pipeline on `orders` (`newAggregation(group("customer").sum("value").as("total"),
sort(DESC, "total"))`, `"orders"`, `Revenue.Total.class`) once; the stages as the template builds them and as the server received them
(`system.profile`'s `command.pipeline`; the server names the op `command`); mongosh's same stages:

```text
  mongosh (no network): db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2) -> 1
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh19.port=20583 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u19.H19 pipeline
  PROBE pipeline: the stages the template sends (toPipeline): {"$group": {"_id": "$customer", "total": {"$sum": "$value"}}}, {"$sort": {"total": -1}}
  PROBE pipeline: groups 4 · sorted by total, then _id: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · their sum 24300
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  system.profile, mongosh (no network) - every op on tiffinbox.orders since the reset, with the pipeline as the server received it:
    ops 1
    op command · ns tiffinbox.orders · command aggregate · pipeline [{"$group":{"_id":"$customer","total":{"$sum":"$value"}}},{"$sort":{"total":-1}}] · nreturned 4
  mongosh: db.setProfilingLevel(0) -> 1
  mongosh, the same stages: db.orders.aggregate([{$group: {_id: "$customer", total: {$sum: "$value"}}}, {$sort: {total: -1}}]) -> groups 4 · sorted by total, then _id: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · their sum 24300
```

The sum is compared with the same run's `/kitchen` `ordersValue` (`anchor`) by `chk19 pipeline`. The four totals are distinct, so
their order is the totals' own; every list of groups is still printed sorted by total, then `_id` (S8.69), and the order the server
returned is printed apart (below, *The server's order*).

### 4 · explain — every document read, no key (the fact unit 20 answers)

mongosh's `explain("executionStats")` of the plain pipeline and of the pipeline with a `$match` on the meal type; the plan's stage
names read off `stages[0].$cursor.queryPlanner.winningPlan` (the path printed), the counts off its `executionStats` (its times and its
memory never printed); the indexes:

```text
  db.orders.explain("executionStats").aggregate([{$group: …}, {$sort: {total: -1}}]) -> read at stages[0].$cursor · queryPlanner.winningPlan stages GROUP > COLLSCAN · executionStats: nReturned 4 · totalDocsExamined 120 · totalKeysExamined 0 · stages of the pipeline $cursor > $sort
  db.orders.explain("executionStats").aggregate([{$match: {mealType: "VEG"}}, {$group: …}, {$sort: {total: -1}}]) -> read at stages[0].$cursor · queryPlanner.winningPlan stages GROUP > COLLSCAN · executionStats: nReturned 2 · totalDocsExamined 120 · totalKeysExamined 0 · stages of the pipeline $cursor > $sort
  db.orders.getIndexes() -> ["_id_"] · db.orders.countDocuments() -> 120
```

The collection carries `_id`'s index alone; a `$match` on `mealType` still reads every document. Unit 20, *Transactions, Indexes and
Embedding vs Referencing*, is the next lesson; nothing of its numbers is promised here.

### 5 · field — `@Field("cust")`: the stored name, and the typed pipeline that maps it (S8.63, S8.70; the harness's copy)

The harness's copy (`probe.u19.OrderRenamed`: the shipped `OrderDocument`'s fields, `@Field("cust")` on `customer`, in its own
collection `orders_r` so the shipped `orders` stays as the start filled it), filled from `orders` through the template; mongosh's view;
the typed pipeline on the copy, and what the server received:

```text
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh19.port=20583 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u19.H19 copy
  PROBE copy: the harness's copy - orders read (findAll, OrderDocument) 120 · saved into orders_r as OrderRenamed (@Field("cust") on customer) -> count 120
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  mongosh (no network): printjson(db.orders_r.findOne({_id: "Ravi-19"})):
    {
      _id: 'Ravi-19',
      cust: 'Ravi',
      mealType: 'VEG',
      day: 19,
      value: 240,
      _class: 'probe.u19.OrderRenamed'
    }
  mongosh: its keys _id,cust,mealType,day,value,_class · the shipped orders' Ravi-19, its keys _id,customer,mealType,day,value,_class · db.orders_r.countDocuments() -> 120 · db.orders.countDocuments() -> 120
-- the typed pipeline on the copy (newAggregation(OrderRenamed.class, group("customer")…)):
  mongosh (no network): db.setProfilingLevel(0); db.system.profile.drop(); db.setProfilingLevel(2) -> 1
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh19.port=20583 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u19.H19 typedr
  PROBE typedr: groups 4 · sorted by total, then _id: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · their sum 24300
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  system.profile - the aggregate on tiffinbox.orders_r, the pipeline as the server received it:
    aggregate ops 1
    op command · ns tiffinbox.orders_r · pipeline [{"$group":{"_id":"$cust","total":{"$sum":"$value"}}},{"$sort":{"total":-1}}] · nreturned 4
  mongosh: db.setProfilingLevel(0) -> 1
```

### 6 · silent — zeros and a null group, no exception (the failure receipt, S8.69; R.396's negation with its controls from the same run)

(a) `$sum` over a String beside its control `sum("value")`; (b) the untyped pipeline on the harness's renamed copy beside its control,
the typed one; mongosh's same stages; the harness JVMs' exits and their logs' `Exception` lines:

```text
-- (a) $sum over a String - sum("mealType") - on the shipped orders, beside its control sum("value"), the harness's JVM:
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh19.port=20583 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u19.H19 summeal,pipeline
  PROBE summeal: the stages the template sends (toPipeline): {"$group": {"_id": "$customer", "total": {"$sum": "$mealType"}}}, {"$sort": {"total": -1}}
  PROBE summeal: groups 4 · sorted by total, then _id: Meera 0 · Priya 0 · Ravi 0 · Sunil 0 · their sum 0
  PROBE pipeline: the stages the template sends (toPipeline): {"$group": {"_id": "$customer", "total": {"$sum": "$value"}}}, {"$sort": {"total": -1}}
  PROBE pipeline: groups 4 · sorted by total, then _id: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · their sum 24300
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  mongosh, the same stage: db.orders.aggregate([{$group: {_id: "$customer", total: {$sum: "$mealType"}}}]) -> groups 4 · sorted by total, then _id: Meera 0 · Priya 0 · Ravi 0 · Sunil 0 · their sum 0 · typeof mealType string
-- (b) the untyped pipeline on the harness's renamed copy (orders_r, customer stored as cust), beside its control the typed one:
$ cd .harness/run-h && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Dlogback.configurationFile=…/harness/logback.xml -Dh19.port=20583 -cp "../hc:../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*" probe.u19.H19 copy,untypedr,typedr
  PROBE copy: the harness's copy - orders read (findAll, OrderDocument) 120 · saved into orders_r as OrderRenamed (@Field("cust") on customer) -> count 120
  PROBE untypedr: the stages the template sends (toPipeline): {"$group": {"_id": "$customer", "total": {"$sum": "$value"}}}, {"$sort": {"total": -1}}
  PROBE untypedr: groups 1 · sorted by total, then _id: null 24300 · their sum 24300
  PROBE typedr: groups 4 · sorted by total, then _id: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · their sum 24300
  its exit 0 · its log, every line but its PROBE lines: 0 · lines naming an Exception 0
  mongosh, the same stage on the copy: db.orders_r.aggregate([{$group: {_id: "$customer", total: {$sum: "$value"}}}]) -> [{"_id":null,"total":24300}] · documents in orders_r with a field customer 0 · with cust 120
```

(a) returns zeros, no error: `$sum` adds numbers and skips a String. (b) returns one group, `null`, holding every order's value: the
untyped pipeline sends `$customer` as written, no document of the copy has that field, and the server groups them all under the same
missing value. Both runs exit 0 with no `Exception` line; each control, in the same JVM, prints the four.

### 7 · twice — two dev starts in a row, the same copy; the copy without the reset (R.431, S8.71)

```text
-- two starts in a row of after/ under dev on the same MongoDB (nothing emptied between; a fresh PostgreSQL database and an emptied Redis each):
-- start 1:
  a fresh database on c8u19-pg: u19twice1 (psql) · its URL in the config tree (0600, never printed)
  redis-cli FLUSHALL (the unit's Redis) -> OK
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20580 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20582 --spring.mongodb.uri=mongodb://127.0.0.1:20583/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  GET /revenue/by-customer -> 200 · its body's md5 8b3f3fffddcafd480eaa4f6cf543985d · GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300}
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20580: 0
  its log: Command "delete" started 2 · Command "insert" started 2 · DuplicateKeyException 0 · E11000 0 · the duplicate id named:  · Application run failed 0
  mongosh (no network): orders countDocuments() 120 · menu countDocuments() 30 · Ravi-19 as stored, its md5 0e996e800ed8fce53dd4c4c9c118debb
-- start 2:
  a fresh database on c8u19-pg: u19twice2 (psql) · its URL in the config tree (0600, never printed)
  redis-cli FLUSHALL (the unit's Redis) -> OK
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20580 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20582 --spring.mongodb.uri=mongodb://127.0.0.1:20583/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  GET /revenue/by-customer -> 200 · its body's md5 8b3f3fffddcafd480eaa4f6cf543985d · GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300}
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20580: 0
  its log: Command "delete" started 2 · Command "insert" started 2 · DuplicateKeyException 0 · E11000 0 · the duplicate id named:  · Application run failed 0
  mongosh (no network): orders countDocuments() 120 · menu countDocuments() 30 · Ravi-19 as stored, its md5 0e996e800ed8fce53dd4c4c9c118debb
-- the labelled copy noreset (harness/variants.py: start() without copies.reset()), on an emptied collection:
  mongosh (no network): db.orders.deleteMany({}) -> deletedCount 120
-- the copy's start 1:
  a fresh database on c8u19-pg: u19twice1 (psql) · its URL in the config tree (0600, never printed)
  redis-cli FLUSHALL (the unit's Redis) -> OK
$ cd .harness/run-noreset && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../noreset/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20580 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20582 --spring.mongodb.uri=mongodb://127.0.0.1:20583/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  GET /revenue/by-customer -> 200 · its body's md5 8b3f3fffddcafd480eaa4f6cf543985d · GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300}
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20580: 0
  its log: Command "delete" started 1 · Command "insert" started 2 · DuplicateKeyException 0 · E11000 0 · the duplicate id named:  · Application run failed 0
  mongosh (no network): orders countDocuments() 120 · menu countDocuments() 30 · Ravi-19 as stored, its md5 0e996e800ed8fce53dd4c4c9c118debb
-- the copy's start 2:
  a fresh database on c8u19-pg: u19twice2 (psql) · its URL in the config tree (0600, never printed)
  redis-cli FLUSHALL (the unit's Redis) -> OK
$ cd .harness/run-noreset && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../noreset/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20580 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20582 --spring.mongodb.uri=mongodb://127.0.0.1:20583/tiffinbox --logging.level.org.mongodb.driver.protocol.command=DEBUG
  the JVM stopped by itself: exit 1 · listening on 20580: 0
  its log: Command "delete" started 1 · Command "insert" started 2 · DuplicateKeyException 1 · E11000 3 · the duplicate id named: E11000 duplicate key error collection: tiffinbox.orders index: _id_ dup key: { _id: "Meera-1" } · Application run failed 1
  mongosh (no network): orders countDocuments() 120 · menu countDocuments() 30 · Ravi-19 as stored, its md5 0e996e800ed8fce53dd4c4c9c118debb
```

Two starts of after/ leave the same count and the same route body (its md5). The labelled copy without the reset (`variants.py
noreset`, its diff printed by the receipt): its first start on an emptied collection copies the orders; its second start's `insertAll`
meets the ids already there — `DuplicateKeyException`, E11000 on `_id_`, the start stops, exit 1, the count unchanged. The fill resets
first, or the second start meets its own ids.

### 8 · default — the default run builds no MongoClient (S8.65; RE-MEASURE 12)

```text
-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), MongoDB absent; one JVM; /actuator/beans exposed for this run (a command-line override, the one beside the port):
$ cd .harness/run-h2 && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20580 --management.endpoints.web.exposure.include=health,prometheus,beans
  GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
  GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 {"monthRevenue":24300} · GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300} · GET /dashboard -> 200
  /actuator/beans: a bean named revenue 0 · orderDocuments 0 · menus 0 · a MongoClient bean 0 · tiffinBoxServer 1
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20580: 0
  its log: lines naming 27017 0 · lines naming mongo, any case 0 · its repository lines: Found 1 JPA repository interface|Found 1 JDBC repository interface · Could not safely identify 3
-- the 18 under mvn -o package with Docker at nothing (anchor's tests, the same run's package log):
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

No profile, H2, Docker pointed at nothing: health UP, `/revenue/by-customer` and `/menu/day-19` 404 (no bean), `/revenue` (the database's
month) and `/kitchen` answer, no `Revenue`, `OrderDocuments`, `Menus` or MongoClient bean, and no log line names 27017 or mongo.
`c8-unit18`'s sentence, re-measured: the default run builds no MongoClient. The beans are read through `/actuator/beans`, exposed for this
run by one command-line override.

### 9 · seven — the comparison set on before/ and after/ (R.363)

```text
$ cd .harness/run && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hcx:../lib-nofly/*" probe.x.XMain "${XA[@]}"
  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
-- the seven: before/'s jar, java -jar, H2 in memory (a fresh JVM), port 20585:
$ cd .harness/before && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20585
  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /revenue/by-customer -> 404 · listens on: 127.0.0.1:20585
$ $CURLSET 20585 .harness/before/secrets/tiffinbox/shutdown-token
  GET /revenue: /revenue    -> 200 application/json  {"monthRevenue":24300}
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20585 now: 0
-- the seven: after/'s jar, java -jar, H2 in memory (a fresh JVM), port 20580:
$ cd .harness/after && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20580
  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /revenue/by-customer -> 404 · listens on: 127.0.0.1:20580
$ $CURLSET 20580 .harness/after/secrets/tiffinbox/shutdown-token
  GET /revenue: /revenue    -> 200 application/json  {"monthRevenue":24300}
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20580 now: 0
  the seven, after/ against before/: lines that differ: 0
```

after/ on 20580, before/ on 20585 (§P's spare, bound for the seven because before/ and after/ run one after the other on their own
ports, as `c8-unit18` did). `GET /revenue/by-customer` is not among the seven; the seven's md5 is the one `c7-unit31` pinned, unchanged.

### 10 · exercise — run as written, in one shell, bash then zsh (R.196)

```text
exercise/README.md's 7 lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:
the solution's line that differs:
  $ sed 's/newAggregation(group(/newAggregation(OrderRenamed.class, group(/' exercise/RenamedRevenue.java > "$EX/RenamedRevenue.java"
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
    built: 1 jar
    orders saved: 120
    group null 24300
    groups: 1
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    orders saved: 120
    group Sunil 9000
    group Ravi 7200
    group Meera 4500
    group Priya 3600
    groups: 4
  the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20589 afterwards: 0 · the container c8u19-mongo-ex afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0
in zsh (/bin/zsh -f) - the README's lines, the block's exit 0:
    built: 1 jar
    orders saved: 120
    group null 24300
    groups: 1
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    orders saved: 120
    group Sunil 9000
    group Ravi 7200
    group Meera 4500
    group Priya 3600
    groups: 4
  the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20589 afterwards: 0 · the container c8u19-mongo-ex afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0
```

The exercise needs Docker and a MongoDB container — it is about a pipeline the server runs. The viewer's container is
`c8u19-mongo-ex` on 20589 (§P's spare: the unit's own MongoDB is on 20583, and the exercise runs before it starts), by the digest, with
the variable; the viewer's `docker -H "$DH" run` carries no `--pull never` (a viewer without the image pulls it; here the image was
present, and the images list is asserted unchanged). The program is `exercise/RenamedRevenue.java`, run by Java's source launcher on
after/'s jar and libraries (built offline from `.m2-demo`, `-pl tiffinbox-web -am`); it makes the orders from after/'s seed and
`tiffinbox.days`, read, never typed. The check is the groups printed — one `null` group broken, the four named groups solved, their sum
the broken group's total — never the exit. RE-MEASURE 10: settled on the harness-style copy of the shipped `OrderDocument`
(`RenamedRevenue.OrderRenamed`, the same five fields with `@Field("cust")`).

## The server's order of each list of groups (S8.69 — printed, never hashed, never asserted)

```
  pipeline run 1: pipeline: the order the server returned: Sunil Ravi Meera Priya
  pipeline run 2: pipeline: the order the server returned: Sunil Ravi Meera Priya
  pipeline run 3: pipeline: the order the server returned: Sunil Ravi Meera Priya
  field run 1: typedr: the order the server returned: Sunil Ravi Meera Priya
  field run 2: typedr: the order the server returned: Sunil Ravi Meera Priya
  field run 3: typedr: the order the server returned: Sunil Ravi Meera Priya
  silent run 1: summeal: the order the server returned: Priya Meera Ravi Sunil
  silent run 1: pipeline: the order the server returned: Sunil Ravi Meera Priya
  silent run 1: untypedr: the order the server returned: null
  silent run 1: typedr: the order the server returned: Sunil Ravi Meera Priya
  silent run 2: summeal: the order the server returned: Priya Meera Ravi Sunil
  silent run 2: pipeline: the order the server returned: Sunil Ravi Meera Priya
  silent run 2: untypedr: the order the server returned: null
  silent run 2: typedr: the order the server returned: Sunil Ravi Meera Priya
  silent run 3: summeal: the order the server returned: Priya Meera Ravi Sunil
  silent run 3: pipeline: the order the server returned: Sunil Ravi Meera Priya
  silent run 3: untypedr: the order the server returned: null
  silent run 3: typedr: the order the server returned: Sunil Ravi Meera Priya
field's typedr: the server's order the same across 3 runs
pipeline's pipeline: the server's order the same across 3 runs
silent's pipeline: the server's order the same across 3 runs
silent's summeal: the server's order the same across 3 runs
silent's typedr: the server's order the same across 3 runs
silent's untypedr: the server's order the same across 3 runs
```

One run of record's lines (the bash 3.2 run's); each run prints its own. In every run of this session the server returned
each list in the same order in all three runs — the zeros of `sum("mealType")` included, which tie: their order did not
move here, and nothing asserts it would not elsewhere.


## Which store, which profile, which tree

- **19/after, profile dev, PostgreSQL 18.6 (20581) + Redis 8.10.3 (20582) + MongoDB 8.3.17 (20583), Compose off:** `anchor`'s dev
  start, `twice`'s two starts — TiffinBox's own routes, its start's lines, the driver's DEBUG lines, mongosh on the same MongoDB.
- **19/after, profile dev, Boot's Compose support on the shipped `compose.yaml` (18881-18883):** `anchor`'s Compose window.
- **19/after, default run, H2, no Docker:** `default`, the seven (and before/'s).
- **The harness's (`probe.u19.H19`, after/'s classes, MongoDB 20583, over the orders `anchor`'s last start copied):** `finder`,
  `pipeline`, `silent` (a); **the harness's copy `orders_r`** (`probe.u19.OrderRenamed`): `field`, `silent` (b).
- **A labelled copy:** `twice`'s `noreset`; the exercise's broken `RenamedRevenue.java` (its own MongoDB, 20589).
- **The IT (MongoDB in Testcontainers' container, 127.0.0.1:20578):** `anchor`'s `MONGO IT` lines.

## Refused, named

- An index in this unit — no `@Indexed`, no `auto-index-creation` (unit 20's; the receipt greps after/ for them).
- A Mongo transaction manager: Boot makes none, and none ships; nothing here promises one.
- A `dropCollection` in the fill, never (R.431): `reset()` deletes; `twice`'s copy empties by `deleteMany`.
- An exec of mongosh inside the mongod container (R.422).
- A fourth witness, refused: the collection is a copy of the same orders, grouped by the server.
- A time for `explain`: its time and memory fields are never printed.
- The SQL family's per-row word for the finder: refused - a derived finder is one `find`, measured.
- A menu or an order named by the date ("today").
- `management.health.mongo.enabled` (R.425): never written.
- A sentence about mongosh's telemetry being switched off: the interface list is the witness.

## Call-backs, by title (R.224)

- `c8-unit18`'s *MongoDB: Documents, Not Rows*: the menu, the slice, the IT's binding and the Compose window's sequence.
- Unit 15's *Spring Data Redis Repositories*: `KitchenOrder`'s id, the same expression.
- The next unit, *Transactions, Indexes and Embedding vs Referencing*: the hand-off below.

## The commands this unit adds

The viewer's mongosh, with no network, beside the Compose container, reading the copy and its pipeline:
`docker -H "$DH" run --rm --pull never --network none --volumes-from tiffinbox-dev-mongo-1 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 --entrypoint mongosh "$(docker -H "$DH" inspect -f '{{.Image}}' tiffinbox-dev-mongo-1)" --quiet 'mongodb://%2Fdata%2Fdb%2Fmongodb-27017.sock/tiffinbox' --eval 'db.orders.aggregate([{$group: {_id: "$customer", total: {$sum: "$value"}}}, {$sort: {total: -1}}])'`.

## The repository, and the network

**No network of any kind** but the final push: every build offline (`-o`, `.m2-demo` a copy of `_research/m2-seed-c8-s4/`, its file
count printed before and asserted after every build; `Downloaded from` counted, none), **no pull** (the three digests and the three
tags `compose.yaml` names asserted present before anything starts), no fetch. mongosh runs only with no network. The images list and
the volume count are asserted unchanged at the end.

## The folders, the harness and the ports

`c8-unit19/` holds `README.md`, `receipts.sh`, `receipts.md5`, `xcheck.sql` (Course 7's capstone's, byte for byte), `before` (the
link), `after/` (the tree), `exercise/` (`README.md`, `SOLUTION.md`, `RenamedRevenue.java` — the broken program) and `harness/`:
`s819.py` (the prose gate: s818's blocks byte for byte, md5 asserted by `chk19 static`, plus this unit's own refused readings, XU19),
`chk19.py` (the checks), `tree19.py` (the pins), `variants.py` (`noreset`), `surefire.py`, `dur8.py` and `logback.xml` (the builders',
byte for byte), `src/probe/u19/H19.java` + `OrderRenamed.java` (the harness JVM) and `src/probe/x/XMain.java` (Course 7's schema probe).
Ports: 20580 TiffinBox after/ · 20581 the unit's PostgreSQL `c8u19-pg` · 20582 the unit's Redis `c8u19-redis` · 20583 the unit's MongoDB
`c8u19-mongo` · 20584 reserved, never bound · 20585 before/ for the seven · 20586-20588 never bound (the harness needs no PostgreSQL of
its own here) · 20589 the exercise's MongoDB `c8u19-mongo-ex` · 20578 the anchor IT's pinned binding · 18881-18883 only in the Compose
window.

## Masks, filters and hygiene — every one, declared

Masked in every capture: the folders and the home; Boot's start and the scan times, Surefire's and Maven's times, Testcontainers'
`started in`; an ObjectId's hex; pids. Cut whole: Boot's MongoClient settings line (counted, never printed); the driver's DEBUG lines
(only `Command "<op>" started on database "<db>"` is kept, counted); `explain`'s times and memory; `system.profile`'s `millis` and `ts`
(never read). The server's order of a list of groups is printed apart from the hashed captures (it may move: S8.69). The receipt
asserts no path, time, MongoDB time, ObjectId, log time, stack frame, raw port, token or password in any capture.

## Interrupted

SIGINT, after the three runs of record, alone, by a driver in the session's scratch folder: `receipts.sh` run with SIGINT at its default
(the perl reset, R.410, in the foreground's place), the signal sent when a named point is reached (read off the process table, the run's
own logs and Docker's list, on a count), then what is left read. Each: exit 130, and nothing left.

```
-- mid-build
at build: kill -INT 34228 (04:47:07)
the receipt's exit: 130
left: java 0 · containers  · tiffinbox-dev volumes/networks 0/0 · volumes 315 · images 9 · listeners 20578 20580-20589 0 · 18881-18883 0 · .r-lock gone · partial captures 0
partial captures: 0 · .r-lock: gone · captures unchanged: yes
-- mid-verify
at verify: kill -INT 34843 (04:48:42)
the receipt's exit: 130
left: java 0 · containers  · tiffinbox-dev volumes/networks 0/0 · volumes 315 · images 9 · listeners 20578 20580-20589 0 · 18881-18883 0 · .r-lock gone · partial captures 0
partial captures: 0 · .r-lock: gone · captures unchanged: yes
-- mid-compose
at compose: kill -INT 37693 (04:51:00)
the receipt's exit: 130
left: java 0 · containers  · tiffinbox-dev volumes/networks 0/0 · volumes 315 · images 9 · listeners 20578 20580-20589 0 · 18881-18883 0 · .r-lock gone · partial captures 0
partial captures: 0 · .r-lock: gone · captures unchanged: yes
-- mid-tbpg
at tbpg: kill -INT 41503 (04:53:08)
the receipt's exit: 130
left: java 0 · containers  · tiffinbox-dev volumes/networks 0/0 · volumes 315 · images 9 · listeners 20578 20580-20589 0 · 18881-18883 0 · .r-lock gone · partial captures 0
partial captures: 0 · .r-lock: gone · captures unchanged: yes
-- mid-fill
at fill: kill -INT 45067 (04:55:08)
the receipt's exit: 130
left: java 0 · containers  · tiffinbox-dev volumes/networks 0/0 · volumes 315 · images 9 · listeners 20578 20580-20589 0 · 18881-18883 0 · .r-lock gone · partial captures 0
partial captures: 0 · .r-lock: gone · captures unchanged: yes
-- mid-pipeline
at pipeline: kill -INT 48558 (04:58:59)
the receipt's exit: 130
left: java 0 · containers  · tiffinbox-dev volumes/networks 0/0 · volumes 315 · images 9 · listeners 20578 20580-20589 0 · 18881-18883 0 · .r-lock gone · partial captures 0
partial captures: 0 · .r-lock: gone · captures unchanged: yes
```

The points: mid-build (Maven building the trees); mid-verify (Surefire's fork running, the IT's MongoDB container up); mid-Compose-window
(Boot's `compose up` under way, the project's mongo container there - the trap ran `compose down -v` and removed the mongo service's
two volumes by name); mid-TiffinBox on PostgreSQL (`anchor`'s dev start answering, the copy inserted); mid-fill (the dev JVM up to its
first `delete`, the fills under way); mid-harness (the harness JVM running `pipeline`'s aggregation). Mid-verify was taken once, not
twice: the time went to the other five points.

## The ledger rows this unit pays

None. `c8-unit18` paid C8-15's Mongo half; this unit names no ledger row as paid.

## RE-MEASURE — the plan's items this unit settles

- **5** — the fill and the four totals on 19/after, beside `/kitchen` and the start's line; two starts the same: settled (above, `anchor`, `twice`).
- **6** — strict mode's lines with four modules: settled, quoted whole (above).
- **10** — the exercise's broken/solved pair on a copy of the shipped `OrderDocument`: settled (`exercise`).
- **12** — the seven and the default run: settled (`default`, `seven`).
- **14** — the database witness on the shipped `compose.yaml`: settled (`anchor`'s Compose window).

## U20 moves the anchor next

The next unit, *Transactions, Indexes and Embedding vs Referencing*: `@Indexed` on `OrderDocument.customer` and `auto-index-creation`
under dev, `explain` on the index this unit's capture lacks, the three transaction managers on the harness, its IT one more. Before
`c8-unit18`'s script, the script stage's one tool line: `check_unit8.py`'s `DUR_SECTIONS = {1, 2, 3, 4}`.

## What differed from the brief

- **The route is `GET /revenue/by-customer`, not `GET /revenue`.** `TiffinBoxServer` has served `GET /revenue` since before Course 8 (`c5-unit11/curlset.sh` requests it) — the
  month's revenue the database computes, `{"monthRevenue": …}` — on every run, and it is one of the seven comparison requests. A second
  `/revenue` mapping stopped the dev start (Spring MVC: *Ambiguous mapping*, measured on the first try in this session's scratch). The
  brief's default-run "`/revenue` 404" is therefore `/revenue/by-customer` 404 here, and `/revenue` answers 200 on both runs.
- **`@DataMongoTest` did not find `OrderDocuments`.** The prompt said the slice's scan finds it; measured in scratch before the change:
  `MongoSlice`'s `@AutoConfigurationPackage` scans `slice`, the test log said `Found 0 MongoDB repository interfaces` and the context
  failed (`NoSuchBeanDefinitionException`). `MongoSlice` gained `@EnableMongoRepositories(basePackageClasses = OrderDocuments.class)`;
  the test log then says `Found 1 MongoDB repository interface`.
- **`mealType` is a String** (the customer's own, as `KitchenOrder`'s), not the `MealType` enum; `findByMealType(String)`.
- **The orders side lives on `Revenue`** (a fourth `ObjectProvider`), not on `Menus`: `Menus` stays `c8-unit18`'s file.
- **The fill collects in the loop and inserts once after it** (`insertAll`): one `insert` op, its `ninserted` the count.
- **`Revenue`'s pipeline is typed** (`newAggregation(OrderDocument.class, …)`) and has no `$match`; the harness's `pipeline` capture runs
  the brief's untyped form on `"orders"` — both print the same four.
- **`Total` is `Revenue.Total(@Id String customer, int total)`**, the group's `_id` mapped to `customer`; the harness reads into it too.
- **No `absent` capture:** `c8-unit18`'s stands — under dev the menu's fill runs first and a start without MongoDB stops there
  (`../c8-unit18`, `absent`); R.396's control for it is `c8-unit18`'s.
- **The profile reading in `anchor` prints no `ndeleted`:** the first of the three runs deleted none (a fresh container), the next two
  deleted the last run's copy — a store's history, not the code's; the op and its empty filter are printed.
- **`explain` printed both shapes** (the plain group and with a `$match`): COLLSCAN both; the plan read at `stages[0].$cursor`.
- **`twice`'s copy answered with a refusal** (E11000 on `_id_`, the start stops), not a doubled count: the ids repeat at every start.
- **The exercise is a source-launched program on after/'s jar**, not its own `pom.xml`; its MongoDB is the viewer's container on 20589;
  its orders come from the seed file and `tiffinbox.days`, read by the program.
- **The libraries did not move** (before/'s and after/'s counts equal, gained 0, lost 0).
- **The unit's own PostgreSQL logs no statements; a fresh database per dev JVM by psql (`pgdb`);** Redis `FLUSHALL`ed before each dev
  start, printed. `TESTCONTAINERS_RYUK_DISABLED=true` and a receipt home for Testcontainers, as `c8-unit18`'s receipt.
- **RE-MEASURE 6's other modules:** the brief expected "could not safely identify" lines about `OrderDocuments` from JPA, JDBC and Redis.
  Measured: JPA's and Redis's. JDBC's scan starts at `com.tiffinbox.jdbc` (`TiffinBoxApp`'s `@EnableJdbcRepositories`), so it never sees
  `OrderDocuments`; it finds its own one interface, as before. Each line is quoted whole above.
- **No capture was dropped.** All ten ran 3/3 (the JVM ones inside each run; `exercise` and the tests across the runs), including
  `twice`'s copy, `field`, `explain`'s `$match` variant and the Compose window's volume sequence.
- **`finder`, `pipeline`, `explain` and `silent` (a) read the copy `anchor`'s last dev start wrote** (no harness fill of `orders`);
  `field` and `silent` (b) fill the harness's own `orders_r` from it, emptied first by a delete.
- **`default`'s `/kitchen` and `/revenue` on H2 print the same sum as dev's** — the same seed; the default run places the same orders.

## For RED

- `GET /revenue` and `GET /revenue/by-customer` print the same sum on purpose: the database's month and MongoDB's grouped copy of the
  same orders. A script must not say MongoDB computed the month's revenue.
- `finder`'s and `pipeline`'s numbers are over the copy `anchor`'s last dev start wrote; their first runs follow `anchor` in the same
  run of `receipts.sh`.
- `field` and `silent` (b) are the harness's copy (`orders_r`, `probe.u19.OrderRenamed`); the shipped `orders` never holds `cust`.
- The server's order for `$sum` over a String (four zeros, a tie) is printed per run in *The server's order*; nothing asserts it.
- Not measured here, and unsaid: an index, a transaction, a `$match` that uses an index, a `getmore` on a finder (none appeared), the
  order of the zeros on another machine.
- `RenamedRevenue.java` (the exercise) builds its orders from the seed file by a regular expression over its `INSERT` lines and
  `tiffinbox.days` from `application.yaml`; a seed with another column order would break it, loudly (no order, no group).
- The exercise's `docker -H "$DH" run` has no `--pull never` on purpose (a viewer may need the pull); the receipt asserts the images list
  unchanged after it.
- The strict-mode lines are counted per run of the JVM; each module prints its "Multiple Spring Data modules found" line once.

## Planted faults — each caught (R.65, R.226)

Run alone, before the three runs of record (2026-11-20 04:13 CET), by a driver in the session's scratch folder: each plant on a scratch
mirror of this folder (its prose, harness, `after/`, `exercise/` and `receipts.sh` copied; nothing written into the unit), then the
check that must catch it; the controls first (each exits 0), then each plant alone (each exits 1), the mirror put back between them.
Doctored captures are Python edits of copies of the published captures.

```
-- controls (the shipped files): each check exits 0
control: the prose gate (s819)                                 exit 0 (want 0)
control: chk19 static                                          exit 0 (want 0)
control: chk19 r250                                            exit 0 (want 0)
control: the before link                                       exit 0 (want 0)
control: the values line in README.md                          exit 0 (want 0)
control: chk19 anchor on the published capture                 exit 0 (want 0)
control: chk19 finder on the published capture                 exit 0 (want 0)
control: chk19 pipeline on the published capture               exit 0 (want 0)
control: chk19 explain on the published capture                exit 0 (want 0)
control: chk19 field on the published capture                  exit 0 (want 0)
control: chk19 silent on the published capture                 exit 0 (want 0)
control: chk19 twice on the published capture                  exit 0 (want 0)
control: chk19 default on the published capture                exit 0 (want 0)
control: chk19 seven on the published capture                  exit 0 (want 0)
control: chk19 exercise on the published capture               exit 0 (want 0)
-- plants (each alone, on the mirror, then the mirror put back): each check exits 1
"the pipeline sums any field" in README.md (XU19; silent's zeros) caught - exit 1 (want 1)
"N+1" for the derived finder (XFAM_S4 / XU19)                  caught - exit 1 (want 1)
"a fourth witness" (RED #16)                                   caught - exit 1 (want 1)
"Mongo is faster here" (XFAM_S4)                               caught - exit 1 (want 1)
the untyped renamed group called the four (exercise SOLUTION = broken, R.196) caught - exit 1 (want 1)
the exercise's broken file made typed (no longer the broken state) caught - exit 1 (want 1)
the fill without the reset (TiffinBoxServer)                   caught - exit 1 (want 1)
a dropCollection in Revenue.reset() (R.431)                    caught - exit 1 (want 1)
an @Indexed on OrderDocument.customer (unit 20's)              caught - exit 1 (want 1)
an R.250 sentence left (the 18 + 9 note removed)               caught - exit 1 (want 1)
an Indian dish name in README.md                               caught - exit 1 (want 1)
a placeholder in README.md                                     caught - exit 1 (want 1)
a changed What-it-prints line (exercise/README.md)             caught - exit 1 (want 1)
a before link to the wrong target                              caught - exit 1 (want 1)
rm -f without -v in receipts.sh (R.387)                        caught - exit 1 (want 1)
the docker CLI unpinned in receipts.sh (R.344)                 caught - exit 1 (want 1)
an exec of mongosh in the mongod container (R.422)             caught - exit 1 (want 1)
a values line off by one number                                caught - exit 1 (want 1)
-- doctored captures (Python, on copies of the published captures): each check exits 1
finder: 60 -> 59                                               caught - exit 1 (want 1)
finder: query -> find in system.profile's op                   caught - exit 1 (want 1)
pipeline: 24300 -> 24000                                       caught - exit 1 (want 1)
silent: null -> Ravi                                           caught - exit 1 (want 1)
silent: a zero -> 120 (sum(mealType) called green)             caught - exit 1 (want 1)
explain: COLLSCAN -> IXSCAN                                    caught - exit 1 (want 1)
twice: 120 -> 240 on the second start                          caught - exit 1 (want 1)
anchor: listDatabases test -> tiffinbox reading (test shown)   caught - exit 1 (want 1)
anchor: the Found 1 MongoDB repository interface line deleted  caught - exit 1 (want 1)
default: /revenue/by-customer 404 -> 200                       caught - exit 1 (want 1)
default: 27017 lines 0 -> 1                                    caught - exit 1 (want 1)
```

Not planted, so not claimed caught: a wrong published hash and a version claim without its line - their gates (`pub`'s compare,
`chk19 anchor`'s version lines) run on every run of record.

## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: broken: one group, null 24300; solved: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · anchor: tests 18 + 10 (package 18); Ports 127.0.0.1:20578->27017/tcp; Found 1 MongoDB repository interface (dev and the slice); could not safely identify OrderDocuments: JPA, Redis; countDocuments 120 = 4 customers x 30 days; revenue/by-customer Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600, sum 24300 = ordersValue = kitchen value; menu 30; listDatabases tiffinbox, no test; Compose window the same four, volumes back to 318 · finder: findByMealType(VEG) 60 (Ravi + Sunil x 30 days), 1 query op filter {mealType: VEG}; criteria find 60, 2 query ops the same filter; getmore 0 · pipeline: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600, sum 24300 = ordersValue; 1 command op (aggregate) with $group/$sort as sent; mongosh the same four · explain: COLLSCAN, totalDocsExamined 120, totalKeysExamined 0 (both); getIndexes ["_id_"] · field: the harness's copy stores cust; the typed pipeline sends $cust and answers the four · silent: sum(mealType): every total 0 beside sum(value)'s four; untyped on the renamed copy: one group null 24300 beside the typed four; exit 0, 0 Exception lines · twice: 120 / 120, the same /revenue/by-customer; the copy without the reset: the second start stops, E11000 on Meera-1, exit 1, count 120 · default: health 200, /revenue/by-customer 404, /menu/day-19 404, /revenue 200 monthRevenue 24300, ordersValue 24300, 0 lines naming 27017 or mongo, no Revenue/OrderDocuments bean · seven: the seven: md5 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/
<!-- values: end -->

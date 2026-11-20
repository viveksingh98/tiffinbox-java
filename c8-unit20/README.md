# c8-unit20 — *Mongo Transactions, Indexes and Schema Design*

Course 8, Section 4's third unit, and **Section 4's third change to the anchor (D3) — the last of Part A, MongoDB**. `before` is a link
to `../c8-unit19/after` (the previous unit's tree; the receipt pins it and asserts that pin is that unit's own after-tree line);
`after/` is this unit's tree, and `../c8-tiffinbox` equals `after/` from this unit's commit on. D3 is small: under the profile "dev",
`OrderDocument`'s `customer` carries `@Indexed`, and `application-dev.yaml` sets the key that lets the mapper create what that
annotation asks for, `spring.data.mongodb.auto-index-creation`. The anchor gains **the index, not a transaction**: no transaction
manager, no replica set and no reference between documents ship in it (⚑9). Those are measured in this unit's **harness**, on this
receipt's own containers, and every line that reports them says so.

A replica set is several mongod processes holding the same data, one of them the primary that takes the writes. This unit runs a
single-node one, its own container, for the harness alone.

Every MongoDB number below comes from two witnesses in the same run (R.423, S8.63): **Java's answer** — TiffinBox's routes under "dev",
the IT's lines, the harness's counts, ids and exceptions (`probe.u20.H20`), the mapper's own `IndexOperations.getIndexInfo()`, the
driver's `ClusterDescription` — and **mongosh's view**: `getIndexes`, `explain("executionStats")`, `system.profile` after a reset (the op
names and namespaces), `db.hello()`, `rs.status()` and the stored documents. mongosh runs only in another container of the same digest
with **no network** (`--network none`, `--volumes-from` the mongod container it reads, over that mongod's unix socket; that container's
interface list is printed, `lo`) — never an exec into a mongod container (R.422). Two mongods run in this receipt — the unit's
standalone `c8u20-mongo` and the harness's replica set `c8u20-mongo-rs` — and every mongosh line names the one it reads. MongoDB is
**8.3.17, by the digest** (`mongo@sha256:05b334b0…c17cd`, `--pull never`, `127.0.0.1` only, no auth, `-e
GLIBC_TUNABLES=glibc.pthread.rseq=1`); PostgreSQL is 18.6 and Redis 8.10.3 by the course's digests. Every line names its tree, its
profile and its store (R.392): **20/after, profile dev, PostgreSQL + Redis + MongoDB** (`anchor`, `index`); **a copy with the key
unset** (`noindex`, `harness/variants.py nokey`); **20/after, default run, H2, no Docker** (`default`, the seven); **the harness's**
(`tx`, `notone`, `advertised`, `unique`, `shapes` — its own collections, never TiffinBox's `orders`).

Eleven captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `exercise` and the
tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string below is asserted
after its capture by `harness/chk20.py` against a second witness of the same run. Evidence by a Claude Opus 5.5 agent on 2026-11-20,
started 06:36 CET.

## Runs of record

`./receipts.sh` (/bin/bash 3.2.57, 2026-11-20 from 07:46:50 CET, ended 07:56:56), `bash receipts.sh` (Homebrew bash 5.3.9, from 07:57:16,
ended 08:08:36) and a sealed fresh clone (below, from 08:08:43, ended 08:20:42), and after the trap's fix below one more
`./receipts.sh` (2026-11-20 from 08:37:03 CET, ended 08:53:22) on the fixed receipt — the one committed: each with every capture = published (the JVM ones 3/3
inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file count unchanged, the volume count and the images
unchanged from start to end, `before/` and `after/` = their pins at the start and the end, nothing listening on the unit's ports at the
end, each log ending with its `c8-unit20:` line; each log through `check_unit8.py 20 --runlog` — `RESULT (run logs): PASS` (the unit
gate itself has no script for this unit yet, as expected). **Nothing was downloaded, nothing pulled.** Seven trial runs before them
shaped the receipt and printed the hashes in `receipts.md5` (what each changed is under *What differed*); the planted faults ran alone
after the three runs of record, the interruptions after them.

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at this unit's commit (before the commit was amended
with these paragraphs) into a path **with a space** (`…/sealed 20/tiffinbox-java`, in the session's scratch folder), the clone's
`.m2-demo` a file copy of the seed, `env -i` with `HOME`, `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin` and
`DOCKER_CONFIG=$HOME/.docker`; `./receipts.sh`. The runs ran on this README before its *Runs of record*, *Interrupted* and *Planted
faults* paragraphs were written; the prose gate, the text-block check and the values check were run again on the final README.

## D3 — the change, file by file, and every README/YAML/Javadoc/compose sentence it rewrote or noted (R.250)

Files changed (the receipt's own `diff -rq before/ after/`), nothing new, nothing deleted; `pom.xml`, `tiffinbox-web/pom.xml`,
`application.yaml`, `OrderDocuments.java`, `Revenue.java`, `TiffinBoxServer.java`, `Menus.java`, `MenuDay.java` and `MongoSlice.java`
exactly as `c8-unit19` shipped them (`chk20 static` compares each); no new artifact — Spring Data MongoDB 5.1.2, there since
`c8-unit18`, holds `@Indexed` and `IndexOperations` (and the harness's `MongoTransactionManager`, `@DocumentReference` and `@DBRef`; the
jar's own entries, printed):

- `tiffinbox-web/src/main/java/com/tiffinbox/web/OrderDocument.java` — `@Indexed` on the record's `customer`
  (`org.springframework.data.mongodb.core.index.Indexed`; not unique — the four customers share the orders). Its Javadoc's sentence
  "No index but the one on _id: unit 20 measures what a query on customer reads without one" is rewritten (the index on `customer`
  since), and a `Course 8, unit 20` paragraph says the shape, not the numbers: the annotation asks and creates nothing by itself; the key
  in `application-dev.yaml` lets the mapper create it at the start, named after the field; without it a find on one customer reads every
  document, with it only that customer's; the start's reset deletes and keeps the index, a drop would take it.
- `tiffinbox-web/src/main/resources/application-dev.yaml` — **`spring.data.mongodb.auto-index-creation: true`** under the profile's
  `spring:`, with a `Course 8, unit 20` comment in the file's voice. The name is read, not typed: Boot's own metadata entry for it, printed
  in `anchor` (a dead key name would be silent — R.436's class).
- `tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java` — a third test: three orders saved through `OrderDocuments`, the
  mapper's `IndexOperations.getIndexInfo()` names the index on `customer` (the mapper's witness) and the driver's `explain` command,
  through `template.getDb().runCommand`, on a find of one customer shows `IXSCAN` (the store's witness) — two witnesses in one test,
  printed with the `MONGO IT` prefix. The container stays the standalone with R.454's binding (no `.withReplicaSet()`, no `--replSet` —
  S8.62, ⚑10): this test is the index, not a transaction. The move of the verify count is this test alone (R.363/R.80).
- `compose.yaml` — no service line changed; the `mongo` service's standalone note stays (still true) and gains a `Course 8, unit 20` one:
  still a standalone, the harness's transactions ran on a replica set of their own, TiffinBox ships none.
- The anchor README: its `Course 8 · unit 20` section, with Part A's closing paragraph (what Section 4's MongoDB now holds, and that
  Part B changes the folder next), and two notes beside the previous unit's sentences.

`TiffinBoxServer.java` needs no unit 20 paragraph: D3 does not touch it (the fill's delete, the previous unit's, is what keeps the index).

The sentences D3 made false or incomplete, each rewritten or noted (`chk20 r250` asserts every one, on every run):

```text
ok R.250: OrderDocument's Javadoc "No index but the one on _id: unit 20 measures what a query on customer reads without one" - rewritten (the index on customer since)
ok R.250: README.md's unit 19 section, "No index but `_id`'s" - noted (Course 8, unit 20: and one on `customer` since)
ok R.250: README.md's unit 19 section, "`mvn verify` runs 18 + 10" - noted (Course 8, unit 20: 18 + 11)
ok R.250: MongoDatastoreIT's "18 + 10 under mvn verify" - noted beside it (18 + 11)
ok R.250: compose.yaml's "A standalone server, not a replica set: TiffinBox ships no MongoDB transaction" - kept (still true), a unit 20 note beside it
ok R.250: README.md's unit 18 section, "18 + 9 since" - unit 19's note kept; its 18 + 10 is now noted in unit 19's section
ok R.250: no anchor sentence states getIndexes ["_id_"] or COLLSCAN as the orders' present state
ok R.250: Revenue's Javadoc "the collection and its indexes stay" (reset, a delete) and "a drop would take the collection's indexes with it" - kept: unit 20 measures both (index's second start; the brief's m8.js for the drop)
```

**R.211/R.331 — the builders.** D3 changes five anchor files an earlier builder could name. The grep before the commit, over the
seventeen shipped builders (`_builders/s801.py`-`s817.py`; Section 4's are not shipped yet): `application-dev.yaml` and `compose.yaml`
are each named by seven of them (`s811`-`s817`), `OrderDocument.java` and `MongoDatastoreIT.java` by none, the anchor `README.md` as a
path of the unit's own copy; each reads its unit's own `c8-unitNN/after` copy or `git show <its pinned commit>:c8-tiffinbox/…`, and names
the live `c8-tiffinbox` only inside its "R.211 live compare" block, a note, never a stop. Nothing moves; no earlier unit or builder is
edited.

## RE-MEASURE 11 — the three managers, the manager named as run (settled first)

The probe ran its non-Mongo manager as a JDBC one over an in-memory H2 — a sketch. This receipt runs **`JpaTransactionManager` over the
unit's PostgreSQL** (its own database, `u20txjpa`, made by psql), TiffinBox's own kind of manager. The context is the cheapest honest
shape, and it is said: **a plain Spring context** (`AnnotationConfigApplicationContext`) — a `DriverManagerDataSource` with the URL read
from a 0600 file, a `LocalContainerEntityManagerFactoryBean` with Hibernate (no entity: none was needed for the manager), the
`JpaTransactionManager` over it, `@EnableTransactionManagement`, a `MongoTemplate` over the unit's standalone, and the harness's one
`@Transactional` method: it inserts `{_id: "a"}` into its own collection `tx_docs`, then throws the harness's planted
`IllegalStateException`, before it would insert `{_id: "b"}`. The manager's class is read off the context at run time
(`getBeansOfType(PlatformTransactionManager.class)`), never asserted from the code. **One manager per JVM**: a context holding JPA's
manager and Mongo's together is Part B's question (unit 24 — which one `@Transactional` gets), never run here. The same method, three
JVM launches, each 3/3:

```text
-- tx jpa (MongoDB on c8u20-mongo, the unit's standalone):
PROBE the context's PlatformTransactionManager beans (getBeansOfType), 1: transactionManager = org.springframework.orm.jpa.JpaTransactionManager
PROBE inside the @Transactional method: a transaction active (TransactionSynchronizationManager.isActualTransactionActive) true · resources bound to the thread: DriverManagerDataSource, the EntityManagerFactory
PROBE the exception: java.lang.IllegalStateException: PLANTED between the two writes
PROBE tx_docs after the call (the harness's count): count 1 · ids [a]
mongosh (--volumes-from c8u20-mongo): db.tx_docs.find().toArray() -> the stored _ids ["a"] · countDocuments 1
-- tx mongo-standalone (MongoDB on c8u20-mongo, the unit's standalone):
PROBE the context's PlatformTransactionManager beans (getBeansOfType), 1: transactionManager = org.springframework.data.mongodb.MongoTransactionManager
PROBE inside the @Transactional method: a transaction active (TransactionSynchronizationManager.isActualTransactionActive) true · resources bound to the thread: SimpleMongoClientDatabaseFactory
PROBE the exception: org.springframework.data.mongodb.UncategorizedMongoDbException: This MongoDB deployment does not support retryable writes. Please add retryWrites=false to your connection string.
PROBE   caused by: com.mongodb.MongoClientException: This MongoDB deployment does not support retryable writes. Please add retryWrites=false to your connection string.
PROBE   caused by: com.mongodb.MongoCommandException: Command execution failed on MongoDB server with error 20 (IllegalOperation): 'Transaction numbers are only allowed on a replica set member or mongos' on server 127.0.0.1:20593. The full response is {"ok": 0.0, "errmsg": "Transaction numbers are only allowed on a replica set member or mongos", "code": 20, "codeName": "IllegalOperation"}
PROBE tx_docs after the call (the harness's count): count 0 · ids []
mongosh (--volumes-from c8u20-mongo): db.tx_docs.find().toArray() -> the stored _ids [] · countDocuments 0
-- tx mongo-rs (MongoDB on c8u20-mongo-rs, the harness's single-node replica set):
PROBE the context's PlatformTransactionManager beans (getBeansOfType), 1: transactionManager = org.springframework.data.mongodb.MongoTransactionManager
PROBE inside the @Transactional method: a transaction active (TransactionSynchronizationManager.isActualTransactionActive) true · resources bound to the thread: SimpleMongoClientDatabaseFactory
PROBE the exception: java.lang.IllegalStateException: PLANTED between the two writes
PROBE tx_docs after the call (the harness's count): count 0 · ids []
mongosh (--volumes-from c8u20-mongo-rs): db.tx_docs.find().toArray() -> the stored _ids [] · countDocuments 0
```

- **`JpaTransactionManager` over PostgreSQL, MongoDB standalone** — `@Transactional` opened a PostgreSQL transaction (the
  `EntityManagerFactory` and the data source bound to the thread) and nothing for Mongo: the first document stayed. The harness's count
  and mongosh's stored ids agree.
- **`MongoTransactionManager`, MongoDB standalone** — refused before the first write: the line the viewer reads first is the driver's
  (retryable writes), and its cause is the server's error 20. Both are quoted above, whole; mongosh reads the collection empty.
- **`MongoTransactionManager`, a single-node replica set** — the first insert ran, the plant fired, and neither document is stored:
  both or neither.

Boot makes no `MongoTransactionManager` — its two MongoDB jars hold no entry naming a transaction, and no Boot jar of that version in the
seed names the class:

```text
spring-boot-mongodb-4.1.2.jar: entries naming a transaction (grep -ci transaction) 0 · its AutoConfiguration.imports: MongoAutoConfiguration,MongoReactiveAutoConfiguration,MongoHealthContributorAutoConfiguration,MongoReactiveHealthContributorAutoConfiguration,MongoMetricsAutoConfiguration
spring-boot-data-mongodb-4.1.2.jar: entries naming a transaction (grep -ci transaction) 0 · its AutoConfiguration.imports: DataMongoAutoConfiguration,DataMongoReactiveAutoConfiguration,DataMongoReactiveRepositoriesAutoConfiguration,DataMongoRepositoriesAutoConfiguration
every Boot 4.1.2 jar in .m2-demo (find -name '*-4.1.2.jar' under org/springframework/boot), entries naming MongoTransactionManager: 0 in 152 jars
```

## RE-MEASURE 7 — the auto-created index's name and `explain` on it (settled first)

On 20/after's shipped tree, dev, a MongoDB that never held the index (each run a fresh container; the first `getIndexes` on `orders` is
before any dev start): the start sends `createIndexes` for `orders` itself — the mapper's, because the key is set — and the index is named
**after the field**, `customer`, not `customer_1` (the name an explicit `createIndex` gives). Its key is ascending, it is not unique. The
start sends it before the menu's fill. `explain` of a find on one customer walks it:

```text
mongosh (no network, --volumes-from c8u20-mongo): db.orders.getIndexes() before after/'s start -> NamespaceNotFound: ns does not exist: tiffinbox.orders · db.orders.countDocuments() -> 0
(x1) Command "createIndexes" started on database "tiffinbox"
system.profile on tiffinbox.orders after the start (mongosh, no network) - the ops in order: command createIndexes [{"key":{"customer":1},"name":"customer"}] · remove, the filter {} · insert, ninserted 120
system.profile: createIndexes commands on orders -> 1 · the first one, as the server received it: createIndexes: "orders", indexes: [{"key":{"customer":1},"name":"customer"}] · its place: before the menu's fill - the first insert on tiffinbox.menu comes after it
mongosh: db.orders.getIndexes() -> _id_ key {"_id":1} unique false · customer key {"customer":1} unique false
the start's lines: 1 Command "createIndexes" started on database "tiffinbox"|2 Command "delete" started on database "tiffinbox"|2 Command "insert" started on database "tiffinbox"|1 tiffinbox: kitchen value:  24300|1 tiffinbox: orders cooked:  120
```
```text
mongosh: db.orders.explain("executionStats").find({customer: "Ravi"}) -> queryPlanner.winningPlan FETCH > IXSCAN · executionStats.executionStages FETCH > IXSCAN · nReturned 30 · totalKeysExamined 30 · totalDocsExamined 30
PROBE idx: the shipped OrderDocument's IndexOperations.getIndexInfo() on orders, 2: _id_ _id ASC unique false · customer customer ASC unique false
mongosh: db.orders.explain("executionStats").find({customer: "Ravi"}) -> queryPlanner.winningPlan FETCH > IXSCAN · executionStats.executionStages FETCH > IXSCAN · nReturned 30 · totalKeysExamined 30 · totalDocsExamined 30
```

The second dev start on the same container (`index`): the fill deletes, the index stays, and `explain` reads the same.

## The captures — what each one shows

### 1 · noindex — the copy with the key unset: nothing created, every document read (the failure receipt; control `index`)

A labelled copy: 20/after with the key's lines removed from `application-dev.yaml` (`harness/variants.py nokey`, the comment above
them kept — a copy). Under dev on the unit's three stores, its MongoDB a fresh container each run (removed with its volumes and started
again; the honest shape S8.76 asks for — the broken state witnessed by `getIndexes` before `explain`, never assumed).

```text
-      auto-index-creation: true
mongosh (no network, --volumes-from c8u20-mongo): db.orders.getIndexes() before the copy's start -> NamespaceNotFound: ns does not exist: tiffinbox.orders · db.orders.countDocuments() -> 0
system.profile on tiffinbox.orders since the reset - the ops in order: remove, the filter {} · insert, ninserted 120
system.profile: createIndexes commands on orders -> 0 · listIndexes commands on orders -> 0
mongosh: db.orders.getIndexes() after the copy's start -> ["_id_"] · db.orders.countDocuments() -> 120
mongosh: db.orders.explain("executionStats").find({customer: "Ravi"}) -> queryPlanner.winningPlan COLLSCAN · executionStats.executionStages COLLSCAN · nReturned 30 · totalKeysExamined 0 · totalDocsExamined 120
```

`@Indexed` is on the field and nothing created the index: no `createIndexes` reached the server, `getIndexes` lists `_id_` alone, and
`explain` reads every document of the collection to return one customer's. Its control is `index`, the same run.

### 2 · anchor — the tests, the libraries, the dev shape on three stores, and the Compose window (⚑9, S8.65, S8.71, S8.75; RE-MEASURE 7, 12, 14)

```text
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
the package log: lines naming 27017 0 · lines naming mongo (any case) 0
before it: listening on 20578 (the anchor IT's pinned binding): 0
the IT's MongoDB container while verify ran, Docker's own list (dk ps, polled on a count): Ports 127.0.0.1:20578->27017/tcp · its command "docker-entrypoint.sh mongod" · listening on 20578 after it: 0
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 11, Failures: 0, Errors: 0, Skipped: 0
the verify log's MongoDB repository line (the slice's scan): (x1) Found 1 MongoDB repository interface
mongosh named in the verify log: 0 · --replSet named in the IT container's command: 0
```
```text
before/: 129 libraries
after/: 129 libraries
gained: 0 · lost: 0
the version lines off the jar names: mongodb-driver-sync-5.8.1.jar spring-boot-4.1.2.jar spring-data-jpa-4.1.2.jar spring-data-mongodb-5.1.2.jar spring-data-redis-4.1.2.jar
Boot's own metadata for the key D3 sets (spring-boot-data-mongodb-4.1.2.jar's spring-configuration-metadata.json): spring.data.mongodb.auto-index-creation java.lang.Boolean (DataMongoProperties)
```
```text
-- after/ under the profile dev, on PostgreSQL 18.6 + Redis 8.10.3 + MongoDB 8.3.17 (the three containers, by the digest), one start on a fresh database and an emptied Redis, Compose off:
(x1) Command "createIndexes" started on database "tiffinbox"
(x2) Command "delete" started on database "tiffinbox"
(x2) Command "insert" started on database "tiffinbox"
(x1) Database: jdbc:postgresql://<the unit's>/<db>?user=tiffinbox&password=******** (PostgreSQL 18.6)
(x1) HHH000001: Hibernate ORM core version 7.4.13.Final
(x1) tiffinbox: kitchen value:  24300
(x1) tiffinbox: orders cooked:  120
mongosh: db.orders.countDocuments() -> 120 · per customer -> Meera 30 · Priya 30 · Ravi 30 · Sunil 30 · db.menu.countDocuments() -> 30
mongosh: listDatabases -> admin,config,local,tiffinbox · that container's interfaces (its /proc/net/dev, read by mongosh): lo
GET /revenue/by-customer -> 200 [{"customer":"Sunil","total":9000},{"customer":"Ravi","total":7200},{"customer":"Meera","total":4500},{"customer":"Priya","total":3600}]
GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300}
GET /menu/day-19 -> 200 {"id":"day-19","items":[{"mealType":"VEG","name":"Vegetable …
GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
GET /dashboard -> 200
the stores' own versions: mongosh db.version() 8.3.17 · redis-cli INFO server redis_version:8.10.3 · psql show server_version 18.6 · mongod --version, a container of the digest with no network: db version v8.3.17
the start's lines: 1 Command "createIndexes" started on database "tiffinbox"|2 Command "delete" started on database "tiffinbox"|2 Command "insert" started on database "tiffinbox"|1 tiffinbox: kitchen value:  24300|1 tiffinbox: orders cooked:  120
GET /revenue/by-customer -> 200 [{"customer":"Sunil","total":9000},{"customer":"Ravi","total":7200},{"customer":"Meera","total":4500},{"customer":"Priya","total":3600}]
```

**The Compose window (RE-MEASURE 14)** — one labelled window per run, on the shipped `compose.yaml`, Boot's Docker Compose support on,
no `spring.*` address key; then the measured sequence: stop (Boot's), `down`, `down -v`, the mongo service's two anonymous volumes
removed by the names its container listed. The store names the database, and the Compose MongoDB — fresh — holds the index too: the key
made it there as well.

```text
before it: listening on 18881-18883 0 · tiffinbox-dev volumes 0 · tiffinbox-dev networks 0 · volumes 318 (the machine's 315 + the unit's three containers') · mongo:8 postgres:18-alpine redis:8-alpine present, on the digests (checked at the start)
the project's containers: tiffinbox-dev-mongo-1 127.0.0.1:18883->27017/tcp|tiffinbox-dev-postgres-1 127.0.0.1:18881->5432/tcp|tiffinbox-dev-redis-1 127.0.0.1:18882->6379/tcp
the start's lines: 1 Command "createIndexes" started on database "tiffinbox"|2 Command "delete" started on database "tiffinbox"|2 Command "insert" started on database "tiffinbox"|1 tiffinbox: kitchen value:  24300|1 tiffinbox: orders cooked:  120
mongosh (no network, --volumes-from tiffinbox-dev-mongo-1): listDatabases -> admin,config,local,tiffinbox · on tiffinbox: db.orders.countDocuments() -> 120 · db.orders.getIndexes() -> ["_id_","customer"] · db.menu.countDocuments() -> 30 · on test: orders -> 0
after TiffinBox stopped (Boot's own compose stop): the project's containers tiffinbox-dev-mongo-1 exited|tiffinbox-dev-postgres-1 exited|tiffinbox-dev-redis-1 exited · volumes 321
then: the project's containers 0 · its networks 0 · volumes 321 · tiffinbox-dev volumes by name: tiffinbox-dev_data · the mongo service's two: present present
then: volumes 320 · tiffinbox-dev volumes by name: 0 · the mongo service's two: present present
the receipt removes the mongo service's two by the names its container listed (dk volume rm): volumes 318 = before the window (the machine's 315 + the unit's three containers') · listening on 18881-18883: 0
```

Which count each volume number is: the machine's own count with no container of this run is the start and end count; with the unit's
three containers alive (PostgreSQL's one, MongoDB's two) the count rises, and the Compose window's own containers add theirs and give
them back. The last line above is the count before and after the window, with the unit's three containers still alive.

### 3 · index — the name, the plan, the Java witness, and the index a delete keeps (RE-MEASURE 7, S8.71)

```text
mongosh: db.orders.getIndexes() -> _id_ key {"_id":1} unique false · customer key {"customer":1} unique false
mongosh: db.orders.explain("executionStats").find({customer: "Ravi"}) -> queryPlanner.winningPlan FETCH > IXSCAN · executionStats.executionStages FETCH > IXSCAN · nReturned 30 · totalKeysExamined 30 · totalDocsExamined 30
mongosh: db.orders.countDocuments({customer: "Ravi"}) -> 30 · db.orders.countDocuments() -> 120
PROBE idx: the shipped OrderDocument's IndexOperations.getIndexInfo() on orders, 2: _id_ _id ASC unique false · customer customer ASC unique false
system.profile on tiffinbox.orders since the reset - the ops in order: remove, the filter {} · insert, ninserted 120
system.profile: drop commands on orders -> 0 · createIndexes commands on orders -> 0 · the driver's DEBUG lines: Command "createIndexes" started 1 · Command "delete" started 2
mongosh, after the second start: db.orders.getIndexes() -> _id_ key {"_id":1} unique false · customer key {"customer":1} unique false · db.orders.countDocuments() -> 120
mongosh: db.orders.explain("executionStats").find({customer: "Ravi"}) -> queryPlanner.winningPlan FETCH > IXSCAN · executionStats.executionStages FETCH > IXSCAN · nReturned 30 · totalKeysExamined 30 · totalDocsExamined 30
```

The mapper's own `getIndexInfo()` and mongosh's `getIndexes` name the same two indexes. A second dev start on the same container: the
fill's reset is a delete with an empty filter, never a drop, and the index is still there after it, read by both witnesses. On that
second start the driver sends `createIndexes` again (its DEBUG line); the server already holds the index.

### 4 · tx — the harness's three managers (S8.67; RE-MEASURE 11)

Above, under RE-MEASURE 11. The harness's replica set, before the three launches (its own window: started, initiated by mongosh with
no network, polled until it is the writable primary — a count it polls, R.412 — used by `tx`, `notone` and `advertised`, then removed
with its volumes):

```text
$ docker -H "$DH" run -d --pull never --name c8u20-mongo-rs --hostname c8u20-mongo-rs -p 127.0.0.1:20595:27017 -e GLIBC_TUNABLES=glibc.pthread.rseq=1 mongo@sha256:05b334b0a7a78fe913caac0cd2e1ecccf4da515d9a3a44be911b6ea3734c17cd --replSet rs0 --unixSocketPrefix /data/db --bind_ip_all
Docker's port list for c8u20-mongo-rs (dk port) -> 27017/tcp -> 127.0.0.1:20595 (--bind_ip_all is inside the container; the host side is 127.0.0.1 alone) · its Mounts: volume /data/configdb · volume /data/db · volumes now 320 (+ its two)
mongosh (no network, --volumes-from c8u20-mongo-rs): rs.initiate() -> ok 1 · me c8u20-mongo-rs:27017 · info2 no configuration specified. Using a default configuration for the set (its two cluster-time fields never printed)
mongosh: db.hello().isWritablePrimary, polled <k> times -> true
mongosh: rs.status() -> set rs0 · members 1 · members[0].name c8u20-mongo-rs:27017 · members[0].stateStr PRIMARY (its time fields never printed)
that container's interfaces (its /proc/net/dev, read by mongosh): lo
```

`--bind_ip_all` is inside the container: Docker publishes its port on the host's `127.0.0.1` alone, and the port list says so. The
container's hostname is fixed (`--hostname c8u20-mongo-rs`), so the address it advertises is the same in every run.

### 5 · notone — the transaction that is not one (the failure receipt, R.396's negation; control: the replica set's, the same run)

The harness plants a failure between two inserts under `@Transactional`. With a `JpaTransactionManager` over PostgreSQL —
`@Transactional` opened a PostgreSQL transaction and nothing for Mongo: the first document stayed.

```text
-- tx jpa (MongoDB on c8u20-mongo, the unit's standalone):
PROBE the context's PlatformTransactionManager beans (getBeansOfType), 1: transactionManager = org.springframework.orm.jpa.JpaTransactionManager
PROBE tx_docs after the call (the harness's count): count 1 · ids [a]
mongosh (--volumes-from c8u20-mongo): db.tx_docs.find().toArray() -> the stored _ids ["a"] · countDocuments 1
-- tx mongo-rs (MongoDB on c8u20-mongo-rs, the harness's single-node replica set):
PROBE the context's PlatformTransactionManager beans (getBeansOfType), 1: transactionManager = org.springframework.data.mongodb.MongoTransactionManager
PROBE tx_docs after the call (the harness's count): count 0 · ids []
mongosh (--volumes-from c8u20-mongo-rs): db.tx_docs.find().toArray() -> the stored _ids [] · countDocuments 0
```

A measurement of its own, not `tx`'s first launch written twice: `notone` runs the two launches again; `chk20 notone` asserts its two
count lines equal `tx`'s, the same run.

### 6 · advertised — the name the replica set gives the driver (S8.68)

```text
mongosh (no network, --volumes-from c8u20-mongo-rs): db.hello() -> me c8u20-mongo-rs:27017 · hosts ["c8u20-mongo-rs:27017"] · setName rs0 · isWritablePrimary true
PROBE topo one-seed: the driver's URI mongodb://127.0.0.1:<the unit's replica set>/tiffinbox
PROBE insertOne {_id: "one-seed"} into topo_docs: done · count 1
PROBE the driver's ClusterDescription: connection mode SINGLE · cluster type REPLICA_SET · servers [127.0.0.1:20595] · the server's type REPLICA_SET_PRIMARY · its setName rs0
mongosh (--volumes-from c8u20-mongo-rs): db.topo_docs.find().toArray() -> the stored _ids ["one-seed"]
PROBE topo replicaset: the driver's URI mongodb://127.0.0.1:<the unit's replica set>/tiffinbox?replicaSet=rs0&serverSelectionTimeoutMS=<n>
PROBE the exception: com.mongodb.MongoTimeoutException: Timed out while waiting for a server that matches WritableServerSelector. Client view of cluster state is {type=REPLICA_SET, servers=[{address=c8u20-mongo-rs:27017, type=UNKNOWN, state=CONNECTING, exception={com.mongodb.MongoSocketException: c8u20-mongo-rs}, caused by {java.net.UnknownHostException: c8u20-mongo-rs}}]
```

With one seed and no `replicaSet` option the driver talks to the one address it was given (`SINGLE`, though the server says it is a
replica set's primary) and the write lands. With the option, the driver follows the name the replica set advertises — the container's
own hostname — and could not resolve it on the Mac: the driver's exception, its text naming `UnknownHostException`. The wait the URI
sets is masked in the capture and never voiced.

### 7 · unique — a unique index, the second save refused (S8.63; the harness's)

```text
PROBE uniq: the harness's UniqDoc (@Indexed(unique = true) on code) in uniq_docs, through a MongoMappingContext with setAutoIndexCreation(true)
PROBE save UniqDoc(u1, LUNCH-1): done
PROBE the exception: org.springframework.dao.DuplicateKeyException: Write operation error on MongoDB server 127.0.0.1:20593. Write error: WriteError{code=11000, message='Plan executor error during update :: caused by :: E11000 duplicate key error collection: tiffinbox.uniq_docs index: code dup key: { code: "LUNCH-1" }', details={}}.
PROBE   caused by: com.mongodb.MongoWriteException: Write operation error on MongoDB server 127.0.0.1:20593. Write error: WriteError{code=11000, message='Plan executor error during update :: caused by :: E11000 duplicate key error collection: tiffinbox.uniq_docs index: code dup key: { code: "LUNCH-1" }', details={}}.
PROBE the mapper's getIndexInfo on uniq_docs: _id_ unique false, code unique true · count 1
its exit 0 · its log, every line but its PROBE lines: 0 · of them naming an Exception 0
mongosh: db.uniq_docs.getIndexes() -> _id_ key {"_id":1} unique false · code key {"code":1} unique true · db.uniq_docs.find().toArray() -> [{"_id":"u1","code":"LUNCH-1"}]
```

The harness's own class with `@Indexed(unique = true)` on a field, in its own collection `uniq_docs`, through a `MongoMappingContext`
with `setAutoIndexCreation(true)` — the harness's, never the anchor's. Spring's translation is `DuplicateKeyException`; the server's
`E11000` is inside its message, quoted whole.

### 8 · shapes — embedded, `@DocumentReference`, `@DBRef` (S8.64, R.424; the harness's three shapes)

The harness's three classes in their own collections, filled from the anchor's seed (the four names and their prices, read off `after/`'s
`V2__seed.sql`) times `tiffinbox.days` (read off `application.yaml`). The stored bytes, by mongosh:

```text
PROBE shapes fill: the harness's customers 4 (after/'s seed: Ravi, Meera, Sunil, Priya) · tiffinbox.days 30 · orders_emb 120 · orders_ref 120 · orders_dbref 120
mongosh (no network, --volumes-from c8u20-mongo), the stored bytes - printjson(db.orders_emb.findOne({_id: "Ravi-1"})):
customer: {
_class: 'probe.u20.H20$OrderEmb'
printjson(db.orders_ref.findOne({_id: "Ravi-1"})):
customer: 'Ravi',
_class: 'probe.u20.H20$OrderRef'
printjson(db.orders_dbref.findOne({_id: "Ravi-1"})):
customer: DBRef('customers', 'Ravi'),
_class: 'probe.u20.H20$OrderDbRef'
the customer field's type, as stored: orders_emb Object · orders_ref string · orders_dbref DBRef · db.customers.countDocuments() 4
```

`findAll()` of each, the profiler reset before each, the commands counted per namespace and op:

```text
-- shapes read-emb, the profiler reset before it:
PROBE shapes read-emb: findAll(OrderEmb.class) -> 120 orders, each with its customer inside
system.profile since the reset, the commands per namespace and op: tiffinbox.orders_emb getmore 1 · tiffinbox.orders_emb query 1
-- shapes read-ref, the profiler reset before it:
PROBE shapes read-ref: findAll(OrderRef.class) -> 120 orders · customers resolved (non-null) 120
system.profile since the reset, the commands per namespace and op: tiffinbox.customers query 120 · tiffinbox.orders_ref getmore 1 · tiffinbox.orders_ref query 1
-- shapes read-dbref, the profiler reset before it:
PROBE shapes read-dbref: findAll(OrderDbRef.class) -> 120 orders · customers resolved (non-null) 120
system.profile since the reset, the commands per namespace and op: tiffinbox.customers query 120 · tiffinbox.orders_dbref getmore 1 · tiffinbox.orders_dbref query 1
-- shapes write-emb, the profiler reset before it:
PROBE shapes write-emb: Ravi's price 120 -> 130 in every embedded copy, updateMulti(OrderEmb.class) -> matched 30 · modified 30
system.profile since the reset, the commands per namespace and op: tiffinbox.orders_emb update 1
system.profile: the update ops' nModified -> tiffinbox.orders_emb 30
-- shapes write-ref, the profiler reset before it:
PROBE shapes write-ref: Ravi's price 120 -> 130 in the one customer document, updateFirst(Cust.class) -> matched 1 · modified 1
system.profile since the reset, the commands per namespace and op: tiffinbox.customers update 1
system.profile: the update ops' nModified -> tiffinbox.customers 1
```

A reference costs one command per document it points to: the harness's orders name four customers, and each reference shape reads a
customer once per order. The write runs the other way: a price kept inside every order changes in each of that customer's orders; a
price kept once changes in one customer document and in no order. These are the harness's three shapes — TiffinBox's orders embed
nothing to reference (the customer is a name).

### 9 · default — the default run builds no MongoClient and sends no index (S8.65; RE-MEASURE 12)

```text
GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 {"monthRevenue":24300} · GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300} · GET /dashboard -> 200
/actuator/beans: a bean named revenue 0 · orderDocuments 0 · menus 0 · a MongoClient bean 0 · tiffinBoxServer 1
its log: lines naming 27017 0 · lines naming mongo, any case 0 · lines naming createIndexes 0 · its repository lines: Found 1 JPA repository interface|Found 1 JDBC repository interface · Could not safely identify 3
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

### 10 · seven — the comparison set on before/ and after/ (R.363)

```text
exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20596 now: 0
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20590 now: 0
the seven, after/ against before/: lines that differ: 0
```

The same answers as the previous unit's, byte for byte, on both trees: D3 changes no route of the default run.

### 11 · exercise — run as written, in one shell, bash then zsh (R.196, S8.76)

The spoken line is the brief's (`wc -w` printed). The viewer's lines start a new MongoDB container by the digest, with the variable, on
`127.0.0.1:20599` — the viewer's run of the image may pull it (the receipt asserts the images unchanged after it) — and remove it with its volumes
at the end; the solution's lines do the same, so each half meets a fresh server. Shape A, U19's form: a source-launched program on
after/'s jar, the shipped `OrderDocument` in a Boot context of two auto-configurations; broken = run without the key, solved = the same
run with `--spring.data.mongodb.auto-index-creation=true` — the key the anchor's `application-dev.yaml` sets, read as Boot reads it, so
the viewer learns the key, not a code call. Broken first, then solved: an index survives a delete, so a server that once ran the
solution would read solved while broken (RED #8). The check is `getIndexes` THEN `explain`, never the exit, never `explain` alone.

```text
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
built: 1 jar
orders saved: 120
indexes: [_id_]
explain find {customer: Ravi}: COLLSCAN · totalDocsExamined 120 · totalKeysExamined 0 · nReturned 30
then the solution's lines, in the same shell - the block's exit 0:
built: 1 jar
orders saved: 120
indexes: [_id_, customer]
explain find {customer: Ravi}: FETCH > IXSCAN · totalDocsExamined 30 · totalKeysExamined 30 · nReturned 30
the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20599 afterwards: 0 · the container c8u20-mongo-ex afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: c7d9fae1 (at the start: c7d9fae1)
built: 1 jar
orders saved: 120
indexes: [_id_]
explain find {customer: Ravi}: COLLSCAN · totalDocsExamined 120 · totalKeysExamined 0 · nReturned 30
then the solution's lines, in the same shell - the block's exit 0:
built: 1 jar
orders saved: 120
indexes: [_id_, customer]
explain find {customer: Ravi}: FETCH > IXSCAN · totalDocsExamined 30 · totalKeysExamined 30 · nReturned 30
the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20599 afterwards: 0 · the container c8u20-mongo-ex afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: c7d9fae1 (at the start: c7d9fae1)
```

## Which store, which profile, which tree

- 20/after, dev, the unit's PostgreSQL + Redis + standalone MongoDB: `anchor`'s start, `index`'s two starts and readings — the
  collection `orders` and the menu.
- 20/after, dev, Compose's three services: `anchor`'s Compose window.
- A copy with the key unset (`nokey`), dev, the unit's three stores: `noindex`.
- The harness's (`probe.u20.H20`), on the unit's standalone: `tx`'s first two launches and `notone`'s first (`tx_docs`), `unique`
  (`uniq_docs`), `shapes` (`customers`, `orders_emb`, `orders_ref`, `orders_dbref`), `index`'s `getIndexInfo` (a read of `orders`).
- The harness's, on the harness's replica set: `tx`'s and `notone`'s replica-set launch (`tx_docs`), `advertised` (`topo_docs`).
- The harness's PostgreSQL database `u20txjpa`, on the unit's PostgreSQL: the `JpaTransactionManager`'s, no table written.
- 20/after, default run, H2, no Docker: `default`, the seven on after/; 19/after: the seven on before/.
- The exercise: the shipped `OrderDocument` in the program's own context, a fresh container per half.

The harness's collections are emptied by `deleteMany({})` by mongosh (printed) or by the harness's own `remove`, never dropped;
`orders` and `menu` are reset by the start itself (R.431).

## Refused, named

- Never a `MongoTransactionManager` in the anchor: Boot makes none, dev's MongoDB is a standalone, and a second manager beside JPA's is
  Part B's question.
- Never a replica set in `compose.yaml` (⚑6, CARRIED (c)): a Compose replica set with a healthcheck would run mongosh in a networked
  container.
- Never `.withReplicaSet()`: it runs mongosh inside the networked container (S8.62).
- Never the `replicaSet` option in a dev URI, nor in any receipt URI but `advertised`'s one labelled failure (S8.68).
- Never a drop of a collection as a reset (R.431): the delete keeps the index.
- Never an exec into a mongod container for mongosh (R.422).
- Never SQL's name for the reference count (R.424): one command per reference.
- Never a word for all-or-nothing standing alone, without the manager and the topology (S8.67).
- Never a length for the driver's search for a server (⚑11).
- Never both managers in one context: that is Part B's.
- Never the dead health key Boot does not read (S8.65).

## The repository, and the network

`.m2-demo` is a file copy of the course's seed `_research/m2-seed-c8-s4` (its file count printed at the start, unchanged at the end);
every build is offline (`mvn -o`, `maven.repo.local` absolute, `Downloaded from` 0 in every log). The harness's JPA manager needs
nothing new: `spring-boot-starter-data-jpa` 4.1.2, `postgresql` 42.7.14 and `spring-orm` 7.0.10 are in the seed (checked by path) and in
after/'s jar already — TiffinBox is a JPA application. No network of any kind but the final `git push`; no pull — the three digests
present (each image inspected by its digest, else the receipt stops and prints the pull command, never runs it).

## The folders, the harness and the ports

`harness/`: `chk20.py` (the checks), `s820.py` (the prose gate), `tree20.py` (the pins), `variants.py` (`nokey`), `surefire.py`,
`dur8.py` and `logback.xml` (earlier units', byte for byte), `src/probe/u20/H20.java` (one class with modes — `tx`, `topo`, `uniq`,
`shapes`, `idx` — and its nested shapes: the planted method, the two context shapes, `UniqDoc`, `Cust`, `OrderEmb`, `OrderRef`,
`OrderDbRef`), `src/probe/x/XMain.java` (Course 7's probe, `XMain`, byte for byte). `exercise/`: `README.md`, `SOLUTION.md`, `IndexedOrders.java`.

Ports, the slot map: 20590 TiffinBox `after/` · 20591 the unit's PostgreSQL · 20592 the unit's Redis · 20593 the unit's MongoDB, a
standalone · 20594 reserved for Part B, never bound · 20595 the harness's replica set · 20596 TiffinBox `before/` for the seven (the
brief gives the slot after MongoDB's to the replica set, so `before/` moves one up) · 20597-20598 never bound · 20599 the exercise's
MongoDB. 20578 is the anchor IT's pinned binding, unbound before each `verify` and after it. 18881-18883 only inside `anchor`'s Compose
window. Nothing listens on any of them at the end.

## Masks, filters and hygiene — every one, declared

The mask (self-tested on plants first): Boot's started-in line, Surefire's elapsed time, the scanning and initialization times,
Flyway's execution time, Testcontainers' started-in, Maven's total time, the Java version, an `ObjectId`'s hex, a `Timestamp`, a poll
count, a pid, an object's hash, the folders, the home and the user. The harness masks the wait in the `advertised` URI and in the
driver's message itself (`<n>`). Never printed: `rs.initiate()`'s cluster time and operation time, `rs.status()`'s optimes, election
date, the time it has been up and its heartbeat, `explain`'s and the profiler's time fields, Boot's `MongoClient` settings line (counted, never shown). The
hygiene gate refuses each of them in every capture, and dur8 finds no word in the captures or this README's text blocks.

## Interrupted

SIGINT, after the planted faults, alone, by a driver in the session's scratch folder: `receipts.sh` started in its own process group
with SIGINT at its default (the perl reset, R.410), the whole group sent SIGINT when the receipt's own log showed a marker, as a
terminal's Ctrl-C would; then what is left, read by the driver.

- **mid-build** (Maven's reactor running, 08:21): exit 130 · java 0 · containers of this unit 0 · Testcontainers 0 · volumes and images
  the machine's · the unit's ports free · `.r-lock` gone · no partial capture · the published captures unchanged.
- **mid-verify** (Testcontainers creating the IT's MongoDB, 08:22): exit 130 · the same, all clean, read once when the receipt had exited.
- **mid-TiffinBox on PostgreSQL** (`noindex`'s dev JVM started, the three stores alive, 08:27): exit 130, java 0, the unit's ports free,
  **but one container left: a mongosh container, `Created` and never started, holding the image's two anonymous volumes** (the count
  two above the machine's). The interrupt had caught `ms` between Docker's create and its start; `--rm` never applies to a container
  that never ran. Removed by hand with `rm -fv` (the count back), and **the receipt fixed**: every `ms` container (and the `mongod
  --version` one) carries the label `c8u20.ms`, the trap removes every container with it (`rm -fv`), and the start refuses to run if
  one exists. Run again on the fixed receipt (08:36): exit 130 · java 0 · no container of this unit · volumes and images the machine's ·
  ports free · `.r-lock` gone · no partial capture · captures unchanged.
- **Not done, for time** (the cap of the session): mid-Compose-window, mid-`tx` with the replica set up, mid-`shapes`. The trap's code
  for them is the same — `cmprm` (Compose's `down -v`, and the mongo service's two volumes by name), `ctrm` (both mongods, the
  labelled mongosh containers), `tcrm` — but it was not exercised there; RED should run them.

## The ledger rows this unit pays

The contract's Known machine item for Section 4, "MongoDB's replica set for transactions (U20)", is paid here — measured on the
harness's own container (`tx`, `notone`, `advertised`), a single-node replica set initiated by mongosh with no network, one seed and no
`replicaSet` option for every write. No row of the promise ledger is this unit's (C8-15 was Section 4's first unit's).

## RE-MEASURE — the plan's items this unit settles

- 7: the auto-created index is named `customer`; `explain` on it, above.
- 11: the three managers 3/3 with `JpaTransactionManager` over the unit's PostgreSQL; the advertised-address pair on the harness's
  container; the shapes' counts on the harness's classes.
- 12: the seven and the default run, above.
- 14: the store names the database on the shipped `compose.yaml`, in one Compose window per run.
- 8 (shared with the two earlier units): `MongoDatastoreIT` under the profile "dev" — the key applies in the slice, the index test passes.

## Part B moves the anchor next

Elasticsearch, units 21 to 24, under its own plan; the script stage's one tool line (`DUR_SECTIONS` gains Section 4) comes before
Section 4's first script. Unit 24's question — a second transaction manager beside JPA's, and which one `@Transactional` gets — is Part B's,
never pre-empted here. Ports from 20604 on are Part B's and none was bound.

## What differed from the brief

- **The route**: `GET /revenue/by-customer` everywhere — `GET /revenue` is the month's revenue PostgreSQL computes, one of the seven.
- **The slot map**: the replica set takes the slot after MongoDB's, so `before/` for the seven moves to 20596.
- **The replica set's hostname is fixed** (`--hostname c8u20-mongo-rs`): a default container hostname is its random id, so `hello`'s
  `me` and the `UnknownHostException` would move between runs of record and break the published hashes. The name is still one the Mac
  cannot resolve — the failure is the same failure.
- **`noindex` and `anchor` each start from a fresh MongoDB container, every run.** The first trial showed why: once the index exists, a
  second start's `createIndexes` leaves no entry in `system.profile` (the driver still logs it), so `anchor`'s profile read differently in
  its second run. A fresh container per run makes the start's index creation the same witnessed act each time. `index` then reads the
  container `anchor`'s last run left.
- **`notone` is its own measurement**, two launches after `tx`'s three, not `tx`'s first launch written twice.
- **The JPA context is a plain `AnnotationConfigApplicationContext`**, not a Boot application: no entity was needed for the manager.
- **The exercise is shape A** (a source-launched program on after/'s jar, a Boot context of two auto-configurations), not 20/after on a
  second Compose stack: one Compose window per run stays one.
- **The trap's fix came after three runs of record**: `ms`'s containers carry a label the trap removes (*Interrupted*). The bash 5.3 run
  and the sealed clone ran the receipt before that change; the fourth run ran the committed one. The change touches no capture.
- **`index`'s createIndexes witness on the second start** is the driver's DEBUG line; the profiler's count is printed beside it.

## For RED

- The manager class in `tx` is read off the context; the context holds exactly one `PlatformTransactionManager` per launch.
- The standalone refusal's top line is Spring's `UncategorizedMongoDbException` wrapping the driver's `MongoClientException`, both
  carrying the retryable-writes text; the server's error 20 is the third link of the chain.
- `advertised`'s one-seed run reports the server's type as the replica set's primary while the connection mode is `SINGLE`.
- The shapes' embedded `findAll` needs a `getmore` after the first batch; its count is printed, never typed.
- The harness's `uniq` save is Spring's `save` (an upsert), so the server's message reads "Plan executor error during update", quoted.
- The volume counts mid-receipt are said per line (which containers are alive); the start and end count is the machine's own.

## Planted faults — each caught (R.65, R.226)

Run alone, after the three runs of record (2026-11-20 08:21 CET), by a driver in the session's scratch folder on a mirror (a
`file://` clone at this unit's commit): each plant on a copy, its check run, exit 1 expected; the controls first. Ten controls, each
passing: the prose as shipped and nine captures as captured. Thirty-three plants, each caught:

- the prose gate (`s820.py`) refused, each by its own rule: the all-or-nothing word beside the JPA manager; Boot credited with Mongo's
  manager; the annotation credited with the index on the copy; SQL's name for the reference count; a comparison word beside Mongo (XFAM_S4's); a wait
  with a number; a container removal without its volumes flag; the docker CLI without its socket; a typed number; a transaction slogan
  with no manager.
- the receipt's gates stopped: the `replicaSet` option in a receipt URI outside `advertised` (S8.68's count); an exec into mongod's
  container for mongosh (R.422); the docker CLI unpinned (R.344); a container removed without `-v` (R.387); `before` pointing at the
  wrong tree (R.211); the exercise's solution made its broken lines (R.196); a placeholder; an Indian dish name (R.215 — the receipt's
  word list, not the prose gate: `s820.py` alone does not name dishes, the driver's own label for it said "missed" and the receipt's
  gate printed the dish). Two were caught first by the after-tree pin, before their own gate: `.withReplicaSet()` in the IT and
  `OrderDocument`'s false sentence put back (R.211: the tree moved) — the pin stops any edit of `after/`.
- `chk20.py` failed each doctored capture: `notone`'s count 1 made 0; `noindex`'s `COLLSCAN` made `IXSCAN`; `index`'s documents
  examined raised to every document; `shapes`' reference count cut; `unique`'s `E11000` deleted; `advertised`'s
  `UnknownHostException` deleted; `anchor`'s `createIndexes` op deleted; `listDatabases` showing `test`; `default`'s 404 made 200;
  the exercise's broken half reading the index (a container that once ran the solution); the standalone refusal's cause deleted; the jar
  read made non-zero.

Not planted, so not claimed caught: a wrong published hash and a version claim without its line - their gates (`pub`'s compare,
`chk20 anchor`'s version lines) run on every run of record.

## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: broken: getIndexes [_id_], explain COLLSCAN 120 examined; solved: getIndexes [_id_, customer], IXSCAN 30 examined · noindex: the copy without the key: getIndexes ["_id_"]; 0 createIndexes; explain COLLSCAN, totalDocsExamined 120, totalKeysExamined 0, nReturned 30 · anchor: tests 18 + 11 (package 18); Ports 127.0.0.1:20578->27017/tcp; the IT's third test: getIndexInfo [_id_, customer], FETCH > IXSCAN; the key spring.data.mongodb.auto-index-creation (Boot's metadata); the start's createIndexes on orders, {customer: 1} named customer, before the fill; getIndexes _id_ + customer; countDocuments 120 = 4 customers x 30 days; revenue/by-customer Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 = ordersValue; listDatabases tiffinbox, no test; Compose window: the index there too, volumes back to 318 (the unit's three containers alive) · index: getIndexes _id_ + customer (key {customer: 1}, not unique); explain FETCH > IXSCAN, nReturned 30, totalKeysExamined 30, totalDocsExamined 30; getIndexInfo the same two; a second start: the fill deletes, the index stays, IXSCAN 30 · tx: JpaTransactionManager over PostgreSQL, MongoDB standalone -> count 1, ids [a] (the harness's plant); MongoTransactionManager, MongoDB standalone -> refused: "This MongoDB deployment does not support retryable writes. Please add retryWrites=false to your connection string." caused by error 20 (IllegalOperation) 'Transaction numbers are only allowed on a replica set member or mongos', count 0; MongoTransactionManager, a single-node replica set -> count 0, ids [] (both or neither); Boot's MongoDB jars: 0 entries name a transaction · notone: JpaTransactionManager over PostgreSQL, MongoDB standalone: the first document stayed, count 1, ids [a]; its control MongoTransactionManager on a single-node replica set: count 0, ids [] · advertised: hello me c8u20-mongo-rs:27017, setName rs0; one seed: SINGLE / REPLICA_SET, the write done; replicaSet=rs0: the driver followed the advertised name and could not resolve it, UnknownHostException: c8u20-mongo-rs · unique: the harness's @Indexed(unique = true): the second save -> DuplicateKeyException, E11000 duplicate key error collection: tiffinbox.uniq_docs index: code; count 1 · shapes: the harness's three shapes, findAll of 120: embedded 1 query op (+ 1 getmore), 0 on customers; @DocumentReference 1 + 120 on customers; @DBRef 1 + 120 - one command per reference; the price write: embedded 30 documents modified vs referenced 1, 0 orders · default: health 200, /revenue/by-customer 404, /menu/day-19 404, /revenue 200, /kitchen 200, 0 lines naming 27017, mongo or createIndexes, no Revenue/OrderDocuments bean; the 18 without Docker · seven: the seven: md5 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/
<!-- values: end -->

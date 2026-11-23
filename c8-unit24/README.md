# c8-unit24 — Polyglot Persistence in One App

Course 8, Section 4 Part B's last unit. Two stores and two transaction managers, measured on a **harness of this unit's own** (the
harness's replica set and the harness's PostgreSQL), never on TiffinBox's stores: Mongo's manager added beside JPA's makes Boot leave
JPA's out; named `transactionManager` it takes JPA's place and the row's save writes nothing; with both declared, each method names the
manager it runs under, and a failure the harness plants after both writes keeps one store's write and loses the other's. That is the
dual write, named here, and the anchor's README hands it forward with one pinned sentence. The anchor change is **`c8-tiffinbox/README.md`
alone** (flag 11): `before` is the link to `../c8-unit23/after`, `after/` is that tree with its README's unit 24 card added, and the jar
the two trees build is the same jar, byte for byte (`default`).

The gloss, first use, as the brief words it for the script (§SECTION SHAPE, unit 24) is quoted in "For RED" — its words trip a carried
rule of this unit's prose gate, so the dual write is named in this README's own words: one change written to two stores, each
write committed on its own.

## Runs of record

- bash 3.2.57, `./receipts.sh` — started 2026-11-23 10:34:44, ended 2026-11-23 10:41:00, exit `0`; the load average (the first of the three the machine prints) `18.04` at the start and `4.89` at the end; `check_unit8.py 24 --runlog` on its log: PASS.
- bash 5.3.9, `bash receipts.sh` — started 2026-11-23 10:41:09, ended 2026-11-23 10:46:51, exit `0`; the load average (the first of the three the machine prints) `4.58` at the start and `5.09` at the end; `check_unit8.py 24 --runlog` on its log: PASS.
- the sealed clone, a path with a space, `./receipts.sh` — started 2026-11-23 10:49:35, ended 2026-11-23 10:55:33, exit `0`; the load average (the first of the three the machine prints) `3.97` at the start and `5.63` at the end; `check_unit8.py 24 --runlog` on its log: PASS.
- SIGINT mid-build (Maven compiling before/'s tree): exit `130`; java `0`, containers of this unit `0`, Compose's `0`, volumes `315`, images `9`, ports bound `0`, captures unchanged: yes.
- SIGINT mid-exercise (its two containers up, the lab's JVM running): exit `130`; java `0`, containers of this unit `0`, Compose's `0`, volumes `315`, images `9`, ports bound `0`, captures unchanged: yes.
- SIGINT mid-replica-set-init (the container alive, the harness JVM initiating it through the driver): exit `130`; java `0`, containers of this unit `0`, Compose's `0`, volumes `315`, images `9`, ports bound `0`, captures unchanged: yes.
- SIGINT mid-dual (both stores alive, the harness JVM in its transactions): exit `130`; java `0`, containers of this unit `0`, Compose's `0`, volumes `315`, images `9`, ports bound `0`, captures unchanged: yes.
- SIGINT mid-footprint (the Compose window open, its four containers up): exit `130`; java `0`, containers of this unit `0`, Compose's `0`, volumes `315`, images `9`, ports bound `0`, captures unchanged: yes.
- Not runs of record, said so: a first attempt of the sealed run stopped at `exercise` (exit `1`, "DIFFERS"): its count of the exercise's java processes read `1` because the command line of this agent's own shell that launched it named the lab's file - the receipt's count matches any process whose command names the lab; the run was repeated from a clean shell and is the one above. A first round of SIGINT points: mid-exercise, the exercise's check had a witness container (`--rm`, no label then) still exiting when the proof was read - volumes back to the start's count once it was gone; its check's container carries a label since, and the trap removes it; mid-replica-set-init was spoiled by an edit to `receipts.sh` while that run read it (a syntax error, exit `2`); mid-footprint was stopped by hand to use a quiet window for the runs of record. All three were run again after the runs of record with the files as committed, and mid-build too (its first run predates the label) - the lines above.
- A last full run of `./receipts.sh` on the files as committed (this README with its runs, plants and SIGINT lines in place), after the plants: started 2026-11-23 11:04:49, ended 11:10:06, exit `0`, every capture = published, the load average `3.84` at the start; `check_unit8.py 24 --runlog`: PASS.

## RE-MEASURE 12 — the two-manager matrix on the harness's stores, every cell 3/3

Every cell is the harness's: one JVM (`probe.u24.H24`, profile `both`) per capture run, three capture runs per run of record, a fresh
PostgreSQL database and an emptied `u24_notes` collection before each. Each method is called planted (the harness plants an
`IllegalStateException`) and then as its control (no plant). The rows are counted by the harness's Java (`JdbcTemplate`, by the dish's
name) and by psql in the harness's PostgreSQL after the JVM is gone; the documents by the harness's Java (`MongoTemplate`) and by
mongosh in a container with no network on the replica set's socket. `chk24.py dual` asserts the three equal for every name, and the
totals equal.

| method | manager | write order | plant | rows | documents | witnesses |
|---|---|---|---|---|---|---|
| `plain` (names none) | JPA's, `@Primary` | row, document | after both writes | `0` | `1` | Java = psql = mongosh |
| `jpaRowDoc` | `transactionManager` | row, document | after both writes | `0` | `1` | Java = psql = mongosh |
| `jpaDocRowAfter` | `transactionManager` | document, row | after both writes | `0` | `1` | Java = psql = mongosh |
| `jpaDocRow` | `transactionManager` | document, plant, row | between the writes | `0` | `1` | Java = psql = mongosh |
| `mongoRowDoc` | `mongoTransactionManager` | row, document | after both writes | `1` | `0` | Java = psql = mongosh |
| `mongoDocRowAfter` | `mongoTransactionManager` | document, row | after both writes | `1` | `0` | Java = psql = mongosh |
| `mongoDocRow` | `mongoTransactionManager` | document, plant, row | between the writes | `0` | `0` | Java = psql = mongosh |
| `nested` | outer JPA's, inner `Inner.doc` on Mongo's | row, inner document | in the outer, after the inner returned | `0` | `1` | Java = psql = mongosh |
| `scoped` | JPA's; the document by an AFTER_COMMIT listener calling `Inner.doc` | row, then the listener | in the listener | `1` | `0` | Java = psql = mongosh |
| each control | as above | as above | none | `1` | `1` | Java = psql = mongosh |

Every cell equals the probe's (S4B probe notes, Step 7). Under JPA's manager the Mongo insert runs in no transaction and stays when the
row is rolled back; under Mongo's the repository's `save` runs a JPA transaction of its own and commits before the planted failure. The
failure between the writes under Mongo's manager loses both — the document is rolled back and the row is never written — which is why the
spine says "after both writes".

## RE-MEASURE 11 — the footprint on 24/after

One Compose window per run of record: the shipped `compose.yaml`'s four services started by Boot's Compose support for `after/` under
"dev", MongoDB a standalone as Part A ships it; the start re-indexes the dishes, one search runs, then `docker stats --no-stream` once.
The reading is a one-shot value, so the hashed capture masks it and the receipt's log prints it whole. This run of record's reading
(MiB as Docker prints it; the VM's total from the engine's `MemTotal`; TiffinBox's resident size by `ps -o rss=`):

```log
tiffinbox-dev-elasticsearch-1 941.2MiB · tiffinbox-dev-mongo-1 164.3MiB · tiffinbox-dev-postgres-1 40.24MiB · tiffinbox-dev-redis-1 7.762MiB · the four together 1153.5 MiB · the VM total 7.818 GiB (MemTotal of the engine 8394457088 B) · TiffinBox rss 407488 kB
```

The probe's reading (Step 8) had Mongo as the harness's replica set; this one is the shipped standalone. The two are not the same store
shape, so neither replaces the other: the README voices this run's numbers as "this run, this VM".

## The change, file by file

ONE file, `c8-tiffinbox/README.md` (and `after/README.md`, its copy): a card, `## Course 8 · unit 24 — Polyglot Persistence in One App:
which manager each write runs under, and the dual write named`, after unit 22's card. It says which manager each shipped write runs
under — PostgreSQL's rows under JPA's `transactionManager` (Boot's), MongoDB's dev fills under no manager on the standalone (Part A's
reading), the index copy after the commit under none (unit 22's `DishIndexSync`) — has the dual write named, points at this folder,
and closes with the hand-off sentence as a line of its own, byte for byte. No sentence of the anchor's README was rewritten: unit 22's card
says "the dual write is named here and handed to unit 24, which measures the two managers" — true as it stands, kept. The card's lines
pass `s824.py` (0 refused, checked by the receipt on the lines `diff` adds) and dur8 (0).

## The captures — what each one shows

### 1 · jars

```text
-- jars: the two jars, by name off after/'s BOOT-INF/lib (ls): spring-boot-jpa-4.1.2.jar · spring-data-commons-4.1.2.jar · BOOT-INF/lib holds 146 jars
  unzip -l spring-boot-jpa-4.1.2.jar | grep JpaBaseConfiguration.class -> org/springframework/boot/jpa/autoconfigure/JpaBaseConfiguration.class 13509 B
$ javap -v -cp spring-boot-jpa-4.1.2.jar org.springframework.boot.jpa.autoconfigure.JpaBaseConfiguration   (the method transactionManager and its RuntimeVisibleAnnotations, whole)
    public org.springframework.transaction.PlatformTransactionManager transactionManager(org.springframework.beans.factory.ObjectProvider<org.springframework.boot.transaction.autoconfigure.TransactionManagerCustomizers>);
      RuntimeVisibleAnnotations:
        0: #n()
          org.springframework.context.annotation.Bean
        1: #n(#n=[c#n])
          org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean(
            value=[class Lorg/springframework/transaction/TransactionManager;]
          )
  unzip -l spring-data-commons-4.1.2.jar | grep ChainedTransactionManager.class -> org/springframework/data/transaction/ChainedTransactionManager.class 7674 B
  javap -v -cp spring-data-commons-4.1.2.jar org.springframework.data.transaction.ChainedTransactionManager: public class org.springframework.data.transaction.ChainedTransactionManager · Deprecated: true · its class annotation: java.lang.Deprecated
  Boot's own MongoDB jars, entries naming MongoTransactionManager (unzip -l): spring-boot-mongodb 0 · spring-boot-data-mongodb 0 - Boot makes no Mongo manager (Part A's reading, unit 20)
```

### 2 · handoff

```text
-- handoff (S8.89): the sentence, its md5, where it stands, and what it rests on:
  printf '%s' "$HANDOFF" | md5 -> a6581dab7e33c458146b1f0e9cb114bc
  after/README.md: lines equal to it (grep -cxF) 1 · that line's md5 (no newline) a6581dab7e33c458146b1f0e9cb114bc
  ../c8-tiffinbox/README.md: lines equal to it (grep -cxF) 1 · that line's md5 (no newline) a6581dab7e33c458146b1f0e9cb114bc
  the roadmap (_briefs/TRACK-ROADMAP.md), the lines it rests on, cut at 160 characters:
    :64 | **13** | **Messaging & Integration** | **32** | Needs transactions (7) to make the outbox pattern mean anything, and Reactor (12) for streaming consumers. |
    :552 ### COURSE 13 — Messaging & Integration (32 units · 6 sections)
    :580 **S4 · Patterns that matter (21-26)**
    :581 - 21 **The Outbox Pattern** — course 8 U24's dual-write problem, solved, with the relay implemented.
    :922 | C8 U24 dual write | forward: C13 outbox (**named by section, not number**) | Declares the hole rather than leaving it silent. |
  the promise ledger's row C8-20 (PROMISE-LEDGER-2026-11-17.md, its first 150 characters): | C8-20 | U24's dual write is named and handed forward to Course 13's outbox **by section, not number** [roadmap §3b `:922`, `:926`] — "solved in c
```

### 3 · mtm

```text
  a fresh database on c8u24-pg-h (psql): u24mtm
  the start: Successfully applied 4 migrations
  the harness's transaction managers: [mongoTransactionManager] -> [MongoTransactionManager]
  the harness's stores before: rows in dish 10 · documents in u24_notes 0
  the harness's mtm plain (Dual.plain, plant no): caller caught org.springframework.beans.factory.NoSuchBeanDefinitionException: No bean named 'transactionManager' available: No matching TransactionManager bean found for qualifier 'transactionManager' - neither qualifier match nor bean name match!
  the harness's mtm plain: rows 0 · documents 0
  the harness's stores after: rows in dish 10 · documents in u24_notes 0
  psql (the harness's PostgreSQL, c8u24-pg-h, database u24mtm): select count(*) from dish -> 10 · the harness's rows (id > 10), by name:
  mongosh (no network, --volumes-from c8u24-mongo-rs): db.u24_notes.countDocuments() -> 0 · by name:
  mongosh (no network): db.u24_notes.deleteMany({}) -> deletedCount 0
```

### 4 · mtmnamed

```text
  a fresh database on c8u24-pg-h (psql): u24named
  the start: Successfully applied 4 migrations
  the harness's transaction managers: [transactionManager] -> [MongoTransactionManager]
  the harness's stores before: rows in dish 10 · documents in u24_notes 0
  the harness's mtmnamed plain (Dual.plain, plant no): caller saw no exception
  the harness's mtmnamed plain: rows 0 · documents 1
  the harness's mtmnamed planted (Dual.plain, plant yes): caller caught java.lang.IllegalStateException: PLANTED after both writes
  the harness's mtmnamed planted: rows 0 · documents 0
  the harness's stores after: rows in dish 10 · documents in u24_notes 1
  its WARN and ERROR lines: 2
    WARN  [main] io.netty.resolver.dns.DnsServerAddressStreamProviders : Can not find io.netty.resolver.dns.macos.MacOSDnsServerAddressStreamProvider in the classpath, fallback to system defaults. This ma
    WARN  [main] org.springframework.boot.thymeleaf.autoconfigure.ThymeleafAutoConfiguration$DefaultTemplateResolverConfiguration : Cannot find template location: classpath:/templates/ (please add some te
  psql (the harness's PostgreSQL, c8u24-pg-h, database u24named): select count(*) from dish -> 10 · the harness's rows (id > 10), by name:
  mongosh (no network, --volumes-from c8u24-mongo-rs): db.u24_notes.countDocuments() -> 1 · by name:
    mongosh documents: mtmnamed plain 1
  mongosh (no network): db.u24_notes.deleteMany({}) -> deletedCount 1
```

### 5 · both

```text
  the harness's transaction managers: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]
  the harness's bean transactionManager: org.springframework.orm.jpa.JpaTransactionManager (@Primary)
  the harness's bean mongoTransactionManager: org.springframework.data.mongodb.MongoTransactionManager
  the harness's Dual.jpaDocRow: @Transactional("transactionManager")
  the harness's Dual.jpaDocRowAfter: @Transactional("transactionManager")
  the harness's Dual.jpaRowDoc: @Transactional("transactionManager")
  the harness's Dual.mongoDocRow: @Transactional("mongoTransactionManager")
  the harness's Dual.mongoDocRowAfter: @Transactional("mongoTransactionManager")
  the harness's Dual.mongoRowDoc: @Transactional("mongoTransactionManager")
  the harness's Dual.nested: @Transactional("transactionManager")
  the harness's Dual.plain: @Transactional("")
  the harness's Dual.scoped: @Transactional("transactionManager")
  the harness's Inner.doc: @Transactional("mongoTransactionManager")
```

### 6 · dual

```text
  a fresh database on c8u24-pg-h (psql): u24dual
  the harness's transaction managers: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]
  the harness's stores before: rows in dish 10 · documents in u24_notes 0
  the harness's plain planted (Dual.plain, plant yes): caller caught java.lang.IllegalStateException: PLANTED after both writes
  the harness's plain planted: rows 0 · documents 1
  the harness's plain control (Dual.plain, plant no): caller saw no exception
  the harness's plain control: rows 1 · documents 1
  the harness's jpaRowDoc planted (Dual.jpaRowDoc, plant yes): caller caught java.lang.IllegalStateException: PLANTED after both writes
  the harness's jpaRowDoc planted: rows 0 · documents 1
  the harness's jpaRowDoc control (Dual.jpaRowDoc, plant no): caller saw no exception
  the harness's jpaRowDoc control: rows 1 · documents 1
  the harness's jpaDocRowAfter planted (Dual.jpaDocRowAfter, plant yes): caller caught java.lang.IllegalStateException: PLANTED after both writes
  the harness's jpaDocRowAfter planted: rows 0 · documents 1
  the harness's jpaDocRowAfter control (Dual.jpaDocRowAfter, plant no): caller saw no exception
  the harness's jpaDocRowAfter control: rows 1 · documents 1
  the harness's jpaDocRow planted (Dual.jpaDocRow, plant yes): caller caught java.lang.IllegalStateException: PLANTED between the writes
  the harness's jpaDocRow planted: rows 0 · documents 1
  the harness's jpaDocRow control (Dual.jpaDocRow, plant no): caller saw no exception
  the harness's jpaDocRow control: rows 1 · documents 1
  the harness's mongoRowDoc planted (Dual.mongoRowDoc, plant yes): caller caught java.lang.IllegalStateException: PLANTED after both writes
  the harness's mongoRowDoc planted: rows 1 · documents 0
  the harness's mongoRowDoc control (Dual.mongoRowDoc, plant no): caller saw no exception
  the harness's mongoRowDoc control: rows 1 · documents 1
  the harness's mongoDocRowAfter planted (Dual.mongoDocRowAfter, plant yes): caller caught java.lang.IllegalStateException: PLANTED after both writes
  the harness's mongoDocRowAfter planted: rows 1 · documents 0
  the harness's mongoDocRowAfter control (Dual.mongoDocRowAfter, plant no): caller saw no exception
  the harness's mongoDocRowAfter control: rows 1 · documents 1
  the harness's mongoDocRow planted (Dual.mongoDocRow, plant yes): caller caught java.lang.IllegalStateException: PLANTED between the writes
  the harness's mongoDocRow planted: rows 0 · documents 0
  the harness's mongoDocRow control (Dual.mongoDocRow, plant no): caller saw no exception
  the harness's mongoDocRow control: rows 1 · documents 1
  the harness's nested planted (Dual.nested, plant yes): caller caught java.lang.IllegalStateException: PLANTED in the outer, after the inner returned
  the harness's nested planted: rows 0 · documents 1
  the harness's nested control (Dual.nested, plant no): caller saw no exception
  the harness's nested control: rows 1 · documents 1
  the harness's stores after: rows in dish 20 · documents in u24_notes 13
  psql (the harness's PostgreSQL, c8u24-pg-h, database u24dual): select count(*) from dish -> 20 · the harness's rows (id > 10), by name:
    psql rows: jpaDocRow control 1
    psql rows: jpaDocRowAfter control 1
    psql rows: jpaRowDoc control 1
    psql rows: mongoDocRow control 1
    psql rows: mongoDocRowAfter control 1
    psql rows: mongoDocRowAfter planted 1
    psql rows: mongoRowDoc control 1
    psql rows: mongoRowDoc planted 1
    psql rows: nested control 1
    psql rows: plain control 1
  mongosh (no network, --volumes-from c8u24-mongo-rs): db.u24_notes.countDocuments() -> 13 · by name:
    mongosh documents: jpaDocRow control 1
    mongosh documents: jpaDocRow planted 1
    mongosh documents: jpaDocRowAfter control 1
    mongosh documents: jpaDocRowAfter planted 1
    mongosh documents: jpaRowDoc control 1
    mongosh documents: jpaRowDoc planted 1
    mongosh documents: mongoDocRow control 1
    mongosh documents: mongoDocRowAfter control 1
    mongosh documents: mongoRowDoc control 1
    mongosh documents: nested control 1
    mongosh documents: nested planted 1
    mongosh documents: plain control 1
    mongosh documents: plain planted 1
  mongosh (no network): db.u24_notes.deleteMany({}) -> deletedCount 13
```

### 7 · scoped

```text
  a fresh database on c8u24-pg-h (psql): u24scoped
  the harness's transaction managers: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]
  the harness's stores before: rows in dish 10 · documents in u24_notes 0
  the harness's scoped planted (Dual.scoped, plant yes): caller saw no exception
  the harness's scoped planted: rows 1 · documents 0
  the harness's scoped control (Dual.scoped, plant no): caller saw no exception
  the harness's scoped control: rows 1 · documents 1
  the harness's stores after: rows in dish 12 · documents in u24_notes 1
    ERROR [main] org.springframework.transaction.support.TransactionSynchronizationUtils : TransactionSynchronization.afterCompletion threw exception
  the start's log: TransactionSynchronization.afterCompletion threw exception lines 1
  psql (the harness's PostgreSQL, c8u24-pg-h, database u24scoped): select count(*) from dish -> 12 · the harness's rows (id > 10), by name:
    psql rows: scoped control 1
    psql rows: scoped planted 1
  mongosh (no network, --volumes-from c8u24-mongo-rs): db.u24_notes.countDocuments() -> 1 · by name:
    mongosh documents: scoped control 1
  mongosh (no network): db.u24_notes.deleteMany({}) -> deletedCount 1
```

### 8 · sockets

```text
-- sockets: c8u24-mongo-rs (the harness's replica set, alive since the harness window opened), its /proc/net/tcp, tcp6, udp and udp6 read by cat at the end of the window (dk exec - a file, never a shell):
  its interfaces (/proc/net/dev): eth0,lo
  the sockets: listening (TCP) on 27017 · connections from another local port (outbound): 0 · UDP sockets: 0
```

### 9 · footprint

```text
  the project's containers: tiffinbox-dev-elasticsearch-1 9300/tcp, 127.0.0.1:18884->9200/tcp · tiffinbox-dev-mongo-1 127.0.0.1:18883->27017/tcp · tiffinbox-dev-postgres-1 127.0.0.1:18881->5432/tcp · tiffinbox-dev-redis-1 127.0.0.1:18882->6379/tcp
  the mongo service (a standalone, Part A's flag 6): its command ["--unixSocketPrefix","/data/db"] · no --replSet
  the start's lines: 1 Successfully applied 4 migrations · 1 tiffinbox: dishes re-indexed: rows 10 · documents before 0 · documents after 10
  GET /dishes/search?q=veg (TiffinBox, 20630) -> 200 1 hit(s), ids [1]
  docker stats --no-stream ONCE, the project's four containers by name (the reading is a one-shot value: masked here, printed whole in the receipt's log): tiffinbox-dev-elasticsearch-1 <mem> · tiffinbox-dev-mongo-1 <mem> · tiffinbox-dev-postgres-1 <mem> · tiffinbox-dev-redis-1 <mem> · the four together <MiB> MiB · the VM total <GiB> GiB (MemTotal of the engine 8394457088 B) · TiffinBox rss <kB> kB
  the containers docker stats listed: 4 of the project's · others (not this unit's, never summed): 1
  then: the project's containers 0 · the mongo service's two anonymous volumes: gone gone
  the receipt removes the mongo service's two by the names its container listed (dk volume rm): volumes back to the count before the window · listening on 18881-18884: 0
```

### 10 · default

```text
  GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
  GET /dishes/search?q=veg -> 404 · GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 · GET /kitchen -> 200
  its log: lines naming 9200 0 · naming elasticsearch, any case 0 · naming 27017 0 · naming mongo, any case 0 · Flyway: Successfully applied 4 migrations
  the jar it ran (after/'s) and before/'s, md5 (flag 11 - the README is not in the jar): equal · BOOT-INF/lib 146 and 146
```

### 11 · seven

```text
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20637 now: 0
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20630 now: 0
  the seven, after/ against before/: lines that differ: 0
```

### 12 · exercise

```text
    the lab's transaction managers: [mongoTransactionManager] -> [MongoTransactionManager]
    the lab's plain call: caller caught NoSuchBeanDefinitionException: No bean named 'transactionManager' available: No matching TransactionManager bean found for qualifier 'transactionManager' - neither qualifier match nor bean name match!
    the lab's plain: rows 0 · documents 0
    check: the bean list [mongoTransactionManager] -> [MongoTransactionManager] · rows (psql) 0 · documents (mongosh, no network) 0 · solved: no
    the lab's transaction managers: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]
    the lab's plain call: caller saw no exception
    the lab's plain: rows 1 · documents 1
    check: the bean list [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager] · rows (psql) 1 · documents (mongosh, no network) 1 · solved: yes
    the lab's transaction managers: [mongoTransactionManager] -> [MongoTransactionManager]
    the lab's plain call: caller caught NoSuchBeanDefinitionException: No bean named 'transactionManager' available: No matching TransactionManager bean found for qualifier 'transactionManager' - neither qualifier match nor bean name match!
    the lab's plain: rows 0 · documents 0
    check: the bean list [mongoTransactionManager] -> [MongoTransactionManager] · rows (psql) 0 · documents (mongosh, no network) 0 · solved: no
    the lab's transaction managers: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager]
    the lab's plain call: caller saw no exception
    the lab's plain: rows 1 · documents 1
    check: the bean list [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager] · rows (psql) 1 · documents (mongosh, no network) 1 · solved: yes
  rename run 1 - the block's exit 0:
    the lab's transaction managers: [transactionManager] -> [MongoTransactionManager]
    the lab's plain call: caller saw no exception
    the lab's plain: rows 0 · documents 1
    check: the bean list [transactionManager] -> [MongoTransactionManager] · rows (psql) 0 · documents (mongosh, no network) 1 · solved: no
  rename run 2 - the block's exit 0:
    the lab's transaction managers: [transactionManager] -> [MongoTransactionManager]
    the lab's plain call: caller saw no exception
    the lab's plain: rows 0 · documents 1
    check: the bean list [transactionManager] -> [MongoTransactionManager] · rows (psql) 0 · documents (mongosh, no network) 1 · solved: no
  rename run 3 - the block's exit 0:
    the lab's transaction managers: [transactionManager] -> [MongoTransactionManager]
    the lab's plain call: caller saw no exception
    the lab's plain: rows 0 · documents 1
    check: the bean list [transactionManager] -> [MongoTransactionManager] · rows (psql) 0 · documents (mongosh, no network) 1 · solved: no
```

## Which store, which profile, which tree

Every count this README names is one store's answer, and which one is said each time. The harness's two: its replica set
`c8u24-mongo-rs` on `127.0.0.1:20635` (MongoDB by the digest, `--replSet rs0`, a fixed `--hostname`, `--bind_ip_all` inside the
container, initiated by the harness JVM through the driver, its one member named `localhost` inside the container — `hello` printed —
and reached by the URI `mongodb://127.0.0.1:20635/tiffinbox`, one seed, no `replicaSet=`), and its PostgreSQL `c8u24-pg-h` on
`127.0.0.1:20636` (the anchor's V1-V4 applied by the harness JVM's Boot start, a fresh database per JVM). The profiles are the
harness's (`mtm`, `mtmnamed`, `both`), never TiffinBox's. TiffinBox's own: `after/` under no profile on H2 for `default` and the
seven (20630; `before/` on 20637); `after/` under "dev" on Compose's four for `footprint` (18881-18884, 20630). The exercise's two are
its own containers on the same two ports (20635, 20636), started and removed by its lines before the harness window opens.

## Refused, named

- A second manager in the anchor (flag 11): measured here as the harness's only; `after/`'s sources are grepped for
  `MongoTransactionManager`, `ChainedTransactionManager` and a replica set — none.
- `ChainedTransactionManager` as a teaching point: it is in the jar, deprecated (`jars`); this unit does not run it.
- XA or JTA: no such store pair here.
- The rename as a solution: refused by `exercise/check.sh` in each of its three runs (`exercise`).
- The next course named by a lesson number, or a verb that promises more than "comes back to" (S8.89): `s824.py`'s XU24.
- A verdict or a ranking beside any store; a duration word (dur8 over this README: 0).

## The repository, and the network

`.m2-demo` is a copy of the course's seed (`_research/m2-seed-c8-s4b`, its file count printed by the receipt); every build is offline
from a copy under `.harness/` (`maven.repo.local` absolute, `-pl tiffinbox-web -am`), and the receipt asserts `.m2-demo` gained no file.
No image is pulled (the four digests asserted present; the images list compared at the end). The only network use is the final
`git push`.

## The folders, the harness and the ports

`harness/src/probe/u24/H24.java` (compiled by `javac` against `after/`'s `BOOT-INF/lib`, not source-launched; the `-cp` is printed),
`s824.py` (the prose gate: s823's blocks carried, md5-asserted by `chk24.py static`, plus XU24), `chk24.py` (one check per capture),
`tree24.py` (tree23's code), `dur8.py` (unit 02's), `logback.xml` (unit 07's). Ports 20630-20639: 20630 TiffinBox `after/`, 20635 the
harness's replica set, 20636 the harness's PostgreSQL, 20637 TiffinBox `before/`; 20631-20634, 20638 and 20639 never bound (this
unit's dev stores are Compose's four, during `footprint` only). Every port asserted free at the start and the end.

## Masks, filters and hygiene

The mask (self-tested at every run) cuts Boot's start and Flyway's execution times, Maven's total, pids, the folders and the home, and
the one-shot memory readings of `footprint`. The receipt counts dur8's words over every capture (0) and refuses a time, a pid, a port
on every interface, the token or the password in any capture.

## Interrupted

SIGINT, sent to the receipt's process group at five points (the scratch driver, foreground, the perl reset): see "Runs of record". At
each: exit `130`, no JVM, no container of this unit's, the volume count and the images as at the start, every port of the unit free,
the captures unchanged.

## The decision this unit hands forward

The promise ledger's row C8-20 held the roadmap's plan for the outbox as a plan, not yet a spoken promise. This unit makes it one, with
ONE sentence, pinned (S8.89), its md5 asserted by the receipt in `after/README.md` and in `c8-tiffinbox/README.md` (`handoff`), resting
on the roadmap's lines `:64`, `:552`, `:580-581` and `:922` (printed by `handoff`):

Course 13, Messaging and Integration, comes back to this dual write with an outbox, in its section on patterns that matter.

## What differed from the brief

- **The dual-write pair:** a `dish` row (the anchor's `DishEntity`, V4's table) and a document in the harness's own collection
  `u24_notes` (`U24Note`, a record in the harness's package) — the brief's choice; `MenuDay` was not used because its documents are
  dev's fills on a standalone, and the harness's collection keeps the subject to the two writes.
- **The harness is a Spring Boot start of its own** (`@SpringBootApplication` in `probe.u24`, JPA's repository scan limited to
  `DishEntityRepository`, `@EntityScan` of the core package, Elasticsearch's seven auto-configurations excluded on its command line),
  so Boot's own `JpaBaseConfiguration` decides which manager exists — the subject of `mtm`. Unit 22's harness was a plain Spring
  context; this one could not be.
- **The replica set is initiated through the driver** by the harness JVM (`replSetInitiate`, its one member named `localhost` inside
  the container; `hello` polled), as the probe did; unit 20's receipt used mongosh with no network for the initiation. mongosh is this
  unit's second witness only.
- **One JVM per capture run, every repetition inside the capture's three runs:** `dual` calls the eight methods planted and as
  controls in one JVM; the 3/3 is the capture's three runs.
- **The footprint is a one-shot reading:** captured once per run of record and masked in the hashed capture; its numbers are this run
  of record's, printed in the log. The probe's numbers were Mongo as a replica set; these are the shipped standalone.
- **The pinned hand-off sentence trips two carried rules** of the prose gate (R.224's call-back without its title; Part A's C8-20 rule
  that every sentence naming the dual write says "named"). The carried blocks stay byte-equal; `s824.py` skips a line that IS the pinned
  sentence by its md5, and its self-test shows the same sentence refused when it is judged.
- **The exercise's PostgreSQL trusts every connection** (`POSTGRES_HOST_AUTH_METHOD=trust`, published on the loopback address alone,
  removed at the end) so no password stands in a viewer's line; the harness's own PostgreSQL uses a generated password in a 0600 file.
- **Slot map:** 20630 TiffinBox, 20635 the replica set, 20636 the harness's PostgreSQL, 20637 `before/`; the dev stores' 20631-20634
  were not needed (the footprint is Compose's window).
- **The roadmap and the ledger** are read from beside the repository; in a clone elsewhere the receipt reads the author's copies.

## For RED

- The brief's gloss for the script, "one change written to two stores with no transaction that spans both", is refused by unit 22's
  carried XU22 rule ("spans both" without "no manager spans both"): the script stage should check it with `s824.py` before it is voiced.
- The video may say the matrix only as the harness's (every cell "the harness's", the stores named); the readings `s824.py`'s XU24
  refuses (its self-test lists each) stay out of the voice.
- `mtmnamed`'s WARN lines are counted and printed whole: none names the row, the dish table or a transaction.

## Planted faults — each caught

Run after the runs of record and the SIGINT points, alone, each on a scratch copy of a sentence or a capture (never this folder's
files), by a scratch driver; each plant shown failing, each control passing. Its lines, as it printed them:

```log
plant    ChainedTransactionManager makes both writes atomic.            CAUGHT  unit 17: atomic without Lua, MULTI or a one-command name; XFAM_S4B: S4B: the chained manager as a fix (S8.88)
plant    Boot keeps JPA's manager.                                      CAUGHT  XU24: U24: Boot keeps JPA's manager beside Mongo's (mtm: the bean list holds one)
plant    The dual write is solved in unit 21 of course 13.              CAUGHT  R.224: a call-back without its title; C8-20: the dual write said as measured - it is named only
plant    The dual write is solved by the listener.                      CAUGHT  C8-20: the dual write said as measured - it is named only; XFAM_S4B: S4B: the dual write solved here (flag 12)
plant    the pinned hand-off sentence, its full stop made !             CAUGHT  R.224: a call-back without its title; C8-20: the dual write said as measured - it is named only
plant    Under Mongo's manager the two stores commit both or neither.   CAUGHT  XU22: U22: both or neither / a manager that spans both (unit 24's, a replica set's)
plant    Naming Mongo's manager transactionManager fixes it.            CAUGHT  XU24: U24: the misnamed manager called a fix or safe (S8.96: the row lost, no exception)
control  The harness plants a failure after both writes under JPA's man passes
control  Still two commits, one after the other.                        passes
control  ChainedTransactionManager is in the jar, deprecated, and this  passes
plant    the hand-off sentence off by one byte -> md5                   CAUGHT  c9ffb15da8b016d30dfd2f2283ae5d33
plant    handoff capture with the off-by-one md5 -> chk24 handoff       CAUGHT  FAIL printf '%s' sentence | md5 = a6581dab7e33c458146b1f0e9cb114bc; FAIL after/README.md holds the sentence once, byte f
plant    mtm: Boot keeps JPA's manager (bean list with both)            CAUGHT  FAIL the bean list: [mongoTransactionManager] -> [MongoTransactionManager] - Boot made no JPA manager
plant    mtm: the exception's message cut                               CAUGHT  FAIL the plain call: NoSuchBeanDefinitionException, quoted whole
plant    mtmnamed: documents 1 -> 0 (no plant)                          CAUGHT  FAIL mtmnamed plain: the harness's Java rows / documents 0 / 0 = psql 0 / mongosh 1; FAIL no plant rows 0 / documents 1;
plant    mtmnamed: a WARN line naming the dish table                    CAUGHT  FAIL none of them names the row, the dish table, a transaction or an insert
plant    dual: jpaRowDoc planted rows 0 -> 1                            CAUGHT  FAIL jpaRowDoc planted: the harness's Java rows / documents 1 / 1 = psql 0 / mongosh 1; FAIL jpaRowDoc, planted after bo
plant    dual: psql's witness disagrees (mongoRowDoc planted)           CAUGHT  FAIL mongoRowDoc planted: the harness's Java rows / documents 1 / 0 = psql 2 / mongosh 0; FAIL the totals: psql 11 rows
plant    dual: mongoDocRow planted 0/0 -> 0/1                           CAUGHT  FAIL mongoDocRow planted: the harness's Java rows / documents 0 / 1 = psql 0 / mongosh 0; FAIL mongoDocRow, planted betw
plant    scoped: the listener 'solves' it, 1/0 -> 1/1                   CAUGHT  FAIL scoped planted: the harness's Java rows / documents 1 / 1 = psql 1 / mongosh 0; FAIL planted in the listener: the c
plant    scoped: the afterCompletion line deleted                       CAUGHT  FAIL Spring's afterCompletion threw exception line: 1
plant    both: @Primary missing                                         CAUGHT  FAIL each manager's class; JPA's @Primary
plant    jars: ChainedTransactionManager not deprecated                 CAUGHT  FAIL ChainedTransactionManager: Deprecated: true, @java.lang.Deprecated
plant    default: 404 -> 200 on /dishes/search                          CAUGHT  FAIL 404 x3, 200, 200
plant    default: the jars differ                                       CAUGHT  FAIL after/'s jar = before/'s, md5
plant    footprint: mongo a replica set                                 CAUGHT  FAIL the mongo service: a standalone (no --replSet)
plant    sockets: an outbound connection                                CAUGHT  FAIL the replica set's container: listening on 27017, outbound 0, UDP 0
plant    seven: a wrong expected md5                                    CAUGHT
control  chk24 mtm on the shipped capture                               passes
control  chk24 mtmnamed on the shipped capture                          passes
control  chk24 both on the shipped capture                              passes
control  chk24 dual on the shipped capture                              passes
control  chk24 scoped on the shipped capture                            passes
control  chk24 jars on the shipped capture                              passes
control  chk24 default on the shipped capture                           passes
control  chk24 footprint on the shipped capture                         passes
control  chk24 sockets on the shipped capture                           passes
plants 25, caught 25 · controls 12, passed 12
```

The rename "solution" is the exercise's own plant (`exercise`, refused in each of its three runs); a wrong `before` link, a moved
tree and a start pin that fails are the receipt's own gates (`pin`, `R.211`) - a fault there stops the receipt with exit `1` before
anything is written (the receipt's output goes to a file, never through `tee`, so a failing pin is the run's exit).

## The ledger rows this unit pays

- C8-20 — the hand-off, pinned (above); roadmap `:355`'s "the dual-write problem named" — named, and handed forward by section.
- Part A's CARRIED two-manager question — measured (`mtm`, `mtmnamed`, `both`, `dual`, `scoped`).

## The values the video may say

<!-- values: begin -->
exercise: broken [mongoTransactionManager] rows 0 documents 0 solved no; solved [transactionManager, mongoTransactionManager] rows 1 documents 1 solved yes; rename [transactionManager] -> [MongoTransactionManager] rows 0 documents 1 solved no 3/3 · jars: @Bean + @ConditionalOnMissingBean(value = [TransactionManager.class]) on JpaBaseConfiguration.transactionManager; ChainedTransactionManager 7674 B, Deprecated: true · handoff: the hand-off sentence md5 a6581dab7e33c458146b1f0e9cb114bc, roadmap :64 :552 :580-581 :922, ledger C8-20 · mtm: [mongoTransactionManager] -> [MongoTransactionManager]; NoSuchBeanDefinitionException: No bean named 'transactionManager' available; rows 0 / documents 0 · mtmnamed: [transactionManager] -> [MongoTransactionManager]; no plant: caller saw no exception, rows 0 / documents 1; planted: IllegalStateException, 0 / 0; WARN lines 2, none naming the row · both: [transactionManager, mongoTransactionManager] -> [JpaTransactionManager, MongoTransactionManager], JPA's @Primary · dual: planted: plain 0/1, jpaRowDoc 0/1, jpaDocRowAfter 0/1, jpaDocRow 0/1, mongoRowDoc 1/0, mongoDocRowAfter 1/0, mongoDocRow 0/0, nested 0/1; every control 1/1 · scoped: planted in the AFTER_COMMIT listener: rows 1 / documents 0, the caller saw no exception; control 1 / 1 · sockets: listening 27017, outbound 0, UDP 0; interfaces eth0,lo · footprint: four containers, Mongo a standalone; the reading in the run's log · default: health 200, 404 x3, 0 Elasticsearch / 0 MongoDB lines, the two jars md5-equal, BOOT-INF/lib 146 · seven: 7 lines, md5 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/
<!-- values: end -->

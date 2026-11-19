# c8-unit16 — Pub/Sub and Streams

Course 8, Section 3's third unit and **Section 3's third change to the anchor (C3)**. `before` is a link to `../c8-unit15/after`
(unit 15's tree; the receipt pins it and asserts that pin is unit 15's own after-tree line); `after/` is this unit's tree, and
`../c8-tiffinbox` equals `after/` from this unit's commit on. Redis has two ways to hand on a kitchen event. Pub/Sub hands a message to
whoever listens now and keeps nothing: the publisher learns how many received it, and a subscriber that connects afterwards hears only
what is published afterwards. A stream keeps every entry, and a consumer group — readers of one stream that share its entries and each
remember what they have not acknowledged — remembers what each consumer was given and did not acknowledge, so a consumer that dies leaves
its entries in the group's pending list, and another consumer takes them by claiming them. Under the profile "dev" TiffinBox now writes
one stream entry for every customer `add` stores, after the commit.

Every Redis number below comes from two witnesses in the same run (R.398): **Java's answer** — the harness's publisher, subscriber,
consumers and listener container through Spring Data Redis, or the running TiffinBox's own `StringRedisTemplate` over the stream its
`KitchenEvents` writes — and **redis-cli inside the Redis container** (`docker -H "$DH" exec`, the image's own client, never a host
install), run while a JVM waits at a pause; `psql` reads the table beside the stream, and `MONITOR`, a second client of the container's
own, shows the listener container's commands. Redis is **Redis 8.10.3, by the digest** (`redis@sha256:7958cfbb…935c3`, `--pull never`,
`127.0.0.1` only, no password); PostgreSQL is 18.6 by the capstone's digest. Every line names its tree, its profile and **whose write**
(R.392, R.413): **16/after, profile dev, PostgreSQL + Redis — the anchor's `KitchenEvents`** (TiffinBox's own start through its
application class, one `POST /customers` per start), **16/after's classes — the harness's publisher, subscriber, consumers c1 / c2 and
listener container c3** (a Redis-only harness JVM; the harness's entries are `entry-1` … `entry-10`, its trim's `t1` … `t1000`, never TiffinBox's),
**redis-cli on the unit's Redis**, or **16/after, default run, H2, no Redis**. Pub/Sub, the group, the SIGINT'd consumer, the claim and
the listener container are the harness's (⚑7); the stream key and its writer are the anchor's.

Ten captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `exercise` and the
tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string below is asserted
after its capture by `harness/chk16.py` against a second witness of the same run. Evidence by a Claude Opus 5.5 agent on 2026-11-19,
started 11:07 CET.

## Runs of record

**On the script as committed:** `bash receipts.sh` (Homebrew bash 5.3.9, 2026-11-19 from 11:48:29 CET, ended 11:53:08), `./receipts.sh`
(/bin/bash 3.2.57, from 11:54:42, ended 11:59:18) and a sealed fresh clone (below, at `84c9342`, from 12:23:51, ended 12:28:42): each with every capture = published
(the JVM ones 3/3 inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file count unchanged, volumes back to
their count and the images unchanged, `before/` and `after/` = their pins at the start and the end, nothing listening on 20550-20559 at
the end, each log ending `exit 0`; each log through `check_unit8.py 16 --runlog` — `RESULT (run logs): PASS` (the unit gate itself has
no unit 16 script yet, as expected). **Nothing was downloaded.** One more full run went to its end: the interruption driver's first
marker never matched (it looked for a module name in the wrong case), so the signal never came and `bash receipts.sh`, started with
SIGINT reset by `perl`, ran from 12:00:19 to its end, every capture = published; the marker was fixed for the interruptions. Earlier runs
during the script's writing stopped on checks of this unit's own making (a placeholder pattern that matched `XPENDING`, a `docker` word in
an echo, a check that read the harness's own header naming its consumer as a claim, an empty pending summary's blank lines); the last of them printed every
capture's hash, written into `receipts.md5`. The planted faults and the interruptions ran after the two runs of record, alone.

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at this unit's commit (`84c9342`, before the commit was amended with these times) into a path **with a space**
(`…/sealed 16/tiffinbox-java`, in the session's scratch folder), the clone's `.m2-demo` a file copy of the seed, `env -i` with `HOME`,
`PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin` and `DOCKER_CONFIG=$HOME/.docker`; `./receipts.sh`. The runs ran on
this README before its *Runs of record*, *Interrupted* and *Planted faults* paragraphs were written; the prose gate and the text-block
and values checks were run again on the final README against the last run's printed lines.

## C3 — the change, file by file, and every README/YAML/Javadoc/compose sentence it rewrote or noted (R.250)

`diff -rq before/ after/` (the receipt prints it): **one file new, three changed, nothing gone.**
- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenEvents.java` — **new**. `@Component @Profile("dev")`, package-private, no public
  API. It takes Boot's own `StringRedisTemplate` — the context's only one, `stringRedisTemplate` (the run prints the bean names), the
  same bean `Leaderboard` takes; `RedisDatastore` and `Leaderboard` declare no template of their own. `void stored(CustomerAdded)` carries
  `@TransactionalEventListener` — `CustomerFeed`'s form, the default phase: after the commit — and calls `RecordId write(CustomerAdded)`,
  which puts `type` (`customer-added`), `name` and `mealType` into a `LinkedHashMap` in that order and writes one entry,
  `opsForStream().add(StreamRecords.mapBacked(fields).withStreamKey("tiffinbox:kitchen-events"))`. `write` is package-private, so the
  test in the same package calls it as a method (⚑14). Its Javadoc, *Course 8, unit 16*: what the stream is (entries Redis keeps, each
  with an id Redis gives it), why the write is after the commit (a refused `add` writes nothing), the dual write in one sentence — a
  customer stored while Redis is down gets no entry: the row commits, the `XADD` fails after it — named, not measured, handed to unit 24
  and to the broker course (C8-20), and why dev-only (⚑4). dur8 over the class: `0` (the receipt's gate); no `delivery-guarantee` word
  (`chk16.py static`).
- `compose.yaml` — the Redis service's notes, in place, ⚑15: one *Course 8, unit 16* sentence after unit 15's — the kitchen stream too is
  Redis's own, and it is the one thing there no start rebuilds: a restart of the container keeps it (the image's save points write
  `dump.rdb` when Redis stops cleanly, and Redis loads it when it starts again), a new container loses it, `XLEN 0` (`persist`); still no
  volume, which would hide that loss. And one *Course 8, unit 16* note beside the "nothing secret" notes: the stream holds an event's
  type, a customer's name and meal type. Comment lines added only; still one volume, Postgres's.
- `tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java` — `@Import({Leaderboard.class, RedisDatastore.class,
  KitchenEvents.class})` (the slice loads templates, not a `@Component`, so the test imports it; the dev profile it already carries is the
  bean's profile — measured: the bean is there, the test passes) and a third test: `write` called with a `CustomerAdded` (no transaction:
  the slice holds no `CustomerRepository` — the after-commit wiring is `anchor`'s capture on PostgreSQL, the test's Javadoc says so),
  then the slice's own `StringRedisTemplate` reads the key's type (`stream`), its length and its one entry, the fields in the order
  written, and the id `write` returned equals the entry's. `mvn -o verify` runs it with the other container tests; the count moves from
  unit 15's `18 + 7` to `18 + 8` — cause: this one test (R.363/R.80); `mvn -o package` still runs the `18` with no Docker.
- `README.md` (the anchor's) — the header gains a *Course 8, unit 16* note and the section gains its unit 16 block, in the unit 15 block's
  shape.

**Untouched, asserted by md5 against `before/`:** `TiffinBoxServer`, `CustomerRepository`, `CustomerAdded`, `CustomerFeed`,
`TiffinBoxProperties`, `Leaderboard`, `KitchenOrder`, `KitchenOrders`, `RedisDatastore`, `RedisCaching`, `KitchenHealthIndicator`,
`KitchenMetrics`, `TiffinBoxApp`, `Dashboard`, `RedisSlice`, `application.yaml`, `application-dev.yaml` and the three `pom.xml` files.
Flyway's V1-V3, no V4; `ddl-auto validate` untouched; Hibernate's schema script = `xcheck.sql` = Course 7's capstone's, byte for byte
(`c7-unit39/xcheck.sql`, `seven`).

**Every sentence C3 makes false or incomplete (R.250), found by grep and read:**
- `compose.yaml`, unit 14's note ("so a new container loses nothing the start does not refill") and unit 15's ("so a new container loses
  nothing the next start does not save again") — true of what they name, incomplete for Redis as a whole since this unit: the unit 16
  sentence follows them in place and names the one thing a new container loses. `chk16.py r250` asserts each is followed by it.
- `compose.yaml`, unit 15's "nor do the kitchen orders" — followed by unit 16's note for the stream.
- Kept, true, untouched — each names `CustomerFeed` as the listener that hears `CustomerAdded` after the commit, and none says it is the
  only one: `CustomerAdded`'s Javadoc ("a listener that asks for the transaction's phase - CustomerFeed's, after the commit - hears it
  only once the row is in the database" — an example, not a list), `CustomerRepository.add`'s ("which CustomerFeed hears after the
  commit"), `CustomerFeed`'s "who tells the feed" paragraph ("none of them tells the feed itself" — still true: `KitchenEvents` tells
  no feed), `TiffinBoxServer`'s ("A stored customer reaches CustomerFeed's listeners through the repository's event"). Under "dev" they
  are now one listener of two, and the core module is not edited for an example that stays true (the prompt allowed a core Javadoc edit
  only for a false sentence). `chk16.py r250` asserts each sentence is there, its file untouched, and that no file names a sole listener.
- `application-dev.yaml`'s notes — unchanged and true: `KitchenEvents` needs Redis only at the `XADD`, after a commit, and under "dev" the
  start already stops without Redis at unit 14's fill (R.413).
- `Found 1 Redis repository interface` — unchanged on every dev start (`anchor`): `KitchenEvents` is a component, not a repository.
- Unit 15's README "Next" ("*Pub/Sub and Streams* (16) moves the anchor next: `KitchenEvents`, the stream bridge under "dev", the compose
  note's third sentence (the kitchen stream, which a new container loses) — the room this unit's note leaves — and `18 + 8`") — not edited
  (unit 15's folder is frozen); done here, as it says.

## The anchor's stream after the start (RE-MEASURE 7) — settled first

`TiffinBoxServer.start()` reads the customers (`repo.findAll()`) and places their orders; it never calls `add`. The seed's four customers
reach the table by Flyway (`V2__seed.sql`, four `INSERT`s), not through `CustomerRepository.add`, so no `CustomerAdded` is published at a
start and **a start writes nothing to the stream** — derived from the sources (`chk16.py static` asserts both), then measured: after the
first start on an empty Redis the stream does not exist (`XLEN 0`, `TYPE none`); one `POST /customers` (the JSON API, c7-unit26's form) →
`201` and the stream gains one entry; the same name again → `409` (the table's `UNIQUE` name refuses it before the publish) and the stream
does not move. **Three starts in a row against the same Redis**, a fresh database each (so each start's seed is the same four rows and the
same name can be stored again): the stream's length after each start is the last start's, and each start's one stored customer adds one
entry — the stream is kept from one start to the next and appended to by `add`, never by a start. Every entry, Java's and redis-cli's,
holds `type customer-added name Asha mealType VEGAN`, the order byte-equal across the three starts (R.411). The compose sentence says what
the run printed: no start rebuilds the stream.

## The container's shutdown order (READ FIRST 13, R.410) — settled first

The probe's listener container logged `RedisConnectionFailureException … Connection closed prematurely` from its poll task after
`container.stop()` returned and the factory closed. The harness's `c3` stops the container, then polls its `Subscription.isActive()`
until it reads `false` (a count, capped — never a sleep the receipt relies on), writes its end marker, and only then does `main` close the
context and with it Lettuce's factory; the Pub/Sub subscriber does the same with `isRunning()` / `isListening()` before `destroy()`.
`chk16.py static` asserts that order in `H16.java`. The Redis harness JVMs log with Logback's own layout at `WARN` — every exception's
class and stack would print — and the receipt counts their logs together after the captures: ERROR 0, `RedisConnectionFailureException`
0, `Connection closed prematurely` 0, and every `WARN` Netty's DNS line on macOS (counted, named). No logger level hides anything.

## The captures — what each one shows

### 1 · anchor — KitchenEvents' stream, three starts in a row, the refused add, the tests, the versions (C3, RE-MEASURE 7, 11)

16/after, profile dev, PostgreSQL + Redis — the anchor's `KitchenEvents`; the overrides on every dev JVM are printed (Compose off, Redis
at `127.0.0.1:20552`, the datasource from the config tree, the password never on a command line). The first block: the start's
strict-mode lines (unchanged), the bean, the template, the versions (R.246), the start's own numbers (unit 14's and 15's, unchanged).

```text
-- after/ under the profile dev, on PostgreSQL 18.6 + Redis 8.10.3 (both containers, by the digest), three starts in a row against one Redis, a fresh database each - KitchenEvents' writes:
the overrides on every dev JVM: --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20552 --logging.level.tiffinbox=INFO (Compose off: no Compose run; the datasource from the config tree, the password never on a command line)
log: Found 1 Redis repository interface
log: Found 1 JPA repository interface
log: Found 1 JDBC repository interface
log: HHH000001: Hibernate ORM core version 7.4.13.Final
log: tiffinbox: orders cooked:  120
log: tiffinbox: kitchen value:  24300
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data JDBC 4.1.2 · Spring Data Redis 4.1.2 · Lettuce 7.5.2.RELEASE/5728917 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
PROBE KitchenEvents beans 1 [kitchenEvents=com.tiffinbox.web.KitchenEvents @Profile[dev]] (profile dev, PostgreSQL 18.6)
PROBE StringRedisTemplate beans [stringRedisTemplate] (profile dev, PostgreSQL 18.6)
PROBE Redis's INFO server, through the connection: redis_version:8.10.3
the Redis container's own client: redis-cli 8.10.3 · INFO server: redis_version:8.10.3
SCARD kitchen-order 120 · ZCARD tiffinbox:leaderboard 4 (unit 14's and 15's, unchanged by unit 16)
```

The stream, start by start — each start's three reads by Java (the running context's `StringRedisTemplate`), redis-cli and psql, the
API's two statuses between them (`201`, then `409` for the same name), and the third start ended by SIGINT at its hold:

```text
-- start 1 of 3:
PROBE stream (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate - KitchenEvents' writes): XLEN 0 · TYPE none · entries []
PROBE add (profile dev, PostgreSQL 18.6): POST /customers {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEGAN"} -> 201
PROBE stream (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate - KitchenEvents' writes): XLEN 1 · TYPE stream · entries [<id> type customer-added name Asha mealType VEGAN]
PROBE add (profile dev, PostgreSQL 18.6): POST /customers {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEGAN"} -> 409
PROBE stream (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate - KitchenEvents' writes): XLEN 1 · TYPE stream · entries [<id> type customer-added name Asha mealType VEGAN]
exit 0 · its log, every line but the harness's own PROBE lines: WARN 3 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0 · RedisConnectionFailureException 0
XLEN tiffinbox:kitchen-events: 0 · TYPE tiffinbox:kitchen-events: none · XRANGE tiffinbox:kitchen-events - +: 
psql: customer rows 4 · rows named Asha 0
XLEN tiffinbox:kitchen-events: 1 · TYPE tiffinbox:kitchen-events: stream · XRANGE tiffinbox:kitchen-events - +: <id> type customer-added name Asha mealType VEGAN
psql: customer rows 5 · rows named Asha 1
XLEN tiffinbox:kitchen-events: 1 · TYPE tiffinbox:kitchen-events: stream · XRANGE tiffinbox:kitchen-events - +: <id> type customer-added name Asha mealType VEGAN
psql: customer rows 5 · rows named Asha 1
-- start 2 of 3:
PROBE stream (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate - KitchenEvents' writes): XLEN 1 · TYPE stream · entries [<id> type customer-added name Asha mealType VEGAN]
PROBE add (profile dev, PostgreSQL 18.6): POST /customers {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEGAN"} -> 201
PROBE stream (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate - KitchenEvents' writes): XLEN 2 · TYPE stream · entries [<id> type customer-added name Asha mealType VEGAN, <id> type customer-added name Asha mealType VEGAN]
PROBE add (profile dev, PostgreSQL 18.6): POST /customers {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEGAN"} -> 409
PROBE stream (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate - KitchenEvents' writes): XLEN 2 · TYPE stream · entries [<id> type customer-added name Asha mealType VEGAN, <id> type customer-added name Asha mealType VEGAN]
exit 0 · its log, every line but the harness's own PROBE lines: WARN 3 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0 · RedisConnectionFailureException 0
XLEN tiffinbox:kitchen-events: 1 · TYPE tiffinbox:kitchen-events: stream · XRANGE tiffinbox:kitchen-events - +: <id> type customer-added name Asha mealType VEGAN
psql: customer rows 4 · rows named Asha 0
XLEN tiffinbox:kitchen-events: 2 · TYPE tiffinbox:kitchen-events: stream · XRANGE tiffinbox:kitchen-events - +: <id> type customer-added name Asha mealType VEGAN | <id> type customer-added name Asha mealType VEGAN
psql: customer rows 5 · rows named Asha 1
XLEN tiffinbox:kitchen-events: 2 · TYPE tiffinbox:kitchen-events: stream · XRANGE tiffinbox:kitchen-events - +: <id> type customer-added name Asha mealType VEGAN | <id> type customer-added name Asha mealType VEGAN
psql: customer rows 5 · rows named Asha 1
-- start 3 of 3:
PROBE stream (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate - KitchenEvents' writes): XLEN 2 · TYPE stream · entries [<id> type customer-added name Asha mealType VEGAN, <id> type customer-added name Asha mealType VEGAN]
PROBE add (profile dev, PostgreSQL 18.6): POST /customers {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEGAN"} -> 201
PROBE stream (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate - KitchenEvents' writes): XLEN 3 · TYPE stream · entries [<id> type customer-added name Asha mealType VEGAN, <id> type customer-added name Asha mealType VEGAN, <id> type customer-added name Asha mealType VEGAN]
PROBE add (profile dev, PostgreSQL 18.6): POST /customers {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEGAN"} -> 409
PROBE stream (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate - KitchenEvents' writes): XLEN 3 · TYPE stream · entries [<id> type customer-added name Asha mealType VEGAN, <id> type customer-added name Asha mealType VEGAN, <id> type customer-added name Asha mealType VEGAN]
exit 130 · its log, every line but the harness's own PROBE lines: WARN 3 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0 · RedisConnectionFailureException 0
XLEN tiffinbox:kitchen-events: 2 · TYPE tiffinbox:kitchen-events: stream · XRANGE tiffinbox:kitchen-events - +: <id> type customer-added name Asha mealType VEGAN | <id> type customer-added name Asha mealType VEGAN
psql: customer rows 4 · rows named Asha 0
XLEN tiffinbox:kitchen-events: 3 · TYPE tiffinbox:kitchen-events: stream · XRANGE tiffinbox:kitchen-events - +: <id> type customer-added name Asha mealType VEGAN | <id> type customer-added name Asha mealType VEGAN | <id> type customer-added name Asha mealType VEGAN
psql: customer rows 5 · rows named Asha 1
XLEN tiffinbox:kitchen-events: 3 · TYPE tiffinbox:kitchen-events: stream · XRANGE tiffinbox:kitchen-events - +: <id> type customer-added name Asha mealType VEGAN | <id> type customer-added name Asha mealType VEGAN | <id> type customer-added name Asha mealType VEGAN
psql: customer rows 5 · rows named Asha 1
the receipt at pause 4: kill -INT sent to the harness JVM (its pid, read off its own line)
```

| witness | tree, profile, whose write | after the start | after one add (`201`) | after the refused add (`409`) |
|---|---|---|---|---|
| `opsForStream().size` / `XLEN` by redis-cli | 16/after, dev, PostgreSQL + Redis — `KitchenEvents` | the last start's | `+1` | unchanged |
| `XRANGE` by Java and redis-cli | the same | every entry `type`, `name`, `mealType` | one more, the same order | the same |
| psql's customer rows | 16/after, dev, PostgreSQL — the table | the seed's | one more | unchanged |

The tests (once per run of record), the jar's libraries and the five classes:

```text
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
tiffinbox-web/target/surefire-reports-it: absent - no container test ran
passed  aStoredCustomerIsOneStreamEntryRedisReadsInTheOrderWritten
Surefire's Results line: Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
REDIS IT the stream, through KitchenEvents' write: an id given by Redis
REDIS IT the same key, through the slice's StringRedisTemplate: type stream · XLEN 1 · XRANGE's entries 1 · the id the write returned = XRANGE's · fields [type=customer-added, name=Asha, mealType=VEGAN]
after/: 122 libraries · spring-data-redis and lettuce in lib/: lettuce-core-7.5.2.RELEASE.jar spring-data-redis-4.1.2.jar
gained: 0 · lost: 0
the five classes in lib/spring-data-redis-4.1.2.jar (unzip -l): ChannelTopic RedisMessageListenerContainer StreamMessageListenerContainer StreamOffset StreamOperations
```

### 2 · pubsub — fire and forget: receivers 0, then 1, and the late subscriber's list (R.404; the harness's, labelled)

16/after's classes — the harness's publisher JVMs and subscriber JVM on the channel `tiffinbox:kitchen`, redis-cli beside them;
`FLUSHALL` first. Two messages before any subscriber (redis-cli's and the publisher's), the subscriber connects, the receipt polls
`PUBSUB NUMSUB` until it is counted, two more (redis-cli's and the publisher's, run while the subscriber waits at its pause):

```text
redis-cli PUBSUB NUMSUB tiffinbox:kitchen: tiffinbox:kitchen 0 · redis-cli PUBLISH tiffinbox:kitchen early-cli -> 0
PROBE publisher (the harness's, convertAndSend on tiffinbox:kitchen): early-java -> receivers 0
PROBE subscriber (the harness's, a RedisMessageListenerContainer on ChannelTopic tiffinbox:kitchen): listening true · heard so far 0
poll: PUBSUB NUMSUB tiffinbox:kitchen (until the subscriber is counted) -> tiffinbox:kitchen 1, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
redis-cli PUBLISH tiffinbox:kitchen late-cli -> 1
PROBE publisher (the harness's, convertAndSend on tiffinbox:kitchen): late-java -> receivers 1
PROBE subscriber: heard 2 [late-cli, late-java]
PROBE subscriber: the container stopped - isRunning false · isListening false (polled to false before the factory closes)
then redis-cli: --scan 0 keys · PUBSUB NUMSUB tiffinbox:kitchen: tiffinbox:kitchen 0
```

| witness | tree, profile, whose write | before the subscriber | the subscriber counted |
|---|---|---|---|
| redis-cli `PUBLISH` (the integer) | redis-cli on the unit's Redis | `0` | `1` |
| `convertAndSend` (receivers) | 16/after's classes — the harness's publisher | `0` | `1` |
| the subscriber's list | the harness's subscriber | not in it | both, in order |
| `--scan` | redis-cli | nothing of the channel's | nothing of the channel's |

Pub/Sub hands a message to whoever listens now and keeps nothing — said as the receiver count, the list and the empty key space.

### 3 · dropped — the event published before the listener connected (the failure receipt, R.396's negation; control: the stream)

The same channel and the anchor's stream key, one window, `FLUSHALL` first: the early event goes to the channel (redis-cli's `PUBLISH`)
and to the stream (redis-cli's `XADD`, labelled harness-entry) before any reader; then the harness's subscriber connects, is counted, and
nothing more is published:

```text
redis-cli PUBLISH tiffinbox:kitchen early-cli -> 0 · redis-cli XADD tiffinbox:kitchen-events * type harness-entry name early-cli mealType VEG -> <id>
--scan, sorted: tiffinbox:kitchen-events (no key named tiffinbox:kitchen)
poll: PUBSUB NUMSUB tiffinbox:kitchen (until the subscriber is counted) -> tiffinbox:kitchen 1, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
PROBE subscriber: heard 0 []
XLEN tiffinbox:kitchen-events: 1 · XRANGE tiffinbox:kitchen-events - +: <id> type harness-entry name early-cli mealType VEG · --scan, sorted: tiffinbox:kitchen-events
then redis-cli: XLEN tiffinbox:kitchen-events 1 · --scan, sorted: tiffinbox:kitchen-events
```

Three nothings for the channel — the publish's `0`, the subscriber's empty list, no key — beside one entry the stream kept: what
Pub/Sub does not keep, the stream does. Its control is `group` and `anchor`, the stream read back.

### 4 · group — ten entries, c1 read and the harness holds it, the claim, the listener container; `XLEN` throughout (the harness's, labelled)

16/after's classes — the harness's entries (`entry-1` … `entry-10`) and consumers on the anchor's key `tiffinbox:kitchen-events`, the
group `kitchen` created by redis-cli (`$ MKSTREAM`); `FLUSHALL` first. The harness's consumer c1 reads, acknowledges, then the harness
holds it — planted (R.406), so the receipt can send SIGINT mid-batch, after the perl reset (exit `130`):

```text
redis-cli XGROUP CREATE tiffinbox:kitchen-events kitchen $ MKSTREAM -> OK · XLEN tiffinbox:kitchen-events: 0 · XINFO GROUPS: name kitchen · consumers 0 · pending 0 · entries-read (nil)
PROBE add10 (the harness's entries, ten XADDs, a LinkedHashMap each): ids [<id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>, <id>] · XLEN by Java 10
redis-cli XLEN tiffinbox:kitchen-events: 10 · XRANGE's first entry: <id> type harness-entry name entry-1 mealType VEG
PROBE c1 (the harness's consumer, group kitchen): read 5 [<id>, <id>, <id>, <id>, <id>] · acknowledged 2 [<id>, <id>]
PROBE hold (the harness holds c1, mid-batch, planted): pid <n>
XPENDING tiffinbox:kitchen-events kitchen: 3 <id> <id> c1 3 · XLEN tiffinbox:kitchen-events: 10
the receipt at pause 1: kill -INT sent to the harness JVM (its pid, read off its own line)
exit 130 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0 · RedisConnectionFailureException 0
redis-cli XPENDING tiffinbox:kitchen-events kitchen: 3 <id> <id> c1 3
redis-cli XPENDING tiffinbox:kitchen-events kitchen - + 10: <id> c1 <idle> 1 <id> c1 <idle> 1 <id> c1 <idle> 1
redis-cli XINFO CONSUMERS tiffinbox:kitchen-events kitchen: name c1 pending 3 idle <n> inactive <n> · XLEN tiffinbox:kitchen-events: 10
```

The harness's consumer c2 takes c1's pending entries by claiming them (`Duration.ZERO` as the minimum idle time — the constant's name,
no unit spoken) and acknowledges them; then the harness's listener container c3 (`StreamMessageListenerContainer.receive`, no auto-ack,
the listener acknowledges each), with `MONITOR` up:

```text
PROBE c2 (the harness's consumer): the pending list by Java before the claim: total 3 · per consumer {c1=3}
PROBE c2: c1's pending ids 3 · claimed 3 [<id>, <id>, <id>] (min-idle-time Duration.ZERO) · acknowledged 3
PROBE c2: the pending list by Java after: total 0 · per consumer {} · XLEN by Java 10
redis-cli XPENDING tiffinbox:kitchen-events kitchen: 0 · XLEN tiffinbox:kitchen-events: 10
PROBE c3 (the harness's StreamMessageListenerContainer, consumer c3, no auto-ack, the listener acknowledges each): received 5 [entry-6, entry-7, entry-8, entry-9, entry-10] · acknowledged 5
PROBE c3: the container stopped, its subscription polled to inactive (isActive false, running false) - then the factory closes
MONITOR's lines between the two markers, each line's unix-time prefix and [0 <client>] stripped: XREADGROUP lines, their distinct forms: "XREADGROUP" "GROUP" "kitchen" "c3" "BLOCK" "<n>" "STREAMS" "tiffinbox:kitchen-events" ">" · XACK lines 5, their form: "XACK" "tiffinbox:kitchen-events" "kitchen" "<id>"
redis-cli XPENDING tiffinbox:kitchen-events kitchen: 0 · XINFO GROUPS: name kitchen · consumers 3 · pending 0 · entries-read 10 · XLEN tiffinbox:kitchen-events: 10
```

| witness | tree, profile, whose write | added | the harness's c1 read / acknowledged | pending | claimed, acknowledged | the harness's c3 | the end |
|---|---|---|---|---|---|---|---|
| Java (`add10`, `read`, `acknowledge`, `pending`, `claim`, the container) | 16/after's classes — the harness's | `10` | `5` / `2` | `3`, all c1's | `3`, `3` | `5` received and acknowledged | `XLEN 10` |
| redis-cli (`XLEN`, `XPENDING`, `XINFO`, `MONITOR`) | redis-cli on the unit's Redis | `10` | — | `3` (the harness's `c1 3`) | `0` | `XREADGROUP … BLOCK <n>`, `5` `XACK` | `XLEN 10`, `XPENDING 0` |

An acknowledged entry is not removed: it leaves the group's pending list and stays in the stream.

### 5 · pending — the entries a dead consumer leaves, until a claim (the failure receipt, R.406; control: `group`'s claim)

The same set-up as `group` up to the SIGINT (the harness holds c1, planted); then no consumer runs and the receipt reads the pending
list ten times, a pause of the receipt's between each, labelled "the harness holds". No clean read follows: the claim is `group`'s.

```text
redis-cli XPENDING tiffinbox:kitchen-events kitchen: 3 <id> <id> c1 3
the harness holds, no consumer running: XPENDING's count, ten reads with a pause of the receipt's between each: 3333333333
redis-cli XPENDING tiffinbox:kitchen-events kitchen - + 10: <id> c1 <idle> 1 <id> c1 <idle> 1 <id> c1 <idle> 1
redis-cli XINFO CONSUMERS tiffinbox:kitchen-events kitchen: name c1 pending 3 idle <n> inactive <n> · XLEN tiffinbox:kitchen-events: 10
```

A consumer that dies leaves its entries in the group's pending list; another consumer takes them by claiming them (`group`).

### 6 · trim — `MAXLEN ~ 100` (the harness's thousand entries)

`FLUSHALL` first, so the anchor's key holds the harness's entries alone; both node settings read off the image:

```text
redis-cli CONFIG GET stream-node-max-entries: stream-node-max-entries 100 · CONFIG GET stream-node-max-bytes: stream-node-max-bytes 4096
PROBE trim (the harness's entries, a thousand XADDs, XAddOptions.maxlen(100).approximateTrimming(true): MAXLEN ~ 100): XLEN by Java 100
redis-cli XLEN tiffinbox:kitchen-events: 100 · TYPE tiffinbox:kitchen-events: stream
```

The run printed the number in the block, 3/3, by Java and by redis-cli; "about" is the option's word ("at least" and "exactly" are not
claimed beyond these runs). A stream keeps its entries until it is trimmed, and only on request.

### 7 · persist — a clean restart keeps the stream; a new container does not (S8.52 → R.405, RE-MEASURE 8, ⚑15)

The harness's ten entries and its group on the unit's container, the image's own settings read first; then the container's own restart
(`dk restart`, the receipt's `docker -H "$DH"` call — a clean stop), the receipt polling `PING` until Redis answers; then the container
removed with its volume and a new one run from the same digest on the same port (`--pull never`):

```text
redis-cli CONFIG GET save: 3600 1 300 100 60 10000 · CONFIG GET appendonly: no · INFO persistence: rdb_changes_since_last_save:11 · XLEN tiffinbox:kitchen-events: 10 · DBSIZE: 1
poll: PING (until Redis answers) -> PONG, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
redis-cli XLEN tiffinbox:kitchen-events: 10 · DBSIZE: 1 · XPENDING tiffinbox:kitchen-events kitchen: 0 · INFO persistence: rdb_changes_since_last_save:0
the container's log since the restart: 'Received SIGTERM' 1 · 'Saving the final RDB snapshot before exiting.' 1 · 'DB saved on disk' 1 · 'DB loaded from disk' 1 · 'Ready to accept connections' 1
its line: DB loaded from disk: <t>
c8u16-redis removed with its volumes (rm -fv) · listening on 20552: 0
c8u16-redis: a new container, published 6379/tcp -> 127.0.0.1:20552 · redis-cli XLEN tiffinbox:kitchen-events: 0 · DBSIZE: 0 · EXISTS tiffinbox:kitchen-events: 0 · its log: 'DB loaded from disk' 0
```

| witness | tree, profile, whose write | before | after the restart | a new container |
|---|---|---|---|---|
| Java (`add10`'s `XLEN`) | 16/after's classes — the harness's entries | `10` | — | — |
| redis-cli `XLEN` / `DBSIZE` | redis-cli on the unit's Redis | `10` / `1` | `10` / `1` | `0` / `0` |
| the container's log | Redis's own (`docker -H "$DH" logs`) | — | each of its four lines once | nothing loaded |

A crash (a `kill -9` of the server, with `appendonly no`) was not measured and is not said (CARRIED).

### 8 · default — the default run never needs Redis (R.400, RE-MEASURE 11)

16/after with no profile, H2 in memory, Docker at nothing, Redis's port pointed at 20559 where nothing listens:

```text
PROBE started: yes · default run, H2 2.5.250 · a web server: yes
PROBE KitchenEvents beans 0 [] (default run, H2 2.5.250)
PROBE http (default run, H2 2.5.250): GET /dashboard -> 200
PROBE http (default run, H2 2.5.250): GET /actuator/health -> 200 · status UP
PROBE http (default run, H2 2.5.250): GET /leaderboard -> 404
PROBE noevents (default run, H2 2.5.250): getBeansOfType(KitchenEvents) 0
PROBE add (default run, H2 2.5.250): POST /customers {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEGAN"} -> 201
exit 0 · its log, every line but the harness's own PROBE lines: WARN 2 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0 · RedisConnectionFailureException 0
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

No `KitchenEvents` bean, so the stored customer reaches no stream and nothing touches Redis; the `18` run under `mvn -o package` with
Docker at nothing.

### 9 · seven — the comparison set on before/ and after/ (R.363)

`c5-unit11/curlset.sh` against each jar on the default run, H2 (after/ on 20550, before/ on 20553), and Hibernate's schema script:

```text
exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 · listens on: 127.0.0.1:20553
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 · listens on: 127.0.0.1:20550
GET /dashboard: 200
GET /dashboard: 200
the seven, after/ against before/: lines that differ: 0
```

The two md5s are the published one of `c7-unit31`, asserted by the check (the values line names it); unchanged from unit 15.

### 10 · exercise — run as written, in one shell, bash then zsh (R.196)

The brief's line, byte for byte, `23` words (`wc -w`, printed by the receipt). Needs Redis: the block starts the pinned image on
`127.0.0.1:20552` and removes it with its volume. The check is `XPENDING`, never the exit — every run exits zero:

```text
the solution's line that differs:
$ perl -e 'alarm 120; exec @ARGV' java -cp ".harness/ex/hc:$L/lib/*" Pending 20552 claim > .harness/ex/c2.log 2>&1; echo "Pending c2: exit $?"; grep -E '^(c2 |the pending list)' .harness/ex/c2.log
```

```text
events added: 5 · c1 read 5 · acknowledged 2 · then c1 stops
redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): 3
c2 read 0 new entries (">") · acknowledged 0
redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): 3 · XLEN tiffinbox:kitchen-events: 5
c2 claimed 3 of c1's pending entries · acknowledged 3
redis-cli XPENDING tiffinbox:kitchen-events kitchen (its count): 0 · XLEN tiffinbox:kitchen-events: 5
the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20552 afterwards: 0 · a container named c8u16-ex: 0
```

README + SOLUTION: `exercise/README.md`, `exercise/SOLUTION.md`; their "What it prints" blocks are asserted against this capture line for
line, in bash (`/bin/bash --noprofile --norc`) and in zsh (`/bin/zsh -f`), each from `env -i`.

## Which store, which profile, whose write

**16/after, profile dev, PostgreSQL + Redis — the anchor's `KitchenEvents`**: `anchor` (the stream's length and entries, psql's rows,
the API's statuses). **16/after's classes — the harness's**: `pubsub` (the publisher JVMs, the subscriber JVM), `dropped` (the subscriber;
the early event and its stream entry are redis-cli's), `group` and `pending` (the harness's ten entries and its consumers c1, c2, c3), `trim` (a thousand entries),
`persist` (the ten entries, then the container's own restart and a new container). **redis-cli on the unit's Redis**: the second witness
everywhere, and the writer of `dropped`'s two early events and every `XGROUP CREATE`. **16/after, default run, H2, no Redis**: `default`,
`seven`, the tests' H2 half. **The exercise's program**: `Pending.java`, its own connection factory, the exercise's own Redis.

## Refused, named

- A crash with `appendonly no` (what a `kill -9` of the server loses): not measured, unsaid (CARRIED).
- The dual write (a customer stored while Redis is down gets no entry): named in `KitchenEvents`' Javadoc, not measured, no capture, no
  number (C8-20 → unit 24 and the broker course, whose *Choosing a Broker* comes first).
- A volume for Redis in `compose.yaml` (⚑15): a volume would hide what `persist` shows.
- An H2 capture of the dev-only bean (RED #12): the bean is `@Profile("dev")`, dev is PostgreSQL; an H2 run would need a profile pair no
  viewer runs — dropped.
- A `Map.of` writer (R.411): refused — its order moved per JVM in the probe; every writer here (the anchor's, the harness's, the
  exercise's) is a `LinkedHashMap`, asserted.
- A Kafka fact or a ranking (R.405): Kafka's name appears here only beside Course 13's titles — *Choosing a Broker* and *Delivery Guarantees*
  — and nothing of it is measured or ranked here.
- A delivery word (R.404: `guaranteed`, `at-least-once`, `at-most-once`, `exactly-once`, `durable`, `never lost`, `reliable
  delivery`): refused — "nothing kept" is the receiver count and the late subscriber's list; "kept" is `XLEN` and `XPENDING`.
- "Acknowledged" said as "removed": refused — an acknowledged entry is not removed from the stream; `XLEN` stays `10` across every
  acknowledgement (`group`).
- A settle sleep (R.412): every wait on Redis polls a count — `PUBSUB NUMSUB` until the subscriber is counted, `PING` until Redis answers,
  the subscriber's own list until it holds what it should, the listener container's acknowledgements until five, its subscription until
  inactive — with the number of reads printed (`polled <k> times`, masked in the capture because it moves run to run).
- A SIGINT to a JVM without the perl reset (R.410): every JVM the receipt starts runs after `perl -e '$SIG{INT}="DEFAULT"; exec …'`
  (`chk16.py static` names any line without it).
- A container removed without `-v` (R.387); a build that names `-pl` without `-am` (R.391); the docker CLI without its pinned socket
  (R.344).

## Call-backs, by title (R.224)

- Course 8's *Spring Data Redis Repositories* (`java8_series.TITLES["15"]`): `before/`, the kitchen orders the dev start still saves
  (`SCARD kitchen-order` read in `anchor`).
- This unit: *Pub/Sub and Streams* (`java8_series.TITLES["16"]`, `16-pub-sub-and-streams`).
- Forward, by title only: *Distributed Locks and Rate Counters* (17); Course 13's *Choosing a Broker* and *Delivery Guarantees* (the
  roadmap's "the honest difference from Kafka (course 13)" is paid there — C8-23).

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged; under "dev" each customer it stores becomes one entry of `tiffinbox:kitchen-events` in the Redis Compose starts
beside Postgres.

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s3` (7,102 files); every build reads it offline
(`-o`, `maven.repo.local` as an absolute path), every one `-pl tiffinbox-web -am`, and the receipt asserts its file count unchanged after
each Maven run and Maven's log free of a download line (`offline: yes`). No dependency moves: both `pom.xml` files are untouched, the jar's
libraries are the same list before and after (`anchor`: gained 0, lost 0), and the five classes this unit uses are in the seed's
`spring-data-redis-4.1.2.jar` (`StreamOperations`, `StreamMessageListenerContainer`, `RedisMessageListenerContainer`, `ChannelTopic`,
`StreamOffset` — `unzip -l`, printed). No network of any kind but the commit's push; no image pulled (both digests present at the start,
the image list the same at the end). Testcontainers runs with Ryuk off (`TESTCONTAINERS_RYUK_DISABLED=true`, as unit 15's receipt sets
it) and a receipt home under `.harness/`; its containers are gone after each `verify`, asserted.

## The folders, the harness and the ports

- `harness/H16.java` — the Redis harness JVM: Lettuce's connection factory on `127.0.0.1:20552` and a `StringRedisTemplate`, nothing
  else — no TiffinBox, no web server, no database; the publisher (`pub=MSG`), the subscriber (`sub=N`), the ten entries (`add10`), the
  consumers c1 (read, acknowledge, the planted hold) and c2 (the claim), the listener container c3, the trim. Its log: Logback's layout at
  `WARN`.
- `harness/U16.java` — TiffinBox's application class with its web server, read through the context's own beans and its own JSON API
  (`add=NAME`), the stream read back by the context's `StringRedisTemplate` at each pause.
- `harness/chk16.py` (the checks), `harness/s816.py` (the prose gate, per sentence, with its self-test; XFAM_S2's block byte-equal to
  s814's and s815's, asserted), `harness/tree16.py` (the trees' pins), `harness/variants.py` (`noprofile`, `mapof`, `inside` — the planted
  faults' copies), `harness/surefire.py`, `harness/dur8.py` (as shipped), `harness/logback.xml` (TiffinBox's JVMs) and `c7-unit29`'s
  `probe/x/XMain.java` (Hibernate's script), each copied byte for byte where it says so.
- Ports, 20550-20559: **20550** TiffinBox `after/` (the harness's web server, `default`, the seven) · **20551** the PostgreSQL container ·
  **20552** the Redis container (the exercise's own Redis before it; `persist`'s new container after its `rm -fv`) · **20553** `before/` for
  the seven · **20559** the port "Redis absent" points at on the default run, asserted unbound · **20554-20558** never bound. Nothing
  listens on any of them at the start or the end.

## Masks, filters and hygiene — every one, declared

The captures mask what moves from run to run and every time: Boot's start line, Surefire's and Maven's times, Flyway's execution time,
Testcontainers' `PT…S`, the folders and the home, pids, identity hashes, **a stream id, both parts** (`<id>`: its first part is a time and
its second moves with it — "an id Redis gives it"), `MONITOR`'s `BLOCK <n>` (the container's poll setting) and its unix-time prefix and
client (stripped), `XPENDING`'s idle column (`<idle>`) and `XINFO`'s `idle` / `inactive` (`<n>`), Redis's `DB loaded from disk` time
(`<t>`), and every poll's count (`polled <k> times`). The mask's self-test plants each and refuses a run if one passes. Every capture is
checked for an absolute path, a time, an unmasked id, a block setting, an idle count, a log time, a stack frame, a raw container port,
the token and the password; dur8 over the captures and this README's text blocks: `0` words.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM, Maven, the exercise's shell, the publisher JVM inside a
pause, the MONITOR client's `dk exec` — after Redis itself has dropped that client, `CLIENT KILL ID`), removes its containers with their
volumes (`rm -fv`: PostgreSQL, Redis, the exercise's), removes any Testcontainers container, deletes the partial captures, and exits 130.
Measured 2026-11-19, from 12:06 to 12:22 CET, each run alone, `bash receipts.sh` started by a driver with SIGINT reset to its default
(`perl`, R.410) and SIGINT sent when a marker appeared in the run's own fresh `.harness`: **mid-build** (Maven building `before/`'s core
module), **mid-verify** (Surefire running the tests), **mid-TiffinBox on PostgreSQL** (`anchor`'s first dev start, its first stream read
printed), **mid-subscriber** (`pubsub`'s subscriber JVM up, its container listening), **mid-consumer hold** (c1 held by the harness,
planted), **mid-container** (c3's listener container polling, its `XREADGROUP` on `MONITOR`), **mid-restart** (`dk restart` of the Redis
container under way). Each: exit `130`; read when the run had stopped and again after a pause of the driver's — no java process, no
container of this unit's, no Testcontainers container, no MONITOR client, volumes and images at their counts, nothing listening on
20550-20559, `.r-lock` gone, no partial capture, `receipts.md5` unchanged, the captures' bytes unchanged.

## The ledger rows this unit pays

- The roadmap's "kitchen events" (`anchor`): paid here — one stream entry per stored customer, after the commit, under "dev".
- The roadmap's "the honest difference from Kafka (course 13)": named here by Course 13's titles, *Choosing a Broker* and *Delivery Guarantees*, and **paid in Course 13** (C8-23, open) —
  this unit shows only what Redis did on this run: one stream in one Redis, a group's pending list a second consumer claims, entries kept
  after acknowledgements, trimmed only on request, kept by a clean restart and lost with the container.
- C8-20, the dual write: named in `KitchenEvents`' Javadoc, handed to unit 24 and to Course 13's *Delivery Guarantees*; not measured.

## RE-MEASURE — the plan's items this unit settles

- **7** (`KitchenEvents` on 16/after, the field order; the harness's group on the anchor's stream key): PostgreSQL only (RED #12 — the H2
  half dropped with the reason above); the field order asserted across three starts and three runs; the group's numbers from the
  harness's own entries on `tiffinbox:kitchen-events` (`group`, `pending`).
- **8** (the restart on the receipt's own container, and the new container's zero): `persist`, 3/3 in each run.
- **11** (the seven and `18 + 8` on 16/after; the default run's health and `/leaderboard`): `seven`, `anchor`, `default`.

## The anchor moved — the builders (R.211, R.331)

Before the commit: `grep -n 'c8-tiffinbox\|TiffinBoxServer\|KitchenEvents\|CustomerAdded\|CustomerFeed\|application.yaml\|application-dev.yaml\|compose.yaml\|RedisDatastoreIT\|tiffinbox-web/pom'`
over `_builders/s80*.py`, `_builders/s81*.py`, `check_unit8.py`, `qa_java8.py` and `build_java8.py`, and `grep -n
'compose.yaml\|CustomerAdded\|KitchenEvents'` over every `c8-unit*/receipts.sh` (its hits read in full before the commit; the agent's
report says where they are kept). The builders' live compares (`s801.py`-`s813.py`, between their "R.211 live compare" comments) read
`c8-tiffinbox` only to print a note when the live anchor has moved on; every claim a builder makes reads `git show <its pinned commit>`
or a `c8-unitNN/` path. No shipped receipt reads `c8-tiffinbox`, its `compose.yaml` or `CustomerAdded` live (the grep's matches there are this unit's
own). No builder and no earlier unit was edited — unit 15's grep, the same answer.

## Next

*Distributed Locks and Rate Counters* (17): RE-MEASURE 9 first (`sync` across two JVMs through the anchor's `RedisCaching`, on
`CustomerRepository.findAll()` itself, with no hold and with the labelled hold); the anchor changes by `findAll`'s Javadoc only if that
capture prints its one and two. No `compose.yaml` change: unit 17 adds nothing to the Redis note. The test count stays `18 + 8` unless a
test of a class `src/main` ships lands — the lock and the counter are harness classes.

## What differed from the brief

- **The stream after the start (RE-MEASURE 7).** The brief's hook number `XLEN 1` is the first start's, after one add. Derived, then
  measured: the seed is Flyway's, a start writes nothing, so `XLEN` after a start is the last start's length — 0 on an empty Redis — and
  three starts against one Redis print the progression above. The compose sentence says "no start rebuilds it", which the run prints.
- **A fresh database per start.** Three starts on one database would store the name once and refuse it twice; each start gets a new
  database by psql (`u16a1`…`u16a3`), so each start's seed and each start's add are the same, and the stream alone carries over.
- **The stream id's mask.** The brief's `<ms>-<seq>` is itself a dur8 word (`ms`), and the second part of an id moves with the time
  (two entries in one tick share it) — the capture would drift. Both parts are masked, `<id>`; the voice says "an id Redis gives it".
- **`trim` on small values.** With the group's entry shape (`harness-entry`, `entry-<n>`, three meal types) five scratch runs printed
  `120`, `120`, `122`, `120`, `119`: a stream node also closes at `stream-node-max-bytes 4096`, and the ids' sizes move. With small values (`t<n>`, `VEG`) a node holds a hundred entries by count and the thousand `XADD`s print `100`, five scratch runs and 3/3 in every
  run of record. "About" is the option's word; the capture prints both node settings.
- **`dropped` is its own window.** The early event goes to the channel AND to the stream (both by redis-cli) before the subscriber
  connects; the subscriber is counted (`NUMSUB 1`), hears nothing, and the stream holds the one entry — three nothings beside one entry.
- **`XGROUP CREATE` by redis-cli**, the receipt's; the ten `XADD`s are the harness's (`opsForStream().add`, a `LinkedHashMap`).
- **`pending`'s hold is the receipt's ten reads**, unit 15's `nolisten` form: `XPENDING`'s count read ten times with a pause of the
  receipt's between each and no consumer running; no clean read follows (group's claim is the control).
- **The Pub/Sub publisher inside a pause** is its own JVM, run by the receipt while the subscriber JVM waits at its pause.
- **The exercise's program needs no Spring context**: `Pending.java` builds Lettuce's factory itself; the died consumer is a JVM that
  exits after acknowledging two of five — no signal needed.
- **The IT imports `KitchenEvents`**, expected and measured: the slice leaves out a `@Component`; with the import under the dev profile the
  bean is there and the third test passes.
- **The `inside` plant is caught by `static`, not by `anchor`'s numbers.** The plan expected a writer that hears `CustomerAdded` inside
  the transaction (`@EventListener`) to write an entry for the refused add. Measured once on that copy (`variants.py inside`, PostgreSQL
  + Redis, 1/1): the refused add wrote none there either — the `INSERT` runs when `save` is called (the row's id comes from the
  database), the duplicate name is refused there, and `add` never reaches its publish. What the after-commit phase adds on this anchor is
  the case of a rollback after the publish, which `add` does not have; it is not measured here.
- **No core Javadoc edit**: `CustomerAdded`'s sentence names `CustomerFeed` as an example and stays true (R.250 list above).

## For RED

- The two Pub/Sub JVMs and the subscriber's list: the subscriber reads its own list until it holds what the receipt published after it
  was counted (a count, capped); were a message to arrive past the cap, `heard` would print fewer and `chk16.py` would fail — none did.
- c1 is SIGINT'd while the harness holds it (planted, labelled in its own line and in the capture's header), after its read and its two
  acknowledgements returned: the three pending entries are the batch's own, not a race.
- `XPENDING`'s summary and extended forms are redis-cli's; the extended form's delivery count (`1` each) is read, its idle column masked.
- `MONITOR`'s lines are taken between the harness's two `ECHO` markers; the container's `XREADGROUP` count varies with its poll setting
  and is printed as its one distinct form, `BLOCK <n>` masked; the `XACK`s are counted off the lines.
- `persist` reads the container's log from the line after its length before the restart, so earlier windows' log lines never count.
- Every `WARN` beyond Netty's line is printed and named: PostgreSQL's two lines for the refused name (`23505`) on each dev start, Flyway's
  H2-version line on the default run.

## Planted faults — each caught (R.65, R.226)

Each plant ran alone — never beside a run of record — after the two runs of record in this folder: a doctored capture or a copy of
`after/` checked by `chk16.py` (Python, never `sed`), a planted sentence on a copy of this README checked by `s816.py`, or a planted file
in a scratch mirror of this folder checked by the mirror's own `receipts.sh`, which must stop at its gate. Each plant exited 1, naming
its rule; each control — every capture as captured, `static` and `r250` on `after/`, this README and the exercise as written — exited
0; nothing in this unit was written (every mirror gate run left no `.harness` and no `.r-lock`). Forty-one plants, all caught; thirteen
controls clean.

- **The plan's list for unit 16:** `Pub/Sub guarantees delivery` (R.404); acknowledged entries said as removed, which they are not — the sentence, and
  `group`'s `XLEN` after the acknowledgements doctored from `10` to `7` (both witnesses no longer agree); a sentence likening Redis to Kafka (R.405); a `Map.of`
  writer — `variants.py mapof` (`static`: the `LinkedHashMap` order check) and the sentence (R.411); `kill -INT` without the perl reset — a
  copy of `receipts.sh` whose Redis harness launch lost its reset (`static` names the line, R.410); the listener container's factory closed
  before the drain — a copy of `H16.java` without the subscription poll (`static`); `KitchenEvents` without `@Profile("dev")` —
  `variants.py noprofile` (`static`), and `default`'s bean count doctored from `0` to `1`; a writer that publishes inside the transaction —
  `variants.py inside` (`static`) and **measured once on PostgreSQL + Redis, 1/1: the refused add wrote no entry there either** (see *What
  differed*); a settle sleep behind the `NUMSUB` poll — a copy of `receipts.sh` (`static` names the line, R.412).
- **Doctored captures:** `heard 2` → `heard 3` and the early message added to the list (`pubsub`); `XPENDING 3` → `0` (`pending`);
  `100` → `1000` (`trim`); the new container's `XLEN 0` → `10` and the `DB loaded from disk` line deleted (`persist`); a field order swapped
  in one entry, the refused add's `XLEN` incremented, the `HHH000001` line deleted, Boot's version and `redis_version` moved (`anchor`); the
  seven's hash; the exercise's solved block made the broken one, and a "What it prints" count changed (R.196).
- **The prose gate:** besides the plan's sentences — a fall-over word for the consumer the harness holds and the receipt signals and a SIGINT sentence without the hold's
  label (R.406); a loss word for the early message (R.404); the C8-20 sentence given a measurement; a stream id with its time part (R.402); a wait word
  behind the poll (R.412); a duration word (dur8); `expires` (XFAM_S2); a typed number (R.302); a harness consumer without its label
  (R.392); `durable` (R.404).
- **The mirror's gates:** a dish name (R.215); a placeholder; `before` linked to unit 14's tree (R.211); the after-tree pin changed (a
  wrong hash, R.211); a container removed without `-v` (R.387); a bare `docker` call (R.344); the solution's "What it prints" line taken
  out; and `compose.yaml` without its unit 16 sentence (`r250`, R.250).

## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: the line 23 words · broken (c2 reads with ">"): c2 read 0, XPENDING 3 by redis-cli and Java, XLEN 5 · solved (c2 claims, min-idle-time Duration.ZERO, and acknowledges): claimed 3, acknowledged 3, XPENDING 0, XLEN 5 · exit 0 both (a standalone program on the anchor's libraries, Redis by the digest, no TiffinBox, no database) · anchor: 16/after, profile dev, PostgreSQL + Redis, KitchenEvents' writes, three starts against one Redis (a fresh database each): XLEN after the start 0/1/2 · after one POST /customers (201) 1/2/3 · after the refused one (409) 1/2/3 · psql 4 -> 5 -> 5 each start · TYPE stream · every entry type customer-added name Asha mealType VEGAN, the order byte-equal across the starts · Found 1 JPA / 1 JDBC / 1 Redis repository interface · orders cooked = SCARD kitchen-order 120 · health 200 · /dashboard 200 · /leaderboard 200 · the third SIGINT -> exit 130 · tests 18 (mvn -o package, no Docker) and 18 + 8 (mvn -o verify) · libs 122 -> 122 (none gained) · Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/JDBC/Redis 4.1.2 · Lettuce 7.5.2.RELEASE · HHH000001 7.4.13.Final · Flyway 12.4.0 · redis_version:8.10.3 · pubsub: the harness's, Pub/Sub on tiffinbox:kitchen: no subscriber -> redis-cli PUBLISH 0 and convertAndSend receivers 0 · the subscriber counted (NUMSUB 1) -> 1 and 1 · heard 2 [late-cli, late-java] · --scan 0 keys · dropped: the harness's, one window: the early event's PUBLISH 0, the subscriber's list 0, --scan nothing of the channel's · the same event on the stream: XLEN 1 · group: the harness's, on tiffinbox:kitchen-events: XLEN 10 · c1 read 5, acknowledged 2, the harness holds (planted), SIGINT -> exit 130 · XPENDING 3, all c1's · c2 claimed 3, acknowledged 3 -> XPENDING 0 · c3 (a StreamMessageListenerContainer) received and acknowledged 5, MONITOR XREADGROUP … BLOCK <n> and 5 XACK · XLEN 10 throughout · pending: the harness's, the SIGINT'd c1 (planted hold): XPENDING 3 held across ten reads (3333333333), XINFO CONSUMERS c1 pending 3, XLEN 10 · trim: the harness's thousand XADDs, MAXLEN ~ 100: XLEN 100 by Java and redis-cli, on stream-node-max-entries 100 (stream-node-max-bytes 4096) · persist: the harness's ten entries, the image's defaults (save 3600 1 300 100 60 10000, appendonly no): XLEN 10 -> a restart of the container -> 10 (Saving the final RDB snapshot, DB saved on disk, DB loaded from disk, once each) -> a new container -> 0 · default: 16/after, default run, H2, no Redis, no Docker: health 200 · /leaderboard 404 · /dashboard 200 · KitchenEvents beans 0 · POST /customers 201 with no Redis · no Redis repository line · the 18 under mvn -o package, Docker at nothing · seven: the seven 466c20ed… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · /leaderboard 404 on the default run · Hibernate's script = xcheck.sql
<!-- values: end -->

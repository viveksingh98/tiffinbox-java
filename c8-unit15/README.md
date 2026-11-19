# c8-unit15 — Spring Data Redis Repositories

Course 8, Section 3's second unit and **Section 3's second change to the anchor (C2)**. `before` is a link to `../c8-unit14/after`
(unit 14's tree; the receipt pins it and asserts that pin is unit 14's own after-tree line); `after/` is this unit's tree, and
`../c8-tiffinbox` equals `after/` from this unit's commit on. Under the profile "dev", Redis keeps the kitchen's orders: Spring Data Redis
maps each order to a hash and keeps a set per indexed value beside it — a secondary index, a set per indexed value, holding the ids that
have it — so a derived finder is a set intersection redis-cli can read. And when a hash's time to live ends, those sets stay behind unless
a running repository is listening.

Every Redis number below comes from two witnesses in the same run (R.398): **Java's answer** — the shipped `KitchenOrders` bean (`count()`,
`findAll()`, the finders, `findById`, `existsById`) — and **redis-cli inside the Redis container** (`docker -H "$DH" exec`, the image's own
client, never a host install), run while a harness JVM waits at a pause; the commands themselves are counted off `MONITOR`, a second
client of the container's own, never typed (R.401). Redis is **Redis 8.10.3, by the digest** (`redis@sha256:7958cfbb…935c3`,
`--pull never`, `127.0.0.1` only, no password); PostgreSQL is 18.6 by the capstone's digest. Every line names its tree, its profile and
**whose save** (R.392, R.413): **15/after, profile dev, PostgreSQL + Redis — the start's saves** (TiffinBox's own start, through its
application class), **15/after's classes — the harness's saves through the shipped repository** (three orders, `o1`, `o2`, `o3`, in a
repository-only harness JVM), **15/after, default run, H2, no Redis**, or **a labelled copy** (the planted faults only).

Twelve captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `exercise` and the
tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string below is asserted
after its capture by `harness/chk15.py` against a second witness of the same run. Evidence by a Claude Opus 5.5 agent on 2026-11-19,
started 09:34 CET.

## Runs of record

**On the script as committed:** `bash receipts.sh` (Homebrew bash 5.3.9, 2026-11-19 from 10:23:23 CET, ended 10:30:43), `./receipts.sh`
(/bin/bash 3.2.57, from 10:30:53, ended by 10:37:47) and a sealed fresh clone (below, from 10:48:46, ended 10:55:35): each with every capture = published
(the JVM ones 3/3 inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file count unchanged, volumes back to
their count and the images unchanged, `before/` and `after/` = their pins at the start and the end, nothing listening on 20540-20549 at
the end, each log ending `exit 0`; each log through `check_unit8.py 15 --runlog` — `RESULT (run logs): PASS` (the unit gate itself has
no unit 15 script yet, as expected). **Nothing was downloaded.** The `./receipts.sh` run was started by the interruption driver (below),
`perl` resetting SIGINT to its default before `exec`, whose first marker never matched (it looked for a lower-case module name) — so the
signal never came and the run went to its end as written; it is kept as the bash 3.2 run of record, and the driver's marker was fixed
for the interruptions. Earlier runs during the script's writing stopped on checks of this unit's own making (a pause's lines read at the
wrong indent; `CLIENT KILL TYPE monitor` refused by Redis 8.10.3, fixed by killing the MONITOR client by its id; a causes line read one
link too early); the last of them printed every capture's hash, written into `receipts.md5`. The planted faults ran after the runs of
record, alone — no capture moved.

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `64f247b` into a path **with a space** (`…/sealed
15/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c8-unit15 c8-tiffinbox`; `diff -rq` against the working folder printed nothing), the clone's `.m2-demo` a file copy
of the seed, `env -i` with `HOME`, `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`
and dead proxies for http and https (`127.0.0.1:9`); `./receipts.sh`. The runs ran on this README before its *Runs of record*,
*Interrupted* and *Planted faults* paragraphs were written; the prose gate and the text-block and values checks were run again on the
final README against the last run's printed lines.

## C2 — the change, file by file, and every README/YAML/Javadoc/compose sentence it rewrote or noted (R.250)

Nine files new or changed besides the anchor README; nothing deleted; both `pom.xml` files untouched (Spring Data Redis already holds
`RedisHash`, `TimeToLive`, `Indexed`, `EnableRedisRepositories` and `RedisKeyValueAdapter` — `anchor` lists them off the jar); Flyway's
V1-V3 untouched, `ddl-auto: validate` untouched, Hibernate's schema script still `xcheck.sql` = `../c7-unit39/xcheck.sql` (`seven`); no
jar gained or lost (`anchor`). The receipt asserts `RedisCaching.java`, `TiffinBoxApp.java`, `KitchenMetrics.java`, `Leaderboard.java`,
`KitchenHealthIndicator.java`, `CustomerRepository.java`, `Dashboard.java`, `application-dev.yaml` and the three `pom.xml` byte-equal to
`before/`'s, and `chk15.py static` that the files below are the only ones that moved.

- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenOrder.java` — **new**: `@RedisHash("kitchen-order")`, `@Id String id`, `@Indexed
  String customer`, `@Indexed String mealType`, `int value` (meals times price, the number the leaderboard and `/kitchen` add up) and
  `@TimeToLive Long ttl` — `null` is no time to live, Spring Data's own meaning. A "Course 8, unit 15" Javadoc in the anchor's voice: what
  Redis keeps here that no table holds (an order on the kitchen's rail), the hash and its sets, the time to live the entity carries, why
  dev-only. **Its `toString` prints `KitchenOrder[<id>,<customer>,<mealType>,<value>]` — the time to live left out**, a configured number:
  the captures print an element's `ttl` beside it as `set`, `-1` or `null`, never its value.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenOrders.java` — **new**: `interface KitchenOrders extends
  CrudRepository<KitchenOrder, String>` with `findByMealType`, `findByCustomer` and `findByCustomerAndMealType`; no paging, no `@Query`,
  no `@Reference`.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/RedisDatastore.java` — **new**: `@Configuration(proxyBeanMethods = false)
  @Profile("dev") @EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)`,
  package-private. Its Javadoc: why ON_STARTUP (`stale`), its condition — it removes an index entry when Redis tells it a hash is gone,
  while a TiffinBox under "dev" is running; a time to live that ended while TiffinBox was down leaves the index as it was until the next
  start re-saves those ids (`nolisten`) — why dev-only (`startstop`, `noconfig`), and that the `CONFIG SET` it writes is the server's and
  outlives the JVM (`anchor`).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java` — the constructor takes an **`ObjectProvider<KitchenOrders>`** beside
  the `ObjectProvider<Leaderboard>`; `start()` asks it once and, in the loop that records each order on the leaderboard — the same loop,
  the same order object, the line after `lb.record(order.customer(), order.value())` — saves
  `new KitchenOrder(c.name() + "-" + (day + 1), order.customer(), c.mealType(), order.value(), orderTtl)`. **The ids are the customer and
  the day: `Ravi-1` … `Ravi-30`**, the loop's own counters, the same each start — never a UUID or a clock. The save stays in `start()`,
  not guarded. A "Course 8, unit 15" Javadoc paragraph beside unit 14's, on the class and on `start()`.
- `tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java` — one more component, **`Duration kitchenOrderTtl`** (Boot converts
  a value like the one `application.yaml` ships), no constraint; `TiffinBoxServer` hands the entity its whole number, as Redis's `EXPIRE` takes it, and **absent or zero means an
  untimed save** (`ttl` null). The record's own `toString` names it.
- `tiffinbox-web/src/main/resources/application.yaml` — **`spring.data.redis.repositories.enabled: false`** (a *Course 8, unit 15* comment:
  Boot's own Redis repositories off on the default run, which then prints no Redis repository line at all — `default`; the profile "dev"
  registers `KitchenOrders` itself) and **`tiffinbox.kitchen-order-ttl`** under `tiffinbox:` with its comment (a value written the way the
  cache's backstop is; why that value: every start saves the same ids again, so it only decides when a dev run's orders leave Redis). The
  sentence "under Spring's AOT step fixed when the jar is built" is **not** written for this key: not measured here.
- `compose.yaml` — **three *Course 8, unit 15* notes, comment lines only**: after "no spring.data.redis key anywhere" (now false: one such key
  exists — `spring.data.redis.repositories.enabled`, not the address); after unit 14's "nor does the leaderboard" (nor do the kitchen
  orders); and ⚑15's sentence after unit 14's no-volume note — the kitchen orders too are Redis's own, the start saves each again with the
  same id, so a new container loses nothing the next start does not save again; and a time to live that ends while TiffinBox is down
  leaves their index entries until that start. Still no volume. Room is left for unit 16's stream sentence.
- `tiffinbox-web/src/test/java/slice/RedisSlice.java` — a *Course 8, unit 15* note (R.250): the slice starts no Redis repository since
  (`application.yaml`'s key), and `RedisDatastoreIT` imports `RedisDatastore`.
- `tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java` — `@Import({Leaderboard.class, RedisDatastore.class})` under the
  profile it already carries, "dev", and **one more test on the shipped `KitchenOrders`**: three orders saved (two with a time to live —
  long enough to outlast the test — and one untimed), `findByMealType` and `count()` by the repository, `SMEMBERS
  kitchen-order:mealType:VEG`, `SCARD kitchen-order` and `TYPE` by the slice's own `StringRedisTemplate`. The repository bean appears by
  the import alone: `@DataRedisTest` reads `application.yaml`, so Boot's own Redis repositories stay off in the slice, and `RedisDatastore`
  registers `KitchenOrders` under "dev" — no test property needed. Its listener writes `CONFIG SET` on Testcontainers' Redis, which is
  removed after the run (Testcontainers' containers counted after the verify, printed). `18 + 7` (`anchor`): the move from unit 14's count is this one test.
- The anchor README — the `## Course 8 · unit 15` section, the header chain's *Course 8, unit 15* note, and **three R.250 notes in place**:
  unit 11's "No `spring.data.redis` key anywhere" (one exists since), unit 11's "Spring Data Redis, with no repository of its own" (under
  "dev" it has one since; the default run prints no Redis repository line), and unit 14's "no `spring.data.redis` key anywhere
  (`spring.data.redis.repositories.enabled` is unit 15's)" (it is in `application.yaml` since).

**Left as they were, and why (R.250):** `application-dev.yaml`'s "no spring.data.redis key here" stays true (the key is
`application.yaml`'s); its unit 14 health note — "with Redis down when TiffinBox starts … it stops, RedisConnectionFailureException" —
is still what 15/after prints with Redis absent (`startstop`: the start's fill fails before the repository's listener starts), so it is
not extended. `TiffinBoxServer`'s unit 14 sentence "Without the bean (the default run) nothing here touches Redis" stays true. Unit 14's
README and its hand-off are frozen; its "Next" — "U15 moves the anchor next (`@RedisHash` under dev,
`spring.data.redis.repositories.enabled: false` in `application.yaml`, the compose note's second sentence)" — is done here. The R.250
list is `chk15.py r250`'s (seven sentences, each with its note after it; a plant that removes one fails the gate).

## Whose save, which number — the shape question settled (RE-MEASURE 4)

The brief's hook numbers (three orders, two timed, one untimed) are the probe's entity's — below, the harness's, labelled. The shipped start saves **one order per placed
order**, every one with the one configured time to live. Both shapes are captured, each labelled:

- **The start's own saves** — 15/after, profile dev, PostgreSQL + Redis, through TiffinBox's application class (`probe.u15.U15`, unit 14's
  form, with its web server). In `anchor`: the start's `SCARD kitchen-order`, its sorted ids and their md5 identical across three starts,
  each customer's index set the same size, the meal types' sets; and in `events`' second half, the shipped shape's own cleanup: the
  setting low on the command line (`--tiffinbox.kitchen-order-ttl=<ttl>`, masked), the start's hashes gone while TiffinBox runs, `SCARD`
  polled to none, `count()` none, `findAll()` empty.
- **The harness's saves through the shipped repository** — `keys`, `monitor`, `ttl`, `events`' first half, `nolisten`, `stale`: three
  orders (`o1` Ravi, `o2` Sunil — both VEG, both timed, and `o3` Meera, NON_VEG, untimed, the values meals times price off the anchor's seed) saved
  through the shipped `KitchenOrders` in a **repository-only harness JVM** (`probe.u15.H15`): a small Spring context of the shipped
  `KitchenOrder`, `KitchenOrders` and — under "dev" — the shipped `RedisDatastore` itself, on Lettuce's connection factory, no TiffinBox
  start, no web server, no database. Why not TiffinBox's application class, as the prompt preferred: **every TiffinBox start saves its own
  orders**, so its 120 would sit beside the three in every count, and `nolisten`'s "fresh JVM that only listens" must save nothing — a
  TiffinBox start always saves. For `stale`, the same JVM registers the shipped `KitchenOrders` through **its own** `@EnableRedisRepositories`
  with no keyspace events (OFF, the annotation's default) — a labelled harness configuration, no copy of the anchor.

The two shapes disagree on nothing but the counts: the hash's fields, the index sets, the `:idx` set, the finders' commands and the
listener's cleanup are the same, with one difference read off the runs and said: **the start's saves carry no `:phantom`** (they run in
`@PostConstruct`, before the repository's listener starts — Spring Data Redis keeps the phantom copy only while its listener runs), and
the running listener still removes their ids from every set (`events`). The video says the start's numbers as the start's and the
harness's as the harness's.

## The captures — what each one shows

### 1 · anchor — the start's own saves, three starts in a row, Found 1, the tests, the versions (C2, R.400, RE-MEASURE 4, 6, 11)

15/after, profile dev, PostgreSQL + Redis — **the start's saves**. The overrides on every dev JVM: `--spring.profiles.active=dev
--spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20542 --logging.level.tiffinbox=INFO`;
the datasource is the config tree's (`secrets/tiffinbox/jdbc-url`, 0600, never on a command line), a fresh database by psql;
`tiffinbox.kitchen-order-ttl` as `application.yaml` ships it. The receipt empties Redis (`FLUSHALL`) and resets the server's setting
(`CONFIG SET notify-keyspace-events ""`) before the first start, then starts TiffinBox three times in a row against the same Redis; the
third ends by SIGINT at its pause (exit 130). Java's side is the context's `KitchenOrders` bean; redis-cli's is read at the pause. Both
sides print the sorted ids' count, first, last and md5 — **equal between the witnesses and across the three starts**, so the ids are
deterministic and each start's save overwrites the last; the count is the start's own `orders cooked` and `/kitchen`'s `ordersCooked`.
Strict mode now prints `Found 1 Redis repository interface`, and JPA's `RepositoryConfigurationExtensionSupport` declines `KitchenOrders`
at INFO (beside the line it already printed for `CustomerAggregates`) — not an error. `CONFIG GET notify-keyspace-events` reads `xE`
during the run (through the connection, and by redis-cli at the pause) and after the third JVM, by redis-cli: the listener wrote it on
the server, and it outlives the JVM. The test count's move from unit 14 is `RedisDatastoreIT`'s second test (R.363/R.80).

```text
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 7, Failures: 0, Errors: 0, Skipped: 0
REDIS IT the orders, through KitchenOrders: count() 3 · findByMealType(VEG) [Ravi-1, Sunil-1]
REDIS IT the same keys, through the slice's StringRedisTemplate: SMEMBERS kitchen-order:mealType:VEG [Ravi-1, Sunil-1] · SCARD kitchen-order 3 · type kitchen-order:Ravi-1 hash
before/: 122 libraries · spring-data-redis, spring-data-keyvalue and lettuce in lib/: lettuce-core-7.5.2.RELEASE.jar spring-data-keyvalue-4.1.2.jar spring-data-redis-4.1.2.jar
after/: 122 libraries · spring-data-redis, spring-data-keyvalue and lettuce in lib/: lettuce-core-7.5.2.RELEASE.jar spring-data-keyvalue-4.1.2.jar spring-data-redis-4.1.2.jar
gained: 0 · lost: 0
the five classes in lib/spring-data-redis-4.1.2.jar (unzip -l): EnableRedisRepositories Indexed RedisHash RedisKeyValueAdapter TimeToLive
log: Found 1 Redis repository interface
log: RepositoryConfigurationExtensionSupport : Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders
log: Found 1 JPA repository interface
log: Found 1 JDBC repository interface
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data JDBC 4.1.2 · Spring Data Redis 4.1.2 · Lettuce 7.5.2.RELEASE/5728917 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
log: HHH000001: Hibernate ORM core version 7.4.13.Final
PROBE KitchenOrders beans 1 [kitchenOrders=a JDK proxy of com.tiffinbox.web.KitchenOrders] · RedisDatastore beans 1 (profile dev, PostgreSQL 18.6)
PROBE CONFIG GET notify-keyspace-events, through the connection, after the start: "xE"
redis-cli CONFIG SET notify-keyspace-events "" -> OK (the server's setting reset; it outlives every JVM) · CONFIG GET notify-keyspace-events: ""
the Redis container's own client: redis-cli 8.10.3 · INFO server: redis_version:8.10.3
```

The first start's saves, by both witnesses — then the other two starts' identical lines:

```text
log: tiffinbox: orders cooked:  120
PROBE http (profile dev, PostgreSQL 18.6): GET /kitchen -> 200 · ordersCooked 120 · ordersValue 24300
PROBE rail (the start's saves, through the shipped KitchenOrders; profile dev, PostgreSQL 18.6): count() 120 · findAll() 120 elements, 0 null · the ids, sorted: 120, first Meera-1, last Sunil-9, md5 of the sorted lines 30c12bb7938c3831651bd81c2e6ceb60
SCARD kitchen-order: 120 · SMEMBERS kitchen-order, sorted: 120 ids, first Meera-1, last Sunil-9, md5 of the sorted lines 30c12bb7938c3831651bd81c2e6ceb60
PROBE rail: findByCustomer, per customer: Meera 30 · Priya 30 · Ravi 30 · Sunil 30 · findByMealType, per meal type: VEG 60 · NON_VEG 30 · VEGAN 30
the index sets, SCARD each: kitchen-order:customer:Meera 30 · kitchen-order:customer:Priya 30 · kitchen-order:customer:Ravi 30 · kitchen-order:customer:Sunil 30 · kitchen-order:mealType:NON_VEG 30 · kitchen-order:mealType:VEG 60 · kitchen-order:mealType:VEGAN 30
TYPE kitchen-order:Meera-1: hash · HGETALL kitchen-order:Meera-1: _class com.tiffinbox.web.KitchenOrder customer Meera id Meera-1 mealType NON_VEG ttl <n> value 150 · PTTL kitchen-order:Meera-1: yes (> 0, the value masked)
TYPE kitchen-order:Meera-1:idx: set · SMEMBERS, sorted: kitchen-order:customer:Meera kitchen-order:mealType:NON_VEG
--scan, every key, an id's day written <n>, counted: customers::SimpleKey [] ×1 · kitchen-order ×1 · kitchen-order:Meera-<n> ×30 · kitchen-order:Meera-<n>:idx ×30 · kitchen-order:Priya-<n> ×30 · kitchen-order:Priya-<n>:idx ×30 · kitchen-order:Ravi-<n> ×30 · kitchen-order:Ravi-<n>:idx ×30 · kitchen-order:Sunil-<n> ×30 · kitchen-order:Sunil-<n>:idx ×30 · kitchen-order:customer:Meera ×1 · kitchen-order:customer:Priya ×1 · kitchen-order:customer:Ravi ×1 · kitchen-order:customer:Sunil ×1 · kitchen-order:mealType:NON_VEG ×1 · kitchen-order:mealType:VEG ×1 · kitchen-order:mealType:VEGAN ×1 · tiffinbox:leaderboard ×1
keys named *:phantom: 0 · CONFIG GET notify-keyspace-events: "xE"
PROBE http (profile dev, PostgreSQL 18.6): GET /actuator/health -> 200 · status UP
PROBE http (profile dev, PostgreSQL 18.6): GET /leaderboard -> 200 · {"Sunil":9000.0,"Ravi":7200.0,"Meera":4500.0,"Priya":3600.0}
PROBE http (profile dev, PostgreSQL 18.6): GET /dashboard -> 200
```

```text
the receipt at pause 2: kill -INT sent to the harness JVM (its pid, read off its own line)
exit 130 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0
after the third JVM, redis-cli: CONFIG GET notify-keyspace-events "xE" (the server's setting, which the start's listener wrote, outlives the JVM) · SCARD kitchen-order 120
```

```text
log: Database: jdbc:postgresql://127.0.0.1:<port>/<db>?user=tiffinbox&password=******** (PostgreSQL 18.6)
```

### 2 · keys — every key three saves leave, by TYPE (the harness's saves through the shipped repository, labelled)

The harness's three orders, saved through the shipped `KitchenOrders` in the repository-only JVM under the shipped `RedisDatastore`
(ON_STARTUP), on an emptied Redis. redis-cli's `--scan` and `TYPE` on every key (R.398): the ids' set `kitchen-order`, a hash per order,
an `:idx` set per order naming the index sets its id is in, a set per indexed value — the secondary index — and a `:phantom` hash beside
each timed order only. The timed hash holds a `ttl` field (masked); the untimed one has none. Java's `count()` and redis-cli's `SCARD`
agree.

```text
kitchen-order: TYPE set
kitchen-order:customer:Meera: TYPE set
kitchen-order:customer:Ravi: TYPE set
kitchen-order:customer:Sunil: TYPE set
kitchen-order:mealType:NON_VEG: TYPE set
kitchen-order:mealType:VEG: TYPE set
kitchen-order:o1: TYPE hash
kitchen-order:o1:idx: TYPE set
kitchen-order:o1:phantom: TYPE hash
kitchen-order:o2: TYPE hash
kitchen-order:o2:idx: TYPE set
kitchen-order:o2:phantom: TYPE hash
kitchen-order:o3: TYPE hash
kitchen-order:o3:idx: TYPE set
HGETALL kitchen-order:o1 (timed): _class com.tiffinbox.web.KitchenOrder customer Ravi id o1 mealType VEG ttl <n> value 240
HGETALL kitchen-order:o3 (untimed): _class com.tiffinbox.web.KitchenOrder customer Meera id o3 mealType NON_VEG value 150
SMEMBERS kitchen-order, sorted: o1 o2 o3 · SCARD kitchen-order: 3
SMEMBERS kitchen-order:o1:idx, sorted: kitchen-order:customer:Ravi kitchen-order:mealType:VEG
SMEMBERS kitchen-order:mealType:VEG, sorted: o1 o2 · SMEMBERS kitchen-order:customer:Ravi: o1
EXISTS kitchen-order:o1:phantom 1 · EXISTS kitchen-order:o2:phantom 1 · EXISTS kitchen-order:o3:phantom 0
PROBE java (the shipped KitchenOrders; the shipped RedisDatastore, keyspace events ON_STARTUP): count() 3 · findAll() [KitchenOrder[o1,Ravi,VEG,240], KitchenOrder[o2,Sunil,VEG,300], KitchenOrder[o3,Meera,NON_VEG,150]] (3 elements, 0 null)
PROBE java: findByMealType(VEG) [KitchenOrder[o1,Ravi,VEG,240], KitchenOrder[o2,Sunil,VEG,300]] · findByCustomer(Ravi) [KitchenOrder[o1,Ravi,VEG,240]] · findByCustomerAndMealType(Ravi, VEG) [KitchenOrder[o1,Ravi,VEG,240]]
PROBE java: findById(o1) Optional[KitchenOrder[o1,Ravi,VEG,240]] · existsById(o1) true · findById(o3) Optional[KitchenOrder[o3,Meera,NON_VEG,150]]
```

### 3 · monitor — the commands, counted off MONITOR (R.401; the harness's saves, labelled)

A `MONITOR` client — the container's own redis-cli, a second client — runs across a timed save, an untimed save, a second timed save,
`findByMealType`, `findByCustomerAndMealType`, `findAll()` and `count()`, each after an `ECHO h15:<operation>` marker; the receipt stops it
by its id (`CLIENT KILL ID`, the client whose flags are `O`). `chk15.py` **counts** each operation's lines and checks them against the
shape the shipped entity's own source gives (its two `@Indexed` fields, its `@TimeToLive`): an untimed save is `DEL`, `HMSET` and five
`SADD`; a timed save under ON_STARTUP adds the hash's `EXPIRE` and the phantom's `DEL`, `HMSET` and `EXPIRE`; a finder is one `SINTER`
(of two index sets for two fields) and one `HGETALL` per id; `findAll()` is `SMEMBERS`, then `HGETALL` and `TTL` per id; `count()` is
`SCARD`. Every `EXPIRE`'s value and the `ttl` field are masked, the unix-time prefix stripped. The counts are in the values block.

```text
"ECHO" "h15:save-timed"
"DEL" "kitchen-order:o1"
"HMSET" "kitchen-order:o1" "_class" "com.tiffinbox.web.KitchenOrder" "customer" "Ravi" "id" "o1" "mealType" "VEG" "ttl" "<n>" "value" "240"
"SADD" "kitchen-order" "o1"
"EXPIRE" "kitchen-order:o1" "<n>"
"DEL" "kitchen-order:o1:phantom"
"HMSET" "kitchen-order:o1:phantom" "_class" "com.tiffinbox.web.KitchenOrder" "customer" "Ravi" "id" "o1" "mealType" "VEG" "ttl" "<n>" "value" "240"
"EXPIRE" "kitchen-order:o1:phantom" "<n>"
"SADD" "kitchen-order:customer:Ravi" "o1"
"SADD" "kitchen-order:o1:idx" "kitchen-order:customer:Ravi"
"SADD" "kitchen-order:mealType:VEG" "o1"
"SADD" "kitchen-order:o1:idx" "kitchen-order:mealType:VEG"
"ECHO" "h15:save-untimed"
"DEL" "kitchen-order:o3"
"HMSET" "kitchen-order:o3" "_class" "com.tiffinbox.web.KitchenOrder" "customer" "Meera" "id" "o3" "mealType" "NON_VEG" "value" "150"
"SADD" "kitchen-order" "o3"
"SADD" "kitchen-order:customer:Meera" "o3"
"SADD" "kitchen-order:o3:idx" "kitchen-order:customer:Meera"
"SADD" "kitchen-order:mealType:NON_VEG" "o3"
"SADD" "kitchen-order:o3:idx" "kitchen-order:mealType:NON_VEG"
"ECHO" "h15:save-timed-2"
"DEL" "kitchen-order:o2"
"HMSET" "kitchen-order:o2" "_class" "com.tiffinbox.web.KitchenOrder" "customer" "Sunil" "id" "o2" "mealType" "VEG" "ttl" "<n>" "value" "300"
"SADD" "kitchen-order" "o2"
"EXPIRE" "kitchen-order:o2" "<n>"
"DEL" "kitchen-order:o2:phantom"
"HMSET" "kitchen-order:o2:phantom" "_class" "com.tiffinbox.web.KitchenOrder" "customer" "Sunil" "id" "o2" "mealType" "VEG" "ttl" "<n>" "value" "300"
"EXPIRE" "kitchen-order:o2:phantom" "<n>"
"SADD" "kitchen-order:mealType:VEG" "o2"
"SADD" "kitchen-order:o2:idx" "kitchen-order:mealType:VEG"
"SADD" "kitchen-order:customer:Sunil" "o2"
"SADD" "kitchen-order:o2:idx" "kitchen-order:customer:Sunil"
"ECHO" "h15:findByMealType"
"SINTER" "kitchen-order:mealType:VEG"
"HGETALL" "kitchen-order:o1"
"HGETALL" "kitchen-order:o2"
"ECHO" "h15:findByCustomerAndMealType"
"SINTER" "kitchen-order:customer:Ravi" "kitchen-order:mealType:VEG"
"ECHO" "h15:findAll"
"SMEMBERS" "kitchen-order"
"TTL" "kitchen-order:o1"
"HGETALL" "kitchen-order:o3"
"TTL" "kitchen-order:o3"
"TTL" "kitchen-order:o2"
"ECHO" "h15:count"
"SCARD" "kitchen-order"
"ECHO" "h15:end"
the receipt at pause 2: CLIENT KILL ID <the MONITOR client's id, read off CLIENT LIST, flags O> -> 1
MONITOR clients left (CLIENT LIST, flags O): 0
PROBE mon (the harness's saves through the shipped repository; the shipped RedisDatastore, keyspace events ON_STARTUP): a timed save (o1), an untimed save (o3), a timed save (o2), findByMealType(VEG) 2 elements, findByCustomerAndMealType(Ravi, VEG) 1, findAll() 3, count() 3 - an ECHO h15:<operation> before each
```

### 4 · ttl — the time to live the entity carries (⚑13; the harness's saves, labelled)

`@TimeToLive` on the field: redis-cli's `PTTL` on a timed hash answers a positive number — printed as "yes", the value masked — and `-1`
on the untimed one; the timed order's `:phantom` exists with its own time to live, the untimed order has none. Java (RE-MEASURE 5):
`findAll()` and `findById` read `TTL`, so the untimed element carries `-1`; a derived finder reads the hash alone, so the untimed element
carries `null` and a timed one the stored field (printed `set`).

```text
PTTL kitchen-order:o1 (timed): yes (> 0, the value masked) · PTTL kitchen-order:o2 (timed): yes (> 0, the value masked) · PTTL kitchen-order:o3 (untimed): -1
EXISTS kitchen-order:o1:phantom 1 · PTTL kitchen-order:o1:phantom: yes (> 0, the value masked) · EXISTS kitchen-order:o3:phantom 0
a field named ttl: in HGETALL kitchen-order:o1 1 · in HGETALL kitchen-order:o3 0
PROBE java: the ttl each element carries (a timed value printed as "set") - findAll(): o1:set o2:set o3:-1 · findByMealType(VEG): o1:set o2:set · findByMealType(NON_VEG): o3:null · findById(o3): -1
```

### 5 · events — ON_STARTUP: "" → xE, the hashes gone while the JVM runs, the sets polled clean (S8.50, R.403, R.412)

The harness's three orders under the shipped `RedisDatastore`. The server's setting reads `""` before the JVM (the image's default, reset
by the receipt) and `xE` once it has started (Redis's own spelling of what Spring Data asked for), by the connection and by redis-cli.
The harness's two timed hashes' time to live ends **while the JVM runs**: the receipt polls `EXISTS` to zero, then polls `SCARD kitchen-order` until
the untimed order is alone in it and the VEG set until it is gone — each a count condition, the number of reads printed (masked); then
Java's `count()` and `findAll()` and redis-cli's `SMEMBERS` agree. The listener removes them once Redis tells it.

```text
redis-cli CONFIG SET notify-keyspace-events "" -> OK (the server's setting reset; it outlives every JVM) · CONFIG GET notify-keyspace-events: ""
PROBE CONFIG GET notify-keyspace-events, through the connection (the shipped RedisDatastore, keyspace events ON_STARTUP): "xE"
CONFIG GET notify-keyspace-events: "xE" · SCARD kitchen-order: 3 · SMEMBERS kitchen-order:mealType:VEG, sorted: o1 o2
poll: EXISTS kitchen-order:o1 kitchen-order:o2 (the two timed hashes gone: their time to live ended) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
poll: SCARD kitchen-order (until the untimed order alone is in it) -> 1, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
poll: SCARD kitchen-order:mealType:VEG (until its set is gone) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
then: SMEMBERS kitchen-order: o3 · EXISTS kitchen-order:o1:idx kitchen-order:o2:idx: 0 · --scan, sorted: kitchen-order kitchen-order:customer:Meera kitchen-order:mealType:NON_VEG kitchen-order:o3 kitchen-order:o3:idx
PROBE java (the shipped KitchenOrders; the shipped RedisDatastore, keyspace events ON_STARTUP): count() 1 · findAll() [KitchenOrder[o3,Meera,NON_VEG,150]] (1 elements, 0 null)
after the JVM, redis-cli: CONFIG GET notify-keyspace-events "xE"
```

**And the start's own shape (RE-MEASURE 4):** 15/after, profile dev, PostgreSQL + Redis — the start's saves, the setting low on the
command line (`--tiffinbox.kitchen-order-ttl=<ttl>`, masked). The start's hashes are polled to `EXISTS` zero while TiffinBox runs, then
`SCARD kitchen-order` to none: no index set, no `:idx` set and no order key is left, and Java's `count()` and `findAll()` say none — the
running TiffinBox's listener cleaned every one, with no `:phantom` beside them.

```text
SCARD kitchen-order: 120 · keys named *:phantom: 0 · CONFIG GET notify-keyspace-events: "xE"
poll: EXISTS on the 120 hashes the set named (all gone: their time to live ended) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
poll: SCARD kitchen-order (until it is gone) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
then: keys named kitchen-order:customer:* 0 · kitchen-order:mealType:* 0 · kitchen-order:*:idx 0 · --scan, sorted: customers::SimpleKey [] tiffinbox:leaderboard
PROBE railgone (the start's saves, after their time to live; profile dev, PostgreSQL 18.6): count() 0 · findAll() 0 elements, 0 null
log: tiffinbox: orders cooked:  120
```

### 6 · nolisten — what the listener never heard (RED #2, R.403, RE-MEASURE 13; the harness's saves, labelled)

ON_STARTUP cleans only what a running repository hears. `j1` saves the three under the shipped `RedisDatastore` and is stopped by SIGINT
(its disposition reset, exit 130) while both timed hashes still exist — SIGINT, not `kill -9`: the JVM's own exit, the receipt's rule
(R.410). With no JVM up, the receipt polls `EXISTS` to zero: `SCARD` still counts three, the VEG set still holds both ids, the `:phantom`
is still there and the server still says `xE`. `j2`, a fresh ON_STARTUP JVM that saves nothing, listens: ten reads of `SCARD`, the
receipt's pause between each, all the stale count. `j3` saves the same three ids again and stays up across their time to live: the
receipt polls `EXISTS` to zero, then `SCARD` to one and the VEG set until it is gone; `count()` agrees. That is the exercise's solution's
shape — and the dev cycle's: TiffinBox's start saves the same ids every time.

```text
the receipt at pause 1, redis-cli: EXISTS kitchen-order:o1 kitchen-order:o2 2 (both timed hashes still there) · SCARD kitchen-order 3 - then SIGINT, before their time to live ends:
the receipt at pause 1: kill -INT sent to the harness JVM (its pid, read off its own line)
exit 130 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0
poll: EXISTS kitchen-order:o1 kitchen-order:o2 (both timed hashes gone, no JVM listening) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
then: SCARD kitchen-order 3 · SMEMBERS kitchen-order:mealType:VEG, sorted: o1 o2 · EXISTS kitchen-order:o1:phantom 1 · CONFIG GET notify-keyspace-events "xE"
the receipt at pause 1, redis-cli, the fresh JVM up and listening (it saves nothing): SCARD kitchen-order, ten reads, a pause of the receipt's between each: 3333333333 · SMEMBERS kitchen-order:mealType:VEG, sorted: o1 o2 · EXISTS kitchen-order:o1:phantom 1
PROBE save3 (the harness's saves through the shipped repository; the shipped RedisDatastore, keyspace events ON_STARTUP): saved again (the same ids) KitchenOrder[o1,Ravi,VEG,240] and KitchenOrder[o2,Sunil,VEG,300] with a time to live (h15.ttl, a configured number), KitchenOrder[o3,Meera,NON_VEG,150] with none (ttl null)
poll: EXISTS kitchen-order:o1 kitchen-order:o2 (the re-saved timed hashes gone: their time to live ended) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
poll: SCARD kitchen-order (until 1) -> 1, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
poll: SCARD kitchen-order:mealType:VEG (until its set is gone) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
then: SMEMBERS kitchen-order: o3 · --scan, sorted: kitchen-order kitchen-order:customer:Meera kitchen-order:mealType:NON_VEG kitchen-order:o3 kitchen-order:o3:idx
PROBE java (the shipped KitchenOrders; the shipped RedisDatastore, keyspace events ON_STARTUP): count() 1 · findAll() [KitchenOrder[o3,Meera,NON_VEG,150]] (1 elements, 0 null)
```

### 7 · stale — keyspace events OFF: count() and findAll()'s nulls beside EXISTS 0 (the failure receipt, R.396's negation; control: `events`)

Keyspace events OFF, Spring Data Redis's default: the harness's own configuration over the shipped `KitchenOrders` (labelled — no copy of
the anchor), the server's setting reset before the JVM and `""` before, during and after. Both timed hashes are gone (`EXISTS` polled to
zero), and the repository still counts them: `count()` and `SCARD` agree on three, `findAll()` returns two null elements beside the
untimed order, the index sets still hold the gone ids, and the derived finder returns an empty list — it drops the ids whose hash is
missing, the finder that hides the fault. `findById` is empty and `existsById` false; no exception (ERROR none, no line naming an
Exception, Netty's DNS line counted). The keys left are listed.

```text
redis-cli CONFIG SET notify-keyspace-events "" -> OK (the server's setting reset; it outlives every JVM) · CONFIG GET notify-keyspace-events: ""
PROBE CONFIG GET notify-keyspace-events, through the connection (the harness's configuration, keyspace events OFF): ""
poll: EXISTS kitchen-order:o1 kitchen-order:o2 (the two timed hashes gone: their time to live ended) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
then: SCARD kitchen-order 3 · SMEMBERS kitchen-order, sorted: o1 o2 o3 · SMEMBERS kitchen-order:mealType:VEG, sorted: o1 o2 · SMEMBERS kitchen-order:customer:Ravi: o1 · EXISTS kitchen-order:o1:phantom 0
PROBE java (the shipped KitchenOrders; the harness's configuration, keyspace events OFF): count() 3 · findAll() [null, null, KitchenOrder[o3,Meera,NON_VEG,150]] (3 elements, 2 null)
PROBE java: findByMealType(VEG) [] · findByCustomer(Ravi) [] · findByCustomerAndMealType(Ravi, VEG) []
PROBE java: findById(o1) Optional.empty · existsById(o1) false · findById(o3) Optional[KitchenOrder[o3,Meera,NON_VEG,150]]
the receipt at pause 2, redis-cli: the keys left, --scan sorted: kitchen-order kitchen-order:customer:Meera kitchen-order:customer:Ravi kitchen-order:customer:Sunil kitchen-order:mealType:NON_VEG kitchen-order:mealType:VEG kitchen-order:o1:idx kitchen-order:o2:idx kitchen-order:o3 kitchen-order:o3:idx
exit 0 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0
after the JVM, redis-cli: CONFIG GET notify-keyspace-events ""
```

### 8 · startstop — under the profile dev, ON_STARTUP needs Redis: the start stops (R.413, ⚑4/⚑6; control: `anchor`)

15/after's jar itself (`java -jar`, unit 14's form) under "dev", PostgreSQL up, Redis absent (`--spring.data.redis.port=20549`, asserted
unbound by `lsof` first): **the start stops, exit 1**, nothing on 20540 (`curl` → `000`). **What 15/after prints is unit 14's line** —
`Error creating bean with name 'tiffinBoxServer'` ← `RedisConnectionFailureException`: the start's fill reaches Redis in `@PostConstruct`,
before the repository's listener starts, so the adapter's own line (`Failed to start bean 'redisKeyValueAdapter'`) is not printed there.
The adapter's failure is measured on the shipped `RedisDatastore` itself, in the repository-only JVM, where nothing touches Redis before
the listener starts: `Failed to start bean 'redisKeyValueAdapter'` ← `RedisConnectionFailureException`, exit 1 — the class TiffinBox ships,
no copy (the prompt's `variants.py nofill` was not needed).

```text
the JVM's exit: 1 · then curl /actuator/health on 20540: 000 · listening on 20540: 0
its log: "Error creating bean with name 'tiffinBoxServer'" 2 lines · "RedisConnectionFailureException: Unable to connect to Redis" 1 · "Failed to start bean 'redisKeyValueAdapter'" 0 · "Application run failed" 1 · "Started TiffinBoxApp" 0 · "orders cooked" 0
its first exception line: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed
the causes, in the order the log names them: org.springframework.data.redis.RedisConnectionFailureException<io.lettuce.core.RedisConnectionException<java.net.ConnectException
PROBE started: no · org.springframework.context.ApplicationContextException: Failed to start bean 'redisKeyValueAdapter'
PROBE caused by: org.springframework.data.redis.RedisConnectionFailureException: Unable to connect to Redis
PROBE <<< exit 1
its log: "Failed to start bean 'redisKeyValueAdapter'" 2 lines
```

### 9 · noconfig — a server that refuses CONFIG stops the ON_STARTUP start (RED #5, the failure receipt; control: `events`)

The pinned digest started a second time, with `--rename-command CONFIG ""`, on 20544 (a spare: the unit's own Redis must keep `CONFIG`,
which every other capture reads and resets), removed with `-fv` after each run. redis-cli's `CONFIG GET` on it answers `ERR unknown command
'CONFIG'`. 15/after's jar under "dev" pointed at it: the start's fill and saves succeed (they need no `CONFIG`), then the listener's start
fails — `Failed to start bean 'redisKeyValueAdapter'` ← `ERR unknown command 'CONFIG'` — exit 1, `000`, and the orders the start saved are
left on that server.

```text
c8u15-nocfg: published 6379/tcp -> 127.0.0.1:20544 · redis-cli CONFIG GET notify-keyspace-events: ERR unknown command 'CONFIG'
the JVM's exit: 1 · then curl /actuator/health on 20540: 000 · listening on 20540: 0
its log: "Failed to start bean 'redisKeyValueAdapter'" 2 lines · "ERR unknown command 'CONFIG'" 1 · "Error creating bean with name 'tiffinBoxServer'" 0 · "orders cooked" 1 · "Started TiffinBoxApp" 0 · "Application run failed" 1
the causes, in the order the log names them: org.springframework.data.redis.RedisSystemException<io.lettuce.core.RedisCommandExecutionException
the second Redis after the stopped start: SCARD kitchen-order 120 (the start's saves reached it before the listener's CONFIG SET was refused) · ZCARD tiffinbox:leaderboard 4
c8u15-nocfg removed with its volumes (rm -fv) · listening on 20544: 0
```

### 10 · default — the default run never needs Redis (R.400, RE-MEASURE 6, 11)

15/after with no profile, H2 in memory, Docker at nothing (`DOCKER_HOST=tcp://127.0.0.1:1`; the docker CLI, pinned, still on its socket),
Redis absent: health 200, `/leaderboard` 404, `/dashboard` 200, no `KitchenOrders` bean and no `RedisDatastore`, and **no Redis repository
line at all** — unit 14's default run printed strict mode's line with none; `spring.data.redis.repositories.enabled: false` backs Boot's
auto-configuration off. JPA still declines `KitchenOrders` at INFO on the default run (its scan sees the interface). The tests without
Docker are the same run's `mvn -o package`.

```text
PROBE started: yes · default run, H2 2.5.250 · a web server: yes
PROBE http (default run, H2 2.5.250): GET /actuator/health -> 200 · status UP
PROBE http (default run, H2 2.5.250): GET /leaderboard -> 404
PROBE http (default run, H2 2.5.250): GET /dashboard -> 200
PROBE noorders (default run, H2 2.5.250): getBeansOfType(KitchenOrders) 0 · a bean of class com.tiffinbox.web.RedisDatastore 0
log: Found 1 JPA repository interface
log: Found 1 JDBC repository interface
its log: lines naming "Redis repositor" 0 · "Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders" 1
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

### 11 · seven — the comparison set on before/ and after/ (R.363)

`../c5-unit11/curlset.sh` on `before/`'s jar (20543) and `after/`'s (20540), each a fresh JVM on H2 — unchanged, the published hash (`../c7-unit31`'s);
Hibernate's schema script is `xcheck.sql`. `after/`'s default run prints no Redis repository line; `before/`'s (unit 14's) prints strict
mode's line with none.

```text
exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 · listens on: 127.0.0.1:20543
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 · listens on: 127.0.0.1:20540
its log: lines naming "Redis repositor" 2
its log: lines naming "Redis repositor" 0
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20543 now: 0
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20540 now: 0
the seven, after/ against before/: lines that differ: 0
```

### 12 · exercise — run as written, in one shell, bash then zsh (R.196)

The brief's words, byte for byte, their count by `wc -w` in the values block. **Needs Redis**: the block starts the pinned Redis by its digest on 20542
(`--pull never`), before the receipt's own container, and removes it with `rm -fv`. The program is a standalone JVM on the shipped
`KitchenOrder` and `KitchenOrders` (built offline from `.m2-demo`, `-pl tiffinbox-web -am`), a small Spring context with its own
`@EnableRedisRepositories` — no TiffinBox web server, no PostgreSQL. Broken: keyspace events off — with the JVM up after both timed hashes
are gone, `count()` and `SCARD` still count them and `findAll()` holds two nulls. Solved: ON_STARTUP, a start that saves the same ids and
stays up across their time to live — `count()` and `SCARD` agree on the untimed order alone. **The check is `count()` and `SCARD`, never the
exit** (zero in both). The time to live is the program's own setting (`Rail.TTL`), never printed.

```text
$ sed 's|^@EnableRedisRepositories(basePackageClasses = KitchenOrders.class)$|@EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)|' exercise/Rail.java > .harness/ex/Rail.java; echo "ON_STARTUP in Rail.java: $(grep -c '^@EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)$' .harness/ex/Rail.java)"
ON_STARTUP in Rail.java: 0
ON_STARTUP in Rail.java: 1
keyspace events (CONFIG GET notify-keyspace-events): ""
keyspace events (CONFIG GET notify-keyspace-events): "xE"
SCARD kitchen-order, read until it holds the untimed order alone (a cap of 50 reads): not reached, 3
SCARD kitchen-order, read until it holds the untimed order alone (a cap of 50 reads): reached, 1
count(): 3
count(): 1
findAll(): [null, null, KitchenOrder[o3,Meera,NON_VEG,150]]
findAll(): [KitchenOrder[o3,Meera,NON_VEG,150]]
redis-cli SCARD kitchen-order: 3
redis-cli SCARD kitchen-order: 1
redis-cli SMEMBERS kitchen-order:mealType:VEG: (o1 o2)
redis-cli SMEMBERS kitchen-order:mealType:VEG: ()
Rail: exit 0
the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20542 afterwards: 0 · a container named c8u15-ex: 0
```

## Which store, which profile, whose save

**15/after, profile dev, PostgreSQL + Redis — the start's saves**: `anchor`, `events`' second half, `noconfig` (on its second Redis),
`startstop`'s first JVM (Redis absent). **15/after's classes — the harness's saves through the shipped repository**: `keys`, `monitor`,
`ttl`, `events`' first half, `nolisten`, `stale` (the harness's OFF configuration), `startstop`'s second JVM (the shipped `RedisDatastore`
alone, Redis absent). **15/after, default run, H2, no Redis**: `default`, `seven`, the tests' H2 half. **The exercise's program**:
`Rail.java`, its own connection factory, the shipped `KitchenOrder` and `KitchenOrders`, the exercise's own Redis.

## Refused, named

- A settle sleep behind a clean read (R.412): every read after a listener's cleanup waits on a count — `EXISTS` to zero, then `SCARD` to its
  clean value — with the number of reads printed (`polled <k> times`, masked in the capture because it moves run to run; the receipt's own
  log prints each run's counts). `chk15.py static` refuses a `sleep` between the `EXISTS` poll and the clean read.
- "500 beside 200" for an absent store (R.413), refused: under "dev" the start stops (`startstop`, `noconfig`).
- A Redis stopped under a running dev TiffinBox (Lettuce reconnecting — a wait): never run here, never a receipt (CARRIED).
- `keyspaceNotificationsConfigParameter = ""`, the way round a server that refuses `CONFIG`: not measured, unsaid (CARRIED).
- `@Reference`, paging and sorting, `@Query` on Redis: not built, not said.
- A volume for Redis in `compose.yaml` (⚑15): the start saves its orders again; a volume would keep only what the start rebuilds.
- "The repository cleans up after itself", "a fresh start cleans the stale index" (R.403), refused: the cleanup is a running repository's, said
  with its condition (`nolisten`).
- SQL's words for Redis's commands (R.401); a Redis claim with Java's answer alone or redis-cli's alone (R.398); a number from the
  harness's saves voiced as the start's (R.392); the default run said to need Redis (R.400); a delivery word (R.404).
- A container removed without `-v` (R.387); a build that names `-pl` without `-am` (R.391); the docker CLI without its pinned socket
  (R.344); `Map.of` in any writer (R.411 — none, asserted on the anchor's files and the exercise's).

## Call-backs, by title (R.224)

- Course 8's *Redis Data Structures From Java* (`java8_series.TITLES["14"]`): `before/`, the leaderboard beside which the orders are saved,
  and unit 14's absent-store line that 15/after still prints first.
- This unit: *Spring Data Redis Repositories* (`java8_series.TITLES["15"]`, `15-spring-data-redis-repositories`).
- Forward, by title only: *Pub/Sub and Streams* (16), *Distributed Locks and Rate Counters* (17).

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged; under "dev" its start saves the kitchen's orders to the Redis Compose starts beside Postgres.

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s3` (byte-identical to Section 2's); every build
reads it offline (`-o`, `maven.repo.local` as an absolute path), every one `-pl tiffinbox-web -am`, and the receipt asserts its file count
unchanged after every Maven run and no "Downloaded from" line. No dependency added: `git diff --stat` touches no `pom.xml`, and `anchor`
lists the five classes off the jar. Docker: the pinned socket on every call, both images by their digests, `--pull never`;
`TESTCONTAINERS_RYUK_DISABLED=true` for the verify, as unit 14's receipt sets it; the image list and the volume count asserted unchanged
at the end, Testcontainers' container gone after the verify. No Compose run in this unit. Nothing in this unit touched the network until
the commit's push; the harness's HTTP requests go to TiffinBox's own web server on 127.0.0.1.

## The folders, the harness and the ports

- `harness/src/probe/u15/U15.java` — TiffinBox's application class with its web server (unit 14's form: steps `info`, `http`, `rail`,
  `railgone`, `noorders`, `hold`), read through the context's own beans; it writes nothing to Redis.
- `harness/src/probe/u15/H15.java` — the repository-only harness JVM: the shipped `KitchenOrder` and `KitchenOrders`, Lettuce's connection
  factory, the two templates and one repository configuration (`h15.mode=shipped` — the shipped `RedisDatastore`; `h15.mode=off` — the
  harness's own, keyspace events OFF); steps `config`, `clear`, `save3`, `resave`, `java`, `mon` (an `ECHO h15:<operation>` marker before
  each operation, for `MONITOR`), `pause`, `hold`. Its `pause` step polls a file with a `Thread.sleep` between looks — a poll for the
  receipt's go, never the proof.
- `harness/src/probe/x/XMain.java` — `c7-unit29`'s schema probe, byte for byte.
- `harness/variants.py` — four labelled copies of `after/`, one line each, for the planted faults only (no capture of record runs a copy):
  `noprofile`, `uuid`, `nottl`, `off`.
- `harness/chk15.py` (the checks), `harness/s815.py` (the prose gate, its self-test first; XFAM_S2's bytes inside it, md5 equal to
  `s814.py`'s block), `harness/tree15.py` (the pins), `harness/surefire.py` and `harness/dur8.py` (unit 02's, byte for byte),
  `harness/logback.xml` (unit 07's).
- `exercise/` — `README.md`, `SOLUTION.md`, `Rail.java`.
- Ports 20540-20549: 20540 TiffinBox `after/` (the harness's web server, the seven, the stopped starts' web port); 20541 the PostgreSQL
  container; 20542 the Redis container — and the exercise's own Redis, which runs before it; 20543 `before/` for the seven; **20544
  `noconfig`'s second Redis**, a spare bound because the refusing server must be another container — the unit's own Redis keeps
  `CONFIG`, which every other capture reads and resets; 20549 the port "Redis absent" points at, asserted unbound; 20545-20548 never bound.

## Masks, filters and hygiene — every one, declared

The receipt masks Boot's `Started … in <t>`, `scanning in <t>`, `initialization completed in <t>`, Flyway's execution time,
Testcontainers' `started in PT<t>S`, Surefire's `Time elapsed`, Maven's `Total time`, any `TTL <n>`, a JVM's `pid <n>`, object hashes
after `@`, the folders and the home — and Section 3's: **the harness's `-Dh15.ttl=<ttl>` and `--tiffinbox.kitchen-order-ttl=<ttl>` on every
command line, HGETALL's `ttl <n>`, MONITOR's `"ttl" "<n>"` field and its `"EXPIRE" "<key>" "<n>"`, and the poll counts (`polled <k>
times`)**. MONITOR's own prefix (the unix time and `[0 <client>]`) is stripped before a line is printed; `PTTL` is never printed as its
number — the receipt prints `-1`, `-2` as Redis prints them and a positive reply as "yes (> 0, the value masked)". The mask's self-test
refuses each planted line unmasked. Captures hold no absolute path, log time, stack frame, raw container port, token or password; dur8
over the captures and this README's text blocks: 0. Netty's DNS line on macOS (`MacOSDnsServerAddressStreamProvider`, at WARN) prints in
every JVM that opens a Redis connection; it is counted and named on each JVM's line, never filtered out.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM, Maven, the exercise's shell, the MONITOR client's
`dk exec` — after Redis itself has dropped that client, `CLIENT KILL ID`), removes its containers with their volumes (`rm -fv`: PostgreSQL,
Redis, the exercise's, `noconfig`'s), removes any Testcontainers container, deletes the partial captures, and exits 130. Measured
2026-11-19, from 10:38 to 10:48 CET, each run alone, `receipts.sh` started by a driver with SIGINT reset to its default (`perl`, R.410) and
SIGINT sent when a marker appeared in the run's own fresh `.harness`: **mid-build** (Maven building `before/`'s core module), **mid-verify**
(Surefire running the tests), **mid-TiffinBox on PostgreSQL** (`anchor`'s first dev start, up), **mid-harness, mid-save** (`keys`' repository
JVM, its `deleteAll` done, the three saves under way), **mid-MONITOR** (`monitor`'s client started, its `OK` read). Each: exit 130; read
when the run had stopped and again after a pause of the driver's — no java process, no container of this unit's, no Testcontainers
container, no MONITOR client process, volumes and images at their counts, nothing listening on 20540-20549, `.r-lock` gone, no
partial capture, `receipts.md5` unchanged, the committed captures' bytes unchanged. One more, unplanned, during the script's writing: a run
stopped by hand at the MONITOR window left the same nothing behind.

## The ledger rows this unit pays

- The roadmap's three nouns for this unit — **`@RedisHash`** (`keys`, `anchor`), **secondary indexes** (`keys`, `monitor`, `stale`) and
  **per-entity TTL** (`ttl`, `events`) — and Section 2's CARRIED row "Spring Data Redis repositories, TTL per entity, secondary indexes":
  paid here. No ledger row is opened or closed otherwise; C8-15's Redis half was unit 14's.

## RE-MEASURE — the plan's items this unit settles

- **4** — the shipped entity's name, package, time-to-live key, ids and save path: `com.tiffinbox.web.KitchenOrder`, hash
  `kitchen-order:<id>`, `tiffinbox.kitchen-order-ttl`, ids `<customer>-<day>`, the same across three starts (`anchor`), the save in
  `start()`'s loop; its timed save under ON_STARTUP counted off MONITOR, its keys, and the stale/clean pair on both shapes, read while a repository listens (above).
- **5** — `findAll()` reads `TTL` per id: its untimed element carries `-1`; a derived finder reads the hash alone, so its untimed element
  carries `null` (`ttl`) — said, the shipped entity prints the same as the probe. Read off the run too: a finder's timed element carries
  the stored `ttl` field (the configured number, printed `set`), not `null`.
- **6** — `spring.data.redis.repositories.enabled: false` with the dev profile's explicit `@EnableRedisRepositories`: the dev run prints
  `Found 1 Redis repository interface` (`anchor`), the default run no Redis repository line at all (`default`, `seven`).
- **11** — the seven and the tests on 15/after (`seven`, `anchor`); the default run's health and `/leaderboard` (`default`).
- **13** — `nolisten` and the exercise's pair on 15/after's classes, polled, 3/3 (`nolisten`; the exercise across the runs).

## The anchor moved — the builders (R.211, R.331)

Before the commit: `grep -n 'c8-tiffinbox\|TiffinBoxServer\|TiffinBoxProperties\|application.yaml\|application-dev.yaml\|compose.yaml\|RedisDatastoreIT\|tiffinbox-web/pom'`
over `_builders/s80*.py`, `_builders/s81*.py`, `check_unit8.py`, `qa_java8.py` and `build_java8.py`, and `grep -n
'application.yaml\|compose.yaml\|TiffinBoxServer'` over every `c8-unit*/receipts.sh` (its hits read in full before the commit, the agent's report says where they are kept). The builders'
live compares (`s801.py`-`s813.py`, each between its "R.211 live compare" comments) read `c8-tiffinbox`'s files only to print a note when
the live anchor has moved on; every claim a builder makes reads `git show <its pinned commit>` or a `c8-unitNN/` path. The shipped
receipts read their own frozen `after/` and `before/` copies; the other hits are comments. Nothing reads a changed file live in a way that
fails; no builder and no earlier unit was edited — unit 14's grep, the same answer.

## Next

*Pub/Sub and Streams* (16) moves the anchor next: `KitchenEvents`, the stream bridge under "dev", the compose note's third sentence (the
kitchen stream, which a new container loses) — the room this unit's note leaves — and `18 + 8`.

## What differed from the brief

- **The shape question (RE-MEASURE 4).** The brief's small numbers are the probe's three orders; the shipped start saves one order per
  placed order. Both are captured and labelled (*Whose save, which number*): the start's saves through TiffinBox's application class
  (`anchor`, `events`' second half), the harness's three through the shipped repository in a **repository-only harness JVM**, not
  TiffinBox's application class — every TiffinBox start saves its own orders beside the three, and `nolisten`'s idle JVM must save
  nothing. The prompt's "the running dev context's, after `FLUSHALL`" form was refused for that reason, not for cost.
- **The id form:** `<customer>-<day>`, the loop's own counters (`Ravi-1` … `Ravi-30`), asserted across three starts by both witnesses'
  sorted md5.
- **The time-to-live setting:** a `Duration` component of `TiffinBoxProperties` (the record that binds `tiffinbox.*`), its whole number handed to
  the entity, absent or zero = untimed; the shipped value is written the way the cache's backstop is, and every capture masks it.
- **`toString` leaves the time to live out** (`KitchenOrder[<id>,<customer>,<mealType>,<value>]`); the harness prints an element's `ttl`
  as `set`, `-1` or `null`.
- **No `:phantom` beside the start's saves** — read off the run, not in the brief: the start saves in `@PostConstruct`, before the
  repository's listener starts, and Spring Data Redis keeps the phantom copy only while its listener runs. The running listener still
  cleans their ids (`events`' second half).
- **`startstop` on 15/after prints unit 14's line**, `Error creating bean with name 'tiffinBoxServer'` ← `RedisConnectionFailureException`
  — the fill fails first; `Failed to start bean 'redisKeyValueAdapter'` prints none there. The adapter's own failure is measured on the
  shipped `RedisDatastore` in the repository-only JVM (3/3), **not on a `variants.py nofill` copy** — the class itself, no source change.
  `application-dev.yaml`'s unit 14 note therefore stays complete and is not extended.
- **`stale`'s OFF** is the harness's own `@EnableRedisRepositories` over the shipped classes, not a `variants.py off` copy; the copy exists
  for the planted faults only.
- **The start's own stale/clean pair is in `events`** (the clean half on the shipped shape, the setting low on the command line); `stale`
  carries the harness's three.
- **`nolisten` stops `j1` with SIGINT** (exit 130), not BLUE's `kill -9`: the receipt's rule (R.410), and both hashes are asserted present
  at the signal.
- **The IT's import form:** `@Import({Leaderboard.class, RedisDatastore.class})` under the class's existing `@ActiveProfiles("dev")` — the
  repository appears by the import alone; no test property.
- **`CLIENT KILL TYPE monitor` is refused by Redis 8.10.3** (`ERR Unknown client type 'monitor'`, read off an early run): the receipt stops
  the MONITOR client by its id (`CLIENT LIST`, flags `O`, then `CLIENT KILL ID`).
- **RE-MEASURE 5, one reading more than the brief's:** a finder's *timed* element carries the stored `ttl` field (`set`), not `null`; the
  untimed element is `null`, as the probe said.
- **The poll counts are masked in the captures** (`polled <k> times`): they move run to run, and the captures are hashed 3/3. Each run's
  counts are printed in its own log, outside the captures.
- **JPA's "Could not safely identify store assignment … KitchenOrders"** prints on the default run too (JPA's scan sees the interface there);
  said in `default`.
- **No duration sentence about the AOT step** for `spring.data.redis.repositories.enabled` (the prompt's "only if you measured" — not
  measured, left out).

## For RED

- The small-number beats are a repository-only JVM's, not TiffinBox's: the classes are the shipped ones (the receipt compiles the harness
  against `after/`'s jar), the configuration is the shipped `RedisDatastore` (registered by class name — it is package-private), the
  connection factory and templates the harness's own. A viewer's TiffinBox registers the same repository through the same class.
- The start's ids are overwritten each start (`DEL`, `HMSET`, the `SADD`s again — the same command shape `monitor` counts), so `SCARD` stays
  the orders' count: three starts print the same count and md5. Whether an id that a changed seed no longer places would linger is not
  measured (the seed is fixed).
- `events`' second half sets the start's time to live low on the command line so it ends inside a window; the listener must be up before
  it ends — the start's own listener starts after the saves, so a value too low would leave the ids stale (the `nolisten` condition in
  miniature). The receipt's value is masked; the capture asserts every id cleaned, 3/3.
- `nolisten`'s ten reads are a hold of the receipt's (a pause between reads, labelled in the line), to show nothing moves — the one place
  the receipt waits without a count condition; no clean read follows it.
- The exercise's poll is Java's (the program reads `hasKey` and `SCARD` in a loop with a cap), printed as "reached" / "not reached"; the
  check is `count()` and `SCARD`, never the exit.
- `noconfig`'s second Redis is left with the start's saves on it until its `rm -fv` — read and printed before the removal.
- The R.211/R.331 grep's hits are filed in the receipts' scratch (`r211.txt`); the live compares print notes only.
- dur8's list over the Javadoc, YAML and compose lines C2 added: 0 (the receipt's gate); two of dur8's words were written once in this
  unit's drafts (a YAML comment, a Javadoc line) and taken out before any run.

## Planted faults — each caught (R.65, R.226)

Each plant ran alone — never beside a run of record — after the three runs of record: a doctored capture or a copy of `after/` checked by
`chk15.py` (Python, never `sed`), a planted sentence on a copy of this README checked by `s815.py`, or a planted file in the sealed clone
checked by that clone's `receipts.sh`. Each plant exited 1, naming its rule; each control — every capture as captured, `static` and `r250`
on `after/`, this README as written — exited 0; nothing in this unit was written (the clone restored after each, its `diff -rq` against
this folder empty). Forty-four plants on the checks and seven on the clone's gates, all caught; fifteen controls clean.

- **The plan's list for unit 15:** the cleanup said as the repository's own, with OFF — `stale`'s `count()` doctored to the clean count
  (both witnesses no longer agree), and the sentence itself (R.403); ON_STARTUP on the default run — a copy without `@Profile("dev")` on
  `RedisDatastore` (`static`), `default` doctored to print a Redis repository line, `startstop` doctored to a start that did not stop; SQL's
  word for `SINTER` (R.401); `CONFIG` not reset before the OFF run — `stale`'s before line doctored to `xE`; **a fresh start said to repair
  the stale index** — `nolisten`'s ten reads and its no-JVM count doctored to the clean count, and the sentence (R.403); **the cleanup read
  after a settle sleep** — a `sleep` put between the `EXISTS` poll and the clean read in a copy of `receipts.sh` (`static` names the line),
  a clean read with no poll count (`events`), and the sentence (R.412); ids that are not deterministic — a copy with a UUID id (`static`)
  and `anchor`'s second start's md5 moved (the three-starts check); a save without the time to live — a copy (`static`) and `ttl`'s timed
  `PTTL` doctored to `-1`; keyspace events OFF in the shipped tree — a copy (`static`).
- **Doctored captures:** a null deleted from `stale`'s `findAll()`; `xE` → `""` in `events`' after line; four of a timed save's lines
  deleted from `monitor` (the count the source gives no longer met); `-1` → a positive reply in `ttl`'s untimed line; the `Error creating
  bean` count deleted from `startstop`; the refused `CONFIG` line deleted from `noconfig`; `default`'s not found turned to found; a phantom
  for the untimed order in `keys`; `anchor`'s `HHH000001` line deleted and a version moved; the seven's hash changed; the exercise's solved
  block made the broken one and a "What it prints" count changed (R.196).
- **Copies of `after/`:** the four of `variants.py`; `compose.yaml`'s "no spring.data.redis key anywhere" with its note taken off (R.250); a
  volume added for Redis (⚑15).
- **The prose gate:** the duration family (dur8, XFAM_S2's); a wait word (R.402); a delivery word (R.404); the default run said
  to need Redis (R.400); an absent store's route error beside a green health (R.413); the harness's order without its label (R.392); a Redis claim with one client's answer
  (R.398); a container removal without the volume flag (R.387); a module build without its dependencies' flag (R.391); an ON_STARTUP
  cleanup without its condition (R.403).
- **The clone's receipt:** a dish name (R.215); a placeholder; `before` linked to unit 13's tree (R.211); a container removed without `-v`
  (R.387); a `docker` call without the socket (R.344); the solution's block equal to the broken one (R.196); a duration word in
  `KitchenOrder`'s Javadoc (stopped first by the after-tree pin, R.211 — the copy is no longer the pinned tree — before the dur8 gate).

Not planted here: a wrong published hash in `receipts.md5` (the `pub` step is unit 14's, byte for byte; each run of record compared every
capture with its published hash).

## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: the line 25 words · broken (keyspace events off): with the JVM up after both timed hashes are gone, count() 3 = SCARD 3, findAll() two nulls · solved (ON_STARTUP, the same ids saved and the JVM up): count() 1 = SCARD 1, the VEG index set gone · exit 0 both (a standalone harness JVM on the shipped KitchenOrders, Redis by the digest, no TiffinBox, no database) · anchor: 15/after, profile dev, PostgreSQL + Redis, the start's saves: Found 1 Redis repository interface (and 1 JPA, 1 JDBC; JPA's INFO line declines KitchenOrders) · count() 120 = SCARD kitchen-order 120 = orders cooked, the index sets 30 per customer, three starts SCARD unchanged and SMEMBERS byte-equal (md5 30c12bb7…), the third SIGINT -> exit 130 · no :phantom beside the start's saves · CONFIG GET "" before -> xE (during and after) · health 200 · /dashboard 200 · /leaderboard 200 · tests 18 (mvn -o package, no Docker) and 18 + 7 (mvn -o verify) · libs 122 -> 122 (none gained) · Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/JDBC/Redis 4.1.2 · Lettuce 7.5.2.RELEASE · HHH000001 7.4.13.Final · Flyway 12.4.0 · redis_version:8.10.3 · keys: the harness's three orders through the shipped repository (15/after's classes, ON_STARTUP): keys kitchen-order (set), kitchen-order:<id> (hash) ×3, :idx (set) ×3, :phantom (hash) ×2 timed only, kitchen-order:customer:<name> and :mealType:<type> (sets) · the timed hash holds ttl (masked), the untimed none · count() 3 = SCARD 3 · monitor: MONITOR, the harness's saves through the shipped repository: untimed save 7 commands · timed save under ON_STARTUP 11 · findByMealType 1 SINTER + 2 HGETALL · findByCustomerAndMealType 1 SINTER of two sets + 1 HGETALL · findAll() SMEMBERS + HGETALL and TTL per id = 7 · count() 1 SCARD · ttl: the harness's orders through the shipped repository: PTTL timed yes (> 0, masked), untimed -1 · :phantom 1 timed / 0 untimed · findAll()'s untimed element ttl -1, a finder's null (RE-MEASURE 5) · events: ON_STARTUP, the harness's three orders: CONFIG GET "" -> xE (the start), the two timed hashes gone while the JVM runs (EXISTS polled to 0) -> SCARD polled to 1, the VEG set to 0 -> count() 1, findAll() [o3] · the start's own 120 orders (15/after, dev, the setting low on the command line): EXISTS polled to 0, SCARD polled to 0 -> count() 0, findAll() [] while TiffinBox runs, no :phantom needed · nolisten: nolisten, the harness's orders through the shipped repository: the JVM stopped (SIGINT, exit 130) before their time to live ended, the hashes gone with no JVM up -> SCARD 3, VEG o1 o2, :phantom 1, xE · a fresh ON_STARTUP JVM, idle -> SCARD ten reads 3333333333 · a JVM that saves the same ids again and stays up -> SCARD polled to 1, the VEG set gone, count() 1 · stale: stale, keyspace events OFF (the harness's configuration over the shipped repository): CONFIG GET "" before and after · the two timed hashes gone (EXISTS 0) -> count() 3 = SCARD 3, findAll() two nulls beside o3, SMEMBERS VEG o1 o2, findByMealType(VEG) [] (it hides them), findById(o1) empty, existsById false · no exception (ERROR 0, no line naming an Exception) · startstop: startstop, 15/after's jar, profile dev, PostgreSQL up, Redis absent: the start stops - Error creating bean with name 'tiffinBoxServer' <- RedisConnectionFailureException (the start's fill, unit 14's), exit 1, curl 000; the adapter's line 0 there · the shipped RedisDatastore alone (the repository-only JVM): Failed to start bean 'redisKeyValueAdapter' <- RedisConnectionFailureException, exit 1 (control: anchor) · noconfig: noconfig, the same digest with --rename-command CONFIG "" (20544): redis-cli CONFIG GET -> ERR unknown command 'CONFIG' · 15/after under dev -> Failed to start bean 'redisKeyValueAdapter' <- ERR unknown command 'CONFIG', exit 1, curl 000 (the start's 120 saves had reached it) (control: events) · default: 15/after, default run, H2, no Redis, no Docker: health 200 · /leaderboard 404 · /dashboard 200 · KitchenOrders beans 0 · no Redis repository line (grep 0; JPA's INFO line on KitchenOrders 1) · the 18 under mvn -o package, Docker at nothing · seven: the seven 466c20ed… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · /leaderboard 404 on the default run · Hibernate's script = xcheck.sql
<!-- values: end -->

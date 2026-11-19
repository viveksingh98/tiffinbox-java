# c8-unit14 — Redis Data Structures From Java

Course 8, Section 3's first unit and **Section 3's first change to the anchor (C1)**. `before` is a link to `../c8-unit13/after`
(unit 13's tree; the receipt pins it and asserts that pin is unit 13's own after-tree line); `after/` is this unit's tree, and
`../c8-tiffinbox` equals `after/` from this unit's commit on. **Section 3 starts here: Redis as a datastore, under the profile dev.**
Until this unit Redis held what a method last returned — the cache's entries. From here it also holds data of its own: the kitchen's
leaderboard, a sorted set (members kept in order by a number Redis stores beside each) of every customer's order value, filled by the
start from the orders it places, written through `StringRedisTemplate` and read back by redis-cli by name — while Boot's other template
bean, `redisTemplate`, writes the same scores under a key redis-cli cannot find by name.

Every Redis number below comes from two witnesses in the same run (R.398): **Java's answer** — the shipped `Leaderboard`'s route,
`GET /leaderboard`, or a template bean of the running context (`StringRedisTemplate`; for the trap, Boot's `redisTemplate`) — and
**redis-cli inside the Redis container** (`docker -H "$DH" exec`, the image's own client, never a host install), run while a harness JVM waits at
a pause. The leaderboard's four scores have a third witness: their sum is `/kitchen`'s `ordersValue` and the start's own `kitchen
value:` log line, three numbers from one run (RE-MEASURE 1). Redis is **Redis 8.10.3, by the digest** (`redis@sha256:7958cfbb…935c3`,
`--pull never`, `127.0.0.1` only, no password); PostgreSQL is 18.6 by the capstone's digest. Every line names its tree and profile:
**14/after, profile dev, PostgreSQL + Redis** (the dev shape; the `Leaderboard` bean exists there only), **14/after, default run, H2, no
Redis**, or **the harness's** (its own keys `h14:…`, its own fills — labelled where they print).

Eleven captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `exercise` and the
tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string below is asserted
after its capture by `harness/chk14.py` against a second witness of the same run. Evidence by a Claude Opus 5.5 agent on
2026-11-19, started 06:32 CET.

## Runs of record

**On the script as committed:** `bash receipts.sh` (Homebrew bash 5.3.9, 2026-11-19 from 07:19:59 CET, ended 07:25:44), a sealed fresh
clone (below, from 07:25:54, ended 07:31:48) and `./receipts.sh` (/bin/bash 3.2.57, from 07:32:01, ended 07:37:45): each with every
capture = published (the JVM ones 3/3 inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file count
unchanged, volumes back to their count and the images unchanged, `before/` and `after/` = their pins at the start and the end, nothing
listening on 20530-20539 at the end, each log ending `exit 0`; each log through `check_unit8.py 14 --runlog` — `RESULT (run logs):
PASS` (the unit gate itself has no unit 14 script yet, as expected). **Nothing was downloaded.** Earlier runs during the script's writing
stopped on checks of this unit's own making (the third start's SIGINT racing the pause's resume, fixed by a step the signal alone ends; the #119 window reading a cold cache, fixed by a request that caches the list first and a window per state); the last of
them printed every capture's hash, written into `receipts.md5`; the planted faults ran after it, alone, and `chk14.py`'s static check was
fixed once (a planted fill without the reset stopped it with a Python error, not a FAIL line) — no capture moved.

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `3478b30` into a path **with a space** (`…/sealed
14/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c8-unit14 c8-tiffinbox`; `diff -rq` against the working folder printed nothing), the clone's `.m2-demo` a file copy
of the seed, `env -i` with `HOME`, `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`
and dead proxies for http and https (`127.0.0.1:9`); `./receipts.sh`. The runs ran on this README before its *Runs of record* and
*Interrupted* paragraphs were written; the prose gate and the text-block and values checks were run again on the final README against
the last run's printed lines.

## C1 — the change, file by file, and every README/YAML/Javadoc/compose sentence it rewrote or noted (R.250)

Eight files new or changed besides the anchor README; nothing deleted; `application.yaml` untouched (`spring.data.redis.repositories.enabled`
is unit 15's, ⚑4); Flyway's V1-V3 untouched, `ddl-auto: validate` untouched, Hibernate's schema script still `xcheck.sql` =
`../c7-unit39/xcheck.sql` (`seven`); no jar gained or lost (`anchor`). The receipt asserts `RedisCaching.java`, `TiffinBoxApp.java`,
`KitchenMetrics.java`, `CustomerRepository.java`, `Dashboard.java`, `application.yaml` and the root and core `pom.xml` byte-equal to
`before/`'s, and `chk14.py static` that the files below are the only ones that moved.

- `tiffinbox-web/src/main/java/com/tiffinbox/web/Leaderboard.java` — **new**: `@RestController @Profile("dev")`, built on
  **`StringRedisTemplate`** (R.399), the key `tiffinbox:leaderboard`; `reset()` is `DEL`, `record(customer, value)` one `ZINCRBY`, and
  `GET /leaderboard` reads `reverseRangeWithScores(0, -1)` — `ZREVRANGE … WITHSCORES` — into a `LinkedHashMap`, so the JSON object keeps
  the order Redis returned, highest score first (BLUE's shape, kept). A "Course 8, unit 14" Javadoc in the anchor's voice: the section,
  why `StringRedisTemplate` (the trap), why the start resets it (`twice`), why dev-only ("under the profile dev, Redis is required").
  `reset` and `record` are public (the harness's `twice` calls them); the route is package-private, as the anchor's routes are.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java` — the constructor takes an **`ObjectProvider<Leaderboard>`**;
  `start()` asks it once (`getIfAvailable()`): with a bean it calls `reset()`, then `record(order.customer(), order.value())` for every
  order it places — the order's own value, meals times price, the number `KitchenMetrics` sums (derived from the order the kitchen
  takes, never typed). The fill stays in `start()` (⚑5) and is not guarded (READ FIRST 14): under "dev" a start that cannot reach Redis
  stops (`absent`). Two "Course 8, unit 14" Javadoc paragraphs, the class's and `start()`'s.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java` — **#119, in place**: after "UP while the database
  answers", a *Course 8, unit 14* note with the fact re-measured here (`notes`, RE-MEASURE 2). Its md5 moves; both md5s are printed in
  `notes`.
- `compose.yaml` — **⚑15, in place**: both sentences kept, each with a *Course 8, unit 14* note — Redis is also a store; the start
  deletes the leaderboard and fills it again, so a new container loses nothing the start does not refill; still no volume (a volume
  would keep only what the start rebuilds; removing the containers keeps Postgres's data, in its volume, and loses Redis's). Units 15
  and 16 extend this note by one sentence each; it leaves them room. The "nothing secret" sentence gains a note too.
- `tiffinbox-web/src/main/resources/application-dev.yaml` — its health comment ("with Redis down, …") gains a *Course 8, unit
  14* note: with Redis down when TiffinBox starts, under "dev" there is no health to read — the start stops. Not in the Section 3
  plan's file list; R.250 asks for it (What differed).
- `tiffinbox-web/pom.xml` — **`spring-boot-starter-data-redis-test`**, test scope, no version typed (Boot's parent manages it), with a
  comment in the Testcontainers block's style; the container-tests comment names the new IT. In the seed (`org/springframework/boot/
  spring-boot-starter-data-redis-test/4.1.2`, `spring-boot-data-redis-test/4.1.2`, asserted by the receipt).
- `tiffinbox-web/src/test/java/slice/RedisSlice.java` — **new**, the slices' form (`@SpringBootConfiguration`), plus
  `@AutoConfigurationPackage`: without it the slice's start stops (`Unable to retrieve @EnableAutoConfiguration base packages`, measured
  on the first try) — Spring Data Redis's repository scan needs a package; this one holds none.
- `tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java` — **new** (⚑14): `@DataRedisTest` +
  `@ContextConfiguration(classes = RedisSlice.class)` + `@Import(Leaderboard.class)` + `@ActiveProfiles("dev")`, a `GenericContainer` on
  the pinned digest with `@ServiceConnection(name = "redis")`; one test — the shipped bean records four customers' values and reads the
  board back, and the slice's own `StringRedisTemplate` reads the same key (its type, Ravi's score, Sunil's rank, the order).

The sentences C1 made false or dated, each with its note in place (R.250; `chk14.py r250` asserts each note after its sentence):

- `compose.yaml`, "Course 8, unit 11: Redis, the cache's store under the profile "dev"" — "(Course 8, unit 14: Redis is also a store
  since, not only the cache's …)";
- `compose.yaml`, "No volume: the image declares none …, and a cache is rebuilt from the database." — "(Course 8, unit 14: so is the
  leaderboard …)";
- `compose.yaml`, "… and the cache holds nothing secret." — "(Course 8, unit 14: nor does the leaderboard …)";
- `KitchenHealthIndicator.java`, "UP while the database answers" — "(Course 8, unit 14: not while the customer list is cached …)" (#119);
- `application-dev.yaml`, "with Redis down, …" (Redis's indicator, under "dev") — "(Course 8, unit 14: with Redis down when TiffinBox
  starts, there is no health to read since …)";
- the anchor README's header, after unit 13's note — a unit 14 note: Section 3's first change, Redis also a store, required under
  "dev", the default run still needs none;
- the anchor README's unit 13 section, "**Section 3 starts here**, on this tree" — *(Course 8, unit 14: it has …)*.

Kept as they are, still true, read one by one: "the default run … needs no Redis" (the anchor README's unit 11, 12 and 13 sections,
`application.yaml`'s cache comment, `pom.xml`'s unit 11 comment, `RedisCaching.java`'s Javadoc — `default` measures it again); "no
`spring.data.redis` key anywhere" (`compose.yaml`, the README's unit 11 section — still none, `chk14.py static`); `RedisCaching.java`'s
"How Redis keeps TiffinBox's cache" (it is the cache's configuration only). The anchor README gains its `## Course 8 · unit 14` section
in the unit 13 section's shape. `c8-unit13/README.md`'s own hand-off ("**Section 3 starts on `after/`.**") is not edited — it is done,
said here.

## Section 3's name, and Section 2's sentence (C8-15, C8-22)

Course 7's finale, *What's Next: Not Everything Is a Relation* (`java7_series.TITLES["40"]`), named the section this unit opens — the
ledger's C8-15 quotes it: "Two of its sections are called Redis as a datastore, and Document and search, and the second of those opens
with MongoDB, Documents, Not Rows." Units 14 to 17 are that section, *Redis as a datastore*; this unit pays C8-15's Redis half (the Mongo
half is Section 4's). Section 2 pinned one sentence (C8-22, `../c8-unit12/pinned.txt`, *Cache Invalidation*; its md5 asserted equal to
this repository's 3478b30 copy in `notes`), byte for byte:

> A cache holds what the method last returned; a write that never passes through the cache leaves it serving the old value.

Then the contrast, measured: the leaderboard is no method's return value and no table's column — it is Redis's own data. No method
returns it and no table holds it: `start()` writes it from the orders the kitchen takes, `GET /leaderboard` reads Redis, and the
default run, which has no Redis, has no leaderboard at all (`zset`, `default`). C8-22 is paid.

## The captures — what each one shows

### 1 · anchor — the dev shape, three starts in a row, the tests, the versions (C1, R.400, RE-MEASURE 1 and 11)

The tests first: `mvn -o package` with Maven's `DOCKER_HOST` at nothing runs the H2 tests and no container test; `mvn -o verify` with
Docker runs them again and then the container tests — `RedisDatastoreIT` beside unit 07's two classes: one test more than unit 13's
container tests, its cause the new IT (R.363, R.80). The jar's libraries are counted on `before/` and `after/`: the same, none gained
(the new starter is test scope). Then **14/after, profile dev, PostgreSQL + Redis**: one fresh database, one Redis, three starts in a
row against it, the third ended by SIGINT at its pause (the JVM's SIGINT reset to its default by `perl`, R.410). Every dev JVM carries
the same overrides: `--spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1
--spring.data.redis.port=20532` (Compose off: no Compose run), the PostgreSQL URL from the config tree (as unit 13's receipts did; its
password never on a command line), `--logging.level.tiffinbox=INFO` (the start's two log lines).

```text
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  Surefire's Results line: Tests run: 6, Failures: 0, Errors: 0, Skipped: 0
    REDIS IT the board, through Leaderboard: {Sunil=9000.0, Ravi=7200.0, Meera=4500.0, Priya=3600.0}
    REDIS IT the same key, through the slice's StringRedisTemplate: type zset · score(Ravi) 7200.0 · reverseRank(Sunil) 0 · order [Sunil, Ravi, Meera, Priya]
  before/: 122 libraries · spring-data-redis and lettuce in lib/: lettuce-core-7.5.2.RELEASE.jar spring-data-redis-4.1.2.jar
  after/: 122 libraries · spring-data-redis and lettuce in lib/: lettuce-core-7.5.2.RELEASE.jar spring-data-redis-4.1.2.jar
  gained: 0 · lost: 0
  the Redis container's own client: redis-cli 8.10.3 · INFO server: redis_version:8.10.3
-- start 1 of 3:
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Found 1 JPA repository interface
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Found 1 JDBC repository interface
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Found 0 Redis repository interfaces
  log: HHH000001: Hibernate ORM core version 7.4.13.Final
  log: tiffinbox: orders cooked:  120
  log: tiffinbox: kitchen value:  24300
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data JDBC 4.1.2 · Spring Data Redis 4.1.2 · Lettuce 7.5.2.RELEASE/5728917 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
PROBE CacheManager beans 1 [cacheManager=org.springframework.data.redis.cache.RedisCacheManager] (profile dev, PostgreSQL 18.6)
PROBE Leaderboard beans 1 [leaderboard=com.tiffinbox.web.Leaderboard] (profile dev, PostgreSQL 18.6)
PROBE Redis's INFO server, through the connection: redis_version:8.10.3
PROBE http (profile dev, PostgreSQL 18.6): GET /dashboard -> 200
PROBE http (profile dev, PostgreSQL 18.6): GET /actuator/health -> 200 · status UP
PROBE http (profile dev, PostgreSQL 18.6): GET /actuator/health/readiness -> 200 · status UP
PROBE http (profile dev, PostgreSQL 18.6): GET /leaderboard -> 200 · {"Sunil":9000.0,"Ravi":7200.0,"Meera":4500.0,"Priya":3600.0}
PROBE http (profile dev, PostgreSQL 18.6): GET /kitchen -> 200 · ordersCooked 120 · ordersValue 24300
  exit 0 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0
  redis-cli ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600
-- start 2 of 3:
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Found 1 JPA repository interface
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Found 1 JDBC repository interface
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Found 0 Redis repository interfaces
  log: HHH000001: Hibernate ORM core version 7.4.13.Final
  log: tiffinbox: orders cooked:  120
  log: tiffinbox: kitchen value:  24300
PROBE http (profile dev, PostgreSQL 18.6): GET /dashboard -> 200
PROBE http (profile dev, PostgreSQL 18.6): GET /actuator/health -> 200 · status UP
PROBE http (profile dev, PostgreSQL 18.6): GET /actuator/health/readiness -> 200 · status UP
PROBE http (profile dev, PostgreSQL 18.6): GET /leaderboard -> 200 · {"Sunil":9000.0,"Ravi":7200.0,"Meera":4500.0,"Priya":3600.0}
PROBE http (profile dev, PostgreSQL 18.6): GET /kitchen -> 200 · ordersCooked 120 · ordersValue 24300
  exit 0 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0
  redis-cli ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600
-- start 3 of 3:
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Found 1 JPA repository interface
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Found 1 JDBC repository interface
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Found 0 Redis repository interfaces
  log: HHH000001: Hibernate ORM core version 7.4.13.Final
  log: tiffinbox: orders cooked:  120
  log: tiffinbox: kitchen value:  24300
PROBE http (profile dev, PostgreSQL 18.6): GET /dashboard -> 200
PROBE http (profile dev, PostgreSQL 18.6): GET /actuator/health -> 200 · status UP
PROBE http (profile dev, PostgreSQL 18.6): GET /actuator/health/readiness -> 200 · status UP
PROBE http (profile dev, PostgreSQL 18.6): GET /leaderboard -> 200 · {"Sunil":9000.0,"Ravi":7200.0,"Meera":4500.0,"Priya":3600.0}
PROBE http (profile dev, PostgreSQL 18.6): GET /kitchen -> 200 · ordersCooked 120 · ordersValue 24300
PROBE hold (profile dev, PostgreSQL 18.6): pid <n>
  exit 130 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0
  the receipt at pause 1: kill -INT sent to the harness JVM (its pid, read off its own line)
  redis-cli ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600
```

### 2 · zset — the hook: the board by Java and by redis-cli, and its sum three ways (R.398, RE-MEASURE 1)

**14/after, profile dev, PostgreSQL + Redis**, one JVM (its own window — What differed): the board the start filled, read by the shipped
route and by the context's `StringRedisTemplate` (`reverseRangeWithScores`, `score`, `reverseRank`, `zCard`, `type`, the encoding
through the connection), then by redis-cli at the pause (`ZREVRANGE … WITHSCORES`, `ZSCORE`, `ZREVRANK`, `ZCARD`, `TYPE`, `OBJECT
ENCODING`). The check asserts the lists equal, and the sum of redis-cli's four scores equal to `/kitchen`'s `ordersValue` and to the
start's `kitchen value:` line.

```text
  log: tiffinbox: orders cooked:  120
  log: tiffinbox: kitchen value:  24300
PROBE http (profile dev, PostgreSQL 18.6): GET /leaderboard -> 200 · {"Sunil":9000.0,"Ravi":7200.0,"Meera":4500.0,"Priya":3600.0}
PROBE http (profile dev, PostgreSQL 18.6): GET /kitchen -> 200 · ordersCooked 120 · ordersValue 24300
PROBE zset (profile dev, PostgreSQL 18.6, the context's StringRedisTemplate): reverseRangeWithScores(tiffinbox:leaderboard, 0, -1) -> Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600
PROBE zset: score(Ravi) 7200.0 · reverseRank(Sunil) 0 · zCard 4 · type zset · encoding listpack
PROBE zset: the four scores' sum 24300 · /kitchen's ordersValue 24300
  the receipt at pause 1, redis-cli (the container's own client):
    ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: Sunil 9000 Ravi 7200 Meera 4500 Priya 3600
    ZSCORE tiffinbox:leaderboard Ravi: 7200 · ZREVRANK tiffinbox:leaderboard Sunil: 0 · ZCARD tiffinbox:leaderboard: 4 · TYPE tiffinbox:leaderboard: zset · OBJECT ENCODING tiffinbox:leaderboard: listpack
```

### 3 · flip — listpack, then skiplist: the threshold read off the image (the harness's keys, labelled)

The harness's keys, not the anchor's board: `CONFIG GET zset-max-listpack-entries` first (through the connection and by redis-cli), then a
key with that many members and a key with one more, each read by Java and by redis-cli, then deleted. The count is derived from the
threshold the image printed, never typed.

```text
PROBE flip (a harness's keys, not the anchor's board; profile dev, PostgreSQL 18.6): CONFIG GET zset-max-listpack-entries, through the connection -> 128
PROBE flip: h14:z128 · zCard 128 · type zset · encoding listpack
PROBE flip: h14:z129 · zCard 129 · type zset · encoding skiplist
PROBE flip: deleted 2 harness keys
  the receipt at pause 1, redis-cli: CONFIG GET zset-max-listpack-entries: zset-max-listpack-entries 128
    h14:z128: ZCARD 128 · TYPE zset · OBJECT ENCODING listpack
    h14:z129: ZCARD 129 · TYPE zset · OBJECT ENCODING skiplist
  after the JVM, redis-cli --scan --pattern 'h14:*': 0 keys
```

### 4 · structs — one structure per beat (the harness's keys, labelled)

The harness's keys: a hash per customer from the seed's row (`HSET` from a `LinkedHashMap`, R.411), the meal types' set
(`tiffinbox.meal-types`, `SADD`), and a counter (`INCR`) — the counter named for unit 17, *Distributed Locks and Rate Counters*, not
taught here. Each by Java and by redis-cli; deleted after.

```text
PROBE structs (a harness's keys, not the anchor's; profile dev, PostgreSQL 18.6): a hash from the seed's row, HSET h14:customer:Ravi (a LinkedHashMap) -> entries {mealType=VEG, pricePerMeal=120, mealsPerDay=2} · type hash · encoding listpack
PROBE structs: the meal types' set (tiffinbox.meal-types), SADD h14:meal-types -> members, sorted [NON_VEG, VEG, VEGAN] · type set · encoding listpack
PROBE structs: a counter, INCR h14:orders-placed -> 1 · type string · encoding int
PROBE structs: deleted 3 harness keys
  the receipt at pause 1, redis-cli:
    h14:customer:Ravi: TYPE hash · HGETALL mealType VEG pricePerMeal 120 mealsPerDay 2 · OBJECT ENCODING listpack
    h14:meal-types: TYPE set · SMEMBERS, sorted NON_VEG VEG VEGAN · OBJECT ENCODING listpack
    h14:orders-placed: TYPE string · GET 1 · OBJECT ENCODING int
  after the JVM, redis-cli --scan --pattern 'h14:*': 0 keys
```

### 5 · twice — why the start resets the board (the harness over the shipped `Leaderboard`, labelled)

The harness's form, chosen over a built copy: it calls the shipped `Leaderboard.record` — the start's own loop, the same orders — twice
with no reset between, on a key it emptied first; redis-cli reads the result at the pause; then `reset()` and one fill restore the start's
board. `ZINCRBY` adds: each score of the harness's two fills is twice the start's. The shipped tree's own control is `anchor`'s three
starts — the same board each time — cross-referenced, not re-run.

```text
PROBE twice (the harness calls the shipped Leaderboard.record, not the start; profile dev, PostgreSQL 18.6): the board the start left -> Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600
PROBE twice: reset() first, so the harness's two fills start from an empty key -> zCard 0
PROBE twice: two fills, 120 and 120 record calls, no reset between -> Sunil 18000 · Ravi 14400 · Meera 9000 · Priya 7200
PROBE twice: then reset() and one fill (120 record calls), the start's own shape -> Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600
  the receipt at pause 1, redis-cli: ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: Sunil 18000 Ravi 14400 Meera 9000 Priya 7200
  redis-cli ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600
```

### 6 · trap — the same fill through Boot's `redisTemplate`: the bytes redis-cli reads (R.399, the failure receipt; control: `zset`)

The harness's fill (labelled — not the anchor's `Leaderboard`) through Boot's `redisTemplate` bean, a `RedisTemplate` of `Object` and
`Object`: its key and value serializer printed off the bean. The start's board is deleted first through `StringRedisTemplate`, so the
plain key is clean. redis-cli `--no-raw` prints what Redis holds; the members are read with `EVAL`, whose `KEYS` call finds the key —
it holds bytes a shell cannot pass as an argument. Credit the serializer: Java serialization's header comes first, then a length,
then the name; Redis stores what it is handed.

```text
PROBE the template bean redisTemplate: org.springframework.data.redis.core.RedisTemplate · key serializer org.springframework.data.redis.serializer.JdkSerializationRedisSerializer · value serializer org.springframework.data.redis.serializer.JdkSerializationRedisSerializer
PROBE the template bean stringRedisTemplate: org.springframework.data.redis.core.StringRedisTemplate · key serializer org.springframework.data.redis.serializer.StringRedisSerializer · value serializer org.springframework.data.redis.serializer.StringRedisSerializer
PROBE trap (a harness's fill through Boot's redisTemplate bean, not the anchor's Leaderboard; profile dev, PostgreSQL 18.6): org.springframework.data.redis.core.RedisTemplate · key serializer org.springframework.data.redis.serializer.JdkSerializationRedisSerializer · value serializer org.springframework.data.redis.serializer.JdkSerializationRedisSerializer
PROBE trap: the start's board deleted first through StringRedisTemplate, so the plain key is clean: delete -> true
PROBE trap: 120 incrementScore calls through redisTemplate, each returned without an exception
PROBE trap: StringRedisTemplate on the plain key: hasKey false · score(Ravi) null
PROBE trap: redisTemplate on its own key: hasKey true · score(Ravi) 7200.0 · zCard 4
PROBE trap: redisTemplate.delete -> true
  exit 0 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0
  the receipt at pause 1, redis-cli (--no-raw: the bytes as Redis holds them):
    --no-raw --scan --pattern '*leaderboard*': "\xac\xed\x00\x05t\x00\x15tiffinbox:leaderboard"
    --no-raw EVAL (KEYS finds the key, which holds bytes a shell cannot pass; ZRANGE … WITHSCORES on it): "\xac\xed\x00\x05t\x00\x05Priya" "3600" "\xac\xed\x00\x05t\x00\x05Meera" "4500" "\xac\xed\x00\x05t\x00\x04Ravi" "7200" "\xac\xed\x00\x05t\x00\x05Sunil" "9000"
    ZSCORE tiffinbox:leaderboard Ravi: () · EXISTS tiffinbox:leaderboard: 0
  after the JVM, redis-cli --no-raw --scan --pattern '*leaderboard*': 0 keys
```

### 7 · absent — under the profile dev, Redis is required (R.413, RE-MEASURE 12; control: `anchor`)

**14/after's jar, profile dev, PostgreSQL up, Redis absent**: `java -jar` with the dev overrides and `--spring.data.redis.port=20539`, a
port asserted unbound first. Under the profile dev, Redis is required: without it TiffinBox does not start, and the log names the
exception. The three phrases are counted, the exit printed, and `curl` finds nothing on the web port. The control is `anchor`'s dev run
with Redis: health UP and the four scores.

```text
-- after/'s jar under the profile dev, PostgreSQL up, Redis absent: --spring.data.redis.port=20539, where nothing listens (lsof: 0 listeners); java -jar, its web server on 20530:
  the JVM's exit: 1 · then curl /actuator/health on 20530: 000 · listening on 20530: 0
  its log: "Error creating bean with name 'tiffinBoxServer'" 2 lines · "RedisConnectionFailureException: Unable to connect to Redis" 1 · "Application run failed" 1 · "Started TiffinBoxApp" 0 · "orders cooked" 0
  its first exception line: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed
  its cause: Caused by: org.springframework.data.redis.RedisConnectionFailureException: Unable to connect to Redis
  the causes, in the order the log names them: org.springframework.data.redis.RedisConnectionFailureException<io.lettuce.core.RedisConnectionException<java.net.ConnectException
```

### 8 · default — the default run never needs Redis (R.400, RE-MEASURE 11)

**14/after, default run, H2, no Redis**: no profile, Docker at nothing (`DOCKER_HOST=tcp://127.0.0.1:1`; the docker CLI pinned to its
socket all the same, R.344), Redis's port pointed at the unbound one. No `Leaderboard` bean, `/leaderboard` not found, the dashboard
answers, the cache in the JVM; and the tests without Docker, from the same run's package log.

```text
PROBE started: yes · default run, H2 2.5.250 · a web server: yes
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.caffeine.CaffeineCacheManager] (default run, H2 2.5.250)
PROBE Leaderboard beans 0 [] (default run, H2 2.5.250)
PROBE http (default run, H2 2.5.250): GET /dashboard -> 200
PROBE http (default run, H2 2.5.250): GET /actuator/health -> 200 · status UP
PROBE http (default run, H2 2.5.250): GET /actuator/health/readiness -> 200 · status UP
PROBE http (default run, H2 2.5.250): GET /leaderboard -> 404
PROBE http (default run, H2 2.5.250): GET /kitchen -> 200 · ordersCooked 120 · ordersValue 24300
PROBE noboard (default run, H2 2.5.250): getBeansOfType(Leaderboard) 0 · GET /leaderboard -> 404
  the docker CLI, pinned, with DOCKER_HOST at nothing: still on the socket - images 7 (R.344)
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

### 9 · notes — the three carried notes (⚑11) and #119 re-measured (RE-MEASURE 2)

The files this unit does not edit, each md5 against this repository's own 3478b30 copy (`git show`) — never a typed hash; the lines this
README quotes, asserted byte-equal to their files; `KitchenHealthIndicator.java`'s md5 on `before/` and on `after/`. Then #119 on
**14/after, profile dev, PostgreSQL + Redis**: psql renames the customer table under a running TiffinBox and the harness reads the
routes; psql renames it back; then a TiffinBox started with the table renamed — a cold JVM, the same Redis, its cached list still there.

```text
  ../c8-unit09/exercise/README.md: md5 aaad9ac98de570dc55b52c483b8fad44 · at 3478b30 aaad9ac98de570dc55b52c483b8fad44
  ../c8-unit09/exercise/SOLUTION.md: md5 5d24575d67514eb213db19f3a951d4dd · at 3478b30 5d24575d67514eb213db19f3a951d4dd
  ../c8-unit11/README.md: md5 3bf1904be10056db271325eb216de87c · at 3478b30 3bf1904be10056db271325eb216de87c
  ../c8-unit12/pinned.txt: md5 ba35ab90cf46ded9976dc945ca11da2d · at 3478b30 ba35ab90cf46ded9976dc945ca11da2d
  quoted in README.md byte for byte: c8-unit09/exercise/README.md:3 1 · SOLUTION.md:3 1 · c8-unit11/README.md:515 1 and :516 1 · c8-unit12/pinned.txt (C8-22) 1
  tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java: before/ md5 605d58fb9a543628dc062be3e7c767e0 · after/ md5 031db40662e9480e921c40867ac225ba · lines naming Course 8, unit 14: 1
PROBE rename (profile dev, PostgreSQL 18.6), before the receipt's first pause, a request that reads the list (the cache then holds it): GET /actuator/health -> 200
PROBE rename (profile dev, PostgreSQL 18.6), after the receipt's pause 1: GET /actuator/health -> 200 UP · GET /actuator/health/readiness -> 200 UP · GET /dashboard -> 500 · GET /customers -> 200
PROBE rename (profile dev, PostgreSQL 18.6), after the receipt's pause 2: GET /actuator/health -> 503 DOWN · GET /actuator/health/readiness -> 503 DOWN · GET /dashboard -> 500 · GET /customers -> 500
PROBE rename (profile dev, PostgreSQL 18.6), after the receipt's pause 3: GET /actuator/health -> 200 UP · GET /actuator/health/readiness -> 200 UP · GET /dashboard -> 200 · GET /customers -> 200
  the receipt at pause 1, psql (a second client, PostgreSQL): alter table customer rename to customer_renamed -> tables named customer 0 · redis-cli EXISTS 'customers::SimpleKey []': 1
  the receipt at pause 2, redis-cli: FLUSHALL -> OK · EXISTS 'customers::SimpleKey []': 0 (the cache emptied; the table still renamed)
  the receipt at pause 3, psql: renamed back -> tables named customer 1
  log: Schema validation: missing table [customer]
  log: Schema validation: missing table [customer]
PROBE started: no · org.springframework.beans.factory.BeanCreationException
  exit 1 · its log, every line but the harness's own PROBE lines: WARN 2 (Netty's DNS line on macOS: 1) · ERROR 2 · lines naming an Exception or an Error class 2
```

### 10 · seven — the comparison set on before/ and after/ (R.363)

The seven on `before/`'s jar (port 20533, a second port so the two jars never share one) and `after/`'s (port 20530), the default run on H2;
`/leaderboard` is not among the seven, and is read beside them: not found on both default runs. Hibernate's script against `xcheck.sql`.

```text
  exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 · listens on: 127.0.0.1:20533
  GET /dashboard: 200
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20533 now: 0
  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 · listens on: 127.0.0.1:20530
  GET /dashboard: 200
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20530 now: 0
  the seven, after/ against before/: lines that differ: 0
```

### 11 · exercise — run as written, in one shell, bash then zsh (R.196)

The plan's words, its word count printed: the README's block, then the solution's, in one `env -i` shell, bash then `zsh -f`. The
exercise needs Redis — it is about what redis-cli reads — so its block starts the pinned Redis by the digest itself on `127.0.0.1:20532`
(before the receipt's own containers start) and removes it with `rm -fv`; no TiffinBox and no database: `exercise/Board.java` is a
standalone harness JVM on the anchor's libraries, built offline from `.m2-demo` (`-pl tiffinbox-web -am`). That is the one honest shape
for a Section 3 exercise. Broken: the board through `RedisTemplate<Object, Object>`; solved: through `StringRedisTemplate`. **The check is
redis-cli's answer, never the exit.**

```text
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
    StringRedisTemplate in Board.java: 0
    template: RedisTemplate · key serializer JdkSerializationRedisSerializer
    orders written: 120 · no exception
    redis-cli ZSCORE tiffinbox:leaderboard Ravi: ()
    redis-cli EXISTS tiffinbox:leaderboard: 0
  then the solution's lines, in the same shell - the block's exit 0:
    StringRedisTemplate in Board.java: 1
    template: StringRedisTemplate · key serializer StringRedisSerializer
    orders written: 120 · no exception
    redis-cli ZSCORE tiffinbox:leaderboard Ravi: (7200)
    redis-cli EXISTS tiffinbox:leaderboard: 1
  the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20532 afterwards: 0 · a container named c8u14-ex: 0
```

## The three carried notes (⚑11)

**#119, in place** — `KitchenHealthIndicator.java`'s Javadoc, its note above (C1), the fact from `notes`.

**#120, not in place** — `c8-unit09/exercise/README.md:3` and `SOLUTION.md:3`, unit 09's exercise, are not edited: `c8-unit09/receipts.sh`
asserts the line byte-equal, and unit 09's video is built. Its line, byte for byte, as each file holds it:

> **Your turn:** two cached methods share one cache and answer each other's calls. Give each method a key of its own.

The note: the two methods answer each other in one direction only, as measured in Section 2 (RED-C8-S1-SCRIPTS, the Section 2 brief's
⚑11): `kSpel(a, 9)` returns `k1` — the second method's call is answered from the first's entry; the reverse was not shown. Cited, not
re-measured here. The md5s of both files are asserted unchanged in `notes`.

**`c8-unit11/README.md:515-516`, not in place** — `c8-unit11/receipts.sh` gates its prose live. The sentence, as the file holds it, its
line break kept (2026-11-19):

>   only "in at least one of the fifty: yes" (and "no" on the anchor's writer), the counts go to `.harness/raw.txt`. The stale count after
>   `@CacheEvict(allEntries = true)` is stable and is the voiced number.

The note: the video keeps it on the panel — the sentence is the panel's, as shipped; nothing here moves it. The file's md5 is asserted
unchanged in `notes`.

## Which store, which profile, which template

Every Redis line names its tree, its profile and its template. **14/after, profile dev, PostgreSQL + Redis**: `anchor`, `zset`, `absent`
(Redis absent), `notes`' #119 — the shipped `Leaderboard` on `StringRedisTemplate`, `RedisCacheManager` for the cache (unchanged from
unit 13), `LettuceConnectionFactory` on `127.0.0.1:20532`. **The harness's**, on the same dev context: `flip` and `structs` (its own
`h14:` keys, `StringRedisTemplate`), `twice` (the shipped `Leaderboard.record`, called by the harness), `trap` (Boot's `redisTemplate`,
`JdkSerializationRedisSerializer`). **14/after, default run, H2, no Redis**: `default`, `seven`, the tests' H2 half. **The exercise's
program**: `Board.java`, its own `LettuceConnectionFactory`, the exercise's own Redis. The number the video says for the board is
`zset`'s and `anchor`'s, the anchor's own; `flip`, `structs`, `twice`'s doubled board and `trap`'s bytes are the harness's, said with
the label.

## Refused, named

- The probe's `lb` profile result, "500 beside 200" (struck by BLUE, RED #1): on the shape the unit ships, the dev start stops without
  Redis (`absent`); a profile no viewer runs is not a receipt.
- "Degrade" — an empty board when Redis is absent (⚑4b): it hides the absent store; no guard around the fill.
- A Redis stopped under a running dev TiffinBox (BLUE's `b14-stopped-1`): never a receipt, never run here, never voiced (R.413).
- A volume for Redis in `compose.yaml` (⚑15): the start rebuilds the board; a volume would keep only what the start rebuilds.
- The `Leaderboard` bean on H2 or on the default run (⚑4): it is dev-only; the default run never needs Redis.
- Crediting Redis with the trap's bytes: the serializer wrote them (R.399).
- SQL's words for Redis's commands (R.401); a Redis claim with Java's answer alone or redis-cli's alone (R.398).
- A number from the harness's keys or fills voiced as the anchor's (R.392).
- A container removed without `-v` (R.387); a build that names `-pl` without `-am` (R.391); the docker CLI without its pinned socket
  (R.344); `Map.of` in any writer (R.411 — none here, asserted on `Leaderboard.java` and `Board.java`).

## Call-backs, by title (R.224)

- Course 7's *What's Next: Not Everything Is a Relation* (`java7_series.TITLES["40"]`): the section's name, C8-15.
- Course 8's *Redis as a Cache* (`java8_series.TITLES["11"]`): the Redis service, `RedisCaching`, the JSON serializer that is the cache's
  alone, and the JDK serializer Boot's template keeps.
- Course 8's *Cache Invalidation* (`java8_series.TITLES["12"]`): Section 2's pinned sentence, C8-22.
- Course 8's *Conditional Caching, sync and Nulls* (`java8_series.TITLES["13"]`): `before/`.
- This unit: *Redis Data Structures From Java* (`java8_series.TITLES["14"]`, `14-redis-data-structures-from-java`).
- Forward, by title only: *Spring Data Redis Repositories* (15), *Pub/Sub and Streams* (16), *Distributed Locks and Rate Counters* (17).

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged; under "dev" its start now needs Redis, which Compose starts beside Postgres.

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s3` (byte-identical to Section 2's); every build
reads it offline (`-o`, `maven.repo.local` as an absolute path), every one `-pl tiffinbox-web -am`, and the receipt asserts its file
count unchanged after every Maven run. Docker: the pinned socket on every call, both images by their digests, `--pull never`;
`TESTCONTAINERS_RYUK_DISABLED=true` for the verify, as unit 13's receipt sets it; the image list and the volume count asserted
unchanged at the end, Testcontainers' container gone after the verify. No Compose run in this unit. Nothing in this unit touched the
network; the harness's HTTP requests go to TiffinBox's own web server on 127.0.0.1.

## The folders, the harness and the ports

- `harness/src/probe/u14/U14.java` — the harness program (steps `info`, `http`, `zset`, `flip`, `structs`, `twice`, `trap`, `noboard`,
  `rename`, `hold`), TiffinBox's application class with its web server, read through the context's own beans; its `pause` step polls a
  file with a `Thread.sleep` between looks — a poll, never the proof. `harness/src/probe/x/XMain.java` — `c7-unit29`'s schema probe,
  byte for byte.
- `harness/variants.py` — two labelled copies of `after/`, one line each, for the planted faults only (no capture of record runs a copy):
  `noreset` (`start()` without `lb.reset()`) and `noprofile` (`Leaderboard` without `@Profile("dev")`).
- `harness/chk14.py` (the checks), `harness/s814.py` (the prose gate, its self-test first; XFAM_S2's bytes from the builders' `s813.py`
  inside it), `harness/tree14.py` (the pins), `harness/surefire.py` and `harness/dur8.py` (unit 02's, byte for byte),
  `harness/logback.xml` (unit 07's).
- `exercise/` — `README.md`, `SOLUTION.md`, `Board.java`.
- Ports 20530-20539: 20530 TiffinBox `after/` (the harness's web server, the seven, the absent start's web port); 20531 the PostgreSQL
  container; 20532 the Redis container — and the exercise's own Redis, which runs before it; 20533 `before/` for the seven; 20539 the port
  "Redis absent" points at, asserted unbound; 20534-20538 never bound.

## Masks, filters and hygiene — every one, declared

The receipt masks Boot's `Started … in <t>`, `scanning in <t>`, `initialization completed in <t>`, Flyway's execution time, Testcontainers'
`started in PT<t>S`, Surefire's `Time elapsed`, Maven's `Total time`, any `TTL <n>`, a JVM's `pid <n>` (the SIGINT step prints its own),
object hashes after `@`, the folders and the home; the mask's self-test refuses each planted line unmasked. Captures hold no absolute
path, log time, stack frame, raw container port, token or password. dur8 over the captures and this README's text blocks: 0. Netty's
DNS line on macOS (`MacOSDnsServerAddressStreamProvider`, at WARN) prints in every dev JVM; it is counted and named on each JVM's line,
never filtered out.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM, Maven, the exercise's shell), removes its two
containers and the exercise's with their volumes (`rm -fv`), removes any Testcontainers container, deletes the partial captures, and
exits 130. Measured 2026-11-19, from 07:44 to 07:58 CET, each run alone, `receipts.sh` started by a driver with SIGINT reset to its
default (`perl`, R.410) and SIGINT sent when a marker appeared in the run's own fresh `.harness`: **mid-build** (Maven building
`before/`'s core module), **mid-verify** (Surefire running the tests), **mid-TiffinBox on PostgreSQL** (`anchor`'s first dev start,
up), **mid-harness, mid-Redis fill** (`twice`, between the harness's reset and its two fills). Each: exit 130; read when the run had stopped and again
after a pause of the driver's — no java process, no container of this unit's, no Testcontainers container, volumes and images at their counts,
nothing listening on 20530-20539, `.r-lock` gone, no partial capture, `receipts.md5` unchanged. The driver's first two tries sent
the signal before `perl` had reset it (the last run's logs answered the marker), so those two receipts ran to the end, every capture
= published; the driver was fixed to look only in the run's own folder, and the two were run again. One container this unit never
made, `cc24` (`ubuntu:24.04`, created 07:28 CET, no port, no volume — another session's), was on the engine from then on; it was not
touched, and no count above moved with it.

## The ledger rows this unit pays

- **C8-15** (Redis half) — the section's name, as Course 7's finale said it; units 14 to 17 are that section. The Mongo half stays open
  for Section 4.
- **C8-22** — Section 2's pinned sentence, byte for byte (md5 asserted), then the datastore contrast, measured.

## RE-MEASURE — the plan's items this unit settles

- **1** — the shipped `Leaderboard` and start fill on the anchor's own tree, on PostgreSQL (the dev shape): the four scores; their sum =
  `/kitchen`'s `ordersValue` = the start's `kitchen value:` line (`zset`, and each of `anchor`'s starts). Settled, 3/3.
- **2** — #119's fact on 14/after before the note's words were fixed (`notes`): the kitchen's indicator UP with the table renamed — its
  read is the cached list — while `/dashboard` fails (it reads the table: the plan expected it to answer from the cache, Redis under dev; it does not);
  a cold start with the table renamed does not start. Settled, 3/3; the note says what was measured.
- **3** — `RedisDatastoreIT` on the shipped `Leaderboard` (`anchor`'s verify), the slice + `@Import` + the dev profile shape, with
  `@AutoConfigurationPackage` on the slice (What differed). Settled once per run of record.
- **11** — the seven on 14/after and before/; the default run's health and `/leaderboard` not found (`seven`, `default`). Settled.
- **12** — `absent` on 14/after: the start stops, exit 1, nothing on the web port, the bean name the shipped class's (`tiffinBoxServer`).
  Settled, 3/3.

## The anchor moved — the builders (R.211, R.331)

Before the commit: `/usr/bin/grep -n 'c8-tiffinbox\|TiffinBoxServer\|KitchenHealthIndicator\|compose.yaml\|tiffinbox-web/pom'` over
`_builders/s80*.py`, `_builders/s81*.py`, `check_unit8.py`, `qa_java8.py` and `build_java8.py`, and `/usr/bin/grep -n
'KitchenHealthIndicator\|compose.yaml'` over every `c8-unit*/receipts.sh`. The builders' live compares (`s801.py`-`s813.py`, each
`diff -rq` of its pinned tree against `c8-tiffinbox`, and `s801.py`'s two files behind an existence check) print a `note:` and never
fail (R.331); `s807.py`-`s813.py` read their anchor files through `git show` at their own evidence commits; no builder names
`KitchenHealthIndicator.java` or `compose.yaml`; the three tools name none of the four paths. The receipts: `c8-unit11/receipts.sh:103`
and `c8-unit13/receipts.sh:97` read their own frozen `after/` and `before/` copies, `c8-unit11/receipts.sh:366` reads its `after/compose.yaml`;
the other hits are comments. Nothing reads the changed files live in a way that fails; no builder and no earlier unit was edited.

## Next

Unit 15, *Spring Data Redis Repositories*, moves the anchor next: `@RedisHash` under dev, `spring.data.redis.repositories.enabled: false`
in `application.yaml`, and the compose note's second sentence (the kitchen orders, re-saved by the start). Unit 16 adds the third
sentence (the kitchen stream). The test count moves by one per unit (⚑14).

## What differed from the brief

- **`zset` in its own window.** The plan put the hook "on the dev run of `anchor` (one JVM, the same window)"; here it is its own dev JVM
  (the same tree, the same profile, the same overrides), so each capture has one window and one hash. `anchor`'s three starts still
  carry the board by both witnesses (the route and redis-cli) and the sum three ways in every start.
- **`twice` and `trap`: the harness forms, no copies.** `twice` calls the shipped `Leaderboard.record` — the start's own loop over the
  same orders — twice with no reset, on a key it empties first, and restores the start's board after; `trap` fills through Boot's own
  `redisTemplate` bean of the running context. Neither builds a copy, so `variants.py` holds only the two copies the planted faults need
  (`noreset`, `noprofile`).
- **The dev shape's datasource: the config tree**, as unit 13's receipts gave it (a 0600 file under `.harness/run-pg/secrets`), not
  `--spring.datasource.url=…` on the command line (BLUE's form): the password is never on a command line. Every other override is
  BLUE's and printed in `anchor`. A fresh database per capture window (psql's `create database`), not `pgreset`; `FLUSHALL` before
  every window, printed.
- **`RedisSlice` carries `@AutoConfigurationPackage`**, and the IT names it with `@ContextConfiguration` (the slices' form). BLUE's `bt14`
  found a configuration in its own test package; in the anchor's layout the slice's start stopped without the package (`Unable to
  retrieve @EnableAutoConfiguration base packages`, the first build of this unit), as `JdbcSlice`'s Javadoc records for its slice.
- **#119's fact is not the plan's.** The plan expected `/dashboard` to answer from the cache, Redis under dev, with the table renamed; measured, it fails
  (the dashboard reads the table), while the kitchen's indicator stays UP and `/customers` answers — both read the cached list, from
  the cache in Redis under dev. A start with the table renamed does not start: Hibernate's schema validation names the missing table. The note says that.
- **Two notes the file list did not name**, both R.250: `application-dev.yaml`'s health comment (with Redis down at the start there is
  no health to read under dev), and `compose.yaml`'s "nothing secret" sentence (the leaderboard holds nothing secret either).
- **"No Redis repository line yet."** Every dev and default run prints Spring Data's strict-mode line for Redis with zero repositories
  (since unit 11, the starter's module); the check asserts that zero and no other Redis count. Unit 15's repository makes it one.
- **Netty's DNS line.** Every dev JVM logs one WARN from Netty on macOS (`MacOSDnsServerAddressStreamProvider`); it is counted and
  named on each JVM's line. `trap`'s "no exception" is ERROR 0 and no line naming an Exception, with Netty's line the only WARN.
- **`absent` runs the jar itself** (`java -jar`, the dev overrides), so the exit printed is TiffinBox's own, not a harness's.
- **The exercise's Redis on the unit's own Redis port**, 20532, before the receipt's container starts, rather than a spare port: the
  README names it, the receipt asserts it free after each shell.
- **The prose gate is stricter than unit 13's**: XFAM_S2's bytes from the builders' `s813.py` run on every sentence, so two of
  `s813.py`'s carried self-test passes are refused here (their sentences name a time to live's end and a read close behind an evict,
  in XFAM_S2's words); the plan's own name for its document passes, its duration meaning does not. Lettuce's version prints with its build id after a slash; the check reads the release.
- **Dropped to "not captured, not said": none.**

## For RED

- `twice` is the harness's loop over the shipped bean, not a second start: a reset that moved out of `start()` would show in
  `anchor`'s three starts (the plant `noreset` below), not in `twice`.
- The third start's exit is the JVM's own on SIGINT, its disposition reset by `perl`; the board after it is read by redis-cli once the
  JVM has gone.
- `absent` shows a refused loopback port only. A host that never answers was not measured; nothing here says what that start does.
- `notes`' cold start stops in Hibernate's validation, before `start()` runs: that run never reaches the leaderboard.
- `default` points Redis's port at an unbound one; the harness prints no `RedisConnectionFactory` line there, and nothing else
  shows a connection was never tried (no MONITOR run).
- `flip`'s count comes off this image's `CONFIG GET`; on a server with another setting the two keys' sizes move with it.
- The IT is one test on the shipped bean, its container started by Testcontainers with Ryuk off and removed after the build
  (`dockeq`); `RedisDatastoreIT` reads Redis through two templates of one connection factory — two clients of one server, not
  redis-cli.
- XFAM_S2's bytes are copied into `s814.py` from the builders' `s813.py`; their md5 against `s808.py`'s slice is the builders' check,
  not run here.

## Planted faults — each caught (R.65, R.226)

Each plant ran alone — never beside a run of record — on a scratch copy: a doctored capture or a copy of `after/` checked by
`chk14.py` (Python, never `sed`), a planted sentence on a copy of this README checked by `s814.py`, or a planted file in a scratch
`git clone` of the repository checked by that clone's `receipts.sh`. Each plant exited 1, naming its rule; each control — the
untouched file — exited 0; nothing in this unit was written (the clone restored after each, its `diff -rq` against this folder empty).

- **The plan's list for unit 14:** a leaderboard on `RedisTemplate<Object, Object>` (`chk14.py static`, R.399) — and its receipt, the
  trap's `EXISTS` typed as one (`trap`); a `Leaderboard` without `@Profile("dev")` (`static`, ⚑4) — and its receipt, `default`'s not
  found typed as found; the fill without the reset in the shipped tree (`static`) — and its receipt, `anchor`'s second start doctored
  to print the board a labelled copy without the reset would print (both witnesses moved; the three-starts check fails); the trap's
  bytes credited to Redis, not the serializer (the prose gate, R.399, and the clone's receipt); C8-22's sentence off by one byte (the
  clone's receipt: the quote is not `pinned.txt`'s line); the struck probe result for the dev run, its route's error beside a green
  health (the prose gate, R.413, and the clone's receipt).
- **Doctored captures:** a score typed into `zset`'s redis-cli line that printed another (Java's list no longer redis-cli's); `trap`'s
  `EXISTS` turned to one; `absent`'s count of the `Error creating bean` line set to none; `default`'s not found turned to found;
  `flip`'s first key's encoding turned to the second's (Java's line no longer redis-cli's); `anchor`'s `HHH000001` line deleted; the
  seven's hash changed; the exercise's solved block made the broken one (R.196); `notes`' emptied-cache health turned to UP.
- **Copies of `after/`:** a guarded fill (`try` around `record`, READ FIRST 14); `compose.yaml`'s "a cache is rebuilt from the
  database" with its note taken off (R.250); a volume added for Redis (⚑15).
- **The prose gate:** the default run said to need the store (R.400); the duration family (XFAM_S2, dur8 — two words); SQL's words for
  Redis's commands (R.401); a word Section 3 leaves to Course 13 (R.404); a wait word (R.402); a typed hash prefix (R.302); the docker CLI without its
  socket (R.344); a container removal without the volume flag (R.387); a module build without its dependencies' flag (R.391); a Redis
  claim with a single client's answer (R.398); the harness's key without its label (R.392).
- **The clone's receipt:** a dish name (R.215); a placeholder; the solution's block equal to the broken one (R.196); `before` linked to
  unit 12's tree (R.211); a container removed without `-v` (R.387); a `docker` call without the socket (R.344); a build without `-am`
  (R.391); `c8-unit11/README.md` changed by one byte (⚑11); a changed "What it prints" line (the exercise ran, and its block differed
  from its printed lines).

Not planted here: a wrong published hash in `receipts.md5` (the `pub` step is unit 13's, byte for byte; each run of record compared
every capture with its published hash), and the two real copies `variants.py` derives (`noreset`, `noprofile`) were not built and run —
their faults are caught above on the static form and on the doctored captures.

## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: the line 22 words · broken (RedisTemplate<Object, Object>, JdkSerializationRedisSerializer): redis-cli ZSCORE Ravi empty, EXISTS 0 · solved (StringRedisTemplate): ZSCORE Ravi 7200, EXISTS 1 · 120 orders, exit 0 both (a standalone harness JVM, Redis by the digest, no TiffinBox, no database) · anchor: 14/after, profile dev, PostgreSQL + Redis: /leaderboard 200 Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 = redis-cli's ZREVRANGE, the sum 24300 = kitchen value 24300 = /kitchen's ordersValue, orders cooked 120, three starts in a row the same board (the reset holds), the third SIGINT -> exit 130 · health 200 · /dashboard 200 · cacheManager RedisCacheManager · the Leaderboard bean · strict mode, Found 1 JPA, 1 JDBC, 0 Redis · tests 18 (mvn -o package, no Docker) and 18 + 6 (mvn -o verify) · libs 122 -> 122 (none gained) · Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/JDBC/Redis 4.1.2 · Lettuce 7.5.2.RELEASE · HHH000001 7.4.13.Final · Flyway 12.4.0 · redis_version:8.10.3 · zset: 14/after, profile dev, PostgreSQL + Redis, Java and redis-cli: ZREVRANGE … WITHSCORES Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · ZSCORE Ravi 7200 · ZREVRANK Sunil 0 · ZCARD 4 · TYPE zset · OBJECT ENCODING listpack · the sum 24300 = /kitchen's ordersValue = the start's kitchen value · orders cooked 120 · flip: the harness's keys (labelled), 14/after, profile dev: CONFIG GET zset-max-listpack-entries 128 · h14:z128 listpack · h14:z129 skiplist (Java and redis-cli) · structs: the harness's keys (labelled), 14/after, profile dev: h14:customer:Ravi hash listpack {mealType=VEG, pricePerMeal=120, mealsPerDay=2} · h14:meal-types set listpack [NON_VEG, VEG, VEGAN] · h14:orders-placed INCR 1 string int (Java and redis-cli) · twice: the harness over the shipped Leaderboard.record (labelled), 14/after, profile dev: two fills, no reset -> Sunil 18000 · Ravi 14400 · Meera 9000 · Priya 7200 (Java and redis-cli; each twice the start's Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600) · the start's own shape resets first: anchor's three starts · trap: the harness's fill through Boot's redisTemplate (labelled), 14/after, profile dev: JdkSerializationRedisSerializer (key and value, read off the bean) · redis-cli --no-raw --scan "\xac\xed\x00\x05t\x00\x15tiffinbox:leaderboard" · the member \xac\xed\x00\x05t\x00\x04Ravi · ZSCORE tiffinbox:leaderboard Ravi empty · EXISTS 0 · StringRedisTemplate score(Ravi) null · the object template reads its own key back 7200.0 · no exception (ERROR 0, exception lines 0) · absent: 14/after, profile dev, PostgreSQL up, Redis absent: the start stops - Error creating bean with name 'tiffinBoxServer' <- RedisConnectionFailureException: Unable to connect to Redis, Application run failed, exit 1, curl 000, nothing on 20530 (control: anchor) · default: 14/after, default run, H2, no Redis, no Docker: health 200 · /leaderboard 404 · /dashboard 200 · Leaderboard beans 0 · CaffeineCacheManager · the 18 under mvn -o package, Docker at nothing · notes: ⚑11: c8-unit09/exercise/README.md, SOLUTION.md, c8-unit11/README.md and c8-unit12/pinned.txt unchanged (md5 = 3478b30's) · KitchenHealthIndicator.java 605d58fb… -> 031db406… · #119 (14/after, profile dev, PostgreSQL + Redis): the customer table renamed under a running TiffinBox, the list in Redis's cache -> health 200 UP, readiness UP, /customers 200, /dashboard 500; the cache emptied too -> health 503 DOWN, /customers 500; a cold start with it renamed -> Schema validation: missing table [customer], exit 1 · seven: the seven 466c20ed… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · /leaderboard 404 on the default run · Hibernate's script = xcheck.sql
<!-- values: end -->

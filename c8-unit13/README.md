# c8-unit13 — Conditional Caching, sync and Nulls

Course 8, Section 2's sixth unit and **Section 2's fifth and last change to the anchor (C5)**. `before` is a link to `../c8-unit12/after`
(unit 12's tree; the receipt pins it and asserts that pin is unit 12's own after-tree line); `after/` is this unit's tree, and
`../c8-tiffinbox` equals `after/` from this unit's commit on. **Section 3 starts on `after/`.** Three attributes of `@Cacheable`, read
off the code: `condition` decides whether the cache is looked at, `unless` whether the answer is kept, and `sync` makes the callers
that ask for a cold key together wait for one read. And an empty `Optional` is a value the cache keeps: a customer added after a
failed lookup stays invisible until the entry goes — the roadmap's "caching `Optional.empty()` and why it matters", paid here.

Every count below comes from two witnesses in the same run (R.375): **the invocation counter** — unit 08's harness `BeanPostProcessor`,
copied, which adds a counting `MethodInterceptor` at position 0 of Spring Data JPA's repository proxy for `CustomerEntityRepository`,
outside the cached bean, so it counts exactly the calls a hit saves, in the JVM or in Redis — and **Hibernate's statement counter**,
`getPrepareStatementCount()`, Course 7's pinned counter (C8-9, below). A window whose two per-call lists differ fails the run. `psql`
inserts and reads PostgreSQL's rows and `redis-cli` reads Redis's keys, each while a harness JVM waits at a pause — the second clients
(R.359). Redis is **Redis 8.10.3, by the digest** (`redis@sha256:7958cfbb…935c3`, `--pull never`, `127.0.0.1` only, no password);
PostgreSQL is 18.6 by the capstone's digest; the default run, `syncunless` and the exercise are H2 in memory.

Nine captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `exercise` and the
tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string below is asserted
right after its capture by `harness/chk13.py` against a second witness of the same run.

## Runs of record

**On the script as committed:** `bash receipts.sh` (Homebrew bash 5.3.9, 2026-11-18 from 18:42:21 CET, ended 18:50:39), a sealed
fresh clone (below, from 18:50:39, ended 18:59:08) and `./receipts.sh` (/bin/bash 3.2.57, from 18:59:08, ended 19:07:39): each with every capture
= published (the JVM ones 3/3 inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file count unchanged,
volumes back to their count and the images unchanged, `before/` and `after/` = their pins at the start and the end, nothing listening on
20520-20529 at the end, each log ending `exit 0`; each log through `check_unit8.py 13 --runlog` — `RESULT (run logs): PASS` (the unit
gate itself has no unit 13 script yet, as expected). **Nothing was downloaded.** Two earlier full runs of this script, before the
`anchor` capture gained its RED #3 hazard JVM, set the other captures' hashes; then a first set of the three runs (18:02-18:28) passed
as these did, on a `chk13.py` whose static check stopped with a Python error, rather than a FAIL line, on one planted fault (sync and
unless on one method); that check was fixed (no capture moved) and the three runs above are the ones of record.

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `e763b59` into a path **with a space** (`…/sealed
13/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c8-unit13 c8-tiffinbox`; `diff -rq` against the working folder printed nothing), the clone's `.m2-demo` a file copy
of the seed, `env -i` with `HOME`, `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`
and dead proxies for http and https (`127.0.0.1:9`); `./receipts.sh`. The runs ran on this README before its *Runs of record*,
*Interrupted* and *Planted faults* paragraphs were written; the prose gate and the text-block and values checks were run again on the
final README against the last run's printed lines.

## C5 — the change, file by file, and every README/YAML/javadoc sentence it rewrote (R.250)

Two files changed besides the anchor README; nothing new, nothing deleted, no `pom.xml`, no `compose.yaml`, no `RedisCaching.java`
(the receipt asserts `RedisCaching.java`, `TiffinBoxApp.java`, `KitchenHealthIndicator.java`, `Dashboard.java`, `TiffinBoxServer.java`,
`application-dev.yaml`, `compose.yaml` and the three `pom.xml` files byte-equal to `before/`'s, and `chk13.py static` that the three
changed files are the only ones); Flyway's V1-V3 untouched, Hibernate's schema script still `xcheck.sql` = `../c7-unit39/xcheck.sql`; no
jar gained or lost (`anchor`).

- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java` — `findAll`'s `@Cacheable("customers")` becomes
  **`@Cacheable(cacheNames = "customers", sync = true)`**: the same cache, the same key, `sync` only. `findByName`, uncached until
  now, gains **`@Cacheable(cacheNames = "customer", unless = "#result == null")`**: the key is the name — Spring's default key for
  a method of one argument, and Redis's `--scan` prints it as `customer::Ravi` (`anchor`). Each method's Javadoc carries a "Course 8,
  unit 13:" paragraph in the class's voice. `add` is unchanged (RED #8): with `unless` a missing name is never stored, and an `add` of
  a stored name is refused by the table's unique name — there is nothing for an evict by name to clear. Unit 12's time to live now
  bounds the `customer` entries too (the policy present: `redis-cli TTL` on `customer::Ravi` reads a positive count, at most the
  configured one, masked; no expiry waited for). The Java diff outside the Javadoc is the two annotation lines (`chk13.py static`).
- `tiffinbox-web/src/main/resources/application.yaml` — `spring.cache.cache-names: customers,customer` (RED #3: with names given
  Caffeine's manager is static, and a name the start did not make throws at its first call — `anchor` shows it the other way round);
  `expireAfterWrite=10m` and `time-to-live: 10m` untouched (`chk13.py static`: the names line and comment lines are the whole diff).

The sentences C5 made false or dated, each with its note in place (R.250; `chk13.py r250` asserts each note on its line, and that no
anchor README line says `findByName` stays uncached without one):

- `CustomerRepository.java`'s class Javadoc, "findByName and pausedDaysByCustomer stay uncached (../c8-unit08, hits and evict)" —
  "(Course 8, unit 13: findByName is cached since, in "customer", unless it finds no one; pausedDaysByCustomer still is not -
  ../c8-unit13, unless.)" — `pausedDaysByCustomer` still stays uncached, said;
- `application.yaml`'s unit 10 comment, "here the one TiffinBox has, customers (CustomerRepository.findAll()'s)" — "(Course 8, unit 13:
  two since - customer too, findByName's, under each name it finds)";
- the anchor README's header, after unit 12's note — a unit 13 note, Section 2's fifth and last change, Section 3 starts here;
- the anchor README's unit 08 section, "`findByName` and `pausedDaysByCustomer` stay uncached" — its unit 13 note;
- the anchor README's unit 10, unit 11 and unit 12 sections, "`findByName` stays uncached" (three lines) — each its unit 13 note;
- the anchor README's unit 12 section, "unit 13's `sync` takes that on" — *(Course 8, unit 13: it has — one read in every round, in one
  JVM; its section below)*;
- `../c8-unit12/README.md`'s *Next* ("Unit 13 moves the anchor next (`sync = true` on the cold key, `unless` on `findByName`, which stays
  uncached until then)") and the same forward line in units 10 and 11 (`findByName` uncached until unit 13) are now done, not false:
  those READMEs are left as shipped, and this note is theirs.

The anchor README gains its `## Course 8 · unit 13` section in the unit 12 section's shape, with "**Section 3 starts here**".

## The captures — what each one shows

### 1 · anchor — two caches at the start, the RED #3 hazard the other way round, both keys on Redis (R.386, R.384)

`before/` (unit 12's tree) on H2 in memory with no Redis, `after/` the same, then `after/` dev-shaped on PostgreSQL + Redis. The cache
names are read off the manager, `getCacheNames()`; `getCache("customer")` is null on `before/` — there, a `@Cacheable("customer")` would
throw at its first call (RED #3) — and a cache on `after/`. Then the hazard itself, the other way round: `after/` with the harness's
`--spring.cache.cache-names=customers` (a name the start did not make), and the first `findByName`. The five `findAll` reads are unit
12's numbers, unchanged; `/actuator/prometheus` holds Caffeine's meter lines for both names (`cache-names` sets them at the start):

```text
-- before/ (unit 12's tree) on H2 in memory, NO Redis (TiffinBox's default run), one JVM, its web server on 20520:
log: HHH000001: Hibernate ORM core version 7.4.13.Final
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data Redis 4.1.2 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.caffeine.CaffeineCacheManager] (H2 2.5.250)
PROBE the cache names at the start, getCacheNames(): [customers]
PROBE getCache("customer"): null
-- after/ on H2 in memory, NO Redis (TiffinBox's default run: no Redis setting given, no Redis container asked), one JVM, its web server on 20520:
log: HHH000001: Hibernate ORM core version 7.4.13.Final
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data Redis 4.1.2 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.caffeine.CaffeineCacheManager] (H2 2.5.250)
PROBE the cache names at the start, getCacheNames(): [customer, customers]
PROBE getCache("customer"): org.springframework.cache.caffeine.CaffeineCache
PROBE reads: five calls of CustomerRepository.findAll() (H2 2.5.250, in the JVM, Caffeine): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE reads: five calls of CustomerRepository.findAll(): the two witnesses' per-call lists equal
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /dashboard -> 200
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health -> 200 · status UP
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health/readiness -> 200 · status UP
PROBE prometheus (H2 2.5.250, in the JVM, Caffeine): GET /actuator/prometheus -> 200 · cache_gets_total lines per cache {customer=2, customers=2} · every cache_ line per cache {customer=6, customers=6}
-- the RED #3 hazard, the other way round: after/ on H2 with --spring.cache.cache-names=customers on the harness's command line (a name the start did not make; the anchor's YAML untouched), the first findByName; one JVM:
log: HHH000001: Hibernate ORM core version 7.4.13.Final
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data Redis 4.1.2 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.caffeine.CaffeineCacheManager] (H2 2.5.250)
PROBE the cache names at the start, getCacheNames(): [customers]
PROBE getCache("customer"): null
PROBE first: java.lang.IllegalArgumentException: Cannot find cache named 'customer' for Builder[public java.util.Optional com.tiffinbox.CustomerRepository.findByName(java.lang.String) throws java.sql.SQLException] caches=[customer] | key='' | keyGenerator='' | cacheManager='' | cacheResol…
PROBE first: findByName("Ravi"), the first cached call (H2 2.5.250, in the JVM, Caffeine): repository calls 0 · prepareStatementCount 0 · per call [0] and [0]
PROBE first: findByName("Ravi"), the first cached call: the two witnesses' per-call lists equal
-- after/ dev-shaped, on PostgreSQL 18.6 + Redis 8.10.3 (both containers, by the digest; the Redis settings from the harness's command line), one JVM, its web server on 20520:
the Redis container's own client: redis-cli 8.10.3 · INFO server: redis_version:8.10.3
log: HHH000001: Hibernate ORM core version 7.4.13.Final
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data Redis 4.1.2 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
PROBE CacheManager beans 1 [cacheManager=org.springframework.data.redis.cache.RedisCacheManager] (PostgreSQL 18.6)
PROBE the cache names at the start, getCacheNames(): [customer, customers]
PROBE getCache("customer"): org.springframework.data.redis.cache.RedisCache
PROBE Redis's INFO server, through the connection: redis_version:8.10.3
PROBE the cache writer: org.springframework.data.redis.cache.DefaultRedisCacheWriter · asynchronousWrites false · a lock wait set yes (not zero)
PROBE reads: five calls of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE reads: five calls of CustomerRepository.findAll(): the two witnesses' per-call lists equal
PROBE byname: findByName("Ravi") (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1] and [1] · returned Optional[Customer[name=Ravi, mealsPerDay=2, pricePerMeal=120, mealType=VEG]]
PROBE http (PostgreSQL 18.6, Redis): GET /dashboard -> 200
PROBE http (PostgreSQL 18.6, Redis): GET /actuator/health -> 200 · status UP
PROBE http (PostgreSQL 18.6, Redis): GET /actuator/health/readiness -> 200 · status UP
redis-cli --scan: customer::Ravi|customers::SimpleKey [] (2 keys)
redis-cli TYPE: customer::Ravi string · customers::SimpleKey [] string
redis-cli TTL "customers::SimpleKey []": TTL <n> · a positive count, at most the configured value (the anchor's spring.cache.redis.time-to-live, read off after/'s YAML): yes
redis-cli TTL "customer::Ravi": TTL <n> · a positive count, at most the configured value (the anchor's spring.cache.redis.time-to-live, read off after/'s YAML): yes
```

The same capture carries the tests, run once per run of record: `mvn -o package` with Maven's `DOCKER_HOST` at nothing, then `mvn -o
verify` with Docker — the container tests run on Caffeine, no Redis — and the libraries, counted by name:

```text
tiffinbox-web/target/surefire-reports-it: absent - no container test ran
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
before/: 122 libraries · Caffeine in lib/: caffeine-3.2.4.jar
after/: 122 libraries · Caffeine in lib/: caffeine-3.2.4.jar
gained: 0 · lost: 0
```

### 2 · sync — one read for every waiting thread, in one JVM, beside unit 12's tree (R.381, R.382, RE-MEASURE 15)

The anchor's own cached `findAll`, its cache emptied before each round; N platform threads started, each counting down a ready latch
and then waiting on one go latch, released together; each thread keeps the size of the list it received; the round's window closes when
every thread returns (R.367, one window per round). No hold anywhere — `harness/src/probe/u13/Stampede.java` names no `sleep`
(asserted). 20 rounds per count, one JVM per row per capture run — three JVMs per row inside each run of record, the capture 3/3
equal. `after/` (`sync = true`) on PostgreSQL + Caffeine and on PostgreSQL + Redis through the cache writer TiffinBox gives Redis, counts
2, 4, 8, 16 and 32; then `before/` (unit 12's tree, no `sync`) in the same JVM form, the contrast at 2 and 4 threads. H2 never runs it.

```text
-- the stampede's class, harness/src/probe/u13/Stampede.java: lines naming sleep 0 · the read each thread makes: the anchor's own CustomerRepository.findAll() (the context's bean)
-- after/ (findAll's @Cacheable with sync = true), PostgreSQL + Caffeine (in the JVM), one JVM:
PROBE sync 2 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 2 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
PROBE sync 4 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 4 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
PROBE sync 8 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 8 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
PROBE sync 16 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 16 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
PROBE sync 32 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 32 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
-- after/ (findAll's @Cacheable with sync = true), PostgreSQL + Redis, the cache writer TiffinBox gives Redis, one JVM:
PROBE sync 2 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 2 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
PROBE sync 4 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 4 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
PROBE sync 8 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 8 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
PROBE sync 16 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 16 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
PROBE sync 32 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 1 in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE sync 32 threads: per round [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
-- before/ (unit 12's tree: findAll's @Cacheable without sync), PostgreSQL + Caffeine (in the JVM), the contrast at 2 and 4 threads, one JVM:
PROBE plain 2 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 2 in every round: yes · more than one in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE plain 2 threads: per round [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
PROBE plain 4 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 4 in every round: yes · more than one in every round: yes · every thread received the list, its size() per round as a set: {4} in every round · calls that threw 0
PROBE plain 4 threads: per round [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
```

Every round of every JVM printed one repository call and one statement on `after/`, at every count, on Caffeine and on Redis, and every
thread received the list, its four rows; `before/`'s rounds printed one per thread at 2 and at 4 — side by side from one run. The
claim is "one read, every thread its rows, in one JVM" (R.382): each row is one JVM, and the waiting is done inside it — Caffeine's
cache, or the `RedisCache` in that JVM; a second server runs its own read. A cross-process claim needs a two-JVM capture, and none was
made. Boot's own Redis writer is not re-run (unit 11's `writer`, *Redis as a Cache*, for what it does).

### 3 · nulls — the empty answer the cache keeps, and the customer it hides (R.383, S8.29, the hook)

The hook. `nounless/`, a labelled copy of 13/after made by `harness/variants.py nounless` — the one source change printed — because
the anchor's own `unless` stores nothing for an empty answer. Three lookups of a name nobody has; the stored form (Caffeine's native
entry; on Redis the key's bytes by `redis-cli --no-raw GET`, while the JVM waits at its pause); TiffinBoxServer's route,
`GET /customers/{name}`; psql inserts Nobody — a second client, a write that never passes through the cache; the lookup and the route
again; `evict("Nobody")`; the lookup again:

```text
--- after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
+++ nounless/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
-    @Cacheable(cacheNames = "customer", unless = "#result == null")
+    @Cacheable(cacheNames = "customer")
-- nounless/, PostgreSQL + Caffeine (in the JVM): findByName("Nobody") x3, the stored form, psql inserts her, the lookup, evict, the lookup; one JVM:
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.caffeine.CaffeineCacheManager] (PostgreSQL 18.6)
PROBE nulls: the first three lookups returned [Optional.empty, Optional.empty, Optional.empty] · per call [1, 0, 0]
PROBE nulls: the stored form, in the cache customer: getNativeCache().getIfPresent("Nobody") org.springframework.cache.support.NullValue
PROBE nulls: TiffinBoxServer's route, before the insert: GET /customers/Nobody -> 404 · repository calls 0 · prepareStatementCount 0
PROBE nulls: after psql's insert, the lookup returned Optional.empty · repository calls 0 · prepareStatementCount 0
PROBE nulls: TiffinBoxServer's route, after the insert: GET /customers/Nobody -> 404 · repository calls 0 · prepareStatementCount 0
PROBE nulls: after evict("Nobody"), the lookup returned Optional[Customer[name=Nobody, mealsPerDay=1, pricePerMeal=100, mealType=VEG]] · repository calls 1 · prepareStatementCount 1
PROBE nulls: findByName("Nobody") x3, psql inserts her, the lookup, evict("Nobody"), the lookup (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 2 · prepareStatementCount 2 · per call [1, 0, 0, 0, 1] and [1, 0, 0, 0, 1] · invocations 1 -> 1 (the insert) -> 2 (the evict)
PROBE nulls: findByName("Nobody") x3, psql inserts her, the lookup, evict("Nobody"), the lookup: the two witnesses' per-call lists equal
the receipt at pause 1, psql (a second client, PostgreSQL): insert Nobody -> rows named Nobody 1
-- nounless/, PostgreSQL + Redis (the cache writer TiffinBox gives Redis), the same steps; redis-cli reads the key before psql inserts her; one JVM:
PROBE CacheManager beans 1 [cacheManager=org.springframework.data.redis.cache.RedisCacheManager] (PostgreSQL 18.6)
PROBE nulls: the first three lookups returned [Optional.empty, Optional.empty, Optional.empty] · per call [1, 0, 0]
PROBE nulls: the stored form, in the cache customer: the receipt reads the key with redis-cli
PROBE nulls: TiffinBoxServer's route, before the insert: GET /customers/Nobody -> 404 · repository calls 0 · prepareStatementCount 0
PROBE nulls: after psql's insert, the lookup returned Optional.empty · repository calls 0 · prepareStatementCount 0
PROBE nulls: TiffinBoxServer's route, after the insert: GET /customers/Nobody -> 404 · repository calls 0 · prepareStatementCount 0
PROBE nulls: after evict("Nobody"), the lookup returned Optional[Customer[name=Nobody, mealsPerDay=1, pricePerMeal=100, mealType=VEG]] · repository calls 1 · prepareStatementCount 1
PROBE nulls: findByName("Nobody") x3, psql inserts her, the lookup, evict("Nobody"), the lookup (PostgreSQL 18.6, Redis): repository calls 2 · prepareStatementCount 2 · per call [1, 0, 0, 0, 1] and [1, 0, 0, 0, 1] · invocations 1 -> 1 (the insert) -> 2 (the evict)
PROBE nulls: findByName("Nobody") x3, psql inserts her, the lookup, evict("Nobody"), the lookup: the two witnesses' per-call lists equal
the receipt at pause 1, redis-cli: --scan customer::Nobody (1 keys) · TYPE "customer::Nobody" string · GET "customer::Nobody" "\xac\xed\x00\x05sr\x00+org.springframework.cache.support.NullValue\x00\x00\x00\x00\x00\x00\x00\x01\x02\x00\x00xp"
the receipt at pause 1, psql (a second client, PostgreSQL): insert Nobody -> rows named Nobody 1
```

Silent, by S8.29's four prints: the lookup after the insert returns `Optional.empty`, reaches nothing — repository calls 0, statements
0 — with no exception, no ERROR line and exit 0, while psql's row is there. The cache unwraps the `Optional`: what it keeps for an empty
answer is Spring's `NullValue` holder — in Caffeine the object, in Redis its bytes. `GET /customers/Nobody` answers 404 before the insert
and still 404 after it, from the same entry (run, not read off the source). The eviction reveals her: the next lookup reaches the
table and finds her.

### 4 · unless — the anchor's own annotation: the empty answer not kept (RE-MEASURE 11)

The anchor's own `@Cacheable(cacheNames = "customer", unless = "#result == null")`. Nobody ×3, then Ravi ×3, what the cache holds
after each; then on a cold cache a lookup of Nobody, psql inserts her (the JVM waits at its pause), and a lookup again — on Caffeine,
then on Redis:

```text
-- after/ (the anchor's unless = "#result == null"), PostgreSQL + Caffeine (in the JVM): Nobody x3, Ravi x3, then on a cold cache a lookup, psql inserts her, a lookup; one JVM:
PROBE unless: findByName("Nobody") x3 (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 3 · prepareStatementCount 3 · per call [1, 1, 1] and [1, 1, 1] · returned [Optional.empty]
PROBE unless: findByName("Nobody") x3: the two witnesses' per-call lists equal
PROBE unless: after Nobody x3, in the cache customer: getNativeCache().getIfPresent("Nobody") null
PROBE unless: findByName("Ravi") x3 (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0] and [1, 0, 0] · returned [Optional[Customer[name=Ravi, mealsPerDay=2, pricePerMeal=120, mealType=VEG]]]
PROBE unless: findByName("Ravi") x3: the two witnesses' per-call lists equal
PROBE unless: after Ravi x3, in the cache customer: getNativeCache().getIfPresent("Ravi") com.tiffinbox.Customer
PROBE unless: the lookup before the insert returned Optional.empty
PROBE unless: the lookup after psql's insert returned Optional[Customer[name=Nobody, mealsPerDay=1, pricePerMeal=100, mealType=VEG]]
PROBE unless: on a cold cache, findByName("Nobody"), psql inserts her, findByName("Nobody") (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · invocations 1 -> 2
PROBE unless: on a cold cache, findByName("Nobody"), psql inserts her, findByName("Nobody"): the two witnesses' per-call lists equal
the receipt at pause 1: the store is in the JVM (Caffeine) - nothing for redis-cli to read
the receipt at pause 2, psql (a second client, PostgreSQL): insert Nobody -> rows named Nobody 1
-- after/, PostgreSQL + Redis (the cache writer TiffinBox gives Redis), the same steps; one JVM:
PROBE unless: findByName("Nobody") x3 (PostgreSQL 18.6, Redis): repository calls 3 · prepareStatementCount 3 · per call [1, 1, 1] and [1, 1, 1] · returned [Optional.empty]
PROBE unless: findByName("Nobody") x3: the two witnesses' per-call lists equal
PROBE unless: after Nobody x3, in the cache customer: the receipt reads the key with redis-cli
PROBE unless: findByName("Ravi") x3 (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0] and [1, 0, 0] · returned [Optional[Customer[name=Ravi, mealsPerDay=2, pricePerMeal=120, mealType=VEG]]]
PROBE unless: findByName("Ravi") x3: the two witnesses' per-call lists equal
PROBE unless: after Ravi x3, in the cache customer: the receipt reads the key with redis-cli
PROBE unless: the lookup before the insert returned Optional.empty
PROBE unless: the lookup after psql's insert returned Optional[Customer[name=Nobody, mealsPerDay=1, pricePerMeal=100, mealType=VEG]]
PROBE unless: on a cold cache, findByName("Nobody"), psql inserts her, findByName("Nobody") (PostgreSQL 18.6, Redis): repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · invocations 1 -> 2
PROBE unless: on a cold cache, findByName("Nobody"), psql inserts her, findByName("Nobody"): the two witnesses' per-call lists equal
the receipt at pause 1, redis-cli: --scan customer::Ravi (1 keys)
the receipt at pause 2, psql (a second client, PostgreSQL): insert Nobody -> rows named Nobody 1
redis-cli --scan: customer::Nobody (1 keys)
```

`unless` is read after the call, on the value the cache would keep, and that value is the unwrapped one: an empty `Optional` reaches
the condition as null — every Nobody lookup ran the method and nothing was stored (`getIfPresent` null; no `customer::Nobody` key on
Redis), while Ravi's `Optional` reached it as a customer and was kept. Said from the measurement, not from the documentation. The
insert-then-find (RE-MEASURE 11): the customer added after a failed lookup is found by the next one, on both stores — and only then is
`customer::Nobody` kept.

### 5 · cond — `condition`, on the harness's own cache (labelled, R.384, R.392)

The anchor has no `condition`. The harness's bean `HarnessCond.Lookups` reads through Spring Data JPA's repository directly (so the
counter sees every call its cache does not answer) under `@Cacheable(cacheNames = "h13cond", condition = "#name.length() > 3")`, on its
own cache, named at the start beside the anchor's two (`--spring.cache.cache-names=customers,customer,h13cond` on the harness's command
line). Sam is not in the seed (Ravi, Meera, Sunil, Priya); the step adds him through `add` first:

```text
-- after/ + the harness's HarnessCond (its own cache h13cond, named beside the anchor's two at the start), PostgreSQL + Caffeine, one JVM:
PROBE cond: a harness bean, not the anchor's cache - HarnessCond.Lookups, its cache h13cond (condition = "#name.length() > 3"); the cache names at the start [customer, customers, h13cond]
PROBE cond: Sam in the seed: false - added through add(Sam) first
PROBE cond: HarnessCond byName("Sam") x3, then byName("Ravi") x3 (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 4 · prepareStatementCount 4 · per call [1, 1, 1, 1, 0, 0] and [1, 1, 1, 1, 0, 0] · returned [Optional[Sam 1 meals], Optional[Sam 1 meals], Optional[Sam 1 meals], Optional[Ravi 2 meals], Optional[Ravi 2 meals], Optional[Ravi 2 meals]]
PROBE cond: HarnessCond byName("Sam") x3, then byName("Ravi") x3: the two witnesses' per-call lists equal
-- the same, PostgreSQL + Redis (the anchor's writer), one JVM:
PROBE cond: a harness bean, not the anchor's cache - HarnessCond.Lookups, its cache h13cond (condition = "#name.length() > 3"); the cache names at the start [customer, customers, h13cond]
PROBE cond: Sam in the seed: false - added through add(Sam) first
PROBE cond: HarnessCond byName("Sam") x3, then byName("Ravi") x3 (PostgreSQL 18.6, Redis): repository calls 4 · prepareStatementCount 4 · per call [1, 1, 1, 1, 0, 0] and [1, 1, 1, 1, 0, 0] · returned [Optional[Sam 1 meals], Optional[Sam 1 meals], Optional[Sam 1 meals], Optional[Ravi 2 meals], Optional[Ravi 2 meals], Optional[Ravi 2 meals]]
PROBE cond: HarnessCond byName("Sam") x3, then byName("Ravi") x3: the two witnesses' per-call lists equal
redis-cli --scan: h13cond::Ravi (1 keys)
```

`condition` is read before the call: a name of three letters is neither looked up nor kept, so every Sam call runs the method, and
Ravi's second and third calls are hits. These numbers are the harness's cache's, never the anchor's (R.392).

### 6 · nonull — `cache-null-values=false` on Redis: it throws (R.383)

`nounless/` with `--spring.cache.redis.cache-null-values=false` on the harness's command line (`RedisCaching` builds its configuration
from Boot's `CacheProperties`, so the key reaches the cache), PostgreSQL + Redis:

```text
-- nounless/ + --spring.cache.redis.cache-null-values=false, PostgreSQL + Redis (the anchor's writer): findByName("Nobody") x3; one JVM:
PROBE started: yes · the database that answered: PostgreSQL 18.6 · the cache's store: Redis · a web server: yes
PROBE the environment: spring.cache.type redis · spring.cache.cache-names customers,customer · spring.cache.redis.cache-null-values false
PROBE nonull: call 1: java.lang.IllegalArgumentException: Cache 'customer' does not allow 'null' values; Avoid storing null via '@Cacheable(unless="#result == null")' or configure RedisCache to allow 'null' via RedisCacheConfiguration
PROBE nonull: call 2: java.lang.IllegalArgumentException: Cache 'customer' does not allow 'null' values; Avoid storing null via '@Cacheable(unless="#result == null")' or configure RedisCache to allow 'null' via RedisCacheConfiguration
PROBE nonull: call 3: java.lang.IllegalArgumentException: Cache 'customer' does not allow 'null' values; Avoid storing null via '@Cacheable(unless="#result == null")' or configure RedisCache to allow 'null' via RedisCacheConfiguration
PROBE nonull: findByName("Nobody") x3, spring.cache.redis.cache-null-values=false (PostgreSQL 18.6, Redis): repository calls 3 · prepareStatementCount 3 · per call [1, 1, 1] and [1, 1, 1] · outcomes [threw IllegalArgumentException, threw IllegalArgumentException, threw IllegalArgumentException]
PROBE nonull: findByName("Nobody") x3, spring.cache.redis.cache-null-values=false: the two witnesses' per-call lists equal
redis-cli --scan:  (0 keys)
```

Not a quieter cache: the context started, and every lookup that finds no one runs the method and then throws at the store —
`IllegalArgumentException` three times in three calls, nothing stored. Caffeine's `allowNullValues` is not a YAML key; it is not
measured here.

### 7 · syncunless — `sync = true` beside `unless`: the start green, the first call throws (the failure receipt)

`syncunless/`, a labelled copy made by `harness/variants.py syncunless`: `sync = true` beside `unless` on `findByName`, the one change
printed. H2 in memory is enough — the refusal is the cache interceptor's, before any store — so no Docker:

```text
--- after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
+++ syncunless/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
-    @Cacheable(cacheNames = "customer", unless = "#result == null")
+    @Cacheable(cacheNames = "customer", sync = true, unless = "#result == null")
PROBE started: yes · the database that answered: H2 2.5.250 · the cache's store: in the JVM, Caffeine · a web server: yes
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /dashboard -> 200
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health -> 200 · status UP
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health/readiness -> 200 · status UP
PROBE first: java.lang.IllegalStateException: A sync=true operation does not support the unless attribute on 'Builder[public java.util.Optional com.tiffinbox.CustomerRepository.findByName(java.lang.String) throws java.sql.SQLException] caches=[customer] | key='' | keyGenerator='' | cac…
PROBE first: findByName("Ravi"), the first cached call (H2 2.5.250, in the JVM, Caffeine): repository calls 0 · prepareStatementCount 0 · per call [0] and [0]
PROBE first: findByName("Ravi"), the first cached call: the two witnesses' per-call lists equal
```

The start is green and, on H2 with no Redis, the health answers 200; the first cached call throws `IllegalStateException` before the method runs. The anchor
keeps the two attributes on two methods.

### 8 · seven — the comparison set on before/ and after/ (R.363)

`before/`'s jar on 20523 — a second port, so the two jars never share one — and `after/`'s on 20520, H2 in memory, the comparison set
of Course 5's *Secrets: What Not to Commit* (`../c5-unit11/curlset.sh`):

```text
exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · listens on: 127.0.0.1:20523
GET /dashboard: 200
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20523 now: 0
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · listens on: 127.0.0.1:20520
GET /dashboard: 200
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20520 now: 0
the seven, after/ against before/: lines that differ: 0
```

### 9 · exercise — run as written, in one shell, bash then zsh (R.196, RE-MEASURE 11)

`exercise/README.md` and `exercise/SOLUTION.md`: H2 + Caffeine, no Docker — the kept empty answer needs no store outside the JVM.
The broken tree is a labelled copy: `after/` with this folder's `exercise/CustomerRepository.java` — `findByName`'s annotation without
`unless`. The program looks up Nobody, inserts her with `JdbcTemplate`, and looks her up again; the solution puts `unless = "#result ==
null"` back. The check is the second lookup's value and the counter, never the exit.

```text
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
unless on findByName: 0
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
cache: CaffeineCacheManager
lookup 1: Nobody not found · repository calls 1
insert: 1 row · the table now holds Nobody: 1
lookup 2: Nobody not found · repository calls 1
then the solution's lines, in the same shell - the block's exit 0:
unless on findByName: 1
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
cache: CaffeineCacheManager
lookup 1: Nobody not found · repository calls 1
insert: 1 row · the table now holds Nobody: 1
lookup 2: Nobody found · repository calls 2
the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20520 afterwards: 0
```

zsh (`/bin/zsh -f`) printed the same lines, in the same order (`chk13.py exercise`).

## Which store, which manager, which writer

Every caching line names its store: **in the JVM, Caffeine** — the default run's `CaffeineCacheManager`, its two caches made at the
start; and **Redis, by the digest** — `RedisCacheManager`, its caches `RedisCache`, `LettuceConnectionFactory` on `127.0.0.1:20522`, and
**the cache writer TiffinBox gives Redis** (`immediateWrites` + `enableLocking`; printed `asynchronousWrites false` with a lock wait
set) in every Redis section. The writer Boot builds over Lettuce is not run in this unit: unit 11's `writer` capture measured what it
does (*Redis as a Cache*), and its stampede rounds were not cold in unit 12's trial — not said. PostgreSQL answers every miss in
`sync`, `nulls`, `unless`, `cond`, `nonull` and the dev-shaped run; H2 in memory answers the default run's, `syncunless`'s, the seven's
and the exercise's.

## Refused, named

- A claim that `sync` holds for two servers or two processes (R.382): every `sync` round ran in one JVM; a cross-process claim
  needs a two-JVM capture, and none was made.
- `cache-null-values=false` called "not cached" or a quieter cache (R.383): it throws `IllegalArgumentException` at every call.
- `sync = true` and `unless` on one method in the anchor: the first call throws (`syncunless`); the anchor keeps them on two methods
  (`chk13.py static`).
- A hold or a `sleep` in the stampede (READ FIRST 14): there is no hold, asserted.
- "N threads, N reads" for a count that missed N in any round (R.381); any stampede number from H2 (R.381 — H2 never runs it).
- `add` said to evict `customer` (RED #8): it evicts nothing in `customer`.
- `Hibernate's cache` or `Spring Data caches` for Spring's cache abstraction (R.348's family); `faster`, `instantly`, `after a while`
  and R.388's family.
- A number from a cache the anchor does not ship voiced as the anchor's (R.392): the harness's `h13cond` is labelled the harness's;
  `customer` is the anchor's from 13/after on.
- A container removed without `-v` (R.387); a build that names `-pl` without `-am` (R.391); the docker CLI without its pinned socket
  (R.344).

## Call-backs, by title (R.224)

- Course 7's *N+1, Measured* (`java7_series.TITLES["30"]`): its pinned counter, from `../c7-unit30/pinned.txt`, its third line — **C8-9
  called back**:

```markdown
SessionFactory.getStatistics().getPrepareStatementCount()
```

- Course 8's *@Cacheable, @CacheEvict, @CachePut* (`java8_series.TITLES["08"]`): the annotations this unit's attributes sit on, `add`'s
  `@CacheEvict(allEntries = true)`, and the counter, copied (`harness/src/probe/u13/Counter.java`, unit 12's but for its package line —
  `chk13.py static`).
- Course 8's *Caffeine* (`java8_series.TITLES["10"]`): `cache-names`, the static manager, the meter lines; its five-read numbers,
  unchanged.
- Course 8's *Redis as a Cache* (`java8_series.TITLES["11"]`): the writer and the JSON serializer the Redis rows go through; its
  `writer` capture, for what the writer Boot builds over Lettuce does.
- Course 8's *Cache Invalidation* (`java8_series.TITLES["12"]`): `before/`; its stampede, which this unit's `sync` answers, and its time
  to live, which bounds `customer` too.
- This unit: *Conditional Caching, sync and Nulls* (`java8_series.TITLES["13"]`, `13-conditional-caching-sync-and-nulls`).

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged.

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s2`; every build reads it offline (`-o`,
`maven.repo.local` as an absolute path), every one `-pl tiffinbox-web -am`, and the receipt asserts its file count unchanged after every
Maven run. Docker: the pinned socket on every call, both images by their digests, `--pull never`; the image list and the volume count are
asserted unchanged at the end. No Compose run in this unit; `compose.yaml` is untouched. Nothing in this unit touched the network; the
harness's HTTP requests go to TiffinBox's own web server on 127.0.0.1.

## The folders, the harness and the ports

- `harness/src/probe/u13/U13.java` — the harness program (steps `info`, `http`, `prom`, `reads`, `byname`, `sync`, `plain`, `nulls`,
  `unless`, `cond`, `nonull`, `first`, `pause`), TiffinBox's application class with its web server; `Stampede.java` — the stampede's
  rounds, no hold, each thread keeping the size of the list it received; `HarnessCond.java` — the `cond` step's harness bean
  (`h13cond`); `Counter.java` — witness 1. `harness/src/probe/x/XMain.java` — `c7-unit29`'s schema probe, byte for byte. `U13.java`'s
  `pause` step polls a file with a `Thread.sleep` between looks — a poll, never the proof; the stampede's class holds none.
- `harness/variants.py` — the two labelled copies of `after/`, one line of `CustomerRepository.java` each: `nounless` (`findByName`'s
  annotation without `unless`; `nulls`, `nonull`) and `syncunless` (`sync = true` beside `unless`; `syncunless`), each diff printed in
  its capture, each copy built offline from its own sources.
- `harness/chk13.py` (the checks), `harness/s813.py` (the prose gate, its self-test first), `harness/tree13.py` (the pins),
  `harness/surefire.py` and `harness/dur8.py` (unit 02's, byte for byte), `harness/logback.xml` (unit 07's).
- `exercise/Lookup.java` — the exercise's program; `exercise/CustomerRepository.java` — the exercise's broken file, the anchor's but
  for `findByName`'s annotation (`chk13.py static`); `xcheck.sql` — Course 7's capstone's.
- Ports: 20520 TiffinBox (`after/` or a copy; the seven; the exercise) · 20521 the PostgreSQL container · 20522 the Redis container ·
  20523 TiffinBox `before/` for the seven · 20524-20529 never bound. All ten are asserted free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masked: this folder and the repository's paths, the home, the user name, Boot's `Started … in <t>`, Surefire's `Time elapsed`, Flyway's
`execution time`, Spring Data's `scanning in <t>`, `initialization completed in <t>`, any `PT<t>`, Maven's `Total time`, `using Java
<version>`, object hashes, `totalLoadTime=<masked>`, `expireAfterWrite=<n>`, `time-to-live=<n>` (with `=` or `:`) and `TTL <n>` for a
positive count (R.380, R.388; unit 12's mask and its self-test, unchanged). The harness prints no time-to-live value. dur8 finds no word
in the captures, in this README's text blocks or in the lines C5 added to `application.yaml` and `CustomerRepository.java`, asserted.
Filtered: the harness JVM's log down to the `Found` lines, `HHH000001`, Flyway's `Database` line (its port and database masked) and the
WARN lines. The PostgreSQL password and the shutdown token are generated per run, 0600, and asserted absent from every capture.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM, Maven, the exercise's shell), removes both containers
with their volumes (`rm -fv`), removes any Testcontainers container, deletes the partial captures, and exits 130. Measured 2026-11-18
between the first set of runs and the set of record, on this folder, the script started with SIGINT at its default (`perl -e '$SIG{INT}="DEFAULT"; exec …'` —
unit 11's form: this machine's shell refuses `set -m`'s process groups) and the signal sent to its pid at six points: mid-build (Maven
building the trees), mid-verify (Testcontainers' container tests running), mid-harness (the `anchor` capture's default-run JVM on the
in-memory database, both containers already up), mid-Redis (the `anchor` capture's dev-shaped JVM on PostgreSQL + Redis, the cache writer TiffinBox
gives Redis), mid-TiffinBox on PostgreSQL (the `sync` capture's Caffeine JVM on PostgreSQL) and mid-stampede (the same JVM, its rounds
past 4 threads) — each looked at twice, the second look a few beats later; `.harness/` cleared before each start. The captures on disk
were compared before and after: all nine unchanged. Nothing else ran beside the drill. It ran between the first set of runs and the
set of record, on the same script; only `chk13.py static`'s handling of one planted fault changed between them (no capture, no
receipt step).

```markdown
mid-build: exit 130 · first look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-build: second look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-build: captures on disk unchanged
mid-verify: exit 130 · first look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-verify: second look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-verify: captures on disk unchanged
mid-harness: exit 130 · first look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-harness: second look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-harness: captures on disk unchanged
mid-redis: exit 130 · first look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-redis: second look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-redis: captures on disk unchanged
mid-pg: exit 130 · first look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-pg: second look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-pg: captures on disk unchanged
mid-stampede: exit 130 · first look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-stampede: second look: java 0 · mvn 0 · c8u13 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20520-20529 0 · .r-lock absent · partial .r-*.[123] 0
mid-stampede: captures on disk unchanged
```

## The ledger rows this unit pays

- The roadmap's "caching `Optional.empty()` and why it matters" — the invisible row, on Caffeine and on Redis (`nulls`), and the
  attribute that stops it (`unless`, the exercise): **paid**.
- **C8-9** — called back (above).

## RE-MEASURE — the brief's items this unit settles

- **11** — with `unless`, the inserted customer is found by the next lookup (insert-then-find, `unless`, on Caffeine and on Redis; the
  exercise, bash and zsh).
- **12** — struck by RED #8 (no evict by name on `add`); nothing measured, nothing added.
- **13** — the seven on 13/after = `before/`'s (`seven`); no script sentence about the dashboard's statements is owed here.
- **15** — `sync` on the anchor's own `findAll`, no hold, on Caffeine and on Redis with the anchor's writer, captured 3/3 (`sync`);
  Boot's own writer not run (its stampede rounds were not cold in unit 12's trial).

## The anchor moved — the builders (R.211, R.331)

Before the commit: `/usr/bin/grep -n 'c8-tiffinbox\|tiffinbox-web/pom\|application.yaml\|application-dev\|compose.yaml\|CustomerRepository\|RedisCaching\|README'`
over `_builders/s80*.py`, `check_unit8.py`, `qa_java8.py` and `build_java8.py` (no `s81*.py` exists yet). `s801.py`'s and `s802.py`'s live
compares print a `note:` and never fail; `s802.py` reads its anchor through `git show` at its own commit; every other builder pins
`c8-unitNN/`. Nothing would fail on C5's paths; no builder was edited.

## Next

Section 2 ends here. Section 3 starts on `after/` — this tree, the anchor as unit 13 left it.

## What differed from the brief

- The brief's `sync` numbers were BLUE's (every one of its rounds, Caffeine and ConcurrentMap). This unit's are its own: 20 rounds per count
  per JVM, three JVMs per row in each run of record, on Caffeine and on Redis through the anchor's writer — the Redis row is captured,
  not dropped. ConcurrentMap's `sync` is not run here. `before/`'s contrast runs 2 and 4 threads only, as the prompt asks.
- `nulls` runs TiffinBoxServer's route as well as reading it off the source: `GET /customers/Nobody` answered 404 before the insert and
  still 404 after it.
- On Redis the stored form of the empty answer is `NullValue`'s bytes as `redis-cli --no-raw GET` prints them: they open with the JDK's
  serialization header (`\xac\xed`), not JSON, although `RedisCaching`'s value serializer is JSON's (unit 11's `json`); this unit does
  not trace which class writes them, and says only what `redis-cli` printed.
- `cond` names its own cache and reads through Spring Data JPA's repository directly, so the anchor's `customer` cache never answers
  for it; Sam is not in the seed and is added through `add` in the step (said in its line). Its Redis row is captured.
- The RED #3 hazard, "the other way round", is a JVM of `anchor` on `after/` with `--spring.cache.cache-names=customers` (a flag, not a
  copy; the anchor's YAML never edited): the first `findByName` throws `Cannot find cache named 'customer'`. The cache-names plant
  is caught by `chk13.py static` on the planted YAML.
- The exercise's broken state is a file of this folder, `exercise/CustomerRepository.java` (the anchor's with one annotation line
  changed), which the block copies into a copy of `after/`; the solution's line puts `unless` back as it copies. It runs `Lookup.java`
  against the tree's extracted jar and its `lib/`, as unit 12's exercise did.
- The tests (`mvn -o package` with Docker at nothing, then `mvn -o verify`) run once per run of record inside `anchor`, as unit 12's.
- The stampede's per-thread proof is each round's set of list sizes, printed once per count as "{4} in every round" (the set every
  round's threads received); a round where a thread threw or got another size would print the 20 sets.

## For RED

- `sync`'s `1 in every round` is asserted per round in every JVM; a single round that printed 2 would make the capture drift and stop
  the run — the claim would then be its rounds, read off the list.
- The Redis `sync` rows go through `RedisCache`'s own synchronized load in this JVM, with the anchor's writer; nothing here measures two
  servers.
- `cond`'s numbers are the harness's cache's; the anchor ships no `condition`.
- `nulls` and `nonull` run the labelled copy `nounless`; `syncunless` runs its own copy; every other capture runs the anchor's tree.
- The harness's `pause` step polls a file with `Thread.sleep` between looks; `Stampede.java` holds none (asserted).

## Planted faults — each caught (R.65, R.226)

Each fault planted on a scratch mirror of this folder (its files copied, the sibling folders it reads linked, the repository's git
directory named for the commit check; for a plant inside `after/`, the mirror's after-tree pin re-derived so the gate that fails is the
fault's own, not the pin's), one at a time, with nothing else running; the doctored captures edited by Python, never sed; each must exit
non-zero (the receipt's gate, `chk13.py` or the prose gate `s813.py`), the controls 0. Nothing was written to this folder or the
repository by a plant (`git status --short` the same before and after). The driver's own log, the planted dish name and placeholder
word elided (`…`) so that this README passes the gates that caught them:

```markdown
-- controls
exit 0  control: the prose gate on the shipped prose (refused 0)       | 
exit 0  control: chk13 sync on the shipped capture                     | 
exit 0  control: chk13 nulls on the shipped capture                    | 
-- unit 13's list (brief, EVIDENCE BATCHES)
exit 1  "sync works across servers" (R.382)                            | README.md line 542: R.382: sync said to work across servers, JVMs or processes - it is in one JVM
exit 1  cache-null-values=false called "not cached" (R.383)            | README.md line 542: R.383: cache-null-values=false called not cached or quieter - it throws
exit 1  sync + unless on one method in the anchor (after/)             | *** static: FAIL the failure receipt: sync and unless never on one method in the anchor (syncunless: the first
exit 1  "add evicts customer" (RED #8)                                 | README.md line 542: RED #8: add said to evict the customer cache - it evicts customers only
-- carried
exit 1  a wrong hash (the after-tree pin)                              | *** R.211: after/'s tree is 54 78daf6f0c023769de3782c3d4a1c5608, the pin in receipts.md5 is 54 078daf6f0c02376
exit 1  a version claim not printed (4.1.3)                            | FAIL the version lines (R.246) on H2 2.5.250
exit 1  a dish name                                                    | *** an Indian dish name (R.215: English names only): exercise/README.md:13:looks up Nobody's …, adds her 
exit 1  a placeholder                                                  | *** a placeholder in this unit's prose or harness: README.md:496:## Next (…) ***
exit 1  a changed What-it-prints line                                  | 
exit 1  a typed SQL string                                             | README.md line 542: R.225/R.365: a typed SQL string in the prose
exit 1  the exercise's solution = broken (R.196)                       | *** R.196: SOLUTION.md's block must be the README's with one line changed ***
exit 1  a before link to the wrong target                              | *** R.211: before must be a link to ../c8-unit12/after (it points at: ../c8-unit11/after) ***
exit 1  a container removed without -v (R.387)                         | *** R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: dk rm
exit 1  the docker CLI unpinned (R.344)                                | *** R.344: receipts.sh calls docker without the pinned socket (every call is dk): 195:psq() { docker exec "$CN
exit 1  an R.250 sentence left (:50's note removed)                    | *** R.250: FAIL R.250: its unit 13 note follows it: proxy that ran add's transaction runs the cache's advice t
exit 1  a build -pl without -am (R.391)                                | *** R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am ***
exit 1  a sleep added to the stampede harness                          | *** READ FIRST 14: the stampede's class holds a sleep (1 line(s)) - the stampede has no hold ***
exit 1  cache-names: customer removed from the anchor's YAML (RED #3)  | *** static: FAIL spring.cache.cache-names: customers -> customers,customer (RED #3);FAIL the YAML's diff: the 
-- doctored captures (Python edits)
exit 1  invocations 1 typed into a sync round that printed 2           | FAIL sync 8 threads (in the JVM, Caffeine): the per-round list printed exactly when every round printed 1
exit 1  found typed into nulls' post-insert line                       | FAIL the invisible row: after the insert the lookup still returns Optional.empty, repository calls 0, statemen
exit 1  invocations 3 -> 1 in unless                                   | FAIL Nobody x3: invocations 3, Optional.empty each - nothing kept (in the JVM, Caffeine)
exit 1  the IllegalStateException line deleted from syncunless         | FAIL 1 line(s) match ^PROBE first: (java\.lang\.IllegalStateException: A sync=true operation does not support 
exit 1  nonull's three exceptions typed down to two                    | FAIL R.383: IllegalArgumentException on every call, the same message: ['java.lang.IllegalArgumentException: Ca
plants and controls: 26 · wrong outcomes: 0 · the repository's git status --short lines: 4 (c8-unit13/ untracked and c8-tiffinbox's three files modified - nothing written by a plant)
```

## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: the line 23 words · broken: lookup 2 not found, repository calls 1 -> 1 · solved: lookup 2 found, repository calls 1 -> 2 · exit 0 both (H2, Caffeine, no Docker) · anchor: before/ (unit 12): caches at the start [customers], getCache("customer") null · after/ default run (H2, no Redis): org.springframework.cache.caffeine.CaffeineCacheManager, caches at the start [customer, customers], findAll [1, 0, 0, 0, 0] by both witnesses (unchanged), /actuator/prometheus cache_gets_total lines customer 2 · customers 2, /dashboard 200, health 200, readiness 200 · --spring.cache.cache-names=customers on after/: the first findByName throws java.lang.IllegalArgumentException: Cannot find cache named 'customer', invocations 0 · dev-shaped (PostgreSQL + Redis by the digest): org.springframework.data.redis.cache.RedisCacheManager, redis_version:8.10.3, the writer asynchronousWrites false with a lock, keys customer::Ravi and customers::SimpleKey [] (TYPE string, TTL a positive count at most the anchor's, masked) · tests 18 (mvn -o package, no Docker) and 18 + 5 (mvn -o verify) · libs 122 -> 122 (none gained) · Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/Redis 4.1.2 · HHH000001 7.4.13.Final · Flyway 12.4.0 · sync: PostgreSQL, 20 rounds per count per JVM, the capture 3/3: after/ (sync = true) in the JVM, Caffeine: 1 in every round at 2, 4, 8, 16 and 32 threads, every thread its 4 rows · after/ Redis (the anchor's writer): 1 in every round at 2, 4, 8, 16 and 32 threads, every thread its 4 rows · before/ (unit 12, no sync) in the JVM, Caffeine: 2 -> 2 and 4 -> 4 in every round · in one JVM · H2 never run · nulls: the labelled copy nounless (unless removed), PostgreSQL: in the JVM, Caffeine: findByName("Nobody") x3 -> Optional.empty, invocations 1, stored getIfPresent("Nobody") org.springframework.cache.support.NullValue · psql inserts her -> still Optional.empty, invocations 1, GET /customers/Nobody 404 then 404 · evict("Nobody") -> found, invocations 2 · Redis: findByName("Nobody") x3 -> Optional.empty, invocations 1, stored "\xac\xed\x00\x05sr\x00+org.springframework.cache.support.NullValue\x00\x00\x00\x00\x00\x00\x00\x01\x02\x00\x00xp" · psql inserts her -> still Optional.empty, invocations 1, GET /customers/Nobody 404 then 404 · evict("Nobody") -> found, invocations 2 · unless: the anchor's unless, PostgreSQL: in the JVM, Caffeine: Nobody x3 -> invocations 3, nothing stored · Ravi x3 -> invocations 1, stored · insert-then-find -> found, invocations 2 · Redis: Nobody x3 -> invocations 3, nothing stored · Ravi x3 -> invocations 1, stored · insert-then-find -> found, invocations 2 · #result the unwrapped value (the Optional never stored, the empty one never kept) · cond: the harness's h13cond (not the anchor's), condition = "#name.length() > 3", PostgreSQL, Sam not in the seed (added through add): in the JVM, Caffeine: per call [1, 1, 1, 1, 0, 0], invocations 4 · Redis: per call [1, 1, 1, 1, 0, 0], invocations 4 · nonull: the labelled copy nounless + cache-null-values=false, PostgreSQL + Redis: findByName("Nobody") x3 -> java.lang.IllegalArgumentException: Cache 'customer' does not allow 'null' values, three times, invocations 3, nothing stored - the context started · syncunless: the labelled copy syncunless (sync = true and unless on findByName), H2, no Docker: the start green (health 200), the first call java.lang.IllegalStateException: A sync=true operation does not support the unless attribute, invocations 0 · seven: the seven 466c20ed… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · Hibernate's script = xcheck.sql
<!-- values: end -->

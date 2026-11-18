# c8-unit12 — Cache Invalidation

Course 8, Section 2's fifth unit and **Section 2's fourth change to the anchor (C4)**. `before` is a link to `../c8-unit11/after`
(unit 11's tree; the receipt pins it and asserts that pin is unit 11's own after-tree line); `after/` is this unit's tree, and
`../c8-tiffinbox` equals `after/` from this unit's commit on. **Invalidation** is telling a cache that what it holds is no longer the
truth — evicting it, overwriting it, or letting a time to live run out. Course 7's *The Second-Level Cache* pinned this sentence for
this lesson (C8-3, `../c7-unit32/pinned.txt`, its md5 asserted by the receipt):

> A second-level cache holds what Hibernate last read or wrote; a write that never passes through Hibernate leaves it serving the old value.

This unit measures the same shape on Spring's cache abstraction, in the JVM and in Redis, and pins Section 2's sentence for Section 3
(C8-22, `pinned.txt`):

> A cache holds what the method last returned; a write that never passes through the cache leaves it serving the old value.

Every count below comes from two witnesses in the same run (R.375): **the invocation counter** — unit 08's harness `BeanPostProcessor`,
copied, which adds a counting `MethodInterceptor` at position 0 of Spring Data JPA's repository proxy for `CustomerEntityRepository`,
outside the cached bean, so it counts exactly the calls a hit saves in whichever store answers, in the JVM or in Redis — and **Hibernate's statement counter**,
`getPrepareStatementCount()`, Course 7's pinned counter (C8-9, below). A window whose two per-call lists differ fails the run. `psql`
reads PostgreSQL's rows and `redis-cli` reads Redis's keys, each while a harness JVM waits at a pause — the second clients (R.359).
Redis is **Redis 8.10.3, by the digest** (`redis@sha256:7958cfbb…935c3`, `--pull never`, `127.0.0.1` only, no password); PostgreSQL is
18.6 by the capstone's digest; the default run and the exercise are H2 in memory.

Nine captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `exercise` and the
tests that `anchor` carries (unit 11's `nodocker` form, folded into `anchor` here) run once per run, and their 3/3 is across the runs of
record. Every number and string below is asserted right after its capture by `harness/chk12.py` against a second witness of the same
run.

## Runs of record

**On the script as committed:** `bash receipts.sh` (Homebrew bash 5.3.9, 2026-11-18 from 16:30:51 CET, ended 16:40:48), a sealed
fresh clone (below, from 16:40:55, ended 16:51:00) and `./receipts.sh` (/bin/bash 3.2.57, from 16:51:13, ended 17:01:35): each with
every capture = published (the JVM ones 3/3 inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file count
unchanged, volumes back to their count and the images unchanged, `before/` and `after/` = their pins at the start and the end, nothing
listening on 20510-20519 at the end, each log ending `exit 0`; each log through `check_unit8.py 12 --runlog` — `RESULT (run logs): PASS`
(the unit gate itself has no unit 12 script yet, as expected). **Nothing was downloaded.** An earlier `./receipts.sh` run (16:20-16:30)
also passed, on a script whose run-log summary of the stampede's rounds read the wrong separator and printed nothing; the separator was
fixed in `chk12.py rawsum` (no capture moved), and that run is not one of record.

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `885b3b3` into a path **with a space** (`…/sealed
12/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c8-unit12 c8-tiffinbox`; `diff -rq` against the working folder printed nothing), the clone's `.m2-demo` a file copy of the
seed, `env -i` with `HOME`, `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker` and dead
proxies for http and https (`127.0.0.1:9`); `./receipts.sh`. The runs ran on this README before its *Runs of record*, *Interrupted* and
*Planted faults* paragraphs were written; the prose gate and the text-block and values checks were run again on the final README
against the last run's printed lines.

## C4 — the change, file by file, and every README/YAML sentence it rewrote (R.250)

One file changed besides the anchor README; nothing new, nothing deleted, no `pom.xml`, no Java file (the receipt asserts
`RedisCaching.java`, `CustomerRepository.java`, `TiffinBoxApp.java`, `KitchenHealthIndicator.java`, `Dashboard.java`,
`TiffinBoxServer.java`, `application-dev.yaml`, `compose.yaml` and the three `pom.xml` files byte-equal to `before/`'s); Flyway's V1-V3
untouched, Hibernate's schema script still `xcheck.sql` = `../c7-unit39/xcheck.sql`; no jar gained or lost (`anchor`).

- `tiffinbox-web/src/main/resources/application.yaml` — under `spring.cache:`, above the `---`: Caffeine's spec becomes
  `maximumSize=100,recordStats,expireAfterWrite=10m`, and `spring.cache.redis.time-to-live: 10m` sits beside it. **One backstop value,
  the same for both stores, written once each** (`chk12.py static` asserts the two values equal). Why this value, in the file's own
  comment: it is a backstop, not the eviction — the list is one entry, read by every page; TiffinBox's own writes still evict it through
  `add`, so the value bounds only the writes the cache never sees (a `JdbcTemplate` update, psql, another process), and a smaller value
  only reads the table more often. The comment uses no duration word (dur8 over it: 0, asserted); under Spring's AOT step the spec is
  fixed when the jar is built (the file's own phrasing).
- `RedisCaching.java` — **unchanged**: its `RedisCacheConfiguration` is built from Boot's `CacheProperties` (unit 11's `ttlbean` settled
  it, RE-MEASURE 7), and the `anchor` capture reads the YAML's value back from Redis: `redis-cli TTL` a positive count, at most the
  configured one, masked.

The sentences C4 made false or dated, each with its note in place (R.250; `chk12.py r250` asserts each note on its line):

- the anchor README's header, after unit 11's note — a unit 12 note: the cached list carries a time to live since;
- the anchor README's unit 08 section, "a call it does not hold (a miss) runs the method and keeps the answer" — *(Course 8, unit 12:
  for the time to live the configuration sets, since)*;
- the anchor README's unit 10 section, "`spring.cache.caffeine.spec: maximumSize=100,recordStats`" — *(Course 8, unit 12:
  `maximumSize=100,recordStats,expireAfterWrite=10m` since)*;
- `application.yaml`'s unit 10 comment, "The spec: a ceiling of … entries … and recordStats, which turns on Caffeine's counts" — "(Course
  8, unit 12: and expireAfterWrite since, the time-to-live backstop - the comment below.)";
- `../c8-unit11/README.md`'s two forward lines — "Unit 12 moves the anchor next (the time-to-live backstop)" (its *Next*) and "With no
  setting the anchor's entry has no time to live (unit 12 sets the backstop)" (its `ttlbean`) — are now done, not false: unit 11's README
  is left as shipped, and this note is theirs. Its `TTL -1` line stays true of 11/after (that capture's tree).

The anchor README gains its `## Course 8 · unit 12` section in the unit 11 section's shape.

## The captures — what each one shows

### 1 · anchor — Caffeine's policy read back, before/ beside after/; the YAML's value read back from Redis (R.386, R.380)

`before/` (unit 11's tree) and `after/` on H2 in memory with no Redis, then `after/` dev-shaped on PostgreSQL + Redis. The policy is read
through `Cache.getNativeCache().policy()`; U10's numbers are unchanged — five reads, Caffeine's own counts beside the two witnesses:

```text
PROBE Caffeine's policy, read back through Cache.getNativeCache().policy(): expireAfterWrite() Optional.empty (absent) · eviction().getMaximum() 100 · isRecordingStats() true
PROBE Caffeine's policy, read back through Cache.getNativeCache().policy(): expireAfterWrite() Optional[…] (present) · its value = the spec's expireAfterWrite=<n>: yes · eviction().getMaximum() 100 · isRecordingStats() true
PROBE reads: five calls of CustomerRepository.findAll() (H2 2.5.250, in the JVM, Caffeine): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE reads: Caffeine's counts (a third witness): hitCount 4 · missCount 1 · estimatedSize 1
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /dashboard -> 200
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health -> 200 · status UP
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health/readiness -> 200 · status UP
PROBE CacheManager beans 1 [cacheManager=org.springframework.data.redis.cache.RedisCacheManager] (PostgreSQL 18.6)
PROBE Redis's INFO server, through the connection: redis_version:8.10.3
PROBE the cache writer: org.springframework.data.redis.cache.DefaultRedisCacheWriter · asynchronousWrites false · a lock wait set yes (not zero)
redis-cli --scan: customers::SimpleKey [] (1 keys)
redis-cli TTL "customers::SimpleKey []": TTL <n> · a positive count, at most the configured value (the anchor's spring.cache.redis.time-to-live, read off after/'s YAML): yes
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data Redis 4.1.2 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
log: HHH000001: Hibernate ORM core version 7.4.13.Final
```

The same capture carries the tests, run once per run of record: `mvn -o package` with Maven's `DOCKER_HOST` at nothing, then
`mvn -o verify` with Docker — the container tests run on Caffeine, no Redis — and the libraries, counted by name:

```text
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
tiffinbox-web/target/surefire-reports-it: absent - no container test ran
Surefire's Results line: Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
before/: 122 libraries · Caffeine in lib/: caffeine-3.2.4.jar
after/: 122 libraries · Caffeine in lib/: caffeine-3.2.4.jar
gained: 0 · lost: 0
```

### 2 · stale — the hook: a write around the cache, psql's row beside the cached read, Caffeine and Redis through the anchor's writer (C8-3's shape, R.359, S8.29)

`after/` on PostgreSQL, Caffeine first (in the JVM), then Redis through the cache writer TiffinBox gives Redis. One read; then
`JdbcTemplate.update` — a write that never passes through the cache; then, while the JVM waits, psql reads the row; then the cached read (PostgreSQL, Caffeine or Redis).
No harness cache is needed here — the anchor's own `customers` cache is the one read (R.384: nothing to name). Caffeine:

```text
PROBE stale: read 1 - Ravi's meals 2
PROBE stale: JdbcTemplate.update("update customer set meals_per_day = 3 where name = 'Ravi'") -> 1 row
the receipt at pause 1, psql (a second client, PostgreSQL): Ravi's row says 3
PROBE stale: read 2 (the cached read) - Ravi's meals 2 · repository calls 0 · prepareStatementCount 0 · returned
PROBE stale: the read, the write around the cache, the read again (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · the cached read says 2, the row now 3 (JdbcTemplate)
```

Redis, the same steps:

```text
PROBE stale: the read, the write around the cache, the read again (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · the cached read says 2, the row now 3 (JdbcTemplate)
```

Silent, by S8.29's four prints: the counter stays at the first read's, no exception, no ERROR line, exit 0 — the row's new number beside the cached read's old one, in Caffeine and in Redis alike. **The control** (the failure receipt's other half, unit 08's evict called back by title — *@Cacheable, @CacheEvict, @CachePut*):
the cache emptied, a read, then a write through `add(Oscar)`, whose `@CacheEvict(allEntries = true)` empties the list, and a read — the
second read reaches the repository and holds the new row, on both stores:

```text
PROBE stale control: the cache emptied, a read, add(Oscar) through the cache, a read (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · rows 4 -> 5 · Oscar in the second read: true · Ravi's meals 3
PROBE stale control: the cache emptied, a read, add(Oscar) through the cache, a read (PostgreSQL 18.6, Redis): repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · rows 4 -> 5 · Oscar in the second read: true · Ravi's meals 3
```

### 3 · evict — `@CacheEvict(allEntries = true)`, unit 08's annotation, on both stores

A read (the rows read off the seed), `add(Hannah)`, a read: the second read reaches the repository and holds the new row; psql's count
is the second read's. On Redis through the cache writer TiffinBox gives Redis only — unit 11's `writer` capture measured the writer Boot
builds over Lettuce; it is not run again here (*Redis as a Cache*, by title).

```text
PROBE evict: a read, add(Hannah) - @CacheEvict(allEntries = true) - a read (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · rows 4 -> 5 · Hannah in the second read: true
PROBE evict: a read, add(Hannah) - @CacheEvict(allEntries = true) - a read (PostgreSQL 18.6, Redis): repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · rows 4 -> 5 · Hannah in the second read: true
psql (a second client): customers 5
```

### 4 · put — `@CachePut`, on the harness's own cache (labelled, R.384, R.392)

The anchor has no `@CachePut`. The harness's bean `HarnessPut.Meals` puts on its own cache, `h12put`, named at the start beside the
anchor's (`--spring.cache.cache-names=customers,h12put` on the harness's command line, never the anchor's YAML): two writes, then a read
on the same key. Every write runs its method; the read is served from the harness's cache (Caffeine, then Redis), the second write's value:

```text
PROBE put: a harness bean, not the anchor's cache - HarnessPut.Meals, its cache h12put; the cache names at the start [customers, h12put]
PROBE put (PostgreSQL 18.6, in the JVM, Caffeine): @CachePut write("Ravi", 2), write("Ravi", 3), then @Cacheable read("Ravi"): per call [1, 1, 0] and [1, 1, 0] · the writes returned [Ravi 2 meals, Ravi 3 meals] · the read returned "Ravi 3 meals"
PROBE put (PostgreSQL 18.6, Redis): @CachePut write("Ravi", 2), write("Ravi", 3), then @Cacheable read("Ravi"): per call [1, 1, 0] and [1, 1, 0] · the writes returned [Ravi 2 meals, Ravi 3 meals] · the read returned "Ravi 3 meals"
redis-cli GET "h12put::Ravi" (the harness's key): "Ravi 3 meals"
```

These numbers are the harness's cache's, never the anchor's (R.392).

### 5 · ttl — the time to live the configuration sets, said as counts (R.380, flag 10)

The anchor's own value is read back in `anchor` (the YAML key, Caffeine's policy present, `redis-cli TTL` a positive count). The expiry
itself runs on **a labelled override of the YAML's value** — `--spring.cache.caffeine.spec=maximumSize=100,recordStats,expireAfterWrite=<n>` and
`--spring.cache.redis.time-to-live=<n>`, the override's value masked in every print. One read; keys 1; the harness then polls the
condition — Caffeine's `getIfPresent` null, Redis's `EXISTS` 0 — bounded, under the JVM's alarm, never a wait on the setting's value as
the proof and never an elapsed time printed; keys 0; a read reaches the repository again:

```text
-- after/, PostgreSQL + Caffeine, a LABELLED SHORT OVERRIDE: --spring.cache.caffeine.spec=maximumSize=100,recordStats,expireAfterWrite=<n> (the anchor's spec with its own value, masked in every print), one JVM:
PROBE ttl: after read 1 - keys 1 (getIfPresent(SimpleKey []) on the native cache, non-null) · estimatedSize 1
PROBE ttl: the harness polled the condition (keys 0), bounded, under the JVM's alarm - keys 0
PROBE ttl: keys 0 · estimatedSize after cleanUp() 0
PROBE ttl: a read, the key gone, a read (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · invocations 1 -> 2 · keys after read 2: 1
PROBE ttl: a read, the key gone, a read: the two witnesses' per-call lists equal
the receipt at pause 1: the store is in the JVM (Caffeine) - nothing for redis-cli to read
the receipt at pause 2: the store is in the JVM (Caffeine) - nothing for redis-cli to read
-- after/, PostgreSQL + Redis (the anchor's writer), a LABELLED SHORT OVERRIDE: --spring.cache.redis.time-to-live=<n> (masked in every print), one JVM:
PROBE ttl: after read 1 - keys 1 (EXISTS "customers::SimpleKey []" through the connection)
PROBE ttl: the harness polled the condition (keys 0), bounded, under the JVM's alarm - keys 0
PROBE ttl: keys 0
PROBE ttl: a read, the key gone, a read (PostgreSQL 18.6, Redis): repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · invocations 1 -> 2 · keys after read 2: 1
PROBE ttl: a read, the key gone, a read: the two witnesses' per-call lists equal
the receipt at pause 1, redis-cli: --scan customers::SimpleKey [] (1 keys)
redis-cli TTL "customers::SimpleKey []": TTL <n> · a positive count, at most the configured value (the override's): yes
the receipt at pause 2, redis-cli: --scan (0 keys) · EXISTS "customers::SimpleKey []" 0
```

Caffeine's expiry is lazy: `estimatedSize` read the moment `getIfPresent` first returns null can still count the entry (standard error
only, it varies); after `cleanUp()` it reads 0, and `getIfPresent` with the counter is the witness pair.

### 6 · stampede — a cold key, N threads, no hold (R.381, READ FIRST 14, RE-MEASURE 15)

The anchor's own cached `findAll`, its cache emptied before each round; N platform threads started, each counting down a ready latch and
then waiting on one go latch, released together; the round's window closes when every thread returns (R.367, one window per round). No
hold anywhere — `harness/src/probe/u12/Stampede.java` names no `sleep` (asserted, 0). 20 rounds per count, counts 2, 4, 8, 16, 32, one JVM
per store per capture run — 3 JVMs per store inside each run of record, the capture 3/3 equal. PostgreSQL only; H2 never runs it. Boot's
own writer is not captured here (the first item the prompt drops): a trial row on unit 11's copy printed rounds where no thread read the
table, the key not cold — `clear()` on that writer had not landed (unit 11's `writer`, *Redis as a Cache*); not said.

```text
-- the stampede's class, harness/src/probe/u12/Stampede.java: lines naming sleep 0 · the read each thread makes: the anchor's own CustomerRepository.findAll() (the context's bean)
-- after/, PostgreSQL + Caffeine (in the JVM), one JVM:
PROBE stampede 2 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 2 in every round: yes · more than one in every round: yes · calls that threw 0
PROBE stampede 2 threads: per round [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
PROBE stampede 4 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 4 in every round: yes · more than one in every round: yes · calls that threw 0
PROBE stampede 4 threads: per round [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
PROBE stampede 8 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · more than one in every round: yes · calls that threw 0
PROBE stampede 16 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · more than one in every round: yes · calls that threw 0
PROBE stampede 32 threads (PostgreSQL 18.6, in the JVM, Caffeine), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · more than one in every round: yes · calls that threw 0
-- after/, PostgreSQL + Redis, the cache writer TiffinBox gives Redis (locking writes), one JVM:
PROBE stampede 2 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 2 in every round: yes · more than one in every round: yes · calls that threw 0
PROBE stampede 2 threads: per round [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
PROBE stampede 4 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · 4 in every round: yes · more than one in every round: yes · calls that threw 0
PROBE stampede 4 threads: per round [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
PROBE stampede 8 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · more than one in every round: yes · calls that threw 0
PROBE stampede 16 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · more than one in every round: yes · calls that threw 0
PROBE stampede 32 threads (PostgreSQL 18.6, Redis), 20 rounds, the key cold in each: every round's repository calls = its statements: yes · more than one in every round: yes · calls that threw 0
```

With 2 and 4 threads every round of every JVM printed N, on Caffeine and on Redis (the list printed, the capture 3/3 — every
round of the run's three JVMs). From 8 threads on the capture prints only "more than one in every round": in this unit's first full run one
JVM's round of 8 printed one read fewer than its threads on Caffeine, so 8 is said with 16 and 32 — "more than one in every round, up to
all of them" (BLUE's every-round result at 8 was its own run; this unit voices its own). Each round's numbers go to the run log (U12-RAW lines,
standard error; `chk12.py rawsum` prints each JVM's least and most there), never to a capture. On Redis the anchor's writer locks
writes, not reads: every thread missed and read the table. `sync = true` is unit 13's — not measured here.

### 7 · pinned — Section 2's sentence, measured on three stores (C8-22, C8-3)

The stale shape alone — one cached read, a `JdbcTemplate` write around the cache, the cached read still old — on a ConcurrentMap
(`--spring.cache.type=simple` on the harness's command line, `cache-names` kept from the anchor's YAML: Boot's
`ConcurrentMapCacheManager`; a flag, not a copy), on Caffeine and on Redis, PostgreSQL each:

```text
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.concurrent.ConcurrentMapCacheManager] (PostgreSQL 18.6)
PROBE pinned: the read, the write around the cache, the read again (PostgreSQL 18.6, in the JVM, a ConcurrentMap): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · Ravi's meals: read 2 · JdbcTemplate update 1 row · row now 3 · cached read says 2
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.caffeine.CaffeineCacheManager] (PostgreSQL 18.6)
PROBE pinned: the read, the write around the cache, the read again (PostgreSQL 18.6, in the JVM, Caffeine): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · Ravi's meals: read 2 · JdbcTemplate update 1 row · row now 3 · cached read says 2
PROBE CacheManager beans 1 [cacheManager=org.springframework.data.redis.cache.RedisCacheManager] (PostgreSQL 18.6)
PROBE pinned: the read, the write around the cache, the read again (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · Ravi's meals: read 2 · JdbcTemplate update 1 row · row now 3 · cached read says 2
-- Course 7's sentence (C8-3), read off ../c7-unit32/pinned.txt - md5 dbd5b67c2521ccde67a5d0f8b6039a62, 1 line:
A second-level cache holds what Hibernate last read or wrote; a write that never passes through Hibernate leaves it serving the old value.
-- Section 2's sentence for Section 3 (C8-22), written by this receipt from its heredoc to .harness/pinned.txt, then compared with this folder's pinned.txt:
A cache holds what the method last returned; a write that never passes through the cache leaves it serving the old value.
md5 ba35ab90cf46ded9976dc945ca11da2d · 1 line · cmp with pinned.txt: the same, byte for byte
```

### 8 · seven — the comparison set on before/ and after/ (R.363)

`before/`'s jar on 20513 — a second port, so the two jars never share one — and `after/`'s on 20510, H2 in memory, the comparison set of Course 5's *Secrets: What Not to Commit* (`../c5-unit11/curlset.sh`):

```text
exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · listens on: 127.0.0.1:20513
GET /dashboard: 200
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20513 now: 0
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · listens on: 127.0.0.1:20510
GET /dashboard: 200
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20510 now: 0
the seven, after/ against before/: lines that differ: 0
```

### 9 · exercise — run as written, in one shell, bash then zsh (R.196, RE-MEASURE 10)

`exercise/README.md` and `exercise/SOLUTION.md`: H2 + Caffeine, no Docker — the stale read needs no store outside the JVM. The broken
program reads, updates around the cache, reads again; the solution empties the `customers` cache on the write path,
`caches.getCache("customers").clear()` — `add`'s own shape (`allEntries = true`: the list's key is `SimpleKey []`, never the update's
values), chosen over `evict(SimpleKey.EMPTY)` for that reason. The check is the second read's value and the counter, never the exit.

```text
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
Maven: exit 0
clear() on the write path in Meals.java: 0
javac: exit 0
TiffinBox: exit 0
cache: CaffeineCacheManager
read 1: Ravi's meals 2 · repository calls 1
update: 1 row · the table now says 3
read 2: Ravi's meals 2 · repository calls 1
then the solution's lines, in the same shell - the block's exit 0:
Maven: exit 0
clear() on the write path in Meals.java: 1
javac: exit 0
TiffinBox: exit 0
cache: CaffeineCacheManager
read 1: Ravi's meals 2 · repository calls 1
update: 1 row · the table now says 3
read 2: Ravi's meals 3 · repository calls 2
the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20510 afterwards: 0
```

## Which store, which manager, which writer

Every caching line names its store: **in the JVM, Caffeine** — the default run's `CaffeineCacheManager`; **in the JVM, a ConcurrentMap**
— `ConcurrentMapCacheManager`, in `pinned` alone, by the harness's flag; and **Redis, by the digest** — `RedisCacheManager`, its cache
`RedisCache`, `LettuceConnectionFactory` on `127.0.0.1:20512`, and **the cache writer TiffinBox gives Redis** (`immediateWrites` +
`enableLocking`; printed `asynchronousWrites false` with a lock wait set). The writer Boot builds over Lettuce is not run in this unit (unit 11's
`writer` capture measured it). PostgreSQL answers every miss in `stale`, `evict`, `put`, `ttl`,
`stampede` and `pinned`; H2 in memory answers the default run's and the exercise's.

## Refused, named

- A time to live said as a time — `after two seconds`, `after a few seconds`, `expires quickly`, `after a while`, `short`, `briefly`,
  `in a moment` (R.380, R.388, RED #10): the time to live the configuration sets is read back as a count and its expiry said as keys and
  invocations.
- `N threads, N reads` for 16 or 32 (R.381): above 8 the rounds are more than one, up to all of them.
- Any stampede number from H2 (R.381): H2 never runs it.
- A hold or a `sleep` in the stampede (READ FIRST 14): there is no hold, asserted.
- `clear()` said to be immediate on Redis with Boot's own writer (unit 11's `writer`: it is not; *Redis as a Cache*).
- Course 7's sentence from *The Second-Level Cache* off by a byte (its md5 and a line-by-line check in the receipt).
- `Hibernate's cache` or `Spring Data caches` for Spring's cache abstraction (R.348's family); `faster`, `instantly` (R.388's family).
- A number from a cache the anchor does not ship (R.392): the harness's `h12put` is labelled the harness's, its key `h12put::Ravi`.
- A container removed without `-v` (R.387); a build that names `-pl` without `-am` (R.391 — BLUE's own fault, an installed sibling jar,
  printed one read in every round); the docker CLI without its pinned socket (R.344).

## Call-backs, by title (R.224)

- Course 7's *The Second-Level Cache* (`java7_series.TITLES["32"]`): its pinned sentence, byte for byte from `../c7-unit32/pinned.txt` —
  **C8-3 paid** (above).
- Course 7's *N+1, Measured* (`java7_series.TITLES["30"]`): its pinned counter, from `../c7-unit30/pinned.txt`, its third line — **C8-9
  called back**:

```markdown
SessionFactory.getStatistics().getPrepareStatementCount()
```

- Course 8's *@Cacheable, @CacheEvict, @CachePut* (`java8_series.TITLES["08"]`): `add`'s `@CacheEvict(allEntries = true)` and the counter,
  copied (`harness/src/probe/u12/Counter.java`, unit 11's but for its package line — `chk12.py static`).
- Course 8's *Caffeine* (`java8_series.TITLES["10"]`): the spec this unit extends; its five-read numbers, unchanged.
- Course 8's *Redis as a Cache* (`java8_series.TITLES["11"]`): `before/`; its writer, its `ttlbean` (the TTL reaching Redis through
  `CacheProperties`).
- This unit: *Cache Invalidation* (`java8_series.TITLES["12"]`, `12-cache-invalidation`).

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged.

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s2`; every build reads it offline (`-o`,
`maven.repo.local` as an absolute path), every one `-pl tiffinbox-web -am`, and the receipt asserts its file count unchanged after every
Maven run. Docker: the pinned socket on every call, both images by their digests, `--pull never`; the image list and the volume count are
asserted unchanged at the end. No Compose run in this unit (unit 11's `compose` settled it; `compose.yaml` is untouched). Nothing in this
unit touched the network; the harness's HTTP requests go to TiffinBox's own web server on 127.0.0.1.

## The folders, the harness and the ports

- `harness/src/probe/u12/U12.java` — the harness program (steps `info`, `http`, `reads`, `stale`, `pinned`, `evict`, `put`, `ttl`,
  `stampede`, `pause`), TiffinBox's application class with its web server; `Stampede.java` — the stampede's rounds, no hold;
  `HarnessPut.java` — the `put` step's harness bean (`h12put`); `Counter.java` — witness 1. `harness/src/probe/x/XMain.java` —
  `c7-unit29`'s schema probe, byte for byte. `U12.java`'s `pause` and `ttl` steps poll a file or a condition with a
  `Thread.sleep` between looks — a poll, never the proof; the stampede's class holds none.
- `harness/chk12.py` (the checks), `harness/s812.py` (the prose gate, its self-test first), `harness/tree12.py` (the pins),
  `harness/surefire.py` and `harness/dur8.py` (unit 02's, byte for byte), `harness/logback.xml`
  (unit 07's).
- `exercise/Meals.java` — the exercise's program; `pinned.txt` — C8-22; `xcheck.sql` — Course 7's capstone's.
- Ports: 20510 TiffinBox (`after/`; the seven; the exercise) · 20511 the PostgreSQL container · 20512 the Redis container ·
  20513 TiffinBox `before/` for the seven · 20514-20519 never bound. All ten are asserted free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masked: this folder and the repository's paths, the home, the user name, Boot's `Started … in <t>`, Surefire's `Time elapsed`, Flyway's
`execution time`, Spring Data's `scanning in <t>`, `initialization completed in <t>`, any `PT<t>`, Maven's `Total time`, `using Java
<version>`, object hashes, `totalLoadTime=<masked>`, **`expireAfterWrite=<n>`**, **`time-to-live=<n>`** (with `=` or `:`) and **`TTL <n>`**
for a positive count (R.380, R.388; the mask's self-test refuses planted unmasked ones, the override's and the anchor's). The harness
prints `spring.cache.redis.time-to-live` as `set` or `unset`, never its value. dur8 finds no word in the captures, in this README's text
blocks or in `application.yaml`'s unit 12 comment, asserted. Filtered: the harness JVM's log down to the `Found` lines, `HHH000001`,
Flyway's `Database` line (its port and database masked) and the WARN lines (Netty's DNS line at start; Flyway's H2 version line). The
PostgreSQL password and the shutdown token are generated per run, 0600, and asserted absent from every capture.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM, Maven, the exercise's shell), removes both containers
with their volumes (`rm -fv`), removes any Testcontainers container, deletes the partial captures, and exits 130. Measured 2026-11-18
after the runs of record, on this folder, the script started with SIGINT at its default (`perl -e '$SIG{INT}="DEFAULT"; exec …'` —
unit 11's form: this machine's shell refuses `set -m`'s process groups) and the signal sent to its pid at six points: mid-build (Maven
building the trees), mid-verify (Testcontainers' container tests running), mid-harness (the `anchor` capture's default-run JVM, H2 in
memory, both containers already up), mid-TiffinBox on PostgreSQL (the `stale` capture's Caffeine JVM, past its first read), mid-Redis
(the `evict` capture's JVM on PostgreSQL + Redis, the cache writer TiffinBox gives Redis) and mid-stampede (the `stampede` capture's Caffeine JVM, its rounds running) — each
looked at twice, the second look a few beats later; `.harness/` cleared before each start. The captures on disk were compared before and
after: all nine unchanged. A lesson paid for once: the planted-fault driver, run from the same shell while a run of record was building,
started mirror copies of this script whose own exit sweep stopped that run's Maven (exit 143) — the plants then ran alone, and the run
of record was started again.

```markdown
mid-build: exit 130 · first look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-build: second look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-verify: exit 130 · first look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-verify: second look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-harness: exit 130 · first look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-harness: second look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-TiffinBox-on-PostgreSQL: exit 130 · first look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-TiffinBox-on-PostgreSQL: second look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-Redis: exit 130 · first look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-Redis: second look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-stampede: exit 130 · first look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
mid-stampede: second look: java 0 · mvn 0 · c8u12 containers 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20510-20519 0 · .r-lock absent · partial .r-*.[123] 0
captures on disk: unchanged
```

## The ledger rows this unit pays

- **C8-3** — Course 7's sentence, byte for byte (md5 `dbd5b67c…`, asserted), then the same shape on Spring's cache abstraction, in Caffeine and in Redis through the anchor's writer, Course 7's *The Second-Level Cache* by title (`stale`, `pinned`):
  **paid**.
- **C8-22** — Section 2's pinned sentence for Section 3: `pinned.txt`, written by the receipt from its heredoc and compared byte for
  byte, measured on three stores: **opened** (Section 3's brief).
- **C8-9** — called back (above).

## RE-MEASURE — the brief's items this unit settles

- **7** — `RedisCaching` built from `CacheProperties`: the anchor's own YAML value reaches Redis (`anchor`: `TTL` a positive count, at most
  the configured one) — RedisCaching stays unchanged.
- **10** — the exercise's evict on the write path, shipped form: `caches.getCache("customers").clear()` after the update → the next read
  shows the new number and reaches the repository (`exercise`, bash and zsh).
- **13** — the seven on 12/after = before/'s (`seven`); no script sentence about the dashboard's statements is owed here.
- **15** — Redis's plain stampede, on the anchor's own `findAll`, no hold, with the anchor's writer — captured 3/3 (`stampede`); with
  Boot's own writer not captured, not said; `sync` is unit 13's.

## The anchor moved — the builders (R.211, R.331)

Before the commit: `/usr/bin/grep -n 'c8-tiffinbox\|tiffinbox-web/pom\|application.yaml\|application-dev\|compose.yaml\|CustomerRepository\|RedisCaching\|README'`
over `_builders/s80*.py`, `check_unit8.py`, `qa_java8.py` and `build_java8.py`. Section 2's builders do not exist yet (no `s81*.py`);
`s801.py`'s and `s802.py`'s live compares print a `note:` and never fail; `s802.py` reads its anchor through `git show` at its own
commit; every other builder pins `c8-unitNN/`. Nothing would fail on C4's paths; no builder was edited.

## Next

Unit 13 moves the anchor next (`sync = true` on the cold key, `unless` on `findByName`, which stays uncached until then).

## What differed from the brief

- The brief's stampede numbers were BLUE's (2, 4 and 8 threads, N in every round of its 120 per count, Caffeine and ConcurrentMap). This unit's are its own:
  60 rounds per count per store per run (3 JVMs × 20), Caffeine and Redis with the anchor's writer. **8 threads missed N in one round of
  one JVM** in this unit's first full run, so the voiced N-of-N claim is 2 and 4 only; 8 joins 16 and 32 ("more than one in every round,
  up to all of them"). ConcurrentMap's stampede is not run here (`pinned` alone runs the ConcurrentMap). The Boot-default-writer row was
  dropped (the prompt's first drop; its trial rounds were not cold, above).
- No harness copy of `after/`: unit 11's `variants.py` would have served only the dropped row, so the harness ships without one, and
  `harness/` lists no `variants.py`.
- The tests (`mvn -o package` with Docker at nothing, then `mvn -o verify` — the counts in `anchor`'s block) run once per run of record inside `anchor`
  — unit 11's `nodocker` form, folded in as the prompt asks; the anchor capture's three runs inside a run carry the same lines.
- The exercise runs `exercise/Meals.java` against `after/`'s extracted jar and its `lib/` — the class path unit 11's exercise used —
  rather than Maven's `dependency:build-classpath` list; the jar's libraries are what `java -jar` runs.
- `stale`'s psql read runs while the JVM waits at a pause (the receipt writes `./go`); `pinned` reads the row with `JdbcTemplate` inside
  the JVM — the three-store sentence's receipt, `stale` its second-client half.
- The override is a value in the YAML's own syntax (masked); the receipt compares redis-cli's `TTL` with it and with the anchor's value
  read off the YAML — numbers the receipt never prints.

## For RED

- The lines up to 8 threads are the same in every run so far; a single round that missed N would make the capture drift and stop the run
  — the voiced claim would then be "more than one in every round" for that count.
- 16 and 32 vary run to run; the run log's per-JVM least and most are printed by `chk12.py rawsum`, never hashed.
- `put`'s numbers are the harness's cache's; the anchor ships no `@CachePut`.
- The harness's `pause` and `ttl` polls use `Thread.sleep` between looks; `Stampede.java` holds none (asserted).

## Planted faults — each caught (R.65, R.226)

Each fault planted on a scratch mirror of this folder (its files copied, the sibling folders it reads linked, the `pinned.txt` of Course 7's *The Second-Level Cache* copied so
it can be planted; the repository's git directory named for the commit check), one at a time; the doctored captures edited by Python, never
sed; each must exit non-zero (the receipt's gate, `chk12.py` or the prose gate `s812.py`), the controls 0. Nothing was written to
this folder or the repository by a plant (`git status --short` the same before and after). The driver's own log:

```markdown
-- controls
exit 0  control: the prose gate on the shipped prose                   |
exit 0  control: chk12 stampede on the shipped capture                 |
exit 0  control: chk12 stale on the shipped capture                    |
-- unit 12's list (brief, EVIDENCE BATCHES)
exit 1  C8-3 off by one byte (c7-unit32/pinned.txt)                    | *** C8-3: ../c7-unit32/pinned.txt's md5 is b3cfa06009938dcc09752605d1da28af, not dbd5b67c2521ccde67a5d0f8b6039
exit 1  C8-3 quoted off by one byte in README.md                       | *** C8-3: README.md holds a line naming Course 7's sentence that is not the sentence, byte for byte (1) ***
exit 1  "after a few seconds" (dur8)                                   | README.md line 120: dur8: seconds
exit 1  "expires quickly" (S8.32/R.380)                                | README.md line 158: dur8: quickly
exit 1  a 16-thread count voiced N -> N (R.381)                        | README.md line 216: R.302: a capture's number typed in prose: 16 reads
exit 1  a stampede tree built -pl without -am (R.391)                  | *** R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am ***
-- carried
exit 1  a wrong hash (the after-tree pin)                              | *** R.211: after/'s tree is 54 322e4af5a4fee8cc512a109a5fec881c, the pin in receipts.md5 is 54 0322e4af5a4fee8
exit 1  a version claim not printed (4.1.3)                            | FAIL not printed: PROBE versions: Spring Boot 4.1.3 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spr
exit 1  a dish name                                                    | *** an Indian dish name (R.215: English names only): exercise/README.md:12:customer list, changes Ravi's panee
exit 1  a placeholder                                                  | *** a placeholder in this unit's prose or harness: README.md:396:## Next (TODO) ***
exit 1  a changed What-it-prints line                                  |
exit 1  a typed SQL string                                             | README.md line 396: R.225/R.365: a typed SQL string in the prose
exit 1  the exercise's solution = broken (R.196)                       | *** R.196: SOLUTION.md's block must be the README's with one line changed ***
exit 1  a before link to the wrong target                              | *** R.211: before must be a link to ../c8-unit11/after (it points at: ../c8-unit10/after) ***
exit 1  a container removed without -v (R.387)                         | *** R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: dk rm
exit 1  the docker CLI unpinned (R.344)                                | *** R.344: receipts.sh calls docker without the pinned socket (every call is dk): 202:psq() { docker exec "$CN
exit 1  an R.250 sentence left (its note removed)                      | FAIL R.250: its unit 12 note follows it: a call it does not hold (a miss) runs the method and keeps t
-- doctored captures (Python edits)
exit 1  invocations 2 typed into stale's cached-read line              | FAIL S8.29: the cached read reached nothing - repository calls 0, statements 0, returned (no exception)
exit 1  keys 0 typed before the poll                                   | FAIL keys 1 -> 0 (polled on the condition), then the read reaches the repository: invocations 1 -> 2 (in the J
exit 1  TTL -1 typed into the anchor's line                            | FAIL 1 line(s) match ^  redis-cli TTL "customers::SimpleKey \[\]": TTL <n> · a positive count, at most the co
exit 1  a sleep added to the stampede harness                          | *** READ FIRST 14: the stampede's class holds a sleep (1 line(s)) - the stampede has no hold ***
exit 1  a 16-thread round typed to 16                                  | FAIL 1 line(s) match ^PROBE stampede 16 threads \(PostgreSQL 18\.6, in\ the\ JVM,\ Caffeine\), 20 rounds, the
exit 1  the psql row typed as 2                                        | FAIL the update changed 1 row, and psql (a second client) reads the row the update wrote: 2
plants and controls: 26 · wrong outcomes: 0 · the repository's git status --short lines: 3 (c8-unit12/ and c8-tiffinbox's two files, untracked/modified - nothing written by a plant)
```

## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: the line 23 words · broken: read 2 says 2 (the table 3), repository calls 1 -> 1 · solved: read 2 says 3, repository calls 1 -> 2 · exit 0 both (H2, Caffeine, no Docker) · anchor: before/ (unit 11): expireAfterWrite Optional.empty · after/ default run (H2, no Redis): org.springframework.cache.caffeine.CaffeineCacheManager, expireAfterWrite Optional[…] = the spec's, maximum 100, recordStats true, [1, 0, 0, 0, 0] by both witnesses, Caffeine hitCount 4 missCount 1 estimatedSize 1, /dashboard 200, health 200, readiness 200 · dev-shaped (PostgreSQL + Redis by the digest): org.springframework.data.redis.cache.RedisCacheManager, redis_version:8.10.3, the writer asynchronousWrites false with a lock, key customers::SimpleKey [], redis-cli TTL a positive count at most the anchor's (masked) · tests 18 (mvn -o package, no Docker) and 18 + 5 (mvn -o verify) · libs 122 -> 122 (none gained) · Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/Redis 4.1.2 · HHH000001 7.4.13.Final · Flyway 12.4.0 · stale: in the JVM, Caffeine (PostgreSQL): row now 3 (psql) · cached read says 2, repository calls 1 then 0, statements 0, no exception, exit 0 · control via add(Oscar): invocations 2, rows 4 -> 5 · Redis (PostgreSQL): row now 3 (psql) · cached read says 2, repository calls 1 then 0, statements 0, no exception, exit 0 · control via add(Oscar): invocations 2, rows 4 -> 5 · evict: in the JVM, Caffeine (PostgreSQL): rows 4 -> 5, invocations 2 (both reads) · Redis (PostgreSQL): rows 4 -> 5, invocations 2 (both reads) · Redis through the anchor's writer · put: the harness's h12put (not the anchor's): in the JVM, Caffeine (PostgreSQL): per call [1, 1, 0], the read returned "Ravi 3 meals" · Redis (PostgreSQL): per call [1, 1, 0], the read returned "Ravi 3 meals" · ttl: a labelled short override (masked), PostgreSQL, Caffeine and Redis alike: keys 1 -> 0 by a bounded poll on the condition, then invocations 1 -> 2; Redis: redis-cli --scan 1 key then 0, TTL a positive count at most the override's; Caffeine: getIfPresent null, estimatedSize 0 after cleanUp() · stampede: PostgreSQL, 20 rounds per count per JVM, 3 JVMs per run (the capture 3/3): Caffeine 2 -> 2 in every round, 4 -> 4 in every round, 8 -> more than one in every round, up to all of them, 16 -> more than one in every round, up to all of them, 32 -> more than one in every round, up to all of them · Redis (the anchor's writer) 2 -> 2 in every round, 4 -> 4 in every round, 8 -> more than one in every round, up to all of them, 16 -> more than one in every round, up to all of them, 32 -> more than one in every round, up to all of them · H2 never run · Boot's own writer not captured · pinned: C8-3 md5 dbd5b67c… · C8-22 pinned.txt md5 ba35ab90… · PostgreSQL: in the JVM, a ConcurrentMap: Ravi's meals: read 2 · JdbcTemplate update 1 row · row now 3 · cached read says 2 · in the JVM, Caffeine: Ravi's meals: read 2 · JdbcTemplate update 1 row · row now 3 · cached read says 2 · Redis: Ravi's meals: read 2 · JdbcTemplate update 1 row · row now 3 · cached read says 2 · seven: the seven 466c20ed… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · Hibernate's script = xcheck.sql
<!-- values: end -->

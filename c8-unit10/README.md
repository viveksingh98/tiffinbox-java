# c8-unit10 — Caffeine

Course 8, Section 2's third unit and **Section 2's second change to the anchor (C2)**. `before` is a link to `../c8-unit08/after`
(unit 08's tree, the cache abstraction on Boot's `ConcurrentMapCacheManager`; the receipt pins it and asserts that pin is unit 08's own
after-tree line); `after/` is this unit's tree, and `../c8-tiffinbox` equals `after/` from this unit's commit on. The customer list's
cache becomes **Caffeine**'s: a cache library for the JVM whose caches are bounded — a ceiling on the entries each keeps — and counted.
**Eviction** is what a bounded cache does past its ceiling: it drops an entry to make room. Boot's cache module sees Caffeine on the class
path and builds a `CaffeineCacheManager`; the cache lives in the JVM, a Caffeine cache per cache name.

Every count below comes from two witnesses in the same run (R.375): **the invocation counter** — unit 08's harness `BeanPostProcessor`,
copied, which adds a counting `MethodInterceptor` at position 0 of Spring Data JPA's repository proxy for `CustomerEntityRepository`,
outside the cached bean, so it counts exactly the calls a hit in Caffeine's cache saves — and **Hibernate's statement counter**,
`getPrepareStatementCount()`, Course 7's pinned counter. A window whose two per-call lists differ fails the run. A third witness is
Caffeine's own: its `stats()`, and the cache lines Micrometer writes on `/actuator/prometheus` — never the only one. Both databases answer
every counted window: H2 in memory, TiffinBox's default, and PostgreSQL 18.6 in a container by the capstone's digest, through the config
tree's URL and the jar's own driver.

Seven captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `tests` and
`exercise` run once per run and were hashed equal over the three runs of record. Every number and string below is asserted right after
its capture by `harness/chk10.py` against a second witness of the same run (*What differed from the brief*, first item).

## C2 — the change, file by file, and every README sentence it rewrote (R.250)

C2 changes two files and the anchor's README; nothing new, nothing deleted, no Java file (`chk10.py static`, from the files; the receipt
also prints `CustomerRepository.java` and `TiffinBoxApp.java` with the same md5 as `before/`'s):

- `tiffinbox-web/pom.xml` — **`com.github.ben-manes.caffeine:caffeine`**, no version typed (Boot's parent manages it), with a "Course 8,
  unit 10:" comment beside it in the form the POM's other dependencies have. Lines added only. The jar's libraries gain Caffeine's jar and
  one of its own dependencies (the `anchor` capture lists them by name, read off `lib/`).
- `tiffinbox-web/src/main/resources/application.yaml` — under the first document's `spring:`, above the `---` (below it, only the rush
  profile would cache this way): `cache.cache-names: customers` and `cache.caffeine.spec: maximumSize=100,recordStats`, with a "Course 8,
  unit 10:" comment in the file's comment style — what the names do (the caches made at the start; the manager static; the caches
  Micrometer reports) and what the spec does (a ceiling the one-entry list never reaches; `recordStats` for Caffeine's counts). Lines
  added only; the exposure `health,prometheus`, `ddl-auto: validate` and Flyway's V1-V3 untouched.
- `README.md` (the anchor's) — a `## Course 8 · unit 10` section in unit 08's block's shape, and two sentences noted in place, each in a
  note that starts *Course 8, unit 10* (`chk10.py r250` asserts each note sits on its sentence; a plant that drops one fails):
  1. the header's line that carries unit 08's note ("Course 8's units are planned to put a number on …") — the cache is Caffeine's since;
  2. unit 08's section, "With no cache library on the class path Boot builds a **`ConcurrentMapCacheManager`**: each cache a
     `ConcurrentHashMap`, in the JVM." — Caffeine is on the class path since, and Boot builds a `CaffeineCacheManager`.
  The hunt: every line of the anchor README naming `ConcurrentMapCacheManager`, `ConcurrentHashMap`, "no cache library", "any cache name"
  or "Boot's default map" (`chk10.py r250` refuses another present-tense `ConcurrentMap` sentence without a unit 08 or unit 10 note).
  The anchor README's older prometheus section is a dated record of its own run and names no cache: not rewritten.

Not changed, and said so: `CustomerRepository` (`@Cacheable("customers")` on `findAll()`, `@CacheEvict` on `add`, `.toList()` kept —
the `ArrayList` is unit 11's), `TiffinBoxApp`, `findByName` (uncached until unit 13), the exposure (`/actuator/caches` and
`/actuator/metrics` stay unexposed — the `anchor` capture prints both 404, and neither is added), Hibernate's schema script (`xcheck.sql`
= `c7-unit39/xcheck.sql`, byte for byte, the `seven` capture's first line).

## The captures — what each one shows

### 1 · anchor — the change, on both databases (C2)

`after/` started by the harness with its web server, once on H2 in memory and once on PostgreSQL 18.6 (the container by the digest,
the jar's own driver): the strict-mode lines and both `Found` lines on each (the capture), the versions read off the running context,
`HHH000001`, the environment's cache keys, the `CacheManager` bean, the cache names at the start, the cache's class and native class, and
four routes asked over HTTP. The start's own read (`TiffinBoxServer.start()`, `@PostConstruct`) is its own window: one repository call
and one statement, Caffeine's counts all zero, the list's entry absent — the start's read runs before caching is live.

```text
before/: 101 libraries · a PostgreSQL driver in lib/: postgresql-42.7.14.jar · Caffeine in lib/: none
after/: 103 libraries · a PostgreSQL driver in lib/: postgresql-42.7.14.jar · Caffeine in lib/: caffeine-3.2.4.jar
gained: caffeine-3.2.4.jar
gained: error_prone_annotations-2.49.0.jar
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data JDBC 4.1.2 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
log: HHH000001: Hibernate ORM core version 7.4.13.Final
PROBE the environment: spring.cache.type unset · spring.cache.cache-names customers · spring.cache.caffeine.spec maximumSize=100,recordStats · management.endpoints.web.exposure.include health,prometheus
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.caffeine.CaffeineCacheManager] (H2 2.5.250)
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.caffeine.CaffeineCacheManager] (PostgreSQL 18.6)
PROBE the cache names at the start, getCacheNames(): [customers]
PROBE cache customers: org.springframework.cache.caffeine.CaffeineCache · native com.github.benmanes.caffeine.cache.BoundedLocalCache$BoundedLocalManualCache
PROBE the start's own read (TiffinBoxServer.start(), @PostConstruct), its own window, from the context's first statement to here (H2 2.5.250): repository calls 1 · prepareStatementCount 1 · Caffeine's stats() CacheStats{hitCount=0, missCount=0, loadSuccessCount=0, loadFailureCount=0, totalLoadTime=<masked>, evictionCount=0, evictionWeight=0} · estimatedSize 0 · the list's entry (SimpleKey []) present false
PROBE http (PostgreSQL 18.6): GET /dashboard -> 200
PROBE http (PostgreSQL 18.6): GET /actuator/caches -> 404
PROBE http (PostgreSQL 18.6): GET /actuator/metrics -> 404
PROBE http (PostgreSQL 18.6): GET /actuator/prometheus -> 200
```

The libraries: `after/`'s jar holds Caffeine's jar and one of Caffeine's own dependencies more than `before/`'s (`comm`, by name; Caffeine's
other dependency, `jspecify`, was already there). The versions are read off the run and off the jar's name in `lib/` (R.246) — Spring
Boot 4.1 or newer, Caffeine as Boot's parent manages it. `/actuator/caches` and `/actuator/metrics` answer 404 on both databases: the
exposure is `health,prometheus`, unchanged, and neither endpoint is added.

### 2 · stats — the hook: five reads, Caffeine's counts, the prometheus lines of the cache named at the start, then `add` (R.375, RE-MEASURE 5)

`after/`, its web server on 20490: one JVM on H2 in memory, three on PostgreSQL 18.6 (three fresh databases), each with the start's own
window first, then five calls of `CustomerRepository.findAll()` through the context's bean in one window — both witnesses per call —
then Caffeine's `stats()` (after `cleanUp()`), then `GET /actuator/prometheus` and its `cache_` lines for `customers` (the names made at
the start, `spring.cache.cache-names: customers`), then `add(Emma)` and one call, the rows read back by `JdbcTemplate` (and by psql on
PostgreSQL after the JVM stopped), Caffeine's counts and the prometheus lines again. The hook's lines are byte-identical on H2 and the
three PostgreSQL JVMs but for the database's name (`chk10.py` hashes them; the md5 is in the values line). PostgreSQL's lines:

```text
PROBE reads: five calls of CustomerRepository.findAll() (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE reads: five calls of CustomerRepository.findAll(): the two witnesses' per-call lists equal
PROBE reads: after the five calls (PostgreSQL 18.6): Caffeine's stats() CacheStats{hitCount=4, missCount=1, loadSuccessCount=0, loadFailureCount=0, totalLoadTime=<masked>, evictionCount=0, evictionWeight=0} · estimatedSize 1 (after cleanUp()) · keys [org.springframework.cache.interceptor.SimpleKey = SimpleKey []]
PROBE scrape (PostgreSQL 18.6): GET /actuator/prometheus -> 200 · cache_ lines 6 · cache_ lines for customers 6
PROBE scrape (PostgreSQL 18.6): prometheus cache_eviction_weight_total{cache="customers",cache_manager="cacheManager",name="customers"} 0.0
PROBE scrape (PostgreSQL 18.6): prometheus cache_evictions_total{cache="customers",cache_manager="cacheManager",name="customers"} 0.0
PROBE scrape (PostgreSQL 18.6): prometheus cache_gets_total{cache="customers",cache_manager="cacheManager",name="customers",result="hit"} 4.0
PROBE scrape (PostgreSQL 18.6): prometheus cache_gets_total{cache="customers",cache_manager="cacheManager",name="customers",result="miss"} 1.0
PROBE scrape (PostgreSQL 18.6): prometheus cache_puts_total{cache="customers",cache_manager="cacheManager",name="customers"} 0.0
PROBE scrape (PostgreSQL 18.6): prometheus cache_size{cache="customers",cache_manager="cacheManager",name="customers"} 1.0
PROBE add: add(Emma) (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1
PROBE add: the next call (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · per call [1] and [1] · rows 5
PROBE add: after add and the next call (PostgreSQL 18.6): Caffeine's stats() CacheStats{hitCount=4, missCount=2, loadSuccessCount=0, loadFailureCount=0, totalLoadTime=<masked>, evictionCount=0, evictionWeight=0} · estimatedSize 1 (after cleanUp()) · keys [org.springframework.cache.interceptor.SimpleKey = SimpleKey []]
PROBE add: then (PostgreSQL 18.6): prometheus cache_gets_total{cache="customers",cache_manager="cacheManager",name="customers",result="miss"} 2.0
psql (a second client, PostgreSQL) after the JVM stopped: customers 5 · Emma
```

What it shows, on the anchor's own cache, in the JVM, Caffeine's: the first read is a miss (the method runs: one repository call, one
statement), the four after it are hits (neither counter moves); Caffeine's own counts say the same, and so do the `cache_gets_total`
lines Micrometer writes for the cache named at the start. TiffinBox's cache holds ONE entry — the list, key `SimpleKey []` — and never
reaches a ceiling: `cache_size` — the meter of the cache named at the start — reads one and `evictionCount` none. `add` empties the cache (unit 08's `@CacheEvict`), and the next read
is a miss again that returns the new row. `cache_puts_total` is printed and not voiced (R.375): it stays at zero although the list was
stored. `cache_eviction_weight_total` is printed too, and not voiced.

### 3 · ceiling — Course 2's sequence on Course 2's map and on Caffeine (a harness, not TiffinBox's cache; R.385, C8-12)

A plain main (`probe.u10.Ceiling`: no Spring, no database — a harness on Caffeine's own API, not TiffinBox's cache) over `after/`'s
libraries. It reads `../c2-unit04/Bounded.java` at run time — the map's constructor, its ceiling and its sequence, the numbers too — and
feeds that sequence, in one JVM, fifty fresh times, to Course 2's `LinkedHashMap` in access order with `removeEldestEntry` and to a Caffeine
cache built with the same ceiling, a same-thread executor (`executor(Runnable::run)`) and `recordStats()`; `cleanUp()` runs before
Caffeine is read. The survivors are printed per map with how many of the fresh pairs printed them:

```text
CEILING Bounded.java (read at run time): new LinkedHashMap<String, Integer>(16, 0.75f, true) · the ceiling: size() > 3 · the sequence [put Ravi 7200, put Meera 5400, put Sam 3600, get Ravi, put Nina 4800] · 50 fresh pairs, one JVM - a harness on Caffeine's own API, not TiffinBox's cache
CEILING Course 2's LinkedHashMap (access order, removeEldestEntry): keySet() in its own order -> {[Sam, Ravi, Nina]=50} · dropped {[Meera]=50}
CEILING Caffeine maximumSize(3), executor(Runnable::run), cleanUp() before reading: asMap().keySet() sorted -> {[Meera, Nina, Ravi]=50} · dropped {[Sam]=50} · estimatedSize {3=50} · stats().evictionCount() {1=50}
CEILING the same survivors: no
```

The same idea, a ceiling — and a different customer dropped: Course 2's own map keeps its terminal line and drops the one nobody touched
first; Caffeine keeps another set. Every pair printed the same. Which policy makes Caffeine choose so is not printed and not said.

### 4 · nonames — `spring.cache.cache-names` removed: the failure receipt (R.384, R.377)

A copy of `after/` (`harness/variants.py`: the one line `cache-names: customers` removed, asserted the only difference), its web server
on 20492, on both databases; then `after/` itself on H2 with a harness bean that brings caches of its own, its names given beside the
anchor's on the harness's command line (`--spring.cache.cache-names=customers,h10`, never the anchor's YAML). In the copy the cache is
made at the first call: Caffeine still counts, and the prometheus endpoint answers with no cache line — exit 0, no exception, no log
line naming a cache, no ERROR (the four prints of a silent failure):

```text
PROBE the environment: spring.cache.type unset · spring.cache.cache-names unset · spring.cache.caffeine.spec maximumSize=100,recordStats · management.endpoints.web.exposure.include health,prometheus
PROBE the cache names at the start, getCacheNames(): []
PROBE reads: after the five calls (PostgreSQL 18.6): Caffeine's stats() CacheStats{hitCount=4, missCount=1, loadSuccessCount=0, loadFailureCount=0, totalLoadTime=<masked>, evictionCount=0, evictionWeight=0} · estimatedSize 1 (after cleanUp()) · keys [org.springframework.cache.interceptor.SimpleKey = SimpleKey []]
PROBE scrape (PostgreSQL 18.6): GET /actuator/prometheus -> 200 · cache_ lines 0 · cache_ lines for customers 0
exit 0 · its log, every line but the harness's own PROBE lines: lines naming a cache (case-insensitive) 0 · WARN 0 · ERROR 0 · exception class names 0
PROBE the environment: spring.cache.type unset · spring.cache.cache-names customers,h10 · spring.cache.caffeine.spec maximumSize=100,recordStats · management.endpoints.web.exposure.include health,prometheus
PROBE names: getCache("stampede") -> null
PROBE names: two calls of @Cacheable("h10") (H2 2.5.250): its method ran 1 · repository calls 1 · per call [1, 0] and [1, 0] · the two lists equal
PROBE names: one call of @Cacheable("unnamed") (H2 2.5.250): threw java.lang.IllegalArgumentException: Cannot find cache named 'unnamed' for Builder[…]
the run's log, the throw's message: lines with "Cannot find cache named 'unnamed'" 1 · with "Cannot find cache named 'h10'" 0
```

With names given the manager is static (RED #3): a name the start did not make has no cache — `getCache` returns null — and a
`@Cacheable` on it throws at the call; the harness's own cache, named at the start, caches. H2 is enough for this half: the manager is the
class path's and the settings', not the database's.

### 5 · tests — without Docker, then with it (R.363)

```text
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
the verify log: 'Found 1 JPA repository interface' 3 · 'Found 1 JDBC repository interface' 3 · 'Creating container for image' 2 · 'Pulling' 0
```

`mvn -o package` with Maven's `DOCKER_HOST` at nothing runs the tests on H2 in memory; `mvn -o verify` with Docker runs them and the
container tests on PostgreSQL in containers (Surefire's reports per folder are in the capture). Both modules' `Found 1 …` lines are
the start's, on every JVM of the `anchor` capture.

### 6 · seven — the comparison set on before/ and after/ (R.363)

```text
exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20493 now: 0
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20490 now: 0
the seven, after/ against before/: lines that differ: 0
```

The seven answer the same on unit 08's tree and on this one, the same md5 Course 7's capstone published (the hash is not moved by C2); `GET
/dashboard` answers on both. Hibernate's schema script is Course 7's capstone's, byte for byte.

### 7 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`'s block, then `SOLUTION.md`'s, in one `env -i` shell, in bash and in `zsh -f`; each file's "What it prints" block is
asserted equal to what its lines printed. The check is the prometheus line of the cache named at the start and Caffeine's count, never the exit: both
states exit 0 and both count the same; only the solved one, with the name given, carries Caffeine's hit line.

## Which store, which manager

Every caching line in this unit names its store: **in the JVM, Caffeine** — the `CaffeineCacheManager` Boot builds with Caffeine on the
class path and `spring.cache.type` unset (printed), its cache `CaffeineCache`, each over a Caffeine
`BoundedLocalCache$BoundedLocalManualCache` (the spec's ceiling makes it a bounded one) — on H2 in memory and on PostgreSQL 18.6 alike
(the database answers the miss; Caffeine answers the hit, in the JVM). The `ceiling` capture is a harness on Caffeine's own API, with no
Spring and no database; the `nonames` capture's first half is a copy of the anchor, labelled the copy's. Redis (unit 11) is not on this
class path, and nothing here is said for it.

## Refused, named

- `LRU`, `least recently used` or `the same eviction` for Caffeine: on Bounded.java's own sequence the two maps keep different customers
  (`ceiling`, R.385). Course 2's own chip — "same idea, a ceiling" — is what the capture shows. Caffeine's policy is not named: the receipt
  prints no policy (R.385).
- A meter sentence without `spring.cache.cache-names`: the `cache_` lines exist for the caches named at the start, and the `nonames` copy
  shows the endpoint without them (R.384).
- A count from the probe's cache of single customers (RED #2): TiffinBox ships one cache, `customers`, in the JVM, Caffeine's, and
  every number here is that cache's (R.392). The `ceiling` numbers are the harness's; the `nonames` numbers are the copy's.
- `cache_puts_total` voiced: it is printed (it reads Caffeine's loads, and Spring's path stores without one) and never voiced (R.375).
- A slogan for a hit, with one witness: every hit here is the two counters per call from one run, Caffeine's counts beside them (R.375).
- The abstraction credited to Spring Data or Hibernate: `spring-context`'s annotations, Boot's `spring-boot-cache` module (R.348).
- A log line claimed for the missing names: the `nonames` capture prints no log line naming a cache and no ERROR (R.377).
- A time for anything: no duration word, and every duration the logs print is masked, Caffeine's `totalLoadTime` among them (R.388).
- The `cleanUp()` hazard said as a measured fact: the `ceiling` harness runs a same-thread executor and calls `cleanUp()` before reading;
  a run without them was not captured, so what such a run would read is not said (*What differed from the brief*).

## Call-backs, by title (R.224)

- Course 2's *Reference Types: Strong, Soft, Weak and WeakHashMap* (`java2_series.TITLES["04"]`): its `Bounded.java` (`../c2-unit04`),
  a `LinkedHashMap` in access order with a ceiling. Its deck, `core-java-2/scripts-and-decks/04-reference-types.md` lines 175 and 178,
  quoted byte for byte (the receipt asserts each line below is a substring of one of them, and prints both lines' md5s) — **C8-12 paid**:

> C2: // the last true = access order: get() moves an entry to the newest end
> C2: var cache = new LinkedHashMap<String, Integer>(16, 0.75f, true) {
> C2: protected boolean removeEldestEntry(Map.Entry<String, Integer> e) {
> C2: return size() > 3;
> C2: [Sam, Ravi, Nina]
> C2: the Spring caching course swaps this for Caffeine — same idea, a ceiling
> C2: "Five lines: a Linked-Hash-Map in access order that drops the eldest entry past your limit. Keep three, touch Ravi, add Nina, and Meera leaves."

  The `ceiling` capture runs that sequence, read off `Bounded.java` at run time, on Course 2's map and on Caffeine, in one JVM: the map
  keeps Course 2's terminal line, Caffeine keeps another set — the ceiling is the same idea, the customer each drops is not.
- Course 7's *N+1, Measured* (`java7_series.TITLES["30"]`): its pinned counter, called back byte for byte from `../c7-unit30/pinned.txt`,
  its third line — **C8-9 called back**:

```markdown
SessionFactory.getStatistics().getPrepareStatementCount()
```

- Course 8's *@Cacheable, @CacheEvict, @CachePut* (`java8_series.TITLES["08"]`): unit 08's tree, this unit's `before`, and its counter,
  copied (`harness/src/probe/u10/Counter.java`: the package line and one sentence differ, `chk10.py static` asserts the rest).
- Next: *Redis as a Cache* (unit 11) moves the anchor next (Redis, Compose) — `findByName` stays uncached until unit 13; `.toList()` →
  `ArrayList` is unit 11's.

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged: TiffinBox still starts on H2 in memory with nothing installed, and `/actuator/prometheus` now carries the
customers cache's lines (the `anchor` and `stats` captures).

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s2` (it holds Caffeine's jar and its
dependencies); every build reads it offline (`-o`, `maven.repo.local` as an absolute path) and the receipt asserts its file count
unchanged after every Maven run. Docker: the pinned socket on every call, the PostgreSQL image by its digest, `--pull never`, no image
pulled (the image list is asserted unchanged), the volume count asserted unchanged at the end. Nothing in this unit touched the network;
the harness's HTTP requests go to TiffinBox's own web server on 127.0.0.1.

## The folders, the harness and the ports

- `harness/src/probe/u10/U10.java` — the harness program (steps `info`, `http`, `reads`, `scrape`, `add`, `names`), TiffinBox's
  application class with its web server; `Counter.java` — witness 1, unit 08's; `HarnessCaches.java` — the `names` step's harness bean
  (`h10`, `unnamed`); `Ceiling.java` — the `ceiling` capture's plain main. `harness/src/probe/x/XMain.java` — `c7-unit29`'s schema probe,
  byte for byte.
- `harness/chk10.py` (the checks), `harness/s810.py` (the prose gate, its self-test first), `harness/tree10.py` (the pins),
  `harness/variants.py` (the `nonames` copy), `harness/surefire.py` and `harness/dur8.py` (unit 02's, byte for byte), `harness/logback.xml`
  (unit 07's, byte for byte).
- Ports: 20490 TiffinBox `after/` (the harness's web server: the prometheus endpoint; the seven) · 20491 the PostgreSQL container · 20492
  the `nonames` copy's web server and the exercise's · 20493 TiffinBox `before/` for the seven · 20494-20499 never bound. All ten are
  asserted free at the start and the end, and each web server's port free again after its JVM stops.

## Masks, filters and hygiene — every one, declared

Masked: this folder and the repository's paths, the home, the user name, Boot's `Started … in <t>`, Surefire's `Time elapsed`, Flyway's
`execution time`, Spring Data's `scanning in <t>`, `initialization completed in <t>`, Testcontainers' `started in PT<t>S`, Maven's `Total
time`, `using Java <version>`, object hashes, and **Caffeine's `totalLoadTime=<masked>`** in every `CacheStats{…}` line (R.388: dur8 does
not flag it; it is masked anyway and never voiced; the mask's self-test refuses a planted unmasked one). dur8 finds no word in the captures or in
this README's text blocks, asserted. Filtered: Maven's own lines; the harness JVM's log down to the strict-mode line, the `Found`
lines, `HHH000001`, Flyway's `Database` line (its port and database name masked) and the WARN lines; the prometheus text down to the
`cache_` lines for `customers` (sorted) and two counts. The PostgreSQL password and the shutdown token are generated per run, 0600, and
asserted absent from every capture.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM, Maven, the exercise's shell), removes its container
with its volume (`rm -fv`) and any Testcontainers container, deletes the partial captures, and exits 130. Measured 2026-11-18 on this
folder, the script started with SIGINT at its default (a driver that resets the signal with `perl` before `exec`: a script started in
the background by a shell without job control inherits SIGINT ignored, and bash cannot trap a signal ignored on entry — the first
attempt here was such a start, and the script ran on; it was stopped by SIGTERM and looked at, nothing left) and the signal sent to its
pid at five points — mid-build (Maven building the trees), mid-verify (Testcontainers' container tests running), mid-harness (a
harness JVM on H2, its web server up), mid-TiffinBox on PostgreSQL (the harness's TiffinBox started on PostgreSQL) and mid-PostgreSQL
(the second PostgreSQL JVM of `stats`, the container up) — each looked at twice, the second look a few beats later. Three of the five
first ran while this README held a planted dish name in its plants block (the gate stopped them before anything started, exit 1); the
block was redacted and those three points run again:

```markdown
exit 130 at each of the five points; at each look: java 0 · mvn 0 · c8u10-pg 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20490-20499 0 · .r-lock absent · partial .r-*.[123] 0 · captures unchanged
```

## The ledger rows this unit pays

- **C8-12** paid: Course 2's five-line `LinkedHashMap` with a ceiling, its own lines quoted, its own sequence run beside Caffeine in one
  JVM, Caffeine's counts on screen — the ceiling the same idea, the customer dropped not the same.
- **C8-9** called back: `getPrepareStatementCount()` beside the invocation counter in every counted window.

## RE-MEASURE — the brief's items this unit settles

5. BLUE's numbers on the U10 shape, on the shipped tree: settled (`stats`, both databases, PostgreSQL in three JVMs; `nonames`;
   `exercise`). The row's open half — `cache-names` with Caffeine as the default type after unit 11 — is unit 11's and is not measured here.
13. The seven on 10/after: unchanged (`seven`). The dashboard's statements are not measured as a page.

## The anchor moved on — the builders (R.211, R.331)

Before the commit, the grep the prompt names — `/usr/bin/grep -n 'c8-tiffinbox\|tiffinbox-web/pom\|application.yaml\|README'` over
`_builders/s80*.py`, `check_unit8.py`, `qa_java8.py` and `build_java8.py` — printed its lines, filed in this run's scratch and summarised here. Every line
naming `c8-tiffinbox` is one of two kinds: an "R.211 live compare" (`s801.py`-`s807.py`: `diff -rq` against the live anchor, a
difference printed as a `note:`, a live file read only behind an existence check — R.331), or `git show <commit>:c8-tiffinbox/<p>` at
the builder's pinned evidence commit (`s802.py`, `s807.py`). No shipped builder fails on the changed paths; none was edited.

## Next

Unit 11 moves the anchor next (Redis, Compose) — `findByName` stays uncached until unit 13; `.toList()` → `ArrayList` is unit 11's.

## What differed from the brief

- **3/3.** The JVM captures (`anchor`, `stats`, `ceiling`, `nonames`, `seven`) run three times inside every run and hash equal; `tests`
  and `exercise` (Maven builds) run once per run, and their hashes were equal over the three runs of record (bash 3.2, bash 5, the sealed
  clone) — the run of record's budget, said here rather than hidden. The hook on PostgreSQL "in three JVMs" is three JVMs inside each
  repetition of `stats` (three fresh databases), beside one on H2.
- **The prometheus text over HTTP, from the harness itself.** The prompt said `curl http://127.0.0.1:20490/actuator/prometheus`. The
  harness asks TiffinBox's own web server with the JDK's `java.net.http` client (no proxy, 127.0.0.1) between its windows, so the five
  reads, the scrape, `add` and the second scrape stay in ONE JVM and in order (R.389) without the receipt pausing the JVM; the request is
  the same GET, its status printed.
- **The PostgreSQL driver.** The jar's own: both trees' `lib/` carry `postgresql-42.7.14.jar` since Course 7's capstone (the `anchor`
  capture prints it), so no PostgreSQL line says "+ the harness's driver".
- **The jars gained.** Caffeine's jar and `error_prone_annotations` (Caffeine's own dependency, read off `lib/`); `jspecify`, Caffeine's
  other dependency, was already in unit 08's jar, so it is not gained.
- **The harness's own cache names (R.384).** Only the JVM that carries a harness cache bean (`HarnessCaches`, the `names` step in
  `nonames`) names caches of its own, `--spring.cache.cache-names=customers,h10` on its command line; every other harness JVM on
  `after/` carries no cache of its own and reads the anchor's YAML (`[customers]`, printed). The order of `getCacheNames()` there is the
  manager's (`[h10, customers]`); the check compares the set.
- **The `cleanUp()` contrast was not captured.** The prompt allowed it "measured once, or not said": a run without the same-thread
  executor reads a size that depends on a background thread, which would not hash equal three times; the hazard is therefore not voiced,
  and the `ceiling` harness always runs the same-thread executor and `cleanUp()`.
- **Survivors read as `asMap().keySet()`, sorted** (not `policy().eviction().get().coldest(3)`): the line says so.
- **`totalLoadTime` masked always.** dur8 does not flag `totalLoadTime=0`; it is masked as `totalLoadTime=<masked>` in every capture
  anyway, as the builders mask it (R.388).
- **Six `cache_` lines, not five.** Micrometer's Caffeine binder also writes `cache_eviction_weight_total`; printed, not voiced.
- **Course 2's own deck lines** are quoted as fragments of lines 175 and 178 (the panel's code strings, the terminal line, the chip and the
  SAY), each asserted a substring of its line; the lines themselves carry the deck's markup and are not copied whole. In a clone of the
  repository alone the deck is not beside it, and the receipt says so instead of re-reading.
- **Names**: Emma is the customer `add` stores (English names only, R.215).

## Planted faults — each caught (R.65, R.226)

Each plant was made in Python on a scratch mirror of the repository (this folder copied, every other entry linked; nothing written
here), one change per plant, and the gate named beside it run on the mirror; every plant exited 1 with the line shown, and the four
controls (the shipped prose and three shipped captures) exited 0. The plants on captures are doctored copies of this run's own
`.r-*.out` files, checked by `chk10.py`. The prose plants add one sentence above *Next* (the line number is the mirror's README's).

```markdown
exit 1 "Caffeine is LRU"  |  R.385  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.385: "LRU" / "the same eviction" for Caffeine - the two maps drop different customers ***
exit 1 "the same customer leaves"  |  R.385  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.385: "LRU" / "the same eviction" for Caffeine - the two maps drop different customers ***
exit 1 the meter claimed without cache-names  |  R.384  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.384: a meter sentence without spring.cache.cache-names ***
exit 1 a hit count from the probe's customer cache  |  R.392  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.392: the customer cache (the probe's) - the anchor ships only customers ***
exit 1 cache_puts_total voiced  |  R.375  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.375: cache_puts_total voiced ***
exit 1 "Window TinyLFU"  |  R.385  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.385: Caffeine's policy named - the receipt prints none ***
exit 1 "faster"  |  R.388 / dur8  |  *** a refused word or reading in this unit's prose:   README.md line 308: dur8: faster ***
exit 1 "Spring warns"  |  R.377  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.377: Spring warns - no WARN line is captured for the cache in this unit ***
exit 1 "Spring Data caches"  |  R.348  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.348: the abstraction credited to Spring Data or Hibernate: Spring Data caches ***
exit 1 a typed number  |  R.302  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.302: a capture's number typed in prose: 4 hits ***
exit 1 a typed SQL string  |  R.225/R.365  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.225/R.365: a typed SQL string in the prose ***
exit 1 rm -f without -v  |  R.387  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.387: rm -f without -v ***
exit 1 -pl tiffinbox-web without -am  |  R.391  |  *** a refused word or reading in this unit's prose:   README.md line 308: R.391: -pl tiffinbox-web without -am ***
exit 1 a dish name  |  R.215  |  *** an Indian dish name (R.215: English names only): README.md:308:Ravi orders <the planted dish name>. ***
exit 1 a placeholder line  |  placeholders  |  *** a placeholder in this unit's prose or harness: README.md:308:<the planted placeholder line> ***
exit 1 a Course 2 quote off by one byte  |  R.370  |  *** R.370: README.md's Course 2 quote is not in the deck's line 175 or 178: return size() > 4; ***
exit 1 an R.250 sentence left (its note dropped)  |  R.250 (and after/'s pin)  |  *** R.211: after/'s tree is 53 548bc0722ac6036d0cfcff289165df43, the pin in receipts.md5 is 53 c130857a337850bbcf4789ab36917c2e - the tree moved ***
exit 1 a before link to the wrong target  |  R.211  |  *** R.211: before must be a link to ../c8-unit08/after (it points at: ../c8-unit07/after) ***
exit 1 a container removed without -v  |  R.387  |  *** R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: dk rm -f|dk rm -fv) ***
exit 1 the docker CLI unpinned  |  R.344  |  *** R.344: receipts.sh calls docker without the pinned socket (every call is dk): 125:docker info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that s ***
exit 1 a dk run without --pull never  |  R.344  |  *** R.344: a dk run without --pull never ***
exit 1 a -pl tiffinbox-web build without -am  |  R.391  |  *** R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am ***
exit 1 the exercise built without -am  |  R.391  |  *** R.391: exercise/README.md builds without -pl tiffinbox-web -am ***
exit 1 the exercise's solution = broken  |  R.196  |  *** R.196: SOLUTION.md's block must be the README's with one line changed ***
exit 1 a placeholder in the harness  |  placeholders  |  *** a placeholder in this unit's prose or harness: harness/src/probe/u10/U10.java:28:import java.util.TreeSet; // <the planted placeholder word> ***
exit 1 an R.250 sentence left, its note dropped (chk10 r250 alone)  |  R.250  |  FAIL R.250: its unit 10 note closes the sentence (next line): With no cache library on the class path Boot builds a **`Con
exit 1 hit 5.0 typed into the prometheus line  |  chk10 stats (R.375: prometheus = Caffeine's own)  |  FAIL prometheus's hit/miss/size/evictions = Caffeine's own (H2 2.5.250): {'cache_eviction_weight_total': '0.0', 'cache_evictions_total': '0.0', 'cache_gets_total:hit': '5.0', 'cache_gets_total:miss': 
exit 1 evictionCount=1 typed  |  chk10 stats (one entry, no eviction)  |  FAIL prometheus's hit/miss/size/evictions = Caffeine's own (H2 2.5.250): {'cache_eviction_weight_total': '0.0', 'cache_evictions_total': '0.0', 'cache_gets_total:hit': '4.0', 'cache_gets_total:miss': 
exit 1 the statement counter dropped  |  R.375  |  FAIL 1 line(s) match ^PROBE reads:\ five\ calls\ of\ CustomerRepository\.findAll\(\) \((H2 2\.5\.250|PostgreSQL 18\.6)\): repository calls (\d+) · prepareStatementCount (\d+) · per call \[([0-9, ]+)\]
exit 1 the two counters disagree  |  R.375  |  FAIL R.375: reads: five calls of CustomerRepository.findAll() on H2 2.5.250 - the counter's per-call list [1, 0, 0, 0, 0] = the statement counter's [1, 1, 0, 0, 0]
exit 1 [Sam, Ravi, Nina] typed into Caffeine's line  |  R.385 (chk10 ceiling)  |  FAIL the victims differ: [Meera] vs [Meera]
exit 1 a cache_ line present in nonames  |  R.384 (chk10 nonames)  |  FAIL nonames: the prometheus endpoint 200, 0 cache_ lines (H2 2.5.250)
exit 1 a harness JVM on after/ started without its names  |  R.384 (chk10 nonames)  |  FAIL R.384: the harness JVM on after/ names its own cache beside the anchor's (customers,h10)
exit 1 a version claim without HHH000001  |  chk10 anchor  |  FAIL Hibernate's version = HHH000001's
exit 1 Caffeine's jar name changed  |  chk10 anchor (R.246)  |  FAIL Caffeine's jar among the gained: ['caffeine-3.3.1.jar', 'error_prone_annotations-2.49.0.jar']
exit 1 a version claim on Boot 4.2.0  |  chk10 anchor (R.246)  |  FAIL the version lines (R.246) on H2 2.5.250
exit 1 the exercise's broken state called solved by its exit  |  R.196  |  FAIL R.196: solved - the hit line 4.0
exit 1 a wrong published hash for the seven  |  chk10 seven  |  FAIL the seven on before/ and after/ = Course 7's published md5
exit 0 (control) the shipped prose  |  s810  |  self-test: 44 cases · refused: 0
exit 0 (control) the shipped stats capture  |  chk10  |  VALUES calls 1 statements 1 per call [1, 0, 0, 0, 0] · Caffeine hitCount=4 missCount=1 evictionCount=0 estimatedSize 1, key SimpleKey [] · prometheus hit 4.0 mi
exit 0 (control) the shipped ceiling capture  |  chk10  |  VALUES a harness on Caffeine's own API, not TiffinBox's cache: Bounded.java's sequence, ceiling 3 - LinkedHashMap [Sam, Ravi, Nina] (drops [Meera]) vs Caffeine 
exit 0 (control) the shipped nonames capture  |  chk10  |  VALUES the copy without spring.cache.cache-names: getCacheNames() [] · calls 1 per call [1, 0, 0, 0, 0] · Caffeine hitCount=4 missCount=1 · GET /actuator/promet
```

## For RED

- The ceiling is the harness's, on Caffeine's own API with a same-thread executor: TiffinBox's own cache holds one entry and never reaches
  its ceiling (`stats`: `cache_size 1.0` for the cache named at the start, `evictionCount=0`), so no anchor eviction is voiced. Which customer Caffeine drops on another
  sequence, or with its default executor, is not measured.
- Why Caffeine keeps a different set is not said: the receipt prints no policy (R.385).
- `cache_puts_total`, not voiced, reads 0.0 after a stored read on every database, for the cache named at the start (`stats`); BLUE's
  reading of why (the binder reports Caffeine's loads) is cited as BLUE's, not re-derived here.
- The `nonames` copy and the exercise's broken state are the same derivation (one line removed): what they show is the copy's. With
  the names given, a `@Cacheable` on a name not made at the start throws at the call (H2 only — the manager's choice, not the
  database's); a start that fails on it was not seen and is not said.
- RE-MEASURE 5's open half (Caffeine as the default type after unit 11, with names) is unit 11's receipt.
- The kitchen's readiness detail reads the cached list (unit 08's finding) — unchanged by C2, not re-measured.

<!-- values: begin -->
the values the video may say - exercise: the line 21 words · broken: hitCount=4, the endpoint 200, cache_ lines for customers 0 · solved: the hit line 4.0 · exit 0 both · tests: 18 (mvn -o package, Maven's DOCKER_HOST at nothing) · 18 + 5 (mvn -o verify: H2 in memory + PostgreSQL in containers) · anchor: CacheManager org.springframework.cache.caffeine.CaffeineCacheManager, cache org.springframework.cache.caffeine.CaffeineCache, native com.github.benmanes.caffeine.cache.BoundedLocalCache$BoundedLocalManualCache, names [customers], on H2 2.5.250 and PostgreSQL 18.6; GET /dashboard 200 · /actuator/caches 404 · /actuator/metrics 404; libs 101 -> 103 (+caffeine-3.2.4.jar, error_prone_annotations-2.49.0.jar); Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/JDBC 4.1.2/4.1.2 · HHH000001 7.4.13.Final · Flyway 12.4.0 · Caffeine jar caffeine-3.2.4.jar; Found 1 JPA + Found 1 JDBC · stats: calls 1 statements 1 per call [1, 0, 0, 0, 0] · Caffeine hitCount=4 missCount=1 evictionCount=0 estimatedSize 1, key SimpleKey [] · prometheus hit 4.0 miss 1.0 size 1.0 evictions 0.0 (puts 0.0, not voiced) · the start: stats 0, the entry absent · add(Emma): the next call [1], rows 4 -> 5 (JdbcTemplate; psql), missCount=2, prometheus miss 2.0 · H2 and PostgreSQL x3 the same (hook md5 259f6aa5) · ceiling: a harness on Caffeine's own API, not TiffinBox's cache: Bounded.java's sequence, ceiling 3 - LinkedHashMap [Sam, Ravi, Nina] (drops [Meera]) vs Caffeine [Meera, Nina, Ravi] (drops [Sam], asMap().keySet() sorted), 50 of 50 pairs in one JVM, the same each · nonames: the copy without spring.cache.cache-names: getCacheNames() [] · calls 1 per call [1, 0, 0, 0, 0] · Caffeine hitCount=4 missCount=1 · GET /actuator/prometheus 200 with cache_ lines 0 · exit 0 · log lines naming a cache 0 · ERROR 0 (H2 and PostgreSQL) · names given (customers,h10): getCache("stampede") null · @Cacheable("unnamed") threw java.lang.IllegalArgumentException: Cannot find cache named 'unnamed' (grep 1) · seven: the seven 466c20ed… on before/ and after/ (0 lines differ) · GET /dashboard 200 · Hibernate's script = xcheck.sql
<!-- values: end -->

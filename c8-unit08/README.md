# c8-unit08 — @Cacheable, @CacheEvict, @CachePut

Course 8, Section 2's first unit and **Section 2's first change to the anchor (C1)**. `before` is a link to `../c8-unit07/after`
(Section 1's last tree, the receipt pins it and asserts that pin is unit 07's own after-tree line); `after/` is this unit's tree, and
`../c8-tiffinbox` equals `after/` from this unit's commit on. TiffinBox's customer read gets a cache in front of it: **Spring's cache
abstraction** — Spring Framework's annotations, in `spring-context`, with Boot's `spring-boot-cache` module building the cache manager.
It is not a Spring Data module, and it is not Hibernate's second-level cache. A **hit** is an answer the cache in the JVM already had, and a
**miss** runs the method. With no cache library on the class path Boot builds a `ConcurrentMapCacheManager`: the cache lives in the JVM, a
`ConcurrentMap` — a `ConcurrentHashMap` — per cache name.

Every count below comes from two witnesses in the same run (R.375): **the invocation counter** — a harness `BeanPostProcessor` that adds
a counting `MethodInterceptor` at position 0 of Spring Data JPA's repository proxy for `CustomerEntityRepository`, outside the cached
bean, so it counts exactly the calls a hit in the JVM saves — and **Hibernate's statement counter**, `getPrepareStatementCount()`, Course 7's pinned
counter. A window whose two per-call lists differ fails the run. Both databases answer every counted window: H2 in memory, TiffinBox's
default, and PostgreSQL 18.6 in a container by the capstone's digest, through the config tree's URL and the jar's own driver.

Eight captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `tests` and
`exercise` run once per run and were hashed equal over the three runs of record. Every number and string below is asserted right after
its capture by `harness/chk08.py` against a second witness of the same run (*What differed from the brief*, first item).

## The change, file by file, and every README sentence it rewrote (R.250)

C1 changes three source files and the anchor's README; nothing new, nothing deleted (`chk08.py static`, from the files):

- `tiffinbox-web/pom.xml` — **`spring-boot-starter-cache`**, no version typed (Boot's parent manages it), with a Course 8 comment beside
  it in the form the POM's other starters have. The jar gains two libraries (the `anchor` capture lists them by name).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java` — **`@EnableCaching`** beside `@EnableJpaAuditing`, its import, and
  a "Course 8, unit 08:" paragraph in the class Javadoc.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java` — **`@Cacheable("customers")`** on `findAll()` and
  **`@CacheEvict(cacheNames = "customers", allEntries = true)`** on `add`, above its `@Transactional(rollbackFor = SQLException.class)`;
  a "Course 8, unit 08:" paragraph in the class Javadoc and one in each method's. `tiffinbox-core/pom.xml` is unchanged: it already
  depends on `spring-context`, which holds both annotations. `findAll()`'s body is unchanged — `.toList()` stays (unit 11 owns the
  `ArrayList`); `findByName` and `pausedDaysByCustomer` stay uncached (unit 13 caches `findByName`).
- `README.md` (the anchor's) — a `## Course 8 · unit 08` section in the Section 1 blocks' shape, and five sentences noted in place, each
  in a note that starts *Course 8, unit 08* (`chk08.py r250` asserts each note sits on its sentence's line; a plant that drops one fails):
  1. the header's "Course 8's units are planned to put a number on …" — the cache abstraction is in since;
  2. `c7-unit38`'s section, "**Unchanged:** … the dashboard's four SQL statements." — the customer read among them is cached since;
  3. `c7-unit39`'s section, "… the dashboard's four SQL statements. Nothing is deleted or renamed." — the same;
  4. `c5-unit22`'s section, its `KitchenHealthIndicator` line "UP while the database answers … and DOWN, with the error's class name, when it
     does not" — not while the cache holds the list (the `hits` capture's `health` lines);
  5. `c5-unit22`'s section, "When the database dies … `/customers` 500; `/kitchen` 200, from memory." — measured before the cache.

No YAML key (no `spring.cache.*`: Boot's choice with no provider is the point), no V4, Flyway's V1-V3 untouched, `ddl-auto: validate`
untouched; Hibernate's schema script is Course 7's capstone's, byte for byte (`xcheck.sql` = `../c7-unit39/xcheck.sql`, the `seven`
capture). What `src/main` did not change is in *For RED*: `KitchenHealthIndicator`'s own Javadoc still says "UP while the database
answers" (the brief's four-file change; the anchor README's note carries the measured reading).

The pins, hashed by `harness/tree08.py` and asserted at the start and the end of every run:

```markdown
before/'s pin = ../c8-unit07/receipts.md5's after-tree line (53 f16230d480e6bf37f47cc98ad6d44c28), re-derived by harness/tree08.py
```

## The captures — what each one shows

### 1 · anchor — the change, on both databases (C1)

`after/` started on H2 in memory and on PostgreSQL 18.6, one JVM each, with no web server. Strict repository configuration mode and
both modules' `Found` lines come off the log; the cache manager, the beans' classes and their advisor lists off the running context.
`CustomerRepository` was a CGLIB subclass already — for `@Transactional`, since `c7-unit26` — and now carries a second advisor, the cache's.
Spring Data JPA's repository proxy shows the counter at position 0 (its advisor list is printed, not interpreted: no order between the
cache's and the transaction's interceptors is claimed beyond what the list prints).

```text
gained: spring-boot-cache-4.1.2.jar
gained: spring-context-support-7.0.10.jar
log: Multiple Spring Data modules found, entering strict repository configuration mode
log: Found 1 JPA repository interface
log: Found 1 JDBC repository interface
log: HHH000001: Hibernate ORM core version 7.4.13.Final
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data JDBC 4.1.2 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.concurrent.ConcurrentMapCacheManager] (H2 2.5.250)
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.concurrent.ConcurrentMapCacheManager] (PostgreSQL 18.6)
PROBE CustomerRepository's bean class: com.tiffinbox.CustomerRepository$$SpringCGLIB$$0 · advisors 2 [BeanFactoryCacheOperationSourceAdvisor(org.springframework.cache.interceptor.CacheInterceptor), BeanFactoryTransactionAttributeSourceAdvisor(org.springframework.transaction.interceptor.TransactionInterceptor)]
PROBE CustomerEntityRepository's bean: a Spring AOP proxy (Advised) · the counter installed: yes, on bean 'customerEntityRepository', at advice position 0 of 8
```

The jar's own PostgreSQL driver is in `lib/` on both trees (Course 7's capstone put it there): every PostgreSQL line in this unit ran on
the jar's own driver, not on one the harness added (*What differed from the brief*).

### 2 · hits — the hit in the JVM, A/B/A′, the start's own read first (R.375, RE-MEASURE 1)

Each JVM prints the start's own read in its own window first: `TiffinBoxServer.start()` runs at `@PostConstruct`, before caching is
live, so it reaches the repository and sends its statement, and the cache is still empty when the application is up — the first counted
call is a miss. **A** is `before/` (no cache), **B** is `after/`, **A′** is `cacheManager.getCache("customers").clear()` on `after/`, then
two more calls. The rows are V2's customers, read back by `psql` on PostgreSQL and counted against V2's seed lines.

```text
PROBE the start's own read (TiffinBoxServer.start(), @PostConstruct), its own window, from the context's first statement to here (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · cache names [] (no customers cache yet)
PROBE hits: five calls of CustomerRepository.findAll() (PostgreSQL 18.6): repository calls 5 · prepareStatementCount 5 · per call [1, 1, 1, 1, 1] and [1, 1, 1, 1, 1] · rows 4
PROBE hits: five calls of CustomerRepository.findAll() (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE hits: five calls of CustomerRepository.findAll(): the two witnesses' per-call lists equal · customers cache entries 1 [org.springframework.cache.interceptor.SimpleKey = SimpleKey []]
PROBE clear: cacheManager.getCache("customers").clear() · then customers cache entries 0 []
PROBE clear: the next two calls (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · rows 4
PROBE hits: five calls of CustomerRepository.findAll() (H2 2.5.250): repository calls 5 · prepareStatementCount 5 · per call [1, 1, 1, 1, 1] and [1, 1, 1, 1, 1] · rows 4
PROBE hits: five calls of CustomerRepository.findAll() (H2 2.5.250): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE clear: the next two calls (H2 2.5.250): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · rows 4
```

The same window on both databases gives the same lists (`chk08.py hits` asserts it). The cache holds one entry, under the key of a call
with no argument, `SimpleKey []`; the list is held in the JVM, in the `ConcurrentHashMap` the `ConcurrentMapCache` keeps.

**The kitchen, with the table gone** (the last step of the same JVMs; the R.250 notes 4 and 5): a `JdbcTemplate` renames the customer
table away. On `before/` the kitchen's health answers DOWN on the next call; on `after/` it stays UP with the cached list's count,
and answers DOWN only once the cache is cleared — on H2 and on PostgreSQL alike:

```text
PROBE health (PostgreSQL 18.6): JdbcTemplate: alter table customer rename to customer_gone - then the kitchen, no CacheManager bean: DOWN {error=InvalidDataAccessResourceUsageException}
PROBE health (PostgreSQL 18.6): JdbcTemplate: alter table customer rename to customer_gone - then the kitchen, customers cache entries 1 [org.springframework.cache.interceptor.SimpleKey = SimpleKey []]: UP {customers=4, ordersCooked=120}
PROBE health (PostgreSQL 18.6): the customers cache cleared - then the kitchen, customers cache entries 0 []: DOWN {error=InvalidDataAccessResourceUsageException}
```

### 3 · evict — `@CacheEvict(allEntries = true)` on `add`, and the commit (RE-MEASURE 2)

One call fills the cache; `add(Emma)` empties it; the next call reaches the repository and returns the new row, the one after does not.
The rows are read back by a second client: a `JdbcTemplate` on the `DataSource`'s own connection in the JVM (not through the cache), and
`psql` on PostgreSQL after the JVM stopped.

Then **RE-MEASURE 2**, on the shipped tree: a listener on `CustomerAdded` (which `add` publishes inside its transaction) prints the cache
inside the transaction, and registers a callback that runs after the commit, while `add` has not yet returned: there a second thread
calls `findAll()`. On both databases, in every run, the cache still held the old list after the commit — the second thread was answered
from the cache in the JVM with one row fewer than the table held — and the entry was gone once `add` returned. The evict runs after the
commit, and between the two a read is served the old list.

```text
PROBE evict: add(Emma) (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · then customers cache entries 0 []
PROBE evict: the next two calls (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · rows 5
PROBE evict: rows by JdbcTemplate (the second client) 5
PROBE order (PostgreSQL 18.6): inside add's transaction (a listener on CustomerAdded): transaction active true · customers cache entries 1 [org.springframework.cache.interceptor.SimpleKey = SimpleKey []]
PROBE order (PostgreSQL 18.6): after the commit, add not yet returned (afterCommit): customers cache entries 1 [org.springframework.cache.interceptor.SimpleKey = SimpleKey []] · rows by JdbcTemplate 6 · a second thread's findAll() there: rows 5 · repository calls 0 · prepareStatementCount 0
PROBE order (PostgreSQL 18.6): after add returned: customers cache entries 0 []
psql (a second client, PostgreSQL) after the JVM stopped: customers 6 · Emma, Oliver
```

### 4 · put — `@CachePut`, on a harness bean, not the anchor's cache (R.392)

The anchor has no update method, and `@CachePut` on the `void add` would store null, so `@CachePut` lives in the harness:
`HarnessPuts.Customers`, a second source beside `TiffinBoxApp`, with `@CachePut(cacheNames = "customer", key = "#c.name()")` on `put` and
`@Cacheable(cacheNames = "customer", key = "#name")` on `byName`, whose body asks the anchor's repository. On H2 in memory (enough here:
nothing in it reaches the database). Three puts run the method three times — it always runs — and the cache holds the last value; the
read on the same cache and key runs nothing and sends nothing, and answers the put's value, which is not the row a second client reads.
On `08/after` the `ConcurrentMapCacheManager` makes a cache on request, so the harness's cache name needs no `spring.cache.cache-names`;
from `10/after` on every harness names its own (R.384).

```text
PROBE put: three @CachePut calls (H2 2.5.250): its method ran 3 · repository calls 0 · prepareStatementCount 0 · the customer cache (org.springframework.cache.concurrent.ConcurrentMapCache, native java.util.concurrent.ConcurrentHashMap) holds {Ravi=Customer[name=Ravi, mealsPerDay=3, pricePerMeal=120, mealType=VEG]}
PROBE put: then @Cacheable byName("Ravi") on the same cache and key (H2 2.5.250): its method ran 0 · repository calls 0 · prepareStatementCount 0 · returned Customer[name=Ravi, mealsPerDay=3, pricePerMeal=120, mealType=VEG]
PROBE put: the anchor's database row for Ravi by JdbcTemplate: meals_per_day 2
```

### 5 · off — `@EnableCaching` removed: the failure receipt (R.377)

A copy of `after/` with `@EnableCaching` and its import line removed (`harness/variants.py`, derived from the shipped file at run time).
No cache manager; `CustomerRepository` still a CGLIB subclass, for `@Transactional` alone; every call reaches the repository; exit 0;
no exception; and no log line naming a cache — the only WARN line is Flyway's H2 version line, which `after/` prints too:

```text
PROBE CacheManager beans 0 [] (PostgreSQL 18.6)
PROBE CustomerRepository's bean class: com.tiffinbox.CustomerRepository$$SpringCGLIB$$0 · advisors 1 [BeanFactoryTransactionAttributeSourceAdvisor(org.springframework.transaction.interceptor.TransactionInterceptor)]
PROBE hits: five calls of CustomerRepository.findAll() (PostgreSQL 18.6): repository calls 5 · prepareStatementCount 5 · per call [1, 1, 1, 1, 1] and [1, 1, 1, 1, 1] · rows 4
exit 0 · its log, every line but the harness's own PROBE lines: lines naming a cache (case-insensitive) 0 · WARN 0 · ERROR 0
```

The annotations do nothing without the switch, and nothing says so. The run's exit is not the check; the two counters are.

### 6 · tests — without Docker, then with it (R.363, RE-MEASURE 3)

`mvn -o package` with Maven's `DOCKER_HOST` pointed at nothing, then `mvn -o verify` on the pinned socket (Ryuk off), both on a copy of
`after/`, `-pl tiffinbox-web -am`. The tests are unchanged and none was added; Surefire's XML per report folder against Maven's Results
lines:

```text
in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
in all: 2 reports · tests 5 · failures 0 · errors 0 · skipped 0
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
tiffinbox-web/target/surefire-reports-it: absent - no container test ran
```

### 7 · seven — the comparison set on before/ and after/ (R.363)

`../c5-unit11/curlset.sh` on each tree's jar, H2 in memory, `after/` on 20470 and `before/` on 20473. The kitchen's health detail and the
list route read the cached `findAll` on `after/`; every write goes through `add`. The hash is `c7-unit31`'s published one, unchanged, and
Hibernate's schema script is `xcheck.sql`:

```text
GET /dashboard: 200
the seven, after/ against before/: lines that differ: 0
exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
```

### 8 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`'s block, then `exercise/SOLUTION.md`'s, in one `env -i` shell — bash, then `/bin/zsh -f`. The broken state is
`after/` without `@EnableCaching` (the `off` copy's derivation); the solution keeps it. The check is the two counters, never the exit:

```text
@EnableCaching lines in TiffinBoxApp.java: 0
@EnableCaching lines in TiffinBoxApp.java: 1
TiffinBox: exit 0
repository calls 5 · prepareStatementCount 5 · per call [1, 1, 1, 1, 1] and [1, 1, 1, 1, 1]
repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0]
```

The viewer runs the block from `c8-unit08/` with this folder's `.m2-demo` in place: one offline Maven build of the copied tree, the
harness compiled against its jar, one JVM on H2 in memory. No time is stated for any of it.

## Which store, which manager

Every caching line in this unit names its store: **in the JVM, a `ConcurrentMap`** — the `ConcurrentMapCacheManager` Boot builds, its
caches `ConcurrentMapCache`, each over a `java.util.concurrent.ConcurrentHashMap` — on H2 in memory and on PostgreSQL 18.6 alike (the
database answers the miss; the cache answers the hit, in the JVM). Caffeine (unit 10) and Redis (unit 11) are not on this class path, and
nothing here is said for them.

## Refused, named

- A slogan for a hit, with one witness: every hit here, in the JVM's `ConcurrentMap`, is the two counters per call, from one run (R.375).
- The abstraction credited to Spring Data or Hibernate: it is `spring-context`'s annotations and Boot's `spring-boot-cache` module
  (R.348, C8-16).
- A log line claimed for a missing `@EnableCaching`: the `off` capture prints no log line naming a cache (R.377).
- The dashboard "cached": its four reads are four windows; only the customer read is cached (R.389).
- A time for anything: no duration word, and every duration the logs print is masked (R.388, R.366).
- A number from the harness's `@CachePut` bean voiced as the anchor's: the `put` capture is labelled the harness's (R.392).

## Call-backs, by title (R.224)

- Course 7's *The Second-Level Cache* (`java7_series.TITLES["32"]`): Hibernate's own cache, inside the persistence layer. This unit's is
  not that one: Spring's abstraction sits in front of a method, above Hibernate, and caches what the method returned. **C8-16 paid.**
- Course 7's *N+1, Measured* (`java7_series.TITLES["30"]`): its pinned counter, called back byte for byte from `../c7-unit30/pinned.txt`,
  its third line — **C8-9 called back**:

```markdown
SessionFactory.getStatistics().getPrepareStatementCount()
```

- Course 8's *Testing the JDBC Layer* (`java8_series.TITLES["07"]`): Section 1's last tree, this unit's `before`.
- Next: *The Cache Abstraction's Machinery* (unit 09) measures on this tree; *Caffeine* (unit 10) moves the anchor next.

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged: TiffinBox still starts on H2 in memory with nothing installed.

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s2` (it holds the cache starter, `spring-boot-cache`
and `spring-context-support`); every build reads it offline (`-o`, `maven.repo.local` as an absolute path) and the receipt asserts its
file count unchanged after every Maven run. Docker: the pinned socket on every call, the PostgreSQL image by its digest, `--pull never`,
no image pulled (the image list is asserted unchanged), the volume count asserted unchanged at the end. Nothing in this unit touched the
network.

## The folders, the harness and the ports

- `harness/src/probe/u08/U8.java` — the harness program (steps `info`, `hits`, `clear`, `evict`, `order`, `health`, `put`);
  `Counter.java` — witness 1; `HarnessPuts.java` — the `put` capture's bean. `harness/src/probe/x/XMain.java` — `c7-unit29`'s schema
  probe, byte for byte.
- `harness/chk08.py` (the checks), `harness/s808.py` (the prose gate, its self-test first), `harness/tree08.py` (the pins),
  `harness/variants.py` (the `off` copy), `harness/surefire.py` and `harness/dur8.py` (unit 02's, byte for byte), `harness/logback.xml`
  (unit 07's, byte for byte).
- Ports: 20470 TiffinBox `after/` for the seven · 20471 the PostgreSQL container · 20472 never bound (the `off` copy's JVMs start no web
  server) · 20473 TiffinBox `before/` for the seven · 20474-20479 never bound. All ten are asserted free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masked: this folder and the repository's paths, the home, the user name, Boot's `Started … in <t>`, Surefire's `Time elapsed`, Flyway's
`execution time`, Spring Data's `scanning in <t>`, `initialization completed in <t>`, Testcontainers' `started in PT<t>S`, Maven's `Total
time`, `using Java <version>`, object hashes. Filtered: Maven's own lines (the captures print the exit, the BUILD line, the offline check
and Surefire's reports); the harness JVM's log down to the strict-mode line, the `Found` lines, `HHH000001`, Flyway's `Database` line
(its port and database name masked; Flyway masks the password itself) and the WARN lines. The PostgreSQL password and the shutdown
token are generated per run, 0600, and asserted absent from every capture.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM, Maven, the exercise's shell), removes its container
with its volume (`rm -fv`) and any Testcontainers container, deletes the partial captures, and exits 130. Measured 2026-11-18 on this
folder, the script started with SIGINT at its default and the signal sent to its pid at five points — mid-build (Maven building the
trees), mid-container (the container up, the exercise's shell running), mid-verify (Testcontainers' container tests running),
mid-harness (a harness JVM on H2) and mid-JVM on PostgreSQL — each looked at twice, the second look a few beats later:

```markdown
exit 130 at each of the five points; at each look: java 0 · mvn 0 · c8u08-pg 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20470-20479 0 · .r-lock absent · partial .r-*.[123] 0 · captures unchanged
```

## The ledger rows this unit pays

- **C8-16** paid: this is the lesson Course 7's *The Second-Level Cache* named — not Hibernate's second-level cache, not Spring Data:
  `spring-context`'s annotations, Boot's `spring-boot-cache` module.
- **C8-9** called back: `getPrepareStatementCount()` beside the invocation counter in every counted window.

## RE-MEASURE — the brief's items this unit settles

1. The counter equals the statements per call on the shipped tree, H2 and PostgreSQL: settled (`hits`, `evict`, `off`, `exercise`).
2. The evict against the commit, on the shipped tree's advisor order: captured on every run, both databases — the evict runs after the
   commit (`evict`).
3. The tests and the seven with `findAll` cached: unchanged (`tests`, `seven`).
13. The dashboard's statements: not measured as a page; only the customer read is counted here.

## The anchor moved on — the builders (R.211, R.331)

Before the commit, the grep the brief names over `_builders/s80*.py` and the three tools found **no shipped builder that reads
`c8-tiffinbox` or any of the four changed files as an input**: the seven builders read `c8-unitNN/` paths pinned to their evidence commits,
and each one's `c8-tiffinbox` mention is the R.211 live compare, a note behind an existence check, never a stop. `check_unit8.py`,
`qa_java8.py` and `build_java8.py` name none of them.

## The four notes the brief sends here (RED-S1-SCRIPTS #103, #120, #137, #240)

Each file is read live by a shipped receipt, so none is edited; each line is quoted byte for byte below (R.370), and the receipt asserts
the four files' md5s unchanged and each quote equal to its line:

- `c8-unit01/README.md`, line 139:

```markdown
Spring Data JDBC: the anchor without it does not start. (This differs from the brief's wording — see *What differed from the brief*.)
```

  Note: what does not start is a copy of the anchor with Spring Data JPA's starter removed, never the anchor itself.
- `c8-unit02/exercise/README.md`, line 3:

```markdown
**Your turn:** TiffinBox's second repository refuses to start. Rename one interface so both Spring Data modules register their repositories.
```

  Note: TiffinBox itself refuses to start with its second repository — the application, not the repository (`APPLICATION FAILED TO START`).
- `c8-unit04/exercise/README.md`, line 3:

```markdown
**Your turn:** looking up a customer who does not exist crashes the route. Return an empty result instead, using JdbcClient.
```

  Note: it crashes the lookup — the exercise is a main program, and no route is run.
- `c8-unit07/README.md`, line 7:

```markdown
TiffinBox gains a test that starts only its JDBC layer: Spring Data JDBC's test slice, `@DataJdbcTest`, started from a configuration
```

  Note: `@DataJdbcTest` is Spring Boot's slice for Spring Data JDBC (`spring-boot-starter-data-jdbc-test`); `@EnableJdbcRepositories` is
  Spring Data JDBC's.

```text
../c8-unit01/README.md: md5 48e9f0d84059e6c22730d32cc904efec = receipts.md5's note:c8-unit01/README.md line (unchanged; its note is in README.md, line 139 quoted byte for byte)
../c8-unit02/exercise/README.md: md5 bbc1ce32f3cc4625b6df004100ab0b2d = receipts.md5's note:c8-unit02/exercise/README.md line (unchanged; its note is in README.md, line 3 quoted byte for byte)
../c8-unit04/exercise/README.md: md5 69ea1c83ba8b12832c528f2dfd2d796d = receipts.md5's note:c8-unit04/exercise/README.md line (unchanged; its note is in README.md, line 3 quoted byte for byte)
../c8-unit07/README.md: md5 32a886c92862629b504134860e25f1d0 = receipts.md5's note:c8-unit07/README.md line (unchanged; its note is in README.md, line 7 quoted byte for byte)
```

## Next

Unit 10 moves the anchor next (Caffeine); `findByName` stays uncached until unit 13. Unit 09 measures on this tree, through copies.

## What differed from the brief

- **3/3.** The JVM captures (`anchor`, `hits`, `evict`, `put`, `off`, `seven`) run three times inside every run and hash equal; `tests`
  and `exercise` (Maven builds) run once per run, and their hashes were equal over the three runs of record (bash 3.2, bash 5, the sealed
  clone) — the run of record's budget, said here rather than hidden.
- **The PostgreSQL driver.** The prompt asked for "the harness's driver from `.m2-demo`" and `after/`'s `lib/` asserted to hold no
  `postgresql-*.jar`. Both trees' jars carry `postgresql-42.7.14.jar` since Course 7's capstone (its POM, runtime scope); every PostgreSQL
  run here used the jar's own driver, and the `anchor` capture prints it on both trees.
- **The kitchen** (`health` lines, added to `hits`): the hunt for R.250 sentences found two the cache makes false that the brief did not
  list — the kitchen's UP-while-the-database-answers lines — so the receipt measures them, on a renamed table (a stand-in for a database
  that stops answering, on H2 and PostgreSQL), and the anchor README notes them. `KitchenHealthIndicator.java`'s Javadoc is not edited
  (the brief's change is four files): *For RED*.
- **The evict** fills the cache with one call first (the brief's beat), and the RE-MEASURE 2 window is its own step (`order`, a second
  `add`, of Oliver), so the evict's own counts are not mixed with the listener's read.
- **The PostgreSQL user** has a generated password (an `--env-file`, 0600) rather than trust on loopback.
- **Names**: Emma and Oliver are the customers `add` stores; Ravi is V2's, used by the harness's `put`.

## Planted faults — each caught (R.65, R.226)

Each plant was made in Python on a scratch mirror of the repository (nothing written here), one change per plant, and the gate named beside it
run on the mirror; every plant exited 1 with the line shown, and the three controls (the shipped prose, the shipped `hits` capture, the
shipped What-it-prints comparison) exited 0. The plants on captures are doctored copies of this run's own `.r-*.out` files.

```markdown
exit 1 "the cache works" with one witness  |  R.375  |  *** a refused word or reading in this unit's prose:  |  README.md line 210: R.375: "the cache works" - a hit is two witnesses from one run, never a slogan ***
exit 1 "Spring Data caches"  |  the family (R.348)  |  *** a refused word or reading in this unit's prose:  |  README.md line 210: R.348 / C8-16: the abstraction credited to Spring Data or Hibernate: Spring Data caches ***
exit 1 "faster"  |  R.388 / dur8  |  *** a refused word or reading in this unit's prose:  |  README.md line 210: dur8: faster ***
exit 1 a dish name  |  R.215  |  *** an Indian dish name (R.215: English names only): README.md:210:Ravi orders <the planted dish name>. ***
exit 1 a placeholder line  |  placeholders  |  *** a placeholder in this unit's prose or harness: README.md:210: <the planted placeholder line> ***
exit 1 a typed SQL string  |  R.225/R.365  |  *** a refused word or reading in this unit's prose:  |  README.md line 210: R.225/R.365: a typed SQL string in the prose ***
exit 1 a changed What-it-prints line  |  the What-it-prints comparison  |  *** exercise/SOLUTION.md's What it prints block is not what its lines printed (receipts.sh's own comparison) ***
exit 1 the exercise's solution = broken  |  R.196  |  *** R.196: SOLUTION.md's block must be the README's with one line changed ***
exit 1 a before link to the wrong target  |  R.211  |  *** R.211: before must be a link to ../c8-unit07/after (it points at: ../c8-unit02/after) ***
exit 1 a container removed without -v  |  R.322/R.387  |  *** R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: dk rm -f|dk rm -fv) ***
exit 1 the docker CLI unpinned  |  R.344  |  *** R.344: receipts.sh calls docker without the pinned socket (every call is dk): 118:docker info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine run
exit 1 a dk run without --pull never  |  R.344  |  *** R.344: a dk run without --pull never ***
exit 1 a -pl tiffinbox-web build without -am  |  R.391  |  *** R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am ***
exit 1 the exercise built without -am  |  R.391  |  *** R.391: exercise/README.md builds without -pl tiffinbox-web -am ***
exit 1 an R.250 sentence left (its note dropped)  |  R.250  |  FAIL R.250: its unit 08 note sits on its line: liveness 200, **readiness 503**; `/customers` 500; `/kitchen
exit 1 one of the four flag-11 files changed  |  its md5 (R.370)  |  *** the note's file ../c8-unit04/exercise/README.md moved: md5 a71ab856184763f3c7351dd7e8c77d80, receipts.md5 69ea1c83ba8b12832c528f2dfd2d796d - its note goes in this R
exit 1 a version claim without HHH000001 (a doctored capture)  |  chk08 anchor  |  FAIL HHH000001 7.4.13.Final (H2 2.5.250)
exit 1 a version claim on Boot 4.2.0 (a doctored capture)  |  chk08 anchor (R.246)  |  FAIL the version lines (R.246) on H2 2.5.250
exit 1 the statement counter dropped (a doctored capture)  |  R.375  |  FAIL 1 line(s) match ^PROBE hits:\ five\ calls\ of\ CustomerRepository\.findAll\(\) \((H2 2\.5\.250|PostgreSQL 18\.6)\): repository calls (\d+) · prepareStatementCount (\
exit 1 the two counters disagree (a doctored capture)  |  R.375  |  FAIL R.375: hits: five calls of CustomerRepository.findAll() on H2 2.5.250 - the counter's per-call list [1, 0, 0, 0, 0] = the statement counter's [1, 1, 0, 0, 0]
exit 1 @EnableCaching absent and the run called green (a doctored capture: B = 5/5, exit 0)  |  R.377 (the counter, not the exit)  |  FAIL B (after/, H2 2.5.250): per call [1, 0, 0, 0, 0]
exit 1 the exercise's broken state called solved by its exit (a doctored capture)  |  R.196  |  FAIL R.196: solved - the two counters per call [1, 0, 0, 0, 0]
exit 1 a wrong published hash for the seven (a doctored capture)  |  chk08 seven  |  FAIL the seven on before/ and after/ = Course 7's published md5
exit 0 (control) the shipped prose  |  s808  |  self-test: 33 cases · refused: 0
exit 0 (control) the shipped hits capture  |  chk08  |  VALUES A before/ calls 5 statements 5 per call [1, 1, 1, 1, 1] (H2 and PostgreSQL alike) · B after/ calls 1 statements 1 per call [1, 0, 0, 0, 0] · A' clear() then [1, 0]
exit 0 (control) the shipped What-it-prints comparison  |  receipts.sh's  |  
```

## For RED

- The kitchen: on `after/` the readiness group's `kitchen` indicator reports the cached list's count while the cache holds it, and stays
  UP with the customer table gone (`hits`, `health` lines, both databases). `KitchenHealthIndicator`'s Javadoc and `application.yaml`'s
  readiness comment ("DOWN when the database does not answer") are not edited by C1. Not measured: the routes over HTTP, readiness's 503,
  a real database outage.
- RE-MEASURE 2's reading is one tree's: the advisor list prints the cache's advisor first, the transaction's second, and the evict landed
  after the commit in every run; no claim about why the order is so.
- The dashboard's statements (RE-MEASURE 13) are not measured: no page count is voiced.

<!-- values: begin -->
the values the video may say - exercise: the line 20 words · broken 5/5 per call [1, 1, 1, 1, 1] · solved 1/1 per call [1, 0, 0, 0, 0] · exit 0 both · tests: 18 (mvn -o package, Maven's DOCKER_HOST at nothing) · 18 + 5 (mvn -o verify: H2 in memory + PostgreSQL in containers) · anchor: CacheManager org.springframework.cache.concurrent.ConcurrentMapCacheManager on H2 2.5.250 and PostgreSQL 18.6; libs 99 -> 101 (+spring-boot-cache-4.1.2.jar, spring-context-support-7.0.10.jar); Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/JDBC 4.1.2/4.1.2 · HHH000001 7.4.13.Final · Flyway 12.4.0; Found 1 JPA + Found 1 JDBC · hits: A before/ calls 5 statements 5 per call [1, 1, 1, 1, 1] (H2 and PostgreSQL alike) · B after/ calls 1 statements 1 per call [1, 0, 0, 0, 0] · A' clear() then [1, 0] · the start's read 1 calls / 1 statements, the cache empty · rows 4 · the kitchen with the table renamed: before/ DOWN {error=InvalidDataAccessResourceUsageException}; after/ UP {customers=4, ordersCooked=120}, cleared DOWN {error=InvalidDataAccessResourceUsageException} · evict: rows 4 -> 5 (JdbcTemplate; psql on PostgreSQL) · add: calls 1 statements 1 · the next two calls [1, 0] and [1, 0] · RE-MEASURE 2: after the commit, before add returned, the cache still held the list - a second thread read 5 rows while the table held 6, on both databases · put: a harness bean, not the anchor's cache: @CachePut ran 3 of 3 · the @Cacheable read on the same key ran 0, repository calls 0, statements 0, answered meals 3 (the row by JdbcTemplate: 2) - H2 · off: CacheManager beans 0 · CustomerRepository still CGLIB (TransactionInterceptor alone) · calls 5 statements 5 per call [1, 1, 1, 1, 1] · exit 0 · log lines naming a cache 0 · ERROR 0 (H2 and PostgreSQL) · seven: the seven 466c20ed… on before/ and after/ (0 lines differ) · GET /dashboard 200 · Hibernate's script = xcheck.sql
<!-- values: end -->

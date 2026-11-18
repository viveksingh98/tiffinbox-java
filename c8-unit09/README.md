# c8-unit09 — The Cache Abstraction's Machinery

Course 8, Section 2, unit 09 — **a harness unit: no anchor change.** Behind unit 08's annotations sit three pieces of machinery, and
this unit measures each one on unit 08's tree: the `CacheManager` Spring Boot picks from the class path (and from `spring.cache.type`),
the key the cache abstraction builds from a call's arguments, and the proxy that puts the cache in front of a bean — so a call from
inside the object walks around it: **the self-invocation trap, a third time**, after Course 4's *JDK Proxies vs CGLIB, and the
Self-Invocation Trap* and Course 7's *@Transactional: What the Proxy Does*.

A **cache key** is the value the cache files an answer under: a call whose key is already in the cache gets that answer back, and the
method does not run. With no key named, the key is built from the arguments alone — the method's name is not in it.

- `anchor` → `../c8-unit08/after` (a link: the tree unit 08 froze, `@EnableCaching` on `TiffinBoxApp`, `@Cacheable("customers")` on
  `CustomerRepository.findAll()`, `@CacheEvict` on `add`; `../c8-tiffinbox` equals it today, `diff -rq` empty, printed by every run).
  `harness/tree09.py` pins its tree in `receipts.md5`'s `anchor-tree` line, written from a run's own output, and every run asserts that
  pin equal to `../c8-unit08/receipts.md5`'s own `after-tree` line.
- Every cache measured here is **a harness bean's, not the anchor's cache** (R.392): `H09.Reads` and its caches `h09:all`, `h09:pkg`,
  `h09:priv`, `h09:keys`, and two more beans, each started only by its own step (`H09Final`, `FinalOne`). The anchor's own `customers`
  cache is not called by any window. The class paths with Caffeine or Redis are **copies** of the anchor's tree, derived at run time by
  `harness/variants.py` and asserted to differ from it in `tiffinbox-web/pom.xml` alone; none of them is the anchor.
- Every count comes from two witnesses in one run (R.375): `Counter` — unit 08's `harness/src/probe/u08/Counter.java`, copied with its
  package line alone changed (the receipt asserts the diff), a counting `MethodInterceptor` at position 0 of Spring Data JPA's proxy for
  `CustomerEntityRepository` — and Hibernate's `getPrepareStatementCount()`. Every cached method's body reads the database once through
  that repository (`count()`), so a call that runs its method moves both counters by one, and a call the cache answers moves neither.
  A window whose two per-call lists differ fails the run.

Five captures. The JVM captures (`managers`, `keys`, `proxy`, `finalclass`) run three times inside each run of `receipts.sh` and are
hashed (`receipts.md5`); `exercise` runs once per run and was hashed equal over the three runs of record. Every number and string below
is asserted right after its capture by `harness/chk09.py` against a second witness of the same run.

## No change to the anchor (⚑8) — the tree measured is `../c8-unit08/after`, pinned

Unit 09 changes nothing in `c8-tiffinbox` (the brief's ⚑8: "U09 changes nothing (harness copies per classpath)"). No builder grep is
owed (no anchor path changes) and no test re-run is owed (R.363 binds anchor changes); the anchor's tree is built from its own
sources in every run (`-pl tiffinbox-web -am`), and both modules' `Found 1 …` lines come off every harness start. The pins:

```markdown
anchor's pin = ../c8-unit08/receipts.md5's after-tree line (53 eedf32a336609f92de214f7beba6d2ec), re-derived by harness/tree09.py
anchor/ against ../c8-tiffinbox: diff -rq empty - the anchor today
```

## The captures — what each one shows

### 1 · managers — the manager Boot picks, per class path and per setting (S8.36, R.384)

Seven harness JVMs, all on H2 in memory: the manager is the class path's choice and the setting's, not the database's, so one database
is enough here. (1) is the anchor itself, the cache starter alone; (2), (3) and (4) are copies of it with Caffeine, with Spring Data
Redis's starter, and with both (each copy's `pom.xml` diff and the jars it gained are printed by the capture); (5) is the both-copy
started three times with `spring.cache.type` set. Each JVM prints the setting it read back, the `CacheManager` bean, the cache it hands
out for `h09:all` and that cache's native store. Where Spring Data Redis is on the class path, Redis is the container by the digest on
127.0.0.1:20482, and the JVM's own connection answers `PING` and reads Redis's version, which `redis-cli` reads too:

```text
PROBE spring.cache.type: unset
PROBE managers: the CacheManager bean org.springframework.cache.concurrent.ConcurrentMapCacheManager · getCache("h09:all") org.springframework.cache.concurrent.ConcurrentMapCache · its native cache java.util.concurrent.ConcurrentHashMap
PROBE managers: the CacheManager bean org.springframework.cache.caffeine.CaffeineCacheManager · getCache("h09:all") org.springframework.cache.caffeine.CaffeineCache · its native cache com.github.benmanes.caffeine.cache.UnboundedLocalCache$UnboundedLocalManualCache
PROBE managers: the CacheManager bean org.springframework.data.redis.cache.RedisCacheManager · getCache("h09:all") org.springframework.data.redis.cache.RedisCache · its native cache org.springframework.data.redis.cache.DefaultRedisCacheWriter
PROBE managers: Spring Data Redis on the class path: yes · its connection factory org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory · 127.0.0.1:20482 · PING -> PONG · INFO server: redis_version 8.10.3
log: Found 0 Redis repository interfaces
PROBE spring.cache.type: none
PROBE managers: the CacheManager bean org.springframework.cache.support.NoOpCacheManager · getCache("h09:all") org.springframework.cache.support.NoOpCache · its native cache org.springframework.cache.support.NoOpCache
PROBE managers: all() three times through NoOpCacheManager (H2 2.5.250): repository calls 3 · prepareStatementCount 3 · per call [1, 1, 1] and [1, 1, 1] · returned [all:4, all:4, all:4]
PROBE managers: all() three times through ConcurrentMapCacheManager (H2 2.5.250): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0] and [1, 0, 0] · returned [all:4, all:4, all:4]
```

Read per run (the values block below lists all seven): the cache starter alone gives `ConcurrentMapCacheManager` — in the JVM, a
`ConcurrentMap`; with Caffeine on the class path, `CaffeineCacheManager` — in the JVM, Caffeine; with Spring Data Redis's starter,
`RedisCacheManager` — Redis, by the digest. **With both on the class path and `spring.cache.type` unset, the manager printed is
`RedisCacheManager`**: Redis's, silently — no log line names the choice. On the both-copy, `spring.cache.type=caffeine` gives the
Caffeine copy's manager, `=simple` the anchor's `ConcurrentMapCacheManager`, and `=none` gives `NoOpCacheManager`, whose cache is never
asked: on that setting the harness copy's three calls all run their method, both counters say so. With Redis on the class path the
strict-mode lines gain a third module, Spring Data Redis, which finds no repository of its own. This is Course 5's *Auto-Configuration,
Mechanism First*, read off a run: Boot's cache auto-configuration builds one manager, from what the class path holds, unless the setting
names one.

No counted window runs on Redis's manager here: the cache writer Boot builds over Lettuce is unit 11's measured receipt, and nothing in
this unit is said for it. The harness's cache name `h09:all` needs no `spring.cache.cache-names` on these copies — each manager makes a
cache on request (the anchor's `ConcurrentMapCacheManager`, the Caffeine copy with no spec, the Redis copy); from `10/after` on, every
harness names its own caches (R.384).

### 2 · keys — the key the abstraction builds, and two methods on one key

One cache, `h09:keys` (in the JVM, a `ConcurrentMap`, on the anchor's tree), five methods called once each; then the cache's native
map, each key printed as its class and its string form, beside the value it holds. On H2 in memory and on PostgreSQL 18.6 (the
container by the digest, the jar's own driver) the shapes are the same:

```text
PROBE keys: native key org.springframework.cache.interceptor.SimpleKey = SimpleKey []   (its value k0:4)
PROBE keys: native key java.lang.String = a   (its value k1:4)
PROBE keys: native key org.springframework.cache.interceptor.SimpleKey = SimpleKey [a, 1]   (its value k2:4)
PROBE keys: native key java.lang.String = kName   (its value kName:4)
PROBE keys: native key java.lang.String = gen:kGen:[a]   (its value kGen:4)
PROBE keys: the KeyGenerator bean h09Keys: h09Keys (gen:<method>:<arguments>)
```

No argument gives `SimpleKey []`; one argument is the key itself, the `String` `a`; two give `SimpleKey [a, 1]`; `key =
"#root.methodName"` gives the method's name; `keyGenerator = "h09Keys"` gives whatever that bean builds — here the method's name and
the arguments, as its own string form says.

**The collision.** `k1("a")` and `kSpel("a", 9)` share the cache `h09:keys`; `k1` takes the default key, `a`, and `kSpel` names its key
`#a`, which is also `a`. The second call is answered with the first method's value:

```text
PROBE pair: k1("a") then kSpel("a", 9), one cache h09:keys (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · returned [k1:4, k1:4]
PROBE pair: then cache h09:keys entries 1 [java.lang.String = a -> k1:4]
exit 0 · its log, every line but the harness's own PROBE lines: lines naming a cache (case-insensitive) 0 · WARN 0 · ERROR 0 · 'Public final method' 0 · 'Could not generate CGLIB subclass' 0 · 'final class' 0
```

The four prints of a silent failure (S8.29): `kSpel`'s counters do not move (its method never ran), the JVM exits 0, no exception is
thrown, and no log line names a cache. The same on H2 in memory.

### 3 · proxy — the self-invocation trap, a third time (⚑4)

The harness bean `H09.Reads` is a CGLIB subclass, and its advisor list (printed, not interpreted) holds the cache's advisor. In one JVM
per database, the same window shape: `all()` called three times from outside the bean, then — the cache cleared — `allViaSelf()` three
times, which calls `this.all()`:

```text
PROBE bean: the harness bean H09.Reads (a harness bean, not the anchor's cache): its class probe.u09.H09$Reads$$SpringCGLIB$$0 · advisors (printed, not interpreted) 1 [BeanFactoryCacheOperationSourceAdvisor(org.springframework.cache.interceptor.CacheInterceptor)]
PROBE self: all() three times, called from outside the bean (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0] and [1, 0, 0] · returned [all:4, all:4, all:4]
PROBE self: allViaSelf() three times - it calls this.all() (PostgreSQL 18.6): repository calls 3 · prepareStatementCount 3 · per call [1, 1, 1] and [1, 1, 1] · returned [all:4, all:4, all:4]
PROBE self: then cache h09:all entries 0 []
PROBE pkg: the package-private @Cacheable pkg("k") three times (PostgreSQL 18.6): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0] and [1, 0, 0] · returned [pkg:4, pkg:4, pkg:4]
PROBE priv: the private @Cacheable priv("k") three times, through the public privViaPublic("k") (PostgreSQL 18.6): repository calls 3 · prepareStatementCount 3 · per call [1, 1, 1] and [1, 1, 1] · returned [priv:4, priv:4, priv:4]
PROBE priv: then cache h09:priv: not made yet (0 entries)
```

Called from outside, through the proxy, the cache in the JVM (a `ConcurrentMap`) answers the second and third calls. Called from inside
the object, `this.all()` is the bean itself, not the proxy: every call runs, and the cache is never asked — it holds nothing after the
three calls. In *JDK Proxies vs CGLIB, and the Self-Invocation Trap* the trap was an internal call silently skipping the aspect. In
*@Transactional: What the Proxy Does* it was a rollback that silently does not happen. Here it is a cache that is never asked. A package-private `@Cacheable` method is cached on Spring 7 (the proxy overrides it); a private one,
called through a public method, runs every time and its cache is never made. Each silent case carries S8.29's four prints: the counter
that keeps counting, exit 0, no exception, and no log line — not one line naming a cache, and no `Public final method` line, with
Spring's AOP and cache loggers at INFO, Boot's default level.

**The public final method** (its own JVM, `H09Final` as a source, the same loggers at INFO): the call runs every time, and it runs on
the proxy instance itself, whose field was never set — the body prints `repo-null` and reads the database through the reference the
configuration kept. Spring warns about the public final method once, at start, in one line:

```text
PROBE final: the public final @Cacheable fin("k") three times (PostgreSQL 18.6): repository calls 3 · prepareStatementCount 3 · per call [1, 1, 1] and [1, 1, 1] · returned [fin:repo-null:4, fin:repo-null:4, fin:repo-null:4]
its WARN line: org.springframework.aop.framework.CglibAopProxy : Public final method [public final java.lang.String probe.u09.H09Final$Fin.fin(java.lang.String)] cannot get proxied via CGLIB, consider removing the final marker or using interface-based JDK proxies.
exit 0 · its log, every line but the harness's own PROBE lines: lines naming a cache (case-insensitive) 0 · WARN 1 · ERROR 0 · 'Public final method' 1 · 'Could not generate CGLIB subclass' 0 · 'final class' 0
```

The final method is warned at start and wrong at the call: it is not refused, and it returns a value. **The line depends on the log
level** — the contrast JVM, the same bean under the harness's `logback.xml` alone (its root at WARN), prints no such line: Spring's
CGLIB proxy checks the class for final methods only when its own logger is at INFO or finer. TiffinBox's own configuration sets no root
level, so Boot's default, INFO, applies there.

Course 4 unit 23's script said, at `spring-core/scripts-and-decks/23-jdk-proxies-vs-cglib-and-the-self-invocation-trap.md:159`:

```markdown
> "By default, an interface bean gets the JDK's proxy, and anything else gets a subclass. A call inside the object never passes the proxy, under either one. Spring warns only about a public final method, and says nothing about this. And the real fix is a second bean. You will meet this trap again, with transactions and with method security."
```

Re-measured on Spring 7, both halves: the public final method's line exists (the final method's JVM, at Boot's default level), and the
self-call's JVM prints none. The quote is true as it was spoken, on Boot's default logging; under a root set to WARN, Spring says
nothing about either.

### 4 · finalclass — the one loud case (⚑4)

On H2 in memory (enough: the start stops before any call). The control is `FinalOne` as shipped — its `Reads` class is not final: the
context starts, the bean is a CGLIB subclass, and its read is cached. The copy (`harness/variants.py finalclass`, one word added,
asserted) makes `Reads` final, and the start stops:

```text
PROBE fclass: its @Cacheable read("k") three times (H2 2.5.250): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0] and [1, 0, 0] · returned [fc:4, fc:4, fc:4]
PROBE started: no · org.springframework.beans.factory.BeanCreationException
PROBE   its cause chain: org.springframework.aop.framework.AopConfigException: Could not generate CGLIB subclass of class probe.u09.FinalOne$Reads: Common causes of this problem include using a final class or a non-visible class
PROBE   its cause chain: java.lang.IllegalArgumentException: Cannot subclass final class probe.u09.FinalOne$Reads
its ERROR line: org.springframework.boot.SpringApplication : Application run failed
exit 1 · its log, every line but the harness's own PROBE lines: lines naming a cache (case-insensitive) 0 · WARN 2 · ERROR 1 · 'Public final method' 0 · 'Could not generate CGLIB subclass' 3 · 'final class' 4
Dashboard.java:30:public final class Dashboard {
```

The anchor's own `Dashboard` is a `public final class`, and no unit puts `@Cacheable` on it: this capture is why — the proxy cannot
subclass a final class, and the application would not start. The only `@Cacheable` annotation in the anchor's `src/main` is unit 08's,
on `CustomerRepository`.

### 5 · exercise — run as written, in one shell, bash then zsh (R.196, RE-MEASURE 4)

`exercise/README.md`'s block, then `exercise/SOLUTION.md`'s, in one `env -i` shell — bash, then `/bin/zsh -f`. The broken state is the
harness as shipped (`kSpel`'s key `#a`); the solution names the method in `kSpel`'s key (`harness/variants.py key`). The check is the
two values and the counters, never the exit:

```text
kSpel's @Cacheable: @Cacheable(cacheNames = "h09:keys", key = "#a")
repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · returned [k1:4, k1:4]
kSpel's @Cacheable: @Cacheable(cacheNames = "h09:keys", key = "#root.methodName + ':' + #a")
repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · returned [k1:4, kSpel:4]
TiffinBox: exit 0
```

The viewer runs the block from `c8-unit09/` with this folder's `.m2-demo` in place: one offline Maven build of the copied anchor, the
harness compiled against its jar, one JVM on H2 in memory. No time is stated for any of it.

## Which store, which manager

Every caching line in this unit names its store and its manager: **in the JVM, a `ConcurrentMap`** (`ConcurrentMapCacheManager`, the
anchor's own class path, and the both-copy with `spring.cache.type=simple`) for `keys`, `proxy`, `finalclass` and the exercise, on H2
in memory and on PostgreSQL 18.6 alike; **in the JVM, Caffeine** (`CaffeineCacheManager`, the Caffeine copy and the both-copy with
`spring.cache.type=caffeine`) and **Redis, by the digest** (`RedisCacheManager`, the Redis copy and the both-copy unset) in `managers`
only, as copies' class paths, each labelled; `NoOpCacheManager` (the both-copy with `spring.cache.type=none`) is no store at all. No
hit is said for Redis here.

## Refused, named

- A warning claimed for the self-call or the private method: the only WARN line captured is the public final method's (R.377).
- The final method called a failure: it runs, on the proxy, and returns a value (⚑4).
- Caffeine named the provider Boot picks with both on the class path: the manager printed is Redis's (R.384).
- The proxy counted instead of the trap: this is the self-invocation trap, a third time (RED #18).
- A manager named without its class path and its `spring.cache.type` (R.384), or without its store (R.376).
- The abstraction credited to Spring Data or Hibernate (R.348).
- A number from a harness bean's cache, or from a copy's class path, voiced as the anchor's: every one here is labelled (R.392).
- A time for anything: no duration word, and every duration the logs print is masked (R.388).

## Call-backs, by title (R.224)

- Course 4's *JDK Proxies vs CGLIB, and the Self-Invocation Trap* (`java4_series.TITLES["23"]`): the internal call that skips the
  aspect; its spoken line is quoted and re-measured above.
- Course 7's *@Transactional: What the Proxy Does* (`java7_series.TITLES["23"]`): the rollback that silently does not happen.
- Course 5's *Auto-Configuration, Mechanism First* (`java5_series.TITLES["04"]`): the mechanism behind the `managers` capture.
- Course 7's *N+1, Measured* (`java7_series.TITLES["30"]`): its pinned counter, called back byte for byte from
  `../c7-unit30/pinned.txt`, its third line — **C8-9 called back**:

```markdown
SessionFactory.getStatistics().getPrepareStatementCount()
```

- Course 8's *@Cacheable, @CacheEvict, @CachePut* (`java8_series.TITLES["08"]`): the tree measured here.
- Next: *Caffeine* (`java8_series.TITLES["10"]`) moves the anchor next.

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged: TiffinBox still starts on H2 in memory with nothing installed.

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s2` (it holds Caffeine 3.2.4, Spring Data
Redis's starter 4.1.2 and Lettuce 7.5.2.RELEASE); every build reads it offline (`-o`, `maven.repo.local` as an absolute path) and the
receipt asserts its file count unchanged after the builds and at the end. Docker: the pinned socket on every call, both images by their
digests, `--pull never`, no image pulled (the image list is asserted unchanged), the volume count asserted back at its start value at
the end (the PostgreSQL image declares a volume, removed with its container; the Redis image declares none). Nothing in this unit
touched the network beyond 127.0.0.1.

## The folders, the harness and the ports

- `harness/src/probe/u09/U9.java` — the harness program (steps `info`, `managers`, `keys`, `pair`, `bean`, `self`, `pkg`, `priv`,
  `final`, `fclass`); `Counter.java` — witness 1, unit 08's class; `H09.java` — the harness bean and its key generator; `H09Final.java`
  — the public final method; `FinalOne.java` — the final-class control.
- `harness/chk09.py` (the checks), `harness/s809.py` (the prose gate, its self-test first), `harness/tree09.py` (the pin),
  `harness/variants.py` (the copies: `caffeine`, `redis`, `both`, `finalclass`, `key`), `harness/dur8.py` (unit 02's, byte for byte),
  `harness/logback.xml` (unit 07's, byte for byte).
- Ports: 20480 never bound (no capture starts TiffinBox's web server) · 20481 the PostgreSQL container · 20482 the Redis container, no
  password, published on 127.0.0.1 only · 20483-20489 never bound. All ten are asserted free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masked: this folder and the repository's paths, the home, the user name, Boot's `Started … in <t>`, Surefire's `Time elapsed`, Flyway's
`execution time`, Spring Data's `scanning in <t>`, `initialization completed in <t>`, Testcontainers' `started in PT<t>S`, Maven's `Total
time`, `using Java <version>`, object hashes. Filtered: the harness JVM's log down to the strict-mode lines, the `Found` lines,
`HHH000001`, Flyway's `Database` line (its port and database name masked), and every WARN and ERROR line (cut at 400 characters); the
log's counts are printed beside them. The WARN lines that are not the unit's subject are Flyway's H2 version line (H2 runs) and Netty's
macOS DNS line (Redis copies). The PostgreSQL password and the shutdown token are generated per run, 0600, and asserted absent from
every capture.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM, Maven, the exercise's shell), removes both containers
with their volumes (`rm -fv`), deletes the partial captures, and exits 130. Measured 2026-11-18 on this folder, the script started as a job of its own (job control on, so SIGINT
reaches it at its default) and the signal sent to its pid at five points — mid-build (Maven building the copies),
mid-harness (a harness JVM on H2), mid-PostgreSQL (a harness JVM on PostgreSQL), mid-Redis (a JVM of the Redis copy) and mid-finalclass —
each looked at twice, the second look a few beats later:

```markdown
exit 130 at each of the five points; at each look: java 0 · mvn 0 · c8u09-pg and c8u09-redis 0 · volumes 315 · images 7 · listeners 20480-20489 0 · .r-lock absent · partial .r-*.[123] 0 · captures unchanged
```

## The ledger rows this unit pays

- **C8-9** called back: `getPrepareStatementCount()` beside the invocation counter in every counted window. Unit 09 pays no row of
  its own.

## RE-MEASURE — the brief's items this unit settles

4. The exercise's solution key, `#root.methodName + ':' + #a` on `kSpel`: each method returns its own value, and each call runs its
   method (the `exercise` capture, bash and zsh, every run).
13. The dashboard's statements: not measured; no page count is voiced.

## Next

Unit 10 moves the anchor next (Caffeine) — `findByName` stays uncached until unit 13.

## What differed from the brief

- **The managers' count.** The brief's count of manager classes is the beat's lines; the captures print seven runs and four
  distinct manager classes (`ConcurrentMapCacheManager` appears for the starter alone and for `spring.cache.type=simple`). The values
  block gives the count as the capture derives it.
- **The WARN depends on the log level** (found here, not in the brief): Spring's CGLIB proxy validates the class only when its logger is
  at INFO or finer. The proxy JVMs set Spring's AOP and cache loggers to INFO (Boot's default) over the harness's `logback.xml`, whose
  root is WARN; a contrast JVM under the harness's file alone prints no such line. The probe ran on Boot's default logging.
- **The final method's second witness.** A method running on the proxy has null fields, so the body reads the database through a static
  reference its configuration kept, beside the null field it reports (`repo-null`): both counters still move once per call.
- **One JVM per database for the silent cases, another for the final method**, so the silent JVM's log is free of the final method's
  WARN, and the self-call's absent line is measured in a JVM where the check that prints the WARN is on.
- **The final class has a control**: `FinalOne` as shipped starts and caches; the copy with one word added does not start.
- **No window on Redis's manager**: the writer Boot builds over Lettuce is unit 11's; `managers` shows Redis answering the JVM's own
  connection (`PING`, its version, matched by `redis-cli`) and the manager's classes only.
- **The exercise's solution** puts the method-naming key on `kSpel` alone (k1's default key is already different from `kSpel:a`); a
  cache each is named in `SOLUTION.md`, not run.
- **SIGINT, sent from a script**: a job started with `&` from a non-interactive bash ignores SIGINT, and a trap cannot catch an ignored
  signal, so the first attempt ran the receipt to its end (exit 0, all clean). The points were measured again with job control on
  (`set -m`), where the job keeps SIGINT at its default, as a foreground job in a terminal does.
- **The PostgreSQL user** has a generated password (an `--env-file`, 0600); Redis runs with no password, on 127.0.0.1 only.

## Planted faults — each caught (R.65, R.226)

Each plant was made in Python on a scratch mirror of the repository (a local clone, this folder copied in; nothing written here), one
change per plant, and the gate named beside it run on the mirror; every plant exited 1 with the line shown, and the six controls (the
shipped prose, the four shipped JVM captures, the shipped What-it-prints comparison) exited 0. The plants on captures are doctored
copies of this run's own `.r-*.out` files.

```markdown
exit 1 "Spring warns you" for the self-call  |  R.377  |  *** a refused word or reading in this unit's prose:   README.md line 293: R.377: Spring warns - the only WARN line captured is the public final method's ***
exit 1 "a final method fails"  |  flag 4  |  *** a refused word or reading in this unit's prose:   README.md line 293: flag 4: "a final method fails" - it runs, on the proxy, with one WARN at start ***
exit 1 "Caffeine wins" with both on the path  |  R.384  |  *** a refused word or reading in this unit's prose:   README.md line 293: R.384: "Caffeine wins" - with both on the class path the manager printed is Redis's ***
exit 1 "the proxy's third time"  |  RED #18  |  *** a refused word or reading in this unit's prose:   README.md line 293: RED #18: the proxy's third time - say "the self-invocation trap, a third time" ***
exit 1 a manager without its class path or setting  |  R.384  |  *** a refused word or reading in this unit's prose:   README.md line 293: R.384: a manager named without its class path or spring.cache.type: RedisCacheManager ***
exit 1 a harness cache voiced as the anchor's  |  R.392  |  *** a refused word or reading in this unit's prose:   README.md line 293: R.392: a harness cache (h09:...) voiced as the anchor's ***
exit 1 "Spring Data caches"  |  R.348  |  *** a refused word or reading in this unit's prose:   README.md line 293: R.348: the abstraction credited to Spring Data or Hibernate: Spring Data caches ***
exit 1 "faster"  |  R.388 / dur8  |  *** a refused word or reading in this unit's prose:   README.md line 293: dur8: faster ***
exit 1 "after a while"  |  R.388's family  |  *** a refused word or reading in this unit's prose:   README.md line 293: R.388's family: after a while ***
exit 1 a typed count (3 vs 1)  |  R.302  |  *** a refused word or reading in this unit's prose:   README.md line 293: R.302: a capture's number typed in prose: 3 vs 1 ***
exit 1 a typed SQL string  |  R.225/R.365  |  *** a refused word or reading in this unit's prose:   README.md line 293: R.225/R.365: a typed SQL string in the prose ***
exit 1 a dish name  |  R.215  |  *** an Indian dish name (R.215: English names only): README.md:293:Unit 10 moves the anchor next (Caffeine) — `findByName` stays uncached until unit 13. Ravi orders panee
exit 1 a placeholder line  |  placeholders  |  *** a placeholder in this unit's prose or harness: README.md:293:Unit 10 moves the anchor next (Caffeine) — `findByName` stays uncached until unit 13 ***
exit 1 the exercise's solution = broken  |  R.196  |  *** R.196: SOLUTION.md's block must be the README's with one line changed ***
exit 1 the pin to the wrong tree  |  R.211  |  *** R.211: anchor must be a link to ../c8-unit08/after (it points at: ../c8-unit07/after) ***
exit 1 a wrong hash (the anchor's pin)  |  R.211  |  *** R.211: anchor/'s tree is 53 eedf32a336609f92de214f7beba6d2ec, the pin in receipts.md5 is 53 eedf32a436609f92de214f7beba6d2ec - the tree moved ***
exit 1 a container removed without -v  |  R.387  |  *** R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: dk rm -f|dk rm -fv) ***
exit 1 the docker CLI unpinned  |  R.344  |  *** R.344: receipts.sh calls docker without the pinned socket (every call is dk): 100:docker info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine runni
exit 1 a dk run without --pull never  |  R.344  |  *** R.344: a dk run without --pull never ***
exit 1 a -pl tiffinbox-web build without -am  |  R.391  |  *** R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am ***
exit 1 the exercise built without -am  |  R.391  |  *** R.391: exercise/README.md builds without -pl tiffinbox-web -am ***
exit 1 the counter changed (not unit 08's)  |  R.375  |  *** harness/src/probe/u09/Counter.java must be unit 08's Counter with its package line alone changed: < package probe.u08;|> package probe.u09;|<                         
exit 1 a WARN count of 2 (a doctored capture)  |  chk09 proxy  |  FAIL the WARN and ERROR lines printed = the log's counts (2, 0)
exit 1 a [1, 1, 0] list for allViaSelf (a doctored capture)  |  chk09 proxy (S8.29)  |  FAIL S8.29: allViaSelf: every call runs - the counter keeps counting (H2 2.5.250)
exit 1 the two counters disagree (a doctored capture)  |  R.375  |  FAIL R.375: priv: the private @Cacheable priv("k") three times, through the public privViaPublic("k") on H2 2.5.250 - the counter's per-call list [1, 1, 1] = the statemen
exit 1 CaffeineCacheManager typed into the both-copy's lines (a doctored capture)  |  chk09 managers (S8.36)  |  FAIL 1 line(s) match ^PROBE managers:\ all\(\)\ three\ times\ through\ CaffeineCacheManager \((H2 2\.5\.250|Pos (found 0)
exit 1 a version claim without HHH000001 (a doctored capture)  |  chk09 keys  |  FAIL HHH000001 7.4.13.Final (H2 2.5.250)
exit 1 a version claim on Boot 4.2.0 (a doctored capture)  |  chk09 keys  |  FAIL the version line (R.246): Boot 4.1.2, Framework 7.0.10, Hibernate = HHH000001's (H2 2.5.250)
exit 1 the collision doctored away (a doctored capture)  |  chk09 keys (S8.29)  |  FAIL the collision: kSpel("a", 9) returned k1's value ['k1:4', 'kSpel:4'] (H2 2.5.250)
exit 1 the final class called started (a doctored capture)  |  chk09 finalclass  |  FAIL 1 line(s) match ^PROBE started: no · (\S+)$ (found 0)
exit 1 the exercise's solved state = broken, its exit 0 (a doctored capture)  |  R.196  |  FAIL RE-MEASURE 4, solved: each method its own value, both calls run
exit 1 a changed What-it-prints line  |  the What-it-prints comparison  |  *** exercise/SOLUTION.md's What it prints block is not what its lines printed (receipts.sh's own comparison) ***
exit 0 (control) the shipped prose  |  s809  |  self-test: 37 cases · refused: 0
exit 0 (control) the shipped managers capture  |  chk09  |  FAIL lines 0
exit 0 (control) the shipped keys capture  |  chk09  |  FAIL lines 0
exit 0 (control) the shipped proxy capture  |  chk09  |  FAIL lines 0
exit 0 (control) the shipped finalclass capture  |  chk09  |  FAIL lines 0
exit 0 (control) the shipped What-it-prints comparison  |  receipts.sh's  |  equal
```

## For RED

- The WARN's dependence on the log level is measured on one bean and one logger setting pair; why Spring gates the check on INFO is
  read off the behaviour, not off the source.
- `managers` runs on H2 alone; the precedence is the class path's, and PostgreSQL is not re-run for it.
- A SIGKILL leaves the containers behind (no trap runs): it happened once here, when the tool running the first SIGINT attempt was
  stopped; both were removed by hand with `rm -fv`, and the volume count went back to its start value.
- The both-copy's Redis manager is shown by its classes and the connection's `PING`; no value is written to Redis by this unit.

<!-- values: begin -->
the values the video may say - exercise: the line 21 words · broken (key "#a"): returned k1:4, k1:4, calls 1 statements 1 per call [1, 0] · solved (key "#root.methodName + ':' + #a"): returned k1:4, kSpel:4, calls 2 statements 2 per call [1, 1] · exit 0 both, H2 in memory · managers: H2 in memory, Redis by the digest (redis_version 8.10.3) where on the class path: the starter alone (unset) ConcurrentMapCacheManager · + caffeine (unset) CaffeineCacheManager · + spring-boot-starter-data-redis (unset) RedisCacheManager · both (unset) RedisCacheManager · both, spring.cache.type=caffeine CaffeineCacheManager · =simple ConcurrentMapCacheManager · =none NoOpCacheManager - its window, three calls of a harness copy's cache: calls 3 statements 3 per call [1, 1, 1]; 4 distinct classes over seven runs · keys: five key shapes (H2 and PostgreSQL alike, ConcurrentMapCache over ConcurrentHashMap): k0() org.springframework.cache.interceptor.SimpleKey = SimpleKey [] · k1("a") java.lang.String = a · k2("a", 1) org.springframework.cache.interceptor.SimpleKey = SimpleKey [a, 1] · kName java.lang.String = kName · kGen java.lang.String = gen:kGen:[a] · the collision k1("a") then kSpel("a", 9): returned k1:4 and k1:4, calls 1 statements 1 per call [1, 0], exit 0, exception none, log lines naming a cache 0 · proxy: the harness bean probe.u09.H09$Reads$$SpringCGLIB$$0, advisors 1 [BeanFactoryCacheOperationSourceAdvisor(org.springframework.cache.interceptor.CacheInterceptor)] (H2 and PostgreSQL alike) · all() x3 calls 1 statements 1 [1, 0, 0] · allViaSelf() x3 calls 3 statements 3 [1, 1, 1], the cache's entries after it 0 · package-private x3 1 [1, 0, 0] · private x3 3 [1, 1, 1] · public final x3 3 [1, 1, 1], returned fin:repo-null:4 · 'Public final method' WARN lines: the final method's JVM 1, the self-call's 0; with the harness's root at WARN 0 · exit 0, no exception, log lines naming a cache 0 in every JVM · finalclass: H2 in memory: FinalOne as shipped (Reads not final) starts, read x3 per call [1, 0, 0] · the copy with Reads final: the start stops - org.springframework.beans.factory.BeanCreationException, exit 1, the log's 'Could not generate CGLIB subclass' lines 3 and 'final class' lines 4, the cause java.lang.IllegalArgumentException · the anchor's Dashboard.java:30 public final class, no @Cacheable on it
<!-- values: end -->

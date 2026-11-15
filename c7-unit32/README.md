# c7-unit32 — The Second-Level Cache

Course 7 · Data with JPA & Hibernate · Section 5 (Performance), its fourth unit — **a harness unit: no change to the anchor** (brief ⚑1).
`anchor` is the link to `../c7-unit31/after` (= `../c7-tiffinbox` as of unit 31's commit `4e6e7c9`); unit 33 builds over the same link;
**34 moves the anchor next (C3); 32 and 33 never touch it.** Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Spring
Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final), 2026-11-15, **on H2 2.5.250 and PostgreSQL 18.6** (brief ⚑7: one
container per run). Hibernate's second-level cache keeps the entities it read, across transactions, so the next read of the same row
sends no SELECT; the hit ratio says how often that happens, counted per region; and a write that never passes through Hibernate leaves
the cached copy behind — psql in another process, or plain JDBC beside Hibernate, changes the row and the next cached read still
answers with the value Hibernate last saw. TiffinBox itself is not started: every capture is the harness's, on the anchor's own tables.

**No anchor change (R.211).** `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` at its
start and end — empty in every run of record — and, should a later unit change the anchor, prints a note instead, never a stop.
`anchor/`'s tree is hashed at the start and the end (`harness/tree32.py`, unit 31's `tree31.py` byte for byte): its file count and md5
are pinned in `receipts.sh` (`T31`, read off `python3 -I harness/tree32.py anchor/` when this unit was built, never typed from a brief) —
this unit never edits `../c7-unit31/after`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 6 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5`. **Start it in a process group of its own** (a
terminal's foreground job is one; from a tool, `perl -MPOSIX -e 'setsid; exec @ARGV' ./receipts.sh`): `sweep()` stops only processes of
its own group whose command line names the harness — so a parent shell whose own command line names it would be stopped too.
`.m2-demo` must be seeded first (below), and the image `postgres@sha256:77f58511…` must be on the machine (`docker image inspect` with the
full digest; the script never pulls).

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s5/` alone (6,772
files), the image `postgres@sha256:77f58511…` present (`docker image inspect`, the full digest), one container per run, removed at its
end. Development runs fixed the captures and the checks; a full passing run wrote every capture 3/3 with the same md5s as the
development passes, and those are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5
`c5e67846845c55d5de9e5e30b438bc32`): 221 s under `./receipts.sh`** (/bin/bash 3.2.57, 2026-11-15 from 09:29 CET), **194 s under `bash
receipts.sh`** (Homebrew bash 5.3.9, from 09:32 CET) **and 249 s from a sealed fresh clone** (below, from 09:36 CET): each exit 0, all 6
captures 3/3 = published, every check passed, every Maven run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0` (three per
run), the anchor note empty at the start and the end, the anchor's tree pinned at both, the container removed and nothing listening on
20110-20119 at the end; each terminal log through `check_unit7.py 32 --runlog` — `RESULT (run logs): PASS` (the unit gate: no 32 script
yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `4e6e7c9` into a path **with a space** (`…/sealed
32/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c7-unit32`: 25 files, the `anchor` link kept); the clone's `.m2-demo` seeded from a file copy of the seed; dead
proxies for http and https in its environment (`127.0.0.1:9`); **`DOCKER_CONFIG=$HOME/.docker`** in its `env -i` (unit 28's finding:
OrbStack's `docker` needs its config to find its context); `./receipts.sh`. The builders' `dur7.py` is not beside the clone: the run
says so and checks `harness/dur7.py` by its md5. The machine was busy (`uptime` read a load of 10.66 after the sealed run); no capture
moved — every md5 is the published one in all three runs. The runs of record ran on this README before this paragraph was written (it
is the only change since; the prose gates and the text-block and values checks were run again on the final text — a full run after it,
exit 0, all 6 = published).
<!-- runs: end -->

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line — R.302: every count,
ratio, jar count, byte count and warning count is here or in a block a run printed, typed nowhere else):

<!-- values: begin -->
the values the video may say: on H2 2.5.250 and PostgreSQL 18.6, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - setup: Caffeine's set (hibernate-jcache + Caffeine's jcache): 11 jars added, 1681123 bytes (cache-api-1.1.1.jar caffeine-3.2.4.jar config-1.4.7.jar error_prone_annotations-2.49.0.jar hibernate-jcache-7.4.13.Final.jar jcache-3.2.4.jar org.osgi.namespace.extender-1.0.1.jar org.osgi.service.component.annotations-1.5.1.jar org.osgi.util.function-1.0.0.jar org.osgi.util.promise-1.0.0.jar osgi.annotation-8.1.0.jar) ; Ehcache's set (hibernate-jcache + ehcache jakarta): 3 jars added, 2539929 bytes (cache-api-1.1.1.jar ehcache-3.12.0-jakarta.jar hibernate-jcache-7.4.13.Final.jar); its JAXB already in the anchor's lib/: jaxb-core-4.0.9.jar jaxb-runtime-4.0.9.jar ; the anchor's lib/: 91 jars ; the keys: hibernate.cache.use_second_level_cache=true, hibernate.cache.region.factory_class=jcache, hibernate.javax.cache.provider=com.github.benmanes.caffeine.jcache.spi.CaffeineCachingProvider, jakarta.persistence.sharedCache.mode=ENABLE_SELECTIVE ; regions: probe.k.ent.KCustomer, probe.k.ent.KCustomer.pauses, probe.k.ent.KPause ; HHH90001006 (HHH90001006: Missing cache region […] was created with provider-specific default policies.) by grep -c: 3, one per region; with missing_cache_strategy=create: 0 ; without the module, the keys on: exit 1, java.lang.ClassNotFoundException: Could not load requested class: jcache; the keys off: regions [], 20 statements for 20 reads, WARN 0 ; Ehcache (the loser, labelled): stderr WARNING: 4, objectFieldOffset 2, first: WARNING: A terminally deprecated method in sun.misc.Unsafe has been called; Caffeine's stderr WARNING: 0 · ratio: K = 5, M = 4: reads 20, region probe.k.ent.KCustomer hit 16 · miss 4 · put 4, statements 4 (three witnesses), JDBC proxy getConnection 20 = Statistics.getConnectCount 20; derived: hits / (hits + misses) = 16 / 20 = 0.800 = (K - 1) / K = 4 / 5 ; K = 10, M = 4: reads 40, region probe.k.ent.KCustomer hit 36 · miss 4 · put 4, statements 4 (three witnesses), JDBC proxy getConnection 40 = Statistics.getConnectCount 40; derived: hits / (hits + misses) = 36 / 40 = 0.900 = (K - 1) / K = 9 / 10 ; the collection (Sunil's pauses, three transactions): statements 1 · 0 · 0; over the three regions hit 7 · miss 1 · put 2; probe.k.ent.KCustomer.pauses per transaction: hit 0 miss 1 put 1 · hit 1 miss 0 put 0 · hit 1 miss 0 put 0 ; Ehcache's K = 5 = Caffeine's · trap: database: H2 - read 1 Ravi 2 (miss 1 · put 1, statements 1); plain JDBC in the JVM (a second java.sql.Connection) sets 3; the database: Ravi 3; read 2 (cached) Ravi 2 (hit 1, statements 0); read 3 (the anchor's CustomerEntity, uncached) Ravi 3 (statements 1) ; (b1) nativeBump("Meera"): rows 1, update customer set meals_per_day = meals_per_day + 1 where name = ?; the next reads Meera 2 and Priya 1 both miss (before it: miss Meera · miss Priya) ; (b2) jpqlBump("Meera"): rows 1, update customer k1_0 set meals_per_day=(k1_0.meals_per_day+1) where k1_0.name=?; the next reads Meera 3 and Priya 1 both miss (before it: hit Meera · hit Priya) ; (b3) the edit through Hibernate: put 1, update customer set meals_per_day=?,name=?,version=? where id=? and version=?; the next read Priya 2, a hit, statements 0 ; database: PostgreSQL - read 1 Ravi 2 (miss 1 · put 1, statements 1); psql in the container (another process) sets 3; the database: Ravi 3; read 2 (cached) Ravi 2 (hit 1, statements 0); read 3 (the anchor's CustomerEntity, uncached) Ravi 3 (statements 1) ; H2 = PostgreSQL for every line above but the writer · query: both databases: runs 1-3 hit 2 · miss 1 · put 1 on default-query-results-region (statements 1 · 0 · 0); an INSERT into customer: miss 1 · put 1 (statements 1); an INSERT into pause: hit 1 (statements 0) · xcheck: 9cf92b8cae3abfd0f1c0706bfe7a4373 · exercise: the README: read 1 2, plain JDBC 3, read 2 2 (hit 1, miss 0); the solution: read 2 3 (hit 0, miss 1) (24 words) · pinned.txt: dbd5b67c2521ccde67a5d0f8b6039a62
<!-- values: end -->

## Pinned sentences (R.252)

Byte-equal in this unit's script and in the unit that consumes it; `pinned.txt` holds the line below and `receipts.sh` checks its md5
and the line, whole, in this README. Course 8's agent for its lesson called Cache Invalidation (Spring Data beyond JPA, its twelfth unit) diffs against `pinned.txt`.

```pinned
A second-level cache holds what Hibernate last read or wrote; a write that never passes through Hibernate leaves it serving the old value.
```

A second-level cache holds what Hibernate last read or wrote; a write that never passes through Hibernate leaves it serving the old value.

The DDL call-back, shared with units 29-31 (R.252): the same hash as in the lesson called Optimistic Locking with At-Version.

## The captures — what each one shows

### 1 · setup — switching it on (H2)

**The added jars, printed (S5.19, RE-MEASURE 13).** Each set is a harness pom of its own (`harness/caffeine/pom.xml`,
`harness/ehcache/pom.xml`: Spring Boot 4.1.2 as parent, no version typed — `hibernate-jcache` is managed through `hibernate-platform`,
Caffeine's `jcache` and Ehcache's `jakarta` jar by the BOM), listed and copied offline by `dependency:list dependency:copy-dependencies`;
every listed jar is marked as already in the anchor's `lib/` or added, the added ones are copied to `.harness/cache-<set>/`, `ls -l` gives
their sizes, and the receipt counts and sums them. The check then counts and sums `ls -l`'s lines again and compares the names with
`dependency:list`'s added lines (`harness/chk32.py setup`):

```text
the caffeine set, added: 11 jars, 1681123 bytes (ls | wc -l; ls -l's sizes summed by awk) · dependency:list's 'added' lines: 11
the ehcache set, added: 3 jars, 2539929 bytes (ls | wc -l; ls -l's sizes summed by awk) · dependency:list's 'added' lines: 3
ok    ehcache: its JAXB jars are in the anchor's lib/ already (not added): jaxb-core-4.0.9.jar jaxb-runtime-4.0.9.jar
```

The two sets side by side: Caffeine's adds the cache module, the JCache API, Caffeine's JCache provider and Caffeine itself, its
Typesafe `config`, `error_prone_annotations` and five OSGi annotation jars; Ehcache's adds the cache module, the JCache API and one
`jakarta` jar — its JAXB runtime is the anchor's own (Hibernate needs it already). Each set's every jar, line by line, is in the capture.
cache2k (the BOM's third JCache provider) is named only. **The loser — `spring-boot-starter-cache`:** that is Spring's cache abstraction
(`@EnableCaching`, Spring's `@Cacheable` on a method), not Hibernate's second-level cache — the loser here; Course 8 takes it up in its lesson called `@Cacheable`, `@CacheEvict`, `@CachePut`.

**The keys, read off the run.** Four run options switch it on — `hibernate.cache.use_second_level_cache=true`,
`hibernate.cache.region.factory_class=jcache`, `hibernate.javax.cache.provider=<the provider>`,
`jakarta.persistence.sharedCache.mode=ENABLE_SELECTIVE` (only an entity marked `@Cacheable` is cached) — and the harness prints each from
`EntityManagerFactory.getProperties()`, beside the region factory in use and the JCache providers `javax.cache.Caching` finds on the class
path; the check asserts the provider key names the one provider found:

```text
PROBE key (EntityManagerFactory.getProperties()): hibernate.cache.use_second_level_cache = true
PROBE key (EntityManagerFactory.getProperties()): hibernate.cache.region.factory_class = jcache
PROBE key (EntityManagerFactory.getProperties()): hibernate.javax.cache.provider = com.github.benmanes.caffeine.jcache.spi.CaffeineCachingProvider
PROBE key (EntityManagerFactory.getProperties()): jakarta.persistence.sharedCache.mode = ENABLE_SELECTIVE
PROBE region factory in use (SessionFactoryImplementor.getCache().getRegionFactory()): org.hibernate.cache.jcache.internal.JCacheRegionFactory
PROBE JCache providers on the class path (javax.cache.Caching.getCachingProviders()): [com.github.benmanes.caffeine.jcache.spi.CaffeineCachingProvider]
PROBE regions (Statistics.getSecondLevelCacheRegionNames(), sorted): [probe.k.ent.KCustomer, probe.k.ent.KCustomer.pauses, probe.k.ent.KPause]
```

The harness entities map the anchor's own tables (`ddl-auto none` keeps them off the schema — said on the slide): `KCustomer` on
`customer`, `@Cacheable` and `@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)`, the anchor's `version` column under `@Version`;
`KPause` on `pause`, cached; `KCustomer.pauses` cached as a collection. Three regions, named after them.

**The default strategy warns once per region; `create` silences it.** Hibernate 7.4.13 creates a missing region with the provider's
defaults and says so at WARN; the receipt counts the lines with `grep -c` and the check asserts the count equals the regions counted and
names each region once (Hibernate creates the regions in no fixed order, so the capture shows the lines sorted):

```text
(sorted; Hibernate creates the regions in no fixed order) WARN  [main] org.hibernate.orm.cache : HHH90001006: Missing cache region [probe.k.ent.KCustomer] was created with provider-specific default policies. Explicitly configure the region and its policies, or disable this warning by setting 'hibernate.javax.cache.missing_cache_strategy' to 'create'.
its WARN lines (grep -c '^WARN '): 3 · HHH90001006 lines (grep -c 'HHH90001006'): 3
its WARN lines (grep -c '^WARN '): 0 · HHH90001006 lines (grep -c 'HHH90001006'): 0
```

The second line is the default run's; the third the run with the fifth key, `hibernate.javax.cache.missing_cache_strategy=create` —
every run after `setup` carries it.

**Without the cache module — two labelled runs on the anchor's libraries as they are.** With the four keys on, the start is refused (a
filed step, R.303: exit 1, its cause read off the chain); with the keys off, there is no region, every `@Cache` is ignored, and each
read sends its SELECT:

```text
PROBE caused by: java.lang.ClassNotFoundException: Could not load requested class: jcache
PROBE region factory in use (SessionFactoryImplementor.getCache().getRegionFactory()): org.hibernate.cache.internal.NoCachingRegionFactory
PROBE regions (Statistics.getSecondLevelCacheRegionNames(), sorted): []
ok    control: a SELECT per read - 20 statements for 20 reads, no region (@Cache ignored)
```

**Ehcache, the labelled loser.** The same reads on Ehcache's set give the same hit, miss and put counts as Caffeine's at K = 5 (asserted
by the `ratio` check), and the JVM itself writes to stderr — a file of its own in every run, counted by `grep -c` (Caffeine's stderr: 0
lines in both of its `setup` runs). Its first line, quoted from the labelled step in `setup`: `WARNING: A terminally deprecated method in sun.misc.Unsafe has been called`.

```text
its stderr (.harness/h.err): 4 lines · grep -c '^WARNING:' 4 · grep -c 'objectFieldOffset' 2
stderr: WARNING: A terminally deprecated method in sun.misc.Unsafe has been called
stderr: WARNING: sun.misc.Unsafe::objectFieldOffset has been called by org.ehcache.impl.internal.concurrent.ThreadLocalRandomUtil (file:…/.harness/cache-ehcache/ehcache-3.12.0-jakarta.jar)
stderr: WARNING: Please consider reporting this to the maintainers of class org.ehcache.impl.internal.concurrent.ThreadLocalRandomUtil
stderr: WARNING: sun.misc.Unsafe::objectFieldOffset will be removed in a future release
ok    Caffeine JVM 1: stderr 0 lines, WARNING: 0
```

That is why Caffeine wins (brief ⚑4): the same counts, and no warning from the JDK on JDK 25.

### 2 · ratio — the hit ratio, derived (S5.7, H2)

K rounds over the seeded customers (M, read back on the second connection), each `em.find(KCustomer.class, id)` in its own
`TransactionTemplate` — its own session, so the first round misses and puts each customer and every later round hits. **Each read here
runs in its own transaction, and each transaction takes a connection — a hit included** (RED #1516): the connections are K × M while the
statements are M. The hit ratio is derived by the check from the printed counts, `hits / (hits + misses)`, and again from the printed
design, `(K − 1) / K`; both are printed and must agree:

```text
PROBE reads 20 | statements: Statistics.getPrepareStatementCount 4 · org.hibernate.SQL lines 4 · JDBC proxy prepareStatement 4 | connections: JDBC proxy getConnection 20 · Statistics.getConnectCount 20 | region probe.k.ent.KCustomer: hit 16 · miss 4 · put 4 | region probe.k.ent.KCustomer.pauses: hit 0 · miss 0 · put 0 | region probe.k.ent.KPause: hit 0 · miss 0 · put 0 | query cache (Statistics.getQueryCacheHitCount · Miss · Put): hit 0 · miss 0 · put 0
ok    K = 5: derived - hits / (hits + misses) = 16 / 20 = 0.800 = (K - 1) / K = 4 / 5 = 0.800
PROBE reads 40 | statements: Statistics.getPrepareStatementCount 4 · org.hibernate.SQL lines 4 · JDBC proxy prepareStatement 4 | connections: JDBC proxy getConnection 40 · Statistics.getConnectCount 40 | region probe.k.ent.KCustomer: hit 36 · miss 4 · put 4 | region probe.k.ent.KCustomer.pauses: hit 0 · miss 0 · put 0 | region probe.k.ent.KPause: hit 0 · miss 0 · put 0 | query cache (Statistics.getQueryCacheHitCount · Miss · Put): hit 0 · miss 0 · put 0
ok    K = 10: derived - hits / (hits + misses) = 36 / 40 = 0.900 = (K - 1) / K = 9 / 10 = 0.900
ok    K = 10: JDBC proxy getConnection 40 = Statistics.getConnectCount 40 = K x M (each read its own transaction, a hit included)
```

Every count has its three witnesses (S5.1): `Statistics.getPrepareStatementCount()` read before and after the step, the
`org.hibernate.SQL` appender's events, the JDBC proxy's `prepareStatement` — and for the connections the proxy's `getConnection` beside
`Statistics.getConnectCount()`. The cache's counters are read per region by method name,
`Statistics.getCacheRegionStatistics(region).getHitCount()` / `getMissCount()` / `getPutCount()`, for every region
`getSecondLevelCacheRegionNames()` lists. The collection region beside: Sunil's pauses, read in three transactions — the first loads the
collection (one SELECT), the next two answer from the collection region and the pause region:

```text
PROBE transaction 1: Sunil's pauses 1 | statements: Statistics.getPrepareStatementCount 1 · org.hibernate.SQL lines 1 · JDBC proxy prepareStatement 1 | connections: JDBC proxy getConnection 1 · Statistics.getConnectCount 1 | region probe.k.ent.KCustomer: hit 1 · miss 0 · put 0 | region probe.k.ent.KCustomer.pauses: hit 0 · miss 1 · put 1 | region probe.k.ent.KPause: hit 0 · miss 0 · put 1 | query cache (Statistics.getQueryCacheHitCount · Miss · Put): hit 0 · miss 0 · put 0
PROBE transaction 2: Sunil's pauses 1 | statements: Statistics.getPrepareStatementCount 0 · org.hibernate.SQL lines 0 · JDBC proxy prepareStatement 0 | connections: JDBC proxy getConnection 1 · Statistics.getConnectCount 1 | region probe.k.ent.KCustomer: hit 1 · miss 0 · put 0 | region probe.k.ent.KCustomer.pauses: hit 1 · miss 0 · put 0 | region probe.k.ent.KPause: hit 1 · miss 0 · put 0 | query cache (Statistics.getQueryCacheHitCount · Miss · Put): hit 0 · miss 0 · put 0
```

### 3 · trap — a write Hibernate never saw (S5.8, both databases; the failure receipt)

**The hook, on PostgreSQL.** One harness JVM reads Ravi (a miss and a put), prints a ready line and blocks on `System.in.read()` — its
stdin is a FIFO this script holds open. While it waits, **this script runs psql in the container** — another process, over the
container's own socket, no password on its command line — and sets Ravi's meals to a value it chose and printed: the JVM's read plus one.
psql's own read of the row is the database-truth line. Then the script writes one byte to the FIFO and the JVM reads Ravi again: the
cached `KCustomer` answers with the old value, a hit, no statement, while the database holds the new one; the anchor's own
`CustomerEntity` (not cached) in the same JVM reads the new one. Three readings on one slide (S5.7): the cached read, psql's value, the region's counts.

```text
PROBE read 1 (phase 1): Ravi meals_per_day 2 | statements: Statistics.getPrepareStatementCount 1 · org.hibernate.SQL lines 1 · JDBC proxy prepareStatement 1 | connections: JDBC proxy getConnection 1 · Statistics.getConnectCount 1 | region probe.k.ent.KCustomer: hit 0 · miss 1 · put 1 | region probe.k.ent.KCustomer.pauses: hit 0 · miss 0 · put 0 | region probe.k.ent.KPause: hit 0 · miss 0 · put 0 | query cache (Statistics.getQueryCacheHitCount · Miss · Put): hit 0 · miss 0 · put 0
PROBE ready: phase 1 done, Ravi read 2 - the JVM now blocks on System.in.read() until the receipt's outside write is done
psql: UPDATE 1
database truth (psql, another process): Ravi|3
PROBE read 2 (the cached KCustomer): Ravi meals_per_day 2 | statements: Statistics.getPrepareStatementCount 0 · org.hibernate.SQL lines 0 · JDBC proxy prepareStatement 0 | connections: JDBC proxy getConnection 1 · Statistics.getConnectCount 1 | region probe.k.ent.KCustomer: hit 1 · miss 0 · put 0 | region probe.k.ent.KCustomer.pauses: hit 0 · miss 0 · put 0 | region probe.k.ent.KPause: hit 0 · miss 0 · put 0 | query cache (Statistics.getQueryCacheHitCount · Miss · Put): hit 0 · miss 0 · put 0
PROBE read 3 (the anchor's CustomerEntity, not cached, findByName): Ravi meals_per_day 3 | statements: Statistics.getPrepareStatementCount 1 · org.hibernate.SQL lines 1 · JDBC proxy prepareStatement 1 | connections: JDBC proxy getConnection 1 · Statistics.getConnectCount 1 | region probe.k.ent.KCustomer: hit 0 · miss 0 · put 0 | region probe.k.ent.KCustomer.pauses: hit 0 · miss 0 · put 0 | region probe.k.ent.KPause: hit 0 · miss 0 · put 0 | query cache (Statistics.getQueryCacheHitCount · Miss · Put): hit 0 · miss 0 · put 0
```

(Each read line goes on with the other regions' deltas and the query cache's, every one 0.) **On H2** the outside writer is plain JDBC in
the same JVM — a second `java.sql.Connection` from `DriverManager` on the same in-memory URL, outside Hibernate — so H2 needs no server
and no FIFO, and binds no port (20117 stays free). Its lines are the same readings (two `database:` lines because the writer differs):

```text
ok    H2: read 2 - the old value 2, a hit, 0 statements (the database says 3)
ok    PostgreSQL: read 2 - the old value 2, a hit, 0 statements (the database says 3)
ok    H2 = PostgreSQL for every reading (the writer aside)
```

**The counter-cases — Hibernate's own writes.** A native `@Modifying` UPDATE through Spring Data (`nativeQuery = true`, no query spaces
declared) bumps Meera: the next reads of **Meera and Priya both miss** — Hibernate empties the entity's region, though one row changed.
A JPQL bulk UPDATE: both miss again. An edit through Hibernate (`em.find`, `setMealsPerDay`, commit): the region's put, the UPDATE read
off the log with its version, and the next read a hit with the new value. The brief's old plan (that the native path leaves the region alone)
is refused by `s32.py` per sentence: both bulk paths empty the region, measured on both databases.

```text
PROBE its SQL texts (org.hibernate.SQL): 1 x update customer set meals_per_day = meals_per_day + 1 where name = ?
ok    H2 (b1): the next reads of Meera AND Priya both miss (and put) - the region emptied
PROBE its SQL texts (org.hibernate.SQL): 1 x update customer k1_0 set meals_per_day=(k1_0.meals_per_day+1) where k1_0.name=?
ok    H2 (b2): the next reads of Meera AND Priya both miss (and put) - the region emptied
PROBE its SQL texts (org.hibernate.SQL): 1 x update customer set meals_per_day=?,name=?,version=? where id=? and version=?
ok    PostgreSQL (b3): the edit through Hibernate - put 1, one statement
ok    PostgreSQL (b3): the next read a hit with the new value, 0 statements
```

The check fails if the database-truth line is missing — the plant "the psql step skipped" (below): the JVM's own two reads still print
then, and a check that only read the JVM's exit or its reads would pass.

### 4 · query — the query cache (both databases)

`hibernate.cache.use_query_cache=true` adds the region `default-query-results-region`. The query reads only `customer` — the names of
the customers with at least one meal a day, by name, with the hint `org.hibernate.cacheable` — and runs three runs, each in its own
transaction; then one INSERT into `customer` (a `CustomerEntity`, another entity on the same table) and the query again; then one
INSERT into `pause` and the query again. The table's timestamp tells Hibernate which cached results to drop: the INSERT into `customer`
makes the query miss; the one into `pause` leaves it a hit — correct, not out of date: the query reads no `pause`.

```text
ok    H2: three runs - miss put (one SELECT), hit, hit (0 statements); hit 2 · miss 1 · put 1
ok    PostgreSQL: after the INSERT into customer the query misses and puts, one SELECT, and returns the new row
ok    PostgreSQL: after the INSERT into pause it hits, 0 statements (the query reads no pause)
ok    H2 = PostgreSQL
```

### 5 · xcheck — the DDL over the anchor (R.252)

Hibernate's script over the anchor's libraries (`probe.x.XMain`, unit 29's byte for byte: the anchor's entities alone, no cache jar on
its class path) = `xcheck.sql` = `../c7-unit31/xcheck.sql`; the harness's `@Cache` annotations are not on the schema (the check greps
the script: no line names a cache). The same hash as in the lesson called Optimistic Locking with At-Version.

```text
its md5: 9cf92b8cae3abfd0f1c0706bfe7a4373 · the filed xcheck.sql: 9cf92b8cae3abfd0f1c0706bfe7a4373 · cmp: the same, byte for byte · the fetch-plan lesson's xcheck.sql: the same, byte for byte
```

### 6 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s lines, then `SOLUTION.md`'s, exactly as written, in one `env -i` shell, `/bin/bash`, then `/bin/zsh -f`; each
file's "What it prints" block compared with the run, line for line; broken and solved differ.

## Call-backs, by title (R.224)

- Course 8 (Spring Data beyond JPA), its lesson called Cache Invalidation — the pinned sentence above; the stale data a writer outside the application leaves (psql here), taken up there.
- Course 8's lesson called `@Cacheable`, `@CacheEvict`, `@CachePut` — Spring's cache abstraction, the loser's home (not Hibernate's cache).
- The lesson called Optimistic Locking with At-Version — `@Version` on `customer`, and the DDL hash sentence.
- The lessons called Lazy Loading and LazyInitializationException, N+1, Measured and JOIN FETCH vs @EntityGraph vs @BatchSize — the section's first three; the collection region here caches what JOIN FETCH vs @EntityGraph vs @BatchSize fetched in one statement.
- The lesson called Your First Entity and EntityManager — open-in-view (off in every harness JVM: each read opens its own session in its own transaction).

## The commands this unit adds

The harness, compiled once against the anchor's extracted libraries (the cache jars are not needed to compile: `@Cache` is
`hibernate-core`'s); the dependency line run on each harness pom; the harness's JVM, its class path in `CP` (one of the three below),
its arguments in two arrays (`V` the flags, `A` the arguments, R.193); `xcheck`'s JVM; the container, its readiness, a fresh database per
JVM, and psql's write and read in the trap (`$DB` the run's database, `$NEW` the value the script chose):

```
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/k/H.java harness/src/probe/k/Main.java harness/src/probe/k/Run.java harness/src/probe/k/Seed.java harness/src/probe/k/SqlCounter.java harness/src/probe/k/ent/KCustomer.java harness/src/probe/k/ent/KPause.java harness/src/probe/k/repo/KRepo.java harness/src/probe/x/XMain.java
mvn -B dependency:list dependency:copy-dependencies -DoutputDirectory=jars
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "$CP" probe.k.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
docker run -d --pull never --name c7u32-pg -p 127.0.0.1:20118:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker exec c7u32-pg pg_isready -U sa -h 127.0.0.1 -q
docker exec c7u32-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
docker exec c7u32-pg psql -U sa -d "$DB" -At -v ON_ERROR_STOP=1 -c "update customer set meals_per_day = $NEW where name = 'Ravi'"
docker exec c7u32-pg psql -U sa -d "$DB" -qAt -v ON_ERROR_STOP=1 -c "select name, meals_per_day from customer where name = 'Ravi'"
CP="../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../cache-caffeine/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar"
CP="../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../cache-ehcache/*"
CP="../hc:../anchor/tiffinbox-web/target/extracted/lib/*"
```

The anchor's own lines are read from `anchor/README.md` and asserted whole: its package line (`mvn -B package`, run offline with
`-DskipTests` — its tests are unit 31's) and its extract line. On PostgreSQL the harness gets `-Dpg.db=NAME -Dpg.pwfile=../secrets/pgpw`
and builds `jdbc:postgresql://127.0.0.1:20118/NAME` inside the JVM (unit 28's form): the password is on no command line, every printed URL
is cut before its `?`. The latched JVM's stdin is `.harness/latch.fifo`; every other JVM's is `/dev/null`.

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s5/` alone (brief ⚑9: s5 is the only seed with the cache jars; it also holds
`p6spy-3.9.1` and `datasource-proxy-1.11.1` for units 33 and 34 — this unit uses neither). Three Maven runs before the captures: the
anchor's package (`-DskipTests`) and the dependency line on each harness pom; each `offline: yes`, 0 `Downloaded from` lines, as the build
lines print. **At run time** the harness binds no port; its H2 databases are in its JVM's memory (`jdbc:h2:mem:u32`, xcheck's `x32`, the
exercise's `ex`); its PostgreSQL databases are fresh ones in the container (`u32trap`, `u32query`), loopback only. **No network act**
(`docker run --pull never`): the section's dated sweep is the brief's (`_research/spring-boot-metadata-2026-11-13.xml`,
`spring-data-bom-metadata-2026-11-13.xml`, `hibernate-core-metadata-2026-11-13.xml`: no 4.1.x patch, Hibernate 7.4.15 exists and is not
adopted — ⚑8, R.223). Every harness JVM prints `Version.getVersionString()`, Spring Data JPA's version, Spring Framework's from
`spring-tx`'s manifest and Hibernate's `HHH000001` line before the context starts (S4.13, asserted per JVM by `chk32.py`), and its
database line: `select version()` cut before ` on `, the URL cut before `?`, the JDBC driver's name and version from its metadata.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `anchor` → `../c7-unit31/after` (a link; `readlink` asserted, its tree hashed and pinned). Never built in place: copied to
  `.harness/anchor` and built there.
- `harness/src/probe/k` — `Main` (the context: `@EntityScan({"com.tiffinbox", "probe.k.ent"})`, `@EnableJpaRepositories({"com.tiffinbox",
  "probe.k.repo"})`, `WebApplicationType.NONE`), `Seed` (the shipped `Database` on the run's database — Ravi, Meera, Sunil, Priya and two
  pauses — and the counting proxy around Boot's pool by a `BeanPostProcessor`), `Run` (the scenarios `setup`, `ratio`, `trap`, `query`;
  every id read back by name on the second connection, never typed), `H` (the second connection, the witnesses, the per-region
  counters as deltas), `SqlCounter` (the SQL logger's events and texts), `ent/KCustomer`, `ent/KPause`, `repo/KRepo` (the native and the
  JPQL bulk updates), `ex/ExApp` (the exercise, compiled only by the exercise's own lines). `harness/src/probe/x/XMain.java` is unit 29's.
- `harness/caffeine/pom.xml`, `harness/ehcache/pom.xml` — the two sets; `harness/logback.xml` (one line per event; Hibernate's SQL
  logger at DEBUG, `org.hibernate.orm.core` at INFO for `HHH000001`, `org.hibernate.orm.cache` at WARN for `HHH90001006`).
- `harness/chk32.py` (the checks), `harness/s32.py` (the prose gate, its self-test first), `harness/tree32.py`, `harness/dur7.py` (the
  builders' `dur7.py`, byte for byte).
- **Ports (§P, 20110-20119):** 20118 the container (`docker port` asserted: `127.0.0.1:20118` alone); 20110-20117 and 20119 never bound
  (H2's writer is in the JVM, so no H2 server on 20117); the harness JVMs bind none. All ten are asserted free at the start and the end.

## Masks, filters and hygiene — every one, declared

- **Masked** in every capture (the mask's self-test runs first on planted lines): the PostgreSQL password (`<pw>`), this folder and its
  parent, plain and `%20`-encoded (Ehcache's stderr names its jar by a `file:` URL), the home folder, the user name, the JDK's version
  (`using Java <version>`), an EntityManager's identity, an identity hash (`@…`), a lambda's address, Spring Data's scan time, H2's build
  date on the driver line.
- **Filtered**: the `org.hibernate.SQL` lines are counted, not shown (their texts the harness prints where a step needs them); the
  `HHH90001006` lines are shown sorted (Hibernate creates the regions in no fixed order — the one ordering change in any capture);
  `ls -l` shows bytes and name only.
- **Hygiene**, asserted at the end: raw password copies 0 in every raw capture run, every capture, every log; no absolute path, unit
  number, time, duration figure, thread number, OS token, unmasked identity, password, URL or stack frame in any capture;
  every JVM pinned (locale) and under its alarm; no kill by name; no bare wait; **no `Thread.sleep`, no polling loop in `harness/src`**
  (the latch is `System.in.read()`, once — grepped); no H2 file; no FIFO outside `.harness`.

## Interrupted

`receipts.sh` traps INT and TERM: it stops the JVM (the latched one included), any Maven or javac and every process under it, the
exercise's shell; closes the FIFO's writing end and removes the FIFO; sweeps its process group; removes the container if it started it
(`CSTARTED` set before `docker run`, `pgrm` retrying until `docker ps -a` no longer names it); removes the capture's unfinished runs; exits
130. A leftover-container guard refuses to start while a container named `c7u32-pg` exists.

**Measured (2026-11-15, from 09:11 CET, on a scratch mirror of this folder — its files, its captures and `.m2-demo` cloned, `c7-unit31`, `c7-unit29` and `c7-tiffinbox` linked):** `receipts.sh` started `env -i` in a session of its own **with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group once the named process was in it (and, for `latch`, once the JVM had printed its ready line and was blocked on its stdin), the state read 5 s after its exit — four trials:

```
build (org.codehaus.plexus.classworlds.launcher.Launcher seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u32-pg: 0 · FIFO: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
harness (probe.k.Main seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u32-pg: 0 · FIFO: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
latch (-Dlatch=stdin + log /^PROBE ready: / seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u32-pg: 0 · FIFO: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
container (-Dpg.db=u32query seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u32-pg: 0 · FIFO: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
```

`build` — the anchor's Maven build; `harness` — the first harness JVM (`setup` on H2), the container up; `latch` — the PostgreSQL trap JVM blocked on `System.in.read()`, its stdin the FIFO; `container` — the query's PostgreSQL JVM (`-Dpg.db=u32query`). The container was gone after each (`docker ps -a`), no FIFO was left, and `pgrep -x java` showed none.

## Exercise

"Your turn: the README's cache keeps serving Ravi's old meals after a plain JDBC update changed them. Make the next read see the database."
(Its word count is printed by the receipt with `wc -w` and asserted equal to the brief's.) A Spring Boot application of its own
(`Diner`, cached, on its own table in its own H2 — not TiffinBox's customers): the README's lines read Ravi, change his meals with plain
JDBC, read him again — a hit with the old value, while the database holds the new one; the solution's one line (a `sed` that puts `emf.getCache().evict(Diner.class, id)` right
after the outside write, the id the one read back by name) makes the second read a miss that prints the new value. Broken ≠ solved by
the printed lines (R.196). **RE-MEASURE 6, settled:** measured — `getCache().evict(<class>, <id>)` after the outside write: the next read
misses and prints the database's value (capture `exercise`, both shells).

## The ledger rows and hand-offs this unit pays

- No ledger row is paid (brief §LEDGER: 32 owns no payment; `PROMISE-LEDGER-2026-11-01.md` untouched).
- **Pinned for Course 8's lesson called Cache Invalidation** (R.252): `pinned.txt`, its md5 checked by `receipts.sh`.
- 34 moves the anchor next (C3); 32 and 33 never touch it.

## RE-MEASURE — the brief's items this unit settles

- **6 (the exercise's evict, the trap with psql run by the receipt):** measured. psql runs from `receipts.sh` itself between two phases
  of one harness JVM (a FIFO on its stdin, `System.in.read()` in the JVM); the evict makes the next read a miss with the new value.
- **13 (Ehcache's added set):** measured on the same basis as Caffeine's — `dependency:list`, the jars the anchor's `lib/` does not hold,
  `ls -l` — and printed side by side (above, and in the values line); its JAXB jars are already in the anchor's `lib/`, named, not added.

## What differed from the brief

1. **Without the cache module, the brief's control is the keys-off run; with the keys on, the start is refused.** The brief (and the
   probe's `u32nocache-h2`) says "without `hibernate-jcache`: regions `[]`, `@Cache` ignored, WARN 0". Measured here: that holds with the
   four keys off; with them on, the anchor's libraries refuse to start (`Unable to resolve name [jcache] as strategy
   [org.hibernate.cache.spi.RegionFactory]`, its last cause quoted above). Both are labelled steps of `setup`; the refusal is filed
   (R.303) and grepped by `receipts.sh` in the capture and in this README.
2. **Ehcache's added set (RE-MEASURE 13)** is the cache module, the JCache API and Ehcache's `jakarta` jar, counted and summed by the
   receipt (the values line); its JAXB runtime and the rest of its tree are the anchor's own, each listed as such. Caffeine's set, printed
   the same way, equals the count and bytes RED counted offline (brief ⚑4) — neither number is typed anywhere outside the values line and
   the printed blocks.
3. **The added set is printed from the build step's log.** `dependency:list dependency:copy-dependencies` runs once per pom before the
   captures (offline, its build line printed); `setup` prints its listed lines, marks each jar, and `ls -l`s the copied jars in each of
   its three runs. Maven is not run inside the capture (its log carries timings).
4. **`HHH90001006` lines are shown sorted.** Hibernate creates the regions in no fixed order (the first development run drifted on
   exactly that); the capture shows the lines sorted, and the check names each region once and compares the `grep -c` count with the
   regions counted.
5. **The trap's new value is chosen by the receipt from the JVM's own read** (its ready line names the value; the receipt adds one,
   prints both, and psql writes it). On H2 the JVM adds one itself and prints the write it sent. No value is typed in `receipts.sh` or
   the harness.
6. **The latch:** the PostgreSQL trap JVM's stdin is a FIFO (`.harness/latch.fifo`) that `receipts.sh` opens for writing on fd 4; the
   JVM prints its ready line and blocks on `System.in.read()`; the receipt's bash loop waits for that line (bash's `sleep`, not the
   harness's), runs psql's write and read, writes one byte, closes fd 4. On H2 there is no FIFO: plain JDBC in the JVM (unit 24's form),
   so 20117 is never bound.
7. **The database-truth line on PostgreSQL is psql's alone**: the JVM's second connection does not read Ravi there, so a skipped psql
   step leaves no truth line at all (the plant), rather than a second connection reading the old value.
8. **The exercise uses a `Diner` of its own** (as units 30 and 31 did), not the K-entities, on its own table in its own H2. `Diner` is a
   top-level class beside `ExApp` in the same file: as a nested class its region was named `probe.k.ex.ExApp$Diner`, and Caffeine's
   `TypesafeConfigurator` then logged `WARN … Failed to load cache configuration` at start (measured in development, not filed — the `$`
   in a region name; a top-level entity's region has none).
9. **`KCustomer` maps `mealsPerDay` by Hibernate's naming strategy, with no `@Column`**: naming the column explicitly beside the anchor's
   `CustomerEntity` on the same table refused the start (`DuplicateMappingException: Table [customer] contains physical column name
   [meals_per_day] referred to by multiple logical column names`, measured in development); the probe's entity had none either.
10. **Every count is a delta** (the counters read before and after each read or step; `Statistics` is never cleared inside a step), so
    one line carries the three statement witnesses, the two connection counts, and hit · miss · put for every region.
11. **The edit through Hibernate shows a hit beside its put**: the `em.find` inside the edit's own transaction is answered by the region;
    the check asserts the put and the one statement, and the next read's hit with the new value.
12. **The query cache's INSERT into `pause` also sends a SELECT** (the `CustomerEntity` it belongs to, found by name); its delta shows
    both statements and no change to the query's region.
13. **H2's class path carries the PostgreSQL driver too** (one class path, `CP`, for both databases); the driver is never used on H2.
14. **The anchor's tests are not run** (`-DskipTests`): they are unit 31's (18/18 there, a guard, R.190); no anchor change here.
15. **No H2 TCP server, no 20117**; the brief's alternative FIFO form on H2 was not chosen.
16. **`DOCKER_CONFIG=$HOME/.docker`** is set in the sealed clone's `env -i` (unit 28's and 31's finding; the value printed in the runs
    paragraph).

## Planted faults — each caught (R.65, R.226)

Measured 2026-11-15 from 09:17 CET. **Receipt plants** — each on a fresh scratch mirror of this folder (its files, captures and
`.m2-demo` cloned; `c7-unit31`, `c7-unit29`, `c7-tiffinbox` linked), the plant applied, `receipts.sh` run `env -i` in a session of its
own (the captures a plant does not need dropped from the mirror's script, so it reaches its check sooner); each exits 1 with
`receipts.md5` and `README.md` as planted — nothing published — and no container left:

| Plant | Caught by | The line it died on (cut) |
|---|---|---|
| a typed ratio — "The hit ratio is" plus a three-place decimal, in a README line no capture printed | `s32` (S5.7) and the R.302 grep | `S5.7: a ratio typed` |
| `A native query leaves the cache stale.` in a README line | `s32` (S5.8) | `S5.8: stale without the writer …`, `S5.8: Hibernate's bulk path said not to invalidate` |
| **the psql step skipped** (psql's write and read replaced by an empty file in the mirror's script) | `chk32 trap` | `FAIL  PostgreSQL: the database-truth line, once` — while the JVM's own two reads still print (both with Ravi's first value) and both JVMs print `exit 0`: a status-only check would pass |
| Ehcache's warning dropped — every JVM's stderr to `/dev/null`, its file left empty | `chk32 setup` (the loser's check) | `FAIL  Ehcache: stderr WARNING: by grep -c 0 = the WARNING: lines shown, > 0` |
| a typed jar count (`Caffeine adds` and a count of jars) | `s32` (R.302) and the R.302 grep | `R.302: a jar or byte count typed` |
| `pinned.txt` with one byte changed | the md5 (R.252) | `R.252: pinned.txt is not the pinned text` (the check now runs before the prose gate — `s32.py` reads `pinned.txt` too) |
| a wrong published hash (`setup` in `receipts.md5`) | `pub` | `setup is not the published capture` |
| a dish name in a README line | R.215 | `an Indian dish name` |
| a placeholder line | the placeholder grep | `a placeholder line in this unit's prose` |
| a changed What-it-prints line (`SOLUTION.md`) | the exercise check | `SOLUTION.md's "What it prints" block is not what the solution's lines printed` |
| a typed SQL string outside the captured blocks | R.225 | `a typed SQL string in README.md` |
| a duration word (`faster`) | `s32` (dur7, the pace words) | `dur7: faster` |
| R.301's family unscoped (`ten times`) | `s32` (R.301) | `R.301's family: ten times` |
| the exercise's solution = broken (the evict replaced by a comment, its What it prints set to the broken one's) | R.196 | `the broken read 2 the old value, a hit; the solution's read 2 the new value, a miss (R.196): FAIL` |
| the password in a log — the mask's password rule removed | the mask's self-test | `mask: the planted … the password … must be masked` |
| a byte added to the mirror's `c7-unit31/after/README.md` (a copy) | the tree pin (R.211) — a stop | `R.211: anchor/ … is not the tree this unit measured` |

**The R.211 note fires, not a stop:** a mirror whose `c7-tiffinbox` is a copy with one byte added to its `README.md` — the run went on to
the end, exit 0, every capture = published, the note on the terminal at the start and at the end (`anchor/ and ../c7-tiffinbox differ …`,
"a later anchor change has moved ../c7-tiffinbox on; no anchor change in this unit").

**Check plants** — `harness/chk32.py` run on a copy of a published capture with one thing changed (each exit 1):

| Plant | The failing line |
|---|---|
| the `create` run fed the default run's log, whole | `FAIL  create: the fifth key read off the run` |
| the `create` run fed the default run's three `HHH90001006` lines and its counts (its keys kept) | `FAIL  create: HHH90001006 by grep -c 0, WARN 0, the same regions` |
| the hit-ratio check fed K = 5's counts for K = 10 | `FAIL  K = 10: reads 20 = K x M = 10 x 4` |
| the Hibernate-edit step fed the native step's region counts (no put) | `FAIL  H2 (b3): the edit through Hibernate - put 1, one statement` |
| the database-truth line removed from a capture | `FAIL  PostgreSQL: the database-truth line, once` |
| a version line dropped — Spring Framework's `7.0.10`, `HHH000001`, Spring Data's `4.1.2`, each in turn | `FAIL  H2: the version line once: …` (each) |
| Ehcache's stderr lines removed and its counts set to 0 | `FAIL  Ehcache: stderr WARNING: by grep -c 0 …` |

**Not run as plants:** a check that cannot fail (R.276) is answered by the table above — every check named there failed on its plant;
a Spring cache abstraction sentence and a connection count unscoped are `s32.py` self-test cases only (refused there), not planted
into the README.

## CARRIED

- A cache on TiffinBox's own `CustomerEntity` — not adopted (⚑4's loser, argued, not measured on TiffinBox); a later course that caches
  TiffinBox re-measures there.
- Region configuration (sizes, expiry) for Caffeine — not set: `missing_cache_strategy=create` takes the provider's defaults.
  Expiry is for Course 8's lesson called Cache Invalidation.
- The query cache's default strategy warning (`HHH90001006` for its region with the strategy unset) — not measured: every query run
  carries `create`.

## For RED

- **The ratio is derived over a design where every read is its own transaction.** A page that reads many customers in one session would
  hit the first-level cache before the second-level one; the K × M design isolates the region on purpose (#1516's sentence). Attack the
  wording if a script line drops "in its own transaction".
- **The FIFO latch on macOS:** the JVM's stdin opened by the background subshell, the writer opened on fd 4 right after (each open waits
  for the other). An interrupt while the JVM waits on `System.in.read()` is one of the four SIGINT trials (Interrupted, above).
- **The hit ratio is a count ratio, formatted to three places by `chk32.py`** (`%.3f`): the two derivations must print the same string.
  The script may say it; it must not attach a duration meaning to it (dur7 words 0).
- **The bulk-update counter-cases are Hibernate 7.4.13's behaviour with no query spaces declared** on the native query; a native query
  that declares its spaces (`addSynchronizedEntityClass`) was not measured — "both miss" is said for the queries as written.
- **The trap's writer on H2 is in the same JVM** — plain JDBC on a second connection, still a write Hibernate never saw; PostgreSQL's is
  another process. The slide's hook is PostgreSQL's (two `database:` lines).
- **`s32.py`'s exemptions:** the brief's exercise sentence (its claim has no three readings in the sentence; its slide is the
  exercise's What it prints) and the pinned sentence (a definition, R.252) are exempt from the three-readings rule by name; every other
  claim of an old value served must carry them. The R.224 rule here is narrow: a lesson named by "called", or the next course by number, needs a known title in the same
  sentence (and line).
- **The jar counts printed in `setup` come from the build step's log**, not from a Maven run inside the capture (point 3 of What
  differed); `ls -l` and the marks run in every one of the three runs.
- **Ehcache's stderr lines are the JDK's** (`sun.misc.Unsafe`), on stderr: the plant "its stderr not captured" leaves the counts at 0 and the
  check exits 1.
- **The added set's basis is "a jar file name the anchor's `lib/` does not hold"** — same name, same version; a version clash would show
  as another jar of the same artifact (none here).
- **`s32.py` does not judge a code span** (a quoted token between backticks: a plant's sentence, a log line, a key) — the planted-fault
  table quotes the refused sentences that way; the receipt's R.302 (typed counts), R.225 (typed SQL) and R.303 (quoted warnings) greps
  still read every character of the README. A claim hidden in a code span would pass `s32` — read the spans.
- **The plants were run on the script one step before the committed one**: after them the R.252 check moved before the prose gate (the
  `pinned` plant re-run on the moved check: caught by the md5), and `s32.py` learned to skip code spans and to look for a title on the
  whole line; the five `s32` plants were re-run on the final `s32.py` (same verdicts).

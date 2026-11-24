# c8-unit27 — *Capstone: TiffinBox, Cached and Searchable*

Course 8, Section 5's third unit and its **second change to the anchor**: `before` is the link `../c8-unit26/after` (unit `26`'s
tree), `after/` is `../c8-tiffinbox` after this unit's change — five test files and the README. The three older ITs
(`CustomerEntityRepositoryIT`, `CustomerAggregatesIT`, `RedisDatastoreIT`) publish their container's port on `127.0.0.1` alone since,
and all five ITs print their own container's bindings, `IT BINDINGS`. `tiffinbox-core/` and `tiffinbox-web/src/main/` are byte-equal
before and after: the jar is the same jar.

The capstone's spine is **one jar, two runs**: the same `tiffinbox-web-1.0.0.jar` starts twice. The default run caches in Caffeine,
on H2 in memory. The profile "dev" runs on PostgreSQL, Redis, MongoDB and Elasticsearch, and caches in Redis. No run holds both caches. Then the tour of dev's routes, one row per
request with each store's own witness; the copies a write leaves; each store absent in turn; another `CacheManager` bean; and `bound`,
the anchor change measured by `mvn verify`.

Which store answered, in every line: **after/'s jar under "dev"** (`runs`' first half, `tour`, `copies`: TiffinBox on `20660`, its
PostgreSQL `20661`, Redis `20662`, MongoDB `20663`, Elasticsearch `20664`); **after/'s jar, the default run** (`runs`' second half,
`default`, the seven: `20665`, H2, no Docker reachable); **after/'s jar under "dev" on `20666`** (`absent`'s four starts and
`twocaches`' two, one at a time, on the same four stores); **the tests' copy** (`bound`: Testcontainers' own containers, the two pinned
ITs on `20578` and `20615`); **the exercise's own four stores** (`20661`-`20664`, its TiffinBox on `20666`). Every line the harness
prints begins "the harness's".

Nine captures. `runs`, `tour`, `copies` and `default` run three times inside each run of `receipts.sh` and are hashed
(`receipts.md5`): each of the three rounds starts one dev JVM, which serves `runs`' first half, the tour and the copies, and one
default JVM, which serves `runs`' second half and `default`. `exercise`, `absent`, `twocaches`, the seven and `bound` run once per run,
and their 3/3 is across the runs of record. Every number below is asserted after its capture by `harness/chk27.py`, re-derived from the
capture's own lines — never from this README's prose.

## Runs of record

Three runs of `receipts.sh` on 2026-11-24, each ending `c8-unit27: every capture = published …`, each log through
`check_unit8.py 27 --runlog` (`RESULT (run logs): PASS`; the unit gate itself exits `2` until the script stage writes unit `27`'s
script — expected). Every capture's md5 equals `receipts.md5`'s in all three; every build offline (`Downloaded from` none). The
launch rule is unit `23`'s (`c8-unit23/README.md:30`) as S8.112 tightened it: a run of record launches only while the first of the
machine's three load averages is below `20` and no other receipt is live, and the load is printed beside the run. Each run's launch
waited no check; `ElasticsearchIT` printed `Timed out waiting` in none of them — its log wait held at each load below. The three
load averages at each run's start and end:

| run | how | result | load at start | load at end |
|---|---|---|---|---|
| run1-bash32 | `./receipts.sh` — macOS's bash 3.2.57 | PASS | `2.74 4.10 4.17` | `3.85 3.90 4.07` |
| run2-bash53 | `/opt/homebrew/bin/bash receipts.sh` — Homebrew's bash 5.3.9 | PASS | `4.06 3.95 4.09` | `8.24 5.06 4.46` |
| run3-sealed | a sealed fresh clone in a path with a space (`sealed 27/`), `./receipts.sh`, `DOCKER_CONFIG=$HOME/.docker` | PASS | `7.88 5.09 4.48` | `4.79 4.59 4.43` |

Not runs of record, said so: four development runs of `receipts.sh` before these three found a lambda's address in the class-load
names, the `Allow` header's order moving between JVMs, the dish's highlighted name carrying the run's number, the static check
counting a Javadoc's `IT BINDINGS` and the harness's `TwoCaches` line that never prints — each fixed before run 1. The three runs
above ran on the files as committed but this section, the interrupted section and the plants' section, written after them; a last
check of the prose gate and the values block on the README as committed is in this commit's message.

## RE-MEASURE 6 — `runs`, `tour`, `default`, `copies`, `absent`, `twocaches` on 27/after (settled first)

Settled, 3/3. **One jar, two runs**: under "dev" the harness reads ONE `CacheManager` bean, `RedisCacheManager`, its caches
`[customer, customers]`, and the JVM's own class-load file lists `2` Caffeine classes (`Caffeine`, `Cache`) and no Caffeine cache; the
default run's one `CacheManager` is `CaffeineCacheManager`, with `93` Caffeine classes loaded. **The tour**, the list's key deleted first
(`DEL` answers `1`: the start had cached it): `GET /customers` reaches PostgreSQL with `3` non-empty statements. The
cache writer sends Redis `7` commands for it; the same read again: none in PostgreSQL, `2` commands in Redis. The leaderboard is one `ZREVRANGE … WITHSCORES`, Sunil first;
the menu one `find`, three items; the revenue one `aggregate`, `120` documents examined, `4` returned; the search two `_search`
requests; `/kitchen` answers `{"ordersCooked":120,"ordersValue":24300}`; `PATCH /customers` and `DELETE /customers/Ravi` answer `405`
with their `Allow` headers. **The default run**: Hibernate's SQL logger prints `1` line for the first read and none for the second;
Caffeine's own meters on `/actuator/prometheus` (for the caches `spring.cache.cache-names` names) move miss `1.0` to `2.0` and hit `0.0` to `1.0`; the five dev-only routes answer `404`,
`POST /dishes` among them. **The copies**: PostgreSQL's `COMMIT` comes first in both writes; then Redis's `XADD` and the cache writer's
evict for a customer, Elasticsearch's index document for a dish — `3` copies in `2` stores, MongoDB's profiler empty in both windows.
**A store absent**: four starts, each `exit 1`, each chain's first two beans read. **Another cache manager**: the "dev" start stops,
`exit 1`, no bean of type `CacheProperties`.

## RE-MEASURE 7 — `bound`: five `IT BINDINGS` lines on 127.0.0.1, `18` + `14`, the Elasticsearch IT's wait and the load (settled first)

Settled, once per run of record, 3/3 across them. `mvn verify` on a plain copy of after/ — no patch: the change is shipped. Maven's
Results lines read `Tests run: 18` and `Tests run: 14`, no failure and no error (`MongoDatastoreIT` `4`). Five `IT BINDINGS` lines from
five classes; `harness/chk27.py` parses every entry and counts the ones off `127.0.0.1`: none. Every Testcontainers container's host
address while the build ran (`docker -H "$DH" ps`, polled through the pinned socket) is `127.0.0.1`. `ElasticsearchIT` printed `Timed out
waiting` in no run: its log wait held at each run's load, printed in the table above. Nothing pulled, no Testcontainers container left.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

`diff -rq before/ after/` lists six files and nothing new: `84` files before, `84` after (`harness/tree27.py`); `tiffinbox-core/` and
`tiffinbox-web/src/main/` byte-equal, asserted before any build.

- `CustomerEntityRepositoryIT.java`, `jdbc/CustomerAggregatesIT.java`, `web/RedisDatastoreIT.java` — the container gains
  `.withCreateContainerCmdModifier(…)` with `Ports.Binding.bindIp("127.0.0.1")` on its one port (`5432`, `5432`, `6379`): the address
  named, the host port Docker's own, read by the service connection. The three `com.github.dockerjava.api.model` imports, as
  `MongoDatastoreIT` imports them; a *Course 8, unit 27* paragraph closing each class's Javadoc. `before/`'s three files hold no
  modifier: they published on every interface, Testcontainers' own default, which `MongoDatastoreIT`'s Javadoc in `before/` states
  (read off `../c8-unit18`'s capture there) — read, never re-run: no container of this unit publishes on every interface (RED #2).
- all five, the three above and `web/MongoDatastoreIT.java`, `web/ElasticsearchIT.java` — one `@BeforeAll` method, `printBindings()`,
  prints `IT BINDINGS <class> [<port>/tcp -> <host address>:<host port>]` off `getContainerInfo()`, an entry for each exposed port Docker
  bound (the `@BeforeAll` form, one for all five, chosen over a first test's first line: it prints once per class whatever the test
  order); its imports `org.junit.jupiter.api.BeforeAll` and `java.util.TreeSet` where the file lacked them. `MongoDatastoreIT`'s and
  `ElasticsearchIT`'s own bindings lines stay beside it.
- `README.md` (the anchor's) — unit `27`'s card (the house form of unit `26`'s), and four notes, found with `git grep -n` over
  `c8-tiffinbox/` for `every interface`, `names the address`, `Testcontainers' default`, `Docker's own record`, `bindIpAndPort`,
  `0.0.0.0` and the three class names: the `MongoDatastoreIT` card's "Testcontainers 2.0.5 publishes on every interface unless the test
  names the address" gains a dated *Course 8, unit 27* note (every IT names it since); the three rebound ITs' cards (`CustomerAggregatesIT`
  in unit `07`'s card, `RedisDatastoreIT` in unit `14`'s, `CustomerEntityRepositoryIT` in the card Course 7's own README holds) each gain "*(Course 8,
  unit 27 binds it to 127.0.0.1)*" where the card describes the container. Not touched, said: the `0.0.0.0` lines are TiffinBox's own
  Tomcat and its image (`TIFFINBOX_ADDRESS`), not the ITs'; the `18 + 14` lines stay true. `harness/chk27.py static` asserts every
  README line with the every-interface sentence carries its unit `27` note, and the three card notes.

R.211/R.331: every shipped builder (`spring-data-beyond-jpa/_builders/s8*.py`) and every shipped `c8-unit*/receipts.sh` and `harness/*`
grepped for the five IT names, `bindIp` and `IT BINDINGS`: the matches are units `22`, `25` and `26`'s, each on a frozen tree pinned to its
commit (`22`'s harness reads `ElasticsearchIT` on `22/after`, `25`'s and `26`'s `it-bindings.patch` on copies of `24/after` and
`26/after`) — nothing they read moves.

## The captures — what each one shows

### 1 · runs — one jar, two runs (S8.105 = R.473)

```text
-- runs: one jar, two runs - after/'s jar (tiffinbox-web-1.0.0.jar, md5 a2b379dc6afc1b87aef5248e20bb0621), started twice, the harness's CacheBeans joined to both:
$ cd .harness/run-dev && perl -e '$SIG{INT}="DEFAULT"; alarm 400; exec @ARGV' java -Duser.language=en -Duser.country=US -Xlog:class+load=info:file=<capture dir>/classload.txt -cp "../hc:<after/'s jar>:<its lib/*>" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20660 --spring.profiles.active=dev --spring.docker.compose.enabled=false <the four stores' addresses by property, 127.0.0.1:20661-20664> --spring.main.sources=probe.u27.CacheBeans --logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE
$ cd .harness/after && DOCKER_HOST=tcp://127.0.0.1:1 perl -e '$SIG{INT}="DEFAULT"; alarm 300; exec @ARGV' java -Duser.language=en -Duser.country=US -Xlog:class+load=info:file=<capture dir>/classload.txt -cp "../hc:<the jar>:<its lib/*>" com.tiffinbox.web.TiffinBoxServer --logging.config=../../harness/logback.xml --tiffinbox.port=20665 --spring.main.sources=probe.u27.CacheBeans
== under dev (20660): exit 0 · listening on: 127.0.0.1:20660
  the harness's CacheManager beans 1: [cacheManager = org.springframework.data.redis.cache.RedisCacheManager caches [customer, customers]]
  the harness's cache customers in cacheManager: org.springframework.data.redis.cache.RedisCache · writes through org.springframework.data.redis.cache.DefaultRedisCacheWriter
  Caffeine classes loaded (the JVM's own -Xlog:class+load file, its com.github.benmanes.caffeine lines): 2 - cache.Cache, cache.Caffeine
== the default run (20665): exit 0 · listening on: 127.0.0.1:20665
  the harness's CacheManager beans 1: [cacheManager = org.springframework.cache.caffeine.CaffeineCacheManager caches [customer, customers]]
  the harness's cache customers in cacheManager: org.springframework.cache.caffeine.CaffeineCache · writes through com.github.benmanes.caffeine.cache.BoundedLocalCache$BoundedLocalManualCache
  Caffeine classes loaded (the JVM's own -Xlog:class+load file, its com.github.benmanes.caffeine lines): 93 - cache.AbstractLinkedDeque, cache.AccessOrderDeque, cache.AccessOrderDeque$AccessOrder, cache.AsyncCache, cache.AsyncCacheLoader, cache.AsyncLoadingCache, cache.BLCHeader$DrainStatusRef, cache.BLCHeader$PadDrainStatus, cache.BaseMpscLinkedArrayQueue, cache.BaseMpscLinkedArrayQueueColdProducerFields, cache.BaseMpscLinkedArrayQueueConsumerFields, cache.BaseMpscLinkedArrayQueuePad1, cache.BaseMpscLinkedArrayQueuePad2, cache.BaseMpscLinkedArrayQueuePad3, cache.BaseMpscLinkedArrayQueueProducerFields, cache.BoundedBuffer, cache.BoundedLocalCache, cache.BoundedLocalCache$$Lambda/<address>, cache.BoundedLocalCache$$Lambda/<address>, cache.BoundedLocalCache$$Lambda/<address>, cache.BoundedLocalCache$$Lambda/<address>, cache.BoundedLocalCache$AddTask, cache.BoundedLocalCache$BoundedLocalAsyncLoadingCache, cache.BoundedLocalCache$BoundedLocalManualCache, cache.BoundedLocalCache$BoundedLocalManualCache$$Lambda/<address>, cache.BoundedLocalCache$BoundedPolicy, cache.BoundedLocalCache$ComputeContext, cache.BoundedLocalCache$EvictContext, cache.BoundedLocalCache$PerformCleanupTask, cache.Buffer, cache.Cache, cache.CacheLoader, cache.Caffeine, cache.Caffeine$$Lambda/<address>, cache.CaffeineSpec, cache.DisabledScheduler, cache.Expiry, cache.FrequencySketch, cache.LinkedDeque, cache.LinkedDeque$PeekingIterator, cache.LoadingCache, cache.LocalAsyncCache, cache.LocalAsyncLoadingCache, cache.LocalCache, cache.LocalCache$$Lambda/<address>, cache.LocalCacheFactory, cache.LocalCacheFactory$$Lambda/<address>, cache.LocalLoadingCache, cache.LocalManualCache, cache.MpscChunkedArrayQueue, cache.MpscChunkedArrayQueueColdProducerFields, cache.MpscGrowableArrayQueue, cache.Node, cache.NodeFactory, cache.NodeFactory$$Lambda/<address>, cache.NodeFactory$DeadStrongKey, cache.NodeFactory$DeadWeakKey, cache.NodeFactory$RetiredStrongKey, cache.NodeFactory$RetiredWeakKey, cache.PS, cache.PSW, cache.PSWMS, cache.Policy, cache.Policy$CacheEntry, cache.References$InternalReference, cache.References$WeakKeyReference, cache.RemovalCause, cache.RemovalCause$1, cache.RemovalCause$2, cache.RemovalCause$3, cache.RemovalCause$4, cache.RemovalCause$5, cache.RemovalListener, cache.SS, cache.SS$$Lambda/<address>, cache.SSS, cache.SSS$$Lambda/<address>, cache.SSSMS, cache.SSSMS$$Lambda/<address>, cache.SSSMSW, cache.SSSMSW$$Lambda/<address>, cache.Scheduler, cache.SingletonWeigher, cache.StripedBuffer, cache.SystemTicker, cache.Ticker, cache.UnboundedLocalCache$UnboundedLocalAsyncLoadingCache, cache.Weigher, cache.WriteOrderDeque, cache.WriteOrderDeque$WriteOrder, cache.stats.CacheStats, cache.stats.ConcurrentStatsCounter, cache.stats.StatsCounter
```

The harness's `CacheBeans` reads the running context: the `CacheManager` beans, the customers cache and the object it writes through.
The Caffeine count is the JVM's own `-Xlog:class+load` file, its `com.github.benmanes.caffeine` lines (a lambda's hidden class carries
an address the JVM picks: masked `<address>`, the count kept). Under "dev" Caffeine's library is loaded for its two classes and builds
no Caffeine cache; each run's control is the other run.

### 2 · tour — dev's routes, one request at a time

```text
-- tour: the dev JVM on 20660, one request at a time; each between its own markers in PostgreSQL's log and in Redis's MONITOR, MongoDB's profiler on for that call alone, the client's trace by the JVM log's line numbers:
  before the first: redis-cli DEL 'customers::SimpleKey []' -> 1 (the start and the readiness check had cached the list - RED #3)
== c1 GET /customers -> 200 · PostgreSQL 3 (non-empty statements; raw 4) · Redis 7 · MongoDB 0 · Elasticsearch 0
   pg     BEGIN READ ONLY
   pg     select ce1_0.id,ce1_0.created_at,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.updated_at,ce1_0.version from customer ce1_
   pg     COMMIT
   redis  "EXISTS" "customers~lock"
   redis  "GET" "customers::SimpleKey []"
   redis  "EXISTS" "customers~lock"
   redis  "SET" "customers~lock" "" "NX"
   redis  "GET" "customers::SimpleKey []"
   redis  "SET" "customers::SimpleKey []" "[\"java.util.ArrayList\",[{\"@class\":\"com.tiffinbox.Customer\",\"name\":\"Meera\",\"m
   redis  "DEL" "customers~lock"
   answer Content-Type: application/json · [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
== c2 GET /customers -> 200 · PostgreSQL 0 (non-empty statements; raw 0) · Redis 2 · MongoDB 0 · Elasticsearch 0
   redis  "EXISTS" "customers~lock"
   redis  "GET" "customers::SimpleKey []"
   answer Content-Type: application/json · [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
== lb GET /leaderboard -> 200 · PostgreSQL 0 (non-empty statements; raw 0) · Redis 1 · MongoDB 0 · Elasticsearch 0
   redis  "ZREVRANGE" "tiffinbox:leaderboard" "0" "-1" "WITHSCORES"
   answer Content-Type: application/json · {"Sunil":9000.0,"Ravi":7200.0,"Meera":4500.0,"Priya":3600.0}
== menu GET /menu/day-19 -> 200 · PostgreSQL 0 (non-empty statements; raw 0) · Redis 0 · MongoDB 1 · Elasticsearch 0
   mongo  query find on tiffinbox.menu · nreturned 1 · docsExamined 1
   answer Content-Type: application/json · {"id":"day-19","items":[{"mealType":"VEG","name":"Vegetable curry with rice","price":110,"allergens":["milk","mustard"]},{"mealType":"NON_VEG","name":"Grilled chicken with rice","price":160,"allergens":["celery"]},{"mealType":"VEGAN","name":"Chickpea and tofu stew","price":130,"allergens":["soy"]}]}
== rev GET /revenue/by-customer -> 200 · PostgreSQL 0 (non-empty statements; raw 0) · Redis 0 · MongoDB 1 · Elasticsearch 0
   mongo  command aggregate on tiffinbox.orders · nreturned 4 · docsExamined 120
   answer Content-Type: application/json · [{"customer":"Sunil","total":9000},{"customer":"Ravi","total":7200},{"customer":"Meera","total":4500},{"customer":"Priya","total":3600}]
== search GET /dishes/search?q=veg -> 200 · PostgreSQL 0 (non-empty statements; raw 0) · Redis 0 · MongoDB 0 · Elasticsearch 2
   es     POST /dishes/_search?search_type=query_then_fetch&typed_keys=true
   es     POST /dishes/_search?search_type=query_then_fetch&typed_keys=true
   answer Content-Type: application/json · [{"id":"1","name":"Vegetarian Lunch Box","fragment":["<em>Vegetarian</em> Lunch Box"]}]
== kitchen GET /kitchen -> 200 · PostgreSQL 0 (non-empty statements; raw 0) · Redis 0 · MongoDB 0 · Elasticsearch 0
   answer Content-Type: application/json · {"ordersCooked":120,"ordersValue":24300}
== patch PATCH /customers -> 405 · PostgreSQL 0 (non-empty statements; raw 0) · Redis 0 · MongoDB 0 · Elasticsearch 0
   answer Allow (sorted): GET, POST · Content-Type: application/problem+json · {"detail":"Method 'PATCH' is not supported.","instance":"/customers","status":405,"title":"Method Not Allowed"}
== delete DELETE /customers/Ravi -> 405 · PostgreSQL 0 (non-empty statements; raw 0) · Redis 0 · MongoDB 0 · Elasticsearch 0
   answer Allow (sorted): GET · Content-Type: application/problem+json · {"detail":"Method 'DELETE' is not supported.","instance":"/customers/Ravi","status":405,"title":"Method Not Allowed"}
```

Each row is one request between its own markers: a `redis-cli ECHO` and a `psql` select before it and after it, so PostgreSQL's
`log_statement=all` lines and Redis's `MONITOR` lines are read inside the window alone; MongoDB's profiler is on for that call alone
(dropped and set to `2` before, read and set to `0` after, by `mongosh`); the Elasticsearch client's own trace lines are the JVM log's
lines between the request's first and last. PostgreSQL's count is its non-empty statements: Hikari's connection check, an empty
statement, lands in a window, and the raw count stands beside. No request is sent while another's window is open, and readiness is
read before the first marker.

### 3 · copies — the map of copies (S8.106 = R.474)

A system of record: the store a change is written to first; a copy or a cache in another store is written from it, after the commit.

```text
-- copies: the same dev JVM after the tour's reads; each write between its own markers, then the read after it:
== addc POST /customers -> 201 · PostgreSQL 3 (non-empty statements; raw 4) · Redis 6 · MongoDB 0 · Elasticsearch 0
   pg     BEGIN
   pg     insert into customer (created_at,meal_type,meals_per_day,name,price_per_meal,updated_at,version) values ($1,$2,$3,$4,$5,$6,$7)
   pg     COMMIT
   redis  "XADD" "tiffinbox:kitchen-events" "*" "type" "customer-added" "name" "Probe<run>" "mealType" "VEG"
   redis  "EXISTS" "customers~lock"
   redis  "SET" "customers~lock" "" "NX"
   redis  "KEYS" "customers::*"
   redis  "DEL" "customers::SimpleKey []"
   redis  "DEL" "customers~lock"
   answer Content-Type: application/json · {"name":"Probe<run>","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}
   the witnesses' order (each event placed by its own log's clock; the times not printed): PostgreSQL BEGIN · PostgreSQL insert into customer · PostgreSQL COMMIT · Redis XADD tiffinbox:kitchen-events · Redis EXISTS customers~lock · Redis SET customers~lock · Redis KEYS customers::* · Redis DEL customers::SimpleKey [] · Redis DEL customers~lock
== c3 GET /customers -> 200 · PostgreSQL 3 (non-empty statements; raw 4) · Redis 7 · MongoDB 0 · Elasticsearch 0
   pg     BEGIN READ ONLY
   pg     select ce1_0.id,ce1_0.created_at,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.updated_at,ce1_0.version from customer ce1_
   pg     COMMIT
   redis  "EXISTS" "customers~lock"
   redis  "GET" "customers::SimpleKey []"
   redis  "EXISTS" "customers~lock"
   redis  "SET" "customers~lock" "" "NX"
   redis  "GET" "customers::SimpleKey []"
   redis  "SET" "customers::SimpleKey []" "[\"java.util.ArrayList\",[{\"@class\":\"com.tiffinbox.Customer\",\"name\":\"Meera\",\"m
   redis  "DEL" "customers~lock"
   answer Content-Type: application/json · [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Probe<run>","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
== addd POST /dishes -> 201 · PostgreSQL 3 (non-empty statements; raw 4) · Redis 0 · MongoDB 0 · Elasticsearch 2
   pg     BEGIN
   pg     insert into dish (meal_type,name,price) values ($1,$2,$3)
   pg     COMMIT
   es     PUT /dishes/_doc/11?refresh=false
   es     POST /dishes/_refresh
   answer Content-Type: application/json · {"id":11,"name":"Probe Dish <run>","mealType":"VEG","price":110}
   the witnesses' order (each event placed by its own log's clock; the times not printed): PostgreSQL BEGIN · PostgreSQL insert into dish · PostgreSQL COMMIT · Elasticsearch PUT /dishes/_doc/11?refresh=false · Elasticsearch POST /dishes/_refresh
== search2 GET /dishes/search?q=probe -> 200 · PostgreSQL 0 (non-empty statements; raw 0) · Redis 0 · MongoDB 0 · Elasticsearch 2
   es     POST /dishes/_search?search_type=query_then_fetch&typed_keys=true
   es     POST /dishes/_search?search_type=query_then_fetch&typed_keys=true
   answer Content-Type: application/json · [{"id":"11","name":"Probe Dish <run>","fragment":["<em>Probe</em> Dish <run>"]}]
  the writers, read off the running context (the harness's CacheBeans):
    the harness's cache customers in cacheManager: org.springframework.data.redis.cache.RedisCache · writes through org.springframework.data.redis.cache.DefaultRedisCacheWriter
    the harness's listeners for a committed transaction 3:
    the harness's   bean customerFeed (com.tiffinbox.web.CustomerFeed) stored[CustomerAdded] phase AFTER_COMMIT
    the harness's   bean dishIndexSync (com.tiffinbox.web.DishIndexSync) copy[DishSaved] phase AFTER_COMMIT
    the harness's   bean kitchenEvents (com.tiffinbox.web.KitchenEvents) stored[CustomerAdded] phase AFTER_COMMIT
```

The order is the witnesses' own: each log's sequence, and the three logs merged by each event's own clock, the times never printed and
never said. The writers are read off the running context: `KitchenEvents.stored` and `DishIndexSync.copy` listen for a committed
transaction (`AFTER_COMMIT`), and the customers cache writes through `DefaultRedisCacheWriter`. A third listener, `CustomerFeed`, hears
the same event and writes to no store. PostgreSQL holds the row inside its transaction; after the commit one copying store per write.

### 4 · default — the default run's tour

```text
-- default: the default run's JVM on 20665 (H2 in memory, Caffeine), one request at a time; Hibernate's SQL logger's lines (the harness's logback) by the JVM log's line numbers:
  the harness's CacheManager beans 1: [cacheManager = org.springframework.cache.caffeine.CaffeineCacheManager caches [customer, customers]]
== addc POST /customers -> 201 · Hibernate SQL lines 1 · Content-Type: application/json · {"name":"Probe<run>","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}
  /actuator/prometheus, cache_gets_total for customers, before the two reads: cache=customers,cache_manager=cacheManager,name=customers,result=hit} 0.0 · cache=customers,cache_manager=cacheManager,name=customers,result=miss} 1.0
== c1 GET /customers -> 200 · Hibernate SQL lines 1 · Content-Type: application/json · [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"nam
== c2 GET /customers -> 200 · Hibernate SQL lines 0 · Content-Type: application/json · [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"nam
  /actuator/prometheus, cache_gets_total for customers, after them: cache=customers,cache_manager=cacheManager,name=customers,result=hit} 1.0 · cache=customers,cache_manager=cacheManager,name=customers,result=miss} 2.0
== lb GET /leaderboard -> 404 · Hibernate SQL lines 0 · Content-Type: application/problem+json · {"detail":"No static resource leaderboard.","instance":"/leaderboard","status":404,"title":"Not Found"}
== menu GET /menu/day-19 -> 404 · Hibernate SQL lines 0 · Content-Type: application/problem+json · {"detail":"No static resource menu/day-19.","instance":"/menu/day-19","status":404,"title":"Not Found"}
== rev GET /revenue/by-customer -> 404 · Hibernate SQL lines 0 · Content-Type: application/problem+json · {"detail":"No static resource revenue/by-customer.","instance":"/revenue/by-customer","status":404,"title":"Not Found"}
== search GET /dishes/search?q=veg -> 404 · Hibernate SQL lines 0 · Content-Type: application/problem+json · {"detail":"No static resource dishes/search.","instance":"/dishes/search","status":404,"title":"Not Found"}
== addd POST /dishes -> 404 · Hibernate SQL lines 0 · Content-Type: application/problem+json · {"detail":"No static resource dishes.","instance":"/dishes","status":404,"title":"Not Found"}
== patch PATCH /customers -> 405 · Hibernate SQL lines 0 · Allow (sorted): GET, POST · Content-Type: application/problem+json · {"detail":"Method 'PATCH' is not supported.","instance":"/customers","status":405,"title":"Method Not Allowed"}
== delete DELETE /customers/Ravi -> 405 · Hibernate SQL lines 0 · Allow (sorted): GET · Content-Type: application/problem+json · {"detail":"Method 'DELETE' is not supported.","instance":"/customers/Ravi","status":405,"title":"Method Not Allowed"}
== cust GET /customers/Ravi -> 200 · Hibernate SQL lines 1 · Content-Type: application/json · {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}
== apidocs GET /v3/api-docs -> 404 · Hibernate SQL lines 0 · Content-Type: application/problem+json · {"detail":"No static resource v3/api-docs.","instance":"/v3/api-docs","status":404,"title":"Not Found"}
== swagger GET /swagger-ui.html -> 404 · Hibernate SQL lines 0 · Content-Type: application/problem+json · {"detail":"No static resource swagger-ui.html.","instance":"/swagger-ui.html","status":404,"title":"Not Found"}
```

### 5 · absent — a store absent, four starts

```text
-- absent: after/'s jar under dev on 20666 (Boot's own logging), one store's address moved to 127.0.0.1:20669 - nothing listens there - the other three up, one start each:
== absent pg: listening on 20669 before the start: 0 (lsof) · each key once on the command line: tiffinbox.jdbc-url=<20669> spring.data.redis.port=<its store> spring.mongodb.uri=<its store> spring.elasticsearch.uris=<its store>
  exit 1 · 'Started TiffinBoxServer' 0 · 'Application run failed' 1 · 'APPLICATION FAILED TO START' 0 · Flyway's lines (applied / up to date) 0
  the chain's first two beans: entityManagerFactory <- flywayInitializer
  the first 'Error creating bean with name' line, from its exception's name: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'entityManagerFactory' defined in class path resource [org/springframework/boot/hibernate/autoconfigure/HibernateJpaConfiguration.class]: Failed to initialize dependency 'flywayInitializer' of LoadTimeWeaverAware bean 'entityManagerFactory': Error creating bean with name 'flywayInitializer' defined in class path resource [org/springframework/boot/flyway/autoconfigure/FlywayAutoConfiguration$FlywayConfiguration.class]: Unable to obtain connection from database: Connection to 127.0.0.1:20669 refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.
  Caused by: org.postgresql.util.PSQLException: Connection to 127.0.0.1:20669 refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.
  Caused by: java.net.ConnectException: Connection refused (connect failed)
== absent redis: listening on 20669 before the start: 0 (lsof) · each key once on the command line: tiffinbox.jdbc-url=<its store> spring.data.redis.port=<20669> spring.mongodb.uri=<its store> spring.elasticsearch.uris=<its store>
  exit 1 · 'Started TiffinBoxServer' 0 · 'Application run failed' 1 · 'APPLICATION FAILED TO START' 0 · Flyway's lines (applied / up to date) 1
  the chain's first two beans: tiffinBoxServer
  the first 'Error creating bean with name' line, from its exception's name: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed
  Caused by: io.netty.channel.AbstractChannel$AnnotatedConnectException: Connection refused (connect failed): /127.0.0.1:20669
  Caused by: java.net.ConnectException: Connection refused (connect failed)
== absent es: listening on 20669 before the start: 0 (lsof) · each key once on the command line: tiffinbox.jdbc-url=<its store> spring.data.redis.port=<its store> spring.mongodb.uri=<its store> spring.elasticsearch.uris=<20669>
  exit 1 · 'Started TiffinBoxServer' 0 · 'Application run failed' 1 · 'APPLICATION FAILED TO START' 0 · Flyway's lines (applied / up to date) 1
  the chain's first two beans: dishIndexSync <- dishes
  the first 'Error creating bean with name' line, from its exception's name: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'dishIndexSync' defined in URL [jar:file:…/.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar!/com/tiffinbox/web/DishIndexSync.class]: Unsatisfied dependency expressed through constructor parameter 0: Error creating bean with name 'dishes' defined in com.tiffinbox.web.Dishes defined in @EnableElasticsearchRepositories declared on DataElasticsearchRepositoriesRegistrar.EnableElasticsearchRepositoriesConfiguration: Failed to instantiate [org.springframework.data.elasticsearch.repository.support.SimpleElasticsearchRepository]: Constructor threw exception
  Caused by: java.net.ConnectException: Connect to http://127.0.0.1:20669 [/127.0.0.1] failed: Connection refused (connect failed)
  Caused by: org.apache.hc.client5.http.HttpHostConnectException: Connect to http://127.0.0.1:20669 [/127.0.0.1] failed: Connection refused (connect failed)
== absent mongo: listening on 20669 before the start: 0 (lsof) · each key once on the command line: tiffinbox.jdbc-url=<its store> spring.data.redis.port=<its store> spring.mongodb.uri=<20669> spring.elasticsearch.uris=<its store>
  exit 1 · 'Started TiffinBoxServer' 0 · 'Application run failed' 1 · 'APPLICATION FAILED TO START' 0 · Flyway's lines (applied / up to date) 1
  the chain's first two beans: menus <- mongoTemplate
  the first 'Error creating bean with name' line, from its exception's name: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'menus' defined in URL [jar:file:…/.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar!/com/tiffinbox/web/Menus.class]: Unsatisfied dependency expressed through constructor parameter 0: Error creating bean with name 'mongoTemplate' defined in class path resource [org/springframework/boot/data/mongodb/autoconfigure/MongoDatabaseFactoryDependentConfiguration.class]: Failed to instantiate [org.springframework.data.mongodb.core.MongoTemplate]: Factory method 'mongoTemplate' threw exception with message: Timed out while waiting for a server that matches WritableServerSelector. Client view of cluster state is {type=UNKNOWN, servers=[{address=127.0.0.1:20669, type=UNKNOWN, state=CONNECTING, exception={com.mongodb.MongoSocketOpenException: Exception opening socket}, caused by {java.net.ConnectException: Connection refused (connect failed)}}]
  Caused by: org.springframework.dao.DataAccessResourceFailureException: Timed out while waiting for a server that matches WritableServerSelector. Client view of cluster state is {type=UNKNOWN, servers=[{address=127.0.0.1:20669, type=UNKNOWN, state=CONNECTING, exception={com.mongodb.MongoSocketOpenException: Exception opening socket}, caused by {java.net.ConnectException: Connection refused (connect failed)}}]
  Caused by: com.mongodb.MongoTimeoutException: Timed out while waiting for a server that matches WritableServerSelector. Client view of cluster state is {type=UNKNOWN, servers=[{address=127.0.0.1:20669, type=UNKNOWN, state=CONNECTING, exception={com.mongodb.MongoSocketOpenException: Exception opening socket}, caused by {java.net.ConnectException: Connection refused (connect failed)}}]
```

Boot `4.1` prints `Application run failed`, not a failure report, for these four: the outermost exception's first `Error creating
bean` line names the chain, and the last two `Caused by:` lines name the client's own exception. Earlier units' `absent` captures,
cited by name: `c8-unit14/receipts.md5` `absent` (Redis absent: `tiffinBoxServer`, the same bean here), `c8-unit18/receipts.md5`
`absent` (MongoDB absent: the driver's `MongoTimeoutException`; here the chain starts at `menus` ← `mongoTemplate`), `c8-unit22/receipts.md5`
`absent` (Elasticsearch absent: the bean `dishes`; here `dishIndexSync`, which takes `dishes`, is the chain's first — unit `22`'s
listener is made before the repository now). The control is `runs`: after/'s start with all four.

### 6 · twocaches — another `CacheManager` bean stops the "dev" start (the failure receipt)

```text
-- twocaches: after/'s jar under dev on 20666 (Boot's own logging), the harness's CacheBeans and TwoCaches joined - a second CacheManager bean, localCaches:
== twocaches, dynamic names:
$ cd .harness/run-dev && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:<after/'s jar>:<its lib/*>" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20666 --spring.profiles.active=dev --spring.docker.compose.enabled=false <the four stores' addresses by property, 127.0.0.1:20661-20664> --spring.main.sources=probe.u27.CacheBeans,probe.u27.TwoCaches
  exit 1 · 'Started TiffinBoxServer' 0 · 'APPLICATION FAILED TO START' 1 · 'Application run failed' 0
  the harness's TwoCaches lines in the log: 0 (the bean's definition is in the context; its method never ran - the start stopped first)
  the first exception's class and bean: org.springframework.beans.factory.UnsatisfiedDependencyException · redisCacheConfiguration
  Description: Parameter 0 of method redisCacheConfiguration in com.tiffinbox.web.RedisCaching required a bean of type 'org.springframework.boot.cache.autoconfigure.CacheProperties' that could not be found.
== twocaches, menu names (--probe.twocaches.names=menu):
$ cd .harness/run-dev && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:<after/'s jar>:<its lib/*>" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20666 --spring.profiles.active=dev --spring.docker.compose.enabled=false <the four stores' addresses by property, 127.0.0.1:20661-20664> --spring.main.sources=probe.u27.CacheBeans,probe.u27.TwoCaches --probe.twocaches.names=menu
  exit 1 · 'Started TiffinBoxServer' 0 · 'APPLICATION FAILED TO START' 1 · 'Application run failed' 0
  the harness's TwoCaches lines in the log: 0 (the bean's definition is in the context; its method never ran - the start stopped first)
  the first exception's class and bean: org.springframework.beans.factory.UnsatisfiedDependencyException · redisCacheConfiguration
  Description: Parameter 0 of method redisCacheConfiguration in com.tiffinbox.web.RedisCaching required a bean of type 'org.springframework.boot.cache.autoconfigure.CacheProperties' that could not be found.
  Boot's CacheAutoConfiguration, its class-level conditions (javap -v, after/'s own BOOT-INF/lib/spring-boot-cache-4.1.2.jar):
    org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean(
    value=[class Lorg/springframework/cache/CacheManager;]
    name=["cacheResolver"]
    )
    org.springframework.boot.context.properties.EnableConfigurationProperties(
    value=[class Lorg/springframework/boot/cache/autoconfigure/CacheProperties;]
    )
```

Boot's `CacheAutoConfiguration` backs off when a `CacheManager` bean exists, and it is the class that enables `CacheProperties`;
`RedisCaching`'s method asks for that bean, and the start stops. The bean is said as another `CacheManager` BEAN only: a
`CachingConfigurer` whose `cacheManager()` names one of two managers was not measured (RED #19, carried). The control is `runs`' dev
start.

### 7 · seven — the comparison set on after/'s jar

```text
-- the seven: after/'s jar, java -jar, H2 in memory (a fresh JVM), port 20665:
$ cd .harness/after && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20665
  GET /actuator/health/readiness -> 200 · listens on: 127.0.0.1:20665
$ $CURLSET 20665 .harness/after/secrets/tiffinbox/shutdown-token
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20665 now: 0
```

`before/`'s `src/main` is byte-equal to after/'s (asserted at the start and in `bound`), so the seven on `before/` is unit `26`'s
capture, cited by name (`c8-unit26/receipts.md5` `seven`), not re-run.

### 8 · bound — the anchor change, measured (S8.107 = R.475)

```text
-- bound: the change - before/ (the link ../c8-unit26/after, unit 26's tree) against after/ (diff -rq; then each file's changed lines, diff -u):
  changed: README.md
  changed: tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java
  changed: tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java
  changed: tiffinbox-web/src/test/java/com/tiffinbox/web/ElasticsearchIT.java
  changed: tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java
  changed: tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java
    README.md: +35 -4
    tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java: +20 -1
    tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java: +20 -1
    tiffinbox-web/src/test/java/com/tiffinbox/web/ElasticsearchIT.java: +12 -0
    tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java: +12 -0
    tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java: +19 -1
  the trees (python3 -I harness/tree27.py, links followed): before/ 84 eacca757e60a03fb5aa5fd3e5234a8bb · after/ 84 9864415b30d2d71a624bd74102e20be8
  under tiffinbox-core/ and tiffinbox-web/src/main/: 0 + 0 files differ - the jar's sources byte-equal
  before/'s three older ITs, their modifier (grep -c withCreateContainerCmdModifier): CustomerEntityRepositoryIT 0 · CustomerAggregatesIT 0 · RedisDatastoreIT 0 - Testcontainers' default, read off MongoDatastoreIT's Javadoc in before/: Testcontainers 2.0.5 publishes a container's port on every interface
  the static check (grep -c, after/'s five IT files - the address named, and the line): CustomerEntityRepositoryIT 1/1 · CustomerAggregatesIT 1/1 · RedisDatastoreIT 1/1 · MongoDatastoreIT 1/1 · ElasticsearchIT 1/1 · -> 1 1 1 1 1
-- bound: mvn verify on .harness/tests, a plain copy of after/ (the change is shipped - no patch):
  the copy against after/ (diff -rq, target and secrets left out): 0 files differ
  before it: listening on 20578 (MongoDatastoreIT's pinned binding): 0 · on 20615 (ElasticsearchIT's): 0 · on 18881-18884: 0
$ cd .harness/tests && DOCKER_HOST=$DH TESTCONTAINERS_RYUK_DISABLED=true env "MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8" perl -e '$SIG{INT}="DEFAULT"; alarm 900; exec @ARGV' mvn -o -B -Dmaven.repo.local="$M2" "-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home" clean verify -pl tiffinbox-web -am   (its alarm's cap: 900, R.247 - five ITs and an Elasticsearch start)
  exit 0 · BUILD SUCCESS · offline: yes
  after it: images 9 (the same list) · volumes 315 (the count before it) · Testcontainers containers 0 · .m2-demo's files unchanged
  the Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  the Results line: Tests run: 14, Failures: 0, Errors: 0, Skipped: 0
  MongoDatastoreIT: Tests run: 4, Failures: 0, Errors: 0, Skipped: 0 -- in com.tiffinbox.web.MongoDatastoreIT
  the IT BINDINGS lines (each IT's own container, Docker's inspect, sorted; the host port masked):
    IT BINDINGS CustomerAggregatesIT [5432/tcp -> 127.0.0.1:<port>]
    IT BINDINGS CustomerEntityRepositoryIT [5432/tcp -> 127.0.0.1:<port>]
    IT BINDINGS ElasticsearchIT [9200/tcp -> 127.0.0.1:<port>]
    IT BINDINGS MongoDatastoreIT [27017/tcp -> 127.0.0.1:<port>]
    IT BINDINGS RedisDatastoreIT [6379/tcp -> 127.0.0.1:<port>]
  the Testcontainers containers' ports while verify ran (dk ps, polled), each distinct host address: 127.0.0.1 · their images: 05b334b0a7a7 77f585114c32 7958cfbb9d15 fb7f2d0df199 · 18881-18884 bound during it: no
  ElasticsearchIT: 'Timed out waiting' lines 0 · its container started: 1 · 'Creating container for image' 5 · 'Pulling' 0 · Testcontainers containers after it: 0 · listening on 20578 and 20615 after it: 0
```

### 9 · exercise — the extra cache manager, removed

```text
exercise/README.md's 16 lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:
the solution's line that differs:
  $ rm -f "$EX/tb/$W/LocalCacheConfig.java"
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
    built: 1 jar
    check: the start: failed - Parameter 0 of method redisCacheConfiguration in com.tiffinbox.web.RedisCaching required a bean of type 'org.springframework.boot.cache.autoconfigure.CacheProperties' that could not be found. · the reads: none · solved: no
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    check: the start: started · DEL customers::SimpleKey [] -> 1 · GET /customers twice: PostgreSQL 3 then 0 statements · Redis EXISTS customers::SimpleKey [] -> 1 · solved: yes
  the shell is now in: this unit's folder · listening on 20661-20666 afterwards: 0 · the exercise's containers afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: the same list yes
in zsh (/bin/zsh -f) - the README's lines, the block's exit 0:
    built: 1 jar
    check: the start: failed - Parameter 0 of method redisCacheConfiguration in com.tiffinbox.web.RedisCaching required a bean of type 'org.springframework.boot.cache.autoconfigure.CacheProperties' that could not be found. · the reads: none · solved: no
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    check: the start: started · DEL customers::SimpleKey [] -> 1 · GET /customers twice: PostgreSQL 3 then 0 statements · Redis EXISTS customers::SimpleKey [] -> 1 · solved: yes
  the shell is now in: this unit's folder · listening on 20661-20666 afterwards: 0 · the exercise's containers afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: the same list yes
a wrong "solution" - the class kept and the dev cache type switched to caffeine (the README's block, one line changed), three times, each in a fresh env -i bash, through exercise/check.sh:
  $ cp exercise/LocalCacheConfig.java "$EX/tb/$W/LocalCacheConfig.java"; printf 'spring.cache.type=caffeine\n' > "$EX/run/application-dev.properties"
  run 1 - the block's exit 0:
    built: 1 jar
    check: the start: started · DEL customers::SimpleKey [] -> 0 · GET /customers twice: PostgreSQL 0 then 0 statements · Redis EXISTS customers::SimpleKey [] -> 0 · solved: no
  listening on 20661-20666 afterwards: 0 · the exercise's containers afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: the same list yes
  run 2 - the block's exit 0:
    built: 1 jar
    check: the start: started · DEL customers::SimpleKey [] -> 0 · GET /customers twice: PostgreSQL 0 then 0 statements · Redis EXISTS customers::SimpleKey [] -> 0 · solved: no
  listening on 20661-20666 afterwards: 0 · the exercise's containers afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: the same list yes
  run 3 - the block's exit 0:
    built: 1 jar
    check: the start: started · DEL customers::SimpleKey [] -> 0 · GET /customers twice: PostgreSQL 0 then 0 statements · Redis EXISTS customers::SimpleKey [] -> 0 · solved: no
  listening on 20661-20666 afterwards: 0 · the exercise's containers afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: the same list yes
```

`exercise/check.sh` reads the start's outcome, then deletes the list's key, then counts PostgreSQL's two windows in its own log and
reads the key back with `redis-cli EXISTS`. The "solution" that keeps the class and switches the dev cache type to `caffeine` starts,
and the key never reaches Redis: refused 3/3, the exit never read.

## Which store, which profile, which tree

`before/` is unit `26`'s after, the link `../c8-unit26/after`; its tree line is `../c8-unit26/receipts.md5`'s `after-tree`, re-derived
by `harness/tree27.py`. `after/` is this unit's, `../c8-tiffinbox` byte for byte at the start and at the end of every run. One jar
(`after/`'s, built once per run, offline) is started under "dev" on `20660` (the harness's `CacheBeans` joined by
`--spring.main.sources`, Boot's own logging, the Elasticsearch client's request logger at `TRACE` for the run), in the default run on
`20665` (`CacheBeans` joined, the harness's `logback.xml`: Hibernate's SQL logger at `DEBUG`), and under "dev" on `20666` for `absent`
and `twocaches` (`TwoCaches` joined for the second). Dev's four stores: `c8u27-pg` (PostgreSQL `18`, `log_statement=all`),
`c8u27-redis`, `c8u27-mongo` (a standalone, `GLIBC_TUNABLES`, a fresh container before every JVM), `c8u27-es` (the six settings, `9300`
not published), all by digest, all on `127.0.0.1` alone. The handler-method counts need `/actuator/mappings` on a flag run (an exposure
override, never shipped): not captured here, not said.

## Measured, not shipped

The whole-app test (`CapstoneProbeIT`, four `@Container @ServiceConnection` containers in one test) — not run (the clock): it stays a
probe's measurement, `3` of `7` runs above the launch rule's load in the S5 probe, and Course 9 decides.

## Refused, named

- The whole-app test for the anchor: its cost (four containers in one JVM) and its coverage (what the five ITs and this unit's
  captures already read) — the probe's `3` of `7` above the launch rule's load, cited; not shipped.
- The `CachingConfigurer` shape for two managers: unmeasured, carried (RED #19).
- `on one app` for the stores (R.473: one jar, two runs); `every other store` and `in sync` (refused: one copying store per write); a time on the copies' order; a footprint
  number (unit `24`'s reading is cited, `c8-unit24/README.md`'s footprint section, one reading, unit `24`'s run of record — no number
  of it here); a Course 9 lesson's number; a verdict of safety on the bound ITs.

## The repository, and the network

Repository `tiffinbox-java`, branch `main`, unit `26`'s commit `88c3aca` its parent. Every build offline from `.m2-demo`, a copy of
the course's seed (`spring-data-beyond-jpa/_research/m2-seed-c8-s4b`, `7,265` files): `Downloaded from` none, the seed's file count
unchanged after `mvn verify`. No image pulled: the four digests were on the machine; images and volumes counted at the start and the end
of every run. The one network call of the whole unit is the final `git push`.

## The folders, the harness and the ports

`after/`, `before` (a link), `exercise/` (`README.md`, `LocalCacheConfig.java`, `SOLUTION.md`, `check.sh`), `harness/` (`chk27.py`,
`s827.py`, `tree27.py`, `dur8.py` and `logback.xml` as units `02` and `07` shipped them, `src/probe/u27/CacheBeans.java` and
`TwoCaches.java`), `receipts.sh`, `receipts.md5`. Ports `20660`-`20669`: `20660` dev, `20661`-`20664` the stores (the exercise's first,
then the unit's), `20665` the default run, `20666` the exercise's TiffinBox and `absent`'s and `twocaches`' starts, `20667`-`20668`
spare and asserted free, `20669` never bound (`absent`'s target, `lsof` before each start). `bound` adds Testcontainers' own host ports
on `127.0.0.1` and the pinned `20578` and `20615`, each asserted free before. `18881`-`18884` free throughout.

## Masks, filters and hygiene — every one, declared

The mask (its self-test in the receipt): the folders and the home, Boot's start times, Flyway's execution time, Maven's and Surefire's
times, Testcontainers' `started in`, any duration the logs print (the MongoDB driver's wait among them), pids, object addresses, the run's
name (`Probe<run>`). Filters: PostgreSQL's empty statements counted beside, never in, the count; a lambda's hidden-class address in the
class-load names. Hygiene: `dur8` over the captures finds no duration word; no time, pid, all-interfaces binding or token in any
capture; every JVM and Maven run under its alarm; every container removed with its volumes.

## Interrupted

Six SIGINT points, each its own `./receipts.sh` (SIGINT reset to its default by `perl`), interrupted when its condition held,
then the machine read back: every one exit `130`, nothing left, `c8-tiffinbox` = after/ (the anchor was already changed on disk; no
point touches it), the captures unchanged, no `.r-lock` and no partial capture left. Run before the plants; the README was not edited
while any of them ran.

| point | exit | JVMs | c8u27 containers | Testcontainers | volumes / images | listeners (20660-20669, 20578, 20615, 18881-18884) | c8-tiffinbox = after/ | captures unchanged |
|---|---|---|---|---|---|---|---|---|
| `mid-build (Maven building after/)` | `130` | `0` | `0` | `0` | `315` / `9` | `0` | yes | yes |
| `mid-exercise (its stores up, its build or start live)` | `130` | `0` | `0` | `0` | `315` / `9` | `0` | yes | yes |
| `mid-dev start (the dev JVM starting, no window yet)` | `130` | `0` | `0` | `0` | `315` / `9` | `0` | yes | yes |
| `mid-tour (a window open, MONITOR live)` | `130` | `0` | `0` | `0` | `315` / `9` | `0` | yes | yes |
| `mid-absent (the MongoDB start, failing)` | `130` | `0` | `0` | `0` | `315` / `9` | `0` | yes | yes |
| `mid-bound (mvn verify, Testcontainers' containers alive)` | `130` | `0` | `0` | `0` | `315` / `9` | `0` | yes | yes |

## Planted faults — each caught (R.65, R.226)

Forty-one plants, each on a scratch copy (never a shipped file), each made to fail first and removed after; each ended with its FAIL
line (or the receipt's `***` line, or the prose gate's refusal), exit `1`, no traceback. Run after the SIGINT points, with no receipt
live. Each plant, its gate and how it ended (the lines themselves in this commit's message for the scratch log):

| # | plant | gate | ended |
|---|---|---|---|
| `01` | bound with the expected host IP changed (127.0.0.2) - no container | chk27 | exit `1`, its FAIL line, no traceback |
| `02` | a copy of RedisDatastoreIT without its modifier (the static check) | chk27 | exit `1`, its FAIL line, no traceback |
| `03` | the static count on a copy of RedisDatastoreIT.java with its modifier removed | chk27 | exit `1`, its FAIL line, no traceback |
| `04` | an IT BINDINGS line removed (an IT whose container never started): 4 classes | chk27 | exit `1`, its FAIL line, no traceback |
| `05` | the tests' second count changed | chk27 | exit `1`, its FAIL line, no traceback |
| `06` | chk27 bound fed an IT BINDINGS entry it cannot parse (no traceback) | chk27 | exit `1`, its FAIL line, no traceback |
| `07` | ElasticsearchIT's `Timed out waiting` count set to one | chk27 | exit `1`, its FAIL line, no traceback |
| `08` | a third class claimed in the dev run's `Caffeine` count | chk27 | exit `1`, its FAIL line, no traceback |
| `09` | two CacheManager beans claimed under dev | chk27 | exit `1`, its FAIL line, no traceback |
| `10` | the tour's second read typed as one statement in PostgreSQL | chk27 | exit `1`, its FAIL line, no traceback |
| `11` | the DEL reply typed 0 | chk27 | exit `1`, its FAIL line, no traceback |
| `12` | a tour capture that is not text at all | chk27 | exit `1`, its FAIL line, no traceback |
| `13` | the copies' order reversed (XADD before COMMIT) | chk27 | exit `1`, its FAIL line, no traceback |
| `14` | a MongoDB profiler line inserted in a copies window | chk27 | exit `1`, its FAIL line, no traceback |
| `15` | a 405 typed for POST /dishes on the default run | chk27 | exit `1`, its FAIL line, no traceback |
| `16` | the `cache_gets_total` miss count left unmoved (the caches `spring.cache.cache-names` names) | chk27 | exit `1`, its FAIL line, no traceback |
| `17` | absent's four reduced to three | chk27 | exit `1`, its FAIL line, no traceback |
| `18` | absent mongo's chain with its second bean dropped | chk27 | exit `1`, its FAIL line, no traceback |
| `19` | the twocaches text one byte changed | chk27 | exit `1`, its FAIL line, no traceback |
| `20` | the javap line without cacheResolver | chk27 | exit `1`, its FAIL line, no traceback |
| `21` | a before link to ../c8-unit25/after (its TEXT wrong, RED #28) | the receipt's gates | exit `1`, its *** line, no traceback |
| `22` | a wrong tree pin in receipts.md5 | the receipt's gates | exit `1`, its *** line, no traceback |
| `23` | src/main changed in a scratch after/ copy (the byte-equal assertion) | the receipt's gates | exit `1`, its *** line, no traceback |
| `24` | the stale every-interface sentence left unnoted (R.453) | chk27 | exit `1`, its FAIL line, no traceback |
| `25` | the anchor card's test count changed | chk27 | exit `1`, its FAIL line, no traceback |
| `26` | `one app`, said of the stores | s827 | exit `1`, a refusal line, no traceback |
| `27` | `both caches`, said of the dev run | s827 | exit `1`, a refusal line, no traceback |
| `28` | `every other store`, said of a copy | s827 | exit `1`, a refusal line, no traceback |
| `29` | the copies called `eventually consistent` | s827 | exit `1`, a refusal line, no traceback |
| `30` | the docker CLI named as the witness | s827 | exit `1`, a refusal line, no traceback |
| `31` | the evict said to happen `automatically` | s827 | exit `1`, a refusal line, no traceback |
| `32` | Testcontainers' default said to be the loopback | s827 | exit `1`, a refusal line, no traceback |
| `33` | a start said with a duration | s827 | exit `1`, a refusal line, no traceback |
| `34` | a Course 9 lesson by its number | s827 | exit `1`, a refusal line, no traceback |
| `35` | the bound tests called `safe` | s827 | exit `1`, a refusal line, no traceback |
| `36` | XFAM_S5's 12 families, one plant each (the self-test's own plants) through s827 | s827 | exit `1`, a refusal line, no traceback |
| `37` | the gloss's near miss, the sentence the prompt names beside the gloss | s827 | exit `1`, a refusal line, no traceback |
| `38` | a placeholder in the README | the receipt's own check | exit `1`, its *** line, no traceback |
| `39` | the cannot-fail detector on a copy of chk27.py (len(x) >= 0) | chk27 | exit `1`, its FAIL line, no traceback |
| `40` | a changed What-it-prints line | the receipt's own check | exit `1`, its *** line, no traceback |
| `41` | the exercise's cache-type "solution" through check.sh (run 1's line) | exercise/check.sh | exit `1`, its check: line, solved: no, no traceback |

Plant 25 is a check of the card's own words beside `bound`'s measured line (the card is prose: no checker reads its count), said so.

## What differed from the brief

- **The gloss.** The orchestrator's correction (2026-11-24): the gloss is the brief's own line, byte-equal (§SECTION SHAPE, BLUE
  RED #4), not the prompt's first draft; the receipt asserts it once, as a line of its own, in `copies`.
- **The `IT BINDINGS` form.** One `@BeforeAll` method, `printBindings()`, in all five ITs, chosen over a first test's first line: it
  prints once per class whatever the test order. It lists an entry for each exposed port Docker bound to a host port; `ElasticsearchIT`
  exposes `9200` alone (its Javadoc says so, and its line holds one entry), so no `9300` entry exists to skip.
- **The `Allow` headers.** The brief gives `Allow: POST, GET`. Measured: the header's order differs between JVMs (`GET, POST` in some
  rounds, `POST, GET` in others, under dev and in the default run), so the receipt prints its methods sorted, `(sorted): GET, POST`,
  and the video says the two methods, not an order.
- **The writers, read off the run.** Not by a `DEBUG` logger: the harness's `CacheBeans` reads the running context — every method of
  TiffinBox's beans that listens for a committed transaction (`KitchenEvents.stored`, `DishIndexSync.copy`, both `AFTER_COMMIT`) and the
  object the customers cache writes through (`DefaultRedisCacheWriter`). A third listener came with it, `CustomerFeed` (the feed's own,
  no store written): named, not counted as a copy.
- **Which JVM served which capture.** One dev JVM per round served `runs`' first half, `tour` and `copies` (their windows never overlap);
  one default JVM per round served `runs`' second half and `default`; the seven starts its own JVM, as unit `26`'s did.
- **The dev JVM's logging.** Boot's own console logging (its timestamps place the Elasticsearch trace in the copies' order), the client's
  request logger at `TRACE` by one command-line key for the run, never shipped; the default JVM runs on the harness's `logback.xml`
  (Hibernate's SQL logger at `DEBUG`).
- **The seven on one tree.** `before/`'s `src/main` is byte-equal to after/'s, so the seven on `before/` is unit `26`'s capture, cited;
  R.363 asks for both trees' sevens when the trees differ — here only the tests and the README do. RED judges.
- **The failure text.** `absent`'s four print `Application run failed` and no failure report, as the brief says; `twocaches` prints
  Boot's report (`APPLICATION FAILED TO START`, its Description quoted whole) and no `Application run failed` line.
- **`twocaches`' harness line.** `TwoCaches`' own line never printed: the start stops before its `@Bean` method runs. The check
  asserts that count (`0`) instead of the line.
- **The flag runs, dropped.** The handler-method counts need `/actuator/mappings` on a flag run each; dropped for the clock, in the
  prompt's order: not captured, not said. The whole-app re-test, dropped first: not run.
- **`before`'s every-interface reading.** `c8-unit25/README.md` holds no verify line that names the interfaces; the reading is `before/`'s
  three files (no modifier) and `MongoDatastoreIT`'s Javadoc there, which states Testcontainers' default off `../c8-unit18`'s capture.
- **The exercise.** The broken copy is `exercise/LocalCacheConfig.java` (a class whose bean name is not its method's, unit `25`'s
  lesson); SOLUTION's changed line removes it from the copy. The refused "solution" keeps the class and writes
  `spring.cache.type=caffeine` into the run folder's `application-dev.properties`: `RedisCaching` is conditional on the type `redis`,
  so that start completes, and Redis never holds the list.
- **The stale sentences.** Beyond the every-interface sentence, the three rebound ITs' cards (noted); nothing else in `c8-tiffinbox/`
  goes stale — its `0.0.0.0` lines are TiffinBox's own Tomcat and image.
- **The carried row's file count.** The brief's carried row says `83` files; measured `84` before and after (unit `26` made it `84`, this
  unit adds none). The row is stale; the ledger is not this unit's to edit.
- **`absent`'s Elasticsearch chain.** Unit `22`'s capture stopped at `dishes`; here the chain's first bean is `dishIndexSync`, which takes
  `dishes` — the same bean, one link further out.
- **The C8-20 sentence.** Not quoted, so no byte-equal copy is asserted.
- **Course 9's stale lines.** `rest-apis-done-right/_briefs/SETUP-BRIEF-2026-11-23.md:51-52` and `:366-367` (the three ITs on every
  interface) and `UNIT-BRIEFS-S1-DESIGN.md:419` (Course 8's item (a)) go stale with this commit; not edited here — sent to Course 9's B8 /
  BLUE by the carried row.

## For RED

- **The hook's two sentences and their captures**: the first read of the customer list and the second (`tour`'s first two rows:
  PostgreSQL `3` then none, Redis `7` then `2`), and another `CacheManager` bean stopping the dev start (`twocaches`, the Description
  quoted whole). The slide shows the `DEL` before the first read: the start had cached the list.
- **What a script must not say**: `on one app`, `both caches`, `every other store`, `in sync`, an order said as a time, a footprint
  number, a handler-method count, a Course 9 lesson's number, `safe` of the bound ITs, the `docker` CLI as the witness.
- **The counts and their witnesses**: every count in the values block, each from its capture's own lines, re-derived by `chk27.py`.
- **The gloss**: the brief's line, byte for byte, first said in `copies`.
- **C8-20**: not called back.
- **Course 9's three stale lines** (for its BLUE): `SETUP-BRIEF-2026-11-23.md:51-52`, `:366-367`, `UNIT-BRIEFS-S1-DESIGN.md:419`.

## The ledger rows this unit pays

- The roadmap's `:361` line, said as "one jar, two runs" (S8.105 = R.473): `runs`.
- RED S4B #3's carried row (the three ITs on every interface): CLOSED — `bound`, five `IT BINDINGS` lines, none off `127.0.0.1`.
- C8-20: not called back here — its sentence is not quoted (no byte-equal copy is needed where none is said).
- The contract's §10 "a system of record": the gloss, its first spoken use, in `copies`.

## The values the video may say

<!-- values: begin -->
```text
exercise: broken: the start fails, no bean of type CacheProperties · solved: started, DEL 1, PostgreSQL 3 then 0, EXISTS 1 · the cache-type switch refused 3/3 (EXISTS 0) · the spoken line 21 words
runs: one jar, two runs - dev: 1 CacheManager, RedisCacheManager, Caffeine classes 2 · default: 1 CacheManager, CaffeineCacheManager, Caffeine classes 93 · cache names [customer, customers]
tour: DEL -> 1 · GET /customers: PostgreSQL 3, Redis 7, then 0 and 2 · /leaderboard ZREVRANGE, Sunil first · /menu/day-19 1 find, 3 items · /revenue/by-customer 1 aggregate, 120 examined, 4 returned · /dishes/search?q=veg 2 _search · /kitchen 120 / 24300 · PATCH 405 Allow: GET, POST · DELETE 405 Allow: GET (empty statements filtered: 1)
copies: POST /customers: COMMIT, then XADD tiffinbox:kitchen-events (KitchenEvents, after the commit), then the evict (DefaultRedisCacheWriter): EXISTS, SET NX, KEYS customers::*, DEL customers::SimpleKey [], DEL customers~lock; the next read PostgreSQL 3 · POST /dishes: COMMIT, then PUT /dishes/_doc/11?refresh=false and POST /dishes/_refresh (DishIndexSync, after the commit); search finds it · MongoDB 0 in both · 3 copies in 2 stores
default: the default run: CaffeineCacheManager · GET /customers Hibernate SQL 1 then 0 · cache_gets_total miss 1.0 -> 2.0, hit 0.0 -> 1.0 · the five dev-only routes 404 (POST /dishes too) · PATCH 405 Allow: GET, POST · DELETE 405 Allow: GET · GET /customers/Ravi 200 · /v3/api-docs 404 · /swagger-ui.html 404
absent: absent: PostgreSQL entityManagerFactory <- flywayInitializer · Redis tiffinBoxServer · Elasticsearch dishIndexSync <- dishes · MongoDB menus <- mongoTemplate · each exit 1
twocaches: twocaches: a second CacheManager bean (localCaches) -> exit 1 · Parameter 0 of method redisCacheConfiguration in com.tiffinbox.web.RedisCaching required a bean of type 'org.springframework.boot.cache.autoconfigure.CacheProperties' that could not be found. · CacheAutoConfiguration @ConditionalOnMissingBean(value = CacheManager.class, name = "cacheResolver")
seven: the seven on after/: 7 lines, md5 = the course's
bound: the change: five IT files + README, 84 files, src/main byte-equal · static 1 1 1 1 1 · tests 18 + 14, 0 failures (MongoDatastoreIT 4) · IT BINDINGS classes 5, entries 5, not 127.0.0.1: 0 · ElasticsearchIT's wait held · containers created 5 · pulled 0
```
<!-- values: end -->

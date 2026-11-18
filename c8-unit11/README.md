# c8-unit11 — Redis as a Cache

Course 8, Section 2's fourth unit and **Section 2's third change to the anchor (C3)**. `before` is a link to `../c8-unit10/after`
(unit 10's tree, Caffeine in the JVM; the receipt pins it and asserts that pin is unit 10's own after-tree line); `after/` is this unit's
tree, and `../c8-tiffinbox` equals `after/` from this unit's commit on. The customer list's cache can live in **Redis** since: outside
the JVM, in a store a second process reads with its own client, `redis-cli`. **Serialization** is turning the object into the bytes the
store keeps; on Redis every cached value crosses a serializer on its way in and on its way back. The default run does not change: it
keeps Caffeine, in the JVM, and needs no Redis; the profile `dev` caches in Redis, the service `compose.yaml` starts beside Postgres.

Every count below comes from two witnesses in the same run (R.375): **the invocation counter** — unit 08's harness `BeanPostProcessor`,
copied, which adds a counting `MethodInterceptor` at position 0 of Spring Data JPA's repository proxy for `CustomerEntityRepository`,
outside the cached bean, so it counts exactly the calls a hit saves, in the JVM or in Redis — and **Hibernate's statement counter**,
`getPrepareStatementCount()`, Course 7's pinned counter. A window whose two per-call lists differ fails the run. The store has a witness
of its own: `redis-cli`, the Redis image's own client, run in the container (`GET`, `SET`, `--scan`, `TYPE`, `TTL`), and `psql` reads
PostgreSQL's rows. Redis is **Redis 8.10.3, by the digest** (`redis@sha256:7958cfbb…935c3`, `--pull never`, `127.0.0.1` only, no
password); PostgreSQL is 18.6 by the capstone's digest; the default run is H2 in memory.

Twelve captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `nodocker` and
`exercise` run once per run and were hashed equal over the three runs of record. Every number and string below is asserted right after
its capture by `harness/chk11.py` against a second witness of the same run.

**The runs of record, on the script as committed:** `./receipts.sh` (/bin/bash 3.2.57, 2026-11-18 from 14:24 CET, ended 14:33),
`bash receipts.sh` (Homebrew bash 5.3.9, from 14:33, ended 14:43) and a sealed fresh clone (below, from 14:43, ended 14:54): each with
every capture = published (the JVM ones 3/3 inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file count
unchanged, volumes back to their count and the images unchanged, `before/` and `after/` = their pins at the start and the end, nothing
listening on 20500-20509 at the end; each terminal log through `check_unit8.py 11 --runlog` — `RESULT (run logs): PASS`. The first two
logs end `exit 0`; the sealed clone's log ends with the script's own last line (every capture = published) and its `.r-lock` removed —
the wrapper's `exit` line was not written (its shell was gone), so that run's status is the script's last line, not a recorded exit code.
**Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `d1e4cf9` into a path **with a space** (`…/sealed
11/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c8-unit11 c8-tiffinbox`), the clone's `.m2-demo` a file copy of the seed, `env -i` with `HOME`,
`PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker` and dead proxies for http and https
(`127.0.0.1:9`); `./receipts.sh`. The runs ran on this README before its *Runs*, *Interrupted* and *Planted faults* paragraphs were
written; the prose gate and the text-block and values checks were run again on the final README against the last run's printed lines.

## C3 — the change, file by file, and every README sentence it rewrote (R.250)

C3 changes six files and the anchor's README, one of them new; nothing deleted (`chk11.py static`, from the files; the receipt also
prints `TiffinBoxApp.java`, `KitchenHealthIndicator.java`, `Dashboard.java` and `TiffinBoxServer.java` with the same md5 as `before/`'s):

- `tiffinbox-web/pom.xml` — **`spring-boot-starter-data-redis`**, no version typed (Boot's parent manages it), with a "Course 8, unit
  11:" comment in the form the POM's other dependencies have. Lines added only. The jar's libraries gain Lettuce, Netty, Reactor, Spring
  Data Redis and Spring Data KeyValue among others (the `anchor` capture lists them by name, read off `lib/`).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/RedisCaching.java` — **new**: one `@Configuration`, `@ConditionalOnProperty(name =
  "spring.cache.type", havingValue = "redis")`, with two beans. (1) A `RedisCacheManagerBuilderCustomizer` that hands Boot's builder **the
  cache writer TiffinBox gives Redis**, `RedisCacheWriter.create(cf, writer -> writer.immediateWrites().enableLocking())` —
  `immediateWrites()` and `enableLocking()` are the two switches; its Javadoc names the default as "the writer Boot builds over Lettuce".
  (2) A `RedisCacheConfiguration` built from Boot's own `CacheProperties` — `time-to-live`, `cache-null-values`, `key-prefix`,
  `use-key-prefix` applied as Boot's own configuration applies them — with `RedisSerializer.json()` (Spring Data Redis's
  `GenericJacksonJsonRedisSerializer`, Jackson 3) as the value serializer. The condition, chosen over `@ConditionalOnClass`: the Redis
  classes are on every class path now, the default run included, and the property is what tells the default run from the profile `dev`;
  the default run builds neither bean (the `anchor` capture prints both absent). TiffinBox's Customer record is not made `Serializable`.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java` — `findAll()` collects into an **`ArrayList`**
  (`Collectors.toCollection(ArrayList::new)`) in place of `Stream.toList()`, with a "Course 8, unit 11:" Javadoc paragraph that carries
  RED #9's sentence: on the default run every hit in the JVM, Caffeine's, returns that one `ArrayList`, and none of its four callers
  changes it (the receipt re-runs the grep on `after/`'s sources and prints the four lines).
- `tiffinbox-web/src/main/resources/application.yaml` — above the `---`: `spring.cache.type: caffeine` under the existing `spring.cache:`,
  and `management.health.redis.enabled: false` under `management:`, each with a "Course 8, unit 11:" comment in the file's style (why:
  the default run keeps no Redis; under Spring's AOT step the choice is fixed when the jar is built; the profile `dev` is a JVM run's).
- `tiffinbox-web/src/main/resources/application-dev.yaml` — `spring.cache.type: redis` and `management.health.redis.enabled: true`,
  with a comment. No `spring.data.redis` key anywhere: Compose wires the address.
- `compose.yaml` — a `redis` service beside `postgres`: `image: redis:8-alpine` (the tag, as Postgres's), the digest and Redis 8.10.3 in
  the comment, no `pull_policy`, `127.0.0.1:18882:6379` (18882 kept, RED #13's reason in the comment), no volume (the image declares
  none: the receipt prints `Config.Volumes`).
- `README.md` (the anchor's) — a `## Course 8 · unit 11` section in unit 10's block's shape with the one `docker pull redis:8-alpine`
  line beside the dev story, and four sentences noted in place, each in a note that starts *Course 8, unit 11* (`chk11.py r250` asserts
  each note sits on its sentence, after it):
  1. the header's line that carries unit 10's note ("that cache is Caffeine's since — bounded and counted …") — on the default run only;
  2. unit 10's section, "With it on the class path Boot's cache module builds a **`CaffeineCacheManager`** in place of the
     `ConcurrentMapCacheManager`." — with Redis on the class path too Boot would build a `RedisCacheManager`; `spring.cache.type` picks;
  3. unit 10's section, "**What it changes:** the customer list is kept by Caffeine, in the JVM" — on the default run; under `dev`, Redis;
  4. the section of Course 5's *Docker Compose for Development*, "`compose.yaml` — new, beside this README: one official Postgres image"
     — and Redis beside it since.
  The hunt covered every line naming Caffeine as the cache, the JVM as its only place, "no Redis", the Compose file's one service and
  "need no Docker". The anchor README's capstone section, `mvn package, mvn install, -Pnative and the Dockerfile's mvn -B package run the
  18 and need no Docker`, stays true and is not rewritten: the `nodocker` capture runs `mvn -o package` with Maven's Docker host pointed
  at nothing.

Not changed, and said so: `TiffinBoxApp`, `KitchenHealthIndicator`, `Dashboard`, `TiffinBoxServer` (md5s = `before/`'s), `findByName`
(uncached until unit 13), no V4 (Flyway's V1-V3 untouched), `ddl-auto: validate`, the exposure `health,prometheus`, Hibernate's schema
script (`xcheck.sql` = `c7-unit39/xcheck.sql`, byte for byte, the `seven` capture's first line).

```text
before/: 103 libraries · Redis's client in lib/:  · spring-data-redis in lib/: none
after/: 122 libraries · Redis's client in lib/: lettuce-core-7.5.2.RELEASE.jar · spring-data-redis in lib/: spring-data-redis-4.1.2.jar
gained: lettuce-core-7.5.2.RELEASE.jar
gained: netty-buffer-4.2.19.Final.jar
gained: netty-codec-base-4.2.19.Final.jar
gained: netty-codec-dns-4.2.19.Final.jar
gained: netty-common-4.2.19.Final.jar
gained: netty-handler-4.2.19.Final.jar
gained: netty-resolver-4.2.19.Final.jar
gained: netty-resolver-dns-4.2.19.Final.jar
gained: netty-transport-4.2.19.Final.jar
gained: netty-transport-native-unix-common-4.2.19.Final.jar
gained: reactive-streams-1.0.4.jar
gained: reactor-core-3.8.8.jar
gained: redis-authx-core-0.1.1-beta2.jar
gained: spring-boot-data-redis-4.1.2.jar
gained: spring-boot-netty-4.1.2.jar
gained: spring-data-keyvalue-4.1.2.jar
gained: spring-data-redis-4.1.2.jar
gained: spring-messaging-7.0.10.jar
gained: spring-oxm-7.0.10.jar
Jackson's databind in after/'s lib/: jackson-databind-3.1.7.jar (tools.jackson's, Jackson 3) · jedis in lib/: 0
the Redis container's own client: redis-cli 8.10.3 · INFO server: redis_version:8.10.3
```

## The captures — what each one shows

### 1 · anchor — the default run with no Redis beside the dev-shaped run on PostgreSQL + Redis (R.386, R.376)

The default run: `after/` on H2 in memory, no Redis setting given and no Redis container asked. Its cache is in the JVM, Caffeine's;
RedisCaching's beans are not built; health, readiness and the dashboard answer. The dev-shaped run: `after/` on PostgreSQL, Redis by the
digest, the settings the profile `dev` holds passed on the harness's command line (the anchor's YAML is never edited for a capture).

```text
PROBE CacheManager beans 1 [cacheManager=org.springframework.cache.caffeine.CaffeineCacheManager] (H2 2.5.250)
PROBE RedisCaching (com.tiffinbox.web): its configuration bean absent · RedisCacheManagerBuilderCustomizer beans [] · RedisCacheConfiguration beans []
PROBE RedisConnectionFactory: org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory
PROBE CacheManager beans 1 [cacheManager=org.springframework.data.redis.cache.RedisCacheManager] (PostgreSQL 18.6)
PROBE RedisCaching (com.tiffinbox.web): its configuration bean present · RedisCacheManagerBuilderCustomizer beans [immediateLockingWriter] · RedisCacheConfiguration beans [redisCacheConfiguration]
PROBE RedisConnectionFactory: org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory
PROBE the connection: 127.0.0.1:20502
PROBE Redis's INFO server, through the connection: redis_version:8.10.3
PROBE the cache writer: org.springframework.data.redis.cache.DefaultRedisCacheWriter · asynchronousWrites false · a lock wait set yes (not zero)
PROBE the customers cache's configuration: value serializer org.springframework.data.redis.serializer.GenericJacksonJsonRedisSerializer · key prefix for customers "customers::" · null values allowed true
PROBE reads: five calls of CustomerRepository.findAll() (H2 2.5.250, in the JVM, Caffeine): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE reads: five calls of CustomerRepository.findAll(): the two witnesses' per-call lists equal
PROBE reads: five calls of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE reads: five calls of CustomerRepository.findAll(): the two witnesses' per-call lists equal
PROBE reads: the classes read back - call 1 (the miss): java.util.ArrayList of com.tiffinbox.Customer · call 5 (a hit): java.util.ArrayList of [com.tiffinbox.Customer]
PROBE reads: the classes read back - call 1 (the miss): java.util.ArrayList of com.tiffinbox.Customer · call 5 (a hit): java.util.ArrayList of [com.tiffinbox.Customer]
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /dashboard -> 200
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health -> 200 · status UP · components [db UP, diskSpace UP, kitchen UP, livenessState UP, ping UP, readinessState UP, ssl UP]
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health/readiness -> 200 · status UP · components [kitchen UP, readinessState UP]
PROBE http (PostgreSQL 18.6, Redis): GET /dashboard -> 200
PROBE http (PostgreSQL 18.6, Redis): GET /actuator/health -> 200 · status UP · components [db UP, diskSpace UP, kitchen UP, livenessState UP, ping UP, readinessState UP, redis UP, ssl UP]
PROBE http (PostgreSQL 18.6, Redis): GET /actuator/health/readiness -> 200 · status UP · components [kitchen UP, readinessState UP]
log: Found 1 JPA repository interface
log: Found 1 JDBC repository interface
log: Found 0 Redis repository interfaces
log: Found 1 JPA repository interface
log: Found 1 JDBC repository interface
log: Found 0 Redis repository interfaces
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data JDBC 4.1.2 · Spring Data Redis 4.1.2 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data JDBC 4.1.2 · Spring Data Redis 4.1.2 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
log: HHH000001: Hibernate ORM core version 7.4.13.Final
log: HHH000001: Hibernate ORM core version 7.4.13.Final
redis-cli --scan: customers::SimpleKey []
```

### 2 · compose — the profile `dev` end to end, on a labelled copy of `compose.yaml` (R.387, RE-MEASURE 6)

Course 5's *Docker Compose for Development* gave this folder the profile `dev`; the same run, Maven's class path (it holds
`spring-boot-docker-compose`; the jar does not), now starts two containers. The receipts run a **labelled copy**,
`harness/compose/compose.yaml` — the anchor's file with the project name `c8-unit11`, both images by their digests with
`pull_policy: never`, and the ports 20503 (Redis) and 20504 (PostgreSQL); the receipt asserts it is `harness/variants.py compose` over
`after/compose.yaml`, byte for byte, and prints the changed lines. The anchor's own file is read by Compose's config command (nothing
started): the tag and 18882 shown. Boot's own Docker calls get the pinned socket (`DOCKER_HOST`).

```text
image: postgres:18-alpine
image: redis:8-alpine
published: "18881"
published: "18882"
keys spring.data.redis.* in after/'s YAML files: 0
Using Docker Compose file …/compose-run/compose.yaml
Network c8-unit11_default: Creating Created
Volume c8-unit11_data: Creating Created
Container c8-unit11-postgres-1: Creating Created Starting Started Waiting Healthy
Container c8-unit11-redis-1: Creating Created Starting Started Waiting Healthy
Container c8-unit11-postgres-1 Removed
Container c8-unit11-redis-1 Removed
Network c8-unit11_default Removed
Volume c8-unit11_data Removed
PROBE CacheManager beans 1 [cacheManager=org.springframework.data.redis.cache.RedisCacheManager] (PostgreSQL 18.6)
PROBE the beans named ...ConnectionDetails...: [dataRedisConnectionDetailsForC8Unit11Redis1, flywayConnectionDetailsForC8Unit11Postgres1, jdbcConnectionDetailsForC8Unit11Postgres1, jdbcConnectionDetailsHikariBeanPostProcessor]
PROBE the connection: 127.0.0.1:20503
PROBE the cache writer: org.springframework.data.redis.cache.DefaultRedisCacheWriter · asynchronousWrites false · a lock wait set yes (not zero)
PROBE reads: five calls of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE reads: five calls of CustomerRepository.findAll(): the two witnesses' per-call lists equal
redis-cli in the copy's Redis container (c8-unit11-redis-1), after the five reads, TiffinBox paused: --scan customers::SimpleKey [] · TYPE string
PROBE http (PostgreSQL 18.6, Redis): GET /actuator/health -> 200 · status UP · components [db UP, diskSpace UP, kitchen UP, livenessState UP, ping UP, readinessState UP, redis UP, ssl UP]
after TiffinBox stopped (Boot's own stop): the project's containers c8-unit11-postgres-1 Exited (0)|c8-unit11-redis-1 Exited (0) · its network c8-unit11_default · its volume c8-unit11_data
Container c8-unit11-postgres-1 Removed
Container c8-unit11-redis-1 Removed
Network c8-unit11_default Removed
Volume c8-unit11_data Removed
then: the project's containers 0 · its network 0 · volumes 316 (315 + this script's PostgreSQL container's 1)
```

Boot's own stop leaves both containers `Exited`, and the network and the volume in place; the receipt's `docker compose -p c8-unit11 down -v`
removes them, and the volume count returns.

### 3 · jdk — Boot's default serializer, Java's own: loud at the put (a labelled copy)

A copy of `after/` (`harness/variants.py jdk`) without RedisCaching's configuration bean: Boot's own configuration applies, and with it
Java's serialization. The method runs, the put throws, the caller gets the exception — at every call — and Redis keeps no key. The fix
taken is JSON, not a `Serializable` record (flag 6).

```text
PROBE the customers cache's configuration: value serializer org.springframework.data.redis.serializer.JdkSerializationRedisSerializer · key prefix for customers "customers::" · null values allowed true
PROBE two: call 1 of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1] and [1] · threw org.springframework.data.redis.serializer.SerializationException: Cannot serialize <- org.springframework.core.serializer.support.SerializationFailedException: Failed to serialize object using DefaultSerializer <- java.io.NotSerializableException: com.tiffinbox.Customer
PROBE two: call 2 of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1] and [1] · threw org.springframework.data.redis.serializer.SerializationException: Cannot serialize <- org.springframework.core.serializer.support.SerializationFailedException: Failed to serialize object using DefaultSerializer <- java.io.NotSerializableException: com.tiffinbox.Customer
redis-cli --scan: 
Customer.java (tiffinbox-core, unchanged): 26:public record Customer(@NotBlank @Size(max = 60) String name, · 'Serializable' in it: 0
```

### 4 · json — the bytes by `redis-cli GET` beside the class Java read back (R.379, RE-MEASURE 8)

The anchor's JSON serializer: five reads, then the bytes Redis keeps, read by `redis-cli GET`, beside the class the hit returned in Java.
The list carries its own class (`["java.util.ArrayList",[…]]`), each element its `@class`. A copy with `findAll` back to
`Stream.toList()` (`harness/variants.py tolist`): the first call (a miss) returns, the second (a hit, in Redis) throws, because the
list was written as a bare array with no class of its own. The last lines are **a harness bean's, not the anchor's cache**:
`@Cacheable("h11")` returning null, in a JVM that names its own cache beside the anchor's (`customers,h11`, R.384) — Redis keeps a null
as Java-serialized `NullValue` bytes even with the JSON serializer.

```text
PROBE reads: five calls of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0] · rows 4
PROBE reads: five calls of CustomerRepository.findAll(): the two witnesses' per-call lists equal
PROBE reads: the classes read back - call 1 (the miss): java.util.ArrayList of com.tiffinbox.Customer · call 5 (a hit): java.util.ArrayList of [com.tiffinbox.Customer]
["java.util.ArrayList",[{"@class":"com.tiffinbox.Customer","name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"@class":"com.tiffinbox.Customer","name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"@class":"com.tiffinbox.Customer","name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"@class":"com.tiffinbox.Customer","name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]]
redis-cli TYPE "customers::SimpleKey []": string · TTL: -1
PROBE two: call 1 of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1] and [1] · returned java.util.ImmutableCollections$ListN of [com.tiffinbox.Customer], 4 elements
PROBE two: call 2 of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 0 · prepareStatementCount 0 · per call [0] and [0] · threw org.springframework.data.redis.serializer.SerializationException: Could not read JSON: Unexpected token (`JsonToken.START_OBJECT`), expected `JsonToken.VALUE_STRING`: need String, Number of Boolean value that contains type id (for subtype of java.lang.Object) <- tools.jackson.databind.exc.MismatchedInputException: Unexpected token (`JsonToken.START_OBJECT`), expected `JsonToken.VALUE_STRING`: need String, Number of Boolean value that contains type id (for subtype of java.lang.Object)
[{"@class":"com.tiffinbox.Customer","name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"@class":"com.tiffinbox.Customer","name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"@class":"com.tiffinbox.Customer","name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"@class":"com.tiffinbox.Customer","name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
PROBE nullv: two calls of @Cacheable("h11") none() (PostgreSQL 18.6, Redis): returned null · per call [1, 0] and [1, 0]
redis-cli --no-raw GET "h11::SimpleKey []" (the harness's null, its bytes escaped): "\xac\xed\x00\x05sr\x00+org.springframework.cache.support.NullValue\x00\x00\x00\x00\x00\x00\x00\x01\x02\x00\x00xp"
```

### 5 · renamed — the silent one, the serializer's own setting: a field renamed between two builds (R.379, S8.29, RE-MEASURE 14)

On the anchor's own key, `customers::SimpleKey []`: one JVM writes the list; `redis-cli GET` reads the bytes; a Python edit renames one
element's field (Priya's `mealType` written as `type`, an earlier build's shape); `redis-cli SET` writes them back; a second JVM reads.
The four prints of a silent failure (S8.29): the counter that does not move (invocations 0, statements 0), the exit 0, no exception,
no ERROR line — and the value read back beside PostgreSQL's row, read by `psql`. The silence is the serializer's own setting: Jackson 3's
`FAIL_ON_UNKNOWN_PROPERTIES` is off by default, and the builder `GenericJacksonJsonRedisSerializer` uses configures it off as well
(`javap -c` on the seed's jars, quoted below; RED #4's lines re-run). A renamed `int` field and a renamed class are loud, at the hit in Redis.

```text
the planted bytes (an earlier build's: Priya's mealType written as type) - the edit's diff: < "mealType":"VEGAN"} > "type":"VEGAN"}
PROBE one: one call of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 0 · prepareStatementCount 0 · per call [0] and [0] · returned
PROBE one: one call of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 0 · prepareStatementCount 0 · per call [0] and [0] · threw org.springframework.data.redis.serializer.SerializationException: Could not read JSON: Cannot map `null` into type `int` (set `DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES` to 'false' to allow) <- tools.jackson.databind.exc.MismatchedInputException: Cannot map `null` into type `int` (set `DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES` to 'false' to allow)
PROBE one: one call of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 0 · prepareStatementCount 0 · per call [0] and [0] · threw org.springframework.data.redis.serializer.SerializationException: Could not read JSON: Could not resolve type id 'com.tiffinbox.CustomerV0' as a subtype of `java.lang.Object`: no such class found <- tools.jackson.databind.exc.InvalidTypeIdException: Could not resolve type id 'com.tiffinbox.CustomerV0' as a subtype of `java.lang.Object`: no such class found
PROBE one: element com.tiffinbox.Customer = Customer[name=Priya, mealsPerDay=1, pricePerMeal=120, mealType=VEGAN]
PROBE one: element com.tiffinbox.Customer = Customer[name=Priya, mealsPerDay=1, pricePerMeal=120, mealType=null]
psql (a second client, PostgreSQL): Priya VEGAN
88: ldc // String FAIL_ON_UNKNOWN_PROPERTIES
90: bipush 6
92: iconst_0
106: getstatic // Field tools/jackson/databind/DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES:Ltools/jackson/databind/DeserializationFeature;
109: iconst_0
110: invokevirtual // Method tools/jackson/databind/cfg/MapperBuilder.configure:(Ltools/jackson/databind/DeserializationFeature;Z)Ltools/jackson/databind/cfg/MapperBuilder;
```

### 6 · strict — the loud fix beside it, and its trade-off (flag 6, RE-MEASURE 9)

A copy (`harness/variants.py strict`) whose serializer is built with `customize(b -> b.enable(FAIL_ON_UNKNOWN_PROPERTIES))`. Today's
bytes still round-trip; the same planted bytes now make the hit in Redis throw, and what the caller gets is the exception, not a miss.

The trade-off, on its own line: bytes an earlier build wrote with a field this build lacks (`phone`) throw too.

And the versioned key prefix: the anchor itself with `--spring.cache.redis.key-prefix=v2:` — RedisCaching applies it from
`CacheProperties` — reads under a new key, so the old bytes are a miss and stay beside it.

```text
PROBE two: call 1 of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1] and [1] · returned java.util.ArrayList of [com.tiffinbox.Customer], 4 elements
PROBE two: call 2 of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 0 · prepareStatementCount 0 · per call [0] and [0] · returned java.util.ArrayList of [com.tiffinbox.Customer], 4 elements
PROBE one: one call of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 0 · prepareStatementCount 0 · per call [0] and [0] · threw org.springframework.data.redis.serializer.SerializationException: Could not read JSON: Unrecognized property "type" (class com.tiffinbox.Customer), not marked as ignorable (4 known properties: "name", "mealsPerDay", "pricePerMeal", "mealType") <- tools.jackson.databind.exc.UnrecognizedPropertyException: Unrecognized property "type" (class com.tiffinbox.Customer), not marked as ignorable (4 known properties: "name", "mealsPerDay", "pricePerMeal", "mealType")
PROBE one: one call of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 0 · prepareStatementCount 0 · per call [0] and [0] · threw org.springframework.data.redis.serializer.SerializationException: Could not read JSON: Unrecognized property "phone" (class com.tiffinbox.Customer), not marked as ignorable (4 known properties: "name", "mealsPerDay", "pricePerMeal", "mealType") <- tools.jackson.databind.exc.UnrecognizedPropertyException: Unrecognized property "phone" (class com.tiffinbox.Customer), not marked as ignorable (4 known properties: "name", "mealsPerDay", "pricePerMeal", "mealType")
PROBE the customers cache's configuration: value serializer org.springframework.data.redis.serializer.GenericJacksonJsonRedisSerializer · key prefix for customers "v2:customers::" · null values allowed true
PROBE one: one call of CustomerRepository.findAll() (PostgreSQL 18.6, Redis): repository calls 1 · prepareStatementCount 1 · per call [1] and [1] · returned
redis-cli --scan: customers::SimpleKey []|v2:customers::SimpleKey []
```

### 7 · writer — the writer Boot builds over Lettuce, as a failure receipt (R.378)

A copy (`harness/variants.py writer`) without the customizer: Boot's own writer, the one it builds over Lettuce. Ten rounds of a read,
`add(<a new name>)` — `@CacheEvict(allEntries = true)` — and an immediate read: on that writer the immediate read returns the list
without the new name (stale): no call reached the repository, the old list came back. The cache writer TiffinBox gives Redis, on the same rounds:
none stale. Then fifty rounds on the same cache and key through Spring's `Cache` API (`evictIfPresent`, `put`, an immediate read):
whether a read right after a put reached the repository; its count varies run to run on Boot's writer and is not in any capture.

```text
PROBE the cache writer: org.springframework.data.redis.cache.DefaultRedisCacheWriter · asynchronousWrites true · a lock wait set no (zero)
PROBE the cache writer: org.springframework.data.redis.cache.DefaultRedisCacheWriter · asynchronousWrites false · a lock wait set yes (not zero)
PROBE evict (PostgreSQL 18.6, Redis): ten rounds of a read, add(a new name) and an immediate read: the new name missing (stale) in 10 of 10 rounds
PROBE evict (PostgreSQL 18.6, Redis): ten rounds of a read, add(a new name) and an immediate read: the new name missing (stale) in 0 of 10 rounds
PROBE evict: then fifty rounds on the same cache and key through Spring's Cache API - evictIfPresent (immediate by its contract), put(the list), an immediate findAll(): a read right after the put reached the repository in at least one of the fifty: yes
PROBE evict: then fifty rounds on the same cache and key through Spring's Cache API - evictIfPresent (immediate by its contract), put(the list), an immediate findAll(): a read right after the put reached the repository in at least one of the fifty: no
DefaultRedisCacheWriter: private static final boolean REACTIVE_REDIS_CONNECTION_FACTORY_PRESENT;
DefaultRedisCacheWriter: private final boolean asynchronousWrites;
DefaultRedisCacheWriter: public boolean supportsAsyncRetrieve();
DefaultRedisCacheWriter: private boolean writeAsynchronously();
RedisCacheWriter.RedisCacheWriterConfigurer: public default org.springframework.data.redis.cache.RedisCacheWriter$RedisCacheWriterConfigurer enableLocking();
RedisCacheWriter.RedisCacheWriterConfigurer: public default org.springframework.data.redis.cache.RedisCacheWriter$RedisCacheWriterConfigurer immediateWrites();
Redis clients in after/'s lib/: lettuce-core-7.5.2.RELEASE.jar - Lettuce only
```

### 8 · ttlbean — a configuration bean that ignores Boot's settings (READ FIRST 8, R.380, RE-MEASURE 7)

A copy (`harness/variants.py ttlbean`) whose `RedisCacheConfiguration` bean ignores `CacheProperties`, with
`spring.cache.redis.time-to-live` set on the command line: `redis-cli TTL` reads `-1`, no expiry, and nothing says so. The anchor's bean,
built from `CacheProperties`, with the same setting: a positive count, at most the value configured — read back, masked, never voiced as
a time. With no setting the anchor's entry has no time to live (unit 12 sets the backstop).

```text
redis-cli TTL "customers::SimpleKey []": -1
redis-cli TTL "customers::SimpleKey []": TTL <n> · a positive count, at most the configured value: yes
redis-cli TTL "customers::SimpleKey []": -1
```

### 9 · health — no Redis, the indicator on: health DOWN (READ FIRST 11, R.386)

`after/` on H2 in memory, no Redis; the harness's flag turns Redis's indicator back on (the anchor's YAML unchanged) and points Lettuce
at a port nothing listens on: `/actuator/health` answers DOWN with the `redis` component DOWN, while readiness and the dashboard answer.
Then the cache's type `redis` with no Redis: the context starts, and every cached call throws. The anchor's own default run, with the
indicator off and no Redis, answers health with no `redis` component (the `anchor` capture).

```text
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /dashboard -> 200
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health -> 503 · status DOWN · components [db UP, diskSpace UP, kitchen UP, livenessState UP, ping UP, readinessState UP, redis DOWN, ssl UP]
PROBE http (H2 2.5.250, in the JVM, Caffeine): GET /actuator/health/readiness -> 200 · status UP · components [kitchen UP, readinessState UP]
PROBE two: call 1 of CustomerRepository.findAll() (H2 2.5.250, Redis): repository calls 0 · prepareStatementCount 0 · per call [0] and [0] · threw org.springframework.data.redis.RedisConnectionFailureException: Unable to connect to Redis <- io.lettuce.core.RedisConnectionException: Unable to connect to 127.0.0.1/<unresolved>:20506 <- io.netty.channel.AbstractChannel$AnnotatedConnectException: Connection refused (connect failed): /127.0.0.1:20506 <- java.net.ConnectException: Connection refused (connect failed)
PROBE two: call 1 of CustomerRepository.findAll(): the two witnesses' per-call lists equal
```

### 10 · nodocker — the tests, without Docker and with it (R.363, RED #6)

```text
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
the verify log: 'Found 1 JPA repository interface' 3 · 'Found 0 Redis repository interfaces' 2 · 'Creating container for image' 2 · 'Pulling' 0 · 'RedisConnectionFailure' 0
```

The container tests run on the default settings — Caffeine, no Redis (no Redis connection failure in the log).

### 11 · seven — the comparison set on before/ and after/ (R.363)

```text
exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · listens on: 127.0.0.1:20505
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · listens on: 127.0.0.1:20500
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20505 now: 0
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20500 now: 0
the seven, after/ against before/: lines that differ: 0
```

### 12 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`: the spoken line, then a block that copies `after/`, puts `Stream.toList()` back, builds offline, starts its own
Redis (`redis:8-alpine` by its tag — the viewer's line; `--pull never` — the receipts' rule; `docker -H "$DH"`), runs the harness on H2
in memory with the cache's type `redis`, removes the container with its volume, and prints both calls. `exercise/SOLUTION.md`: the same
block with one line changed (the derivation not run). The check is the second call's line and the counter, never the exit.

## Which store, which manager, which writer

Every caching line names its store: **in the JVM, Caffeine** — the default run, `CaffeineCacheManager`, `spring.cache.type: caffeine`
printed, no Redis anywhere — and **Redis, by the digest** — `RedisCacheManager`, its cache `RedisCache`, `LettuceConnectionFactory` on
`127.0.0.1` and the unit's port, and **the cache writer TiffinBox gives Redis** (`immediateWrites` + `enableLocking`; the `anchor` capture
prints `asynchronousWrites false` and a lock wait set). The writer Boot builds over Lettuce appears in one capture, labelled the copy's
(`writer`), and in the copy `jdk` (which keeps the anchor's writer and drops only the serializer). PostgreSQL answers every miss on
the Redis lines; H2 in memory answers the default run's, the `health` capture's and the exercise's.

## Refused, named

- The claim that Redis is the asynchronous part: it is not — the calls of the writer Boot builds over Lettuce are (flag 5, the `writer`
  capture's javap).
- A Redis sentence about evict, clear, a read after a write or a stale list without its writer named (R.378).
- The bytes said without both halves — `redis-cli GET`'s bytes and the class Java read back (R.379).
- The renamed field's silence credited to Redis or to JSON: it is the serializer's own setting, `FAIL_ON_UNKNOWN_PROPERTIES` off,
  with the strict build's loud fix beside it (R.379, R.370).
- A key other than `customers::SimpleKey []` for the anchor at 11/after: the probe's single-customer key was its bean's; the harness's
  `h11` key is labelled the harness's (R.392).
- A time to live said as a time: it is a setting, read back as a count by `redis-cli TTL`, masked in the captures (R.380).
- A health line for Redis without the default run that has none (R.386: the `anchor` capture's first JVM).
- Redis as a datastore: this unit is Redis as a cache, not a datastore (C8-15, Section 3).
- A Compose project removed other than by `down -v`, a container removed without `-v` (R.387); a build that names `-pl` without `-am`
  (R.391); `pull_policy: never` or a digest in the viewer's `compose.yaml` (flag 7 — the tag there, the digest in the comment and the
  receipts' copy); a `spring.data.redis` key in the anchor's YAML (flag 7 — Compose wires it).
- `-Pnative` or the AOT step as a claim: not measured; the profile `dev` is said as a JVM run's (RED #6).
- A time for anything: no duration word, and every duration the logs print is masked (R.388).

## Call-backs, by title (R.224)

- Course 5's *Docker Compose for Development* (`java5_series.TITLES["17"]`): its profile `dev`, its Compose file, its words for Boot's own
  stop (`Exited`, the network left) — the `compose` capture measures them on a copy with Redis beside Postgres.
- Course 7's *N+1, Measured* (`java7_series.TITLES["30"]`): its pinned counter, called back byte for byte from `../c7-unit30/pinned.txt`,
  its third line — **C8-9 called back**:

```markdown
SessionFactory.getStatistics().getPrepareStatementCount()
```

- Course 8's *@Cacheable, @CacheEvict, @CachePut* (`java8_series.TITLES["08"]`): unit 08's counter, copied
  (`harness/src/probe/u11/Counter.java`: the package line and one sentence differ, `chk11.py static` asserts the rest).
- Course 8's *Caffeine* (`java8_series.TITLES["10"]`): unit 10's tree, this unit's `before`; its cache stays the default run's.
- This unit: *Redis as a Cache* (`java8_series.TITLES["11"]`, `11-redis-as-a-cache`).

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged: TiffinBox still starts on H2 in memory with nothing installed; the profile `dev` now also needs the image
`redis:8-alpine` (the anchor README's one `docker pull redis:8-alpine` line).

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s2` (it holds the Redis starter, Spring Data
Redis, Lettuce and Jackson 3's databind); every build reads it offline (`-o`, `maven.repo.local` as an absolute path) and the receipt
asserts its file count unchanged after every Maven run. Docker: the pinned socket on every call (Boot's Compose calls through
`DOCKER_HOST`), both images by their digests, `--pull never` and `pull_policy: never`; the tag `redis:8-alpine` is asserted to be the
digest's image here; no image pulled (the image list is asserted unchanged), the volume count asserted unchanged at the end. Nothing in
this unit touched the network; the harness's HTTP requests go to TiffinBox's own web server on 127.0.0.1.

## The folders, the harness and the ports

- `harness/src/probe/u11/U11.java` — the harness program (steps `info`, `http`, `reads`, `one`, `two`, `evict`, `nullv`, `pause`),
  TiffinBox's application class with its web server; `Counter.java` — witness 1, unit 08's; `HarnessNull.java` — the `nullv` step's
  harness bean (`h11`). `harness/src/probe/x/XMain.java` — `c7-unit29`'s schema probe, byte for byte.
- `harness/chk11.py` (the checks), `harness/s811.py` (the prose gate, its self-test first), `harness/tree11.py` (the pins),
  `harness/variants.py` (the copies `jdk`, `tolist`, `strict`, `writer`, `ttlbean` and the Compose copy), `harness/compose/compose.yaml`
  (that copy, shipped), `harness/surefire.py` and `harness/dur8.py` (unit 02's, byte for byte), `harness/logback.xml` (unit 07's).
- Ports: 20500 TiffinBox (`after/` and the copies; the seven; the exercise) · 20501 the PostgreSQL container · 20502 the Redis container
  (and the exercise's own Redis, never at the same time) · 20503 the Compose copy's Redis · 20504 the Compose copy's PostgreSQL · 20505
  TiffinBox `before/` for the seven · 20506 pointed at by the `health` capture's runs with no Redis — asserted free before and after,
  never bound · 20507-20509 never bound. All ten are asserted free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masked: this folder and the repository's paths, the home, the user name, Boot's `Started … in <t>`, Surefire's `Time elapsed`, Flyway's
`execution time`, Spring Data's `scanning in <t>`, `initialization completed in <t>`, any `PT<t>S`, Maven's `Total time`, `using Java
<version>`, object hashes, **`time-to-live=<n>s`** and **`TTL <n>`** for a positive count (R.380, R.388; the mask's self-test refuses
planted unmasked ones). dur8 finds no word in the captures or in this README's text blocks, asserted. Filtered: Maven's own lines; the
harness JVM's log down to the strict-mode lines, the `Found` lines, `HHH000001`, Flyway's `Database` line (its port and database masked)
and the WARN lines (Netty's DNS line at start; Flyway's H2 version line); Compose's lines filtered to one line per network, volume and
container. The PostgreSQL password and the shutdown token are generated per run, 0600, and asserted absent from every capture.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM, Maven, the exercise's shell), removes both containers
with their volumes (`rm -fv`), removes the Compose project with its volumes (`down -v`, from the copy's folder or by its file), removes
any Testcontainers container and the exercise's own Redis, deletes the partial captures, and exits 130. Measured 2026-11-18 on this
folder, the script started with SIGINT at its default (`perl -e '$SIG{INT}="DEFAULT"; exec …'`; `set -m` was asked for in the driver,
and this machine's shell refused its process groups — `setpgid … Operation not permitted` — so the reset is perl's) and the signal sent
to its pid at eight points: mid-build (the copies building), mid-verify (Testcontainers' container tests running), mid-harness (the
`anchor` capture's default-run JVM, H2 in memory), mid-TiffinBox on PostgreSQL twice (the `anchor` capture's dev-shaped JVM; a
`renamed` JVM on PostgreSQL + Redis), mid-Redis twice (the `jdk` capture with both containers up; between two `renamed` JVMs) and
mid-Compose (the Compose copy's two containers `Healthy`, TiffinBox starting on them) — each looked at twice, the second look a few
beats later. Two first attempts at mid-build and mid-verify met a marker file left by the run before and stopped the script in its
gates; the driver then cleared `.harness/` before each start, and both points ran again. The captures on disk were compared with
`receipts.md5` afterwards: all twelve unchanged.

```markdown
exit 130 at each of the eight points; at each look: java 0 · mvn 0 · c8u11 containers 0 · c8-unit11 containers 0 · network 0 · testcontainers 0 · volumes 315 · images 7 · listeners 20500-20509 0 · .r-lock absent · partial .r-*.[123] 0
```

## The ledger rows this unit pays

None (LEDGER). **C8-9** called back: `getPrepareStatementCount()` beside the invocation counter in every counted window. **C8-15** stays
open: this is Redis as a cache, not a datastore (C8-15, Section 3).

## RE-MEASURE — the brief's items this unit settles

5. The open half — `cache-names` with Caffeine as the default type after this unit: the default run prints `spring.cache.cache-names
   customers` and `spring.cache.type caffeine`, its manager Caffeine's (`anchor`). The meters for the caches named at the start are unit 10's and not re-read.
6. The receipts' Compose copy (project `c8-unit11`, the unit's ports, digests, `pull_policy: never`), the profile `dev` end to end, Boot's
   stop and `down -v` (`compose`).
7. `RedisCaching` built from `CacheProperties`: the time to live applied (`ttlbean`) and the key prefix applied (`strict`).
8. The exercise pair on the shipped tree: `toList()` → the hit in Redis throws; `ArrayList` → a hit in Redis (`json`, `exercise`).
9. The strict build through Redis: the hit in Redis throws and the caller gets the exception; an added field throws too; the versioned prefix makes
   the old bytes a miss (`strict`).
13. The seven on 11/after: unchanged (`seven`). The dashboard's statements are not measured as a page.
14. The hook and `renamed` on the anchor's own key `customers::SimpleKey []` (`json`, `renamed`).

## The anchor moved on — the builders (R.211, R.331)

Before the commit, the grep the prompt names — `/usr/bin/grep -n
'c8-tiffinbox\|tiffinbox-web/pom\|application.yaml\|application-dev\|compose.yaml\|CustomerRepository\|RedisCaching\|README'` over
`_builders/s80*.py`, `_builders/s81*.py` (none exists yet), `check_unit8.py`, `qa_java8.py` and `build_java8.py` — printed its lines,
filed in this run's scratch. Every line naming `c8-tiffinbox` is an "R.211 live compare" (`s801.py`-`s807.py`: a difference printed as a
`note:`, a live file read only behind an existence check — R.331) or a `git show <commit>:c8-tiffinbox/<p>` at a builder's pinned
evidence commit. No shipped builder fails on the changed paths; none was edited.

## Next

Unit 12 moves the anchor next (the time-to-live backstop); `findByName` stays uncached until unit 13.

## What differed from the brief

- **3/3.** The JVM captures (`anchor`, `compose`, `jdk`, `json`, `renamed`, `strict`, `writer`, `ttlbean`, `health`, `seven`) run three
  times inside every run and hash equal; `nodocker` and `exercise` (Maven builds) run once per run, their hashes equal over the three
  runs of record (bash 3.2, bash 5, the sealed clone).
- **Captures named as the prompt lists them, with `nodocker` holding both test runs.** The prompt's `18 + 5` sits in `anchor`; it is the
  second half of `nodocker` here (the Docker-free `mvn -o package`, then `mvn -o verify` with Docker), so the two Maven runs are one capture.
- **`RedisCaching`'s condition is `@ConditionalOnProperty(spring.cache.type=redis)`, not `@ConditionalOnClass`.** The Redis classes are
  on every class path now, the default run's included; the property is the one difference between the default run and `dev`. The default
  run builds neither bean (printed). Under the AOT step a property condition is fixed at build time — the `dev` profile is said as a JVM
  run's, as the anchor's own comments say.
- **The time to live read back is `600s`, not `2s`.** `redis-cli TTL` runs after the harness JVM has stopped; a two-second entry could be
  gone by then (`-2`) and the capture would not hash equal. The setting is printed masked (`time-to-live=<n>s`), the count read back
  masked (`TTL <n>`), and the line prints only "a positive count, at most the configured value: yes". No expiry is waited for anywhere.
- **The health capture uses the harness's flag, not a YAML copy.** `--management.health.redis.enabled=true` on the command line is the
  copy the prompt describes (the indicator back on) without a sixth build; the anchor's YAML is untouched. Lettuce is pointed at 20506,
  where nothing listens (asserted before and after), so no default port of this machine is asked.
- **Two of the writer's counts are not voiced.** After the stale read, whether the next read reached the repository moved across the
  repetitions of one run (one round in one repetition); it went to `.harness/raw.txt` and out of the capture.
- **The writer's read-after-write count is not voiced.** On the writer Boot builds over Lettuce, a read right after a put reached the
  repository in some of fifty rounds and the count moved from JVM to JVM in exploration; the capture prints
  only "in at least one of the fifty: yes" (and "no" on the anchor's writer), the counts go to `.harness/raw.txt`. The stale count after
  `@CacheEvict(allEntries = true)` is stable and is the voiced number.
- **The renamed class's message.** Jackson 3 says `Could not resolve type id 'com.tiffinbox.CustomerV0' as a subtype of
  `java.lang.Object`: no such class found`, not the probe notes' "Cannot locate class"; the check reads the class name off the message.
- **The planted bytes are derived per run.** Each plant is a Python edit of the bytes `redis-cli GET` read in the same run (the diff is
  printed), written back with `redis-cli SET`; the int and class plants are one capture each, inside `renamed`.
- **The Compose `--scan` runs while TiffinBox waits.** Boot's stop leaves the Redis container `Exited`, so `redis-cli` cannot run after the
  JVM; the harness's `pause` step waits for the receipt's file, the receipt runs `redis-cli` in the copy's container, then lets it go on.
  The pause measures nothing.
- **The harness is compiled once, against `after/`'s jar**, and runs over each copy's jar; the receipt asserts every copy's `lib/` is
  `after/`'s. Every copy is built with `-pl tiffinbox-web -am` from its own tree (R.391).
- **Names**: Alice, Brian, Clara, Derek, Elena, Frank, Grace, Henry, Irene and James are the customers the `writer` rounds add; Priya is
  V2's seed customer whose field is renamed (English names only, R.215).

## Planted faults — each caught (R.65, R.226)

Each plant was made in Python on a scratch mirror of the repository (this folder copied, every other entry linked; nothing written
here), one change per plant, and the gate named beside it run on the mirror; every plant exited 1 with the line shown, and the four
controls (the shipped prose and three shipped captures) exited 0. The prose plants add one sentence above *Next* (the line number is the
mirror's README's); the plants on captures are doctored copies of this run's own `.r-*.out` files, checked by `chk11.py`. One plant
(the default run's health line renamed) stops `chk11.py anchor` with a `KeyError` while it composes its values line, after its
checks: exit 1, as the line shows.

```markdown
exit 1 "Redis is asynchronous"  |  flag 5  |  *** a refused word or reading in this unit's prose:   README.md line 459: flag 5: "Redis is asynchronous" - the writer's calls are ***
exit 1 the JSON bytes read back by Java only  |  R.379  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.379: the bytes without redis-cli's GET and the class read back ***
exit 1 the silence credited to Redis  |  R.379/R.370  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.379/R.370: the silence credited to Redis or JSON, not the serializer's own setting ***
exit 1 the silence credited to JSON  |  R.379/R.370  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.379/R.370: the silence credited to Redis or JSON, not the serializer's own setting ***
exit 1 a customer:: key at 11/after  |  R.392  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.392: a customer:: key or the customer cache - the anchor at 11/after caches only customers::SimpleKey [] ***
exit 1 the health line without the no-Redis default run  |  R.386  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.386: a health sentence without the default run that has no Redis;  README.md line 459: R.302: a capture's number typed in prose: 503 ***
exit 1 a TTL said as a time  |  R.380  |  *** a refused word or reading in this unit's prose:   README.md line 459: dur8: seconds;  README.md line 459: R.388's family: two seconds;  README.md line 459: R.380: a TTL said as a time ***
exit 1 Redis as a datastore  |  C8-15  |  *** a refused word or reading in this unit's prose:   README.md line 459: C8-15: Redis as a datastore - this unit is Redis as a cache ***
exit 1 a Redis evict sentence without its writer  |  R.378  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.378: a Redis evict / clear / read-after-write sentence without the writer named ***
exit 1 Compose down without -v  |  R.387  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.387: Compose down without -v ***
exit 1 pull_policy in the viewer's compose.yaml  |  flag 7  |  *** a refused word or reading in this unit's prose:   README.md line 459: flag 7: pull_policy or a digest as the viewer's compose.yaml line ***
exit 1 a spring.data.redis key in the anchor's YAML  |  flag 7  |  *** a refused word or reading in this unit's prose:   README.md line 459: flag 7: a spring.data.redis key in the anchor's YAML ***
exit 1 "faster"  |  R.388 / dur8  |  *** a refused word or reading in this unit's prose:   README.md line 459: dur8: faster ***
exit 1 "Spring Data caches"  |  R.348  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.348: the abstraction credited to Spring Data or Hibernate: Spring Data caches ***
exit 1 a typed number  |  R.302  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.302: a capture's number typed in prose: Stale in 1 ***
exit 1 a typed SQL string  |  R.225/R.365  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.225/R.365: a typed SQL string in the prose ***
exit 1 rm -f without -v  |  R.387  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.387: rm -f without -v ***
exit 1 -pl tiffinbox-web without -am  |  R.391  |  *** a refused word or reading in this unit's prose:   README.md line 459: R.391: -pl tiffinbox-web without -am ***
exit 1 a dish name  |  R.215  |  *** an Indian dish name (R.215: English names only): README.md:459:Ravi orders <the planted dish name>. ***
exit 1 a placeholder line  |  placeholders  |  *** a placeholder in this unit's prose or harness: README.md:459:<the planted placeholder line> ***
exit 1 a before link to the wrong target  |  R.211  |  *** R.211: before must be a link to ../c8-unit10/after (it points at: ../c8-unit08/after) ***
exit 1 a container removed without -v  |  R.387  |  *** R.387/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv (found: dk rm -f|dk rm -fv) ***
exit 1 a Compose down without -v  |  R.387  |  *** R.387: receipts.sh takes a Compose project down without its volumes - every one is down -v (found: compose -p $PROJ down|compose -p $PROJ down -v) ***
exit 1 the docker CLI unpinned  |  R.344  |  *** R.344: receipts.sh calls docker without the pinned socket (every call is dk): 127:docker info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that s ***
exit 1 a dk run without --pull never  |  R.344  |  *** R.344: a dk run without --pull never ***
exit 1 a -pl tiffinbox-web build without -am  |  R.391  |  *** R.391: a Maven build in receipts.sh without -pl tiffinbox-web -am ***
exit 1 the exercise built without -am  |  R.391  |  *** R.391: exercise/README.md builds without -pl tiffinbox-web -am ***
exit 1 the exercise's solution = broken  |  R.196  |  *** R.196: SOLUTION.md's block must be the README's with one line changed ***
exit 1 a changed What-it-prints line  |  R.196 / wib  |  *** exercise/README.md: its What it prints block is not what its lines printed ***
exit 1 an R.250 sentence left (its note dropped, chk11 r250)  |  R.250  |  FAIL R.250: its unit 11 note sits on its line, after it: **What it changes:** the customer list is kept by Caffeine,
exit 1 Boot's default writer left in the anchor (chk11 static)  |  R.378  |  FAIL RedisCaching: the writer customizer - immediateWrites() and enableLocking()
exit 1 a pull_policy in the anchor's compose.yaml (chk11 static)  |  flag 7  |  FAIL compose.yaml's redis: the tag, no pull_policy, 127.0.0.1:18882, no volume
exit 1 invocations 1 typed into renamed  |  S8.29 / R.375 (chk11 renamed)  |  FAIL R.375: one: one call of CustomerRepository.findAll() on PostgreSQL 18.6 - the counter's per-call list [1] = the statement counter's [0]
exit 1 TTL 2 typed into the bean copy's line  |  R.380 (chk11 ttlbean)  |  FAIL the copy's bean ignores CacheProperties: TTL -1 (no expiry), silent
exit 1 a --scan key added to jdk  |  loud at put (chk11 jdk)  |  FAIL redis-cli --scan: no key
exit 1 stale 0 of 10 typed into writer's default line  |  R.378 (chk11 writer)  |  FAIL the stale count = the rounds listed stale
exit 1 the health 503 typed as 200  |  R.386 (chk11 health)  |  FAIL no Redis, the indicator on: /actuator/health 503, redis DOWN
exit 1 the default run's health line dropped (anchor)  |  R.386 (chk11 anchor)  |  KeyError: '/actuator/health'
exit 1 a version claim without HHH000001  |  R.246 (chk11 anchor)  |  FAIL Hibernate's version = HHH000001's
exit 1 the Lettuce jar name changed  |  R.246 (chk11 anchor)  |  FAIL gained: lettuce-core-7.5.2.RELEASE.jar
exit 1 the bytes said without the class read back (json)  |  R.379 (chk11 json)  |  FAIL R.379: the class Java read back (ArrayList of Customer) = the classes the bytes name
exit 1 the two counters disagree  |  R.375 (chk11 anchor)  |  FAIL R.375: reads: five calls of CustomerRepository.findAll() on H2 2.5.250 - the counter's per-call list [1, 0, 0, 0, 0] = the statement counter's [1, 1, 0, 0, 0]
exit 1 a wrong published hash for the seven  |  chk11 seven  |  FAIL the seven on before/ and after/ = Course 7's published md5
exit 0 (control) the shipped prose  |  s811  |  self-test: 71 cases · refused: 0
exit 0 (control) the shipped renamed capture  |  chk11  |  VALUES the anchor's key customers::SimpleKey [] · the planted bytes (Priya's mealType as type, by redis-cli SET) -> Customer[name=Priya, mealsPerDay=1, pricePer
exit 0 (control) the shipped writer capture  |  chk11  |  VALUES the writer Boot builds over Lettuce (the copy, asynchronousWrites true, no lock): @CacheEvict(allEntries = true) then an immediate read - stale in 10 of 
exit 0 (control) the shipped health capture  |  chk11  |  VALUES no Redis, Redis's indicator on: /actuator/health 503 (redis DOWN), readiness 200, /dashboard 200 · the cache type redis with no Redis: started, each call
```

## For RED

- The writer's stale count is ten rounds in one JVM per run (three JVMs per run of record, nine over the runs); `sync` and the stampede
  on Redis are unit 12's and 13's (RE-MEASURE 15) and are not measured here.
- The `NullValue` bytes are a harness bean's (`h11`), labelled; the anchor caches no null at 11/after.
- The strict build is a copy; the anchor ships the default serializer and its silence. Whether the course recommends the strict build or
  the versioned prefix is the script's to say — both are captured, each with its outcome.
- The Compose run uses Maven's class path (`dependency:build-classpath` in `after/`'s build), as Course 5's *Docker Compose for Development* did; the jar holds
  no Compose support and is not run under `dev`.
- `-Pnative` is not measured (RED #6): no Section 2 sentence speaks of it; the anchor README's "need no Docker" is kept true by `nodocker`.
- The four callers of `findAll()` are read off the sources (the receipt prints the grep); no caller was run to prove it does not mutate.
- The harness passes the dev-shaped settings itself (`spring.cache.type=redis`, the indicator on, Lettuce's host and port); only the
  `compose` capture reads `application-dev.yaml` through the profile.

<!-- values: begin -->
the values the video may say - exercise: the line 22 words · broken: call 2 (the hit) threw SerializationException: Could not read JSON: Unexpected token, repository calls 0 · solved: call 2 returned java.util.ArrayList, repository calls 0 · exit 0 both · nodocker: 18 (mvn -o package, Maven's DOCKER_HOST at nothing - no Docker) · 18 + 5 (mvn -o verify: H2 in memory + PostgreSQL in containers, on Caffeine, no Redis) · anchor: default run (H2, no Redis): org.springframework.cache.caffeine.CaffeineCacheManager, health 200, readiness 200, /dashboard 200, no redis component, RedisCaching's beans absent · dev-shaped (PostgreSQL + Redis by the digest): org.springframework.data.redis.cache.RedisCacheManager, LettuceConnectionFactory 127.0.0.1:20502, redis_version:8.10.3, the writer asynchronousWrites false with a lock, health 200 redis UP, key customers::SimpleKey [] · [1, 0, 0, 0, 0] on both · classes ArrayList of Customer · libs 103 -> 122 (+19: lettuce-core-7.5.2.RELEASE.jar, netty-buffer-4.2.19.Final.jar, netty-codec-base-4.2.19.Final.jar, netty-codec-dns-4.2.19.Final.jar, netty-common-4.2.19.Final.jar, netty-handler-4.2.19.Final.jar, netty-resolver-4.2.19.Final.jar, netty-resolver-dns-4.2.19.Final.jar, netty-transport-4.2.19.Final.jar, netty-transport-native-unix-common-4.2.19.Final.jar, reactive-streams-1.0.4.jar, reactor-core-3.8.8.jar, redis-authx-core-0.1.1-beta2.jar, spring-boot-data-redis-4.1.2.jar, spring-boot-netty-4.1.2.jar, spring-data-keyvalue-4.1.2.jar, spring-data-redis-4.1.2.jar, spring-messaging-7.0.10.jar, spring-oxm-7.0.10.jar) · Boot 4.1.2 · Framework 7.0.10 · Spring Data JPA/JDBC/Redis 4.1.2 · HHH000001 7.4.13.Final · Flyway 12.4.0 · Lettuce lettuce-core-7.5.2.RELEASE.jar · Jackson jackson-databind-3.1.7.jar · Found 1 JPA + 1 JDBC + 0 Redis · compose: Using Docker Compose file · Network c8-unit11_default Created · c8-unit11-redis-1 and -postgres-1 Created / Started / Waiting / Healthy · beans dataRedisConnectionDetailsForC8Unit11Redis1, flywayConnectionDetailsForC8Unit11Postgres1, jdbcConnectionDetailsForC8Unit11Postgres1, jdbcConnectionDetailsHikariBeanPostProcessor · no spring.data.redis key · org.springframework.data.redis.cache.RedisCacheManager on 127.0.0.1:20503 · [1, 0, 0, 0, 0] · --scan customers::SimpleKey [] · health 200 redis UP · after Boot's stop: c8-unit11-postgres-1 Exited (0) and c8-unit11-redis-1 Exited (0), the network and the volume left · down -v: 4 Removed lines, volumes back to 315 · jdk: the copy without RedisCaching's configuration (Java's serialization): call 1 and call 2 each invoke (invocations 1, then 2) and throw SerializationException: Cannot serialize <- NotSerializableException: com.tiffinbox.Customer at put · redis-cli --scan: no key · the record not Serializable · json: bytes by redis-cli GET ["java.util.ArrayList",[{"@class":"com.tiffinbox.Customer","… · the class read back java.util.ArrayList of com.tiffinbox.Customer · [1, 0, 0, 0, 0] · TYPE string, TTL -1 · toList() copy: call 1 returned, call 2 (the hit) threw SerializationException: Could not read JSON: Unexpected token … type id (bytes [{"@class":"com.tiffinbox.Customer",…) · the harness's null (h11, labelled): per call [1, 0], bytes "\xac\xed\x00\x05sr\x00+org.springframework.cache.support.Nu… · renamed: the anchor's key customers::SimpleKey [] · the planted bytes (Priya's mealType as type, by redis-cli SET) -> Customer[name=Priya, mealsPerDay=1, pricePerMeal=120, mealType=null], invocations 0, statements 0, exit 0, no exception, no ERROR · psql: Priya VEGAN · credited to the serializer's own setting: Jackson 3's FAIL_ON_UNKNOWN_PROPERTIES default iconst_0 and GenericJacksonJsonRedisSerializer's builder configure(FAIL_ON_UNKNOWN_PROPERTIES, iconst_0) (javap) · renamed int field: Cannot map `null` into type `int` · renamed class: Could not resolve type id 'com.tiffinbox.CustomerV0' as a subtype of `java.lang.Object`: no such class found · strict: the strict copy (FAIL_ON_UNKNOWN_PROPERTIES enabled): the same planted bytes -> the hit throws SerializationException: Could not read JSON: Unrecognized property "type", invocations 0 (the caller gets the exception) · the trade-off: an added field (phone) throws too · a versioned key prefix (v2:, from CacheProperties) on the anchor: invocations 1, Priya VEGAN, --scan both keys · writer: the writer Boot builds over Lettuce (the copy, asynchronousWrites true, no lock): @CacheEvict(allEntries = true) then an immediate read - stale in 10 of 10; a read right after a put reached the repository in some of fifty rounds (the count not voiced) · the cache writer TiffinBox gives Redis (immediateWrites + enableLocking): stale 0 of 10, none after a put · javap: asynchronousWrites, immediateWrites() · Lettuce only · ttlbean: the copy whose bean ignores CacheProperties, time-to-live set: redis-cli TTL -1 · the anchor's bean, the same setting: TTL a positive count, at most the configured value (masked, never voiced as a time) · the anchor with none: TTL -1 · health: no Redis, Redis's indicator on: /actuator/health 503 (redis DOWN), readiness 200, /dashboard 200 · the cache type redis with no Redis: started, each call threw RedisConnectionFailureException · the anchor's default: health 200, no redis component (anchor) · seven: the seven 466c20ed… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · Hibernate's script = xcheck.sql
<!-- values: end -->

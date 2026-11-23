# c8-unit25 — *The Spring Data Commons Layer*

Course 8, Section 5's first unit, and **no change to the anchor** (flag 3): `before` and `after` are both links to
`../c8-unit24/after`, one tree, and `../c8-tiffinbox` equals it before and after this unit. The unit reads what TiffinBox's six
shipped repositories share, twice — off the jars (`javap`, `unzip`) and off the run (the harness, joined to TiffinBox under the
profile "dev" on the unit's four stores) — and where that shared part ends.

The Commons layer: the interfaces, the method-name parser and the factory key that TiffinBox's five Spring Data modules share.

Which store answered, in every line: **the jars** (`jars`: the eight Spring Data jars by path under `.m2-demo`, no JVM); **24/after
under "dev" with the harness joined** (`hierarchy`, `parse`, `strict`, `types`, `hole`, `saveall`: TiffinBox on `20640`, its
PostgreSQL `20641`, Redis `20642`, MongoDB `20643`, Elasticsearch `20644`); **24/after's jar, default run, H2, no Docker** (the
seven, `20640`); **the tests' copy** (`verify`: Testcontainers' own containers, the two pinned ITs on `20578` and `20615`); **the
exercise's own four stores** (`20641`-`20644`, its TiffinBox on `20645`). Every line the harness prints begins "the harness's";
the two repositories it builds — `RValue` on Spring Data Redis, `MValue` on Spring Data MongoDB — are its own, built through each
module's `RepositoryFactorySupport`, never by a scan of its package, and never TiffinBox's.

Ten captures. `jars`, `hierarchy`, `parse`, `strict`, `types` and `hole` run three times inside each run of `receipts.sh` and are
hashed (`receipts.md5`); `exercise`, `saveall`, the seven and `verify` run once per run, and their 3/3 is across the runs of record.
Every number below is asserted after its capture by `harness/chk25.py`, re-derived from the capture's own lines — never from this
README's prose.

## Runs of record

Three runs of `receipts.sh` on 2026-11-23, each ending `c8-unit25: every capture = published …`, each log through
`check_unit8.py 25 --runlog` (`RESULT (run logs): PASS`; the unit gate itself exits `2` until the script stage writes unit `25`'s
script — expected). Every capture's md5 equals `receipts.md5`'s in all three; both builds offline (`offline: yes`, `Downloaded
from` `0`). The launch rule is unit `23`'s (`c8-unit23/README.md:30`) as S8.112 tightened it: a run of record launches only while
the first of the machine's three load averages is below `20` and no other receipt is live, and the load is printed beside the run. Each run's
launch waited `0` checks; the three load averages at each run's start and end:

| run | how | result | load at start | load at end |
|---|---|---|---|---|
| run1-bash32 | `./receipts.sh` — macOS's bash 3.2.57 | PASS | `5.87 5.25 4.56` | `4.43 5.11 4.75` |
| run2-bash53 | `bash receipts.sh` — Homebrew's bash 5.3.9 | PASS | `4.23 5.06 4.73` | `4.80 4.86 4.72` |
| run3-sealed | a sealed fresh clone in a path with a space (`sealed 25/`), `./receipts.sh`, `DOCKER_CONFIG=$HOME/.docker` | PASS | `4.11 4.70 4.67` | `5.78 5.27 4.88` |

Not runs of record, said so: an earlier launch of run 1 (`./receipts.sh`, load `2.49` at its start) was stopped by this agent with
SIGINT in its exercise, to add the hole table's numbers check to `harness/chk25.py` before any run of record — its trap left nothing
(java `0`, containers `0`, volumes `315`); the next launch (load `3.31` at its start) printed every capture `= published` and then
stopped at the README's values block, which had been written from a development run without the exercise's line (`exit 1`, the
README fixed, the run repeated). The three runs above ran on the files as committed. A last full run of `./receipts.sh` on the
files as committed (this README whole, with this section, the SIGINT points and the plants in place) followed the plants; its
result and its load are in this unit's commit message.

## RE-MEASURE 1 — `hierarchy`, `parse` and `strict` on 24/after under this harness (settled first)

Settled, 3/3 in each run of record, every count the probe's: Commons' `Repositories` over the dev context lists `6` repositories,
their factory beans are `5` classes (`5` modules), every chain of interfaces ends at `org.springframework.data.repository.Repository`
in `spring-data-commons-4.1.2.jar`, and each composition holds one fragment, the module's base class. Commons' `PartTree` prints
`name SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By` for `findByName` on `CustomerEntity`, `CustomerRow` and `Dish` and for
`Dishes.searchByName` (`x4`), and `mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By` for `findByMealType` on all six
domain types (`x6`). This start prints `Multiple Spring Data modules found, entering strict repository configuration mode` `x6`
and `12` store-assignment lines, each its module's one template filled in (JPA `4`, Elasticsearch `2`, Reactive Elasticsearch `2`, MongoDB `2`,
Redis `2`) — unit 22's after printed the same `12` (`c8-unit22/README.md:113`, the line in the block that opens at `:111`).

## RE-MEASURE 2 — `hole`, per call, with the shipped harness's names (settled first)

Settled, 3/3 in each run of record, each call between its own two markers (RED #5): the harness's Redis repository answers
`findByValue(240)` with zero orders and no exception, one command in its window (`SINTER kitchen-order:value:240`), beside the
harness's MongoDB repository's `30`; `findByValueGreaterThan(200)` throws at the call on Spring Data Redis with `0` commands in its
window, beside MongoDB's `60`; `findByMealTypo` builds on Spring Data Redis and its first call throws (`0` commands), while Spring
Data MongoDB refuses it at the build. The table is below ("The hole, cell by cell"); every cell matches the probe's per-call
re-measurement.

## RE-MEASURE `3` + `4` — `saveall`, `types`, and the exercise's fix (settled first)

`saveall`, once per run of record, 3/3 across the runs: one Commons method, `saveAll` of three new entities, and five requests by
their witnesses; Spring Data JPA, `BEGIN` + three `INSERT` + `COMMIT` in PostgreSQL's log; Spring Data JDBC, the same shape; Spring
Data Redis, `21` commands (per entity `DEL`, `HMSET`, five `SADD`); Spring Data MongoDB, `3` `update` upserts beside `MongoTemplate.insertAll`'s
`1` `insert` (`ninserted 3`); Spring Data Elasticsearch, `_bulk?refresh=false` + `_refresh` (`2` requests). `types`, 3/3 in each run:
`Window` and `ScrollPosition` load from `spring-data-commons-4.1.2.jar`; the shipped `findFirst10ByOrderByNameAsc(ScrollPosition.keyset())`
answers the first window, `[Meera, Priya, Ravi, Sunil]`, `hasNext false` — four customers under a limit of ten: no second window,
so no keyset predicate is claimed (RED #16). The exercise's fix, once per run of record in bash and in zsh, 3/3 across the runs:
`@Indexed` on `value` in a copy of `KitchenOrder`, and TiffinBox's own seeding writes the set — `findByValue(240)` answers `30`,
`redis-cli SCARD kitchen-order:value:240` answers `30`.

## RE-MEASURE 13 — `verify` on the labelled rebound copy: `18` + `13`, five IT BINDINGS lines (settled first)

The tests ran on a copy with the three older tests' containers bound to 127.0.0.1 — U27 ships that change.

`.harness/tests` is a copy of after/ with `harness/it-bindings.patch` applied: five test files, nothing under `src/main`. Once per
run of record: `Tests run: 18` and `Tests run: 13`, `0` failures each, read off Maven's Results lines; five `IT BINDINGS` lines, five
distinct classes, every host address `127.0.0.1`; `ElasticsearchIT` passed in every run, each run launched below the load line
(its log's lines `Timed out waiting` are counted in `verify`). `Pulling` `0`; no Testcontainers container left.

## The captures — what each one shows

### 1 · jars — the interfaces, the factory key and the creators, off the jars (S8.98)

The eight jars by path under `.m2-demo`, each with its size and md5, equal to after/'s `BOOT-INF/lib`. `Repository<T, ID>` has an
empty body (a marker); `CrudRepository` has `12` abstract methods; `JpaRepository` adds `11`; `MongoRepository` adds `insert`;
`ElasticsearchRepository` extends `PagingAndSortingRepository` and `CrudRepository` (no `List` forms, no query by example) and adds
`searchSimilar` and the refresh-policy overloads. TiffinBox's JDBC and Redis repositories extend Commons' interfaces directly. The
factory key is in six jars (`none` in commons and relational), and the five query creators each extend Commons' `AbstractQueryCreator`.

```text
-- jars: the eight Spring Data jars, by path under .m2-demo (the seed's copy), each with its size and md5:
  .m2-demo/org/springframework/data/spring-data-commons/4.1.2/spring-data-commons-4.1.2.jar 1781830 B md5 941395f823a50945ba3b5cd176ebe669
  .m2-demo/org/springframework/data/spring-data-jpa/4.1.2/spring-data-jpa-4.1.2.jar 2208897 B md5 04cc0a03b45fc44fb794d4b4ea450989
  .m2-demo/org/springframework/data/spring-data-jdbc/4.1.2/spring-data-jdbc-4.1.2.jar 520907 B md5 e6721d0c30ed80cc79425d66b4f3b42b
  .m2-demo/org/springframework/data/spring-data-relational/4.1.2/spring-data-relational-4.1.2.jar 591434 B md5 49be89263e48c58b7a7c8ee4e37aa3d9
  .m2-demo/org/springframework/data/spring-data-redis/4.1.2/spring-data-redis-4.1.2.jar 2455537 B md5 3e6e613a19f0ec40db44cda8eb5c80ed
  .m2-demo/org/springframework/data/spring-data-keyvalue/4.1.2/spring-data-keyvalue-4.1.2.jar 141221 B md5 963cccc13aa1f85e6c65a438f388598f
  .m2-demo/org/springframework/data/spring-data-mongodb/5.1.2/spring-data-mongodb-5.1.2.jar 2722370 B md5 81cb434bac858c69f6e2002d5c33f1a1
  .m2-demo/org/springframework/data/spring-data-elasticsearch/6.1.2/spring-data-elasticsearch-6.1.2.jar 1075347 B md5 0b0388443c49a8b239ed14fdfa651d31
  the same jars in after/'s BOOT-INF/lib, md5 equal to the seed's: yyyyyyyy
== Commons' repository interfaces (javap -p -cp spring-data-commons-4.1.2.jar):
-- org.springframework.data.repository.Repository
   public interface org.springframework.data.repository.Repository<T, ID> {
   }
-- org.springframework.data.repository.CrudRepository
   public interface org.springframework.data.repository.CrudRepository<T, ID> extends org.springframework.data.repository.Repository<T, ID> {
     public abstract <S extends T> S save(S);
     public abstract <S extends T> java.lang.Iterable<S> saveAll(java.lang.Iterable<S>);
     public abstract java.util.Optional<T> findById(ID);
     public abstract boolean existsById(ID);
     public abstract java.lang.Iterable<T> findAll();
     public abstract java.lang.Iterable<T> findAllById(java.lang.Iterable<ID>);
     public abstract long count();
     public abstract void deleteById(ID);
     public abstract void delete(T);
     public abstract void deleteAllById(java.lang.Iterable<? extends ID>);
     public abstract void deleteAll(java.lang.Iterable<? extends T>);
     public abstract void deleteAll();
   }
-- org.springframework.data.repository.ListCrudRepository
   public interface org.springframework.data.repository.ListCrudRepository<T, ID> extends org.springframework.data.repository.CrudRepository<T, ID> {
     public abstract <S extends T> java.util.List<S> saveAll(java.lang.Iterable<S>);
     public abstract java.util.List<T> findAll();
     public abstract java.util.List<T> findAllById(java.lang.Iterable<ID>);
     public default java.lang.Iterable findAllById(java.lang.Iterable);
     public default java.lang.Iterable findAll();
     public default java.lang.Iterable saveAll(java.lang.Iterable);
   }
-- org.springframework.data.repository.PagingAndSortingRepository
   public interface org.springframework.data.repository.PagingAndSortingRepository<T, ID> extends org.springframework.data.repository.Repository<T, ID> {
     public abstract java.lang.Iterable<T> findAll(org.springframework.data.domain.Sort);
     public abstract org.springframework.data.domain.Page<T> findAll(org.springframework.data.domain.Pageable);
   }
-- org.springframework.data.repository.ListPagingAndSortingRepository
   public interface org.springframework.data.repository.ListPagingAndSortingRepository<T, ID> extends org.springframework.data.repository.PagingAndSortingRepository<T, ID> {
     public abstract java.util.List<T> findAll(org.springframework.data.domain.Sort);
     public default java.lang.Iterable findAll(org.springframework.data.domain.Sort);
   }
-- org.springframework.data.repository.query.QueryByExampleExecutor
   public interface org.springframework.data.repository.query.QueryByExampleExecutor<T> {
     public abstract <S extends T> java.util.Optional<S> findOne(org.springframework.data.domain.Example<S>);
     public abstract <S extends T> java.lang.Iterable<S> findAll(org.springframework.data.domain.Example<S>);
     public abstract <S extends T> java.lang.Iterable<S> findAll(org.springframework.data.domain.Example<S>, org.springframework.data.domain.Sort);
     public abstract <S extends T> org.springframework.data.domain.Page<S> findAll(org.springframework.data.domain.Example<S>, org.springframework.data.domain.Pageable);
     public abstract <S extends T> long count(org.springframework.data.domain.Example<S>);
     public abstract <S extends T> boolean exists(org.springframework.data.domain.Example<S>);
     public abstract <S extends T, R> R findBy(org.springframework.data.domain.Example<S>, java.util.function.Function<org.springframework.data.repository.query.FluentQuery$FetchableFluentQuery<S>, R>);
   }
== each module's own repository interface (javap -p, the module's jar + Commons'):
-- spring-data-jpa-4.1.2.jar
   public interface org.springframework.data.jpa.repository.JpaRepository<T, ID> extends org.springframework.data.repository.ListCrudRepository<T, ID>, org.springframework.data.repository.ListPagingAndSortingRepository<T, ID>, org.springframework.data.repository.query.QueryByExampleExecutor<T> {
     public abstract void flush();
     public abstract <S extends T> S saveAndFlush(S);
     public abstract <S extends T> java.util.List<S> saveAllAndFlush(java.lang.Iterable<S>);
     public default void deleteInBatch(java.lang.Iterable<T>);
     public abstract void deleteAllInBatch(java.lang.Iterable<T>);
     public abstract void deleteAllByIdInBatch(java.lang.Iterable<ID>);
     public abstract void deleteAllInBatch();
     public abstract T getOne(ID);
     public abstract T getById(ID);
     public abstract T getReferenceById(ID);
     public abstract <S extends T> java.util.List<S> findAll(org.springframework.data.domain.Example<S>);
     public abstract <S extends T> java.util.List<S> findAll(org.springframework.data.domain.Example<S>, org.springframework.data.domain.Sort);
     public default java.lang.Iterable findAll(org.springframework.data.domain.Example, org.springframework.data.domain.Sort);
     public default java.lang.Iterable findAll(org.springframework.data.domain.Example);
   }
-- spring-data-mongodb-5.1.2.jar
   public interface org.springframework.data.mongodb.repository.MongoRepository<T, ID> extends org.springframework.data.repository.ListCrudRepository<T, ID>, org.springframework.data.repository.ListPagingAndSortingRepository<T, ID>, org.springframework.data.repository.query.QueryByExampleExecutor<T> {
     public abstract <S extends T> S insert(S);
     public abstract <S extends T> java.util.List<S> insert(java.lang.Iterable<S>);
     public abstract <S extends T> java.util.List<S> findAll(org.springframework.data.domain.Example<S>);
     public abstract <S extends T> java.util.List<S> findAll(org.springframework.data.domain.Example<S>, org.springframework.data.domain.Sort);
     public default java.lang.Iterable findAll(org.springframework.data.domain.Example, org.springframework.data.domain.Sort);
     public default java.lang.Iterable findAll(org.springframework.data.domain.Example);
   }
-- spring-data-elasticsearch-6.1.2.jar
   public interface org.springframework.data.elasticsearch.repository.ElasticsearchRepository<T, ID> extends org.springframework.data.repository.PagingAndSortingRepository<T, ID>, org.springframework.data.repository.CrudRepository<T, ID> {
     public abstract org.springframework.data.domain.Page<T> searchSimilar(T, java.lang.String[], org.springframework.data.domain.Pageable);
     public abstract <S extends T> S save(S, org.springframework.data.elasticsearch.core.RefreshPolicy);
     public abstract <S extends T> java.lang.Iterable<S> saveAll(java.lang.Iterable<S>, org.springframework.data.elasticsearch.core.RefreshPolicy);
     public abstract void deleteById(ID, org.springframework.data.elasticsearch.core.RefreshPolicy);
     public abstract void delete(T, org.springframework.data.elasticsearch.core.RefreshPolicy);
     public abstract void deleteAllById(java.lang.Iterable<? extends ID>, org.springframework.data.elasticsearch.core.RefreshPolicy);
     public abstract void deleteAll(java.lang.Iterable<? extends T>, org.springframework.data.elasticsearch.core.RefreshPolicy);
     public abstract void deleteAll(org.springframework.data.elasticsearch.core.RefreshPolicy);
   }
-- spring-data-keyvalue-4.1.2.jar (Spring Data Redis's repositories' base)
   public interface org.springframework.data.keyvalue.repository.KeyValueRepository<T, ID> extends org.springframework.data.repository.ListCrudRepository<T, ID>, org.springframework.data.repository.ListPagingAndSortingRepository<T, ID> {
   }
== TiffinBox's six repository interfaces, their extends lines (grep -n, after/'s sources):
  CustomerEntityRepository.java:43:public interface CustomerEntityRepository extends JpaRepository<CustomerEntity, Long>
  DishEntityRepository.java:11:public interface DishEntityRepository extends JpaRepository<DishEntity, Long>
  CustomerAggregates.java:18:public interface CustomerAggregates extends ListCrudRepository<CustomerRow, Long>, ListPagingAndSortingRepository<CustomerRow, Long>
  KitchenOrders.java:17:public interface KitchenOrders extends CrudRepository<KitchenOrder, String>
  OrderDocuments.java:16:public interface OrderDocuments extends MongoRepository<OrderDocument, String>
  Dishes.java:23:public interface Dishes extends ElasticsearchRepository<Dish, String>
== META-INF/spring.factories, the key org.springframework.data.repository.core.support.RepositoryFactorySupport (unzip -p), each jar:
  spring-data-commons-4.1.2.jar            none
  spring-data-jpa-4.1.2.jar                org.springframework.data.jpa.repository.support.JpaRepositoryFactory
  spring-data-jdbc-4.1.2.jar               org.springframework.data.jdbc.repository.support.JdbcRepositoryFactory
  spring-data-relational-4.1.2.jar         none
  spring-data-redis-4.1.2.jar              org.springframework.data.redis.repository.support.RedisRepositoryFactory
  spring-data-keyvalue-4.1.2.jar           org.springframework.data.keyvalue.repository.support.KeyValueRepositoryFactory
  spring-data-mongodb-5.1.2.jar            org.springframework.data.mongodb.repository.support.MongoRepositoryFactory
  spring-data-elasticsearch-6.1.2.jar      org.springframework.data.elasticsearch.repository.support.ElasticsearchRepositoryFactory
== each module's query creator, its class line (javap):
  public class org.springframework.data.jpa.repository.query.JpaQueryCreator extends org.springframework.data.repository.query.parser.AbstractQueryCreator<java.lang.String, org.springframework.data.jpa.repository.query.JpqlQueryBuilder$Predicate> implements org.springframework.data.jpa.repository.query.JpqlQueryCreator {
  public abstract class org.springframework.data.relational.repository.query.RelationalQueryCreator<T> extends org.springframework.data.repository.query.parser.AbstractQueryCreator<T, org.springframework.data.relational.core.query.Criteria> {
  public class org.springframework.data.redis.repository.query.RedisQueryCreator extends org.springframework.data.repository.query.parser.AbstractQueryCreator<org.springframework.data.keyvalue.core.query.KeyValueQuery<org.springframework.data.redis.repository.query.RedisOperationChain>, org.springframework.data.redis.repository.query.RedisOperationChain> {
  public class org.springframework.data.mongodb.repository.query.MongoQueryCreator extends org.springframework.data.repository.query.parser.AbstractQueryCreator<org.springframework.data.mongodb.core.query.Query, org.springframework.data.mongodb.core.query.Criteria> {
  public class org.springframework.data.elasticsearch.repository.query.parser.ElasticsearchQueryCreator extends org.springframework.data.repository.query.parser.AbstractQueryCreator<org.springframework.data.elasticsearch.core.query.CriteriaQuery, org.springframework.data.elasticsearch.core.query.CriteriaQuery> {
== Commons' domain types (unzip -l spring-data-commons-4.1.2.jar org/springframework/data/domain/):
  org/springframework/data/domain/Example.class
  org/springframework/data/domain/KeysetScrollPosition.class
  org/springframework/data/domain/OffsetScrollPosition.class
  org/springframework/data/domain/Page.class
  org/springframework/data/domain/PageRequest.class
  org/springframework/data/domain/Pageable.class
  org/springframework/data/domain/ScrollPosition.class
  org/springframework/data/domain/Slice.class
  org/springframework/data/domain/Sort.class
  org/springframework/data/domain/Window.class
== Redis's refusal, the string in RedisQueryCreator.class (unzip -p | strings): .%s is not supported for Redis query derivation
== Boot's Docker Compose support, skip.in-tests (.m2-demo's spring-boot-docker-compose-4.1.2.jar, its metadata - the jar is not in after/'s BOOT-INF/lib): spring.docker.compose.skip.in-tests default true
```

### 2 · hierarchy — the six, off the run (S8.98, S8.101)

The harness builds its two repositories through the factories first; Commons' `Repositories` still lists TiffinBox's six. `KitchenOrders`' base class is `SimpleKeyValueRepository` — Spring Data KeyValue's class, not Spring Data Redis's.

```text
-- hierarchy: TiffinBox (after/) under dev on the unit's four stores, the harness joined (facts); the JVM's exit 0
the harness's repositories built by the factories before the listing: RValue by RedisRepositoryFactory (true), MValue by MongoRepositoryFactory (true) - no bean of either
the harness's repositories (org.springframework.data.repository.support.Repositories over the context): 6
the harness's REPO CustomerEntityRepository · domain CustomerEntity · id Long · bean customerEntityRepository · factory bean org.springframework.data.jpa.repository.support.JpaRepositoryFactoryBean · base class org.springframework.data.jpa.repository.support.SimpleJpaRepository
the harness's   chain com.tiffinbox.CustomerEntityRepository [tiffinbox-core-1.0.0.jar] -> [JpaRepository]
the harness's   chain org.springframework.data.jpa.repository.JpaRepository [spring-data-jpa-4.1.2.jar] -> [ListCrudRepository, ListPagingAndSortingRepository, QueryByExampleExecutor]
the harness's   chain org.springframework.data.repository.ListCrudRepository [spring-data-commons-4.1.2.jar] -> [CrudRepository]
the harness's   chain org.springframework.data.repository.ListPagingAndSortingRepository [spring-data-commons-4.1.2.jar] -> [PagingAndSortingRepository]
the harness's   chain org.springframework.data.repository.query.QueryByExampleExecutor [spring-data-commons-4.1.2.jar] -> []
the harness's   chain org.springframework.data.repository.CrudRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.PagingAndSortingRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.Repository [spring-data-commons-4.1.2.jar] -> []
the harness's   query methods [findAllByOrderByNameAsc, findByName, findFirst10ByOrderByNameAsc, monthRevenue, pausedDays]
the harness's   composition's fragments 1 [StructuralRepositoryFragment SimpleJpaRepository]
the harness's REPO DishEntityRepository · domain DishEntity · id Long · bean dishEntityRepository · factory bean org.springframework.data.jpa.repository.support.JpaRepositoryFactoryBean · base class org.springframework.data.jpa.repository.support.SimpleJpaRepository
the harness's   chain com.tiffinbox.DishEntityRepository [tiffinbox-core-1.0.0.jar] -> [JpaRepository]
the harness's   chain org.springframework.data.jpa.repository.JpaRepository [spring-data-jpa-4.1.2.jar] -> [ListCrudRepository, ListPagingAndSortingRepository, QueryByExampleExecutor]
the harness's   chain org.springframework.data.repository.ListCrudRepository [spring-data-commons-4.1.2.jar] -> [CrudRepository]
the harness's   chain org.springframework.data.repository.ListPagingAndSortingRepository [spring-data-commons-4.1.2.jar] -> [PagingAndSortingRepository]
the harness's   chain org.springframework.data.repository.query.QueryByExampleExecutor [spring-data-commons-4.1.2.jar] -> []
the harness's   chain org.springframework.data.repository.CrudRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.PagingAndSortingRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.Repository [spring-data-commons-4.1.2.jar] -> []
the harness's   query methods []
the harness's   composition's fragments 1 [StructuralRepositoryFragment SimpleJpaRepository]
the harness's REPO CustomerAggregates · domain CustomerRow · id Long · bean customerAggregates · factory bean org.springframework.data.jdbc.repository.support.JdbcRepositoryFactoryBean · base class org.springframework.data.jdbc.repository.support.SimpleJdbcRepository
the harness's   chain com.tiffinbox.jdbc.CustomerAggregates [tiffinbox-core-1.0.0.jar] -> [ListCrudRepository, ListPagingAndSortingRepository]
the harness's   chain org.springframework.data.repository.ListCrudRepository [spring-data-commons-4.1.2.jar] -> [CrudRepository]
the harness's   chain org.springframework.data.repository.ListPagingAndSortingRepository [spring-data-commons-4.1.2.jar] -> [PagingAndSortingRepository]
the harness's   chain org.springframework.data.repository.CrudRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.PagingAndSortingRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.Repository [spring-data-commons-4.1.2.jar] -> []
the harness's   query methods [findByName, monthRevenue, pausedDays]
the harness's   composition's fragments 1 [StructuralRepositoryFragment SimpleJdbcRepository]
the harness's REPO Dishes · domain Dish · id String · bean dishes · factory bean org.springframework.data.elasticsearch.repository.support.ElasticsearchRepositoryFactoryBean · base class org.springframework.data.elasticsearch.repository.support.SimpleElasticsearchRepository
the harness's   chain com.tiffinbox.web.Dishes [tiffinbox-web-1.0.0.jar] -> [ElasticsearchRepository]
the harness's   chain org.springframework.data.elasticsearch.repository.ElasticsearchRepository [spring-data-elasticsearch-6.1.2.jar] -> [PagingAndSortingRepository, CrudRepository]
the harness's   chain org.springframework.data.repository.PagingAndSortingRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.CrudRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.Repository [spring-data-commons-4.1.2.jar] -> []
the harness's   query methods [findByName, searchByName]
the harness's   composition's fragments 1 [StructuralRepositoryFragment SimpleElasticsearchRepository]
the harness's REPO KitchenOrders · domain KitchenOrder · id String · bean kitchenOrders · factory bean org.springframework.data.redis.repository.support.RedisRepositoryFactoryBean · base class org.springframework.data.keyvalue.repository.support.SimpleKeyValueRepository
the harness's   chain com.tiffinbox.web.KitchenOrders [tiffinbox-web-1.0.0.jar] -> [CrudRepository]
the harness's   chain org.springframework.data.repository.CrudRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.Repository [spring-data-commons-4.1.2.jar] -> []
the harness's   query methods [findByCustomer, findByCustomerAndMealType, findByMealType]
the harness's   composition's fragments 1 [StructuralRepositoryFragment SimpleKeyValueRepository]
the harness's REPO OrderDocuments · domain OrderDocument · id String · bean orderDocuments · factory bean org.springframework.data.mongodb.repository.support.MongoRepositoryFactoryBean · base class org.springframework.data.mongodb.repository.support.SimpleMongoRepository
the harness's   chain com.tiffinbox.web.OrderDocuments [tiffinbox-web-1.0.0.jar] -> [MongoRepository]
the harness's   chain org.springframework.data.mongodb.repository.MongoRepository [spring-data-mongodb-5.1.2.jar] -> [ListCrudRepository, ListPagingAndSortingRepository, QueryByExampleExecutor]
the harness's   chain org.springframework.data.repository.ListCrudRepository [spring-data-commons-4.1.2.jar] -> [CrudRepository]
the harness's   chain org.springframework.data.repository.ListPagingAndSortingRepository [spring-data-commons-4.1.2.jar] -> [PagingAndSortingRepository]
the harness's   chain org.springframework.data.repository.query.QueryByExampleExecutor [spring-data-commons-4.1.2.jar] -> []
the harness's   chain org.springframework.data.repository.CrudRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.PagingAndSortingRepository [spring-data-commons-4.1.2.jar] -> [Repository]
the harness's   chain org.springframework.data.repository.Repository [spring-data-commons-4.1.2.jar] -> []
the harness's   query methods [findByMealType]
the harness's   composition's fragments 1 [StructuralRepositoryFragment SimpleMongoRepository]
  who names each in src/main and in src/test (harness/chk25.py inject: after/'s Java, comments stripped, the repository's own file left out):
    CustomerEntityRepository  main: CustomerRepository · test: CustomerAggregatesIT, CustomerEntityRepositoryIT
    DishEntityRepository      main: DishService, TiffinBoxServer · test: none
    CustomerAggregates        main: none · test: CustomerAggregatesIT
    KitchenOrders             main: RedisDatastore, TiffinBoxServer · test: RedisDatastoreIT
    OrderDocuments            main: none · test: MongoDatastoreIT, MongoSlice
    Dishes                    main: DishIndexSync, DishSearch, TiffinBoxServer · test: ElasticsearchIT, ElasticsearchSlice
```

### 3 · parse — one parser, five requests (S8.99)

The filter is declared: PostgreSQL's window counts non-empty statements, the raw count beside it (Hikari's empty validation
statement lands in the JDBC window — raw `3`, non-empty `2`, in every run).

```text
-- parse: Commons' PartTree on each query method's name (the harness, facts), and on findByMealType for all six domain types:
the harness's   PartTree("findAllByOrderByNameAsc", CustomerEntity) = Order By name: ASC
the harness's   PartTree("findByName", CustomerEntity) = name SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's   PartTree("findFirst10ByOrderByNameAsc", CustomerEntity) = Order By name: ASC
the harness's   PartTree("monthRevenue", CustomerEntity) refused: org.springframework.data.core.PropertyReferenceException: No property 'monthRevenue' found for type 'CustomerEntity'
the harness's   PartTree("pausedDays", CustomerEntity) refused: org.springframework.data.core.PropertyReferenceException: No property 'pausedDays' found for type 'CustomerEntity'
the harness's   PartTree("findByName", CustomerRow) = name SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's   PartTree("monthRevenue", CustomerRow) refused: org.springframework.data.core.PropertyReferenceException: No property 'monthRevenue' found for type 'CustomerRow'
the harness's   PartTree("pausedDays", CustomerRow) refused: org.springframework.data.core.PropertyReferenceException: No property 'pausedDays' found for type 'CustomerRow'
the harness's   PartTree("findByName", Dish) = name SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's   PartTree("searchByName", Dish) = name SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's   PartTree("findByCustomer", KitchenOrder) = customer SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's   PartTree("findByCustomerAndMealType", KitchenOrder) = customer SIMPLE_PROPERTY (1): [Is, Equals] NEVER and mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's   PartTree("findByMealType", KitchenOrder) = mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's   PartTree("findByMealType", OrderDocument) = mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's PARSE findByMealType on KitchenOrder = mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's PARSE findByMealType on OrderDocument = mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's PARSE findByMealType on Dish = mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's PARSE findByMealType on CustomerRow = mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's PARSE findByMealType on CustomerEntity = mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's PARSE findByMealType on DishEntity = mealType SIMPLE_PROPERTY (1): [Is, Equals] NEVER Order By
the harness's PARSE findByMealTypo on KitchenOrder refused: org.springframework.data.core.PropertyReferenceException: No property 'mealTypo' found for type 'KitchenOrder'; Did you mean 'mealType'
-- each shipped derived method, called once between its own markers; the store's witness for the window (PostgreSQL's log - non-empty statements, the markers left out, the raw count beside; Redis's MONITOR - the markers left out; MongoDB's profiler; the Elasticsearch client's trace):
  window jpa-findByName: markers found · PostgreSQL 1 non-empty statement(s) (raw 1) · Redis 0 command(s) · Elasticsearch 0 request(s)
    PostgreSQL: select ce1_0.id,ce1_0.created_at,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.updated_at,ce1_0.version from customer ce1_0 where ce1_0.name=$1
  window jdbc-findByName: markers found · PostgreSQL 2 non-empty statement(s) (raw 3) · Redis 0 command(s) · Elasticsearch 0 request(s)
    PostgreSQL: SELECT customer.id AS id, customer.name AS name, customer.version AS version, customer.meal_type AS meal_type, customer.meals_per_day AS meals_per_day, customer.price_per_meal AS price_per_meal FROM customer WHERE customer.name = $1
    PostgreSQL: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer_id = $1
  window redis-findByMealType: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 61 command(s) · Elasticsearch 0 request(s)
    Redis: "SINTER" "kitchen-order:mealType:VEG"
    Redis: "HGETALL" "kitchen-order:<id>" (x60)
  window redis-findByCustomerAndMealType: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 31 command(s) · Elasticsearch 0 request(s)
    Redis: "SINTER" "kitchen-order:customer:Ravi" "kitchen-order:mealType:VEG"
    Redis: "HGETALL" "kitchen-order:<id>" (x30)
  window mongo-findByMealType: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window es-findByName: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 2 request(s)
    Elasticsearch: POST '<es>/dishes/_search?search_type=query_then_fetch&typed_keys=true' -d '{"_source":false,"from":0,"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":0,"track_scores":false,"track_total_hits":2147483647,"version":true}'
    Elasticsearch: POST '<es>/dishes/_search?search_type=query_then_fetch&typed_keys=true' -d '{"from":0,"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":1,"track_scores":false,"version":true}'
the harness's CALL Spring Data JPA CustomerEntityRepository.findByName("Ravi") -> Ravi VEG
the harness's CALL Spring Data JDBC CustomerAggregates.findByName("Ravi") -> Ravi id 1
the harness's CALL Spring Data Redis KitchenOrders.findByMealType("VEG") -> 60 orders, customers [Ravi, Sunil]
the harness's CALL Spring Data Redis KitchenOrders.findByCustomerAndMealType("Ravi", "VEG") -> 30 orders
the harness's   the profiler [OrderDocuments.findByMealType] op=query ns=tiffinbox.orders command=find filter={"mealType": "VEG"} docsExamined=120 nreturned=60 ninserted=null nMatched=null nModified=null nUpserted=null
the harness's   the profiler [OrderDocuments.findByMealType] entries 1
the harness's CALL Spring Data MongoDB OrderDocuments.findByMealType("VEG") -> 60 documents, customers [Ravi, Sunil]
the harness's CALL Spring Data Elasticsearch Dishes.findByName("veg") -> [1 Vegetarian Lunch Box]
```

### 4 · strict — the referee (R.354)

```text
-- strict: the start's repository lines (facts), whole, as printed, each counted (the logger's prefix cut):
  (x1) Bootstrapping Spring Data Elasticsearch repositories in DEFAULT mode.
  (x1) Bootstrapping Spring Data JDBC repositories in DEFAULT mode.
  (x1) Bootstrapping Spring Data JPA repositories in DEFAULT mode.
  (x1) Bootstrapping Spring Data MongoDB repositories in DEFAULT mode.
  (x1) Bootstrapping Spring Data Reactive Elasticsearch repositories in DEFAULT mode.
  (x1) Bootstrapping Spring Data Redis repositories in DEFAULT mode.
  (x1) Finished Spring Data repository scanning in <t>. Found 0 Reactive Elasticsearch repository interfaces.
  (x1) Finished Spring Data repository scanning in <t>. Found 1 Elasticsearch repository interface.
  (x1) Finished Spring Data repository scanning in <t>. Found 1 JDBC repository interface.
  (x1) Finished Spring Data repository scanning in <t>. Found 1 MongoDB repository interface.
  (x1) Finished Spring Data repository scanning in <t>. Found 1 Redis repository interface.
  (x1) Finished Spring Data repository scanning in <t>. Found 2 JPA repository interfaces.
  (x6) Multiple Spring Data modules found, entering strict repository configuration mode
  (x1) Spring Data Elasticsearch - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders; If you want this repository to be a Elasticsearch repository, consider annotating your entities with one of these annotations: org.springframework.data.elasticsearch.annotations.Document (preferred), or consider extending one of the following types with your repository: org.springframework.data.elasticsearch.repository.ElasticsearchRepository
  (x1) Spring Data Elasticsearch - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments; If you want this repository to be a Elasticsearch repository, consider annotating your entities with one of these annotations: org.springframework.data.elasticsearch.annotations.Document (preferred), or consider extending one of the following types with your repository: org.springframework.data.elasticsearch.repository.ElasticsearchRepository
  (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.jdbc.CustomerAggregates; If you want this repository to be a JPA repository, consider annotating your entities with one of these annotations: jakarta.persistence.Entity, jakarta.persistence.MappedSuperclass (preferred), or consider extending one of the following types with your repository: org.springframework.data.jpa.repository.JpaRepository
  (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes; If you want this repository to be a JPA repository, consider annotating your entities with one of these annotations: jakarta.persistence.Entity, jakarta.persistence.MappedSuperclass (preferred), or consider extending one of the following types with your repository: org.springframework.data.jpa.repository.JpaRepository
  (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders; If you want this repository to be a JPA repository, consider annotating your entities with one of these annotations: jakarta.persistence.Entity, jakarta.persistence.MappedSuperclass (preferred), or consider extending one of the following types with your repository: org.springframework.data.jpa.repository.JpaRepository
  (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments; If you want this repository to be a JPA repository, consider annotating your entities with one of these annotations: jakarta.persistence.Entity, jakarta.persistence.MappedSuperclass (preferred), or consider extending one of the following types with your repository: org.springframework.data.jpa.repository.JpaRepository
  (x1) Spring Data MongoDB - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes; If you want this repository to be a MongoDB repository, consider annotating your entities with one of these annotations: org.springframework.data.mongodb.core.mapping.Document (preferred), or consider extending one of the following types with your repository: org.springframework.data.mongodb.repository.MongoRepository
  (x1) Spring Data MongoDB - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders; If you want this repository to be a MongoDB repository, consider annotating your entities with one of these annotations: org.springframework.data.mongodb.core.mapping.Document (preferred), or consider extending one of the following types with your repository: org.springframework.data.mongodb.repository.MongoRepository
  (x1) Spring Data Reactive Elasticsearch - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders; If you want this repository to be a Reactive Elasticsearch repository, consider annotating your entities with one of these annotations: org.springframework.data.elasticsearch.annotations.Document (preferred), or consider extending one of the following types with your repository: org.springframework.data.elasticsearch.repository.ReactiveElasticsearchRepository
  (x1) Spring Data Reactive Elasticsearch - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments; If you want this repository to be a Reactive Elasticsearch repository, consider annotating your entities with one of these annotations: org.springframework.data.elasticsearch.annotations.Document (preferred), or consider extending one of the following types with your repository: org.springframework.data.elasticsearch.repository.ReactiveElasticsearchRepository
  (x1) Spring Data Redis - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes; If you want this repository to be a Redis repository, consider annotating your entities with one of these annotations: org.springframework.data.redis.core.RedisHash (preferred), or consider extending one of the following types with your repository: org.springframework.data.keyvalue.repository.KeyValueRepository
  (x1) Spring Data Redis - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments; If you want this repository to be a Redis repository, consider annotating your entities with one of these annotations: org.springframework.data.redis.core.RedisHash (preferred), or consider extending one of the following types with your repository: org.springframework.data.keyvalue.repository.KeyValueRepository
```

### 5 · types — the shared types (C8-6)

```text
-- types: Commons' shared types (the harness, facts):
the harness's TYPES Window's class org.springframework.data.domain.Window from spring-data-commons-4.1.2.jar · ScrollPosition's org.springframework.data.domain.ScrollPosition from spring-data-commons-4.1.2.jar
the harness's TYPES CustomerEntityRepository.findFirst10ByOrderByNameAsc(ScrollPosition.keyset()) -> the first window [Meera, Priya, Ravi, Sunil] · size 4 · hasNext false · its class org.springframework.data.domain.WindowImpl from spring-data-commons-4.1.2.jar
  window keyset-jpa: markers found · PostgreSQL 1 non-empty statement(s) (raw 1) · Redis 0 command(s) · Elasticsearch 0 request(s)
    PostgreSQL: select ce1_0.id,ce1_0.created_at,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.updated_at,ce1_0.version from customer ce1_0 order by ce1_0.name,ce1_0.id fetch first $1 rows only
```

### 6 · hole — where the shared layer ends (S8.100, the failure receipt)

```text
-- hole: one name on two modules - the harness's repositories, built by Spring Data Redis's and Spring Data MongoDB's own factories over TiffinBox's 120 kitchen orders (the JVM's exit 0):
the harness's Spring Data Redis's factory over KeyValueOperations (RedisKeyValueTemplate), Spring Data MongoDB's over MongoTemplate - the harness's repositories, no scan
the harness's HOLE redis RValue build ok · call -> 0 results
the harness's HOLE redis RValueGt build ok · CALL threw java.lang.IllegalArgumentException: GREATER_THAN (1): [IsGreaterThan, GreaterThan] is not supported for Redis query derivation
the harness's HOLE redis RTypo build ok · CALL threw org.springframework.data.core.PropertyReferenceException: No property 'mealTypo' found for type 'KitchenOrder'; Did you mean 'mealType'
the harness's HOLE redis RNot build ok · CALL threw java.lang.IllegalArgumentException: NEGATING_SIMPLE_PROPERTY (1): [IsNot, Not] is not supported for Redis query derivation
the harness's HOLE redis RIn build ok · CALL threw java.lang.IllegalArgumentException: IN (1): [IsIn, In] is not supported for Redis query derivation
the harness's HOLE redis RStart build ok · CALL threw java.lang.IllegalArgumentException: STARTING_WITH (1): [IsStartingWith, StartingWith, StartsWith] is not supported for Redis query derivation
the harness's HOLE redis RIgnore build ok · call -> 0 results
the harness's HOLE redis ROrder build ok · call -> 60 results
the harness's HOLE redis RCount build ok · call -> 60
the harness's HOLE redis RExists build ok · call -> true
the harness's HOLE redis RFirst build ok · call -> 3 results
the harness's HOLE redis ROr build ok · call -> 60 results
the harness's HOLE mongo MValue build ok · call -> 30 results
the harness's   the profiler [MValue] op=query ns=tiffinbox.orders command=find filter={"value": 240} docsExamined=120 nreturned=30 ninserted=null nMatched=null nModified=null nUpserted=null
the harness's   the profiler [MValue] entries 1
the harness's HOLE mongo MValueGt build ok · call -> 60 results
the harness's   the profiler [MValueGt] op=query ns=tiffinbox.orders command=find filter={"value": {"$gt": 200}} docsExamined=120 nreturned=60 ninserted=null nMatched=null nModified=null nUpserted=null
the harness's   the profiler [MValueGt] entries 1
the harness's HOLE mongo MTypo BUILD refused: org.springframework.data.repository.query.QueryCreationException: No property 'mealTypo' found for type 'OrderDocument'; Did you mean 'mealType' | cause org.springframework.data.core.PropertyReferenceException: No property 'mealTypo' found for type 'OrderDocument'; Did you mean 'mealType'
the harness's HOLE mongo MNot build ok · call -> 60 results
the harness's   the profiler [MNot] op=query ns=tiffinbox.orders command=find filter={"mealType": {"$ne": "VEG"}} docsExamined=120 nreturned=60 ninserted=null nMatched=null nModified=null nUpserted=null
the harness's   the profiler [MNot] entries 1
the harness's HOLE mongo MStart build ok · call -> 30 results
the harness's   the profiler [MStart] op=query ns=tiffinbox.orders command=find filter={"customer": {"$regularExpression": {"pattern": "^Ra", "options": ""}}} docsExamined=30 nreturned=30 ninserted=null nMatched=null nModified=null nUpserted=null
the harness's   the profiler [MStart] entries 1
the harness's Redis index sets for kitchen-order (KEYS kitchen-order:*:*, the per-order :idx sets left out): [kitchen-order:customer:Meera, kitchen-order:customer:Priya, kitchen-order:customer:Ravi, kitchen-order:customer:Sunil, kitchen-order:mealType:NON_VEG, kitchen-order:mealType:VEG, kitchen-order:mealType:VEGAN]
  each call's own window (a marker before it and after it), the commands Redis's MONITOR saw in it, the markers left out:
  window call-redis-RValue: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 1 command(s) · Elasticsearch 0 request(s)
    Redis: "SINTER" "kitchen-order:value:240"
  window call-redis-RValueGt: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window call-redis-RTypo: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window call-redis-RNot: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window call-redis-RIn: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window call-redis-RStart: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window call-redis-RIgnore: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 1 command(s) · Elasticsearch 0 request(s)
    Redis: "SINTER" "kitchen-order:mealType:veg"
  window call-redis-ROrder: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 61 command(s) · Elasticsearch 0 request(s)
    Redis: "SINTER" "kitchen-order:mealType:VEG"
    Redis: "HGETALL" "kitchen-order:<id>" (x60)
  window call-redis-RCount: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 1 command(s) · Elasticsearch 0 request(s)
    Redis: "SINTER" "kitchen-order:mealType:VEG"
  window call-redis-RExists: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 1 command(s) · Elasticsearch 0 request(s)
    Redis: "SINTER" "kitchen-order:mealType:VEG"
  window call-redis-RFirst: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 4 command(s) · Elasticsearch 0 request(s)
    Redis: "SINTER" "kitchen-order:mealType:VEG"
    Redis: "HGETALL" "kitchen-order:<id>" (x3)
  window call-redis-ROr: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 61 command(s) · Elasticsearch 0 request(s)
    Redis: "SUNION" "kitchen-order:customer:Ravi" "kitchen-order:mealType:VEGAN"
    Redis: "HGETALL" "kitchen-order:<id>" (x60)
  window call-mongo-MValue: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window call-mongo-MValueGt: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window call-mongo-MNot: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window call-mongo-MStart: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  the stores' own tools after the JVM is gone:
    redis-cli EXISTS kitchen-order:value:240 -> 0 · SCARD kitchen-order:value:240 -> 0 · SCARD kitchen-order:mealType:VEG -> 60 · SCARD kitchen-order -> 120
    redis-cli KEYS 'kitchen-order:*:*' (the per-order :idx sets left out) -> kitchen-order:customer:Meera kitchen-order:customer:Priya kitchen-order:customer:Ravi kitchen-order:customer:Sunil kitchen-order:mealType:NON_VEG kitchen-order:mealType:VEG kitchen-order:mealType:VEGAN
    mongosh: db.orders.countDocuments() -> 120 · countDocuments({value: 240}) -> 30 · countDocuments({value: {$gt: 200}}) -> 60
  c8u25-es's sockets at the end of the window (S8.92), its /proc/net/tcp, tcp6, udp and udp6 read by cat (dk exec - a file, never a shell):
    its interfaces (/proc/net/dev): eth0,lo
    the sockets: listening (TCP) on 9200, 9300 · connections from another local port (outbound): 0 · UDP sockets: 0
```

### 7 · saveall — one Commons method, five requests

```text
-- saveall: Commons' saveAll, three new entities per module (the harness's ids and names, removed after; the stores are fresh before every harness JVM anyway):
  window saveall-jpa: markers found · PostgreSQL 5 non-empty statement(s) (raw 5) · Redis 0 command(s) · Elasticsearch 0 request(s)
    PostgreSQL: BEGIN
    PostgreSQL: insert into dish (meal_type,name,price) values ($1,$2,$3) RETURNING *
    PostgreSQL: insert into dish (meal_type,name,price) values ($1,$2,$3) RETURNING *
    PostgreSQL: insert into dish (meal_type,name,price) values ($1,$2,$3) RETURNING *
    PostgreSQL: COMMIT
  window saveall-jdbc: markers found · PostgreSQL 5 non-empty statement(s) (raw 5) · Redis 0 command(s) · Elasticsearch 0 request(s)
    PostgreSQL: BEGIN
    PostgreSQL: INSERT INTO customer (meal_type, meals_per_day, name, price_per_meal, version) VALUES ($1, $2, $3, $4, $5) RETURNING *
    PostgreSQL: INSERT INTO customer (meal_type, meals_per_day, name, price_per_meal, version) VALUES ($1, $2, $3, $4, $5) RETURNING *
    PostgreSQL: INSERT INTO customer (meal_type, meals_per_day, name, price_per_meal, version) VALUES ($1, $2, $3, $4, $5) RETURNING *
    PostgreSQL: COMMIT
  window saveall-redis: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 21 command(s) · Elasticsearch 0 request(s)
    Redis: "DEL" "kitchen-order:<id>"
    Redis: "HMSET" "kitchen-order:<id>" …
    Redis: "SADD" "kitchen-order" "<id>"
    Redis: "SADD" "kitchen-order:mealType:VEG" "<id>"
    Redis: "SADD" "kitchen-order:<id>:idx" "kitchen-order:mealType:VEG"
    Redis: "SADD" "kitchen-order:customer:H25" "<id>"
    Redis: "SADD" "kitchen-order:<id>:idx" "kitchen-order:customer:H25"
    Redis: "DEL" "kitchen-order:<id>"
    Redis: "HMSET" "kitchen-order:<id>" …
    Redis: "SADD" "kitchen-order" "<id>"
    Redis: "SADD" "kitchen-order:mealType:VEG" "<id>"
    Redis: "SADD" "kitchen-order:<id>:idx" "kitchen-order:mealType:VEG"
    Redis: "SADD" "kitchen-order:customer:H25" "<id>"
    Redis: "SADD" "kitchen-order:<id>:idx" "kitchen-order:customer:H25"
    Redis: "DEL" "kitchen-order:<id>"
    Redis: "HMSET" "kitchen-order:<id>" …
    Redis: "SADD" "kitchen-order" "<id>"
    Redis: "SADD" "kitchen-order:mealType:VEG" "<id>"
    Redis: "SADD" "kitchen-order:<id>:idx" "kitchen-order:mealType:VEG"
    Redis: "SADD" "kitchen-order:customer:H25" "<id>"
    Redis: "SADD" "kitchen-order:<id>:idx" "kitchen-order:customer:H25"
  window saveall-mongo-repository: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window saveall-mongo-template: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 0 request(s)
  window saveall-es: markers found · PostgreSQL 0 non-empty statement(s) (raw 0) · Redis 0 command(s) · Elasticsearch 2 request(s)
    Elasticsearch: POST '<es>/_bulk?refresh=false' -d '{"index":{"_id":"h25-1","_index":"dishes"}}
    Elasticsearch: POST '<es>/dishes/_refresh'
the harness's   the profiler [MongoRepository.saveAll(three, ids assigned)] op=update ns=tiffinbox.orders command=update filter={"_id": "h25-1"} docsExamined=0 nreturned=null ninserted=null nMatched=0 nModified=0 nUpserted=1
the harness's   the profiler [MongoRepository.saveAll(three, ids assigned)] op=update ns=tiffinbox.orders command=update filter={"_id": "h25-2"} docsExamined=0 nreturned=null ninserted=null nMatched=0 nModified=0 nUpserted=1
the harness's   the profiler [MongoRepository.saveAll(three, ids assigned)] op=update ns=tiffinbox.orders command=update filter={"_id": "h25-3"} docsExamined=0 nreturned=null ninserted=null nMatched=0 nModified=0 nUpserted=1
the harness's   the profiler [MongoRepository.saveAll(three, ids assigned)] entries 3
the harness's   the profiler [MongoTemplate.insertAll(three)] op=insert ns=tiffinbox.orders command=insert docsExamined=null nreturned=null ninserted=3 nMatched=null nModified=null nUpserted=null
the harness's   the profiler [MongoTemplate.insertAll(three)] entries 1
the harness's MongoDB documents of the harness removed: 6
the harness's saveall done; the harness's rows, documents and keys removed
```

### 8 · seven — the comparison set on the one tree (R.363)

Before/ and after/ are one tree, so the seven runs once; its responses' md5 is the course's, read off `../c7-unit31/receipts.sh`,
the same md5 unit 24's seven printed for both its trees.

```text
-- the seven: after/'s jar, java -jar, H2 in memory (a fresh JVM), port 20640 - before/ is the same tree (one link target), so it runs once:
$ cd .harness/after && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20640
  GET /actuator/health/readiness -> 200 · listens on: 127.0.0.1:20640
$ $CURLSET 20640 .harness/after/secrets/tiffinbox/shutdown-token
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20640 now: 0
```

### 9 · verify — `18` + `13` on the labelled copy (flag 8(d))

```text
-- verify: mvn verify on .harness/tests - a copy of after/ with harness/it-bindings.patch applied (the three older tests' containers bound to 127.0.0.1, U27 ships that change; every IT prints its own container's bindings):
  the copy against after/ (diff -rq, target and secrets left out): tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java tiffinbox-web/src/test/java/com/tiffinbox/web/ElasticsearchIT.java tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java tiffinbox-web/src/test/java/com/tiffinbox/web/RedisDatastoreIT.java
  the diff (diff -ru after/ .harness/tests/, the five files): f527b912345363f0e5c2ad31c7a0403b (md5 of its changed lines) · lines added 41 · removed 3 · under src/main: 0
  the modifier, per IT file (grep -c withCreateContainerCmdModifier): CustomerEntityRepositoryIT 1 · CustomerAggregatesIT 1 · RedisDatastoreIT 1 · MongoDatastoreIT 1 · ElasticsearchIT 1
  before it: listening on 20578 (MongoDatastoreIT's pinned binding): 0 · on 20615 (ElasticsearchIT's): 0 · on 18881-18884: 0
  exit 0 · BUILD SUCCESS · offline: yes
  after it: images 9 (the same list) · volumes 315 (the count before it) · Testcontainers containers 0 · .m2-demo's files unchanged
  the Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  the Results line: Tests run: 13, Failures: 0, Errors: 0, Skipped: 0
  the IT BINDINGS lines (each IT's own container, Docker's inspect, sorted; the host port masked):
    IT BINDINGS CustomerAggregatesIT [5432/tcp -> 127.0.0.1:<port>]
    IT BINDINGS CustomerEntityRepositoryIT [5432/tcp -> 127.0.0.1:<port>]
    IT BINDINGS ElasticsearchIT [9200/tcp -> 127.0.0.1:<port>]
    IT BINDINGS MongoDatastoreIT [27017/tcp -> 127.0.0.1:<port>]
    IT BINDINGS RedisDatastoreIT [6379/tcp -> 127.0.0.1:<port>]
  the Testcontainers containers' ports while verify ran (dk ps, polled), each distinct host address: 127.0.0.1 · their images: 05b334b0a7a7 77f585114c32 7958cfbb9d15 fb7f2d0df199 · 18881-18884 bound during it: no
  ElasticsearchIT: 'Timed out waiting' lines 0 · its container started: 1 · 'Creating container for image' 5 · 'Pulling' 0 · Testcontainers containers after it: 0 · listening on 20578 and 20615 after it: 0
```

### 10 · exercise — run as written, in one shell, bash then zsh (R.196)

```text
exercise/README.md's 16 lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:
the solution's line that differs:
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
    built: 1 jar
    the lab's KitchenOrder: @Indexed fields [customer, mealType]
    the lab's RValue (built by RedisRepositoryFactory): findByValue(240) -> 0 orders
    check: the lab's call findByValue(240) -> 0 orders · redis-cli SCARD kitchen-order:value:240 0 · solved: no
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    the lab's KitchenOrder: @Indexed fields [customer, mealType, value]
    the lab's RValue (built by RedisRepositoryFactory): findByValue(240) -> 30 orders
    check: the lab's call findByValue(240) -> 30 orders · redis-cli SCARD kitchen-order:value:240 30 · solved: yes
  the shell is now in: this unit's folder · listening on 20641-20645 afterwards: 0 · the exercise's containers afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: the same list yes
in zsh (/bin/zsh -f) - the README's lines, the block's exit 0:
    built: 1 jar
    the lab's KitchenOrder: @Indexed fields [customer, mealType]
    the lab's RValue (built by RedisRepositoryFactory): findByValue(240) -> 0 orders
    check: the lab's call findByValue(240) -> 0 orders · redis-cli SCARD kitchen-order:value:240 0 · solved: no
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    the lab's KitchenOrder: @Indexed fields [customer, mealType, value]
    the lab's RValue (built by RedisRepositoryFactory): findByValue(240) -> 30 orders
    check: the lab's call findByValue(240) -> 30 orders · redis-cli SCARD kitchen-order:value:240 30 · solved: yes
  the shell is now in: this unit's folder · listening on 20641-20645 afterwards: 0 · the exercise's containers afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: the same list yes
a wrong "solution" - another method's name (the README's block, the lab's call renamed to findByCustomer("Ravi"), which finds thirty), in a fresh env -i bash, through exercise/check.sh:
  the block's exit 0:
    the lab's KitchenOrder: @Indexed fields [customer, mealType]
    the lab's RValue (built by RedisRepositoryFactory): findByCustomer(240) -> 30 orders
    check: the lab's call findByCustomer(240) -> 30 orders · redis-cli SCARD kitchen-order:value:240 0 · solved: no
a wrong "solution" - another number (SOLUTION.md's block, the lab's number 480), in a fresh env -i bash, through exercise/check.sh:
  the block's exit 0:
    the lab's KitchenOrder: @Indexed fields [customer, mealType, value]
    the lab's RValue (built by RedisRepositoryFactory): findByValue(480) -> 0 orders
    check: the lab's call findByValue(480) -> 0 orders · redis-cli SCARD kitchen-order:value:240 30 · solved: no
```

## The hole, cell by cell

One method name, two modules, the harness's two repositories, over TiffinBox's `120` kitchen orders (the same seeding in Redis's
`kitchen-order:*` and MongoDB's `tiffinbox.orders`). Every cell from `hole`'s capture; "commands" are the commands Redis's MONITOR
saw between that call's own two markers; "documents" are the profiler's `nreturned` for that call's one `find`. The second witness
for each count is the store's own tool after the JVM is gone: `redis-cli` on the unit's Redis, `mongosh` in the unit's MongoDB.

| method (one name, both modules) | Spring Data Redis (`KitchenOrder`) | commands in its window | Spring Data MongoDB (`OrderDocument`) | documents | the stores' tools |
|---|---|---|---|---|---|
| `findByValue(240)` | `0` results, no exception | `1` — `SINTER kitchen-order:value:240` | `30` | `30` (`{"value": 240}`) | `redis-cli SCARD kitchen-order:value:240` `0`, `EXISTS` `0` · `mongosh` `countDocuments({value: 240})` `30` |
| `findByValueGreaterThan(200)` | throws at the call: `IllegalArgumentException: GREATER_THAN (1): [IsGreaterThan, GreaterThan] is not supported for Redis query derivation` | `0` | `60` | `60` (`{"value": {"$gt": 200}}`) | `mongosh` `countDocuments({value: {$gt: 200}})` `60` |
| `findByMealTypo("VEG")` | builds; the first call throws `PropertyReferenceException: No property 'mealTypo' found for type 'KitchenOrder'; Did you mean 'mealType'` | `0` | refused at the build: `QueryCreationException`, the same property text for `OrderDocument` | no call | — |
| `findByMealTypeNot("VEG")` | throws at the call (`NEGATING_SIMPLE_PROPERTY`) | `0` | `60` | `60` (`$ne`) | — |
| `findByCustomerStartingWith("Ra")` | throws at the call (`STARTING_WITH`) | `0` | `30` | `30` (a regular expression `^Ra`) | — |
| `findByMealTypeIn(VEG, VEGAN)` | throws at the call (`IN`) | `0` | not run | — | — |
| `findByMealTypeIgnoreCase("veg")` | `0` results, no exception | `1` — `SINTER kitchen-order:mealType:veg` | not run | — | — |
| `findByMealTypeOrderByValueDesc("VEG")` · `countByMealType` · `existsByMealType` · `findFirst3ByMealType` · `findByMealTypeOrCustomer` | `60` · `60` · `true` · `3` · `60` | `61` · `1` · `1` · `4` · `61` (`SUNION`) | not run | — | — |

The index sets after TiffinBox's start, by the harness's `KEYS` and by `redis-cli KEYS` after the JVM: `customer` and `mealType`
only — the shipped `KitchenOrder` carries `@Indexed` on those two fields, and no `kitchen-order:value:*` set exists. So the shared
layer ends in three ways on one name: a keyword the module's creator refuses (loud, at the call, no command sent), a property the
store never indexed (zero, no exception, one command), and a typo (loud — at the build on Spring Data MongoDB, at the first call on
Spring Data Redis).

## Which store, which profile, which tree

- **One tree, named once:** `../c8-unit24/after` — `before` and `after` are both links to it; its pin is unit 24's after-tree line
  (file count and hash read off `../c8-unit24/receipts.md5` by the receipt, re-derived by `harness/tree25.py`, asserted for both
  links at the start and at the end); every capture ran on it, and its jar was built offline from a copy in `.harness/`.
- **The harness's two repositories vs TiffinBox's six:** `RValue` and its siblings (Spring Data Redis, built by
  `new RedisRepositoryFactory(keyValueOperations)`) and `MValue` and its siblings (Spring Data MongoDB, built by
  `new MongoRepositoryFactory(mongoTemplate)`) are the harness's; no bean of either exists, and `hierarchy` asserts the six it lists
  are TiffinBox's by name.
- **Dev's four stores, each with its witness:** PostgreSQL `c8u25-pg` on `20641` (`log_statement=all` — its log is the witness; the
  database `tiffinbox` dropped and created before every harness JVM); Redis `c8u25-redis` on `20642` (`redis-cli MONITOR` around each
  JVM; `FLUSHALL` before each); MongoDB `c8u25-mongo` on `20643`, a standalone, a fresh container before each JVM, `GLIBC_TUNABLES`,
  `--unixSocketPrefix /data/db` (the profiler at level `2`, read per call by the harness); Elasticsearch `c8u25-es` on `20644`, by
  the digest, the six settings, `9300` not published (the client's TRACE logger `co.elastic.clients.transport.rest5_client.low_level.Request`;
  the index `dishes` deleted before each JVM, TiffinBox's start builds it again). TiffinBox under "dev" on `20640`, every address by
  property, Compose off (`spring.docker.compose.enabled=false`), one Elasticsearch URI.
- **The seven:** after/'s jar, the default run, H2 in memory, no Docker, `20640`.
- **The tests' copy, labelled:** the tests ran on a copy with the three older tests' containers bound to 127.0.0.1 — U27 ships that
  change. `.harness/tests` = after/ + `harness/it-bindings.patch` (the diff printed and hashed in `verify`); Testcontainers' own
  containers on `127.0.0.1:<random>`, `MongoDatastoreIT` on its pinned `20578`, `ElasticsearchIT` on its pinned `20615`.
- **The exercise:** its own four containers on `20641`-`20644` (by the tags), its TiffinBox under "dev" on `20645`, run before the
  unit's stores open.

## Refused, named

- `deleteByCustomer`'s `AopInvocationException` (a `long` return on an empty Redis result) is a return-type mismatch, not a hole:
  unused, not run here.
- The probe's JDBC `Window` attempt (a signature with no `ScrollPosition` parameter) — inconclusive in the probe, not run here, and
  this unit says nothing of it.
- `Spring Data runs the query`, and Commons as the sender of a request: the parser is Commons', the request is each module's — the
  prose gate's XFAM_S5 refuses both.
- `works the same on every store` and its kin (`one API for every database`, `store-agnostic`, `swap the database`) — XFAM_S5.
- A lesson of the next course by number — XFAM_S5's forward-reference family.
- The two `@Query` sums as parsed names: `PartTree` refuses `monthRevenue` and `pausedDays` with `PropertyReferenceException` (package
  `org.springframework.data.core`) — they carry their own SQL, and this unit never shows them as Commons'.
- A harness `@Enable...Repositories` as a mode of the harness: it is the plant (below), never shipped — the receipt refuses one
  anywhere in `harness/src` or `exercise/`.

## The repository, and the network

This unit changes no file of the anchor: `../c8-tiffinbox` equals `../c8-unit24/after` at the start and at the end of every run
(`diff -rq` empty, asserted). The seed is `../../spring-data-beyond-jpa/_research/m2-seed-c8-s4b/` (`7,265` files); no artifact was
added. `.m2-demo` is a copy of that seed, and both builds (the package and `verify`) are offline (`-o`, `maven.repo.local`
absolute, `Downloaded from` counted `0`, `.m2-demo`'s file count unchanged). No pull: the four images by their digests and the
four tags the exercise names, present before the run; the images list and the volume count the same at the end. No network but the
loopback, and the push of this unit's commit.

## The folders, the harness and the ports

- `harness/src/probe/u25/H25.java` — the harness: modes `facts` (the hierarchy, the parser, the five requests; then `K25`), `hole`
  and `saveall` by `--h25.mode`, the harness's repository interfaces (`RValue`, `RValueGt`, `RTypo`, … on Spring Data Redis;
  `MValue`, `MValueGt`, `MTypo`, … on Spring Data MongoDB), the markers; its runner bean is `h25Runner` (a configuration class and
  its `@Bean` method with one name clash at the start). `harness/src/probe/u25/K25.java` — the shared types.
- `harness/chk25.py` — the checks and the witness windows; `harness/s825.py` — the prose gate (s824's family base byte for byte,
  XFAM_S5 and TIMEPAT_S5 byte for byte from the S5 probe's `fam/xfam5b.py`, TITLES with "Paging and Sorting", unit 25's own
  family); `harness/tree25.py` — the tree pin, unit 10's lines; `harness/it-bindings.patch` — the tests' copy's five edits, BLUE
  C8-S5's `b27v` against 24/after; `harness/dur8.py` (unit 02's) and `harness/logback.xml` (unit 07's), byte for byte.
- `exercise/` — `README.md` (the spoken line), `KitchenOrder.java` (after/'s, byte for byte: the broken copy), `Lab25.java` (the lab:
  `RValue` built by `RedisRepositoryFactory`), `SOLUTION.md`, `check.sh` (the lab's line and `redis-cli SCARD`).
- No jar of this unit is shipped: the harness is compiled by `javac` 25 against after/'s jar and its `lib/*`, the `-cp` printed by
  the receipt.
- Ports, all on `127.0.0.1`: `20640` TiffinBox (dev, the harness joined; the seven's default run) · `20641` PostgreSQL · `20642`
  Redis · `20643` MongoDB · `20644` Elasticsearch · `20645` the exercise's TiffinBox · `20646`-`20648` spare, asserted free ·
  `20649` never bound, asserted free at the start and the end · `20578` and `20615` during `verify` only · `18881`-`18884` free
  throughout (Compose off by property under dev; off in tests by `skip.in-tests`, read off its jar in `jars`).

## Masks, filters and hygiene — every one, declared

- **The non-empty-statements filter:** PostgreSQL's window counts statements with text; Hikari's empty validation statement
  (`statement: ` with no text) is filtered, and the raw count is printed beside every filtered one (`raw`, in each window line).
- **The markers are left out of every window:** the `select 'S5MARK-…'` statements, the `ECHO S5MARK-…` commands and the printed
  marker lines.
- **Redis's ids:** `kitchen-order:<id>` stands for an order's own id (`Ravi-12`, `h25-1`), and a run of the same command is counted
  `(xN)`; `HMSET`'s field list is cut after its key.
- **MongoDB's session id** is never printed: the harness prints the command's name and filter, not the command document.
- **The masks (the receipt's `mask`, its self-test run first):** the folders and the home; Boot's `Started … in`, `Finished Spring
  Data repository scanning in N ms`, the initialization line, Flyway's execution time, Maven's `Total time`, Surefire's `Time
  elapsed`, Testcontainers' `started in PT…S` (TIMEPAT_S5's members), `pid`, and an object's identity hash. The harness prints no
  time; no capture carries the profiler's `millis`, a `took`, a time to live or a cache's settings.
- Every capture is refused if it holds a raw container port, an all-interfaces binding, a time, a `pid` or the shutdown token;
  `dur8` over the captures, this README and the exercise is `0`.

## Interrupted

Five SIGINT points, run after the runs of record and before the plants (unit 22's lesson), each by SIGINT to the receipt's own
process group in the foreground (every JVM and Maven run with SIGINT at its default, R.410). The scripts are the evidence agent's scratch
(`sigint.sh`; logs `sigint-<point>.out`); each point was reached by a condition the script polled, never by a sleep:

- **mid-build** — Maven building the copy of after/: exit `130`.
- **mid-exercise** — the exercise's four containers up and the lab's JVM running: exit `130`.
- **mid-dev start** — the unit's four stores up, the harness's facts JVM started and not yet printing: exit `130`.
- **mid-`hole`** — MONITOR running, the hole JVM past its first call's marker: exit `130`.
- **mid-`verify`** — a Testcontainers container alive, Maven and its forked test JVM running: exit `130`; afterwards
  the list of containers with the label `org.testcontainers=true` is empty (the trap removes them by the label).

Each time, afterwards: java processes `0`, no `c8u25-*` container and no Testcontainers container, volumes `315`, images `9`,
nothing listening on `20640`-`20649`, `20578`, `20615` or `18881`-`18884`, no `redis-cli MONITOR` left, `.r-lock` gone, no partial
capture, every `.r-*.out` unchanged (md5 before = after).

## Planted faults — each caught (R.65, R.226)

Run after the runs of record and the SIGINT points, never beside a run of record, by `plants.sh` (the evidence agent's scratch) on the
sealed clone's copy of this folder and its run's captures; each plant judged by the gate that must refuse it, each removed after:

- **The numbers check (S8.95):** MongoDB's `30` written in the hole table's Redis cell for `findByValue(240)` — `chk25 readme`'s hole
  table check refuses it; the strict count typed as `11` in the values block — `chk25 readme` refuses it; one store-assignment line
  gone from the `strict` capture (`11`) — `chk25 strict` refuses it.
- **The per-call count:** a MONITOR line doctored into `findByValueGreaterThan`'s own window — `chk25 hole` refuses it (`1` command
  where the call threw).
- **S8.101's negation:** a scratch class with `@EnableMongoRepositories` joined to a dev start on its own four stores — `Found 1
  MongoDB repository interface`, the plant's repository listed and `OrderDocuments` gone; `chk25 hierarchy` refuses the six by name
  (exit `1`; it printed that FAIL line, then stopped on a listing line it could not parse — disclosed: the refusal stands on the FAIL
  line and the exit).
- **The prose gate (`s825.py`):** twelve sentences, one per XFAM_S5 family — `12` families hit; `Spring Data runs the query on
  PostgreSQL.`, `The same repository works the same on every store.` and a forward reference by lesson number — XFAM_S5; two time
  sentences — the inherited time family; a count of modules two too many — XU25. Controls: the prompt's allowed forms pass.
- **verify's check:** a host IP `127.0.0.2` in one IT BINDINGS line; a copy of `RedisDatastoreIT` without its modifier (`grep -c`
  `0`); four classes — `chk25 verify` refuses each.
- **The exercise:** another method's name and another number — `exercise/check.sh` refuses both in every run of record (above);
  a changed What-it-prints line — the receipt's comparison refuses it.
- **The receipt's own gates:** a wrong `before` link (R.250), a wrong tree hash (R.211), a placeholder — each stops `receipts.sh`
  at its gate. The cannot-fail detector (R.276, R.374): a copy of `chk25.py` with `ok(x == x)` and `ok(len(x) >= 0)` — `2` hits; the
  shipped `chk25.py` — `0`.

In all, `22` plants refused and `8` controls passing (`plants.sh`'s last line); the folder restored and compared after.

## What differed from the brief

Each entry dated 2026-11-23, the evidence agent's choice where the plan left one open (Vivek was not present; nothing was asked).

- **The exercise's shape is the probe's:** TiffinBox under "dev" on four stores of the exercise's own, the copy of `KitchenOrder`
  ahead of the jar on the class path, the lab joined by `--spring.main.sources` (ports `20641`-`20644`, TiffinBox on `20645`). A
  leaner shape that still measures TiffinBox's own seeding was not found: under "dev" TiffinBox needs all four stores to start.
- **The two wrong solutions are run once per run of record** (another method's name; another number), so each is refused 3/3 across
  the three runs, not three times inside one.
- **`types` runs inside the facts JVM**, so it is 3/3 inside each run (the brief asked 1/1 per run).
- **`sockets` is folded into `hole`'s tail**, as unit `23` did: the Elasticsearch container's sockets, read at the end of each hole window.
- **The tests' copy ships as a patch:** `harness/it-bindings.patch` (five files, BLUE's `b27v` edits against 24/after, the dates cut from
  its headers) — so a sealed clone builds the same copy; the prompt's harness list did not name it.
- **The seven's expected value** is the md5 of its seven responses, read off `../c7-unit31/receipts.sh` (the value unit 24's seven
  printed for both its trees); unit 24's `receipts.md5` line for `seven` hashes that whole capture, ports and two trees included.
- **`KitchenOrders` is injected in `src/main` by `RedisDatastore` and `TiffinBoxServer`** — the comment-stripped reader finds both
  (the probe's grep named `TiffinBoxServer`); the count of injected repositories, `4`, is the probe's.
- **The harness reads MongoDB's profiler per call** (on before the call, read after), so each MongoDB cell is one call's window, as
  each Redis cell is.
- **The verify's alarm is `900`** for the five ITs with an Elasticsearch start (R.247).
- **The slot map is the brief's**, with no change.
- **The cross-references resolve** (R.211, R.331): `c8-unit22/README.md:113` (the brief's `:111` is the opening fence of that block;
  `:113` is the line that says `12`), `c8-unit23/README.md:30` (the launch rule), `../c8-unit24/receipts.md5`'s after-tree line (read by
  the receipt); four cited, four resolved.
- **No count differed from the probe's** (the hole table, the five requests, `saveall`, the strict lines, the first window, the
  exercise's `30`).

## For RED

- **The hook's label, in its words:** "The harness's two repositories, one method name: MongoDB answers findByValue with thirty
  orders, and Redis answers zero, with no exception." — both repositories are the harness's (`hole`), and the label is in the line.
- **What a script must not say:** Commons as a runtime (the parser is Commons', each request is the module's); the umbrella over every
  store (`one API for every store`); a time (the captures print none, and dur8 counts `0` words here).
- **The counts and their witnesses:** every number in "The values the video may say" names its capture; each has two witnesses where
  a store answers (the harness's Java and the store's own tool — PostgreSQL's log, MONITOR and `redis-cli`, the profiler and `mongosh`,
  the client's trace).
- **The gloss**, first spoken use, byte for byte: the line under this README's title.
- **The call-back:** the keyset names come from Course 7's lesson called Paging and Sorting: Window and ScrollPosition, both in the
  Commons jar.

## The ledger rows this unit pays

- **C8-7 — paid.** "Spring Data" is the modules that share Commons; unit 01 named the three. This unit names what Commons ships, off
  the jars and off the dev start: the interfaces (`Repository`, `CrudRepository`, `ListCrudRepository`, `PagingAndSortingRepository`,
  `ListPagingAndSortingRepository`, `QueryByExampleExecutor`), the method-name parser (`PartTree`, and every module's creator
  extending `AbstractQueryCreator`), and the factory key (`RepositoryFactorySupport` in six jars' `spring.factories`).
- **C8-6 — called back by name:** the paging API's names are Commons' (`Window`, `ScrollPosition`, `KeysetScrollPosition`), the
  shipped keyset method answers the first window, and the JDBC keyset branch stays closed (nothing claimed of it).
- **Roadmap `:359`** — "the `Repository` hierarchy that all of this shares": shown off the jars and the run.

## The values the video may say

Each line is one capture's `VALUES` line, written by `harness/chk25.py` from that capture; the receipt asserts this block equal to
the runs' at the end of every run.

<!-- values: begin -->
```text
exercise: broken findByValue(240) 0, SCARD 0 · solved 30, SCARD 30 · another name refused · another number refused · the spoken line 22 words
jars: CrudRepository 12 methods · JpaRepository adds 11 · the factory key in 6 jars (jpa, jdbc, redis, keyvalue, mongodb, elasticsearch), none in commons and relational · 5 query creators extend AbstractQueryCreator · 10 domain types
hierarchy: repositories 6 · factory beans 5 · one fragment each · chains ending at Commons' Repository 6 · injected in src/main 4 (OrderDocuments, CustomerAggregates: their tests only) · KitchenOrders' base SimpleKeyValueRepository
parse: the name line x4, the mealType line x6, @Query sums refused 4 · JPA 1 statement · JDBC 2 · Redis 61 and 31 commands · MongoDB 1 find (120 examined, 60 returned) · Elasticsearch 2 requests · empty statements filtered 1
strict: strict-mode lines x6 · Could not safely identify 12 (JPA 4, Elasticsearch 2, Reactive Elasticsearch 2, MongoDB 2, Redis 2) · Found JPA 2, JDBC 1, Redis 1, MongoDB 1, Elasticsearch 1, Reactive Elasticsearch 0
types: Window and ScrollPosition from spring-data-commons-4.1.2.jar · the first window [Meera, Priya, Ravi, Sunil], hasNext false, 1 statement
hole: Redis findByValue(240) 0, no exception, 1 command · findByValueGreaterThan(200) throws, 0 commands · findByMealTypo throws at the first call, 0 commands · MongoDB 30 · 60 · refused at the build · redis-cli SCARD kitchen-order:value:240 0 · mongosh 30 and 60 · Not/In/StartingWith throw with 0 commands · IgnoreCase 0 with 1 · OrderByValueDesc 61 · count 1 · exists 1 · First3 4 · Or 61 (SUNION)
saveall: saveAll of three: JPA 5 statements, JDBC 5 (BEGIN, 3 INSERT, COMMIT) · Redis 21 commands · MongoDB 3 updates (upserts) beside insertAll's 1 insert (ninserted 3) · Elasticsearch 2 requests
seven: the seven: 7 lines, md5 = the course's
verify: tests 18 + 13, 0 failures · IT BINDINGS 5 classes, every host IP 127.0.0.1 · containers created 5 · pulled 0
```
<!-- values: end -->

# Which database, honestly — the decision table

Five stores this course ran, five ways a store failed. Every body cell names the capture that showed the failure and the number that
capture printed, in its own words; a cell with no capture says `unmeasured`. `harness/u23check.py` reads every cell.

| store | a silent wrong answer | the store absent at start | a write outside the transaction | a default that does nothing | a cost that grows |
|---|---|---|---|---|---|
| PostgreSQL | unmeasured | unmeasured | unmeasured | unmeasured | `unit01/statements`: Spring Data JDBC's page, the witness 43, of them SELECTs from pause by customer_id 40, beside JPA's page, the witness 4; `unit18/oneread`: statements 1, JOIN in it 3, rows 4; `unit18/rename`: the three tables, UPDATE 30, beside MongoDB's nModified 30 |
| Caffeine | `unit12/stale`: the cached read says 2, the row now 3 | unmeasured | unmeasured | `unit10/nonames`: hitCount=4, missCount=1, cache_ lines 0 | `unit12/stampede`: 2 threads, 2 in every round |
| Redis | `unit16/dropped`: PUBLISH -> 0, the subscriber heard 0 | `unit14/absent`: the JVM's exit: 1, curl /actuator/health: 000 | `unit17/otherholder`: holder A releases by DEL: deleted true, then EXISTS -> 0 | `unit15/stale`: keyspace events off, count() 3, findAll() 3 elements, 2 null | unmeasured |
| MongoDB | `unit19/silent`: sum("mealType"), groups 4, every total 0, their sum 0 | `unit18/absent`: the JVM's exit: 1, health 000, MongoTimeoutException 1 | `unit20/notone`: JpaTransactionManager, tx_docs count 1, ids [a] | `unit20/noindex`: getIndexes ["_id_"], COLLSCAN, totalDocsExamined 120 | `unit20/shapes`: findAll(OrderRef.class) 120 orders, tiffinbox.customers query 120 |
| Elasticsearch | powerful full-text search | `unit22/absent`: the JVM's exit 1, Connection refused | `unit22/drift`: intx, rows 0 / index 1 | `unit22/stale`: the template's save, the count that follows it -> 0 | `unit21/sayso`: edge_ngram, _analyze "Vegetarian" -> 9 tokens |

The cells that say `unmeasured` (one line each):

- PostgreSQL, a silent wrong answer: no capture of this course prints it.
- PostgreSQL, the store absent at start: no capture of this course prints it.
- PostgreSQL, a write outside the transaction: no capture of this course prints it.
- PostgreSQL, a default that does nothing: no capture of this course prints it.
- Caffeine, the store absent at start: no capture of this course prints it.
- Caffeine, a write outside the transaction: no capture of this course prints it.
- Redis, a cost that grows: no capture of this course prints it.

No row ranks a store, and no cell says which store to pick for what. The one vector sentence: a vector index is a kind of index this course does not build.

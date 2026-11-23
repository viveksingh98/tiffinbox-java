# c8-unit22 — *Spring Data Elasticsearch*

Course 8, Section 4's fifth unit, and **Section 4 Part B's second change to the anchor — the write path to the dish index, under the
profile "dev"**. `before` is a link to `../c8-unit21/after` (the previous unit's tree; the receipt pins it and asserts that pin is that
unit's own after-tree line); `after/` is this unit's tree, and `../c8-tiffinbox` equals `after/` from this unit's commit on. Unit 21
gave the anchor a table of dishes (PostgreSQL's rows under "dev", the source) and an index of them (Elasticsearch's, the copy the start
rebuilds). This unit gives a new dish a way in: `POST /dishes` saves it as a row in a transaction of JPA's manager, and a listener,
`DishIndexSync`, copies that row into the index once the transaction has committed — through the repository's own `save`. The search
`GET /dishes/search` asks the index through `Dishes.searchByName` since, with `@Highlight`, and each document it returns carries the
fragment of its name Elasticsearch marked. The default run keeps none of it: no route, no bean, no Elasticsearch line.

**An inverted index** is a list from each token to the documents that hold it: Elasticsearch answers a search by looking the search's
tokens up in that list, and a document is in the list only once the index has refreshed after the write.

Every Elasticsearch number below comes from two witnesses in the same run (S8.78): **Java's answer** — TiffinBox's routes under "dev",
the start's own log line, the requests the client sent (its own trace logger, `co.elastic.clients.transport.rest5_client.low_level.Request`
at TRACE), the IT's lines, the harness's `PROBE` lines, the exercise's program — and **the store's own answer**: Elasticsearch's REST API
by `curl` on the loopback port from this Mac (`_search`, `_count`, `_mapping`, `_settings`, `_cat/indices`, `_doc`), and every row count
by PostgreSQL's own `psql` (a count of the table's rows). curl never runs inside a container (§BUILDERS 9); the receipt's `exec` calls
read a file each by `cat` (`/proc/sys/vm/max_map_count`, `/proc/net/*`) or run PostgreSQL's and Redis's own clients, never a shell.
Elasticsearch is **9.4.8, by the digest** (`docker.elastic.co/elasticsearch/elasticsearch@sha256:fb7f2d0d…c5d5c403`, `--pull never`,
`127.0.0.1` only), every container with the six settings `compose.yaml` explains; PostgreSQL, Redis and MongoDB by the course's digests.
Every line names its tree, its profile, its store and its index (R.392): **22/after, profile dev, the unit's four stores** (`anchor`,
`mapping`, `sync`, `absent`; the index `dishes` on `20614`); **the harness** (`probe.u22.H22` on 22/after's jar: `requests` and
`highlight` on the index `dishes`, `nrt`'s Spring half and `stale` on its own scratch index `dishes_nrt_j`, and `drift` — **the harness
plants a failure** — on the harness's own PostgreSQL, `20616`, and its own index `dishes_drift`); **curl alone** on a scratch index
`dishes_nrt` (`nrt`'s REST half); **22/after, default run, H2, no Docker** (`default`, the seven).

Fourteen captures. The JVM and store captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`);
`exercise` and the tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string
below is asserted after its capture by `harness/chk22.py` against another witness of the same run; every count it prints beside an
ids list is re-derived from that list, and every "rows / documents" pair from `psql`'s and `_count`'s answers of the same run (S8.95).

## Runs of record

Three runs of `receipts.sh` on 2026-11-23, each ending `c8-unit22: every capture = published …`, each log through
`check_unit8.py 22 --runlog` (`RESULT (run logs): PASS`; the unit gate itself exits `2` until the script stage writes unit 22's
script — expected). Every capture's md5 equals `receipts.md5`'s in all three; every build offline (`offline: yes`, `Downloaded from`
`0`). The machine's three load averages at each run's start and end — another session's `ffmpeg` was alive
(idle) throughout; the runs waited for none above `5` % CPU:

| run | how | result | load at start | load at end |
|---|---|---|---|---|
| run1-bash32 | `./receipts.sh` — macOS's bash 3.2.57 | PASS | `7.75 11.13 10.79` | `4.79 6.06 8.53` |
| run2-bash53 | `bash receipts.sh` — Homebrew's bash 5.3.9 | PASS | `4.79 6.06 8.53` | `4.67 5.04 6.53` |
| run3-sealed | a sealed fresh clone in a path with a space (`sealed 22/`), `./receipts.sh`, `DOCKER_CONFIG=$HOME/.docker` | PASS | `5.13 5.12 6.54` | `6.44 6.45 6.61` |

A first bash 3.2 run, before these three, printed one `grep: exercise: Is a directory` line (a gate's grep without `-r`):
`check_unit8.py --runlog` refused that log (R.166), the grep was fixed (`$G -rqE`), and the three above ran on the fixed receipt.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250, S8.93)

Twelve files of `after/` differ from `before/` — four new, eight changed, none deleted (the receipt prints the list at its start):

- **`tiffinbox-web/.../Dishes.java`** — `@Highlight(fields = @HighlightField(name = "name")) SearchHits<Dish> searchByName(String name)`
  beside `findByName`: the same derived `query_string` (`default_operator and`, `fields [name]`), with a highlight request for `name`
  (the request lines are `highlight`'s capture). Its Javadoc gains a *Course 8, unit 22* paragraph: the fragment, and the repository's
  save as the listener's write (`refresh=false`, then `_refresh`).
- **`DishSearch.java`** — the route reads `searchByName` since; each hit is `Hit(id, name, fragment)`, `fragment` the fragments
  Elasticsearch marked in `name`. Still `@Profile("dev")`: `404` on the default run.
- **`DishWrite.java`** (new) — `POST /dishes`, JSON in (`name`, `mealType`, `price`), `201` and the saved dish; `@Profile("dev")`.
- **`DishService.java`** (new, web) — `@Service @Profile("dev")`, `@Transactional` on JPA's manager: saves a `DishEntity` through
  `DishEntityRepository`, publishes `DishSaved`. No index write inside it.
- **`DishSaved.java`** (new) — `record DishSaved(long id, String name, String mealType, int price)`.
- **`DishIndexSync.java`** (new) — `@Component @Profile("dev")`, `@TransactionalEventListener(phase = AFTER_COMMIT)` on `DishSaved`:
  `Dishes.save(new Dish(…))`. Its Javadoc: the row is the source, the listener copies it after the commit, a failure in it reaches no
  caller (`drift`, where the harness plants that failure).
- **`TiffinBoxServer.java`** — a *Course 8, unit 22* Javadoc paragraph after unit 21's: the start's delete-then-save stays; between
  starts, the listener copies each committed row. No line of code moves (`chk22.py static` compares the class without its Javadoc).
- **`tiffinbox-core/.../DishEntity.java`** — a public constructor `(name, mealType, price)` for a new row; a dated note in its Javadoc.
- **`DishEntityRepository.java`** — a dated note: "nothing writes a dish row but `V4__dish.sql`" is no longer the whole story.
- **`ElasticsearchIT.java`** — another test, `searchByName("veg")` on the three dishes the first test saves: one document, its
  fragment; the binding `127.0.0.1:20606` → **`127.0.0.1:20615`** (this unit's slot map; noted in its Javadoc); its test count noted.
- **`MongoDatastoreIT.java`** — its Javadoc's test-count note gains a *Course 8, unit 22* line, `18 + 13`.
- **`README.md`** (the anchor's) — a `## Course 8 · unit 22` section after unit 21's; the dated notes below.

**The R.250 hunt** — `grep -rn` in `c8-tiffinbox/` for `18 + 12`, `rebuilds`, `start alone`, `re-index`, `only the start` and `copy`,
each hit decided:
- `18 + 12` (`5` lines): the anchor README's sections of the three units before this one — each gains a *Course 8, unit 22* note
  (`18 + 13`) beside unit 21's; `ElasticsearchIT`'s and `MongoDatastoreIT`'s Javadoc — noted. None left without its note (`chk22.py r250`).
- `rebuilds` (`17` lines): the Redis and MongoDB sentences (units 14-19) — about other copies, unchanged; unit 21's README section
  "a copy … which the "dev" start rebuilds" — noted (the listener adds each committed row); `DishEntity`'s Javadoc — noted;
  `TiffinBoxServer`'s "the index is a copy the start rebuilds" — a unit 22 paragraph follows it; `compose.yaml`'s two sentences
  (the Elasticsearch service's header and its no-volume line) — **kept**: still true (a new container loses the listener's copies too,
  and the next start rebuilds them from the rows), and compose.yaml stays byte for byte unit 21's; `V4__dish.sql`'s — **kept**, a
  migration's bytes are Flyway's checksum (below, "What differed").
- `start alone`, `only the start`: no hit.
- `re-index` (`4` lines): this unit's own new sentences and the start's log line — true.
- `copy` (`85` lines): read for the index's copy; every sentence about `dishes` either says what the start does (true) or carries a unit
  22 note.
- Unit 21's Part B opening sentence, "unit 22 adds the write path next", is kept and noted *(Course 8, unit 22: it has — its section
  below.)*.

**R.211/R.331 — the builders and the shipped receipts that name a changed path.** `grep` over `spring-data-beyond-jpa/_builders/s8*.py`
and every shipped `c8-unit*/receipts.sh` and `c8-unit*/harness/*.py` for `Dishes.java`, `DishSearch.java`, `TiffinBoxServer.java`,
`ElasticsearchIT.java`, `MongoDatastoreIT.java`, `DishEntity.java`, `DishEntityRepository.java` and the new files' names: the matches are on
frozen trees pinned to their own commits (unit 21's `chk21.py` reads `Dishes.java`, `DishSearch.java`, `ElasticsearchIT.java` and
`TiffinBoxServer.java` on 21/after; earlier units read `TiffinBoxServer.java` and `MongoDatastoreIT.java` on their own `after/`), so
nothing moves; the count is in the commit message.

## RE-MEASURE 7 + flag 9 — the shipped sync, on 22/after under dev (settled first)

The start on a fresh database applies Flyway's migrations and re-indexes the rows; Spring Data's strict mode prints its lines, the same
count unit 21's run printed — `DishService` and `DishIndexSync` are no repositories, so no scan counts them; then `POST /dishes` saves a
row, and the listener's two requests follow it: the repository's save (`refresh=false`), then its `_refresh`. PostgreSQL's `count(*)`
and the index's `_count`, read in the same run, agree after the POST, and a second start on the same database deletes and re-saves the
copies of all of the rows (`anchor`):

```text
(x1) Successfully applied 4 migrations
of them "Could not safely identify": 12 · naming Dishes: 3 - by module: Spring Data JPA, Spring Data MongoDB, Spring Data Redis · "Multiple Spring Data modules found": 6
(x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes
(x1) Spring Data MongoDB - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes
(x1) Spring Data Redis - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes
(x1) tiffinbox: dishes re-indexed: rows 10 · documents before 0 · documents after 10
the rows (psql, the unit's PostgreSQL): select count(*) from dish -> 10 · the index (curl on 20614): _cat/indices dishes -> dishes green open 1 0 10
POST /dishes {"name":"Mushroom Noodle Bowl","mealType":"VEG","price":110} (TiffinBox) -> 201 {"id":11,"name":"Mushroom Noodle Bowl","mealType":"VEG","price":110}
the listener's requests, by the client's trace logger (after the POST, before any other request): PUT '<es>/dishes/_doc/11?refresh=false' · POST '<es>/dishes/_refresh'
then the rows (psql): select count(*) from dish -> 11 · select id from dish where name = the new dish -> 11 · the index (curl): _count -> 11 · _doc/11's _source -> {"_class": "com.tiffinbox.web.Dish", "id": "11", "mealType": "VEG", "name": "Mushroom Noodle Bowl", "price": 110}
GET /dishes/search?q=mushroom (TiffinBox) -> 200 [{"id":"11","name":"Mushroom Noodle Bowl","fragment":["<em>Mushroom</em> Noodle Bowl"]}] · curl: match name mushroom -> 1 [11]
curl: _count dishes before it -> 11
the start's re-index line: dishes re-indexed: rows 11 · documents before 11 · documents after 11
the rows (psql): 11 · the index (curl): _count -> 11 · match name mushroom -> 1 [11]
```

## RE-MEASURE 5 + flag 15 — the test count and the slice (settled first)

`mvn -o verify -pl tiffinbox-web -am` runs **`18 + 13`** (Maven's Results lines, beside Surefire's reports): the new test is
`ElasticsearchIT`'s new one, on the slice, which holds no JPA and no transaction manager — so the listener is `anchor`'s and `sync`'s
witness, never a test's. The IT's container is published on `127.0.0.1:20615` alone (its `9300` exposed by the image, never
published), and gone after; the Mongo IT's on `127.0.0.1:20578`. `mvn -o package` with Docker at nothing runs the `18`. The jar's
libraries: after/'s count equals before/'s — the change adds no dependency (`anchor`):

```text
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 13, Failures: 0, Errors: 0, Skipped: 0
the Elasticsearch IT's container while verify ran, Docker's own list (dk ps, polled on a count): Ports 9300/tcp, 127.0.0.1:20615->9200/tcp · listening on 20615 after it: 0
the Mongo IT's container while verify ran: Ports 127.0.0.1:20578->27017/tcp · listening on 20578 after it: 0
ES IT Dishes.searchByName("veg") of three saved: ids [1] · the fragment of the first [<em>Vegetarian</em> Lunch Box]
ES IT heap_max_in_bytes (the client's nodes info, jvm): 536870912
before/: 146 libraries
after/: 146 libraries
gained: 0 · lost: 0
the version lines off the jar names: elasticsearch-java-9.4.8.jar elasticsearch-rest5-client-9.4.8.jar spring-boot-4.1.2.jar spring-data-elasticsearch-6.1.2.jar spring-tx-7.0.10.jar
```

## The captures — what each one shows

### 1 · anchor — the tests, the dev shape on four stores, the write path, a second start, and the Compose window

Under "dev" on the unit's four stores the route answers `veg` with the vegetarian box and its fragment, by TiffinBox and by
`curl`'s own `_search` with a highlight block; `POST /dishes` answers `201` with the id PostgreSQL assigned; the rows and the
documents agree after it; the new dish is found by its own word by both witnesses; Part A's and unit 21's routes still answer. The
beans: the five under "dev", and one transaction manager. The Compose window does the same on Compose's stores, its PostgreSQL read by
its own `psql`:

```text
S8.84: the key spring.elasticsearch.uris on that command line: 1 - the one URI http://127.0.0.1:20614
the hosts those requests went to: 127.0.0.1:20614
the wait lines ("Waiting"/"retry" naming Elasticsearch): 0
GET /dishes/search?q=veg (TiffinBox) -> 200 [{"id":"1","name":"Vegetarian Lunch Box","fragment":["<em>Vegetarian</em> Lunch Box"]}]
curl: POST /dishes/_search match name veg, highlight name -> 1 [1] · 1 VEG highlight.name ["<em>Vegetarian</em> Lunch Box"]
GET /revenue/by-customer -> 200 [{"customer":"Sunil","total":9000},{"customer":"Ravi","total":7200},{"customer":"Meera","total":4500},{"customer":"Priya","total":3600}]
GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300}
GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
/actuator/beans (this run's override): the beans by name (1 present, 0 absent): dishes 1 · dishSearch 1 · dishWrite 1 · dishService 1 · dishIndexSync 1 · elasticsearchClient 1 · the PlatformTransactionManager beans: ['transactionManager JpaTransactionManager']
the hosts the client's requests went to (its trace logger): 127.0.0.1:18884 · the Compose service's own published port (dk port): 9200/tcp -> 127.0.0.1:18884
curl on 18884 (the elasticsearch service): _cat/indices dishes -> dishes green open 1 0 10 · match name veg -> 1 [1]
the rows (psql, Compose's PostgreSQL, the postgres service's own client): select count(*) from dish -> 11 · the index (curl on 18884): _count -> 11 · the listener's requests: PUT '<es>/dishes/_doc/11?refresh=false' · POST '<es>/dishes/_refresh'
the receipt removes the mongo service's two by the names its container listed (dk volume rm): volumes 318 = before the window · listening on 18881-18884: 0
Testcontainers' own ElasticsearchContainer, read off its jar (unzip -p): the memory file elasticsearch-default-memory-vm.options -> -Xms2147483648 -Xmx2147483648 -Dingest.geoip.downloader.enabled.default=false · the class file's strings, each present or not: ELASTIC_PASSWORD present · changeme present · xpack.security.enabled present · cluster.routing.allocation.disk.threshold_enabled present · discovery.type present
ES IT the container's environment, as run (PATH and HOSTNAME left out): [ELASTIC_CONTAINER=true, ELASTIC_PASSWORD=changeme, ES_JAVA_OPTS=-Xms512m -Xmx512m, SHELL=/bin/bash, cluster.routing.allocation.disk.threshold_enabled=false, container=oci, discovery.type=single-node, ingest.geoip.downloader.enabled=false, xpack.inference.elastic.authorization.enabled=false, xpack.ml.enabled=false, xpack.security.enabled=false]
```

### 2 · mapping — what the annotations asked for and what the mapper added (S8.78)

`Dish.java`'s annotations, by line, beside `_mapping`: `name` text by `dish`, `mealType` keyword, `price` integer — and two fields the
annotations never named: `_class`, the type hint (keyword, not indexed, no doc values), and `id`, the record's id written into the body
and mapped dynamically (text with a keyword sub-field). `_doc/1`'s stored `_source` shows both. The Java witness is the index creation
the client sent at the start, `anchor`'s line:

```text
line 23: @Document(indexName = "dishes")
line 24: @Setting(settingPath = "dish-settings.json")
line 25: public record Dish(@Id String id,
line 26:                    @Field(type = FieldType.Text, analyzer = "dish") String name,
line 27:                    @Field(type = FieldType.Keyword) String mealType,
line 28:                    @Field(type = FieldType.Integer) int price) {
curl: GET /dishes/_mapping -> _class {"doc_values": false, "index": false, "type": "keyword"} · id {"fields": {"keyword": {"ignore_above": 256, "type": "keyword"}}, "type": "text"} · mealType {"type": "keyword"} · name {"analyzer": "dish", "type": "text"} · price {"type": "integer"}
curl: GET /dishes/_settings (flat; its analysis and replicas) -> index.analysis.analyzer.dish.filter ["lowercase", "veg_syn"] · index.analysis.analyzer.dish.tokenizer "standard" · index.analysis.analyzer.dish.type "custom" · index.analysis.filter.veg_syn.synonyms ["veg, vegetarian"] · index.analysis.filter.veg_syn.type "synonym" · index.number_of_replicas "0" · index.number_of_shards "1"
curl: GET /dishes/_doc/1 -> _source {"_class": "com.tiffinbox.web.Dish", "id": "1", "mealType": "VEG", "name": "Vegetarian Lunch Box", "price": 110}
```

### 3 · requests — the three ways to ask, by the request each one sends (flag 8)

The derived finder sends a count request (`"size":0`, `track_total_hits`) and then a page of one; `CriteriaQuery` sends the same
`query_string` with `"size":10000`; `NativeQuery` sends a `match` with `"size":10` — its own page, and the reason a query that finds
more than ten returns ten (ten rows hide that here; the request shows it). All three find the vegetarian box alone; `curl`, sending
each body to `_search`, finds the same ids. A `prefix` finds four, and one of them is the vegan box:

```text
request: POST '<es>/dishes/_search' -d '{"_source":false,"from":0,"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":0,"track_scores":false,"track_total_hits":2147483647,"version":true}'
request: POST '<es>/dishes/_search' -d '{"from":0,"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":1,"track_scores":false,"version":true}'
request: POST '<es>/dishes/_search' -d '{"from":0,"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":10000,"track_scores":false,"version":true}'
request: POST '<es>/dishes/_search' -d '{"from":0,"query":{"match":{"name":{"query":"veg"}}},"size":10,"sort":[],"track_scores":false,"version":true}'
request: POST '<es>/dishes/_search' -d '{"from":0,"query":{"prefix":{"name":{"value":"veg"}}},"size":10,"sort":[],"track_scores":false,"version":true}'
PROBE 1 derived: Dishes.findByName("veg") -> [1 Vegetarian Lunch Box]
PROBE 2 CriteriaQuery Criteria.where("name").is("veg") -> 1 [1] [Vegetarian Lunch Box]
PROBE 3 NativeQuery match name veg -> 1 [1] [Vegetarian Lunch Box]
PROBE 4 NativeQuery prefix name veg -> 4 [1, 10, 2, 8] [1 VEG Vegetarian Lunch Box, 10 VEG Mixed Vegetable Rice, 2 VEG Vegetable Curry with Rice, 8 VEGAN Vegan Lunch Box]
curl: POST /dishes/_search {"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":1} -> 1 [1]
curl: POST /dishes/_search {"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":10000} -> 1 [1]
curl: POST /dishes/_search {"query":{"match":{"name":{"query":"veg"}}},"size":10} -> 1 [1]
curl: POST /dishes/_search {"query":{"prefix":{"name":{"value":"veg"}}},"size":10} -> 4 [1, 10, 2, 8]
```

### 4 · highlight — the fragment the index marked (the unit's beat)

`veg` is not a word of "Vegetarian Lunch Box"; the analyzer's synonym put the token there, and the fragment shows which word of the
name carried it. `lunch` marks the word itself, in two dishes:

```text
PROBE Dishes.searchByName("veg") -> 1 [1] · 1 VEG {name=[<em>Vegetarian</em> Lunch Box]}
PROBE Dishes.searchByName("vegetarian") -> 1 [1] · 1 VEG {name=[<em>Vegetarian</em> Lunch Box]}
PROBE Dishes.searchByName("lunch") -> 2 [1, 8] · 1 VEG {name=[Vegetarian <em>Lunch</em> Box]} · 8 VEGAN {name=[Vegan <em>Lunch</em> Box]}
curl: match name veg, highlight name -> 1 [1] · 1 VEG highlight.name ["<em>Vegetarian</em> Lunch Box"]
curl: match name vegetarian, highlight name -> 1 [1] · 1 VEG highlight.name ["<em>Vegetarian</em> Lunch Box"]
curl: match name lunch, highlight name -> 2 [1, 8] · 1 VEG highlight.name ["Vegetarian <em>Lunch</em> Box"] · 8 VEGAN highlight.name ["Vegan <em>Lunch</em> Box"]
```

### 5 · nrt — the count that follows a write, by REST and by each Spring save (S8.81)

By `curl` alone, on a fresh scratch index each time: a document written with no refresh, then a count — `0`; with `refresh=wait_for` —
`1`; with `refresh=true` — `1`. By the harness, on its own scratch index: the repository's `save` sends `refresh=false` and then
`_refresh`, and the count reads `1`; the template's `save` sends `refresh=false` and nothing after it (its refresh policy `null`), and
the count reads `0`; the template `withRefreshPolicy(IMMEDIATE)` sends `refresh=true`, and the count reads `1`:

```text
PUT /dishes_nrt/_doc/1 -> result created · forced_refresh false · then _count -> 0 · _search match_all -> 0 []
PUT /dishes_nrt/_doc/1?refresh=wait_for -> result created · forced_refresh false · then _count -> 1 · _search match_all -> 1 [1]
PUT /dishes_nrt/_doc/1?refresh=true -> result created · forced_refresh true · then _count -> 1 · _search match_all -> 1 [1]
PROBE the template's refresh policy (getRefreshPolicy) -> null
PROBE -- a: the repository's save (SimpleElasticsearchRepository), a fresh dishes_nrt_j
PROBE -- b: ElasticsearchOperations.save, a fresh dishes_nrt_j
PROBE -- c: withRefreshPolicy(IMMEDIATE).save, a fresh dishes_nrt_j
request: PUT '<es>/dishes_nrt_j/_doc/1?refresh=false' -d '{"_class":"probe.u22.H22$NrtDish","id":"1","name":"Vegetarian Lunch Box","mealType":"VEG","price":110}'
request: PUT '<es>/dishes_nrt_j/_doc/1?refresh=true' -d '{"_class":"probe.u22.H22$NrtDish","id":"1","name":"Vegetarian Lunch Box","mealType":"VEG","price":110}'
request: POST '<es>/dishes_nrt_j/_refresh'
PROBE a: the count that follows it -> 1
PROBE b: the count that follows it -> 0
PROBE c: the count that follows it -> 1
```

### 6 · stale — the search that misses the document just saved (the second failure receipt)

The template's save, then a count: `0` — beside its control in the same run, the repository's save, then a count: `1`. The document
the first count misses is in the index; the count that follows the template's save reads none of it:

```text
PROBE the template's save, the count that follows it -> 0
PROBE the repository's save, the count that follows it -> 1
```

### 7 · sync — the anchor's shape: a copy, with its drift beside it

A fresh database: rows `10` beside documents `10`; a `POST`: `11` beside `11`; another `POST`: `12` beside `12`; the first name again —
the table's unique key refuses it, the row rolls back, the listener never runs, and the counts stay `12` beside `12`; a second start on
the same database deletes and re-saves the copies, and both stores hold the same ids. The copy holds what the table committed — and
`drift` (below) shows the harness's failure that leaves it a row behind:

```text
after the start: dishes re-indexed: rows 10 · documents before 0 · documents after 10 · rows 10 · documents 10
POST /dishes Mushroom Noodle Bowl -> 201 {"id":11,"name":"Mushroom Noodle Bowl","mealType":"VEG","price":110} · the listener's requests: PUT '<es>/dishes/_doc/11?refresh=false' · POST '<es>/dishes/_refresh' · rows 11 · documents 11
POST /dishes Tomato Basil Soup -> 201 {"id":12,"name":"Tomato Basil Soup","mealType":"VEGAN","price":130} · the listener's requests: PUT '<es>/dishes/_doc/12?refresh=false' · POST '<es>/dishes/_refresh' · rows 12 · documents 12
POST /dishes Mushroom Noodle Bowl again (the name is the table's unique key) -> 500 · rows 12 · documents 12
the second start on u22sync: dishes re-indexed: rows 12 · documents before 12 · documents after 12 · rows 12 · documents 12 · ids (psql) 1,2,3,4,5,6,7,8,9,10,11,12 · ids (curl, match_all) 12 [1, 10, 11, 12, 2, 3, 4, 5, 6, 7, 8, 9]
```

### 8 · drift — the harness plants a failure (the failure receipt, flag 9)

**The harness plants a failure**, three modes, each on a fresh database of the harness's PostgreSQL and its own index `dishes_drift`;
the one transaction manager in its context is JPA's. `intx` writes the row and the document inside one `@Transactional` method, then
throws the planted exception: the table rolls the row back, and the index keeps the document — `rows 0 / index 1`. `listener` saves the
row and hands the index write to an `AFTER_COMMIT` listener, which throws the planted exception before its write: Spring logs the
`afterCompletion` line, and the caller saw no exception — `rows 1 / index 0`. `control`, no plant: `rows 1 / index 1`. Two stores, two
writes, and no manager spans both: this dual write is named here and handed to unit 24, which measures the two managers:

```text
-- mode intx (a fresh database h22intx on c8u22-pg-h):
-- mode listener (a fresh database h22listener on c8u22-pg-h):
-- mode control (a fresh database h22control on c8u22-pg-h):
PROBE the context's transaction managers, by name -> class: [transactionManager] -> [JpaTransactionManager]
PROBE intx: the row saved inside the transaction, its id 11
PROBE intx: the document saved inside the same transaction, then a _refresh of dishes_drift
PROBE the listener (AFTER_COMMIT) throws: java.lang.IllegalStateException: PLANTED in the AFTER_COMMIT listener, before the index write (the harness plants a failure)
PROBE the listener (AFTER_COMMIT): the document saved, then a _refresh of dishes_drift
ERROR org.springframework.transaction.support.TransactionSynchronizationUtils: TransactionSynchronization.afterCompletion threw exception
PROBE the caller: the exception java.lang.IllegalStateException: PLANTED after both writes (the harness plants a failure)
PROBE the caller: the call returned, no exception
rows, PostgreSQL's own answer (psql on c8u22-pg-h, h22intx): the new dish (Garden Pea Soup) 0 · all rows 10 · the index, curl's _count on dishes_drift -> 1
rows, PostgreSQL's own answer (psql on c8u22-pg-h, h22listener): the new dish (Garden Pea Soup) 1 · all rows 11 · the index, curl's _count on dishes_drift -> 0
rows, PostgreSQL's own answer (psql on c8u22-pg-h, h22control): the new dish (Garden Pea Soup) 1 · all rows 11 · the index, curl's _count on dishes_drift -> 1
```

### 9 · default — no profile, no Docker: the default run as before (S8.83)

```text
GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
GET /dishes/search?q=veg -> 404 · GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 {"monthRevenue":24300} · GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300}
POST /dishes {"name":"Mushroom Noodle Bowl",...} -> 404
/actuator/beans: the beans by name (1 present, 0 absent): dishes 0 · dishSearch 0 · dishWrite 0 · dishService 0 · dishIndexSync 0 · elasticsearchClient 0 · a bean whose type names Elasticsearch 0
its log: lines naming 9200 0 · naming elasticsearch, any case 0 · naming 27017 0 · naming mongo, any case 0 · Flyway: Successfully applied 4 migrations
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

### 10 · absent — under dev with Elasticsearch absent: the start stops (S8.84, the third failure receipt)

The one URI the JVM was given, and the client's exception as printed (the port masked in the voice: "the client's exception"):

```text
S8.84: the key spring.elasticsearch.uris on that command line: 1 - the one URI http://127.0.0.1:20619
readiness never answered 200 · the JVM's exit 1 · listening on 20610: 0
Error creating bean with name 'dishes' defined in com.tiffinbox.web.Dishes defined in @EnableElasticsearchRepositories declared on DataElasticsearchRepositoriesRegistrar.EnableElasticsearchRepositoriesConfiguration
DataAccessResourceFailureException: Connect to http://127.0.0.1:20619 [/127.0.0.1] failed: Connection refused (connect failed)
its log: lines naming 20619 5 · the hosts its client tried (Connect to ...): Connect to http://127.0.0.1:20619 · 'dishes re-indexed' 0
```

### 11 · seven — the comparison set on before/ and after/ (R.363)

```text
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20617 now: 0
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20610 now: 0
the seven, after/ against before/: lines that differ: 0
```

### 12 · sockets — the connection witness at the end of the receipt (S8.92)

```text
its interfaces (/proc/net/dev): eth0,lo
the sockets: listening (TCP) on 9200, 9300 · connections from another local port (outbound): 0 · UDP sockets: 0
```

### 13 · exercise — run as written, in one shell, bash then zsh (R.196)

```text
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
in zsh (/bin/zsh -f) - the README's lines, the block's exit 0:
$ perl -pe 's/ops\.save\(dish\);/ops.withRefreshPolicy(RefreshPolicy.IMMEDIATE).save(dish);/' exercise/SaveLab.java > "$EX/SaveLab.java"
saved: dish 1 · the count that follows: 0
saved: dish 1 · the count that follows: 1
check: _count -> 0 · document writes the program sent: 1 · a refresh behind the write: no · solved: no
check: _count -> 1 · document writes the program sent: 1 · a refresh behind the write: yes · solved: yes
the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20618 afterwards: 0 · the container c8u22-es-ex afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: the same list yes
```

## Which store, which profile, which tree

- **PostgreSQL holds the rows — the source.** The unit's PostgreSQL `c8u22-pg` on `20611` (a fresh database per dev JVM: `u22anchor`,
  `u22sync`, `u22absent`; the second start of `anchor` and of `sync` reuses its database on purpose); Compose's PostgreSQL on `18881`
  inside `anchor`'s window (read by the postgres service's own `psql`); **the harness's** PostgreSQL `c8u22-pg-h` on `20616` (`drift`
  only, a fresh database per mode, `h22intx`, `h22listener`, `h22control`). Every row count is `psql`'s `count(*)` of the named one.
- **Elasticsearch holds the copy.** The shipped index `dishes` on the unit's Elasticsearch `c8u22-es`, `20614` (`anchor`, `mapping`,
  `requests`, `highlight`, `sync`); Compose's `dishes` on `18884`; the IT's on `20615` (Testcontainers, during `mvn verify` only); the
  exercise's own container on `20618`. The scratch indices, each made and deleted by the run that names it: `dishes_nrt` (curl alone,
  `nrt`), `dishes_nrt_j` (the harness, `nrt` and `stale`), `dishes_drift` (the harness, `drift`).
- **Which tree and profile:** 22/after under "dev" (`anchor`, `mapping`, `sync`, `absent`, the Compose window); 22/after's jar under the
  harness's own Spring context, no Boot (`requests`, `highlight`, `nrt`, `stale`, `drift`); 22/after with no profile on H2, no Docker
  (`default`, the seven on after/); 21/after with no profile (the seven on before/).
- **"the harness plants a failure"** — every `drift` line: the three modes are the harness's `probe.u22.H22`, never the anchor's.
  The anchor ships no index write inside JPA's transaction and no second manager.

## Refused, named

- An index write inside JPA's transaction in the anchor — `drift`'s `intx` is the harness's, and it prints the copy holding a dish the
  table does not (`rows 0 / index 1`).
- Another transaction manager in the anchor — the anchor's one is `transactionManager`, `JpaTransactionManager` (`anchor`'s
  `/actuator/beans` line, and the harness's bean list in `drift`).
- The listener on `BEFORE_COMMIT` — measured once as a plant (below): the caller saw the planted exception and the row rolled back.
  The shipped phase is `AFTER_COMMIT`: the copy is written only for a row the table kept.
- A pause, or a second write, to make a count read `1` — the exercise's checker counts the writes and looks for the refresh.
- An exec into a container to run curl there; a binding on every interface; the key `spring.elasticsearch.uris` twice on one command line.
- Wording, per sentence, by `harness/s822.py`: the families of Part A and Part B and the refused readings of units 21 and 22, each
  self-tested on a plant (the plant list below) — the counts are the measurement, never a time (R.432).

## The repository, and the network

The seed is `../../spring-data-beyond-jpa/_research/m2-seed-c8-s4b/` as unit 21 used it (no new artifact: `spring-data-elasticsearch`
6.1.2 holds `@Highlight`, `@HighlightField`, `CriteriaQuery`, `NativeQuery` and `RefreshPolicy`, and `spring-tx` holds
`@TransactionalEventListener` — the receipt lists them off the jars). `.m2-demo` is a copy of that seed, and every build is offline
(`-o`, `maven.repo.local` absolute, `Downloaded from` counted `0`, `.m2-demo`'s file count unchanged). No pull: the four images by their
digests, present before the run; the images list and the volume count the same at the end. No network but the loopback, and the
connection witness at the end (`sockets`): no outbound TCP or UDP socket in the samples of the unit's Elasticsearch container.

## The folders, the harness and the ports

- `harness/src/probe/u22/H22.java` — the harness JVM, in its own package `probe.u22`, compiled against 22/after's jar and libraries.
  Unit 20's `H20` shape: a plain Spring context (`AnnotationConfigApplicationContext`) where JPA is needed (`drift`: the
  `DataSource` from a `0600` file, Flyway V1-V4 from the core jar's migrations, `LocalContainerEntityManagerFactoryBean`,
  `JpaTransactionManager` named `transactionManager`, `@EnableJpaRepositories` for the shipped `DishEntityRepository`), and Elastic's
  client and Spring Data Elasticsearch's template built by hand otherwise; one mode per launch, every line it means printed with
  `PROBE`; it halts once its mode is done (the client's I/O threads are not daemons).
- `harness/chk22.py` (the checks), `harness/s822.py` (the prose gate), `harness/tree22.py` (the tree pin, unit 10's lines),
  `harness/surefire.py` and `harness/dur8.py` (unit 02's, byte for byte), `harness/logback.xml` (unit 07's, byte for byte).
- Ports, all on `127.0.0.1`: `20610` TiffinBox after/ · `20611` the unit's PostgreSQL · `20612` the unit's Redis · `20613` the unit's
  MongoDB, a standalone (a fresh container per dev start, as unit 20 found; this unit reads nothing from MongoDB) · `20614` the unit's
  Elasticsearch · `20615` the IT's Elasticsearch (Testcontainers, during `mvn verify` only) · `20616` the harness's PostgreSQL ·
  `20617` TiffinBox before/ for the seven · `20618` the exercise's Elasticsearch · `20619` never bound (Elasticsearch absent).
  `20578` the Mongo IT's pinned binding. `18881-18884` only inside `anchor`'s Compose window.
- Memory: at most two Elasticsearch containers alive together — the unit's and the IT's (during `mvn verify`, before the unit's starts),
  or the exercise's alone (the exercise runs first).

## Masks, filters and hygiene — every one, declared

The receipt masks the folders and the home, the Spring and Maven times (`Started … in`, `Time elapsed`, `scanning in`, `initialization
completed in`, `execution time`, `started in PT…`, `Total time`), `"took"`, `took[…]`, `"@timestamp"`, `pid`, and an object's identity
hash (`@…`). It cuts the client's search requests' fixed query string (`?search_type=query_then_fetch&typed_keys=true`) and replaces the
loopback address of the unit's Elasticsearch with `<es>` in the harness's and the listener's request lines. `dk stats` and
`_cat/indices`' `docs.deleted` are read into the receipt's log, never a capture (a resident size and a merge move them). Every capture
is then refused if it holds an absolute path, a time, a time setting (`refresh_interval`, `search.idle.after`), a log time, a stack
frame, H2's generated database name, a raw container port, an all-interfaces binding, the shutdown token or the PostgreSQL password;
`dur8` over the captures and this README's text blocks is `0`.

## Interrupted

One SIGINT point was run, after the three runs of record: **mid-build** (the receipt started in its own process group with SIGINT at
its default, R.410, interrupted while Maven built the trees): the receipt's exit `130`; afterwards `java` processes `0`, no container
of this unit's, Compose's or Testcontainers' (`c8u22-*`, `tiffinbox-dev-*`: `0`), volumes `315`, images `9`, nothing listening on
`20578`, `20610-20619` or `18881-18884`, `.r-lock` gone, no partial capture, the captures unchanged.

The five other points the plan names were run on 2026-11-23, after unit `23`'s commit, by the evidence agents' own script
(`sigint.sh`, their scratch), each against this folder's `receipts.sh` as committed, started in its own process group with SIGINT at
its default (R.410): **mid-exercise** (the exercise's own Elasticsearch container `c8u22-es-ex` up), **mid-verify** (a Testcontainers
container up under `mvn verify`), **mid-dev-start** (the unit's four stores up, TiffinBox's dev JVM starting), **mid-Compose-window**
(the Compose project's four services and the unit's four stores up), **mid-`drift`** (the harness's PostgreSQL up, the harness JVM in
its `drift` mode). Each time: the receipt's exit `130`; afterwards `java` processes `0`, no container of this unit's, Compose's or
Testcontainers' (`c8u22-*`, `tiffinbox-dev-*`: `0`), no `tiffinbox-dev` network or volume, volumes `315`, images `9`, nothing
listening on `20578`, `20610-20619` or `18881-18884`, `.r-lock` gone, no partial capture; where the unit's Elasticsearch was up, the
trap deleted the three scratch indices and printed `_cat/indices` (`dishes` alone left, or nothing where the dev start had
not yet made it); after each point every capture's md5 equal
to `receipts.md5`'s.

The first mid-Compose attempt never reached the window: with the machine's load near `30` the receipt stopped itself at the
exercise's check — in zsh the broken program's count read `1` — and left that failing capture in place of the published one; the next
run wrote the published capture back, and the point, run again, ended as above. The exercise's check reads `_count` with a curl of its
own after the program exits, so the index's periodic refresh can fall between the two (the race `nrt` met, "What differed") — a fault
of that check under load, not of the traps; not changed here.

## The decision-table unit measures nothing new

Part B's next unit, the decision table, cites this unit's captures by name (S8.97). The Planned-captures entries RED S4B may cite: `anchor`, `requests`, `nrt`,
`stale`, `sync`, `drift`, `default`, `absent`.

## What differed from the plan

Each entry dated 2026-11-23, the evidence agent's choice where the plan left one open (Vivek was not present; nothing was asked).

- **The slot map.** `20610` TiffinBox after/, `20611`-`20614` the unit's four stores, **`20615` the IT's binding** (an anchor change of
  one number: `ElasticsearchIT` pinned `20606` in unit 21's slot map; its Javadoc and the anchor README say so), **`20616` the
  harness's PostgreSQL**, **`20617` before/ for the seven** (the plan's `+5` is the IT's here and `+6` the harness's, so before/ moves to
  `+7`), **`20618` the exercise's Elasticsearch**, `20619` never bound.
- **One Elasticsearch container for the harness, not two.** `drift`'s index `dishes_drift` lives on the unit's Elasticsearch (`20614`),
  made and deleted by the harness per mode; another container would have been the third alive during the run's busiest window, and
  the memory rule allows two.
- **`POST /dishes` lives in its own controller, `DishWrite`, under "dev" only**, and `DishService` (web, not core: it publishes an event
  the web module's listener hears, and core holds no Spring event of its own) is "dev"'s too. So the default run prints the lines unit
  21's `default` printed, plus one: `POST /dishes` answers `404`. The response is **`201`** with the saved dish (`DishSaved` as JSON,
  the id PostgreSQL assigned).
- **What the route returns.** `GET /dishes/search` keeps its route and returns `Hit(id, name, fragment)`, `fragment` the list of the name's
  fragments Elasticsearch marked (one per document here, since every document matched in `name`); no sibling route.
- **`DishEntity` gained a public constructor** `(name, mealType, price)` for a new row; the id stays the identity's.
- **The receipt's new dishes**: `Mushroom Noodle Bowl` (VEG, `110`) and `Tomato Basil Soup` (VEGAN, `130`) — English, none of V4's ten,
  no Hinglish word; the harness's `Garden Pea Soup`. The search word for the first is `mushroom`.
- **The harness's index writes in `drift` use the template's save plus an explicit `_refresh`** (the repository's save shape) on
  `dishes_drift`, a harness index with the shipped `Dish`'s settings and mapping; the harness's `nrt` and `stale` use a harness record,
  `NrtDish` (the shipped `Dish`'s fields, settings and analyzer, `@Document(indexName = "dishes_nrt_j")`), so that "the repository's
  save" is a real `SimpleElasticsearchRepository` save on a scratch index, never on the shipped one.
- **`stale` is its own harness mode**, and `chk22.py same` asserts its two counts and request lines equal to `nrt`'s `a` and `b`.
- **`nrt`'s REST half does not print `refresh_interval` or `search.idle.after`**: the receipt's hygiene refuses a time setting in any
  capture, so those two are not captured and not said.
- **`highlight`'s route half is `anchor`'s line** (`GET /dishes/search?q=veg (TiffinBox)`, with its fragment) — the route needs the dev
  JVM, which `anchor` holds; `highlight` itself is the harness's and curl's.
- **`mapping`'s Java witness is cited, not re-printed**: the client's `PUT /dishes` body is `anchor`'s line "the index creation, as
  the client sent it".
- **The planted exception inside the listener is quoted by the harness** (`PROBE the listener (AFTER_COMMIT) throws: …`): unit 07's
  `logback.xml` prints no stack (`%nopex`), so Spring's own `TransactionSynchronization.afterCompletion threw exception` line is quoted
  as printed and the cause beside it by the harness.
- **The double family test**: every README and Javadoc sentence ran through `s822.py` (s821's blocks byte for byte, XU22 added) and the
  Javadoc and comment lines the change added through `chk22.py javadoc` (R.302's typed-number rule aside — a Javadoc names its numbers as
  code does); 0 refused. The script stage's Part A blocks are the builder's (`_builders/s818.py`), which `chk22.py static` asserts equal
  to `s822.py`'s slices by md5.
- **`V4__dish.sql`'s comment "a copy the dev start rebuilds" is kept, not noted**: a migration's bytes are Flyway's checksum, so a
  comment edit there is a new checksum on every database that ran V4. The anchor README's unit 22 section says the listener adds.
- **`ElasticsearchIT`'s new test indexes the same three dishes** as the first test (ids `1`, `2`, `8`), not V4's ten: the slice has no
  JPA, and the three are the ones whose names the fragment and the vegan box need.
- **Testcontainers' defaults** are read off its jar once per run inside `anchor` (`unzip -p`, the class file's strings and the memory
  file), as unit 21 did.
- **`nrt`'s REST half sends the write, the count and the search in ONE `curl` (`--next`)** — three requests one after the other, no
  process started between them. Measured: a first bash 5.3.9 run (the machine's load at `18`) printed `then _count -> 0` in one
  repetition and `then _count -> 1` in another when the three were separate `curl` processes — the index's own periodic refresh fell
  between the write and the count. The capture's form changed, the three runs of record above ran on the fixed receipt, and the
  plan's wording for that count is said here as "the count that follows".
- **The receipt runs before this README's last sections were written.** "Runs of record", "Interrupted" and "Planted faults" were
  written after the three runs from their logs; the README's own gates (`s822.py`, the text blocks against the captures, the values
  line, the S8.95 numbers check) were run again on the final README, offline, and passed — said in the report.

## For RED

- **The bean name.** The anchor has one transaction manager, `transactionManager`, `JpaTransactionManager` (`anchor`'s `/actuator/beans`
  line); the harness's context prints the same pair (`drift`). Whether a second manager's name makes the clash loud or quiet is unit 24's
  question (RED #2), not measured here.
- **The listener's two requests are the repository's save.** `PUT /dishes/_doc/11?refresh=false` then `POST /dishes/_refresh`, by the
  client's own trace logger, after the `POST` and before any other request (`anchor`, `sync`, and the Compose window on `18884`). The
  count `11` beside the row count `11` is read after the route returned — no time is said, the count is.
- **`stale` is a slice of `nrt`.** `chk22.py same` asserts the template's `0` and the repository's `1` and their request lines identical
  in both captures.
- **`drift` is the harness's, labelled in every line of this README that cites it.** Its index is a harness index on the unit's
  Elasticsearch (`dishes_drift`, deleted after each mode, printed); its rows the harness's PostgreSQL on `20616`, never the unit's.
- **The unique-key refusal in `sync`.** The first name sent again is refused by the table, the row rolls back, and the index count
  stays: the `AFTER_COMMIT` phase writes no copy for a row the table did not keep. The status code is the one the route printed.
- **Strict mode** prints the same count on 22/after as on 21/after: the new beans are not repositories.
- **`NativeQuery`'s `"size":10`** is the hazard shown on the request: with ten documents nothing is cut here, so the README says it
  from the request line, never from a result.
- **Not captured, not said:** `refresh_interval` and `search.idle.after` (the hygiene refuses a time setting in a capture).

## Planted faults — each caught (R.65, R.226)

Run after the three runs of record, never beside one, by `plants.sh` (the evidence agent's scratch) on a scratch mirror of this folder;
each plant judged by the receipt's own gate or `harness/chk22.py`, each refused, and the controls passing:

- Prose, per sentence (`s822.py`): eight planted sentences, one for each refused reading the plan lists — the slogan of a copy that
  never differs from its rows, the time slogan, the two-store write called solved, a singular time word, a Hinglish dish name, the
  visibility word without a count, the listener as the fix, PostgreSQL as the search engine — each refused (their text is in
  `plants.sh`, the evidence agent's scratch). Control: a sentence with its count and its drift beside it passes.
- Doctored captures, in Python, on copies (`chk22.py`): `stale`'s `0` → `1`; `drift`'s `intx` rows `0` → `1`; `listener`'s index
  `0` → `1`; the `afterCompletion threw exception` line cut; the `<em>` stripped from `highlight`'s fragment; `10000` → `10` in
  `requests`; documents `11` → `10` in `sync`; `404` → `200` in `default`; `Connection refused` cut from `absent`; `13` → `12` in the
  test count; the URI doubled in `anchor`'s S8.84 line. Controls: each real capture passes.
- The receipt's own greps on a doctored mirror: `anchor`'s IT port line doctored to every interface (the S8.94 hygiene grep); a `took`
  unmasked (the TIMEPAT_S4B grep); a container removed without `-v` (R.387); a container call without the pinned socket (R.344); the key
  `spring.elasticsearch.uris` twice in `DEV` (S8.84's gate); a wrong `before` link (R.211); a wrong after-tree hash (the pin); the
  exercise's solution equal to the broken block (R.196: `0` lines differ, not `2`); a changed What-it-prints line; a placeholder; an
  R.250 sentence left (`18 + 12` without its note, `chk22.py r250`); the listener on `BEFORE_COMMIT` and `DishIndexSync` without
  `@Profile("dev")` (`chk22.py static`; the second was not started as a default run — not measured, not said). In all, `32` plants
  refused and `10` controls passing (`plants.sh`'s last line).
- Measured once, outside the runs (the evidence agent's session, 2026-11-23): the listener on `BEFORE_COMMIT`, by the harness's own
  mode `drift beforecommit` — the caller saw the planted `IllegalStateException`, rows `0` / index `0`: the row rolled back with the
  failure, so the phase that runs inside the transaction turns a failed copy into a failed write; the shipped `AFTER_COMMIT` keeps the
  row and leaves the copy a row behind, which `drift`'s `listener` mode shows. A two-write "solution" and a pause "solution" of the exercise,
  each run against a fresh index: the checker printed `document writes the program sent: 2 · a refresh behind the write: no · solved:
  no`, and for the pause `_count -> 1 · document writes the program sent: 1 · a refresh behind the write: no · solved: no` — the count
  alone would have passed it; the trace refused it. `ElasticsearchIT` without its binding: cited, not measured again — unit 21's plant
  `nobind` (`../c8-unit21`, "Planted faults") measured Testcontainers 2.0.5 publishing on every interface and the S8.94 grep stopping
  the receipt; this unit's IT keeps the same binding form on `20615`.

## The values the video may say

Every count with its index, store, tree and ids; every rows / index pair with its store named; every `drift` line labelled — the
harness plants a failure. The line between the markers is the receipt's own (`.harness/values.txt`), asserted equal at every run:

<!-- values: begin -->
drift (the harness plants a failure; PostgreSQL's psql on the harness's database beside _count on dishes_drift): `intx`: rows 0 / index 1 · `listener`: rows 1 / index 0 · `control`: rows 1 / index 1
the values the video may say - exercise: the exercise: the template's save 0, solved 1, one write, refresh=true · anchor: anchor: Flyway 4, the re-index rows 10 -> documents 10, dishes green 10, veg [1] with the fragment <em>Vegetarian</em> Lunch Box by TiffinBox and curl, strict mode 12 "could not safely identify" lines (3 naming Dishes: Spring Data JPA, Spring Data MongoDB, Spring Data Redis) and 6 "Multiple Spring Data modules found", POST /dishes 201 id 11, rows 11 = documents 11, the listener PUT _doc/11?refresh=false then _refresh, the second start on the same database rows 11 -> documents 11, Compose on 18884 with rows 11 = documents 11, 18 + 13, the IT 127.0.0.1:20615 and the Mongo IT 127.0.0.1:20578, the 18 without Docker, 146 libraries (before 146), HHH000001 7.4.13.Final · mapping: mapping: _class keyword (index false), the dynamic id text + keyword, name text by dish, _doc/1 _class com.tiffinbox.web.Dish · requests: requests: the derived finder size 0 then size 1, CriteriaQuery size 10000, NativeQuery size 10, each [1]; prefix 4 [1, 10, 2, 8] (1 VEG, 10 VEG, 2 VEG, 8 VEGAN) · highlight: highlight: veg <em>Vegetarian</em> Lunch Box [1], vegetarian the same, lunch [1, 8] Vegetarian <em>Lunch</em> Box and Vegan <em>Lunch</em> Box · nrt: nrt: REST at once 0, wait_for 1, true 1; Spring the repository's save 1 (refresh=false then _refresh), ElasticsearchOperations.save 0 (refresh=false, policy null), withRefreshPolicy(IMMEDIATE) 1 (refresh=true) · stale: stale: the template's save then a count 0, beside the repository's save 1 · sync: sync: rows 10 = documents 10, POST -> 11 = 11, another POST -> 12 = 12, the same name again 500 and 12 = 12, the second start 12 -> 12 · drift: drift (the harness plants a failure): intx rows 0 / index 1, listener rows 1 / index 0 and the caller saw no exception, control rows 1 / index 1 · absent: absent: exit 1, Error creating bean with name 'dishes', DataAccessResourceFailureException: Connect to ... Connection refused, the one URI · default: default: health 200, /dishes/search 404, /revenue/by-customer 404, /menu/day-19 404, /revenue 200, /kitchen 200, POST /dishes 404, 0 lines naming 9200 or elasticsearch, 0 naming 27017 or mongo, the 18 under mvn package · seven: the seven: md5 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/ · sockets: sockets: listening on 9200, 9300, outbound 0, UDP 0
<!-- values: end -->

# c8-unit21 — *Full-Text Search: The Analyzer Explained*

Course 8, Section 4's fourth unit, and **Section 4 Part B's first change to the anchor — Elasticsearch, under the profile "dev"**.
`before` is a link to `../c8-unit20/after` (the previous unit's tree; the receipt pins it and asserts that pin is that unit's own
after-tree line); `after/` is this unit's tree, and `../c8-tiffinbox` equals `after/` from this unit's commit on. The change gives the
anchor a table of dishes and an index of them: `V4__dish.sql` writes ten dish rows (PostgreSQL's under "dev", the source), the "dev"
start copies every row into Elasticsearch's index `dishes` (the copy), and `GET /dishes/search?q=` asks that index. The index's field
`name` is analysed by `dish`, an analyzer of TiffinBox's own (`dish-settings.json`). The default run keeps no Elasticsearch and builds
no client: the seven auto-configurations of Boot's two Elasticsearch jars are excluded there, as Part A's three MongoDB ones are.

**An analyzer** is the step that turns text into the tokens an index stores, and turns a query into the tokens it looks up. The
standard analyzer splits on word boundaries and lowercases; a search for a word finds a document only when the index stored that
token for it.

Every Elasticsearch number below comes from two witnesses in the same run (S8.78): **Java's answer** — TiffinBox's route
`GET /dishes/search` under "dev", the start's own log line, the requests the client sent (its own trace logger,
`co.elastic.clients.transport.rest5_client.low_level.Request` at TRACE), the IT's lines, the exercise's program — and **the store's
own REST API, by `curl` on the loopback port from this Mac**: `_analyze`, `_search`, `_mapping`, `_settings`, `_cat/indices`,
`_explain`, `_cluster/settings`, `GET /`. curl never runs inside the container (§BUILDERS 9); the receipt's two `exec` calls read a
file each (`/proc/sys/vm/max_map_count`, `/proc/sys/kernel/osrelease`, `/proc/net/*`) by `cat`, never a shell. Elasticsearch is
**9.4.8, by the digest** (`docker.elastic.co/elasticsearch/elasticsearch@sha256:fb7f2d0d…c5d5c403`, `--pull never`, `127.0.0.1`
only), every container with the six settings `compose.yaml` explains; PostgreSQL 18.6, Redis 8.10.3 and MongoDB 8.3.17 by the course's
digests. Every line names its tree, its profile, its store and its index (R.392): **21/after, profile dev, the four stores** (`anchor`,
`tokens`, `explain`, `absent`; the index `dishes` on `20604`, analysed by `dish`); **a copy with the standard analyzer**
(`harness/variants.py std`: `nohit`, and the scratch indices of `sayso`, `fuzzy`, `late` on its own Elasticsearch, `20605`);
**21/after, default run, H2, no Docker** (`default`, the seven); **the image's default on this VM** (`image`'s labelled container).

Thirteen captures. The JVM and store captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`);
`exercise` and the tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string
below is asserted after its capture by `harness/chk21.py` against another witness of the same run; every count it prints beside an
ids list is re-derived from that list, and every id's meal type is read off `V4__dish.sql` (S8.95). Evidence by a Claude Opus 5.5
agent on 2026-11-23, started 00:14 CET.

## Runs of record

**2026-11-23, the finishing agent (session 4a171840) - the three runs of record, each with every capture = published, every
`chk21.py` check held, every Maven run offline (`'Downloaded from' 0`; the tests' `offline: yes` twice in `anchor`), the volume
count and the images unchanged, `before/` and `after/` = their pins at the start and the end, nothing listening on the unit's ports at
the end, each log ending with its `c8-unit21:` line and each through `check_unit8.py 21 --runlog` - `RESULT (run logs): PASS`:**
- `./receipts.sh` (/bin/bash 3.2.57), from 04:11:17 CET, ended 04:23:27; the 1-min load average 3.97 at the start, 6.63 at the end;
  `pgrep -x ffmpeg` one process (41794, another session's re-voice job, 0 % CPU, idle) both times.
- `bash receipts.sh` (Homebrew bash 5.3.9), from 04:23:34, ended 04:36:07; load 6.34 / 5.07; the same idle ffmpeg.
- A sealed fresh clone (R.129): `git clone` (`file://`) of tiffinbox-java at this unit's commit (before it was amended with these
  paragraphs) into a path with a space (`…/scratchpad/ev21/sealed 21/tiffinbox-java`), the clone's `c8-unit21/.m2-demo` a file copy of
  `m2-seed-c8-s4b` (7,265 files, 509,551,205 B), `env -i` with `HOME`, `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`
  and `DOCKER_CONFIG=$HOME/.docker`; `./receipts.sh` from 04:37:09, ended 04:50:20; load 4.95 / 5.44; the same idle ffmpeg.
  The clone was removed after.
- Before them, three starts of the first run that did not finish, each recorded under *What differed* (dated): 03:31 (stopped by
  this agent after the gates, to note a stale Javadoc sentence - the after-tree pin moved), 03:35 (`nohit` drifted - the receipt
  fixed), 04:00 (`explain` differed from the debug pass's hash, as warned - re-pinned from that run, 3/3 inside it; the run that
  followed reproduced it). The runs ran on this README before its *Runs of record*, *Interrupted* and *Planted faults* dated
  paragraphs were written; the prose gate, the text-block check and the values check were run again on the final README.

The first agent's account follows, as written (its session, 00:14-02:14 CET).

The first agent's session ended without them. The machine ran under a load average between 105 and 191
during this session (another job's `ffmpeg` and OrbStack's helper at the top of `ps`).
What ran, all from this folder:
- **The trial runs of `./receipts.sh`** (bash 3.2.57) that found and fixed the receipt's own faults (each stopped at its first
  failure, by the receipt's own gate or check): the permission bit, three static gates that matched their own messages, the
  environment order `dk inspect` prints (sorted since), an empty Mounts reading (`none` since). One of them ran the gates, the four
  builds, `exercise` (bash then zsh, the hash in `receipts.md5`) and `image`'s three runs to the drift that the sort fixed.
- **Debug passes** (bash 5.3.9, a copy of this receipt as `.r-dbg.sh` with the builds reused and each capture run once): `image`,
  the tests, `anchor`, `tokens`, `nohit`, `sayso`, `fuzzy`, `late`, `explain` (on a curl-built copy of the shipped index - its hash is
  not the run of record's), `absent`, `default`, the seven, `sockets` - every check passing (`chk21.py`), the hashes in `receipts.md5`.
- **The mid-verify SIGINT run** (bash 3.2.57, `./receipts.sh` in its own process group) reached the tests before its SIGINT: on the way it
  ran the gates, the four builds, `exercise` (bash then zsh) - `= published` - and `image` three times - `3/3 = published`, the hash
  the debug pass wrote. So `exercise` is 1/1 in two runs and `image` 3/3 in two runs, the same hashes.
- **No run of record**: the three the brief asks for (bash 3.2.57, bash 5.3.9, a sealed fresh clone) did not fit the cap; each would
  not fit beside the other two on this machine as loaded. The hashes in `receipts.md5` are the debug passes' (each capture
  once; `exercise` and `image` three times in the trial run's), every one checked by `chk21.py`; the first run of record will say
  whether each is the published one (`pub`), and `explain`'s was taken on a curl-built copy of the shipped index, so that one may move.
  `dk stats` readings, once each: the labelled default container and the four stores' sizes were printed into the debug logs, not kept.

## The change, file by file, and every README/YAML/Javadoc/compose sentence it rewrote or noted (R.250, S8.93)

The files the change added or changed, as the receipt lists them (`diff -rq before/ after/`), besides the anchor README:

```text
    changed: README.md
    changed: compose.yaml
    changed: tiffinbox-web/pom.xml
    changed: tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
    changed: tiffinbox-web/src/main/resources/application-dev.yaml
    changed: tiffinbox-web/src/main/resources/application.yaml
    changed: tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java
    changed: tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java
    changed: tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java
    new: tiffinbox-core/src/main/java/com/tiffinbox/DishEntity.java
    new: tiffinbox-core/src/main/java/com/tiffinbox/DishEntityRepository.java
    new: tiffinbox-core/src/main/resources/db/migration/V4__dish.sql
    new: tiffinbox-web/src/main/java/com/tiffinbox/web/Dish.java
    new: tiffinbox-web/src/main/java/com/tiffinbox/web/DishSearch.java
    new: tiffinbox-web/src/main/java/com/tiffinbox/web/Dishes.java
    new: tiffinbox-web/src/main/resources/dish-settings.json
    new: tiffinbox-web/src/test/java/com/tiffinbox/web/ElasticsearchIT.java
    new: tiffinbox-web/src/test/java/slice/ElasticsearchSlice.java
```

- `tiffinbox-web/pom.xml` — `spring-boot-starter-data-elasticsearch` (compile), `spring-boot-starter-data-elasticsearch-test` and
  `testcontainers-elasticsearch` (test), no version typed: the parent's BOM picks Spring Data Elasticsearch 6.1.2, the client 9.4.8,
  Testcontainers' module 2.0.5. Its comment on Jackson 2, written when Jackson 2 left this POM, gains a note: Jackson 2's `jackson-databind` is back at run time,
  through the client, and Spring MVC still writes with Jackson 3 (`anchor` measures both).
- `tiffinbox-core/…/db/migration/V4__dish.sql` — the table `dish` and ten rows, the English names of the brief's flag 6 in its order
  (ids `1` to `10` by the identity, on a fresh database), meal types `VEG`, `NON_VEG`, `VEGAN`, and each row's price the menu's price for
  its meal type, `MenuDay`'s `VEG_PRICE`, `NON_VEG_PRICE`, `VEGAN_PRICE` (derived, never invented; `chk21.py static` asserts it).
  `DishEntity` and `DishEntityRepository` (Spring Data JPA, `tiffinbox-core`) read them; Hibernate validates the entity against V4.
- `Dish.java`, `Dishes.java`, `DishSearch.java`, `resources/dish-settings.json` (`tiffinbox-web`) — the document, its repository with
  the derived `findByName`, the route under "dev" only, and the analyzer `dish` (the standard tokenizer, lowercase, the synonym
  `veg, vegetarian`) with `number_of_replicas: 0`. `Dish`'s id is a String, the row's id; the mapper also writes `_class`, and the
  record's `id` lands in the document's body as a dynamic text field (`anchor`'s `_mapping`).
- `TiffinBoxServer.java` — under "dev", after the MongoDB fills, the start deletes the index's documents, saves every row's copy through
  `Dishes` (one bulk, then the repository's own `_refresh`, by the trace logger) and logs the rows' count beside the documents' before and
  after; two more `ObjectProvider`s, so the default run, which has no `Dishes`, touches nothing; a Javadoc paragraph for unit 21.
- `application.yaml` — the exclude list gains the seven names `unzip -p` prints off the two jars' `AutoConfiguration.imports` (ten with
  Part A's three); its comment says why and counts them. `application-dev.yaml` — its comment: the same empty list clears the seven too;
  the address key is `spring.elasticsearch.uris`, as Boot's metadata names it, and is not set there (Compose hands it).
- `compose.yaml` — the fourth service, `elasticsearch`: the image by its tag (`docker.elastic.co/elasticsearch/elasticsearch:9.4.8`), the
  digest and the two heaps in its comment, the six settings each with its reason, `127.0.0.1:18884:9200`, no volume, no `pull_policy`.
  `git grep -l 18884 HEAD` names only `c5-unit17/README.md` and `c5-unit17/receipts.sh` (`c5-unit17`'s receipt port); the comment
  says so, as `18882`'s does.
- `CustomerAggregatesIT.java`, `CustomerEntityRepositoryIT.java` — their migration lists `V1`-`V4`, a comment naming unit 21 (a fourth
  migration fails both lists otherwise: `nolists` among the plants). `slice/ElasticsearchSlice.java` and `ElasticsearchIT.java` — new:
  `@DataElasticsearchTest` from the slice, under "dev" (whose empty list clears the exclude; Boot's Compose support does not start in a
  test), `@Container @ServiceConnection ElasticsearchContainer` on the digest with four settings as variables and the heap as
  `ES_JAVA_OPTS` (Testcontainers sets `discovery.type=single-node` itself — the container's environment as run is printed), port `9200`
  the only one exposed and bound to `127.0.0.1:20606` alone (S8.94). `MongoDatastoreIT`'s Javadoc count gains a note.

The sentences the change made false or incomplete — each found by `git grep` for `Jackson`, `18 + 11`, `exclude`, `services`, the
Mongo-list sentences and `V1-V3`, and each rewritten or noted beside it, checked by `chk21.py r250` (R.250):

```text
ok tiffinbox-web/pom.xml: the Course 6 Jackson comment noted (R.250)
ok R.250: the anchor README's jar-count chain 58 -> 56 -> 61 and "one Jackson from there on" (Course 6 unit 04's section) - noted (Course 8, unit 21: two Jacksons again, BOOT-INF/lib's count since)
ok R.250: tiffinbox-web/pom.xml's Course 6 comment "Jackson 2's jackson-databind ... is gone" - noted beside it
ok R.250: README.md's unit 20 section "`mvn verify` runs 18 + 11" - noted (18 + 12)
ok R.250: README.md's unit 19 section "18 + 10 (Course 8, unit 20: 18 + 11 ...)" - noted (18 + 12)
ok R.250: MongoDatastoreIT's Javadoc "18 + 11" - noted (18 + 12, ElasticsearchIT beside it)
ok R.250: README.md's unit 18 section, the exclude list's three names - noted (ten since)
ok R.250: README.md's Part A closing "Part B ... changes this folder next" - noted (it has)
ok R.250: application.yaml's exclude comment - grown: the seven and the count, ten
ok R.250: application-dev.yaml's exclude comment - grown: the same empty list clears the seven
ok R.250: compose.yaml's header "MongoDB, the third" - grown: Elasticsearch, the fourth
ok R.250: TiffinBoxServer's Javadoc - a unit 21 paragraph (the fifth and sixth providers, the re-index), the fills' list grown
ok R.250: CustomerEntityRepositoryIT's Javadoc "lists V1-V3" - rewritten (V1-V4)
ok R.250: README.md's head "Flyway's three migrations (V1-V3)" - kept: it says what Course 7 left (the Course 8 notes beside it say what moved), and unit 21's section names V4
```

**R.211/R.331 — the builders.** The change touches nine anchor paths an earlier builder or receipt could name (`application.yaml`,
`application-dev.yaml`, `compose.yaml`, `TiffinBoxServer.java`, `tiffinbox-web/pom.xml`, `CustomerAggregatesIT.java`,
`CustomerEntityRepositoryIT.java`, `db/migration`, `README.md`). The grep before the commit, over every shipped builder (`spring-data-beyond-jpa/_builders/s8*.py`) and every shipped
`c8-unit*/receipts.sh` and `harness/*.py` but this unit's, files naming each path (builders · receipts and harness):
`application.yaml` `9` · `27`, `application-dev.yaml` `9` · `29`, `compose.yaml` `10` · `35`, `TiffinBoxServer.java` `7` · `16`,
`tiffinbox-web/pom.xml` `14` · `23`, `CustomerAggregatesIT.java` `1` · `2`, `CustomerEntityRepositoryIT.java` `1` · `1`, `db/migration`
`0` · `17`. Each of those paths is named by earlier units' files (the builders read
each unit's own `after/` or a pinned commit, and the receipts their own `before`/`after` trees and their own expected lines - `chk02.py`'s
migration list and the earlier receipts' "Successfully applied 3 migrations" lines among them), all on frozen trees pinned to their
commits; none reads `c8-tiffinbox` live for a value this change moves, so nothing moves (the note form, R.211). `s801.py`'s live
compare of `c8-tiffinbox` is a note, never a failure, by its own code.

## RE-MEASURE 1 + flag 7 — the exclude and the default run (settled first)

The seven names are never typed: the receipt prints them off `.m2-demo`'s two jars by `unzip -p`, and `chk21.py static` asserts that
`application.yaml`'s list is Part A's three followed by exactly those seven, in the jars' order:

```text
ok application.yaml: the exclude list = Part A's three + the seven names the two jars' AutoConfiguration.imports list (read off .m2-demo's jars), in their order - ten
  the two jars' AutoConfiguration.imports (unzip -p off .m2-demo), 7 names: elasticsearch.autoconfigure.ElasticsearchClientAutoConfiguration · elasticsearch.autoconfigure.ElasticsearchRestClientAutoConfiguration · elasticsearch.autoconfigure.health.ElasticsearchRestHealthContributorAutoConfiguration · data.elasticsearch.autoconfigure.DataElasticsearchAutoConfiguration · data.elasticsearch.autoconfigure.DataElasticsearchReactiveRepositoriesAutoConfiguration · data.elasticsearch.autoconfigure.DataElasticsearchRepositoriesAutoConfiguration · data.elasticsearch.autoconfigure.health.DataElasticsearchReactiveHealthContributorAutoConfiguration
```

On 21/after's default run — no profile, H2, Docker at nothing (`DOCKER_HOST=tcp://127.0.0.1:1`) — health answers `200`, no log line names
`9200` or Elasticsearch, none names `27017` or Mongo, and the three routes of Section 4's units answer `404`; the beans list holds no
Elasticsearch bean, 3/3 (`default`, below). The health key alone is the refused shape, and on this tree it reads otherwise than the plan did: the copy `healthkey` (the seven names
out, the key in) does not start - Boot's Elasticsearch repositories build `Dishes`, whose constructor reaches `localhost` on port `9200` for its
index, and the JVM exits `1` with the client's `Connection refused`, measured each run, never shipped. The probe's reading (health
`200`, the scans' lines) was on a tree with no Elasticsearch repository in it. Under "dev" the empty list brings all ten back, and strict repository mode prints its lines for the new module (`anchor`).
The brief asked for the ten together on 20/after with the starter; this receipt measures them on 21/after, which is that tree plus the
starter and the classes that use it (what differed, below).

## RE-MEASURE 2 — V4's ten and the shipped analyzer's numbers (settled first)

```text
    (x1) tiffinbox: dishes re-indexed: rows 10 · documents before 0 · documents after 10
  the rows (psql, the unit's PostgreSQL): select count(*) from dish -> 10 · select id, meal_type from dish order by id -> 1 VEG, 2 VEG, 3 VEGAN, 4 VEGAN, 5 NON_VEG, 6 NON_VEG, 7 VEG, 8 VEGAN, 9 NON_VEG, 10 VEG
  curl on 20604: _cat/indices dishes -> dishes green open 1 0 10
  curl: POST /dishes/_analyze {analyzer dish, "Vegetarian Lunch Box"} -> 4 [vegetarian, veg, lunch, box]
  curl: POST /dishes/_search match name veg -> 1 [1] · match name vegetarian -> 1 [1]
  GET /dishes/search?q=veg (TiffinBox) -> 200 [{"id":"1","name":"Vegetarian Lunch Box"}] · q=vegetarian -> 200 [{"id":"1","name":"Vegetarian Lunch Box"}]
  the start's re-index line: dishes re-indexed: rows 10 · documents before 10 · documents after 10
  the start's lines: 1 Successfully applied 4 migrations|1 tiffinbox: dishes re-indexed: rows 10 · documents before 0 · documents after 10|1 tiffinbox: kitchen value:  24300
  curl on 18884 (the elasticsearch service): _cat/indices dishes -> dishes green open 1 0 10 · match name veg -> 1 [1]
  GET /dishes/search?q=veg (TiffinBox) -> 200 [{"id":"1","name":"Vegetarian Lunch Box"}]
```

Every number of the brief's unit 21 is re-measured here on the shipped tree and the shipped index, not the probe's: ten rows
(PostgreSQL), ten documents (Elasticsearch), `green` with no replica, the four tokens of `dish`, and `veg` answered by the vegetarian box
alone through both witnesses; the ways to say so and their ids on a copy with the standard analyzer (`nohit`, `sayso`, `fuzzy`).

## The captures — what each one shows

### 1 · image — the image, its default heap, and the unit's Elasticsearch with the six settings (flags 3-5, S8.77, S8.92)

```text
-- the image, by its digest (dk image inspect, no container):
  Id sha256:fb7f2d0df199b3ea14a700e88a0b701d502cb44409ece3e1540b1dc1c5d5c403 · RepoDigests ["docker.elastic.co/elasticsearch/elasticsearch@sha256:fb7f2d0df199b3ea14a700e88a0b701d502cb44409ece3e1540b1dc1c5d5c403"] · Architecture arm64 · Entrypoint ["/bin/tini","--","/usr/local/bin/docker-entrypoint.sh"] · Cmd ["eswrapper"]
  its declared volumes (Config.Volumes): 0 []
  its environment (Config.Env): ["PATH=/usr/share/elasticsearch/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","container=oci","ELASTIC_CONTAINER=true","SHELL=/bin/bash"]
-- the image's default on this VM: a labelled container c8u21-es-default, five of the six settings - no ES_JAVA_OPTS, so the heap is the image's own choice:
  GET /_nodes/jvm (curl, 127.0.0.1) -> version 27 · mem.heap_max_in_bytes 4198498304 · mem.heap_init_in_bytes 4198498304
  dk stats --no-stream, once: read into the receipt's log, never this capture (a resident size moves between runs)
  volumes with it alive: 315 (before it: 315)
  c8u21-es-default removed (rm -fv) · volumes 315
-- the unit's Elasticsearch: c8u21-es, by the digest, --pull never, the six settings, published on 127.0.0.1:20604 only (9300 not published), a fixed --hostname:
$ docker -H "$DH" run -d --pull never --name c8u21-es --hostname c8u21-es -p 127.0.0.1:20604:9200 -e discovery.type=single-node -e xpack.security.enabled=false -e xpack.ml.enabled=false -e ingest.geoip.downloader.enabled=false -e xpack.inference.elastic.authorization.enabled=false -e ES_JAVA_OPTS=-Xms512m -Xmx512m docker.elastic.co/elasticsearch/elasticsearch@sha256:fb7f2d0df199b3ea14a700e88a0b701d502cb44409ece3e1540b1dc1c5d5c403
  Docker's port list for c8u21-es (dk port) -> 9200/tcp -> 127.0.0.1:20604 · its Mounts: none · volumes 315 (before it: 315)
  its environment as run, the six (dk inspect): ES_JAVA_OPTS=-Xms512m -Xmx512m · discovery.type=single-node · ingest.geoip.downloader.enabled=false · xpack.inference.elastic.authorization.enabled=false · xpack.ml.enabled=false · xpack.security.enabled=false
  GET / (curl, 127.0.0.1, no credentials) -> name c8u21-es · version.number 9.4.8 · build_flavor default · lucene_version 10.4.0 · tagline You Know, for Search
  curl -i GET /: status 200 · its header names: X-elastic-product content-length content-type · a Warning header: 0
  GET /_nodes/jvm -> version 27 · vm_vendor Oracle Corporation · mem.heap_max_in_bytes 536870912 · mem.heap_init_in_bytes 536870912
  GET /_cluster/settings?include_defaults&flat_settings (the six's keys, read back): discovery.type single-node · xpack.security.enabled false · xpack.ml.enabled false · ingest.geoip.downloader.enabled false · xpack.inference.elastic.authorization.enabled false · cluster.routing.allocation.disk.threshold_enabled true
  GET /_cluster/health -> status green · number_of_nodes 1
  the files read inside it (dk exec, cat - a file, never a shell into the store): /proc/sys/vm/max_map_count 262144 · /proc/sys/kernel/osrelease (uname -r's) 7.0.11-orbstack-00360-gc9bc4d96ac70 · /proc/net/dev's interfaces eth0,lo
  its log (dk logs), lines: 'Security is disabled' 1 · 'Starting authorization task executor' 0 · the ML controller ('controller (64 bit)') 0 · 'bound or publishing to a non-loopback address' 0 · 'heap size [' heap size [512mb]
```

The image declares no volume, and the volume count does not move with either container alive. Its default heap, on a labelled
container with five of the six settings (no `ES_JAVA_OPTS`), is the image's own choice on this VM; the pinned one is what the other
five containers of this receipt run. The kernel's `vm.max_map_count` already meets what Elasticsearch asks: nothing changes on the VM.
The six settings read back: security off (`200` with no credentials, no `Warning` header, `Security is disabled` in its log), machine
learning off (no `controller` line), the GeoIP downloader off, the Elastic Inference Service's authorization off (its executor's start
line is absent), one node. `dk stats --no-stream` was read once per run of `image` for the labelled default container and once per
run of `anchor` with the four stores alive; resident sizes move between runs, so they are in the receipt's own log (and this README's
runs of record), never in a capture.

### 2 · anchor — the tests, the libraries, the dev shape on four stores, and the Compose window (RE-MEASURE 2-6, 15)

```text
-- the tests: after/ copied to .harness/tests; mvn package with Maven's DOCKER_HOST pointed at nothing (tcp://127.0.0.1:1), offline:
$ cd .harness/tests && env DOCKER_HOST=tcp://127.0.0.1:1 env "MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8" perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local="$M2" "-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home" clean package -pl tiffinbox-web -am
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
  after it: images 9 (the same list) · volumes 315 (the count before it) · Testcontainers containers 0 · .m2-demo's files unchanged
  Surefire's reports, tiffinbox-web/target/surefire-reports:
    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0
      passed  aListenerHearsANewCustomer
    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0
      passed  aPathNobodyMapsIsAProblemDetail
      passed  aFailingRepositoryIsAFiveHundred
      passed  aFailingRepositoryShowsTheErrorPage
    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0
      passed  theFeedIsAnEventStream
      passed  theDashboardIsAPage
      passed  anInvalidCustomerBreaksThreeRules
      passed  theTestsRunInEnglish
      passed  anUploadAddsTheGoodRowAndNamesTheRest
      passed  shutdownIsNotAGet
      passed  customersAreJson
      passed  theFormIsAPage
      passed  aNameNobodyHasIsAProblemDetail
      passed  aFailingRepositoryLeavesNoStatus
      passed  theSliceLeavesTheDatabaseOut
      passed  sixtyOneSpacesBreakBothRules
      passed  anInvalidCustomerInGerman
      passed  aSixtyOneLetterNameIsRefused
    the fork's locale, read from the reports' properties: user.language en · user.country US · the same in every report: yes
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
  tiffinbox-web/target/surefire-reports-it: absent - no container test ran
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  the package log: lines naming 9200 0 · lines naming 27017 0
-- then mvn verify, the anchor's recipe (DOCKER_HOST on the pinned socket, Ryuk off - TESTCONTAINERS_RYUK_DISABLED=true, a receipt home), offline:
  before it: listening on 20578 (the Mongo IT's pinned binding): 0 · on 20606 (the Elasticsearch IT's): 0
$ cd .harness/tests && env "MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8" perl -e '$SIG{INT}="DEFAULT"; alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local="$M2" "-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home" clean verify -pl tiffinbox-web -am
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
  after it: images 9 (the same list) · volumes 315 (the count before it) · Testcontainers containers 0 · .m2-demo's files unchanged
  the Elasticsearch IT's container while verify ran, Docker's own list (dk ps, polled on a count): Ports 9300/tcp, 127.0.0.1:20606->9200/tcp · listening on 20606 after it: 0
  the Mongo IT's container while verify ran: Ports 127.0.0.1:20578->27017/tcp · listening on 20578 after it: 0
  Surefire's reports, tiffinbox-web/target/surefire-reports:
    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0
      passed  aListenerHearsANewCustomer
    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0
      passed  aPathNobodyMapsIsAProblemDetail
      passed  aFailingRepositoryIsAFiveHundred
      passed  aFailingRepositoryShowsTheErrorPage
    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0
      passed  theFeedIsAnEventStream
      passed  theDashboardIsAPage
      passed  anInvalidCustomerBreaksThreeRules
      passed  theTestsRunInEnglish
      passed  anUploadAddsTheGoodRowAndNamesTheRest
      passed  shutdownIsNotAGet
      passed  customersAreJson
      passed  theFormIsAPage
      passed  aNameNobodyHasIsAProblemDetail
      passed  aFailingRepositoryLeavesNoStatus
      passed  theSliceLeavesTheDatabaseOut
      passed  sixtyOneSpacesBreakBothRules
      passed  anInvalidCustomerInGerman
      passed  aSixtyOneLetterNameIsRefused
    the fork's locale, read from the reports' properties: user.language en · user.country US · the same in every report: yes
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
  Surefire's reports, tiffinbox-web/target/surefire-reports-it:
    TEST-com.tiffinbox.CustomerEntityRepositoryIT.xml: tests 3 · failures 0 · errors 0 · skipped 0
      passed  theMigrationsAreTheSchema
      passed  theDashboardReadIsOneStatementHoweverManyCustomers
      passed  theCustomersComeTenAtATimeByKeyset
    TEST-com.tiffinbox.jdbc.CustomerAggregatesIT.xml: tests 2 · failures 0 · errors 0 · skipped 0
      passed  theSliceStartsTheJdbcLayerAndTheFixtureIsHere
      passed  theFixtureRunsAgainAndTheFirstOneIsGone
    TEST-com.tiffinbox.web.ElasticsearchIT.xml: tests 1 · failures 0 · errors 0 · skipped 0
      passed  vegFindsTheVegetarianDishAloneWithTheDishAnalyzer
    TEST-com.tiffinbox.web.MongoDatastoreIT.xml: tests 3 · failures 0 · errors 0 · skipped 0
      passed  theKeyMakesTheIndexOnCustomerAndTheFindWalksIt
      passed  theDerivedFinderReadsTheCopiedOrdersOfOneMealType
      passed  aDayOfTheMenuIsOneDocumentWithItsItemsInside
    TEST-com.tiffinbox.web.RedisDatastoreIT.xml: tests 3 · failures 0 · errors 0 · skipped 0
      passed  theLeaderboardIsASortedSetRedisReadsByName
      passed  theKitchenOrdersAreHashesAndTheirIndexSetsRedisReadsByName
      passed  aStoredCustomerIsOneStreamEntryRedisReadsInTheOrderWritten
    the fork's locale, read from the reports' properties: user.language en · user.country US · the same in every report: yes
    in all: 5 reports · tests 12 · failures 0 · errors 0 · skipped 0
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  Surefire's Results line: Tests run: 12, Failures: 0, Errors: 0, Skipped: 0
  ES IT the container's port bindings (Docker's own record): [127.0.0.1:20606->9200/tcp]
  ES IT the container's environment, as run (PATH and HOSTNAME left out): [ELASTIC_CONTAINER=true, ELASTIC_PASSWORD=changeme, ES_JAVA_OPTS=-Xms512m -Xmx512m, SHELL=/bin/bash, cluster.routing.allocation.disk.threshold_enabled=false, container=oci, discovery.type=single-node, ingest.geoip.downloader.enabled=false, xpack.inference.elastic.authorization.enabled=false, xpack.ml.enabled=false, xpack.security.enabled=false]
  ES IT the server's version (the client's info()): 9.4.8
  ES IT heap_max_in_bytes (the client's nodes info, jvm): 536870912
  ES IT Dishes.findByName("veg") of three saved: [Vegetarian Lunch Box]
  ES IT _analyze on dishes, analyzer dish, "Vegetarian Lunch Box" (the client's): [vegetarian, veg, lunch, box]
  the verify log's Elasticsearch repository line (the slice's scan): (x1) Found 1 Elasticsearch repository interface
  the verify log: 'Creating container for image' 5 · 'Pulling' 0 · lines naming docker compose 0 · Testcontainers containers after it: 0
  Testcontainers' own ElasticsearchContainer, read off its jar (unzip -p; its constants by the class file's strings): the memory file elasticsearch-default-memory-vm.options -> -Xms2147483648 -Xmx2147483648 -Dingest.geoip.downloader.enabled.default=false · the class file's strings, each present or not: ELASTIC_PASSWORD yes · changeme yes · discovery.type yes · single-node yes · cluster.routing.allocation.disk.threshold_enabled yes · xpack.security.enabled yes
-- the jar's libraries (ls lib | wc -l), before/ and after/, and the jars after/ gained or lost (comm, by name):
  before/: 129 libraries
  after/: 146 libraries
  gained: 17 - elasticsearch-java-9.4.8.jar elasticsearch-rest5-client-9.4.8.jar httpclient5-5.6.5.jar httpcore5-5.4.4.jar httpcore5-h2-5.4.4.jar jackson-core-2.21.7.jar jackson-databind-2.21.7.jar jakarta.json-api-2.1.3.jar jsr305-3.0.2.jar opentelemetry-api-1.62.0.jar opentelemetry-common-1.62.0.jar opentelemetry-context-1.62.0.jar opentelemetry-semconv-1.41.1.jar parsson-1.1.9.jar spring-boot-data-elasticsearch-4.1.2.jar spring-boot-elasticsearch-4.1.2.jar spring-data-elasticsearch-6.1.2.jar · lost: 0
  the Jackson jars in after/'s lib: jackson-annotations-2.21.jar jackson-core-2.21.7.jar jackson-core-3.1.7.jar jackson-databind-2.21.7.jar jackson-databind-3.1.7.jar spring-boot-jackson-4.1.2.jar · in before/'s: jackson-annotations-2.21.jar jackson-core-3.1.7.jar jackson-databind-3.1.7.jar spring-boot-jackson-4.1.2.jar
  the version lines off the jar names: elasticsearch-java-9.4.8.jar elasticsearch-rest5-client-9.4.8.jar hibernate-core-7.4.13.Final.jar spring-boot-4.1.2.jar spring-data-elasticsearch-6.1.2.jar
  Boot's own metadata for the key the receipt sets (spring-boot-elasticsearch-4.1.2.jar's spring-configuration-metadata.json): management.health.elasticsearch.enabled java.lang.Boolean default true · spring.elasticsearch.uris java.util.List<java.lang.String> default ["http://localhost:9200"]
-- after/ under the profile dev, on PostgreSQL + Redis + MongoDB + Elasticsearch (the four containers, by the digest), a fresh database, an emptied Redis, a fresh MongoDB, Compose off; the index dishes removed first (curl DELETE), so the start meets none:
  curl DELETE /dishes on 20604, then _cat/indices dishes* -> none
  the overrides: --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20602 --spring.mongodb.uri=mongodb://127.0.0.1:20603/tiffinbox --logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE --spring.elasticsearch.uris=http://127.0.0.1:20604 --management.endpoints.web.exposure.include=health,prometheus,beans (the datasource from the config tree, the password never on a command line; /actuator/beans for this run only)
  redis-cli FLUSHALL (the unit's Redis) -> OK
  a fresh database on c8u21-pg: u21anchor (psql) · its URL in the config tree (0600, never printed)
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20600 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20602 --spring.mongodb.uri=mongodb://127.0.0.1:20603/tiffinbox --logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE --spring.elasticsearch.uris=http://127.0.0.1:20604 --management.endpoints.web.exposure.include=health,prometheus,beans
  the start's repository lines, whole, as printed (each counted; the logger's prefix cut, the candidate's advice after its first clause cut):
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
    (x1) Spring Data Elasticsearch - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders
    (x1) Spring Data Elasticsearch - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments
    (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.jdbc.CustomerAggregates
    (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes
    (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders
    (x1) Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments
    (x1) Spring Data MongoDB - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes
    (x1) Spring Data MongoDB - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders
    (x1) Spring Data Reactive Elasticsearch - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.KitchenOrders
    (x1) Spring Data Reactive Elasticsearch - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments
    (x1) Spring Data Redis - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.Dishes
    (x1) Spring Data Redis - Could not safely identify store assignment for repository candidate interface com.tiffinbox.web.OrderDocuments
  of them "Could not safely identify": 12 · naming Dishes: 3 - by module: Spring Data JPA, Spring Data MongoDB, Spring Data Redis
  the start's other lines:
    (x1) HHH000001: Hibernate ORM core version 7.4.13.Final
    (x1) Successfully applied 4 migrations
    (x1) tiffinbox: dishes re-indexed: rows 10 · documents before 0 · documents after 10
    (x1) tiffinbox: kitchen value:  24300
  the client's requests, by its trace logger (co.elastic.clients.transport.rest5_client.low_level.Request at TRACE), method and path, in order, each run of the same counted:
    (x1) HEAD <es>/dishes
    (x1) PUT <es>/dishes
    (x1) POST <es>/dishes/_search
    (x1) POST <es>/dishes/_delete_by_query
    (x1) POST <es>/dishes/_refresh
    (x1) POST <es>/_bulk
    (x1) POST <es>/dishes/_refresh
    (x1) POST <es>/dishes/_search
  the hosts those requests went to: 127.0.0.1:20604
  the index creation, as the client sent it (PUT /dishes, the body whole): {"aliases":{},"mappings":{"properties":{"price":{"type":"integer"},"name":{"type":"text","analyzer":"dish"},"mealType":{"type":"keyword"},"_class":{"type":"keyword","doc_values":false,"index":false}}},"settings":{"index":{"number_of_replicas":"0"},"analysis":{"analyzer":{"dish":{"type":"custom","filter":["lowercase","veg_syn"],"tokenizer":"standard"}},"filter":{"veg_syn":{"type":"synonym","synonyms":["veg, vegetarian"]}}}}}
  the bulk request's action lines (index, one per document): 10 · refresh=false on the bulk: 1 · then POST /dishes/_refresh: 1
  the rows (psql, the unit's PostgreSQL): select count(*) from dish -> 10 · select id, meal_type from dish order by id -> 1 VEG, 2 VEG, 3 VEGAN, 4 VEGAN, 5 NON_VEG, 6 NON_VEG, 7 VEG, 8 VEGAN, 9 NON_VEG, 10 VEG
  curl on 20604: _cat/indices dishes -> dishes green open 1 0 10
  curl: GET /dishes/_mapping -> _class {"doc_values": false, "index": false, "type": "keyword"} · id {"fields": {"keyword": {"ignore_above": 256, "type": "keyword"}}, "type": "text"} · mealType {"type": "keyword"} · name {"analyzer": "dish", "type": "text"} · price {"type": "integer"}
  curl: GET /dishes/_settings (flat; its analysis and replicas) -> index.analysis.analyzer.dish.filter ["lowercase", "veg_syn"] · index.analysis.analyzer.dish.tokenizer "standard" · index.analysis.analyzer.dish.type "custom" · index.analysis.filter.veg_syn.synonyms ["veg, vegetarian"] · index.analysis.filter.veg_syn.type "synonym" · index.number_of_replicas "0" · index.number_of_shards "1"
  curl: GET /dishes/_doc/1 -> _source {"_class": "com.tiffinbox.web.Dish", "id": "1", "mealType": "VEG", "name": "Vegetarian Lunch Box", "price": 110}
  curl: POST /dishes/_analyze {analyzer dish, "Vegetarian Lunch Box"} -> 4 [vegetarian, veg, lunch, box]
  curl: POST /dishes/_search match name veg -> 1 [1] · match name vegetarian -> 1 [1]
  GET /dishes/search?q=veg (TiffinBox) -> 200 [{"id":"1","name":"Vegetarian Lunch Box"}] · q=vegetarian -> 200 [{"id":"1","name":"Vegetarian Lunch Box"}]
  the requests the finder sent for q=veg, by the client's trace logger (the two, whole bodies): 
    curl -iX POST '<es>/dishes/_search?search_type=query_then_fetch&typed_keys=true' -d '{"_source":false,"from":0,"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":0,"track_scores":false,"track_total_hits":2147483647,"version":true}'
    curl -iX POST '<es>/dishes/_search?search_type=query_then_fetch&typed_keys=true' -d '{"from":0,"query":{"bool":{"must":[{"query_string":{"default_operator":"and","fields":["name"],"query":"veg"}}]}},"size":1,"track_scores":false,"version":true}'
  GET /revenue/by-customer -> 200 [{"customer":"Sunil","total":9000},{"customer":"Ravi","total":7200},{"customer":"Meera","total":4500},{"customer":"Priya","total":3600}]
  GET /revenue -> 200 {"monthRevenue":24300}
  GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300}
  GET /menu/day-19 -> 200 {"id":"day-19","items":[{"mealType":"VEG","name":"Vegetable …
  GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
  GET /dashboard -> 200
  /actuator/beans (this run's override): dishes 2 · dishSearch 1 · dishEntityRepository 1 · elasticsearchClient 2 · Spring MVC's JSON converters, by their beans' types: org.springframework.boot.http.converter.autoconfigure.Jackson2HttpMessageConvertersConfiguration · org.springframework.boot.http.converter.autoconfigure.JacksonHttpMessageConvertersConfiguration · org.springframework.boot.http.converter.autoconfigure.JacksonHttpMessageConvertersConfiguration$JacksonJsonHttpMessageConverterConfiguration · org.springframework.boot.http.converter.autoconfigure.JacksonHttpMessageConvertersConfiguration$JacksonJsonHttpMessageConvertersCustomizer
  the response header of /dishes/search: Content-Type: application/json
  dk stats --no-stream with the four stores alive: read into the receipt's log, never this capture (resident sizes move)
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20600: 0
-- a second dev start of after/ on the same Elasticsearch (a fresh database, an emptied Redis, a fresh MongoDB): the re-index meets the ten documents the first left:
  curl: _cat/indices dishes before it -> dishes green open 1 0 10
  redis-cli FLUSHALL (the unit's Redis) -> OK
  a fresh database on c8u21-pg: u21anchor2 (psql) · its URL in the config tree (0600, never printed)
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20600 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20602 --spring.mongodb.uri=mongodb://127.0.0.1:20603/tiffinbox --logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE --spring.elasticsearch.uris=http://127.0.0.1:20604
  the start's re-index line: dishes re-indexed: rows 10 · documents before 10 · documents after 10
  the client's requests (method and path, in order): (x1) HEAD <es>/dishes · (x1) POST <es>/dishes/_search · (x1) POST <es>/dishes/_delete_by_query · (x1) POST <es>/dishes/_refresh · (x1) POST <es>/_bulk · (x1) POST <es>/dishes/_refresh · (x1) POST <es>/dishes/_search
  curl: _cat/indices dishes after it -> dishes green open 1 0 10 · match name veg -> 1 [1]
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20600: 0
-- the Compose window: after/ under dev, Boot's Docker Compose support on, the shipped compose.yaml (cmp: after/'s), from .harness/compose-run; no spring.* address key - Boot hands them over:
  before it: listening on 18881-18884 0 · tiffinbox-dev volumes 0 · tiffinbox-dev networks 0 · volumes 318 (the machine's 315 + the unit's containers') · the four tags present, on the digests (checked at the start)
$ cd .harness/compose-run && DOCKER_HOST=$DH perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "<after/'s classes>:<Maven's runtime class path for after/>" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=20600 --spring.profiles.active=dev --logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE
  the project's containers: tiffinbox-dev-elasticsearch-1 9300/tcp, 127.0.0.1:18884->9200/tcp|tiffinbox-dev-mongo-1 127.0.0.1:18883->27017/tcp|tiffinbox-dev-postgres-1 127.0.0.1:18881->5432/tcp|tiffinbox-dev-redis-1 127.0.0.1:18882->6379/tcp
  the elasticsearch service's container: its Mounts: none · the mongo service's: volume /data/configdb · volume /data/db · volumes now 321
  the start's lines: 1 Successfully applied 4 migrations|1 tiffinbox: dishes re-indexed: rows 10 · documents before 0 · documents after 10|1 tiffinbox: kitchen value:  24300
  the hosts the client's requests went to (its trace logger): 127.0.0.1:18884 · the Compose service's own published port (dk port): 9200/tcp -> 127.0.0.1:18884
  curl on 18884 (the elasticsearch service): _cat/indices dishes -> dishes green open 1 0 10 · match name veg -> 1 [1]
  GET /dishes/search?q=veg (TiffinBox) -> 200 [{"id":"1","name":"Vegetarian Lunch Box"}]
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20600: 0
  after TiffinBox stopped (Boot's own compose stop): the project's containers tiffinbox-dev-elasticsearch-1 exited|tiffinbox-dev-mongo-1 exited|tiffinbox-dev-postgres-1 exited|tiffinbox-dev-redis-1 exited · volumes 321
$ cd .harness/compose-run && docker -H "$DH" compose -p tiffinbox-dev down
  then: the project's containers 0 · its networks 0 · volumes 321 · tiffinbox-dev volumes by name: tiffinbox-dev_data · the mongo service's two: present present
$ cd .harness/compose-run && docker -H "$DH" compose -p tiffinbox-dev down -v
  then: volumes 320 · tiffinbox-dev volumes by name: 0 · the mongo service's two: present present
  the receipt removes the mongo service's two by the names its container listed (dk volume rm): volumes 318 = before the window · listening on 18881-18884: 0
```

The client created the index at the start, through the repository's mapping, with the `@Setting` analyzer: the `PUT /dishes` line is
its own request, the body whole. The finder `findByName` sends a `query_string` on `name` — twice, a count and then the page — and
Elasticsearch analyses its word with the field's analyzer before it looks it up. The Compose window runs Boot's Docker Compose support on
the shipped file: four services, every request of the client to `127.0.0.1:18884`, the address Boot's factory read off the service;
`ELASTIC_PASSWORD` is not set and not needed with security off. Its volumes go as `c8-unit18` measured: `stop`, then `down`, then
`down -v`, then the mongo service's two by name; Elasticsearch's service holds none. The four stores' resident sizes, read by `dk stats` in each run of `anchor`, are in the runs of record below.

### 3 · tokens — what the index stores, and the exact-match side (S8.78)

```text
-- tokens: the analyzers, by curl on 20604 (the unit's Elasticsearch, the shipped index dishes that anchor's start left):
  POST /_analyze {analyzer standard, "Vegetarian Lunch Box"} -> 3 [vegetarian, lunch, box]
  POST /dishes/_analyze {analyzer dish, "Vegetarian Lunch Box"} -> 4 [vegetarian, veg, lunch, box]
  POST /dishes/_analyze {field name, "veg"} (the field's own analyzer, at search) -> 2 [veg, vegetarian]
  the shipped mapping's fields (no keyword sub-field on name): _class keyword · id text fields keyword · mealType keyword · name text · price integer
  term name (text) "Vegetarian Lunch Box" -> 0 [] · term name "vegetarian" -> 1 [1]
  term mealType (keyword) "VEG" -> 4 [1, 10, 2, 7] · term mealType "veg" -> 0 []
  the ids' rows (V4__dish.sql's order): 1 VEG Vegetarian Lunch Box · 10 VEG Mixed Vegetable Rice · 2 VEG Vegetable Curry with Rice · 7 VEG Cottage Cheese in Spinach Gravy
  the Java side, the same run: ES IT _analyze on dishes, analyzer dish, "Vegetarian Lunch Box" (the client's): [vegetarian, veg, lunch, box]
```

`term` looks a value up as written, with no analyzer: on the text field `name` the whole name is no token, and on the keyword field
`mealType` the value is one token, exactly as stored. The shipped mapping carries no keyword sub-field on `name`, so the exact-match
side is `mealType`'s.

### 4 · nohit — a copy with the standard analyzer: veg finds nothing (the failure receipt; control `vegetarian` and the shipped analyzer)

```text
-- nohit: the labelled copy std (dish-settings.json's analyzer dish without its synonym - the standard tokenizer and lowercase), under dev, on its own Elasticsearch (c8u21-es-std, 127.0.0.1:20605) and the unit's PostgreSQL, Redis and a fresh MongoDB:
  the copy's one change (harness/variants.py std), as its diff:
    -    "analyzer": { "dish": { "type": "custom", "tokenizer": "standard", "filter": ["lowercase", "veg_syn"] } }
    +    "analyzer": { "dish": { "type": "custom", "tokenizer": "standard", "filter": ["lowercase"] } }
  curl DELETE /dishes on 20605, then _cat/indices dishes* -> none
  redis-cli FLUSHALL (the unit's Redis) -> OK
  a fresh database on c8u21-pg: u21std (psql) · its URL in the config tree (0600, never printed)
$ cd .harness/run-std && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../std/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20600 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20602 --spring.mongodb.uri=mongodb://127.0.0.1:20603/tiffinbox --logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE --spring.elasticsearch.uris=http://127.0.0.1:20605
  the copy's start: Successfully applied 4 migrations · dishes re-indexed: rows 10 · documents before 0 · documents after 10 · the hosts its client's requests went to: 127.0.0.1:20605
  curl on 20605: _cat/indices dishes -> dishes green open 1 0 10 · _analyze {analyzer dish, "Vegetarian Lunch Box"} -> 3 [vegetarian, lunch, box] · beside _analyze {analyzer standard} -> 3 [vegetarian, lunch, box]
  GET /dishes/search?q=veg (the copy's TiffinBox) -> 200 [] · its JVM still running: yes · lines naming an Exception in its log: 0
  GET /dishes/search?q=vegetarian (the control, the same JVM) -> 200 [{"id":"1","name":"Vegetarian Lunch Box"}]
  curl on 20605: match name veg -> 0 [] · curl's exit 0
  curl on 20605: match name vegetarian -> 1 [1]
  curl on 20605: prefix name veg -> 4 [1, 10, 2, 8] · the ids' rows: 1 VEG Vegetarian Lunch Box · 10 VEG Mixed Vegetable Rice · 2 VEG Vegetable Curry with Rice · 8 VEGAN Vegan Lunch Box
  the shipped analyzer, the same run - curl on 20604: match name veg -> 1 [1]
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20600: 0
```

R.312's negation: the copy's route answers `200` and an empty list, no exception, the JVM running, curl's exit `0` — a search that
finds nothing is an answer, not an error. The control in the same JVM, `vegetarian`, finds the vegetarian box; the shipped analyzer, in
the same run, finds the vegetarian box for `veg`.

### 5 · sayso — the ways to say so, each with what it also finds (S8.79, S8.80, S8.95)

```text
-- sayso: the ways to say so, on the copy's Elasticsearch (20605): its index dishes (the standard analyzer's tokens), and scratch indices of the same ten documents (V4__dish.sql's rows, ids 1-10), each named, each removed at the end:
  dishes (standard): prefix name veg -> 4 [1, 10, 2, 8] · the ids' rows: 1 VEG Vegetarian Lunch Box · 10 VEG Mixed Vegetable Rice · 2 VEG Vegetable Curry with Rice · 8 VEGAN Vegan Lunch Box
  dishes (standard): match_phrase_prefix name veg -> 4 [1, 10, 2, 8]
  dishes (standard): wildcard name veg* -> 4 [1, 10, 2, 8]
  dishes (standard): match name veg fuzziness AUTO -> 0 []
  dishes_en (name analysed by english, number_of_replicas 0): PUT -> acknowledged true · bulk -> errors false · items 10
    _analyze {analyzer english, "vegetarian vegetable vegan veg"} -> 4 [vegetarian, veget, vegan, veg] · match name veg -> 0 []
  dishes_ngram (name analysed by edge_ngram 2-15 on letters at index time, standard at search, number_of_replicas 0): PUT -> acknowledged true · bulk -> errors false · items 10
    _analyze {analyzer autocomplete, "Vegetarian"} -> 9 [ve, veg, vege, veget, vegeta, vegetar, vegetari, vegetaria, vegetarian] · match name veg -> 4 [1, 10, 2, 8] · the ids' rows: 1 VEG Vegetarian Lunch Box · 10 VEG Mixed Vegetable Rice · 2 VEG Vegetable Curry with Rice · 8 VEGAN Vegan Lunch Box
  dishes_syn (after/'s dish-settings.json as its settings, read off the file; name analysed by dish): PUT -> acknowledged true · bulk -> errors false · items 10
    _analyze {analyzer dish, "Vegetarian Lunch Box"} -> 4 [vegetarian, veg, lunch, box] · match name veg -> 1 [1] · the ids' rows: 1 VEG Vegetarian Lunch Box
  dishes_default (no settings: the default replica, one): PUT -> acknowledged true
  _cat/indices on 20605 (index, health, status, pri, rep, docs.count): dishes green open 1 0 10 · dishes_default yellow open 1 1 0 · dishes_en green open 1 0 10 · dishes_ngram green open 1 0 10 · dishes_syn green open 1 0 10
  _cluster/health on 20605 with dishes_default there: status yellow · unassigned_shards 1
  DELETE /dishes_en -> acknowledged true
  DELETE /dishes_ngram -> acknowledged true
  DELETE /dishes_syn -> acknowledged true
  DELETE /dishes_default -> acknowledged true
  _cluster/health on 20605 after: status green · unassigned_shards 0
```

| way (index, analyzer) | what veg finds | what it also finds |
|---|---|---|
| `match` (`dishes`, the copy's standard steps) | `0 []` | nothing |
| `prefix` (`dishes`, the copy's) | `4 [1, 10, 2, 8]` | `10` Mixed Vegetable Rice (VEG); `2` Vegetable Curry with Rice (VEG); `8` Vegan Lunch Box (VEGAN) |
| `match_phrase_prefix` (`dishes`, the copy's) | `4 [1, 10, 2, 8]` | `10` Mixed Vegetable Rice (VEG); `2` Vegetable Curry with Rice (VEG); `8` Vegan Lunch Box (VEGAN) |
| `wildcard veg*` (`dishes`, the copy's) | `4 [1, 10, 2, 8]` | `10` Mixed Vegetable Rice (VEG); `2` Vegetable Curry with Rice (VEG); `8` Vegan Lunch Box (VEGAN) |
| `fuzziness: AUTO` (`dishes`, the copy's) | `0 []` | nothing |
| `fuzziness: 2` (`dishes`, the copy's) | `2 [6, 8]` | `6` Egg Fried Rice (NON_VEG); `8` Vegan Lunch Box (VEGAN) |
| `match` (`dishes_en`, `english`) | `0 []` | nothing |
| `match` (`dishes_ngram`, `edge_ngram` at index time) | `4 [1, 10, 2, 8]` | `10` Mixed Vegetable Rice (VEG); `2` Vegetable Curry with Rice (VEG); `8` Vegan Lunch Box (VEGAN) |
| `match` (`dishes_syn`, the shipped `dish-settings.json`) | `1 [1]` | nothing else |

The sizes `_cat/indices` prints are left out of the capture: they move between runs. `yellow` is the default index's one replica with
nowhere to go on one node; `green` is `number_of_replicas: 0`, the shipped setting.

### 6 · fuzzy — the near word that is not the word (the second failure receipt)

```text
-- fuzzy: fuzziness on the copy's index dishes (20605, the standard analyzer's tokens), beside the shipped analyzer on 20604:
  match name veg fuzziness 2 -> 2 [6, 8] · the ids' rows: 6 NON_VEG Egg Fried Rice · 8 VEGAN Vegan Lunch Box
  match name veg fuzziness AUTO -> 0 []
  _analyze standard "Egg Fried Rice" -> 3 [egg, fried, rice] · "Vegan Lunch Box" -> 3 [vegan, lunch, box]
  the shipped analyzer (20604, dishes): match name veg -> 1 [1] · the ids' rows: 1 VEG Vegetarian Lunch Box
```

### 7 · late — a synonym after the documents are in

```text
-- late: a synonym after the documents are in - a scratch index dishes_late on the copy's Elasticsearch (20605), name analysed by the default (standard), the ten documents:
  PUT /dishes_late -> acknowledged true · bulk -> errors false · items 10 · match name veg -> 0 []
  POST /dishes_late/_close -> acknowledged true
  PUT /dishes_late/_settings {the analyzer dish: standard, lowercase, the synonym veg, vegetarian} -> acknowledged true
  POST /dishes_late/_open -> acknowledged true
  PUT /dishes_late/_mapping {name: text, analyzer dish} -> error illegal_argument_exception: Mapper for [name] conflicts with existing mapper: Cannot update parameter [analyzer] from [default] to [dish] · curl's exit 0 · its HTTP status 400
  PUT /dishes_late/_mapping {name: text, search_analyzer dish} -> acknowledged true
  GET /dishes_late/_mapping, name -> {"analyzer": "default", "search_analyzer": "dish", "type": "text"}
  match name veg, no document indexed again -> 1 [1] · _analyze {field name, "veg"} -> 1 [veg] · docs.count 10
  DELETE /dishes_late -> acknowledged true
```

A mapped field's analyzer is fixed: the refusal is the store's own answer, `400`, quoted whole, with curl's exit `0`. The search side
can change: `search_analyzer` is accepted, and `veg` finds the vegetarian box with no document indexed again — the synonym applies to the
search's own tokens, and the stored token `vegetarian` matches. The exercise's check reads this side too (RED #14).

### 8 · explain — the score's three factors (the brief's last beat)

```text
-- explain: the score of the vegetarian box (id 1) for match name vegetarian, on the shipped index dishes (20604), read off _explain:
  matched true
  3.026459 weight(Synonym(name:veg name:vegetarian) in 0) [PerFieldSimilarity], result of:
    3.026459 score(freq=2.0), computed as boost * idf * tf from:
      2.2 boost
      2.1282318 idf, computed as log(1 + (N - n + 0.5) / (n + 0.5)) from:
        2 n, number of documents containing term
        20 N, total number of documents with field
      0.6463878 tf, computed as freq / (freq + k1 * (1 - b + b * dl / avgdl)) from:
        2.0 termFreq=2.0
        1.2 k1, term saturation parameter
        0.75 b, length normalization parameter
        3.0 dl, length of field
        3.4 avgdl, average length of field
  _cat/indices dishes (its documents, deleted ones included): 10 20
```

The score is a number `_explain` prints, the product of the three factors beside it; it orders hits, and this unit says nothing more of
it.

### 9 · default — no profile, no Docker: no client, no Elasticsearch line (S8.83; RE-MEASURE 1, 13)

```text
-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), no Elasticsearch, no MongoDB; one JVM; /actuator/beans exposed for this run (a command-line override, the one beside the port):
$ cd .harness/run-h2 && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20600 --management.endpoints.web.exposure.include=health,prometheus,beans
  GET /actuator/health -> 200 {"groups":["liveness","readiness"],"status":"UP"}
  GET /dishes/search?q=veg -> 404 · GET /revenue/by-customer -> 404 · GET /menu/day-19 -> 404 · GET /revenue -> 200 {"monthRevenue":24300} · GET /kitchen -> 200 {"ordersCooked":120,"ordersValue":24300} · GET /dashboard -> 200
  /actuator/beans: dishes 0 · dishSearch 0 · elasticsearchClient 0 · a bean whose type names Elasticsearch 0 · dishEntityRepository 1 · tiffinBoxServer 1
  POST /shutdown (the token on curl's standard input) -> 200 · the JVM's exit 0 · listening on 20600: 0
  its log: lines naming 9200 0 · naming elasticsearch, any case 0 · naming 27017 0 · naming mongo, any case 0 · Flyway: Successfully applied 4 migrations on Database: jdbc:h2:mem:<name> (H2 2.5 · its repository lines: Found 2 JPA repository interfaces|Found 1 JDBC repository interface
-- the refused shape, labelled: the copy healthkey (application.yaml without the seven Elasticsearch names, management.health.elasticsearch.enabled: false instead), the default run again:
  the copy's change (harness/variants.py healthkey), as its diff:
    -      - org.springframework.boot.elasticsearch.autoconfigure.ElasticsearchClientAutoConfiguration
    -      - org.springframework.boot.elasticsearch.autoconfigure.ElasticsearchRestClientAutoConfiguration
    -      - org.springframework.boot.elasticsearch.autoconfigure.health.ElasticsearchRestHealthContributorAutoConfiguration
    -      - org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchAutoConfiguration
    -      - org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchReactiveRepositoriesAutoConfiguration
    -      - org.springframework.boot.data.elasticsearch.autoconfigure.DataElasticsearchRepositoriesAutoConfiguration
    -      - org.springframework.boot.data.elasticsearch.autoconfigure.health.DataElasticsearchReactiveHealthContributorAutoConfiguration
    +    elasticsearch:
    +      enabled: false
$ cd .harness/run-hk && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../healthkey/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20600 
  readiness never answered 200 · the JVM's exit 1 · listening on 20600: 0
  its log: lines naming 9200 4 · naming elasticsearch, any case 28 · its repository lines naming Elasticsearch: Found 0 Reactive Elasticsearch repository interfaces · Found 1 Elasticsearch repository interface
  the failure's own lines, as printed (the bean and the cause, each once):
    DataAccessResourceFailureException: Connect to http://localhost:9200 [localhost/127.0.0.1, localhost/0:0:0:0:0:0:0:1] failed: Connection refused (connect failed)
    Error creating bean with name 'dishes'
    Error creating bean with name 'tiffinBoxServer'
-- the 18 under mvn -o package with Docker at nothing (anchor's tests, the same run's package log):
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

### 10 · absent — under dev with Elasticsearch absent: the start stops (S8.84, the third failure receipt)

```text
-- absent: after/ under dev with PostgreSQL, Redis and a fresh MongoDB up and Elasticsearch absent - spring.elasticsearch.uris on 127.0.0.1:20609, where nothing listens:
  listening on 20609: 0
  redis-cli FLUSHALL (the unit's Redis) -> OK
  a fresh database on c8u21-pg: u21absent (psql) · its URL in the config tree (0600, never printed)
$ cd .harness/run-pg && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20600 --spring.profiles.active=dev --spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20602 --spring.mongodb.uri=mongodb://127.0.0.1:20603/tiffinbox --logging.level.co.elastic.clients.transport.rest5_client.low_level.Request=TRACE --spring.elasticsearch.uris=http://127.0.0.1:20609
  readiness never answered 200 · the JVM's exit 1 · listening on 20600: 0
  the failure, as printed (its first lines naming the bean and the cause; the logger's prefix cut):
    Connection refused (connect failed)
    DataAccessResourceFailureException: Connect to http://127.0.0.1:20609 [/127.0.0.1] failed: Connection refused (connect failed)
    Error creating bean with name 'dishSearch' defined in URL [jar
    Error creating bean with name 'dishes' defined in com.tiffinbox.web.Dishes defined in @EnableElasticsearchRepositories declared on DataElasticsearchRepositoriesRegistrar.EnableElasticsearchRepositoriesConfiguration
    Failed to instantiate [org.springframework.data.elasticsearch.repository.support.SimpleElasticsearchRepository]: Constructor threw exception
  its log: lines naming 20609 5 · the hosts its client tried (Connect to ...): Connect to http://127.0.0.1:20609 · 'dishes re-indexed' 0 · Flyway: Successfully applied 4 migrations
```

R.312's negation with its control: the same start with Elasticsearch on `20604` is `anchor`'s. The repository's constructor reaches the
store for its index, so the context fails while the beans are made — Redis's shape in `c8-unit15`, not MongoDB's in `c8-unit18`.

### 11 · seven — the comparison set on before/ and after/ (R.363)

```text
-- the seven: before/'s jar, java -jar, H2 in memory (a fresh JVM), port 20607:
$ cd .harness/before && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20607
  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /dishes/search?q=veg -> 404 · listens on: 127.0.0.1:20607
$ $CURLSET 20607 .harness/before/secrets/tiffinbox/shutdown-token
  GET /revenue: /revenue    -> 200 application/json  {"monthRevenue":24300}
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20607 now: 0
-- the seven: after/'s jar, java -jar, H2 in memory (a fresh JVM), port 20600:
$ cd .harness/after && perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20600
  GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /dishes/search?q=veg -> 404 · listens on: 127.0.0.1:20600
$ $CURLSET 20600 .harness/after/secrets/tiffinbox/shutdown-token
  GET /revenue: /revenue    -> 200 application/json  {"monthRevenue":24300}
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20600 now: 0
  the seven, after/ against before/: lines that differ: 0
```

`before/` runs on `20607`: the slot map gives `20605` to the copy's Elasticsearch and `20606` to the IT's binding. The V4 rows change no
route of the seven: the hash is the one `c7-unit31`'s receipt names, on both trees.

### 12 · sockets — the connection witness at the end of the receipt (S8.92)

```text
-- sockets: c8u21-es (the unit's Elasticsearch, alive since image), its /proc/net/tcp, tcp6, udp and udp6 read by cat at the end of the receipt (dk exec - a file, never a shell):
  its interfaces (/proc/net/dev): eth0,lo
  the sockets: listening (TCP) on 9200, 9300 · connections from another local port (outbound): 0 · UDP sockets: 0
```

The unit's Elasticsearch container, alive from `image` to the end: its interfaces, and its sockets read at the end — no outbound TCP or
UDP socket in the samples. A sampled table can miss a socket that opens and closes between two reads; that is the witness's limit.

### 13 · exercise — run as written, in one shell, bash then zsh (R.196, S8.76)

```text
exercise/README.md's 8 lines, then exercise/SOLUTION.md's, as written, one after the other in ONE env -i shell (HOME and the PATH this script was started with), started in this folder:
the solution's line that differs:
  $ perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -cp "$EX/x/tiffinbox-web-1.0.0.jar:$EX/x/lib/*" exercise/DishLab.java exercise/dish-settings.json > "$EX/run.log" 2>&1; grep -E '^(index dishes|dishes indexed|match |prefix )' "$EX/run.log"
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
    built: 1 jar
    index dishes before: absent · settings dish-settings-standard.json
    dishes indexed: 10 of 10 rows
    match name veg: 0 []
    prefix name veg: 4 [1, 10, 2, 8]
    check: match name veg -> 0 [] · name's search-side analyzer: dish · its tokens for vegetarian: [vegetarian] · solved: no
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    index dishes before: absent · settings dish-settings.json
    dishes indexed: 10 of 10 rows
    match name veg: 1 [1]
    prefix name veg: 4 [1, 10, 2, 8]
    check: match name veg -> 1 [1] · name's search-side analyzer: dish · its tokens for vegetarian: [vegetarian, veg] · solved: yes
  the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20608 afterwards: 0 · the container c8u21-es-ex afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: c7d9fae1 (at the start: c7d9fae1)
in zsh (/bin/zsh -f) - the README's lines, the block's exit 0:
    built: 1 jar
    index dishes before: absent · settings dish-settings-standard.json
    dishes indexed: 10 of 10 rows
    match name veg: 0 []
    prefix name veg: 4 [1, 10, 2, 8]
    check: match name veg -> 0 [] · name's search-side analyzer: dish · its tokens for vegetarian: [vegetarian] · solved: no
  then the solution's lines, in the same shell - the block's exit 0:
    built: 1 jar
    index dishes before: absent · settings dish-settings.json
    dishes indexed: 10 of 10 rows
    match name veg: 1 [1]
    prefix name veg: 4 [1, 10, 2, 8]
    check: match name veg -> 1 [1] · name's search-side analyzer: dish · its tokens for vegetarian: [vegetarian, veg] · solved: yes
  the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20608 afterwards: 0 · the container c8u21-es-ex afterwards: 0 · volumes 315 (before the shell: 315) · java processes of the exercise: 0 · images afterwards: c7d9fae1 (at the start: c7d9fae1)
```

## Which store, which profile, which tree

- **PostgreSQL's rows** (`c8u21-pg`, `20601`, a fresh database per dev start) are the source: ten dish rows by Flyway's V4 on 21/after.
- **Elasticsearch's index `dishes`** on `c8u21-es` (`20604`) is the copy the dev start of 21/after rebuilds from those rows, analysed by
  `dish`: `anchor`, `tokens`, `explain`, the shipped lines of `nohit` and `fuzzy`. On `18884` the same copy, rebuilt in Compose's window.
- **A copy with the standard analyzer** (`c8u21-es-std`, `20605`): the copy `std`'s own dev start filled its index `dishes`; `sayso`,
  `fuzzy` and `late` add scratch indices there, each named, each removed.
- **The image's default on this VM**: `c8u21-es-default`, once per run of `image`, removed before the others start.
- **21/after's default run** (H2, no Docker): `default`, the seven; `before/`'s default run for the seven too.
- The IT's Elasticsearch (Testcontainers', `127.0.0.1:20606`) holds its own three documents; the exercise's (`20608`) its own ten.

## Refused, named

- Another analyzer in the anchor (the standard-analyzer index is a labelled copy on its own container); the health key alone (the
  default run stops on `Dishes`' constructor); `icu`; the client 9.5.6; the reactive starter; OpenSearch.
- curl inside the container; a port on every interface (Testcontainers' default, refused by the IT's own binding); `--pull` other than
  never in this receipt.
- The readings `harness/s821.py` refuses, each shown failing on a plant in its self-test (XFAM_S4B, XU21, the HINGLISH list): the
  analyzer left unnamed when veg is said to find the vegetarian box; a store's answer without its index and analyzer; the score called a
  quality; a verdict beside any store; the network said in any form but the socket witness's; security off called anything
  but off; a wait word, or a time for the start - the start's own lines are masked or cut.

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s4b/` (7,265 files; `m2-seed-c8-s4/` is Part A's
and is not used), made with `cp -cR`; every build is `mvn -o` with `maven.repo.local` an absolute path to it, and the receipt asserts its
file count unchanged after every Maven run. The four images are on the machine by their digests before the run; nothing is pulled. No
network is used but the loopback ports and the Docker socket.

## The folders, the harness and the ports

- `harness/s821.py` — the prose gate (the family base byte for byte, XFAM_S4B and TIMEPAT_S4B, XU21, HINGLISH read at run time),
  `harness/chk21.py` — the checks, `harness/tree21.py`, `harness/variants.py` (`std`, `healthkey`, and the plants `nolists`, `nobind`),
  `harness/dur8.py`, `surefire.py`, `logback.xml` as shipped (cmp asserted). The client's trace logger is set on each JVM's command line
  (`--logging.level.…Request=TRACE`), not by a file.
- Ports: `20600` TiffinBox (`after/` and the two copies) · `20601` PostgreSQL `c8u21-pg` · `20602` Redis `c8u21-redis` · `20603`
MongoDB `c8u21-mongo`, a standalone, a fresh container for every dev start · `20604` Elasticsearch `c8u21-es` · `20605` the copy's
Elasticsearch `c8u21-es-std` · `20606` the IT's pinned binding, bound by Testcontainers during `mvn verify` alone · `20607` TiffinBox
`before/` for the seven · `20608` the exercise's Elasticsearch `c8u21-es-ex` · `20609` never bound (Elasticsearch absent). `20578` is the
Mongo IT's pinned binding (during `mvn verify`); `18881`-`18884` are bound only inside `anchor`'s Compose window. At most two Elasticsearch
containers are alive together: `c8u21-es` beside the IT's, Compose's or the copy's; the labelled default container runs alone, first.

## Masks, filters and hygiene — every one, declared

- The folders and the home, the user's name, a pid: `…`, `~`, `<user>`, `<n>`.
- Spring's start lines (`in <t> (process running for <t>)`), Surefire's `Time elapsed`, Flyway's `execution time`, Spring Data's
  `scanning in`, the context's `initialization completed in`, Testcontainers' `started in PT…`, Maven's `Total time`: masked by `mask()`,
  its self-test planted first.
- Elasticsearch's `took`, `took[…]` and `@timestamp`: masked by `mask()` (TIMEPAT_S4B's form); the receipt prints `_search` answers as
  counts and ids, never the whole body, and never `timed_out`.
- Left out of every capture, by the receipt's own printing: `_cat/indices`' sizes (they move), `index.creation_date` and `index.uuid`
  (`_settings` printed for its analysis and replicas only), the node's id and `cluster_uuid` (`GET /` prints its name, the fixed
  `--hostname`), the client's trace timestamps (each request line is cut to its method, path and body), `dk stats`' resident sizes.
- Hygiene, asserted over every capture: no absolute path, no time, no `took`, no `@timestamp`, no client wait key, no log time, no
  stack frame, no H2 database name, no raw port of a Testcontainers mapping, no all-interfaces binding, no token, no password; dur8 0.

## Interrupted

The receipt's traps are U20's, extended: on `INT` or `TERM` it kills its JVMs and Maven by their process trees, sweeps its process
group by name, removes Testcontainers' containers by their label, runs the Compose window's `down -v` and removes the mongo service's
two volumes by name, removes every container of this unit by name with `rm -fv` (the four stores, the copy's, the default heap's and
the exercise's Elasticsearch), and removes the partial captures. Measured here, SIGINT to the receipt's whole process group as a terminal's
Ctrl-C delivers it (the receipt started with SIGINT reset to its default, `perl -e '$SIG{INT}="DEFAULT"; setpgrp(0,0); exec …'`, R.410):
- **mid-build** (Maven running in `.harness/before`): exit `130`; no JVM; no container of this unit; Testcontainers' `0`; volumes and images
  unchanged; `20578`, `20600`-`20609`, `18881`-`18884` free; `.r-lock` gone; no partial capture; the captures unchanged.
- **mid-exercise, the fresh Elasticsearch `c8u21-es-ex` alive**: exit `130`; the container removed with its volumes (`rm -fv` by name in the
  trap); the rest as above.
- **mid-verify, Testcontainers' containers alive**: SIGINT when Docker's own list showed the Elasticsearch IT's container
  (`9300/tcp, 127.0.0.1:20606->9200/tcp`): exit `130`; Testcontainers' containers `0`, read twice (once the receipt had exited, and again
  after a pause), no JVM, volumes and images unchanged, the ports free.
- A first attempt started the receipt from a non-interactive shell's background job, where SIGINT arrives ignored: bash cannot trap it,
  Maven (its SIGINT reset to the default by its `perl` alarm) died alone, and the receipt stopped on its own build check, exit `1` -
  everything cleaned by the EXIT trap all the same. Not a receipt fault; the measured runs above reset SIGINT first.
- **Not done** (the cap): mid-`anchor`'s dev start on the four stores, mid-Compose window, mid-`sayso` with the copy's container alive.

- **2026-11-23, the finishing agent - the three points left open, each after the runs of record, each the same way** (`perl -e
  '$SIG{INT}="DEFAULT"; setpgrp(0,0); exec @ARGV' ./receipts.sh`, SIGINT to the receipt's process group by the driver
  `sigint.sh` in the agent's scratch folder, the proof read three moments later):
  - **mid-`anchor`'s dev start on the four stores** (`c8u21-pg`, `c8u21-redis`, `c8u21-mongo`, `c8u21-es` running, TiffinBox's JVM
    started and not yet up; volumes 318): exit `130`; java `0`; no container of this unit, Compose's or Testcontainers' (`dk ps -a`:
    `open-webui` alone); volumes `315`, images `9`; `20578`, `20600`-`20609`, `18881`-`18884` free; `.r-lock` gone; no partial capture;
    the captures unchanged (their md5s compared).
  - **mid-Compose window** (Boot's `compose up` had run: `tiffinbox-dev-postgres-1`, `-redis-1`, `-mongo-1`, `-elasticsearch-1` beside
    the unit's four; TiffinBox's JVM alive; volumes 321): exit `130`; the project down with its network and volumes (`tiffinbox-dev`
    networks `0`, volumes `0`, the mongo service's two anonymous volumes removed by name), volumes `315`; the rest as above.
  - **mid-`sayso`, the copy's container alive** (`c8u21-es-std` on `20605` beside the unit's four stores; `nohit` 3/3 = published just
    before; volumes 318): exit `130`; the copy's container removed with its volumes, its scratch indices with it; the rest as above.
## The ledger rows this unit pays

C8-15's search half ("Document and search", paid across `c8-unit18` to unit 22): this unit pays its first search part - an index
of the dish rows, the analyzer that writes its tokens, and what each way to search for `veg` finds, measured. The contract's Known
machine item for Elasticsearch is paid here, measured on this machine: one node (`discovery.type=single-node`), the memory (the image's
default heap beside the pinned one), `vm.max_map_count` (no change on the VM), security off on the loopback port alone, and the server's
version against the client's (`9.4.8` both).

## RE-MEASURE — the plan's items this unit settles

- **1** (the exclude, flag 7): the seven names off the jars, the default run `200` with no line naming `9200`, Elasticsearch, `27017`
  or Mongo, 3/3; the health key alone printed as the refused shape - settled first, above.
- **2** (V4's ten and every number of the brief's unit 21 on the shipped tree): settled first, above; every number equal to the probe's
  except where the shipped shape differs (the shipped mapping has no `name.raw`, so the exact-match side is `mealType`'s).
- **3** (Compose on the shipped file): four services, every request of the client to `127.0.0.1:18884`, `dishes green` and `veg` one
  hit on `18884`, the volume sequence back to the count before the window (`anchor`).
- **4** (the jar and Jackson): the library count read off both jars, Jackson 2's `jackson-databind` 2.21.7 in `after/`'s and not in
  `before/`'s, and Spring MVC's JSON converter Jackson 3's (`JacksonJsonHttpMessageConverter` among the beans, no Jackson 2 converter
  bean) (`anchor`).
- **5** (the IT under dev): `@ActiveProfiles("dev")` clears the exclude in the slice; Compose does not start in a test; `18 + 12` (`anchor`).
- **6** (Docker-free package): the `18` with `DOCKER_HOST` at nothing (`anchor`, `default`).
- **13** (the default run's routes): `/dishes/search`, `/revenue/by-customer`, `/menu/day-19` 404; `/revenue`, `/kitchen`, `/dashboard`
  200 (`default`).
- **14** (the exercise's check reads the search side): `check.sh` reads `search_analyzer`, else `analyzer` (RED #14) - `late` shows the
  route it would accept.
- **15** (the IT's binding and the Mongo IT's): `127.0.0.1:20606->9200/tcp` and `127.0.0.1:20578->27017/tcp` by Docker's own list
  while `verify` ran, both free after; the IT asserts its own binding too (`anchor`).

## Part B moves the anchor next

Unit 22 adds the write path next: `POST /dishes`, the AFTER_COMMIT index sync, the highlight (the Part B plan, its unit 22). This unit's
index is rebuilt by the dev start alone.

## What differed from the brief

- **The slot map** (the prompt's, settled): `20600` TiffinBox, `20601`-`20604` the four stores, `20605` the copy's Elasticsearch,
  `20606` the IT's binding, `20607` `before/` for the seven (the brief's spare slot, since `20605` and `20606` are taken), `20608` the
  exercise, `20609` absent. The brief's port line had `20606`-`20608` spare.
- **The exercise's shape: (A)**, a source-launched program (`exercise/DishLab.java`) on `after/`'s jar, the shipped `Dish` in an index
  it creates with the settings file named on its command line, on a fresh Elasticsearch per half (`20608`): one store for the viewer
  instead of four. Broken = `exercise/dish-settings-standard.json` (the analyzer `dish` with the standard tokenizer and lowercase only),
  solved = `exercise/dish-settings.json`, a byte-for-byte copy of the shipped file (`cmp` asserted). The ten rows are read off
  `after/`'s `V4__dish.sql` at run time. The viewer's lines name the image by its tag and carry no `--pull never` (they may pull; the
  receipt asserts the images unchanged after each shell). A second run in the same shell reuses the jar the first built under
  `.harness/ex` (the README says so): the receipt's bash and zsh shells each build once.
- **The double family test.** `harness/s821.py` carries the harness's family base byte for byte (`chk21.py static` asserts the
  slices equal to `c8-unit18/harness/s818.py`'s, and XU19, XU20 equal to `c8-unit19`'s and `c8-unit20`'s) and adds XFAM_S4B and TIMEPAT_S4B. The
  script stage's amended Part A blocks (`_builders/s818.py`'s 22-family XFAM_S4 and its XEXEMPT_S4) were exec'd out of the builder's
  source, read-only, over this README's parts, the exercise's two files and every line the change added (the new files whole): `943` sentences, `0` of
  them hit by the `22` families. The builder's block, sliced from `XFAM_S4 = {` to its closing brace, hashes `dd535e3b…` here, not the `f865889b…` the
  prompt quotes - the slice boundaries differ, the block is the one the builder holds today; XEXEMPT_S4 only narrows XFAM_S3, which the
  harness's carried `s3` judges, so it adds no hit.
- **XFAM_S4B's "singular time words" member, narrowed by one lookahead** `(?!-)`: as BLUE wrote it, it refused a case s820's
  self-test carries, the course's own cache gloss - the member read the ordinal before a hyphen as a time. With the lookahead that case
  passes, and RED #4's four plants still hit (s821's self-test carries them). Units 22-24 carry the block as written here.
- **No harness JVM.** The brief's captures need none: the Java witnesses are TiffinBox's own route and start line, the client's own
  trace lines, the IT's lines and the exercise's program. `tokens`' Java witness is the IT's `_analyze` line from the same run of record.
- **`late`, `sayso` and `fuzzy` on scratch indices** of the copy's Elasticsearch: `late` needs a field whose analyzer is the default
  (the refusal names `[default]`), so it builds `dishes_late`; the copy's own index `dishes` (its analyzer `dish` with the standard steps)
  serves prefix, wildcard, fuzziness and `nohit`.
- **`sockets`, a thirteenth capture**: the socket list is read at the end of the receipt on the unit's Elasticsearch (alive from
  `image` to the end), as S8.92 asks, rather than inside `image`.
- **The health key alone, each run of `default`** (the prompt said once), **and its reading**: the plan expected health `200` with the
  repository scans' lines; on 21/after the default run with the key alone stops, exit `1` - `Dishes` exists, Boot's Elasticsearch
  repositories build it, and its constructor reaches `localhost` on port `9200` (`DataAccessResourceFailureException`, Connection refused). The
  anchor's `application.yaml` comment says so; the shipped exclude of the seven is the only shape measured to start with no store.
- **RE-MEASURE 1 on 21/after**, not on 20/after plus the starter: 21/after is that tree with the starter and the classes that use it, and
  the shipped list is what the viewer runs.
- **The seven without Hibernate's schema script**: `DishEntity` adds a table, so Course 7's capstone `xcheck.sql` no longer describes
  the mapping; the seven's hash is the comparison here, and Hibernate's `validate` against V4 passes at every start (default, anchor).
- **`id` as a String**: an Elasticsearch document's id is a string; the row's `Long` is written as its decimal string. The ids' order in
  every list is the strings' order (`1, 10, 2, 8`), as the probe's.
- **Prices**: `MenuDay`'s three per meal type (`VEG_PRICE`, `NON_VEG_PRICE`, `VEGAN_PRICE`), not the probe's sketch prices.
- **The trace logger** is set on each JVM's command line, not by a file in `harness/`.
- **2026-11-23, the finishing agent (session 4a171840), an R.250 sentence the hunt missed**: `CustomerEntityRepositoryIT`'s class
  Javadoc still said "Flyway migrates it (V1-V3)" (its method Javadoc and its list were rewritten to V1-V4, the class sentence was
  not). Found by re-running the hunt's `git grep` for `V1-V3` before the commit; noted beside it in `after/` and `c8-tiffinbox` (the
  line "(Course 8, unit 21: V1-V4 - V4__dish.sql.)" under it). A Javadoc line of a test: no jar, no capture moves; the after-tree pin
  moves from `77 d301d035…` to `77 df69d8d9…` (`harness/tree21.py`, re-pinned in `receipts.md5` from that output). The planted-faults
  block below quotes the old pin as the plant runs printed it; it is kept as printed.

- **2026-11-23, the finishing agent, `nohit` drifted on the first run of record** (bash 3.2.57, started 03:35:00 CET, stopped by its own
  check at 03:48: `nohit drifts across 3 runs`). Its fifth line printed the answer of `curl DELETE /dishes` on `20605`: `absent` on the
  first of the three runs (a fresh copy container), `removed` on the second and third (the index the run before left - `sayso`,
  `fuzzy` and `late` read it after, so it stays). The debug pass ran each capture once and never saw a repeat. Fixed in the receipt:
  the delete's answer is no longer printed; the line prints the state after it, `anchor`'s form (`curl DELETE /dishes on 20605, then
  _cat/indices dishes* -> none`), and the README's block says the same. No number moved: the other lines of the three runs were the
  same (`diff` printed line 5 alone). `nohit`'s pin moves `123be5bd…` -> `b1029654…`: the first run's capture with that one line as the
  fixed receipt prints it (`chk21.py nohit` passes on it), confirmed `= published` by the three runs of record below.
- **2026-11-23, the finishing agent, `explain` re-pinned from the first run of record** (as the debug pass had warned: its capture was
  taken on a curl-built copy of the index). On the run of record `explain` reads the index `anchor` leaves: the dev start's re-index is
  `deleteAll()` then `saveAll()` (each document marked deleted, not removed), so after `anchor`'s starts the index holds its ten documents and 20 deleted ones
  (`_cat/indices`: `10 20`), and `_explain`'s statistics count the deleted ones: `N` 20 and `n` 2 (not 10 and 1), the idf
  2.1282318 (not 1.9924302), the score 3.026459 (not 2.833342); the boost 2.2 and the tf 0.6463878 are the same. 3/3 inside the run.
  The section-8 block and the values line now say the run's lines; `receipts.md5`'s `explain` line `e1ed10d6…` -> `90b32881…`.
  For the video: the three factors are as printed, on that index state - a score's statistics include deleted documents until
  Elasticsearch merges them away; the unit says no more of it than that.
## For RED

- The analyzer `dish` of the copy `std` keeps its name (`dish`) with the standard steps; its `_analyze` equals `standard`'s in the same
  run (`nohit`) - the copy is the standard analyzer's tokens under the shipped name, so `Dish`'s mapping applies unchanged.
- `prefix`, `match_phrase_prefix`, `wildcard` and `edge_ngram` find the same four ids; the vegan box is one of them; fuzziness `2`
  finds two and never the vegetarian box. Every count is re-derived from its ids, every meal type read off V4 (`chk21.py`, S8.95).
- The finder's `query_string` is the request the client sent, by its own trace logger; the receipt prints the two bodies whole.
- `explain`'s three factors are read off one index state: `anchor`'s second start deletes and saves again; `explain` prints
  `docs.deleted` beside the score, and the hash is stable across the three runs.
- `ElasticsearchIT` asserts its binding (`127.0.0.1:20606->9200/tcp`) itself, and the receipt watches Docker's own list while
  `verify` runs: two witnesses of S8.94.
- The exercise's check reads the field's search-side analyzer (`search_analyzer`, else `analyzer`), so `late`'s route would pass it too
  (RED #14); a prefix or fuzziness "solution" changes the program's own lines, not the check's `match`.
- `dk stats` is never a capture line; its readings are in the runs of record.

## Planted faults — each caught (R.65, R.226)

The plant driver (`plants.sh`, in the agent's scratch folder, never in this unit) ran each plant on a scratch mirror of this folder
(`../c8-unit21-plant`, removed after); nothing was written here. The controls first (the unit's own captures, each check exit `0`), then
each plant with its check's verdict:

```
  control image                                                                  exit 0
  control anchor                                                                 exit 0
  control tokens                                                                 exit 0
  control nohit                                                                  exit 0
  control sayso                                                                  exit 0
  control late                                                                   exit 0
  control explain                                                                exit 0
  control default                                                                exit 0
  control absent                                                                 exit 0
  control sockets                                                                exit 0
  control fuzzy                                                                  exit 0
  nohit: the copy's veg count 0 -> 1                                             chk21 nohit exit 1 caught
  fuzzy: [6, 8] -> [1]                                                           chk21 fuzzy exit 1 caught
  late: the refusal line deleted                                                 chk21 late exit 1 caught
  anchor: green -> yellow in _cat                                                chk21 anchor exit 1 caught
  default: 404 -> 200                                                            chk21 default exit 1 caught
  absent: Connection refused deleted                                             chk21 absent exit 1 caught
  image: the executor's start line inserted                                      chk21 image exit 1 caught
  anchor: 127.0.0.1:20606 -> 0.0.0.0 in the IT's docker ps line                  chk21 anchor exit 1 caught
  anchor: the test count 18 + 12 -> 18 + 11                                      chk21 anchor exit 1 caught
  image: no ES_JAVA_OPTS - the unit's heap = the default's                       chk21 image exit 1 caught
  sockets: an outbound socket                                                    chk21 sockets exit 1 caught
  "a prefix query fixes veg" -> XFAM_S4B                                         s821 refused 1 caught
  a Hindi dish word -> HINGLISH                                                  s821 refused 1 caught
  "Elasticsearch finds it in one second" -> XFAM_S4B singular time words         s821 refused 3 caught
  took unmasked -> TIMEPAT_S4B                                                   s821 refused 1 caught
  "the health key alone builds no client" -> XU21                                s821 refused 1 caught
  rm -f without v -> R.387                                                       s821 refused 1 caught
  -pl without -am -> R.391                                                       s821 refused 1 caught
  the docker CLI unpinned -> R.344                                               s821 refused 1 caught
  docker exec curl -> XU21                                                       s821 refused 2 caught
  the false vegan count of the old line -> S8.95                                 chk21 numbers exit 1 caught
  control: the shipped README and exercise -> S8.95                              exit 0
  an R.250 sentence left (18 + 11, its note removed)                             chk21 r250 exit 1 caught
  rm -f without -v in receipts.sh                                                stopped:   *** R.387: receipts.sh removes a container without its volumes - every removal is dk rm -fv (found: dk rm -f
  the docker CLI unpinned in receipts.sh                                         stopped:   *** R.344: receipts.sh calls docker without the pinned socket (every call is dk): 141:docker info > /dev/nul
  an exec into the container to run curl                                         stopped:   *** §BUILDERS 9: receipts.sh reads Elasticsearch by an exec into its container and curl there - curl runs o
  an Elasticsearch container without the six settings                            stopped:   *** ⚑4: an Elasticsearch container run without the six settings ($ESSET) - or the labelled default ($ESDEF
  a wrong hash in receipts.md5 (the after-tree pin)                              stopped:   *** R.211: after/'s tree is 77 d301d0358b8aead8a98721939872e983, the pin in receipts.md5 is 77 000000008b8ae
  a placeholder in the README                                                    stopped:   *** a placeholder in this unit's prose or exercise: README.md, the planted word ***
  a changed What-it-prints line (exercise/README.md)                             stopped:   *** a java process is running before this script starts one - not this script's; stop it first ***
  the exercise's solution = the broken block                                     stopped:   *** R.196: SOLUTION.md's block must be the README's with one line changed ***
  a version claim without 9.4.8 (compose.yaml's tag)                             stopped:   *** R.211: after/'s tree is 77 1ac5ac1f175b70a4b046a8c3407c9778, the pin in receipts.md5 is 77 d301d0358b8ae
  a wrong before link (../c8-unit19/after)                                       stopped:   *** R.211: before must be a link to ../c8-unit20/after (it points at: ../c8-unit19/after) ***
```

Not planted here (the cap): a container without `xpack.inference.elastic.authorization.enabled=false` read for the executor's line (its
check is `image`'s count, shown failing by the doctored line above); the two ITs' lists back to V1-V3 under `mvn verify` (`variants.py
nolists`) and `ElasticsearchIT` without its binding (`variants.py nobind`) - both copies are written and print their diffs; their
`verify` runs did not fit.

**2026-11-23, the finishing agent - the three left open, each run alone after the runs of record and the interruptions, each on a
scratch copy in the agent's scratch folder (removed after, with every container it made; volumes 315 before and after, java 0,
`~/.testcontainers.properties` absent), by the driver `plants.sh` there:**
- `nobind` (`harness/variants.py nobind`: `ElasticsearchIT` without its `127.0.0.1:20606` binding), `mvn verify` offline: exit 1, `BUILD
  FAILURE` - `ElasticsearchIT.vegFindsTheVegetarianDishAloneWithTheDishAnalyzer` failed (its own binding check), and Docker's own list
  showed the IT's container's 9200 published on every interface, IPv4 and IPv6, on a random host port; the receipt's
  S8.94 grep matches that line - caught, the receipt stops.
- `nolists` (`harness/variants.py nolists`: both ITs' migration lists back to V1-V3), `mvn verify` offline: exit 1, `BUILD FAILURE` -
  `CustomerAggregatesIT` 1 failure of 2 (the driver kept the first eight result lines; `CustomerEntityRepositoryIT`'s line was past
  them), the other ITs passing, the Elasticsearch IT's container on `127.0.0.1:20606` - caught.
- a container without `xpack.inference.elastic.authorization.enabled=false` (the other five settings and the pinned heap, `127.0.0.1:20604`):
  its log printed `Starting authorization task executor` once; that count written into a copy of `image`'s capture in place of `0`,
  `chk21.py image` exits 1 (2 FAIL, the first the six-settings line) - caught.


## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: the exercise: broken (the standard analyzer's steps) veg 0, prefix 4 with one vegan; solved (the shipped dish-settings.json) veg [1] - by the program and by check.sh, bash and zsh · image: image: version.number 9.4.8, JDK 27, 0 declared volumes, max_map_count 262144, the default heap 4198498304 (the image's default on this VM) and the pinned 536870912, the six settings read back, Security is disabled, no executor start, no controller · anchor: anchor: Flyway 4, the re-index rows 10 -> documents 10 (a second start: before 10, after 10), dishes green 10, _analyze dish 4 [vegetarian, veg, lunch, box], veg [1] by TiffinBox and curl, the finder's query_string, strict mode 12 "could not safely identify" lines (3 naming Dishes: Spring Data JPA, Spring Data MongoDB, Spring Data Redis), Compose on 18884, 18 + 12, the IT 127.0.0.1:20606 and the Mongo IT 127.0.0.1:20578, the 18 without Docker, 146 libraries (before 129), Jackson 2 back beside Jackson 3, HHH000001 7.4.13.Final · tokens: tokens: standard 3 [vegetarian, lunch, box], dish 4 [vegetarian, veg, lunch, box]; term on the text field 0; term mealType VEG 4 ['1', '10', '2', '7'], veg 0 · nohit: nohit (a copy with the standard analyzer): veg 0 [] by the copy's route and curl, no exception; vegetarian 1 [1]; prefix 4 ['1', '10', '2', '8'] (1 vegan: 8); the shipped analyzer 1 [1] · sayso: sayso: prefix / match_phrase_prefix / wildcard 4 ['1', '10', '2', '8'] (also the vegan box); fuzziness AUTO 0; english [vegetarian, veget, vegan, veg], veg 0; edge_ngram 9 tokens, veg 4; the synonym 4 tokens, veg 1 [1]; yellow with a replica, green with 0 · fuzzy: fuzzy: fuzziness 2 -> 2 ['6', '8'] (Egg Fried Rice · Vegan Lunch Box), never the vegetarian box; AUTO 0; the shipped analyzer 1 [1] · late: late: "Mapper for [name] conflicts with existing mapper: Cannot update parameter [analyzer] from [default] to [dish]" (400); search_analyzer dish acknowledged, veg 1 [1] with no re-index · explain: explain: the vegetarian box for vegetarian, score 3.026459 = boost 2.2 x idf 2.1282318 x tf 0.6463878 · absent: absent: exit 1, Error creating bean with name 'dishes', DataAccessResourceFailureException: Connect to <the URI> ... Connection refused · default: default: health 200, /dishes/search 404, /revenue/by-customer 404, /menu/day-19 404, /revenue 200, /kitchen 200, 0 lines naming 9200 or elasticsearch, 0 naming 27017 or mongo, no Elasticsearch bean, Flyway 4 on H2; the health key alone (a labelled copy): exit 1, Dishes' constructor refused at localhost:9200; the 18 without Docker · seven: the seven: md5 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/ · sockets: sockets: no outbound TCP or UDP socket in the samples (listening 9200, 9300; interfaces eth0, lo)
<!-- values: end -->

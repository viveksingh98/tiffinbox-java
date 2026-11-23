# c8-unit26 — *Custom Repository Fragments*

Course 8, Section 5's second unit and its **first change to the anchor**: `before` is the link `../c8-unit25/after` (unit `25`'s tree,
which is unit 24's), `after/` is `../c8-tiffinbox` after this unit's change. `OrderDocuments` gets a repository fragment —
`OrderTotals` and its class `OrderTotalsImpl` — and `Revenue`'s route reads the four totals through it, into `CustomerTotal`.

A repository fragment: an interface of your own, and a class named after it, whose method the repository hands to that class.

Which store answered, in every line: **after/ under "dev"** (`anchor`'s first start, `composition`, the harness's variants in
`silent`, `lookup` (a) and `jpatx`, and `why`: TiffinBox on `20650`, its PostgreSQL `20651`, Redis `20652`, MongoDB `20653`,
Elasticsearch `20654`); **before/ under "dev"** (`anchor`'s second start, on `20655`, the same four stores); **two copies of after/**
(`misnamed` and `lookup` (b), each under "dev" on `20656`); **both trees' jars, default run, H2, no Docker** (the seven, `20650` and
`20655`); **the tests' copy** (`verify`: Testcontainers' own containers, the two pinned ITs on `20578` and `20615`); **the exercise's
own four stores** (`20651`-`20654`, its TiffinBox on `20656`). Every line the harness prints begins "the harness's"; every line its
variants print begins "the harness's variant".

Ten captures. `anchor`, `composition`, `misnamed` and `silent` run three times inside each run of `receipts.sh` and are hashed
(`receipts.md5`); `exercise`, `lookup`, `why`, `jpatx` (its three runs without `@Transactional` inside it, and its control), the
seven and `verify` run once per run, and their 3/3 is across the runs of record. Every number below is asserted after its capture by
`harness/chk26.py`, re-derived from the capture's own lines — never from this README's prose.

## Runs of record

Three runs of `receipts.sh` on 2026-11-23, each ending `c8-unit26: every capture = published …`, each log through
`check_unit8.py 26 --runlog` (`RESULT (run logs): PASS`; the unit gate itself exits `2` until the script stage writes unit `26`'s
script — expected). Every capture's md5 equals `receipts.md5`'s in all three; every build offline (`Downloaded from` `0`). The
launch rule is unit `23`'s (`c8-unit23/README.md:30`) as S8.112 tightened it: a run of record launches only while the first of
the machine's three load averages is below `20` and no other receipt is live, and the load is printed beside the run. Each run's
launch waited `0` checks; `ElasticsearchIT` printed `Timed out waiting` `0` times in each. The three load averages at each run's
start and end:

| run | how | result | load at start | load at end |
|---|---|---|---|---|
| run1-bash32 | `./receipts.sh` — macOS's bash 3.2.57 | PASS | `2.49 4.11 4.57` | `5.50 4.85 4.75` |
| run2-bash53 | `/opt/homebrew/bin/bash receipts.sh` — Homebrew's bash 5.3.9 | PASS | `4.88 4.73 4.71` | `4.34 4.34 4.48` |
| run3-sealed | a sealed fresh clone in a path with a space (`sealed 26/`), `./receipts.sh`, `DOCKER_CONFIG=$HOME/.docker` | PASS | `3.91 4.25 4.45` | `5.01 4.58 4.47` |

Not runs of record, said so: development runs of `receipts.sh` before these three (load up to `13` from other lanes at one
start) found a refused word in the exercise's README, the `@Enable` gate reading a copied Javadoc and `check.sh`'s compile-error
pattern stopping at the folder's space — each fixed before run 1; the three runs above ran on the files as committed but this
section and the plants' section, which were written after them. A last full run of `./receipts.sh` on the files as committed
followed the SIGINT points and the plants; its result and its load are in this unit's commit message.

## RE-MEASURE 5 — `composition`, `misnamed`, `silent` and `jpatx` on 26/after (settled first)

Settled, 3/3 in each run of record. Spring Data Commons' `RepositoryInformation` for `OrderDocuments` holds two fragments:
`ImplementedRepositoryFragment OrderTotals:OrderTotalsImpl`, then `StructuralRepositoryFragment SimpleMongoRepository` (unit `25`'s
`hierarchy` listed the second alone, one fragment per repository — `c8-unit25/README.md`, RE-MEASURE 1). `isCustomMethod` is true for
`totalsByCustomer` and `isQueryMethod` true for `findByMealType`. In each call's own profiler window: one `aggregate` for
`totalsByCustomer()`, one `find` for `findByMealType("VEG")`. The call's stack runs from `OrderTotalsImpl.totalsByCustomer` through
`RepositoryMethodInvoker$RepositoryFragmentMethodInvoker`, `RepositoryComposition$RepositoryFragments.invoke`,
`RepositoryComposition.invoke`, `RepositoryFactorySupport$ImplementationMethodExecutionInterceptor` and
`QueryExecutorMethodInterceptor` to the repository's proxy. The class misnamed on a copy: exit `1`, the chain quoted whole below. The
harness's variant: `7` with its class named `OrderLookupImpl`, `30` with it named `OrderLookupImplementation`, exit `0` and no
exception either way. The harness's JPA fragment: rows `0` without `@Transactional`, rows `1` with it.

## RE-MEASURE 12 — the route's JSON byte-equal before/after, 84 files (settled first)

Settled, 3/3 in each run of record: `GET /revenue/by-customer` on `before/` (under "dev" on `20655`) and on `after/` (`20650`)
answer the same body, byte for byte (`cmp`, and the md5 of each), the four totals Sunil `9000`, Ravi `7200`, Meera `4500`, Priya
`3600`, whose sum `chk26.py` adds — `24300`, `/kitchen`'s `ordersValue` on both trees. `after/` holds `84` files (`harness/tree26.py`),
`before/` `81`.

## RE-MEASURE 13 — `verify` on the labelled rebound copy: `18` + `14`, five IT BINDINGS lines (settled first)

Settled once per run of record, three runs: the tests ran on a copy with the three older tests' containers bound to 127.0.0.1 — U27
ships that change. Surefire's Results line `Tests run: 18`, Failsafe's `Tests run: 14` (`MongoDatastoreIT` `4`), `0` failures, five
`IT BINDINGS` lines from five classes, every host address `127.0.0.1`, `ElasticsearchIT` with `Timed out waiting` `0` in every run, `Pulling` `0`.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

`before/` against `after/` — three files new, four changed (the anchor's README among them), nothing deleted but the type
`Revenue.Total`, which `CustomerTotal` replaces:

```text
  changed: README.md
  changed: tiffinbox-web/src/main/java/com/tiffinbox/web/OrderDocuments.java
  changed: tiffinbox-web/src/main/java/com/tiffinbox/web/Revenue.java
  changed: tiffinbox-web/src/test/java/com/tiffinbox/web/MongoDatastoreIT.java
  new: tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerTotal.java
  new: tiffinbox-web/src/main/java/com/tiffinbox/web/OrderTotals.java
  new: tiffinbox-web/src/main/java/com/tiffinbox/web/OrderTotalsImpl.java
```

- `OrderTotals.java` (new): the fragment's interface, `List<CustomerTotal> totalsByCustomer()`; its Javadoc names the class, the
  postfix, `RepositoryComposition` and the misnamed failure.
- `OrderTotalsImpl.java` (new): unit `19`'s typed pipeline, moved from `Revenue` unchanged, `MongoTemplate` through the constructor;
  no `@Component`, no `@Repository` (`chk26 static` asserts both).
- `CustomerTotal.java` (new): `record CustomerTotal(@Id String customer, long total)`.
- `OrderDocuments.java`: `extends MongoRepository<OrderDocument, String>, OrderTotals`; the Javadoc keeps its derived-finder paragraph
  and gains a *Course 8, unit 26* paragraph — it said no "one derived finder" before and says none now.
- `Revenue.java`: the route returns `orders.totalsByCustomer()`; `Revenue.Total` and `pipeline()` gone; unit `19`'s pipeline paragraphs
  stay (they describe the pipeline, stage for stage, which now sits in `OrderTotalsImpl`), and a dated *Course 8, unit 26* paragraph
  says where it lives.
- `MongoDatastoreIT.java`: the fourth test and a *Course 8, unit 26* Javadoc paragraph; the binding stays `127.0.0.1:20578`.
- `c8-tiffinbox/README.md`: unit `26`'s card (the change file by file, `84` files, `18 + 14`, the fragment named, the advisory's line
  beside the `@Aggregation` alternative); unit `19`'s card gets two dated notes, never a rewrite — after its `OrderDocuments.java` line
  ("and a repository fragment since …") and after its `Revenue.java` line ("unit 26 moves the pipeline behind
  `OrderDocuments.totalsByCustomer()`; `Revenue.Total` is `CustomerTotal` from unit 26 on …"); the four lines that give `18 + 13` as the
  latest count (units `19`, `20`, `21` and `22`'s cards) each gain `*(Course 8, unit 26: 18 + 14)*`.

The hunt (`git grep -n` in `c8-tiffinbox/` before the change), and the decision for each match: `Revenue.Total` — unit `19`'s card (noted)
and `Revenue.java` (the record removed; the new paragraph names it once, as what `CustomerTotal` replaces); `one derived finder` —
unit `19`'s card only (noted; `OrderDocuments.java`'s Javadoc never said it); `18 + 13` — four card lines (noted); `typed on` — unit
`19`'s card (the same sentence, noted); `by-customer` — unit `19`'s card, `Revenue.java` and `TiffinBoxServer.java`'s Javadoc (still
true: the route is the same, its JSON the same — left). `chk26 static` re-runs the stale check on every run: a README line with
`Revenue.Total`, `18 + 13` or "one derived finder" outside unit `26`'s own card must carry its unit 26 note, and no Java code names
`Revenue.Total`.

R.211/R.331: `grep` of every shipped builder (`_builders/s8*.py`) and every shipped `c8-unit*/receipts.sh` and `harness/*.py` for
`OrderDocuments.java`, `Revenue.java`, `MongoDatastoreIT.java`, `OrderTotals`, `OrderTotalsImpl`, `CustomerTotal` and
`Revenue.Total`: the matches are unit `19`'s receipt and checker (they read `19/after`, a frozen tree), unit `25`'s `chk25.py` and
`receipts.sh` (they read `24/after` through their links) and 25's `it-bindings.patch` (applied to `24/after`'s copy) — every one on a
tree pinned to its own commit, so nothing moves: `5` builders (`s818.py`-`s822.py`, each reading its own unit's `after`) and `11`
receipt, checker and patch files (units `18`-`22` and `25`), every hit on a frozen tree.

## The captures — what each one shows

### 1 · anchor — the change, the trees, the route before and after (RE-MEASURE 12)

Both trees built offline, the same libraries:

```text
  the builds: after/ 'Downloaded from' 0 · before/ 0 · BOOT-INF/lib: after/ 146 jars, before/ 146 jars, the same names: yes
  @EnableMongoRepositories' repositoryImplementationPostfix, its default (javap -v, .m2-demo/org/springframework/data/spring-data-mongodb/5.1.2/spring-data-mongodb-5.1.2.jar): "Impl"
```

Who reads each repository in `after/`'s code: five of the six have a reader in `src/main` now — `OrderDocuments` gains `Revenue`:

```text
    OrderDocuments            main: Revenue · test: MongoDatastoreIT, MongoSlice
    CustomerAggregates        main: none · test: CustomerAggregatesIT
```

Each start prints strict mode `x6` and `12` store-assignment lines (the same on both trees: `OrderTotalsImpl` is not a repository
candidate), Flyway's `4` migrations, `Found 1 MongoDB repository interface`. The route on each tree, and `/kitchen`:

```text
  GET /revenue/by-customer on 20650 (after/): [{"customer":"Sunil","total":9000},{"customer":"Ravi","total":7200},{"customer":"Meera","total":4500},{"customer":"Priya","total":3600}]
  GET /revenue/by-customer on 20655 (before/): [{"customer":"Sunil","total":9000},{"customer":"Ravi","total":7200},{"customer":"Meera","total":4500},{"customer":"Priya","total":3600}]
  the two bodies: md5 after/ 8b3f3fffddcafd480eaa4f6cf543985d · before/ 8b3f3fffddcafd480eaa4f6cf543985d · cmp: byte-equal
  GET /kitchen on 20650 (after/): {"ordersCooked":120,"ordersValue":24300} · on 20655 (before/): {"ordersCooked":120,"ordersValue":24300}
```

### 2 · composition — what the repository holds, and the call's way through it (S8.102)

```text
the harness's   composition (RepositoryInformation.getRepositoryComposition().getFragments()) 2 [ImplementedRepositoryFragment OrderTotals:OrderTotalsImpl, StructuralRepositoryFragment SimpleMongoRepository]
the harness's   OrderDocuments.findByMealType isCustomMethod false · isQueryMethod true
the harness's   OrderTotals.totalsByCustomer isCustomMethod true · isQueryMethod false
the harness's beans whose class is TiffinBox's and ends in Impl or Implementation: 1 [orderTotalsImpl=com.tiffinbox.web.OrderTotalsImpl]
the harness's   the profiler [totalsByCustomer] op=command ns=tiffinbox.orders nreturned=4 docsExamined=120 command={"aggregate": "orders", "pipeline": [{"$group": {"_id": "$customer", "total": {"$sum": "$value"}}}, {"$sort": {"total": -1}}], "cursor": {}}
the harness's   the profiler [totalsByCustomer] entries 1
the harness's   STACK 09 com.tiffinbox.web.OrderTotalsImpl.totalsByCustomer
the harness's   STACK 13 org.springframework.data.repository.core.support.RepositoryMethodInvoker$RepositoryFragmentMethodInvoker.lambda$new$0
the harness's   STACK 16 org.springframework.data.repository.core.support.RepositoryComposition$RepositoryFragments.invoke
the harness's   STACK 17 org.springframework.data.repository.core.support.RepositoryComposition.invoke
the harness's   STACK 18 org.springframework.data.repository.core.support.RepositoryFactorySupport$ImplementationMethodExecutionInterceptor.invoke
the harness's   STACK 21 org.springframework.data.repository.core.support.QueryExecutorMethodInterceptor.invoke
the harness's   STACK 28 jdk.proxy<n>.$Proxy<n>.totalsByCustomer
the harness's   the profiler [findByMealType] op=query ns=tiffinbox.orders nreturned=60 docsExamined=120 command={"find": "orders", "filter": {"mealType": "VEG"}}
    mongosh: db.orders.aggregate([{$group: {_id: '$customer', total: {$sum: '$value'}}}, {$sort: {total: -1}}]) -> Sunil 9000, Ravi 7200, Meera 4500, Priya 3600
```

The six repositories are still six and their factory beans five (unit `25`'s list, re-read). The call reaches the class through
`RepositoryComposition`: the proxy's interceptors hand `totalsByCustomer` to the composition, the composition to the fragment
`OrderTotals:OrderTotalsImpl`, and only then does `MongoTemplate` send its one `aggregate`. `findByMealType` never reaches a fragment:
it is a derived method, and Spring Data MongoDB sends its `find`. The Elasticsearch container's sockets close the capture (S8.92,
folded here as unit 25 folded them into `hole`): listening on `9200` and `9300`, no outbound connection, no UDP socket.

### 3 · misnamed — the class under another name: the start stops (S8.103, the failure receipt)

```text
  its exit 1 · 'Started TiffinBoxServer' 0 · 'APPLICATION FAILED TO START' 0 · 'Application run failed' 1 · its MongoDB Found line: Found 1 MongoDB repository interface.
    Caused by: org.springframework.data.repository.query.QueryCreationException: Cannot create query for method [OrderTotals.totalsByCustomer()]; No property 'totalsByCustomer' found for type 'OrderDocument'
    Caused by: org.springframework.data.core.PropertyReferenceException: No property 'totalsByCustomer' found for type 'OrderDocument'
```

The outermost exception is `UnsatisfiedDependencyException` on the bean `revenue` (its constructor's parameter `1`,
`OrderDocuments`), caused by `BeanCreationException` on `orderDocuments` (R.462's owner, `org.springframework.beans.factory`) — the
capture holds all four lines whole. Commons found no `OrderTotalsImpl`, and Spring Data MongoDB parsed the method's name as a derived
one, looking for a property `totalsByCustomer` on `OrderDocument`. The control is `anchor`'s `after/` start and `composition`.

### 4 · silent — a name that also parses: no failure, another answer (S8.103, the harness's)

The harness's variant adds another fragment, `OrderLookup.findByCustomer(String)` — a name Commons can parse too. With its class
named `OrderLookupImpl`:

```text
the harness's   composition (RepositoryInformation.getRepositoryComposition().getFragments()) 3 [ImplementedRepositoryFragment OrderTotals:OrderTotalsImpl, ImplementedRepositoryFragment OrderLookup:OrderLookupImpl, StructuralRepositoryFragment SimpleMongoRepository]
the harness's   the profiler [findByCustomer] op=query ns=tiffinbox.orders nreturned=7 docsExamined=30 command={"find": "orders", "filter": {"customer": "Ravi"}, "sort": {"day": -1}, "limit": 7}
the harness's CALL findByCustomer("Ravi") -> 7 results
```

With it named `OrderLookupImplementation`:

```text
the harness's   composition (RepositoryInformation.getRepositoryComposition().getFragments()) 2 [ImplementedRepositoryFragment OrderTotals:OrderTotalsImpl, StructuralRepositoryFragment SimpleMongoRepository]
the harness's   OrderLookup.findByCustomer isCustomMethod false · isQueryMethod true
the harness's   the profiler [findByCustomer] op=query ns=tiffinbox.orders nreturned=30 docsExamined=30 command={"find": "orders", "filter": {"customer": "Ravi"}}
the harness's CALL findByCustomer("Ravi") -> 30 results
```

Both JVMs exit `0` with `0` ERROR lines and no exception. The second find sends a filter and no sort — `30` is a count, and the
capture prints the ids in the order they came back, nothing more. `mongosh`, after each JVM, gives `7` for the same filter, sort and
limit and `30` for the filter alone. The name decides loud or silent: `totalsByCustomer` names no property, so a missing class stops
the start; `findByCustomer` names one, so a missing class turns into another query.

### 5 · lookup — one bean, and the package (1/1 each)

(a) The harness's variant with `@Component` on `OrderTotalsImpl`: the start completes, the composition is the same two fragments, and
there is still one bean of the class, `orderTotalsImpl` — Commons uses the bean that exists. (b) A copy with `OrderTotalsImpl` moved to
`com.tiffinbox`, above the repository's package: exit `1`, the same four-line chain as `misnamed` (`chk26 lookup` compares them, the
jar's URL aside).

### 6 · why — the same pipeline as strings (the harness's)

The harness's repository `OrderTotalsAsStrings`, built by `new MongoRepositoryFactory(mongoTemplate)`, carries the pipeline as two
`@Aggregation` strings. The profiler shows the strings sent as written — the same command the fragment's typed pipeline sends — and
the four totals are the fragment's, line for line:

```text
the harness's   the profiler [totals] op=command ns=tiffinbox.orders nreturned=4 docsExamined=120 command={"aggregate": "orders", "pipeline": [{"$group": {"_id": "$customer", "total": {"$sum": "$value"}}}, {"$sort": {"total": -1}}], "cursor": {}}
```

Both ran and both answered the same; nothing here measures a renamed field in either form.

### 7 · jpatx — a JPA fragment's own transaction (S8.104, the harness's)

The harness's variant gives `CustomerEntityRepository` a fragment `CustomerWrites` whose class persists one customer through the
`EntityManager`. Without `@Transactional` on its method, three times:

```text
the harness's variant CustomerWritesImpl.addProbe: a transaction active on this thread: false
the harness's CALL addProbe("the-harness-26") threw org.springframework.dao.InvalidDataAccessApiUsageException: No EntityManager with actual transaction available for current thread - cannot reliably process 'persist' call
the harness's   cause jakarta.persistence.TransactionRequiredException: No EntityManager with actual transaction available for current thread - cannot reliably process 'persist' call
  psql after: select count(*) from customer where name = 'the-harness-26' -> 0
```

With `@Transactional` on it, once: `a transaction active on this thread: true`, the call returns, `psql` counts `1`. The generated
methods' transaction is `SimpleJpaRepository`'s; a fragment's is its own — the harness's variant, said as such.

### 8 · seven — the comparison set on both trees (R.363)

`after/`'s jar on `20650` and `before/`'s on `20655`, H2, no Docker: seven responses each, the md5 the course's (read off
`../c7-unit31/receipts.sh`), on both.

### 9 · verify — `18` + `14` on the labelled copy (flag 8(d))

```text
  MongoDatastoreIT: Tests run: 4, Failures: 0, Errors: 0, Skipped: 0 -- in com.tiffinbox.web.MongoDatastoreIT
  the new test's own line: MONGO IT the fragment's totalsByCustomer(), through OrderDocuments: [CustomerTotal[customer=Ravi, total=480], CustomerTotal[customer=Sunil, total=300]]
```

### 10 · exercise — run as written, in one shell, bash then zsh (R.196)

The README's lines print the broken start (`No property 'totalsByCustomer' found for type 'OrderDocument'`, solved: no), the
solution's print the start, the four totals and `24300` (solved: yes), in bash and in zsh; the deleted-method "solution" builds no jar
— `OrderTotalsImplementation is not abstract and does not override abstract method totalsByCustomer()` — and fails the check, three
times in each run. The exercise's spoken line is `24` words (`wc -w`).

## Which store, which profile, which tree

- **`before/`** is the link `../c8-unit25/after` (its text exactly that, RED #28) — unit `25`'s `after`, itself the link to
  `../c8-unit24/after`; one tree, named once: `81` files, the pin `../c8-unit25/receipts.md5`'s `after-tree` line, re-derived by
  `harness/tree26.py`, never typed. It runs twice here: under "dev" on `20655` (`anchor`, its route's JSON) and on H2 on `20655` (the
  seven).
- **`after/`** is this unit's tree, `../c8-tiffinbox` after the change (`diff -rq` empty at the receipt's start and end), `84` files,
  pinned in `receipts.md5`. Under "dev" on `20650` it runs `anchor`, `composition`, the harness's variants (`silent`, `lookup` (a),
  `jpatx`) and `why`; on H2 on `20650`, the seven.
- **The harness's variants** — `harness/variants/`, never shipped, each file saying so in its first comment, each compiled against
  `after/`'s jar and put FIRST on the class path of a JVM that runs `after/`'s jar: `silent` (`OrderDocuments` extends `OrderTotals`
  and `OrderLookup`; `OrderLookupImpl`), `silentbad` (the same, `OrderLookupImplementation`), `comp` (the shipped `OrderTotalsImpl` with
  `@Component`), `jpa` and `jpatx` (`CustomerWrites` on `CustomerEntityRepository`, without and with `@Transactional`). The shipped
  `OrderTotals`, `OrderTotalsImpl` and `CustomerTotal` come from the jar in every one of them.
- **The copies** — `.harness/misnamed` (a copy of `after/` with `exercise/OrderTotalsImplementation.java` in place of
  `OrderTotalsImpl.java` — the exercise's broken tree, the same files) and `.harness/pkg` (a copy with `OrderTotalsImpl` moved to
  `com.tiffinbox`), each built offline and started under "dev" on `20656`, one at a time.
- **Dev's four stores:** `c8u26-pg` PostgreSQL on `20651` (`log_statement=all`; its witness `psql`), `c8u26-redis` Redis on `20652`,
  `c8u26-mongo` MongoDB on `20653` (a standalone, a fresh container before every JVM, `GLIBC_TUNABLES`; its witnesses the profiler —
  read per call by the harness, one window per call — and `mongosh` after the JVM is gone), `c8u26-es` Elasticsearch on `20654` (the
  six settings, by digest, `9300` not published). Each published on `127.0.0.1` alone.
- **The tests' copy, labelled:** the tests ran on a copy with the three older tests' containers bound to 127.0.0.1 — U27 ships that
  change. `.harness/tests` = `after/` + `harness/it-bindings.patch` (five test files, nothing under `src/main`).
- **The exercise's own four stores** on `20651`-`20654` (`c8u26-ex-*`, by the tags the course measured), its TiffinBox on `20656`;
  they run before the unit's own stores, never beside them.

## Refused, named

- A `repositoryImplementationPostfix` on an `@EnableMongoRepositories` of the viewer's own as the exercise's solution: not measured
  here, and an `@Enable...Repositories` switches Boot's own scan off for that module (unit `25`'s plant showed what that costs).
- `@Aggregation` as the shipped shape: `why` runs it as the harness's repository only; the anchor ships the fragment.
- A renamed-field measurement of either form (the fragment's typed pipeline against the strings): not captured here — carried, unsaid.
- `Spring Data writes your method`, `the generated Impl`, `Spring Data MongoDB calls your class` with no composition named:
  `harness/s826.py`'s XU26 refuses each (the plants below).
- "ascending" or "in day order" for `silent`'s thirty: the derived find sends a filter and no sort (the profiler's own line).
- A `Course 9` number, and `safe` or `secure` for the pipeline: XFAM_S5 refuses both; the advisory sentence stays in the anchor's
  README, never in a capture.

## The repository, and the network

One commit on `main` for `c8-unit26/` and `c8-tiffinbox/` (the six files and its README). `.harness`, `.m2-demo`, `target` and
`secrets` are never committed (`.gitignore`). Nothing in this unit touches the network: every build is offline (`-o`, `.m2-demo`,
`Downloaded from` `0` in every log), every container `--pull never` from an image already on the machine by its digest, and the only
network the agent used is the final `git push`. `.m2-demo` is a copy of the course's seed `_research/m2-seed-c8-s4b` (`7265` files);
this unit adds no dependency.

## The folders, the harness and the ports

- `before` → `../c8-unit25/after`; `after/` — the anchor after this unit's change.
- `harness/src/probe/u26/H26.java` — the harness (modes `composition`, `why`, `jpatx` by `--h26.mode`), joined by
  `--spring.main.sources=probe.u26.H26`; its configuration class's bean name is `h26`, its `@Bean` methods `h26Runner` and
  `h26StackListener` (25's lesson: never one name for both). It reads the call's stack through a MongoDB driver `CommandListener` it
  adds by a `MongoClientSettingsBuilderCustomizer`: on the thread that sends the `aggregate`, `Thread.getStackTrace()`, from
  `MongoTemplate` up to the harness's own call. The shipped classes print nothing.
- `harness/variants/` — the harness's variants (above); `harness/s826.py`, `chk26.py`, `tree26.py`, `dur8.py` (the builders' as unit
  02 shipped it), `logback.xml` (unit 07's), `it-bindings.patch` (unit `25`'s five edits, MongoDatastoreIT's hunk re-made: its changed
  lines are 25's, line for line).
- `exercise/` — `README.md` (the `24` words), `OrderTotalsImplementation.java`, `SOLUTION.md`, `check.sh`.
- Ports `20650`-`20659`: `20650` TiffinBox (`after/`), `20651`-`20654` the four stores, `20655` TiffinBox (`before/`), `20656` the
  exercise's TiffinBox and the two copies' starts, one at a time, `20657`-`20658` spare (asserted free), `20659` never bound; during
  `verify` only, Testcontainers' own ports on `127.0.0.1` and the pinned `20578` and `20615`. `18881`-`18884` free throughout.

## Masks, filters and hygiene — every one, declared

The receipt's `mask` replaces this folder's path, its parent's and the home folder with `…`, `…/..` and `~` (and their `%20` forms,
for the sealed clone's path); Boot's `Started … in`, `scanning in`, `initialization completed in`, Flyway's execution time, Maven's
`Total time`, Surefire's `Time elapsed`, Testcontainers' `started in PT…S` (TIMEPAT_S5's members), `pid N`, a MongoDB `lsid`,
object hashes after `@`, and Boot's `... N common frames omitted`; the user's name. The harness itself drops `lsid`, `$db` and
`$clusterTime` from each profiler command and writes `jdk.proxy<n>.$Proxy<n>` for the proxy class's numbered name. The JPA
fragment's row carries the harness's name, `the-harness-26`. No filter hides a line: `silent`'s capture leaves out the thirty
`OrderDocument[...]` lines and prints their ids on one line instead, in the order returned; the stack lines are `composition`'s.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: every JVM, Maven and shell it started is stopped by its process id and its children, every
container of the unit's (`c8u26-*`, the exercise's four) and every Testcontainers container (by the label) removed with its volumes,
the partial captures removed; exit `130`. Six SIGINT points, run after the runs of record and before the plants, each on this folder
(not the clone), each launched with SIGINT reset to its default (R.410) and interrupted once its moment was reached: mid-build
(`build-before.log` written), mid-exercise (the README's block had built its jar), mid-dev start (`anchor`'s first JVM starting), mid-
`composition` (the harness's `totalsByCustomer` window open), mid-`misnamed` (the copy's JVM starting, before it fails), mid-`verify`
(Testcontainers creating its containers). Each: exit `130`, no JVM, no `c8u26-*` container, no Testcontainers container, volumes
`315`, images `9`, nothing listening on `20650`-`20659`, `20578`, `20615` or `18881`-`18884`, the captures unchanged, no partial
capture or lock left, and `../c8-tiffinbox` = `after/` after each (the anchor is changed on disk before the runs; a SIGINT never
touches it). A first batch of four of them is not counted: this agent edited this README while they ran, and each stopped at the
prose gate (exit `1`) before its moment - they were run again on the README unchanged.

## Planted faults — each caught (R.65, R.226)

Run after the three runs of record and the SIGINT points, each on a scratch copy (a doctored capture, a copy of `after/`, a scratch
sentence, or the sealed clone's own files, restored after), never on the shipped files; each made to fail its gate first, then
removed. **Every one ended with its own FAIL line (or the receipt's `***` line, or the prose gate's refusal), exit `1`, and no
traceback** — the defect class unit `25`'s checker carried (a verdict, then a traceback on a line it could not parse) is closed:
`chk26.py` parses every listing line by a named pattern or ends in a FAIL line of its own.

| # | the plant | its gate | what it printed last |
|---|---|---|---|
| `1` | `composition` read with the fragment line removed | `chk26 composition` | the composition: one line expected, `0` found; two fragments FAIL |
| `2` | the tracebacking checker: a composition line `chk26` cannot parse (its `[` made `{`) | `chk26 composition` | `the composition line does not parse` - a FAIL line, exit `1`, no traceback |
| `3` | a capture that is not text at all | `chk26 composition` | `the checker could not read its input: UnicodeDecodeError` - a FAIL line |
| `4` | a doctored `isCustomMethod true` on the misnamed class's run | `chk26 silent` | `named OrderLookupImplementation: isCustomMethod false, isQueryMethod true` FAIL |
| `5` | `silent`'s thirty typed as the class's seven | `chk26 silent` | `the class never ran, 30 results` FAIL |
| `6` | the class's seven typed as thirty | `chk26 silent` | `the class ran, 7 results` FAIL |
| `7` | the JSON before/after made unequal (a key reordered in `before/`'s body) | `chk26 anchor` | RE-MEASURE 12 FAIL |
| `8` | the four totals with one changed (Ravi `7300`) | `chk26 anchor` | the sum `24400` is not `ordersValue` FAIL |
| `9` | the sum without `/kitchen` read | `chk26 anchor` | `ordersValue` unread (`?`) FAIL |
| `10` | a strict-mode count of `5` | `chk26 anchor` | `strict mode x5` FAIL |
| `11` | the test count `18 + 13` | `chk26 verify` | the tests FAIL |
| `12` | `verify` with the host IP changed (`127.0.0.2`) | `chk26 verify` | every entry's host IP FAIL |
| `13` | a copy of `RedisDatastoreIT` without its modifier (the static count `0`) | `chk26 verify` | the static check FAIL |
| `14` | the `IT BINDINGS` set with four classes | `chk26 verify` | five lines, five classes FAIL |
| `15` | `jpatx`'s rows `0` typed as `1` | `chk26 jpatx` | the three runs alike, rows `0` FAIL |
| `16` | `misnamed`'s chain with another exception's package | `chk26 misnamed` | the chain whole FAIL |
| `17` | `Revenue.Total` left in a README sentence without its note | `chk26 static` (a copy of `after/`) | the stale-sentence check FAIL |
| `18` | "one derived finder" left in `OrderDocuments`' Javadoc | `chk26 static` | FAIL |
| `19` | a README count `18 + 13` left without its note | `chk26 static` | the stale-sentence check FAIL |
| `20-26` | seven scratch sentences, one per refused reading the prompt names: the Impl called generated, Spring Data writing your method, a safety verdict on the pipeline, the bare call of your class, an order word for the thirty, a duration, another course's lesson by number | `harness/s826.py` | XU26 (4), XFAM_S5 (2), the inherited time family (1) |
| `27` | XFAM_S5's own plants, one sentence each, through the gate | `harness/s826.py` | all `12` families refuse |
| `28` | the cannot-fail detector (R.276 + R.374) on a copy of `chk26.py` with `x == x` and `len(x) >= 0` | the detector | FAIL; the shipped `chk26.py` holds `0` |
| `29` | a changed "What it prints" line | the receipt's comparison | `*** … not what its lines printed ***` |
| `30` | the exercise's deleted-method "solution" | `exercise/check.sh` | `solved: no` (no jar) - and the receipt's own 3/3 |
| `31` | a `before` link to `../c8-unit24/after` (the resolved tree right, the TEXT wrong - RED #28) | `receipts.sh` (the sealed clone) | `*** R.250/RED #28 … ***`, exit `1` |
| `32` | a wrong `after-tree` hash | `receipts.sh` | `*** R.211 … the tree moved ***` |
| `33` | a placeholder in the README | `receipts.sh` | `*** a placeholder … ***` |
| `34` | a static check that fails | `receipts.sh` | `*** static: FAIL planted ***` |

## What differed from the brief

- **The record and its package:** `CustomerTotal` is a top-level record in `com.tiffinbox.web` (BLUE's amendment, RED #18) with
  `@Id` on `customer`: the pipeline's group key arrives as `_id`, and `Revenue.Total` carried the same `@Id` - without it the mapper
  has no property for `_id`. `total` is a `long` (the brief's), where `Revenue.Total`'s was an `int`; the JSON is the same, byte for
  byte (`anchor`). `Revenue.Total` and the static `Revenue.pipeline()` are gone (nothing else read either: `git grep` over `after/`).
- **The failure text is not the brief's in two places, measured:** the start prints no `APPLICATION FAILED TO START` (Boot has no
  failure analyzer for this exception; it prints `Application run failed` once - the probe's `f26bad` summaries said `0` too), and the
  outermost exception is `UnsatisfiedDependencyException` on the bean `revenue` - `Revenue` now takes `OrderDocuments` through its
  constructor - whose cause is the brief's `BeanCreationException` on `orderDocuments`, then `QueryCreationException`, then
  `PropertyReferenceException`. The four lines are quoted whole in `misnamed`.
- **How the stack was read:** the shipped `OrderTotalsImpl` prints nothing. The harness adds a MongoDB driver `CommandListener`
  (through a `MongoClientSettingsBuilderCustomizer` bean of its own) that, while the `totalsByCustomer()` window is open, takes
  `Thread.getStackTrace()` on the thread that sends the `aggregate`; the sync driver calls it on the caller's thread, so the stack runs
  from `MongoTemplate` through `OrderTotalsImpl.totalsByCustomer` and Commons' classes to the proxy and the harness's own call.
- **The `silent` variant's shape:** the probe's - a variant `OrderDocuments` extending `MongoRepository`, `OrderTotals` and
  `OrderLookup`, with `OrderLookupImpl` (the last seven days, newest first) or `OrderLookupImplementation`, first on the class path
  ahead of `after/`'s jar; the shipped `OrderTotalsImpl` still answers `OrderTotals` from the jar (three fragments, then two).
- **Which copy builds ran:** all - `after/`, `before/`, the misnamed copy, the package copy (`lookup` (b) was not dropped), and the
  exercise's own builds (four per run, plus the three deleted-method builds). Nothing was dropped to "not captured": `lookup` (b),
  `why` and both halves of `jpatx` ran in every run of record.
- **The misnamed copy and the exercise:** the receipt builds `.harness/misnamed` from `after/` with
  `exercise/OrderTotalsImplementation.java` in place of `OrderTotalsImpl.java` - the exercise's broken tree, the same files - once per
  run, for `misnamed`; the exercise's README builds its own copy the same way, as a viewer would. `misnamed` and the package copy start
  on `20656`, the exercise's slot, one at a time and never beside the exercise.
- **The exercise's shape:** the viewer's lines copy `after/`, put the renamed class in, build offline, start four stores and the copy
  under "dev" on `20656`, read the route and `/kitchen` when it starts, stop it by `POST /shutdown`, and run `check.sh` - which reads the
  start's outcome off the log and the route's four totals with their sum beside `ordersValue`, never an exit. The wrong "solution" the
  check must refuse deletes the method from the class: it builds no jar (a compile error), measured 3/3 per run.
- **The strict-mode count did not move:** `x6` and `12` (JPA `4`, Elasticsearch `2`, Reactive Elasticsearch `2`, MongoDB `2`, Redis
  `2`) on `after/` and on `before/` - `OrderTotalsImpl` is not a repository candidate.
- **The injected count:** `5` of the six repositories have a reader in `src/main` on `after/` (unit 25 counted `4` - `OrderDocuments`
  gains `Revenue`); `CustomerAggregates` still has its tests alone.
- **One more bean:** Commons registers the fragment's class as a bean, `orderTotalsImpl`, without `@Component` (`composition`'s bean
  line); with `@Component` (`lookup` (a)) there is still one bean of that name.
- **`it-bindings.patch`:** unit `25`'s five edits; `MongoDatastoreIT`'s Javadoc grew, so its hunk was re-made (`diff -ru` of a copy with
  25's patch applied) - its changed lines are 25's, line for line (`chk26 static`).
- **The anchor's README:** unit `19`'s card gets two dated notes (its `OrderDocuments.java` and `Revenue.java` lines), and the four
  lines that say `18 + 13` as the latest count each gain `*(Course 8, unit 26: 18 + 14)*`; the header's long note line names units up
  to `18` only and is left as unit 24 left it; there is no separate section list to update.
- **The prose gate's `@Enable` check** reads Java code lines only: the `jpa` variant's copy of `CustomerEntityRepository` keeps that
  file's Javadoc, which names `@EnableJpaRepositories`.

## For RED

- **The hook's label:** the brief's hook says "TiffinBox does not start" for a renamed COPY (`misnamed`, `.harness/misnamed`, a copy of
  `after/` with one class renamed). The receipt labels it "a copy of after/"; the exercise's spoken line says "TiffinBox stops at the
  start" in the same sense. The script stage decides the voiced label; the slide names the copy.
- **What a script must not say:** `Spring Data writes your method`, `the generated Impl` (XU26 / XFAM_S5); `Spring Data MongoDB calls
  your class` without `RepositoryComposition` or the composition on the slide or in the sentence; "ascending" or "in day order" for
  `silent`'s thirty (the derived find sends no sort); a time of any kind (dur8 `0`); `safe` or `secure`; a `Course 9` number.
- **The counts and their witnesses:** two fragments (Commons' `RepositoryInformation`, the harness's line; three in the harness's
  variant); `isCustomMethod(totalsByCustomer)` true, `isQueryMethod(findByMealType)` true (the harness's lines); one `aggregate` and one
  `find` (MongoDB's profiler, each call's own window); the four totals (the route on both trees, the harness's call, `mongosh`'s own
  `$group`); `24300` (the totals added by `chk26.py`, `/kitchen`'s `ordersValue` on both trees); exit `1` (the copies' JVMs); `7` vs
  `30` (the harness's variant, the profiler, `mongosh`); rows `0` / `1` (the harness's `JdbcTemplate` and `psql`); `18` + `14` (Surefire's
  and Failsafe's Results lines on the labelled copy); `84` files (`tree26.py`).
- **The gloss** stands once, byte for byte, as its own line near the top.
- **The CVE line is a README fact of the anchor, never voiced and never a capture claim.**

## The ledger rows this unit pays

- **Roadmap `:360`** ("a hand-written method mixed into a generated interface"): paid as "a fragment beside the derived methods" —
  `OrderTotals` beside `findByMealType` on `OrderDocuments`, never "generated" for the Impl.
- **Contract §10's "a repository fragment"**: the gloss, above.
- **C8-6 and C8-7** (unit `25`'s rows): untouched here.

## The values the video may say

Each line is one capture's `VALUES` line from `harness/chk26.py`, written by the runs (the receipt asserts this block equals them):

<!-- values: begin -->
```text
exercise: broken: the start fails, No property 'totalsByCustomer' found for type 'OrderDocument' · solved: started, the four totals, 24300 · the deleted method refused 3/3 (no jar) · the spoken line 24 words
anchor: changed 4 (README.md, OrderDocuments, Revenue, MongoDatastoreIT) · new 3 (CustomerTotal, OrderTotals, OrderTotalsImpl) · files 81 -> 84 · libs 146 · postfix "Impl" · repositories with a src/main reader 5 of 6 (CustomerEntityRepository, DishEntityRepository, Dishes, KitchenOrders, OrderDocuments) · strict x6, Could not safely identify 12, Flyway 4 · the JSON byte-equal md5 8b3f3fffddcafd480eaa4f6cf543985d · Sunil 9000 · Ravi 7200 · Meera 4500 · Priya 3600 · sum 24300 = ordersValue
composition: fragments 2 (OrderTotals:OrderTotalsImpl, SimpleMongoRepository) · isCustomMethod(totalsByCustomer) true · isQueryMethod(findByMealType) true · repositories 6, factory beans 5 · aggregate 1, find 1 (60) · the stack through RepositoryComposition (31 frames) · mongosh the same four totals
misnamed: exit 1 · UnsatisfiedDependencyException 'revenue' <- BeanCreationException 'orderDocuments' <- QueryCreationException: Cannot create query for method [OrderTotals.totalsByCustomer()] <- PropertyReferenceException: No property 'totalsByCustomer' found for type 'OrderDocument' · 'APPLICATION FAILED TO START' 0, 'Application run failed' 1
silent: the harness's variant: OrderLookupImpl -> 7 (3 fragments, isCustomMethod true, find sort day -1 limit 7) · OrderLookupImplementation -> 30 (2 fragments, isCustomMethod false, isQueryMethod true, find with no sort), exit 0, ERROR 0 · mongosh 7 and 30
lookup: (a) @Component: one bean orderTotalsImpl, the composition unchanged · (b) the class in com.tiffinbox: exit 1, misnamed's chain
why: @Aggregation strings: 1 aggregate, the same command, the same four totals
jpatx: the harness's variant: no @Transactional -> active false, InvalidDataAccessApiUsageException (TransactionRequiredException), rows 0, 3/3 · @Transactional -> active true, rows 1
seven: the seven on after/ and before/: 7 lines each, md5 = the course's
verify: tests 18 + 14, 0 failures (MongoDatastoreIT 4) · the new test Ravi 480, Sunil 300 · IT BINDINGS 5 classes, every host IP 127.0.0.1 · containers created 5 · pulled 0
```
<!-- values: end -->

Which tree, store, port and witness for each: `anchor` — both trees under "dev" (`20650`, `20655`), the route's JSON by `curl` and `cmp`, the sum by `chk26.py` beside `/kitchen`; `composition` — `after/` on `20650`, Commons' `RepositoryInformation` (the harness), MongoDB's profiler on `20653` and `mongosh`; `misnamed` and `lookup` (b) — the copies on `20656`, Boot's own log; `silent`, `lookup` (a), `why`, `jpatx` — the harness's variants and repository on `after/`'s jar on `20650`, the profiler and `mongosh` (`20653`), `psql` (`20651`); the seven — both jars on H2 (`20650`, `20655`); `verify` — the labelled copy's Surefire and Failsafe lines; `exercise` — the exercise's own stores on `20651`-`20654`, its TiffinBox on `20656`, `check.sh`.

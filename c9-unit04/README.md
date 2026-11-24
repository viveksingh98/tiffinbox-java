# c9-unit04 — *Idempotency, Safety and Retries*

Course 9, Section 1's unit `04` and **Course 9's first change to the anchor**. `before/` is a frozen copy of `../c9-tiffinbox` at the
set-up commit `80f7839` (that is `../c8-unit27/after` with a README header); `after/` is `../c9-tiffinbox` after this unit's change. A
third tree, `mid`, is the version step alone — `before/` with the parent at `4.1.3` and `<tomcat.version>11.0.29</tomcat.version>` — a
copy under `.harness/`, never shipped. The version step and the key are two A/B pairs; the cache proxy is a third, switched on `after/` by
`tiffinbox.cache.transaction-aware`.

The hook is the `pause` capture, on H2 and on PostgreSQL:

Send the same pause twice and TiffinBox counts it twice: five paused days, then seven, then nine.

The gloss, as the brief gives it:

An idempotency key: a label the client puts on a request so a repeat of it gets the first answer back.

On the public pause route the second try with the same key gets the first answer back, byte for byte, and the route does not run: the
`key` capture's request witness reads handler `none`, and the paused days move once. That measured second answer is what "idempotent"
means for this route, deepened from unit `02`'s gloss.

## Runs of record

Three runs of `receipts.sh`, each ending `c9-unit04: every capture = published`, each log through `check_unit9.py 04 --runlog`
(`RESULT (run logs): PASS`; the unit gate exits `2` until the script stage writes unit `04`'s script — expected). Every build offline
(`Downloading from` and `Downloaded from` none in every Maven log). The launch rule is R.480: a run of record launches only while the
first load average is below `20` and no other receipt runs; `guard` checks both before every build, container, JVM and `mvn verify`, and
prints the load beside it. The three runs, the loads at their start and end, and the `ElasticsearchIT` wait, are in the table:

<!-- runs: begin -->
| run | how | result | load at start | load at verify | load at end | ElasticsearchIT's wait |
|---|---|---|---|---|---|---|
| run1-bash32 | `./receipts.sh` — macOS's bash 3.2.57 | PASS | `8.44 7.14 8.64` | `7.65` | `3.52 4.58 6.76` | held |
| run2-bash53 | `/opt/homebrew/bin/bash receipts.sh` — Homebrew's bash 5.3.9 | PASS | `3.52 4.58 6.76` | `4.76` | `4.03 4.15 5.67` | held |
| run3-sealed | a sealed fresh clone (`git clone file://…`) in a path with a space (`sealed 04/`), `./receipts.sh`, `DOCKER_CONFIG=$HOME/.docker` | PASS | `4.03 4.15 5.67` | `4.87` | `3.17 3.98 5.09` | held |
<!-- runs: end -->

The three runs ran on the files as committed but for this README's tables of runs, interrupts and plants and a few sentences,
written after them; the last check before the commit re-ran the prose gate, the static check and the values block on the README as
committed (the commit message says so).

Not runs of record, said so: development runs of `receipts.sh` before these found a shell glob in the `curl` call, Maven's `user.home`
broken by the folder's space, the phase-2 limit of the fence's test values ending every longer hold with `503` on the default run (so the holds now run on a
JVM with the shipped defaults, and only the fence's JVMs carry the test values), the request witness's line read before the JVM had
printed it, a bean name the map loser shared with its class, a load spike from another program's video encode (the guard stopped
that run, as it must), `dependency:list` refused offline without a `compile` phase for the sibling module (an earlier set of three
runs pinned its `exit 1`: superseded, all three run again), and the bill's git-ignored file, absent in a fresh clone, inside the hash
(it is printed where it exists, never hashed).

## RE-MEASURE: the version step (`4.1.3` and `11.0.29`: the BOM's moves, the three trees' seven and surface, the tests per runner)

Settled, 3/3. The parent's BOM moves `36` of its `195` version properties, none added or removed; Spring Framework `7.0.10` → `7.0.11`,
Spring Data `2026.0.2` → `2026.0.3`, Hibernate ORM `7.4.13.Final` → `7.4.15.Final`, Jackson `3.1.7` → `3.1.8`, Netty `4.2.19.Final` →
`4.2.20.Final`. `BOOT-INF/lib` holds `146` jars on all three trees; the moved names are listed in the `tests` capture, and Tomcat's
three jars read `11.0.29` on `mid` and `after/`. `mvn -o package` runs `18` tests on `before/` and on `mid` (the version step alone
keeps them), and `18` + `10` on `after/`. The seven and the old surface (the feed read by a count condition, the boundary's reader)
are byte-equal on `before/`, `mid`, `after/` and `after/` with the proxy off; the hashes are in the values block. Tomcat's `TRACE`
answer, re-measured on `before/` and `after/` as the A/B's control, is `405` on both, its body Boot's error JSON; the boundary's B5b
settled `CONNECT` and the over-long request line on `11.0.29` (`S1B`, BOUNDARY CHECK RESULT), not re-run here.

## RE-MEASURE: the five ITs on `21280`-`21284` (`18` + `k`, `14`, the Elasticsearch wait and the load)

Settled, once per run of record, 3/3 across them. `mvn -o verify` on a plain copy of `after/`: Maven's Results lines read `Tests run: 28`
and `Tests run: 14`, no failure and no error (`MongoDatastoreIT` `4`). Five `IT BINDINGS` lines from five classes, each on its own port:
`CustomerEntityRepositoryIT` `21280`, `CustomerAggregatesIT` `21281`, `RedisDatastoreIT` `21282`, `MongoDatastoreIT` `21283`,
`ElasticsearchIT` `21284`; `harness/chk04.py` parses every entry and counts the ones off `127.0.0.1`: none. The ports Testcontainers'
containers held while the build ran, read through the pinned socket, are printed beside, never as the witness. `ElasticsearchIT`'s log
wait held in every run of record, at the loads in the table above. Nothing pulled; no Testcontainers container left; `21280`-`21284`
free before and after.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

`harness/chk04.py static` derives the file list: `before/` holds `84` files, `after/` `92`; `8` new, `10` changed, none gone.
- `pom.xml` — the parent `4.1.2` → `4.1.3`, `<tomcat.version>11.0.29</tomcat.version>`, one comment naming the advisories (CVE-2026-123886
  HIGH and CVE-2026-59342 MEDIUM, fixed by `4.1.3`'s Spring Data; Tomcat's ten advisories after `11.0.27`, four Important); the two older
  comments that say `4.1.2` and Framework `7.0.10` each gain a *Course 9, unit 04* note.
- `tiffinbox-core/pom.xml`, `tiffinbox-web/src/main/resources/application.yaml` — comments only: a *Course 9, unit 04* note beside each
  `4.1.2`.
- `V5__idempotency_key.sql`, `IdempotencyKeyFilter`, `IdempotencyKeys`, `TransactionAwareCaching`, `CustomerPauses`, `Pauses` — BLUE C9-U04's
  design (`_research/blue-c9-u04-2026-11-23/design/`, its `MD5SUMS.txt` asserted), shipped as written: the kit is already in the house's
  Javadoc form ("Course 9, unit 04: …"), and the filter logs its `KEY …` lines the captures read.
- `IdempotencyKeyTest` (`7`), `TransactionAwareCachingTest` (`3`) — the pinning tests; `TiffinBoxWebTest` gains a `@MockitoBean Pauses`:
  the slice now holds `CustomerPauses` and not the component it calls.
- The five ITs — `bindIpAndPort("127.0.0.1", 2128N)`, a *Course 9, unit 04* Javadoc paragraph each; `ElasticsearchIT`'s own binding
  assertion follows; `CustomerEntityRepositoryIT` and `CustomerAggregatesIT` assert Flyway's history with V5.
- `README.md` of the anchor — unit `04`'s card, and a dated note under the Course 9 header: the header's starting point (Boot `4.1.2`,
  V1-V4, Course 8's IT ports, the set-up's counts) is the set-up's and stays as written.

The hunt (`git grep` over `../c9-tiffinbox` for `4.1.2`, `11.0.27`, `V1-V4`, `four migrations`, `20578`, `20615`, `every interface`,
`12 handler`, `84 tracked`, `idempot`, `exactly once`): every hit outside the README is in a file that now carries a *Course 9, unit 04*
note, which `chk04.py static` asserts file by file; the README's hits are the Course 9 header (noted) and Course 8's unit cards (history,
kept as written). Course 8 unit 08's sentence about the evict after the commit stays true, and is now true for every cache on every run:
the proxy defers each evict made inside a transaction.

R.211/R.331: `grep -n 'c9-tiffinbox\|c8-tiffinbox'` over `C9/_builders/*.py` and the Course 9 tools (`check_unit9.py`, `qa_java9.py`,
`build_java9.py`, `upload_java9.py`, `deck_kit9.py`, `gen_thumbs_java9.py`): `C9/_builders/` holds the tools' twins and the cloner
(`clone_java9_tools.py`, `dur9.py`, `dur9_allow.py`, `rule_sweep9.py`), no unit builder yet; the matches are the cloner's rewrite rules,
`upload_java9.py`'s description link to the anchor's folder and `deck_kit9.py`'s provenance comments. No tool reads a file of the
anchor, so nothing moves with this change but `deck_kit9.BOOT_VERSION` (`4.1.2` → `4.1.3`), which the tools' chain moves, not this
unit. Course 8's builders and receipts read the frozen `c8-*` trees, which this unit does not touch.

## The captures — what each one shows

Each capture is `.r-<name>.out` (git-ignored), checked after it, before the next capture, by `harness/chk04.py <name>` and hashed in `receipts.md5`. PostgreSQL
is `c9u04-pg` on `20931` by the pinned digest; every database sentence below names the database that answered.

The code panel, as the filter and its registration hold them:

```
the key           one RFC 9651 String, 1 to 255 characters from A-Z a-z 0-9 - . _ ~, no parameters; all field lines combined first
the fingerprint   SHA-256 over the method, the request URI and query as sent, and the body's bytes
a stored answer   status, Location, Content-Type and the body - a replay carries only these
the two values    tiffinbox.idempotency.phase2-timeout (default on line 28 of IdempotencyKeys.java)
                  tiffinbox.idempotency.reclaim-after (default on line 29; the start fails unless it is the longer)
kept              a key row is kept, no expiry - not in this course
honoured routes   POST /api/v1/customers/{name}/pauses: the key required (400 without it)
                  POST /customers: the key optional (inert without it); its form passes untouched
                  /customers/import and PATCH: not keyed
problem types     tag:tiffinbox.example,2026:idempotency-key-missing   400  Idempotency-Key is missing
                  tag:tiffinbox.example,2026:idempotency-key-malformed 400  Idempotency-Key is malformed
                  tag:tiffinbox.example,2026:idempotency-key-outstanding 409 A request is outstanding for this Idempotency-Key
                  tag:tiffinbox.example,2026:idempotency-key-reused    422  Idempotency-Key is already used
```

### tests
The version step and the ITs, above. The handler methods, read off `/actuator/mappings` on one flag start of `after/` (the exposure flag
set for that one run, never shipped): the values block gives TiffinBox's total, unit `04`'s two (`CustomerPauses`), and the set-up's count
— the total minus unit `04`'s — which unit `01`'s hook counts. The JVM's own lines: Tomcat `11.0.29`, Hibernate `7.4.15.Final`, Flyway's
five migrations at version `v5`. S9.36 (1): `mvn -o dependency:list` on `after/`, the resolved runtime tree offline from the seed,
its count and the Tomcat, Netty, Spring Boot and Framework coordinates printed in the capture.

### bill
Course 4's *Core Resilience Annotations in Framework 7* (`../c4-unit30`), read the day the receipt runs: its README's bill block and
`.r-bill.out`'s first two lines, which agree. The payment sent twice (C9-12) is named for `Timeouts and Retries From the Caller's Side`;
nothing is measured for it here.

### twice
`POST /customers` with JSON and no key, twice, on H2 and on PostgreSQL: `201`, then `409` with no `type` (about:blank). One row by the
second client. The same body with a fresh name answers `201` (R.312).

### pause — the failure receipt
The harness's unkeyed route, `POST /probe/pauses/Sunil?days=2`, twice: `200` twice and the dashboard's paused days five, seven, nine, on
H2 and on PostgreSQL, the pause rows read by the second client beside them. The code runs and the arithmetic is wrong.

### key
The public route, `POST /api/v1/customers/Sunil/pauses?days=2`, with no body and no `Content-Type`. No key: `400`, typed `…-missing`, the
paused days unchanged. Key `a-1`: `201` with `Location: …/pauses/<id>`, plus two paused days; the same key again: `201`, byte-identical to
the first (`cmp`, `Date` masked), the request witness's handler `none` and two statements, one of them the refused claim `INSERT` — on
PostgreSQL its `log_statement` shows the `INSERT`, the unique-key error and the stored answer's `SELECT` between the markers. The paused
days stay where they were. `GET` the `Location`: `200` with the pause. `POST /customers` with a key twice: `201`, `201` byte-identical, one
row; without a key: `201` (inert). The form at `/customers` with a key: `302`, one row, no key row — passed by its content type, because
a browser's form never sends the header and its re-render must not be stored. `application/json-patch+json` with a key is guarded
(`201`, a key row): Spring MVC's JSON converter reads `application/*+json`, so the scope exempts the form instead of admitting
`application/json` alone.

### mismatch
Key `a-1` with another query, `?days=3`: `422`, typed `…-reused`; the paused days unchanged. Draft `-09`, section `2.7`, in the filed copy
under `_research/docs-2026-11-23/`.

### error
A planted failure after the route's write (the harness's `X-Probe-Fail-After-Write`) on `POST /customers` with key `pl-1`: `500`, no
`Location`, no row, no key row (released); the retry with the same key runs again: `201`, one row.

### race
The first request held after its write inside phase 2 (a planted hold, released by a file the script creates after it has seen the
duplicate's answer): the duplicate answers `409`, typed `…-outstanding`, on the same JVM and, on PostgreSQL, on the second JVM on `20935`
too. PostgreSQL's `pg_locks` shows no waiting lock: the claim was committed alone. The first then answers `201`; the retry after it
gets the first answer, byte-identical.

### tx
A duplicate sent between the stored answer's `UPDATE` and the commit (a planted hold in `beforeCommit`). On PostgreSQL the duplicate's
`UPDATE` waits on the claim's row (`pg_locks`, not granted) and, after the commit, gets the stored answer, byte-identical. On H2 it answers
`409`, typed, while the first is held.

### fence
The receipt's test values (`phase2-timeout` and `reclaim-after` each once on the command line, labelled "the receipt's test values, not
the defaults"): A is held inside phase 2 past its limit and the age; B, the same key and the same bytes, polls and gets `409`s, typed,
until it reclaims the claim (`KEY RECLAIMED`) and commits: `201`. A, released, answers `503` as `application/problem+json` (on the default run's H2 and on PostgreSQL), no `Location`
(`KEY RELEASED after phase 2's time limit (TransactionTimedOutException): 0 key row deleted`). One pause, on H2 in one JVM and on
PostgreSQL across two live JVMs (A on `20932`, B on `20935`); a third try gets B's answer, byte-identical. The count of `409`s depends on
the machine and is masked in the hash.

### plantnofence and plantnolimit
The same run on the shipped filter with one `sed` each, the diff printed in `.harness/`: **no fence** (no token in the answer's `UPDATE`,
its count not asserted, no phase-2 limit, an unfenced release): A `201` with its own `Location` and B `201` — two pauses. **The fence
alone** (no phase-2 limit): A `409`, `KEY ROLLBACK: the claim was reclaimed by another request (the fence)`, one pause.

### killh2 and killpg
`kill -9` of the JVM inside phase 2 (the claim committed, the pause written, nothing committed), its own pid. The client's `curl` gets
an empty reply; on PostgreSQL the key row is `status 0`, claimed, and no session is idle in a transaction. PostgreSQL first: the
`plant-noreclaim` JVM (`AND 1 = 0` in the takeover) still answers `409` past the age — the stuck key RED found; then the shipped JVM's
first retry reclaims, `201`, and one more is byte-identical; one pause. H2 needs a file database for a kill pair, labelled "H2 on a file,
the harness's" (an in-memory H2 dies with its JVM): the shipped JVM answers `409`s until the age, then `201`, then the same answer; one
pause. The second H2 variant BLUE ran (another age) is not run here.

### map
The labelled loser, `probe.u04.MapKeys`: the key's answer in a map inside one JVM, on the harness's unkeyed route, on PostgreSQL. In one
JVM the second try is replayed from the map. After a restart, with PostgreSQL keeping its rows, the map has forgotten the key and the
second pause lands. H2 is not run for this: an in-memory H2 dies with its JVM (PostgreSQL only).

### types
Every answer the filter writes parses as JSON (`json.loads`). The six malformed keys — an escaped quote, two field lines, a parameter, a
Token, an empty String, `256` characters — each answer `400`, typed `…-malformed`, the key never echoed; `255` characters answer `201`.
The two `409`s side by side: the route's own (no `type`) and the filter's (typed); clients branch on `type`, never on `detail` (RFC 9457
sections `3.1.1`, `3.1.3`, `3.1.4`, in the filed copy). The `tag:` URIs are identifiers, not loopback hosts: they appear in this README and
the captures only, never in a spoken line, and `check_unit9.py`'s URL gate meets them only through unit `09`'s plan.

### order, orderpg and orderoff
Course 8's *@Cacheable, @CacheEvict, @CachePut* order, on the shipped tree, H2 and PostgreSQL. Proxy on, no key: inside `add`'s
transaction the list is cached; at the `CustomerAdded` event after the commit still cached; after `add` returns, `[]`. Proxy on, with the
key: `add` returns with the key's transaction still active and the list still cached (the evict deferred); at the event after the commit,
already `[]`; the next `GET` lists the customer. Proxy off, with the key: `add` returns with the transaction active and the list already
`[]`, evicted before the commit. For Course 8's *Capstone: TiffinBox, Cached and Searchable*: unkeyed, the feed's event comes before the
evict, both after the commit; inside the key's transaction the order turns round, the evict at the commit and the event after.

### window, windowpg, windowii, windowiipg and windowoff
Once the `Started` line is printed, before any request, the `customers` cache is empty; on the default run one `GET /actuator/health` reads the list once and caches it in Caffeine; then `GET
/customers` costs no statement. The cause is the kitchen's health indicator, whose read of the customers goes through the cached `findAll()` (its Javadoc's
note from Course 8's *Redis Data Structures From Java* says so), never `start()`, whose read runs before caching is live; this receipt's readiness waits
poll the `Started` line, so the cold state is visible. Held after a keyed write, before the commit: with the proxy, warm, a read inside the
window gets the old list from Caffeine's cache with no statement and, after the commit, the cache is `[]` and the next read lists the customer;
cold, the read inside loads the old list and caches it, and the deferred clear removes it at the commit. Proxy off, warm: after the commit
the list still lacks the customer with no statement — the stale read the proxy removes. The configured time to live is printed as
Caffeine's own `expireAfterWrite` read back, nothing said about it.

### limits and limitspg
A `70,000`-byte JSON body with a key: `413`, `Content Too Large`, no key row (the cap is checked before the body is buffered). Prometheus
after the replays: `http_server_requests_seconds_count` carries the pause route's pattern for its `201`s (replays among them), `400`s,
`409`s, `422` and `503` (the default run, H2). V5's `body` column is `CHARACTER VARYING` on H2 and `text` on PostgreSQL.

### inert
The seven and the old surface with no `Idempotency-Key`, one JVM per request set, on `before/`, `mid`, `after/` and `after/` with the proxy
off: byte-equal (the values block holds the two hashes). The self-test: a planted `ShallowEtagHeaderFilter` on `/*` leaves the seven
unchanged and moves the old surface to the boundary's plant hash — the feed answers nothing when buffered, by bytes.

### exercise
`exercise/README.md`'s block, then `SOLUTION.md`'s, each in an `env -i` shell, bash then `/bin/zsh -f`, from the exercise's folder, on
`after/`'s jar alone (no harness) on `20938`: the broken form fails, the solution passes, and a wrong "solution" — one key and another
`?days=` on the second try — answers `422` and fails the check.

## Which store, which profile, which tree

`before/` is the set-up commit's tree; `mid` the version step alone; `after/` the anchor after this unit. H2 in memory on `20930`
(TiffinBox `after/` with the harness), PostgreSQL `18.6` on `20931` with TiffinBox on `20932` and the second JVM on `20935`. The harness
— `probe.Witness` (datasource-proxy `1.11.1`, on the harness's class path only, never in the anchor's poms), `probe.Http` (the request
witness, ERROR dispatches included), `probe.Routes`, `probe.Etag`, copied from the S1 probe and trimmed; `probe.u04.U04Probe` from BLUE's
kit, its hold's wait made a file watch (no timed wait in `harness/src`); `probe.u04.MapKeys`, written here — joins by
`--spring.main.sources`, never the jar. The PostgreSQL driver is the jar's own (`postgresql-42.7.14.jar`, shipped for "dev" since Course
8). The flag start for `/actuator/mappings` is labelled "never shipped".

## Measured, not shipped

The flag start's mappings. The "dev" window (PostgreSQL, Redis, MongoDB and Elasticsearch live) is not measured at unit `04`: the
post-processor's two Redis cases are covered by `TransactionAwareCachingTest` (a transaction-aware `RedisCacheManager` returned
unchanged, a plain one wrapped once); carried to the next unit that runs "dev". The `limits` variant without the route-pattern fix: not
run.

## Refused, named

These words and readings are refused in this unit's prose and its script, each with the reason the captures give: `harmless` of a double
submit (the `pause` capture counts it twice); `exactly once` (the key makes a repeat get the first answer back, measured per key and per
database, nothing more); the key's `expiry` (a key row is kept: not in this course); a duration on the retry (the `409`s are counted, the
age is a configured value); `safe` said of a retry; the interceptor placement (BLUE C9-S1: a `400` with the body consumed); the in-JVM map
(the `map` capture's loser); the one-transaction design (BLUE C9-S1's measurement: H2's refused lock and PostgreSQL's unbounded block); Redis
as the store; Boot `4.2.0` and `4.1.2` as of `S1B`'s dated decision; the in-controller placement; a time printed under load.

## The repository, and the network

Before this unit's commit `git rev-list --left-right --count origin/main...main` read `0 1`: the set-up commit `80f7839`, local. This
unit's one commit makes it `0 2`, and its `git push` carries both and makes it `0 0`. No network of any kind but that push: every build
offline from `.m2-demo`, a copy-on-write copy of the seed `m2-seed-c9-u04` (the boundary's B5b), no image pulled. S9.36: the advisories'
filed copies — the boundary filed no `advisories/` folder under `_research/docs-*`, so the pom's comment names them as `S1B` and the
contract give them, and no web read was made here.

## The folders, the harness and the ports

`before/`, `after/`, `exercise/` (`README.md`, `SOLUTION.md`, `send.sh` as broken, `check.sh`), `harness/` (`chk04.py`, `s904.py`,
`tree04.py`, `dur9.py`, `src/`), `receipts.sh`, `receipts.md5`. Everything else the run writes is under `.harness/` or `.r-*`, git-ignored.
Ports: `20930`-`20939` (Course 9's unit `04` band) and `21280`-`21284` during `mvn verify` only; Course 8's `20578`, `20615` and
`18881`-`18884` are never bound, and all of them are asserted free at the start and at the end.

## Masks, filters and hygiene

The mask replaces the folders, the home, Spring's and Maven's times, PostgreSQL's log prefix (its time and pid), the claim tokens and the
`Date` header; its self-test runs first. The hash of each capture also masks the one count that depends on the machine — the `409`s a
polling retry gets before the age — and drops the `KEY IN-FLIGHT` lines that count them. Every container is removed with its volumes; the
image and volume counts are asserted back at the end; every JVM is stopped by its token or its pid, never by name.

## Interrupted

<!-- sigint: begin -->
After the three runs of record, the receipt interrupted by a `SIGINT` to its process group (as a terminal's Ctrl-C sends it) once a
file of the run showed the point reached, then checked by another script: no JVM, Maven or Surefire process of the run, no `c9u04-pg`
and no Testcontainers container, volumes `315` and images `9` as at the start, `20930`-`20939` and `21280`-`21284` free, `.r-lock`
gone, every `.r-*.out` capture unchanged (the run writes `.r-*.new` and renames them only at its end), and `../c9-tiffinbox` = `after/`.

```
mid-build    (Maven building mid)                      exit 1 · "*** .harness/mid did not build offline (exit 130) ***" · clean
mid-verify   (ElasticsearchIT's container up)          exit 1 · "the trap: 1 Testcontainers container(s) removed with their volumes (rm -fv)" · clean
mid-race     (the first request held inside phase 2)   exit 1 · "*** race: its check failed ***" · clean
SIGTERM      (a full run, at the PostgreSQL kill pair) exit 143 · clean
```

The exit is `1`, not `130`: the group's signal stops the child first (Maven, the held `curl`), and the receipt's own check of that
child's result stops the run before its `INT` trap runs; the `EXIT` trap then cleans up as above. Not done, said so: mid-harness
(`javac`), mid-container (the PostgreSQL start), mid-TiffinBox on PostgreSQL and mid-`kill` (a killed JVM's restart) — the time cap.
A first attempt sent the `SIGINT` from a shell without job control, where a background job starts with `SIGINT` ignored: the run did
not stop, and it was ended by `SIGTERM` (the last line above).
<!-- sigint: end -->

## Planted faults — each caught

<!-- plants: begin -->
Each made to fail first, on a scratch copy, then removed; each ended with its own `FAIL` or `***` line and a non-zero exit, no
traceback. **In every run of record** (captures): `plant-nofence` → A `201` with its own `Location` and B `201`, two pauses
(`plantnofence`); `plant-nolimit` → A `409`, the fence's rollback, one pause (`plantnolimit`); `plant-noreclaim` → `409` past the age, the
stuck key (`killpg`); the `ShallowEtagHeaderFilter` on `/*` → the seven unchanged, the old surface moved (`inert`); the proxy off → the
stale read (`windowoff`); a wrong "solution", another `?days=` under the one key → `422`, the check fails (`exercise`). **The S9.34 order
test** on a copy of `after/` whose `IdempotencyKeys.ORDER` is `Ordered.HIGHEST_PRECEDENCE`: `mvn -o test` of that one test fails
(`Tests run: 1, Failures: 1`, AssertJ's "to be greater than"), and on the shipped `-90` it passes. **The checker** (`harness/chk04.py`
on planted copies of a run's captures and of `after/`), each a `FAIL` line and exit `1`:

```
an IT on 127.0.0.2: exit 1 · FAIL MongoDatastoreIT binds 27017 -> 127.0.0.1:21283, once, by bindIpAndPort (found [('127.0.0.2', '21283', '27017')])
an IT's port off by one: exit 1 · FAIL ElasticsearchIT binds 9200 -> 127.0.0.1:21284, once, by bindIpAndPort (found [('127.0.0.1', '21285', '9200')])
an IT without its modifier: exit 1 · FAIL RedisDatastoreIT binds 6379 -> 127.0.0.1:21282, once, by bindIpAndPort (found [])
a Course 8 port back (20578): exit 1 · FAIL MongoDatastoreIT binds 27017 -> 127.0.0.1:21283, once, by bindIpAndPort (found [('127.0.0.1', '20578', '27017')])
a stale sentence left (4.1.2 with no note): exit 1 · FAIL R.250: tiffinbox-core/pom.xml still says '4.1.2' with no Course 9, unit 04 note
a harness import in src/main: exit 1 · FAIL src/main holds no harness class and no X-Probe header
the order -90 changed to HIGHEST_PRECEDENCE: exit 1 · FAIL IdempotencyKeys.ORDER = -90
a replay typed equal when cmp differs: exit 1 · FAIL (ii) try 2 byte-identical (cmp)
a 409 typed where the capture holds 422: exit 1 · FAIL another query under a stored key: 422 ...-reused
one IT BINDINGS line removed (4 classes): exit 1 · FAIL IT BINDINGS: classes 5 (found 4)
the tests typed wrong (after/ = before/): exit 1 · FAIL after/ adds tests: 18 + 0
two pauses typed one (the fence): exit 1 · FAIL ONE pause
a changed What-it-prints line: exit 1 · FAIL exercise/README.md's What it prints = the broken run's lines
the seven moved: exit 1 · FAIL after: the seven = 466c20ed
an unparsable listing fed to chk04 key: exit 1 · FAIL no key: no line matches '\\(i\\) no key: .* -> (\\d{3})'
an unparsable listing fed to chk04 tests: exit 1 · FAIL no before section
an unparsable listing fed to chk04 fence: exit 1 · FAIL the slow original's lines
an unparsable listing fed to chk04 exercise: exit 1 · FAIL broken (bash): FAIL
an unparsable listing fed to chk04 inert: exit 1 · FAIL the expected hashes
an unparsable listing fed to chk04 kill: exit 1 · FAIL no checks for the capture 'kill'
an unparsable Surefire XML: exit 1 · FAIL the checker could not read its input (ParseError: not well-formed (invalid token): line 1, column 4)
the cannot-fail detector: an empty capture: exit 1 · FAIL every duplicate while the first is held: 409 ...-outstanding (0)
the README's 18 + k typed wrong (the values block): exit 1 · FAIL the values block differs from this run's:
```

**The receipt's own gates**, on the sealed clone:

```
before/ one byte off the set-up commit: exit 1 · *** before/ is not c9-tiffinbox at the set-up commit 80f7839 (diff -rq: Files before/README.md and .harness/setup/c9-tiffinbox/README.md differ) ***
src/main of before/ changed: exit 1 · *** before/ is not c9-tiffinbox at the set-up commit 80f7839 (diff -rq: Files before/tiffinbox-web/src/main/java/com/tiffinbox/web/Revenue.java and .harness/setup/c9-tiff
a duration word in the README: exit 1 · *** a refused word or reading in this unit's prose:   README.md line 469: dur8: two seconds;  README.md line 469: R.388's family: two seconds ***
a status in the hundred form in the README: exit 1 · *** a refused word or reading in this unit's prose:   README.md line 469: XU04: U04: a status said as digits or in the hundred form ***
a placeholder line: exit 1 · *** a placeholder in this unit's prose or exercise: README.md:<the planted line> ***
the exercise's solution = the broken form: exit 1 · *** R.196: SOLUTION.md's block must be the README's with one line changed ***
a container removed without -v: exit 1 · *** R.387: receipts.sh removes a container without its volumes (found: dk rm -f|dk rm -fv) ***
the docker CLI unpinned: exit 1 · *** R.344: receipts.sh calls docker without the pinned socket: 445:noop2() { docker ps > /dev/null; } ***
a Course 8 port (20578) bound, DOCKER_HOST=tcp://127.0.0.1:1 in the environment: exit 1 · *** something already listens on 20578 - this unit's ports must be free ***
a Downloading from line in a build log: exit 1 · *** dl.log: Maven's log says it downloaded (offline: no) ***
```

**The prose gate**, one plant per family, each refused; the near misses pass:

```
"A double submit is harmless.": refused 1
"The pause lands exactly once.": refused 1
"The key expires.": refused 2
"Key retention is short.": refused 3
"Delivery is guaranteed.": refused 2
"POST is idempotent by default.": refused 2
"The client is automatically retried.": refused 2
"The filter answers four hundred and twenty-two.": refused 1
"The retry lands in two seconds.": refused 2
"Then the cache catches up.": refused 1
"A replay is faster.": refused 4
"REST requires a key.": refused 1
"Most APIs do this.": refused 1
"The second try lands at once.": refused 2
"The filter answers 422 here.": refused 1
"The retry is safe.": refused 3
NEAR MISS "The filter answers four twenty-two.": refused: 0
NEAR MISS "The route answers four oh nine.": refused: 0
NEAR MISS "It says that a lifetime exists, not its value.": refused: 0
NEAR MISS "Paused days go from five to seven.": refused: 0
```
<!-- plants: end -->

## What differed from the brief

<!-- differed: begin -->
- **`before/` is a frozen copy, not a link.** The contract (`SC :188`, "From then on" `:200`) and the set-up document (`SETUP` `:325`-`:348`) give unit
  `04`'s `before` as the link to `../c8-unitLL/after`; the orchestrator's instruction for this unit is a frozen copy of `../c9-tiffinbox` at
  the set-up commit, so the receipt asserts against that commit (`git archive`). Both readings hold: `before/` differs from
  `../c8-unit27/after` by its README alone, and the receipt prints that diff. The link form resumes at unit `05`.
- **The exercise sends a fresh key per try**, as BLUE C9-U04 #2 decided over the brief's "posts twice with no header": on the shipped
  public route a request with no key is a `400` and counts nothing.
- **The fence's test values run on their own JVMs.** The first development runs carried the test values on every harness JVM, and
  phase 2's test limit ended every longer hold (`race`, `window`, `order`) with `503` on the default run. The holds now run on JVMs with the shipped
  defaults; only the fence's and the kill pairs' JVMs carry the test values, labelled.
- **The PostgreSQL driver is the jar's own** (`postgresql-42.7.14.jar` in `after/`'s `BOOT-INF/lib`, shipped for "dev" since Course 8),
  not a harness driver: the brief's "`lib/` holds no `postgresql-*.jar`" (Course 8's R.335 form) does not hold for this tree. The receipt
  asserts the jar's driver is there and uses it.
- **PostgreSQL runs with trust on the loopback** (`127.0.0.1:20931` alone, asserted), as Course 8 unit 27's receipt ran it; no password
  exists to generate or print.
- **The `map` capture's source** is a filter written here (`probe.u04.MapKeys`, on the harness's unkeyed route), modelled on the S1
  probe's `Keys.java` map store; H2's restart is not run (PostgreSQL only).
- **The `kill` pair's second H2 variant** (BLUE's second age) is not run; the first is. The "dev" window is not run (optional; carried).
- **The dur9 pin**: `harness/dur9.py` is `_builders/dur9.py` as shipped; the receipt asserts it equal to the builders' file and to the md5
  `java9_series.py` pins (read off that file, never typed). The prompt's older pin value was BLUE C9-TOOLS's, before BLUE ROUND 2.
- **The two configured values** are given as property names with "default on line N of `IdempotencyKeys.java`", in a code panel; no
  duration form is written anywhere in the prose (dur9 over the README and the exercise: none).
- **The four `tag:` URIs** appear in this README and the captures only; `check_unit9.py`'s URL gate meets them through unit `09`.
- **The kitchen's warm cache.** The brief attributes it to Course 8 unit 14: the health indicator is older, and unit 14's Javadoc note on
  it says its read is the cached `findAll()` since unit 08. The warmth after the first health check is measured either way (`window`).
- **The advisories (S9.36)**: no `advisories/` folder was filed under `_research/docs-*`; the pom's comment names them as `S1B` and the
  contract give them, and no web read was made.
- **3/3 is across the three runs of record**: each capture runs once per run, and its hash must equal `receipts.md5`'s in all three.
- **Numbers that moved from the brief's**: the tests are `18` + `10` at `package` (the brief: `18 + k`), the ITs `14`; the paused days of the
  hook and the key are the brief's; the `409` counts of a polling retry are machine-dependent and masked in the hash.
<!-- differed: end -->

## For RED

<!-- red: begin -->
- The hook (`pause`) and the exercise's sentence (`exercise`) are the brief's, byte for byte; their captures above.
- A script must not say `harmless`, `exactly once`, the key's `expiry`, a duration on the retry, or `safe` of a retry (Refused, named).
- The gloss is the brief's line, once; "idempotent" is said only with the route's measured second answer.
- The call-backs, by title only: *Core Resilience Annotations in Framework 7* (its numbers read off `../c4-unit30` the day the receipt
  runs), *@Cacheable, @CacheEvict, @CachePut*, *Capstone: TiffinBox, Cached and Searchable*, *Redis Data Structures From Java* (the health
  indicator's note); C9-12 → `Timeouts and Retries From the Caller's Side`.
- RED-C9-U04's rows, each with its capture: `#1` (`kill -9` inside phase 2 leaves a stuck key) → `killpg`, `killh2`, `fence`; `#2` (the body-less route) →
  `key`; `#3` (the two `409`s) → `types`; `#4` (the warm cache, the order) → `window`, `order`; `#5` (an error's headers) → `error`; `#6`
  (JSON by concatenation, the key echoed) → `types`; `#7` (a hand-built manager, nested decorators) → `TransactionAwareCachingTest`; `#8` (the proxy is another feature) → `mid`, `orderoff`, `windowoff`, `inert`'s proxy-off pair; `#9` (the order test) → `IdempotencyKeyTest`
  and its plant; `#10` (the hold for shipped code) → the harness's advice on the shipped beans; `#12` (R.480's launch rule) → `guard`;
  `#13`-`#21` → `types` (format), `race` (hold placement), `error` (the freed key), the code panel (`no expiry`), `limits` (the body cap),
  `key` (the stored parts), `key`'s `GET` (the GET route), `window` (the cold window), `race` (the held loser's witness).
<!-- red: end -->

## The ledger rows this unit pays

<!-- ledger: begin -->
- Roadmap: `_briefs/TRACK-ROADMAP.md`'s line for unit `04`, as it reads:

```
- 04 **Idempotency, Safety and Retries** — an idempotency key implemented; a double-submit proved harmless.
```

  The key is implemented and measured; the double submit is measured, with the key, as one pause counted once (`key`, `exercise`), and
  the roadmap's last word is refused in this unit's prose without the key and the counts.
- **C9-7** paid: the bill read off `../c4-unit30`, called back by title (`bill`).
- **C9-11** paid for this anchor change: the seven and the old surface on `before/`, `mid` and `after/` (`inert`).
- **C9-12** named, handed to unit `21` by title (`bill`'s last line).
- **C9-18** (the problem-type scheme → unit `09`), **C9-19** (`kept, no expiry — not in this course`, said once here), **C9-20** (a replay
  carries four parts → unit `12`): the ledger rows the boundary added; this unit's captures are their source.
<!-- ledger: end -->

## The values the video may say

Every value below is a run's own, re-derived by `harness/chk04.py` and asserted equal to this block at the end of every run.

<!-- values: begin -->
```
tests: tests_before=18 tests_mid=18 tests_after=28 tests_k=10 its=14 it_entries=5 lib_before=146 lib_mid=146 lib_after=146 bom_moved=36 bom_total=195 handlers_total=14 handlers_u04=2 handlers_setup=12
bill: bill_attempts=3 bill_charged=1020
inert: seven=466c20ed surface=316a9637
window: window_h2=health->warm
twice: twice_h2=201/409
pause: pause_h2=5->7->9
key: replay_statements_h2=2 replay_writes_h2=1 key_h2=9->11->11
mismatch: mismatch_h2=11
error: 
race: race_h2=409x1
tx: tx_h2=201/409
types: 
order: order_h2=ok
windowii: ttl_h2=PT10M
limits: body_type_h2=CHARACTER_VARYING
orderoff: order_h2_off=ok
windowoff: ttl_off_h2=PT10M
fence: fence_h2_pauses=1 fence_h2_A=503 fence_h2_B=201
plantnofence: plant_nofence_pauses=2 plant_nofence_A=201 plant_nofence_B=201
plantnolimit: plant_nolimit_pauses=1 plant_nolimit_A=409 plant_nolimit_B=201
killh2: kill_h2=+1 kill_k3_409s_h2=masked
windowpg: window_pg=health->warm
twicepg: twice_pg=201/409
pausepg: pause_pg=5->7->9
keypg: replay_statements_pg=2 replay_writes_pg=1 key_pg=9->11->11
mismatchpg: mismatch_pg=11
errorpg: 
racepg: race_pg=409x2
txpg: tx_pg=201/201
typespg: 
orderpg: order_pg=ok
windowiipg: ttl_pg=PT10M
limitspg: body_type_pg=text
fencepg: fence_pg_pauses=1 fence_pg_A=503 fence_pg_B=201
map: map_pg=3->3->4->4
killpg: kill_pg=+1 kill_k3_409s_pg=masked
exercise: exercise=broken-FAIL,solved-PASS,wrong-FAIL
```
<!-- values: end -->

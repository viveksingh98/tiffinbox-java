# c7-unit09 — @OneToMany/@ManyToOne and the Owning Side

Course 7 · Data with JPA & Hibernate · Section 2 (Mapping), its fourth unit, and **the course's fourth change to the anchor — Section
2's last** · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Hibernate ORM 7.4.13.Final, Jakarta Persistence
3.2.0, H2 2.5.250 — the anchor's pin — HikariCP 7.0.2), 2026-11-04, **on H2 only** (brief ⚑2: the probe found 09's DDL and SQL the same
on PostgreSQL; this unit speaks for H2 and says so). A foreign key lives in one table, so one side of a relationship owns it. The
**owning side** is the field Hibernate writes the foreign key from — here the pause's `customer`, because `customer_id` is a column of
the pause table; the **inverse side** is the other one, the customer's list of pauses, marked `mappedBy` and read through that key, never
written. Measured: one customer and two pauses mapped three ways (a unidirectional list with `@JoinColumn`, a bare unidirectional list,
bidirectional with `mappedBy`); a pause added to the inverse side only; four mappings on TiffinBox's own `pause` table, whose
`customer_id` is `NOT NULL`; and TiffinBox's own entities, which now map its pauses.

**The anchor changes (brief ⚑1) — and freezes for Section 2.** `after/` is this unit's frozen copy of `../c7-tiffinbox` after the change;
`before` is the link to `../c7-unit07/after`, the anchor before it. Units 10-14 build on `after/` (their `anchor` links point here) and
change nothing in it. `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets after ../c7-tiffinbox` at its start and end —
empty in every run of record — and, from any later anchor change on, prints a note instead (R.211). Both trees are copied under
`.harness/` and built there, never in place. What changed (`anchor` prints the file list, `CustomerEntity.java`'s diff and
`PauseEntity.java`'s code lines):

- `tiffinbox-core/src/main/java/com/tiffinbox/PauseEntity.java` — **new**: `@Entity @Table(name = "pause")`, an IDENTITY id,
  `@ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "customer_id") CustomerEntity customer`, `int days`; a
  constructor `PauseEntity(CustomerEntity customer, int days)` that sets the owning side; the getters; a Javadoc that says which side owns.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java` — `@OneToMany(mappedBy = "customer") List<PauseEntity> pauses` (no
  cascade), `getPauses()`, and two Javadoc paragraphs (the field's, and one in the class's).
- `README.md` — the anchor's: its unit 09 section, and the header's note (Section 2's last anchor change).
- **Kept, unchanged** (R.180): `Database` (`pause.customer_id BIGINT NOT NULL REFERENCES customer(id)` — `anchor` greps it; the seed),
  `CustomerRepository`, `application.yaml` (`ddl-auto: none`), the 18 tests, the web layer (it reads the record `Customer`, never the
  entities).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 8 captures, 3 runs each; every spoken number checked after its capture; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first), and when a check after a capture fails. **Start it in
a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be
seeded first (below). No Docker, no container, no password: every database is H2 in a JVM's memory.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own,
`.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Three development runs fixed the captures and the checks (the first stopped at `anchor`'s check: the anchor README had no unit 09
section yet; the second at a check's indentation of `PauseEntity.java`'s lines; the third — after this README's own sentence about the
struck claim was reworded, which the refusal had caught — wrote every capture 3/3 with every check passing, and its md5s are
`receipts.md5`); then `inverse`'s check was reordered to read the row first (the witness before the in-memory line; no capture
changed). **The runs of record, on the
script as committed (`receipts.sh` md5 `4b0c9581a0a82676930aa8142cee455b`): 249 s under `./receipts.sh`** (/bin/bash 3.2.57) **and 284 s under `bash
receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 8 captures 3/3 = published, every check passed, each of the two builds `offline:
yes · exit 0 · 'Downloaded from' lines in its log: 0` (and `tests`' `offline: yes`, inside its capture), nothing listening on
19880-19889 at the end; each terminal log through `check_unit7.py 09 --runlog` — `RESULT (run logs): PASS` (the unit gate answers "no
09-*.md … nothing to check": no script yet). **Nothing was downloaded**, and this unit made no network act. After this README's last prose was written, one more `./receipts.sh` on the tree as committed (`env -i`, a session of
its own): exit 0 in 166 s, all 8 = published, `--runlog` PASS. (The two runs of record above ran beside unit 07's re-run and the plants on
a busy machine; the sealed clone and this run had it to themselves.)

Published hashes: shapes `52cf5c3b51b4d35694b73ecaae0a370a` · inverse `682073ecb4fa0ac3c7ea5504a1ad1bfe` · ownpause `4f6b84afea51ecf33b54e1871a7c91f2` · anchor `e74164b05e10887e971eb3a00e2cd8e7` · seven `56dfa4aac9f7fb2f163c4836555b0889` · tests `56b0251ebe01abece53c6094c0c379ab` · xcheck `9072c6f11c8c8e713c997b58d3a79d74` · exercise `7a2a954365ecc0f281e19c03f707036d`.

**For units 10-14 — Boot's script for the anchor's two entities, md5 `f595637014e786fa38606859951e4f97`** (the `xcheck` capture, published `9072c6f11c8c8e713c997b58d3a79d74`): each harness
unit of 10-14 compares its harness's DDL for `com.tiffinbox.CustomerEntity` and `com.tiffinbox.PauseEntity` with this md5 — "Boot's
script as 09 captured it" (R.212) — as unit 08 compared with unit 07's `820b43fc…`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 07's recipe, with this unit's folder and no Docker:

```bash
S=/tmp/sealed09; W="/tmp/sealed 09"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" "$W" && git clone -q "file://$T" "$W/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/../../data-jpa-hibernate/_research/m2-seed-c7-s2/" "$S/central/"
printf 'MAVEN_OPTS="-Duser.home=%s $MAVEN_OPTS"\n' "$S/home" > "$S/home/.mavenrc"
cat > "$S/home/.m2/settings.xml" <<XML
<settings>
  <mirrors><mirror><id>sealed</id><mirrorOf>*</mirrorOf><url>file://$S/central</url></mirror></mirrors>
  <proxies>
    <proxy><id>dead-http</id><active>true</active><protocol>http</protocol><host>127.0.0.1</host><port>9</port></proxy>
    <proxy><id>dead-https</id><active>true</active><protocol>https</protocol><host>127.0.0.1</host><port>9</port></proxy>
  </proxies>
</settings>
XML
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X"
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$W/tiffinbox-java/c7-unit09" && readlink before && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-04):** a `git clone` of tiffinbox-java at `8e77e27` into a path **with a space** (`…/sealed 09/tiffinbox-java`), this
commit's 73 files put in as git takes them (`git ls-files -m` and `-o --exclude-standard`, each `cmp`-equal to the working tree; `before`
→ `../c7-unit07/after` by `readlink`); a `file://` copy of the s2 seed (4,971 files); pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the dead proxies, a session of its
own: **exit 0 in 165 s, all 8 = published, every check passed**; each build `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`;
after the run `.m2-demo` held 4,971 files, 0 `_remote.repositories`; the builders' `dur7.py` is not beside a clone (the terminal says so;
its md5 is the check). Its terminal log through `--runlog`: PASS. (The clone's README was this file before its last prose was filled in;
this README passes the same gates in the run on the tree as committed, above.)

## The commands this unit adds

```bash
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/map/H.java harness/src/probe/map/Main.java harness/src/probe/map/shapes/*.java harness/src/probe/map/own/*.java
java -Duser.language=en -Duser.country=US -Dlogback.configurationFile=../../harness/logback.xml "${V[@]}" -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.map.Main "${A[@]}"
```

The harness compiled against `after/`'s extracted jar (91 libraries); **the harness line** (run from `.harness/run`: `V` its JVM flags,
`A` its arguments — R.193, each printed as `$ V=(…)` / `$ A=(…)`). The lines read from `after/README.md` (6, each asserted whole) are
unit 07's but its POST and its extracted-jar line: `mvn -B package`, `mvn -B clean test`, the run line, the extract line, the GET of `/customers`, and the
first-entity lesson's DDL line (the run line with the two schema-generation options: asserted to be that and nothing else).

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Three builds: `before/`'s and `after/`'s `package` (each runs
its 18 tests) and `tests`' `clean test`; each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived
from the build log, never typed). After the builds the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`,
`hibernate-core-7.4.13.Final.jar` and `h2-2.5.250.jar`. **At run time** every request goes to `127.0.0.1`; every database is H2 in a
JVM's memory (the harness's, TiffinBox's `jdbc:h2:mem:tiffinbox`). **No network act**: this unit reads no version file — unit 06 made
Section 2's dated sweep (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-04.xml`, md5 `f9f50873…`: 4.1.2 the newest
4.1.x GA, 4.1.3 absent, no 4.2 GA; R.223), and no Section 2 unit speaks a "newest" fact (⚑6).

## The demo token

TiffinBox's runs (`anchor`, `seven`, `xcheck`) start in a copy under `.harness/` holding a config tree with a 32-character demo token
(`secrets/tiffinbox/shutdown-token`, never committed, listed before every start); `harness/shutdown.sh` and `$CURLSET` read it from that
file. It is masked as `[masked: the 32-character token]`; the checks count 0 raw copies in every raw capture run, every capture and every
log. The harness's `Database` is given its own harness-only token argument (`harness-only-not-a-secret-u09`, 29 characters: the record's
16+-character rule), which no capture prints.

## The locale

Every java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it; the test fork's
comes from the POM's `argLine`. **The harness prints ASCII** (` | ` between facts).

## The folders, the harness and the ports

- `after/` — the anchor after this change; `before` — the link to `../c7-unit07/after`. `.harness/before`, `.harness/after` — copied,
  each with a config tree, built with the README's `mvn -B package` offline, each jar extracted (91 libraries); `.harness/hc` — the
  harness, compiled; `.harness/run` — where every harness JVM starts (its scripts land there); `.harness/tests` — `tests`' copy;
  `.harness/ex` — the exercise's classes.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/map`, package `probe.map`; a check refuses `probe.map` anywhere in
  after/'s code). `H.java` is unit 08's (H2 in memory only) with `jdbcUrl()` (the URL the shipped `Database` is given), `reset()` (Hibernate's
  `Statistics` cleared and the driver counters set to 0 before the counted work), `counted()` (the `Statistics` line, each counter named by
  what it counts: `statements prepared (getPrepareStatementCount)`, `entity inserts`, `entity updates (getEntityUpdateCount)`, `collection
  recreates`, `collection updates` — S2.3/R.208) and `tx()` (07's: `before commit` / `after commit` around the commit). **Not a Boot
  application** (⚑3, R.212): one `EntityManagerFactory` per run, Jakarta Persistence 3.2's `PersistenceConfiguration` over the classes the
  run names, Boot's two naming strategies, statistics on, `drop-and-create` on the run's own database only (R.178; `own`, `anchor` and
  `xcheck` set it to `none` — the shipped `Database` makes the tables); the JDBC proxy of unit 06 beside it. Every run prints
  `org.hibernate.Version.getVersionString()` first and Hibernate's own `HHH000001` line (its core logger at INFO — R.222), then its
  `database:` line. Scenarios (`Main.java`): `shapes KIND FILE`, `inverse`, `own VARIANT`, `anchor FILE`, `ex CLASS`, `xcheck FILE`.
  Entities, English names only: `probe.map.shapes` — `UniCustomer`/`UniPause` (`@OneToMany(cascade = PERSIST) @JoinColumn(name =
  "customer_id")`), `JtCustomer`/`JtPause` (`@OneToMany(cascade = PERSIST)`, nothing else), `BiCustomer`/`BiPause` (`mappedBy = "customer"`,
  `@ManyToOne @JoinColumn(name = "customer_id")`, `addPause` sets both sides); `probe.map.own` — on `Database`'s own tables: `OwnBase` (a
  `@MappedSuperclass` with the customer table's five columns), `BiOwnCustomer`/`BiOwnPause` (A, A′: `mappedBy`, `@ManyToOne(optional =
  false)`), `UniOwnCustomer` (B), `NnOwnCustomer` (B2: `nullable = false`), `NuOwnCustomer` (C: `nullable = false, updatable = false`), each
  with `OwnPause` (`id`, `days`); `probe.map.ex` — the exercise's `ExCustomer`/`ExPause` (never compiled into `.harness/hc`, asserted).
  `harness/logback.xml` — unit 08's, its comment naming this lesson; `harness/shutdown.sh` (the CORS lesson's), `harness/surefire.py` (the
  testing lesson's) and `harness/dur7.py` (the builders', md5 `41667fed…`), byte for byte.
- **Ports** (§P, 19880-19889): `anchor`'s TiffinBox run 19880 · `seven` 19881 · `xcheck`'s Boot run 19882 · 19889 never bound (asserted
  free first and last; a JVM that listens there is killed and the run dies); 19883-19888 unused and checked free. 18425, 8080 and 35729
  checked free first and last. The harness's JVMs, `tests` and the exercise bind none.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on a planted line): the token → `[masked: the 32-character token]`; this
   folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; H2's generated database name;
   an identity hash → `@…`; **Hibernate's generated constraint names** → `FK<hash>` (`FK` and 25 characters Hibernate derives from the
   table and column names — `FKm2mc7dy22sku3hjrgease2abs` is `bi_pause`'s; nobody's code writes them).
2. **A harness log** (`hview`): every line, trailing spaces dropped.
3. **A TiffinBox log** (`tview`): the lines of `TiffinBoxServer`, `org.hibernate.orm.core`, Hikari's pool, `org.hibernate.SQL` and
   `LocalContainerEntityManagerFactoryBean`; the SQL logger's lines counted, WARN and ERROR counted.
4. **A Maven log**: its `$` line, exit, `BUILD` line, `offline`; Surefire's reports with the console's summary beside their sum.
5. **Hygiene, checked last over every capture** (unit 07's list): no absolute path, no unit number (a `diff`'s `-`/`+` lines may quote
   one), no Boot process line, no time, no log time, no thread number, no JDK/OS version token, no unmasked generated database name, **no
   unmasked constraint name**, no random port, no per-run timing figure, no stack frame; every `$` line's URL 127.0.0.1's; every java line
   pinned; one `secrets/` listing per TiffinBox start; `GenerationTarget encountered exception` 0 in every harness and Boot log (R.213); no
   SQL keyword as a harness name; no H2 database file anywhere in this folder; no `pkill`/`killall`; no bare `wait`; no one-string
   multi-option variable (R.193); **no Indian dish name** in any capture (R.215).
6. **Duration words** (R.172): `dur7.DUR` over this README and the exercise's two files must find **0** — this unit speaks no time; one
   match stops the run before anything is built. **Dish names** (R.215): 41 words, whole words, any case, refused in this README,
   `exercise/` and `harness/src` before anything is built, and in every capture at the end. **The claim RED #307 struck**: a line of this
   README or the exercise's files in which the attribute's name follows the restricting word RED #307 struck, within one sentence, is
   refused before anything is built (`receipts.sh` holds the pattern) — `ownpause` C writes one statement per row with no `mappedBy` at all.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`), sweeps its own process group for any
TiffinBox JVM, harness JVM (`probe.map.Main`), Maven or Surefire fork left, deletes the capture runs it had not finished (`.r-NAME.1-3`),
and removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-04, the sealed clone, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own
**with SIGINT at its default**, `kill -INT` to its group once the named process was in it, the state read 5 s later — three trials, each
**exit 130, nothing left**:

```
build: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
boot: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the first Maven (`before/`'s package, its Surefire fork); `harness` — the first harness JVM (`shapes` 1); `boot` — TiffinBox
itself (`anchor`, port 19880). `pgrep -fl java` afterwards: none.

## 1 · shapes — one customer, two pauses, three mappings (S2.3)

Ravi with two pauses (3 and 5 days), `cascade = PERSIST`, one transaction, markers `before persist()` · `after persist()` · `before commit`
· `after commit`; each count from two witnesses, the SQL logger's lines and `getPrepareStatementCount()` (R.184), with the driver's
`prepareStatement`/`executeUpdate` beside them. **Shape 1, a unidirectional list with `@JoinColumn(name = "customer_id")`:** `uni_pause
(days integer not null, customer_id bigint, id …)`; 3 INSERTs, the pauses' **without `customer_id`** (`insert into uni_pause (days,id)
values (?,default)`), then after `before commit` **2 × `update uni_pause set customer_id=? where id=?`** — **5 statements** (5 SQL lines,
`getPrepareStatementCount` 5, `executeUpdate` 5) — and **`Statistics`: entity updates (`getEntityUpdateCount`) 0**, collection recreates 1:
the two UPDATEs are the collection's, and the entity counter cannot see them (ⓘ4, S2.3). **Shape 2, a bare unidirectional list:** a join
table, `jt_customer_pauses (jt_customer_id bigint not null, pauses_id bigint not null unique)`, two foreign keys (`FK<hash>`); 3 INSERTs,
then after `before commit` 2 × `insert into jt_customer_pauses` — 5 statements. **Shape 3, bidirectional, `mappedBy = "customer"`, both
sides set:** **3 INSERTs, each pause's carrying `customer_id`**, nothing after `before commit` — 3 statements. Each reads back `[3, 5]` in a
new EntityManager; the raw rows by a second connection.

## 2 · inverse — a pause added to the inverse side only

Kavya persisted; then, in the same EntityManager, a pause of 4 days persisted and added to `kavya.getPauses()` only — its customer never
set (in memory: Kavya's pauses 1, the pause's customer null). The bind logger: `insert into bi_pause (customer_id,days,id) values
(?,?,default)` with **`binding parameter (1:BIGINT) <- [null]`**; 1 statement; `Statistics`: **collection updates 1** (it counted the list
— which wrote nothing; ⓘ5); a second connection reads **`[1 | null | 4]`** (id, customer_id, days); a new EntityManager reads **Kavya's
pauses 0**. No error, no warning: the list is the inverse side, and Hibernate writes `customer_id` from the owning side alone.

## 3 · ownpause — TiffinBox's own pause table, four mappings (A/B/B2/C/A′, the failure receipt)

Each JVM: the shipped `Database` (`new Database(new TiffinBoxProperties(…))`, `createAndSeed()`) makes and seeds its tables on the run's
database — customers 1-4, pauses `[1 | 3 | 3, 2 | 4 | 2]` — Hibernate's schema generation off; then Kavya with one pause of 3 days,
`cascade = PERSIST`.
- **A — bidirectional** (`BiOwnCustomer` `mappedBy`, `BiOwnPause` `@ManyToOne(optional = false) @JoinColumn(name = "customer_id")`, both
  sides set): `insert into customer …` · `insert into pause (customer_id,days,id) values (?,?,default)` · nothing after `before commit` —
  **2 statements**; the pause row `3 | 5 | 3`.
- **B — unidirectional, the default `@JoinColumn`** — **the failure receipt**: `insert into pause (days,id) values (?,default)` refused
  inside `persist()` — **`NULL not allowed for column "CUSTOMER_ID"`** (H2 23502, logged as two WARN lines), **exit 1**,
  `ConstraintViolationException` ← `JdbcSQLIntegrityConstraintViolationException`; the transaction rolled back: **nothing written**
  (customers 1-4, pauses the two seeded). The trio: exit 1 · the exception · the tables unchanged.
- **B2 — `@JoinColumn(name = "customer_id", nullable = false)`**: the pause's INSERT carries `customer_id` — **and the UPDATE stays**: after
  `before commit`, `update pause set customer_id=? where id=?` — **3 statements** for a customer and one pause. `nullable = false` fixes
  the `NOT NULL` refusal, not the extra write (READ FIRST 6; said as Hibernate 7.4.13's behaviour on this capture — its `HHH000001` line
  and `getVersionString()` are in it, R.222).
- **C — `@JoinColumn(name = "customer_id", nullable = false, updatable = false)`**: the FK in the INSERT, **no UPDATE** — **2
  statements** (RED #307, BLUE re-measured). Said as what it is: the join column made read-only for the collection's updates, so the INSERT
  is the only write.
- **A′ = A**, re-run in a JVM of its own: the same lines (asserted equal, R.1).

## 4 · anchor — TiffinBox's own entities on the shipped Database's tables (the change's witness, RED #319)

The change: `diff -rq before after` → `README.md`, `CustomerEntity.java`, `PauseEntity.java (new)`; `CustomerEntity.java`'s diff (5 hunks,
20 lines in, 0 out); `PauseEntity.java`'s code lines; `Database.java`'s pause table by `grep -n`: **`44: customer_id BIGINT NOT NULL
REFERENCES customer(id),`** (unchanged). Then the shipped `Database` seeds this run's database, and the anchor's entities, from `after/`'s
jar, read every customer's pauses (`getPauses()`, then each `getDays()`): **`Ravi [] | Meera [] | Sunil [3] | Priya [2]`** — **5
statements** (5 `select` lines = `getPrepareStatementCount` 5, `executeQuery` 5: one for the customers, one per customer's pauses — the
count only; *N+1, Measured* is that lesson's, never explained here). A pause of 5 days for Ravi from the owning side
(`getReference(CustomerEntity.class, 1L)`, `new PauseEntity(ravi, 5)`): **one INSERT** with `customer_id`, 1 statement; a second connection
reads **`3 | 1 | 5`**. **Hibernate's DDL for the two** (a file, never run): `create table pause (days integer not null, customer_id bigint
not null, id …)` and `alter table if exists pause add constraint FK<hash> foreign key (customer_id) references customer` — the columns
`Database` creates. **TiffinBox itself** (after/'s jar, port 19880): ready, `GET /customers` → the four, 200 (read by `CustomerRepository`,
JDBC); its log `HHH000001: Hibernate ORM core version 7.4.13.Final`, `Initialized JPA EntityManagerFactory` 1, 0 SQL lines — it starts
with the two entities mapped (a guard: a context that starts is not a mapping that works — the harness's read above is the witness).

## 5 · seven — a guard (R.190)

`before/`'s jar and `after/`'s, port 19881, a fresh JVM each: **`466c20ed7e0d5439cb052f32ce09de1b` on both**, lines that differ 0; each
log `HHH000001 … 7.4.13.Final`, the pool `url=jdbc:h2:mem:tiffinbox`. Equal by construction: the web layer never reads the entities.

## 6 · tests — TiffinBox's tests (C7-4)

`cd .harness/tests && mvn -o -B -Dmaven.repo.local="$M2" clean test`: exit 0, BUILD SUCCESS, offline: yes; `TiffinBoxWebTest` 14,
`FullStackTest` 3, `FeedTest` 1 — **18**, failures 0, the console's summary the same; 2 `Initialized JPA EntityManagerFactory`, 0 SQL lines:
a guard, not a witness.

## 7 · xcheck — the harness's DDL against Boot's (R.212)

Boot's: `after/`'s jar with the first-entity lesson's DDL line (port 19882, stopped by POST /shutdown) writes `hibernate-ddl.sql`; the
harness's: its own EntityManagerFactory over `com.tiffinbox.CustomerEntity` and `com.tiffinbox.PauseEntity`, `xcheck.sql`. Both three
lines — `create table customer (…, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id));`, `create table pause (days
integer not null, customer_id bigint not null, id bigint generated by default as identity, primary key (id));`, `alter table if exists
pause add constraint FK<hash> foreign key (customer_id) references customer;` — **`cmp`: the same, byte for byte, md5 `f595637014e786fa38606859951e4f97`** (unit
07's was `820b43fc…`: the pause table now). **Units 10-14 compare their harness's script with this md5 — "Boot's script as 09 captured
it"** (R.212).

## 8 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s 7 lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: the copy of `ExCustomer.java` made with
`sed`, its `addPause` given `pause.setCustomer(this);`), each block sourced in one `env -i` shell, `/bin/bash --noprofile --norc` then
`/bin/zsh -f`; each block in a fresh JVM. In both: the README → exit 0, **`[1 | null | 4]`**, Kavya's pauses 0; the solution → exit 0,
**`[1 | 1 | 4]`**, Kavya's pauses 1; the shell back in this folder; bash's output = zsh's.

## Exercise

**Your turn:** the README adds a pause to Kavya's list and the table never hears who it belongs to. Fix it.
(21 words, `wc -w` on the quoted sentence, asserted in `receipts.sh`.) `exercise/README.md` ships `ExCustomer.addPause` adding to the list
only, `exercise/SOLUTION.md` beside it; broken (`customer_id null`) ≠ solved (`customer_id 1`), each from its own fresh JVM, measured by
the `exercise` capture (R.196).

## The anchor's README — what this unit changed in it

- **A new section**, `## Course 7 · unit 09 — the owning side: …`, after unit 07's: the new file and the changed one, why the pause owns the
  relationship (the three mappings of `ownpause`, each said with its count), what the entities read (the four, five statements — the count
  only, *N+1, Measured* by title), Hibernate's DDL beside `Database`'s, the tests and the seven unchanged.
- **The header** — a note: a pause is an entity since unit 09, and **this is Section 2's last change to the folder: units 10-14 measure
  this tree through their links to `../c7-unit09/after`.**
- No history note below the rule was made false (`grep -n -i pause` over it: the Course 5 lines about `/pauses` and `pausedDays` are
  TiffinBox's routes and dashboard, unchanged).

## The shipped receipts on the moved anchor (R.211)

`../c7-unit07/receipts.sh` (unchanged, md5 `f05048bd…`) run once on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, a
session of its own, 2026-11-04 from 22:01 CET: **exit 0 in 458 s** (the machine busy with this unit's runs beside it), the note `(after/ and
../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files after/README.md and ../c7-tiffinbox/README.md differ;Files
after/…/CustomerEntity.java and …)` at its start and end, no line saying "= ../c7-tiffinbox", all 10 captures 3/3 = published, its own
container (`c7-u07-pg`, 127.0.0.1:19868, its design) started and removed, `receipts.md5` unchanged, `check_unit7.py 07 --runlog` PASS; its
README gains one dated paragraph saying so.

`../c7-unit08/receipts.sh` (unchanged, md5 `0ad1322e…`) run once on the moved anchor the same way, from 21:56 CET: **exit 0 in 71 s**,
its anchor check's note (`anchor/ and ../c7-tiffinbox differ …`) at its start and end, all 7 captures 3/3 = published (its `xcheck` still
`820b43fc…`: its entity is unit 07's tree's), `receipts.md5` unchanged, `check_unit7.py 08 --runlog` PASS; its README gains one dated
paragraph.

Units 01-06 were not re-run (brief and this unit's order: their notes are unit 06's form, exercised by 07's anchor change; nothing in
this change touches their frozen trees or scripts). No builder asserts `c7-tiffinbox` against a unit's tree (unit 06's `grep`: the one
assert was s703:41, fixed there).

## The ledger rows and hand-offs this unit pays

- **C7-4 — re-run**: 18, unchanged (`tests`), a guard (R.190).
- No other row is paid here (the brief's §LEDGER: 09 pays C7-4 only). The 5-statement read of the four customers' pauses is handed to
  *N+1, Measured* (U30) and *JOIN FETCH vs @EntityGraph vs @BatchSize* (U31), by title.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: `customer_id null` / `customer_id 1`, a fresh JVM each half |
| 2 | the shipped `Database` built in code on the harness's URL, H2: `ownpause` (×5) and `anchor` |
| 8 | the anchor change on the frozen tree (`09/after`): `PauseEntity`, `CustomerEntity.pauses`, their Javadoc; the README |
| 12 | `xcheck` on `09/after`: `f595637014e786fa38606859951e4f97` (the pause table and its foreign key added) |
| — | ⚑8's "not yet run on 42.7.14: U09" — this unit runs on H2 only and loads no Postgres driver; BLUE's PG run of #307 on 42.7.14 (`ANUCustomer` 2 statements, `ANCustomer` 3) is cited, not re-run |

## What differed from the brief

1. **H2 only, `ownpause` included** (the brief's Beats are H2; BLUE's PostgreSQL re-measurement of RED #307 on driver 42.7.14 —
   `nullable = false, updatable = false` 2 statements, `nullable = false` 3 — is cited, not re-run). No container, no password, no driver
   resolved: this unit's `receipts.sh` has no Docker line at all.
2. **`anchor`'s Boot run (19880) is a guard, not a POST** (unit 07 POSTed Kavya on Postgres): with H2 in TiffinBox's own JVM, the run
   shows TiffinBox starting with the two entities mapped (`Initialized JPA EntityManagerFactory` 1, `HHH000001`), its customers served by
   `CustomerRepository`; the witness of the change is the harness's seed read through the entities (RED #319), which fails on the plant below.
3. **B is refused inside `persist()`, not at the commit**: IDENTITY sends each INSERT when `persist` cascades to the pause, so the trio's
   lines come before `after persist()` (asserted absent); the customer's INSERT rolls back with it (customers 1-4 after). `Statistics`
   counts both INSERTs as prepared (2) — prepared, not written.
4. **The days and names the brief left open**: `shapes` — Ravi with 3 and 5 days; `inverse` and `ownpause` — Kavya (4 days; 3 days);
   the exercise — Kavya, 4 days. The probe's `1 | 4 | null` is printed in the order `id | customer_id | days` (`1 | null | 4`).
5. **The anchor's pause from the owning side uses `getReference(CustomerEntity.class, 1L)`**: one INSERT, 1 statement, no SELECT for Ravi
   (a `find` would add one); the row `3 | 1 | 5` is the probe's.
6. **`CustomerEntity.pauses` has no cascade and no helper; `PauseEntity`'s constructor sets the owning side only** (the brief names
   `@OneToMany(mappedBy = "customer")` alone): a constructor that also added itself to the customer's list would load that list — a
   SELECT — on every new pause. No TiffinBox path writes a pause through the entities yet (CARRIED).
7. **`xcheck` covers both entities**: Boot scans `com.tiffinbox`, so its script now holds the `pause` table and its foreign key; the
   harness is given `CustomerEntity` and `PauseEntity`. The md5 units 10-14 compare with is that three-line script's.
8. **Constraint names are masked in captures (`FK<hash>`); the scripts' md5s are of the unmasked files** — `cmp` and the md5 compare the
   files byte for byte, as Boot and the harness wrote them.
9. **The struck claim (RED #307) is refused by this receipt** over this README and the exercise's files; the SAY-line refusal is the
   builder's (s709, CARRIED).
10. **The exercise's broken half exits 0**: the bug is silent. Broken ≠ solved is measured by the row (`customer_id null` / `1`) and the
    new EntityManager's count (0 / 1), never by the exit code.
11. **`inverse` runs with the bind logger at TRACE**, to show `customer_id` bound `null` (the brief's "bound null").
12. **Statistics' counters are printed under what they count** (`statements prepared (getPrepareStatementCount)`, `entity updates
    (getEntityUpdateCount)`, `collection recreates`, `collection updates` — R.206, R.208), so a slide quoting one cannot mislabel it.
13. **Unit 07's receipt starts its own container** when it is re-run on the moved anchor (its design: `c7-u07-pg`, the image by digest,
    `--pull never`, 127.0.0.1:19868, removed by it) — the only container of this session; this unit's own work ran none.
14. **The anchor README's header note says Section 2's anchor is frozen** at this tree (units 10-14 through their links), and
    `CustomerEntity`'s Javadoc names unit 09 in two places (as unit 07's did).
15. **Plants on copies**, as unit 07's: each a scratch mirror of the pieces this unit reads (`c7-unit09`, `c7-unit07/after`, `c7-tiffinbox`,
    the three shared scripts; `.m2-demo` an APFS clone of this unit's), the captures before the planted one left out where named and the
    planted capture's hash taken out of the mirror's `receipts.md5` so its check speaks; most ran beside each other and beside the runs of
    record (no port is bound before `anchor`).

## Planted faults — each caught (R.65)

In every run: `ownpause` B is the failure receipt (the trio), and `shapes` 1's two UPDATEs beside `entity updates 0` are the hook's check.
On copies (What differed, 15), each **exit 1**, nothing written to this folder, 0 listeners on 19880-19889 after it:
- **The owning side set in `inverse`** (`Main.inverse()` given `pause.setCustomer(kavya)` after the list's add; `shapes` left out,
  `inverse` out of `receipts.md5`) → `*** inverse: customer_id null: expected the line:   PROBE bi_pause, read by a second connection (id |
  customer_id | days): [1 | null | 4] ***` (74 s).
- **`getEntityUpdateCount()` as the UPDATE witness** (`chk_shapes`' count of the two UPDATEs read from the `Statistics` line's `entity
  updates` instead of the SQL log; the capture unchanged) → `*** shapes 1: two UPDATEs (update uni_pause set customer_id=?), after before
  commit, and nothing else there - counted from the SQL log (0) ***` (89 s) — S2.3's plant: the counter reads 0 for two UPDATEs.
- **`nullable = false` claimed to remove the UPDATE** (`chk_ownpause` expecting 2 statements for B2) → `*** ownpause B2 (nullable =
  false): the UPDATE kept: 2 statements - the SQL log's lines (3) and getPrepareStatementCount() (3) both (R.184) ***` (103 s).
- **The struck claim in a SAY line** (a README line `> SAY: ` + the restricting word + `mappedBy writes one statement per row.`) → `*** a
  line says … writes one statement per row - ownpause C shows two statements without it (RED #307): README.md:332:… ***`
  (2 s), before anything is built.
- **`updatable = false` dropped from C** (`NuOwnCustomer`'s `@JoinColumn(name = "customer_id", nullable = false)`; `ownpause` out of
  `receipts.md5`) → `*** ownpause C (nullable = false, updatable = false): no UPDATE: 2 statements - the SQL log's lines (3) and
  getPrepareStatementCount() (3) both (R.184) ***` (129 s) — the count flips to 3.
- **A constraint name unmasked** (the `FK<hash>` `gsub` taken out of `mask()`) → `*** mask: the planted JDK version, generated database
  name, token, folders, home, identity hash and constraint name must be masked ***` (91 s, after the builds, before any capture); the
  hygiene's `FK[0-9a-z]{10,}` over every capture and `shapes`' own check are the nets behind it.
- **A wrong published hash** (`receipts.md5`'s `shapes` with its last digit changed) → `*** shapes is not the published capture … ***`
  (130 s).
- **A version claim without its `HHH000001` line** (`harness/logback.xml` without its `org.hibernate.orm.core` logger; `shapes` out of
  `receipts.md5`) → `*** shapes: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its 3 harness JVMs
  (R.222) ***` (131 s).
- **An Indian dish name** (one README line naming a dish on the list) → `*** an Indian dish name (R.215: English names only):
  README.md:332:… ***` (2 s), before anything is built.
- **One per capture class:** `shapes` — `JtCustomer` given `@JoinColumn(name = "customer_id")` (no join table) → `*** shapes 2: expected
  the line:     create table jt_customer_pauses (jt_customer_id bigint not null, pauses_id bigint not null unique); ***` (129 s);
  `exercise` — `SOLUTION.md`'s `sed` given a pattern that matches nothing (four spaces of indent for eight: the copy unchanged, still one
  line differing from the README's) → `*** exercise: the solution - customer_id 1: expected the line:     PROBE ex_pause, read by a second
  connection (id | customer_id | days): [1 | 1 | 4] ***` (149 s); `anchor` — `PauseEntity`'s
  `@JoinColumn(name = "cust_id")` in the mirror's `after/` (`shapes`…`ownpause` left out, `anchor` out of `receipts.md5`) → `*** anchor: the
  seed read through the entities: expected the line:   PROBE read by Hibernate (the anchor's two entities): Ravi [] | Meera [] | Sunil [3] |
  Priya [2] ***` (39 s) — the capture held `SQLGrammarException: … Column "P1_0.CUST_ID" not found`, the read failing at its first lazy
  list; `xcheck` — the harness's DDL over `CustomerEntity` alone (`shapes`…`tests` left out, `xcheck` out of `receipts.md5`) → `*** xcheck:
  the harness's DDL is not Boot's, byte for byte ***` (37 s). `seven` and `tests` are guards (R.190): no plant of this change can move
  them, which is what they show.

## Found on the way

- **IDENTITY refuses B at `persist()`**: the pause's INSERT is sent when `persist` cascades, so a mapping that cannot write the row fails
  before any commit — and `getPrepareStatementCount()` counts the refused statement (2 for B).
- **`Statistics` says `collection updates 1` for the inverse-side add that wrote nothing** (ⓘ5, reproduced) and `collection recreates 1`
  for shapes 1-3 and A/B2/C — collection events, not statements.
- **A bare unidirectional `@OneToMany` makes its join table's `pauses_id` `unique`**: JPA's one-to-many through a join table, each pause
  in one customer's list at most.
- **The anchor's seed read is one SELECT per customer's list even for the two with no pauses** (Ravi, Meera): a lazy collection is read
  when it is touched, empty or not — the count only here (U30's).
- **This README's own sentence about the struck claim tripped the refusal** on the first run of the check (the third development run):
  the pattern reads prose, not intent; the sentence was reworded (What differed, 9).
- The harness's core logger at INFO prints `HHH000489: No JTA platform available …` in every harness JVM — deterministic, kept in the
  captures as Hibernate prints it.

## CARRIED

- The 5-statement read of the four customers' pauses → *N+1, Measured* (U30), *JOIN FETCH vs @EntityGraph vs @BatchSize* (U31).
- The inverse side kept in step with the owning side in TiffinBox's own code (a helper on `CustomerEntity` that sets both) → not added
  here: no TiffinBox path writes a pause through the entities yet; *Cascades and Orphan Removal* (U11) works on this shape in its harness.
- A pause with no customer on the anchor's `PauseEntity` (`optional = false`): what Hibernate does before any SQL was not measured here.
- PostgreSQL for `ownpause` → BLUE's run of #307 (H2 = PG, 42.7.14), cited; no Section 2 unit after this one re-runs it.
- `10-14`'s `xcheck` compares with this unit's `f595637014e786fa38606859951e4f97` ("Boot's script as 09 captured it", R.212).
- The builder (s709) must refuse the dish-name list and the struck claim (RED #307) in SAY lines and on slides, and assert `duration
  words: 0` (R.172) itself.

## For RED

Re-run from a clean tree (seeded `.m2-demo`, `HOME` with dead proxies) in a process group of its own; ports 20200-20239 for any re-run
of this unit's JVMs outside its script. Worth breaking: whether B2 and C differ in one attribute only (`NnOwnCustomer.java` and
`NuOwnCustomer.java`, `diff`: the `@JoinColumn` line and the Javadoc's description); whether `getPrepareStatementCount()` and the SQL lines
could agree while both miss a statement (the driver's `executeUpdate` count is printed beside them); whether the struck-claim pattern can
be paraphrased past (it can: it is this receipt's net over its own prose; the builder must check the SAY lines); whether the anchor's
`optional = false` changes the inverse-side trap on TiffinBox's own table (not measured: CARRIED); whether the five-statement read is
stable (it is the lazy list's, one per customer, 3/3 here). Evidence by a Claude Opus 5.5 agent on 2026-11-04.

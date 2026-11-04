# c7-unit10 — @OneToOne and @ManyToMany

Course 7 · Data with JPA & Hibernate · Section 2 (Mapping), its fifth unit — **a harness unit: no change to the anchor** · Verified on
**JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the
anchor's pin — HikariCP 7.0.2), 2026-11-04, **on H2 only** (brief ⚑2: the probe found 10's DDL and SQL the same on PostgreSQL; this unit
speaks for H2 and says so). A one-to-one puts the foreign key in one of the two tables — here the customer's, `wallet_id bigint unique`:
the `unique` is what makes it one-to-one. Found from the customer's side, the wallet waits as a proxy; found from the wallet's side,
Hibernate asks for the customer at once, because the wallet's row has no column that says whether one exists. A many-to-many keeps its
pairs in a **join table** (a table of two foreign keys, one row per pair); mapped as a `List`, that table has no primary key, and
removing one favourite meal rewrites all of them. And the facts about a pair — how many meals a day, since when — need an entity of
their own in the middle.

**No anchor change (brief ⚑1).** `anchor` is the link to `../c7-unit09/after`, the tree Section 2 froze (units 10-14 measure it and
change nothing in it). `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox` at its start and end —
empty in every run of record — and, from any later anchor change on, prints a note instead, never a stop (R.211, Course 6's form). The
anchor is copied under `.harness/anchor` and built there, never in place.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 5 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first), and when a check after a capture fails. **Start it in
a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be
seeded first (below). No Docker, no container, no password, no TiffinBox JVM: every database is H2 in a harness JVM's memory.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own, `.m2-demo`
seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Four development runs fixed the captures and the checks (the first stopped at a shell syntax error in the
script as assembled; the second at the keyword net over the harness's own SQL — Found on the way; the third wrote every capture 3/3
with every check passing, and its md5s are `receipts.md5`; the fourth, after the checks were reordered so each plant's named check
speaks first — What differed, 9 — read all five `= published`).
**The runs of record, on the script as committed (`receipts.sh` md5 `38e596b19c9d9ea48d3e019570a2a635`): 69 s under `./receipts.sh`**
(/bin/bash 3.2.57) **and 63 s under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 5 captures 3/3 = published, every
check passed, the one build `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty at the start and the
end, nothing listening on 18425, 8080, 35729 or 19890-19899 at the end; each terminal log through `check_unit7.py 10 --runlog` — `0 grep
error line(s)`, `RESULT (run logs): PASS` (the unit gate answers "no 10-*.md … nothing to check": no script yet). The builders'
`_builders/dur7.py` over this README and the exercise's two files: 0 duration words. **Nothing was downloaded**, and this unit made no
network act. After this README's prose was written (but this sentence), one more `./receipts.sh` on the tree as committed (`env
-i`, a session of its own): exit 0 in 62 s, all 5 = published, `--runlog` PASS.

Published hashes: one `187602919a9a501ae9846deed0633d09` · many `d587f45a0daf45de82c8da86379fb7d5` · middle `f958fb62e43a60156d7d0f1c1771d778` · xcheck `becd7570f9ce7365f469f1f029d2150b` · exercise `0ddc70a92a525e4ac36d287cbd03fd94`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 09's recipe, with this unit's folder:

```bash
S=/tmp/sealed10; W="/tmp/sealed 10"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit10" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-04):** a `git clone` of tiffinbox-java at `9853dae` into a path **with a space** (`…/sealed 10/tiffinbox-java`), this
commit's 20 files put in as git takes them (`git ls-files -o --exclude-standard c7-unit10`, each `cmp`-equal to the working tree; `anchor`
→ `../c7-unit09/after` by `readlink`); a `file://` copy of the s2 seed (4,971 files); pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the dead proxies, a session of its
own: **exit 0 in 66 s, all 5 = published, every check passed**; the build `offline: yes · exit 0 · 'Downloaded from' lines in its log:
0`; after the run `.m2-demo` held 4,971 files, 0 `_remote.repositories`; the builders' `dur7.py` and unit 09's captures are not beside a
clone (the terminal says so for each; `dur7.py`'s md5 and Boot's script md5 are the checks). Its terminal log through `--runlog`: PASS.

## The commands this unit adds

```bash
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/map/H.java harness/src/probe/map/Main.java harness/src/probe/map/one/*.java harness/src/probe/map/many/*.java harness/src/probe/map/middle/*.java
java -Duser.language=en -Duser.country=US -Dlogback.configurationFile=../../harness/logback.xml "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.map.Main "${A[@]}"
```

The harness compiled against the anchor's extracted jar (91 libraries); **the harness line** (run from `.harness/run`: `V` its JVM flags,
`A` its arguments — R.193, each printed as `$ V=(…)` / `$ A=(…)`). The lines read from `anchor/README.md` (2, each asserted whole):
`mvn -B package` and the extract line — unit 08's.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). One build: the anchor's `package` (its 18 tests run inside
it), `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from the build log, never typed). After
it the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar` and `h2-2.5.250.jar`.
**At run time** nothing leaves the computer: every database is H2 in a harness JVM's memory. **No network act**: this unit reads no
version file — unit 06 made Section 2's dated sweep (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-04.xml`, md5
`f9f50873…`: 4.1.2 the newest 4.1.x GA, 4.1.3 absent, no 4.2 GA; R.223), and no Section 2 unit speaks a "newest" fact (⚑6). **No
PostgreSQL driver is loaded** (H2 only): the brief's AMENDMENT names "U10-U11 … on 42.7.14 → their units' receipts"; for this unit there is
no Postgres run to put on 42.7.14 — see "What differed", 1.

## The locale

Every java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it; the test fork's
comes from the POM's `argLine`. **The harness prints ASCII** (` | ` between facts).

## The folders, the harness and the ports

- `anchor` — the link to `../c7-unit09/after` (asserted: a link, that target). `.harness/anchor` — its copy, built with the README's
  `mvn -B package` offline, its jar extracted (91 libraries); `.harness/hc` — the harness, compiled; `.harness/run` — where every harness
  JVM starts (its scripts land there); `.harness/ex` — the exercise's classes.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/map`, package `probe.map`; a check refuses `probe.map` anywhere in
  the anchor's code). `H.java` is unit 09's with two additions: **`writes`** — the JDBC proxy now keeps, for every `executeUpdate`, **the
  number the driver returned** (the rows the database says it changed) and the statement's SQL, printed by `written()` as `returned N <-
  <sql>` (RED #321: "all three rows" is that number, never inferred); and **`loaded()`** — `emf.getPersistenceUnitUtil().isLoaded(entity,
  attribute)`, the persistence unit's own answer, the witness for "lazy" beside the class name (RED #323). Unit 09's `reset()` (now also
  clearing `writes`), `counted()` (each `Statistics` counter named by what it counts — R.206, R.208) and `tx()` (`before commit` / `after
  commit`) are unchanged. **Not a Boot application** (⚑3, R.212): one `EntityManagerFactory` per run, Jakarta Persistence 3.2's
  `PersistenceConfiguration` over the classes the run names, Boot's two naming strategies, statistics on, `drop-and-create` on the run's
  own database only (R.178; `xcheck` sets it to `none`: a script only). Every run prints `org.hibernate.Version.getVersionString()` first
  and Hibernate's own `HHH000001` line (its core logger at INFO — R.222), then its `database:` line. Scenarios (`Main.java`): `one SIDE
  FILE`, `many KIND FILE`, `middle FILE`, `ex CLASS`, `xcheck FILE`. Entities, English names only (S2.10, R.215): `probe.map.one` —
  `WalletCustomer` (`@OneToOne(fetch = LAZY, cascade = PERSIST) @JoinColumn(name = "wallet_id") Wallet wallet`) and `Wallet` (`int
  balance`, `@OneToOne(mappedBy = "wallet", fetch = LAZY) WalletCustomer customer`); `probe.map.many` — `Meal` (`name`: Platter, Salad,
  Soup), `ListFan` (`@ManyToMany List<Meal> favourites`), `SetFan` (`Set<Meal>`), `OrderedFan` (`@ManyToMany @OrderColumn List<Meal>`);
  `probe.map.middle` — `SubCustomer`, `Subscription` (`@ManyToOne(optional = false)` customer and meal, `int mealsPerDay`, `LocalDate
  since`); `probe.map.ex` — the exercise's `ExFan`/`ExMeal` (never compiled into `.harness/hc`, asserted). `harness/logback.xml` — unit
  09's, its comment naming this lesson; `harness/dur7.py` — the builders', md5 `41667fed…`, byte for byte.
- **Ports** (§P, 19890-19899): **none bound.** 19899 is asserted free at the start and the end, with 19890-19898, 18425, 8080 and 35729.
  The harness's JVMs and the exercise bind none; the anchor's tests (inside its package build) bind what TiffinBox's tests bind.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on a planted line): this folder → `…`, the folder above → `…/..`, home → `~`, the
   user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; **Hibernate's generated constraint names** → `FK<hash>` (and
   `UK<hash>`, should one appear — none does: the one-to-one's `unique` is written inline), 25 characters Hibernate derives from the table
   and column names, nobody's code. The scripts' md5s are of the unmasked files (`xcheck` compares those).
2. **A harness log** (`hview`): every line, trailing spaces dropped.
3. **A Maven log**: never printed in a capture; its `$` line, exit, `offline` and `Downloaded from` count go to the terminal.
4. **Hygiene, checked last over every capture** (unit 08's list): no absolute path, no unit number, no time, no log time, no thread
   number, no JDK/OS version token, no unmasked generated database name, **no unmasked constraint name**, no port, no per-run timing
   figure, no stack frame; every java line pinned; `GenerationTarget encountered exception` 0 in every harness log (R.213); no SQL keyword
   as an entity or field name (the entity sources; the SQL the harness sends is not a name); no H2 database file anywhere in this folder;
   no `pkill`/`killall`; no bare `wait`; no one-string multi-option variable (R.193); **no Indian dish name** in any capture (R.215).
5. **Duration words** (R.172): `dur7.DUR` over this README and the exercise's two files must find **0** — this unit speaks no time; one
   match stops the run before anything is built. **Dish names** (R.215, S2.10): 41 words, whole words, any case, refused in this README,
   `exercise/` and `harness/src` before anything is built, and in every capture at the end. **R.201:** bytecode enhancement is not measured
   here (no enhancement plugin in the seed), so a line of this README or the exercise's files that names it must say "not measured" in
   that same line, and no capture names it — the brief's sentence about the inverse side waiting with it stays labelled or cut.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`), sweeps its own process group for any
harness JVM (`probe.map.Main`), Maven or Surefire fork left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes
`.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-04, a scratch mirror holding the five published captures, the script as committed):** `./receipts.sh` (/bin/bash 3.2)
started in a session of its own with SIGINT at its default, `kill -INT` to its group once the named process was in it, the state read 5 s
later — each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 2 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 2 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
exercise: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the anchor's Maven (its Surefire fork); `harness` — the first harness JVM (`one` A); `exercise` — the exercise's shell
(`ex-drive.sh`, bash). `pgrep -fl java` afterwards: none.

## 1 · one — a customer and his wallet, one-to-one (A/B, RED #323)

The script (A's; B writes the same, `cmp` asserted): `create table wallet (balance integer not null, id …, primary key (id));` ·
**`create table wallet_customer (id …, wallet_id bigint unique, name varchar(255), primary key (id));`** · `alter table if exists
wallet_customer add constraint FK<hash> foreign key (wallet_id) references wallet;` — the foreign key in the owning side's table, and its
**`unique`**: that is what makes it one-to-one in the table. Ravi and a wallet of 500 persisted (`[1 | Ravi | 1]`, `[1 | 500]` by a
second connection). Then, in a new EntityManager, the counters reset:

- **A — `find(WalletCustomer.class, 1)`** (the owning side): **1 statement** (the SQL log's 1 line = `getPrepareStatementCount()` 1 = the
  driver's `prepareStatement` 1, R.184), `select … from wallet_customer wc1_0 where wc1_0.id=?`; **`isLoaded(customer, "wallet")
  false`** and the wallet's class **`probe.map.one.Wallet$HibernateProxy`** — both asserted (`lazy()`).
- **B — `find(Wallet.class, 1)`** (the inverse side, `fetch = LAZY` written on it): **2 statements**, inside `find()`, in this order:
  `select w1_0.id,w1_0.balance from wallet w1_0 where w1_0.id=?`, then **`select … from wallet_customer wc1_0 where wc1_0.wallet_id=?`**;
  **`isLoaded(wallet, "customer") true`**, the customer's class **`probe.map.one.WalletCustomer`** — no proxy.

The voice: "the wallet's row has no column that says whether a customer exists, so Hibernate asks" — said as the two lines' order in the
log (S2.11). **"With bytecode enhancement it can wait" is not measured here** (R.201): label it "not measured here" on screen or cut it.

## 2 · many — three favourite meals, Salad removed (A/B/C, RED #321)

Each: Platter, Salad, Soup persisted with Ravi holding all three; the join table read by a second connection — **3 rows**; then, in a new
transaction, Ravi found, Salad removed; `before remove(Salad)` / `before commit` / `after commit`; the counters (reset before the
transaction); **what each `executeUpdate` returned**; the join table again — **2 rows**; a new EntityManager reads `[Platter, Soup]`.
Every write comes after `before commit`, none at `remove()` (asserted).

| | the join table's DDL | the writes after `before commit` (what the driver returned) | statements (2 are the reads) |
|---|---|---|---|
| **A `List`** | `list_fan_favourites (favourites_id bigint not null, list_fan_id bigint not null)` — **no primary key** | **`delete from list_fan_favourites where list_fan_id=?` → returned 3**, then 2 × `insert …` → 1 each: **3 writes** | 5 |
| **B `Set`** | `set_fan_favourites (…, primary key (favourites_id, set_fan_id))` | **`delete from set_fan_favourites where set_fan_id=? and favourites_id=?` → returned 1**: 1 write | 3 |
| **C `@OrderColumn`** | `ordered_fan_favourites (favourites_order integer not null check ((favourites_order>=0)), …, primary key (favourites_order, ordered_fan_id))` | `delete … where ordered_fan_id=? and favourites_order=?` → 1, `update … set favourites_id=? where … favourites_order=?` → 1 (Soup moves into position 1): 2 writes | 4 |

The rows by a second connection: A and B `[1 | 1, 2 | 1, 3 | 1]` → `[1 | 1, 3 | 1]` (favourites_id | fan id); C `[0 | 1 | 1, 1 | 2 | 1,
2 | 3 | 1]` → `[0 | 1 | 1, 1 | 3 | 1]` (position | favourites_id | fan id). **`Statistics`: `collection updates 1`** in all three, `entity
updates (getEntityUpdateCount) 0` (S2.3, R.208) — the statement count and the driver's return values are the witnesses, never "Hibernate
counted N updates". **The hook's "deletes all three rows" is the DELETE's own return value, 3, printed in the capture** (RED #321); the
3 → 2 by a second connection is beside it.

## 3 · middle — the entity in the middle

`Subscription` (`SubCustomer customer`, `Meal meal`, both `@ManyToOne(optional = false)`, `int mealsPerDay`, `LocalDate since`):
**`create table subscription (meals_per_day integer not null, since date, customer_id bigint not null, id bigint generated by default
as identity, meal_id bigint not null, primary key (id));`** + two foreign keys. Platter, Ravi and one subscription (2 a day, since
2026-11-04) persisted: **3 INSERTs** (`statements prepared 3`, `entity inserts 3`), the row `1 | 1 | 1 | 2 | 2026-11-04` (id | customer_id
| meal_id | meals_per_day | since) by a second connection. The voice: "how many a day, and since when — a join table has nowhere to put
them" (said as a capability shown, not an opinion).

## 4 · xcheck — the harness's DDL against Boot's, as unit 09 captured it (R.212, RED #308)

The harness's own EntityManagerFactory over `com.tiffinbox.CustomerEntity` and `com.tiffinbox.PauseEntity` (from the anchor's jar)
writes `xcheck.sql`: three lines (`create table customer …`, `create table pause …`, the foreign key), **md5
`f595637014e786fa38606859951e4f97` = Boot's script as unit 09 captured it** — the md5 read from `../c7-unit09/README.md` (asserted
there) and that capture's own published md5 `9072c6f1…` read from `../c7-unit09/receipts.md5` before any build. **No Boot run** (this unit
binds no port). When `../c7-unit09/.r-xcheck.out` is on disk with its published md5, Boot's three lines (constraint name masked there)
are read from it and each asserted in this capture too (a clone has no captures: the md5 is the comparison, said on the terminal).

## 5 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s 7 lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: the copy of `ExFan.java` made with
`sed`, its `List<ExMeal> favourites = new ArrayList<>()` made `Set<ExMeal> favourites = new HashSet<>()`), each block sourced in one
`env -i` shell, `/bin/bash --noprofile --norc` then `/bin/zsh -f`; each block in a fresh JVM. In both: the README → exit 0,
**`executeUpdate calls: 3`** — `returned 3 <- delete from ex_fan_favourites where ex_fan_id=?` and two INSERTs back; the solution →
exit 0, **`executeUpdate calls: 1`** — `returned 1 <- delete … where ex_fan_id=? and favourites_id=?`; 2 rows left both times; the shell
back in this folder; bash's output = zsh's.

## Exercise

**Your turn:** the README removes one favourite meal and Hibernate rewrites the whole list. Change the collection type so it doesn't.
(21 words, `wc -w` on the quoted sentence, asserted in `receipts.sh`.) `exercise/README.md` ships `ExFan.favourites` as a `List`,
`exercise/SOLUTION.md` beside it; broken (3 writes) ≠ solved (1 write), each from its own fresh JVM, measured by the `exercise` capture
(R.196). Both exit 0 and both leave 2 rows: the difference is the writes, never the exit code or the table.

## What the video may say — and the capture each comes from

- `wallet_id bigint unique` — the `unique` makes it one-to-one (`one`, the script).
- From the customer: **one** SELECT, the wallet **not loaded** (`isLoaded … false`), a `Wallet$HibernateProxy` (`one` A).
- From the wallet, `LAZY` written: **two** SELECTs, the second `… where wallet_id=?`, the customer loaded, no proxy (`one` B).
- Remove Salad from a `List`: **a DELETE that removed all three rows (the driver returned 3) and two INSERTs** — three writes for one
  removal; the join table has **no primary key** (`many` A). From a `Set`: **one DELETE, one row** (`many` B). `@OrderColumn`: a DELETE
  and an UPDATE (`many` C). `collection updates 1` all three — said as what it counts.
- The entity in the middle: `meals_per_day integer not null, since date`, three INSERTs (`middle`).
- The harness's DDL = Boot's (`xcheck`). The exercise: 3 writes → 1 (`exercise`).
- "Hibernate 7" for the version (§3); the captures each print `7.4.13.Final` twice (R.222). **On H2** (R.173, R.217).

## The ledger rows and hand-offs this unit pays

- No ledger row is paid here (the brief's §LEDGER names none for 10).
- The lazy `@OneToOne` inverse side with bytecode enhancement → not measured (CARRIED, the brief's own line: U29/U31's brief decides).

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: 3 writes / 1 write, a fresh JVM each half |
| 9 | English names: `Wallet`, `Meal` "Platter" / "Salad" / "Soup" in the DDL, rows and reads (the probe's names renamed); the dish list refused over prose, harness and captures |
| 12 | `xcheck` on `09/after`: `f595637014e786fa38606859951e4f97` (Boot's script as 09 captured it) |
| — | ⚑8's "not yet run on 42.7.14: … U10-U11" — not applicable to this unit: see What differed, 1 |

## What differed from the brief

1. **H2 only, and the AMENDMENT's "U10-U11 … on 42.7.14 → their units' receipts" does not apply here.** That line (and ⚑8's "Not yet
   run on 42.7.14: … U10-U11") is about the probe's PostgreSQL runs on driver 42.7.13; ⚑2 makes 10 an H2 unit (its Beats say "(H2)"), so
   this receipt runs no Postgres and loads no Postgres driver — there is no run of 10 on any Postgres driver to repeat. The probe's
   finding that 10's DDL and SQL are the same on PostgreSQL (Step 5, "both DBs identical") stays the probe's, on 42.7.13, and no slide
   of this unit may speak for Postgres (R.217). A Postgres run for 10 on 42.7.14 would need a container and a unit port (19898) — not
   made: nothing in the brief's Beats needs it.
2. **"All three rows" is the DELETE's own return value** (RED #321's first option): the JDBC proxy keeps what each `executeUpdate`
   returned and its SQL; the second-connection count is 3 → 2 (before and after the transaction), not 3 → 0 → 2 — no read was made
   inside the transaction, between the DELETE and the INSERTs (not measured), so the return value is the witness.
3. **The lazy witness is two lines, both asserted** (RED #323): `isLoaded(customer, "wallet") false` (from
   `emf.getPersistenceUnitUtil()`) and the class `Wallet$HibernateProxy`. Planted below: `fetch = EAGER` fails `isLoaded` first (and the
   class too); a proxy touched after the count keeps its proxy class while `isLoaded` turns `true` — the class-only check passes it, the
   real one fails it.
4. **Names the brief left open**: the owning entity is `WalletCustomer` (table `wallet_customer`; the probe's `WCustomer`), the fans
   `ListFan`/`SetFan`/`OrderedFan` (the probe's table names), the middle's customer `SubCustomer`; Ravi everywhere but the exercise (Kavya);
   the wallet's balance 500; the subscription 2 a day since 2026-11-04 (a fixed date, so the capture hashes the same tomorrow).
5. **The probe's raw row `2 | 2026-11-04 | 1 | 1 | 1` is printed in the order `id | customer_id | meal_id | meals_per_day | since`**
   (`1 | 1 | 1 | 2 | 2026-11-04`).
6. **The cascade**: `WalletCustomer.wallet` has `cascade = PERSIST` (one `persist` writes both); the brief's Beats name only `LAZY`. It
   changes no SELECT in A or B.
7. **`many` counts its statements from the join table's first read on**, so the 2 SELECTs that read Ravi and his favourites are inside
   the 5 / 3 / 4 (the probe's table says the same: "2 SELECTs included"); the writes are counted after `before commit`.
8. **The exercise's two halves both exit 0 and both leave 2 rows**: the bug is cost, not a wrong table. Broken ≠ solved is measured by
   `executeUpdate calls` and the DELETE's return value (3 / 1), never by the exit code.
9. **Check order chosen so each plant's named check speaks first**: in `one` A the lazy check (`isLoaded`, then the class) comes before
   the statement count; in `many` A the write count comes first. No capture changed (the checks read; the captures' md5s stayed).
10. **The middle uses `SubCustomer`, not the anchor's `CustomerEntity`**: the brief says `Subscription (customer, …)`; a harness entity on
    the harness's own database keeps the anchor untouched (⚑3).
11. **Plants on copies** (unit 09's form): each a scratch mirror (`c7-unit10` without its captures, `.m2-demo` an APFS clone of this
    unit's, `c7-unit09/after`, its README, `receipts.md5` and `.r-xcheck.out`, `c7-tiffinbox`), the planted capture's hash taken out of
    the mirror's `receipts.md5` where named, so its check speaks; run seven at a time beside each other, on `receipts.sh` md5 `38e596b1…`
    (the one committed). The mirrors held this README as a draft (the README is gated by the prose checks, never hashed; the two prose
    plants each added one line to the README as it then stood).

## Planted faults — each caught (R.65)

On copies (What differed, 11), each **exit 1**, nothing written to this folder, 0 listeners on 19800-20399 and no java after them:
- **`Set` in A** (`ListFan.favourites` a `Set<Meal> = new HashSet<>()`; `many` out of `receipts.md5`) → `*** many A (List): 3 writes after
  the removal (the driver's executeUpdate calls, each listed with what it returned): expected the line:   PROBE jdbc: executeUpdate
  returned, in order (3): ***` (99 s).
- **`fetch = EAGER` on the owning side** (`WalletCustomer`; `one` out) → `*** one A: the wallet not loaded - isLoaded false (the witness
  for lazy): expected the line:   PROBE isLoaded(customer, "wallet") (emf.getPersistenceUnitUtil()): false ***` (75 s). The capture held
  one SELECT with `left join wallet`, `isLoaded … true`, class `probe.map.one.Wallet`. **With the class-only check** (`lazy()` cut to its
  class line) the same plant fails too: `*** one A: the wallet a Hibernate proxy: expected the line: … Wallet$HibernateProxy ***` (74 s) —
  on EAGER both witnesses flip (RED #323's "show which": both).
- **The check that cannot tell — and the one that can** (`Main.one` A given `c.getWallet().getBalance();` after the counters, before
  the witnesses — the proxy initialized, its class unchanged): with the **class-only check** the run **passes `one`'s checks** (its line
  `one: … the wallet probe.map.one.Wallet$HibernateProxy` printed; the capture held `isLoaded … true` and a second SELECT `from wallet`)
  and stopped only at the end for the unpublished hash (`*** no published hash for: one … ***`, 131 s); with the **real check** →
  `*** one A: the wallet not loaded - isLoaded false (the witness for lazy): … ***` (75 s).
- **The DELETE's count not printed — "three rows" typed** (`H.java` keeping the SQL without `executeUpdate`'s return value; `many` out)
  → `*** many A: the DELETE returned 3 - all three of Ravi's rows (RED #321): expected the line:   PROBE   returned 3 <- delete from
  list_fan_favourites where list_fan_id=? ***` (99 s).
- **A primary key claimed for the `List`'s join table** (`chk_many` expecting `… list_fan_id bigint not null, primary key (favourites_id,
  list_fan_id));`) → `*** many A: the List's join table, its primary key (the claim): expected the line: … ***` (99 s).
- **A wrong published hash** (`receipts.md5`'s `one` with its last digit changed) → `*** one is not the published capture … ***` (66 s).
- **A version claim without its `HHH000001` line** (`harness/logback.xml` without its `org.hibernate.orm.core` logger; `one` out) →
  `*** one: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its 2 harness JVMs (R.222) ***` (68 s).
- **`xcheck` against a wrong 09 md5** (`X09` changed in the mirror's `receipts.sh`) → `*** ../c7-unit09/README.md no longer states Boot's
  script md5 f595637014e786fa38606859951e4f96 - the number this unit compares with ***` (45 s, before any capture); **and with the
  mirror's `c7-unit09/README.md` changed to match** (`xcheck` out) → `*** xcheck: the harness's script is Boot's as the owning-side
  lesson captured it (f595…4f96): expected the line:   md5 of .harness/run/xcheck.sql: f595…4f96 ***` (101 s).
- **An Indian dish name** (one README line naming a dish on the list) → `*** an Indian dish name (R.215: English names only):
  README.md:12:… ***` (2 s), before anything is built.
- **One per capture class:** `one` and `many` above; `middle` — `Subscription.since` given `@Column(name = "start_date")` (`middle` out)
  → `*** middle: expected the line:     create table subscription (meals_per_day integer not null, since date, … ***` (96 s); `xcheck`
  above; `exercise` — `SOLUTION.md`'s `sed` given a pattern that matches nothing (eight spaces of indent for four: the copy unchanged,
  still one line differing from the README's; `exercise` out) → `*** exercise: the solution - one DELETE (1 write): expected the line:
  PROBE Salad removed from Kavya's favourites - executeUpdate calls: 1 ***` (126 s).
- **The unmeasured claim made** (a README line saying the inverse side "can wait" with bytecode enhancement, without "not measured" in it) → `*** a line names bytecode enhancement without 'not measured' in it (R.201 - it is not measured here): README.md:357:… ***`
  (1 s), before anything is built.

## Found on the way

- **The keyword net caught the harness's own SQL** on the second development run: unit 08's check (an entity type followed by an SQL
  keyword) matched `"… from wallet order by id"` in `Main.java` — the word `wallet` before `order`. The net now reads the entity sources
  only (`one`, `many`, `middle`, `ex`), which is what R.213 guards: names, not the SQL the harness sends.
- **`Statistics` counts a `List`'s rewrite as `collection updates 1`, `collection recreates 0`** — the DELETE-all-and-reinsert is one
  collection update to Hibernate; only the statements and the driver's return values show its size (S2.3 again).
- **`@OrderColumn` removes the middle element by deleting the last position and moving the last element up** (`update … set
  favourites_id=? where … favourites_order=?`): Salad's row is not the one deleted; Soup's position 2 is, and position 1 now holds Soup.
- **`fetch = EAGER` on the owning side reads the wallet by a join in the same SELECT** (`left join wallet w1_0`): still one statement —
  the statement count alone cannot tell lazy from eager here; `isLoaded` and the class can.
- The harness's core logger at INFO prints `HHH000489: No JTA platform available …` in every harness JVM — deterministic, kept in the
  captures as Hibernate prints it.

## CARRIED

- **Bytecode enhancement and the lazy `@OneToOne` inverse side** → not measured (no enhancement plugin in the seed); U29/U31's brief
  decides (the brief's CARRIED line).
- **PostgreSQL for 10** → not run (What differed, 1); the probe's "both DBs identical" stays the probe's, on 42.7.13.
- `11-14`'s `xcheck` compares with unit 09's `f595637014e786fa38606859951e4f97` too (unchanged by this unit).
- The builder (s710) must refuse the dish-name list in SAY lines and on slides, assert `duration words: 0` (R.172), refuse "Hibernate
  counted N updates" for collection work (S2.3), and keep the bytecode enhancement sentence labelled "not measured" or cut (R.201).

## For RED

Re-run from a clean tree (seeded `.m2-demo`) in a process group of its own; ports 20240-20279 for any re-run of this unit's JVMs outside
its script. Worth breaking: whether `isLoaded` could read `false` for a wallet that is in fact loaded (the touched-proxy plant says it
reads `true` once initialized); whether `returned 3` could come from something other than the three rows (the second connection's 3 → 2
is beside it, and the proxy records the value the driver hands Hibernate); whether `many`'s 5 / 3 / 4 include the reads (they do: 2
each, asserted); whether a `Set` needs `equals`/`hashCode` for this removal (not here: Salad is the same managed instance the collection
holds — a detached or new `Meal("Salad")` was not measured); whether `@OrderColumn`'s UPDATE count grows with the list's length (not
measured: three elements only). Evidence by a Claude Opus 5.5 agent on 2026-11-04.

# c7-unit11 — Cascades and Orphan Removal

Course 7 · Data with JPA & Hibernate · Section 2 (Mapping), its sixth unit — **a harness unit: no change to the anchor** · Verified on
**JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the
anchor's pin), 2026-11-04, **on H2 only** (the brief's Beats: "H2"; this unit speaks for H2 and says so). A cascade copies an
operation from the customer to her pauses. `orphanRemoval` does something no operation asked for: it deletes a pause the moment it
leaves her list. Both are one attribute on `@OneToMany` — and `merge` is where the wrong one writes nonsense: a detached Kavya, one new
7-day pause, `merge` with `cascade = PERSIST`, and the table gains **`3 | 0 | null`** — a pause of zero days that belongs to nobody. No
error.

**No anchor change.** `anchor` is the link to `../c7-unit09/after`, the tree Section 2 froze. `receipts.sh` prints `diff -rq -x .m2-demo
-x target -x secrets anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record — and, from any later anchor change
on, prints a note instead, never a stop (R.211). The anchor is copied under `.harness/anchor` and built there, never in place.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 6 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first), and when a check after a capture fails. **Start it in
a process group of its own** (a terminal's foreground job is one), with SIGINT at its default: `sweep()` stops only processes of its own
group, and a bash started with SIGINT ignored cannot trap it (Found on the way). `.m2-demo` must be seeded first (below). No Docker, no
container, no password, no TiffinBox JVM: every database is H2 in a harness JVM's memory.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own, `.m2-demo`
seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Two development runs fixed the captures and the
checks (the first stopped at a check of mine that read the seeding transaction's `after commit` as the action's — Found on the way; the
second wrote every capture 3/3 with every check passing, and its md5s are `receipts.md5`).
**The runs of record, on the script as committed (`receipts.sh` md5 `82627ef1f0e39aaa5021609d5bd8a7ed`): 348 s under `./receipts.sh`**
(/bin/bash 3.2.57, beside the twelve plant mirrors and the sealed clone's run — a busy machine) **and 127 s under `bash receipts.sh`**
(Homebrew bash 5.3.9): each exit 0, all 6 captures 3/3 = published, every check passed, the one build `offline: yes · exit 0 ·
'Downloaded from' lines in its log: 0`, the anchor note empty at the start and the end, nothing listening on 18425, 8080, 35729 or
19900-19909 at the end; each terminal log through `check_unit7.py 11 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS`.
The builders' `_builders/dur7.py` over this README and the exercise's two files: 0 duration words. **Nothing was downloaded**, and
this unit made no network act. (An earlier `./receipts.sh` on `receipts.sh` `52d114df…` — the merge checks in the other order, What
differed 11 — also exited 0 with all 6 = published; the script changed after it, so it is not a run of record.)

Published hashes: orphan `602d8372ecf9e91a93eef04553edda3b` · remove `2b02b8d398518865a1b0c6d8731cac26` · replace `4820af506f997dd6ded3bc2d2429d8b7` · merge `82a725d0311ac709f46675a804e23f0e` · xcheck `ced109764dc2342855867a5754e0d96a` · exercise `02558260456c8ca4a060ccf85dafd2e9`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 10's recipe, with this unit's folder:

```bash
S=/tmp/sealed11; W="/tmp/sealed 11"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit11" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-04):** a `git clone` of tiffinbox-java at `1111582` into a path **with a space** (`…/sealed 11/tiffinbox-java`), this
commit's 24 files put in as git takes them (`git ls-files -o --exclude-standard c7-unit11`; `anchor` → `../c7-unit09/after` by
`readlink`; `receipts.sh` the committed `82627ef1…`, README.md this one as then drafted — its run-of-record paragraphs since filled in,
no command line changed); a `file://` copy of the s2 seed (4,971 files); pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0
from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the dead proxies, a session of its own:
**exit 0 in 348 s, all 6 = published, every check passed**; the build `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`;
after the run `.m2-demo` held 4,971 files, 0 `_remote.repositories`; the builders' `dur7.py` and unit 09's captures are not beside a
clone (the terminal says so for each; `dur7.py`'s md5 and Boot's script md5 are the checks). Its terminal log through `--runlog`: PASS.

## The commands this unit adds

```bash
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/map/H.java harness/src/probe/map/Main.java harness/src/probe/map/cascade/*.java
java -Duser.language=en -Duser.country=US -Dlogback.configurationFile=../../harness/logback.xml "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.map.Main "${A[@]}"
```

The harness compiled against the anchor's extracted jar (91 libraries); **the harness line** (run from `.harness/run`: `V` its JVM flags,
`A` its arguments — R.193, each printed as `$ V=(…)` / `$ A=(…)`). The lines read from `anchor/README.md` (2, each asserted whole):
`mvn -B package` and the extract line — unit 10's.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). One build: the anchor's `package` (its 18 tests run inside
it), `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from the build log, never typed). After
it the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar` and `h2-2.5.250.jar`.
**At run time** nothing leaves the computer: every database is H2 in a harness JVM's memory. **No network act**: this unit reads no
version file — unit 06 made Section 2's dated sweep (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-04.xml`: 4.1.2
the newest 4.1.x GA; R.223), and no Section 2 unit speaks a "newest" fact. **No PostgreSQL driver is loaded** (What differed, 1).

## The locale

Every java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it; the test fork's
comes from the POM's `argLine`. **The harness prints ASCII** (` | ` between facts).

## The folders, the harness and the ports

- `anchor` — the link to `../c7-unit09/after` (asserted: a link, that target). `.harness/anchor` — its copy, built with the README's
  `mvn -B package` offline, its jar extracted (91 libraries); `.harness/hc` — the harness, compiled; `.harness/run` — where every harness
  JVM starts (its scripts land there); `.harness/ex` — the exercise's classes.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/map`, package `probe.map`; a check refuses `probe.map` anywhere in
  the anchor's code). `H.java` is unit 10's with one change: `counted()` also prints **`collection removes`** and **`entity deletes`**
  (each `Statistics` counter named by what it counts — R.206, R.208; S2.3). Unit 10's JDBC proxy (`writes`: what each `executeUpdate`
  returned and its SQL), `reset()`, `tx()` (`before commit` / `after commit`) are unchanged. **Not a Boot application** (R.212): one
  `EntityManagerFactory` per run, `PersistenceConfiguration` over the classes the run names, Boot's two naming strategies, statistics
  on, `drop-and-create` on the run's own database only (`xcheck` sets it to `none`: a script only). Every run prints
  `org.hibernate.Version.getVersionString()` first and Hibernate's own `HHH000001` line (its core logger at INFO — R.222, #311), then its
  `database:` line. Scenarios (`Main.java`): `orphan KIND FILE`, `remove KIND FILE`, `replace KIND HOW FILE`, `merge KIND FILE`, `ex
  CLASS`, `xcheck FILE`. Each starts from Kavya with pauses of 3 and 2 days, each pause persisted explicitly with the owning side set,
  then resets the counters and prints `the action: …` before the one action under test.
- **Entities** (`probe.map.cascade`, English names only — S2.10, R.215; tables named apart from the anchor's `customer`/`pause` —
  S2.7): five customer/pause pairs of the anchor's shape (`@OneToMany(mappedBy = "customer") List<…> pauses`; the pause `int days`,
  `@ManyToOne(fetch = LAZY) @JoinColumn(name = "customer_id")`), one attribute apart: `OrphanCustomer` (`cascade = ALL, orphanRemoval =
  true`), `RemoveCustomer` (`cascade = {PERSIST, REMOVE}`), `PlainCustomer` (none), `MergeAllCustomer` (`cascade = ALL`),
  `PersistCustomer` (`cascade = PERSIST`), each with its `…Pause`; two interfaces, `Parent` and `Kid`, let `Main` drive all five. The
  exercise's `probe.map.ex.ExCustomer`/`ExPause` (never compiled into `.harness/hc`, asserted). `harness/logback.xml` — unit 10's, its
  comment naming this lesson; `harness/dur7.py` — the builders', md5 `41667fed…`, byte for byte.
- **Ports** (§P, 19900-19909): **none bound.** 19909 is asserted free at the start and the end, with 19900-19908, 18425, 8080 and 35729.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on planted lines): this folder → `…`, the folder above → `…/..`, home → `~`,
   the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; **Hibernate's generated constraint names** → `FK<hash>`
   (and `UK<hash>`) — **in either case**: lower case in the DDL (`FKlvy3…`), upper case in H2's referential-integrity message
   (`FKN4O1…`), both planted in the self-test; 25 characters Hibernate derives from the table and column names, nobody's code.
2. **A harness log** (`hview`): every line, trailing spaces dropped.
3. **A Maven log**: never printed in a capture; its `$` line, exit, `offline` and `Downloaded from` count go to the terminal.
4. **Hygiene, checked last over every capture** (unit 10's list): no absolute path, no unit number, no time, no log time, no thread
   number, no JDK/OS version token, no unmasked generated database name, **no unmasked constraint name** (`FK` + 11 or more letters or
   digits, either case), no port, no per-run timing figure, no stack frame; every java line pinned; `GenerationTarget encountered
   exception` 0 in every harness log (R.213); no SQL keyword as an entity or field name; no H2 database file anywhere in this folder; no
   `pkill`/`killall`; no bare `wait`; no one-string multi-option variable (R.193); **no Indian dish name** in any capture (R.215).
5. **Duration words** (R.172): `dur7.DUR` over this README and the exercise's two files must find **0** — this unit speaks no time ("3
   days" is a pause's length, a number the pattern does not match: measured). **Dish names** (R.215): 41 words, whole words, any case,
   refused in this README, `exercise/` and `harness/src` before anything is built, and in every capture at the end. **R.201, the
   mechanism sentence:** "merge did not copy the new pause; PERSIST saved an empty one" may stand in this unit's prose only while `merge`
   B's capture prints the managed copy's fields (RE-MEASURE 5); `receipts.sh` counts the sentence in the prose first and refuses it
   after `merge` when the capture lacks the line.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`), sweeps its own process group for any
harness JVM, Maven or Surefire fork left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The
published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-04, a scratch mirror holding the six published captures, the script as committed):** `./receipts.sh` (/bin/bash 3.2)
started in a session of its own with SIGINT at its default, `kill -INT` to its group once the named process was in it, the state read 5 s
later — each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
exercise: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the anchor's Maven (its Surefire fork); `harness` — the first harness JVM (`orphan` A); `exercise` — the exercise's shell
(`ex-drive.sh`, bash). `pgrep -fl java` afterwards: none.

## 1 · orphan — her 3-day pause leaves the list (A/B/A′, R.1, RED #309)

The script (A's): `create table orphan_customer (id …, name varchar(255), primary key (id));` · `create table orphan_pause (days
integer not null, customer_id bigint, id bigint generated by default as identity, primary key (id));` · the foreign key (`FK<hash>`).
Kavya and pauses of 3 and 2 days: `[1 | 3 | 1, 2 | 2 | 1]` (id | days | customer_id, by a second connection). Then, in a new
transaction, `getPauses().remove(0)`:

- **A — `cascade = ALL, orphanRemoval = true`:** at the commit, **`delete from orphan_pause where id=?`** — the driver returned 1; the
  table `[2 | 2 | 1]`; a new EntityManager reads `[2]`. 3 statements (2 reads + the DELETE: the SQL log's lines = `getPrepareStatementCount()`
  = the driver's `prepareStatement`, R.184); `Statistics` `collection updates 1 · entity deletes 1`.
- **B — `cascade = {PERSIST, REMOVE}`:** **nothing written** (`executeUpdate returned, in order (0)`); the table still `[1 | 3 | 1, 2 | 2
  | 1]` — **the row still points at Kavya**, and a new EntityManager reads her pauses as `[3, 2]` again (the probe's "not run" — now
  measured). 2 statements, the reads.
- **A′ — A again, a fresh JVM:** the same lines; its script = A's (`cmp`).

## 2 · remove — Kavya herself removed (A/B/C; C the failure receipt)

`em.remove(customer)`:
- **A `ALL + orphanRemoval` and B `PERSIST + REMOVE` alike:** her pauses read, then at the commit **2 × `delete from <t>_pause where
  id=?`, then `delete from <t>_customer where id=?`**, each returned 1; no rows left; "no Kavya" in a new EntityManager; 5 statements;
  `Statistics` `collection removes 1 · entity deletes 3`. On removing the parent, `REMOVE` and `orphanRemoval` do the same.
- **C — no cascade — the failure trio:** **exit 1**; **`jakarta.persistence.RollbackException: Error while committing the transaction
  [could not execute statement [Referential integrity constraint violation: "FK<hash>: PUBLIC.PLAIN_PAUSE FOREIGN KEY(CUSTOMER_ID)
  REFERENCES PUBLIC.PLAIN_CUSTOMER(ID) (CAST(1 AS BIGINT))"; SQL statement:`** ← `org.hibernate.exception.ConstraintViolationException`
  ← `org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException` (and H2's `WARN … HHH000247: ErrorCode: 23503`); the customer's DELETE
  was sent and refused (`executeUpdate 1`, returned none); **nothing deleted**: Kavya and `[3, 2]` still there. 2 statements.

## 3 · replace — a new list, or the same list emptied (A/B/C)

- **A — `setPauses(new ArrayList<>())` with `orphanRemoval = true`:** **exit 1**, `jakarta.persistence.RollbackException: Error while
  committing the transaction [A collection with orphan deletion was no longer referenced by the owning entity instance:
  probe.map.cascade.OrphanCustomer.pauses]` ← **`org.hibernate.HibernateException: A collection with orphan deletion was no longer
  referenced by the owning entity instance: probe.map.cascade.OrphanCustomer.pauses`** (7.4's words, quoted from the capture — not
  Hibernate 5's `cascade="all-delete-orphan"` wording); the commit rolls back, **0 writes**, both rows kept.
- **B — the same line, `PERSIST + REMOVE`, no orphanRemoval:** **nothing written**, 2 statements (the reads), 0 UPDATE/DELETE/INSERT
  statements — while **`Statistics` says `entity updates (getEntityUpdateCount) 1 · collection recreates 1 · collection removes 1`**
  (S2.3: Statistics counts what Hibernate decided, never the statements; the statement count is the witness).
- **C — `getPauses().clear()` with `orphanRemoval = true`:** **2 × `delete from orphan_pause where id=?`**, each returned 1; Kavya stays,
  her pauses `[]`. 4 statements.

## 4 · merge — a detached Kavya, one new pause (A/B/A′, R.1, RED #309; the hook)

Kavya read with her pauses in a transaction that ends (detached); a new pause of 7 days added both ways (`attach(kavya)` and
`getPauses().add`); the counters reset; `merge(detached)` in a new transaction; each from its own fresh JVM (R.196):
- **A — `cascade = ALL`:** `select … from merge_all_customer mac1_0 left join merge_all_pause p1_0 on … where mac1_0.id=?` then **`insert
  into merge_all_pause (customer_id,days,id) values (?,?,default)`** → the table gains **`3 | 7 | 1`**; a new EntityManager reads `[3, 2,
  7]`. 2 statements.
- **B — `cascade = PERSIST` only:** **`3 | 0 | null`**, 3/3 — **no exception, no WARN**; a new EntityManager reads `[3, 2]` (the row is
  nobody's). The INSERT comes at the commit, not at `merge()`; 5 statements (merge's four reads — the customer, each of her two pauses by
  id, her pause list — and the INSERT).
- **A′ — `ALL` again, a fresh JVM:** **`3 | 7 | 1`** again; its script = A's. The flip of one attribute is the cause (R.1).

**RE-MEASURE 5 — what the managed copy holds after `merge`** (printed in A, B and A′ between `merge()` and the commit):
- B: `the managed Kavya is the detached object: false | her pauses (days) [3, 2, 0]` · **`her last pause: days 0 | customer null | id
  null | the detached new pause itself: false | em.contains: false`** · `the detached new pause: days 7 | customer the detached Kavya | id
  null | em.contains: false`.
- A (and A′): `[3, 2, 7]` · `her last pause: days 7 | customer the managed Kavya | id 3 | the detached new pause itself: false |
  em.contains: true`.

**Verdict:** the mechanism sentence **may be voiced** — the capture shows it: without `MERGE`, the managed list holds a *new, empty*
pause (0 days, no customer, not managed yet) in place of the 7-day one, and `PERSIST` inserted that empty object at the commit. The
voice: "merge did not copy the new pause; PERSIST saved an empty one". *Why* Hibernate puts an empty instance there (RED #309's
`EntityType.replace` reading) is still not captured (R.201): say what the capture shows, not the internal method.

## 5 · xcheck — the harness's DDL against Boot's, as unit 09 captured it (R.212, RED #308)

The harness's own EntityManagerFactory over `com.tiffinbox.CustomerEntity` and `com.tiffinbox.PauseEntity` (from the anchor's jar)
writes `xcheck.sql`: three lines, **md5 `f595637014e786fa38606859951e4f97` = Boot's script as unit 09 captured it** — the md5 read from
`../c7-unit09/README.md` (asserted there) and that capture's own published md5 `9072c6f1…` read from `../c7-unit09/receipts.md5` before
any build. **No Boot run** (this unit binds no port). When `../c7-unit09/.r-xcheck.out` is on disk with its published md5, Boot's three
lines are read from it and each asserted in this capture too (a clone has no captures: the md5 is the comparison).

## 6 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s 7 lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: the copy of `ExCustomer.java` made
with `sed`, `emptyPauses()`'s `pauses = new ArrayList<>();` made `pauses.clear();`), each block sourced in one `env -i` shell,
`/bin/bash --noprofile --norc` then `/bin/zsh -f`; each block in a fresh JVM. In both: the README → **`exit 1`**, the
`RollbackException` ← `HibernateException` (`… probe.map.ex.ExCustomer.pauses`), `executeUpdate calls: 0`, 2 rows; the solution →
**`exit 0`**, `executeUpdate calls: 2` — two `returned 1 <- delete from ex_pause where id=?`, 0 rows; the shell back in this folder;
bash's output = zsh's.

## Exercise

**Your turn:** the README empties Kavya's pauses by handing her a new list, and the commit fails. Empty the list she already has.
(23 words, `wc -w` on the quoted sentence, asserted in `receipts.sh`.) `exercise/README.md` ships `emptyPauses()` handing her a new list,
`exercise/SOLUTION.md` beside it; broken (exit 1, the HibernateException, 0 writes) ≠ solved (exit 0, 2 DELETEs), each from its own
fresh JVM, measured by the `exercise` capture (R.196).

## What the video may say — and the capture each comes from

- **The hook:** a detached customer, one new pause, `merge` with `cascade = PERSIST`: the row **`3 | 0 | null`**, no error (`merge` B);
  `cascade = ALL` → **`3 | 7 | 1`** (`merge` A and A′ — the flip is the cause).
- The voice may say "merge did not copy the new pause; PERSIST saved an empty one" (`merge` B, RE-MEASURE 5: the managed copy's
  last pause `days 0 | customer null`); not the internal method that does it.
- Leaving the list: `orphanRemoval` → **one DELETE, the row gone** (`orphan` A, A′); `PERSIST + REMOVE` → **nothing written, the row
  still points at Kavya**, and she still has both pauses when read again (`orphan` B).
- Removing the parent: `REMOVE` and `orphanRemoval` alike — **two pause DELETEs, then hers** (`remove` A, B); no cascade →
  **`RollbackException: Error while committing the transaction`** ← `ConstraintViolationException`, "Referential integrity constraint
  violation", the FK name on screen as `FK…` (`remove` C — the failure receipt), nothing deleted.
- A new list with `orphanRemoval`: **"A collection with orphan deletion was no longer referenced by the owning entity instance"** (7.4's
  words, `replace` A); without it, nothing written, while `Statistics` reports an entity update — said as what it counts (`replace` B);
  `clear()` → **two DELETEs** (`replace` C, the exercise).
- The harness's DDL = Boot's (`xcheck`). "Hibernate 7" for the version; each capture prints `7.4.13.Final` twice per JVM (`HHH000001` and
  `getVersionString()`, R.222). **On H2** (R.173, R.217).

## The ledger rows and hand-offs this unit pays

- No ledger row is paid here (the brief's §LEDGER names none for 11).
- RE-MEASURE 5 is settled here (below).

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: exit 1 + HibernateException / exit 0 + 2 DELETEs, a fresh JVM each half |
| 5 | the managed copy after `merge` with PERSIST only: its new pause `days 0 \| customer null \| id null`, not the detached object, not yet managed — the sentence may be voiced (`merge` B) |
| 9 | English names: Kavya, pauses in days; the dish list refused over prose, harness and captures |
| 12 | `xcheck` on `09/after`: `f595637014e786fa38606859951e4f97` (Boot's script as 09 captured it) |

## What differed from the brief

1. **H2 only; the AMENDMENT's "U10-U11 … on 42.7.14 → their units' receipts" does not apply here** (unit 10's reading, What differed 1,
   kept): the brief's Beats make 11 an H2 unit; the probe's "H2 and Postgres give the same SQL order and the same rows in every case"
   (Step 6) stays the probe's, on driver 42.7.13, and no slide of this unit may speak for Postgres (R.217). A Postgres run would need a
   container and a unit port (19908) — not made: nothing in the Beats needs it.
2. **Five customer/pause pairs, one attribute apart**, instead of the probe's four (`O`/`R`/`N`/`P`): the merge's A is **`cascade = ALL`
   without `orphanRemoval`** (`MergeAllCustomer`), so A/B/A′ flip exactly one attribute (`ALL` ↔ `PERSIST`); the probe ran merge A on `O`
   (`ALL + orphanRemoval`). `orphan` A/B flips the brief's pair (`ALL + orphanRemoval` ↔ `PERSIST + REMOVE`) as written.
3. **The pause's `customer_id` is nullable** (`@ManyToOne(fetch = LAZY)` without `optional = false`, unlike the anchor's
   `PauseEntity`): with `optional = false` the hook's `null` could not be written at all (not measured here); the brief's Beats name the
   row `3 | 0 | null`, so the harness keeps Hibernate's default and the DDL shows `customer_id bigint` (asserted).
4. **A′ runs are separate invocations of the same scenario, not a separate class** (R.1): `A=(orphan orphan …)` / `A=(merge all …)` again;
   the plant "PERSIST in merge A′" therefore changes A′'s argument in `receipts.sh` (`merge persist`), not an entity.
5. **`replace` B's Statistics is `entity updates 1 · collection recreates 1 · collection removes 1`** — the brief's "`updates 1`" read
   from `getEntityUpdateCount()`; this harness prints each counter by name, and `collection updates` is 0.
6. **`remove` C's driver call:** `executeUpdate 1` — the customer's DELETE was sent and refused, so the JDBC proxy recorded no return value
   (`returned, in order (0)`); "nothing deleted" is the second connection's rows, beside it.
7. **The merge B statement count is 5** (four reads at `merge()` — the customer, each known pause by id, the list — and the INSERT at the
   commit); A's is 2 (one `left join` read). Asserted, not voiced as a lesson.
8. **The mask covers H2's upper-case constraint name** (`FKN4O1…` in the referential-integrity message): unit 10's mask matched lower case
   only, which the DDL alone needed; the self-test plants both.
9. **R.201's gate is a check of the prose against the capture** (the mechanism sentence counted in README.md and exercise/, refused
   after `merge` unless `merge` B prints the managed copy's line), replacing unit 10's bytecode-enhancement label check, which this
   unit has no sentence for.
10. **Plants on copies** (unit 10's form): each a scratch mirror (`c7-unit11` without its captures, `.m2-demo` a link to one scratch copy
    of the s2 seed, `c7-unit09/after`, its README, `receipts.md5` and `.r-xcheck.out`, `c7-tiffinbox`), the planted capture's hash taken
    out of the mirror's `receipts.md5` where named, so its check speaks; twelve run at once beside each other, on `receipts.sh` md5
    `82627ef1…` (the one committed). The mirrors held this README as a draft (the README is gated by the prose checks, never hashed).
11. **Check order chosen so each plant's named check speaks first** (unit 10's form): in `merge` the hook's row (`3 | 0 | null`) is
    checked before the R.201 prose gate, and in A/A′ the row (`3 | 7 | 1`) before the seeding line. No capture changed.

## Planted faults — each caught (R.65)

On copies (What differed, 10), each **exit 1**, nothing written to this folder, 0 listeners on 19800-20399 and no java after them;
twelve at once on `receipts.sh` `82627ef1…` (the times are a busy machine's):
- **`ALL` in `merge` B** (`PersistCustomer` given `cascade = CascadeType.ALL`; `merge` out of `receipts.md5`) → `*** merge B (PERSIST
  only): the hook 3 | 0 | null: after the action, expected persist_customer [1 | Kavya] and persist_pause [1 | 3 | 1, 2 | 2 | 1, 3 | 0 |
  null] by a second connection - read: … ***` (303 s).
- **`PERSIST` in `merge` A′** (`receipts.sh`'s A′ run given `A=(merge persist merge-a2.sql)`; `merge` out) → `*** merge A' (ALL again, a
  fresh JVM): after the action, expected merge_all_customer [1 | Kavya] and merge_all_pause [1 | 3 | 1, 2 | 2 | 1, 3 | 7 | 1] … ***` (303 s).
- **`clear()` in `replace` A** (`receipts.sh`'s A run given `clear`; `replace` out) → `*** replace A (a new list, orphanRemoval): the
  RollbackException with 7.4's words: expected the line: … ***` (264 s).
- **`orphanRemoval` left on in `orphan` B** (`RemoveCustomer` given `orphanRemoval = true`; `orphan` out) → `*** orphan B (PERSIST +
  REMOVE): nothing written - 0 writes: expected the line:   PROBE jdbc: executeUpdate returned, in order (0): ***` (173 s).
- **The FK name unmasked in `remove` C** (the mask's `FK` pattern back to lower case only, unit 10's; `remove` out) → `*** mask: the
  planted JDK version, folders, home, identity hash and constraint names (H2's upper-case one too) must be masked ***` (100 s, before
  any capture); the hygiene net (`FK` + 11 letters or digits, either case) stands behind it.
- **The mechanism sentence without RE-MEASURE 5's capture** (`Main.merge` without its three managed-copy lines, the README's sentence
  kept; `merge` out) → `*** the mechanism sentence ('merge did not copy the new pause; PERSIST saved an empty one') is in this unit's
  prose, but merge B's capture does not print the managed copy's fields (RE-MEASURE 5, R.201) - cut the sentence or capture it ***`
  (303 s) — the hook's row check passed first (the row is still `3 | 0 | null`): only the prose gate stops it.
- **A wrong published hash** (`receipts.md5`'s `orphan` with its last digit changed) → `*** orphan is not the published capture … ***` (171 s).
- **A version claim without its `HHH000001` line** (`harness/logback.xml` without its `org.hibernate.orm.core` logger; `orphan` out) →
  `*** orphan: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its 3 harness JVMs (R.222) ***` (170 s).
- **`xcheck` against a wrong 09 md5** (`X09` changed in the mirror's `receipts.sh`) → `*** ../c7-unit09/README.md no longer states Boot's
  script md5 f595637014e786fa38606859951e4f96 - the number this unit compares with ***` (101 s, before any capture).
- **A dish name** (one README line naming a dish on the list) → `*** an Indian dish name (R.215: English names only): README.md:…:-
  Kavya's lunch is … ***` (3 s), before anything is built.
- **One per capture class:** `orphan`, `replace`, `merge`, `xcheck` above; `remove` — `PlainCustomer` given `cascade = REMOVE` (`remove`
  out) → `*** remove C: RollbackException: Error while committing the transaction: expected the line: … ***` (216 s); `exercise` —
  `SOLUTION.md`'s `sed` given a pattern that matches nothing (twelve spaces of indent for eight: the copy unchanged, still one line
  differing from the README's; `exercise` out) → `*** exercise: the solution - clear(), two DELETEs: expected the line:     exit 0 ***` (349 s).
- The same twelve on `52d114df…` (the merge checks in the other order) were each caught too; there `ALL` in `merge` B was stopped by the
  prose gate before the row check, and `PERSIST` in A′ by its seeding line — the reorder (What differed, 11) lets each plant's named
  check speak first.

## Found on the way

- **A check of mine read the wrong transaction** on the first development run: "the commit did not finish" looked for `after commit`
  anywhere in `remove` C's block — and found the seeding transaction's. It now reads from `the action` on. No capture changed.
- **A bash started with SIGINT ignored cannot trap it.** The first plant batch, launched as background jobs of a non-interactive shell
  (which start with SIGINT ignored), did not stop on `kill -INT`: bash cannot trap a signal ignored on entry. Stopped with TERM (trapped
  the same way), nothing left. The SIGINT receipts below start `receipts.sh` with SIGINT at its default, as a terminal does.
- **The first mirror script made its mirrors inside this folder** (a relative path after a `cd`); found by the size of the copies, the twelve
  stray folders removed before any run of record, `git status` checked.
- **`merge` with `PERSIST` only reads each known pause by id** (two `select … from persist_pause pp1_0 where pp1_0.id=?`) before the list;
  with `ALL` one `left join` reads them all.
- **On removing the parent, `REMOVE` and `orphanRemoval` print the same lines**, `collection removes 1` in both.
- The harness's core logger at INFO prints `HHH000489: No JTA platform available …` in every harness JVM — deterministic, kept.

## CARRIED

- **Why** merge puts an empty instance in the managed list (RED #309's `EntityType.replace` reading) → not captured; the slide shows the
  row and the managed copy's fields, the voice says what they show (R.201).
- **`optional = false` on the pause with the PERSIST-only merge** (the anchor's own mapping) → not measured: would the hook become a loud
  not-null failure? A later unit's brief decides if it is spoken.
- **PostgreSQL for 11** → not run (What differed, 1); the probe's "both DBs the same" stays the probe's, on 42.7.13.
- `12-14`'s `xcheck` compares with unit 09's `f595637014e786fa38606859951e4f97` too (unchanged by this unit).
- The builder (s710) must refuse the dish-name list in SAY lines and on slides, assert `duration words: 0` (R.172), refuse "Hibernate
  counted N updates" for `replace` B (S2.3), and keep the mechanism sentence to what RE-MEASURE 5 printed (R.201).

## For RED

Re-run from a clean tree (seeded `.m2-demo`) in a process group of its own with SIGINT at its default; ports 20240-20279 for any re-run
of this unit's JVMs outside its script. Worth breaking: whether `3 | 0 | null` depends on the pause's `customer_id` being nullable (it
does by construction — What differed 3; `optional = false` not measured); whether the empty managed pause comes from the no-argument
constructor (the capture shows `days 0`, the field's default — consistent, not proven); whether `orphan` B's row "still pointing at
Kavya" would be cleaned by a later `orphanRemoval` (not measured); whether `replace` A fails for any new collection or only an empty one
(only `new ArrayList<>()` was measured); whether `clear()` then `add()` in the same transaction keeps the added pause (not measured).
Evidence by a Claude Opus 5.5 agent on 2026-11-04.

# c7-unit28 — Pessimistic Locking and Deadlocks

Course 7 · Data with JPA & Hibernate · Section 4 (Transactions), its sixth and last unit — **a harness unit, no change to the anchor**
(brief ⚑1): `anchor` is the link to `../c7-unit27/after`, Section 4's frozen anchor (= `../c7-tiffinbox`). Verified on **JDK 25.0.4.1,
Apache Maven 3.9.16, Spring Boot 4.1.2** (Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final), 2026-11-12, **on
two databases** (brief ⚑2): H2 2.5.250 in each JVM's memory and **PostgreSQL 18.6** (driver 42.7.14) in one container per run. A
pessimistic lock takes the row before anyone else can: the next transaction waits, gives up when its lock timeout says so, or skips the
row. Two transactions that take two rows in opposite orders wait for each other — until the database refuses one of them. Which one
depends on the database and on the design: on PostgreSQL on the gap between the two requests, measured against `deadlock_timeout`; on
H2 it is the request that closes the circle.

**No change to the anchor.** `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` at its
start and end — empty in every run of record — and, should a later course change the anchor, prints a note instead, never a stop
(R.211). The anchor is copied under `.harness/anchor` and built there with its README's package line, offline (its 18 tests run); the
harness runs over its extracted libraries (91).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5`. **Start it in a process group of its own** (a
terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be seeded first (below). Docker
must run, with the pinned image on this machine; nothing is pulled.

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files). Development runs fixed the captures and the checks; two full passing runs wrote every capture 3/3 with the same md5s, and those
are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `b636cec2e7eca2b5289b2ad025fea04b`): 294 s under `./receipts.sh`**
(/bin/bash 3.2.57, 2026-11-12 from 08:44 CET), **291 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from 08:49 CET), **288 s from a
sealed fresh clone** (below, from 09:05 CET) **and 298 s on the tree as committed** (from 09:12 CET) (`./receipts.sh`; this README final but this one
figure): each exit 0, all 7 captures 3/3 = published, every check passed, the one Maven run `offline: yes · exit 0 · 'Downloaded from'
lines in its log: 0`, the anchor note empty at the start and the end, the container removed, nothing listening on 20070-20079 at the
end; each terminal log through `check_unit7.py 28 --runlog` — `RESULT (run logs): PASS` (the unit gate: no 28 script yet). **Nothing
was downloaded; nothing was pulled.**

**A sealed fresh clone (R.129)** — unit 25's recipe: a `git clone` of tiffinbox-java at `bc05519` (`file://`) into a path **with a space**
(`…/sealed 28/tiffinbox-java`, in the session's scratch folder), this unit's 17 files put in as git takes them (`git ls-files -o
--exclude-standard c7-unit28`, `anchor` → `../c7-unit27/after` by `readlink`); a `file://` copy of the s3 seed as Maven's only
repository (5,023 files once `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left out), dead proxies for
http and https, the pre-flight `dependency:get` of an absent artifact refused with 221 `Downloading from sealed: file://` lines and 0
from http(s); the clone's `.m2-demo` seeded from that copy; `./receipts.sh` `env -i` with the dead proxies and
**`DOCKER_CONFIG=$HOME/.docker`** (unit 25's finding: under the sealed `HOME` the docker CLI has no context and cannot reach OrbStack's
engine; the variable points it at the user's own docker configuration and nothing else), the builders' `dur7.py` not beside the clone
(its md5 was the check).
<!-- runs: end -->

Published hashes: locks `d19bfae9a3ace1a637feeb311b0f8478` · wait `f973d2fe7c5e55bb7c8aa393a51b50b2` · txtimeout `8e9b238f54e79c3dbbe89f714d73b25f` · deadlock `dec5ccb6f2b2dcee94634c8b6de007ae` · order `ad728b699e2e51b7019adffb3d984322` · xcheck `67de26a8d092b3754a5d3348fe8dee0b` · exercise `1a3218444889e21d4d5632141ebf43f8`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string
typed in this README outside this block and the captured blocks below is refused; inside them every statement is the logger's or the
server's, read off a capture):

<!-- values: begin -->
the values the video may say: H2 2.5.250 and PostgreSQL 18.6 (driver 42.7.14), Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - locks: the SELECT carries ce1_0.version (select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 where ce1_0.id=? for update); PESSIMISTIC_WRITE H2 for update, PostgreSQL for no key update of ce1_0; PESSIMISTIC_READ H2 for update, PostgreSQL for share of ce1_0; lock.timeout 0 nowait; 1000 H2 wait 1, PostgreSQL set local lock_timeout = 1000 around the SELECT, then set local lock_timeout = 0; -2 skip locked; PESSIMISTIC_FORCE_INCREMENT update customer set version=? where id=? and version=?, Ravi version 0 -> 1; no transaction org.springframework.dao.InvalidDataAccessApiUsageException <- jakarta.persistence.TransactionRequiredException: No active transaction · wait (T1 holds Ravi): lock.timeout 0 H2 org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockTimeoutException <- org.h2.jdbc.JdbcSQLTimeoutException <- org.h2.mvstore.MVStoreException (HYT00), PostgreSQL org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockTimeoutException <- org.postgresql.util.PSQLException · org.postgresql.util.PSQLException: ERROR: could not obtain lock on row in relation "customer" (55P03); lock.timeout 1000 H2 HYT00, PostgreSQL ERROR: canceling statement due to lock timeout (55P03); -2 T2 gets [Sunil]; plain: H2 witness, before T1 is released (the second connection, information_schema.sessions, T2's session): BLOCKER_ID = T1's session; PostgreSQL witness, before T1 is released (the second connection, pg_stat_activity, T2's backend pid): wait_event_type Lock · wait_event transactionid · pg_blocking_pids: T1's backend; then T1's commit, then T2's SELECT returns Ravi · txtimeout (timeout = 1, configured): org.springframework.transaction.TransactionTimedOutException: Transaction timed out: deadline was <date> on both; PostgreSQL's long statement jakarta.persistence.PersistenceException <- org.hibernate.QueryTimeoutException <- org.postgresql.util.PSQLException · ERROR: canceling statement due to user request (57014) · deadlock (deadlock_timeout 1s): gap 300 PostgreSQL victim T1 T1 T1, H2 victim T2 T2 T2; labelled gap 1500 PostgreSQL victim T2 T2 T2, H2 victim T2 T2 T2; PostgreSQL org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockAcquisitionException <- org.postgresql.util.PSQLException (40P01); H2 org.springframework.dao.CannotAcquireLockException <- org.hibernate.exception.LockAcquisitionException <- org.h2.jdbc.JdbcSQLTransactionRollbackException (Deadlock detected. The current transaction was rolled back., 40001) <- org.h2.mvstore.MVStoreException: Transaction <n> has been chosen as a deadlock victim.; the survivor commits, the second connection reads Ravi 2, Meera 1 · order: both lock Ravi first - T1 committed · T2 committed · the order, read off the one log: T2 seen blocked before T1's commit began yes · T2's first lock returned after T1's Initiating transaction commit yes · xcheck: 9cf92b8cae3abfd0f1c0706bfe7a4373, the same hash as in the lesson called Optimistic Locking with At-Version · exercise: T2 threw (the deadlock's victim) -> locked Ravi, then Meera, committed (22 words)
<!-- values: end -->

### The SQL of each lock — the table built from the log (`locks`, [S4 §8], RE-MEASURE 5)

One harness JVM per database; each lock mode or hint alone, in a `@Transactional` method of the harness's `Lock28` (its proxy names it
in the manager's line), the shipped seed again before each. The table is **built by `locks.py` from Hibernate's SQL logger lines between
each step's markers** — never typed — and compared with the brief's [S4 §8] (mismatches 0); `…` stands for the select list and
`from customer ce1_0`, which every row shares. The select list is 27's: it carries the version column (RE-MEASURE 5 — the whole line is
in the values above).

<!-- captured: locks begin -->
| the lock mode, the hint (a harness method, alone) | H2 2.5.250 | PostgreSQL 18.6 |
|---|---|---|
| PESSIMISTIC_WRITE | `… where ce1_0.id=? for update` | `… where ce1_0.id=? for no key update of ce1_0` |
| PESSIMISTIC_READ | `… where ce1_0.id=? for update` | `… where ce1_0.id=? for share of ce1_0` |
| EntityManager.find with PESSIMISTIC_WRITE | `… where ce1_0.id=? for update` | `… where ce1_0.id=? for no key update of ce1_0` |
| PESSIMISTIC_WRITE, lock.timeout 0 | `… where ce1_0.id=? for update nowait` | `… where ce1_0.id=? for no key update of ce1_0 nowait` |
| PESSIMISTIC_WRITE, lock.timeout 1000 | `… where ce1_0.id=? for update wait 1` | `select current_setting('lock_timeout', true)` · `set local lock_timeout = 1000` · `… where ce1_0.id=? for no key update of ce1_0` · `set local lock_timeout = 0` |
| PESSIMISTIC_WRITE, lock.timeout -2 | `… where ce1_0.meal_type=? order by ce1_0.id fetch first ? rows only for update skip locked` | `… where ce1_0.meal_type=? order by ce1_0.id fetch first ? rows only for no key update of ce1_0 skip locked` |
| PESSIMISTIC_FORCE_INCREMENT | `… where ce1_0.id=? for update` · `update customer set version=? where id=? and version=?` | `… where ce1_0.id=? for no key update of ce1_0` · `update customer set version=? where id=? and version=?` |
| PESSIMISTIC_WRITE without a transaction | no statement sent | no statement sent |
<!-- captured: locks end -->

Said with the database named (S4.4): **H2 writes the same clause for PESSIMISTIC_READ as for PESSIMISTIC_WRITE** — on H2 a read lock is
an exclusive one. PostgreSQL's read lock is its share lock. The lock timeout of 1000 is the hint's configured value, read off the
capture as configured: H2 turns it into its own clause, PostgreSQL into a transaction-local setting around the one statement, set back
after it. `PESSIMISTIC_FORCE_INCREMENT` on 27's versioned `CustomerEntity` sends the version UPDATE right after the locking read (the
loaded object says version 1, the second connection reads Ravi's version 1 after the commit). Without a transaction the repository
refuses before any SQL: Spring's `InvalidDataAccessApiUsageException` around Jakarta Persistence's `TransactionRequiredException: No
active transaction`.

### Waiting — T1 holds Ravi, T2 asks four ways (`wait`, S4.8, S4.18)

Two threads, T1 and T2, and latches. T1 locks Ravi (`@Lock(PESSIMISTIC_WRITE)`) and holds him until a latch releases it. T2 asks for
Ravi with the hint 0, the hint 1000, the hint -2 and with no hint. Every refusal is printed as its chain — class with package, message,
first cause, SQLState — and asserted (S4.8); the class is Spring's `CannotAcquireLockException` around Hibernate's
`LockTimeoutException` on both databases (the values line has each chain). H2 says `HYT00` for the hint 0 and for the hint 1000
alike; PostgreSQL `55P03` for both, with two messages. The hint -2 gives T2 the VEG row nobody holds: `[Sunil]`.

**The plain ask, ordered by the capture (S4.18, RED #1210, RE-MEASURE 11).** T2 asks for Ravi with no hint and blocks. The main thread
then reads T2's state **through the second connection, while T2 is alive and before anyone releases T1** — on PostgreSQL the activity
view's wait-event type for T2's backend pid (`Lock`, the blocking pid T1's), on H2 the sessions table's blocker column for T2's session
(T1's session) — prints it, and only then counts the latch down. T1 returns, its commit follows, and T2's SELECT returns Ravi. The
harness's appender keeps every line of the two threads in the one order logback received them; the scenario prints them thread by
thread and **derives the order from that sequence**: the witness before T1's commit began, T1's `Initiating transaction commit` before
T2's SELECT returned — `yes`, `yes`, both databases. No line of the harness sleeps (a grep in the receipt); the plant that takes the
`@Lock` off is in the plant table.

### A transaction's own timeout (`txtimeout`, moved from 23)

`@Transactional(timeout = 1)` — the configured value, voiced "a timeout of one, as configured" (S4.7); the manager's line names it
(`…,timeout_1`). The method reads Ravi, waits idle on a latch nobody counts down (1500, configured), and sends its next statement:
Spring refuses it before it reaches the database — `TransactionTimedOutException: Transaction timed out: deadline was <date>` (the date
masked), on H2 and on PostgreSQL alike, no cause. **On PostgreSQL** one statement that outlasts the timeout is cancelled by the
driver: Jakarta Persistence's `PersistenceException` around Hibernate's `QueryTimeoutException` around the driver's `canceling
statement due to user request` (57014) — Spring translates neither (said as captured). H2's statement timeout is not shown (CARRIED).

### The deadlock — the failure receipt (`deadlock`, S4.6, S4.8, S4.11, ⚑9)

T1 locks Ravi, then Meera; T2 locks Meera, then Ravi. Latches order the first locks (T1's, then T2's) and T1's ask for Meera; T2's ask
for Ravi waits a **configured gap of 300** on a latch nobody counts down. Three rounds per JVM, the seed again before each. **The victim
of every round is counted by the threw lines of each thread** (`len`, `vict.py`), never typed, and printed beside `deadlock_timeout`
(read by `show`) and the gap:

- **PostgreSQL, gap 300: T1, T1, T1** (`deadlock_timeout 1s`). **H2, gap 300: T2, T2, T2.**
- **Labelled, gap 1500 — and on PostgreSQL `log_lock_waits = on` for that run's own database alone** (`alter database u28dlw set`,
  printed; `show log_lock_waits` → `on` inside the JVM): **PostgreSQL T2, T2, T2; H2 T2, T2, T2.**

**The ⚑9 timing margin, said as the two captures (RED #1208).** The gap orders the two asks; the victim is not a latch's. With a gap of
300 T2's request reaches PostgreSQL inside `deadlock_timeout` of T1's, so when T1's own check runs, the circle is already closed and
T1's request is refused. With the gap of 1500 T1's check runs before T2 has asked: it finds no circle (the server logs that T1 is still
waiting), and T2's check, later, finds it and T2's request is refused. On H2 the request that closes the circle is refused in both
designs. The receipt prints `deadlock_timeout 1s` and the configured gap beside every victim; the gap-0 plant (below) shows the victim
moving when the margin goes. In every round the survivor commits and the second connection reads the seed unchanged: Ravi 2, Meera 1.

**H2's chain carries its cause line (S4.8, RED #1205):** H2 words this refusal as it words 25's serialization refusal — the same class,
the message "Deadlock detected. The current transaction was rolled back.", the same first cause and 40001 — and only its last cause
tells them apart: `MVStoreException: Transaction <n> has been chosen as a deadlock victim.` (`<n>` masked), asserted present in every
round; the plant that feeds 25's lost-update chain to this check fails it. PostgreSQL's chain: `CannotAcquireLockException` ←
`LockAcquisitionException` ← the driver's `ERROR: deadlock detected` (40P01), its message naming both processes (labelled by the
harness: the pid each thread printed with `pg_backend_pid()` inside its transaction).

**PostgreSQL's own lines** (S4.11): `docker logs --since` a stamp taken before the JVM, the records of that JVM's two backends only,
split by a marker each round logs from the second connection (`raise log`), each pid written as the label of the thread that printed it
(`srv.py`), transaction ids and measured figures masked. The server's victim is the backend whose pid T1 (gap 300) or T2 (gap 1500)
printed — matched every round. Round 1 of each:

<!-- captured: server begin -->
```
PostgreSQL, gap 300, round 1 - the victim T1's backend:
ERROR:  deadlock detected
DETAIL:  Process <pid of T1> waits for ShareLock on transaction <xid>; blocked by process <pid of T2>.
CONTEXT:  while locking tuple (0,2) in relation "customer"
PostgreSQL, LABELLED gap 1500 and log_lock_waits = on, round 1:
[T1] LOG:  process <pid of T1> still waiting for ShareLock on transaction <xid> after <masked>
[T2] LOG:  process <pid of T2> detected deadlock while waiting for ShareLock on transaction <xid> after <masked>
[T2] ERROR:  deadlock detected
```
<!-- captured: server end -->

### The fix — one order (`order`)

Both lock Ravi first, then Meera. T2 asks for Ravi while T1 holds him and blocks; the second connection witnesses it (as in `wait`)
before a latch releases T1; T1 takes Meera, nobody holds it, and commits; T2 then gets Ravi and Meera and commits. Three rounds per
database: both commit, no thread throws, the order derived from the one log (T2 seen blocked before T1's commit began, T2's first lock
returned after T1's `Initiating transaction commit`), the rows unchanged.

### The DDL (R.252, `xcheck`, RED #1209)

`probe.x.XMain` (`@EntityScan("com.tiffinbox")` alone, `scripts.action=create`, a file, never run) over the anchor's libraries: md5
**`9cf92b8cae3abfd0f1c0706bfe7a4373`**, byte for byte `../c7-unit27/xcheck.sql` (`cmp`). The callback sentence, said: **the same hash as in
the lesson called Optimistic Locking with At-Version.**

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/t/Buf.java harness/src/probe/t/H.java harness/src/probe/t/Lock28.java harness/src/probe/t/Main.java harness/src/probe/t/Run.java harness/src/probe/t/Seed.java harness/src/probe/t/repo/Locks.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" probe.t.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
docker run -d --pull never --name c7u28-pg -p 127.0.0.1:20078:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker exec c7u28-pg pg_isready -U sa -h 127.0.0.1 -q
docker exec c7u28-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
docker exec c7u28-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "alter database $DB set log_lock_waits = on"
docker logs --since "$ST" c7u28-pg
```

**The `javac` line** compiles the harness with `-parameters` against the anchor's libraries into `.harness/hc`. **The two java lines**
run `probe.t.Main` (every scenario; the PostgreSQL driver from this unit's `.m2-demo`) and `probe.x.XMain` (`xcheck`), each from
`.harness/run` (`V` the JVM flags — the scenario `-Ds=locks|wait|txtimeout|deadlock|order`, the deadlock's `-Dgap`, `-Drounds`,
`-Dlabel`, PostgreSQL's `-Dpg.db` and `-Dpg.pwfile` — `A` the arguments, R.193, each printed as `$ V=(…)` / `$ A=(…)`), each under
`perl -e 'alarm 240; exec @ARGV'` (R.247). **The docker lines** start the container (loopback only, the password from the 0600 file),
wait for it, make a fresh database per JVM (`DB` printed before each), set the labelled run's one per-database setting, and read the
server's log since the stamp `ST` taken before a deadlock JVM (the stamp is not printed). The lines read from `anchor/README.md` (2,
each asserted whole) are its package and extract lines.

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; s4 = s3, the brief; it holds the PostgreSQL driver 42.7.14).
One Maven run: the anchor's copy with its tests (the build's summary lines summed and asserted 18 · 0 · 0 · 0), `offline: yes`, 0
`Downloaded from` lines. After it the script asserts `.m2-demo` holds Boot's parent 4.1.2, `hibernate-core-7.4.13.Final.jar`,
`spring-data-jpa-4.1.2.jar`, `spring-tx-7.0.10.jar`, `spring-orm-7.0.10.jar`, `h2-2.5.250.jar` and the driver. **At run time** the
harness binds no port; H2 is in each JVM's memory (`jdbc:h2:mem:u28`, xcheck's `x28`, the exercise's `ex`); PostgreSQL listens on
`127.0.0.1:20078` only (`docker port` asserted) and is asked by the harness's JDBC and by `docker exec` / `docker logs`. **`docker run
--pull never`**: the image `postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873` must be on the machine
(`docker image inspect`, before anything starts). **No network act**: the section's dated sweep is the brief's
(`_research/spring-boot-metadata-2026-11-10.xml`, `spring-data-bom-metadata-2026-11-10.xml`: the 4.1 line ends 4.1.2, `4.2.0-RC2` not
GA — ⚑6, R.223). Spring Framework's version is printed by every harness JVM from `spring-tx`'s manifest (`7.0.10`), beside Spring Data
JPA's (`4.1.2`), `Version.getVersionString()` and Hibernate's `HHH000001` line (S4.13), before the context starts; PostgreSQL's
`select version()` and the driver's name and version in every harness JVM's `database:` line.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `anchor` → `../c7-unit27/after` (a link; `readlink` asserted) — Section 4's frozen anchor. Never built in place.
- `harness/` — `src/probe/t/Main.java` (unit 25's: a Spring Boot context, `WebApplicationType.NONE`, `@EntityScan("com.tiffinbox")`,
  `@EnableJpaRepositories` on `com.tiffinbox` and `probe.t.repo` — `Found 2 JPA repository interfaces.`; the PostgreSQL URL built inside
  the JVM from `-Dpg.db` and `-Dpg.pwfile`, port 20078; the three version lines first), `Run.java` (the scenarios `locks`, `wait`,
  `txtimeout`, `deadlock`, `order`; the shipped seed again before each part; the two threads, T1 and T2, their latches, the witness
  through the second connection, the derived order lines; the round markers on PostgreSQL), `Lock28.java` (the `@Transactional`
  methods each part calls through the proxy: the locking reads, `hold`, `ask`, `both` — two rows in the order given, the gap —,
  `deadline` and `longStatement` with `timeout = 1`; each latch wait bounded by 60, a guard that throws, never an order),
  `repo/Locks.java` (the locking repository on the anchor's `CustomerEntity`: `@Lock` and the three `jakarta.persistence.lock.timeout`
  hints), `Buf.java` (the one appender, and the PROBE lines' path: a line printed when it arrives, or, while two threads run, kept in the
  one order it arrived and printed thread by thread; a pid written as its thread's label), `H.java` (helpers: the chain with SQLState,
  the second connection — `DriverManager` on the same URL — and its reads), `Seed.java` (unit 25's: the shipped `Database` built in
  code); `src/probe/x/XMain.java` (xcheck's context, unit 25's byte for byte); `src/probe/t/ex/ExApp.java` (the exercise's, compiled
  only by the exercise); `logback.xml` (one line per event with its thread, through `Buf`; `org.hibernate.SQL` DEBUG,
  `JpaTransactionManager` DEBUG, Hibernate's JDBC error lines at WARN, the version and start lines at INFO, the rest WARN); `dur7.py`
  (the builders', byte for byte, md5 `41667fed…`). English names only (R.215): Ravi, Meera, Sunil, Priya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `anchor` (the copy, built there), `hc`, `run`, `secrets/pgpw` (0600), the
  checkers `dur.py`, `s28.py`, `chain.py`, `locks.py`, `vict.py`, `srv.py`, `srv.raw` (the server's log since the stamp), `ex`, the
  logs. `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 20070-20079):** 20078 the container (`127.0.0.1` only) · 20070-20077 unused (the harness JVMs bind none) · 20079 never
  bound. All ten are checked free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): the password → `<pw>`; this folder → `…`, the folder
above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; an EntityManager's identity →
`SessionImpl(<n><open>)`; Spring Data's scan figure → `<n>`; the deadline's date → `<date>`; H2's transaction numbers (`Transaction <n>`,
`transaction <n>(<n>)`, `tx <n>`) → `<n>`; a PostgreSQL transaction id → `<xid>`; a pid the harness did not label → `<pid>`; a measured
figure with its unit (H2's allocated interval, PostgreSQL's still-waiting figures) → `<masked>`; the harness's `PIDMAP` lines (each
round's two pids, for `srv.py`) taken out. The harness itself writes a PostgreSQL pid that a thread printed as that thread's label
(`<pid of T1>`), in its own lines and in the server's (`srv.py`). Filters: a harness JVM's log is printed whole (trailing spaces
dropped); the server's log by its two backends and the round markers; the scripts' foreign-key names → `FK<name>` on screen (the md5s
are the files'). Hygiene, over every capture: raw password copies 0 (each raw run counted before the mask, every capture, log, the
server's log and file after); no absolute path, unit number, log time, timestamp, numbered thread, JDK or OS token, measured figure,
pid, transaction id, `PIDMAP` line, deadline date, stack frame, unmasked identity or URL; every JVM pinned and under its alarm; no kill
by name, no bare `wait`; **no sleep in `harness/src`** (S4.18); no H2 database file outside `.harness` (R.195); no dish name (R.215).
The prose gates, before any build: no duration word (dur7, R.172) **and no duration meaning** (S4.7's family, R.264, unit 27's gate
carried); no dish name; no placeholder line and no empty "What it prints" block; **S4.8's, S4.14's and ⚑9's readings, per sentence**
(`s28.py`, 11-case self-test: the waits' refused class name, "the cheaper transaction", "the later waiter is always the victim", "a
shared lock on H2", a PostgreSQL victim claim without its gap or `deadlock_timeout`, a server-wide setting); no SQL string outside the
captured blocks and the values line (R.225); no server-wide setting statement in the script or the harness (S4.11).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven or the
`javac` it waits for (`$mpid`, with every process under it), the exercise's shell (`$xpid`), sweeps its own process group for any
harness or exercise JVM, Surefire fork, `javac`, Maven, `docker exec` or `docker logs` left, **removes the container** (`docker rm -f`,
again until `docker ps -a` names it no more — `CSTARTED` is set before `docker run`), deletes the capture runs it had not finished
(`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured (2026-11-12, on scratch mirrors of this folder — its files, `.m2-demo` and the published captures copied, `c7-unit27` and
`c7-tiffinbox` linked; the script as committed):** `receipts.sh` (/bin/bash 3.2) started `env -i` in a session of its own **with SIGINT
at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group once the named process was in it,
the state read 5 s after its exit — three trials:

```
build (surefirebooter seen: 2): processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · the container left: no · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness (probe.t.Main seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · the container left: no · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
container (-Ds=deadlock seen: 1, the container up: yes): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · the container left: no · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the anchor's Maven build, its Surefire fork running (before the container); `harness` — the first harness JVM (`locks`, H2,
the container up); `container` — the first deadlock JVM, the container up and asked. `pgrep -x java` afterwards: none; `docker ps -a`:
`open-webui` only.

## 1 · locks — the SQL of each lock (both)

One harness JVM per database (a fresh PostgreSQL database `u28lk`): eight steps, each between markers, its SQL lines, its result, its
chain if it threw, and the second connection's read of Ravi and Meera after it. `locks.py` builds the table above and checks it.

## 2 · wait — four asks while T1 holds Ravi (both; S4.8, S4.18)

One harness JVM per database (`u28wt`); for each ask the seed again, the two threads' lines thread by thread, the main thread's, the
derived order line (the plain ask) and the outcome line.

## 3 · txtimeout — `timeout = 1`, configured (both; the long statement PostgreSQL's)

One harness JVM per database (`u28tt`): the deadline part on both, the long statement on PostgreSQL.

## 4 · deadlock — opposite orders (both; the failure receipt; S4.6, S4.8, S4.11, ⚑9)

Four harness JVMs: H2 and PostgreSQL (`u28dl`) at the gap 300, then the labelled H2 and PostgreSQL (`u28dlw`, `log_lock_waits = on` for
it alone) at the gap 1500; three rounds each; PostgreSQL's server lines after each PostgreSQL JVM. Each of the three runs is checked
for its victims before the three are compared (`pre_deadlock`), so a run whose victims move fails on them, with every round's victim
printed.

## 5 · order — one order (both)

One harness JVM per database (`u28or`), three rounds each.

## 6 · xcheck — the harness's DDL script, against the version lesson's (R.212, R.252)

One `probe.x.XMain` JVM over the anchor's libraries; its script `cmp`-equal to `../c7-unit27/xcheck.sql`.

## 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196, S4.16)

`exercise/README.md`'s block, then `exercise/SOLUTION.md`'s, in one `env -i` shell — `/bin/bash --noprofile --norc`, then
`/bin/zsh -f`; each file's "What it prints" block = the run, line for line.

## Exercise

`exercise/README.md`, the spoken line (22 words by `wc -w`, R.203 ≤ 25):

Your turn: the README's two transactions lock Ravi and Meera in opposite orders, and one is killed. Lock them in one order.

`exercise/SOLUTION.md` — the one changed line (T2's call names Ravi first) and what it prints. The exercise runs on H2 (the brief);
the `deadlock` and `order` captures are its two shapes on both databases.

## The ledger rows and hand-offs this unit pays

- **No ledger row** is 28's (the brief's §LEDGER; `PROMISE-LEDGER-2026-11-01.md`).
- **Section 4's evidence is complete** with this unit; the anchor stays frozen at `../c7-unit27/after`.
- Called back by title, no new gloss (R.204, R.224): the lesson called *Optimistic Locking with At-Version* (unit 27 — the version
  column whose UPDATE `PESSIMISTIC_FORCE_INCREMENT` sends, and the DDL hash, R.252); the lesson called *Isolation Levels* (unit 25 — H2's
  serialization refusal, the chain this unit's H2 cause line tells apart).

## RE-MEASURE — the brief's items this unit settles

- **#1** (the exercise as README + SOLUTION files, bash + zsh, `env -i`) — settled for 28: `exercise` (the probe's `same` end states —
  opposite orders: T2 the victim, Ravi 2, Meera 1; one order: both commit — on an entity of the exercise's own; H2 only).
- **#5** (28's SQL over 27/after) — settled: every SELECT list carries the version column, the whole line in the values;
  `PESSIMISTIC_FORCE_INCREMENT` on `CustomerEntity` itself sends `update customer …` with the version.
- **#7** (28's `wait` inside receipts, 3/3 per database) — settled.
- **#11** (the plain wait's blocked-state witness and the latch order) — **measured**: PostgreSQL's activity view says `Lock` /
  `transactionid` for T2's backend with T1's pid as the blocker; **H2's sessions table names T1's session as T2's blocker** (the column
  the brief found in the H2 jar, its value measured here for the first time), both before T1's release, 3/3.

## What differed from the brief

- **The two threads' lines are printed thread by thread, not in arrival order.** Two threads that run at the same time interleave their
  log lines differently from run to run (T1's `Closing JPA EntityManager…` against T2's next line, after a release), so a capture in
  arrival order is not 3/3. The harness's appender (`Buf`) keeps the lines in the one order logback received them, prints each
  thread's in its own order (which the latches fix), and **derives the order between the threads from that kept sequence**, printing it
  as a line (`the order, read off the one log: … yes`). That is S4.18's "the order read off the capture, never typed" read inside the
  JVM from the log's own sequence; the receipt asserts the derived lines. For RED.
- **The gap without a sleep:** a `CountDownLatch` named `gap` that nobody counts down, its `await` bounded by the configured
  value, named `gap` and printed (`… after a configured gap of 300`). It satisfies S4.18 because it
  orders nothing between threads that the receipt claims: the latches order the first locks and T1's ask; the gap only holds T2's
  second ask back by the configured margin (⚑9), and **who is refused is read off the capture** (the threw lines per thread, and the
  server's ERROR record matched to the thread's pid). `txtimeout`'s idle wait is the same construct (`idle`, 1500, configured).
- **The plain wait's witness polls the database, not a clock:** the second connection asks again and again while T2 is alive (no pause
  between asks) until T2 is seen blocked; if T2 ends first the witness says so and the check fails (the no-`@Lock` plant).
- **`order`'s T2 line:** the prompt's "T2's first lock SQL after T1's `Initiating transaction commit`" cannot hold — Hibernate logs a
  statement before it sends it, so T2's locking SELECT is logged before it blocks, before T1's commit. The receipt asserts what the log
  can show: **T2's first lock returned** (its own line after the SELECT) after T1's `Initiating transaction commit`, and T2 seen blocked
  before T1's commit began.
- **The brief's mask token for a measured figure is `<masked>` here**, figure and unit together: the brief's token is the unit's
  abbreviation, a word dur7 refuses, so this README could not quote the masked server lines (`… after <masked>`), nor H2's
  `allocated time interval <masked>`.
- **PostgreSQL's server lines are filtered by the JVM's two backends, not by database name**: the image's `log_line_prefix` carries no
  database (`%m [%p]`), and `log_line_prefix` cannot be set per database (S4.11 allows only `alter database … set`). Each round logs a
  marker (`raise log 'u28 marker: …'`) from the second connection, and `srv.py` keeps, per round, the records of the two pids that
  round's threads printed (the `PIDMAP` lines the harness prints raw and the mask takes out).
- **The pids are labelled inside the harness** (`<pid of T1>`), in its own lines, the chain's message and — by `srv.py` — the
  server's; a pid nobody printed would show as `<pid>` and fail the checks. The brief's hook `Process <a> … blocked by process <b>`
  is this unit's `Process <pid of T1> … blocked by process <pid of T2>`.
- **The H2 timeout case** (the hint 1000) is H2's `HYT00` with H2's own last cause (`… within allocated time interval <masked>`), the same
  shape as the hint 0's; H2 has no separate lock-timeout message.
- **The exercise's entity is its own, `Diner`, locked through a Spring Data repository of its own** (`Diners`, `@Lock`): an
  `EntityManager` locking query (tried first, development run) gives Hibernate's Jakarta Persistence class untranslated — the class
  name S4.8 refuses for the waits — while the lesson's waits go through a repository and are Spring's `CannotAcquireLockException`. The
  repository keeps the exercise's chain the lesson's. Its messages name `probe.t.ex.Diner`/`DINER` nowhere on screen: the runner prints
  the chain's classes and its last cause's first sentence, its numbers taken out (`Transaction <n> …`).
- **The exercise's logging is Boot's own at WARN** (`--logging.level.root=warn`): the harness's `logback.xml` names the harness's
  appender class, which the exercise's class path does not hold; the block keeps the runner's PROBE lines only.
- **`locks` has an eighth step,** `EntityManager.find` with `PESSIMISTIC_WRITE` (the probe's), beside the brief's seven.
- **The labelled 1500 run is another pair of JVMs inside `deadlock`** (one per database), each printing its label line; on PostgreSQL its
  own fresh database `u28dlw` gets the one setting, never the gap-300 database.
- **`order` runs three rounds per JVM** (the prompt's 3/3) with the witness each round; the probe's `same` ran without one.
- **The anchor's build runs its tests** (18, asserted) — unit 25's form; the brief's cost note did not ask for them.
- **No network act**; the push at the end is the only one. The start's `main...origin/main` = `0 0` was read from the local refs.

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror of this folder (its files and `.m2-demo` copied; `c7-unit27`, `c7-tiffinbox`, `c7-unit25`, `c7-unit09` linked),
`env -i`, a session of its own, `/bin/bash` 3.2, the script as committed but the plant; each **exit 1**, `receipts.md5` and `README.md`
unchanged (nothing written). A plant marked † also takes, in its mirror only, the captures it does not target out of the script, so the
targeted check is the one that fires. The ten above the line die before the build; the eight below start the container (one at a time).

| plant | caught by |
|---|---|
| "T2 waits" and the family's first word (no end to the wait) in a README line | the duration gate: `<- S4.7's family: a duration meaning` |
| the hint 1000 voiced as a duration (the family's number-and-unit form) | the duration gate: `<- S4.7's family` |
| the refused class name of the waits in a README sentence | `s28.py`: `S4.8: a refused name` |
| "The later waiter is always the victim." | `s28.py`: `S4.14: the victim is always one waiter` |
| `log_lock_waits` by a server-wide statement (the script's and the README's setting line) | `S4.11: a server-wide setting statement … per-database settings only` |
| an Indian dish name | the dish gate (R.215) |
| a to-do marker line | the placeholder gate |
| a typed SQL string in prose ("… ends in" + the H2 clause) | the typed-SQL gate (R.225) |
| `Thread.sleep(gapMs)` in place of the gap's latch | the sleep grep: `a harness class sleeps (S4.18)` |
| the version lesson's md5 typed as unit 09's (`f5956370…` for `9cf92b8c…`) | `../c7-unit27/xcheck.sql must be the version lesson's filed script, md5 f5956370…`, at the start |
| a wrong published hash (`locks`, its last digit) | `locks is not the published capture` |
| no Spring Framework version line (`Main.java`'s print removed) | `locks H2: the version lines … (S4.13)` |
| the password in a log (`Run.java` prints the URL whole) | `a harness JVM printed the password (1 raw copies before any mask) - R.214` |
| a measured figure unmasked (the still-waiting mask taken out) | the mask's self-test, before any capture |
| **28's H2 deadlock check fed 25's lost-update chain** (`../c7-unit25/.r-anomalies.out`, H2 REPEATABLE_READ's lost-update cell) | `the MVStoreException cause line naming a deadlock victim is ABSENT (S4.8, RED #1205): org.h2.mvstore.MVStoreException:  [2.5.250/105]` — its message, first cause and 40001 passed |
| **no `@Lock` on the plain wait** (`findWaitById`; † `locks` out) | `pre_wait`, run 1: `witness: T2 was never seen blocked - it ended first` · the derived order `no · no`, on both databases (S4.18) |
| a changed "What it prints" line (exercise/README.md, its last: Ravi 3; † every capture but `exercise` out) | the exercise's line-for-line comparison |
| **the gap 0, 9 rounds** (RED #1208; † `locks`, `wait`, `txtimeout` out) | `pre_deadlock`, run 1: `the victims per round at the configured gap 0 (deadlock_timeout 1s, 9 rounds) - H2: T2 T2 T2 T2 T2 T2 T2 T2 T2 · PostgreSQL: T1 T2 T2 T1 T2 T2 T2 T1 T1` — **PostgreSQL's victim moves (T1 4 of 9, T2 5 of 9)** when the margin goes; H2's does not (T2 9 of 9) |

The gap-0 rounds agree with RED's (T1 4 / T2 8 of 12): without the margin either PostgreSQL session's check can run first. Not run: a
plant on the anchor's tests (untouched); the gap-0 plant over more JVMs (one was enough to fail).

## Found on the way

- **H2's blocker column has a value**: `information_schema.sessions`' blocker of a session waiting on a row lock is the holder's
  session id (RE-MEASURE 11).
- **On the `EntityManager` path a lock refusal is not Spring's class** (the exercise's first form, above): Spring translates a refusal
  only through a repository or a `@Repository` bean; the waits of the lesson go through `Locks`, a repository.
- **PostgreSQL's lock-timeout message carries its tuple** (`Where: while locking tuple (0,1) in relation "customer"`); the lock-timeout
  0 message does not.

## CARRIED

- **`_builders/dur7.py` and S4.7's duration-meaning family** — still the tooling's (the brief's CARRIED); this unit's gate carries unit
  27's as is.
- **H2's statement timeout** — not shown (the brief's CARRIED: 23 measured none on H2); `txtimeout` speaks PostgreSQL for the long
  statement and both for the deadline.
- **Section 4's evidence is complete** — next are the six scripts 23-28 (FACTORY-NEXT).

## For RED

- **The order between threads is derived inside the JVM** from the appender's kept sequence (What differed, first item), and printed as
  a derived line; the capture's own line order is per thread. A slide that shows two threads' lines interleaved must not be made from
  this capture's line order.
- **The gap-300 victim is a timing margin, not a latch** (⚑9, RED #1208): the receipt prints `deadlock_timeout 1s` and the gap beside
  every victim and the README says so; the gap-0 plant shows the victim moving (its rounds in the plant table). A slide says "with a
  configured gap of 300" beside the victim.
- **The duration gate:** unit 27's, carried as is — its two exempt sentences (26's Course 13 sentence, 27's exercise line) are not in
  this unit's prose, so the exemption changes nothing here; 28's exercise line passes the family unexempted.
- **S4.8's refused class name** is refused per sentence in this README and the exercise files by `s28.py`; it is therefore not
  written here even where it is a measured fact (the exercise's first form, What differed).
- **`<masked>` for the brief's figure token** (What differed): the script-writer quotes the server's still-waiting line as `after <masked>` or cuts it
  before "after".
- **H2's PESSIMISTIC_READ** is the same clause as PESSIMISTIC_WRITE (the table) — "a shared lock on H2" is refused by `s28.py`.
- **Not measured here:** a deadlock between more than two transactions; `deadlock_timeout` other than its default (`1s`, read by
  `show`); H2's statement timeout; TiffinBox's routes (no route locks).

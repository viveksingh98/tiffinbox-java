# c7-unit25 — Isolation Levels

Course 7 · Data with JPA & Hibernate · Section 4 (Transactions), its third unit and **its first on PostgreSQL**, **a harness unit — no
change to the anchor** (brief ⚑1): `anchor` is the link to `../c7-unit17/after`. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring
Boot 4.1.2** (Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final), 2026-11-11, **on two databases** (brief ⚑2):
**H2 2.5.250** (the anchor's pin, in each JVM's memory) and **PostgreSQL 18.6** (`postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873`,
one container per run, `--pull never`, `127.0.0.1:20048` only; the JDBC driver 42.7.14; the two live sessions' client `psql` 17.10).
**Isolation** — how much of another transaction's work one transaction may see — comes in four levels; five anomalies show what each
level lets through. Measured: the 40 cells (five interleaves × four levels × two databases) by two JDBC connections; nine scenes in two
live `psql` sessions; Spring's `@Transactional(isolation = …)` on the connection; the persistence context, whose memory makes a read look
repeatable; and `readOnly`, which only PostgreSQL enforces on a write.

**No anchor change.** `anchor` → `../c7-unit17/after` (`readlink` asserted). `receipts.sh` prints `diff -rq -x .m2-demo -x target -x
secrets -x .harness anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record — and, from a later anchor change on
(26, 27), prints a note instead (R.211). The anchor is copied under `.harness/anchor` and built there with its README's package line
(offline; its 18 tests run inside that build, their summary lines summed and asserted 18 · 0 · 0 · 0), its jar extracted with the
anchor's own line; the harness runs over those 91 libraries, with the PostgreSQL driver from this unit's `.m2-demo`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5`. **Start it in a process group of its own** (a
terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be seeded first (below). **Docker
must run and hold the image** (`docker image inspect` before anything starts; the script never pulls). The container `c7u25-pg` is
created by the script and removed by it — at the end, after a failed check, and on Ctrl-C (the trap's `pgrm`).

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files). Development runs fixed the captures and the checks; the first full passing run wrote every capture 3/3, and those md5s are
`receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `608c90a53efc24b5d95cccca994a9980`): 230 s under
`./receipts.sh`** (/bin/bash 3.2.57, 2026-11-11 from 19:24 CET), **268 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from 19:28
CET) **and 258 s from a sealed fresh clone** (below, from 19:33 CET): each exit 0, all 7 captures 3/3 = published, every check passed,
the Maven run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty at the start and the end, the
container removed, nothing listening on 20040-20049 at the end; each terminal log through `check_unit7.py 25 --runlog` — `RESULT (run
logs): PASS` (the unit gate: no 25 script yet). **Nothing was downloaded; nothing was pulled.**

Published hashes: anomalies `4fcb79c073230d134c882aff994aee4f` · psql `a0bf7137f0eaf3649a0cab66860cde3d` · spring `daa90c7534cc242da87140c8f05fc872` · context `aab85eaba0b66eebae28578a604109a8` · readonly `548be4d1547f8c5aa50ca277f72e6f35` · xcheck `da193a4070d1d1fd404a2a806671397e` · exercise `cc84ed7e045cf78fbb4dbfdb4762c6e6`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string
typed in this README outside its captured blocks is refused):

<!-- values: begin -->
the values the video may say: H2 2.5.250 and PostgreSQL 18.6 (driver 42.7.14), Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - anomalies: 40 cells, mismatches 0; H2 RU SSSSS · RC -SSSS · RR ---RS · SER ---RS; PostgreSQL RU -SSSS · RC -SSSS · RR ---RS · SER ---RR; the hook, B at READ UNCOMMITTED while A's 9 is uncommitted: H2 reads 9, PostgreSQL reads 2; H2's lost-update refusal: org.h2.jdbc.JdbcSQLTransactionRollbackException: Deadlock detected. The current transaction was rolled back. Details: "CUSTOMER"; SQL statement: ⏎ update customer set meals_per_day = 3 where name = 'Ravi' [40001-250], its cause org.h2.mvstore.MVStoreException:  [2.5.250/105] (no deadlock victim) · psql: RU 2 and 2 · RC 2 then 9 · RR 2 then 2 · RC phantom 2 then 3 · RR 2 then 2 · could not serialize access due to concurrent update (40001) · could not serialize access due to read/write dependencies among transactions, Canceled on identification as a pivot, during commit attempt. (40001) · (waiting: no answer yet) until A commits · canceling statement due to lock timeout (55P03) · spring: 1/2/4/8 set per transaction, DEFAULT 2 after each, one physical connection, Hikari null · context: READ_COMMITTED - A (native SQL) 2 then 9 · B (findById) 2 then 2, 0 SQL statements, the same instance; REPEATABLE_READ - 2 then 2 both ways · readonly: MANUAL, isReadOnly true, the edit not written on both; the native UPDATE committed on H2, refused on PostgreSQL (org.hibernate.exception.GenericJDBCException <- org.postgresql.util.PSQLException: ERROR: cannot execute UPDATE in a read-only transaction (25006)) · exercise: 2, then 9 -> 2, then 2
<!-- values: end -->

### The cell table — built from the 40 `cell` lines, never typed (S4.4, S4.17, RED #1206)

`anomalies.py` (written by `receipts.sh` into `.harness/`) reads each database's 20 cell lines, checks every cell's level (the code A
and B report, 1/2/4/8, and the level B's own session says — `show transaction_isolation` on PostgreSQL, `information_schema.sessions` on
H2), checks its **control** — A's update count (1 row) and A's own read (9; the VEG count 3 for the phantom) beside B's reads; write
skew's invariant: the VEG sum before (5), what A alone and B alone would leave (4, 3), the sum after — **re-derives the verdict from those
numbers** (dirty: B's read equals A's uncommitted 9; non-repeatable and phantom: B's second read differs from its first and equals A's
committed value; lost update: two increments leave Ravi 3; write skew: the sum after is neither 4 nor 3), compares it with the printed
verdict and with the brief's expected table, and checks each refusal's chain in the cell's own block. The rows below are its output;
`receipts.sh` asserts every one is here, whole, and that there are 40.

| database | level (code) | anomaly | verdict | the cell's control and reads |
|---|---|---|---|---|
| H2 | READ_UNCOMMITTED (1) | dirty read | **SEEN** | B reads 2, then 9 · A: 1 row, A reads 9, not committed |
| H2 | READ_UNCOMMITTED (1) | non-repeatable read | **SEEN** | B reads 2, then 9 · A: 1 row, A reads 9, committed |
| H2 | READ_UNCOMMITTED (1) | phantom read | **SEEN** | B counts 2, then 3 · A: 1 row, A counts 3, committed |
| H2 | READ_UNCOMMITTED (1) | lost update | **SEEN** | both read 2 · A: 1 row, reads 3, commits · B: 1 row, commits · Ravi now 3 after two increments |
| H2 | READ_UNCOMMITTED (1) | write skew | **SEEN** | VEG sum 5 before · A alone leaves 4, B alone 3 · both commit · 2 after |
| H2 | READ_COMMITTED (2) | dirty read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, not committed |
| H2 | READ_COMMITTED (2) | non-repeatable read | **SEEN** | B reads 2, then 9 · A: 1 row, A reads 9, committed |
| H2 | READ_COMMITTED (2) | phantom read | **SEEN** | B counts 2, then 3 · A: 1 row, A counts 3, committed |
| H2 | READ_COMMITTED (2) | lost update | **SEEN** | both read 2 · A: 1 row, reads 3, commits · B: 1 row, commits · Ravi now 3 after two increments |
| H2 | READ_COMMITTED (2) | write skew | **SEEN** | VEG sum 5 before · A alone leaves 4, B alone 3 · both commit · 2 after |
| H2 | REPEATABLE_READ (4) | dirty read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, not committed |
| H2 | REPEATABLE_READ (4) | non-repeatable read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, committed |
| H2 | REPEATABLE_READ (4) | phantom read | not seen | B counts 2, then 2 · A: 1 row, A counts 3, committed |
| H2 | REPEATABLE_READ (4) | lost update | refused | both read 2 · A: 1 row, reads 3, commits · B's update refused: org.h2.jdbc.JdbcSQLTransactionRollbackException, SQLState 40001 · Ravi now 3 |
| H2 | REPEATABLE_READ (4) | write skew | **SEEN** | VEG sum 5 before · A alone leaves 4, B alone 3 · both commit · 2 after |
| H2 | SERIALIZABLE (8) | dirty read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, not committed |
| H2 | SERIALIZABLE (8) | non-repeatable read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, committed |
| H2 | SERIALIZABLE (8) | phantom read | not seen | B counts 2, then 2 · A: 1 row, A counts 3, committed |
| H2 | SERIALIZABLE (8) | lost update | refused | both read 2 · A: 1 row, reads 3, commits · B's update refused: org.h2.jdbc.JdbcSQLTransactionRollbackException, SQLState 40001 · Ravi now 3 |
| H2 | SERIALIZABLE (8) | write skew | **SEEN** | VEG sum 5 before · A alone leaves 4, B alone 3 · both commit · 2 after |
| PostgreSQL | READ_UNCOMMITTED (1) | dirty read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, not committed |
| PostgreSQL | READ_UNCOMMITTED (1) | non-repeatable read | **SEEN** | B reads 2, then 9 · A: 1 row, A reads 9, committed |
| PostgreSQL | READ_UNCOMMITTED (1) | phantom read | **SEEN** | B counts 2, then 3 · A: 1 row, A counts 3, committed |
| PostgreSQL | READ_UNCOMMITTED (1) | lost update | **SEEN** | both read 2 · A: 1 row, reads 3, commits · B: 1 row, commits · Ravi now 3 after two increments |
| PostgreSQL | READ_UNCOMMITTED (1) | write skew | **SEEN** | VEG sum 5 before · A alone leaves 4, B alone 3 · both commit · 2 after |
| PostgreSQL | READ_COMMITTED (2) | dirty read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, not committed |
| PostgreSQL | READ_COMMITTED (2) | non-repeatable read | **SEEN** | B reads 2, then 9 · A: 1 row, A reads 9, committed |
| PostgreSQL | READ_COMMITTED (2) | phantom read | **SEEN** | B counts 2, then 3 · A: 1 row, A counts 3, committed |
| PostgreSQL | READ_COMMITTED (2) | lost update | **SEEN** | both read 2 · A: 1 row, reads 3, commits · B: 1 row, commits · Ravi now 3 after two increments |
| PostgreSQL | READ_COMMITTED (2) | write skew | **SEEN** | VEG sum 5 before · A alone leaves 4, B alone 3 · both commit · 2 after |
| PostgreSQL | REPEATABLE_READ (4) | dirty read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, not committed |
| PostgreSQL | REPEATABLE_READ (4) | non-repeatable read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, committed |
| PostgreSQL | REPEATABLE_READ (4) | phantom read | not seen | B counts 2, then 2 · A: 1 row, A counts 3, committed |
| PostgreSQL | REPEATABLE_READ (4) | lost update | refused | both read 2 · A: 1 row, reads 3, commits · B's update refused: org.postgresql.util.PSQLException, SQLState 40001 · Ravi now 3 |
| PostgreSQL | REPEATABLE_READ (4) | write skew | **SEEN** | VEG sum 5 before · A alone leaves 4, B alone 3 · both commit · 2 after |
| PostgreSQL | SERIALIZABLE (8) | dirty read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, not committed |
| PostgreSQL | SERIALIZABLE (8) | non-repeatable read | not seen | B reads 2, then 2 · A: 1 row, A reads 9, committed |
| PostgreSQL | SERIALIZABLE (8) | phantom read | not seen | B counts 2, then 2 · A: 1 row, A counts 3, committed |
| PostgreSQL | SERIALIZABLE (8) | lost update | refused | both read 2 · A: 1 row, reads 3, commits · B's update refused: org.postgresql.util.PSQLException, SQLState 40001 · Ravi now 3 |
| PostgreSQL | SERIALIZABLE (8) | write skew | refused | VEG sum 5 before · A alone leaves 4, B alone 3 · B's commit refused: org.postgresql.util.PSQLException, SQLState 40001 · 4 after |

**The two databases do not agree** (S4.4 — every sentence names its database): on **H2**, READ_UNCOMMITTED shows the dirty read (B
reads 9 while A's 9 is not committed); on **PostgreSQL** there is no dirty read at any level — B reads 2 at READ_UNCOMMITTED, and its own
session says `read uncommitted`. On **both**, the non-repeatable read and the phantom show at READ_UNCOMMITTED and READ_COMMITTED and
not at REPEATABLE_READ or SERIALIZABLE; the lost update shows at READ_UNCOMMITTED and READ_COMMITTED and is refused at REPEATABLE_READ
and SERIALIZABLE (SQLState 40001 on both). Write skew shows on **H2** at all four levels, SERIALIZABLE included; on **PostgreSQL** it
shows at the first three and is refused at SERIALIZABLE, at B's commit.

**H2's word for its refusal** (S4.8, S4.14, RED #1205): H2 2.5.250, by its cause line no deadlock, refuses the lost update at REPEATABLE_READ and SERIALIZABLE with
`org.h2.jdbc.JdbcSQLTransactionRollbackException: Deadlock detected. The current transaction was rolled back.` (SQLState 40001), beside
its cause line, the first cause `org.h2.mvstore.MVStoreException:  [2.5.250/105]` — an empty message. H2 names this refusal a deadlock; its own cause line
shows none was chosen: the check asserts the cause line is there and that no line saying `has been chosen as a deadlock victim` is
(that line belongs to the lesson called Pessimistic Locking and Deadlocks, H2's real case). The slide quotes H2's words as H2's,
beside the cause line, and explains nothing further.

### Two live sessions — the transcript (S4.12)

`harness/two25.py` (the probe's third driver, made the unit's; Python's standard library only) starts two `/opt/homebrew/bin/psql -X
-q -At` processes, A and B, each writing to a pseudo-terminal that the driver reads as raw bytes; it sends one statement at a time in a
fixed order, then a `\echo` marker, and prints what the session wrote before the marker came back, prefixed with the session's name.
A statement whose marker does not come back within the configured read bound is printed `(waiting: no answer yet)` — no answer within
the bound in the transcript's header; nothing here measures a time, and a loaded machine fails the `cmp` below, loudly. Every scene
begins on a fresh database copied (`create database … template u25psql`) from a template that **the shipped `Database` seeded** — a
harness JVM, `-Ds=seed`, first (RE-MEASURE 3: the driver holds no DDL text; the hygiene grep refuses `create table` in it). The
password reaches the two children in their environment only. `receipts.sh` compares the three runs' transcripts byte for byte
(`cmp`) and this block with the capture's, byte for byte — the transcript **is** the slide's text, `A>` / `B>` kept:

<!-- captured: begin -->
```
# two live psql sessions, A and B: /opt/homebrew/bin/psql -X -q -At -P pager=off -v ON_ERROR_STOP=0 -h 127.0.0.1 -p 20048 -U sa -d postgres (each its own process; output on a pseudo-terminal, read as raw bytes)
# the children's environment: PGPASSWORD (from the 0600 file, never printed) · PGOPTIONS=-c client_min_messages=warning · LC_ALL=C
# read bounds, as configured: 3.0 for each answer · 2.0 for a statement expected to block · 5.0 for the answer after a release and for the lock_timeout statement
# "(waiting: no answer yet)" = no answer within the bound printed above; nothing here measures a time

## 1 a dirty read? B at READ UNCOMMITTED
A> \c postgres
B> \c postgres
A> drop database if exists u25s1 with (force);
A> create database u25s1 template u25psql;
A> \c u25s1
B> \c u25s1
B> begin isolation level read uncommitted;
B> show transaction_isolation;
B  read uncommitted
B> select meals_per_day from customer where name = 'Ravi';
B  2
A> begin;
A> update customer set meals_per_day = 9 where name = 'Ravi';
A> select meals_per_day from customer where name = 'Ravi';
A  9
B> select meals_per_day from customer where name = 'Ravi';
B  2
A> rollback;
B> commit;

## 2 a non-repeatable read? B at READ COMMITTED
A> \c postgres
B> \c postgres
A> drop database if exists u25s2 with (force);
A> create database u25s2 template u25psql;
A> \c u25s2
B> \c u25s2
B> begin isolation level read committed;
B> select meals_per_day from customer where name = 'Ravi';
B  2
A> update customer set meals_per_day = 9 where name = 'Ravi';
A> select meals_per_day from customer where name = 'Ravi';
A  9
B> select meals_per_day from customer where name = 'Ravi';
B  9
B> commit;

## 3 a non-repeatable read? B at REPEATABLE READ
A> \c postgres
B> \c postgres
A> drop database if exists u25s3 with (force);
A> create database u25s3 template u25psql;
A> \c u25s3
B> \c u25s3
B> begin isolation level repeatable read;
B> select meals_per_day from customer where name = 'Ravi';
B  2
A> update customer set meals_per_day = 9 where name = 'Ravi';
A> select meals_per_day from customer where name = 'Ravi';
A  9
B> select meals_per_day from customer where name = 'Ravi';
B  2
B> commit;

## 4 a phantom? B at READ COMMITTED
A> \c postgres
B> \c postgres
A> drop database if exists u25s4 with (force);
A> create database u25s4 template u25psql;
A> \c u25s4
B> \c u25s4
B> begin isolation level read committed;
B> select count(*) from customer where meal_type = 'VEG';
B  2
A> insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('Asha', 1, 100, 'VEG');
A> select count(*) from customer where meal_type = 'VEG';
A  3
B> select count(*) from customer where meal_type = 'VEG';
B  3
B> commit;

## 5 a phantom? B at REPEATABLE READ
A> \c postgres
B> \c postgres
A> drop database if exists u25s5 with (force);
A> create database u25s5 template u25psql;
A> \c u25s5
B> \c u25s5
B> begin isolation level repeatable read;
B> select count(*) from customer where meal_type = 'VEG';
B  2
A> insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('Asha', 1, 100, 'VEG');
A> select count(*) from customer where meal_type = 'VEG';
A  3
B> select count(*) from customer where meal_type = 'VEG';
B  2
B> commit;

## 6 a lost update? both at REPEATABLE READ
A> \c postgres
B> \c postgres
A> drop database if exists u25s6 with (force);
A> create database u25s6 template u25psql;
A> \c u25s6
B> \c u25s6
B> begin isolation level repeatable read;
B> select meals_per_day from customer where name = 'Ravi';
B  2
A> begin isolation level repeatable read;
A> select meals_per_day from customer where name = 'Ravi';
A  2
A> update customer set meals_per_day = 3 where name = 'Ravi';
A> commit;
B> update customer set meals_per_day = 3 where name = 'Ravi';
B  ERROR:  could not serialize access due to concurrent update
B> \echo SQLSTATE :LAST_ERROR_SQLSTATE
B  SQLSTATE 40001
B> rollback;
A> select meals_per_day from customer where name = 'Ravi';
A  3

## 7 write skew? both at SERIALIZABLE
A> \c postgres
B> \c postgres
A> drop database if exists u25s7 with (force);
A> create database u25s7 template u25psql;
A> \c u25s7
B> \c u25s7
A> begin isolation level serializable;
A> select sum(meals_per_day) from customer where meal_type = 'VEG';
A  5
B> begin isolation level serializable;
B> select sum(meals_per_day) from customer where meal_type = 'VEG';
B  5
A> update customer set meals_per_day = 1 where name = 'Ravi';
B> update customer set meals_per_day = 1 where name = 'Sunil';
A> commit;
B> commit;
B  ERROR:  could not serialize access due to read/write dependencies among transactions
B  DETAIL:  Reason code: Canceled on identification as a pivot, during commit attempt.
B  HINT:  The transaction might succeed if retried.
B> \echo SQLSTATE :LAST_ERROR_SQLSTATE
B  SQLSTATE 40001
A> select sum(meals_per_day) from customer where meal_type = 'VEG';
A  4

## 8 a lock wait at READ COMMITTED, no lock_timeout
A> \c postgres
B> \c postgres
A> drop database if exists u25s8 with (force);
A> create database u25s8 template u25psql;
A> \c u25s8
B> \c u25s8
A> begin;
A> update customer set meals_per_day = 9 where name = 'Ravi';
B> begin;
B> update customer set meals_per_day = 5 where name = 'Ravi';
B  (waiting: no answer yet)
A> commit;
B  (answered: the blocked statement's marker came back)
B> commit;
B> select meals_per_day from customer where name = 'Ravi';
B  5

## 9 the same wait with lock_timeout set (a configured value)
A> \c postgres
B> \c postgres
A> drop database if exists u25s9 with (force);
A> create database u25s9 template u25psql;
A> \c u25s9
B> \c u25s9
A> begin;
A> update customer set meals_per_day = 9 where name = 'Ravi';
B> begin;
B> set local lock_timeout = '1s';
B> show lock_timeout;
B  1s
B> update customer set meals_per_day = 5 where name = 'Ravi';
B  ERROR:  canceling statement due to lock timeout
B  CONTEXT:  while updating tuple (0,1) in relation "customer"
B> \echo SQLSTATE :LAST_ERROR_SQLSTATE
B  SQLSTATE 55P03
B> rollback;
A> commit;
B> select meals_per_day from customer where name = 'Ravi';
B  9

sessions closed: A exit 0 · B exit 0
```
<!-- captured: end -->

Scene 1 is the hook's PostgreSQL half: B at READ UNCOMMITTED reads 2, and 2 again while A's 9 is not committed. Scenes 2-5: READ
COMMITTED reads 2, then 9 (non-repeatable) and counts 2, then 3 (a phantom); REPEATABLE READ reads 2 and 2, counts 2 and 2. Scene 6:
the lost update refused at REPEATABLE READ. Scene 7: write skew refused at SERIALIZABLE, at B's commit — PostgreSQL's detail line
names the reason, and A's sum is 4. Scene 8: B's UPDATE waits on A's row lock — `(waiting: no answer yet)` within the bound — and
answers once A commits; Ravi is B's 5. Scene 9: the same wait with `set local lock_timeout = '1s'` (the configured text; `show
lock_timeout` prints it back) ends in `canceling statement due to lock timeout`, SQLState 55P03.

### readOnly — two databases, two answers (READ FIRST 7, S4.17, RED #1213)

On **both** databases a `@Transactional(readOnly = true)` method runs with Hibernate's flush mode `MANUAL`, the JDBC connection's
`isReadOnly()` true and `TransactionSynchronizationManager.isCurrentTransactionReadOnly()` true — each printed inside the transaction —
and an edit of the loaded object is not written (the second connection reads Ravi 2 after). A native UPDATE inside such a method is
where they part: **PostgreSQL** refuses it (`cannot execute UPDATE in a read-only transaction`, 25006); **H2** commits it (Ravi 9), with
the same three prints, read inside that very transaction. So `readOnly` refuses a write on PostgreSQL only; on H2 it is a flush-mode
hint.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 24's recipe, with this unit's folder (this unit's files put into the clone as git takes them — `git
ls-files -o --exclude-standard c7-unit25` — and the root `.gitignore` as committed). Docker must run with the image present: the
container is the same pinned image on `127.0.0.1:20048`; nothing is pulled.

```bash
S=/tmp/sealed25; W="/tmp/sealed 25"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" "$W" && git clone -q "file://$T" "$W/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/../../data-jpa-hibernate/_research/m2-seed-c7-s3/" "$S/central/"
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
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X DOCKER_CONFIG=$HOME/.docker"   # DOCKER_CONFIG: your docker context (the sealed HOME has none)
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$W/tiffinbox-java/c7-unit25" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-11, from 19:33 CET):** a `git clone` of tiffinbox-java at `0333c87` into a path **with a space** (`…/sealed 25/tiffinbox-java`,
in the session's scratch folder), this unit's 16 files put in as git takes them (`anchor` → `../c7-unit17/after` by `readlink`); a
`file://` copy of the s3 seed (5,023 files once `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left
out); pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy;
`/bin/bash` 3.2, `env -i` with the dead proxies and `DOCKER_CONFIG`: **exit 0 in 258 s**, all 7 = published, `offline: yes`, 0
`Downloaded from` lines; the builders' `dur7.py` not beside the clone (its md5 was the check).

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/t/H.java harness/src/probe/t/Iso25.java harness/src/probe/t/Main.java harness/src/probe/t/Run.java harness/src/probe/t/Seed.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" probe.t.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
docker run -d --pull never --name c7u25-pg -p 127.0.0.1:20048:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker exec c7u25-pg pg_isready -U sa -h 127.0.0.1 -q
docker exec c7u25-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
perl -e 'alarm 120; exec @ARGV' python3 -I -B harness/two25.py 20048 .harness/secrets/pgpw u25psql 3.0 2.0 5.0
```

**The harness line** compiles the harness against the anchor's extracted libraries with `-parameters`. **The two java lines** run the
harness and xcheck's context from `.harness/run` (`V` the JVM flags — the scenario `-Ds=anomalies|spring|context|readonly|seed` and, on
PostgreSQL, `-Dpg.db=<the fresh database> -Dpg.pwfile=../secrets/pgpw`; `A` the arguments; each printed as `$ V=(…)` / `$ A=(…)`,
R.193). The harness's class path carries the PostgreSQL driver from `.m2-demo` (the anchor's `lib/` has none — asserted). Every java
line runs under `perl -e 'alarm 240; exec @ARGV'` (R.247; an alarm that fires ends the JVM with exit 142, which the runner refuses).
**The docker lines** start the container from the pinned image (never pulled), loopback only (`docker port` asserted `5432/tcp ->
127.0.0.1:20048`), user `sa`, the password read from the file; wait for it (`pg_isready`, at most 120 tries, 0.5 apart); and make a
**fresh database per JVM** (`u25an`, `u25sp`, `u25cx`, `u25ro`) **and one for `psql`** (`u25psql`, the template), dropped with force first.
**The python line** runs the two-session driver from this folder under its alarm, with its port, the password file, the template and
the three read bounds (3.0 for each answer, 2.0 for a statement expected to block, 5.0 after a release and for the `lock_timeout`
statement — printed again in the transcript's header). The lines read from `anchor/README.md` (2, each asserted whole) are its
package line `mvn -B package` and its extract line.

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; s4 = s3, the brief). One Maven run: the anchor's `package`
(its 18 tests run), `offline: yes` with 0 `Downloaded from` lines in every run of record (the label derived from the build log, never
typed). After it the script asserts `.m2-demo` holds Boot's parent 4.1.2, `hibernate-core-7.4.13.Final.jar`, `spring-data-jpa-4.1.2.jar`,
`spring-tx-7.0.10.jar`, `spring-orm-7.0.10.jar`, `h2-2.5.250.jar` and `postgresql-42.7.14.jar`. **At run time** the harness JVMs and the
two `psql` sessions bind no port; H2 is in a JVM's memory (`jdbc:h2:mem:u25`, xcheck's `x25`, the exercise's `ex`); PostgreSQL is the
container on `127.0.0.1:20048`, asked by the harness's JDBC, by `psql` and by `docker exec`. **No network act**: the image is on the
machine (`--pull never`), and the section's dated sweep is the brief's (`_research/spring-boot-metadata-2026-11-10.xml`,
`spring-data-bom-metadata-2026-11-10.xml`: the 4.1 line ends 4.1.2, `4.2.0-RC2` not GA — ⚑6, R.223). Every harness JVM prints Spring
Framework's version from `spring-tx`'s manifest (`7.0.10`) beside Spring Data JPA's (`4.1.2`), `Version.getVersionString()` and
Hibernate's own `HHH000001` line (S4.13), before the context starts; and its database's line — `select version()` cut at " on " (the
build platform) and the JDBC driver's name and version.

**The two connection paths** (as unit 06 said them for the first PostgreSQL unit): the harness's JDBC reaches the container through
the published loopback port, `127.0.0.1:20048`, with the user `sa` and the password the JVM reads from `.harness/secrets/pgpw`; the
fresh databases are made inside the container by `docker exec … psql` over its own local socket. The two `psql` sessions use the
first path, with the password in their environment.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm). The `psql` children get `LC_ALL=C`.

## The folders, the harness and the ports

- `anchor` → `../c7-unit17/after` (a link; `readlink` asserted) — never built in place.
- `harness/` — `src/probe/t/Main.java` (unit 23's form: a Spring Boot context, `WebApplicationType.NONE`; `@EntityScan("com.tiffinbox")`
  and `@EnableJpaRepositories("com.tiffinbox")` — the anchor's entities and its own `CustomerEntityRepository`: `Found 1 JPA repository
  interface.`; the three version lines before the context; on PostgreSQL the URL built from `-Dpg.db` and the password file, unit 20's
  way), `src/probe/t/Seed.java` (the shipped `Database`, built in code on the run's own database: its `createAndSeed` creates the tables
  with the shipped DDL text and seeds Ravi, Meera, Sunil, Priya and two pauses), `src/probe/t/Run.java` (one scenario per JVM; the
  database's line, the seed read by the second connection, the level codes; `anomalies` — the 40-cell matrix on two JDBC connections of
  its own, one thread, the seed again before every cell, each cell between `PROBE >>> cell …` and `PROBE <<< cell …`; `spring`; `context`
  — two threads, two latches, three rounds per level; `readonly`; `seed`), `src/probe/t/Iso25.java` (`@Service`: the five `@Transactional`
  methods `spring` calls, each printing the JDBC level, the physical connection's number in this JVM and the database's own answer; the
  reader `readTwice` — native SQL (A), then `findById` (B), twice, around the writer's commit — and the writer; `roEdit` and `roWrite`,
  `readOnly = true`), `src/probe/t/H.java` (helpers: the chain printer with the first SQLState, the second connection, the URL cut before
  its `?`), `src/probe/x/XMain.java` (xcheck's context, unit 23's byte for byte), `src/probe/t/ex/ExApp.java` (the exercise's — compiled
  only by the exercise), `two25.py` (the psql driver), `logback.xml` (one line per event, no stack trace, no thread name;
  `org.hibernate.SQL` DEBUG, `JpaTransactionManager` DEBUG, the version and start lines at INFO, the rest at WARN), `dur7.py` (the
  builders', byte for byte, md5 `41667fed…`). English names only (R.215): Ravi, Meera, Sunil, Priya, Asha.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `anchor` (the copy, built, extracted), `hc` (the harness), `run` (the JVMs' working
  folder), `secrets/pgpw` (the password, 0600), `anomalies.py`, `s414.py`, `dur.py` (the checkers), `two-1..3.out` (the transcripts
  `cmp` compares), `ex` (the exercise's copy), the logs. `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 20040-20049):** 20048 the container (127.0.0.1 only) · 20040-20047 unused (no harness JVM, no `psql` and no exercise
  binds a port) · 20049 never bound. All ten are checked free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): the PostgreSQL password → `<pw>` (never printed: every
capture's raw output is counted for it BEFORE the mask and must hold 0 — a harness or a driver that printed it dies — and again after,
in every capture, log and file: "raw password copies after mask: 0"); this folder → `…`, the folder above → `…/..`, home → `~`, the user
name → `<user>`; ` using Java <version>`; an identity hash → `@…`; an EntityManager's identity → `SessionImpl(<n><open>)`; Spring Data's
scan line's figure → `<n>`. **No PostgreSQL pid, transaction id, H2 session id or connection hash is printed at all**: the physical
connection is numbered in the JVM (`#1`), never hashed; the hygiene grep refuses a backend pid or a long transaction number. Filters: a
harness JVM's log is printed whole (trailing spaces dropped); the database line cuts `select version()` at " on " (the build
platform). Hygiene, over every capture: no absolute path, unit number, log time, timestamp, thread number, JDK or OS token, figure of
elapsed time, stack frame, unmasked identity, URL; every JVM pinned and under its alarm; no kill by name, no bare `wait`; no sleep in the
harness or the driver (S4.18); no DDL copy (`create table`) in the harness or the driver (RE-MEASURE 3); no buffered reader in the
driver (S4.12); no `ALTER SYSTEM` (S4.11); no H2 database file outside `.harness` (R.195); no dish name (R.215). The prose gates, before
any build: no duration word (dur7, R.172) **and no duration meaning** (S4.7's family, R.264, self-tested — a spoken count of the timeout among its
cases; `lock_timeout` is quoted as its configured text `'1s'`); no dish name; no placeholder line and no empty "What it prints" block;
**S4.14's readings refused per sentence** — a dirty read said of PostgreSQL without a negation, "readOnly refuses writes" without
PostgreSQL, "deadlock" without H2 and its cause line — **S4.4's** "a level prevents an anomaly" without a database, and S4.3's unscoped
interface sentence, with a twelve-case self-test (the captured transcript and the cell table are left out of the sentence gate: they are
compared with the captures instead); no SQL string in this README outside its captured blocks (R.225).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops what it started (`$pid` — a harness JVM or the
psql driver, with its two `psql` children; `$mpid` — the Maven or `javac`, with every process under it; `$xpid` — the exercise's shell),
sweeps its own process group for any harness or exercise JVM, `two25.py`, `psql -X`, `docker exec c7u25-pg`, Surefire fork, `javac` or
Maven left, **removes the container** (`pgrm`: `docker rm -f c7u25-pg` until `docker ps -a` names it no more; `CSTARTED` is set before
`docker run`, so an interrupt during the start removes it too), deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes
`.r-lock`. The published captures are untouched.

**Measured (2026-11-11, on scratch mirrors of this folder — its files, `c7-unit17`, `c7-tiffinbox` and `c7-unit09` linked, the published
captures copied in — the script as committed):** `./receipts.sh` (/bin/bash 3.2) started `env -i` in a session of its own **with SIGINT
at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group once the named process was in it,
the state read 5 s later — four trials:

```
build: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · container c7u25-pg left: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
container: processes in the group at SIGINT 2 · exit 130 · 5 s later in the group: 0 · container c7u25-pg left: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · container c7u25-pg left: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
psql: processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · container c7u25-pg left: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the anchor's Maven build; `container` — the moment `docker ps -a` first names `c7u25-pg` (the start, before `pg_isready`
answers); `harness` — the first harness JVM (`anomalies` on H2, the container up); `psql` — the two-session driver with its two `psql`
children. `pgrep -x java` afterwards: none; `docker ps -a`: no `c7u25-pg`.

## 1 · anomalies — 40 cells (S4.4, S4.5, S4.8, S4.17)

One H2 JVM, then one PostgreSQL JVM on its fresh database `u25an`. Two JDBC connections of their own (`DriverManager`, the run's URL),
autocommit off, both set to the cell's level, driven on **one thread** in a fixed order — no wait can happen, so no latch is needed:
every interleave reads after the other's write or commit, never against a lock. The seed again before every cell. The interleaves:
**dirty read** — B reads Ravi; A sets 9 (1 row) and reads it, uncommitted; B reads; A rolls back. **Non-repeatable** — B reads; A sets 9,
reads it, commits; B reads again. **Phantom** — B counts VEG; A inserts Asha (VEG), counts, commits; B counts again. **Lost update** — B and
A read Ravi 2; A writes 3, reads it, commits; B writes 3: either it commits (two increments, Ravi 3: one lost) or it is refused. **Write
skew** — A and B read the VEG sum 5; A lowers Ravi to 1, B lowers Sunil to 1, A commits, B commits or is refused; the sum after is
compared with what A alone (4) and B alone (3) would leave. Every read is SQL that reaches the database (S4.5). The failure receipt is
the brief's choice of two: **`context` B** (below); this capture also shows the plan's claim refused — the PostgreSQL dirty-read cell, not
seen at READ_UNCOMMITTED.

## 2 · psql — two live sessions (S4.12)

The template first (`u25psql`, seeded by a harness JVM, `-Ds=seed` — its versions, database line and seed asserted); then the driver.
Checked: the three transcripts byte-identical (`cmp`), each the capture's, the header's three bounds, nine scenes, each scene's reads
by regex (above), one `(waiting: no answer yet)` (scene 8's) and none in scene 9, no marker leaked, both sessions closed with exit 0.

## 3 · spring — `@Transactional(isolation = …)` (both)

Nine calls in one JVM per database: DEFAULT, READ_UNCOMMITTED, DEFAULT, READ_COMMITTED, DEFAULT, REPEATABLE_READ, DEFAULT,
SERIALIZABLE, DEFAULT. Each prints, inside its transaction, `getTransactionIsolation()` on the JDBC connection Hibernate holds (1, 2, 4,
8 — the level codes), the physical connection's number in this JVM, and the database's own answer. The manager's line names the level
(`PROPAGATION_REQUIRED,ISOLATION_READ_UNCOMMITTED`, …). DEFAULT answers 2 (read committed) every time: the level is set per transaction
and reset after, on the same physical connection (`#1` throughout); Hikari's `transactionIsolation` is `null` (Boot sets none).

## 4 · context — the persistence context hides a non-repeatable read (S4.5; the failure receipt)

Two threads, two latches, three rounds per level, per database: the reader's transaction reads Ravi by native SQL (**A**) and by
`findById` (**B**), counts down; the writer's own transaction loads Ravi, sets 9, commits, counts down; the reader reads both ways again.
At **READ_COMMITTED**: A reads 2, then 9 — the anomaly — while B reads 2, then 2, the same instance, and the second `findById` sends **no
SQL** (0 `org.hibernate.SQL` lines between its markers; the second native read sends 1). B is the failure receipt: a test that read the
row with `findById` would call READ_COMMITTED repeatable. At **REPEATABLE_READ**: 2, then 2 both ways. The order is read off the capture
(the first reads, the writer's commit, the second reads — S4.18). After: the second connection reads 9.

## 5 · readonly (both)

`roEdit` loads Ravi and sets 7 on the object in a `readOnly = true` transaction; `roWrite` prints the three attributes inside, then
runs a native UPDATE. The manager's line says `…,ISOLATION_DEFAULT,readOnly`. Checked per database: the prints, the edit not written,
and the write — H2 `the native update: 1 row, committed`, Ravi 9; PostgreSQL `org.hibernate.exception.GenericJDBCException: JDBC
exception executing SQL [ERROR: cannot execute UPDATE in a read-only transaction] […]` ← `org.postgresql.util.PSQLException: ERROR:
cannot execute UPDATE in a read-only transaction`, SQLState 25006, Ravi 2. (The service is a plain `@Service`, not a `@Repository`: no
Spring exception translation, so Hibernate's class is the top of the chain.)

## 6 · xcheck — the harness's DDL script, against the owning-side lesson's (R.212, R.252)

`probe.x.XMain` (no port; H2) writes Hibernate's script for the anchor's two entities: md5 `f595637014e786fa38606859951e4f97`, the same
as in the lesson called One To Many, Many To One and the Owning Side — the shared DDL sentence (R.252), RED #1209.

## 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196, S4.16)

`exercise/README.md`'s block, then `SOLUTION.md`'s, in ONE `env -i` shell (`/bin/bash --noprofile --norc`, then `/bin/zsh -f`); the
broken state is READ_COMMITTED (2, then 9 · two answers), the solved one REPEATABLE_READ (2, then 2 · both reads agree), the kitchen's 9
committed in both; each file's "What it prints" compared line for line; bash and zsh print the same.

## Exercise

**Your turn:** the README's report reads Ravi's meals twice in one transaction and gets two answers. Make both reads agree. (20
words, `wc -w`, R.203.) On H2 for the viewer; the same reader is measured on both databases as `context`.

## The ledger rows and hand-offs this unit pays

Unit 25 owns no row of `PROMISE-LEDGER-2026-11-01.md` (the brief's §LEDGER). It pays the brief's U25 roadmap line as amended:
non-repeatable and phantom reads on PostgreSQL (psql and JDBC); no dirty read on PostgreSQL, one on H2; each slide names its database. It hands
`28` (Pessimistic Locking and Deadlocks) the H2 lost-update chain whose absence-of-a-victim assertion 28's H2 check must not accept
(S4.8), and the psql driver's form (S4.12) if 28 shows sessions.

## RE-MEASURE — the brief's items this unit settles

- **Row 3** (`two.py`'s table from the shipped `Database`, not a DDL copy): settled — the template is seeded by the shipped `Database`
  (a harness JVM), every scene copies it; the driver holds no `create table` (grep).
- **Row 7** (25's `context` and `spring` inside receipts, 3/3 per database): settled — both captures 3/3, each on H2 and PostgreSQL.
- **Row 9** is 26's (C6/31's three adds), not this unit's — the prompt named it; nothing of 25 touches the feed (recorded under What
  differed).
- **Row 12** (25's cell controls, the readOnly H2 cell's three prints): settled — every cell's control printed and checked; the three
  prints inside `roWrite`'s own transaction, on both databases.
- **Row 1** (25's exercise as README + SOLUTION, bash + zsh, `env -i`): settled.

## What differed from the brief

- **The psql driver's resets copy a template** (RE-MEASURE 3): the probe's `two.py` dropped and re-created the tables with its own DDL
  text in every scene; here a harness JVM seeds the template `u25psql` with the shipped `Database`, and each scene runs `create database
  u25sN template u25psql` and `\c` into it (the scene's databases are dropped with force first; `PGOPTIONS=-c client_min_messages=warning`
  keeps the first run's "does not exist, skipping" notice out, so the three transcripts can be `cmp`-equal). The brief's "one database for
  `psql`" is that template; each scene's copy is printed in the transcript.
- **Nine scenes, in the prompt's order**: RU dirty · RC and RR non-repeatable · RC and RR phantom · RR lost update · SER write skew · the
  RC lock wait · `lock_timeout`. The probe's third driver ran them interleaved (RC non-repeatable, RC phantom, RR …) and set
  `lock_timeout` at session level; here it is `set local lock_timeout = '1s'` inside B's transaction, as the prompt says. Two lines the
  probe's driver did not print: A's own read after its write in scenes 1-5 (the control, S4.17), and `\echo SQLSTATE :LAST_ERROR_SQLSTATE`
  after each refusal (psql prints no SQLState by default: 40001, 40001, 55P03). After the lock wait's release the driver prints `B
  (answered: the blocked statement's marker came back)` (with `-q`, psql prints no command tag, so the release would show nothing).
- **The JDBC matrix's interleaves add a read**: the dirty-read cell reads B once before A's write (so B's own baseline, 2, is in the
  cell), and every cell reads A's own value after its write — the controls S4.17 asks for. The probe's cells lacked both (RE-MEASURE 12).
- **The anomaly cells run on one thread**, not with latches: two JDBC connections in a fixed order never meet a lock (no statement waits),
  so there is nothing to order between threads (⚑9 says "two JDBC connections on one thread for 25's matrix").
- **`spring` numbers the physical connection** (`#1`) instead of printing a masked hash: a mask would hide whether it is one connection;
  the number is computed inside the JVM from the identity of the connection under Hikari's proxy. The probe's `rrRo` (REPEATABLE_READ
  with readOnly) is not in `spring`: `readonly` is its own capture.
- **`readonly`'s write is a native UPDATE only**; the brief's READ FIRST 7 also names `save` of a new row (INSERT refused on PostgreSQL) —
  not captured here (CARRIED). On PostgreSQL the chain's top is Hibernate's `GenericJDBCException` (the service is no `@Repository`, so
  Spring translates nothing): class, message, first cause and SQLState asserted.
- **The password file is mode 0600**, read by the container through the bind mount (unit 20 chmod-ed its file 644; measured here: the
  container started with 0600 under OrbStack). The password reaches the harness by `-Dpg.pwfile` (unit 20's way) and psql by its
  children's environment.
- **No per-database setting is made** (S4.11 permits `alter database … set`; 25 needs none) and **no server log is read** (no beat speaks
  of it); a grep refuses `ALTER SYSTEM` in the script and the harness.
- **The failure receipt** is `context` B (the brief's first choice); the PostgreSQL dirty-read cell is in the table as "the plan's claim,
  refused".
- **The prompt's RE-MEASURE "row 9"** is 26's in the brief (C6/31's adds and the feed) — nothing here touches it; recorded, not done.
- **The exercise's change is a `sed` on the copy step** (the block's one changed line), as unit 24's; the viewer edits one annotation.

## Planted faults — each caught (R.65, R.226)

<!-- values: begin -->
Each on a scratch mirror of this folder (its files as committed, `c7-unit17`, `c7-tiffinbox`, `c7-unit09` linked, `.m2-demo` cloned), the
one edit named, `./receipts.sh` under `env -i` in a session of its own; each **exit 1**, `receipts.md5` unchanged (but the first plant,
whose edit is to `receipts.md5` itself), nothing published. The die line, cut:

| plant (the brief's list at 487-489, and the prompt's) | caught by | die line |
|---|---|---|
| a cell typed (README's PostgreSQL READ_UNCOMMITTED dirty-read row said **SEEN**) | the table check (S4.4) | `README.md's cell table does not hold the capture's row: \| PostgreSQL \| READ_UNCOMMITTED (1) \| dirty read \| not seen \| …` |
| `findById` for the native read (`Iso25.nativeMeals`) | `context`'s check (S4.5) | `context H2 READ_COMMITTED round 1: native 2 then 9, findById 2 then 2: expected the line …` |
| "Here PostgreSQL shows a dirty read at READ_UNCOMMITTED." in README | S4.14's sentence gate | `<- S4.14: a dirty read said of PostgreSQL (it reads 2)` |
| a buffered reader in `two25.py` (`os.fdopen(…).readline()` for `os.read`) | the three runs (S4.12) | `psql drifts across three runs (diff .r-psql.1 .r-psql.2 .r-psql.3)` (and the static grep would refuse it at the end) |
| the password in a log (the harness prints the raw URL) | R.214's raw count before the mask | `a harness JVM printed the password (1 raw copies before any mask) - R.214` |
| readOnly's refusal claimed for H2 ("On H2 readOnly refuses the UPDATE.") | S4.14's sentence gate; the H2 cell says `the native update: 1 row, committed` | `<- S4.14: readOnly refuses writes, without PostgreSQL (H2 commits it)` |
| A's UPDATE matches 0 rows (`where name = 'Nobody'` in the dirty-read cell) | `anomalies.py`'s control (S4.17) | `H2 READ_UNCOMMITTED dirty read: the control - A's update matched 0 rows, not 1 (S4.17): the cell proves nothing` |
| `readOnly` removed from `roWrite` | `readonly`'s H2 write cell, its three prints (S4.17) | `readonly H2 write: the three attributes inside the write's own transaction (S4.17): expected the line …` |
| 28's H2 deadlock chain fed to a lost-update cell (the cause line replaced by `… has been chosen as a deadlock victim …` in the H2 block, `anomalies.py` run on it) | the absence assert (S4.8) | `mismatches 2` — the empty cause line missing; `a deadlock victim's cause line in a lost-update cell (S4.8, RED #1205)`; checker exit 1 |
| "The lost update on H2 ends in a deadlock." in README | S4.14's sentence gate | `<- S4.14: a deadlock said of the lost-update cell …` |
| a wrong published hash (`receipts.md5`'s anomalies line, its last digit) | `pub` | `anomalies is not the published capture …` |
| a version claim without Spring Framework's line (`Main` prints no `7.0.10`) | `ver()` (S4.13) | `anomalies H2: the version lines - getVersionString(), Hibernate's HHH000001, Spring Data JPA's 4.1.2 and Spring Framework's 7.0.10 - once in its harness JVM (S4.13)` |
| an Indian dish name (a sentence naming one of the 41 refused words) | R.215 | `an Indian dish name (R.215: English names only): README.md:…` |
| a placeholder line (the refused marker word, then "the output", in exercise/README.md) | the placeholder gate | `a placeholder line in this unit's prose …` |
| a changed What-it-prints line (README's `2, then 9` → `2, then 2`) | `chk_exercise` | `exercise/README.md's "What it prints" block is not what the README's lines printed: 7c7 …` |
| a typed SQL string ("B runs select meals_per_day from customer twice.") | R.225 | `a typed SQL string in README.md (R.225): …` |
| a wrong unit 09 md5 (`X09` ending `…98`) | R.212's check of 09's README | `../c7-unit09/README.md must name f595637014e786fa38606859951e4f98 - Boot's script md5 (R.212)` |
| a duration word (dur7's plural unit-of-time word in a sentence about the lock wait) | dur7 (R.172) | `README.md line …: <the word> <- dur7: this unit speaks no time` |
| `lock_timeout` voiced as a count (B waits "one" of the unit for the lock) | S4.7's family | `README.md line …: <the count> <- S4.7's family: a duration meaning` |
| "SERIALIZABLE prevents write skew." (no database) | S4.4's sentence gate | `<- S4.4: a level prevents an anomaly, without the database` |

**Not run:** a plant for HHH000001 alone or Spring Data's 4.1.2 alone (the same `ver()` line as Framework's, which was run); a gap or
order plant (the matrix is single-threaded; `context`'s order check is unplanted).
<!-- values: end -->

## Found on the way

- **`-q` hides psql's command tags**, so a blocked UPDATE that is released prints nothing; the driver says so itself (`B  (answered: the
  blocked statement's marker came back)`), and the next read shows the value (Ravi 5).
- **psql prints no SQLState by default**; `\echo SQLSTATE :LAST_ERROR_SQLSTATE` (psql 12 and later) prints it without changing the
  error lines' verbosity — 40001, 40001, 55P03.
- **`drop database if exists` prints a NOTICE on the first run only** — a drift between run 1 and runs 2-3 of the same container;
  `PGOPTIONS=-c client_min_messages=warning` keeps it out (every reconnect inherits it, unlike a `set`).
- **`drop database` right after the sessions leave it can wait** for the backends to exit — the development driver's end-of-run drops
  printed `(waiting: no answer yet)` and drifted; the drops moved to the start of each scene, `with (force)`.
- **The PostgreSQL JDBC driver reports the session's level faithfully**: `getTransactionIsolation()` inside a READ_UNCOMMITTED
  transaction is 1, and the server says `read uncommitted` — the level is accepted, only its behaviour is READ COMMITTED's.
- **A 0600 password file works with OrbStack's bind mount** (unit 20 used 644).
- **The docker CLI needs its context** when `HOME` is replaced (the sealed clone): `DOCKER_CONFIG=$HOME/.docker` in the recipe's
  environment; without it the CLI looks at `/var/run/docker.sock` and finds no daemon.
- **Micrometer's `AbstractTimer` warned once** (`'amount' should not be negative but was: -1000000`) in one of three development runs
  of `context` — a timer reading across the two threads — and the capture drifted; `logback.xml` sets that one logger to ERROR
  (declared in the file; no beat reads it).

## CARRIED

- **28** reuses S4.8's H2 assertion on the cause line the other way round (present, in Pessimistic Locking and Deadlocks); this
  unit's lost-update chain is its negative plant.
- **`log_lock_waits` / server log lines** (S4.11's `docker logs --since`): not needed here (no server-log beat); 28 reads them.
- **`readOnly` with `save` of a new row** (the brief's READ FIRST 7 "a `save` inside → INSERT refused"): not captured here (the native
  UPDATE is the beat); the INSERT form stays the probe's.

## For RED

- **Is one thread enough for the matrix?** Every cell's statements run in a fixed order on two connections; none waits on a lock (the
  lost update's B writes after A committed; write skew's two updates touch different rows), so the order is the program's. A cell whose
  statement would block would hang under the alarm (R.247) and fail loudly.
- **The write-skew verdict is derived, not typed**: SEEN iff the VEG sum after is neither A-alone's (4) nor B-alone's (3); the checker
  re-derives it from the cell's printed numbers and the brief's table is the comparison, not the source.
- **H2 SERIALIZABLE lets write skew through** (four levels, 3/3) — the slide says it of H2 by name; "SERIALIZABLE prevents write skew"
  without a database is refused (S4.4's regex, self-tested).
- **PostgreSQL READ_UNCOMMITTED**: B's own session says `read uncommitted` and reads 2 — measured both by JDBC (the cell) and by psql
  (scene 1). The sentence gate refuses a dirty read said of PostgreSQL without a negation.
- **`(waiting: no answer yet)`** means no answer within 2.0 (the configured bound, in the header): a machine loaded enough to delay an
  answer past 3.0 would print a waiting line elsewhere and fail `cmp` and the one-waiting-line check — loud, not silent.
- **`lock_timeout`** is on screen as `set local lock_timeout = '1s'` and `show` → `1s`; the prose never voices it as a count
  (the duration family refuses that case; its self-test holds it).
- **The persistence-context beat** counts SQL lines between the reader's own markers; the writer's statements fall outside them by the
  latches (its commit is printed before the reader's second reads — the order check).
- **What is not measured here**: `readOnly` with a new row's INSERT; PostgreSQL's server log; the lesson called Pessimistic Locking and Deadlocks (28).

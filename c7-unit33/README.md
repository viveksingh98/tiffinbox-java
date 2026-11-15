# c7-unit33 — Batching and the Write Path

Course 7 · Data with JPA & Hibernate · Section 5 (Performance), its fifth unit — **a harness unit: no change to the anchor** (brief ⚑1),
**plus one labelled copy of the anchor under `.harness/` (brief ⚑5)**. `anchor` is the link to `../c7-unit31/after` (= `../c7-tiffinbox`
as of unit 31's commit `4e6e7c9`; unit 32 did not move it); **34 moves the anchor next (C3); 32 and 33 never touched it.** Verified on
**JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final),
2026-11-15, **on H2 2.5.250 and PostgreSQL 18.6** (brief ⚑7: one container per run). Hibernate can send many INSERTs in one trip to the
database — if it knows the ids before it inserts. TiffinBox's ids come from the database, so its inserts never batch; its edits can.
And on Postgres each statement is a trip to the server — the batch makes fewer trips. Every capture is the harness's, except `anchor`:
TiffinBox from the labelled copy and from the anchor itself, on H2 over TCP.

**No anchor change (R.211).** `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` at its
start and end — empty in every run of record — and, should a later unit change the anchor, prints a note instead, never a stop.
`anchor/`'s tree is hashed at the start and the end (`harness/tree33.py`, unit 31's `tree31.py` byte for byte): its file count and md5
are pinned in `receipts.sh` (`T31`, the pin unit 32 holds, read off `python3 -I harness/tree33.py anchor/`) — this unit never edits
`../c7-unit31/after`. **TiffinBox keeps its identity column**: the copy that moves it to SEQUENCE lives only under `.harness/copy-seq`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5`. **Start it in a process group of its own** (a
terminal's foreground job is one; from a tool, `perl -MPOSIX -e 'setsid; exec @ARGV' ./receipts.sh`): `sweep()` stops only processes of
its own group whose command line names the harness, TiffinBox's jar, H2's tools or the container. `.m2-demo` must be seeded first
(below), and the image `postgres@sha256:77f58511…` must be on the machine (`docker image inspect` with the full digest; never pulled).

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s5/` alone (6,772
files), the image `postgres@sha256:77f58511…` present (`docker image inspect`, the full digest), one container per run, removed at its
end. Development runs fixed the captures and the checks; a full passing run wrote every capture 3/3 with the same md5s as the
development passes, and those are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5
`eb1ac876c6487a62357b6226598865ec`): 587 s under `./receipts.sh`** (/bin/bash 3.2.57, 2026-11-15 from 11:16 CET), **604 s under `bash
receipts.sh`** (Homebrew bash 5.3.9, from 11:26 CET) **and 611 s from a sealed fresh clone** (below, from 11:36 CET): each exit 0, all 9
captures 3/3 = published, every check passed, every Maven run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0` (two per
run), the anchor note empty at the start and the end, the anchor's tree pinned at both, the container removed and nothing listening on
20120-20129 at the end; each terminal log through `check_unit7.py 33 --runlog` — `RESULT (run logs): PASS` (the unit gate: no 33 script
yet). **Each run of record held 12 timing JVMs per database** and its own threshold check passed — every PostgreSQL SEQUENCE ratio
above T in all three, each run's smallest ratio and margin printed on its terminal by `chk33.py` (the bash 3.2 run's are the table
above); H2's on the chip in each. The load averages (`sysctl -n vm.loadavg`, context, not a correction) were read before and after
every capture run of `time`; the bash 3.2 run's are under its table, and none of the three runs' loads reached the brief's 15. **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `3f3cda2` into a path **with a space** (`…/sealed
33/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -o
--exclude-standard c7-unit33`: 28 files, the `anchor` link kept); the clone's `.m2-demo` a file copy of the seed; dead proxies for http
and https in its environment (`127.0.0.1:9`); **`DOCKER_CONFIG=$HOME/.docker`** in its `env -i`; `./receipts.sh`. The builders'
`dur7.py` is not beside the clone: the run says so and checks `harness/dur7.py` by its md5. **The README the runs read:** the bash 3.2
run read this README with the measuring run's time table; the table was then replaced by that run's own (`.r-time.table.md`, as the
receipt wrote it) before the bash 5.3 run and the clone, which read and checked it; this runs paragraph and the last For RED bullet
were written after the three runs (the prose gate, the R.225 and R.302 greps, the text-block, values and table checks run again on the
final text, standalone — all clean).
<!-- runs: end -->

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line — R.302: every count,
md5 and derived line is here or in a block a run printed, typed nowhere else; the timing ratios are in the time table alone):

<!-- values: begin -->
the values the video may say: on H2 2.5.250 and PostgreSQL 18.6, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - batch: N = 200 persists in one transaction; without a batch size: IDENTITY statements 200 · SQL lines 200 · prepareStatement 200 · addBatch 0 · executeBatch 0 · executeUpdate 200; SEQUENCE statements 205 · SQL lines 205 · prepareStatement 205 · addBatch 0 · executeBatch 0 · executeUpdate 200 (sequence calls 5); the anchor's CustomerEntity statements 200 · SQL lines 200 · prepareStatement 200 · addBatch 0 · executeBatch 0 · executeUpdate 200 ; with hibernate.jdbc.batch_size=50: IDENTITY statements 200 · SQL lines 200 · prepareStatement 200 · addBatch 0 · executeBatch 0 · executeUpdate 200; the anchor's CustomerEntity statements 200 · SQL lines 200 · prepareStatement 200 · addBatch 0 · executeBatch 0 · executeUpdate 200 (the failure receipt); SEQUENCE statements 6 · SQL lines 205 · prepareStatement 6 · addBatch 200 · executeBatch 4 · executeUpdate 0 (sequence calls 5) - the SQL log's 205 lines beside its 6 statements, never a witness; derived ceil(200 / 50) = 4; saveAll statements 5 · SQL lines 204 · prepareStatement 5 · addBatch 200 · executeBatch 4 · executeUpdate 0; the batch TRACE Adding to JDBC batch (1 / 50) - [probe.b.ent.XSeq#INSERT] ×200, at (50 / 50) ×4; HHH100501 once per keyed JVM; the sequence call: H2 select next value for x_seq_seq, PostgreSQL select nextval('x_seq_seq'); H2 = PostgreSQL · order: 100 customers each with one pause, batch 50: without order_inserts statements 206, addBatch 200, executeBatch 200 (a batch per insert); with hibernate.order_inserts=true statements 8, addBatch 200, executeBatch 4; H2 = PostgreSQL · updates: 104 CustomerEntity rows edited in one transaction: hibernate.jdbc.batch_size=50 statements 2, addBatch 104, executeBatch 3 (derived ceil(104 / 50) = 3), 104 rows at version 1; no key statements 105, executeUpdate 104; batch_versioned_data=false the same 3; the UPDATE: update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=?,version=? where id=? and version=?; grep -a over hibernate-core-7.4.13.Final.jar (8400 files): batch_versioned_data 0 files, hibernate.jdbc.batch_size 6, hibernate.order_inserts 2, hibernate.order_updates 2 (BatchSettings among them); H2 = PostgreSQL · chunk: 1000 persists in one transaction, batch 50: getEntityCount() 1000 before the commit, executeBatch 20, statements 22; flush() + clear() every 50: the largest 50, 0 at the end, executeBatch 20, statements 40 (each flush prepares its INSERT again); derived 1000 / 50 = 20 · flush: called 1 remove Dev · 2 remove Asha's pause · 3 edit Asha · 4 persist Nina · 5 persist Nina's pause -> flushed at the commit, in the order sent: insert w_customer · insert w_pause · update w_customer · delete w_customer · delete w_pause (the SQL: insert into w_customer (meals_per_day,name,version,id) values (?,?,?,?) ; insert into w_pause (customer_id,days,id) values (?,?,?) ; update w_customer set meals_per_day=?,name=?,version=? where id=? and version=? ; delete from w_customer where id=? and version=? ; delete from w_pause where id=?); during the calls only the sequence call - H2 select next value for w_pause_seq, PostgreSQL select nextval('w_pause_seq'); second connection: w_customer [Asha 3 1, Nina 1 0] · w_pause [4 Nina] · time: the fixed design: N 1000 persists per run in one transaction, W 10 warm-up rounds, R 9 timed, four runs per round (SEQUENCE batch 1 / 50, IDENTITY batch 1 / 50), the order reversed every other round; 4 JVMs per database per capture run, 12 per database in the three runs; executeBatch per run SEQUENCE batch 50: 20, the other three 0; on PostgreSQL SEQUENCE ratio >= 5: true in every JVM, on this Mac; H2's ratios numbers on the chip, no threshold · anchor: the labelled copy (CustomerEntity and PauseEntity on SEQUENCE, allocationSize 50; Database's sequences; the three keys): its tests 18 pass (a guard); its DDL e501fad0de84d8e1544fc045c27ed0c3 (the anchor's 9cf92b8cae3abfd0f1c0706bfe7a4373), 6 lines differ; the import of 36: added 36, 'Adding to JDBC batch (1 / 50)' 36, 36 transactions (CustomerRepository.add), 37 SQL lines (1 sequence call); the seed's ids 1/51/101/151; the seven 466c20ed7e0d5439cb052f32ce09de1b; the anchor with hibernate.jdbc.batch_size=50: 'Adding to JDBC batch' 0, 36 transactions, 36 SQL lines · xcheck: 9cf92b8cae3abfd0f1c0706bfe7a4373 · exercise: the README: batch_size 50, order_inserts null, 100 diners and 100 breaks, executeBatch 200 (one per insert: 2 x 100); the solution: order_inserts true, executeBatch 4 (derived ceil(2 x 100 / 50) = 4) (24 words) · pinned.txt: 67907942ffce51fcc9286b29acf3be67
<!-- values: end -->

## Pinned sentences (R.252)

Byte-equal in this unit's script and in the units that consume it; `pinned.txt` holds the line below and `receipts.sh` checks its md5
and the line, whole, in this README. Course 14's agents — its lesson called Chunk-Oriented Processing (its seventh unit) and its lesson
called Writers and the Flush (its ninth, `TRACK-ROADMAP.md`: "batched inserts; composite writers") — diff against `pinned.txt`.

```pinned
A batch writer flushes and clears at every chunk, so the persistence context holds one chunk, never the whole run.
```

A batch writer flushes and clears at every chunk, so the persistence context holds one chunk, never the whole run.

The DDL call-back, shared with units 29-32 (R.252): the same hash as in the lesson called Optimistic Locking with At-Version.

## The captures — what each one shows

### 1 · batch — IDENTITY against SEQUENCE (both databases, R.206; the failure receipt)

N inserts in one transaction (N read off the run), three entities: the harness's IDENTITY entity on `x_ident`, its SEQUENCE entity on
`x_seq` (`x_seq_seq`, `allocationSize = 50` = `INCREMENT BY 50`), and **the anchor's own `CustomerEntity`**. First with no batch size, then
with `hibernate.jdbc.batch_size=50` as a run option (read back off the `EntityManagerFactory`), where Spring Data's `saveAll` runs too.
Each step prints the **three statement witnesses** — `Statistics.getPrepareStatementCount()` (cleared per step), the SQL logger's events
(a counting appender on `org.hibernate.SQL`), the JDBC proxy's `prepareStatement` around Boot's pool — and **the batching witnesses**: the
proxy's `addBatch`, `executeBatch` and `executeUpdate`, and the batch logger at TRACE, counted per step. The rows are read back on a
second connection. With the key, on H2 (PostgreSQL prints the same counts — the check asserts it):

```text
PROBE counts: statements: Statistics.getPrepareStatementCount 200 · org.hibernate.SQL lines 200 · JDBC proxy prepareStatement 200 | batching: JDBC proxy addBatch 0 · executeBatch 0 · executeUpdate 200
PROBE counts: statements: Statistics.getPrepareStatementCount 6 · org.hibernate.SQL lines 205 · JDBC proxy prepareStatement 6 | batching: JDBC proxy addBatch 200 · executeBatch 4 · executeUpdate 0
batch TRACE in this step (org.hibernate.orm.jdbc.batch, counted, not shown): Adding to JDBC batch 200 (at (1 / 50): 4, at (50 / 50): 4) · Created JDBC batch 1 · Executing JDBC batch 4 · first: Adding to JDBC batch (1 / 50) - [probe.b.ent.XSeq#INSERT] · first: Executing JDBC batch (50 / 50) - [probe.b.ent.XSeq#INSERT]
```

The first line is the IDENTITY entity's and, the same, the anchor's `CustomerEntity`'s — **the failure receipt on TiffinBox's own
entity**: the key is on, and an identity INSERT still goes alone, because Hibernate needs the row's id back before it can go on. The
second is the SEQUENCE entity's: the ids come from the sequence first, so one prepared INSERT carries every row, in batches. **The SQL
log's lines are not a batch witness** (R.206): beside the six prepared statements the logger still prints a line per row — they are the
texts Hibernate logs, not the statements the driver sends. Boot's INFO line with the key, quoted once and never as a witness:
`HHH100501: Automatic JDBC statement batching enabled (maximum batch size 50)`. The batch count is derived, never typed: `chk33.py`
computes `ceil(N / batch_size)` from the printed N and the key read off the run, and compares it with `executeBatch`. The sequence call is
each database's own — two `database:` lines, H2's and PostgreSQL's, in the values line.

**Ledger C7-11, its batch half — paid here.** Course 2's lesson called Transactions and Batches: All or Nothing called `executeBatch`
on a `PreparedStatement` by hand; this capture counts the same call, made by Hibernate under `hibernate.jdbc.batch_size`, through the
proxy — and shows when it is never made. The other half (the JDBC calls under `@Transactional`) was paid by the lesson called
@Transactional: What the Proxy Does (its `jdbc` trace).

### 2 · order — `order_inserts` (both databases)

N customers, each persisted with one pause right after it (`w_customer`, `w_pause`, both SEQUENCE), batch 50 — without, then with
`hibernate.order_inserts=true`:

```text
PROBE counts: statements: Statistics.getPrepareStatementCount 206 · org.hibernate.SQL lines 206 · JDBC proxy prepareStatement 206 | batching: JDBC proxy addBatch 200 · executeBatch 200 · executeUpdate 0
PROBE counts: statements: Statistics.getPrepareStatementCount 8 · org.hibernate.SQL lines 206 · JDBC proxy prepareStatement 8 | batching: JDBC proxy addBatch 200 · executeBatch 4 · executeUpdate 0
```

A JDBC batch holds one statement text: without the key every switch of table sends the open batch with one row in it — a batch per
insert. With it Hibernate sorts the flush's inserts by entity first, and two statement texts carry every row in full batches. This is
the exercise (below).

### 3 · updates — TiffinBox's edits already batch (both databases, S5.10)

N generated customers beside the four seeded (plain JDBC on the second connection, counted back), then every `CustomerEntity` edited in
one transaction — with the key, without it, and with the key plus `hibernate.jdbc.batch_versioned_data=false`, a key that changes nothing:

```text
PROBE counts: statements: Statistics.getPrepareStatementCount 2 · org.hibernate.SQL lines 105 · JDBC proxy prepareStatement 2 | batching: JDBC proxy addBatch 104 · executeBatch 3 · executeUpdate 0
PROBE counts: statements: Statistics.getPrepareStatementCount 105 · org.hibernate.SQL lines 105 · JDBC proxy prepareStatement 105 | batching: JDBC proxy addBatch 0 · executeBatch 0 · executeUpdate 104
PROBE result: entities edited 104 · rows at version 1, read back: 104 · at version 0: 0
```

**The identity column holds back only the INSERT**; the anchor's own versioned entity, the key alone, and its edits go in batches of
fifty — one SELECT, one prepared UPDATE (its text read off the logger, in the values line, its version check included). The third JVM
prints the second JVM's counts exactly — and the knob it sets is not Hibernate's any more:

```text
files unpacked: 8400
files holding it: 0
```

**`batch_versioned_data` is absent from 7.4.13** (R.293): `grep -a` over every file of the unpacked `hibernate-core-7.4.13.Final.jar`
finds it in 0 files, while `hibernate.jdbc.batch_size`, `hibernate.order_inserts` and `hibernate.order_updates` are each in
`org/hibernate/cfg/BatchSettings.class` (the file lists are in the capture). It is named here as what older Hibernate had; a run option
that names it is read back off the `EntityManagerFactory` as a property and changes nothing.

### 4 · chunk — the persistence context (H2)

N persists in one transaction, batch 50: once with no clear, once with `flush()` + `clear()` every 50 —
`Session.getStatistics().getEntityCount()` read after each persist:

```text
PROBE result: entities in the persistence context before the commit (Session.getStatistics().getEntityCount()): 1000 · rows read back: x_seq 1000
PROBE result: the largest persistence context (getEntityCount() after each persist) 50 · at the end 0 · rows read back: x_seq 2000
PROBE counts: statements: Statistics.getPrepareStatementCount 40 · org.hibernate.SQL lines 1020 · JDBC proxy prepareStatement 40 | batching: JDBC proxy addBatch 1000 · executeBatch 20 · executeUpdate 0
```

Without the clear every entity stays in the persistence context to the commit; with it the context never holds more than one chunk,
and the batches are the same. Each flush prepares its INSERT again, so the statement count is the sequence calls plus one per flush —
`chk33.py` derives it from the printed N. This is the chunk boundary of Course 14's lesson called Chunk-Oriented Processing (the pinned sentence).

### 5 · flush — the write path (both databases)

One unit of work on the write-path tables, called **remove Dev, remove Asha's pause, edit Asha, persist Nina, persist her pause**; the
SQL logger shown, Spring's transaction manager at DEBUG:

```text
PROBE call order: 1 remove Dev · 2 remove Asha's pause · 3 edit Asha · 4 persist Nina · 5 persist Nina's pause
PROBE SQL sent while the five calls ran, in order: select next value for w_pause_seq
DEBUG [main] org.springframework.orm.jpa.JpaTransactionManager : Initiating transaction commit
DEBUG [main] org.hibernate.SQL : insert into w_customer (meals_per_day,name,version,id) values (?,?,?,?)
DEBUG [main] org.hibernate.SQL : insert into w_pause (customer_id,days,id) values (?,?,?)
DEBUG [main] org.hibernate.SQL : update w_customer set meals_per_day=?,name=?,version=? where id=? and version=?
DEBUG [main] org.hibernate.SQL : delete from w_customer where id=? and version=?
DEBUG [main] org.hibernate.SQL : delete from w_pause where id=?
```

Called remove, remove, edit, persist, persist, Hibernate flushed the inserts, then the update, then the deletes — at the commit, whatever
the call order; the only SQL while the calls ran is the id for the new pause (PostgreSQL's sequence call is in the values line).
`chk33.py` reads the order off the log after `Initiating transaction commit` and compares it with the call order printed.

### 6 · time — the batch's ratio, a fixed design (⚑5, S5.9, R.207, R.236, R.300)

**The design, fixed in the receipt** (`TW=10 TR=9 TN=1000 TJ=4 TT=5`): 1,000 persists per run, one transaction per run, **10 warm-up
rounds, then 9 timed**, four runs per round — SEQUENCE batch 1, SEQUENCE batch 50, IDENTITY batch 1, IDENTITY batch 50, the size set per
session (`Session.setJdbcBatchSize`) — **in that order on even rounds and in the reverse order on odd rounds** (alternated, S5.17: within
each id strategy batch 1 runs first on even rounds and batch 50 first on odd ones; every round's order is printed and checked). Every run
writes names of its own round, its rows are read back (count, distinct names, the first and the last), and its `executeBatch` is read
off the proxy. The SQL logger at WARN in the timing JVMs; **the counting proxy and statistics are on in every run — both batch sizes pay
them alike**. Each JVM prints its timed values, its medians and its ratios, masked in the hashed capture (`<masked>`, `<ms>`,
`<ratio>`), and PostgreSQL's threshold line, hashed:

```text
PROBE executeBatch per run (the counting proxy), every round: SEQUENCE batch 50 [20]
PROBE executeBatch per run (the counting proxy), every round: IDENTITY batch 50 [0]
PROBE ratio SEQUENCE batch 1 / batch 50: <ratio> · ratio IDENTITY batch 1 / batch 50: <ratio>
exit 0 · on PostgreSQL, JVM 1: SEQUENCE ratio >= 5: true
exit 0 · on H2, JVM 1: its ratios go to the table as numbers - no threshold on H2 (S5.9)
```

**4 JVMs per database per run of the capture, H2 and PostgreSQL in turn, JVM by JVM; the capture runs 3/3, so each run of
record holds 12 timing JVMs per database** (R.236's "at least ten"). Their ratios go to `.r-time.table` (not hashed); `chk33.py` reads it:
at least ten per database, every PostgreSQL SEQUENCE ratio at or above T, the margin printed. **T = 5, fixed in the script before the runs
of record** — the probe's candidate; the measuring run's twelve PostgreSQL ratios all cleared 8 as well, but with a margin under one
on a machine whose load moved through the day, so the receipt keeps 5 (its margin printed below). On this Mac, on PostgreSQL, batch 50 is
faster than batch 1 in every JVM of every run of record: ratio >= T: true, T = 5. **H2's SEQUENCE ratios are numbers on the chip, never
characterised; no threshold is set for them.** IDENTITY's two batch sizes are the control (the same statements both ways); its ratios
are printed beside, with no word for them.

The table of the run of record (`./receipts.sh`, bash 3.2.57) — every JVM, both databases, both strategies; the medians as the JVMs printed
them (R.207: never spoken; the ratio is the medians' ratio):

<!-- time-table: begin -->
| database | capture run | JVM | SEQUENCE batch 1 / 50 | IDENTITY batch 1 / 50 | medians (ms): SEQUENCE 1 · 50 · IDENTITY 1 · 50 |
|---|---|---|---|---|---|
| H2 | 1 | 1 | 1.07 | 1.02 | 6.7 · 6.3 · 17.9 · 17.6 |
| PostgreSQL | 1 | 1 | 10.95 | 1.03 | 134.6 · 12.3 · 128.1 · 124.3 |
| H2 | 1 | 2 | 0.96 | 1.19 | 6.4 · 6.6 · 16.9 · 14.2 |
| PostgreSQL | 1 | 2 | 11.64 | 0.99 | 143.1 · 12.3 · 142.3 · 144.2 |
| H2 | 1 | 3 | 1.18 | 1.10 | 8.5 · 7.2 · 24.1 · 21.9 |
| PostgreSQL | 1 | 3 | 10.33 | 1.01 | 130.1 · 12.6 · 145.1 · 143.7 |
| H2 | 1 | 4 | 1.50 | 1.10 | 9.0 · 6.0 · 16.6 · 15.2 |
| PostgreSQL | 1 | 4 | 10.19 | 0.99 | 123.9 · 12.2 · 120.4 · 122.0 |
| H2 | 2 | 1 | 0.98 | 0.94 | 5.5 · 5.6 · 14.5 · 15.5 |
| PostgreSQL | 2 | 1 | 11.61 | 0.97 | 141.6 · 12.2 · 143.3 · 147.8 |
| H2 | 2 | 2 | 1.57 | 1.05 | 11.7 · 7.5 · 20.4 · 19.4 |
| PostgreSQL | 2 | 2 | 10.41 | 0.94 | 140.1 · 13.5 · 144.4 · 153.0 |
| H2 | 2 | 3 | 1.02 | 0.98 | 6.1 · 6.0 · 17.2 · 17.5 |
| PostgreSQL | 2 | 3 | 9.20 | 0.93 | 117.4 · 12.8 · 127.2 · 136.8 |
| H2 | 2 | 4 | 1.02 | 0.98 | 6.4 · 6.2 · 15.5 · 15.8 |
| PostgreSQL | 2 | 4 | 10.86 | 0.96 | 140.3 · 12.9 · 139.4 · 145.4 |
| H2 | 3 | 1 | 1.14 | 0.88 | 9.6 · 8.4 · 22.2 · 25.0 |
| PostgreSQL | 3 | 1 | 9.17 | 1.07 | 118.7 · 12.9 · 147.2 · 137.0 |
| H2 | 3 | 2 | 1.07 | 0.96 | 7.6 · 7.1 · 18.4 · 19.3 |
| PostgreSQL | 3 | 2 | 11.42 | 1.05 | 142.7 · 12.5 · 147.0 · 140.1 |
| H2 | 3 | 3 | 0.95 | 0.96 | 5.8 · 6.2 · 13.4 · 13.9 |
| PostgreSQL | 3 | 3 | 10.99 | 1.00 | 141.6 · 12.9 · 148.1 · 148.2 |
| H2 | 3 | 4 | 1.11 | 0.88 | 8.0 · 7.2 · 21.3 · 24.1 |
| PostgreSQL | 3 | 4 | 10.69 | 0.98 | 141.4 · 13.2 · 146.7 · 149.0 |

margin: the smallest PostgreSQL SEQUENCE ratio 9.17 - T 5 = 4.17
load average, capture run 1 - load average before: { 4.83 5.02 5.16 }
load average, capture run 1 - load average after: { 4.13 4.67 5.00 }
load average, capture run 2 - load average before: { 4.13 4.67 5.00 }
load average, capture run 2 - load average after: { 3.24 4.24 4.81 }
load average, capture run 3 - load average before: { 3.24 4.24 4.81 }
load average, capture run 3 - load average after: { 3.86 4.25 4.76 }
<!-- time-table: end -->

### 7 · anchor — the labelled copy and TiffinBox's import (H2 over TCP; the failure receipt's second half)

**The labelled copy** (⚑5): `.harness/copy-seq` = `anchor/` copied, then `harness/derive33.py` — the probe's `edit.py seq batch`:
`CustomerEntity` and `PauseEntity` on `GenerationType.SEQUENCE` (`@SequenceGenerator`, `customer_seq` / `pause_seq`,
`allocationSize = 50`), `Database`'s two sequences (`INCREMENT BY 50`) and its id columns defaulting to the sequence's next value, and
`application.yaml`'s `hibernate.jdbc.batch_size: 50`, `order_inserts: true`, `order_updates: true`. The capture prints every changed line
(`diff -U0`), the copy's tests (`mvn -o clean verify` — a guard, R.190, never a witness) and its DDL by `XMain`, against the anchor's:

```text
its build (README.md's verify line, offline - a guard, R.190): Surefire's summary lines, summed: tests 18 · failures 0 · errors 0 · skipped 0 · BUILD SUCCESS
its md5: e501fad0de84d8e1544fc045c27ed0c3 · the anchor's (xcheck.sql): 9cf92b8cae3abfd0f1c0706bfe7a4373 · the lines that differ (diff xcheck.sql .harness/ddl-copy.sql):
> create sequence customer_seq start with 1 increment by 50;
> create sequence pause_seq start with 1 increment by 50;
lines that differ: 6
```

The two `create table` lines change too (`id bigint not null` for `generated by default as identity`), shown in the capture: the
diff's six lines are those two tables before and after and the two new sequences. The probe's md5 was the probe's own reading; this one is
the one this run printed. Then **TiffinBox from the copy** on 20120, its database on the H2 server (20127), the batch logger at TRACE:
`POST /customers/import` of the generated lines (unit 20's generator, `csv33.py`), counted between two markers in TiffinBox's log:

```text
-> 200 {"file":"import.csv","added":36,"refused":{}}
between its markers: org.hibernate.SQL lines 37 (of them select nextval / next value: 1) · 'Adding to JDBC batch' 36 (at (1 / 50): 36) · 'Executing JDBC batch' 36 · 'Creating new transaction with name [com.tiffinbox.CustomerRepository.add]' 36 · WARN lines 0 · ERROR lines 0
its first 'Adding to JDBC batch' line (the message): Adding to JDBC batch (1 / 50) - [com.tiffinbox.CustomerEntity#INSERT]
```

**Each row is its own transaction** (the lesson called Rollback Rules put `@Transactional` on `add`), so each batch holds one INSERT —
the copy batches, and gains nothing. The second connection (the Shell over TCP) reads what the move changes, the seed's ids:

```text
1   | Ravi
51  | Meera
101 | Sunil
151 | Priya
152 | Customer 0000001
```

The seven on the copy — a fresh JVM, its own database, unit 11's comparison set — print the anchor's md5 (the record carries no id):

```text
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b
```

**Beside it, the anchor itself** — TiffinBox's identity columns — with `--spring.jpa.properties.hibernate.jdbc.batch_size=50` as a run
option, the same import:

```text
between its markers: org.hibernate.SQL lines 36 (of them select nextval / next value: 0) · 'Adding to JDBC batch' 0 (at (1 / 50): 0) · 'Executing JDBC batch' 0 · 'Creating new transaction with name [com.tiffinbox.CustomerRepository.add]' 36 · WARN lines 0 · ERROR lines 0
```

**TiffinBox keeps its identity column.** Its only bulk path is one transaction per row, so neither id strategy lets its import batch;
the move would cost the DDL diff above and the seed's ids, for no write that batches (Loser A). `batch_size` alone in the anchor (Loser
B) would batch its edits (`updates`), and no route of TiffinBox's edits many rows. The import in one transaction (Loser C) was measured
all-or-nothing by the lesson called Propagation, All Seven.

### 8 · xcheck — the DDL over the anchor (R.252)

Hibernate's script over the anchor's libraries (`probe.x.XMain`, unit 29's byte for byte: the anchor's entities alone) = `xcheck.sql` =
`../c7-unit32/xcheck.sql`. The same hash as in the lesson called Optimistic Locking with At-Version.

```text
its md5: 9cf92b8cae3abfd0f1c0706bfe7a4373 · the filed xcheck.sql: 9cf92b8cae3abfd0f1c0706bfe7a4373 · cmp: the same, byte for byte · the second-level cache lesson's xcheck.sql: the same, byte for byte
```

### 9 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s lines, then `SOLUTION.md`'s, exactly as written, in one `env -i` shell, `/bin/bash`, then `/bin/zsh -f`; each
file's "What it prints" block compared with the run, line for line; broken and solved differ.

## Call-backs, by title (R.224)

- Course 2's lesson called Transactions and Batches: All or Nothing (`java2_series.TITLES["36"]`) — `executeBatch` by hand; here the
  proxy counts Hibernate's (C7-11, its batch half).
- Course 14's lesson called Chunk-Oriented Processing and its lesson called Writers and the Flush — the pinned sentence, `chunk` and
  `batch` (pinned, `TRACK-ROADMAP.md`).
- The lesson called Ids and Generation Strategies — the IDENTITY / SEQUENCE choice and its exercise (the id strategy); **this unit's
  exercise is the ordering** (`order_inserts`): one mechanism, one sentence each (R.200).
- The lesson called Propagation, All Seven — the one-transaction import measured all-or-nothing (the brief's Loser C, by title).
- The lesson called Rollback Rules — `add`'s `@Transactional`, why the import is one transaction per row.
- The lesson called Optimistic Locking with At-Version — `@Version` on `customer` (the UPDATE's `and version=?`), and the DDL hash sentence.
- The lesson called @Transactional: What the Proxy Does — C7-11's first half.
- The lesson called Paging and Sorting — the import's generator (`csv33.py`, unit 31's `csv31.py`).
- The section's first four: the lessons called Lazy Loading and LazyInitializationException, N+1, Measured, JOIN FETCH vs @EntityGraph
  vs @BatchSize and The Second-Level Cache.

## The commands this unit adds

The harness, compiled once against the anchor's extracted libraries; the copy's build line (offline, its tests run — a guard) and its
derive; the jar's unpack and its `grep -a` (`$K` the key); the harness's JVM (`V` the flags, `A` the arguments, R.193); `XMain`'s JVM
(`$T` the tree: `anchor` or `copy-seq`); the H2 TCP server and its Shell (`$DB` the database, `$Q` the query); the import's generator and
its POST; the container, its readiness, a fresh database per JVM:

```
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/b/H.java harness/src/probe/b/Main.java harness/src/probe/b/Run.java harness/src/probe/b/Seed.java harness/src/probe/b/SqlCounter.java harness/src/probe/b/Time.java harness/src/probe/b/ent/WCustomer.java harness/src/probe/b/ent/WPause.java harness/src/probe/b/ent/XIdent.java harness/src/probe/b/ent/XSeq.java harness/src/probe/b/repo/XSeqRepo.java harness/src/probe/x/XMain.java
mvn -B clean verify
python3 -I harness/derive33.py .harness/copy-seq
unzip -q -o .harness/anchor/tiffinbox-web/target/extracted/lib/hibernate-core-7.4.13.Final.jar -d .harness/hibernate-core
grep -a -r -l -F "$K" .harness/hibernate-core
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" probe.b.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../$T/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../anchor/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20127 -ifNotExists
cd .harness/run && perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../anchor/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Shell -url "jdbc:h2:tcp://127.0.0.1:20127/mem:$DB" -user sa -password '' -sql "$Q"
python3 -I harness/csv33.py "$N" > .harness/import.csv
curl -s --noproxy '*' -F 'file=@.harness/import.csv;type=text/csv' http://127.0.0.1:20120/customers/import
docker run -d --pull never --name c7u33-pg -p 127.0.0.1:20128:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker exec c7u33-pg pg_isready -U sa -h 127.0.0.1 -q
docker exec c7u33-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
```

The anchor's own lines are read from `anchor/README.md` and asserted whole: its package line (`mvn -B package`, offline, `-DskipTests` —
its tests are unit 31's), its extract line, its run line (port 20120, under the alarm and the locale) and its token line. On PostgreSQL
the harness gets `-Dpg.db=NAME -Dpg.pwfile=../secrets/pgpw` and builds `jdbc:postgresql://127.0.0.1:20128/NAME` inside the JVM: the
password is on no command line, every printed URL is cut before its `?`. TiffinBox's run options: `--spring.datasource.username=sa` (unit
29's step: Boot treats the TCP URL as not embedded), the SQL logger, the transaction manager at DEBUG, the batch logger at TRACE.

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s5/` alone (6,772 files, as unit 32 used it; its cache jars, `p6spy-3.9.1` and
`datasource-proxy-1.11.1` are not on any class path here — the counting proxy is the harness's own `java.lang.reflect.Proxy`). Two Maven
runs before the captures: the anchor's package (`-DskipTests`) and the copy's `clean verify`; each `offline: yes`, 0 `Downloaded from`
lines, as the build lines print. **At run time** the harness binds no port; its H2 databases are in its JVM's memory (`jdbc:h2:mem:u33`,
`x33`, the exercise's `ex`); its PostgreSQL databases are fresh ones in the container (`u33batch0` … `u33time4`), loopback only;
TiffinBox's databases live on the H2 server (`mem:u33c`, `mem:u33a`) or in its own JVM (the seven). **No network act** (`docker run
--pull never`): the section's dated sweep is the brief's (`_research/spring-boot-metadata-2026-11-13.xml`,
`spring-data-bom-metadata-2026-11-13.xml`, `hibernate-core-metadata-2026-11-13.xml`: no 4.1.x patch, Hibernate 7.4.15 exists and is not
adopted — ⚑8, R.223). Every harness JVM prints `Version.getVersionString()`, Spring Data JPA's version, Spring Framework's from
`spring-tx`'s manifest and Hibernate's `HHH000001` line before the context starts (S4.13, asserted per JVM by `chk33.py`), and its
database line.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `anchor` → `../c7-unit31/after` (a link; `readlink` asserted, its tree hashed and pinned). Never built in place: copied to
  `.harness/anchor` and built there; copied again to `.harness/copy-seq` for the labelled copy (`harness/derive33.py`, never committed).
- `harness/src/probe/b` — `Main` (the context: `@EntityScan({"com.tiffinbox", "probe.b.ent"})`, `@EnableJpaRepositories({"com.tiffinbox",
  "probe.b.repo"})`, `WebApplicationType.NONE`), `Seed` (the shipped `Database` on the run's database, the counting proxy around Boot's
  pool, the harness tables by plain JDBC after the seed), `Run` (the scenarios `batch`, `order`, `updates`, `chunk`, `flush`), `Time`
  (the fixed design), `H` (the second connection, the witnesses), `SqlCounter` (the SQL logger's events and texts, in order),
  `ent/XIdent`, `ent/XSeq`, `ent/WCustomer`, `ent/WPause`, `repo/XSeqRepo`, `ex/ExApp` (the exercise, compiled only by its own lines).
  `harness/src/probe/x/XMain.java` is unit 29's. No `Thread.sleep` in `harness/src` (grepped).
- `harness/logback.xml` (one line per event; `org.hibernate.SQL` DEBUG — WARN in the timing JVMs by a run option; `org.hibernate.orm.core`
  INFO for `HHH000001`; `org.hibernate.orm.jdbc.batch` INFO for `HHH100501`, TRACE by a run option in `batch`); `harness/chk33.py` (the
  checks), `harness/s33.py` (the prose gate, its self-test first), `harness/derive33.py`, `harness/tree33.py` and `harness/csv33.py`
  (unit 31's `tree31.py` and `csv31.py`, byte for byte), `harness/dur7.py` (the builders' `dur7.py`, byte for byte, untouched).
- **Ports (§P, 20120-20129):** 20120 TiffinBox — the copy's import, then the copy's seven, then the anchor's labelled run, in turn, one at
  a time; 20127 the H2 TCP server (`127.0.0.1` alone, asserted); 20128 the container (`docker port` asserted: `127.0.0.1:20128` alone);
  20121-20126 and 20129 never bound; the harness JVMs bind none. All ten are asserted free at the start and the end.
- **Alarms (R.247):** every harness JVM `alarm 240` — a timing JVM on PostgreSQL is 19 rounds × 4 runs × 1,000 persists (the probe's six
  timing JVMs ran well inside one cap together); 240 leaves room on a loaded machine, and the script's own wait gives up at 250; TiffinBox and the
  Shell `alarm 240`; the H2 server `alarm 3000` (it lives for the whole run); the exercise's JVM `alarm 120`.

## Masks, filters and hygiene — every one, declared

- **Masked** in every capture (the mask's self-test runs first on planted lines): the PostgreSQL password (`<pw>`), the TiffinBox token,
  this folder and its parent (plain and `%20`-encoded), the home folder, the user name, the JDK's version, an EntityManager's identity, an
  identity hash, a lambda's address, Spring Data's scan figure, H2's build date, the Shell's row-count figure, a response's timestamp, a
  request thread's number; **in `time`**: every timed value (`[<masked>]`), every median (`<ms>`), every ratio (`<ratio>`) — the figures
  go to `.r-time.table` alone.
- **Filtered**: the `org.hibernate.SQL` lines are counted, not shown (shown in order in `flush`); the batch logger's TRACE lines are
  counted per step, never shown (the first of each kind quoted); TiffinBox's import is summarised by counts between two markers.
- **Hygiene**, asserted at the end: raw password and token copies 0 in every raw capture run, every capture, every log; no absolute path,
  unit number, time, duration figure, unmasked ratio, thread number, OS token, unmasked identity, password, URL but TiffinBox's own or
  stack frame in any capture; every JVM pinned (locale) and under its alarm; no kill by name; no bare wait; no sleep or polling loop in
  `harness/src`; no H2 file.

## Interrupted

`receipts.sh` traps INT and TERM: it stops the JVM (harness or TiffinBox), any Maven or javac and every process under it, the exercise's
shell, the H2 server; sweeps its process group; removes the container if it started it (`CSTARTED` set before `docker run`, `pgrm`
retrying until `docker ps -a` no longer names it); removes the capture's unfinished runs; exits 130. A leftover-container guard refuses to
start while a container named `c7u33-pg` exists.

**Measured (2026-11-15, from 10:59 CET, on a scratch mirror of this folder — its files, its captures and `.m2-demo` cloned, the sibling units linked):** `receipts.sh` started `env -i` in a session of its own **with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group once the named process was in it, the state read 5 s after its exit — six trials:

```
build (org.codehaus.plexus.classworlds.launcher.Launcher seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u33-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
h2server (org.h2.tools.Server seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u33-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
harness (-Ds=batch seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u33-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
container (-Dpg.db=u33order seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u33-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
timing (-Ds=time seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u33-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
tiffinbox (tiffinbox-web-1.0.0.jar --tiffinbox.port=20120 seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u33-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
```

`build` — the anchor's Maven build; `h2server` — the H2 TCP server just up, before the container; `harness` — the first harness JVM (`batch`
on H2); `container` — a PostgreSQL JVM of `order` (`-Dpg.db=u33order`), the container up; `timing` — the first timing JVM; `tiffinbox` —
TiffinBox from the copy on 20120 (the H2 server and the container up). The container was gone after each (`docker ps -a`), nothing
listened in 19800-20399, and `pgrep -x java` showed none.

## Exercise

"Your turn: the README saves customers with a pause each, and every insert goes in a batch of its own. Make the batches full." (Its word
count is printed by the receipt with `wc -w` and asserted equal to the brief's.) A Spring Boot application of its own (`Diner` and
`Break`, SEQUENCE ids, `batch_size=50`, H2 in memory, no port, no container — not TiffinBox's tables): the README's lines save diners
with a break each and print one `executeBatch` per insert; the solution's one changed line adds `hibernate.order_inserts=true` and the
same rows go in full batches. Broken ≠ solved by the printed lines (R.196); the check derives the solution's count from the printed rows.
**R.200:** the lesson called Ids and Generation Strategies has the id strategy as its exercise; this one is the ordering.

## The ledger rows and hand-offs this unit pays

- **C7-11, its batch half — paid** by `batch`: the proxy's `executeBatch` 0 on IDENTITY (the anchor's `CustomerEntity` included) and on
  SEQUENCE with the key, the batch TRACE beside it; Course 2's lesson called Transactions and Batches: All or Nothing by title. Its other
  half was paid by the lesson called @Transactional: What the Proxy Does. `PROMISE-LEDGER-2026-11-01.md` is not edited here.
- **Pinned for Course 14's lesson called Chunk-Oriented Processing** (R.252): `pinned.txt`, its md5 checked by `receipts.sh`; `chunk` and `batch` are the captures behind it.
- 34 moves the anchor next (C3); 32 and 33 never touched it.

## RE-MEASURE — the brief's items this unit settles

- **7 (T over at least ten JVMs per database, the README table):** settled — 12 per database in each run of record, alternated rounds,
  T = 5 below every PostgreSQL ratio, its margin printed (the table above; each run of record's own table checked by the receipt).
- **11 (33's PostgreSQL runs inside receipts, 3/3):** settled — every PostgreSQL step (`batch`, `order`, `updates`, `flush`, `time`) runs
  inside the receipt, one container per run, a fresh database per JVM, each capture 3/3 = published.

## What differed from the brief

1. **The timing JVMs are spread over the capture's three runs.** The brief asks for at least ten timing JVMs per database per run of
   record and for every capture 3/3; `time` runs 4 JVMs per database per capture run (`TJ=4`), so each run of record holds 12 per
   database — the hash covers each run's design, round orders, `executeBatch` sets and PostgreSQL's threshold lines; the ratios are
   tabled from all 12 (`.r-time.table`, not hashed). Ten JVMs in each of the three runs would triple the timing for no new reading.
2. **T = 5, the probe's candidate, kept.** Every PostgreSQL ratio of the measuring run cleared 8 as well, but by less than one; the
   machine's load moved through the day (the brief: 31 saw about 15). The margin is printed in every run of record's table, so a reader
   sees how far above 5 the ratios sit.
3. **The alternation is a full reversal.** Even rounds run SEQUENCE batch 1, SEQUENCE batch 50, IDENTITY batch 1, IDENTITY batch 50; odd
   rounds the reverse (the probe's `Time.java` order). Within each id strategy the batch-off/batch-on order flips every round, as the
   brief asks (S5.17); the id strategies' order flips too. BLUE's `alternated(…)` form (per round without/with, odd rounds reversed) is
   the same rule over two sides.
4. **H2's JVMs carry no threshold line.** The brief: H2's ratio a number on the chip, never characterised. The capture prints "no threshold
   on H2" in its place; the ratios go to the table as numbers.
5. **The batch TRACE is counted per step, not shown** (two hundred lines a step); its first `Adding to JDBC batch` and `Executing JDBC
   batch` lines are quoted, and the counts of each kind, including those at `(1 / 50)` and `(50 / 50)`, are checked against `executeBatch`.
6. **The labelled copy is built with `mvn -B clean verify`** (this README's line, offline), so its tests run as the guard; the anchor's own
   copy is built `-DskipTests` (its tests are unit 31's). The seven runs on the copy on port 20120 too, after its import and before the
   anchor's labelled run — the three TiffinBox JVMs take the port in turn.
7. **The seven's md5 is read off `../c7-unit31/receipts.sh`** (its `S466` line), not typed, and compared with the copy's.
8. **No S3 unit has a ten-JVM threshold table to copy** (`TJ=` in `c7-unit06` and `c7-unit20` is three per database); R.236's table here is
   this unit's own form: one row per JVM, the margin line under it, checked by `chk33.py table` on this README and on each run's table.
9. **The S5.10 grep is over the unpacked jar** (`unzip` into `.harness/hibernate-core`, 8,400 files as printed, then `grep -a -r -l -F`), so
    each file that holds a key is named.
10. **The flush step's SQL is shown in the capture** (five lines, in the order sent) — the one capture where `org.hibernate.SQL` lines are
    printed, since the order is the finding.
11. **`s33.py` judges whole paragraphs**: unit 32's `s32.py` judged line by line, so a sentence that ran over a line break lost its gate or
    its title; here the lines of a paragraph are joined before the sentences are cut.

## Planted faults — each caught (R.65, R.226)

Measured 2026-11-15 from 10:44 CET. **Receipt plants** — each on a fresh scratch mirror of this folder (its files, captures and
`.m2-demo` cloned; `c7-unit31`, `c7-unit29`, `c7-unit32`, `c5-unit11` and `c7-tiffinbox` linked), the plant applied, `receipts.sh` run
`env -i` in a session of its own (for the hash and exercise plants the captures a plant does not need dropped from the mirror's script,
so it reaches its check sooner); each exits 1 with `receipts.md5` and `README.md` as planted — nothing published — and no container
left. The prose plants are one sentence appended to the mirror's README (quoted here in code spans, which `s33.py` does not judge):

| Plant | Caught by | The line it died on (cut) |
|---|---|---|
| `And the batch is ten times quicker on PostgreSQL.` | `s33` (dur7; R.301's family) | `dur7: quicker` |
| the old spine, `And on Postgres the trip is what costs.` | `s33` (R.301) | `R.301's family: costs` |
| `On H2 the batch makes no difference.` | `s33` (S5.9) | `S5.9: a verdict on a ratio` |
| `Set hibernate.jdbc.batch_versioned_data=true and the versioned updates batch.` | `s33` (S5.10) | `S5.10: batch_versioned_data credited as a live setting` |
| the flush order typed in call order (`… sends the deletes first, then the update, then the inserts.`) | `s33` (the SQL order) | `the flush order: SQL verbs out of Hibernate's order` |
| a spoken median (`… about fourteen milliseconds.`) | `s33` (dur7, R.207) | `dur7: milliseconds` |
| `With the key, executeBatch > 0 for IDENTITY too.` | `s33` (R.206) | `R.206: executeBatch > 0` |
| a typed ratio (`The smallest PostgreSQL ratio was` and a two-place number) | `s33` (R.302) and the R.302 grep | `R.302: a ratio typed` |
| `pinned.txt` with one byte changed | the md5 (R.252) | `R.252: pinned.txt is not the pinned text` |
| a wrong published hash (`batch` in `receipts.md5`) | `pub` | `batch is not the published capture` |
| a dish name in a README line | R.215 | `an Indian dish name` |
| a placeholder line | the placeholder grep | `a placeholder line in this unit's prose` |
| a typed SQL string outside the captured blocks | R.225 | `a typed SQL string in the prose (R.225)` |
| a changed What-it-prints line (`SOLUTION.md`) | the exercise check | `SOLUTION.md's "What it prints" block is not what the solution's lines printed` |
| the solution = broken (its key set to `false`, its What it prints set to the broken one's) | R.196 | `exercise: the broken run one batch per insert, the solution full batches (R.196): FAIL …` |
| the password in a log — the mask's password rule removed | the mask's self-test | `mask: the planted … the password … must be masked` |

**The R.211 note fires, not a stop:** a mirror whose `c7-tiffinbox` is a copy with one byte added to its `README.md` — the run went on to
the end, exit 0, all 9 captures = published, the note on the terminal at the start and at the end (`anchor/ and ../c7-tiffinbox differ …`,
"a later anchor change has moved ../c7-tiffinbox on; no anchor change in this unit").

**Check plants** — `harness/chk33.py` run on a copy of a published capture with one thing changed (each exit 1):

| Plant | The failing line (cut) |
|---|---|
| R.206: the IDENTITY row's check made to assert `executeBatch > 0` | `FAIL  H2 off ident: PLANT executeBatch > 0 for IDENTITY …` — the run printed 0 |
| S5.17: the timing's odd rounds set to the even rounds' order (grouped) | `FAIL  H2 2.5.250: R.300 - even rounds …, odd rounds reversed` |
| R.236: the time table with one PostgreSQL ratio below T (`chk33.py table`, the form README.md's table is checked with) | `FAIL  the table: every PostgreSQL SEQUENCE ratio >= T = 5 (below it: [4.9])` |
| R.236: the run's `.r-time.table` with one PostgreSQL ratio below T | `FAIL  this run's table (.r-time.table): every PostgreSQL SEQUENCE ratio >= T = 5 …` |
| the copy's import check fed the anchor's import (no batch line in it) | `FAIL  the copy: 'Adding to JDBC batch (1 / 50)' 0 = transactions 36 = added 36 …` |
| S4.13: a version line dropped — `HHH000001`, Spring Data's `4.1.2`, Spring Framework's `7.0.10`, each in turn | `FAIL  the version line once in the JVM: …` (each) |
| S5.10: the `grep -a` made to find `batch_versioned_data` in one file | `FAIL  S5.10: 0 files of hibernate-core-7.4.13.Final.jar hold batch_versioned_data` |
| the flush's SQL fed in call order (a delete first) | `FAIL  H2 2.5.250: at the commit inserts, then updates, then deletes: …` |
| `order`: the run without the key fed the keyed run's counts | `FAIL  H2 without order_inserts: … a batch per insert` |
| `chunk`: the cleared run's largest context fed the whole run's | `FAIL  flush() + clear() every 50: the largest 1000 = the batch size …` |

**Not run as plants:** a check that cannot fail (R.276) is answered by the tables above — every check named there failed on its plant;
`s33.py`'s other refused readings (the R.287 wordings, R.190, R.224, a pace word in a sentence about the in-memory database) are its self-test's cases only
(refused there), not planted into the README.

## CARRIED

- The anchor on SEQUENCE — measured on the labelled copy, not adopted (⚑5); a later course that bulk-inserts re-measures on its own
  write path.
- A one-transaction import with per-row savepoints (would let SEQUENCE batch TiffinBox's import) — not this course's.
- The time-meaning family (S5.18) is this unit's `s33.py`'s (BLUE's `tm.py` regexes copied in); `dur7.py` untouched.
- PostgreSQL's alternated ratio for 34's query plan — 34's agent (RE-MEASURE 9); this unit's ratio is the batch's.

## For RED

- **The timing compares batch 1 with batch 50 in one JVM, per session** (`Session.setJdbcBatchSize`), not two configured JVMs; the
  global key is unset in the timing JVMs. A batch size set per session is the knob a batch writer uses; the `batch` capture shows the
  global key gives the same `executeBatch`.
- **The counting proxy and `Statistics` are on in every timing run.** Both batch sizes pay them; a reader who wants the bare driver's
  figures would have to run without the witnesses, and then `executeBatch` per run (`20` / `0` / `0` / `0`, asserted) is gone.
- **T = 5 against a measured floor near 9** (the margin line in the table): the threshold is a claim the receipt can keep under load,
  not the measured ratio. The voice says the threshold beside its line (ratio >= T: true), never the medians or a ratio from the table (R.207, R.302).
- **The timing ratios are not in any hash.** The hashed capture holds the design, every round's order, every run's content check, the
  `executeBatch` sets and PostgreSQL's threshold lines; the figures are in `.r-time.table` and in the table above (the bash 3.2 run of
  record's). A table typed by hand would pass `chk33.py table` if it kept ten rows a database above T — the rows here were pasted from
  `.r-time.table.md`, which the receipt writes.
- **H2's ratios straddle 1 and are never characterised** — `s33.py` refuses a duration word in a sentence about H2 unless it says "no
  threshold" / "numbers on the chip", and a verdict on a ratio anywhere (its self-test lists the phrases).
- **The alternation flips the whole round** (both id strategies and both batch sizes); the round-order check reads every round's printed
  order. A grouped design fails it (the plant).
- **`saveAll` runs with the caller's transaction absent**, so it is one transaction of `SimpleJpaRepository`'s own; its sequence pool
  continues the earlier step's in the same JVM — its sequence calls are counted in the logger's texts, never typed.
- **The SQL-order check in prose is narrow**: a sentence whose `insert` / `update` / `delete` words are out of that order is refused; the
  call order is said with `remove` / `edit` / `persist`. A sentence that says the call order in SQL verbs would be refused — on purpose.
- **The import's counts are a whole request's** (between two markers in TiffinBox's log), on the copy and on the anchor; the
  "Adding to JDBC batch" lines are TRACE lines, not witnesses on their own — their count equals `added` and the transactions' count.
- **`s33.py` does not judge a code span**; the receipt's R.302 and R.225 greps still read every character outside fenced blocks, the
  values block and the time table.
- **The plants ran on `s33.py` one step before the committed one**: afterwards its S5.10 and R.206 (`executeBatch > 0`) rules stopped
  reading code spans, as its other rules never did (the plants table quotes the refused sentences that way); those two receipt plants
  were run again on the final `s33.py` (the same verdict, exit 1). Every run of record ran the committed `s33.py`.

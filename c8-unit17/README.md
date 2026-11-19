# c8-unit17 — *Distributed Locks and Rate Counters*

Course 8, Section 3's fourth and last unit, and **Section 3's fourth change to the anchor (C4) — conditional, and it landed**. `before`
is a link to `../c8-unit16/after` (unit 16's tree; the receipt pins it and asserts that pin is unit 16's own after-tree line); `after/`
is this unit's tree, and `../c8-tiffinbox` equals `after/` from this unit's commit on. A distributed lock — one key many processes agree
to wait on — is, in Redis, one key set only if it is absent and with a time to live; the harness's lock here is exactly that, and so is
the counter beside it: one `INCR`, with its time to live set in the same step. Neither is TiffinBox's (⚑8): TiffinBox takes no lock and
keeps no counter, and the lock, its holders A, B and C, Redlock's majority and the counter are the harness's classes in `harness/`.
What TiffinBox does have is a lock it did not write: the cache writer it gives Redis (`RedisCaching`, `enableLocking()`) holds a key
in Redis while it fills the cache, and this unit measured that writer with two JVMs on one Redis, on `CustomerRepository.findAll()`
itself (`sync`), before it touched the anchor — and the anchor's Javadoc now says what that capture printed.

Every Redis number below comes from two witnesses in the same run (R.398): **Java's answer** — the harness JVMs' replies through Spring
Data Redis (`setIfAbsent`, `GET`, `delete`, the Lua script's return, Redlock's per-instance list, the counter's counts), or each
TiffinBox JVM's invocation counter (unit 13's `Counter`) and the list it got — and **redis-cli inside the Redis container**
(`docker -H "$DH" exec`, the image's own client, never a host install), run while a JVM waits at a pause; for `sync`, PostgreSQL's own
log of every statement, counted between two psql markers, is the second witness of the table's reads. Redis is **Redis 8.10.3, by the
digest** (`redis@sha256:7958cfbb…935c3`, `--pull never`, `127.0.0.1` only, no password); PostgreSQL is 18.6 by the capstone's digest.
Every line names its tree, its profile and **whose write** (R.392, R.413): **after/'s classes — the harness's lock, holder A / B / C,
Redlock's majority, the harness's counter** (a Redis-only harness JVM, `probe.u17.H17`); **17/after, profile dev, PostgreSQL + Redis —
TiffinBox JVM 1 and JVM 2, the anchor's `findAll`, the shipped `RedisCaching`** (`sync` row a, `anchor`); **a copy of after/ without
`enableLocking()`, or with the harness's hold in `findAll` — labelled** (`sync` rows b, c, d; `harness/variants.py`); **redis-cli on
20562 / 20563 / 20564**; or **17/after, default run, H2, no Redis**.

Eleven captures. The JVM captures run three times inside each run of `receipts.sh` and are hashed (`receipts.md5`); `exercise` and the
tests that `anchor` carries run once per run, and their 3/3 is across the runs of record. Every number and string below is asserted
after its capture by `harness/chk17.py` against a second witness of the same run. Evidence by a Claude Opus 5.5 agent on 2026-11-19,
started 12:37 CET.

## Runs of record

**On the script as committed:** `bash receipts.sh` (Homebrew bash 5.3.9, 2026-11-19 from 13:37:18 CET, ended 13:44:45), `./receipts.sh`
(/bin/bash 3.2.57, from 13:44:56, ended 13:52:27) and a sealed fresh clone (below, at `2d8b341`, from 13:52:59, ended 14:00:49): each
with every capture = published (the JVM ones 3/3 inside the run), every check held, every Maven run `offline: yes`, `.m2-demo`'s file
count unchanged, volumes back to their count and the images unchanged, `before/` and `after/` = their pins at the start and the end,
nothing listening on 20560-20569 at the end, each log ending with its `c8-unit17:` line; each log through `check_unit8.py 17
--runlog` — `RESULT (run logs): PASS` (the unit gate itself has no unit 17 script yet, as expected). **Nothing was downloaded.** One
run before them printed every capture's hash and stopped at the README's text-block check (the README was a stub then); the hashes
went into `receipts.md5`. The first `bash receipts.sh` after it stopped on `sync`'s own 3/3 check (*What differed*, the caller's
place); two more stopped at the README's own gates (a number typed in a sentence, the values line's order) and were fixed in the
README alone. The planted faults and the interruptions ran after the three runs of record, alone.

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at this unit's commit (`2d8b341`, before the commit was
amended with these times) into a path **with a space** (`…/sealed 17/tiffinbox-java`, in the session's scratch folder), the clone's
`.m2-demo` a file copy of the seed (7,102 files), `env -i` with `HOME`, `PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`
and `DOCKER_CONFIG=$HOME/.docker`; `./receipts.sh`. The runs ran on this README before its *Runs of record*, *Interrupted* and
*Planted faults* paragraphs were written; the prose gate and the text-block and values checks were run again on the final README
against the last run's printed lines.

## C4 — the conditional change: what `sync` printed and what it did to the anchor, and the unit 13 sentence's dated note (R.250)

**Decided by `sync` (RE-MEASURE 9) before any anchor file was touched.** The rule (the prompt's, ⚑10): the Javadoc moves only if the
shipped writer printed one read in the held pair AND with no hold, and the copy without `enableLocking()` printed two in the held pair,
each row 3/3. A first measurement in the session's scratch folder (the same harness, the same four trees, three rounds of the four
rows) printed exactly that; the anchor was then edited, and every run of record printed it again (`sync`, below). So C4 landed.

`diff -rq before/ after/` (the receipt prints it): **two files changed, nothing new, nothing gone** — one Javadoc paragraph and the
anchor README's section for it; no code line, no test, no configuration, no `compose.yaml` change:
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java` — `findAll()`'s Javadoc gains a *Course 8, unit 17* paragraph,
  placed after unit 13's, which stays word for word (R.250). The paragraph quotes only the rows `sync` printed: the shipped writer's one
  read with its lock key in Redis, the copy's two, the hold labelled as the harness's, and the no-hold row beside them; it closes by
  naming which clause of unit 13's sentence the capture contradicts. Read off `after/` by `diff` (`anchor` prints the same lines):

```text
> *
> * <p>Course 8, unit 17: across two JVMs, one Redis, under "dev": one read of the table with the writer TiffinBox gives Redis -
> * its enableLocking() lock, {@code customers~lock}, seen by redis-cli while the method ran - and two in a copy without
> * {@code enableLocking()} (../c8-unit17, sync). The two JVMs call this method on one signal; the rows that make them overlap
> * for sure are the ones where the harness holds the method in a labelled copy (planted): one read with the shipped writer, two
> * without its lock. Beside them, with no hold, the shipped writer gave one read as well. The unit 13 sentence above was
> * measured in one JVM; its last clause - a second server runs its own read - is what the copy without enableLocking() printed,
> * not the shipped writer (../c8-unit17, sync).
```

- `README.md` (the anchor's) — a `## Course 8 · unit 17` section in the unit 16 section's shape: what changed (one Javadoc), what did
  not (no lock, no counter, no test, no `compose.yaml` change — ⚑8: the lock and the counter are harness code), and why.

**The after-tree moved by those two files, `+0` files**: its pin is a new hash over the same count (`receipts.md5`, `after-tree`), its
cause these two files alone. `before/` is unit 16's after-tree, re-derived by `harness/tree17.py` and asserted equal to
`../c8-unit16/receipts.md5`'s line.

**R.250 — the sentences C4 makes incomplete, each noted, none deleted.** `findAll()`'s unit 13 sentence ("Under the profile "dev" the
waiting is done by the cache writer TiffinBox gives Redis (RedisCaching), in this JVM; a second server runs its own read.") stays as it
was; the unit 17 paragraph beside it says its last clause is what the copy without the lock printed, not the shipped writer. The class
Javadoc's "in one JVM (../c8-unit13, sync)" is a statement of what unit 13 measured — still true, kept. The anchor README's unit 13
section ("in one JVM — Caffeine's cache or the cache writer TiffinBox gives Redis") is kept, and the unit 17 section beside it says
the two-JVM reading. **A dated note on `../c8-unit13/README.md`** (2026-11-19, here and not in place: `c8-unit13/` is frozen and its
`receipts.sh` reads its README live): its `sync` section and its values line say one read "in one JVM", which is what unit 13 measured
and stays true; with the cache writer TiffinBox gives Redis, two JVMs on one Redis printed one read as well (`sync`, rows a and c),
and a copy without `enableLocking()` printed two (rows b and d) — the "in one JVM" reading is the narrower of the two, not a wrong one.

## RE-MEASURE 9 on `findAll` itself — the four rows (settled first)

Two TiffinBox JVMs, each TiffinBox's own application class with its web server (JVM 1 on 20560, JVM 2 on 20566 — the start under "dev"
needs no web-free mode, and both bind), unit 13's invocation counter on Spring Data JPA's repository, profile dev, one PostgreSQL
database (a fresh one per row, by psql), one Redis (`FLUSHALL` before each row, and again before the release). Both starts run the
dev start's fill, so two starts against one Redis and one database: the leaderboard is reset and filled by each start (unit 14's form —
the same four scores after the second), and the kitchen orders are saved twice under the same ids (unit 15's deterministic ids), so
`SCARD kitchen-order` stays one start's count — printed once, row a. Then the customers key is asserted cold
(`EXISTS 'customers::SimpleKey []'` → `0`), both JVMs stand at their poll on `tiffinbox:u17:go`, and one redis-cli `SET` releases both;
each calls `CustomerRepository.findAll()` once through its context's bean (not HTTP — the harness's counter and the cache are the method's) and
prints its counter's delta and its list's size. In the held rows the harness holds each caller inside `findAll` (planted — a labelled
copy, `variants.py hold`, whose `findAll` first polls a file on a count, on the harness's caller thread only), each JVM reports where its
caller is parked, the receipt reads `--scan` during the hold, then writes the file. Which JVM wins the release moves from run to run; the
capture writes each JVM's number `<k>` and sorts the two lines, so the row's numbers, not the winner, are what is hashed.

```text
-- sync row (a): after/, the shipped RedisCaching (immediateWrites().enableLocking()) · no hold
after both starts against one Redis (each start's fill ran: orders cooked twice), redis-cli: ZCARD tiffinbox:leaderboard 4 · SCARD kitchen-order 120 · XLEN tiffinbox:kitchen-events 0 · ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES: Sunil 9000 Ravi 7200 Meera 4500 Priya 3600
redis-cli EXISTS 'customers::SimpleKey []' -> 0 (the customers key cold before the release)
the counters' deltas, sorted: 0 1 · their sum 1
PostgreSQL's log between the two psql markers (statement: select 'u17-sync-a-begin' / -end): the statement counted, read off the log: select … from customer ce1_0 order by ce1_0.name · its lines: 1
-- sync row (b): the labelled copy nolocking of after/ (harness/variants.py nolocking) · no hold
redis-cli EXISTS 'customers::SimpleKey []' -> 0 (the customers key cold before the release)
the counters' deltas, sorted: 1 1 · their sum 2
PostgreSQL's log between the two psql markers (statement: select 'u17-sync-b-begin' / -end): the statement counted, read off the log: select … from customer ce1_0 order by ce1_0.name · its lines: 2
-- sync row (c): the labelled copy hold of after/ (harness/variants.py hold) · the harness holds the caller inside findAll (planted, labelled)
redis-cli EXISTS 'customers::SimpleKey []' -> 0 (the customers key cold before the release)
during the hold (both callers parked, each by its own JVM's line), redis-cli --scan, sorted: customers~lock tiffinbox:u17:go
PROBE JVM <k>'s caller: inside the copy's hold in CustomerRepository.findAll (the harness holds - planted) · read <k> times
PROBE JVM <k>'s caller: waiting inside Spring Data Redis's cache writer, before the method · read <k> times
the counters' deltas, sorted: 0 1 · their sum 1
PostgreSQL's log between the two psql markers (statement: select 'u17-sync-c-begin' / -end): the statement counted, read off the log: select … from customer ce1_0 order by ce1_0.name · its lines: 1
-- sync row (d): the labelled copy nolockhold of after/ (harness/variants.py nolockhold) · the harness holds the caller inside findAll (planted, labelled)
redis-cli EXISTS 'customers::SimpleKey []' -> 0 (the customers key cold before the release)
during the hold (both callers parked, each by its own JVM's line), redis-cli --scan, sorted: tiffinbox:u17:go
PROBE JVM <k>'s caller: inside the copy's hold in CustomerRepository.findAll (the harness holds - planted) · read <k> times
PROBE JVM <k>'s caller: inside the copy's hold in CustomerRepository.findAll (the harness holds - planted) · read <k> times
the counters' deltas, sorted: 1 1 · their sum 2
PostgreSQL's log between the two psql markers (statement: select 'u17-sync-d-begin' / -end): the statement counted, read off the log: select … from customer ce1_0 order by ce1_0.name · its lines: 2
```

What decides C4 — printed in every run of record, 3/3: row (a), the shipped writer with no hold, `1`; row (c), the shipped writer held,
`1`, with `customers~lock` in Redis during the hold and one caller waiting inside the cache writer; row (d), the copy without
`enableLocking()` held, `2`, both callers inside the hold and no lock key. Row (b), the copy with no hold, printed `2` in every round
here — without the hold whether the two overlap is the release's chance, and the README says only what printed. The probe's own
manager printed `1` and `2` first; these numbers are the anchor's tree's and the copies', read off this unit's runs.

## The lock's no-hold control (RE-MEASURE 14, settled first)

Before the held windows were written: the harness's holder A acquires, then **releases inside its lock** — by `DEL` in one window, by the
Lua compare-and-delete in the next — and only then the harness's holder B (a second harness JVM) acquires. No hold anywhere.

```text
-- holder A releases by DEL, inside its lock (no hold):
PROBE holder A (the harness's lock): setIfAbsent(tiffinbox:lock:kitchen-slot, A, <the lock's time to live>) -> acquired true
PROBE holder A releases by DEL (the harness's lock): deleted true
the receipt at pause 1, redis-cli: GET tiffinbox:lock:kitchen-slot -> A · PTTL tiffinbox:lock:kitchen-slot -> <n> (positive)
the receipt at pause 2, redis-cli: GET tiffinbox:lock:kitchen-slot -> [] · EXISTS tiffinbox:lock:kitchen-slot -> 0
redis-cli GET tiffinbox:lock:kitchen-slot -> B
-- holder A releases by the Lua compare-and-delete, inside its lock (no hold):
PROBE holder A (the harness's lock): setIfAbsent(tiffinbox:lock:kitchen-slot, A, <the lock's time to live>) -> acquired true
PROBE holder A releases by the Lua compare-and-delete (the harness's lock): returned 1
the receipt at pause 1, redis-cli: GET tiffinbox:lock:kitchen-slot -> A · PTTL tiffinbox:lock:kitchen-slot -> <n> (positive)
the receipt at pause 2, redis-cli: GET tiffinbox:lock:kitchen-slot -> [] · EXISTS tiffinbox:lock:kitchen-slot -> 0
redis-cli GET tiffinbox:lock:kitchen-slot -> B
```

So the overrun in `otherholder` and `lua` is the harness's hold (planted), not the lock's: released inside its lock, A's `DEL` and A's
Lua release each delete A's own key, and B acquires after.

## The captures — what each one shows

### 1 · sync — two JVMs, one Redis, `findAll` itself (RE-MEASURE 9, ⚑10, R.408)

The rows above. The second witness per row: PostgreSQL's log, between `select 'u17-sync-<row>-begin'` and `-end` (psql), counts the
customer reads by the shape the capture prints, read off the log, never typed; each count is asserted equal to the two counters' sum. `customers~lock` is the lock key `enableLocking()` holds (`<cache>~lock`), seen by redis-cli's
`--scan` while row c's harness hold ran and gone after; `customers::SimpleKey []` is the list both JVMs read afterwards. `sync`'s voice, only beside this capture: across two JVMs, with the writer TiffinBox gives Redis, one read of the table — `customers~lock` in Redis while it
ran; two without `enableLocking()`. Both TiffinBox JVMs' logs: ERROR `0`, no exception line, `RedisConnectionFailureException` `0`.

| row | tree, whose write | the hold | Java (the counters' sum) | PostgreSQL (the customer reads) | redis-cli during the hold |
|---|---|---|---|---|---|
| a | 17/after, profile dev, the shipped `RedisCaching` | none | `1` | `1` | — |
| b | a copy without `enableLocking()` — labelled | none | `2` | `2` | — |
| c | a copy of 17/after whose `findAll` the harness holds — labelled | planted | `1` | `1` | `customers~lock` |
| d | both changes — labelled | planted | `2` | `2` | no lock key |

### 2 · lock — the harness's lock, released inside it (the control, RE-MEASURE 14)

Above. Two witnesses per step: Java's `acquired true` / `deleted true` / `returned 1` / B's `acquired true`, and redis-cli's `GET A`,
`PTTL` positive (the reply masked `<n>`), `GET` empty and `EXISTS 0` after the release, `GET B`. 3/3 per release.

| step | Java (after/'s classes — the harness's lock) | redis-cli on 20562 |
|---|---|---|
| A acquires | `acquired true` | `GET A` · `PTTL` positive |
| A releases inside its lock | `DEL` → `deleted true` / Lua → `returned 1` | `GET` empty · `EXISTS 0` |
| B (a second harness JVM) acquires | `acquired true` | `GET B` |

### 3 · otherholder — when the harness holds A past its lock's time to live, A's `DEL` deletes B's lock (the failure receipt, R.396's negation; controls `lock` and `lua`)

The harness's holder A acquires; then the harness holds A past its lock's time to live (PLANTED, labelled on its own line and in the
capture's header — a pause polling a file; the receipt waits by polling `EXISTS` on a count until `0`, never a sleep of the lock's
length). The key gone while A still runs, the harness's holder B (a second JVM) acquires; A reads the key before its release and sees
`B` — A and B `held at once`; A's release by `DEL` returns `deleted true`, redis-cli reads the key empty — A deleted B's lock — and the
harness's holder C (a third JVM) acquires while B believes it holds.

```text
PROBE holder A (the harness's lock): setIfAbsent(tiffinbox:lock:kitchen-slot, A, <the lock's time to live>) -> acquired true
PROBE the harness holds this holder past its lock's time to live (planted, labelled)
PROBE holder A sees the lock's value before release: B
PROBE holder A and holder B held at once: A's work ran past its lock while B held it (the planted hold)
PROBE holder A releases by DEL (the harness's lock): deleted true
the receipt at pause 1, redis-cli: GET tiffinbox:lock:kitchen-slot -> A · PTTL tiffinbox:lock:kitchen-slot -> <n> (positive)
the receipt at pause 2 - the harness holds A past its lock's time to live (planted):
poll: EXISTS tiffinbox:lock:kitchen-slot (until A's key is gone, A still running) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
redis-cli GET tiffinbox:lock:kitchen-slot -> B
the receipt at pause 3, after A's release, redis-cli: GET tiffinbox:lock:kitchen-slot -> [] · EXISTS tiffinbox:lock:kitchen-slot -> 0
redis-cli GET tiffinbox:lock:kitchen-slot -> C
```

### 4 · lua — the same hold, the Lua compare-and-delete: B's lock stays, and A and B still held the slot together (R.407, R.350)

The same window, the release by one Lua script Redis runs as one step (`DefaultRedisScript<Long>`:
`if redis.call('GET', KEYS[1]) == ARGV[1] then return redis.call('DEL', KEYS[1]) else return 0 end`): `returned 0`, redis-cli `GET B`,
the harness's holder C refused. What it does not stop, on the same slide: A's work still ran past its lock while B held it — the harness
holds A there, planted — and the capture prints `held at once` in this window too. The Lua release stops A deleting B's lock; it does not stop A and B holding the slot
together. The argument for what would (§4, stated, not built): a fencing token — a number the lock hands each holder, rising, which the
store checks on every write — would refuse A's late write; no token is built here.

```text
PROBE holder A (the harness's lock): setIfAbsent(tiffinbox:lock:kitchen-slot, A, <the lock's time to live>) -> acquired true
PROBE the harness holds this holder past its lock's time to live (planted, labelled)
PROBE holder A sees the lock's value before release: B
PROBE holder A and holder B held at once: A's work ran past its lock while B held it (the planted hold)
PROBE holder A releases by the Lua compare-and-delete (the harness's lock): returned 0
the receipt at pause 1, redis-cli: GET tiffinbox:lock:kitchen-slot -> A · PTTL tiffinbox:lock:kitchen-slot -> <n> (positive)
the receipt at pause 2 - the harness holds A past its lock's time to live (planted):
poll: EXISTS tiffinbox:lock:kitchen-slot (until A's key is gone, A still running) -> 0, polled <k> times (a count condition, cap 300 reads, under the receipt's alarm)
redis-cli GET tiffinbox:lock:kitchen-slot -> B
the receipt at pause 3, after A's release, redis-cli: GET tiffinbox:lock:kitchen-slot -> [B] · EXISTS tiffinbox:lock:kitchen-slot -> 1
redis-cli GET tiffinbox:lock:kitchen-slot -> B
```

| step | Java (the harness's holders) | redis-cli on 20562 — `otherholder` (DEL) | — `lua` |
|---|---|---|---|
| A acquires | `acquired true` | `GET A` · `PTTL` positive | the same |
| the harness holds A (planted) | — | `EXISTS` polled to `0` | the same |
| B acquires | `acquired true` | `GET B` | the same |
| A reads before release | `B` · `held at once` | — | the same |
| A releases | `deleted true` / `returned 0` | `GET` empty | `GET B` |
| C acquires | `true` / `false` | `GET C` | `GET B` |

### 5 · rate — the harness's counter: one Lua `INCR` + `EXPIRE`, five allowed, the sixth refused; two one-command forms

One Lua script (`DefaultRedisScript<Long>`:
`local c = redis.call('INCR', KEYS[1]); if c == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]) end; return c`) counts each request and
sets the key's time to live on the first, in one step on the server; the harness allows a count up to its limit. Then, on Redis 8.10.3
(read off `INFO server`), two one-command forms redis-cli answers: `EXPIRE <key> <n> NX` sets a time to live only where none is set, and
`SET <key> 1 EX <n> NX` creates a counter key with its time to live in one command — the time to live never printed with its number.

```text
PROBE request 1 (the harness's counter, the Lua INCR + EXPIRE on the first): count 1 -> allowed (limit 5)
PROBE request 2 (the harness's counter, the Lua INCR + EXPIRE on the first): count 2 -> allowed (limit 5)
PROBE request 3 (the harness's counter, the Lua INCR + EXPIRE on the first): count 3 -> allowed (limit 5)
PROBE request 4 (the harness's counter, the Lua INCR + EXPIRE on the first): count 4 -> allowed (limit 5)
PROBE request 5 (the harness's counter, the Lua INCR + EXPIRE on the first): count 5 -> allowed (limit 5)
PROBE request 6 (the harness's counter, the Lua INCR + EXPIRE on the first): count 6 -> refused (limit 5)
redis-cli GET tiffinbox:rate:kitchen-slot -> 6 · TTL tiffinbox:rate:kitchen-slot -> <n> (positive)
-- two one-command forms on this Redis, by redis-cli (INFO server: redis_version:8.10.3):
SET tiffinbox:rate:nx 1 -> OK · TTL -> -1
EXPIRE tiffinbox:rate:nx <n> NX -> 1 · again -> 0 · TTL -> <n> (positive)
SET tiffinbox:rate:ex 1 EX <n> NX -> OK · INCR tiffinbox:rate:ex -> 2 · TTL -> <n> (positive)
```

### 6 · race — `INCR`, the harness holds before `EXPIRE`, SIGINT: a counter that never ends (the failure receipt; control `rate`)

The harness's counter done in two commands: `INCR`, then the harness holds before its `EXPIRE` (PLANTED, labelled), and the receipt
sends SIGINT to that JVM (read off its own pid line; the JVM's SIGINT reset by `perl`, R.410). The JVM exits `130`; the key stays, with
no time to live.

```text
PROBE the harness's counter, INCR tiffinbox:rate:race -> 1
PROBE the harness holds before its EXPIRE (planted, labelled): pid <n>
exit 130 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0 · RedisConnectionFailureException 0
the receipt at pause 1: kill -INT sent to the harness JVM (its pid, read off its own line)
redis-cli GET tiffinbox:rate:race -> 1 · TTL tiffinbox:rate:race -> -1 · EXISTS tiffinbox:rate:race -> 1
```

### 7 · anchor — the dev shape on PostgreSQL + Redis, the tests, the libraries, the version lines (RE-MEASURE 11, C4)

17/after under the profile dev, one start on a fresh database and an emptied Redis (the overrides: `--spring.profiles.active=dev
--spring.docker.compose.enabled=false --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=20562 --logging.level.tiffinbox=INFO`,
the datasource from a config tree; no Compose run), read at a pause, then SIGINT; the tests by `mvn -o package` with Docker at nothing
and `mvn -o verify` with Docker (Testcontainers, Ryuk off — `TESTCONTAINERS_RYUK_DISABLED=true`, as unit 16's receipt sets it); the
jar's libraries before and after; the Javadoc paragraph read off `after/`.

```text
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
Surefire's Results line: Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
the verify log: 'Creating container for image' 3 · 'Pulling' 0 · Testcontainers containers after it: 0
before/: 122 libraries · spring-data-redis and lettuce in lib/: lettuce-core-7.5.2.RELEASE.jar spring-data-redis-4.1.2.jar
after/: 122 libraries · spring-data-redis and lettuce in lib/: lettuce-core-7.5.2.RELEASE.jar spring-data-redis-4.1.2.jar
gained: 0 · lost: 0
after/compose.yaml: md5 7cef436fb2bc69bf9142ed2cb811708d = before/'s: yes
after/tiffinbox-web/pom.xml: md5 bbda2250ef0c0c81e5a99df3b50ad39d = before/'s: yes
after/tiffinbox-web/src/main/resources/application-dev.yaml: md5 3a2fbe67fcc2463ad148e42b7969fe22 = before/'s: yes
after/tiffinbox-web/src/main/java/com/tiffinbox/web/RedisCaching.java: md5 71ff69508cf96d905ed3f9ebe8b6afde = before/'s: yes
the Redis container's own client: redis-cli 8.10.3 · INFO server: redis_version:8.10.3
log: Multiple Spring Data modules found, entering strict repository configuration mode
log: Found 1 Redis repository interface
log: Multiple Spring Data modules found, entering strict repository configuration mode
log: Found 1 JPA repository interface
log: Multiple Spring Data modules found, entering strict repository configuration mode
log: Found 1 JDBC repository interface
log: HHH000001: Hibernate ORM core version 7.4.13.Final
log: tiffinbox: orders cooked:  120
log: tiffinbox: kitchen value:  24300
PROBE versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JPA 4.1.2 · Spring Data JDBC 4.1.2 · Spring Data Redis 4.1.2 · Lettuce 7.5.2.RELEASE/5728917 · Hibernate 7.4.13.Final · Flyway (version.txt) 12.4.0
PROBE bean kitchenEvents: present (profile dev, PostgreSQL 18.6)
PROBE bean leaderboard: present (profile dev, PostgreSQL 18.6)
PROBE bean redisDatastore: present (profile dev, PostgreSQL 18.6)
PROBE Redis's INFO server, through the connection: redis_version:8.10.3
PROBE http (profile dev, PostgreSQL 18.6): GET /dashboard -> 200
PROBE http (profile dev, PostgreSQL 18.6): GET /actuator/health -> 200 · status UP
PROBE http (profile dev, PostgreSQL 18.6): GET /leaderboard -> 200
PROBE http (profile dev, PostgreSQL 18.6): GET /kitchen -> 200 · ordersCooked 120
exit 130 · its log, every line but the harness's own PROBE lines: WARN 1 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0 · RedisConnectionFailureException 0
SCARD kitchen-order 120 · ZCARD tiffinbox:leaderboard 4 · XLEN tiffinbox:kitchen-events 0 (units 14, 15 and 16's, unchanged by unit 17)
--scan, keys with lock or rate in their name: 0
```

**No move at 17** in the tests: no test of this folder was added, because the lock and the counter are harness code and TiffinBox
ships neither (⚑8, ⚑14, RED #10); the Javadoc paragraph is not code a test reads.

### 8 · default — the default run never needs Redis (R.400, RE-MEASURE 11)

```text
-- after/ with no profile (TiffinBox's default run): H2 in memory, Docker at nothing (DOCKER_HOST=tcp://127.0.0.1:1), Redis absent (--spring.data.redis.port=20569, nothing listens: 0); one JVM:
PROBE started: yes · default run, H2 2.5.250 · the cache's store: in the JVM, CaffeineCacheManager · a web server: yes
PROBE http (default run, H2 2.5.250): GET /dashboard -> 200
PROBE http (default run, H2 2.5.250): GET /actuator/health -> 200 · status UP
PROBE http (default run, H2 2.5.250): GET /leaderboard -> 404
PROBE http (default run, H2 2.5.250): GET /kitchen -> 200 · ordersCooked 120
exit 0 · its log, every line but the harness's own PROBE lines: WARN 2 (Netty's DNS line on macOS: 1) · ERROR 0 · lines naming an Exception or an Error class 0 · RedisConnectionFailureException 0
Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

### 9 · seven — the comparison set on before/ and after/ (R.363)

The seven requests of `../c5-unit11/curlset.sh` on `before/`'s jar (port 20565) and `after/`'s (port 20560), the default run, H2;
Hibernate's schema script beside them. Unchanged, as expected: the Javadoc is no byte of the jar's behaviour.

```text
exit 0 · cmp with xcheck.sql (= Course 7's capstone's): the same, byte for byte
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 · listens on: 127.0.0.1:20565
GET /dashboard: 200
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20565 now: 0
GET /actuator/health/readiness -> 200 · GET /actuator/health -> 200 · GET /leaderboard -> 404 · listens on: 127.0.0.1:20560
GET /dashboard: 200
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20560 now: 0
the seven, after/ against before/: lines that differ: 0
```

### 10 · redlock — the harness's majority acquire on three Redis: `3`, `2`, `1 of 3`, and the minority release (⚑9, RE-MEASURE 10)

Three Redis containers of the one digest — the unit's on 20562, two more on 20563 and 20564, up only inside this window (`--pull
never`, removed `rm -fv` at its end). The harness's holder A sends `SET NX` with the lock's time to live to each and counts the ones that
answered `true`; the majority of three is two. Then the receipt stops the third container (`dk stop`), then the second. A stopped
instance answers nothing: the harness prints `RedisConnectionFailureException` for it, named and counted — the one place that exception
is allowed in this unit's run, its JVM logs gathered in a file of their own (`h-redlock.log`) and every such line asserted to be the
harness's own per-instance line. After `NOT HELD` the harness releases the key it did get, by the Lua compare-and-delete (RE-MEASURE 10:
redis-cli reads 20562's key empty after it). A sketch: no clock-drift term, no retry — the published algorithm has both, and this one
has neither. TiffinBox ships one Redis; Redlock is the harness's alone.

```text
-- all three up:
PROBE redlock (the harness's majority acquire, holder A): 20562 -> true · 20563 -> true · 20564 -> true
PROBE redlock: 3 of 3 -> HELD (majority 2)
redis-cli GET tiffinbox:lock:kitchen-slot on each: 20562 [A] · 20563 [A] · 20564 [A]
-- dk stop c8u17-redis3 (20564):
PROBE redlock (the harness's majority acquire, holder A): 20562 -> true · 20563 -> true · 20564 -> RedisConnectionFailureException
PROBE redlock: 2 of 3 -> HELD (majority 2)
redis-cli GET tiffinbox:lock:kitchen-slot on each: 20562 [A] · 20563 [A] · 20564 stopped (its State.Running false - no redis-cli)
-- dk stop c8u17-redis2 (20563) too:
PROBE redlock (the harness's majority acquire, holder A): 20562 -> true · 20563 -> RedisConnectionFailureException · 20564 -> RedisConnectionFailureException
PROBE redlock: 1 of 3 -> NOT HELD (majority 2)
PROBE redlock: the minority release on 20562 (the Lua compare-and-delete) -> returned 1
redis-cli GET tiffinbox:lock:kitchen-slot on each: 20562 [] · 20563 stopped (its State.Running false - no redis-cli) · 20564 stopped (its State.Running false - no redis-cli)
c8u17-redis2 and c8u17-redis3 removed with their volumes (rm -fv) · listening on 20563: 0 · on 20564: 0
```

§4 documentation, from memory, unchecked — no saved copy on disk and no network in this run: Martin Kleppmann's 2016 essay `How to do
distributed locking` argues against relying on Redlock's timing, and Salvatore Sanfilippo's (antirez) 2016 reply "Is Redlock safe?"
answers it; neither is measured here, and this README gives no verdict on Redlock.

### 11 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`'s lines, then `exercise/SOLUTION.md`'s, one after the other, in one `env -i` shell: `/bin/bash --noprofile
--norc`, then `/bin/zsh -f`. The broken state's `DEL` leaves redis-cli's `GET` empty; the solution's Lua release returns `0` and leaves
`B`. The check is redis-cli's `GET`, never the exit: the program exits `0` in both.

```text
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
Maven: exit 0
javac: exit 0
docker run: exit 0
Release: exit 0
holder A: acquired true
the program holds A past its lock's time to live (EXISTS read until 0): EXISTS 0
holder B: acquired true
holder A sees, before its release: B
holder A releases by DEL: deleted true
redis-cli GET tiffinbox:lock:kitchen-slot: []
docker rm -fv: exit 0
then the solution's lines, in the same shell - the block's exit 0:
Maven: exit 0
javac: exit 0
docker run: exit 0
Release: exit 0
holder A: acquired true
the program holds A past its lock's time to live (EXISTS read until 0): EXISTS 0
holder B: acquired true
holder A sees, before its release: B
holder A releases by the Lua compare-and-delete: returned 0
redis-cli GET tiffinbox:lock:kitchen-slot: [B]
docker rm -fv: exit 0
the shell is now in: this unit's folder · the shell's own output: 0 lines · listening on 20562 afterwards: 0 · a container named c8u17-ex: 0
```

## Which store, which profile, whose write

**after/'s classes — the harness's lock, holders A / B / C, Redlock's majority and the harness's counter** (`probe.u17.H17`, a
Redis-only JVM): `lock`, `otherholder`, `lua`, `redlock`, `rate`, `race`. **17/after, profile dev, PostgreSQL + Redis — TiffinBox JVM 1
and JVM 2 through the anchor's `findAll` and the shipped `RedisCaching`**: `sync` row a and `anchor`. **The labelled copies**
(`variants.py nolocking`, `hold`, `nolockhold`): `sync` rows b, c and d — never the anchor's. **redis-cli on the unit's Redis** (and on
20563 / 20564 inside `redlock`): the second witness everywhere, the writer of the go key and of `rate`'s two one-command forms.
**PostgreSQL's own log**: `sync`'s second witness of the table's reads. **17/after, default run, H2, no Redis**: `default`, `seven`, the
tests' H2 half. **The exercise's program**: `Release.java`, its own connection factory, the exercise's own Redis.

## Refused, named

- A lock in TiffinBox, and a counter in TiffinBox (⚑8): neither is shipped; the anchor's only lock is the one its cache writer holds.
- An anchor test of harness code (RED #10, ⚑14): the tests stay as unit 16 left them.
- A safety verdict on the harness's lock, a verdict on Redlock, the citations said as fact (R.407, XFAM_S3, RED #13): refused by
  `s817.py`; the two positions appear only under the unchecked label above.
- No Kafka fact (R.405): Course 13's *Choosing a Broker* and *Delivery Guarantees* take the broker comparison up.
- The lock's time to live as a number, and the harness's counter's (R.402, the dur8 list): `PTTL` / `TTL` replies masked `<n>`, the
  `EXPIRE … NX` and `SET … EX … NX` commands printed with `<n>`, `-1` and `-2` read as they are.
- A clock-drift claim: the sketch has no drift term, and nothing here measures a clock.
- A cross-process `sync` claim beyond the capture (R.408, R.409): the two-JVM words only beside `sync` and `customers~lock`; the
  servers' words never.
- MONITOR's `customers~lock` lines for `sync` — dropped first under the time cap (the prompt's order): the counters, PostgreSQL's
  count and `--scan` are the witnesses; not captured, not said.
- A settle sleep (R.412): every wait polls a count — the go key, `EXISTS` until `0`, each JVM's own line, `PING` — with the reads masked
  `<k>` in the captures.

## Call-backs, by title (R.224)

- Course 8's *Spring Data Redis Repositories* (unit 15): the kitchen orders the dev start saves, `SCARD kitchen-order` read in `sync`
  and `anchor`; *Pub/Sub and Streams* (unit 16): `before/`, its stream `XLEN` read in `anchor`.
- This unit: *Distributed Locks and Rate Counters* (17).
- Forward, by title only: Course 13's *Choosing a Broker* and *Delivery Guarantees*.

## The commands this unit adds

`./receipts.sh` (bash 3.2) or `bash receipts.sh` (bash 5), from this folder; the exercise's block from this folder. The anchor's own
commands are unchanged.

## The repository, and the network

`.m2-demo` is a copy of the course's seed, `spring-data-beyond-jpa/_research/m2-seed-c8-s3` (7,102 files); every build reads it offline
(`-o`, `maven.repo.local` as an absolute path), every one `-pl tiffinbox-web -am`, and the receipt asserts its file count unchanged after
each Maven run and Maven's log free of a download line (`offline: yes`). No dependency moves: both `pom.xml` files are untouched, the
jar's libraries are the same list before and after (`anchor`: gained 0, lost 0), and the three classes the harness's lock and counter use
are in the seed's `spring-data-redis-4.1.2.jar` (`core/script/DefaultRedisScript`, `core/ValueOperations`, `core/RedisTemplate` —
`unzip -l`, printed). No network of any kind but the commit's push; no image pulled (both digests present at the start, the image list
the same at the end).

## The folders, the harness and the ports

- `harness/src/probe/u17/H17.java` — the Redis harness JVM: Lettuce's connection factory on `127.0.0.1:20562` (and on 20563 / 20564 for
  `redlock`) and a `StringRedisTemplate`, nothing else — the lock (`acq=`, `see=`, `del=`, `lua=`), the planted hold (`past`), Redlock's
  majority (`redlock=`), the counter (`rate=`, `race`). The harness's holders B and C are second and third runs of it inside the first's pause.
- `harness/src/probe/u17/U17.java` — TiffinBox's application class with its web server and `Counter`; `sync=N` (the pause, the go-key
  poll, one `findAll()` on the caller thread, the caller's state under the hold), `info`, `http`, `hold`.
- `harness/src/probe/u17/Counter.java` — unit 13's invocation counter, its package line and its copied-from sentence changed (asserted).
- `harness/chk17.py`, `harness/s817.py` (XFAM_S2's block byte-equal to s814's and s816's, asserted), `harness/tree17.py`,
  `harness/variants.py` (`nolocking`, `hold`, `nolockhold`), `harness/surefire.py`, `harness/dur8.py` (as shipped),
  `harness/logback.xml` and `c7-unit29`'s `probe/x/XMain.java`, each copied byte for byte where it says so.
- Ports, 20560-20569: **20560** TiffinBox `after/` (`sync`'s JVM 1, `anchor`, `default`, the seven) · **20561** the PostgreSQL container
  (`-c log_statement=all`, for the whole run) · **20562** the Redis container (the exercise's own Redis before it; Redlock's first) ·
  **20563 / 20564** Redlock's second and third Redis, up only inside `redlock` · **20565** `before/` for the seven · **20566** `sync`'s
  JVM 2 · **20569** the port "Redis absent" points at on the default run, asserted unbound · **20567 / 20568** never bound. Nothing
  listens on any of them at the start or the end.

## Masks, filters and hygiene — every one, declared

The captures mask what moves from run to run: Boot's start line, Surefire's and Maven's times, Flyway's execution time, the folders
and the home, pids, identity hashes, every poll's count (`polled <k> times`, `read <k> times`), the number of the JVM that wins `sync`'s
release (`JVM <k>`, the two lines sorted), and every positive time to live (`<n> (positive)`). The mask's self-test plants each and
refuses a run if one passes. Every capture is checked for an absolute path, a time, a poll count, a time to live as a number, a log
time, a stack frame, a raw container port, the token and the password; dur8 over the captures and this README's text blocks: `0` words.

## Interrupted

`receipts.sh` traps SIGINT and SIGTERM: it stops its own processes by pid (a JVM — `sync`'s two TiffinBox JVMs in the trap's two
slots —, Maven, the exercise's shell, a second harness JVM inside a pause), removes its containers with their volumes (`rm -fv`:
PostgreSQL, Redis, Redlock's second and third, the exercise's), removes any Testcontainers container, deletes the partial captures,
and exits 130. Measured 2026-11-19, from 14:02 to 14:24 CET, each run alone, `bash receipts.sh` started by a driver with SIGINT
reset to its default (`perl`, R.410), its `.harness` cleared first, and SIGINT sent when a marker appeared in the run's own fresh
`.harness`: **mid-build** (Maven building `before/`'s core module), **mid-verify** (Surefire running the tests), **mid-`sync`**
(both TiffinBox JVMs up on PostgreSQL and Redis at their first pause — this is also the mid-TiffinBox-on-PostgreSQL case),
**mid-`redlock`** (the third Redis container running, three up), **mid-holder-A's hold** (`otherholder`'s holder A held by the
harness, planted) and **mid-`race`** (the harness holding before its `EXPIRE` — the capture's own SIGINT goes to that JVM; the
receipt's came beside it). Each: exit `130`; read when the run had stopped and again after a pause of the driver's — no java process,
no container of this unit's, no Testcontainers container, no redis-cli client, volumes `315` and images `7` as before, nothing
listening on 20560-20569, `.r-lock` gone, no partial capture, the captures' bytes and `receipts.md5` unchanged.

## The ledger rows this unit pays

- The roadmap's "a correct-enough lock, and why Redlock is contested": paid — `lock`, `otherholder`, `lua` (the harness's lock, the release by Lua, what it does not stop), `redlock` (the majority and its sketch's limits), the two positions cited unchecked.
- S2 CARRIED "cross-process `sync` (two JVMs, one Redis)": paid by `sync`.
- The contract's R.350 (a lock sentence says what it leaves open): `lua`'s `held at once`, said on the same slide.
- **C8-24** (unit 17's cross-JVM `sync` → the anchor's Javadoc): **closed — corrected: the capture printed one and two, and
  `findAll()`'s Javadoc carries the unit 17 paragraph (`sync`, rows a-d, 3/3 each).**

## RE-MEASURE — the plan's items this unit settles

- **9** (cross-JVM `sync` through the anchor's `RedisCaching` on `findAll` itself, no hold and the labelled hold): `sync`, above.
- **10** (the Redlock harness with the minority release): built — `redlock`'s `NOT HELD` window releases 20562's key, read empty.
- **11** (the seven and `18 + 8` on 17/after; the default run's health and `/leaderboard`): `seven`, `anchor`, `default`.
- **14** (the lock's no-hold control): `lock`, above.

## The anchor moved — the builders (R.211, R.331)

Before the commit: `grep -n 'c8-tiffinbox\|CustomerRepository\|RedisCaching\|findAll\|application-dev.yaml\|compose.yaml'` over
`_builders/s80*.py`, `_builders/s81*.py`, `check_unit8.py`, `qa_java8.py` and `build_java8.py`, and `grep -n
'CustomerRepository\|RedisCaching'` over every `c8-unit*/receipts.sh`, its hits read in full (the agent's report says where they are
kept). The builders read `CustomerRepository.java` from their own unit's `after/` or `anchor/` (`s806.py`, `s808.py`, `s810.py`,
`s811.py`, `s813.py`), never from `c8-tiffinbox`; their live compares read `c8-tiffinbox` only to print a note when the live anchor has
moved on. No shipped receipt reads `c8-tiffinbox`'s `CustomerRepository.java` live. No claim depends on the Javadoc's bytes; no
builder and no earlier unit was edited.

## Section 3 complete — next: scripts 14-17

This was the last evidence batch of Section 3 (units 14-17, each with its receipts, its captures and its anchor change). Next is the
script stage, in the order the brief's EVIDENCE BATCHES gives: `check_unit8.py`'s `DUR_SECTIONS = {1, 2, 3}` first (Section 3 gates
duration words), then `_builders/s814.py`-`s817.py`, RED (one agent, 14-17), BLUE, build, QA, thumbnails, copy, the Shorts rows.

## What differed from the brief

- **C4 is two files, not one.** The prompt's "one Javadoc" is the code change; the anchor README carries a section for it (the unit 16
  section's shape) and one header note at the end of unit 16's, so `diff -rq before/ after/` lists `CustomerRepository.java` and
  `README.md`, `+0` files, the after-tree's hash moved by those two (`chk17.py readme` asserts the README change is that section and that
  note, nothing else).
- **RE-MEASURE 9 ran twice before it was written.** Once in the session's scratch folder (the same harness, the same four trees, three
  rounds of the four rows, before any anchor file was touched): rows a, b, c, d printed one, two, one and two reads in every round, the
  lock key in Redis in row c's hold; then the Javadoc was written; then every run of record printed the same (`sync`, 3/3 in each run).
- **JVM 2 has its own web server, on 20566.** TiffinBox's start under "dev" needs no web-free mode; both JVMs bind, and the second
  JVM's start runs the fill again against the same Redis and database (orders cooked twice per row, the same count; `SCARD
  kitchen-order` one start's count — the ids are the same; the leaderboard reset and refilled to the same four scores).
- **Which JVM wins the release is masked.** The winner moves from run to run; the capture writes `JVM <k>` and sorts each row's two
  answer lines, and the check asserts the sorted deltas, their sum and PostgreSQL's count, never the winner.
- **The held rows wait on each JVM's own evidence, not on the hold alone.** Each JVM reads its caller thread's state and stack until it
  is parked — inside the copy's hold, or waiting inside Spring Data Redis's cache writer — and prints which; the receipt reads `--scan`
  only after both lines, then ends the hold. The hold itself polls a file on the harness's caller thread only (`u17-caller`), so the
  start and every other thread pass straight through.
- **Row (b), no hold, printed two in every round** (the scratch rounds and every run of record): the README says what printed; a one
  there would have been the release's chance.
- **PostgreSQL logs every statement for the whole run** (`-c log_statement=all` on the container), not only in `sync`'s window; only
  `sync` counts lines off it, between its psql markers.
- **MONITOR for `sync` was dropped**, the first of the prompt's drop order: the counters, PostgreSQL's count and `--scan` witness each
  row; no `MONITOR` line is captured or said.
- **`lock`'s holder B is a second harness JVM**, as in `otherholder` and `lua`, so the control and the failure share one shape.
- **The lock's time to live is a constant of the harness** (`H17.LOCK_TTL`), never printed and never passed on a command line; every
  positive `PTTL` / `TTL` reply is written `<n> (positive)` by the receipt, and `-1` / `-2` as they are.
- **The exercise's program plays both holders in one JVM**, its hold its own `EXISTS` read until the key is gone (the program's, "on
  purpose"); its README says so.
- **`redlock`'s minority release is built** (RE-MEASURE 10): after `NOT HELD` the harness's Lua release on 20562, redis-cli `GET`
  empty. Its extra containers are `c8u17-redis2` / `c8u17-redis3`; a stopped one is read by `dk inspect` (`State.Running false`). The
  run log's R.410 count leaves this window out by file, not by markers: the Redis harness JVMs' logs inside `redlock` go to
  `h-redlock.log`, where every `RedisConnectionFailureException` line is asserted to be the harness's own per-instance line.
- **The default run's "Redis absent" port is 20569**, from the spare range, asserted unbound and never bound; 20567 and 20568 stay
  unbound.
- **Two `cap` helpers changed shape from unit 16's**: the Redis harness's second and third JVMs (`side`, holders B and C) take the
  publisher's place inside a pause; `sync` runs two TiffinBox JVMs in the background together, their pids in the trap's two slots.
- **The caller's place is read until it holds still.** The first `bash receipts.sh` stopped on its own 3/3 check: in one pass of row c
  both JVMs had reported their caller waiting inside the cache writer — the caller that went on to hold the lock had been read while it
  passed through the writer on its way into the method. Since, each JVM reads its caller until the same answer comes `STABLE` reads in a row (`U17.java`)
  (a count, under the JVM's alarm); ten rounds of rows c and d in the scratch folder then printed one caller in the hold and one waiting
  (c) and both in the hold (d), every round, and the runs of record 3/3.

## For RED

- `sync`'s winner moves: which JVM takes the lock is the release's race; the capture writes `JVM <k>` and sorts the two lines, and the
  check asserts the sorted deltas, the sum and PostgreSQL's count — never which JVM ran the method.
- The held rows park each caller on its own JVM's evidence (the caller thread's state and stack: inside the copy's hold, or waiting in
  Spring Data Redis's cache writer) before the receipt reads `--scan` and ends the hold — a count, not a guess.
- The hold copy's `u17Hold()` runs only on the harness's caller thread (`u17-caller`) and only under `-Du17.hold`: the start, the
  health indicator and every other thread pass straight through; row a and `anchor` run `after/` itself, which has no hold at all.
- `otherholder` and `lua`: the receipt answers A's hold only after its own `EXISTS` poll read `0` and B's JVM printed `acquired true`.
- `race`'s SIGINT goes to the pid the JVM printed on its own hold line, after `perl` reset the signal (R.410); exit `130` asserted.
- `redlock`'s stopped instances are read by `dk inspect` (`State.Running false`), never by a redis-cli that cannot answer.
- One plant passed the prose gate: a sentence typing a count of requests (*Planted faults*). `s817.py`'s typed-number list is unit
  16's; the harness was not changed after the runs of record, so the gap is shipped as measured.
- `chk17.py static` stops on a Javadoc without the unit 13 sentence by an exception (its own index call), not by a named line; `r250`
  names the same plant. Both exit 1.

## Planted faults — each caught (R.65, R.226)

Each plant ran alone — never beside a run of record — after the three runs of record: a doctored capture checked by `chk17.py`
(Python, never `sed`), a planted sentence on a copy of this README checked by `s817.py`, or a planted file in a scratch mirror of this
folder (its parent linking the units it reads) checked by `chk17.py static` / `r250`. Each control — every capture as captured, the
README and the exercise as written, `static` and `r250` on the mirror as shipped — exited 0: fourteen controls, all clean. Of
forty-nine plants, **forty-eight were caught and one was missed** (below).

- **The brief's 17 list:** a sentence crediting the Lua release with a sound lock, and a verdict on Redlock (XFAM_S3, R.407); the
  lock's end given as a count of time (dur8, XFAM_S2); the copy's `sync` said to reach past the JVMs it ran in (R.382); a hold sentence whose overrun carries no planted label (R.406, RED #8); the key's end called by the word XFAM_S2 refuses (RED #7); the `nolocking` copy voiced as
  the anchor's (R.302, R.392); the third Redis removed without its volume in a copy of `receipts.sh` (`static`, R.387); `kill -INT` without the perl reset — the Redis harness launch's reset taken out of a copy (`static`,
  R.410); a sleep of the lock's length behind the `EXISTS` poll (`static`, R.412); the Javadoc paragraph on a copy where `sync`
  printed two — rows a and c doctored to two while `after/` carries the paragraph (`chk17 sync`).
- **Doctored captures:** `otherholder`'s `GET` after A's release made `B`, and C's `true` made `false`; `lua`'s `returned 0` made `1`,
  and C's `false` made `true`; `redlock`'s `1 of 3 -> NOT HELD` made `HELD`, and 20562's `GET` after the minority release made
  non-empty; `sync`'s row d made one read, row c's `customers~lock` taken out of the scan, and PostgreSQL's count made unequal to the
  counters' sum; `rate`'s sixth `refused` made `allowed`, and `EXPIRE … NX`'s second `0` made `1`; `race`'s `TTL -1` made positive;
  a `PTTL` reply unmasked (`lock`); `default`'s `404` made `200`; the seven's hash; `anchor`'s `HHH000001` line taken out, Boot's
  version and `redis_version` moved; the exercise's solved block made the broken one (R.196).
- **The prose gate:** besides the list above — `atomic` with no Lua, MULTI or one-command name; a `PX` with its number (R.402); a
  citation outside the unchecked label (RED #13); a holder without its label (R.392); the two-JVM words outside `sync`; a container removal without its volume (R.387); a module build without its
  dependencies' flag (R.391); the docker CLI without its socket (R.344); the test count typed (R.302); a claim about clocks; a fact
  about another broker (R.405); a typed md5; a wait word; `immediately`.
- **The mirror's files:** the unit 13 sentence taken out of the Javadoc (`r250` names it; `static` stopped on it with an exception
  rather than a named line — For RED); a lock class added to the anchor (⚑8, `static`'s file list); this README's dated unit 13 note
  taken out (`r250`).
- **Missed:** "The 6 requests give 5 allowed." — `s817.py`'s typed-number list (carried from unit 16's) names no `requests` or
  `allowed`, so the sentence passes. Not fixed after the runs of record (the harness the runs ran is the harness shipped); the README
  types no such sentence; RED's to judge — For RED.

## The values the video may say

<!-- values: begin -->
the values the video may say - exercise: the line 25 words · broken (DEL): deleted true, redis-cli GET empty · solved (the Lua compare-and-delete): returned 0, redis-cli GET B · the program holds A past its lock's time to live on purpose · exit 0 both (a standalone program on the anchor's libraries, Redis by the digest) · sync: RE-MEASURE 9, two TiffinBox JVMs, one Redis, one PostgreSQL, findAll() through each context's bean, released by one Redis key: (a) after/'s shipped writer, no hold - 1 read · (b) a copy without enableLocking(), labelled, no hold - 2 · (c) the shipped writer, the harness holds (planted) - 1, customers~lock seen by redis-cli · (d) the copy without enableLocking(), the harness holds - 2, no lock key · each sum = PostgreSQL's customer SELECTs between the markers; two starts against one Redis: ZCARD tiffinbox:leaderboard 4, SCARD kitchen-order 120 (= one start's orders cooked 120) · redlock: the harness's Redlock sketch, three Redis of the one digest: 3 of 3 HELD / 2 of 3 HELD / 1 of 3 NOT HELD · stopped instances answer RedisConnectionFailureException (named) · the minority release: 20562's key gone (redis-cli GET empty) · no drift term, no retry · lock: the harness's lock, no hold (RE-MEASURE 14): A acquired true, redis-cli GET A, PTTL positive; A releases inside its lock - DEL deleted true / the Lua release returned 1; redis-cli GET empty; then B acquired true, GET B · otherholder: the harness holds A past its lock's time to live (planted): B acquired true, A sees B (held at once); A's DEL deleted true; redis-cli GET empty - A deleted B's lock; C acquired true · lua: the harness holds A past its lock's time to live (planted): B acquired true, A sees B (held at once); the Lua compare-and-delete returned 0; redis-cli GET B; C acquired false · race: INCR 1, the harness holds before EXPIRE (planted), SIGINT -> exit 130; redis-cli GET 1, TTL -1 · rate: the harness's counter: requests 1-5 allowed, the 6th refused; redis-cli GET 6, TTL positive · on 8.10.3: EXPIRE … NX 1 then 0; SET … EX … NX OK, INCR 2, TTL positive · anchor: 17/after, profile dev, PostgreSQL + Redis: Found 1 JPA / 1 JDBC / 1 Redis repository interface · orders cooked 120 · kitchen value 24300 · SCARD kitchen-order 120 · health 200 · /leaderboard 200 · /dashboard 200 · Boot 4.1.2, Framework 7.0.10, Spring Data JPA/JDBC/Redis 4.1.2, Lettuce 7.5.2.RELEASE, HHH000001 7.4.13.Final, Flyway 12.4.0, redis_version 8.10.3 · SIGINT -> exit 130 · libraries 122, none gained · tests 18 + 8 (no move at 17: no anchor test of harness code) · default: 17/after, default run, H2, no Redis, no Docker: health 200 · /leaderboard 404 · /dashboard 200 · the 18 under mvn -o package, Docker at nothing · seven: the seven 466c20ed… on before/ and after/ (0 lines differ) · GET /dashboard 200 · health 200 · /leaderboard 404 on the default run · Hibernate's script = xcheck.sql
<!-- values: end -->

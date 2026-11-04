# c7-unit08 — Embeddables and Value Objects

Course 7 · Data with JPA & Hibernate · Section 2 (Mapping), its third unit · **no change to the anchor** · Verified on **JDK 25.0.4.1,
Apache Maven 3.9.16, Spring Boot 4.1.2** (Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the anchor's pin),
2026-11-04. An address is not a table; it is three columns that belong together. An **embeddable** is a class Hibernate maps into the
columns of the entity that holds it, never a table of its own (`@Embeddable` on the class, `@Embedded` on the field); a **value
object** is a small object that is nothing but its values — two addresses with the same three values are the same address — and has
no id. Measured on H2 (brief ⚑2: the probe found H2 and PostgreSQL write the same DDL and SQL for every beat here; this unit speaks for
H2 only and says so): the DDL Hibernate writes for one embedded `Address`; what happens to an address of three nulls; the same value
object as a record; two addresses in one entity — refused until the second gets its own column names.

**No anchor change (brief ⚑1).** `anchor` is the link to `../c7-unit07/after`, the frozen tree after the course's third anchor change
(ids by IDENTITY, `mealType` an enum stored by its name). `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets anchor/
../c7-tiffinbox` at its start and its end — empty in every run of record — and from a later anchor change on prints a note instead,
never a stop (R.211). The anchor is copied under `.harness/anchor` and built there, never in place; nothing in it is read but its
extracted jar (the libraries the harness runs on, and `com.tiffinbox.CustomerEntity` for `xcheck`). Every entity this unit maps is the
harness's own (`harness/src/probe/map/embed`).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first), and when a check after a capture fails. **Start it in
a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group. No Docker, no
container, no password: this unit runs H2 only. `.m2-demo` must be seeded first (below).

**Runs, each `env -i`** (`HOME` = a home of its own whose `.mavenrc` sets `-Duser.home` there and whose `settings.xml` names only two
dead proxies, `127.0.0.1:9`; `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`; `http(s)_proxy` dead too), a session of its own,
`.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Two development runs fixed the
captures and the checks (the first stopped at `exercise`'s check: a trailing space Hibernate puts after its `PersistenceException`
message — Found on the way; the second wrote every capture 3/3 with every check and the hygiene passing, and its md5s are
`receipts.md5`). **The runs of record, on the script as committed (`receipts.sh` md5 `0ad1322e32ab86be2d641d2c2c526dfb`): 63 s under
`./receipts.sh`** (/bin/bash 3.2.57) **and 63 s under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 7 captures 3/3 =
published, every check passed, the one build `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty at
the start and the end, nothing listening on 19870-19879 at the end; each terminal log through `check_unit7.py 08 --runlog` —
`0 grep error line(s)`, `RESULT (run logs): PASS` (the unit gate answers "no 08-*.md … nothing to check": no script yet). **Nothing
was downloaded**, and this unit made no network act.

Published hashes: ddl `c9bc322f33216db6822b66c9ffb4a43b` · nulls `24fce57486ea4662e5b2d6337fe7af87` · record `e650b3969176245d1cddaf9dd052a2aa` · two `390961afb6556eac383ab69f22dd1832` · overrides `3d461b6fe6525cce6780d4ae9f3cad92` · xcheck `d99a052716b49543ae22cae0b0da7ecb` · exercise `bfaed47210e5445d942a7c1e80d871a2`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 07's recipe, with this unit's folder (no `DOCKER_CONFIG`: no container here):

```bash
S=/tmp/sealed08; W="/tmp/sealed 08"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit08" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-04):** a `git clone` of tiffinbox-java at `d84bf1b` into a path **with a space** (`…/sealed 08/tiffinbox-java`), this
commit's 17 files put in as git takes them (`git ls-files -o --exclude-standard`, each `cmp`-equal to the working tree; `anchor` →
`../c7-unit07/after` by `readlink`); a `file://` copy of the s2 seed (4,971 files); pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i`, a session of its own: **exit 0 in 62
s, all 7 = published, every check passed**; the build `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`; after the run
`.m2-demo` held 4,971 files, 0 `_remote.repositories`; the builders' `dur7.py` is not beside a clone, nor unit 07's `.r-xcheck.out`
(the terminal says so of each; `dur7.py`'s md5 and unit 07's published `820b43fc…` are the checks). Its terminal log through `--runlog`: PASS.

## The commands this unit adds

```bash
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/map/H.java harness/src/probe/map/Main.java harness/src/probe/map/embed/*.java
java -Duser.language=en -Duser.country=US -Dlogback.configurationFile=../../harness/logback.xml "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.map.Main "${A[@]}"
```

The harness compiled against the anchor's extracted jar (its 91 libraries: Hibernate, Jakarta Persistence, H2, Logback, Boot's naming
strategy) into `.harness/hc`; **the harness line**, run from `.harness/run`: `V` its JVM flags (`-Dsql=WARN` where a capture shows only
the script, nothing where it shows the SQL), `A` its arguments — R.193, each printed as `$ V=(…)` / `$ A=(…)`. The lines read from
`anchor/README.md` (2, each asserted whole): `mvn -B package` (run offline, `mvn -o -B -Dmaven.repo.local="$M2" clean package`, from
`.harness/anchor`) and the extract line, `java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination
tiffinbox-web/target/extracted`.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). One build: the anchor's `package` (it runs the anchor's 18
tests), `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from the build log, never typed).
After it the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar` and
`h2-2.5.250.jar`. **At run time** nothing leaves the computer: every database is H2 in one harness JVM's memory, gone with it. **No
network act**: this unit reads no version file — unit 06 made Section 2's dated sweep
(`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-04.xml`, md5 `f9f50873…`: 4.1.2 the newest 4.1.x GA, 4.1.3 absent,
no 4.2 GA; R.223), and no Section 2 unit speaks a "newest" fact (⚑6).

## No token, no password

No TiffinBox server runs here, so there is no demo token, no `secrets/` folder (a check refuses one in this folder) and no shutdown
call; no container, so no database password. The harness's H2 databases have the user `sa` and an empty password, in memory.

## The locale

Every java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it; the anchor's
test fork gets its locale from the POM's `argLine`. **The harness prints ASCII** (` | ` between facts).

## The folders, the harness and the ports

- `anchor` — the link to `../c7-unit07/after`. `.harness/anchor` — copied, built with the README's `mvn -B package` offline, its jar
  extracted (91 libraries); `.harness/hc` — the harness, compiled; `.harness/run` — where every harness JVM starts (its scripts land
  there); `.harness/ex` — the exercise's class.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/map`, package `probe.map`; a check refuses `probe.map` anywhere in
  the anchor's code). `H.java` is unit 07's with its PostgreSQL path, its file database and its kept database taken out (this unit runs
  H2 in memory only). **Not a Boot application** (⚑3, R.212): one `EntityManagerFactory` per run, Jakarta Persistence 3.2's
  `PersistenceConfiguration` over the classes the run names, Boot's two naming strategies, statistics on, `drop-and-create` on the run's
  own in-memory database only (R.178; `xcheck` sets it to `none`); the JDBC proxy of unit 06 beside it. Every run prints
  `org.hibernate.Version.getVersionString()` first, its `database:` line, and Hibernate's own `HHH000001` line (R.222). Scenarios
  (`Main.java`): `ddl FILE CLASS…` (the script, written and run; then whether the file exists), `nulls CLASS` (three customers persisted,
  the raw rows, each read back by id in the same EntityManager and in a new one), `two` (one customer with two addresses, the table's
  columns and row, the read), `ex CLASS` (the exercise's), `xcheck FILE`. Entities (`probe.map.embed`, English names): `Address`
  (`@Embeddable`, a class: `line1`, `city`, `@Column(length = 6) pincode`, equals/hashCode/toString by value), `RecAddress` (the same as
  a record), `AddrCustomer` (`@Embedded Address address`), `RecCustomer` (`@Embedded RecAddress address`), `TwoAddrCustomer` (`home` and
  `office`, no column names), `TwoOverCustomer` (the same, `office` with three `@AttributeOverride` — repeatable, no
  `@AttributeOverrides` wrapper). `probe.map.ex.ExCustomer` is the exercise's (two Addresses, no overrides; never compiled into
  `.harness/hc`, asserted). `harness/logback.xml` — unit 07's, with `org.hibernate.orm.core` at INFO (for `HHH000001`; it also prints
  `HHH000489`, the no-JTA line); `harness/dur7.py` (the builders', md5 `41667fed…`), byte for byte. No `pom.xml` (no driver to
  resolve), no `shutdown.sh`, no `surefire.py` (no server, no `tests` capture).
- **Ports** (§P, 19870-19879): **none bound**. 19870-19879 (19879 the unit's "never bound" port), 18425, 8080 and 35729 are checked free
  at the start and the end. The anchor's 18 tests run inside its package build and bind what TiffinBox's tests bind; the harness's JVMs
  and the exercise bind none.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on a planted line): this folder → `…`, the folder above → `…/..`, home → `~`,
   the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`. (No token, password, generated database name or pid to
   mask: the H2 names are the harness's own, `u08ddl`, `u08nulls`, `u08two`, `u08ex`, `u08xcheck`.)
2. **A harness log** (`hview`): every line, trailing spaces dropped. **The exercise's output**: every line, trailing spaces dropped (the
   capture says so).
3. **A Maven log**: the build's one line — what it built, `offline`, exit, its `Downloaded from` count (terminal only; it is not a capture).
4. **Hygiene, checked last over every capture** (unit 07's list, the token and password items dropped): no absolute path, no unit number,
   no Boot process line, no time, no log time, no thread number, no JDK/OS version token, no unmasked generated database name, **no port
   at all**, no per-run timing figure, no stack frame; no `$` line with a URL; every java line pinned; `GenerationTarget encountered
   exception` 0 in every harness log (R.213); no SQL keyword as a harness name; no H2 database file anywhere in this folder (R.195); no
   `pkill`/`killall`; no bare `wait`; no one-string multi-option variable (R.193); no Indian dish name in any capture (R.215).
5. **Duration words** (R.172): `dur7.DUR` over this README and the exercise's two files must find **0** — this unit speaks no time.
   **Dish names** (R.215, the course's memory rule — the AI voice mispronounces them): 41 words — Indian dish names and one more the rule
   names — whole words, any case, refused in this README, `exercise/` and `harness/src` before anything is built, and in every capture at
   the end. The people are Ravi, Meera and Sunil; the cities Pune and Kolkata.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`, with every process under it), sweeps
its own process group for any harness JVM (`probe.map.Main`), Maven or Surefire fork left, deletes the capture runs it had not finished
(`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-04, a scratch mirror of the repository, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a
session of its own **with SIGINT at its default**, `kill -INT` to its group once the named process was in it, the state read 5 s later —
three trials, each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 6 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 2 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
exercise: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the anchor's Maven, its Surefire fork running (`surefirebooter` in the group); `harness` — the first harness JVM (`ddl`);
`exercise` — the exercise's `/bin/zsh -f` shell. `pgrep -fl java` afterwards: none.

## 1 · ddl — one Address, three columns in the customer's table

`AddrCustomer` with an `@Embedded Address address`: Hibernate's script, one statement —

```
create table addr_customer (pincode varchar(6), id bigint generated by default as identity, city varchar(255), line1 varchar(255), name varchar(255), primary key (id));
```

**The address's three columns sit in the customer's own table** — `line1`, `city`, `pincode` (its `@Column(length = 6)` kept), no
`address_` prefix, no `address` table, no foreign key. (The column order is
Hibernate's, not the class's.) H2 2.5.250, the `database:` line in the capture.

## 2 · nulls — a full address, none, and an empty one (RE-MEASURE 6)

Ravi with `Address("12 MG Road", "Pune", "411001")`, Meera with `null`, Sunil with `new Address(null, null, null)`, persisted in one
transaction (three `insert into addr_customer (city,line1,pincode,name,id) values (?,?,?,?,default)`). The rows, by a second connection:

```
1 | Ravi | 12 MG Road | Pune | 411001
2 | Meera | null | null | null
3 | Sunil | null | null | null
```

Meera's row and Sunil's are the same: **the table cannot tell no address from an empty one.** Read back by id:

- **in the same EntityManager** (no clear, after the commit): `Sunil=Address[line1=null, city=null, pincode=null]`, Meera `null` — *the
  objects persisted* (`==`: yes), handed back by the persistence context, **0 SQL** (no `select` between the commit and that line);
- **in a new EntityManager**: three `select`s, `Ravi=Address[line1=12 MG Road, city=Pune, pincode=411001], Meera=null, Sunil=null` — the
  objects persisted: no. **The Address Sunil was given comes back as `null`.**

The hook is the second read, and the voice says it as this run's read on Hibernate 7.4.13.Final (the capture's `HHH000001` line and
`getVersionString()` line), never as a setting (the brief's hazard: Hibernate 5's `create_empty_composites` was not measured). Its plant
(the "new" read made in the same EntityManager) is below: the check fails.

## 3 · record — the same value object as a record

`@Embeddable public record RecAddress(String line1, String city, @Column(length = 6) String pincode) { }` in `RecCustomer`: the script is
`addr_customer`'s **byte for byte but for the table's name** (`rec_customer`; the check replaces the name and compares); the same three
rows; the same two reads — `RecAddress[line1=null, city=null, pincode=null]` in the same EntityManager, `null` in a new one. A record
is the shorter value object: persist, DDL and read all ran on Hibernate 7.4.13.Final (the inserts list `line1,city,pincode`, the
record's order; the class's `city,line1,pincode`).

## 4 · two — two addresses, no column names (the failure receipt, B/A′)

**B** — `TwoAddrCustomer`, `@Embedded Address home` and `@Embedded Address office`: **the trio — exit 1 · `org.hibernate.MappingException:
Column 'city' is duplicated in mapping for entity 'probe.map.embed.TwoAddrCustomer' (use '@Column(insertable=false, updatable=false)'
when mapping multiple properties to the same column)` · the EntityManagerFactory built: no** — under `jakarta.persistence.PersistenceException:
Unable to build Hibernate SessionFactory [persistence unit: u08ddl]`; 0 SQL lines; **no script written** (`two-b.sql exists: no`).
Hibernate refuses the mapping before any SQL — not a DDL failure. Said: **its hint names a different fix** — read-only columns, for two
fields that really are one column; here they are two addresses, and the override is the fix.
**A′** — `TwoOverCustomer`, the office with `@AttributeOverride(name = "line1", column = @Column(name = "office_line1"))`, the same for
`city` and `pincode` (`length = 6` written again — an override replaces the whole `@Column`): exit 0, the script

```
create table two_over_customer (office_pincode varchar(6), pincode varchar(6), id bigint generated by default as identity, city varchar(255), line1 varchar(255), name varchar(255), office_city varchar(255), office_line1 varchar(255), primary key (id));
```

## 5 · overrides — one row, eight columns

Ravi with a home at 12 MG Road, Pune 411001 and an office at 4 Park Street, Kolkata 700016: one `insert into two_over_customer
(city,line1,pincode,name,office_city,office_line1,office_pincode,id)`; the catalogue's columns **(8): `office_pincode, pincode, id, city,
line1, name, office_city, office_line1`**; the row **(1)**: `700016 | 411001 | 1 | Pune | 12 MG Road | Ravi | Kolkata | 4 Park Street`;
read back in a new EntityManager: `home=Address[line1=12 MG Road, city=Pune, pincode=411001] | office=Address[line1=4 Park Street,
city=Kolkata, pincode=700016]`.

## 6 · xcheck — the harness's DDL against Boot's, as unit 07 captured it (R.212, RED #308)

This unit binds no port, so it starts no Boot: the harness's script for the anchor's `com.tiffinbox.CustomerEntity` (from the anchor's
jar, a file, never run) is compared with **Boot's script as unit 07 captured it**, by md5 — `820b43fcc96665c2d457212a156204eb`, stated
in `../c7-unit07/README.md` (its `xcheck` section; that capture's own published md5 `74ea6be7…` is in `../c7-unit07/receipts.md5`, both
asserted by `receipts.sh` before the capture). The harness's: one line, `create table customer (meals_per_day integer not null,
price_per_meal integer not null, id bigint generated by default as identity, name varchar(60) not null unique, meal_type enum
('NON_VEG','VEG','VEGAN') not null, primary key (id));` — **md5 `820b43fc…`, the same**. Where unit 07's capture is on disk
(`../c7-unit07/.r-xcheck.out`, git-ignored, so not in a clone) and still hashes as published, the script is also read from it and its
md5 checked (terminal only, so a clone's capture is the same). The capture names unit 07 as "the enums lesson" (no unit number in a
capture).

## 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s 7 lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: the copy of `ExCustomer.java` made
with a `sed` that puts three `@AttributeOverride` on `office`), each block sourced in one `env -i` shell, `/bin/bash --noprofile
--norc` then `/bin/zsh -f`, each block one fresh harness JVM. In both: the README → **`exit 1`**, `MappingException: Column 'city' is
duplicated in mapping for entity 'probe.map.ex.ExCustomer' …`, no row; the solution → **`exit 0`**, `ex_customer`'s columns **(8)**, its
rows **(1)**: `700016 | 411001 | 1 | Pune | 12 MG Road | Ravi | Kolkata | 4 Park Street`; the shell back in this folder; bash's output =
zsh's.

## Exercise

**Your turn:** the README embeds two addresses and Hibernate refuses to start. Give the second one its own column names.
(20 words, `wc -w` on the quoted sentence, asserted in `receipts.sh`.) `exercise/README.md` ships `ExCustomer` with two `Address`es and
no overrides, `exercise/SOLUTION.md` beside it; broken (the `MappingException`, exit 1) ≠ solved (one row, eight columns, exit 0), each
from its own fresh JVM, measured by the `exercise` capture (R.196).

## The anchor

Unchanged: `anchor` → `../c7-unit07/after`, and `../c7-tiffinbox` = that tree at this unit's start and end in every run of record (the
`diff -rq` above, empty). No file of the anchor, no shipped unit folder (01-07) and no builder is touched by this unit.

## The ledger rows and hand-offs this unit pays

- None (the brief's §LEDGER: 08 pays no row). Its `xcheck` re-proves the harness = Boot on the anchor's entity as unit 07 left it (R.212).

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: `MappingException` exit 1 / one row, eight columns exit 0 |
| 6 | the all-null embedded read in the same EntityManager: **the object persisted, `Address[line1=null, city=null, pincode=null]`, 0 SQL**; in a new one `null` (as the probe read it) — the hook is the new one's |
| 12 | `xcheck` on `07/after`: `820b43fc…`, = Boot's script as unit 07 captured it |

## What differed from the brief

1. **`xcheck` compares by md5 with unit 07's published number** (the AMENDMENT, RED #308), not with a file: unit 07's captures are
   git-ignored, so a clone holds no Boot script to `cmp`. `receipts.sh` asserts `../c7-unit07/README.md` states `820b43fc…` and
   `../c7-unit07/receipts.md5` names its `xcheck` capture `74ea6be7…`; where that capture is on disk it reads the script from it too
   (terminal only).
2. **The version line is printed by the harness itself**: Hibernate's `HHH000001` (its `org.hibernate.orm.core` logger at INFO in
   `harness/logback.xml`) beside `getVersionString()`, in every harness JVM — no Boot run here to print it (the AMENDMENT's #311 line
   for a Boot run; the harness logback of 06/07 held all of `org.hibernate` at WARN). It brings `HHH000489` (no JTA platform) with it, printed as
   it comes.
3. **`nulls` reads twice** — the same EntityManager first (RE-MEASURE 6), then a new one — and prints whether `find` handed back the
   objects persisted. The brief's beat is the new one's read; the same EntityManager's is the plant's shape, shown in every run.
4. **`two` is B then A′ in one capture**, and `overrides` is A′'s entity with a row in it (the brief lists `two` (B/A′) and `overrides`
   apart; A′ there is a script only, `overrides` the row).
5. **The office's pincode override writes `length = 6` again**: an `@AttributeOverride` column replaces the field's `@Column`; without
   it the office's pincode would take the default length (not run on its own here).
6. **No `tests`, `seven` or `pom.xml`**: no TiffinBox server, no driver; the anchor's 18 tests run inside its package build (exit 0, the
   build line), not as a capture (the brief's planned captures for 08 have none).
7. **The plants run the whole script** on a scratch mirror of the repository (the anchor, unit 07's README and `receipts.md5`,
   `../c7-tiffinbox`), the planted capture and those after it out of `receipts.md5` so the check speaks before the hash: a whole run is
   short here (the plants' times are below).
8. **The exercise's output has its trailing spaces dropped** in the capture (Found on the way); `exercise/README.md` shows the lines as
   a terminal shows them.
9. **The dish-name refusal (R.215) and the duration gate (R.172) are in this receipt**, as unit 07's.
10. **This README's run paragraphs were written after the runs they report** (the bash runs' before the sealed clone, the sealed
    clone's last); `dur7.DUR`, the dish list and the two `mine()` lines were checked by hand on the final text (0, 0, each line once).
    A first start of the runs of record was stopped before this README was finished, and stands void.

## Planted faults — each caught (R.65)

On copies (each a scratch mirror of the repository: `c7-unit07/after`, `c7-unit07/README.md` and `receipts.md5`, `c7-tiffinbox`, this
folder with `.m2-demo` cloned; `receipts.md5` kept unless the plant says), `./receipts.sh` (/bin/bash 3.2, `env -i`, a session of its
own), the script as committed — each **exit 1**, nothing written to this folder, 0 listeners on 19870-19879:
- **`@AttributeOverride` removed from the solution** (`SOLUTION.md`'s `sed` made `s/…office;$/    private Address office;/`, still one
  line changed; `exercise` out of `receipts.md5`) → `*** exercise: the solution - one row, eight columns: expected the line:     exit 0 ***`
  (78 s) — the solution's block printed the `MappingException`, as the README's did.
- **The "new" read made in the same EntityManager** (`Main.nulls`: `var em2 = em;` in place of `em.close()` and a new EntityManager;
  `nulls`, `record` out) → `*** nulls: expected the line:   PROBE read in a new EntityManager - find by id: [Ravi=Address[…], Meera=null,
  Sunil=null] | the objects persisted: no ***` (38 s) — read there, Sunil is the empty `Address` he was given.
- **A wrong published hash** (`receipts.md5`'s `ddl` with its last digit changed) → `*** ddl is not the published capture … ***` (33 s).
- **A version claim without its `HHH000001` line** (`harness/logback.xml` without the `org.hibernate.orm.core` logger; every capture
  out) → `*** ddl: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its 1 harness JVMs (R.222) ***` (33 s).
- **`xcheck` against a wrong 07 md5** (`X07=…204ec`) → `*** ../c7-unit07/README.md no longer states Boot's script md5 …204ec - the number
  this unit compares with ***` (21 s); and with unit 07's README in the mirror changed to the same wrong number (`xcheck` out) →
  `*** xcheck: the harness's script is Boot's as the enums lesson captured it (…204ec): expected the line:   md5 of
  .harness/run/xcheck.sql: …204ec ***` (53 s) — the capture's own check.
- **An Indian dish name** (one README line appended: a plate of a dish whose name is on the list) → `*** an Indian dish name (R.215:
  English names only): README.md:…: … ***` (1 s), before anything is built.
- **One per capture class beside them:** `ddl` — `@Column(name = "address_city")` on `Address.city` (a prefix) → `*** ddl: the three
  columns in addr_customer: expected the line: … ***` (26 s); `record` — `RecAddress`'s `@Column(length = 6)` dropped → `*** record:
  RecCustomer's DDL is AddrCustomer's, byte for byte, but for the table's name ***` (47 s); `two` — B given the three overrides →
  `*** two B: the trio - exit 1, the MappingException, no EntityManagerFactory, 0 SQL: expected the line: … ***` (56 s); `overrides` —
  the office persisted as a copy of the home → `*** overrides: expected the line:   PROBE two_over_customer's rows, … Kolkata | 4 Park
  Street] ***` (59 s).

## Found on the way

- **Hibernate's `PersistenceException` message ends in a space** (`… [persistence unit: u08ex] `): the harness log view drops trailing
  spaces, the exercise's raw output did not, and the first development run stopped at `exercise`'s check. The exercise's output is now
  shown with trailing spaces dropped, declared in the capture's own words.
- **The same EntityManager answers `find` from its persistence context** after the commit: 0 SQL, the very objects persisted — so an
  all-null embedded value is "null" only to a read that goes to the table.
- **A record's columns are inserted in its component order** (`line1,city,pincode`), a class's in the field names' alphabetical order
  (`city,line1,pincode`); the DDL is the same for both.
- **An `@AttributeOverride` column replaces the whole `@Column`**: the field's `length = 6` does not carry over (What differed, 5).
- `org.hibernate.orm.core` at INFO prints, besides `HHH000001`, `HHH000489` (no JTA platform) on every factory that builds — none
  that fails (B prints `HHH000001` only).

## CARRIED

- **"Both databases write the same DDL here"** — the probe's diff (H2 vs PostgreSQL, empty for every 08 beat); this unit ran H2 only
  and its voice speaks for H2 only (⚑2, R.217). A Postgres run of these captures is nobody's yet; not needed for any claim.
- **Hibernate 5's `create_empty_composites`** (the empty-object-on-read setting) — not measured; the voice never names it as a setting.
- **The builder (s708)** must refuse the dish-name list in SAY lines and on slides (R.215), assert `duration words: 0` (R.172), say
  "on H2", say the same-EntityManager read only as the persistence context's (no SQL), and quote Hibernate's hint as Hibernate's, with
  the override as the fix.
- 10-14's `xcheck` compare with unit 09's number (R.212), not this unit's.

## For RED

Re-run from a clean tree (seeded `.m2-demo`, `HOME` with dead proxies) in a process group of its own; ports 20200-20279 for any
re-run of this unit's JVMs outside its script (none needs one). Worth breaking: whether "comes back as null" could be the same
EntityManager's (the capture prints both reads and `==`; the check asserts the new one's `Sunil=null` and the same one's empty
`Address`); whether the `two` refusal is before any SQL (0 `org.hibernate.SQL` lines, no script file — the check counts both); whether
`xcheck`'s md5 is really unit 07's (the script reads it from unit 07's README and `receipts.md5`, and the plant with a wrong one fails);
whether `record`'s "byte-identical" hides a column difference (the check compares the whole line after the table's name). Evidence by a
Claude Opus 5.5 agent on 2026-11-04.

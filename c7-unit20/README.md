# c7-unit20 — Paging and Sorting

Course 7 · Data with JPA & Hibernate · Section 3 (Querying), its sixth unit, and **the third on Section 3's frozen anchor — no change
to the anchor** (brief ⚑11): `anchor` is the link to `../c7-unit17/after`. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.2** (Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the anchor's pin), and
**PostgreSQL 18.6** (`postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873`, PostgreSQL JDBC 42.7.14),
2026-11-08 — **on H2 and on PostgreSQL** (brief ⚑2: 20 is Section 3's one Postgres unit; every capture's own lines name the database
each JVM ran on). A page is a query and a count; a slice is a query and one extra row. OFFSET pages are easy and get slower the deeper
you go, because the database still walks every row it skips. A keyset page remembers where it stopped and asks for what comes after.
Measured: `Page` and `Slice` side by side; `Sort` with two keys, a misspelt property, and a sort across the join (where H2 and
PostgreSQL put the customers without a pause at opposite ends); the count Spring Data derives for a join (one customer counted twice,
then `select distinct`); `Window`, `ScrollPosition.keyset()` and `WindowIterator`; a labelled trap of Spring Data JPA 4.1.2's scroll
methods; and OFFSET against keyset over the load's rows on both databases — the ratios on this Mac, the depth series, and
PostgreSQL's plans, actual rows only.

**No anchor change (brief ⚑11).** `anchor` → `../c7-unit17/after` (`readlink` asserted), Section 3's frozen anchor. `receipts.sh` prints
`diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record —
and, from any later anchor change on, prints a note instead (R.211). The anchor is copied under `.harness/anchor` and built there with
its README's package line (offline; its 18 tests run inside that build), its jar extracted with the anchor's own line; the harness runs
over those 91 libraries (and, for PostgreSQL, the driver jar from `.m2-demo`) and maps the jar's own entities. TiffinBox itself is not
started by this unit.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 8 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5`. **Start it in a process group of its own** (a
terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be seeded first (below). **Docker
must run, and the image must be on the machine** (`docker image inspect` of the digest; the script never pulls): the script starts its
own container, `c7u20-pg`, on `127.0.0.1:19998`, and removes it at its end and on every other exit — a failed check, Ctrl-C. It refuses
to start when a container of that name exists or something listens on 19998, and it never removes a container it did not create.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files, an APFS clone of the folder). A development run (a scratch copy of this script, `.r-dev.sh`, git-ignored, whose table, plan,
values and exercise-block gates and the published-hash stop print instead of stopping) wrote every capture 3/3, and those md5s are
`receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `c482a2e65c7e6bbdc2065683583e85a8`): 340 s under
`./receipts.sh`** (/bin/bash 3.2.57, 2026-11-08 from 07:42:22 CET), **344 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from 07:48:02
CET) **and 381 s from a sealed fresh clone in a path with a space** (below, from 07:53:46 CET): each exit 0, all 8 captures 3/3 =
published, every check passed, the build `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty at the
start and the end, the container removed and nothing listening on 18425, 8080, 35729 or 19990-19999 at the end; each terminal log
through `check_unit7.py 20 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS` (the unit gate itself answers "no 20-*.md …
nothing to check": no script yet). **Nothing was downloaded**; the only connections were the loopback JDBC and `docker exec` to this
script's own container. Each run of record started 3 × 6 = 18 timing JVMs and 9 fresh PostgreSQL databases for `time`, 3 more for
`sort`.


Published hashes: page `bafa49ffacc7ba12e2904dc2c11dbb00` · sort `5ff6664f0c8df73e29b891b28c9ed24e` · count `72bf5523c501fe3b0e85ae543dfb6f57` · keyset `ea46fea5b67b78ea8f22d8a96c367b94` · trap `cc2e413184118604fdf7f814fedfbb88` · time `d6a6c3b5f2c6279caaf82099fa1bfa21` · xcheck `a75c0b634e52dfe122cb7c9a05525d39` · exercise `271036189d818e9886b4fe060d51ba80`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string or
a row count typed anywhere else is refused):

the values the video may say: a Page - 6 customers, 3 pages, 2 statements: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.meal_type=? order by ce1_0.name fetch first ? rows only, then select count(ce1_0.id) from customer ce1_0 where ce1_0.meal_type=? · page 1: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.meal_type=? order by ce1_0.name offset ? rows fetch first ? rows only · a Slice - 1 statement, 3 entity loads for a page of 2, hasNext · page 0 not full: 1 statement · sort: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 order by ce1_0.meals_per_day desc,ce1_0.name · Sort.by("nmae"): org.springframework.data.core.PropertyReferenceException: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name' · Sort.by("pauses.days"): select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 left join pause p1_0 on ce1_0.id=p1_0.customer_id order by p1_0.days - NULLs first on H2, last on PostgreSQL · count B: Page 0 of 2 · total 3 · content [Priya, Sunil] (select count(ce1_0.id) from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>=?) · at size 10: Page 0 of 1 · total 2 · content [Priya, Sunil] · A: Page 0 of 1 · total 2 · content [Priya, Sunil] (select count(distinct ce1_0.id) from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>=?) · keyset: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.meal_type=? order by ce1_0.name,ce1_0.id fetch first ? rows only · positionAt(1): KeysetScrollPosition [FORWARD, {id=6, name=Dev}] · next: (ce1_0.name>? or ce1_0.name=? and ce1_0.id>?) · three windows walk 6 · the iterator: the cap 10 · elements 6 · the iterator has more: false · [Asha, Dev, Nina, Omar, Ravi, Sunil] · the trap (Spring Data JPA 4.1.2): offset() then keyset() on one method - Window size 2 · hasNext true · content [Asha, Dev] again, the cap 10 · elements 10 · the iterator has more: true · [Asha, Dev, Asha, Dev, Asha, Dev, Asha, Dev, Asha, Dev] · time: 1000004 rows; offset last/first >= 10, offset-last/keyset-last >= 10, keyset last/first <= 2 - on H2 and PostgreSQL, every JVM · the deeper you go: the depth medians increase · PostgreSQL actual rows (first page, offset last, keyset last, depth): 20.00 1000000.00 21.00 250000.00 500000.00 750000.00 · H2 scanCount: 20 1000000 22 250000 500000 750000 · xcheck: f595637014e786fa38606859951e4f97 · exercise: total 3, then 2 (22 words)

## The timing — its design, and what the video may say about time (R.172, R.207, ⚑5)

**20 is the one unit of Section 3 that speaks time**, and only as ratios measured on this Mac, never as a figure. The design is fixed
in `receipts.sh` and in the harness (`Run.time()`), and the table below is composed by `receipts.sh` from `time`'s own lines and
compared with this README, row by row (a row typed here that the capture does not give stops the run):

<!-- time: the design table, composed from the capture (receipts.sh compares it, row by row) -->
| what | measured |
|---|---|
| rows (select count(*)) | 1000004 - 1000000 generated by one JDBC batch per JVM, and the shipped seed's 4 |
| page size | 20 - the last full page 49999 |
| rounds | W 10 warm-up, R 9 timed - the median of the 9 per call |
| per round (r = round % 7) | offset pages r and 49999-r; keyset after id 20r and after id 999980-20r; depth pages 12499-r, 24999-r, 37499-r; the order of the 7 calls rotates each round |
| content checks | 133 calls per JVM, each 20 rows with its first and last id as computed from the counted rows |
| JVMs | 3 on H2 (each its own database in its memory) + 3 on PostgreSQL 18.6 (a fresh database each, ANALYZE customer) per capture run; 3 capture runs |
| thresholds (hashed) | offset last/first >= 10 · offset-last/keyset-last >= 10 · keyset last/first <= 2, in every JVM |

The two OFFSET calls are `List<CustomerEntity> findAllBy(Pageable)` sorted by `id` (a `List`, so no count runs); the two keyset calls
are `Window<CustomerEntity> findFirst20ByOrderByIdAsc(ScrollPosition)` — **its own method**, which no offset position ever reaches
(⚑10): `ScrollPosition.keyset()` for the first page, `ScrollPosition.forward(Map.of("id", …))` for every other. Each call's 20 rows and
their first and last id are checked against the ids computed from the counted rows, every call of every round (RED #906: a poisoned
keyset method passes every row count and every ratio, and only this check sees it); the first round runs once more with Hibernate's SQL
logger and its bind logger on, each call between its own markers, so the keyset-last line is seen carrying its predicate and every plan
below explains a SELECT the logger printed, with the values Hibernate bound. The medians of the 9 timed rounds give three ratios per
JVM, compared with thresholds fixed by BLUE over 22 JVMs per database (lowest PostgreSQL offset ratios 26.87 and 26.50, highest keyset
ratio 1.02 — margins 2.69× / 2.65× / 1.96×; the brief's AMENDMENT, `U20 time (#906)` and #907): **`offset last/first >= 10`**,
**`offset-last/keyset-last >= 10`**, **`keyset last/first <= 2`**. The three threshold lines are what the capture hashes, one per JVM
(six JVMs, both databases); the medians, the ratios and the margins print to the terminal on every run, outside the hash — the
figures below are this unit's runs of record.

**Duration words this unit speaks** (dur7.DUR's matches, each one of these three, any case; every other duration word is refused): slow · slower · faster

dur7 over this README and the exercise's two files (`harness/dur7.py`, the builders' byte for byte): `duration words: 14 (faster 4, slow 4, slower 6) · outside the list: 0` over this README as committed (the runs of record, on an earlier draft of its prose, counted 11; the count includes the list line itself) — recorded, not 0
(R.172 as the setup brief's ⚑5 allows for 20). **How each word rests on the capture** (asserted after `time`, every JVM, both
databases): "slow" and "slower" — OFFSET's last page against its first, `offset last/first >= 10: true` (the voice: *at least ten times
slower*); "faster" — keyset's last page against OFFSET's last, `offset-last/keyset-last >= 10: true`; *no more than twice* (no dur7 word)
— keyset's last page against its first, `keyset last/first <= 2: true`. A dur7 word outside the three stops the run before any build.

**The ratios of the runs of record** (medians of R 9 per call, printed by every timing JVM; never hashed):

```
run 1 H2 JVM 1: offset last/first 53.19 · offset-last/keyset-last 62.55 · keyset last/first 0.65
run 1 H2 JVM 2: offset last/first 53.74 · offset-last/keyset-last 57.54 · keyset last/first 0.74
run 1 H2 JVM 3: offset last/first 50.53 · offset-last/keyset-last 56.57 · keyset last/first 0.63
run 1 PostgreSQL JVM 1: offset last/first 37.35 · offset-last/keyset-last 38.84 · keyset last/first 0.72
run 1 PostgreSQL JVM 2: offset last/first 39.73 · offset-last/keyset-last 35.24 · keyset last/first 0.81
run 1 PostgreSQL JVM 3: offset last/first 38.03 · offset-last/keyset-last 31.47 · keyset last/first 0.86
```

That is capture run 1 of the first run of record (`./receipts.sh`, bash 3.2.57); over its 18 timing JVMs (3 capture runs × 6) the
ranges were — **H2**: offset last/first 47.49-57.57 · offset-last/keyset-last 52.50-66.97 · keyset last/first 0.56-0.74; **PostgreSQL**:
offset last/first 35.65-39.73 · offset-last/keyset-last 27.88-38.84 · keyset last/first 0.72-0.95. The second (bash 5.3.9, 18 JVMs): H2 50.47-63.00 · 40.25-73.98 · 0.64-0.92; PostgreSQL 36.64-43.11 · 30.67-35.94 · 0.78-0.92. Every one of these 36 JVMs is above its OFFSET thresholds by at least 2.78× and under its keyset bound by at least 2.10×; the lowest, PostgreSQL offset-last/keyset-last 27.88, is above BLUE's low of 26.50.

### The depth series — "the deeper you go" (S3.18)

Every timing JVM also times three OFFSET pages between the first and the last — pages ¼, ½ and ¾ of the way, rotated with the rest —
and asserts the five medians (page 0, ¼, ½, ¾, last) strictly increase: `depth: … strictly increase - the deeper you go: true`, in each
of the six JVMs (the line is hashed). The spine's "the deeper you go" rests on that line; dropped, the trend phrase has nothing under it
and the run stops.

### The plans — PostgreSQL's actual rows, H2's scanCount (S3.14, R.214, R.227)

After its timing, each PostgreSQL JVM runs `explain (analyze, timing off, summary off, costs off, buffers off)` on six SELECTs **as the
SQL logger printed them in round 0, with the values Hibernate bound** (each header line's SQL and bound values are asserted equal to
that call's logged line and its bind lines): the first page, the last page by OFFSET, the last by keyset, and the three depth pages.
The plan text is equal in the three fresh databases (RE-MEASURE 7). The three a slide may show, as captured (composed by `receipts.sh`
and compared with this block):

<!-- time: the plans, composed from the capture (receipts.sh compares it) -->
```
PROBE plan (PostgreSQL) first page (offset-first, round 0): explain (analyze, timing off, summary off, costs off, buffers off) select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 order by ce1_0.id fetch first ? rows only · bound [20]
PROBE   | Limit (actual rows=20.00 loops=1)
PROBE   |   ->  Index Scan using customer_pkey on customer ce1_0 (actual rows=20.00 loops=1)
PROBE   |         Index Searches: 1
PROBE plan (PostgreSQL) offset last (page 49999): explain (analyze, timing off, summary off, costs off, buffers off) select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 order by ce1_0.id offset ? rows fetch first ? rows only · bound [999980, 20]
PROBE   | Limit (actual rows=20.00 loops=1)
PROBE   |   ->  Index Scan using customer_pkey on customer ce1_0 (actual rows=1000000.00 loops=1)
PROBE   |         Index Searches: 1
PROBE plan (PostgreSQL) keyset last (after id 999980): explain (analyze, timing off, summary off, costs off, buffers off) select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.id>? order by ce1_0.id fetch first ? rows only · bound [999980, 21]
PROBE   | Limit (actual rows=21.00 loops=1)
PROBE   |   ->  Index Scan using customer_pkey on customer ce1_0 (actual rows=21.00 loops=1)
PROBE   |         Index Cond: (id > '999980'::bigint)
PROBE   |         Index Searches: 1
```

OFFSET's last page reads every row up to it and returns 20; keyset's reads 21 (the 20, and one more that tells `Window.hasNext()`),
through the same index, from the id it was given. Each H2 JVM runs `EXPLAIN ANALYZE` on the same six SELECTs and prints only its
`scanCount`, labelled H2 — never as PostgreSQL's (a plan line labelled with the other database stops the run): `scanCount` 20 (first page) · 1000000 (offset last) · 22 (keyset last) · 250000 / 500000 / 750000 (depth), the same in its three JVMs.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 19's recipe, with this unit's folder (Docker runs on the host; the image must be there):

```bash
S=/tmp/sealed20; W="/tmp/sealed 20"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X"
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$W/tiffinbox-java/c7-unit20" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E DOCKER_HOST="unix://$HOME/.orbstack/run/docker.sock" ./receipts.sh            # a process group of its own; the docker CLI's socket named, its HOME is the sealed one
```

**Run (2026-11-08, from 07:53:46 CET):** a `git clone` of tiffinbox-java at `0553f54` into a path **with a space** (`…/sealed
20/tiffinbox-java`, in the session's scratch folder), this commit's change put in as git takes it (every path `git ls-files -o
--exclude-standard` listed under `c7-unit20/` `cmp`-equal to the working tree, `anchor` → `../c7-unit17/after` by `readlink`); a
`file://` copy of the s3 seed (5,023 files once `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left out);
pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash`
3.2, `env -i` with the dead proxies and `DOCKER_HOST` naming the host's OrbStack socket (the sealed `HOME` has no docker context), a
session of its own: **exit 0 in 381 s, all 8 = published, every check passed**; the build `offline: yes · exit 0 · 'Downloaded from'
lines in its log: 0`; after the run `.m2-demo` held 5,023 files, 0 `_remote.repositories`. Its terminal log through `--runlog`: PASS.
(The clone's README was this file before its last prose was filled in.)

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java harness/src/probe/q/repo/Customers.java harness/src/probe/x/XMain.java
perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
perl -e 'alarm 300; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" probe.q.Main "${A[@]}"
perl -e 'alarm 300; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" probe.q.Main "${A[@]}"
perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
docker run -d --pull never --name c7u20-pg -p 127.0.0.1:19998:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker exec c7u20-pg pg_isready -U sa -h 127.0.0.1 -q
docker exec c7u20-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
```

**The harness line** compiles the harness against the anchor's libraries with `-parameters` (the `@Param` names are read at run time).
**The java lines** run the harness and xcheck's context from `.harness/run` — `V` the JVM flags (the scenario `-Ds=page|sort|count|keyset|
trap|time`, the variant `-Dv=A|B`, and for PostgreSQL `-Dpg.db=<database> -Dpg.pwfile=../secrets/pgpw`), `A` the arguments (R.193),
each printed as `$ V=(…)` / `$ A=(…)`. Every harness JVM runs under `perl -e 'alarm 120; exec @ARGV'`, a timing JVM under `alarm 300`
(R.247: macOS has no `timeout`; an alarm that fires ends the JVM with exit 142, which the runner refuses; the probe's PostgreSQL timing
JVMs ended in about 14 s each, this unit's in about 11 — the alarm leaves a margin of twenty times); the exercise's JVM under its own
alarm. **The docker lines** start the container (`--pull never`, `127.0.0.1:19998` only, user `sa`, the password read by the image's
entrypoint from the file `POSTGRES_PASSWORD_FILE` names, a bind mount of `.harness/secrets/pgpw` — never on a command line), wait for
`pg_isready` (capped at 120 tries), and give each PostgreSQL JVM a fresh database (`drop database if exists … with (force)`, `create
database …`, printed in the capture with its database's name). The lines read from `anchor/README.md` (2, each asserted whole) are its
package line, `mvn -B package`, and its extract line.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files, an APFS clone of the folder; it holds
`org/postgresql/postgresql/42.7.14`). One build: the anchor's `package` (its 18 tests run); `offline: yes` with 0 `Downloaded from` lines
in every run of record (the label is derived from the build log, never typed). After it the script asserts `.m2-demo` holds
`spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar`, `spring-data-jpa-4.1.2.jar`, `h2-2.5.250.jar` and
`postgresql-42.7.14.jar`. **At run time** no JVM binds a port; H2 is in each JVM's memory (`jdbc:h2:mem:u20`, the timing JVMs'
`u20t1`-`u20t3`, xcheck's `x20`, the exercise's `ex`); the one network act is the loopback JDBC (and `docker exec`) to this script's own
container. **No other network act**: the section's dated sweep is the brief's (`../../../data-jpa-hibernate/_research/spring-boot-
metadata-2026-11-07.xml`, md5 `2ccae19d…`: the 4.1 line ends 4.1.2; `4.2.0-RC2` not GA — ⚑6, R.223). Spring Data JPA's version is
printed by every harness JVM from its jar's manifest (`4.1.2`), beside Hibernate's `HHH000001` line and `Version.getVersionString()`
(S3.15, R.246), before the context starts — asserted once per harness JVM in every capture; PostgreSQL's version (`select version()`,
cut before its " on " — `PostgreSQL 18.6`) in every PostgreSQL JVM's database line.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness, the container and the ports

- `anchor` → `../c7-unit17/after` (a link; `readlink` asserted) — Section 3's frozen anchor, never built in place.
- `harness/` — `src/probe/q/Main.java` (unit 19's, plus the PostgreSQL URL: with `-Dpg.db` it builds
  `jdbc:postgresql://127.0.0.1:19998/<db>` with the user and the password from the file `-Dpg.pwfile` names, as Boot's lowest-priority
  default property — the password on no command line; every URL the harness prints is cut before its `?`), `src/probe/q/Seed.java`
  (unit 19's, byte for byte), `src/probe/q/repo/Customers.java` (`Page findByMealType(MealType, Pageable)`, its `Slice` twin
  `findSliceByMealType`, `pausedSince` — `@Query("select c from CustomerEntity c join c.pauses p where p.days >= :d")` — and its
  `select distinct c` twin `pausedSinceDistinct`, `Window findFirst2ByMealTypeOrderByNameAsc(MealType, ScrollPosition)` (keyset only),
  its offset twin `queryFirst2ByMealTypeOrderByNameAsc` and the iterator's `readFirst2ByMealTypeOrderByNameAsc` (⚑10: one method per
  position kind), `List findAllBy(Pageable)` and `Window findFirst20ByOrderByIdAsc(ScrollPosition)` for the timing),
  `src/probe/q/Run.java` (one scenario per JVM; each call between `PROBE >>> label` and `PROBE <<< label · statements
  (getPrepareStatementCount) … · entity loads … · queries …`; the four more customers saved through the repository — Asha, Dev, Nina,
  Omar, English names, R.215; the counts read back by a second connection; the loader — `Customer 0000001` … by one JDBC batch, its
  count read back by `select count(*)`, `ANALYZE customer` on PostgreSQL; every loop capped and its cap printed, S3.16),
  `src/probe/x/XMain.java` (unit 19's, byte for byte), `src/probe/q/ex/ExApp.java` (the exercise's — compiled only by the exercise),
  `logback.xml` (unit 19's, its comment changed), `dur7.py` (the builders', byte for byte, md5 `41667fed…`).
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `anchor`, `hc`, `run`, `ex`, the logs, and `secrets/pgpw` — the generated password
  (24 characters, a fresh one every run, mode 644 inside a 700 folder so the container's `postgres` user can read its bind mount; never
  printed, never committed: `.harness/` and `**/secrets/` are in the root `.gitignore`). `.r-NAME.1-3` while a capture runs;
  `.r-NAME.out` its result (git-ignored).
- **The container (R.214):** `c7u20-pg`, from the pinned digest (`--pull never`), `-p 127.0.0.1:19998:5432` (its port map asserted:
  `5432/tcp 127.0.0.1:19998` alone), started after the build — so an interrupted build leaves none — and removed with `docker rm -f` at
  the end and from the `EXIT` trap (set before `docker run`). After each PostgreSQL JVM its log is masked (`<pw>`) and its raw copies of
  the password counted: `raw password copies in its log after the mask: 0`, in the capture, asserted.
- **Ports (§P, 19990-19999):** 19998 is the container's; no JVM binds a port. 19990-19997, 19999, 18425 (TiffinBox's default), 8080 and
  35729 are checked free at the start and the end; 19998 free at the start and again once the container is removed; 19999 never bound.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): this folder → `…`, the folder above → `…/..`, home → `~`,
the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; Spring Data's scan line's figure → `<n>`; H2's generated
`CONSTRAINT_<n>`, `CONSTRAINT_INDEX_<n>`; **every figure on a timing line (the harness prints its medians, ratios and margins on lines of their own) → `<n>`** (the timing's medians, ratios, margins and depth
medians: the line stays in the capture, its figures do not — they print whole to the terminal, R.207); the PostgreSQL password → `<pw>`
(after each PostgreSQL JVM). `xcheck` prints Hibernate's generated foreign-key name as `FK<name>`. A harness JVM's log is printed whole.
Hygiene, over every capture: no password, no `password=` or `user=sa&`, no absolute path, unit number, log time, timestamp, thread number,
JDK or OS token (PostgreSQL's `select version()` is cut before its build triple), figure of elapsed time, unmasked timing figure,
stack frame, URL; every JVM pinned and under its alarm; no kill by name, no bare `wait`, no one-string multi-option variable; no H2
database file (R.195); no dish name (R.215). The prose gates, before any build: dur7's words outside 20's three; a dish name; a
placeholder or an empty "What it prints" block; the 3.x property-exception name (S3.10); a row count spelt out in words or typed (S3.12); a plan
with a cost, a time, a width or a planning or execution line (S3.14); a SQL string outside the values line, the plan block and the
exercise's measured blocks (R.225).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven or the
`javac` it waits for (`$mpid`, with every process under it), the exercise's shell (`$xpid`), sweeps its own process group for any harness
or exercise JVM, `javac`, Maven or `docker exec` left, **removes the container if it created it** (`docker rm -f c7u20-pg`), deletes the
capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured (2026-11-08, from 08:00:07 CET, the sealed clone, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a
session of its own **with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group one
second after the named process appeared in it, the state read 5 s later — three trials, each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 3 · container up at SIGINT: no · exit 130 · 5 s later in the group: 0 · container: none · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 1 · container up at SIGINT: no · exit 130 · 5 s later in the group: 0 · container: none · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
timing: processes in the group at SIGINT 3 · container up at SIGINT: c7u20-pg · exit 130 · 5 s later in the group: 0 · container: none · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the Maven (the anchor's package); `harness` — the trial's pattern (`probe.q.Main`) first matched the `javac` line (its source
path), so the SIGINT landed one second later, **while `docker run` was creating the container** — the case that found the defect below;
`timing` — the first PostgreSQL timing JVM (`-Dpg.db=u20t1`, a harness JVM loading or timing, the container up). `pgrep -x java`
afterwards: none. **The defect the trials found (fixed before the runs of record):** the first `harness` trial, on an earlier script,
left a container in the state `Created` — the Ctrl-C cut the `docker` client while the daemon was still creating it, and the trap's one
`docker rm -f` came first. `pgrm` now repeats `docker rm -f` until `docker ps -a` names the container no more (at least three tries,
0.5 apart, at most 20); the three trials above ran on the fixed script, and so did every run of record.

## 1 · page — Page vs Slice (H2; S3.11)

One harness JVM. Four more vegetarian customers saved through the repository (Asha, Dev, Nina, Omar: six VEG in all). `findByMealType(VEG,
PageRequest.of(0, 2, Sort.by("name")))` → a `Page`: **2 statements** — its SELECT, then the count Spring Data derives — by the SQL log and
by `getPrepareStatementCount()` both (R.184), `Page 0 of 3 · total 6 · content [Asha, Dev]`; page 0's SELECT has no offset clause,
page 1's ends `offset ? rows fetch first ? rows only` and runs the count again. `findSliceByMealType` with the same request → a `Slice`:
**1 statement, no count**, and **3 entity loads for a page of 2** — the one more row it reads to know `hasNext` (true; the last slice,
page 2, false). And no count when page 0 is not full: the VEGAN page of ten (Priya alone) — 1 statement, `total 1`.

## 2 · sort — two keys, a misspelt property, a sort across the join (H2 and PostgreSQL; S3.7, S3.9, S3.10)

One JVM per database (PostgreSQL: a fresh database), the shipped seed. **The same three SQL texts on both** (asserted byte for byte).
`Sort.by(DESC, "mealsPerDay").and(Sort.by("name"))` → the meals per day descending, then the name (unique: it breaks the tie between
Meera and Priya). `Sort.by("nmae")` → **at the call, 0 statements**: `org.springframework.data.core.PropertyReferenceException: No
property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'` (class with its package, message, no cause — S3.10; the JVM ends
exit 0: a call failure, not a start failure, S3.9). `Sort.by("pauses.days")` → a left join on the pause table, ordered by its days:
**the customers without a pause (Ravi and Meera, `null`) first on H2, last on PostgreSQL**. Ravi and Meera tie, so the capture prints
each row's ordering key alone — `[null, null, 2, 3]` on H2, `[2, 3, null, null]` on PostgreSQL — never the names among the ties (S3.7).

## 3 · count — the join's count (the failure receipt; S3.11)

Three JVMs on H2 — **B, A, A′** — each giving Sunil a second pause (four days) by a second connection, which then counts **2
customers** with a pause of at least two days (`count(distinct customer_id)`) and **3 pauses** (`count(*)`). **B** — `pausedSince(2,
…)`, the join without `distinct`, at `PageRequest.of(0, 2, Sort.by(DESC, "id"))`: the content is Priya and Sunil — Hibernate hands back
each customer once — but the page is full, so Spring Data runs its count, derived from the query: the join's rows, **`total 3`**, `Page
0 of 2`, 2 statements. At a page of ten the page is not full, no count runs, and the total is 2 — the broken state says what the solved
one says (RED #918; so the exercise names its page of two, with its reason). **A** and **A′** — `select distinct c` → Spring Data
derives `count(distinct …)` of the id → **`total 2`**, one page, 2 statements; A′ prints what A printed. B also shows the brief's
`Sort.by("id")` (ascending): Sunil's two rows fill page 0, the page holds one customer, is not full, runs no count, and says `total 1` —
Priya is on no page at all (below, "What differed" 2).

## 4 · keyset — Window, ScrollPosition, WindowIterator (H2; S3.4, S3.16, ⚑10)

One JVM, the six VEG customers. `findFirst2ByMealTypeOrderByNameAsc(VEG, ScrollPosition.keyset())` → the order by gains the id after the
name (a unique tie-breaker); window 1 `[Asha, Dev]`, `hasNext true`, and `window.positionAt(1)` = `KeysetScrollPosition [FORWARD,
{id=6, name=Dev}]` as printed; windows 2 and 3 ask for what comes after, the predicate on the name and the id (S3.4, asserted on each
line); **three windows walk six**, window 3 `hasNext false`. An offset scroll (`ScrollPosition.offset()`) on its own method,
`queryFirst2ByMealTypeOrderByNameAsc` — the order by the name alone (⚑10: no keyset method in this JVM ever sees an offset position).
`WindowIterator.of(…).startingAt(ScrollPosition.keyset())` over a third method, `readFirst2ByMealTypeOrderByNameAsc`, read under a cap
of 10 elements (printed): 6 elements, three windows, then it ends by itself.

## 5 · trap — a scroll method's offset query, reused (labelled: measured on Spring Data JPA 4.1.2; ⚑10, RED #908)

Three JVMs on H2, each printing `a trap measured on Spring Data JPA 4.1.2` (the version from the jar's manifest, S3.15). **A** and
**A′** — `keyset()` on `findFirst2ByMealTypeOrderByNameAsc`, a method nothing else has called: keyset's own SQL (`keyset`'s window 1),
and the iterator over it ends by itself (6 elements under the cap of 10). **B** — `offset()` first, then `keyset()` on the same method:
**the offset SQL twice** (no id in the order by), the first window again, and the iterator — which takes each window's last position —
asks for the first window over and over: `[Asha, Dev, Asha, Dev, …]`, 10 elements, stopped by its cap alone (`the iterator has more:
true`). Said as SQL lines on one version (R.201: "built once and reused" is not captured). Without the cap the loop never ends; with
the cap removed, the JVM's alarm ends it and the receipt fails (S3.16, the plant below).

## 6 · time — OFFSET against keyset, with the depth series and the plans (H2 and PostgreSQL; ⚑5, S3.4, S3.5, S3.12, S3.14, S3.18)

Six JVMs per capture run — three on H2 (each its own database in its memory), three on PostgreSQL (a fresh database each) — in the
design above. Per JVM, asserted: the rows counted (`select count(*)`, never typed — S3.12) are the generated and the seed's four; the
design line; each round-0 call 20 rows with its first and last id as computed; the keyset-last SQL line carries its predicate on the id
(predicate lines 1 of 1); 133 content-checked calls; the three threshold lines and the depth line `true`; six plans labelled with their
own database, each explaining its round-0 SELECT with its bound values; PostgreSQL's plan text equal over the three fresh databases;
H2's scanCounts equal over its three.

## 7 · xcheck — the harness's DDL script, against the owning-side lesson's (R.212, RE-MEASURE 3)

`probe.x.XMain` — the anchor's entities alone (`Found 0 JPA repository interfaces.`, no seed), `scripts.action=create` into a file
never run: two `create table` lines and one `alter table`, md5 **`f595637014e786fa38606859951e4f97`** = unit 09's published script md5
(its README names it; its `xcheck` capture `9072c6f1…`, asserted) — no mapping moved.

## 8 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `SOLUTION.md`'s, read from the files, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then the
same in `/bin/zsh -f`: the README's app (`ExApp`, `probe.q.ex`, the shipped `Database` on its own H2, Sunil's second pause, a repository
of its own with the join without `distinct`, a runner asking for a page of two) → `exit 0`, count B's count line, **`total 3`**; the
solution (one source line: `select distinct c`) → `exit 0`, count A's count line, **`total 2`** (= the second connection's 2). Both exit
0: broken ≠ solved is read off the total and the count's SQL, never the exit code. Bash and zsh print the same; the shell ends in this
folder. **Each exercise file's "What it prints" block is compared with what the run printed, line for line.**

## Exercise

**Your turn:** the README pages customers who took a pause, and the page counts one customer twice. Make the count count customers.
(22 words, `wc -w`, R.203 — the brief's line, unchanged.) `exercise/README.md` and `exercise/SOLUTION.md`.

## The ledger rows and hand-offs this unit pays

- **Section 3 owns no ledger row** (`PROMISE-LEDGER-2026-11-01.md`); this unit settles none and opens none.
- **The call-backs Course 8 and 9 make, by API name, as measured on Spring Data JPA 4.1.2:** `Page`, `Slice`, `PageRequest.of(page,
  size, sort)`, `Sort.by`, `Window<T>`, `ScrollPosition.keyset()`, `ScrollPosition.forward(Map)`, `Window.positionAt(int)`,
  `Window.hasNext()`, `WindowIterator.of(…).startingAt(…)`, `KeysetScrollPosition` — each called in `page`, `keyset` or `time`.
- Hand-offs by title: *Query By Example and Querydsl* (21).

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: the join without `distinct` → `total 3` / `select distinct c` → `total 2`, each `exit 0`; each file's "What it prints" = the run |
| 3 | xcheck for 20: the harness's script with `@EntityScan("com.tiffinbox")` alone = `f5956370…` (unit 09's), on the frozen anchor |
| 6 | U20's design inside a receipt: three JVMs per database per capture run, the rotation, every call's content checked, the thresholds, the depth series — 3/3 |
| 7 | PostgreSQL's plan text equal over three fresh databases — asserted in every capture run (nine fresh databases per receipt) |
| 8 | the scroll reuse on PostgreSQL — **not settled**: `trap` runs on H2 only (below, "What differed" 6) |

## What differed from the brief

1. **`depth` and `plans` are not captures of their own: they run inside `time`'s six JVMs.** Every timing JVM times the three depth
   pages with the four calls (seven calls a round, rotated — BLUE's `u20b -Ddepth` design, which is how BLUE's depth JVMs ran) and, after
   its timing, explains the six SELECTs on its own fresh database. So the depth series has 6 JVMs per capture run, not "3 more per
   database", and the plans 3 fresh PostgreSQL databases per capture run (9 per receipt), not 3 in all. Chosen to keep the receipt
   inside its window (one PostgreSQL load per JVM instead of three); the depth medians, the threshold lines and the plans are each still
   asserted per JVM. Cost: the four ratios are timed beside three more OFFSET calls a round — BLUE's depth JVMs measured the same mix
   (PostgreSQL low 26.87) and the thresholds were fixed over them.
2. **`count` B's sort is `Sort.by(DESC, "id")`, not the brief's `Sort.by("id")`** — measured: ascending, Sunil's two join rows are rows
   1 and 2, Hibernate hands back one customer, the page of two is not full, no count runs: `Page 0 of 1 · total 1 · content [Sunil]` —
   Priya on no page at all. The brief's `total 3` needs Priya's row inside page 0, which descending gives (`[Priya, Sunil]`, a full
   page, the count runs: `total 3`). The ascending case is kept in B as a labelled call (a second failure of the same query — content
   lost, not only the count) and asserted; the exercise uses the descending page. `id` is unique, so S3.7 holds either way.
3. **PostgreSQL's keyset plan reads `actual rows=21.00`, not 20.00** — Spring Data asks keyset for one row more than the window (the
   bound `21`, read off Hibernate's bind logger) to know `hasNext`; H2's keyset `scanCount` is 22 (the brief: 21). Both asserted as
   measured. The offset plans are the brief's: first page 20.00, last 1000000.00, depth 250000.00 / 500000.00 / 750000.00.
4. **`trap` is kept, on H2 only** (⚑10 allowed cutting it): clean 3/3, bounded by its cap; RE-MEASURE 8 (the reuse on PostgreSQL) is
   therefore not settled — no capture says PostgreSQL behaves the same, and the README says nothing of it.
5. **The timing's PostgreSQL loader uses `reWriteBatchedInserts=true`** on its own JDBC connection (not on Hibernate's): one JDBC batch
   per 10,000 rows. A load setting, not a query setting; the timed calls go through Boot's pool and Hibernate.
6. **The password reaches the container by `POSTGRES_PASSWORD_FILE`** (a read-only bind mount of `.harness/secrets/pgpw`) and the
   harness by a file it reads (`-Dpg.pwfile`) — never on a command line or in `docker inspect`'s environment. The probe put it in the
   JDBC URL on the command line; here the URL with the password exists only inside the JVM, and every URL printed is cut before `?`.
7. **The PostgreSQL schema is the shipped `Database`'s**, as on H2 (`ddl-auto none`; its `GENERATED BY DEFAULT AS IDENTITY` since unit
   06) — not Hibernate's `create`: the same tables on both databases.
8. **The alarms: 120 for a harness JVM, 300 for a timing JVM** (the brief left them to this unit): the longest timing JVM measured about
   11 s, loading included.
9. **The values line and the chip:** the ratios are printed and never hashed (R.207), so the values line names the thresholds, and the
   chip's ratios come from the runs of record above, not from a hashed line.

10. **A first set of runs of record was thrown away.** The three runs on the script with md5 `df64999e…` (330 / 338 / 371 s, each exit 0,
   all 8 = published — the same hashes) came before the SIGINT trials; the `harness` trial then found the container left `Created`
   (Interrupted, above). `pgrm` was fixed and all three runs of record ran again on the script as committed (`c482a2e6…`).
11. **The plants ran in order of their cost**, the prose gates first and the timing ones last, inside this unit's deadline; the
   table below says which ran.

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror of this folder (an APFS clone; `c7-tiffinbox`, `c7-unit17`, `c7-unit09` beside it as links), one fault per
mirror, run as the runs of record are (`env -i`, a session of its own), on the script as committed (except where the plant is the
script); the first line the run stopped on is quoted (cut at 230 characters):

| plant | the fault | the run | stopped on |
|---|---|---|---|
| plancost | a slide plan line with a cost, a width and the plan header appended to README.md | exit 1 · 2 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | a plan with costs or times (S3.14: explain (analyze, timing off, summary off, costs off, buffers off), actual rows only) - on the planted line (its text not repeated here: this README passes the same gate) |
| count-in-words | the row count spelt out in words, appended to README.md | exit 1 · 1 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | a typed row count - the load's count is read back by select count(*) and composed, never typed (S3.12) - on the planted line (its text not repeated here: this README passes the same gate) |
| durword | a duration word outside the list (an adverb) appended to README.md | exit 1 · 1 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | dur7.DUR found a duration word this unit does not list (R.172, ⚑5) - on the planted line (its text not repeated here: this README passes the same gate) |
| dish | a dish name appended to README.md | exit 1 · 1 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | an Indian dish name (R.215: English names only) - on the planted line (its text not repeated here: this README passes the same gate) |
| placeholder | a placeholder line in exercise/README.md | exit 1 · 1 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | a placeholder line in this unit's prose - the exercise's blocks hold the measured output - on the planted line (its text not repeated here: this README passes the same gate) |
| hashtime | the timing mask removed from receipts.sh (a hashed timing figure) | exit 1 · 18 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | mask: the planted JDK version, folders, home, identity hash, scan time, H2's generated names and a timing figure must be masked |
| badhash | a wrong published hash for page in receipts.md5 | exit 1 · 30 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | page is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-page.out against its block in README.md |
| nohhh | Hibernate's core logger dropped from logback.xml (a version claim without HHH000001) | exit 1 · 30 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | page: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its 1 harness JVMs (R.222, S3.15/R.246) |
| distinct | `distinct` in count B's query (Customers.pausedSince) | exit 1 · 88 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | count B: the derived count, no distinct: select count(distinct ce1_0 .id) from customer ce1_0 join pause p1_0 on ce1_0 .id=p1_0 .customer_id where p1_0 .days>=? |
| nocap | the iterator's cap removed (Run.iterate: `while (it.hasNext())`) - the trap's B loops | exit 1 · 243 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | the harness JVM's alarm fired (exit 142) - a run that does not end by itself is a failed receipt (R.247) |
| poison | `findFirst20ByOrderByIdAsc(ScrollPosition.offset())` called before the timing, on the timing's keyset method | exit 1 · 359 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | NOT CAUGHT - the run passed every check, exit 0 (see For RED) |
| norot | no rotation (`final int r = 0;` in Run.time) | exit 0 · 458 s · receipts.md5 unchanged: yes · container left: none · 19998: 0 | NOT CAUGHT - the run passed every check, exit 0 (see For RED) |

**Not run before this unit's deadline (08:35 CET):** `nodepth` (the depth line dropped from Run.time), `h2aspg` (H2's scanCount lines labelled PostgreSQL), `size10` (the exercise's page size 10 (ExApp: `PageRequest.of(0, 10, …)`)), `nosdv` (Spring Data JPA's version line dropped from Main). Each has its check in `receipts.sh` (named in the list above the table's plants: the `ver` version lines, the threshold, depth and plan-label checks in `chk_time`, the exercise totals); none is claimed caught here.


## Found on the way

- **Paging a join without `distinct` loses rows, not only the count** (What differed 2): with Sunil's two rows first, page 0 of two is
  one customer and says `total 1`; Priya is on no page. The descending page shows the count's error; the ascending one shows the
  content's. Measured on Spring Data JPA 4.1.2 + Hibernate 7.4.13.Final, H2.
- **Keyset reads limit + 1** (21 for a window of 20): the bind logger's `[21]` and PostgreSQL's `actual rows=21.00` agree.
- The PostgreSQL timing JVMs ended in about 11 s, the H2 ones in about 7, each loading its rows.

## CARRIED

- **The Spring Data 4.1.2 scroll reuse** (⚑10) → re-checked by any later course that scrolls (Course 8's brief), on its own Spring Data
  version — and on PostgreSQL, which `trap` does not run (RE-MEASURE 8, open).
- **Paging in TiffinBox's web layer** (`GET /customers?page=`) → Course 9's brief (unchanged).
- **`check_unit7.py`'s `DUR_SECTIONS`** (20 speaks durations) → the tooling session; this unit lists and asserts its three words.
- **The join page that loses a row** (Found on the way) → a script beat if the writer wants it (the capture has it, labelled); no
  later unit is named for it.

## For RED

- **PLANT NOT CAUGHT — no rotation (S3.5).** `final int r = 0;` in `Run.time()` (every round the same seven pages) ran the whole
  receipt to **exit 0** (458 s): every threshold line stayed `true` on H2. The brief's measurement (H2 ratio near 1 without rotation)
  was made with four calls a round; here each round also runs the three depth pages between them, which seems to defeat H2's result
  reuse even without rotation — not measured further. So S3.5's plant does not fail in this design: the rotation is still in the
  receipt and the README, but no check here proves it is needed. RED: decide whether `time` needs a check that fails without rotation
  (for instance the four calls alone in one more JVM) before a script leans on "rotated".
- **Plants not run** (the deadline): the depth line dropped, H2's scanCount labelled PostgreSQL, the exercise's page size 10, Spring
  Data JPA's version line dropped — their checks are in `receipts.sh`; none is claimed caught.
- **`poison`** was caught through the timing JVMs' own content check (each exit 1; `time: each of its 6 harness JVMs ends by itself,
  exit 0` stopped the run); the JVM's exception line was not kept from the mirror.
- **The timing mix** (What differed 1): the ratios are medians over rounds that also time three depth pages; attack whether that moves
  any ratio toward its threshold. The lowest of this unit's runs is printed above; the thresholds' margins over BLUE's 22 JVMs stand.
- **The thresholds are the harness's lines** (`… >= 10: true`): the receipt asserts the line, the harness computes the ratio. A wrong
  comparison in `Run.time()` would pass both — read the three lines of code (`a >= 10`, `b >= 10`, `k <= 2`).
- **`count` B's descending sort** (What differed 2) chooses the page that shows `total 3`; the ascending one shows `total 1`. Both are in
  the capture; ask whether the script should say which order it pages in.
- **The plans' SQL is the harness's text**, asserted equal to the logged line and its bound values to the bind logger's — not taken
  from the log itself. A change in Hibernate's SQL would stop the run, not silently explain another query.
- **`trap` on H2 only**; RE-MEASURE 8 open.
- **The duration words:** three (slow, slower, faster), each resting on a threshold line; "at least ten times" and "no more than twice"
  are not dur7 words, but each maps to its line (the voice should say "on this Mac").
- **The sealed clone's docker** reaches the host's daemon (`DOCKER_HOST` named on the `env -i` line); the seal covers Maven, not the
  container — the image is local, `--pull never`.

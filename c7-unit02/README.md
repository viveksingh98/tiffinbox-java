# c7-unit02 — JPA, Hibernate, Spring Data: Three Different Things

Course 7 · Data with JPA & Hibernate · Section 1 (ORM from First Principles), its second unit · Verified on **JDK 25.0.4.1, Apache
Maven 3.9.16, Spring Boot 4.1.2** (the anchor's parent, read off its `pom.xml`; Hibernate ORM 7.4.13.Final, Spring Data JPA 4.1.2,
Spring Framework 7.0.10 — each read off the dependency tree, below; BSD grep 2.6.0 at `/usr/bin/grep`), 2026-11-03. **No Postgres,
no container, no JVM started but Maven's**, no port bound: this is a reading unit. Three names that people use as one:
**J-P-A** — Jakarta Persistence, spelt J-P-A — is the **specification**: the annotations and interfaces (`@Entity`, `EntityManager`)
in one API jar; **Hibernate** is the **implementation**, the library that does the work (it reads the annotations, writes the SQL);
**Spring Data J-P-A** is the **repository layer** on top (`JpaRepository`, the interface you extend instead of writing a class). Spring's
own JPA support (`spring-orm`, `spring-tx`) belongs to the Spring **Framework**, not to Spring Data, and Spring **Boot** wires them
together. The dependency tree of the TiffinBox you are about to change says which jar is which.

**No anchor change.** `anchor` is the link to `../c7-unit03/after` — the tree the first-entity lesson froze — and the script dies unless
`diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox` is empty, at its start and again at its end: it was, in every run of
record. The anchor is never built in place: it is copied to `.harness/after` and built there; the baseline is built in `.harness/base`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 4 captures, 3 runs each; every spoken number asserted after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the `JAVA_HOME` export on its first line after the shebang and dies unless `java -version` and `javac -version`
say 25; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line
first). **Start it in a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group.
`.m2-demo` must be seeded first (below) — or the first build runs once more without `-o`, and its `offline:` line names the artifact it
missed and the repositories that answered.

**Runs (2026-11-03), each `env -i`** (`HOME` = a home of its own whose `.mavenrc` sets `-Duser.home` there and whose `settings.xml`
names only two dead proxies, `127.0.0.1:9` — so no Maven run could reach the network; `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:
/sbin`; `http(s)_proxy` dead too), a session of its own, `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s1/`
alone (6,608 files). Three development runs fixed the captures and the checks (the third made every capture 3/3 and stopped at "no
published hash" with every check passed; its md5s are `receipts.md5`). **The runs of record, on `receipts.sh` md5
`ad697a495253a0d1ae325c6f2ff75cfe`: 63 s under `./receipts.sh`** (/bin/bash 3.2.57) **and 70 s under `bash receipts.sh`** (Homebrew
bash 5.3.9): each exit 0, all 4 captures 3/3 = published, every check passed; each of the five Maven builds before the captures
`offline: yes · exit 0 · 'Downloaded from' lines in its log: 0` (the fifth is the move-tree comparison on a copy of
`../c7-unit03/.harness/move`: md5 `dde63b6f…` = the baseline's); each terminal log through `check_unit7.py 02 --runlog` — `0 grep error
line(s)`, `RESULT (run logs): PASS` (the unit gate itself answers "no 02-*.md … nothing to check": no script yet). **No run of record
downloaded anything.** After this README's numbers were written, the same two runs on the tree as committed: 81 s and 84 s, each exit 0, all 4 = published, `--runlog` PASS.

Published hashes: tree `46f4f7ab1cb7c3411c5dc2c8a05bfdea` · owners `e92f96d5143a78d67392f16edcbb08b4` · poms `4f2205553699f3f015f824825d620269` · exercise `1f22cf27bd1788161abdd56091f44f87`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash** (type `bash` first if your Terminal is zsh: zsh does not split the unquoted `$E`).

**Run (2026-11-03):** a `git clone` of tiffinbox-java at `dc8ed5d` into a path **with a space** (`…/sealed 02/tiffinbox-java`), with
`c7-unit02/` and `.gitignore` put in as git would take them (`git ls-files -co --exclude-standard`: 9 files, each `cmp`-equal to the
working tree; `anchor` → `../c7-unit03/after` by `readlink`); a `file://` copy of the seed (4,967 files: `_remote.repositories`,
`*.lastUpdated` and `resolver-status.properties` left out); pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from
http(s) — `sealed: file:// only`; the clone's `.m2-demo` **seeded from that copy** (4,967 files); `/bin/bash` 3.2, `env -i`, a session
of its own: **exit 0 in 146 s, all 4 = published, every check passed**; each of its four builds said **`offline: yes · exit 0 ·
'Downloaded from' lines in its log: 0`**; after the run the clone's `.m2-demo` still held 4,967 files (0 `_remote.repositories`). The
two terminal-only lines said what a clone has not: `../c7-unit03/.harness/move is not beside this clone` and `the Hibernate 8 status
chip: refused - no dated metadata file …: Hibernate 8's status: not read`. Its log through `--runlog`: PASS. **And with an empty
`.m2-demo`** (a copy of the clone, the seeding line left out; same script): the first build `offline: no - the offline build could not
resolve org.springframework.boot:spring-boot-starter-parent:pom:4.1.2 from .m2-demo, so it ran once more without -o; that run
downloaded from: sealed (file) 600; of them over http(s): 0`, the second (`jakarta.persistence-api:jar:3.2.0`) `sealed (file) 73`, the
first tree line (`maven-dependency-plugin:jar:3.11.0`) `sealed (file) 174`, the fourth `offline: yes`; its `_remote.repositories`:
847 `>sealed=`, 0 `>central=` — then exit 0 in 183 s, all 4 = published, `--runlog` PASS: the label names the one repository that
answered, never one the log does not.

```bash
S=/tmp/sealed02; W="/tmp/sealed 02"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" "$W" && git clone -q "file://$T" "$W/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/../../data-jpa-hibernate/_research/m2-seed-c7-s1/" "$S/central/"
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
cd "$W/tiffinbox-java/c7-unit02" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

(The clone's own `c7-unit02/` is the committed one once this unit is in git; before its commit it was put in as git would take it.)
A clone has no `../../../data-jpa-hibernate/_research/` beside it and no `../c7-unit03/.harness/`: the Hibernate 8 line says
`refused` and the move-tree comparison says it is not beside the clone — both terminal only, no capture depends on either.

## The commands this unit adds

```bash
mvn -o -B -Dmaven.repo.local="$M2" dependency:tree -DoutputFile=tree.txt
mvn -o -B -Dmaven.repo.local="$M2" -DskipTests package
python3 -I -B harness/pom.py deps "$M2/org/hibernate/orm/hibernate-core/7.4.13.Final/hibernate-core-7.4.13.Final.pom"
```

`receipts.sh` reads two lines from the anchor's own README (`anchor/README.md`, each asserted there whole): `mvn -B dependency:tree`
("Versions live in exactly one place") and `mvn -B package`. **The tree line** is the anchor's with `mvn -B` made `mvn -o -B
-Dmaven.repo.local="$M2"` and ` -DoutputFile=tree.txt` added — nothing else (asserted) — and it runs **from the reactor root**, the
folder of the parent POM: each module writes its own `tree.txt`, and the receipt reads `tiffinbox-web/tree.txt` (R.181). **The
package line** is the anchor's made offline the same way, with `-DskipTests`: this unit reads the two jars' `BOOT-INF/lib`, it does not
test them (the first-entity lesson ran the 18 tests on both trees; skipping them here also means no test binds a port). **The move
line** — `sed 's#<version>4.1.1</version>#<version>4.1.2</version>#' pom.xml > pom.xml.new && mv pom.xml.new pom.xml` — is read from
`../c7-unit03/README.md` (asserted there whole) and run on `.harness/base`, the copy of the first-entity lesson's previous tree.
`harness/pom.py` reads a POM as the POM says it — `deps` (each `<dependency>` directly under `<project><dependencies>`), `where` (every
element whose text is a name, with its line and path), `prop` (one property) — nothing resolved, nothing inherited.

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s1/` alone (6,608 files) before the runs of record: `rsync -a
../../../data-jpa-hibernate/_research/m2-seed-c7-s1/ .m2-demo/` from this folder. The seed holds Boot's parent 4.1.2, the data
starter and everything the builds and the tree read, `maven-dependency-plugin` 3.11.0 (Boot 4.1.2's, read off the tree run's log)
among them, and **no `com/tiffinbox`** — the receipt dies if `.m2-demo` holds one (an installed TiffinBox would change what the
exercise's `-pl` tree reads). The four builds before the captures go through `mbuild`, the entity-states lesson's (its label read off
the log; on an empty repository it names the missing artifact and the repositories that answered). **Nothing was downloaded** by a
receipt run of record: each said `offline: yes` with 0 `Downloaded from` lines, and the runs' `HOME` named only dead proxies.

**The one network call of this unit** (the brief's ⚑10, RE-MEASURE 9) was made once, by its author, before the receipts, and outside
them: at **2026-11-03T06:00:29Z** (`date -u`),

```
curl -fsS https://repo1.maven.org/maven2/org/hibernate/orm/hibernate-core/maven-metadata.xml -o ../../../data-jpa-hibernate/_research/hibernate-core-metadata-2026-11-03.xml
```

exit 0, 11,312 bytes, md5 **`5af4b46c5ee1ffb8a6165c9e29668f6a`**. The file lives in the course folder, outside this repository (it is not
committed). `receipts.sh` reads it offline, **after** the captures, on the terminal only:

```
Hibernate 8's status, read from hibernate-core-metadata-2026-11-03.xml (dated 2026-11-03, md5 5af4b46c5ee1ffb8a6165c9e29668f6a): 8.x versions 5 (8.0.0.Alpha1 8.0.0.Beta1 8.0.0.Beta2 8.0.0.Beta3 8.0.0.Beta4) · the newest 8.x: 8.0.0.Beta4 · an 8.x .Final (GA): none - not GA · <latest> 8.0.0.Beta4 · <release> 8.0.0.Beta4 (Maven's newest non-snapshot, not a GA mark) · the newest .Final: 7.4.14.Final · Course 7 is written to Hibernate 7 (7.4.13.Final, Boot 4.1.2's)
```

**The chip, then: Hibernate 8 — newest 8.0.0.Beta4, not GA (Central's metadata, 2026-11-03); Course 7 is written to Hibernate 7.** The
file's `<lastUpdated>` is `20261028161319` — Beta4's day, the setup sweep's 2026-10-28: nothing newer since. The receipt **refuses** the
line (and prints why) when the file's name carries no date, when the file is missing, when its md5 is not the one above, or when it
holds no 8.x — the builder refuses the chip the same way (the brief's rule: no file, no chip). No Maven run touched the network for it:
Maven stays `-o`. At run time nothing is sent anywhere. Apart from that one `curl` and the final `git push`, this unit used no network.

## The locale

No JVM of this unit's own starts, so no locale is pinned on a java line; Maven runs under the script's `LC_ALL=C`, and nothing it prints
is captured — only what the script read from its log and from the files it wrote.

## The folders, the harness and the ports

- `anchor` — the link to `../c7-unit03/after` (= `../c7-tiffinbox`), read only; copied to **`.harness/after`** (`diff -rq` empty) and
  built there. **`.harness/base`** — the baseline: `../c7-unit03/before/` (the link to `../c6-unit31/after`, Course 6's last tree),
  copied, with the first-entity lesson's move line run on the copy; the receipt asserts its diff against the source is exactly
  `@@ -13 +13 @@ -    <version>4.1.1</version> +    <version>4.1.2</version>` and that nothing else differs. This **is** that lesson's
  `move` tree: when `../c7-unit03/.harness/move` is beside this folder, the receipt copies it (read only) to `.harness/m03`, asserts its
  files equal `.harness/base`'s and runs the same tree line there — `tiffinbox-web/tree.txt` md5 `dde63b6fed7a0d482f8d1d8874a8231c` on
  both (terminal only; a clone has no `.harness`). `.harness/ls` — the eight jar listings; `.harness/ex` — the exercise's copy.
- `harness/dur7.py` is Course 7's builders' duration pattern, byte for byte (md5 `41667fed9ffcefe171389eed7e654e66` asserted; `cmp`
  against `../../../data-jpa-hibernate/_builders/dur7.py` when that file is beside the clone). `harness/pom.py` — the POM reader above.
- **Ports** (§P, 19810-19819): **none bound** — no server, no test runs. All ten are checked free (`lsof`) first and last, 19819 among
  them.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on a planted line): this folder → `…`, the folder above → `…/..`, home → `~`,
   the user name → `<user>`; ` using Java <version>` (R.151). None appears: the captures print `$M2` as written, never its value.
2. **Maven's logs are never printed.** From each tree run's log the script reads its exit code, the plugin's version, the reactor's
   module count, the `The POM for … is missing` WARNING lines, the `Downloaded from` lines and the `BUILD SUCCESS` line — counts and one
   version, nothing else. **No Maven duration is captured** (its `Total time` and `Finished at` lines never reach a capture; a last check
   refuses them). The builds' labels go to the terminal only.
3. **The trees are read as data**: one row per line — `groupId:artifactId:type[:classifier]`, version, scope, optional, depth (three
   characters of indentation a level), line number — and compared **by artifact, never by line** (R.45: a line total is no witness).
4. **Hygiene, checked last over every capture**: no absolute path; no unit number; no process line, no time, no Maven duration; no
   JDK/OS version token; no stack frame; no `$` line with a URL; **no bare `grep` on a `$` line**; no `java` on a `$` line (no JVM but
   Maven's); **every `mvn` on a `$` line offline on this unit's repository**; no `pkill`/`killall`; no bare `wait`; no variable holding
   several options in one string (R.193); nothing installed into `.m2-demo`. **`duration words: 0`** — dur7's `DUR` over this README and
   the exercise's two files, before anything runs (R.172).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the Maven it waits for (`$mpid`, with every
process under it — `killtree`), the exercise's shell (`$xpid`, with every process under it), sweeps its own process group for a Maven
left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured (2026-11-03):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own **with SIGINT at its default**
(`signal.signal(SIGINT, SIG_DFL)` before `setsid`/`exec`), under the runs-of-record `env -i`, `kill -INT` to that group once the
named step was running, the state read 5 s after it exited — four trials, each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · Maven launchers on this machine: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
tree: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · Maven launchers on this machine: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
owners: processes in the group at SIGINT 2 · exit 130 · 5 s later in the group: 0 · Maven launchers on this machine: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
exercise: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · Maven launchers on this machine: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the first package build (Maven's launcher in the group); `tree` — the `tree` capture, its Maven on the anchor's copy; `owners` —
the `owners` capture (the script, an `unzip` or a `grep` in the group, no Maven); `exercise` — the exercise capture, its `env -i`
shell's Maven running.

## 1 · tree — the anchor's tree from the reactor root, beside the 4.1.2 tree without the starter (R.181; RED #12, #17; RE-MEASURE 9)

The tree line runs twice, each a fresh Maven run, from the reactor root of each copy: **the baseline** (`.harness/base`, Boot 4.1.2, no
data starter, no `jakarta.persistence-api` in tiffinbox-core) and **the anchor** (`.harness/after`). Each: exit 0, plugin
`maven-dependency-plugin 3.11.0`, **reactor modules 3**, **`The POM for … is missing` WARNING lines: 0**, `Downloaded from` 0, `BUILD
SUCCESS` 1; `tree.txt` written by all three modules; **`com.h2database:h2` in `tiffinbox-web/tree.txt`: 1 line** (H2 2.5.250 — the
anchor's own `<h2.version>`, not the BOM's). The baseline's `tiffinbox-web/tree.txt`: 105 lines, **104 artifacts**, md5 `dde63b6f…`; the
anchor's: 134 lines, **133 artifacts**, md5 `2a2297f6…` (the probe's u03 tree, byte for byte). The anchor's tree is printed whole.

**Compared by artifact:**
- **added: 29**, by name, in the tree's order: `jakarta.persistence-api` 3.2.0, `spring-boot-starter-data-jpa`, `spring-boot-starter-jdbc`,
  `HikariCP` 7.0.2, `spring-boot-data-jpa`, `spring-boot-data-commons`, `spring-boot-persistence`, `spring-data-commons` 4.1.2,
  `spring-boot-hibernate`, `spring-boot-jpa`, `hibernate-core` 7.4.13.Final, `jakarta.transaction-api` 2.0.1, `hibernate-models` 1.1.2,
  `jaxb-runtime` 4.0.9, `jaxb-core` 4.0.9, `angus-activation` 2.0.3, `txw2` 4.0.9, `istack-commons-runtime` 4.1.2, `jakarta.inject-api`
  2.0.1, `spring-orm` 7.0.10, `spring-data-jpa` 4.1.2, `spring-tx` 7.0.10, `antlr4-runtime` 4.13.2, `spring-aspects` 7.0.10,
  `aspectjweaver` 1.9.25.1, `spring-boot-jdbc`, `spring-boot-sql`, `spring-boot-transaction`, `spring-jdbc` 7.0.10 (Boot's modules at
  4.1.2). The check compares the set with the 29 named in `receipts.sh` and the list's length with the derived count.
- **removed: 0.**
- **the same artifact at another scope: 3**, named apart — `jakarta.xml.bind-api` 4.0.5, `jakarta.activation-api` 2.1.4, `byte-buddy`
  1.18.15, each **test → runtime**: in the baseline only the tests used them; hibernate-core needs them at run time. A "new artifacts"
  count misses them, and the jar does not.
- the same artifact at another version: 0. **`derived: added 29 · removed 0 · scope moves 3 · version changes 0`.**

**The versions, read off the tree** (the parent off `pom.xml`'s `<parent>`) and asserted equal to the brief's expected values (R.196,
RED #17 — on a mismatch the tree wins and the voice is corrected, never the reverse): `spring-boot-starter-parent` **4.1.2** ·
`hibernate-core` **7.4.13.Final** · `jakarta.persistence-api` **3.2.0** · `spring-data-jpa` / `spring-data-commons` **4.1.2** ·
`spring-orm` / `spring-tx` / `spring-jdbc` **7.0.10** · `HikariCP` **7.0.2** · `h2` **2.5.250** · `spring-boot-starter-data-jpa` 4.1.2 —
11 of 11 read = expected.

**Where the specification's jar prints:** in the anchor's tree, **1 line — line 13, depth 2, under `com.tiffinbox:tiffinbox-core`**
(line 2): tiffinbox-core declares it for `CustomerEntity`'s annotations, so that is its first path; hibernate-core's and spring-boot-jpa's
POMs name it too (`poms`), and the tree does not print it again. **A tree prints each artifact once, at its first path** — nobody should
count layers by indentation. In the baseline's tree: 0 lines.

**`BOOT-INF/lib`**, read with `unzip -l` from the two jars the package line built: **61 → 91**; 30 in the anchor's jar only, 0 in the
baseline's only. Each of the 30 matched to the tree by file name (`artifactId-version.jar`): **27 the tree added, 3 the tree moved from
test to runtime, 0 neither**. The tree's added artifacts with no jar: **2 — `spring-boot-starter-data-jpa` and `spring-boot-starter-jdbc`**,
each a `Spring-Boot-Jar-Type: dependencies-starter` by its own `MANIFEST.MF` (Boot's plugin leaves starters out of the jar).
**`derived: BOOT-INF/lib 61 -> 91, +30 = 29 added - 2 left out of the jar + 3 moved from test to runtime`** — the jar count and the
artifact count, each said with its source.

## 2 · owners — who owns which class (R.134)

Eight jars, each at the version the anchor's tree gives it, listed once with `unzip -l "$M2/…"` into `.harness/ls` (paths printed
relative to `$M2`): jakarta.persistence-api-3.2.0 (252 entries), hibernate-core-7.4.13.Final (8,846; 8,320 classes), spring-data-jpa-4.1.2,
spring-data-commons-4.1.2, spring-orm-7.0.10, spring-tx-7.0.10, spring-boot-persistence-4.1.2, spring-boot-hibernate-4.1.2. Each class
is looked for in **all eight** with `/usr/bin/grep -cxF '<path>.class' .harness/ls/*.txt` (exact names): every one of the 16 is **1 in its
jar and 0 in the seven others** (asserted per class, under its own command line). The owner's family is read from the jar's groupId:

| classes | jar | family |
|---|---|---|
| `jakarta.persistence.Entity`, `EntityManager`, `Table`, `Column` | jakarta.persistence-api-3.2.0 | Jakarta Persistence (J-P-A), the specification |
| `org.hibernate.Session`, `SessionFactory`, `stat.Statistics` | hibernate-core-7.4.13.Final | Hibernate ORM, the implementation |
| `JpaRepository`, `SimpleJpaRepository` | spring-data-jpa-4.1.2 | Spring Data, the repository layer |
| `CrudRepository` | spring-data-commons-4.1.2 | Spring Data, the repository layer |
| `LocalContainerEntityManagerFactoryBean`, `JpaTransactionManager` | spring-orm-7.0.10 | **Spring Framework** — not Spring Data |
| `@Transactional`, `TransactionTemplate` | spring-tx-7.0.10 | Spring Framework |
| `EntityScan` | spring-boot-persistence-4.1.2 | Spring Boot |
| `HibernateJpaAutoConfiguration` | spring-boot-hibernate-4.1.2 | Spring Boot |

## 3 · poms — who needs whom (RED #18)

Read from `.m2-demo` with `harness/pom.py` — each `<dependency>` directly under `<project><dependencies>`, its scope as written (none
written: compile, Maven's default) and `optional` as written; `<dependencyManagement>`, the build's plugins and the parent's lines are not
dependencies and are not read.
- **hibernate-core 7.4.13.Final**: **9 dependencies** — counted as the direct `<dependency>` elements of its POM, compile 2 /
  runtime 7 / optional 0: `jakarta.persistence-api` **compile**, `jakarta.transaction-api` compile, `jboss-logging`, `hibernate-models`,
  `byte-buddy`, `jakarta.xml.bind-api`, `jaxb-runtime`, `jakarta.inject-api`, `antlr4-runtime` runtime. The implementation implements the
  spec: it needs the spec's jar. (Its POM's two `<dependencyManagement>` entries are not counted.)
- **spring-data-jpa 4.1.2**: 40 dependencies (compile 15, provided 7, test 18; optional 8). On screen as the POM says them:
  **`${hibernate.groupId}.orm:hibernate-core compile optional`** and **`org.eclipse.persistence:org.eclipse.persistence.jpa compile
  optional`** (EclipseLink); `${hibernate.groupId}` is `org.hibernate`, the property in its parent `spring-data-jpa-parent-4.1.2.pom`.
  **`jakarta.persistence-api` among its dependencies: 0.** Its POM names that artifact once — line 436,
  `project/build/plugins/plugin/configuration/annotationProcessorPaths/path/artifactId`: a compiler's annotation-processor path in its own
  build, not a dependency. So "its POM marks Hibernate optional" — never "works over either": EclipseLink never ran here.
- **Where Spring Data J-P-A's side gets the spec jar:** Boot's `spring-boot-jpa` 4.1.2 — `jakarta.persistence:jakarta.persistence-api
  compile` (beside spring-boot-jdbc, spring-boot-transaction, spring-orm).
- **The path the viewer types, from the tree's indentation** (each line's parent is the nearest line above it one level less deep): line
  73, depth 1 `spring-boot-starter-data-jpa` → line 76, depth 2 `spring-boot-data-jpa` → line 80, depth 3 `spring-boot-hibernate` → line 82,
  depth 4 `hibernate-core` 7.4.13.Final — **two Boot hops between the starter and Hibernate**; and each POM on it names the next
  (starter-data-jpa → spring-boot-data-jpa; data-jpa → spring-boot-hibernate; hibernate → `org.hibernate.orm:hibernate-core compile`).

## 4 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s 8 lines, then `exercise/SOLUTION.md`'s (two lines differ: the Maven line and the file the last grep reads), each
block sourced in one `env -i` shell (`HOME`, the `PATH` the script was started with) started in this folder — `/bin/bash --noprofile
--norc`, then again `/bin/zsh -f`; each block copies the anchor afresh to `.harness/ex` and is a fresh Maven run on the unit's own
`.m2-demo`. The README's Maven line is asserted to be the receipt's tree line with `-DoutputFile=tree.txt` made `-pl tiffinbox-web`; the
solution's, the receipt's tree line itself. **README** (`-pl tiffinbox-web`): Maven `exit 0` — BUILD SUCCESS — the WARNING `The POM for
com.tiffinbox:tiffinbox-core:jar:1.0.0 is missing` **1**, `com.h2database:h2` **0** (the block exits 1, on the grep that found nothing).
**SOLUTION** (from the root, `-DoutputFile=tree.txt`, read from `tiffinbox-web/tree.txt`): `exit 0`, the WARNING **0**, H2 **1**. Bash and
zsh print the same. **Broken 0 ≠ solved 1.** No option list lives in a variable (R.193).

## Exercise

**Your turn:** the README's tree has no database driver in it. Run it the way the receipt does, and find H2. (20 words by `wc -w`,
"Your turn:" included.) `exercise/README.md` ships the `-pl` tree (H2 **0**, a WARNING, exit 0), `exercise/SOLUTION.md` the reactor-root
tree (H2 **1**); both measured by the `exercise` capture, in bash and in zsh. Run them from this folder: they need only the seeded
`.m2-demo` and the `anchor` link, and they copy the anchor to `.harness/ex` themselves.

## The ledger rows and hand-offs this unit pays

- **C7-6 — paid (the three names):** J-P-A, spelt, the specification; Hibernate the implementation; Spring Data J-P-A the repository
  layer — defined in this README's first paragraph and shown by the `owners` table (each family by the jar's groupId) and the `poms`
  lines. The persistence context is the persistence-context lesson's half of the row.
- **§3's version-bound unit:** every version this course states is read here off the tree on 2026-11-03 and asserted equal to the
  expected values (11 of 11); every other unit writes "Spring Boot 4.1 or newer" / "Hibernate 7".
- **C7-12 — holds:** this unit's title is unchanged ("JPA, Hibernate, Spring Data: Three Different Things", the slug of `java7_series.py`).

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 9 | 02's tree of the frozen `03/after`: md5 `2a2297f6f5289ef9db52086fc1a6f5cd` (= the probe's u03 tree), from the reactor root, H2 1, no POM missing; against the 4.1.2 tree without the starter (`dde63b6f…`, = the first-entity lesson's `move` tree, checked on a copy of it): 29 added by name, 0 removed, 3 scope moves, 0 version changes; `BOOT-INF/lib` 61 → 91. **Hibernate 8's status on the day: newest 8.0.0.Beta4, not GA** (the dated metadata file above) |
| 10 | the exercise as viewers run it: `env -i`, bash and `/bin/zsh -f`, README then SOLUTION in one shell, each a fresh Maven run: H2 0 → 1. Its blocks export JDK 25 first (no JVM of the unit's own starts, so "Java 23 refused" has nothing else to refuse) |

## What differed from the brief

1. **The baseline is the first-entity lesson's previous tree with the parent at 4.1.2 (its `move`), not the anchor minus the
   starter.** The brief allowed either and asked for the one that equals that lesson's `move` tree. Measured in the scratch folder
   on 2026-11-03, offline on this unit's `.m2-demo`: the anchor's copy with only the `spring-boot-starter-data-jpa` `<dependency>` block
   removed (a 4-line diff, asserted) gives a `tiffinbox-web/tree.txt` of **106 lines, md5 `8cc41fa1…`**, one line more than `move`'s
   (`dde63b6f…`, 105): tiffinbox-core still declares `jakarta.persistence-api` (for `CustomerEntity`), so the "added" count would be 28 —
   and that copy would not even compile (`TiffinBoxApp` imports `EntityScan`), so its jar could not give `BOOT-INF/lib`. The previous tree
   with the move line equals the `move` tree file for file, and its tree md5 is the one a copy of `../c7-unit03/.harness/move` gives
   (asserted in every run where that folder is beside this one; read only, run on a copy). So "4.1.2 without the starter" here means
   **4.1.2 without anything the first-entity lesson added**: the starter *and* tiffinbox-core's API jar *and* the entity.
2. **The jars are built with `-DskipTests`.** The brief named no test run; the first-entity lesson ran the 18 tests on both trees.
   Skipping them keeps "no port bound" true (a `RANDOM_PORT` test binds one) and leaves Maven the only JVM.
3. **The tree runs once more, through `mbuild`, before the captures** (on each copy), so that on an empty repository the dependency
   plugin is resolved by the labelled retry and the captures themselves can stay strictly offline.
4. **`mbuild` is the entity-states lesson's, with `grep` written `$G`** (`/usr/bin/grep`) — the only difference, as the
   object-relational-mismatch lesson made it; this task's rule that every line of `receipts.sh` uses `/usr/bin/grep` wins over "byte for
   byte". Its label is derived from the log; there is no fixed sentence.
5. **The Hibernate 8 status is terminal only, not a capture.** The dated metadata file lives outside the repository (not committed), so a
   clone cannot read it; a capture that depends on it would not reproduce. The receipt prints the status line (or `refused` and why) after
   the captures, ties it to the file's md5, and the README carries it.
6. **"no `jakarta.persistence-api` line" is said as "no `jakarta.persistence-api` dependency".** spring-data-jpa's POM does name the
   artifact once (line 436, an annotation-processor path in its own build). The capture prints that line with its element path, and the
   check asserts that no element under `<dependencies>` names it.
7. **The exercise copies the anchor itself** (`rsync … anchor/ .harness/ex/`, its first lines) and exports JDK 25 first, so a viewer's
   run never writes a `tree.txt` into the anchor and does not depend on anything `receipts.sh` left. SOLUTION.md differs in two lines
   (the Maven line and the file the last grep reads), not one.
8. **More versions read than the brief listed:** `h2` 2.5.250 and `spring-boot-starter-data-jpa` 4.1.2 join the nine (11 asserted).
9. **Owners: 16 classes in 8 jars** — the brief's list; `Repository`, `SharedEntityManagerCreator` and the other classes the probe named
   are not looked for.

## Planted faults — each caught (R.65)

Each planted on the unit's files in place (backups kept outside the repository, restored and `cmp`-checked after each), run under
`./receipts.sh` with the runs-of-record environment; each fails its check, and the files were byte-identical to the shipped ones
afterwards.

| plant | what failed | exit |
|---|---|---|
| a version typed instead of read: hibernate-core's expected value `7.4.5.Final` | `tree: the version read off the tree is not the expected one for org.hibernate.orm:hibernate-core:jar - read: … 7.4.13.Final` | 1 |
| `spring-orm` attributed to Spring Data (`LocalContainerEntityManagerFactoryBean … Spring Data, the repository layer`) | `owners: LocalContainerEntityManagerFactoryBean.class belongs to spring-orm-7.0.10.jar, Spring Data …: expected the line …` — the jar's groupId says Spring Framework | 1 |
| the tree compared with the first-entity lesson's 4.1.1 tree (the move line not run; its two guards bypassed) | with the published hash: `tree … DIFFERS`; with the tree's hash taken out: `tree: the comparison against the 4.1.2 tree without the starter (never the 4.1.1 one)` — the derived line read `added 29 · removed 0 · scope moves 3 · version changes 56` (Found on the way) | 1, 1 |
| a `-pl tiffinbox-web` tree as the receipt's tree | with the published hash: `tree … DIFFERS`; without: `tree (R.181): each tree run exits 0 from the reactor root …` — reactor modules 1, the WARNING 1, only `tiffinbox-web/tree.txt` written, `com.h2database:h2` 0 | 1, 1 |
| the status chip with no dated file: the file named `…-2026-11-04.xml` (absent) | `the Hibernate 8 status chip: refused - no dated metadata file at …: Hibernate 8's status: not read` (no capture depends on it: the run goes on) | 0 |
| the status chip from an undated name, `hibernate-core-metadata.xml` | `refused - the metadata file's name carries no date` | 0 |
| a wrong published hash (tree's last digit) | `tree md5 46f4f7ab… DIFFERS from the published 46f4f7ab…deb` | 1 |
| a duration word in the README (one line appended: "The tree took 7", then the unit of time dur7 refuses) | `dur7.DUR found duration words (Section 1 states none, R.172): README.md line …` — before anything runs | 1 |

## Found on the way

- **Against the 4.1.1 tree, the artifact comparison still reads 29 added, 0 removed, 3 scope moves — and 56 version changes.** The
  brief's plant expected the "0 removed, 3 scope moves" check to fail; measured, those two numbers hold against `03/before`'s tree too
  (the starter adds the same artifacts at either parent). What catches the wrong baseline is the **version changes** count (56, against
  0) — the derived line is asserted whole, so the plant fails on it. A **line** diff against that tree gives **88 added lines** (and 59
  removed), RED #12's number, reproduced.
- **Maven's `<release>` in the metadata is `8.0.0.Beta4`.** `<release>` means "newest non-snapshot", not GA; a script that read it as
  "released" would announce Hibernate 8. The receipt derives GA from `.Final` and says so on the line.
- **The newest Hibernate 7 is 7.4.14.Final**, one patch past Boot 4.1.2's 7.4.13.Final (as the setup sweep found); Course 7 stays on
  Boot's.
- **The two starters Boot's plugin leaves out of the jar say so themselves:** `Spring-Boot-Jar-Type: dependencies-starter` in each
  `MANIFEST.MF` — the reason for "− 2", read, not assumed.
- **spring-data-jpa's POM marks `spring-aspects` optional, yet it is in the jar:** Boot's `spring-boot-data-jpa` declares it (compile),
  and the tree prints it under that module. An `optional` in a library's POM says nothing about whether a starter brings it.
- **A bash dynamic-scope trap** (during development, not in a run of record): a capture function that set a variable named `nm` changed
  `cap()`'s own local `nm`, and the capture was filed as `.r-3.out`. The capture functions now declare their variables `local`.

## CARRIED

- **Hibernate 8** — not GA on 2026-11-03 (8.0.0.Beta4, Central's metadata `lastUpdated` 2026-10-28). Course 7 stays on Hibernate 7; a
  later unit that names Hibernate 8 re-reads a dated file of its own day.
- **The scripts:** U02's script says the versions as read here (asserted 11/11), the three names as §10 keeps them apart, "its POM marks
  Hibernate optional" (never "works over either"), "+30 = 29 − 2 + 3" with each source, and "a tree prints each artifact once".
- **03/04's `offline:` label** (FACTORY-NEXT, RED) — not touched by this unit.

## For RED

1. **The baseline choice** (What differed 1): "4.1.2 without the starter" is the first-entity lesson's `move` tree, so "29 added" counts
   tiffinbox-core's `jakarta.persistence-api` as added too. The script should say "the starter and the entity's API jar add 29", or name
   the baseline as "the tree before the entity lesson, on 4.1.2" — not "the starter adds 29".
2. **The brief's planted-fault line for 02** ("the tree compared with `03/before`'s 4.1.1 tree → the '0 removed, 3 scope moves' check
   fails") is half wrong: removed and scope moves hold (0, 3); the version-change count (56) catches it. The brief's text should be
   corrected; this unit's check holds because it asserts the whole derived line.
3. **The Hibernate 8 chip is terminal only** — the builder must read the dated file itself (same md5) or this README's line; no capture
   carries it. A sealed clone prints `refused`, by design.
4. **"no `jakarta.persistence-api` line" vs "no dependency"** (What differed 6): a slide that shows spring-data-jpa's POM and says "no
   line names the spec" is false — line 436 does, in `annotationProcessorPaths`.
5. **03/04's `offline:` label** is still the separate fix FACTORY-NEXT names; this unit's `mbuild` is 05's.

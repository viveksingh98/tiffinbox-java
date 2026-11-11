# c7-unit26 — Rollback Rules

Course 7 · Data with JPA & Hibernate · Section 4 (Transactions), its fourth unit and **its first change to the anchor** (brief ⚑1, C1;
the course's eighth): `before` is the link to `../c7-unit17/after` (Section 3's frozen anchor), `after/` is this unit's tree, and
`../c7-tiffinbox` equals `after/` from this unit's commit on. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2**
(Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final), 2026-11-11, **on H2 2.5.250** only (brief ⚑2: every rule
line H2 = PostgreSQL in the probe; this unit's receipt runs H2, so its claims are said "on H2"). A **rollback rule** decides what a
failure undoes: a transactional method rolls back on an unchecked exception or an `Error`, and **commits on a checked one** — even as the
exception leaves the method. TiffinBox gets its first `@Transactional`, and the default rule turns its 409 into a 500 until the rule
names the exception. The feed now hears a customer only after the commit.

**The anchor changes (C1).** `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox` at its
start and end — empty in every run of record — and, from a later anchor change on (27 moves it again), prints a note instead, never a
stop (R.211). Each tree is copied under `.harness/` and built there with the README's package line, offline; the harness runs over the
copies' extracted libraries (91 each).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 10 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5`. **Start it in a process group of its own** (a
terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be seeded first (below).

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files). Development runs fixed the captures and the checks; the first full passing run wrote every capture 3/3, and those md5s are
`receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `10211df9e2ecbb42bb78ea81d169f7a0`): 432 s under
`./receipts.sh`** (/bin/bash 3.2.57, 2026-11-11 from 21:05 CET), **465 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from 21:13
CET), **460 s from a sealed fresh clone** (below, from 21:21 CET) **and 394 s on the tree as committed** (`./receipts.sh`, from 21:29 CET): each exit 0, all 10 captures 3/3 = published, every check passed,
every Maven run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty at the start and the end, nothing
listening on 20050-20059 at the end; each terminal log through `check_unit7.py 26 --runlog` — `RESULT (run logs): PASS` (the unit gate:
no 26 script yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — unit 24's recipe: a `git clone` of tiffinbox-java at `6483bc7` (`file://`) into a path **with a space**
(`…/sealed 26/tiffinbox-java`, in the session's scratch folder), this commit's 74 files put in as git will take them (`git ls-files -m -o
--exclude-standard c7-unit26 c7-tiffinbox c7-unit17 c7-unit22`, links kept); a mirror of the seed as Maven's only repository (`file://`),
dead proxies for http and https, the pre-flight `dependency:get` of an absent artifact refused with `Downloading from sealed: file://`
only; the clone's `.m2-demo` seeded from that copy; `./receipts.sh` `env -i` (the dead proxies in its environment).
<!-- runs: end -->

Published hashes: rules `8cbcaf8b1e238337d61804ee74e4863f` · allexceptions `55d6b388608908536bba26529a5e6768` · twowrites `d1a267c983bbed8deefcd37b860d65e1` · events `696753e6a5cf1ee96f1cb83ee96530bd` · anchor `b9739b0e3ec634559554152afef77533` · feed `81e35a0b483201bb7ffc937ff8f02497` · seven `e3e43133d83ef99e7f8f3bb4132159c7` · tests `f9fbfce876ab0f49bd54b902e208f243` · xcheck `987b966704fbcee8f5886634dc43835e` · exercise `22f93957c0a704819e03df25edd8df8a`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string
typed in this README outside its captured blocks is refused):

<!-- values: begin -->
the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - rules: 10 rows, mismatches 0; checked KEPT · rollbackFor gone · RuntimeException gone · noRollbackFor KEPT · Error gone · caught KEPT · setRollbackOnly gone (Transactional code has requested rollback) · JTA checked KEPT · JTA runtime gone · JTA rollbackOn gone; the checked row: Completing transaction for [probe.t.Rb26.checked] after exception: probe.t.H$CheckedBoom: checked, after saving Asha, then Initiating transaction commit · allexceptions (LABELLED): checked gone, JTA checked gone, noRollbackFor KEPT; default RollbackOn.RUNTIME_EXCEPTIONS; Boot's keys: defaultTimeout rollbackOnCommitFailure · twowrites: Kavya KEPT · her pauses 0 · threw FileNotFoundException; rollbackFor: Kira gone · her pauses 0 · threw FileNotFoundException · events: plain thread main · isActualTransactionActive true · isSynchronizationActive true · the second connection sees the row false; AFTER_COMMIT thread main · isActualTransactionActive true · isSynchronizationActive false · the second connection sees the row true; no transaction: No transaction is active - skipping; throwing listener: TransactionSynchronization.afterCompletion threw exception, the row kept; the anchor's add: Creating new transaction with name [com.tiffinbox.CustomerRepository.add]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,-java.sql.SQLException · anchor B (18 tests passed): 201 · 500 (Application exception overridden by commit exception · org.springframework.transaction.UnexpectedRollbackException: Transaction silently rolled back because it has been marked as rollback-only) · import 500; A: 201 · 409 · import {"file":"customers.csv","added":2,"refused":{"line 3":"a customer named Ravi already exists"}} 200 · feed: 3 Asha Lata Dev; B'': FeedTest java.util.concurrent.TimeoutException (tests 18 · failures 0 · errors 1 · skipped 0) · seven: 466c20ed7e0d5439cb052f32ce09de1b, SQL lines 7, during the seven 5, both trees · tests: 18 (14/3/1) · xcheck: f595637014e786fa38606859951e4f97 · exercise: java.io.FileNotFoundException: welcome-letter.txt (the letter template is missing), customer rows 5 · Kavya kept -> rollbackFor = Exception.class: customer rows 4 · Kavya gone (20 words)
<!-- values: end -->

### The rules — built from the ten `row` lines, never typed (S4.1, S4.2)

`rows.py` (written by `receipts.sh` into `.harness/`) reads each `row` line, checks its outcome against the brief's expected table (the
ten rows of [S4 §5]), and in the row's own block: the manager's `Creating new transaction with name […]` line carrying the row's
attribute, the method's own print inside its transaction (`tx active true · name …`), the interceptor's `Completing transaction for […]`
line (`after exception: …` for a row that threw), exactly one of `Initiating transaction commit` / `rollback` (commit for KEPT), and one
read by the second connection after the manager's last line. The attribute is read off the method by the context's own
`TransactionAttributeSource` (the bean Spring's interceptor uses). The rows below are its output; `receipts.sh` asserts every one is
here, whole.

| row | method | attribute | the customer, by the second connection after the call | the call |
|---|---|---|---|---|
| checked exception | `Rb26.checked` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT` | Asha KEPT | threw CheckedBoom |
| checked, rollbackFor = Exception.class | `Rb26.checkedRollbackFor` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT,-java.lang.Exception` | Dev gone | threw CheckedBoom |
| RuntimeException | `Rb26.runtime` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT` | Nina gone | threw Boom |
| RuntimeException, noRollbackFor = Boom.class | `Rb26.runtimeNoRollbackFor` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT,+probe.t.H$Boom` | Omar KEPT | threw Boom |
| an Error | `Rb26.error` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT` | Tara gone | threw AssertionError |
| RuntimeException caught inside | `Rb26.caught` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT` | Zoe KEPT | returned |
| setRollbackOnly(), no exception | `Rb26.rollbackOnly` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT` | Ivan gone | returned |
| JTA's annotation, checked | `Jta26.checked` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT` | Mia KEPT | threw CheckedBoom |
| JTA's annotation, RuntimeException | `Jta26.runtime` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT` | Ella gone | threw Boom |
| JTA's annotation, checked, rollbackOn = Exception.class | `Jta26.checkedRollbackOn` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT,-java.lang.Exception` | Lena gone | threw CheckedBoom |

`-java.lang.Exception` in an attribute is a rule "roll back for this class and its subclasses", `+probe.t.H$Boom` one "commit for it".
The checked row's two lines, in order: `Completing transaction for [probe.t.Rb26.checked] after exception: probe.t.H$CheckedBoom:
checked, after saving Asha`, then `Initiating transaction commit`. `setRollbackOnly()` throws nothing and the manager says
`Transactional code has requested rollback`, then rolls back. Spring honours JTA's `jakarta.transaction.Transactional` (on the class path
through Hibernate) with the same checked-exception default; its attribute for a rule is `rollbackOn`.

**LABELLED `allx` — Framework 7's switch** (`allexceptions`): the harness's profile `allx` adds
`@EnableTransactionManagement(rollbackOn = RollbackOn.ALL_EXCEPTIONS)` (`harness/src/probe/t/AllX.java`; Boot's own
`@EnableTransactionManagement` steps back). Eight of the ten rows keep their outcome — `noRollbackFor` still KEPT, the caught exception
still KEPT; the two that change:

| row | method | attribute | the customer, by the second connection after the call | the call |
|---|---|---|---|---|
| checked exception | `Rb26.checked` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT,-java.lang.Exception` | Asha gone | threw CheckedBoom |
| JTA's annotation, checked | `Jta26.checked` | `PROPAGATION_REQUIRED,ISOLATION_DEFAULT,-java.lang.Exception` | Mia gone | threw CheckedBoom |

The annotation's default, read off `spring-tx-7.0.10.jar` by `javap -v`: `AnnotationDefault` → `RollbackOn;.RUNTIME_EXCEPTIONS`. Boot
4.1.2 has no key for it: `TransactionProperties` (`spring.transaction.*`) holds two fields, `defaultTimeout` and
`rollbackOnCommitFailure` (`javap -p`). The switch is the harness's; TiffinBox keeps the default and names its rule on `add`.

### C1 — the change, file by file, and every sentence it rewrote (R.250)

`diff -rq before after` (the `anchor` capture prints it, and each diff whole):
- **`tiffinbox-core/…/CustomerRepository.java`** — `public final class` → `public class` (Spring's proxy for a transactional bean is a
  subclass; unit 23's `final` capture is the refusal a `final` class gets); a new constructor argument, `ApplicationEventPublisher
  events`; **`@Transactional(rollbackFor = SQLException.class)` on `add`**, which, after `save`, calls
  `events.publishEvent(new CustomerAdded(customer))`. Its Javadoc gains two paragraphs (the class's: why not `final`, who tells the feed;
  `add`'s: the one transaction, the checked-exception default and the 500 it would cause, the rule that brings the 409 back).
- **`tiffinbox-core/…/CustomerAdded.java`** (new) — `public record CustomerAdded(Customer customer)`.
- **`tiffinbox-web/…/CustomerFeed.java`** — `@TransactionalEventListener void stored(CustomerAdded e)` → `added(e.customer())`. The
  class Javadoc's sentence "Every customer TiffinBox stores - through the JSON API (TiffinBoxServer), the form (DashboardPage) or an upload
  (CustomerImport) - is sent to every emitter still open …" now reads "Every customer TiffinBox stores is sent to every emitter still open
  …", and a new paragraph says who tells the feed (the repository's event) and when (after the commit).
- **`tiffinbox-web/…/TiffinBoxServer.java`** — the call to the feed in `add`, the `CustomerFeed feed` field and its constructor argument
  removed. Javadoc: "every customer this route stores is told to CustomerFeed, which sends it … - as the form's POST (DashboardPage) and an
  upload's rows (CustomerImport) do" → "every customer this route stores reaches CustomerFeed … Course 7, unit 26: CustomerRepository's add
  tells it, after its transaction commits - this class no longer does, and no longer takes CustomerFeed"; `add`'s "A stored customer is
  sent to every client listening to CustomerFeed first." → "A stored customer reaches CustomerFeed's listeners through the repository's
  event, after add's transaction commits."
- **`tiffinbox-web/…/DashboardPage.java`** — the call, the field and the constructor argument removed; "Stored: CustomerFeed's listeners
  hear the new customer (since the capstone, as they hear the JSON API's)" → "… hear the new customer from the repository's event, after
  add's transaction commits (Course 7, unit 26)".
- **`tiffinbox-web/…/CustomerImport.java`** — the call, the field and the constructor argument removed (RED #1201); "A row that is stored
  is told to CustomerFeed, as every new customer is." → "A row that is stored reaches CustomerFeed as every new customer does, through the
  repository's event after its add commits (Course 7, unit 26)."
- **`README.md`** (the anchor's) — a header note, the `## Course 7 · unit 26` section, and two history notes amended in place (Course 6
  unit 31's `DashboardPage` line and its "What this tree hands on": "the feed's events come from the web layer's adds" gains *(Course 7,
  unit 26: from the repository's `CustomerAdded`, after `add`'s transaction commits, since)*).

The R.250 gate, before any build: each of the five old sentences is in `before/` once and in `after/`'s sources and its unit 26 section 0
times; `feed.added` 3 calls in `before/`'s web classes, 0 anywhere in `after/`'s sources and that section; no `CustomerFeed feed` in the
three web classes; `CustomerRepository` `final` on `before/`, not on `after/`. `TiffinBoxWebTest` and `FullStackTest` are untouched: they
mock `CustomerRepository` (`@MockitoBean`), so its new constructor argument never reaches them — measured 18/18 (`tests`).

### TiffinBox — the 409, the 500, the 409 (S4.9)

One annotation, the same duplicate POST. **B** (labelled: `after/` with the rule taken off — a plain `@Transactional` on `add`, its one
line): `POST /customers` Kavya → 201; the same again → **500**; the server's log for it: `Participating transaction failed - marking
existing transaction as rollback-only`, `Initiating transaction commit`, `ERROR … TransactionInterceptor: Application exception
overridden by commit exception`, and the request failed with `org.springframework.transaction.UnexpectedRollbackException: Transaction
silently rolled back because it has been marked as rollback-only`. The import (Asha, a duplicate Ravi, Dev) → **500**: Asha's own add
committed before Ravi's refusal, Dev was never reached (`GET /customers` after: Asha, Kavya, Meera, Priya, Ravi, Sunil). B's eighteen
tests passed in its build — **the tests did not notice**. **A** (`after/`, `rollbackFor = SQLException.class`): 201, then **409**
(`a customer named Kavya already exists`), the import 200 `added 2` with `line 3` refused; `add`'s own line `Creating new transaction
with name [com.tiffinbox.CustomerRepository.add]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,-java.sql.SQLException`. **B′** and **A′**: the
same trees copied and built again, printing what B and A printed (R.1).

### The feed — Course 6's three adds, three events; and B′′ (⚑8, RED #1201)

A listener on `GET /customers/feed` (the anchor README's `curl -s -N` line, to a file), then the three adds of Course 6's *Capstone: The
TiffinBox Web App* — a JSON POST (Asha, 201), a form POST (Lata, 302 to the dashboard), an upload of one row (Dev, 200 `added 1`): **three
`customer-added` events**, Asha, Lata, Dev — the capstone's "three customer-added events", now from one publisher in core. **B′′**
(labelled: `after/` with `add`'s annotation line removed — the event published with no transaction around it): its tests, offline —
`FeedTest`'s `aListenerHearsANewCustomer` **ERROR `java.util.concurrent.TimeoutException`**, 18 run, 1 error. The after-commit listener is
skipped when no transaction is active (`events` shows the DEBUG line `No transaction is active - skipping`, silent at INFO).

### The listeners — four cases and the anchor's own (S4.10, `events`)

Each listener prints its thread, `TransactionSynchronizationManager`'s state and the second connection's read **inside it**:
- **A plain `@EventListener`** runs inside `publishEvent`, before the commit: `thread main · isActualTransactionActive true ·
  isSynchronizationActive true · the second connection sees the row false` — and it heard Zoe, whose transaction then rolled back (no
  after-commit call for Zoe; the after-rollback listener heard her, the row false).
- **`@TransactionalEventListener(AFTER_COMMIT)`** runs after the commit, on the same thread: `thread main · isActualTransactionActive
  true · isSynchronizationActive false · the second connection sees the row true`. Said as captured: `isActualTransactionActive` prints
  `true` inside it.
- **No transaction** around the publish (Ivan): both transactional listeners print nothing; the event package's DEBUG line says `No
  transaction is active - skipping`, twice; the plain listener still hears Ivan.
- **An AFTER_COMMIT listener that throws** (Omar): `ERROR … TransactionSynchronizationUtils : TransactionSynchronization.afterCompletion
  threw exception`; the caller returns normally; Omar's row is kept. **The Course 13 sentence (pinned, byte-equal in 26's script, R.252):
  "One transaction covers one database; a second system that must hear about the same change can fail after the commit."**
- **The anchor's own `CustomerRepository.add`** (after/'s, a CGLIB proxy now: `com.tiffinbox.CustomerRepository$$SpringCGLIB$$<n> ·
  isCglibProxy true`): `Creating new transaction with name [com.tiffinbox.CustomerRepository.add]:
  PROPAGATION_REQUIRED,ISOLATION_DEFAULT,-java.sql.SQLException`; a listener for its `CustomerAdded` hears Kavya after the commit, the row
  visible; a taken name (Ravi) rolls back by the rule and publishes nothing that is heard.

The order in which `publishEvent` calls the plain and the transactional listeners is not fixed (the brief's hazard; it moved between
runs in development): the harness's listeners carry `@Order` (the plain one first) so no hash depends on it.

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/before/tiffinbox-web/target/extracted/lib/*" harness/src/probe/t/AllX.java harness/src/probe/t/H.java harness/src/probe/t/Jta26.java harness/src/probe/t/Main.java harness/src/probe/t/Rb26.java harness/src/probe/t/Run.java harness/src/probe/t/Seed.java
javac -parameters -d .harness/hce -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/t/AllX.java harness/src/probe/t/H.java harness/src/probe/t/Jta26.java harness/src/probe/t/Main.java harness/src/probe/t/Rb26.java harness/src/probe/t/Run.java harness/src/probe/t/Seed.java harness/src/probe/t/ev/Added.java harness/src/probe/t/ev/Ev26.java harness/src/probe/t/ev/FeedListeners.java harness/src/probe/t/ev/FeedSvc.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../before/tiffinbox-web/target/extracted/lib/*" probe.t.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hce:../after/tiffinbox-web/target/extracted/lib/*" probe.t.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hce:../after/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
perl -pi -e 's/^    \@Transactional\(rollbackFor = SQLException\.class\)$/    \@Transactional/' .harness/anb/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
perl -ni -e 'print unless /^    \@Transactional\(rollbackFor = SQLException\.class\)$/' .harness/bpp/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.springframework.orm.jpa.JpaTransactionManager=debug
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

**The two `javac` lines** compile the harness twice with `-parameters`: `probe.t` (and `AllX`) against `before/`'s libraries into
`.harness/hc` (`rules`, `allexceptions`, `twowrites` — the rules are the framework's, measured on Section 3's frozen tree), and with
`probe.t.ev` and `probe.x` against `after/`'s into `.harness/hce` (`events`, `xcheck` — `probe.t.ev` reads the anchor's `CustomerAdded`,
which only `after/` has). **The three java lines** run the harness over `before/`'s libraries, over `after/`'s, and xcheck's context, from
`.harness/run` (`V` the JVM flags — the scenario `-Ds=rules|twowrites|events` — `A` the arguments, R.193, each printed as `$ V=(…)` / `$
A=(…)`; the labelled `allexceptions` adds `--spring.profiles.active=allx` to `A`), each under `perl -e 'alarm 240; exec @ARGV'` (R.247).
**The `perl -pi` line** makes anchor B (the rule taken off `add`), **the `perl -ni` line** makes B′′ (`add`'s annotation line removed);
the script asserts each copy differs from `after/` by that one line and nothing else. **The two run lines** are the README's run line
with one logger option: the transaction manager's DEBUG lines for `anchor`, Hibernate's SQL logger for `seven`. The lines read from
`after/README.md` (10, each asserted whole) are its package, test, extract and run lines, its token line, and its JSON POST, form POST,
import, list and feed `curl` lines (the port replaced, `--noproxy '*'` put in: the loopback).

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; s4 = s3, the brief). Six Maven runs before the captures —
`before/`, `after/` and B with their tests (each build's summary lines summed and asserted 18 · 0 · 0 · 0), B′ and A′ with `-DskipTests`
— and two inside captures, three times each: `tests` (`after/`) and `feed`'s B′′; every one `offline: yes`, 0 `Downloaded from` lines.
After the builds the script asserts `.m2-demo` holds Boot's parent 4.1.2, `hibernate-core-7.4.13.Final.jar`, `spring-data-jpa-4.1.2.jar`,
`spring-tx-7.0.10.jar` and `h2-2.5.250.jar`. **At run time** the harness binds no port; every database is H2 in a JVM's memory
(`jdbc:h2:mem:u26`, xcheck's `x26`, the exercise's `ex`, TiffinBox's own generated name, masked `<uuid>`); TiffinBox listens on
`127.0.0.1` only and is asked by `curl` on the loopback. **No network act**: the section's dated sweep is the brief's
(`_research/spring-boot-metadata-2026-11-10.xml`, `spring-data-bom-metadata-2026-11-10.xml`: the 4.1 line ends 4.1.2, `4.2.0-RC2` not GA
— ⚑6, R.223). Spring Framework's version is printed by every harness JVM from `spring-tx`'s manifest (`7.0.10`), beside Spring Data JPA's
(`4.1.2`), `Version.getVersionString()` and Hibernate's `HHH000001` line (S4.13), before the context starts.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `before` → `../c7-unit17/after` (a link; `readlink` asserted); `after/` — this unit's tree, `../c7-tiffinbox` at this commit. Neither is
  built in place.
- `harness/` — `src/probe/t/Main.java` (unit 23's form: a Spring Boot context, `WebApplicationType.NONE`, `@EntityScan` and
  `@EnableJpaRepositories` on `com.tiffinbox` — `Found 1 JPA repository interface.`; the three version lines first), `Run.java` (the
  `rules` and `twowrites` scenarios: per row the seed again, `>>> row …` / `<<< row …`, the method called by name through its bean's proxy),
  `Rb26.java` (Spring's annotation, nine methods), `Jta26.java` (JTA's, three), `AllX.java` (the profile `allx` only), `H.java` (the helpers:
  the chain, the method's print, the second connection — `rows()`, `has()`, `pauses()`, and `where()`, a listener's thread and state),
  `Seed.java` (unit 23's); `src/probe/t/ev/` (`Ev26.java` — the `events` scenario, importing the anchor's `CustomerRepository` as a bean;
  `FeedSvc.java`, `Added.java`, `FeedListeners.java`); `src/probe/x/XMain.java` (xcheck's context, unit 24's byte for byte);
  `src/probe/t/ex/ExApp.java` (the exercise's, compiled only by the exercise); `logback.xml` (one line per event, no stack trace;
  `org.hibernate.SQL` and `JpaTransactionManager` DEBUG, the transaction interceptor TRACE, the transaction event package DEBUG, the
  version and start lines at INFO, the rest WARN); `dur7.py` (the builders', byte for byte, md5 `41667fed…`); `surefire.py` (the testing
  lesson's, `../c6-unit28/harness/surefire.py`, byte for byte). English names only (R.215): Ravi, Meera, Sunil, Priya, Asha, Dev, Nina,
  Omar, Tara, Zoe, Ivan, Mia, Ella, Lena, Kavya, Kira, Lata.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `before`, `after`, `anb` (B), `anb2` (B′), `ana2` (A′), `bpp` (B′′), `tests` (each a copy,
  built or tested there, each with its `secrets/`), `hc`, `hce`, `run`, `customers.csv` (the import's three rows), `feedrow/customers.csv`
  (the feed's one row), `rows.py`, `ex`, the logs. `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 20050-20059):** 20050 anchor B · 20051 anchor A · 20052 B′ · 20053 A′ · 20054 `feed` · 20055 `seven` before/ · 20056
  `seven` after/ · 20057 unused (the brief's `xcheck` port: `probe.x.XMain` binds none) · 20058 unused · 20059 never bound. All ten, 18425
  (TiffinBox's default), 8080 and 35729 are checked free at the start and the end; each start checks its own port free first.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): the generated token → `[masked: the token]`; this folder
→ `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; an
EntityManager's identity → `SessionImpl(<n><open>)`; a lambda class's address → `$$Lambda/<n>`; Spring Data's scan figure → `<n>`;
TiffinBox's generated database name → `jdbc:h2:mem:<uuid>`; an application context's `started on <date>` (in the event package's DEBUG
lines); H2's constraint names → `CONSTRAINT_<n>` / `CONSTRAINT_INDEX_<n>`; a 500 body's `"timestamp"` → `<time>`. Filters: a harness
JVM's log is printed whole (trailing spaces dropped); TiffinBox's log per request (`req`): the transaction manager's create / commit /
rollback / mark lines, the interceptor's, Hibernate's refusal, WARN and ERROR, and a failed request's exception from the dispatcher's
`Request processing failed:` line; a JSON answer without its two number fields; the seven by the comparison set's lines. Hygiene, over
every capture: raw token copies 0 (each raw run counted before the mask, and every capture, log and file after); no absolute path, unit
number (the anchor capture's quoted diff lines aside), log time, timestamp, thread number, a context's start date, JDK or OS token,
figure of elapsed time, stack frame, unmasked identity, lambda address or generated name, URL but TiffinBox's own loopback ports
(`127.0.0.1:20050`-`20056`); every JVM pinned and under its alarm; no kill by name, no bare `wait`; no `Thread.sleep` in the harness
(S4.18); no H2 database file outside `.harness` (R.195); no dish name (R.215). The prose gates, before any build: no duration word (dur7,
R.172) **and no duration meaning** (S4.7's family, R.264; `_builders/dur7.py` is not edited); no dish name; no placeholder line and no
empty "What it prints" block; **S4.10's reading** — a sentence that says the transaction has ended (or that the listener runs outside it)
is refused unless it negates or quotes `isActualTransactionActive`, over this README, `exercise/`, `after/README.md`'s unit 26 section and
the three event sources, with an eight-case self-test; no SQL string in this README (R.225); **R.250's sentence set** (above).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid` — a harness JVM or
TiffinBox), the feed's listener (`$lpid`, a `curl`), the Maven or the `javac` it waits for (`$mpid`, with every process under it), the
exercise's shell (`$xpid`), sweeps its own process group for any harness, exercise or TiffinBox JVM, listener, Surefire fork, `javac` or
Maven left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured (2026-11-11, on scratch mirrors of this folder — its files and `.m2-demo` cloned, `c7-unit17`, `c7-unit09`, `c7-tiffinbox`,
`c5-unit11` and `c6-unit28` linked; the script as committed, the published captures copied in):** `receipts.sh` (/bin/bash 3.2) started
`env -i` in a session of its own **with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to
its group once the named process was in it, the state read 5 s after its exit — four trials:

```
build (surefirebooter seen: 2): processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness (probe.t.Main seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
tiffinbox (tiffinbox.port=2005 seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
listener (/customers/feed seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — `before/`'s Maven build, its Surefire fork running; `harness` — the first harness JVM (`rules`, `probe.t.Main`); `tiffinbox` —
TiffinBox's first start in `anchor` (B, port 20050); `listener` — the feed's `curl -N` with TiffinBox on 20054. `pgrep -x java`
afterwards: none.

## 1 · rules — the ten rows (S4.1, S4.2)

One harness JVM over `before/`'s libraries, Boot's `JpaTransactionManager` as built, no profile. For each row: the seed again, the call
through the bean's proxy, its chain if it threw, the second connection's read, the row line. The table above is `rows.py`'s output.

## 2 · allexceptions — LABELLED `allx` (S4.13)

The same ten rows with the profile `allx` (labelled in the capture's own header, the profile read back by the context), then `javap -v`
over `spring-tx-7.0.10.jar` (`rollbackOn()`'s `AnnotationDefault`) and `javap -p` over `spring-boot-transaction-4.1.2.jar`
(`TransactionProperties`' fields). The version lines (Framework 7.0.10) are in the same capture (S4.13).

## 3 · twowrites — a customer, then a checked failure before her pause

`Rb26.twoWrites(Kavya)` saves Kavya, then reads a pause file that is missing — `java.io.FileNotFoundException: pauses.csv (the pause file
is missing)`, checked — before her pause is written: **Kavya KEPT, her pauses 0** (the second connection's two reads after the call).
With `rollbackFor = Exception.class` (Kira): gone, pauses 0.

## 4 · events — the listeners (S4.10)

One harness JVM over `after/`'s libraries (the cases above). Each case runs on a fresh seed between `>>> case …` and `<<< case …`; every
listener line is printed from inside the listener.

## 5 · anchor — the change, and TiffinBox A/B/A′/B′ (S4.9, the failure receipt)

The change (`diff -rq` and each file's diff, whole), then four TiffinBox starts, each its own tree and port, each asked the same three
requests (POST Kavya, the same again, the import) and `GET /customers`, each stopped by its pid (SIGTERM, exit 143). The checks: the
change's file list and its key lines; B's 201 · 500 with the interceptor's ERROR and the `UnexpectedRollbackException`, B's import 500
and its names after; A's 201 · 409, the import 200 `added 2`, its names after; `add`'s attribute line on each; B′ = B and A′ = A but their
ports and trees (R.1).

## 6 · feed — three adds, three events; B′′ (⚑8)

`after/`'s jar on 20054; the listener started and its `:listening` line awaited before the first add; the three adds; the data lines
awaited (3); TiffinBox stopped (SIGTERM) — its graceful shutdown ends the stream, and the listener's `curl` exits 0. Then B′′'s tests:
Surefire's reports read by `surefire.py` — `FeedTest` ERROR `TimeoutException`, the other 17 passed.

## 7 · seven — before/ and after/, a guard (R.190, RED #1214)

Each tree's jar with Hibernate's SQL logger on, a fresh JVM, the comparison set (`../c5-unit11/curlset.sh`, POST /shutdown last). The
seven `466c20ed7e0d5439cb052f32ce09de1b` on both, 0 lines differ, and Hibernate's SQL lines — in the log and during the seven — the same
on both trees, with the same statements (C1 adds no SQL to the seven's routes: none of them adds a customer).

## 8 · tests — TiffinBox's eighteen, on after/ (C7-4)

`after/` copied to `.harness/tests`, `mvn -B clean test` offline: `TiffinBoxWebTest` 14, `FullStackTest` 3, `FeedTest` 1 — 18, 0 failures,
0 errors, from Surefire's reports, the console's summary the same. `TiffinBoxWebTest` and `FullStackTest` mock `CustomerRepository`
(`@MockitoBean`, one line each); `FeedTest` runs the real one — and so the real event and listener.

## 9 · xcheck — the harness's DDL script over after/, against the owning-side lesson's (R.212, R.252)

`probe.x.XMain` (`@EntityScan("com.tiffinbox")` alone) over `after/`'s libraries, `scripts.action=create`: two `create table` lines and one
`alter table`, md5 `f595637014e786fa38606859951e4f97` = unit 09's (its README names it, its published xcheck capture asserted) — no
mapping moved (RED #1214). The DDL callback sentence (R.252) is the shared one: "…the same hash as in the lesson called One To Many, Many
To One and the Owning Side."

## 10 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196, S4.16)

The README's lines, then the solution's, in one `env -i` shell, `/bin/bash --noprofile --norc`, then `/bin/zsh -f`; each file's "What it
prints" block compared with the run line for line, bash and zsh asserted equal; the end states checked first. **Broken** (as shipped):
`SignUp.signUp` (`@Transactional`) saves Kavya through TiffinBox's own repository, then a checked `FileNotFoundException` leaves it —
`Initiating transaction commit`, five rows, Kavya kept. **Solved** (one line: `@Transactional(rollbackFor = Exception.class)`): the same
exception, `Initiating transaction rollback`, four rows, Kavya gone — the `rules` capture's second row. The same exception kind and call
path in both (S4.16).

## Exercise

`exercise/README.md` — "Your turn: the README's method fails with a checked exception and the customer is still saved. Make it roll
back." (20 words by `wc -w`, R.203 ≤ 25.) `exercise/SOLUTION.md` — the one changed line and what it prints.

## The ledger rows and hand-offs this unit pays

- **C7-15** (the feed hears the web layer's adds only) — **paid**: one repository-level event, `CustomerAdded`, published inside `add`'s
  transaction and heard by `CustomerFeed` after the commit (`anchor`, `feed`: three adds, three events; `FeedTest` B′′).
- **C7-19** (Course 4 unit 26's on-screen chip "named, not covered: `@TransactionalEventListener` — after the publishing transaction
  commits; with the data courses") — **paid**: `CustomerFeed`'s `@TransactionalEventListener` (`events`, `feed`); the script names the
  chip as paid, calling back Course 4's *Conditional, Ordered and Async Listeners* by title.
- **C7-4** ("TiffinBox has tests now", 18) — **re-run**: 18 after the change (`tests`), and 18 on B (its build) — carried to U39.
- **Course 13 (the outbox) — pinned**: the throwing after-commit listener (`events`, Omar: committed row, failed listener, no rollback);
  the sentence "One transaction covers one database; a second system that must hear about the same change can fail after the commit."
- Called back by title, no new gloss (R.204, R.224): Course 4's *The Event Publisher: Delete a Dependency* (an event listener) and
  *Conditional, Ordered and Async Listeners* (the chip); the lesson called *@Transactional: What the Proxy Does* (unit 23 — the `final`
  refusal this change answers); Course 6's *Capstone: The TiffinBox Web App* (the three adds the `feed` capture replays).

## RE-MEASURE — the brief's items this unit settles

- **#1** (the exercise as README + SOLUTION files, bash + zsh, `env -i`) — settled for 26: `exercise`.
- **#4** (C1 on the frozen tree with its Javadoc/README sentence set, R.250) — settled: `after/`, the R.250 gate, `anchor`.
- **#8** (the Course 13 sentence's capture) — kept in the harness (`events`, Omar): the throwing listener is the harness's, beside the
  anchor's own `CustomerRepository.add` and a harness listener for its `CustomerAdded`; `CustomerFeed` itself is never made to throw.
- **#9** (C6/31's three adds → three `customer-added` events on 26/after; the dead `feed` fields and arguments removed; 18/18) — settled:
  `feed`, the R.250 gate, `tests`.

## What differed from the brief

- **B is `after/` with the rule taken off** (one line: `@Transactional(rollbackFor = SQLException.class)` → `@Transactional`), not `before/`
  with `final` dropped and a plain annotation (the brief's words for B, the probe's sT1). B and A then differ by the rule alone — the
  lesson's one variable — and B carries the event too, so its 500 is the rule's and nothing else's. Its eighteen tests run in its build
  (the brief: "the tests did not notice"); B′ is B copied and built again (`-DskipTests`), A′ `after/` copied and built again.
- **B′′ is `after/` with `add`'s annotation line removed** (the probe's sT4 shape on the C1 tree): the event is still published, with no
  transaction; its tests run (`mvn -B clean test`, the README's line) inside the `feed` capture, three times.
- **The import runs inside each anchor start** (B, A, B′, A′ — after the two POSTs), not in a JVM of its own; **port 20054 is `feed`'s**
  (the brief listed 20054 "import"). 20057 (the brief's `xcheck`) and 20058 stay unused: `probe.x.XMain` binds no port.
- **B's import answers 500 after Asha's own add committed** — `add` is its own transaction per row, so Asha (row 1) is stored, Ravi's
  refusal turns into the commit's `UnexpectedRollbackException`, the request fails, and Dev (row 3) is never tried: `GET /customers` after
  B lists Asha. The brief said "import 500"; the stored Asha is the capture's.
- **The harness is compiled twice** (`hc` over `before/`'s libraries, `hce` over `after/`'s): the rules are measured on Section 3's frozen
  tree (the brief: `rules`/`allexceptions`/`twowrites` over 17/after), `events` and `xcheck` on this unit's (the brief: `events` over
  26/after). `xcheck` runs over `after/`: the DDL is the anchor's own after the change.
- **The Course 13 sentence and S4.7's family.** BLUE's duration-meaning family refuses an article or a number before `second` (the family's number-and-unit part),
  and the pinned sentence has one, before `system`. The duration gate takes that one sentence, whole and byte for byte, out of a line before
  the family reads it (an assertion in the gate proves the family would refuse it otherwise); nothing else is exempt. **The 26 builder
  needs the same exemption** — For RED.
- **The listeners carry `@Order`** (the plain one `@Order(1)`, the transactional ones `@Order(2)`): without it the plain listener's line
  moved against the transactional ones' "Registered transaction synchronization" lines between runs (the brief's hazard: "the
  listener's order against the plain listener is not fixed") and `events` drifted in development.
- **`events` adds two cases to the brief's four:** a transaction that rolls back after publishing (Zoe: the plain listener heard her; the
  after-rollback listener heard her, the row false) and the anchor's own `CustomerRepository.add` (Kavya heard after the commit; a taken
  name rolled back, nothing heard).
- **The 409 body** is TiffinBox's ProblemDetail as Jackson writes it (`detail`, `instance`, `status`, `title` — sorted): read off the
  capture, not the order the brief or Course 6 typed.
- **The feed's three adds** are the anchor README's own JSON POST (Asha), form POST (Lata) and import line (one row, Dev, in
  `.harness/feedrow/customers.csv`) — the capstone's three kinds of add; the form's 302 `Location` is absolute
  (`http://127.0.0.1:20054/dashboard`, as Tomcat writes it).
- **Two README history notes amended in place** in `after/README.md` (Course 6 unit 31's `DashboardPage` line and "What this tree hands
  on"), per the anchor README's own rule ("the history notes a Course 7 unit makes false: each is amended in place").
- **The anchor was moved before the runs of record** (`rsync -a --delete` of `after/` into `../c7-tiffinbox`, `.m2-demo`/`target`/
  `secrets`/`.harness` excluded): the anchor note is empty at the start and the end of every run of record.
- **The re-run of `../c7-unit17` and `../c7-unit22` ran side by side** (their ports 19960-19969 and 20010-20019 do not meet).
- **No network act**; the push at the end is the only one. The start's `main...origin/main` = `0 0` was read from the local refs.

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror of this folder (its files and `.m2-demo` cloned; `c7-unit17`, `c7-unit09`, `c7-tiffinbox`, `c5-unit11`,
`c6-unit28` linked), `env -i`, a session of its own, `/bin/bash` 3.2; each **exit 1**, `receipts.md5` and `README.md` unchanged (nothing
written). A plant marked † also takes, in its mirror only, the captures before the one it targets out of the script (and, for the two
derived copies, the check that the copy differs by its one line — which catches the plant first when left in), so the targeted check is
the one that fires.

| plant | caught by |
|---|---|
| A without `rollbackFor` (the rule taken off `.harness/after` and `.harness/ana2` after B's derivation; † `rules`…`events` out, B's one-line check out) | `anchor A: the duplicate POST - 409, as before the change: {"timestamp":"<time>","status":500,…} 500` — while after/'s build printed its 18 tests 0 failures (said: the tests did not notice) |
| the same plant with B's one-line check left in | `anchor B: the one line` (B's copy no longer differs from A) |
| the after-commit listener as a plain `@EventListener` (`FeedListeners.afterCommit`) | `events: AFTER_COMMIT - the same thread, the row visible, …: … isSynchronizationActive true · the second connection sees the row false` |
| B′′ keeping `add`'s `@Transactional` (L_BPP not run; † the copy's differ-check and its one-line check out; `rules`…`anchor` out) | `feed B'': FeedTest must fail with TimeoutException - …: none` (FeedTest passed) |
| "the transaction has ended" in this README (S4.10) | the S4.10 sentence gate, the sentence quoted |
| a stale feed sentence in `after/`'s `TiffinBoxServer` Javadoc ("A stored customer is sent to every client listening to CustomerFeed first.") | R.250: `after/ still states the old mechanism: …` |
| a `feed.added(customer)` call left in `after/`'s `CustomerImport` (the line alone) | R.250 (RED #1201): `a feed.added call or sentence left in after/: …CustomerImport.java:90` |
| `before/`'s whole `CustomerImport.java` in `after/` (the field, the argument, the call, the old Javadoc) | R.250: the old sentence, first |
| a wrong published hash (`rules`) | `rules is not the published capture` |
| no Spring Framework version line (S4.13; `Main.java`'s print removed) | `rules: the version lines … (S4.13)` |
| an Indian dish name · a to-do marker line · a typed INSERT · a duration meaning from S4.7's family | the dish, placeholder, typed-SQL and duration gates, before any build |
| a changed "What it prints" line (exercise/README.md, the after line; † every capture but `exercise` out) | the exercise's line-for-line comparison |
| a wrong unit 09 md5 (`X09`) | `../c7-unit09/README.md must name … (R.212)`, before any capture |

Not run: a planted `fallbackExecution = true` (not measured, CARRIED); a plant on `TiffinBoxWebTest`/`FullStackTest` (untouched).

## The anchor moved on — the re-runs of 17 and 22 (R.211, RED #1200)

`grep -n c7-tiffinbox` before the commit (R.211, the brief's EVIDENCE BATCHES): `_builders/s701.py` and `s702.py` (prose only),
`s703.py`, `s706.py`, `s707.py`, `s709.py`, `s715.py`, `s717.py` (each asserts `after/` against `git show <sha>:c7-tiffinbox/<p>` and prints
`note:` on a live diff); `check_unit7.py` and `qa_java7.py` — no line. **`s717.py` run once after the move** (a scratch copy of it with
`_builders/dur7.py` beside it, so its `OUT` is the copy's folder and nothing is written into the course): exit 0, seven `note: c7-tiffinbox
has moved on since f620c1a (a later change to the anchor); after/ is checked against f620c1a: …` lines (README.md, CustomerAdded.java,
CustomerRepository.java, CustomerFeed.java, CustomerImport.java, DashboardPage.java, TiffinBoxServer.java), then `anchor: after/ =
f620c1a:c7-tiffinbox in its 4 changed files; diff -rq against the live c7-tiffinbox: 7 lines` — the expected sign.

**`../c7-unit17/receipts.sh`** (unchanged, md5 `a24fdfdb550ef69eb12b395995853190`) and **`../c7-unit22/receipts.sh`** (unchanged, md5
`0a02855994dd3c22790faa3bcfe6b58b`), each run once on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, a session of its
own, side by side from 20:29:15 CET: **17 exit 0 in 457 s, 22 exit 0 in 258 s**; each printed its note at its start and its end
(`(after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files after/README.md and
../c7-tiffinbox/README.md differ;Only in ../c7-tiffinbox/…: CustomerAdded.java;…)` for 17, `(anchor/ and ../c7-tiffinbox differ - the
anchor has moved past the tree this unit reads: …)` for 22), all captures 3/3 = published (9 and 7), `receipts.md5` unchanged, each log
through `check_unit7.py --runlog` PASS. RED #1200's other receipts (15, 16, 18-21, 23-25) print their notes the same way and were not
re-run. The dated "Re-run after unit 26 moved the anchor" paragraph is in `../c7-unit17/README.md` and `../c7-unit22/README.md`.

## CARRIED

- **`_builders/dur7.py` and S4.7's duration-meaning family** — still the tooling's (the brief's CARRIED); this unit's gate carries it.
- **`fallbackExecution = true`** (⚑8's loser C) — not measured; only if a later lesson publishes outside a transaction.
- **27 moves the anchor again** (C2, `@Version`): this unit's `anchornote` then prints its note; `after/` stays this unit's tree.
- **The outbox** — Course 13, pinned above.

## For RED

- **The Course 13 sentence vs S4.7's family:** its ordinal before `system` is refused by the family; this gate exempts the pinned sentence, whole,
  byte for byte, and nothing else. The 26 builder must carry the same exemption (or the sentence must change — which would break R.252's
  byte-equality; Vivek's call only if RED disagrees).
- **S4.9:** the witnesses differ between B and A (the duplicate's 500/409, the import's 500/200, `add`'s attribute line); the guards
  (the seven, its SQL statements, the 18 tests, the DDL md5) are equal — the plant "A without `rollbackFor`" fails on the 409 while
  after/'s 18 tests pass.
- **S4.10:** every listener line is printed inside the listener; `isActualTransactionActive true` inside AFTER_COMMIT is said as captured.
  `isSynchronizationActive false` there is the reason a listener cannot register a further synchronization — not measured as a claim.
- **B's import stores Asha** before the 500 (each row's add is its own transaction): a slide that says "the import lost everything" is
  wrong for B.
- **The listeners' `@Order`** is the harness's; `CustomerFeed`'s listener carries none (one listener per phase in TiffinBox).
- **`TiffinBoxWebTest` and `FullStackTest` mock `CustomerRepository`:** the event path is covered by `FeedTest` alone (B′′).
- **Not measured here:** PostgreSQL (⚑2: H2 only for 26); `fallbackExecution = true`; a throwing `CustomerFeed` itself (the Course 13
  case is the harness's listener).

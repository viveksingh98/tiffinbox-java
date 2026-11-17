# c7-unit40 — What's Next: Not Everything Is a Relation

Course 7 · Data with JPA & Hibernate · Section 7 (Close), its last unit, and the course's · Verified on **JDK 25.0.4.1** (for
`../c6-unit32/receipts.sh`, which builds), git 2.54.0, Python 3.14.7, Apache Maven 3.9.16 (c6-unit32's build), /bin/bash 3.2.57 and
Homebrew bash 5.3.9, 2026-11-17. The finale: the repository's front page finally names this course, and **Course 6's finale's published
receipt fails three of its own checks on that page — until its readme capture is pinned to the commit it measured**; then every count
the course earned, read back from its own files, and the next course, *Spring Data beyond JPA*, named by its own titles — whose Redis
and document sections are where not everything is a relation.

**No anchor change.** `anchor` is the link to `../c7-unit39/after` (= `c7-tiffinbox`, Course 7's final anchor and the tree the next
course starts from; its tree's hash pinned by `harness/tree40.py`, unit 33's `tree33.py` byte for byte; R.211's `diff -rq -x .m2-demo
-x target -x secrets -x .harness anchor/ ../c7-tiffinbox` printed at the receipt's start and end — empty, the note form kept in the
script, never fired). No database, no JVM of TiffinBox's, no container, no exercise, no `xcheck.sql` (the finale's precedent:
c6-unit32 shipped none). **Four files outside this folder change, in this unit's commit — the course's one approved exception to "one
unit folder per commit" (contract §5, R.176, S6.15, ledger C7-13):** the repository's root `README.md` (Course 7 joins its title, its
folder map and its course sections; the roadmap line byte-identical), and Course 6's finale's `../c6-unit32/receipts.sh` (its
`readmecap` pinned to `828e395`), `receipts.md5` (that capture's republished md5) and `README.md` (told, R.73). Course 6's video is
unchanged. Course 5's finale, `../c5-unit30/`, is not touched: it reads pinned commits only since `b50b410`.

```
./receipts.sh     # c6-unit32's receipt re-run whole, then 2 captures, 3 runs each; every number asserted by harness/chk40.py
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top, for c6-unit32's build.) It **dies** when a capture's md5
differs from `receipts.md5` — but for `counts` on a clone whose neighbours are absent (below, "The repository"). It needs a **full
clone** (it reads `828e395`, `0458d2b`, `53379bd` and `06ae5dd` with `git show`). **Start it in a process group of its own** (a
terminal's foreground job is one): its clean-up sweeps its own group, and c6-unit32's receipt, which it starts, sweeps the same group.

<!-- runs: begin -->
**Runs of record (2026-11-17), each `env -i` (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`) and a process
group of its own, on the script as committed (`receipts.sh` md5 `f203db165565df1d493771d19c10f096`):** 62 s under `./receipts.sh`
(/bin/bash 3.2.57, from 08:52 CET) and 64 s under `bash receipts.sh` (Homebrew bash 5.3.9, from 08:53 CET): each exit 0, c6-unit32's
receipt re-run exit 0 with both its captures = published (`offline: yes`), both captures here 3/3 = published, every check of
`harness/chk40.py` passed, the anchor's tree pinned and its `diff -rq` empty at the start and the end, nothing listening on 20190-20199
or 19610-19612/19619 at the end; each terminal log through `check_unit7.py 40 --runlog` — `RESULT (run logs): PASS` (the unit gate:
no unit 40 script yet, so its `finale_gate` does not run — the build stage's). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `06ae5dd` into a path **with a space** (`…/sealed
40/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard README.md c6-unit32 c7-unit40`, the link kept, each `cmp`-equal); c6-unit32's `.m2-demo` absent (git ignores it);
Maven sealed by c6-unit32's own recipe (a `file://` copy of `spring-web-mvc/_research/m2-seed-s6/`, dead proxies for http and https;
its pre-flight exit 1, `Downloading from sealed: file://` only); `env -i` with the sealed `HOME`: **exit 0 in 66 s**; c6-unit32's build
`offline: no` (its empty `.m2-demo` filled from the sealed mirror: `_remote.repositories` all `>sealed=`, 0 from http(s)), both its
captures = published; `readme` 3/3 = published; **`counts` 3/3 and different from the published hash, as expected there** — the
registry, the roadmap, Course 6's finale's script and the course's scripts are not beside that clone, and its capture prints a note for
each (every in-repository count asserted the same); `check_unit7.py 40 --runlog` PASS. The three runs ran on this README before this
paragraph, the interrupt paragraph and the plants list were written (the only changes since; a fourth run on the final text is in the
commit message).
<!-- runs: end -->

Published hashes (`receipts.md5`, both captures 3/3 in every run):

```
readme fcbf0ce27cdd4fd0184ab8367d76226c
counts d54549257ecbe0a80eca940c3f57bc0f
```

**The values the video may say** (each read by a program off a file or a run and asserted by `harness/chk40.py`; none typed):

<!-- values: begin -->
the values the video may say: the front page - Course 7 joins the title, the folder map (c7-unitNN/) and the sections (2 3 4 5 6 7), the roadmap line byte-identical, the README +10 / -3 lines against 828e395 (git's numstat); Course 6's finale pinned - readmecap's five reads of ../README.md read git -C .. show 828e395:README.md (4 lines, 6 occurrences with its $ line, 0 reads of ../README.md left), its readme 4e4241ddf3eb8a044c7762a1938ee54f -> 68a6fc68d166b539919751ffe4774324, its memory 5673a1507c1e1980401d21adb4b3e504 unchanged, its whole receipt exit 0; Course 5's finale 4456fd199c0cc10b1647683ea7526015 = published, untouched; the unpinned function from 06ae5dd on the edited README: three FAIL lines - the folders now, the sections now, the title names Spring Web MVC - and md5 626d2ae87e9a2305fab2ba1f8880c2f8, not 4e4241dd · counts: 15 c7-unitNN/after folders (03 06 07 09 15 16 17 26 27 29 31 34 36 38 39), 12 before Section 6 and 3 in Sections 6-7; 40 unit folders; the DDL lineage 9cf92b8c (27 29 30 31 32 33) -> 7f6942f0 (34-37) -> f4f15b9c (38 39), 12 files, 3 hashes; tests 18 (unit 36) -> 18 + 3 = 21 (unit 39); the pinned sentences 3 + 1 + 1 lines; unit 20's API line; 289 captures in 39 units (35 · 68 · 57 · 48 · 47 · 28 · 6 per section); the registry 40 lessons, 7 sections (ORM from First Principles · Mapping · Querying · Transactions · Performance · Schema and Lifecycle · Close); Course 8 Spring Data beyond JPA, 28 units · 5 sections, U01 Why Another Data Module, U02 Aggregates, Not Entities, U07 Testing the JDBC Layer, S3 Redis as a datastore, S4 Document and search, U18 MongoDB: Documents, Not Rows; C7-12 nothing to correct; the retirement 0 of 34 scripts
<!-- values: end -->

## The repository, and the network

This unit's receipt downloads nothing and builds nothing. **c6-unit32's receipt, which it re-runs, builds the Course 6 anchor once** into
c6-unit32's own `.m2-demo`, offline (`offline: yes` in every run here: that folder was seeded from
`../../spring-web-mvc/_research/m2-seed-s6/` when Course 6 measured it; on a fresh clone it is empty, and c6-unit32's own run paragraph
gives the sealed mirror). Nothing leaves the machine.

**Read outside the repository, when it sits beside it** (unit 37's precedent for the roadmap): the registry
`~/Desktop/PromptVidya-Automation/java7_series.py`, the roadmap `../../_briefs/TRACK-ROADMAP.md`, Course 6's finale's script
`../../spring-web-mvc/scripts-and-decks/32-whats-next-where-the-data-lives.md` (C7-12) and this course's scripts
`../../data-jpa-hibernate/scripts-and-decks/` (the retirement's grep). **The published `counts` capture is the full run beside the
repository**; a clone elsewhere prints a note per absent file instead of the read, its `counts` md5 then differs from the published one
and the receipt says so instead of stopping (it is the only capture that may), every in-repository count is still asserted, and
`check_unit7.py --runlog` still passes. The sealed clone's run below is that case.

## The folders, the harness and the ports

`anchor` → `../c7-unit39/after`; `harness/`: `chk40.py` (the checks, each capture's lines against a second witness this program reads
itself — git, the files the capture read), `s40.py` (the prose gate, unit 39's `s39.py` carried with the finale's readings and a
self-test), `dur7.py` (the builders', as shipped), `tree40.py` (unit 33's `tree33.py`, byte for byte). No exercise (contract §7: the
finale is exempt; `check_unit7.py` skips the last unit) and no `xcheck.sql` (no anchor change, c6-unit32's precedent). **Ports: none
of this unit's own** — 20190-20199 asserted free at the start and the end; c6-unit32's receipt binds its own 19610, 19611 and 19612 while
it runs, and those and its 19619 are asserted free before and after it.

## Masks, filters and hygiene — every one, declared

None but the paths: the captures print the repository's files by paths relative to this folder (`../README.md`, `../c7-unitNN/…`,
`../../_briefs/TRACK-ROADMAP.md`) and the registry by its home path (`~/Desktop/…`); `cap()` refuses an absolute path in a capture.
The demo token of c6-unit32 is its receipt's business: its own mask, its own count of raw copies (0, asserted by it). The word for the
container engine appears 0 times in `receipts.sh` (its own self-check, first).

## 1 · readme — the front page, and the two finales' captures of it (the failure receipt is part 4)

(1) `../README.md` read live through this unit's `view()` (c6-unit32's form: line 1, the folders lines 1-5 map, the course sections,
the roadmap line) beside the same lines of the README as `828e395` (Course 6's finale's commit) left it; the roadmap line the same in
both; the lines gained and lost, which `chk40.py` compares with `git diff --numstat 828e395`; the `## Course 7 — Data with JPA &
Hibernate` section, whole. (2) **Course 6's finale's `readmecap`, pinned by this commit**, cut out of its shipped `receipts.sh` and run
from its own folder with the variables its script sets: its pinned reads counted, 0 reads of `../README.md` left in the function, its md5
= its `receipts.md5`. (3) **Course 5's finale's `readmecap`**, the same way: still its published `4456fd19…` (C7-13's first half
stands). (4) **The failure receipt, labelled — the hook:** the UNPINNED `readmecap`, its `receipts.sh` as commit `06ae5dd` had it
(from git), run from c6-unit32's folder on the README as it is now, then that file's own readme checks on what it printed: **three
FAIL lines**, quoted here as the hook,

```
    FAIL readme: the folders now: expected the line:   the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/
    FAIL readme: the sections now: expected the line:   its course sections: 2 3 4 5 6
    FAIL readme: the title names Spring Web MVC
```

and its md5 not the `4e4241dd…` that commit published (the probe of 2026-11-16 saw another md5 on its own sketch of the README; this
README's text gives `626d2ae8…`; only "not equal" is asserted).

`.r-readme.out` · md5 `fcbf0ce27cdd4fd0184ab8367d76226c` · 3 of 3

```
1 · the repository's README as it is now, read live:
$ cat ../README.md
  line 1: # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core*, *Spring Boot*, *Spring Web MVC* and *Data with JPA & Hibernate* (Learn Programming with Vivek)
  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/ c7-unitNN/
  its course sections: 2 3 4 5 6 7
  its roadmap line: 470:Videos publish a few per day on the channel. Roadmap (19 courses): Java Fundamentals → Core Java II → Build & Test Like a Pro → Spring Framework Core → Spring Boot → Spring Web MVC → Data with JPA & Hibernate → … → Spring AI.
and as Course 6's finale's commit left it:
$ git -C .. show 828e395:README.md
  line 1: # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core*, *Spring Boot* and *Spring Web MVC* (Learn Programming with Vivek)
  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/
  its course sections: 2 3 4 5 6
  its roadmap line: 463:Videos publish a few per day on the channel. Roadmap (19 courses): Java Fundamentals → Core Java II → Build & Test Like a Pro → Spring Framework Core → Spring Boot → Spring Web MVC → Data with JPA & Hibernate → … → Spring AI.
  the roadmap line, the same in both: yes
  lines the README gained: 10 · lines it lost: 3
its Course 7 section, whole:
  ## Course 7 — Data with JPA & Hibernate
  **TiffinBox on JPA and Hibernate**, in `c7-unitNN/` (40 units, 7 sections), with the long-lived project in `c7-tiffinbox/`: the SQL
  TiffinBox wrote by hand handed over to JPA, Hibernate and Spring Data JPA, one job at a time — ORM from first principles, mapping,
  querying, transactions, performance, schema and lifecycle (migrations, auditing, soft deletes), and a capstone on PostgreSQL with
  a container test. The same layout as Course 6: a README and a `receipts.sh` per unit. `c7-tiffinbox/` is the tree the next course,
  *Spring Data beyond JPA*, starts from.
2 · Course 6's finale's readme function ($C6), PINNED to 828e395 by this commit - its reads, and the function re-run from its own folder:
$ grep -c 'git -C \.\. show 828e395:README.md' $C6/receipts.sh
  4
$ grep -o 'git -C \.\. show 828e395:README.md' $C6/receipts.sh | wc -l | tr -d ' '
  6
$ sed -n '/^readmecap() {/,/; }$/p' $C6/receipts.sh | grep -c '\.\./README\.md'
  0
  its readme function, run in its own folder: 28 lines · md5 68a6fc68d166b539919751ffe4774324 · its receipts.md5's readme: 68a6fc68d166b539919751ffe4774324 · the same: yes
  its line under "and as it is now:": $ git -C .. show 828e395:README.md
  its title line now, as it reads it: line 1: # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core*, *Spring Boot* and *Spring Web MVC* (Learn Programming with Vivek)
3 · Course 5's finale's readme function ($C5), pinned since Course 6's finale - its reads, and the function re-run from its own folder:
$ sed -n '/^readmecap() {/,/; }$/p' $C5/receipts.sh | grep -c '\.\./README\.md'
  0
  its readme function, run in its own folder: 12 lines · md5 4456fd199c0cc10b1647683ea7526015 · its receipts.md5's readme: 4456fd199c0cc10b1647683ea7526015 · the same: yes
4 · the failure receipt (labelled): Course 6's finale's readme function UNPINNED - its receipts.sh as commit 06ae5dd had it - on the README as it is now:
$ git -C .. show 06ae5dd:c6-unit32/receipts.sh
  that file: md5 60f63030b9517d5ce5f8a255a351b2f3 · reads of ../README.md inside its readmecap: 6
  its readme function, run in its own folder: 28 lines · md5 626d2ae87e9a2305fab2ba1f8880c2f8 · the readme 06ae5dd's receipts.md5 published: 4e4241ddf3eb8a044c7762a1938ee54f · the same: no
  its line under "and as it is now:": $ cat ../README.md
  its own readme checks (13 lines of that file), on what it printed:
    FAIL readme: the folders now: expected the line:   the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/
    FAIL readme: the sections now: expected the line:   its course sections: 2 3 4 5 6
    FAIL readme: the title names Spring Web MVC
    FAIL lines: 3
```

## 2 · counts — every number the finale says, read off files (contract §6c)

In the repository: the `c7-unitNN/after` folders counted and listed (the anchor changes: 12 before Section 6, 3 in Sections 6 and 7),
the unit folders, the DDL script's lineage (`md5 -q` of every `xcheck.sql`, grouped by hash with the units that ship it: three hashes;
units 28 and 40 ship none), the tests (unit 36's published report total, 18; unit 39's published values line, Surefire 18 + the IT
execution's 3 = 21), the three pinned files printed whole (`chk40.py` compares them with the files byte for byte), unit 20's API line
read by its text (380-381), and the captures per section — `receipts.md5` lines in `c7-unit01..39`, by the registry's `SECTION_OF`
bounds, typed in the script so a clone without the registry prints the same lines and asserted equal to the registry's where it sits
beside the repository. Outside it (above): the registry's 40 lessons, 7 sections and their names, `TITLES['01'..'03']` and `['40']`;
the roadmap's seven Course 8 lines, each read by number AND found by `grep -n`, the two equal (R.63, RED #1809) — the heading at
`:324`, U01 `:327`, U02 `:328`, U07 `:333`, **S3 *Redis as a datastore* `:343`, S4 *Document and search* `:349`, U18 *MongoDB:
Documents, Not Rows* `:350`**; C7-12, Course 6's finale's lines 129-132 compared with the registry, "nothing to correct" derived by the
comparison (C7-12: its six comparisons each print equal — backticks and case aside, said so on its lines); and the retirement's
grep (`grep -il 'hibernate generat'`) over the course's 34 scripts: 0 hits. **The retirement:** the course retires the words Hibernate generates as
its rule, kept in all 34 scripts — Hibernate writes the SQL its mapping asks for, and the course always showed it.

`.r-counts.out` · md5 `d54549257ecbe0a80eca940c3f57bc0f` · 3 of 3

```
the anchor changes - the c7-unitNN/after folders, counted:
$ ls -d ../c7-unit*/after | wc -l | tr -d ' '
  15
  the folders: 03 06 07 09 15 16 17 26 27 29 31 34 36 38 39
  before Section 6 (units 01-34): 12 · in Sections 6 and 7 (35-40): 3
the course's unit folders:
$ ls -d ../c7-unit[0-9][0-9] | wc -l | tr -d ' '
  40
  first and last: c7-unit01 c7-unit40
the DDL script's lineage - Hibernate's script over each anchor's libraries, md5 -q c7-unitNN/xcheck.sql, grouped:
$ md5 -q ../c7-unit*/xcheck.sql
  9cf92b8cae3abfd0f1c0706bfe7a4373 units 27 29 30 31 32 33
  7f6942f0ed8bf296d661f629557f26c6 units 34 35 36 37
  f4f15b9c71145930e75568c4e64ab595 units 38 39
  files: 12 · distinct hashes: 3 · the hash changed between units: 33->34 37->38
the tests - the Flyway lesson's published report total, and the capstone's:
$ grep -n '^in all: [0-9]* reports · tests ' ../c7-unit36/README.md
  226:in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
$ grep -o 'surefire-reports [0-9]* ([^)]*) + surefire-reports-it [A-Za-z]* [0-9]* = [0-9]*' ../c7-unit39/README.md
  surefire-reports 18 (TiffinBoxWebTest 14, FullStackTest 3, FeedTest 1) + surefire-reports-it CustomerEntityRepositoryIT 3 = 21
the pinned sentences - the call-backs later courses make, as their units pinned them:
$ cat ../c7-unit30/pinned.txt
  Hibernate's statistics count every statement it prepares; the count of queries leaves out the collection loads.
  One query for the list and one more for each row is the N plus one, whatever sends the extra queries.
  SessionFactory.getStatistics().getPrepareStatementCount()
  lines: 3
$ cat ../c7-unit32/pinned.txt
  A second-level cache holds what Hibernate last read or wrote; a write that never passes through Hibernate leaves it serving the old value.
  lines: 1
$ cat ../c7-unit33/pinned.txt
  A batch writer flushes and clears at every chunk, so the persistence context holds one chunk, never the whole run.
  lines: 1
the paging API names the next courses call back (unit 20's README, its ledger line, read by its text):
$ grep -n -A1 'The call-backs Course 8 and 9 make, by API name' ../c7-unit20/README.md
  380:- **The call-backs Course 8 and 9 make, by API name, as measured on Spring Data JPA 4.1.2:** `Page`, `Slice`, `PageRequest.of(page,
  381-  size, sort)`, `Sort.by`, `Window<T>`, `ScrollPosition.keyset()`, `ScrollPosition.forward(Map)`, `Window.positionAt(int)`,
the captures - receipts.md5 lines in c7-unit01..39, per section (the bounds: the registry's SECTION_OF, 1:01-05 2:06-14 3:15-22 4:23-28 5:29-34 6:35-38 7:39-40):
  section 1 (01-05): 5 units · 35 captures
  section 2 (06-14): 9 units · 68 captures
  section 3 (15-22): 8 units · 57 captures
  section 4 (23-28): 6 units · 48 captures
  section 5 (29-34): 6 units · 47 captures
  section 6 (35-38): 4 units · 28 captures
  section 7 (39-40): 1 units · 6 captures
  in all: 39 units · 289 captures
OUTSIDE the repository - read when the file sits beside it:
$ python3: java7_series (~/Desktop/PromptVidya-Automation/java7_series.py) - len(TITLES), len(SECTIONS), the sections, TITLES 01-03 and 40
  len(TITLES) 40 · len(SECTIONS) 7
  section 1: ORM from First Principles
  section 2: Mapping
  section 3: Querying
  section 4: Transactions
  section 5: Performance
  section 6: Schema and Lifecycle
  section 7: Close
  TITLES[01]: The Object-Relational Mismatch, Named
  TITLES[02]: JPA, Hibernate, Spring Data: Three Different Things
  TITLES[03]: Your First Entity and EntityManager
  TITLES[40]: What's Next: Not Everything Is a Relation
  SECTION_OF as bounds: 1:01-05 2:06-14 3:15-22 4:23-28 5:29-34 6:35-38 7:39-40 · the bounds above: the same
$ sed -n '<N>p' ../../_briefs/TRACK-ROADMAP.md, and grep -n for the same text - each line read by number AND found, the two equal:
  :324 grep -n: 324 · the same: yes · ### COURSE 8 — Spring Data beyond JPA (28 units · 5 sections)
  :327 grep -n: 327 · the same: yes · - 01 **Why Another Data Module** — the persistence context reframed as a cost, with the number attached.
  :328 grep -n: 328 · the same: yes · - 02 **Aggregates, Not Entities** — no lazy loading, no dirty checking; the SQL is obvious because there is nothing hiding it.
  :333 grep -n: 333 · the same: yes · - 07 **Testing the JDBC Layer** *(Amendment A)* — `@DataJdbcTest`, Testcontainers Postgres, `@Sql` fixtures.
  :343 grep -n: 343 · the same: yes · **S3 · Redis as a datastore (14-17)**
  :349 grep -n: 349 · the same: yes · **S4 · Document and search (18-24)**
  :350 grep -n: 350 · the same: yes · - 18 **MongoDB: Documents, Not Rows** — the TiffinBox menu as a document, and when that actually wins.
  Course 8: Spring Data beyond JPA · 28 units · 5 sections
$ sed -n '129,132p' ../../spring-web-mvc/scripts-and-decks/32-whats-next-where-the-data-lives.md (C7-12: what Course 6's finale said), against the registry:
  **📊 ON SCREEN:** The roadmap, read today (md5 at build): **Data with JPA & Hibernate** — 40 lessons · 7 sections · a rail of 19 courses; its first titles *The Object-Relational Mismatch, Named*, *JPA, Hibernate, Spring Data: Three Different Things*, *Your First Entity and `EntityManager`*; its section *Schema and lifecycle*. Named, not taught.
  
  **🎙️ SAY:**
  > "The next course is Data with J-P-A and Hibernate: forty lessons in seven sections, the next stop on a rail of nineteen courses. It opens with The Object-Relational Mismatch, Named, then J-P-A, Hibernate, Spring Data, Three Different Things, then Your First Entity and Entity Manager. It also has a section called Schema and lifecycle. I'm naming them here, not teaching them."
  said lessons 40 · the registry 40 · equal: yes
  said sections 7 · the registry 7 · equal: yes
  said title 01: The Object-Relational Mismatch, Named · the registry: The Object-Relational Mismatch, Named · equal (backticks aside): yes
  said title 02: JPA, Hibernate, Spring Data: Three Different Things · the registry: JPA, Hibernate, Spring Data: Three Different Things · equal (backticks aside): yes
  said title 03: Your First Entity and `EntityManager` · the registry: Your First Entity and EntityManager · equal (backticks aside): yes
  said section: Schema and lifecycle · the registry section 6: Schema and Lifecycle · equal (case aside): yes
  C7-12: every count and title the last finale said equals the registry now - nothing to correct
$ ls ../../data-jpa-hibernate/scripts-and-decks/[0-9][0-9]-*.md | wc -l; grep -il 'hibernate generat' …/[0-9][0-9]-*.md | wc -l (the retirement):
  scripts: 34 · scripts holding it: 0
```

## Not captured here — the builder's, read on the day (contract §6c, R.63, S6.14)

`data-jpa-hibernate/_builders/s740.py` does not exist yet: it is the build stage's (S6.14; `check_unit7.py`'s `finale_gate` reports
"finale builder s740.py exists" as not yet true until then — expected). Its contract, from the gate: exactly one `OUT = js.DECKS` line
(`s632.py`'s form — `s734.py`'s conditional form would fail the gate), one `derived:` line carrying every cardinal from three up that
the voice says. What it will read, measured here on 2026-11-17 for the reader — **the builder re-reads them on the day**: the registry
(`len(TITLES)` 40, `len(SECTIONS)` 7, the seven names); the roadmap's lines `:324`, `:327`, `:328`, `:333`, `:343`, `:349`, `:350` with
the line numbers asserted; the C7-12 comparison against `32-whats-next-where-the-data-lives.md:129-132` (nothing to correct today);
the 34-script grep for the retired words (0 today); and this unit's `counts` capture for the repository's numbers. None of the first
four is in this repository.

## The root README and Course 6's pin (⚑11, R.176)

- `../README.md`: line 1 + *Data with JPA & Hibernate*; "all seven courses"; the folder line + `c7-unitNN/` + `c7-tiffinbox/`; a
  `## Course 7 — Data with JPA & Hibernate` section after Course 6's in Course 6's form (40 units, 7 sections — the registry's numbers,
  as the `counts` capture prints them; `c7-tiffinbox/` the tree the next course, *Spring Data beyond JPA*, starts from); the roadmap line
  byte-identical (part 1 compares it).
- `../c6-unit32/receipts.sh`: `readmecap`'s five reads of `../README.md` (its lines 312, 313, 315 twice, 317) read `git -C .. show
  828e395:README.md` — the probe's `pinfix.py` replacements re-derived by `ev40`'s own script, which also asserts 0 reads of `../README.md`
  left inside the function; its `$` line under "and as it is now:" names `828e395`; the label stays (Course 6's video shows it, the
  `b50b410` precedent did the same); the existence checks at its lines 94 and 338 and the check at 412 untouched; nothing else changed
  (`git diff --stat`: the four lines). `receipts.md5`: readme `4e4241dd…` → `68a6fc68d166b539919751ffe4774324`, re-measured by the pinned
  script's own run on the edited README (`./receipts.sh`, exit 1 on the old hash, memory = published) and equal to the probe's; memory
  `5673a150…` unchanged. `README.md`: told (R.73) — a dated paragraph in its §2, its block's line 8, its hashes, and a section "The root
  README and Course 6's own pin".
- **The four runs** (part 1-4 above, and the re-run before the captures): unpinned, README unchanged = the published `4e4241dd…` (its
  runs of record of 2026-10-30); pinned, README unchanged = `68a6fc68…` (the pinned function never reads the working tree: the probe's two
  outputs were byte-equal); **pinned, README changed = published** (`68a6fc68…`, part 2, and c6-unit32's whole receipt exit 0); **unpinned,
  README changed = the three FAIL lines** (part 4).

## Interrupted

Ctrl-C at any point: the trap stops c6-unit32's receipt by its pid with its children (its own trap then stops its JVM and its Maven
build and sweeps), sweeps this run's process group for a TiffinBox JVM, a Maven launcher, H2's shell or the check, drops the unfinished
capture passes and exits 130. Measured on the script as committed, `./receipts.sh` started as its own process group (`set -m`) and sent SIGINT as a terminal sends
it, at two points: **mid-c6-unit32-run** (its first JVM listening on 19612) and **mid-harness** (the first `readme` pass written):
each exit 130; nothing listening on 20190-20199 or 19610-19612/19619; no process left in the run's group, no TiffinBox jar running;
no `.r-lock` here or in c6-unit32; no unfinished capture pass; the root `README.md`, c6-unit32's three files, both units' published
captures and `git status` unchanged by the interrupt. **Found by the first trial:** the trap's first form sent `kill -9` right after
the TERM and cut c6-unit32's own trap short — its `.r-lock` stayed; the trap now gives that receipt time to finish its own clean-up
(`graceful`), and the repeated trials left nothing.

## Planted faults — each caught (R.65, R.226)

Each on a fresh scratch mirror (a clone at `06ae5dd` with this commit's files put in and c6-unit32's `.m2-demo` cloned beside), the
fault planted, `./receipts.sh` run in its `c7-unit40`, on the script as committed: each **exit 1**, `.r-readme.out` and `.r-counts.out`
not written, no `.r-lock` left.

| Plant (the brief's list for 40, and the limits') | Caught by |
|---|---|
| The root README edited, the pin not applied (c6-unit32's `receipts.sh` and `receipts.md5` as `06ae5dd` had them) — S6.15 | c6-unit32's own re-run, before the captures: `readme md5 626d2ae8… DIFFERS from the published 4e4241dd…`, exit 1 → this receipt stops |
| The pinned function with one read of `../README.md` restored (its line 317) | c6-unit32's re-run passes (that read's Course 6 section is unchanged); part 2's `grep -c` prints 1, and `chk40.py`'s own read of the function too → FAIL, exit 1 |
| A typed count in this README (`16 anchor changes`) | `s40.py`: a typed count, not in the counts capture (the line quoted) |
| `Hibernate generates` in a second sentence (a third site, with the grep's line) | `s40.py`: "outside the retirement's one sentence" |
| The root README's roadmap line changed by one character | part 1 "the same in both: no" and `chk40.py`'s own read → FAIL (part 4 then prints a fourth FAIL line too); c6-unit32's and c5-unit30's re-runs pass — they read pinned commits only (see "What differed") |
| A byte added to the mirror's `c7-unit39/after/README.md` | `tree40.py`'s pin: the same file count, another hash, against the pinned `3978284c…` (R.211) |
| The word for the container engine in a comment of `receipts.sh` | the self-check, first |

The finale-gate plant (`s734.py`'s conditional `OUT` form → `check_unit7.py 40` FAIL) is the build stage's (S6.14): not run here.

## The ledger rows this unit pays

- **C7-12 — paid: nothing to correct.** Course 6's finale said "40 lessons · 7 sections", three titles and the section *Schema and
  lifecycle*; the registry says the same today (`counts`, its C7-12 lines) — said as "as the last course's finale promised".
- **C7-13 — paid: both pins in one commit.** c5-unit30's since `b50b410` (part 3, unchanged); c6-unit32's in this commit (parts 2 and 4).
- **C7-14** — closed by unit 39's README sentence; nothing carried here.
- **CARRIED:** this unit's own `readme` capture reads `../README.md` live (part 1). The next finale — Course 8's, in the commit that adds
  Course 8 to the root README — pins it the same way (`cat ../README.md` → `git -C .. show <this unit's commit>:README.md`, its `$` line
  saying so), in the same commit (R.176's rule, carried by name).

## RE-MEASURE — the brief's items this unit settles

None open. The pin's md5 (READ FIRST 13: `68a6fc68…`) is re-measured here, by c6-unit32's own run, not copied.

## What differed from the brief

- **The sections' bounds.** The brief's typed bounds for the captures per section (01-05 · 06-14 · 15-20 · 21-26 · 27-34 · 35-39) are
  not the registry's: `java7_series.SECTION_OF` gives 01-05 · 06-14 · 15-22 · 23-28 · 29-34 · 35-38 · 39-40. The registry's are used,
  typed in `receipts.sh` (so a clone without the registry prints the same lines) and asserted equal to `SECTION_OF` where it sits beside.
- **"`grep -c 'git -C \.\. show 828e395:README.md'` ≥ 5"** — `grep -c` counts lines, and two of the five reads share line 315: it prints
  4. Both counts are printed and asserted: 4 lines, 6 occurrences (the five reads and the `$` line that names them).
- **"`git diff --stat` shows the five lines"** — four lines (the five reads; line 315 holds two).
- **c6-unit32's ports.** The brief says its re-run binds "19600-19611"; its receipt binds 19610, 19611 and 19612 (its own header's band,
  19610-19619). Those four (and 19619) are asserted free before and after it; 20190-20199 at this receipt's start and end.
- **The roadmap-line plant.** The brief expects c5-unit30's and c6-unit32's re-runs to fail too when the live roadmap line changes by
  one character; measured, both pass — each reads pinned commits only, which is what the pins are for. Part 1's "the same in both" line
  and `chk40.py`'s own second read catch it (exit 1).
- **`counts` may differ off the repository's neighbours.** The capture holds the out-of-repository reads, as the brief asks, so on a
  clone without them its md5 differs; `cap()` prints that and goes on for `counts` alone (every in-repository count still asserted).
- **C7-12's comparison** is "backticks and case aside", printed on its lines: Course 6's finale wrote `` `EntityManager` `` and "Schema and
  lifecycle"; the registry holds "EntityManager" and "Schema and Lifecycle".
- **Unit 39's 18 + 3** is read from its README's values line: its `.r-tests.out` is git-ignored and absent on a clone.
- **The commit's last line** is `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, as the brief and the session's attribution
  give it (the orchestrator's message named another model; the evidence agent is Opus 5.5).

## Found on the way

- **c6-unit32's header comment still says the readme capture reads the README "as it is now"** (its receipts.sh lines 14-15): the brief
  allows only the five reads to change in that file, so it stays; its README says the function is pinned. For RED.
- **The pinned function uses `<(…)`**, bash's process substitution, in three places (the probe's form): c6-unit32's shebang is
  `/bin/bash`, and 3.2.57 runs it (both bashes here).
- **The unpinned function reads `../README.md` six times counting its own `$` line** — the same six places the pin now names `828e395`.
- **`828e395`'s README is `b50b410`'s byte for byte** (`git diff --stat b50b410 828e395 -- README.md` empty): the "README as
  `b50b410` left it" of c6-unit32's carried note and the brief's `828e395` are one file.

## For RED (part B)

- The pin: `git diff 06ae5dd -- c6-unit32/receipts.sh` (the four lines) and part 2's counts; re-run it: `cd ../c6-unit32 && ./receipts.sh`.
- The failure receipt: part 4's three FAIL lines come from the shipped checks of `06ae5dd`, cut out by line range and run with each
  `die` printing instead of stopping — whether that cut is the whole of c6-unit32's readme check set.
- Whether the Course 7 section's one-sentence summary of the course (its seven sections' subjects) is fair to Sections 1-7.
- The sections' bounds: the brief's typed bounds differed from the registry's (below, "What differed"); the registry's are used and
  asserted.

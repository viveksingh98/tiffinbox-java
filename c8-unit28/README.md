# c8-unit28 — *What's Next: The API Other People Will Use*

Course 8's last unit, the finale. **No anchor change:** `anchor` is the link `../c8-unit27/after` (= `../c8-tiffinbox`, Course 8's
final anchor, the tree the next course starts from), its tree pinned by `harness/tree28.py` against `receipts.md5`'s `anchor-tree`
line, which equals `../c8-unit27/receipts.md5`'s `after-tree` line. No store, no container of this unit's own, no exercise (the
finales' precedent: `c5-unit30`, `c6-unit32`, `c7-unit40`). One TiffinBox JVM per `api` run: the default run, H2 in memory.

This unit's commit is **the course's one change to the repository's root `README.md`** (contract §5, R.176, R.327): the title gains
*Spring Data beyond JPA*, "all seven courses" becomes "all eight courses", the folder line gains `c8-unitNN/` + `c8-tiffinbox/`, and a
`## Course 8 — Spring Data beyond JPA` section follows Course 7's in its shape (`c7-unit40` gave Course 7's). In the same commit,
`c7-unit40`'s three live readers of that README are pinned to the commit they measured, `70ad921`: `readmecap40`'s own reads and its
shown command, the README its part 4 hands to `c6-unit32`'s `06ae5dd` function, and `chk40.py`'s reads (S8.108 = R.476, C8-1).

An API: the routes, methods and bodies a program that is not TiffinBox can call.

Three captures, each hashed over three rounds inside every run of `receipts.sh` (`receipts.md5`): `readme` (the pin, measured, and
the failure receipt), `counts` (every count the finale says, read off the files that hold it: §6c, S8.109 = R.477) and `api` (the
routes the next course starts from, S8.110 = R.478). Every number below is re-derived after its capture by `harness/chk28.py` from the
capture's own lines and another witness it reads itself — never from this README's prose. One sentence is pinned for the next
course's lesson called Resources, URIs and the Method Table, byte for byte, in `pinned.txt`:

A PATCH to slash customers answers four-oh-five, and its Allow header names POST and GET.

## Runs of record

Three runs of `receipts.sh` on 2026-11-24, each ending `c8-unit28: every capture 3/3 and = published …`, each log through
`check_unit8.py 28 --runlog` (`RESULT (run logs): PASS`; the unit gate itself exits `2` until the script stage writes unit `28`'s
script — expected). Every capture's md5 equals `receipts.md5`'s in all three; the build offline in each (`Downloaded from` none). The
launch rule is unit `23`'s (`c8-unit23/README.md:30`) as S8.112 tightened it: a run of record launches only while the first of the
machine's three load averages is below `20` and no other receipt is live, and the load is printed beside the run.

| run | how | result | load at start | load at end |
|---|---|---|---|---|
| run1-bash32 | `./receipts.sh` — macOS's bash 3.2.57 | PASS | `2.08 2.93 3.04` | `3.05 3.09 3.10` |
| run2-bash53 | `/opt/homebrew/bin/bash receipts.sh` — Homebrew's bash 5.3.9 | PASS | `2.81 3.04 3.08` | `2.98 3.07 3.08` |
| run3-sealed | a sealed fresh clone in a path with a space (`sealed 28/`): `git clone file://` at `e65298c`, this commit's files copied in (each `cmp`-equal, the link kept), `.m2-demo` a copy of the seed; `env -i` with `HOME`, a plain `PATH` and `TRACK_DIR`; `./receipts.sh` | PASS | `4.46 3.80 3.38` | `3.96 3.73 3.38` |

Not runs of record, said so: development runs before these found the cut-out functions run from the wrong folder, the README's part 2
differing by `6` lines (not `5`), `chk40.py`'s mentions of `70ad921` counted as `6`, a placeholder check that read the whole root
README, and a sweep pattern that matched the calling shell's own command line; an earlier set of three runs, before `s828.py`'s
self-test was made to print a FAIL line instead of an assertion, passed too. The runs above ran on the files as committed but this
section, written after them; a last run on the README as committed is in this commit's message. A first try at the third run
finished = published, but its caller's shell named the checker in its own command line and the receipt's last sweep stopped that
shell, so its exit and load were not recorded: it was run again (above). Start `receipts.sh` as a terminal does, in a process group
of its own.

## RE-MEASURE 8 — `readme`: the three readers pinned, one md5 before and after (settled first)

- `c7-unit40`'s `readmecap40` **as shipped** (cut out of `git show e65298c:c7-unit40/receipts.sh`, the S5 probe's `u28.sh` cut) on the
  README as `e65298c` had it, in a scratch clone: **equal to the published `readme` line of `c7-unit40/receipts.md5`**, as shipped.
- The same function on the README this commit leaves: its md5 moves; the lines that differ are the title, the folders, the sections
  (`2 3 4 5 6 7 8` now), the roadmap line's number, the gained/lost line and part 4's md5. The shipped `chk40.py` on it: **exit `1`,
  `3` FAIL lines** — the folders, the sections, the title. That is the hook: Course 7's finale's receipt fails its own checks until its
  capture and its checker read the commit they measured.
- The **pinned** function (this commit's `c7-unit40/receipts.sh`) on the README before **and** after the edit: **one md5**, the
  republished `readme` line of `c7-unit40/receipts.md5` (the S5 probe's own value, measured again). It differs from the published capture
  by the lines that change by design: the shown command, part 4's md5 and part 4's line under "and as it is now:".
- The **pinned** `chk40.py` on the pinned capture, README before and after: **exit `0` both times, its output byte-equal** to the
  shipped `chk40.py`'s on the published capture; on the unpinned capture (the control): **exit `1`, `6` FAIL lines**.
- `c6-unit32`'s and `c5-unit30`'s pinned functions, run inside the pinned capture: each equal to its own `receipts.md5` `readme` line,
  unchanged.
- This unit's own part reads the README **live** (`$ cat ../README.md`): the next course's finale pins this read (C9-1).

## RE-MEASURE 9 — `api` on 27/after: `12`, `405` / `405` / `404`, the pinned sentence

The anchor's jar, the default run on `127.0.0.1:20670`, one exposure flag (`mappings` beside `health,prometheus` — never shipped, the
anchor's own list stays `health,prometheus`). `/actuator/mappings`: **`12` handler methods of TiffinBox's own** (`GET` `8` · `POST`
`4`), by the rule printed in the capture: a `handlerMethod` whose class is in `com.tiffinbox`; Boot's actuator, its error controller
and the static resources are counted beside it and set aside. `PATCH /customers` → **`405`**, its `Allow` header the set `{GET, POST}`,
`application/problem+json`, the detail "Method 'PATCH' is not supported."; `DELETE /customers/Ravi` → **`405`**, `Allow` `{GET}`;
`GET /v3/api-docs` and `GET /swagger-ui.html` → **`404`** each: TiffinBox publishes no contract today. The `Allow` header is compared
as a set and printed sorted: unit `27` saw its order move between JVMs, and the pinned sentence names both methods without an order.

## RE-MEASURE 10 — the finale's counts, each from its file

Read on the day, each beside its source in the `counts` capture: `28` lessons in `5` sections (`java8_series.py`); `19` anchor changes
— the `c8-unitNN/after` entries that are directories (`find -type d`), listed `02 07 08 10`-`22 24 26 27`; `23` and `25` are links,
not counted; the tests from `18 + 3` at the course's start (`c7-unit39/README.md`'s reports, the tree the course started from, and
`SETUP-BRIEF-2026-11-17.md:35`) to `18 + 14` at its end (`c8-unit27/README.md`'s `bound:` line); the captures per section (the
`receipts.md5` lines that are not a tree line, summed by the registry's `SECTION_OF`); Course 8's pinned sentences by md5; the
contract's rules from `R.343` to its last, `R.488` (its line `350`, read on the day); the next course's `26` lessons in `5` sections and
its three opening titles (`java9_series.py`, equal to the roadmap's `:369`-`:371`, each read by number and found by grep); the track's
`19` courses (the roadmap's `:48`). The dev run's handler methods were not captured in unit `27` (its flag runs were dropped for the
clock, its README says so): not said here either.

## The change, file by file

- **`../README.md`** (`+16 -3`, `git diff --numstat e65298c`): line 1 gains *Spring Data beyond JPA*; "all seven courses" → "all eight
  courses"; the folder line gains `Course 8 in c8-unitNN/ + c8-tiffinbox/`; a `## Course 8 — Spring Data beyond JPA` section before the
  `Videos publish` line, in Course 7's shape (`c7-unit40`): the units and sections, the long-lived project, what the tree is at the end
  (`18 + 14`, every container test on the loopback address), Spring's two advisories by ID, URL and versions, named and not adopted,
  and the next course by its title. The roadmap line stays byte for byte (`c7-unit40`'s finale left it as it was; `readme` part 6
  prints it). The section, whole, is in the `readme` capture's part 6 below.
- **`../c7-unit40/receipts.sh`**: `PIN7=70ad921` beside `PIN6`, with a dated comment (R.73); `readmecap40` writes
  `git -C .. show $PIN7:README.md` to `.harness/readme-70ad921.md` once and reads that file where it read `../README.md` (its `view`,
  the roadmap line, the two `diff` reads, the section it prints whole); its shown line `$ cat ../README.md` became the pinned command; part 4
  hands `c6-unit32`'s `06ae5dd` function that file (one `sed` over the cut-out function, the S5 probe's `u28d.sh` form). The label
  lines stay. The README's reads inside the function and its part 4: `7` before, `1` after (the label of part 4's count).
- **`../c7-unit40/harness/chk40.py`**: its four lines, BLUE's `chk40-pinned.py` the model, and a dated comment — the block's first
  line, the README read (`git show 70ad921:README.md`), git's numstat (`828e395 70ad921`), part 4's "as it is now" line. Its reads of
  the README: `2` before, `0` after.
- **`../c7-unit40/receipts.md5`**: the `readme` line **republished** (the shown command changed by design, R.73); the `counts` line
  unchanged (the `readme` capture compares the rest with `e65298c`'s).
- **`../c7-unit40/README.md`**: its readme block and heading replaced byte for byte with the pinned run's output, a dated paragraph
  "Course 8, unit 28" after the block saying what was pinned, why, and that the md5 moved; one sentence before the block no longer types
  part 4's old md5 (the block prints the new one). `c7-unit40`'s own prose gate (`s40.py` with `dur7.py`) on its README: refused `0`.
  The published video keeps its labels; only the `$` lines name the pin.
- **`c8-unit28/`**: this folder. Nothing in `c8-tiffinbox/`, `c5-unit30/`, `c6-unit32/` or any other unit changes.

## The captures — what each one shows

### 1 · readme

Parts `1`-`6` as RE-MEASURE 8 lists them. The scratch clone is `git clone --shared` of the repository with `e65298c`'s four paths
checked out; the README in it is swapped between the one before this commit and the one it leaves, and every function runs in the
clone's `c7-unit40`, as `c7-unit40`'s own script runs it.

```text
the scratch clone: git clone --shared --no-checkout .. .harness/wt; git -C .harness/wt checkout e65298c -- README.md c7-unit40 c6-unit32 c5-unit30
  the README before this commit (git show e65298c:README.md): md5 68c15b5c0720e2b8155b80f761faa521 · 472 lines
  the README this commit leaves (../README.md): md5 7b22d4c74ae700f218b2aed0e6050346 · 485 lines · git diff --numstat e65298c -- README.md: +16 -3
  the published readme md5 (git show e65298c:c7-unit40/receipts.md5): fcbf0ce27cdd4fd0184ab8367d76226c · the republished (../c7-unit40/receipts.md5): b75791fa5077f943c0bd85a9bdfbe5b3
  c7-unit40/receipts.md5's other lines, against e65298c's: the same
the reads of the README, counted:
  readmecap40 + its part 4, as shipped: grep -o '../README.md' -> 7 · pinned (this commit): 1 (1 of them the label) · git -C .. show $PIN7:README.md: 2
  chk40.py's reads of the README (open("../README.md") and its "$ cat ../README.md" block), as shipped: 2 · pinned: 0 · its reads of 70ad921: 6
1 · c7-unit40's readmecap40 AS SHIPPED, on the README before this commit:
  md5 fcbf0ce27cdd4fd0184ab8367d76226c · lines 45 · = the published fcbf0ce27cdd4fd0184ab8367d76226c: yes
2 · the same function on the README this commit leaves (the failure receipt, labelled):
  md5 3bb51d46cb89ee877a8e4162a19ff058 · = the published: no · the lines that differ from (1):
    3,6c3,6
    <   line 1: # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core*, *Spring Boot*, *Spring Web MVC* and *Data with JPA & Hibernate* (Learn Programming with Vivek)
    <   the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/ c7-unitNN/
    <   its course sections: 2 3 4 5 6 7
    <   its roadmap line: 470:Videos publish a few per day on the channel. Roadmap (19 courses): Java Fundamentals → Core Java II → Build & Test Like a Pro → Spring Framework Core → Spring Boot → Spring Web MVC → Data with JPA & Hibernate → … → Spring AI.
    ---
    >   line 1: # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core*, *Spring Boot*, *Spring Web MVC*, *Data with JPA & Hibernate* and *Spring Data beyond JPA* (Learn Programming with Vivek)
    >   the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/ c7-unitNN/ c8-unitNN/
    >   its course sections: 2 3 4 5 6 7 8
    >   its roadmap line: 483:Videos publish a few per day on the channel. Roadmap (19 courses): Java Fundamentals → Core Java II → Build & Test Like a Pro → Spring Framework Core → Spring Boot → Spring Web MVC → Data with JPA & Hibernate → … → Spring AI.
    14c14
    <   lines the README gained: 10 · lines it lost: 3
    ---
    >   lines the README gained: 23 · lines it lost: 3
    39c39
    <   its readme function, run in its own folder: 28 lines · md5 626d2ae87e9a2305fab2ba1f8880c2f8 · the readme 06ae5dd's receipts.md5 published: 4e4241ddf3eb8a044c7762a1938ee54f · the same: no
    ---
    >   its readme function, run in its own folder: 28 lines · md5 cbb0b74442df2b4b1620f3643a06ecaa · the readme 06ae5dd's receipts.md5 published: 4e4241ddf3eb8a044c7762a1938ee54f · the same: no
  the shipped chk40.py on it: exit 1 · its FAIL lines 3:
    FAIL 1: the folders now + c7-unitNN/
    FAIL 1: the sections now 2-7
    FAIL 1: the title names Data with JPA & Hibernate
3 · the PINNED readmecap40 (this commit's c7-unit40/receipts.sh), on the README before and after this commit:
  before: md5 b75791fa5077f943c0bd85a9bdfbe5b3 · after: md5 b75791fa5077f943c0bd85a9bdfbe5b3 · one md5: yes · = the republished b75791fa5077f943c0bd85a9bdfbe5b3: yes · = the published: no
  the lines it differs from the published capture (1) by:
    2c2
    < $ cat ../README.md
    ---
    > $ git -C .. show 70ad921:README.md
    39,40c39,40
    <   its readme function, run in its own folder: 28 lines · md5 626d2ae87e9a2305fab2ba1f8880c2f8 · the readme 06ae5dd's receipts.md5 published: 4e4241ddf3eb8a044c7762a1938ee54f · the same: no
    <   its line under "and as it is now:": $ cat ../README.md
    ---
    >   its readme function, run in its own folder: 28 lines · md5 61f59107e26ba0429e2445aef4c00cba · the readme 06ae5dd's receipts.md5 published: 4e4241ddf3eb8a044c7762a1938ee54f · the same: no
    >   its line under "and as it is now:": $ cat ../c7-unit40/.harness/readme-70ad921.md
4 · the pinned chk40.py (this commit's) on (3) before and after, against the shipped chk40.py on (1); and on (2), the control:
  the shipped chk40.py on (1), the README before: exit 0 · FAIL lines 0 · output md5 1e4523af549bc35acf36b4be6fb38277
  the pinned chk40.py on (3), the README before: exit 0 · FAIL lines 0 · output md5 1e4523af549bc35acf36b4be6fb38277 · = the shipped one's on (1): yes
  the pinned chk40.py on (3), the README after: exit 0 · FAIL lines 0 · output md5 1e4523af549bc35acf36b4be6fb38277 · = the shipped one's on (1): yes
  the pinned chk40.py on (2), the README after (the control): exit 1 · FAIL lines 6:
    FAIL no line starting '$ git -C .. show 70ad921:README.md'
    FAIL 1: the folders now + c7-unitNN/
    FAIL 1: the sections now 2-7
    FAIL 1: the title names Data with JPA & Hibernate
    FAIL 1: gained/lost = git diff --numstat 828e395 (['10', '3'])
    FAIL 4: the unpinned function reads the README as 70ad921 had it: expected exactly one line /  its line under "and as it is now:": \$ cat \.\./c7-unit40/\.harness/readme-70ad921\.md/ - found 0
5 · the two older finales' pinned functions, inside (3) after, against their receipts.md5:
  c6-unit32: its readme function, run in its own folder: 28 lines · md5 68a6fc68d166b539919751ffe4774324 · its receipts.md5's readme: 68a6fc68d166b539919751ffe4774324 · the same: yes · ../c6-unit32/receipts.md5's readme 68a6fc68d166b539919751ffe4774324
  c5-unit30: its readme function, run in its own folder: 12 lines · md5 4456fd199c0cc10b1647683ea7526015 · its receipts.md5's readme: 4456fd199c0cc10b1647683ea7526015 · the same: yes · ../c5-unit30/receipts.md5's readme 4456fd199c0cc10b1647683ea7526015
  c7-unit40/README.md's readme block (the lines under its heading): md5 b75791fa5077f943c0bd85a9bdfbe5b3 · its heading: 1 line naming the republished md5
6 · the README as it is now, read live by this unit (Course 9's finale pins this read):
$ cat ../README.md
  line 1: # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core*, *Spring Boot*, *Spring Web MVC*, *Data with JPA & Hibernate* and *Spring Data beyond JPA* (Learn Programming with Vivek)
  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/ c7-unitNN/ c8-unitNN/
  its course sections: 2 3 4 5 6 7 8
  its roadmap line: 483:Videos publish a few per day on the channel. Roadmap (19 courses): Java Fundamentals → Core Java II → Build & Test Like a Pro → Spring Framework Core → Spring Boot → Spring Web MVC → Data with JPA & Hibernate → … → Spring AI.
its Course 8 section, whole:
  ## Course 8 — Spring Data beyond JPA
  **TiffinBox beside JPA**, in `c8-unitNN/` (28 units, 5 sections), with the long-lived project in `c8-tiffinbox/`. Its sections:
  Spring Data JDBC and its aggregates, the caching abstraction on Caffeine and then on Redis, Redis holding records of its own,
  documents in MongoDB and search in Elasticsearch, and the Commons layer those modules share, closed by a capstone with one jar and
  two runs: the default run on H2 with Caffeine, and "dev" on PostgreSQL, Redis, MongoDB and Elasticsearch. The same layout as the
  course before: a README and a `receipts.sh` per unit. At the end its tests are `18 + 14`, and every container test publishes its
  container on the loopback address alone. Spring's two advisories of 2026-11-19 are named here, not adopted: CVE-2026-123886
  (Spring Data Elasticsearch, `https://spring.io/security/cve-2026-123886`, versions 6.1.0 to 6.1.2) and CVE-2026-59342 (Spring Data
  MongoDB, `https://spring.io/security/cve-2026-59342`, versions 5.1.0 to 5.1.2). This course runs 6.1.2 and 5.1.2 with Boot 4.1.2;
  Boot 4.1.3 brings 6.1.3 and 5.1.3. A grep of `c8-tiffinbox/` finds 0 files that import a string annotation from either module's
  repository packages, the shape both advisories name; Course 9's first boundary step decides the version. `c8-tiffinbox/` is the
  tree the next course, *REST APIs Done Right*, starts from.
```

### 2 · counts

```text
the registry: ~/Desktop/PromptVidya-Automation/java8_series.py - len(TITLES), len(SECTIONS), SECTION_OF as bounds, TITLES[28]:
  java8_series: len(TITLES) 28 · len(SECTIONS) 5
  section 1: Spring Data JDBC
  section 2: The Caching Abstraction
  section 3: Redis as a Datastore
  section 4: Document and Search
  section 5: Common Ground and Close
  SECTION_OF as bounds: 1:01-07 2:08-13 3:14-17 4:18-24 5:25-28
  TITLES[28]: What's Next: The API Other People Will Use · SLUGS[28]: 28-whats-next-the-api-other-people-will-use
the anchor changes - the c8-unitNN/after entries that are directories, not links:
$ find ../c8-unit[0-9][0-9] -maxdepth 1 -name after -type d | wc -l | tr -d ' '
  19
  the units: 02 07 08 10 11 12 13 14 15 16 17 18 19 20 21 22 24 26 27
  after/ as a link (not counted): 23 25 · the unit folders: 28 (c8-unit01 c8-unit28)
the tests - at the course's start (the tree it started from, Course 7's last anchor) and at its end (its last anchor change):
$ grep -o 'surefire-reports [0-9]* ([^)]*) + surefire-reports-it [A-Za-z]* [0-9]* = [0-9]*' ../c7-unit39/README.md
  surefire-reports 18 (TiffinBoxWebTest 14, FullStackTest 3, FeedTest 1) + surefire-reports-it CustomerEntityRepositoryIT 3 = 21
$ sed -n 35p ../../spring-data-beyond-jpa/_briefs/SETUP-BRIEF-2026-11-17.md | grep -o 'tests 18 + 3 IT'
  tests 18 + 3 IT
$ grep -n '^bound: ' ../c8-unit27/README.md | grep -o 'tests [0-9]* + [0-9]*, [0-9]* failures'
  tests 18 + 14, 0 failures
the captures - receipts.md5 lines that are not a tree line, in c8-unit01..27, per section (the registry's SECTION_OF):
  section 1 (01-07): 7 units · 48 captures
  section 2 (08-13): 6 units · 54 captures
  section 3 (14-17): 4 units · 44 captures
  section 4 (18-24): 7 units · 75 captures
  section 5 (25-27): 3 units · 29 captures
  in all: 27 units · 250 captures (unit 28 aside: this unit)
the pinned sentences - Course 8's call-backs as their units pinned them:
$ md5 -q ../c8-unit01/pinned.txt; grep -cF "$(cat ../c8-unit01/pinned.txt)" ../c8-unit01/README.md
  59850ae54f53d33200307e32edba7973 · lines 1 · in its README: 1 lines
$ md5 -q ../c8-unit12/pinned.txt; grep -cF "$(cat ../c8-unit12/pinned.txt)" ../c8-unit12/README.md
  ba35ab90cf46ded9976dc945ca11da2d · lines 1 · in its README: 2 lines
$ printf '%s' "$HANDOFF" | md5   (unit 24's C8-20 sentence: HANDOFF= in ../c8-unit24/receipts.sh, against its README's record)
  a6581dab7e33c458146b1f0e9cb114bc · its README's record: 1 line · ../c8-tiffinbox/README.md holds it: 1 line
$ md5 -q pinned.txt   (this unit's, for Course 9's Resources, URIs and the Method Table)
  2a866987eea96a5cb42553f5dfb319b3 · lines 1
the rules - the contract's Course 8 rules, read on the day:
$ grep -nE '^- \*\*R\.[0-9]+\*\*' ../../spring-data-beyond-jpa/_briefs/STYLE-CONTRACT.md - the first, the last, how many:
  first R.343 (line 187) · last R.488 (line 350) · rules 146 · the numbers consecutive: yes
the next course - ~/Desktop/PromptVidya-Automation/java9_series.py, and the roadmap (../../_briefs/TRACK-ROADMAP.md), each line read by number AND found by grep:
  java9_series: len(TITLES) 26 · len(SECTIONS) 5
  TITLES[01]: What REST Actually Says
  TITLES[02]: Resources, URIs and the Method Table
  TITLES[03]: Status Codes That Mean Something
  :48 grep -n: 48 · the same: yes · **19 courses · 614 units · ≈50 hours** at this channel's measured 4:26-5:10 per unit.
  :366 grep -n: 366 · the same: yes · ### COURSE 9 — REST APIs Done Right (26 units · 5 sections)
  :369 grep -n: 369 · the same: yes · - 01 **What REST Actually Says** — Fielding's constraints plainly; which ones your API breaks and when that 
  :370 grep -n: 370 · the same: yes · - 02 **Resources, URIs and the Method Table** — the nine methods and what each one guarantees.
  :371 grep -n: 371 · the same: yes · - 03 **Status Codes That Mean Something** — the dozen you will actually use, each with a TiffinBox case.
  :362 grep -n: 362 · the same: yes · - 28 **What's Next: The API Other People Will Use** — hand-off to course 9.
  the roadmap :369-371 = java9_series TITLES 01-03: yes
  the roadmap :366 = java9_series: REST APIs Done Right · 26 units · 5 sections · equal: yes
  the track (:48): 19 courses
the dev run's handler methods: c8-unit27 captured none - grep -c over its README and its receipts.md5 for a mappings capture:
  ../c8-unit27/receipts.md5 lines naming mappings: 0 · ../c8-unit27/README.md's line on the flag runs: 1 · not captured in 27, not said
C8-14 - what Course 7's finale said (../../data-jpa-hibernate/scripts-and-decks/40-…md :134 and :141), against the registry today:
  said Why Another Data Module (found) · TITLES[01]: Why Another Data Module · equal (case, colons, commas and spelt letters aside): yes
  said Aggregates, Not Entities (found) · TITLES[02]: Aggregates, Not Entities · equal (case, colons, commas and spelt letters aside): yes
  said Testing the J-D-B-C Layer (found) · TITLES[07]: Testing the JDBC Layer · equal (case, colons, commas and spelt letters aside): yes
  said MongoDB, Documents, Not Rows (found) · TITLES[18]: MongoDB: Documents, Not Rows · equal (case, colons, commas and spelt letters aside): yes
  said section Redis as a datastore (found) · SECTIONS[3]: Redis as a Datastore · equal (case aside): yes
  said section Document and search (found) · SECTIONS[4]: Document and Search · equal (case aside): yes
  said: Course eight of nineteen, twenty-eight lessons in five sections: found · the registry 28 lessons, 5 sections
  C8-14: every title, section and count the last finale said equals the registry now - nothing to correct
the advisories' shape (⚑17) on the anchor: files importing a string annotation from Spring Data MongoDB's or Elasticsearch's repository packages:
$ grep -rlE 'org\.springframework\.data\.(mongodb\.repository\.(Query|Aggregation)|elasticsearch\.annotations\.Query)' --include='*.java' anchor/ | wc -l | tr -d ' '
  0
  the anchor's @Query lines, all JPQL or SQL sums with no parameter: 4 · with a parameter (:name or ?1): 0
  the jar's module versions (unzip -l, BOOT-INF/lib): spring-data-elasticsearch-6.1.2.jar spring-data-mongodb-5.1.2.jar · Spring Boot (the anchor's pom.xml parent): 4.1.2
```

### 3 · api

```text
$ cd .harness/after && DOCKER_HOST=tcp://127.0.0.1:1 perl -e '$SIG{INT}="DEFAULT"; alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=20670 --management.endpoints.web.exposure.include=health,prometheus,mappings
  readiness 200 · TiffinBox listened on: 127.0.0.1:20670 · stopped by POST /shutdown: {"stopping":true} · exit 0 · listening on 20670 now: 0
the handler methods - /actuator/mappings, the dispatcherServlet's list; the rule: TiffinBox's own = a handlerMethod whose className is com.tiffinbox.*:
  entries 21 · TiffinBox's own 12 (GET 8 · POST 4 · other 0) · set aside: Boot's actuator 5 · Boot's error controller 2 · static resources 2
  GET   /customers         TiffinBoxServer#customers
  GET   /customers/feed    CustomerFeed#feed
  GET   /customers/new     DashboardPage#form
  GET   /customers/{name}  TiffinBoxServer#customer
  GET   /dashboard         DashboardPage#page
  GET   /dashboard         TiffinBoxServer#dashboard
  GET   /kitchen           TiffinBoxServer#kitchen
  GET   /revenue           TiffinBoxServer#revenue
  POST  /customers         DashboardPage#add
  POST  /customers         TiffinBoxServer#add
  POST  /customers/import  CustomerImport#importCsv
  POST  /shutdown          TiffinBoxServer#shutdown
PATCH /customers -> 405 · Allow (as a set, sorted): GET, POST · Content-Type: application/problem+json · body {"detail": "Method 'PATCH' is not supported.", "instance": "/customers", "status": 405, "title": "Method Not Allowed"}
DELETE /customers/Ravi -> 405 · Allow (as a set, sorted): GET · Content-Type: application/problem+json · body {"detail": "Method 'DELETE' is not supported.", "instance": "/customers/Ravi", "status": 405, "title": "Method Not Allowed"}
GET /v3/api-docs -> 404 · Allow (as a set, sorted): none · Content-Type: application/problem+json · body {"detail": "No static resource v3/api-docs.", "instance": "/v3/api-docs", "status": 404, "title": "Not Found"}
GET /swagger-ui.html -> 404 · Allow (as a set, sorted): none · Content-Type: application/problem+json · body {"detail": "No static resource swagger-ui.html.", "instance": "/swagger-ui.html", "status": 404, "title": "Not Found"}
GET /actuator -> 200 · Allow (as a set, sorted): none · Content-Type: application/vnd.spring-boot.actuator.v3+json · body links: health health-path mappings prometheus self
the callers of TiffinBox's routes - its pages, its tests, the course's comparison requests:
$ grep -rnoE '@\{/[a-z/]+\}' anchor/tiffinbox-web/src/main/resources/templates
  customer-form.html:7:@{/customers}
  fragments.html:9:@{/customers/new}
  fragments.html:9:@{/dashboard}
$ grep -cE '"/(customers|dashboard|kitchen|revenue|shutdown)' anchor/tiffinbox-web/src/test/java/com/tiffinbox/web/*.java (files with a hit)
  FeedTest.java:2
  FullStackTest.java:3
  TiffinBoxWebTest.java:13
$ grep -nE '^req |"\$B/shutdown"' ../c5-unit11/curlset.sh   (the seven)
  10:req GET /customers
  11:req GET /revenue
  12:req GET /dashboard
  13:req GET /kitchen
  14:req GET /nowhere
  15:req GET /shutdown
  16:out=$(printf 'X-Shutdown-Token: %s\n' "$tok" | curl -s -o "$T" -w '%{http_code} %{content_type}' -H @- -X POST "$B/shutdown")
the pinned sentence (pinned.txt), against this capture:
  A PATCH to slash customers answers four-oh-five, and its Allow header names POST and GET.
  md5 -q pinned.txt: 2a866987eea96a5cb42553f5dfb319b3
```

## Which tree, which profile

`anchor` → `../c8-unit27/after`, copied to `.harness/after/` and built there offline; the default run (no profile: H2 in memory,
Caffeine, no Docker reachable — `DOCKER_HOST` points at a closed port), one JVM per `api` run on `127.0.0.1:20670`, stopped by its
shutdown token. No store, no container, no "dev" run: the dev run's routes are unit `27`'s `tour` capture, cited as it stands.
`seven` is not a capture of this unit — no anchor change — and unit `27`'s stands.

## Refused, named

- A dev run in this unit (RED #28): unit `27`'s `tour` is the dev run's record.
- A lesson of the next course by its number in a spoken line (§3b): the hand-off names titles; the course's own number and its
  lesson count stand in its first sentence, as `c7-unit40`'s hand-off did ("Course eight of nineteen").
- The republished md5 called a match of the published one: it is republished by design (R.73). Only the shipped function on the README before this
  commit gives the published one.
- A verdict on the advisories' reach into this tree (⚑17): they are named, not adopted; the next course's first boundary step decides the
  version. No version move in this course.
- A verdict on the routes (XU28's REST family), the API called finished, an exercise, a footprint.

## The repository, and the network

Repository `tiffinbox-java`, branch `main`, unit `27`'s commit `e65298c` its parent; `git status --short` empty and `origin/main...main`
`0 0` at the start. One build, offline from `.m2-demo` (a copy of the course's seed `spring-data-beyond-jpa/_research/m2-seed-c8-s4b`,
its file count printed and asserted unchanged after the build): `Downloaded from` none. Nothing leaves the machine but the final
`git push`. The files this unit reads outside the repository sit two folders up, as on the author's Mac: the registries
(`~/Desktop/PromptVidya-Automation/java8_series.py`, `java9_series.py`), the roadmap, the contract, the set-up notes (`SETUP-BRIEF-2026-11-17.md`) and
the script of `c7-unit40`'s video; a clone elsewhere names that folder with `TRACK_DIR`, and its captures print the same bytes.

## The folders, the harness and the ports

`README.md`, `anchor` (the link), `harness/` (`chk28.py`, `dur8.py` as unit `02` shipped it, `s828.py`, `tree28.py`), `pinned.txt`,
`receipts.md5`, `receipts.sh`; `.m2-demo/`, `.harness/` and `.r-*` are the run's and ignored by git. Ports: `20670` TiffinBox;
`20671`-`20679` asserted free at the start and the end; no `mvn verify` in this unit, so unit `27`'s pinned ITs' ports are not touched.

## Masks, filters and hygiene

The captures print paths relative to this folder and the home as `~`; `cap()` refuses an absolute path. The mask (`mask()`, its
self-test first) replaces a start's timings and a pid; the `api` capture prints the `Allow` header as a sorted set and the
problem bodies with sorted keys. The shutdown token is generated per run (`0600`), sent on curl's standard input, and asserted absent
from TiffinBox's log.

## Interrupted

Each started as a terminal starts it — in a process group of its own, SIGINT at its default — and the SIGINT sent to the group, as a
Ctrl-C does, at the point named; each run of `receipts.sh` on the files as committed:

| SIGINT | alive at the signal | exit | after it |
|---|---|---|---|
| mid-build (Maven running) | Maven's JVM | `130` | no java, no Maven, no `.r-lock`, no `.r-*.[123]` |
| mid-`readme` (git reads and the cut-out functions in the scratch clone) | git, bash | `130` | the scratch clone `.harness/wt` left (git-ignored, the next run's first step removes `.harness/`); the repository's working tree and index untouched |
| mid-`counts` (file reads only) | python3 | `130` | nothing left |
| mid-`api` (TiffinBox's JVM up on `20670`) | TiffinBox's JVM | `130` | no java, nothing on `20670` |

After each: `git status --short` showed only this unit's edits (the root `README.md`, the four `c7-unit40` files, `c8-unit28/`), and the
published `.r-*.out` files were not rewritten by the interrupted run. A first attempt launched the receipt as a background job of a
non-interactive shell, where SIGINT is ignored: that run went on to its end (exit `0`); it is not counted here.

## Planted faults — each caught

Each in the sealed clone (the runs of record's third tree), the fault planted, the receipt run or `chk28.py` given a capture copy with
the fault; each ended with its FAIL line or its `***` line, **exit `1`, no traceback**, and each was removed after (every file restored
from the repository, `git status` back to this unit's edits). The controls first: `chk28.py readme`, `counts` and `api` on the
published captures, exit `0`.

| Plant | Caught by |
|---|---|
| `c7-unit40` pinned in `receipts.sh` only (`chk40.py` as `e65298c` shipped it) | `chk28.py static` first ("its four lines read 70ad921"); with that check skipped, the `readme` capture's part 4: the shipped checker on the pinned capture exits `1` with `6` FAIL lines (README after; `5` before) → `chk28.py readme` FAIL |
| `chk40.py` pinned, but its README read (`open("../README.md")`) left live | `chk28.py static`; with it skipped, `chk28.py readme`: chk40's reads `2` → `1`, not `0`. The pinned checker itself still exits `0` with that one line live: the count is what catches it |
| The pinned sentence one byte changed (`pinned.txt`) | the receipt's gate: the sentence must stand in `README.md` once, byte for byte; `chk28.py static` and `api` pin its bytes too |
| The anchor-change count with a link counted (`find` without `-type d`) | `chk28.py counts`: its line no longer parses (`the check could not run`, a FAIL line) |
| `c8-unit23/after` made a directory | `chk28.py counts`: its anchor-changes check, `19` and the list (the list printed shows `23`) |
| `18 + 13` for the end | `chk28.py counts`: the tests at the end, against `c8-unit27/README.md` |
| The last rule one off (`R.487`) | `chk28.py counts`: the rules, against the contract read again |
| A Course 9 title misspelt in `s828.py`'s `TITLES` | the prose gate: its own self-test fails on the pin's lead sentence (a FAIL line, exit `1`); `chk28.py static` compares `TITLES` with the registry and the roadmap too |
| The root README's Course 8 section given a safety verdict on the advisories | the prose gate on that section: XFAM_S5's safety family and XU28's |
| A lesson of the next course by its ordinal, in this README | the prose gate: XFAM_S5's forward reference and XU28's lesson-number family |
| The republished md5 given the word for a match of the published one, in this README | the prose gate: XU28's republished-md5 family |
| A REST verdict; a lesson's unit-number form; the API said to be at its end - each in this README | the prose gate: XFAM_S5 and XU28 on the first; XU28 alone on the other two |
| `PATCH`'s `Allow` header with one method (the set `{GET}`) | `chk28.py api`: the `405` line and the pinned sentence's facts |
| `/v3/api-docs` answering `200` | `chk28.py api`: the `404` line |
| The unpinned md5 written as the republished one in `c7-unit40/receipts.md5` | `chk28.py readme`: part 3's one md5 is not the republished line |
| The old `readme` line left in `c7-unit40/receipts.md5` | `chk28.py readme`: published and republished equal; the old md5 still in the file |
| `c7-unit40/README.md`'s block with one line as it was (`$ cat ../README.md`) | `chk28.py readme`: the block is not the republished capture, byte for byte |
| A placeholder in this README | the receipt's gate |
| An empty capture to each of `readme`, `counts`, `api` (the cannot-fail detector) | `chk28.py`: a FAIL line and exit `1` for each |
| A listing line no rule parses, added to the `counts` capture | `chk28.py counts`: "every line of the capture parsed or skipped by a named rule" |
| A capture file that does not exist | `chk28.py`: "the check could not run (FileNotFoundError …)", exit `1` |

No exercise here, so the brief's "a changed What-it-prints line" has no line to change.

## What differed from the brief

- **The pin's edit, made the house way on the shipped file.** `readmecap40` reads `git -C .. show $PIN7:README.md` once, into
  `.harness/readme-70ad921.md`, and every read and the part-4 `sed` use that file; the probe's `u28.sh` piped `git show` into each read
  (its count of pinned reads differs, the capture's bytes do not: the republished md5 is the probe's own `b75791fa…`). `PIN7` is a
  variable beside `PIN6`, as the brief asked; the shown command prints `70ad921` through it.
- **`readme` runs in a scratch clone** (`.harness/wt`, `git clone --shared` with `e65298c`'s four paths checked out), never in the
  repository's own `c7-unit40`: the README before the edit and after it are swapped there, so the repository's working tree is never
  written by a capture, and `c7-unit40/.harness/` is not touched.
- **Part 2 differs from the published capture by `6` lines, not the brief's list of four** — the title, the folders, the sections, the
  roadmap line's number, the gained/lost line, and part 4's md5 (its part 4, unpinned, reads the live README too); the shipped `chk40.py`
  on it prints `3` FAIL lines (the folders, the sections, the title), as the probe measured on its sketch edit; git's numstat agrees
  with the capture there, so it adds no FAIL line.
- **The handler count:** `12` measured on the default run; **`17` not said** — unit `27` dropped its flag runs and captured no
  mappings (`counts` prints the grep: its `receipts.md5` names no mappings capture). The finale says `12` only.
- **`18 + 3` at the course's start** is read off `c7-unit39/README.md`'s reports (the tree Course 8 started from) and
  `SETUP-BRIEF-2026-11-17.md:35`; `c8-unit02` states no such total, and the contract states it only inside R.363.
- **Unit 24's C8-20 sentence** is read off `HANDOFF=` in `c8-unit24/receipts.sh`, its md5 against that unit's README record, and
  found once in `c8-tiffinbox/README.md`. `c8-unit01/pinned.txt` is not a line of its own in its README (it stands inside a sentence
  there): counted with `grep -cF`, not `-cxF`.
- **C8-14's comparison** sets aside case, colons, commas and spelt-out letters (`J-D-B-C` → `JDBC`): the script says "MongoDB,
  Documents, Not Rows" where the registry spells "MongoDB: Documents, Not Rows". Nothing to correct.
- **The last rule is `R.488`** (the contract's line `350`); the rules run consecutively from `R.343`.
- **The anchor changes' list:** `02 07 08 10`-`22 24 26 27` — `19`, as expected; `23` and `25` are links.
- **The files outside the repository** are read from two folders up, or from `TRACK_DIR` (the sealed clone sets it), so all three
  runs of record print the same bytes; `c7-unit40` instead let its clone's `counts` differ.
- **`c7-unit40/README.md`**: besides the block and the dated paragraph, the sentence before the block no longer types part 4's
  old md5 (`s40.py` refuses an md5 no capture prints). `c7-unit40/receipts.sh`'s dated comment names the published `readme` md5 and
  part 4's old one in full, so its table of plants keeps passing its own gate.
- **The root README's Course 8 section** says "every container test publishes its container on the loopback address alone" (unit
  `27`'s `bound`: five classes, `0` off `127.0.0.1`), where the brief said "the three ITs"; it names no earlier course by number but
  Course 9 (R.224's call-back rule would ask for a title).
- **No run of `c7-unit40/receipts.sh` whole is a run of record here**: it rebuilds `c6-unit32` first. Its `readme` capture is measured
  inside this unit's `readme` (the same functions, cut out the same way), and its prose gate on its edited README is shown refused `0`.

## For RED

- **The hook** — "Add Course 8 to the front page, and Course 7's finale's receipt fails its own checks, until its capture and its
  checker read the commit they measured." — is the `readme` capture's part 2 (the unpinned md5 and the shipped `chk40.py`'s `3` FAIL
  lines) beside part 3 (one md5) and part 4 (the pinned checker's exit `0`, its output byte-equal; the control's `6` FAIL lines).
- **The builder's `derived:` sources**: every value line below names its capture line or file; `counts` prints each source beside
  its number (the registry, `find -type d`, the reports' line, the `receipts.md5` files, the contract's grep, the roadmap by number and
  by grep).
- **R.224:** `s828.py`'s `TITLES` gains the next course's three titles off `java9_series.py`, asserted equal to the roadmap by
  `chk28.py static`. The pin's lead sentence passes `s828.py` and fails `s827.py`'s list (the control: `R.224: a call-back without its
  title`).
- **The hand-off's lines** pass `s828.py` with `0` hits, the course's number and its lesson count among them ("Course nine of
  nineteen", "twenty-six lessons in five sections"); a LESSON's number in any form - a number word, a digit, an ordinal, a
  `unit 04` or `U04` form - fires XU28's first family; XFAM_S5's forward-reference family fires on the number-word and ordinal forms too,
  not on `U04` (the plants below). The pin's lead sentence passes `s828.py`; `s827.py` and the S5 probe's `s823.py` refuse it
  (R.224), the control.
- **The live video's builder** (`data-jpa-hibernate/_builders/s740.py:30`) asserts that `c7-unit40/receipts.md5` equals its
  evidence commit's: on today's tree it would stop there. That is a published video's builder — not edited. The video shows what it
  was built with; the repository's line moved by design (R.73).
- **R.211/R.331's grep** over the shipped builders and every `c*-unit*/receipts.sh` and `harness/*` for the root README, `c7-unit40`,
  its old md5 and `70ad921`: `s740.py` (above, not edited), `s827.py` (unit 27's builder, names no `c7-unit40` file it reads),
  `c5-unit30/receipts.sh` and `c6-unit32/receipts.sh` (their pinned functions' labels; re-run unchanged in part 5), and `c7-unit40`'s
  own two files (pinned here).
- **Carried for the next course's BLUE:** its folder is read-only here. `rest-apis-done-right/_briefs/SETUP-BRIEF-2026-11-23.md:51-52`
  and `:366-367` and `UNIT-BRIEFS-S1-DESIGN.md:419` still hold the stale lines unit `27` found. Its finale pins this unit's live read
  of the README (C9-1).
- **`c7-unit40/receipts.sh` run whole on this commit's tree** (once, not a run of record): `c6-unit32`'s receipt re-run exit `0`, both
  its captures = published, its build offline; `readme` `3`/`3` = the republished line. Its `counts` stops at its own retirement
  check: `data-jpa-hibernate/scripts-and-decks/` holds `40` scripts today where its check expects `34` (the folder outside the
  repository grew after Course 7's finale; `0` of them hold the retired words). That is not this commit's change — the `counts` line
  and `chk40.py`'s counts checks are untouched — and it is named here for whoever re-runs that receipt next.

## The ledger rows this unit pays

| Row | Here | State at the course's end |
|---|---|---|
| **C8-1** the root README at a finale, every live reader pinned | the pin, one commit, all three readers (`readme`) | **paid** |
| **C8-14** Course 7's finale's counts and titles | `counts`' C8-14 lines | **checked**: nothing to correct |
| **C8-21** the course's name on the rail | `PLAYLIST_NAME` unchanged in the registry | **unchanged** |
| **C8-25** the hand-off for the next course | the hand-off's facts: `28` · `5`, Course nine of nineteen, `26` · `5`, the three titles, `19` anchor changes, `18 + 3` → `18 + 14`, `12` handler methods, the pinned sentence and its md5, the two advisories | **handed** to the next course's C9-10 |
| C8-6, C8-7 | units 06 and 25 | paid; the JDBC keyset branch closed |
| C8-19 | — | closed for Course 8 |
| C8-20 | unit 24 | paid at 24; unchanged |
| C8-23 | Kafka's side, handed on | open: the messaging course's (*Choosing a Broker*) |
| C8-2…C8-5, C8-8…C8-13, C8-15…C8-18, C8-22, C8-24 | Sections 1-4 | as their briefs' rows left them |

## The values the video may say

Each value beside its source — the builder's `derived:` line is made from this block (R.477).

<!-- values: begin -->
```text
readme: the published fcbf0ce27cdd4fd0184ab8367d76226c = the shipped function on the README before the edit (readme part 1; git show e65298c:c7-unit40/receipts.md5)
readme: the unpinned function on the README after: md5 3bb51d46cb89ee877a8e4162a19ff058 != published; 6 lines differ; the shipped chk40.py exit 1, 3 FAIL lines - the folders, the sections, the title (readme part 2)
readme: the pinned function, README before and after: one md5 b75791fa5077f943c0bd85a9bdfbe5b3 = c7-unit40/receipts.md5's readme line, republished (readme part 3)
readme: 3 lines differ from the published by design - the shown command, part 4's md5, part 4's "as it is now" line (readme part 3)
readme: the pinned chk40.py exit 0 before and after, output = the shipped one's on the published capture; on the unpinned capture exit 1, 6 FAIL lines (readme part 4)
readme: c6-unit32 68a6fc68d166b539919751ffe4774324 and c5-unit30 4456fd199c0cc10b1647683ea7526015 = their receipts.md5, unchanged (readme part 5)
readme: the README's reads in readmecap40 + part 4: 7 -> 1 (the label); chk40.py's: 2 -> 0 (readme, "the reads of the README, counted")
counts: 28 lessons · 5 sections (java8_series.py, counts "java8_series:" line)
counts: 19 anchor changes - 02 07 08 10-22 24 26 27; 23 and 25 links (counts, find -type d)
counts: tests 18 + 3 at the start (c7-unit39/README.md's reports; SETUP-BRIEF-2026-11-17.md:35) -> 18 + 14 at the end (c8-unit27/README.md's bound: line)
counts: captures 48 · 54 · 44 · 75 · 29 by section, 250 in 27 units (the receipts.md5 files, the registry's SECTION_OF)
counts: pinned sentences c8-unit01 59850ae54f53d33200307e32edba7973 · c8-unit12 ba35ab90cf46ded9976dc945ca11da2d · U24's C8-20 a6581dab7e33c458146b1f0e9cb114bc · this unit's pinned.txt 2a866987eea96a5cb42553f5dfb319b3 (counts)
counts: the rules R.343 to R.488 (STYLE-CONTRACT.md:350), 146 rules, consecutive (counts, the contract's grep)
counts: Course 9 - 26 lessons · 5 sections; What REST Actually Says · Resources, URIs and the Method Table · Status Codes That Mean Something (java9_series.py = TRACK-ROADMAP.md :366, :369-371)
counts: the track 19 courses (TRACK-ROADMAP.md:48) - "Course nine of nineteen"
counts: C8-14 nothing to correct (40-whats-next-not-everything-is-a-relation.md :134, :141 against java8_series.py)
counts: the advisories' shape on the anchor: 0 files; @Query lines 4, all JPQL or SQL, no parameter; spring-data-elasticsearch 6.1.2, spring-data-mongodb 5.1.2, Boot 4.1.2 (counts)
counts: the dev run's handler methods: not captured in 27, not said (counts)
api: 12 handler methods of TiffinBox's own, GET 8 · POST 4 (api, /actuator/mappings, the com.tiffinbox rule)
api: PATCH /customers -> 405, Allow {GET, POST}, application/problem+json, "Method 'PATCH' is not supported." (api)
api: DELETE /customers/Ravi -> 405, Allow {GET} (api)
api: GET /v3/api-docs -> 404 · GET /swagger-ui.html -> 404 (api)
api: the callers - its pages (@{/customers} form, @{/customers/new}, @{/dashboard}), its tests (FeedTest, FullStackTest, TiffinBoxWebTest), the seven (c5-unit11/curlset.sh) (api)
api: the pinned sentence, pinned.txt md5 2a866987eea96a5cb42553f5dfb319b3 - its facts = the api capture (chk28.py api)
```
<!-- values: end -->

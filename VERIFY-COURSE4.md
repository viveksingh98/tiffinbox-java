# VERIFY-COURSE4 — every Course 4 README command, run from a fresh clone

`verify_course4.sh` (repository root, untracked, not committed) runs every command the Spring Framework
Core READMEs give a viewer — `c4-tiffinbox/README.md`, `c4-unit01` … `c4-unit32/README.md`, and the
exercise `README.md` / `solution/SOLUTION.md` files — and prints PASS / FAIL / SKIP for each. This file
records the current run, what the fix commit `51035ef` changed and how each fix is now held, the
mutation tests, and every FAIL with its evidence.

## The current run — at `51035ef`

| | |
|---|---|
| date | 2026-09-27, 08:07:54 → 08:23:11 |
| commit | `51035ef` "Course 4: fix the 8 README/code FAILs a fresh-clone verification found" (checked out in a fresh clone; the local HEAD — `611a3fc` when this was written — differs from it only outside `c4-*`: Course 5 files and their `.gitignore` lines, so everything below holds at HEAD too) |
| clone | `git clone <this repository> "…/scratchpad/verify c4/tiffinbox-java"; git checkout 51035ef` — **the path contains a space** |
| command | `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; C4_CENTRAL_CACHE=<scratch>/central-cache C4_CENTRAL_SEEDS=<20 local repositories> ./verify_course4.sh` — no arguments, every `.m2-demo` cold |
| toolchain | JDK 25.0.4.1 (Homebrew openjdk@25), Apache Maven 3.9.16, python3, bash (zsh login shell), macOS 27.0 |
| Maven | 39,046 resolution requests, every one answered by the caching proxy on 127.0.0.1:18499 (39,044 from its cache, 2 `com.tiffinbox` 404s); none reached Central or its mirror in this run — the cache had been filled during the earlier runs, from the seeds and, for what no seed held, from Google's mirror of Central (see below) |
| wall time | **15m15s** |
| result | **PASS 939 · FAIL 1 · SKIP 10** (exit 1) |

**How the downloads were made — and why.** Every unit's `.m2-demo` started empty and was filled by Maven's own
resolver over HTTP. That is some sixty cold local repositories per full run — 39,046 requests, counted above.
After the experiments that built this script and two cold full runs, Maven Central blocked this machine's IP —
`HTTP 429`, "Your ip has exceeded rate limits" — partway through the third full run (every build from unit 10
on failed, with nothing wrong in the units). The block lasted about 1 h 55 min (one POM polled once a minute:
429 from 06:29 to 08:23, 200 at 08:24). Sonatype's guidance for that block is a caching proxy, not harder retries, so
the script now starts one on 127.0.0.1:18499 (a mirror passed as `MAVEN_ARGS=-s …`, so the units' own
`receipts.sh` use it too; `C4_CENTRAL_CACHE=off` goes direct). For this run the proxy was seeded, read-only, with
released artifacts from the author's existing `c4-unit13…32/.m2-demo` directories and `~/.m2/repository`
(checksums recomputed from the bytes; `maven-metadata.xml` asked of Central first); what the seeds lacked went
to Central — and, while Central was still refusing this IP, to Google's public mirror of Central
(`maven-central.storage-download.googleapis.com`; its `maven-resolver-api-1.9.22.jar` checked against Central's
published `.sha1`). A 429 that still reaches Maven is retried with back-off (30 s … 5 min) before a check is judged. The only README line
that quotes Central's URL (`c4-tiffinbox`'s `-pl` `[ERROR]`) is compared with the proxy's URL read as Central's.
The course's own `com.tiffinbox` artifacts are answered 404 by the proxy without asking Central (Central does
not host them; the `-pl` table's "Could not find artifact … in central" is exactly that 404).

Teardown, all PASS: git reported 0 ignored/untracked entries under `c4-*` before the run and 0 after
(every generated file removed); every tracked `c4-*` file byte-identical (content fingerprint);
`~/.m2/repository/com/tiffinbox` untouched; no JVM left running from any `c4-*` folder; ports
18425 18431 18441 18442 18445-18449 18451 18452 free. Nothing ran on 18500+.

Checks per folder: tiffinbox 70 · unit01 45 · unit02 23 · unit03 21 · unit04 37 · unit05 29 · unit06 31 · unit07 25 · unit08 36 · unit09 25 · unit10 26 · unit11 36 · unit12 28 · unit13 24 · unit14 29 · unit15 27 · unit16 42 · unit17 28 · unit18 28 · unit19 24 · unit20 29 · unit21 27 · unit22 22 · unit23 23 · unit24 31 · unit25 25 · unit26 25 · unit27 21 · unit28 17 · unit29 19 · unit30 24 · unit31 37 · unit32 11 · teardown 5

History: the first two runs (at `439c5be`, before the fix) were PASS 909 · FAIL 8 · SKIP 9 (26m14s) and
PASS 914 · FAIL 8 · SKIP 10 (26m15s), with the same eight FAILs; they are kept below with their evidence. The
third, at `51035ef`, was stopped at unit 16 when Central's 429 block made every build fail (its first nine
units had already shown the eight FAILs fixed and one new one, the one left below); the fourth, through the
seeded cache but with Central still blocked, was stopped in unit 01 after the three commands that needed an
artifact no seed held (`maven-resolver-*-1.9.22.jar` for `install`, and Spring Boot 4.1.1) had failed with 429 —
which is why the proxy now falls back to Google's mirror of Central.

## What is left at `51035ef` — one FAIL, introduced by fix 7 (cause: `.gitignore`)

- **c4-unit01** — …and everything the README's block wrote is covered by .gitignore — `git status shows new untracked: c4-unit01/breaks/one-bean-deleted/.cp`

Unit 01's new break line, `(cd breaks/one-bean-deleted && mvn … clean package dependency:build-classpath
-Dmdep.outputFile=.cp -DincludeScope=runtime && java … > .r-cb1.out 2>&1; echo "exit $?")`, writes
`c4-unit01/breaks/one-bean-deleted/.cp`. The `.gitignore`'s Section 1 block lists `c4-unit01/.cp` …
`c4-unit06/.cp` and, for the break, only `.r-*` and `target/`; so after a viewer follows the README,
`git status` shows `?? c4-unit01/breaks/one-bean-deleted/.cp` — a file of absolute paths the `.gitignore`
itself says "is machine-local by construction and must never be committed". Everything else in the new
block reproduces (it prints `exit 1`; `chain.py` then shows `UnsatisfiedDependencyException` →
`Caused by: NoSuchBeanDefinitionException`). Not fixed here: one line, `c4-unit01/breaks/one-bean-deleted/.cp`,
in that `.gitignore` block would close it.

## The eight FAILs of `439c5be`, and how each is held now

Every check below reads the README at run time, so it tests the corrected text — and a README that
regresses to the old text FAILs again (demonstrated: see "Regression" under the mutation tests).

| # | where | the old FAIL (at `439c5be`) | the fix in `51035ef` | what the script checks now | now |
|---|---|---|---|---|---|
| 1 | `c4-tiffinbox/README.md`, MANIFEST block | Class-Path: README 5 jars, actual 15 | block re-captured (15 jars, wrapped as a manifest wraps) | the README's Class-Path, unwrapped, equals the built jar's | PASS |
| 2 | same, `ls tiffinbox-web/target/lib` | README 5 names, actual 15 | block re-captured | the listing equals the README's, both ways | PASS |
| 3 | same, `mvn -B dependency:tree` | README 9 lines, actual 29 | block re-captured (29 lines); prose names the Spring BOM; the `-pl` paragraph says the Spring subtree disappears too | the tree equals the README's, line for line; **new:** every name the "Versions live in exactly one place" sentence gives (`tiffinbox-core`, `h2`, `jackson-databind`, `jakarta.annotation-api`) is in the parent's `<dependencyManagement>` and the Spring BOM is imported there; "the four plugin versions" = 4 `<plugin>` in `<pluginManagement>`; the `-pl` tree has neither h2 nor `org.springframework` | PASS |
| 1-3 | same, new "Read this first" note | — | "outputs re-captured … (15 jars at run time …) … frozen in `../c4-unit31/before/`; run a command there to see Course 3's output" | **new:** `target/lib` holds the number of jars the note gives; in `../c4-unit31/before/` a build gives the manifest Class-Path, the `lib` listing and the dependency tree that **`c3-tiffinbox/README.md`** (Course 3's own, frozen README) prints | PASS |
| 4 | same, "Course 4 starts here" | "still hash to `fdb1643d…` here", "`Wiring.java` … copied here", ledger 18·4·3·0·0 — all false in `c4-tiffinbox` | section marked **Historical**, pointing at `../c4-unit31/before/` | where the claims are checked is **decided by the README**: with a note that is "Historical" and names `../c4-unit31/before/`, they are checked there — the five hash `fdb1643d…`, `Wiring.java` is `cmp`-identical to `c3-unit28`'s, the ledger prints the section's own panel — plus the note's own claims here (the five now hash `4aa1368f…`; `onlyannotations.py` before → anchor: 0 code lines) and "not in this one" (here the ledger exits 2). Without the note they are checked here, as before, and FAIL | PASS |
| 5 | `c4-unit01/README.md` line 15 | "three places, one value" named `c4-tiffinbox/…` (`4aa1368f…` there) | names `c4-unit31/before/tiffinbox-core/…` and states `c4-tiffinbox`'s `4aa1368f…` | **the places are read off the sentence** (every backticked path in it; `…/.../…` a wildcard) and the README's own derivation is run in each: 3 places, each `fdb1643d…`; and the quoted `4aa1368f…` prefix is `c4-tiffinbox`'s | PASS |
| 6 | `c4-unit01/README.md` command block | no line wrote `.cp`: `cat: .cp: No such file or directory`, exit 1 | `dependency:build-classpath … -Dmdep.outputFile=.cp` line added | the block must contain that line **before** its first `java -cp "target/classes:$(cat .cp)"` line (the break's own `-Dmdep.outputFile=.cp` does not count), and it is run as the README's line | PASS |
| 7 | same, `python3 chain.py breaks/one-bean-deleted/.r-cb1.out` | input `.gitignore`d, never produced: `FileNotFoundError`, exit 1 | the block now builds the break and writes `.r-cb1.out` first | the block must write `breaks/one-bean-deleted/.r-cb1.out` before the `chain.py` line reads it; the README's two-line command is run verbatim → prints `exit 1` ("# exit 1: the break"); the capture holds the exception (mvn exited 0, java ran); `chain.py` exits 0 and its output is `UnsatisfiedDependencyException` → `Caused by: NoSuchBeanDefinitionException` | PASS (but see the FAIL left) |
| 8 | `c4-unit11/exercise/stamp.py` | stale copy: start state hashed `572a3801…`, not the README's `20b2e62e…` | byte-identical to `c4-unit11/stamp.py` | unchanged check: the language-pinned start state through the `stamp.py` shipped in `exercise/` gives the README's md5, 3/3 | PASS |

## What changed in the script for `51035ef`

- **The eight checks test the corrected claims** (table above): the MANIFEST / `lib` / tree blocks are compared
  as before, now against the re-captured text; the "Read this first" note is held (its jar count, and
  `../c4-unit31/before/` giving Course 3's own outputs from `c3-tiffinbox/README.md`); "Versions live in exactly
  one place" is read and every artifact it names looked up in the parent's `<dependencyManagement>` (and the BOM
  import); the `-pl` tree must show neither h2 nor Spring; the historical section is checked **where its note
  says**, and in this folder when it carries no note; unit 01's three places are read off its sentence, its
  block's order is checked (`.cp` and `.r-cb1.out` written before they are read), its new two-line break command
  is run verbatim, and what it writes is held to `.gitignore`.
- **A caching proxy of Central** (above) — seedable, with Google's mirror as the fallback when Central refuses —
  and a 429 back-off in every expected-exit check; a FAIL's evidence now also prints Maven's `[ERROR]` lines
  (they come last, where the first twelve lines of output never reached).

## The 10 SKIPs — each labelled in the output with what went unchecked

- **c4-tiffinbox** · 'pass another as the first argument: java -jar target/tiffinbox-web-1.0.0.jar 9090' (9090 is outside the 18400-18499 range this run may bind; the same positional-port argument is run below with 18431)
- **c4-tiffinbox** · 'The receipt: the split changed nothing observable' — md5 d6402e7c500031cb39addba72cb846e5 6 of 6 (no command is given; it compares c2-capstone with c3-tiffinbox, Course 3's receipt, not anything in this folder)
- **c4-unit04** · the module table's rows 2-6 (CGLIB in a module with no opens, --add-opens …=ALL-UNNAMED / =spring.core, opens, class path) (the README says so itself: that failing probe 'was run in the author's scratch module path, not here' — nothing shipped to run)
- **c4-unit05** · the three CGLIB limits (final @Configuration class, final @Bean method, no visible constructor) (no probe for them ships in this unit; the table is prose)
- **c4-unit10** · 'Its raw form gives 2 distinct values across three runs' (timing, not code: the JUL header's clock second decides it (this run: 1 distinct); unit 11's README says the count 'is itself not a fact')
- **c4-unit11** · the table's 'raw, same 3 runs: 2 distinct' column (timing, not code (this run: 2 distinct raw value(s)); the README itself goes on to say the count 'is itself not a fact')
- **c4-unit24** · '834 Spring classes in a Spring run' (what the weaver would examine without the include line) (no command in the unit reproduces that count)
- **c4-unit28** · the raw gaps panel (run 1: [304, 300, 300] …) (durations: 'they wobble, which is exactly why no single one is quoted as a fact' — the shape above is what is held)
- **c4-unit29** · the raw-numbers panel (counts 13 vs 13, longest gaps 856 vs 108 ms …) ('printed so you can see the wobble, never quoted as facts' — the computed verdicts above are what is held)
- **c4-unit29** · SOLUTION.md (the exception kept in the future; a catch-and-log wrapper) (the solution is code to write, not a file or a one-line edit — nothing shipped to lay over the exercise)

## Mutation tests

### Regression — the three fixed files put back to `439c5be`

`git checkout 439c5be -- c4-tiffinbox/README.md c4-unit01/README.md c4-unit11/exercise/stamp.py`, then
`./verify_course4.sh tiffinbox 01 11`: **PASS 130 · FAIL 11 · SKIP 3**. Every one of the eight old FAILs comes back, and
three more fail because the old text lacks the claims the fix added ("Read this first" twice, and unit 01's
"whose copies now hash `4aa1368f…`"):
  - c4-tiffinbox: …its Class-Path is the one the README prints
  - c4-tiffinbox: …the jars the README lists, and only those
  - c4-tiffinbox: 'Read this first': '? jars at run time' (tiffinbox-web/target/lib)
  - c4-tiffinbox: 'Read this first': '… frozen in ../c4-unit31/before/; run a command there to see Course 3's output'
  - c4-tiffinbox: …the tree is exactly the README's
  - c4-tiffinbox: 'Course 4 starts here' (2026-09-16), no historical note: 'the five carried sources still hash to fdb1643d here', 'Wiring.java … copied here', and its ledger panel
  - c4-unit01: …the five carried sources, derived as printed, in c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/ -> fdb1643d622615f3c331d75deaebb9da
  - c4-unit01: …'c4-tiffinbox, whose copies now hash ?…' (a prefix, as the README quotes it)
  - c4-unit01: README block, in order: 'mvn … clean package' then 'java -cp "target/classes:$(cat .cp)" com.tiffinbox.SameThreeBoxes'
  - c4-unit01: README: python3 chain.py breaks/one-bean-deleted/.r-cb1.out
  - c4-unit11: …the start state, masked with the stamp.py shipped IN exercise/ (python3 stamp.py), language-pinned -> md5 20b2e62eaefb17dc487f9bc1b7169545

Restored with `git checkout 51035ef -- …`; `git diff` against `51035ef` empty.

### Nine breakages of different kinds, nine caught

On a fresh clone at `51035ef`, after its full run, with the final script:
`./verify_course4.sh 03 07 08 09 12 14 27 31 32` → **PASS 180 · FAIL 18 · SKIP 0**. Reverted (`git checkout` of the eight
files, the listener killed; `git diff` empty, nothing on 18441), the same nine units: **PASS 238 · FAIL 0 · SKIP 0**.

| # | kind | what was broken | caught by (FAIL) |
|---|---|---|---|
| M1 | a README hash edited | `c4-unit07/README.md`: last hex digit of `.r-rail` `c302ca86…384d` → `…384e` | `java … LifecycleRail -> exit 0, 3/3, md5, 30 output lines` — "md5 …384d, the README says …384e" |
| M2 | a receipts.sh assertion's target changed in source | `c4-unit27/Pools.java`: `ThreadPoolTaskExecutor` sized 2 → 3 | `c4-unit27/receipts.sh -> exit 0` — exit 1 ("sized pool: 3") |
| M3 | a file a README command needs, deleted | `rm c4-unit08/lifecycle-rows.sh` | `sh lifecycle-rows.sh -> …` — exit codes [127 127 127]; and its panel |
| M4 | an expected output line changed (README panel) | `c4-unit09/README.md`: `oneForEver … isSingleton()=true` → `=false` | `…getScope()="" and isSingleton()=true` — "1 of the panel's 3 line(s) are not in the capture" |
| M5 | a port left occupied | `python3 -m http.server 18441 --bind 127.0.0.1` | `c4-unit31: port(s) 18441 … free before it runs` — "already listening: 18441(Python pid …)"; unit 31 not run; teardown port check too |
| M6 | a shipped solution that no longer reaches the README's end state | `c4-unit12/exercise/solution/Checks.java`: `@Order(3)` → `@Order(0)` on power | `exercise/solution/ -> exit 0, 3/3, md5` (vs `c3563e17…`); and "End state … [water, gas, power]" |
| M7 | the published hash file edited — receipts.sh prints DIFFERS **and still exits 0** | `c4-unit32/receipts.md5`: `takeout …074c` → `…074d` | `receipts.sh .r-takeout: = receipts.md5 = the README` and "not one capture drifts or differs" — while `c4-unit32/receipts.sh -> exit 0` stayed PASS |
| M8 | a README command edited | `c4-unit03/README.md` line 12: `…ThreeInjectionPoints` → `…ThreeInjectionPoint` | `java … ThreeInjectionPoints` — "the README no longer prints this command"; its claim and panel |
| M9 | non-deterministic output — receipts.sh prints `*** DRIFTS ***` **and still exits 0** | `c4-unit14/TheName.java`: prints `System.nanoTime()` | "not one capture drifts" (`name-right … *** DRIFTS ***`) and both hash checks — while `c4-unit14/receipts.sh -> exit 0` stayed PASS |

M7 and M9 are the Course 3 lesson in Course 4 form: fourteen of the nineteen receipts.sh print
`*** DRIFTS ***` without changing their exit code, and units 31-32 print "DIFFERS from the published"
and exit 0. An exit-0 check alone passes both mutations; this script fails them.

## The eight FAILs found at `439c5be` — the original evidence

A. `c4-tiffinbox/README.md` (its carried Course 3 half, not updated after unit 31's rewire):
1. `unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF` — README Class-Path 5 jars
   (`tiffinbox-core`, `h2`, three `jackson-*`); actual 15 (plus `spring-context/aop/beans/core/expression-7.0.9`,
   `commons-logging-1.3.5`, `jspecify-1.0.0`, `micrometer-observation/commons-1.16.7`, `jakarta.annotation-api-3.0.0`).
2. `ls tiffinbox-web/target/lib` — README 5 names, actual 15.
3. `mvn -B dependency:tree` — README 9 coordinate lines, actual 29 (the Spring subtree under core, twice).
4. "Course 4 starts here (added 2026-09-16)" — "still hash to `fdb1643d…` here" (actual `4aa1368f…`),
   "`Wiring.java` … copied here" (gone), the ledger 18/4/3/0/0 "re-derived here"
   (`sh ../c4-unit01/ledger.sh tiffinbox-core/…/wiring/Wiring.java` exits 2).

B. `c4-unit01/README.md`:
5. Line 15, "It gives `fdb1643d…` in … `c4-tiffinbox/tiffinbox-core/…` … — three places, one value":
   `c4-tiffinbox` gave `4aa1368f…` (the README's own "Since the capstone" section already said so).
6. Lines 22-31: `mvn … clean package` then `java -cp "target/classes:$(cat .cp)" …` — nothing wrote `.cp`:
   `cat: .cp: No such file or directory`, `NoClassDefFoundError`, exit 1.
7. Line 30: `python3 chain.py breaks/one-bean-deleted/.r-cb1.out` — a `.gitignore`d capture no command made:
   `FileNotFoundError`, exit 1.

C. `c4-unit11/exercise/stamp.py` (code):
8. The exercise's start state, language-pinned and masked with `exercise/stamp.py`, hashed
   `572a38016ea4006fadee4db092926836`, not the README's `20b2e62e…`: that copy predated the fix
   `c4-unit11/stamp.py` records (it rewrote ContextReport's `sort … natural order` row and masked 3 stamps,
   not 2). `../stamp.py` gave `20b2e62e…` 3/3.

## Observations — not FAILs, written down for the author

- **Some break hashes are over `chain.py`'s output without the line saying so.** Unit 02's "Stable across
  three runs, hashable with no masking, md5 `f3583dba…`" is `chain.py` of the capture; the raw
  `java … BreakMissingName 2>&1` hashes `7ed82088…` (also 3/3). Units 04 (`903600f0…`) and 06 (`f3503356…`,
  `d906f4b6…`) are the same; unit 03 says chain.py elided the frames; units 07, 10 and 12 say
  "through chain.py". The script hashes the filtered form, which reproduces.
- **Section 1's exercise/ and breaks/ print no build line** (apart from unit 01's break, now). Following unit
  01's offline paragraph and the `.gitignore` (no `.m2-demo` for them), the script resolves them into the
  unit's `.m2-demo` — the same `$PWD/../../.m2-demo` the new unit-01 break line uses.
- **`c4-tiffinbox`'s `-pl` table only holds before `install`**, and the README prints `mvn -B clean install`
  before it; top to bottom, `mvn -B clean package -pl tiffinbox-web` succeeds. The script runs the table
  first, as verify_course3.sh did for the same carried text.
- **Counts in prose the script does not hold:** `c4-tiffinbox` says "The five objects carry `@Component` (and
  two `@Value` parameters, one `@PostConstruct`)" and unit 31 says "`@Value` on two constructor parameters".
  The rewired sources have five `@Component`s, but four `@Value` constructor parameters (Database,
  OrderQueue, two on TiffinBoxServer) and two `@PostConstruct` (Database, TiffinBoxServer).
- **Timing claims:** unit 10's "Its raw form gives **2 distinct values** across three runs" counts clock
  seconds (1 or 2 here); SKIPped with the count measured in the SKIP line.
- **Six checks pass only with a column dropped or a wrapped value re-joined**, and each such PASS line says
  so: unit 01's ledger row (dot leader), unit 02's Definitions panel (`scope=`/`lazy=`), unit 05's end
  state ("(your code)"), unit 10's `[2]` panel (a wrapped value), unit 15's panel and SOLUTION.md (a package name).
- `c4-unit12`'s `chain.py` output keeps the second line of a multi-line JUL record (`SELECT SUM(…)`) above
  the exception — cosmetic; the hash is stable and the README's panel does not show it.

## What the script holds

- **Units 01-12**: each README command, asserted to be printed verbatim, run 3× with stdout+stderr; the
  exit code, 3/3 identity, the md5 (read off the README at run time: the Nth 32-hex string after a fixed
  anchor — an edited README hash is a FAIL), the stated line count, the README's output panels line by
  line, the exercise start state and the shipped solution (laid over a copy beside `exercise/`, never over
  the tracked file), and every "Reproducible offline" claim as a pair (online `verify`, then `-o`).
  Unit 01 also: its block's order (`.cp` and `.r-cb1.out` written before they are read), and that
  everything its block writes is covered by `.gitignore`.
- **Unit 13**: `flip.sh`, `flip.sh sysprop` (A/B/A′ hashes, the winner lines, the file put back), the
  guards (exit 2), the errata's `TIFFINBOX_COOKS=4`, and the README's warning that an unquoted
  `-Dmaven.repo.local=$PWD/.m2-demo` is split by bash in a path with a space.
- **Units 14-32**: the README's build lines; `receipts.sh` PASSes only on exit 0; then every capture's hash
  on receipts.sh's own line against the README's, "3/3", the stated exit code, the README's command being
  the one receipts.sh runs, no `DRIFTS`/`DIFFERS` line, everything written covered by `.gitignore`;
  units 31-32 also against `receipts.md5`; the README panels against the `.r-*.out` captures; source line
  numbers the errata cite; the exercises (start state, shipped solution, the SOLUTION.md edits that are
  stated exactly).
- **c4-tiffinbox**: both halves of its README (above), run against the project as it is; the `-pl`
  table before `install`; the server on 18425 and 18431 with every curl; the offline receipt.
- **Around every unit**: fixed ports asserted free before (a busy port is a FAIL) and after; every JVM
  whose working directory is inside the unit killed and reported; at the end, the tree as found.

Re-run: `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; ./verify_course4.sh` (everything),
`./verify_course4.sh tiffinbox 01 11` (only those); `KEEP_M2=1` keeps the scratch repositories for a warm
re-run, `KEEP_WORK=1` keeps every capture the run took. The Central cache is on by default and kept in
`${TMPDIR}/c4verify-central-cache` between runs (`C4_CENTRAL_CACHE=<dir>` moves it, `=off` goes straight to
Central); `C4_CENTRAL_SEEDS` (newline-separated local repositories) lets it serve released artifacts without
asking Central at all; `C4_429_RETRIES=N` sets the back-off retries (5).

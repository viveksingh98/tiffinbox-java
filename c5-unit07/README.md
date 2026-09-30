# c5-unit07 — application.yaml in Practice

Course 5 · Spring Boot · Section 2 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-30.
TiffinBox's four settings move from `application.properties` to `application.yaml` — the same keys, one level of nesting
per dot — and this unit measures what the new format gives and what it hides: the parser that reads it, a list that is
three keys, a second document a profile switches on, the spellings that reach a key, values YAML retypes as it reads them,
and indentation mistakes — two loud ones, and one that makes no sound.

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it. "Before" is `../c5-unit06/after/` (the
anchor as the last unit left it), **copied** to `.harness/before/` and built there, so this unit never writes into another
unit's folder. Clean builds, offline first; every number the video speaks is asserted; three runs per capture.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 11 captures, 3 runs each; every spoken number asserted; a published-md5 mismatch stops it
```

(`receipts.sh` carries the same two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) `receipts.sh`
**dies** when a capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can see which one
moved (tested: a wrong published hash for `change` stopped the run with exit 1). The builds try `mvn -o` against this
unit's `.m2-demo` (a copy of `../c5-unit06/.m2-demo`: nothing new was needed — snakeyaml 2.6 was already in `lib/`) and
resolve from Maven Central only if that fails. Offline re-run of the frozen tree: `mvn -o -B -f after/pom.xml
-Dmaven.repo.local="$PWD/.m2-demo" verify` → BUILD SUCCESS, 0 WARNING lines.

## The harness — TiffinBox's own `main`, read from the inside

`harness/com/tiffinbox/harness/` holds plain classes with **no class-level annotation**, so TiffinBox's
`@ComponentScan("com.tiffinbox")` (which registers annotated classes only) never picks one up. None copies TiffinBox's
start-up: each calls the tree's own `TiffinBoxServer.main(args)` inside Boot's `SpringApplication.withHook(…)`, whose run
listener is handed the context `main` starts (`Run.java`). If `main` throws, the harness prints the exception's type —
Boot's own report does not always name it — and rethrows the same exception, so the exit code is the one TiffinBox's own
run gives.

- `Winner <key> <TiffinBox's arguments>` — walks the live `Environment`'s property sources **in order** and prints what
  each holds for the key under that exact name (with Boot's `Origin` where the source tracks one). WINNER is what the
  `Environment` answers; "from source N" is the source **Boot's view** at the top of the stack (`configurationProperties`)
  found it in, asked the way that view asks (`ConfigurationPropertySources.get(env)`, source by source). When the view
  found it under another spelling, a line says so, with the name it found (`not under that name: …`). Then the bean
  field the key ends up in, read off the live bean, and which file the class path gives for Boot's two file names.
- `Keys <key or -> <prefix,…> <TiffinBox's arguments>` — for every file Boot loaded (a property source whose name starts
  `Config resource`; a YAML file with two documents is two of them), the keys under the prefixes, each **beside the line
  of the file it came from, as written**, with the value Boot holds and that value's Java type. With a key, it ends with
  the `Environment`'s answer and the bean field.
- `ListKey <key> <TiffinBox's arguments>` — `Keys`' listing for one list, then the list asked three ways: the
  `Environment` by the list's own name, by one item's name, and Boot's `Binder` for a `List<String>`.
- `ByValue <TiffinBox's arguments>` — registers one extra bean by code, `MealTypesByValue`, when the context is prepared
  (so it is created before TiffinBox's own beans). It reads the list the way TiffinBox's classes read their keys: one
  `@Value("${tiffinbox.meal-types}")` placeholder on a constructor parameter.
- `Sources <TiffinBox's arguments>` — every property source, in order, with its class (Spring Framework's or Boot's), and
  the class that declares the method matching a key to an environment variable's name.

**`$BEFORE` and `$AFTER`** are the harness's classes plus that tree's jars (`tiffinbox-web-1.0.0.jar` and `lib/*.jar`);
`receipts.sh` writes them to `.harness/before.classpath` and `.harness/after.classpath`. Every command is printed exactly
as it runs: `receipts.sh` passes it to `eval`, so those two variables expand when it runs. The jar runs (`java -jar
tiffinbox-web-1.0.0.jar …`) are started in that tree's `tiffinbox-web/target`, or in a copy of it (`.harness/no-snakeyaml-*`).

**The demo files.** A folder put in front of `$AFTER` on a class path holds one `application.yaml` (and `both/` an
`application.properties` too) that the class path then gives **instead of** the copy packaged in TiffinBox's jar; the
harness's last line names the file it got. Each is the anchor's `application.yaml` with one declared change, and the
`files` capture diffs every one against it: `both/` (cooks 3 → 4, beside the previous tree's `application.properties`,
byte for byte) · `comma/` (the list as one comma-separated string) · `camel/` (`jdbc-url:` written `jdbcUrl:`, with its own
database name) · `scalars/unquoted/` and `scalars/quoted/` (three lines added) · `breaks/nested/` (the rush document's
`tiffinbox:` block two spaces further in) · `breaks/tab/` (one key's indent a tab) · `breaks/over/` (one key indented one
space too far) · `breaks/onespace/` (the list's last item indented one space further than the two above it) · `exercise/`
(the anchor's file, byte for byte).

**Ports** (Section 2 brief ⚑11: 18670-18679): serve 18670 · keys 18671 · both 18672 · parser 18673 (B never binds) · list
18674 · docs 18675 · relaxed 18676 (the camel placeholder never binds) · scalars 18677 · break 18678 (C and D never bind)
· the exercise 18679. Every command
names its port; `receipts.sh` first checks that nothing listens on 18425 or on any of its ports.

## Masks, filters and hygiene — every one, declared

1. Boot's own log lines (each starts with an ISO timestamp and carries a pid) are dropped from a harness report and
   counted; so are the lines printed before the report (the banner and its blank lines): the last line of each report says
   how many of each (`… elided: N log line(s) of Boot's, and M line(s) printed before the report …`).
2. Boot's INFO line about profiles is kept with everything before its message cut by `sub()` (time, level, pid, thread,
   logger) — `docs` and `serve`.
3. A failed start is shown from Logback's first line (`Application run failed`) to the line that says where
   (`in 'reader', line …, column …`), its clock time replaced by `<time>` through `gsub()` — `break` C and D; or as its
   one `Caused by:` / exception line — `list` A, `parser` B, `relaxed`'s camel placeholder. Each ends with a counted line: `… N more line(s) … not
   shown: …`.
4. In `files`, a tab character is shown as `<TAB>` (`gsub()`).
5. `change` shows every changed code line (git's diff, `-U0`); comment and blank lines are counted on the header line, not
   shown.
6. Hygiene: `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS` and `JDK_JAVA_OPTIONS`
   before it runs anything — a variable of yours would otherwise become a property source. It also refuses to run twice at
   once in this folder (`.r-lock`): two runs share `.harness/` and the ports. On every exit — the end, a failed check, or
   Ctrl-C — its EXIT trap stops the JVM it started in the background, if it still runs, and removes the lock; Ctrl-C makes
   it exit 130. Tested 2026-09-30: Ctrl-C (SIGINT to the script's process group) while a `break` run listened on 18678 →
   exit 130, that JVM gone, nothing listening on 18425 or 18670-18679, `.r-lock` removed. If a port is still busy, the
   port check names it and gives the stop command: `curl -X POST http://127.0.0.1:<port>/shutdown`.
7. `serve`'s second and third runs take their flag from `after/README.md` (its logging command and its lunch-rush
   command, the flag after the port), read out of the file by `sed`; each label prints what it read, and `receipts.sh`
   dies if the file stops giving one.

## 1 · The change — one file out, one file in

`.r-change.out` `e0d9c6dfc185f6ef5ecad2ce0d613632`

```
files, README aside: the previous tree 14 · after/ 14 · in both 13: identical 12, changed 1
  only before: tiffinbox-web/src/main/resources/application.properties
  only after:  tiffinbox-web/src/main/resources/application.yaml
TiffinBoxApp.java, every changed line but comments and blanks (4 of those not shown):
  (none)
the file that went, whole: tiffinbox-web/src/main/resources/application.properties
  1 | # The values that lived beside the constructors in Wiring.java, and the port main() used to hard-code.
  2 | tiffinbox.jdbc-url=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1
  3 | tiffinbox.cooks=3
  4 | tiffinbox.days=30
  5 | tiffinbox.port=18425
the file that came, whole: tiffinbox-web/src/main/resources/application.yaml
  1 | # TiffinBox's settings: the four keys application.properties held, one level of nesting per dot.
  2 | tiffinbox:
  3 |   jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1
  4 |   cooks: 3
  5 |   days: 30
  6 |   port: 18425
  7 |   # The meal types TiffinBox serves. Boot keeps a list as one key per item: meal-types[0], [1], [2].
  8 |   meal-types:
  9 |     - VEG
 10 |     - NON_VEG
 11 |     - VEGAN
 12 | ---
 13 | # A second document in the same file, read only while the profile "rush" is active.
 14 | spring:
 15 |   config:
 16 |     activate:
 17 |       on-profile: rush
 18 | tiffinbox:
 19 |   cooks: 6
```

Fourteen files each side (README aside): twelve identical, one changed — `TiffinBoxApp.java`, whose Javadoc gains a
paragraph (4 comment lines counted, no code line). `application.properties` is gone and `application.yaml` is new. The
old file typed `tiffinbox.` four times; the new one writes `tiffinbox:` once and nests the four keys under it — one level
of indentation per dot — then adds the list (lines 8-11) and, after `---`, a second document for the profile `rush`
(lines 12-19: `cooks: 6`).

## 2 · What Boot read from each file — and the seven responses

`.r-keys.out` `d4729667c6af132a29f000415189e44e`

```
the previous tree: application.properties
$ java -cp "$BEFORE" com.tiffinbox.harness.Keys - tiffinbox --tiffinbox.port=18671
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 7 · Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
  line  2 | tiffinbox.jdbc-url=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1  ->  tiffinbox.jdbc-url = jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1 (String)
  line  3 | tiffinbox.cooks=3                                           ->  tiffinbox.cooks = 3 (String)
  line  4 | tiffinbox.days=30                                           ->  tiffinbox.days = 30 (String)
  line  5 | tiffinbox.port=18425                                        ->  tiffinbox.port = 18425 (String)
the class path gives: application.yaml <- none · application.properties <- tiffinbox-web-1.0.0.jar!/application.properties
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
this tree: application.yaml
$ java -cp "$AFTER" com.tiffinbox.harness.Keys - tiffinbox --tiffinbox.port=18671
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 7 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  line  3 |   jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1  ->  tiffinbox.jdbc-url = jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1 (String)
  line  4 |   cooks: 3                                           ->  tiffinbox.cooks = 3 (Integer)
  line  5 |   days: 30                                           ->  tiffinbox.days = 30 (Integer)
  line  6 |   port: 18425                                        ->  tiffinbox.port = 18425 (Integer)
  line  9 |     - VEG                                            ->  tiffinbox.meal-types[0] = VEG (String)
  line 10 |     - NON_VEG                                        ->  tiffinbox.meal-types[1] = NON_VEG (String)
  line 11 |     - VEGAN                                          ->  tiffinbox.meal-types[2] = VEGAN (String)
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
the old file's keys, found in the new file: 4 of 4 · with the same value, as text: 4 · only in the new file: tiffinbox.meal-types[0] tiffinbox.meal-types[1] tiffinbox.meal-types[2]
```

`Keys` asked each tree's running app what Boot read out of its file, line by line. The four keys the old file held are
all in the new one, with the same values as text (`receipts.sh` compares the two lists); the new file adds three keys,
the list's. One difference the format makes: the properties file hands Boot text (`3 (String)`), YAML hands it a typed
value (`3 (Integer)`) — `@Value` converts either, and the responses do not change:

`.r-serve.out` `07f3ff5253b0c8c66d26f8a79bb24797`

```
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18670
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the logging flag after/README.md gives, after the port: --logging.level.tiffinbox=debug
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18670 --logging.level.tiffinbox=debug
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  route DEBUG lines 5
the lunch-rush flag after/README.md gives, after the port: --spring.profiles.active=rush
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18670 --spring.profiles.active=rush
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  Boot: The following 1 profile is active: "rush"
```

The run command is the one the last unit introduced; the seven responses of `../c4-unit31/curlset.sh` hash to
`115c36bac276128e245ca57df11c2891` with the new file, with the logging flag read out of `after/README.md` (5 route lines), and with
the profile `rush` switched on (six cooks share the same orders, so the responses are the same).

## 3 · Keep the old file, and it answers first

`.r-both.out` `3707edf6fba43e8218466335b04d1844`

```
$ java -cp "both:$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18672
exit 0 · WARN lines 0 · ERROR lines 0
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 8, Config resource 'class path resource [application.properties]' via location 'optional:classpath:/'
   1 configurationProperties    3   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.properties]' via location 'optional:classpath:/' 3   origin: class path resource [application.properties] - 3:17
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 4   origin: class path resource [application.yaml] - 4:10
   8 applicationInfo            -
the bean's own field: OrderQueue.cooks = 3
the class path gives: application.yaml <- both/application.yaml · application.properties <- both/application.properties
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

`both/` holds the previous tree's `application.properties` (byte for byte) and the anchor's YAML with `cooks: 4`. Boot
loads both from the same location, `optional:classpath:/`, and asks `application.properties` first: source 6, the YAML
source 7. The answer is 3 — the old file's — with exit 0 and no warning. That is why the anchor **deletes** the old file
rather than keeping it beside the new one.

## 4 · Who reads the YAML: snake YAML

`.r-parser.out` `f844f0d183e275f30b734e4a85f8229f`

```
A   this tree's jar, lib/ as built: 26 jars, snakeyaml among them: snakeyaml-2.6.jar
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18673
  listens on: 127.0.0.1:18673 · POST /shutdown -> {"stopping":true} · exit 0 · WARN lines 0 · ERROR lines 0
B   a copy of the same jar and lib/, lib/snakeyaml-*.jar deleted: 25 jars
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18673
  listens on: nothing · exit 1 · WARN lines 0 · ERROR lines 1
  java.lang.IllegalStateException: Attempted to load Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' but snakeyaml was not found on the classpath
  … 31 more line(s) of the jar's output not shown: Logback's first line and the stack frames …
A′  A, re-run
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18673
  listens on: 127.0.0.1:18673 · POST /shutdown -> {"stopping":true} · exit 0 · WARN lines 0 · ERROR lines 0
C   the previous tree's jar and lib/ (application.properties), copied, snakeyaml deleted the same way: 25 jars
$ java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18673
  listens on: 127.0.0.1:18673 · POST /shutdown -> {"stopping":true} · exit 0 · WARN lines 0 · ERROR lines 0
```

The parser is `snakeyaml`, one of the jars Boot brought when it arrived (`../c5-unit01/`, `.r-price.out`: "added: …
snakeyaml …"). **A** this tree's jar listens. **B** a copy of the same jar and `lib/` without `snakeyaml-2.6.jar`: exit 1,
nothing listens, and Boot's message names both the file it tried to load and the missing parser. **A′** is A re-run: the
same lines (`receipts.sh` compares them). **C** (a variant, labelled so) is the previous tree — `application.properties`,
no YAML — with the same jar deleted: it starts. Until this unit, nothing in TiffinBox needed snakeyaml.

## 5 · A list is three keys

`.r-list.out` `da902adec6864d8d3abeda1af98bc024`

```
$ java -cp "$AFTER" com.tiffinbox.harness.ListKey tiffinbox.meal-types --tiffinbox.port=18674
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 7 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  line  9 |     - VEG      ->  tiffinbox.meal-types[0] = VEG (String)
  line 10 |     - NON_VEG  ->  tiffinbox.meal-types[1] = NON_VEG (String)
  line 11 |     - VEGAN    ->  tiffinbox.meal-types[2] = VEGAN (String)
env.getProperty("tiffinbox.meal-types")    = null
env.getProperty("tiffinbox.meal-types[1]") = NON_VEG
Boot's Binder, asked for a List<String> at tiffinbox.meal-types: [VEG, NON_VEG, VEGAN]
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
TiffinBox's own readers, in after/: 4 @Value placeholders, in Database.java OrderQueue.java TiffinBoxServer.java
the harness's reader, the way TiffinBox's classes read a key: @Value("${tiffinbox.meal-types}") List<String> mealTypes
A   the list as the anchor writes it: three items
$ java -cp "$AFTER" com.tiffinbox.harness.ByValue --tiffinbox.port=18674
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.meal-types' in value "${tiffinbox.meal-types}"
  the exception TiffinBox's main threw: org.springframework.beans.factory.BeanCreationException
  … 62 more line(s) of this run's output not shown: the banner, Boot's log, its failure report and the stack frames …
B   comma/: the same list written as one string
$ java -cp "comma:$AFTER" com.tiffinbox.harness.ByValue --tiffinbox.port=18674
  exit 0 · WARN lines 0 · ERROR lines 0 · listening lines 1
  @Value("${tiffinbox.meal-types}") List<String> mealTypes = [VEG, NON_VEG, VEGAN]
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.ByValue --tiffinbox.port=18674
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.meal-types' in value "${tiffinbox.meal-types}"
  the exception TiffinBox's main threw: org.springframework.beans.factory.BeanCreationException
  … 62 more line(s) of this run's output not shown: the banner, Boot's log, its failure report and the stack frames …
C   one numbered key of the list: @Value("${tiffinbox.meal-types[0]}")
$ java -cp "$AFTER" com.tiffinbox.harness.ItemByValue --tiffinbox.port=18674
  exit 0 · WARN lines 0 · ERROR lines 0 · listening lines 1
  @Value("${tiffinbox.meal-types[0]}") String first = VEG
```

YAML writes the list plainly — one item per line, each after a dash — but Boot does not keep a list: it keeps **three
keys**, `tiffinbox.meal-types[0]`, `[1]` and `[2]`. The list's own name answers `null`; one item's name answers; Boot's
`Binder` — the tool Boot builds typed objects with, and the next unit's reader — puts the three back together.
TiffinBox's own classes read their settings with `@Value` (4 placeholders, counted). **A** the harness's `@Value` of the
list: exit 1, `Could not resolve placeholder 'tiffinbox.meal-types'` — one placeholder asks for one key, and no key has
that name. **B** `comma/`, the same list written as one comma-separated string (one key): exit 0, `[VEG, NON_VEG, VEGAN]`.
**A′** = A. **C** (a variant, labelled so) one numbered key of the list, `@Value("${tiffinbox.meal-types[0]}")`: exit 0,
`VEG`. So `@Value` reads one of the three keys, never the whole list. Nothing in TiffinBox reads the list yet.

## 6 · Two documents in one file

`.r-docs.out` `a04e15fcae8fa8d410b5f9008d471d82`

```
A   no profile
$ java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18675
exit 0 · WARN lines 0 · ERROR lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
   1 configurationProperties    3   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   7 applicationInfo            -
the bean's own field: OrderQueue.cooks = 3
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
B   the profile rush, switched on
$ java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18675 --spring.profiles.active=rush
exit 0 · WARN lines 0 · ERROR lines 0 · Boot: The following 1 profile is active: "rush"
KEY tiffinbox.cooks -> WINNER 6 · from source 6 of 8, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
   1 configurationProperties    6   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1) 6   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 19:10
   7 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   8 applicationInfo            -
the bean's own field: OrderQueue.cooks = 6
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.cooks --tiffinbox.port=18675
exit 0 · WARN lines 0 · ERROR lines 0 · Boot: No active profile set, falling back to 1 default profile: "default"
KEY tiffinbox.cooks -> WINNER 3 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
   1 configurationProperties    3   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) 3   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 4:10
   7 applicationInfo            -
the bean's own field: OrderQueue.cooks = 3
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

`---` starts a second document, and `spring.config.activate.on-profile: rush` ties it to the profile `rush` — a named set
of settings switched on at start-up. **A** no profile: 7 property sources, and the second document is not one of them;
cooks 3 (document #0, line 4). **B** `--spring.profiles.active=rush`: 8 sources — document #1 (line 19) ranks above
document #0 — and cooks 6; Boot's own INFO line names the active profile. **A′** = A. (The origins read 19:10 and 4:10;
the probe's 17:10 came from a file with two comment lines fewer.)

## 7 · One key, three spellings

`.r-relaxed.out` `69ef1ab3315652a341d6bb3d41707b7f`

```
$ java -cp "$AFTER" com.tiffinbox.harness.Sources --tiffinbox.port=18676
exit 0 · WARN lines 0 · ERROR lines 0
the property sources, in order, and each one's class:
   1 configurationProperties    org.springframework.boot.context.properties.source.ConfigurationPropertySourcesPropertySource
   2 commandLineArgs            org.springframework.core.env.SimpleCommandLinePropertySource
   3 systemProperties           org.springframework.core.env.PropertiesPropertySource
   4 systemEnvironment          org.springframework.boot.support.SystemEnvironmentPropertySourceEnvironmentPostProcessor$OriginAwareSystemEnvironmentPropertySource
   5 random                     org.springframework.boot.env.RandomValuePropertySource
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) org.springframework.boot.env.OriginTrackedMapPropertySource
   7 applicationInfo            org.springframework.boot.ApplicationInfoPropertySource
systemEnvironment's class extends org.springframework.core.env.SystemEnvironmentPropertySource: true
the method that matches a key to a variable's name, resolvePropertyName, is declared by org.springframework.core.env.SystemEnvironmentPropertySource · final: true
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
an environment variable, underscores for the dot and the dash
$ TIFFINBOX_JDBC_URL='jdbc:h2:mem:underscores;DB_CLOSE_DELAY=-1' java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.jdbc-url --tiffinbox.port=18676
exit 0 · WARN lines 0 · ERROR lines 0
KEY tiffinbox.jdbc-url -> WINNER jdbc:h2:mem:underscores;DB_CLOSE_DELAY=-1 · from source 4 of 7, systemEnvironment
   1 configurationProperties    jdbc:h2:mem:underscores;DB_CLOSE_DELAY=-1   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          jdbc:h2:mem:underscores;DB_CLOSE_DELAY=-1   origin: System Environment Property "TIFFINBOX_JDBC_URL"
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 3:13
   7 applicationInfo            -
the bean's own field: Database.url = jdbc:h2:mem:underscores;DB_CLOSE_DELAY=-1
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
an environment variable, no underscore for the dash
$ TIFFINBOX_JDBCURL='jdbc:h2:mem:nodash;DB_CLOSE_DELAY=-1' java -cp "$AFTER" com.tiffinbox.harness.Winner tiffinbox.jdbc-url --tiffinbox.port=18676
exit 0 · WARN lines 0 · ERROR lines 0
KEY tiffinbox.jdbc-url -> WINNER jdbc:h2:mem:nodash;DB_CLOSE_DELAY=-1 · from source 4 of 7, systemEnvironment
  not under that name: Boot's view found it under the name TIFFINBOX_JDBCURL · System Environment Property "TIFFINBOX_JDBCURL"
   1 configurationProperties    jdbc:h2:mem:nodash;DB_CLOSE_DELAY=-1   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1   origin: class path resource [application.yaml] from tiffinbox-web-1.0.0.jar - 3:13
   7 applicationInfo            -
the bean's own field: Database.url = jdbc:h2:mem:nodash;DB_CLOSE_DELAY=-1
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
camel/: the key written in camel case in the file
$ java -cp "camel:$AFTER" com.tiffinbox.harness.Winner tiffinbox.jdbc-url --tiffinbox.port=18676
exit 0 · WARN lines 0 · ERROR lines 0
KEY tiffinbox.jdbc-url -> WINNER jdbc:h2:mem:camel;DB_CLOSE_DELAY=-1 · from source 6 of 7, Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  not under that name: Boot's view found it under the name tiffinbox.jdbcUrl · class path resource [application.yaml] - 3:12, the line reads:   jdbcUrl: jdbc:h2:mem:camel;DB_CLOSE_DELAY=-1
   1 configurationProperties    jdbc:h2:mem:camel;DB_CLOSE_DELAY=-1   (Boot's view over the sources below it)
   2 commandLineArgs            -
   3 systemProperties           -
   4 systemEnvironment          -
   5 random                     -
   6 Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0) -
   7 applicationInfo            -
the bean's own field: Database.url = jdbc:h2:mem:camel;DB_CLOSE_DELAY=-1
the class path gives: application.yaml <- camel/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
the other way round: a placeholder in camel case, @Value("${tiffinbox.jdbcUrl}"), the file keeping jdbc-url
$ java -cp "$AFTER" com.tiffinbox.harness.CamelByValue --tiffinbox.port=18676
  exit 1 · WARN lines 1 · ERROR lines 1 · listening lines 0
  Caused by: org.springframework.util.PlaceholderResolutionException: Could not resolve placeholder 'tiffinbox.jdbcUrl' in value "${tiffinbox.jdbcUrl}"
  the exception TiffinBox's main threw: org.springframework.beans.factory.BeanCreationException
  … 62 more line(s) of this run's output not shown: the banner, Boot's log, its failure report and the stack frames …
```

`Sources` first: Boot's view at the top is Boot's own class; the environment-variable source is a Boot subclass of Spring
Framework's `SystemEnvironmentPropertySource`, and the method that matches a key to a variable's name,
`resolvePropertyName`, is Spring's — `final`, so the subclass cannot change it. Then three runs, each with one spelling on
its own, and `Database.url` read off the live bean each time:
- `TIFFINBOX_JDBC_URL` (underscores for the dot and the dash): the `systemEnvironment` source itself holds it — Spring's
  own rule.
- `TIFFINBOX_JDBCURL` (no underscore for the dash): `systemEnvironment` answers `-` for `tiffinbox.jdbc-url`, yet the value
  arrives — Boot's view found it under the name `TIFFINBOX_JDBCURL`.
- The other way round — the camel spelling in a `@Value` placeholder, `${tiffinbox.jdbcUrl}`, the file keeping
  `jdbc-url`: exit 1, `Could not resolve placeholder 'tiffinbox.jdbcUrl'`. The matching is one way: a file or a variable
  may spell the key differently and still reach the dashed name, but a placeholder must use the dashed name. (RED
  2026-09-30 #15: the limit a learner meets the same day; the video shows it on a chip.)
- `camel/`, `jdbcUrl:` in the file: the file's source answers `-`, and Boot's view found `tiffinbox.jdbcUrl`, line 3.

The last unit's exercise solution promised this ("Which spellings reach which key is the next unit's subject"). The video
names the term the Spring Boot reference guide uses for it, relaxed binding; no jar on TiffinBox's class path carries the
phrase, so the video attributes the name to the guide, not to Boot.

## 8 · Values YAML retypes as it reads them

`.r-scalars.out` `942186a9ae1bb15e7a52c3044c7befe5`

```
the words a plain YAML value becomes true or false for: the BOOL pattern of org.yaml.snakeyaml.resolver.Resolver, in lib/snakeyaml-2.6.jar (javap):
  ^(?:yes|Yes|YES|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF)$
A   scalars/unquoted
$ java -cp "scalars/unquoted:$AFTER" com.tiffinbox.harness.Keys - tiffinbox.country,tiffinbox.sunday,tiffinbox.menu-version --tiffinbox.port=18677
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 7 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  line  7 |   country: NO         ->  tiffinbox.country = false (Boolean)
  line  8 |   sunday: off         ->  tiffinbox.sunday = false (Boolean)
  line  9 |   menu-version: 1.10  ->  tiffinbox.menu-version = 1.1 (Double)
the class path gives: application.yaml <- scalars/unquoted/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
B   scalars/quoted: the same three values in double quotes
$ java -cp "scalars/quoted:$AFTER" com.tiffinbox.harness.Keys - tiffinbox.country,tiffinbox.sunday,tiffinbox.menu-version --tiffinbox.port=18677
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 7 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  line  7 |   country: "NO"         ->  tiffinbox.country = NO (String)
  line  8 |   sunday: "off"         ->  tiffinbox.sunday = off (String)
  line  9 |   menu-version: "1.10"  ->  tiffinbox.menu-version = 1.10 (String)
the class path gives: application.yaml <- scalars/quoted/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
A′  A, re-run
$ java -cp "scalars/unquoted:$AFTER" com.tiffinbox.harness.Keys - tiffinbox.country,tiffinbox.sunday,tiffinbox.menu-version --tiffinbox.port=18677
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 7 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  line  7 |   country: NO         ->  tiffinbox.country = false (Boolean)
  line  8 |   sunday: off         ->  tiffinbox.sunday = false (Boolean)
  line  9 |   menu-version: 1.10  ->  tiffinbox.menu-version = 1.1 (Double)
the class path gives: application.yaml <- scalars/unquoted/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

The first line is read out of snakeyaml's own class with `javap`: the pattern its resolver compiles into the `BOOL` field.
`NO` and `off` are in it, so **A** reads `country: NO` and `sunday: off` as `false` (a `Boolean`), and `menu-version: 1.10`
as the `Double` `1.1`. **B** the same three values in double quotes: text, exactly as typed. **A′** = A. (`0123` is left out
of the video on purpose: it is the exercise.)

## 9 · The break — two loud, one silent

`.r-break.out` `0812510048dbcdb59b9a8d5d2579af89`

```
A   the anchor's own file, the profile rush on
$ java -cp "$AFTER" com.tiffinbox.harness.Keys tiffinbox.cooks tiffinbox.cooks,spring.tiffinbox --tiffinbox.port=18678 --spring.profiles.active=rush
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 8 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
  line 19 |   cooks: 6  ->  tiffinbox.cooks = 6 (Integer)
source 7 of 8 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  line  4 |   cooks: 3  ->  tiffinbox.cooks = 3 (Integer)
KEY tiffinbox.cooks -> WINNER 6 · the bean's own field: OrderQueue.cooks = 6
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
B   breaks/nested: the rush document's tiffinbox block, two spaces further in
$ java -cp "breaks/nested:$AFTER" com.tiffinbox.harness.Keys tiffinbox.cooks tiffinbox.cooks,spring.tiffinbox --tiffinbox.port=18678 --spring.profiles.active=rush
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 8 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
  line 19 |     cooks: 6  ->  spring.tiffinbox.cooks = 6 (Integer)
source 7 of 8 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  line  4 |   cooks: 3  ->  tiffinbox.cooks = 3 (Integer)
KEY tiffinbox.cooks -> WINNER 3 · the bean's own field: OrderQueue.cooks = 3
the class path gives: application.yaml <- breaks/nested/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
A′  A, re-run
$ java -cp "$AFTER" com.tiffinbox.harness.Keys tiffinbox.cooks tiffinbox.cooks,spring.tiffinbox --tiffinbox.port=18678 --spring.profiles.active=rush
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 8 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #1)
  line 19 |   cooks: 6  ->  tiffinbox.cooks = 6 (Integer)
source 7 of 8 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  line  4 |   cooks: 3  ->  tiffinbox.cooks = 3 (Integer)
KEY tiffinbox.cooks -> WINNER 6 · the bean's own field: OrderQueue.cooks = 6
the class path gives: application.yaml <- tiffinbox-web-1.0.0.jar!/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
C   breaks/tab: one key's two-space indent replaced by a tab
$ java -cp "breaks/tab:$AFTER" com.tiffinbox.harness.Keys tiffinbox.cooks tiffinbox.cooks,spring.tiffinbox --tiffinbox.port=18678 --spring.profiles.active=rush
exit 1 · banner lines 0 · listening lines 0 · lines that name application.yaml 0
  <time> [main] ERROR org.springframework.boot.SpringApplication -- Application run failed
  while scanning for the next token
  found character '\t(TAB)' that cannot start any token. (Do not use \t(TAB) for indentation)
   in 'reader', line 4, column 1:
the exception TiffinBox's main threw: org.yaml.snakeyaml.scanner.ScannerException
  … 66 more line(s) of this run's output not shown: the bad line and its caret, then the stack frames …
D   breaks/over: one key indented one space too far
$ java -cp "breaks/over:$AFTER" com.tiffinbox.harness.Keys tiffinbox.cooks tiffinbox.cooks,spring.tiffinbox --tiffinbox.port=18678 --spring.profiles.active=rush
exit 1 · banner lines 0 · listening lines 0 · lines that name application.yaml 0
  <time> [main] ERROR org.springframework.boot.SpringApplication -- Application run failed
  mapping values are not allowed here
   in 'reader', line 4, column 9:
the exception TiffinBox's main threw: org.yaml.snakeyaml.scanner.ScannerException
  … 67 more line(s) of this run's output not shown: the bad line and its caret, then the stack frames …
E   breaks/onespace: the list's last item one space further in than the two above it
$ java -cp "breaks/onespace:$AFTER" com.tiffinbox.harness.Keys - tiffinbox.meal-types --tiffinbox.port=18678
exit 0 · WARN lines 0 · ERROR lines 0
source 6 of 7 · Config resource 'class path resource [application.yaml]' via location 'optional:classpath:/' (document #0)
  line  9 |     - VEG      ->  tiffinbox.meal-types[0] = VEG (String)
  line 10 |     - NON_VEG  ->  tiffinbox.meal-types[1] = NON_VEG - VEGAN (String)
the class path gives: application.yaml <- breaks/onespace/application.yaml · application.properties <- none
… elided: 7 log line(s) of Boot's, and 10 line(s) printed before the report (the banner and its blank lines) …
```

A to D are the same command with one file swapped in front of `$AFTER`, the profile `rush` on; E asks `Keys` for the
list, with `breaks/onespace` in front.
**Silent — A/B/A′:** **A** the anchor's own file: document #1's `cooks: 6` is `tiffinbox.cooks`, and the answer is 6.
**B** `breaks/nested`, the rush document's `tiffinbox:` block two spaces further in (under `spring:`): exit 0, no WARN
line, document #1 still loaded — and its line 19 is now `spring.tiffinbox.cooks`, a key TiffinBox never asks for (its four
`@Value` placeholders all name `tiffinbox.*`). The answer: 3. **A′** = A, line for line.
**Loud — C and D (variants, labelled so):** **C** a tab in front of one key, **D** one key indented a space too far: exit 1
before the banner, nothing listens, and SnakeYAML's `ScannerException` points at `line 4, column 1` and `line 4, column 9`
— `in 'reader'`. **0 lines** of either run's output name `application.yaml`.
**Silent again — E (a variant):** `breaks/onespace`, the list's last item one space further in than the two above it.
YAML still parses it — a more-indented line continues the plain value above it — so exit 0, no WARN line, and **two**
keys: `tiffinbox.meal-types[1] = NON_VEG - VEGAN`. D's one space is loud because YAML cannot parse it; E's is silent
because it can. The voice's "That one space: the same" is D's space, on screen beside it; the recap card gives the rule:
what YAML cannot parse is loud, what it can parse is silent, even one space.

## 10 · The demo files, against the anchor's

`.r-files.out` `1184a0d50777c03dc80e417126392783`

```
both/application.yaml, against the anchor's application.yaml:
  4c4
  <   cooks: 3
  ---
  >   cooks: 4
comma/application.yaml, against the anchor's application.yaml:
  8,11c8
  <   meal-types:
  <     - VEG
  <     - NON_VEG
  <     - VEGAN
  ---
  >   meal-types: VEG,NON_VEG,VEGAN
camel/application.yaml, against the anchor's application.yaml:
  3c3
  <   jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1
  ---
  >   jdbcUrl: jdbc:h2:mem:camel;DB_CLOSE_DELAY=-1
scalars/unquoted/application.yaml, against the anchor's application.yaml:
  6a7,9
  >   country: NO
  >   sunday: off
  >   menu-version: 1.10
scalars/quoted/application.yaml, against the anchor's application.yaml:
  6a7,9
  >   country: "NO"
  >   sunday: "off"
  >   menu-version: "1.10"
breaks/nested/application.yaml, against the anchor's application.yaml:
  18,19c18,19
  < tiffinbox:
  <   cooks: 6
  ---
  >   tiffinbox:
  >     cooks: 6
breaks/tab/application.yaml, against the anchor's application.yaml:
  4c4
  <   cooks: 3
  ---
  > <TAB>cooks: 3
breaks/over/application.yaml, against the anchor's application.yaml:
  4c4
  <   cooks: 3
  ---
  >    cooks: 3
breaks/onespace/application.yaml, against the anchor's application.yaml:
  11c11
  <     - VEGAN
  ---
  >      - VEGAN
exercise/application.yaml: the anchor's application.yaml, byte for byte
both/application.properties: the previous tree's application.properties, byte for byte
```

Every demo file differs from the anchor's `application.yaml` exactly as its folder says, and `exercise/application.yaml`
is the anchor's byte for byte (the exercise has you copy it to `my/` and edit the copy, so this file is never edited).

## Exercise

`exercise/README.md` — add an area code, `0123`, to `my/application.yaml`, your copy of TiffinBox's YAML; predict what
Boot stores for `tiffinbox.area-code`, then make it store exactly `0123`. Measured answers, run exactly as written in a clean
shell, in `exercise/solution/SOLUTION.md` (unquoted: `WINNER 83`, an `Integer` — a number with a leading zero is read as
octal; quoted: `WINNER 0123`; appended at the end of the file instead: `WINNER null`, because the last lines belong to the
rush document).

## Found on the way

- **Two placeholders on one line.** The `list` capture's count of TiffinBox's `@Value` readers first said 3: `grep -c`
  counts lines, and `TiffinBoxServer`'s constructor carries two placeholders on one line. The assertion (4) caught it;
  the count now uses `grep -o`.
- **Boot's view is not a public class.** `ConfigurationPropertySourcesPropertySource` is package-private in Boot 4.1.1;
  the harness recognises it with Boot's public `ConfigurationPropertySources.isAttachedConfigurationPropertySource(…)`,
  and reads the name a property was found under from the public `PropertySourceOrigin.getPropertyName()`.

# c5-unit28 — Boot 4 and Framework 7: What Changed

Course 5 · Spring Boot · Section 5, its second unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1 against
3.5.16, Spring Framework 7.0.9 against 6.2.19**, 2026-10-08. This course ran on Boot 4.1.1 and Framework 7.0.9. This unit counts
what those versions changed for TiffinBox **against the last Boot 3's own jars** (Boot 3.5.16, the newest 3.5.x, and the Framework
6.2.19 it manages) — one autoconfigure jar became modules, Actuator's health moved packages, Boot's own JSON went to Jackson 3,
Framework 7 marks its packages with JSpecify — and what did **not** change (heapdump's default access, the endpoint access model,
the bridge's constructor). The break asks which Jackson writes TiffinBox's seven answers (A/B/A′, then C). Course 4's "fifty" is
re-derived on 4.1.1 and split (ledger P21/P22).

**No anchor change.** `after` is a link to `../c5-unit27/after` — the anchor as the command-line lesson left it (=
`../c5-tiffinbox`, `diff -rq -x target` empty when this unit was made). It is read and copied, never built in place: before =
after. No native build, no Docker, no GraalVM (brief ⚑6, ⚑17).

**The old jars.** `harness/jars/pom.xml` builds nothing: it names, by exact version, every file this unit reads beside TiffinBox's
own jars, so that Maven copies them out of `.m2-demo` (on a fresh clone, from Maven Central, once) into two folders — **`$OLD`**:
Boot 3.5.16's `spring-boot-autoconfigure`, `-actuator`, `-actuator-autoconfigure`, its BOM (`spring-boot-dependencies`) and Compose
module's POM, and `spring-context` 6.2.19; **`$NEW`**: Boot 4.1.1's BOM, Compose POM and Jackson module (`spring-boot-jackson`),
Jackson 3's databind POM (3.1.5), `spring-web` 7.0.9, and the properties migrator with `spring-boot-configuration-metadata` 4.1.1.
**`$LIB`** is TiffinBox's own: after/'s jar, built here and extracted (`lib/`, 46 jars).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 10 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

**Runs of record after BLUE (2026-10-09, RED C5-S5 #1 #4 #8; `modules`, `swap`, `counts` republished):** **546 s under `./receipts.sh`** (/bin/bash 3.2.57, exit 0, all 10 = published, every check passed); **536 s under `bash receipts.sh`** (Homebrew bash 5.3.9, exit 0, all 10 = published); **634 s from a sealed fresh clone** (`git clone` of commit `0aaac65`, `env -i`, `HOME` with only `.mavenrc` and a `settings.xml` mirroring to a `file://` copy of the four units' `.m2-demo`, proxies at 127.0.0.1:9; bash 5.3.9): exit 0, all 10 = published, 706 artifacts all from the `file://` copy, `.m2-demo` 1,919 files. Load averages 140-300 (three other units alongside). Interrupt test (own process group, SIGINT once swap C listened on 19141): exit 130, 0 processes left, 18425, 8080 and 19140-19145 free, no `.r-lock`, no partial capture, the published captures unchanged. The earlier runs below are of the tree before BLUE.

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) **Runs of record (2026-10-08):**
**153 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0, all 10 captures = published, every check passed; load about 6); **156 s under `bash receipts.sh`** (Homebrew bash 5.3.9, this folder, exit 0, all 10 = published); and a sealed clone (below). It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first).
Published hashes: modules `1f03ef09484e30684640c3ecbbd900e3` · moved `4de1bfb4c26a91c4dbd96cef6bb0718f` · jackson `dade77edf851fd8a5fbeed0ca966a3bc` · swap `217cf70cd2abb53203adb1afde158f96` · nulls `4c4d9c2d490707d6353739c33e052787` · notnew `c208512633baf3c9f5b24618ccda1941` · counts `65d0a55277fb500c010f29833c7c80f3` · versions `58511836bf4f691a9665a851d8e228a8` · migrator `43ed27927270d137ac4d15e207010b37` · exercise `908197b08b45dd96777071ff40938f0d`

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded for this unit from
`../../spring-boot/_research/m2-seed-s5/` **less `com/tiffinbox/`** (5,568 files; the brief's seed rule, S5.3 — never Maven Central
first). **Nothing was downloaded** for this unit: every build said `offline: yes`. Before the captures, `receipts.sh` runs one build
of each kind the captures use — after/ with the README's class-path line (it also brings Maven's dependency plugin: unit 27's
finding), the harness's POM (`validate`: the copies into `$OLD` and `$NEW`), and Course 4's app — so on a fresh clone those builds
fill `.m2-demo` and every capture's build says `offline: yes`. At run time nothing leaves 127.0.0.1.

**From a clone, sealed (2026-10-08, brief S5.2).** The repository was cloned (`git clone` of the local repository at this unit's
first commit) into an empty folder — nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*`; `README.md` is the only file
changed since, by this paragraph. `bash receipts.sh` (Homebrew bash 5.3.9) ran under `env -i`, with a `HOME` whose `.mavenrc` points
Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`) and every Java proxy property at a port that
refuses (127.0.0.1:9), and whose Maven settings send every repository to a `file://` copy of Central's files made from `.m2-demo`
(4,164 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out,
`maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same
refusing port; no `GRAALVM_HOME`. **Exit 0 after 157 s** — all 10 captures = published, every spoken number asserted, 0 raw demo
tokens. The three pre-capture builds said `offline: no` (an empty `.m2-demo`) and between them took **706 files, every one from the
`file://` copy**, 0 from anywhere else; every capture's build said `offline: yes`; `.m2-demo` ended with 1,919 files.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it.
The token never reaches a command line: the seven requests and `harness/shutdown.sh` read it from the file. Every capture is masked
— the token becomes `[masked: the 26-character token]` — and `receipts.sh` counts the raw token in each run's own output **before**
masking (`.harness/raw-*`: 0 in all 30 capture runs); in **the log of every TiffinBox that served** — the token and the shutdown
header's name `X-Shutdown-Token`, in any case: 0 and 0 each (30 per receipt run); in **the log of every start that failed** (3 per
run); then in every capture, this README, the exercise, the harness and `receipts.md5`: 0 each. The builder counts it again in the
script, the deck and the prompter: 0.

## The folders, the variables and the ports

- `.harness/serve/` — after/, built with the README's class-path line and extracted (`$LIB`; `moved`'s and `nulls`' sources;
  `notnew`, `counts` and `migrator` run from it). `.harness/jars/` — `harness/jars/` copied and run (`$OLD` = its `target/old`,
  `$NEW` = its `target/new`). `.harness/box0`, `.harness/box` — Course 4's `boot-in-ninety-seconds`, copied (never built in Course
  4's frozen folder). `.harness/a`, `b`, `c` — `swap`'s three copies. `.harness/lint`, `lintp` — `nulls`' two builds.
  `.harness/hc` — the harness's classes. The exercise: `.harness/mine/`.
- **The harness** (the course's, never TiffinBox's; outside `com.tiffinbox`): `harness/probe/count/Count.java` — a runner joined by
  `--spring.main.sources`, printing the context's bean definitions split by the package of each bean's type (its own definition
  counted apart); `BoxCount.java` — `SpringApplication.run` on Course 4's `BoxApp`, then the same split; `harness/jars.py` — reads
  BOMs, POMs, metadata, `package-info` classes, constructors (javap) and TiffinBox's imports (each subcommand documented at its top);
  three patches (`jackson3-code.patch`, `jackson3-pom.patch`, `old-nullable.patch`); `harness/shutdown.sh` (the failure lesson's).
- On screen: `$OLD`, `$NEW`, `$LIB` (above); `$IMP` = `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`;
  `$M2` = this unit's `.m2-demo`; `$CURLSET` = `../c5-unit11/curlset.sh`. Every other command is printed whole.
- **The class-path layouts** (S4.18): the executable jar in `notnew`; the extracted jar (`-cp`) in `counts` and `migrator`; the
  build's folders (`target/classes` + `classpath.txt`, the README's "Postgres with TiffinBox" line **without** `--spring.profiles.active=dev`,
  so Boot's Compose support stays off and nothing runs Docker) in `swap`.
- **Ports** (brief ⚑1, 19140-19149, checked free with `lsof` before anything is wiped; 18425 and 8080 too, and never bound):
  `swap` A and A′ 19140 · `swap` C 19141 · `notnew` 19142 · `counts` 19143 · `migrator` 19144 · the exercise 19145. Every run passes
  options only (⚑18).

## Masks, filters and hygiene — every one, declared

1. **Paths and the token** (`gsub()`, literals escaped), in every line: the token → `[masked: the 26-character token]`; this
   folder's absolute path → `…` (also URL-encoded); the folder above → `…/..`; the home folder → `~`; the user name → `<user>`. A last
   check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's process line, a log
   time, a thread number, a stack frame, or `offline: no`.
2. **Jar listings** — counts only (`grep -c`), or the named lines; **javap** — the lines a `grep -E` names; **POMs and metadata** —
   `harness/jars.py`, each subcommand's filter in its docstring (a table's cut counted: "properties N · in this table K · not shown");
   **javac** — its "Compiling" lines, and its deprecation warnings, distinct (Maven prints each one more than once), the path cut
   before `tiffinbox-web/`; **diff** — `diff -U0` hunks without the two file lines; **the class path** — jar names, sorted.
3. **A running TiffinBox's log** is read after it stopped: Boot's first line cut before ` with PID`; WARN and ERROR lines counted;
   lines naming a key counted; the harness's `harness: ` lines; the migrator's report from its ERROR line to `Please refer`, tabs as
   two spaces, blank lines out. **A failed start** — the failure lesson's shape: frames, `Caused by:` and folded frames counted, the
   first line of each exception, WARN/ERROR lines from their level on. **Never a line total** (S5.30).
4. **No duration is captured.**
5. **Hygiene:** the S5.15 loop, verbatim from the failure lesson's receipts (`sed -E`, a canary planted under each name, the run
   stopped if one survives); `127.0.0.1` first in `no_proxy`/`NO_PROXY`; one run at a time (`.r-lock`); no `secrets/` here, and none,
   nor a `target/`, `banner.txt` or `tiffinbox-local.yaml`, in after/ (unit 27's folder); `after` must be the link.

**Interrupted.** `receipts.sh`'s exit trap stops the processes it started in the background (`$pid`, `$fpid`), then `sweep()`s its
process group for anything of this run (a TiffinBox JVM, Course 4's app, BoxCount, a Maven JVM) — TERM, then KILL after 5 s; after an
interrupt it deletes unfinished capture runs, then drops the lock. **Tested 2026-10-08 on the final script**, `receipts.sh` as a job
of its own process group, `SIGINT` to the whole group the moment a TiffinBox listened on 19140 (`swap` A; 3 processes in the group):
**exit 130**; 5 s later 0 processes in the group and the JVM gone; 18425, 8080 and 19140-19145 free; `.r-lock` gone; 0 unfinished
capture files.

## 1 · modules — one jar became many

The auto-configuration list (`$IMP`) in Boot's autoconfigure jar: **156** entries in 3.5.16's, **12** in 4.1.1's; Jackson's configuration listed in the old jar, then in `spring-boot-jackson`. TiffinBox's jar (`$LIB`, 46 jars): **6** jars hold a list, **74** entries. The BOMs' `dependencyManagement` entries with groupId `org.springframework.boot`: 73 → 311, starters 55 → 170, **the rest (not starters) 18 → 141** — Boot artifacts of every kind (modules, loaders, build tools, test jars), so the video shows them dim and no longer says "modules" (RED C5-S5 #4: at least 9 of 3.5.16's 18 hold no auto-configuration list, which is the voice's definition of a module).

`.r-modules.out` · md5 `1f03ef09484e30684640c3ecbbd900e3` · 3 of 3

```
the auto-configuration list ($IMP) in Boot's autoconfigure jar - the last Boot 3's, then this course's - its entries:
$ unzip -p "$OLD/spring-boot-autoconfigure-3.5.16.jar" "$IMP" | grep -cvE '^[[:space:]]*(#|$)'
  156
$ unzip -p "$LIB/spring-boot-autoconfigure-4.1.1.jar" "$IMP" | grep -cvE '^[[:space:]]*(#|$)'
  12
where Boot's Jackson configuration is listed - in the old autoconfigure jar, then in a module of its own:
$ unzip -p "$OLD/spring-boot-autoconfigure-3.5.16.jar" "$IMP" | grep -F .JacksonAutoConfiguration
  org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration
$ unzip -p "$NEW/spring-boot-jackson-4.1.1.jar" "$IMP" | grep -F .JacksonAutoConfiguration
  org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration
TiffinBox's jar - every jar it ships ($LIB) that holds the list, and its entries:
$ for j in "$LIB"/*.jar; do n=$(unzip -p "$j" "$IMP" 2> /dev/null | grep -cvE '^[[:space:]]*(#|$)'); [ "$n" = 0 ] || echo "$(basename "$j") $n"; done
  spring-boot-actuator-autoconfigure-4.1.1.jar 24
  spring-boot-autoconfigure-4.1.1.jar 12
  spring-boot-health-4.1.1.jar 7
  spring-boot-micrometer-metrics-4.1.1.jar 28
  spring-boot-micrometer-observation-4.1.1.jar 2
  spring-boot-validation-4.1.1.jar 1
  the jars that hold the list: 6 · its entries in all of them: 74 · the jars in $LIB: 46
the Boot artifacts each BOM manages - its dependencyManagement entries with groupId org.springframework.boot, the starters apart:
$ python3 harness/jars.py bom "$OLD/spring-boot-dependencies-3.5.16.pom" "$NEW/spring-boot-dependencies-4.1.1.pom"
  spring-boot-dependencies-3.5.16.pom: entries 411 · org.springframework.boot 73 · starters 55 · the rest, not starters 18
  spring-boot-dependencies-4.1.1.pom: entries 652 · org.springframework.boot 311 · starters 170 · the rest, not starters 141
```

## 2 · moved — what TiffinBox felt

Actuator's list **123 → 24**; the package `org.springframework.boot.actuate.health` **50 class files → 0**. TiffinBox's 34 distinct Boot imports (16 source files, `harness/jars.py imports`): 19 under the same package and name in 3.5.16's three jars; **7 moved** — the same simple name in 3.5.16's `actuate.health` (the bridge's 5, the kitchen indicator's 2); 8 in Boot's core jar (`spring-boot-4.1.1.jar`), whose 3.5.16 copy was not fetched — **not compared** (RE-MEASURE 7). `WebEndpointDiscoverer`: 3.5.16 has constructors of 6 and 8 arguments, 4.1.1 one of 8; **the 8-argument signature is the same**; the bridge makes 1 call.

`.r-moved.out` · md5 `4de1bfb4c26a91c4dbd96cef6bb0718f` · 3 of 3

```
Actuator's auto-configuration list - the last Boot 3's actuator-autoconfigure jar, then this course's, its entries:
$ unzip -p "$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar" "$IMP" | grep -cvE '^[[:space:]]*(#|$)'
  123
$ unzip -p "$LIB/spring-boot-actuator-autoconfigure-4.1.1.jar" "$IMP" | grep -cvE '^[[:space:]]*(#|$)'
  24
the package org.springframework.boot.actuate.health in Boot's actuator jar - its class files, both versions:
$ unzip -Z1 "$OLD/spring-boot-actuator-3.5.16.jar" | grep -cE '^org/springframework/boot/actuate/health/[^/]+\.class$'
  50
$ unzip -Z1 "$LIB/spring-boot-actuator-4.1.1.jar" | grep -cE '^org/springframework/boot/actuate/health/[^/]+\.class$'
  0
TiffinBox's own imports from org.springframework.boot (after/'s sources, copied to .harness/serve), each looked up in the
last Boot 3's three jars by package and name, then by name alone; the rest by the jar of TiffinBox's that holds it:
$ python3 harness/jars.py imports .harness/serve "$OLD/spring-boot-actuator-3.5.16.jar:$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar:$OLD/spring-boot-autoconfigure-3.5.16.jar" "$(ls "$LIB"/*.jar | paste -sd: -)"
  source files 16 · org.springframework.boot imports, one per class: 34
  the same package and name in 3.5.16's jars: 19
  moved - the same name, another package in 3.5.16's jars: 7
    org.springframework.boot.health.actuate.endpoint.HealthEndpoint  (in ActuatorRoutes.java) - 3.5.16: org.springframework.boot.actuate.health.HealthEndpoint
    org.springframework.boot.health.actuate.endpoint.HealthEndpointGroups  (in ActuatorRoutes.java) - 3.5.16: org.springframework.boot.actuate.health.HealthEndpointGroups
    org.springframework.boot.health.actuate.endpoint.HealthEndpointWebExtension  (in ActuatorRoutes.java) - 3.5.16: org.springframework.boot.actuate.health.HealthEndpointWebExtension
    org.springframework.boot.health.contributor.Health  (in KitchenHealthIndicator.java) - 3.5.16: org.springframework.boot.actuate.health.Health
    org.springframework.boot.health.contributor.HealthIndicator  (in KitchenHealthIndicator.java) - 3.5.16: org.springframework.boot.actuate.health.HealthIndicator
    org.springframework.boot.health.registry.HealthContributorRegistry  (in ActuatorRoutes.java) - 3.5.16: org.springframework.boot.actuate.health.HealthContributorRegistry
    org.springframework.boot.health.registry.ReactiveHealthContributorRegistry  (in ActuatorRoutes.java) - 3.5.16: org.springframework.boot.actuate.health.ReactiveHealthContributorRegistry
  in none of them: 8 - each in TiffinBox's jars, by the jar that holds it:
    spring-boot-4.1.1.jar: 8 - DefaultApplicationArguments ExitCodeGenerator SpringApplication ApplicationEnvironmentPreparedEvent ConfigurationProperties EnableConfigurationProperties AbstractFailureAnalyzer FailureAnalysis
the bridge's discoverer - WebEndpointDiscoverer's public constructors (javap), both versions:
$ python3 harness/jars.py ctors org.springframework.boot.actuate.endpoint.web.annotation.WebEndpointDiscoverer "$OLD/spring-boot-actuator-3.5.16.jar" "$LIB/spring-boot-actuator-4.1.1.jar"
  spring-boot-actuator-3.5.16.jar: public constructors 2 · their arguments: 6, 8
  spring-boot-actuator-4.1.1.jar: public constructors 1 · their arguments: 8
  the 8-argument constructor, in every jar above: the same signature
  the bridge, ActuatorRoutes.java, calls it with: 1 constructor call(s)
```

## 3 · jackson — what moved to Jackson 3

Boot's own JSON bean (javap): `ObjectMapper jacksonObjectMapper(Jackson2ObjectMapperBuilder)` in 3.5.16, `JsonMapper jacksonJsonMapper(JsonMapper$Builder)` in 4.1.1's `spring-boot-jackson`. `jackson-bom.version` 2.21.4 → 3.1.5 (4.1.1 also manages `jackson-2-bom` 2.21.5). The Compose module: `com.fasterxml.jackson.core:jackson-databind` → `tools.jackson.core:jackson-databind`. Jackson 3's databind depends on `com.fasterxml.jackson.core:jackson-annotations` — one annotations jar for both. Actuator's Jackson configurations: 1 class file → 2. TiffinBox: Jackson 2's three jars, 0 `tools/jackson/` classes, no `spring-boot-jackson`, 2 `new ObjectMapper()` of its own.

`.r-jackson.out` · md5 `dade77edf851fd8a5fbeed0ca966a3bc` · 3 of 3

```
Boot's own JSON bean - the method that declares it, read with javap - the last Boot 3's, then this course's:
$ javap -cp "$OLD/spring-boot-autoconfigure-3.5.16.jar" 'org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration$JacksonObjectMapperConfiguration' | grep -E ' jackson[A-Za-z]*Mapper\('
    com.fasterxml.jackson.databind.ObjectMapper jacksonObjectMapper(org.springframework.http.converter.json.Jackson2ObjectMapperBuilder);
$ javap -cp "$NEW/spring-boot-jackson-4.1.1.jar" org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration | grep -E ' jackson[A-Za-z]*Mapper\('
    tools.jackson.databind.json.JsonMapper jacksonJsonMapper(tools.jackson.databind.json.JsonMapper$Builder);
the Jackson each BOM manages:
$ python3 harness/jars.py props jackson-bom.version,jackson-2-bom.version "$OLD/spring-boot-dependencies-3.5.16.pom" "$NEW/spring-boot-dependencies-4.1.1.pom"
  property               spring-boot-dependencies-3.5.16.pom  spring-boot-dependencies-4.1.1.pom
  jackson-bom.version    2.21.4                               3.1.5
  jackson-2-bom.version  -                                    2.21.5
  spring-boot-dependencies-3.5.16.pom: properties 191 · in this table 1 · not shown 190
  spring-boot-dependencies-4.1.1.pom: properties 195 · in this table 2 · not shown 193
the Compose module's own dependencies, both versions - and Jackson 3's databind's:
$ python3 harness/jars.py deps "$OLD/spring-boot-docker-compose-3.5.16.pom" "$NEW/spring-boot-docker-compose-4.1.1.pom" "$NEW/jackson-databind-3.1.5.pom"
  spring-boot-docker-compose-3.5.16.pom: org.springframework.boot:spring-boot · com.fasterxml.jackson.core:jackson-databind · com.fasterxml.jackson.module:jackson-module-parameter-names
  spring-boot-docker-compose-4.1.1.pom: org.springframework.boot:spring-boot-autoconfigure · tools.jackson.core:jackson-databind
  jackson-databind-3.1.5.pom: com.fasterxml.jackson.core:jackson-annotations · tools.jackson.core:jackson-core
Actuator's Jackson configurations - their class files in actuator-autoconfigure, both versions:
$ unzip -Z1 "$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar" | grep -E 'endpoint/jackson/[A-Za-z0-9]+\.class$'
  org/springframework/boot/actuate/autoconfigure/endpoint/jackson/JacksonEndpointAutoConfiguration.class
$ unzip -Z1 "$LIB/spring-boot-actuator-autoconfigure-4.1.1.jar" | grep -E 'endpoint/jackson/[A-Za-z0-9]+\.class$'
  org/springframework/boot/actuate/autoconfigure/endpoint/jackson/Jackson2EndpointAutoConfiguration.class
  org/springframework/boot/actuate/autoconfigure/endpoint/jackson/JacksonEndpointAutoConfiguration.class
TiffinBox - the Jackson jars it ships, Jackson 3's classes in any of them, Boot's Jackson module, and the mappers it makes:
$ ls "$LIB" | grep -i jackson
  jackson-annotations-2.22.jar
  jackson-core-2.22.2.jar
  jackson-databind-2.22.2.jar
$ for j in "$LIB"/*.jar; do unzip -Z1 "$j"; done | grep -c '^tools/jackson/'
  0
$ ls "$LIB" | grep -c '^spring-boot-jackson'
  0
$ grep -rn 'new ObjectMapper()' .harness/serve/tiffinbox-core/src .harness/serve/tiffinbox-web/src | sed 's/^.*\/\([A-Za-z]*\.java\):/\1:/' | sort
  ActuatorRoutes.java:58:    private static final ObjectMapper JSON = new ObjectMapper();
  TiffinBoxServer.java:73:    private static final ObjectMapper JSON = new ObjectMapper();
```

## 4 · swap — the break (A/B/A′, then C): Jackson 3

**A** — after/, the README's class-path build, the README's folder run without its `dev` profile (no Docker), 19140: the seven `115c36ba…`. **B** — the two lines that use the mapper swapped to Jackson 3 (`harness/jackson3-code.patch`), the POM untouched: **exit 1, `package tools.jackson.databind.json does not exist`**, no class written — although Jackson 3's databind is on the run's class path all along (the Compose module, at run time only). **A′** — A's command: the seven. **C** (labelled) — the code swapped **and** `tools.jackson.core:jackson-databind` declared (`harness/jackson3-pom.patch`): built; the executable jar holds no Jackson 3 (the plugin's excludes), so C runs from the folders as A did; the class path lists the same 53 jars in another order; **the seven, 0 lines different from A's**. **C′** (labelled) — C's executable jar, the README's run line, 19141: **exit 1** before Boot starts, `Exception in thread "main" java.lang.NoClassDefFoundError: tools/jackson/databind/json/JsonMapper` (Caused by `ClassNotFoundException`), nothing listening — the Actuator lesson's excludes drop exactly the dependency C declares, so "the seven come out the same" holds **from the folders only** (RED C5-S5 #1). The patch swaps the server's mapper (`TiffinBoxServer.java`); the bridge (`ActuatorRoutes.java`) keeps its Jackson 2 mapper.

`.r-swap.out` · md5 `217cf70cd2abb53203adb1afde158f96` · 3 of 3

```
A - after/, copied to .harness/a with a config tree, built with the README's class-path line; the README's folder run, port 19140:
$ cd .harness/a && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  built after/ · offline: yes · exit 0
$ cd .harness/a && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19140
  listens on: 127.0.0.1:19140
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19140/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19140 .harness/a/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - after/, copied to .harness/b; the code swapped to Jackson 3 (harness/jackson3-code.patch), the POM untouched:
$ cd .harness/b && patch -s -p1 < ../../harness/jackson3-code.patch && diff -U0 ../../after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java | sed 1,2d
  @@ -3 +3 @@
  -import com.fasterxml.jackson.databind.ObjectMapper;
  +import tools.jackson.databind.json.JsonMapper;
  @@ -73 +73 @@
  -    private static final ObjectMapper JSON = new ObjectMapper();
  +    private static final JsonMapper JSON = JsonMapper.builder().build();
$ cd .harness/b && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  built the code swapped · offline: yes · exit 1
  javac's errors (distinct; the path cut before tiffinbox-web/):
    tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java:[3,35] package tools.jackson.databind.json does not exist
    tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java:[73,26] cannot find symbol
  tiffinbox-web/target/classes/com/tiffinbox/web/TiffinBoxServer.class: does not exist
  the class path Maven lists for the run (A's, .harness/a/tiffinbox-web/target/classpath.txt) - Jackson 3's databind: 1
A' - A again:
$ cd .harness/a && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19140
  listens on: 127.0.0.1:19140
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19140/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19140 .harness/a/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - after/, copied to .harness/c; the code swapped, and Jackson 3 declared in the POM (harness/jackson3-pom.patch):
$ cd .harness/c && patch -s -p1 < ../../harness/jackson3-code.patch && patch -s -p1 < ../../harness/jackson3-pom.patch && diff -U0 ../../after/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d
  @@ -27,0 +28,4 @@
  +      <groupId>tools.jackson.core</groupId>
  +      <artifactId>jackson-databind</artifactId>
  +    </dependency>
  +    <dependency>
$ cd .harness/c && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  built the code swapped, Jackson 3 declared · offline: yes · exit 0
  the executable jar's BOOT-INF/lib - Jackson 3's databind: 0 (the plugin's excludes keep it out) - so C runs from the folders, as A did
  the class path Maven lists, against A's - its jars' names, sorted: the same jars (53 jars; in another order: yes)
$ cd .harness/c && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19141
  listens on: 127.0.0.1:19141
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19141/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19141 .harness/c/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
$ diff .harness/seven-a.txt .harness/seven-c.txt | grep -c '^[<>]'
  0
C' (labelled) - C's executable jar, the README's run line, port 19141:
$ cd .harness/c && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19141
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 0 · Caused by: 0 · frames folded as common 0
  its log: TiffinBox listening 0 · its standard error: 19 lines · the demo token in its log: 0
  its standard error - the exception's lines (its stack frames: 16, not shown):
    Exception in thread "main" java.lang.NoClassDefFoundError: tools/jackson/databind/json/JsonMapper
    Caused by: java.lang.ClassNotFoundException: tools.jackson.databind.json.JsonMapper
  listening now: 19141 0
```

## 5 · nulls — Framework 7's null-safety

spring-context 6.2.19: 58 `package-info` classes, **58 `@NonNullApi`**, 0 `@NullMarked`; 7.0.9: 59, 0, **55 `@NullMarked`** (descriptor read from each class's bytes). `org.springframework.lang.Nullable` in spring-core 7.0.9: `@Deprecated(since="7.0")`. TiffinBox ships `jspecify-1.0.1.jar`, uses 0 nullability annotations, and its three POMs name no NullAway or Error Prone. The README's plain build with `-Dmaven.compiler.showDeprecation=true`: 7 + 9 files, **0** deprecation warnings; the same build with one planted `@org.springframework.lang.Nullable` (`harness/old-nullable.patch`): **1** — so the count can move.

`.r-nulls.out` · md5 `4c4d9c2d490707d6353739c33e052787` · 3 of 3

```
Spring's packages and the annotation that says "not null unless marked" - spring-context, the Framework the last Boot 3 manages, then this course's:
$ python3 harness/jars.py annos "$OLD/spring-context-6.2.19.jar" 'Lorg/springframework/lang/NonNullApi;' 'Lorg/jspecify/annotations/NullMarked;'
  spring-context-6.2.19.jar: package-info classes 58 · NonNullApi 58 · NullMarked 0
$ python3 harness/jars.py annos "$LIB/spring-context-7.0.9.jar" 'Lorg/springframework/lang/NonNullApi;' 'Lorg/jspecify/annotations/NullMarked;'
  spring-context-7.0.9.jar: package-info classes 59 · NonNullApi 0 · NullMarked 55
Spring's own Nullable, in this course's spring-core - its annotations (javap -v):
$ javap -v -cp "$LIB/spring-core-7.0.9.jar" org.springframework.lang.Nullable | grep -E '^ *(java\.lang\.Deprecated\(|since=)'
      java.lang.Deprecated(
        since="7.0"
TiffinBox - the JSpecify jar it ships, its sources' nullability annotations, a null checker in its three POMs:
$ ls "$LIB" | grep jspecify
  jspecify-1.0.1.jar
$ grep -rlE '@(Nullable|NonNull|NullMarked|NonNullApi|NullUnmarked)\b' .harness/serve/tiffinbox-core/src .harness/serve/tiffinbox-web/src | wc -l | tr -d ' '
  0
$ cat .harness/serve/pom.xml .harness/serve/tiffinbox-core/pom.xml .harness/serve/tiffinbox-web/pom.xml | grep -ciE 'nullaway|errorprone|error_prone'
  0
TiffinBox's code on this course's Boot and Framework - after/, copied to .harness/lint, the README's plain line with javac's
deprecation warnings on:
$ cd .harness/lint && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package -Dmaven.compiler.showDeprecation=true
  built after/, deprecation warnings on · offline: yes · exit 0
  Compiling 7 source files with javac [debug deprecation parameters release 25]
  Compiling 9 source files with javac [debug deprecation parameters release 25]
  javac's warnings that say deprecated, distinct: 0
the same build on a copy with one planted use of Spring's old Nullable (harness/old-nullable.patch) - so the count can move:
$ cd .harness/lintp && patch -s -p1 < ../../harness/old-nullable.patch && diff -U0 ../../after/tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java | sed 1,2d
  @@ -13 +13 @@
  -    @Override
  +    @Override @org.springframework.lang.Nullable
$ cd .harness/lintp && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package -Dmaven.compiler.showDeprecation=true
  built the planted copy, deprecation warnings on · offline: yes · exit 0
  Compiling 7 source files with javac [debug deprecation parameters release 25]
  Compiling 9 source files with javac [debug deprecation parameters release 25]
  javac's warnings that say deprecated, distinct: 1
  [WARNING] tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java:[13,40] org.springframework.lang.Nullable in org.springframework.lang has been deprecated
```

## 6 · notnew — what the last Boot 3 already had

`HeapDumpWebEndpoint`'s `@WebEndpoint(id="heapdump", defaultAccess=NONE)` in **both** jars. `management.endpoints.enabled-by-default`: deprecated, replacement `management.endpoints.access.default`, **since 3.4.0**, in both versions' own metadata; `access.default` exists in 3.5.16. **A** — the README's run line on 19142: health 200, the kitchen 200. **B** — plus `--management.endpoints.enabled-by-default=false` (readiness cannot answer, so `/kitchen` is waited for and the stop runs by POST /shutdown on every path): readiness and health **404**, the kitchen 200, **0 WARN, 0 ERROR, 0 lines naming the key**. **A′** — health back.

`.r-notnew.out` · md5 `c208512633baf3c9f5b24618ccda1941` · 3 of 3

```
heapdump - the class's endpoint annotation (javap -v), both versions:
$ javap -v -cp "$OLD/spring-boot-actuator-3.5.16.jar" org.springframework.boot.actuate.management.HeapDumpWebEndpoint | grep -E '^ +(org\.springframework\.boot\.actuate\.endpoint\.web\.annotation\.WebEndpoint\(|id=|defaultAccess=)'
      org.springframework.boot.actuate.endpoint.web.annotation.WebEndpoint(
        id="heapdump"
        defaultAccess=Lorg/springframework/boot/actuate/endpoint/Access;.NONE
$ javap -v -cp "$LIB/spring-boot-actuator-4.1.1.jar" org.springframework.boot.actuate.management.HeapDumpWebEndpoint | grep -E '^ +(org\.springframework\.boot\.actuate\.endpoint\.web\.annotation\.WebEndpoint\(|id=|defaultAccess=)'
      org.springframework.boot.actuate.endpoint.web.annotation.WebEndpoint(
        id="heapdump"
        defaultAccess=Lorg/springframework/boot/actuate/endpoint/Access;.NONE
the endpoint access model - the old switch and its replacement, in each version's own metadata:
$ python3 harness/jars.py meta management.endpoints.enabled-by-default "$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar" "$LIB/spring-boot-actuator-autoconfigure-4.1.1.jar"
  spring-boot-actuator-autoconfigure-3.5.16.jar: management.endpoints.enabled-by-default · type java.lang.Boolean · deprecated · level warning · replacement management.endpoints.access.default · since 3.4.0
  spring-boot-actuator-autoconfigure-4.1.1.jar: management.endpoints.enabled-by-default · type java.lang.Boolean · deprecated · level warning · replacement management.endpoints.access.default · since 3.4.0
$ python3 harness/jars.py meta management.endpoints.access.default "$OLD/spring-boot-actuator-autoconfigure-3.5.16.jar" "$LIB/spring-boot-actuator-autoconfigure-4.1.1.jar"
  spring-boot-actuator-autoconfigure-3.5.16.jar: management.endpoints.access.default · type org.springframework.boot.actuate.endpoint.Access · not deprecated
  spring-boot-actuator-autoconfigure-4.1.1.jar: management.endpoints.access.default · type org.springframework.boot.actuate.endpoint.Access · not deprecated
A - the deprecated switch on this course's Boot: not given. The README's run line, from .harness/serve, port 19142:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19142
  listens on: 127.0.0.1:19142
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19142/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19142/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19142/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
$ harness/shutdown.sh 19142 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19142 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: WARN lines 0 · ERROR lines 0 · lines naming management.endpoints.enabled-by-default: 0
B - the same line, the old switch off: --management.endpoints.enabled-by-default=false (readiness cannot answer; /kitchen waited for):
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19142 --management.endpoints.enabled-by-default=false
  listens on: 127.0.0.1:19142
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19142/actuator/health/readiness
  {"error":"not found"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19142/actuator/health
  {"error":"not found"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19142/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
$ harness/shutdown.sh 19142 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19142 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: WARN lines 0 · ERROR lines 0 · lines naming management.endpoints.enabled-by-default: 0
A' - A again:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19142
  listens on: 127.0.0.1:19142
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19142/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19142/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19142/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
$ harness/shutdown.sh 19142 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19142 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: WARN lines 0 · ERROR lines 0 · lines naming management.endpoints.enabled-by-default: 0
```

## 7 · counts — a count needs its split (P21/P22)

Course 4's `boot-in-ninety-seconds` copied (0 files differ), its parent 4.1.1, built offline and run as written: **`… asked for: 50`**. The harness's BoxCount (`SpringApplication.run` on BoxApp, the same start): **`com.tiffinbox 1 · org.springframework (not boot) 11 · org.springframework.boot 38`**. TiffinBox with the harness's Count joined: 144 definitions, the harness's own 1 → **143**, `com.tiffinbox` **11**, Boot 104, Spring 12, Micrometer/Prometheus 16, nothing outside those groups (so no Jackson bean).

`.r-counts.out` · md5 `65d0a55277fb500c010f29833c7c80f3` · 3 of 3

```
Course 4's Boot app (boot-in-ninety-seconds/, from Course 4's first lesson), copied to .harness/box - the copy, its parent, its count:
  the copy against Course 4's own folder (diff -rq, without target/ and .m2-demo/): 0 files differ
  its parent: <version>4.1.1</version>
  BoxApp.java: ConfigurableApplicationContext ctx = SpringApplication.run(BoxApp.class, args);
  BoxApp.java: System.out.println("bean definitions in a Boot context nobody in this file asked for: "
  BoxApp.java: + ctx.getBeanFactory().getBeanDefinitionCount());
$ cd .harness/box && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built Course 4's app · offline: yes · exit 0
$ cd .harness/box && java -jar target/boot-in-ninety-seconds-1.0.0.jar
  bean definitions in a Boot context nobody in this file asked for: 50
  its log: Boot's Started line 1 · the demo token 0
$ cd .harness/box && java -Djarmode=tools -jar target/boot-in-ninety-seconds-1.0.0.jar extract --destination target/extracted
  extracted: exit 0 · its lib/ holds 20 jars
the same start, split by package - the harness's BoxCount (SpringApplication.run on BoxApp, then the split):
$ cd .harness/box && java -cp "target/extracted/boot-in-ninety-seconds-1.0.0.jar:target/extracted/lib/*:../hc" probe.count.BoxCount
  harness: BoxApp · bean definitions 50 · com.tiffinbox 1 · org.springframework (not boot) 11 · org.springframework.boot 38
TiffinBox - the harness's Count joined to the README's exploded run ($LIB's jars), port 19143:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19143 --spring.main.sources=probe.count.Count
  listens on: 127.0.0.1:19143
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19143/actuator/health/readiness
  {"status":"UP"} 200
$ harness/shutdown.sh 19143 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19143 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  harness: TiffinBox · bean definitions 144 · com.tiffinbox 11 · io.micrometer and io.prometheus 16 · org.springframework (not boot) 12 · org.springframework.boot 104 · the harness 1
```

## 8 · versions — the parent's versions; Framework 7's version attribute

Nine properties of each BOM (`harness/jars.py props`; 191 and 195 properties, the rest counted, not shown); Undertow: 11 lines in 3.5.16's BOM, **0** in 4.1.1's. spring-web 7.0.9: `@RequestMapping` and `@GetMapping` declare `String version()` — not compared with 6.2's spring-web (not fetched), so **no "new in 7" claim**; spring-web in TiffinBox's jars: 0 (Course 6's *API Versioning in Framework 7*).

`.r-versions.out` · md5 `58511836bf4f691a9665a851d8e228a8` · 3 of 3

```
the versions the parent manages, BOM against BOM - nine properties of each BOM, the rest counted:
$ python3 harness/jars.py props spring-framework.version,jackson-bom.version,micrometer.version,tomcat.version,jetty.version,jakarta-servlet.version,hibernate.version,junit-jupiter.version,undertow.version "$OLD/spring-boot-dependencies-3.5.16.pom" "$NEW/spring-boot-dependencies-4.1.1.pom"
  property                  spring-boot-dependencies-3.5.16.pom  spring-boot-dependencies-4.1.1.pom
  spring-framework.version  6.2.19                               7.0.9
  jackson-bom.version       2.21.4                               3.1.5
  micrometer.version        1.15.12                              1.17.1
  tomcat.version            10.1.55                              11.0.24
  jetty.version             12.0.36                              12.1.12
  jakarta-servlet.version   6.0.0                                6.1.0
  hibernate.version         6.6.53.Final                         7.4.5.Final
  junit-jupiter.version     5.12.2                               6.0.3
  undertow.version          2.3.24.Final                         -
  spring-boot-dependencies-3.5.16.pom: properties 191 · in this table 9 · not shown 182
  spring-boot-dependencies-4.1.1.pom: properties 195 · in this table 8 · not shown 187
$ python3 harness/jars.py mentions undertow "$OLD/spring-boot-dependencies-3.5.16.pom" "$NEW/spring-boot-dependencies-4.1.1.pom"
  spring-boot-dependencies-3.5.16.pom: lines that mention undertow, in any case: 11
  spring-boot-dependencies-4.1.1.pom: lines that mention undertow, in any case: 0
Framework 7's request mappings - spring-web 7.0.9 (javap), and whether TiffinBox ships spring-web at all:
$ javap -cp "$NEW/spring-web-7.0.9.jar" org.springframework.web.bind.annotation.RequestMapping | grep -F ' version()'
    public abstract java.lang.String version();
$ javap -cp "$NEW/spring-web-7.0.9.jar" org.springframework.web.bind.annotation.GetMapping | grep -F ' version()'
    public abstract java.lang.String version();
$ ls "$LIB" | grep -c '^spring-web'
  0
```

## 9 · migrator — Boot's properties migrator

The README's exploded run with `spring-boot-properties-migrator` and `spring-boot-configuration-metadata` 4.1.1 (`$NEW`) on the class path, 19144. **A** — TiffinBox's own keys: 0 lines from `PropertiesMigrationListener`, 0 WARN, 0 ERROR, the seven. **B** — plus `--management.endpoints.enabled-by-default=true`: readiness 200, the seven, and its ERROR report: `Key: management.endpoints.enabled-by-default`, `Reason: Replacement key 'management.endpoints.access.default' uses an incompatible target type` (the exercise's end state). **A′** = A. **C** (labelled) — the migrator without its metadata jar: exit 1, `NoClassDefFoundError: …/ConfigurationMetadataRepositoryJsonBuilder`.

`.r-migrator.out` · md5 `43ed27927270d137ac4d15e207010b37` · 3 of 3

```
A - the README's exploded run from .harness/serve, the migrator and its metadata jar added ($NEW), port 19144:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$NEW/spring-boot-properties-migrator-4.1.1.jar:$NEW/spring-boot-configuration-metadata-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19144
  listens on: 127.0.0.1:19144
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19144/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19144 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: lines from PropertiesMigrationListener 0 · WARN lines 0 · ERROR lines 0
B - the same, and a Boot 3 key: --management.endpoints.enabled-by-default=true:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$NEW/spring-boot-properties-migrator-4.1.1.jar:$NEW/spring-boot-configuration-metadata-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19144 --management.endpoints.enabled-by-default=true
  listens on: 127.0.0.1:19144
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19144/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19144 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: lines from PropertiesMigrationListener 1 · its report:
  ERROR o.s.b.c.p.m.PropertiesMigrationListener:
  The use of configuration keys that are no longer supported was found in the environment:
  Property source 'commandLineArgs':
    Key: management.endpoints.enabled-by-default
      Reason: Replacement key 'management.endpoints.access.default' uses an incompatible target type
  Please refer to the release notes or reference guide for potential alternatives.
A' - A again:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$NEW/spring-boot-properties-migrator-4.1.1.jar:$NEW/spring-boot-configuration-metadata-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19144
  listens on: 127.0.0.1:19144
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19144/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19144 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: lines from PropertiesMigrationListener 0 · WARN lines 0 · ERROR lines 0
C (labelled) - the migrator alone, without its metadata jar:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$NEW/spring-boot-properties-migrator-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19144
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 22 · Caused by: 1 · frames folded as common 20
  ERROR o.s.boot.SpringApplication: Application run failed
  java.lang.NoClassDefFoundError: org/springframework/boot/configurationmetadata/ConfigurationMetadataRepositoryJsonBuilder
  Caused by: java.lang.ClassNotFoundException: org.springframework.boot.configurationmetadata.ConfigurationMetadataRepositoryJsonBuilder
  its log: TiffinBox listening 0 · its standard error: 29 lines · the demo token in its log: 0
  listening now: 19144 0
```

## 10 · exercise — the exercise, run as written

exercise/README.md's commands, then SOLUTION.md's one line, exactly as written: `Key: management.endpoints.enabled-by-default`; nothing listens on 19145 afterwards; its own token 0 times in its log.

`.r-exercise.out` · md5 `908197b08b45dd96777071ff40938f0d` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 5 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  exit 0 · printed: 0 line(s)
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ M="$PWD/.m2-demo" H="$PWD/harness" && cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && B="$M/org/springframework/boot" && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$B/spring-boot-properties-migrator/4.1.1/spring-boot-properties-migrator-4.1.1.jar:$B/spring-boot-configuration-metadata/4.1.1/spring-boot-configuration-metadata-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19145 --management.endpoints.enabled-by-default=true > run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19145/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; "$H/shutdown.sh" 19145 secrets/tiffinbox/shutdown-token > /dev/null; wait; grep -m1 -o 'Key: .*' run.log
Key: management.endpoints.enabled-by-default
  exit 0 · listening on 19145 now: 0
  its log (.harness/mine/after/run.log): its own token 0 times · X-Shutdown-Token 0 times
```

## Exercise

**Your turn:** put Boot's properties migrator on TiffinBox's class path, start it with management dot endpoints dot
enabled-by-default, and read the report. `exercise/README.md` has the commands; done is the line
`Key: management.endpoints.enabled-by-default` (the `exercise` capture; `migrator` B shows the whole report). Without the old key the
solution's line prints nothing and exits 1 (measured once by hand, 2026-10-08: `exercise/solution/SOLUTION.md`).

## UNIT 28's RE-CUT LIST — the brief's table, each row with this unit's verdict

| # | Item | This unit (receipts, 2026-10-08) | Where |
|---|---|---|---|
| 1 | the module reshuffle | autoconfigure 156 → 12; TiffinBox 6 lists, 74 entries; BOM Boot artifacts, starters apart, **18 → 141** (the brief's 19 → 142 counted the plugin entry) | on screen, dim, not spoken (`modules`; RED C5-S5 #4) |
| 2 | Jackson 3 (P5/P6/P7) | Boot's bean `ObjectMapper` → `JsonMapper`; Compose module 2 → 3; annotations shared; the seven identical | spoken (`jackson`, `swap`); the mapper API beyond the default mapper not spoken, not captured (RE-MEASURE 8) |
| 3 | JSpecify null-safety | 58/58 `@NonNullApi` → 55/59 `@NullMarked`; Spring's `Nullable` deprecated since 7.0; TiffinBox 0 annotations | spoken (`nulls`) |
| 4 | API versioning | `version()` on `@RequestMapping`/`@GetMapping` in spring-web 7.0.9; not on TiffinBox's class path; 6.2 not counted | spoken once, Course 6 by title (`versions`) |
| 5 | Actuator's split | actuator-autoconfigure 123 → 24; health 7, metrics 28, observation 2 (TiffinBox's lib); `actuate.health` 50 → 0 | spoken (`moved`, `modules`) |
| 6 | Jackson 2 and 3 endpoint configurations | class files 1 → 2 (`JacksonEndpointAutoConfiguration`, `Jackson2EndpointAutoConfiguration`) | capture only (`jackson`) |
| 7 | heapdump's default access NONE | **in 3.5.16 too** — not a Boot 4 change | spoken (`notnew`) |
| 8 | Live Reload's deprecation | the DevTools lesson's capture (not re-run) | README only |
| 9 | the bridge's 8-argument constructor | **the same signature in 3.5.16 and 4.1.1**; the 6-argument one left | spoken (`moved`) |
| 10 | unit 21's "seventy-five more" / "a hundred fifty-three" | today's anchor 143 (11 its own) | spoken (`counts`) |
| 11 | P21/P22, Course 4's "fifty" | 50 on 4.1.1 = 1 + 11 + 38 | spoken (`counts`) — **paid** |
| 12 | the endpoint access model | `enabled-by-default` deprecated since 3.4.0 (both metadata files); still honoured on 4.1.1, silently; the migrator names it | spoken (`notnew`) + exercise |
| 13 | `spring-boot-starter-web` deprecated | the starter lesson's capture (not re-run) | README only |
| 14 | the Compose module's Jackson 3 broke AOT | `spring-boot-docker-compose` 3.5.16 → Jackson 2, 4.1.1 → Jackson 3 | spoken (`jackson`) |
| 15 | the BOM's versions | Framework 6.2.19 → 7.0.9, Jackson 2.21.4 → 3.1.5, Micrometer 1.15 → 1.17, Tomcat 10.1 → 11.0, Jetty 12.0 → 12.1, Servlet 6.0 → 6.1, Hibernate 6.6 → 7.4, JUnit Jupiter 5.12 → 6.0; Undertow 11 → 0 lines | chip and one sentence (`versions`) |
| 16 | TiffinBox's own code | `-Dmaven.compiler.showDeprecation=true`: **16** files (7 + 9), 0 warnings; a planted old `Nullable`: 1 | spoken (`nulls`) |

**Ledger.** **P21/P22** paid (`counts`). **P5/P6/P7**: measured with both jars; the correction comment on the Core Java II video is
already posted (Vivek's decision, 2026-10-08) — the voice gives the measurement, never a verdict. **P25** retired (not shown in Course
5; Vivek: leave it — the Java API is still identical from Kotlin). **P2**: NullAway and Kotlin are named on a chip only; API
versioning is named with its Course 6 lesson.

## RE-MEASURE — the brief's items this unit settles

| Item (brief) | The probe | This unit |
|---|---|---|
| 6 · the migrator with `=false` | without the migrator: applies | **not spoken** — the exercise uses `=true` (readiness 200); `=false` is measured without the migrator (`notnew` B: health 404, 0 WARN) |
| 7 · TiffinBox's core imports against 3.5.16 | not counted | **not compared, and said so**: 8 imports live in `spring-boot-4.1.1.jar`; 3.5.16's core jar is not fetched; only the 7 health imports are claimed (`moved`) |
| 8 · Jackson 3's mapper API beyond the default mapper | not captured | **not spoken** (no claim about the builder or unchecked exceptions) |

## Found on the way

- **The BOM's modules are 18 → 141, not 19 → 142.** The probe's count included `spring-boot-maven-plugin` (`pluginManagement`);
  `harness/jars.py bom` counts `dependencyManagement` only (73 → 311 `org.springframework.boot` entries, 55 → 170 starters).
- **Jackson 3 was on TiffinBox's run-time class path all along**: Maven's list for the folder run holds `jackson-databind` 3.1.5
  through the optional Compose module (`swap`, B's line), yet the compiler never sees it — B fails on the package. C's POM line
  changes the scope, not the jars: the same 53 names, in another order.
- **The executable jar would not run C**: the plugin's excludes (the Actuator lesson's AOT fix) leave Jackson 3 out of `BOOT-INF/lib`,
  so C runs from the folders, and so does A, for a like-for-like comparison (S4.18).
- **4.1.1's actuator-autoconfigure lists neither Jackson endpoint configuration** in its imports file, though both classes are in
  the jar; this unit counts them as class files and claims no more.
- **TiffinBox's container holds no Jackson bean at all**: Count finds nothing outside the Boot, Spring, Micrometer and TiffinBox
  groups; its two mappers are its own `static final` fields.
- **The source count moved**: 16 files since the command-line lesson's guard and analyzer (the brief said 14).
- **Planted faults, each run once (2026-10-08, S5.18)** — the checks run against a copy of the published captures, one edit each:
  `swap`'s diff count `0` → `2` → `swap C: 0 lines differ`; `migrator` A's listener count `0` → `1` → `migrator A: nothing reported`;
  `nulls`' planted warning count `1` → `0` → `nulls: the planted one counted`; one `moved` line moved to ActuatorRoutes → `moved: the
  bridge's 5, the indicator's 2`; BoxCount's `38` → `39` → `counts: 1 + 11 + 38`; `notnew` B's WARN `0` → `1` → `notnew B: silent`.
  Each died on its fault and passed on the published captures. The measurements can move too: the seven with two JSON keys swapped
  give `diff … | grep -c '^[<>]'` **2**; a WARN line in a log gives `WARN lines 1`; the planted `Nullable` gives 1 warning (`nulls`).

## For unit 29 and RED

- **Unit 29** starts from `../c5-unit27/after` as this unit does; this unit changed nothing in the anchor and binds only 19140-19145.
- **For RED:** whether "a hundred and forty-one modules, against eighteen" should be spoken at all (it counts `dependencyManagement`
  entries, starters apart); the folder run without the `dev` profile as A's layout (derived from the README's line, asserted); the
  migrator's B kept off the slides as the exercise's answer; words at 669 of 700.

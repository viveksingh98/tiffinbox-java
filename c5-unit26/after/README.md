# c5-tiffinbox — Course 5 (Spring Boot)'s long-lived project

**Starts as an exact copy of `c4-tiffinbox`** at the end of Course 4 (tiffinbox-java 1b3b52f): the application Course 4
rewired — `TiffinBoxApp`, component scanning, `tiffinbox.properties`, no `Wiring.java`. Course 5's units change it
from here on; `c4-tiffinbox` stays frozen, so every Course 4 unit keeps pointing at what it measured. Unit 01 of
Course 5 is where Spring Boot arrives. Everything below the second rule is `c4-tiffinbox`'s README as it was.

## Course 5 · unit 01 — Boot arrives (2026-09-27)

Three files changed, and nothing else:
- `pom.xml` inherits `spring-boot-starter-parent:4.1.1` (`java.version 25` replaces `maven.compiler.release`; the
  Spring Framework BOM import goes — the parent manages Spring Framework 7.0.9 now);
- `tiffinbox-web/pom.xml` adds `spring-boot-starter`;
- `TiffinBoxServer.main`: `new AnnotationConfigApplicationContext(TiffinBoxApp.class)` + `registerShutdownHook()`
  become `SpringApplication.run(TiffinBoxApp.class, args)`.

The run command is unchanged — `java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431` — and the seven
responses of `../c4-unit31/curlset.sh` hash to `115c36bac276128e245ca57df11c2891`, exactly as Course 4's did. What Boot
added (a banner, its own log format over the application's JUL records, four property sources, 11 more jars, and
`-parameters` in this build) is measured in `../c5-unit01/`.

## Course 5 · unit 03 — the Jackson family moves together (2026-09-27)

`pom.xml` no longer pins `jackson-databind` alone: under Boot's parent that left `jackson-core` and
`jackson-annotations` on Boot's 2.21.x beside databind 2.22.2. It sets `<jackson-2-bom.version>2.22.2</jackson-2-bom.version>`
instead — the property Boot's BOM reads — and all three are 2.22.x. The seven responses are unchanged; evidence in
`../c5-unit03/`.

## Course 5 · unit 04 — auto-configuration switched on (2026-09-27)

`TiffinBoxApp` gains `@EnableAutoConfiguration`. On this class path Boot's imports file lists 12 configuration classes;
9 are registered, 3 are not used; the definitions go 12 → 55; the seven responses are unchanged. Evidence in
`../c5-unit04/`.

## Course 5 · unit 06 — one configuration file, and a new run command (2026-09-29)

Three changes, and nothing else:
- `tiffinbox-web/src/main/resources/tiffinbox.properties` is renamed `application.properties`, byte for byte. Boot
  finds a file of that name by itself, while it prepares the environment.
- `TiffinBoxApp` loses `@PropertySource("classpath:tiffinbox.properties")` and its import. A `@PropertySource` file
  ranks **last** of the property sources (8 of 8 with the key set in five places), and it is read during refresh, after
  Boot has read keys such as `logging.level.tiffinbox` and `spring.main.banner-mode` (both measured: in that file they
  were silently ignored).
- `TiffinBoxServer.main` loses the three-line port bridge (`System.setProperty("tiffinbox.port", args[0])`). Boot's
  command-line source already outranked that system property.

**The run command changes, for the first time in Course 5:**

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

Flags may come in any order (`--debug --tiffinbox.port=18431` works), and the seven responses of
`../c4-unit31/curlset.sh` still hash to `115c36bac276128e245ca57df11c2891`. **The old command still starts, and says
nothing:** `java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431` exits 0 and listens on **18425**, the file's
port — a bare number names no property, so nothing reads it. Every `… <port>` command further down this README was
written before this change: put `--tiffinbox.port=` in front of the number. Evidence in `../c5-unit06/`.

## Course 5 · unit 07 — application.yaml (2026-09-30)

Two files, and one comment:
- `tiffinbox-web/src/main/resources/application.properties` is **deleted**, and `application.yaml` replaces it. The
  same four keys with the same values, one level of nesting per dot (`tiffinbox:` written once, `cooks: 3` under it), and
  two things the old file did not have:
  - `tiffinbox.meal-types`, a list (`VEG`, `NON_VEG`, `VEGAN`). Boot keeps it as three keys, `tiffinbox.meal-types[0]`
    to `[2]`; `@Value("${tiffinbox.meal-types}")` cannot read it (the start fails: `Could not resolve placeholder`), and
    nothing in TiffinBox reads it yet.
  - a second document, after `---`, read only while the profile `rush` is active: `tiffinbox.cooks: 6`.
- The old file is deleted rather than kept beside the new one: in the same folder Boot asks `application.properties`
  first, so an edit to the YAML would be silently outvoted (measured: YAML `cooks: 4`, answer `3`).
- `TiffinBoxApp`'s Javadoc says so (comments only).

The run command is unchanged, and the seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891`. The lunch rush is one flag more:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.profiles.active=rush
```

Boot logs `The following 1 profile is active: "rush"`, and `OrderQueue` runs six cooks (the responses do not change:
the cooks share the same orders). **Indentation is structure in YAML:** indent the rush document's `tiffinbox:` block two
spaces further, under `spring:`, and the start is clean, silent, and back to three cooks — the key has become
`spring.tiffinbox.cooks`. A tab, or one space too many under `tiffinbox:`, fails the start with a line and a column
(`in 'reader', line 4, column 1`), and the message does not name the file. Evidence in `../c5-unit07/`.

## Course 5 · unit 08 — one typed record for every reader (2026-09-30)

Six files changed, two new, and nothing else:
- `tiffinbox-core` gains `TiffinBoxProperties`, a record annotated `@ConfigurationProperties("tiffinbox")` —
  `String jdbcUrl, int cooks, int days, int port, List<MealType> mealTypes` — and `MealType`, an enum (`VEG`, `NON_VEG`,
  `VEGAN`). Boot's binder fills the record through its one constructor, from every key under `tiffinbox`, the list
  included (each item a `MealType`).
- `TiffinBoxApp` gains `@EnableConfigurationProperties(TiffinBoxProperties.class)`, which registers the record as a bean
  (its name: `tiffinbox-com.tiffinbox.TiffinBoxProperties`). Without it, TiffinBox does not start: no bean of that type.
- `Database`, `OrderQueue` and `TiffinBoxServer` take the record in their constructors, so TiffinBox's `@Value`
  placeholders go from 4 to 0. `TiffinBoxServer` reads the list at last, and logs it at startup:
  `meal types:     [VEG, NON_VEG, VEGAN]`.
- `tiffinbox-core/pom.xml` depends on `spring-boot` (the annotation is Boot's). Core still has no HTTP in it.
- The root `pom.xml` names Boot's configuration processor in `maven-compiler-plugin`'s `annotationProcessorPaths`, with no
  version (the parent manages it). The core jar now carries `META-INF/spring-configuration-metadata.json` — one group,
  five properties, each described by the record's `@param` line — the file an IDE reads to complete and describe the
  keys. Added as an ordinary dependency instead, the processor writes nothing on JDK 25 — 0 files, 0 warnings — unless
  processing is switched on (`<proc>full</proc>`).

The run command and `application.yaml` are unchanged, and the seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891`. The file may spell a meal type loosely (`veg`, `non-veg`, `"Vegan "`): Boot's
conversion service binds each to its constant, with no converter written; a word it cannot match (`vegetarian`) stops the
start and lists the valid values.

**What it quietly costs:** a key missing from the file no longer stops the start. Delete `days` and TiffinBox starts,
cooks 0 orders and answers `/kitchen` with zeros — the `"defaultValue": 0` the metadata file gives every `int`. With
`@Value`, the same file stopped the start and named `tiffinbox.days`. Evidence in `../c5-unit08/`.

## Course 5 · unit 09 — the configuration refuses to start (2026-09-30)

Three files changed, and nothing else:
- `tiffinbox-web/pom.xml` adds `spring-boot-starter-validation`: Hibernate Validator 9.1.3.Final (the implementation), the
  Bean Validation API it implements, and `spring-boot-validation`, whose own imports file lists one class,
  `ValidationAutoConfiguration`. `lib/` goes from 26 jars to 33, and the jars in it that carry an
  `AutoConfiguration.imports` file from 1 to 2.
- `tiffinbox-core/pom.xml` adds `jakarta.validation-api` (no version: managed) — the constraint annotations, and nothing
  that checks them. Core still has no HTTP in it.
- `TiffinBoxProperties` gains `@Validated` and a rule on each component — `@NotBlank jdbcUrl`, `@NotNull @Min(1)` on
  `cooks`, `days` and `port`, `@NotEmpty mealTypes` — and its three numbers become `Integer`, so a key nobody wrote is
  `null` ("must not be null") rather than an `int`'s zero. The metadata file no longer gives them `"defaultValue": 0`.

A value that breaks a rule now stops the start, before the port opens, with one report (four bad values in one file gave
one report with four blocks). Each block names the property — by the record's Java name, `tiffinbox.jdbcUrl`, not
`jdbc-url` — its value, its origin, and the rule. `cooks: 0` in a file:

```
    Property: tiffinbox.cooks
    Value: "0"
    Origin: class path resource [application.yaml] - 4:10
    Reason: must be greater than or equal to 1
```

The report gets its turn because `Database`, `OrderQueue` and `TiffinBoxServer` all take the record: with `Database` back
on a `@Value` placeholder, a blank URL fails first, as `SQLException: No suitable driver found`, and no report is printed.
The run command and `application.yaml` are unchanged, and the seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891`. Evidence in `../c5-unit09/`.

## Course 5 · unit 10 — profiles, a group, and a developer's own file (2026-09-30)

One file changed, two new, and nothing else:
- `tiffinbox-web/src/main/resources/application.yaml` gains two keys in its first document:
  - `spring.profiles.group.lunch: rush,audit` — a profile group. `--spring.profiles.active=lunch` switches on three
    profiles, and Boot says so: `The following 3 profiles are active: "lunch", "rush", "audit"`.
  - `spring.config.import: optional:file:./tiffinbox-local.yaml` — a developer's own settings, read from the folder
    TiffinBox starts in when that file is there. `optional:` makes a missing file no error; without it, a missing file
    stops the start, and Boot's report says `prefix it with 'optional:'`.
- `tiffinbox-web/src/main/resources/application-audit.yaml` (new) — the profile `audit`, a file of its own with one key,
  `logging.level.tiffinbox: debug`. Boot reads a profile's file while it prepares the environment, before refresh, so a
  logging key works there (5 route lines at DEBUG) — the key a `@PropertySource` file received too late.
- `.gitignore` (new, beside this README) — `tiffinbox-local.yaml`, so a developer's own file stays out of git.

Where `tiffinbox.cooks` comes from with `lunch` on and a `tiffinbox-local.yaml` present, highest first: the audit's file
(no cooks in it) · the rush document (6, the winner) · `tiffinbox-local.yaml` · `application.yaml`'s first document (3).
Naming the profiles the other way round (`audit,rush`) gives the same order: here a profile's own file ranks above both
documents of `application.yaml`. A misspelt profile (`lnch`) starts without a warning: Boot's profile line names it, and
nothing is composed for it. `spring.profiles.active` inside a profile file stops the start
(`InvalidConfigDataPropertyException`, naming the file, line and column) — once that profile is switched on; until then
the file is never read.

The run command is unchanged, and the seven responses of `../c4-unit31/curlset.sh` still hash to
`115c36bac276128e245ca57df11c2891` — plain, with `rush`, and with the group:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.profiles.active=lunch
```

Started as above, from this folder, TiffinBox imports `./tiffinbox-local.yaml` — a file beside this README, for example:

```yaml
tiffinbox:
  cooks: 4
```

Evidence in `../c5-unit10/`.

## Course 5 · unit 11 — a secret with a job (2026-09-30)

Until now anyone who could reach TiffinBox's port could stop it: POST /shutdown asked for nothing. Four files changed,
and nothing else:
- `TiffinBoxProperties` gains `@NotBlank String shutdownToken` — the key `tiffinbox.shutdown-token` — and its length rule,
  16 characters or more, as a yes-or-no method, `isShutdownTokenLongEnough()`. Not as `@Size` on the token: a failure
  report prints the value of the property that broke a rule, so `@Size` on the token prints the token, with the file it
  came from, in a log line at ERROR. With the method, a short token's report reads `Value: "false"`. The record also
  writes its own `toString()`: every component, and `[not shown]` in the token's place — a record's default prints every
  component, the token included, and a settings object is the first thing anyone logs.
- `TiffinBoxServer` answers POST /shutdown with `403 {"error":"forbidden"}` — and keeps running — unless the request's
  `X-Shutdown-Token` header holds the token (compared with `MessageDigest.isEqual`). Nothing logs the header or the token.
- `application.yaml`'s `spring.config.import` becomes a list: `optional:file:./tiffinbox-local.yaml`, then
  `optional:configtree:./secrets/` — a config tree: one file per key, in the folder TiffinBox starts in. Both rank below
  the profiles' sources, and the later import ranks higher: with a token in both, the tree's answers.
- `.gitignore` gains `secrets/`.

**The run command is unchanged, but TiffinBox no longer starts without a token.** With none anywhere the start stops,
before the port opens: `Property: tiffinbox.shutdownToken` · `Value: "null"` · `Reason: must not be blank`. Make one, in a
file beside this README that only you can read (never committed: `secrets/` is git-ignored), then start as before:

```bash
mkdir -p secrets/tiffinbox && (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > secrets/tiffinbox/shutdown-token)
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

Boot drops the file's trailing newline. **Stopping it now takes the header** — read from the file, so the token is never
on a command line (`ps` prints every argument; `ps eww`, a process's environment too):

```bash
{ printf 'X-Shutdown-Token: '; head -n 1 secrets/tiffinbox/shutdown-token; } | curl -s -w ' %{http_code}\n' -H @- -X POST http://127.0.0.1:18431/shutdown
```

It answers `{"stopping":true} 200`; without the header, `{"error":"forbidden"} 403`, and TiffinBox keeps running.
`../c4-unit31/curlset.sh` can no longer stop it: its seven responses now hash to `11bbc19ca107097dfd6477aa7fb0246b`. The
comparison set from here on is `../c5-unit11/curlset.sh PORT TOKENFILE` — Course 4's seven, the last with the header — and
they hash to `115c36bac276128e245ca57df11c2891`: plain, and with the logging, rush and lunch commands above. With `lunch`
on (the audit's logging at DEBUG) the token appears 0 times in the log. Evidence in `../c5-unit11/`.

## Course 5 · unit 13 — one executable jar (2026-10-05)

One file changed, and nothing else: `tiffinbox-web/pom.xml` declares `spring-boot-maven-plugin` — bare, with no version
and no execution: Boot's parent manages both, and declaring the plugin is what binds its `repackage` goal to `package` —
and loses the jar plugin's `<archive>` block (`Main-Class`, `addClasspath`, `classpathPrefix`) and the
`copy-dependencies` execution.

`tiffinbox-web/target/tiffinbox-web-1.0.0.jar` is now Boot's executable jar, a jar of jars: TiffinBox's three classes and
two YAML files under `BOOT-INF/classes/`, the 31 jars it needs under `BOOT-INF/lib/`, each kept whole, and Boot's launcher
at the top — `Main-Class: org.springframework.boot.loader.launch.JarLauncher`, `Start-Class:
com.tiffinbox.web.TiffinBoxServer`. The build no longer writes `target/lib/`, and the jar runs alone. **The run command is
unchanged:**

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

(it still needs its token — unit 11's section above). **A class path from the jar** — for a tool or a test harness that
names its own main class — comes from Boot's own tool, which unpacks the jar into a thin jar and a `lib/` folder:

```bash
java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
```

The extracted jar's `Main-Class` is TiffinBox's own and its `Class-Path` names the 31 jars in `lib/`, so `java -jar
tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431` runs it too, without Boot's launcher. The
`lib/*` in the second command is the JVM's own class-path wildcard: every jar in that folder. Each of the three serves the
seven responses `115c36bac276128e245ca57df11c2891` (`../c5-unit11/curlset.sh PORT TOKENFILE`). **Don't put a jar built with
the old `<archive>` block beside an older `lib/`:** its `Class-Path` header survives `repackage`, and the application class
loader, asked first, loads the classes that header names from that folder — measured with an older release's `lib/`:
`NoSuchMethodError: 'java.lang.String com.tiffinbox.TiffinBoxProperties.shutdownToken()'`. The jar as built here has no
`Class-Path` and serves from the same folder. Evidence in `../c5-unit13/`.

## Course 5 · unit 14 — one fixed build time (2026-10-05)

One file changed, and nothing else: the root `pom.xml` gains one property,
`<project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>` — the same line, with the same date,
that Course 3's reproducible-build exercise put into its packaging POM (`../c3-unit23/pom.xml`). Every archive the build
writes now stamps each entry with that instant instead of the build's clock, so **two clean builds of the same sources,
in one time zone, give the same bytes**: measured, `tiffinbox-web-1.0.0.jar` built twice has one md5, and the four
layers Boot's index names (`BOOT-INF/layers.idx`: `dependencies`, `spring-boot-loader`, `snapshot-dependencies`,
`application`) unpack to the same files. In another time zone the jar differs: Boot's repackage gives 8 entries under
`BOOT-INF/classes/` an NTFS time field that follows the zone (measured: `TZ=UTC` against `TZ=Asia/Kolkata`, 5.5 hours
apart; every entry's name, content and date the same; `tiffinbox-core`'s jar byte for byte the same) — `../c5-unit14/`,
capture `moved`. Without it, `tiffinbox-core`'s jar — the same classes, 18 of its 19 entries dated by its build — and
with it the `application` layer of Boot's jar changed on every build, even with no change at all.

Nothing about building or running TiffinBox changes: the build, the jar's name and the run command are unit 13's
(`java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431`, with its token). `tiffinbox-core` lands in
the `application` layer only when the reactor builds it — a build from this root folder; a build of `tiffinbox-web` on its
own takes `tiffinbox-core` from the local repository, as a library, into `dependencies`.

The images this was measured with are not part of the anchor: Boot's two-stage Dockerfile recipe, a copy of
host-extracted layer folders, and a single-jar image (Boot's jar, copied whole) live in `../c5-unit14/docker/`, with
their evidence. **If you write a Dockerfile for this jar, run Boot's `extract` inside the build**, as the recipe's first
stage does: with this fixed time, a layer folder extracted on the host keeps its files' sizes and times across a
same-length change, Docker's build does not send the changed file again, and the image keeps the old class (measured in
`../c5-unit14/`, capture `stale`).

## Course 5 · unit 15 — an address a container can reach (2026-10-05)

Three files changed, and nothing else:
- `TiffinBoxProperties` gains `@NotBlank String address` — the key `tiffinbox.address` — after `port`; its `toString()`
  prints it.
- `TiffinBoxServer` binds that address — `new InetSocketAddress(address, port)`, where it said `"127.0.0.1"` — and its
  listening line prints it: `TiffinBox listening on http://<address>:<port>`.
- `application.yaml` gives the key its default, `address: 127.0.0.1`: this computer only, as before.

**On the Mac, nothing changes:** the run command, the log line (`TiffinBox listening on http://127.0.0.1:18431`) and the
seven responses (`115c36bac276128e245ca57df11c2891`). **In a container, `127.0.0.1` is the container's own address:** a
port Docker publishes does not arrive there — measured: the log says `TiffinBox listening on http://127.0.0.1:18425`, and
the Mac's `curl` gets `curl: (52) Empty reply from server` (on OrbStack; another Docker may answer differently). Give
the container `TIFFINBOX_ADDRESS=0.0.0.0` — every interface of the container — and publish the port on the Mac's
`127.0.0.1` alone. Boot's own key, `server.address` (`SERVER_ADDRESS`), changes nothing here: TiffinBox's `HttpServer`
never reads it.

**An image with no Dockerfile.** Boot's Maven plugin hands the jar to Paketo's buildpacks, in two steps: the first builds
both modules (so `tiffinbox-core` lands in the `application` layer, unit 14's index), the second builds the web module's
image from the jar the first just made. The builder is pinned by its digest, and neither it nor the run image is pulled
when already present:

```bash
mvn -B install
mvn -B -pl tiffinbox-web spring-boot:build-image-no-fork -Dspring-boot.build-image.builder=paketobuildpacks/builder-noble-java-tiny@sha256:b95da27fce97b58037f0c11ae934760c50730da4c9a24976205b53638592eba9 -Dspring-boot.build-image.runImage=paketobuildpacks/ubuntu-noble-run-tiny:0.0.138 -Dspring-boot.build-image.pullPolicy=IF_NOT_PRESENT
docker run -d --name tiffinbox -m 1g --user "$(id -u):$(id -g)" -e TIFFINBOX_ADDRESS=0.0.0.0 -v "$PWD/secrets:/workspace/secrets:ro" -p 127.0.0.1:18431:18425 tiffinbox-web:1.0.0
```

The image is `tiffinbox-web:1.0.0`, Boot's default name for this module. It runs as user `1002:1001` from `/workspace` —
the jar, unpacked — and holds no shell. The config tree goes there, read-only, so the token never enters the image; with
`-e TIFFINBOX_SHUTDOWN_TOKEN=…` instead, `docker inspect` lists the token. Stop it with POST /shutdown and the header (unit
11's command, on port 18431): the container exits 0, and `docker rm tiffinbox` removes it. **Not `mvn
spring-boot:build-image` from this folder:** it runs on `tiffinbox-core` first, fails (`Unable to find main class`), and
leaves a container, its image and four `pack-*` volumes behind. A first build downloads, inside the build, BellSoft
Liberica JRE 25.0.4 and syft (github.com) and spring-cloud-bindings 2.0.4 (Maven Central); the JRE is kept in the image's
own layer, so a rebuild skips the download only while the previous image is still there. `--user "$(id -u):$(id -g)"`
runs the container as the owner of the `0600` token file. Where a file keeps its owner and mode — measured in a Docker
volume, as on Linux — the image's own user, `1002:1001`, cannot read the folder, and the container exits 82 before Java
starts (the buildpack's memory calculator: `open /workspace/secrets: permission denied`); run as your own user, it
serves. On this Mac, OrbStack's file sharing lets the image's own user read a mounted file too. Evidence in
`../c5-unit15/`, capture `user`.

## Course 5 · unit 16 — a Dockerfile of its own (2026-10-05)

Two new files beside this README, and nothing else changed (the jar is byte for byte the one before):
- `Dockerfile` — two stages, both on the official `eclipse-temurin:25-jre`. Stage one copies the jar Maven built and runs
  Boot's extract tool on it, inside the build (unit 14's recipe). Stage two — the only one that ships — copies the four layer
  folders into `/app`, then three settings: `ENV TIFFINBOX_ADDRESS=0.0.0.0` (unit 15's key: in a container `127.0.0.1` is the
  container's own), `USER ubuntu` (uid 1000, already in the base image, which runs as root) and an exec-form entrypoint,
  `ENTRYPOINT ["java", "-jar", "application.jar"]`. No memory flag is baked in.
- `.dockerignore` — `secrets/` and `tiffinbox-local.yaml`, the two files this README tells you to keep beside it and never
  commit. `docker build` hands the builder this folder, the build context: a Dockerfile that copies the whole folder (`COPY .`)
  puts the token into an image layer, and the ignore file keeps both out whatever a Dockerfile copies. This Dockerfile copies
  the jar alone, and BuildKit sent it the same bytes with or without the ignore file — measured, on this Mac.

**Build and run** — Maven on your machine first, then Docker; the config tree mounted read-only where the image works,
`/app`; the port published on `127.0.0.1` alone; a memory limit:

```bash
mvn -B package
docker build -t tiffinbox-docker:1.0.0 .
docker run -d --name tiffinbox -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:18431:18425 tiffinbox-docker:1.0.0
```

Inside the container TiffinBox listens on `0.0.0.0:18425`; the Mac reaches it on `127.0.0.1:18431`, with the same seven
responses (`115c36bac276128e245ca57df11c2891`). Boot's first line says `started by ubuntu in /app`. Stop it with POST /shutdown
and the header (unit 11's command, on port 18431) — the container exits 0 — or with `docker stop tiffinbox`: Java is process
1, so Docker's SIGTERM reaches it, Boot's shutdown hook closes the context and TiffinBox's `@PreDestroy` method runs; the
container exits 143. Then `docker rm tiffinbox`. Arguments after the image name reach TiffinBox:
`… tiffinbox-docker:1.0.0 --tiffinbox.days=10`.
- **Keep the exec form.** In the shell form (`ENTRYPOINT java -jar application.jar`) Docker runs `/bin/sh -c`, the shell is
  process 1, an argument after the image name never reaches Java, and `docker stop` waits out Docker's ten seconds, then kills
  everything: exit 137, no `@PreDestroy`. The build warns (`JSONArgsRecommended`), and `docker build -q` hides the warning.
- **Memory:** Java reads the container's limit. With `-m 512m` it keeps a quarter for its heap (`MaxHeapSize = 134217728`);
  without `-m`, a quarter of whatever memory Docker's machine has. Change the share at run time, not in the image:
  `-e JAVA_TOOL_OPTIONS=-XX:MaxRAMPercentage=75`.
- **The user:** as `ubuntu`, the container cannot delete the app's own jar; the same image run with `--user root` can.
  `ubuntu` is a member of Ubuntu's default groups, `sudo` among them; the image has no `sudo` command.
- On the Mac the container's user, `ubuntu` (uid 1000), read the `0600` token file through OrbStack's file sharing.
  Where a file keeps its owner and mode — measured in a Docker volume, as on Linux — it cannot read a tree another user
  owns: TiffinBox stops before it listens (`Unable to find files in '/app/./secrets'`, caused by
  `java.nio.file.AccessDeniedException`), exit 1. Run it as the tree's owner — `--user "$(id -u):$(id -g)"` in the
  `docker run` line — and it serves the seven. Evidence in `../c5-unit16/`, capture `owner`.

## Course 5 · unit 17 — Postgres for development (2026-10-05)

Two new files and two changed ones; the Java sources are untouched:
- `compose.yaml` — new, beside this README: one official Postgres image (`postgres:18-alpine`), the project name
  `tiffinbox-dev` (so the network, the container and the volume are `tiffinbox-dev_default`, `tiffinbox-dev-postgres-1` and
  `tiffinbox-dev_data`, whatever this folder is called), its port published on `127.0.0.1:18881` alone, and no password —
  `POSTGRES_HOST_AUTH_METHOD: trust` tells Postgres to trust whoever connects, so nothing secret is committed. The data lives
  in a volume with a name: `docker compose down` keeps it, `docker compose -p tiffinbox-dev down -v` deletes it. Without
  that line the image's own volume gets no name, and `docker compose down` leaves it behind, its 64-character ID the only
  name it has.
- `tiffinbox-web/pom.xml` — `spring-boot-docker-compose`, Boot's Docker Compose support, as an **optional** dependency. It
  brings two jars of Jackson 3 (`jackson-databind`, `jackson-core` 3.1.5) to the class path Maven lists, beside Jackson 2.
  The executable jar holds none of the three: Boot's plugin leaves optional dependencies out (`includeOptional`, off),
  and keeps this module out on its own too (`excludeDockerCompose`, on). With `includeOptional` on, that second setting
  still keeps the module out, but not its Jackson: 33 jars, the module 0, Jackson 3's two.
- `application.yaml` — `spring.docker.compose.enabled: false`: off.
- `application-dev.yaml` — new: the profile `dev` switches it on.

**Postgres with TiffinBox** — from this folder (`compose.yaml` and `secrets/` beside you), on the class path Maven lists:

```bash
mvn -B package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.profiles.active=dev
```

Boot runs Docker's own command-line tool before TiffinBox starts — `docker compose … up --no-color --detach --wait` among
others — and Compose creates the network, the volume and the container; its last line is `Healthy`, which here means
only that the container is running: the image declares no health check of its own (`docker image inspect` says `null`),
and the running container has no health status (`docker inspect`). TiffinBox then serves the same seven responses
(`115c36bac276128e245ca57df11c2891`). When TiffinBox stops, Boot runs `docker compose … stop --timeout 10` on its
shutdown hook's thread: the container is left `exited`, and the network and the volume stay. Add
`--spring.docker.compose.stop.command=down` and Boot removes the container instead; the volume stays. To remove
everything, `docker compose -p tiffinbox-dev down -v`.

**Why it is off unless `dev` is on.** With the module on the class path and Boot's default, a start from a folder that holds
no `compose.yaml` stops: `No Docker Compose file found in directory '…'`. With the profile on and Docker not answering:
`'docker version --format {{.Client.Version}}' failed with exit code 1.` With Docker off, start without `dev`, or add
`--spring.docker.compose.enabled=false`. Without `dev` nothing changes — the jar, the jar extracted, the image and Maven's
class path each serve the seven: the executable jar holds no Docker Compose support, and run with `dev` it starts nothing.

**Postgres runs beside TiffinBox, not under it.** TiffinBox's `Database` still connects to `tiffinbox.jdbc-url`, H2 in
memory, and its SQL is H2's: pointed at this Postgres (`--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:18881/tiffinbox?user=tiffinbox`,
with the Postgres driver on the class path), the start stops with `syntax error at or near "AUTO_INCREMENT"`. Postgres is
Course 7's subject. With Spring Boot's JDBC module and the Postgres driver on the class path (not in this project), Boot
registers the database's address as a bean — `jdbcConnectionDetailsForTiffinboxDevPostgres1`,
`jdbc:postgresql://127.0.0.1:18881/tiffinbox`, user `tiffinbox` — but with no connection pool on the class path its
`DataSource` is an embedded H2. Evidence in `../c5-unit17/`.

## Course 5 · unit 19 — ahead of time, and a native image (2026-10-05)

One file changed: `tiffinbox-web/pom.xml` declares GraalVM's Native Build Tools plugin (`native-maven-plugin`), bare — no
version, no execution. Boot's parent manages its version, **1.1.8** (`native-build-tools-plugin.version`; Course 3 pinned
1.1.13 by hand). Nothing else in TiffinBox changed: a build without the profile `native` gives the same executable jar as
before, but for the copy of this POM Maven puts in every jar (169 of 170 entries the same). The plugin is now a build extension
of every build of the web module (Boot's parent declares it with `<extensions>true</extensions>`): the first build downloads it
from Maven Central, with its metadata repository. The plugin reads that metadata repository (a zip) from the local Maven
repository — and when the zip is not there, it does not stop, even offline (`-o`): it downloads the zip from GitHub instead.

**Spring's ahead-of-time step (AOT), on the plain JDK.** Boot's parent's profile `native` runs Boot's `process-aot` on the web
module: at build time it reads TiffinBox's configuration — the scan, the conditions, the constructors — without starting the
server, and writes what it decided as Java code (`tiffinbox-web/target/spring-aot/main/`: the bean definitions as code,
compiled into the jar) and as data
(`reachability-metadata.json` — not Course 3's `reflect-config.json` — the file a native build reads). With the plugin
declared, the profile also runs the plugin's `add-reachability-metadata`, which copies metadata for the jars TiffinBox uses
from GraalVM's shared repository (a zip Maven downloads from Central on the first build; for H2 2.5.250 it has no entry, and
takes 2.1.210's):

```bash
mvn -B -Pnative package
java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

The jar runs with or without `-Dspring.aot.enabled=true`; with it, Spring starts the context from the generated code, and
Boot's first line says `Starting AOT-processed TiffinBoxServer`. Measured: the same seven responses
(`115c36bac276128e245ca57df11c2891`) either way; 59 bean definitions without it, 55 with it — the four missing are three
post-processors whose work the build already did (the configuration-class one, the autowired one, the common-annotation one)
and Boot's cache for reading class files.

**What the build decides, a run can no longer change.** Under `-Dspring.aot.enabled=true`, `spring.threads.virtual.enabled`
given at run time is read and ignored: the environment says `true`, and Boot's executor is still the pool
(`ThreadPoolTaskExecutor`, eight platform threads) — no warning. Built with the switch on
(`-Dspring-boot.aot.jvmArguments=-Dspring.threads.virtual.enabled=true`), the same run without it gets virtual threads. An
`@Async` method follows Boot's executor: under AOT, the pool. Choose such settings when you build.

**A faster start, with the JDK's AOT cache too** — Course 3's training run, now on TiffinBox, on the extracted jar (unit 13's
command): train once — one command records the run and writes the cache — then run with the cache:

```bash
java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
java -XX:AOTCacheOutput=tiffinbox-web/target/tiffinbox.aot -Dspring.aot.enabled=true -Dspring.context.exit=onRefresh -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -XX:AOTCache=tiffinbox-web/target/tiffinbox.aot -Dspring.aot.enabled=true -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

Measured on an Apple M1 (8 cores, 16 GB), from the process's start to the first answer, the middle of five runs: the executable
jar over a second; Spring's AOT alone a little faster (its median under the jar's, over three quarters of it); the jar extracted,
faster; extracted and with the JDK's AOT cache, with or without Spring's AOT, under half the executable jar's. On the executable
jar itself the cache does less: over half the jar's time. Never the `Started … in` line. Evidence in `../c5-unit19/`, capture
`ladder`.

**A native image** — needs a GraalVM JDK 25 (`GRAALVM_HOME`; the course used GraalVM CE 25.3.4.1) and minutes of CPU. First
install both modules, then build the binary from the web module alone:

```bash
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25
mvn -B -Pnative install
mvn -B -Pnative -pl tiffinbox-web native:compile-no-fork
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431
```

**As this unit left it, the binary stopped at start**: the build says `BUILD SUCCESS`, and the binary prints Boot's banner, then
exits 1 — `MissingReflectionRegistrationError: Cannot reflectively invoke method 'public boolean
com.tiffinbox.TiffinBoxProperties.isShutdownTokenLongEnough()'` (Hibernate Validator calls the token-length rule by reflection,
and nothing registered it). Unit 20 adds the hints (below). The binary was built from Maven's class path, so it also held the
optional `spring-boot-docker-compose` and its Jackson 3, which the executable jar leaves out; unit 20 keeps them out of the
binary too. **Not `mvn -Pnative native:compile` from this folder:** it runs on the parent POM first and fails (`Image classpath
is empty`). Evidence in `../c5-unit19/`.


## Course 5 · unit 20 — the hints a closed world needs (2026-10-06)

Three Java files gained one annotation each, and `tiffinbox-web/pom.xml` keeps two optional modules out of the native binary.
Nothing a JVM run sees changed: the executable jar serves the same seven responses (`115c36bac276128e245ca57df11c2891`) before and
after, and holds the same 31 jars.

**What a native binary cannot do without them.** A native image calls by reflection only what its build registered, and Spring's
ahead-of-time step registers what Spring itself calls. TiffinBox calls more: its router invokes the route methods it finds by
reflection, Jackson reads the `Customer` record by reflection, and Hibernate Validator calls the token-length rule by reflection.
Each hint taken out on its own, the other two in (`../c5-unit20/`, capture `breaks`):

- without `@Reflective` on `isShutdownTokenLongEnough()` (`TiffinBoxProperties`), the binary stops at start, exit 1 —
  `MissingReflectionRegistrationError` on that method, as in unit 19: the router's and the record's hints are not enough;
- without `@Reflective` on the annotation `Route`, the router still finds its five routes (`routes mapped: [GET /customers, GET
  /dashboard, GET /kitchen, GET /revenue, POST /shutdown]`), but calling one fails on the request's thread (`Cannot reflectively
  invoke method 'java.lang.Object com.tiffinbox.web.TiffinBoxServer.kitchen()'`) and the client gets no answer — POST /shutdown
  included: only a signal stops it. GraalVM's refusal is an `Error` (a `LinkageError`), and the handler catches only `Exception`,
  so no 500 is sent;
- without `@RegisterReflectionForBinding(Customer.class)` on `TiffinBoxServer`, `/customers` answers
  `500 {"error":"InvalidDefinitionException"}` (Jackson's), and the other six answers are the same.

**The hints, where the need is** — Spring's own annotations, from `spring-core`:

```java
@Reflective                                      // on @interface Route: every method carrying @Route is registered
@RegisterReflectionForBinding(Customer.class)    // on TiffinBoxServer: the record, its components, their accessors
@Reflective                                      // on TiffinBoxProperties.isShutdownTokenLongEnough(): that method
```

Each one is data in Spring's generated `reachability-metadata.json` (`mvn -B -Pnative package`; 262 reflection entries before,
263 after): `Customer` is a new entry — its fields, its constructors and its four accessors — `TiffinBoxServer`'s entry gains its
five route methods, and `TiffinBoxProperties`' gains `isShutdownTokenLongEnough`. A `RuntimeHintsRegistrar`, Spring's general
tool — code that registers hints, imported with `@ImportRuntimeHints` — wrote the same file byte for byte in place of the third
annotation (capture `metadata`, E; not in the anchor, which keeps `TiffinBoxApp` unedited).

**The binary's class path.** The plugin builds the binary from Maven's class path, not from the jar's. Unit 19's binary held the
optional `spring-boot-docker-compose` and its two Jackson 3 jars (36 jars against the jar's 31; in its bytes, 34 distinct names
from the Compose module and 991 from Jackson 3, 24 and 884 of them class names). The plugin's `<exclusions>` keep those three jars
out: 33 jars — the jar's 31 less `spring-boot-jarmode-tools`, plus three starters that hold no class — and in the binary's bytes
0 names from the Compose module and 3 from Jackson 3 (2 of them class names) — names that classes of `spring-boot`'s own JSON
support mention. The executable jar never held either. TiffinBox's own Jackson, version 2 (`com.fasterxml`), stays on the
binary's class path.

Build and run the binary with unit 19's four lines (above). Measured on an Apple M1 (8 cores, 16 GB), from the process's start to
the first answer, the middle of five runs after a warm-up round: the binary's warmed-up start under a tenth of a second, under a
tenth of the executable jar's time, and under a fifth of the fastest JVM way (the jar extracted, with the JDK's AOT cache and
Spring's AOT). That is one measure, start time, on one Mac: no size, and no throughput figure — the work done once it runs is
Course 18's to measure (Course 3's rule). Evidence in `../c5-unit20/`.


## Course 5 · unit 21 — Actuator, on TiffinBox's own server (2026-10-07)

Four files changed and one is new. The seven responses are the same before and after
(`115c36bac276128e245ca57df11c2891`), and so is `TiffinBoxApp.java`:
- `tiffinbox-web/pom.xml` — **`spring-boot-starter-actuator`**, Boot's Actuator: endpoints, small reports on the running
  application (health, env, beans, metrics, …), and Micrometer, Boot's metrics library. Eight more jars in `BOOT-INF/lib`
  (31 → 39). And **three `<excludes>` in Boot's plugin** — `org.springframework.boot:spring-boot-docker-compose`,
  `tools.jackson.core:jackson-databind`, `tools.jackson.core:jackson-core`: the three jars the native plugin's exclusions already keep
  out of the binary (unit 20), now kept out of Spring's AOT step too (below).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java` — **new**: three beans that put Boot's endpoints on
  TiffinBox's own server, under `/actuator`.
- `TiffinBoxServer.java` — one more constructor argument, the handler `ActuatorRoutes` builds, and one more context:
  `server.createContext("/actuator", actuator)`. One server, one stop: POST /shutdown still ends the JVM.
- `application.yaml` — `management.endpoints.web.exposure.include: health`: the endpoints that answer, written down.
- `.gitignore` — `*.hprof`: a heap dump holds the shutdown token (below), so none is ever committed.

**The starter alone reaches nothing.** Boot's HTTP side of Actuator waits for a web application it knows — Spring MVC or WebFlux,
on Tomcat, Jetty or Netty (Course 6). TiffinBox's server is the JDK's own, so to Boot TiffinBox is no web application (`NONE`).
Measured with the starter and nothing else: 59 bean definitions become 134 and 10 auto-configuration classes 31, one endpoint bean
exists (`health`) — and no bean hands it to HTTP or to JMX: `/actuator/health` gets TiffinBox's own server's 404 (`No context found
for request`). Boot's condition report (`--debug`) says why, in Boot's words: `WebEndpointAutoConfiguration` —
`@ConditionalOnWebApplication did not find reactive or servlet web application classes`; `JmxEndpointAutoConfiguration` — `did not
find property 'spring.jmx.enabled'`; `HealthEndpointWebExtensionConfiguration` — `did not find servlet web application classes`.
JMX switched on carries health and, with every endpoint exposed, 11 MBeans — never `heapdump`, `logfile` or `prometheus`, whose
classes are `@WebEndpoint`s. Spring MVC on Tomcat makes TiffinBox the web application Boot waits for: 12 more jars and a second
server in the JVM, which keeps running after TiffinBox's POST /shutdown until it is killed — Course 6's road.

**So TiffinBox serves the endpoints itself** — `ActuatorRoutes`, from Boot's own parts. An endpoint is a bean with operations, HTTP
is one adapter, and exposure is a filter:
- `webEndpointDiscoverer` — Boot's own `WebEndpointDiscoverer`, the class Spring MVC's Actuator adapter reads, through two filters:
  exposure (`management.endpoints.web.exposure.*`, `health` unless told otherwise) and access (`management.endpoint.<id>.access`). It
  is a bean: Spring's AOT step reads its class's hints (`@ImportRuntimeHints`) from beans, and the native binary needs them.
- `healthEndpointWebExtension` — Boot's `HealthEndpointWebExtension`: health over HTTP, its groups, no details unless asked for.
  `@ConditionalOnAvailableEndpoint(endpoint = HealthEndpoint.class)` keeps it out while health is not exposed.
- `actuatorHandler` — the `HttpHandler` for `/actuator`: it matches the request's path and verb to an operation (`health`,
  `health/{*path}`, `loggers/{name}`, …), passes the path's variables, a JSON body and the `Accept` header, invokes the operation and
  writes its answer with TiffinBox's own Jackson (version 2) — 404 for a path no operation has, 405 for a path without that verb, and
  500 for an `Exception` or a `LinkageError` (a missing class, or a native binary's missing hint).

In a Spring MVC application Boot writes this adapter for you; TiffinBox's server is its own, so it writes it here.

```bash
mvn -B package
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/liveness
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/readiness
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/actuator/env
```

Measured: `{"status":"UP","groups":["liveness","readiness"]}` 200 for health, `{"status":"UP"}` 200 for each group, 404 for env (not
exposed), 405 for a POST to health; TiffinBox listens on its one address, and POST /shutdown ends the JVM, exit 0. Ask readiness
until it answers 200 before anything else: TiffinBox's own routes answer earlier (the next unit). The starter makes the jar's start
longer — on an Apple M1, by under a quarter, from the process's start to its first answer, the middle of five runs.

**Exposure is a list, and each endpoint costs what it hands over.** Widen it for one run, with a flag, on the JVM:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,env
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/env/tiffinbox.shutdown-token
```

- `env` masks every value (`******`) but lists the name of every environment variable and every system property, and the config
  tree's property source names its folder's absolute path. `--management.endpoint.env.show-values=when-authorized` still masks (no
  Spring Security here: Course 10); `=always` prints the shutdown token in clear. Never `always`.
- `beans` lists every bean (153 with every endpoint exposed) and where each was read from — for TiffinBox's own, the jar's absolute
  path. `conditions` is the condition report. `mappings` is empty: TiffinBox's routes are not Spring MVC's (Course 6 lists them).
- `heapdump` has access NONE by default: exposed, it still answers 404. Switched on for one run, it hands over a copy of the JVM's
  memory, over 20 MB, with 3 copies of the shutdown token in it — `rm heap.hprof` at once (`.gitignore` keeps it out of a
  commit):

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,heapdump --management.endpoint.heapdump.access=read-only
curl -s -o heap.hprof -w '%{http_code}\n' http://127.0.0.1:18431/actuator/heapdump
```

- Every endpoint at once stops the start — exit 1, `NoClassDefFoundError: com/fasterxml/jackson/datatype/jsr310/JavaTimeModule`,
  for the `configprops` endpoint, which needs Jackson 2's time module; TiffinBox's Jackson 2 does not carry it, and Boot has no
  failure analysis for it:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include='*'
```

  With configprops excluded it starts, and 11 of the 19 endpoints the jars declare answer:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include='*' --management.endpoints.web.exposure.exclude=configprops
```

So the list in `application.yaml` stays `health`, Boot's own default, written down so that widening it is a line someone reviews;
what to expose in production, and how to secure it, is Course 18's.

**AOT and the native binary.** Spring's AOT step (the profile `native`) reads Maven's class path, not the jar's — and there the
optional Compose module brings Jackson 3. Without the plugin's excludes it generated Actuator's Jackson 3 configuration
(`JacksonEndpointAutoConfiguration__BeanDefinitions`), and the AOT jar — `java -Dspring.aot.enabled=true -jar …`, unit 19's line —
stopped at start after TiffinBox's server had opened its port: `NoClassDefFoundError: tools/jackson/databind/json/JsonMapper`, exit 1,
while the same jar run without AOT served. With the excludes, the AOT jar and the native binary (unit 19's four lines) serve the
seven and `/actuator/health`. **Under AOT, and in the binary, the exposure list is the one built in:** a
`--management.endpoints.web.exposure.include` given at run time adds nothing there (env stays 404); change `application.yaml` and
build again. Evidence in `../c5-unit21/`.

## Course 5 · unit 22 — the kitchen joins readiness (2026-10-07)

One file is new and one changed. The seven responses are the same before and after
(`115c36bac276128e245ca57df11c2891`), and so are `ActuatorRoutes.java`, `TiffinBoxServer.java` and `TiffinBoxApp.java`:
- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java` — **new**: a `HealthIndicator` bean, one more
  component of `/actuator/health`. Boot names the component after the bean, `HealthIndicator` left off: **`kitchen`**. UP while
  the database answers — with the customers it holds and the orders the kitchen cooked — and DOWN, with the error's class name,
  when it does not.
- `application.yaml` — **`management.endpoint.health.group.readiness.include: readinessState,kitchen`**: the kitchen joins the
  readiness group, beside Boot's own readiness state; liveness stays Boot's liveness state alone.

**Health is components and groups.** Each component is a health indicator, a bean that answers UP or DOWN; `/actuator/health`
answers with the worst of them — 503 for DOWN or OUT_OF_SERVICE, 200 otherwise — and hides which ones there are. Shown by a flag,
the anchor as unit 21 left it had five: `diskSpace`, `livenessState`, `ping`, `readinessState`, `ssl`. A group is a named subset
with its own path: Boot 4.1 makes two by default, **liveness** (`livenessState`: should a platform restart this process?) and
**readiness** (`readinessState`: should it send this process traffic?). A probe is a platform — Kubernetes, Course 18 — asking
one of those paths on a timer. Boot's own two groups show no components, even with the flag below; a group you define — as
`application.yaml` now defines readiness — shows them. Before this change a dead database left health UP: nothing in it touched
the database.

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.show-components=always
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health/kitchen
```

Measured: six components now, `kitchen` among them, UP; `/actuator/health/kitchen` answers `{"status":"UP"}` 200 — and 404
without the flag: a component's own path exists only while components are shown. Its details, by a second flag:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.show-details=always
```

`/actuator/health/kitchen` → status UP, details `{"customers":4,"ordersCooked":120}` (the bridge writes an answer's keys in the order
reflection lists them, which has moved between runs: compare keys, not text). Ask the kitchen alone with that flag:
`/actuator/health` itself would show the disk's sizes and the folder TiffinBox runs in.

**Answered is not ready.** TiffinBox's server opens in `@PostConstruct`, during the refresh: polled from the moment the process
starts, `/kitchen` answered 200 at least once while liveness and readiness both answered 503. Boot publishes liveness
(`CORRECT`) after the refresh and readiness (`ACCEPTING_TRAFFIC`) after the runners. Wait for readiness, never for the port.

**When the database dies** (unit 22's harness closes it once TiffinBox is ready): `/actuator/health` 503, `kitchen` DOWN with
`{"error":"JdbcSQLSyntaxErrorException"}` — H2 opens a new, empty in-memory database under the same URL, so the table is gone —
liveness 200, **readiness 503**; `/customers` 500; `/kitchen` 200, from memory. A platform stops sending this process traffic and
does not restart it: a restart cannot bring a database back. Without the kitchen in readiness — the line below — readiness says 200
and traffic keeps arriving at a TiffinBox that answers 500:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.group.readiness.include=readinessState
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers
```

The trade: every TiffinBox that shares one database leaves rotation together when it blinks — when that is worth it is Course 18's.

**Readiness by hand** (`AvailabilityChangeEvent.publish(context, ReadinessState.REFUSING_TRAFFIC)`) counts only after Boot's own
`ACCEPTING_TRAFFIC`: published from a runner it is overwritten (readiness 200); published after it, readiness answers
`{"status":"OUT_OF_SERVICE"}` 503. On SIGTERM TiffinBox's context closes and publishes no state (exit 143).

**Switching the groups off** — `management.endpoint.health.probes.enabled`, true by default — now stops the start: the readiness
group names `readinessState`, which exists only while probes are on, and Boot says so (`Health contributor 'readinessState'
defined in 'management.endpoint.health.group.readiness.include' does not exist`). Not `management.health.probes.enabled`:
deprecated since 2.3.2 at level `error`, it changes nothing.

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoint.health.probes.enabled=false
```

The AOT jar and the native binary (unit 19's lines) report the kitchen UP and readiness 200, and serve the seven. Evidence in
`../c5-unit22/`.

## Course 5 · unit 23 — the kitchen's count and every answer's time, scraped (2026-10-07)

One file is new and four changed. The seven responses are the same before and after (`115c36bac276128e245ca57df11c2891`);
`tiffinbox-core`, `TiffinBoxApp.java` and `KitchenHealthIndicator.java` are not touched:
- `tiffinbox-web/pom.xml` — **`io.micrometer:micrometer-registry-prometheus`**, its version Boot's parent's (1.17.1). The executable
  jar's `BOOT-INF/lib` goes from 39 jars to 46: the registry and six `prometheus-metrics-*` jars (the Prometheus client, 1.7.0).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java` — **new**: a `MeterBinder` bean that registers two
  `FunctionCounter`s, `tiffinbox.orders.cooked` and `tiffinbox.orders.value`, over `OrderQueue::cooked` and `::cookedValue` — read
  when the registry is read, so the kitchen keeps its own count and `tiffinbox-core` gains no dependency. Its one hint,
  `@RegisterReflection` of `com.sun.management.OperatingSystemMXBean`'s public methods, is for the native binary (below).
- `TiffinBoxServer.java` — a `MeterRegistry` constructor parameter, and a timer around `handle()`: **`tiffinbox.requests`**, tagged
  `route` — the route TiffinBox declares (`GET /customers`), or `UNKNOWN` for a verb no route declares — and `status`.
- `ActuatorRoutes.java` — one line: a `byte[]` answer is written as it is. Boot hands the scrape over as bytes, and the bridge
  wrote them as JSON — a quoted base64 string, with Prometheus's content type.
- `application.yaml` — **`management.endpoints.web.exposure.include: health,prometheus`**.

**A meter** is one named measurement; a **registry** keeps them. Actuator's starter brought Micrometer with a registry that keeps
them in memory, `SimpleMeterRegistry`: JVM, process, system, Logback, disk, executor and application meters, and
`/actuator/prometheus` 404 even when exposed by a flag — the endpoint exists only beside Prometheus's registry. No `http.server.*` meter either, even after
a request: TiffinBox's server is the JDK's, and nothing in Boot times it. With the registry, `/actuator/prometheus` answers in
the text a Prometheus server reads when it **scrapes** — pulls the page on a timer, over HTTP:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/actuator/prometheus
curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' -H 'Accept: application/openmetrics-text; version=1.0.0' http://127.0.0.1:18431/actuator/prometheus
```

Measured: `200 text/plain;version=0.0.4;charset=utf-8`; `# HELP`, `# TYPE tiffinbox_orders_cooked_total counter`,
`tiffinbox_orders_cooked_total 120.0` and `tiffinbox_orders_value_total 24300.0` — the dots of a meter's name become underscores,
and a counter gains `_total`. Asked for OpenMetrics: `200 application/openmetrics-text;version=1.0.0;charset=utf-8`, the family
named `tiffinbox_orders_cooked` (the sample keeps `_total`), and the last line `# EOF`. A scrape holds this computer's own
numbers — memory, threads, the disk and the folder TiffinBox runs in — so the file stays on your machine. The two counters are
`/kitchen`'s numbers (`{"ordersCooked":120,"ordersValue":24300}`), with the default 30 days; with `--tiffinbox.days=10`, 40 and
8100:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --tiffinbox.days=10
```

**The timer** appears with its first answer: a `summary` — `tiffinbox_requests_seconds_count` and `_sum` per route and status, in
seconds — and a gauge, `tiffinbox_requests_seconds_max`. After `/customers`, `/revenue`, `/dashboard`, `/kitchen`, `/nowhere`,
`GET /shutdown` and a `POST /shutdown` without the token: one series each for the four routes (200), `UNKNOWN` 405 and
`POST /shutdown` 403; `/nowhere` is not timed — the JDK server's own 404, before any handler of TiffinBox's.

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/customers/7
curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/shutdown
```

**The route tag holds a route, never a URL.** The JDK server matches a context by prefix: `/customers/7`, `/customers/8` and
`/customersXYZ` all reach the `/customers` route (and answer the customer list — a router quirk, path patterns are Course 6's),
and all four count under one series, `route="GET /customers"`, `4`. A copy whose tag holds the raw path keeps one series per
URL a client types — every one of them kept, and scraped, from then on.

**Actuator's other metrics endpoints, by flag** — the registry's class and the meters' names:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,metrics,beans
curl -s -o metrics.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/metrics
curl -s -o beans.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/beans
curl -s -o metrics.json -w '%{http_code}\n' 'http://127.0.0.1:18431/actuator/metrics/tiffinbox.requests?tag=status:405'
```

`prometheusMeterRegistry`, a `PrometheusMeterRegistry`. **The bridge passes no query string:** `?tag=status:405` reaches no
endpoint, and the answer is the whole meter's — read a tag's series in the scrape.

**The native binary needs one hint.** Micrometer's processor meters call the JDK's operating-system bean through
`com.sun.management.OperatingSystemMXBean`, by reflection, and Micrometer's own native-image metadata lists three of that
interface's methods — not `getProcessCpuTime()`, which its CPU-time meter (`process.cpu.time`) calls. Without the hint the binary's
scrape answers `{"error":"MissingReflectionRegistrationError"}` 500; the same binary with the CPU-time meter switched off answers
200, without `process_cpu_time_ns_total`:

```bash
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --management.metrics.enable.process.cpu.time=false
```

With the hint, 200 and every meter. `com.sun.management.UnixOperatingSystemMXBean` in its place answers 200 too: it inherits the
method, and the hint registers an interface's public methods, inherited ones included. The AOT jar and the binary
serve the seven and the scrape. Evidence in `../c5-unit23/`.

## Course 5 · unit 24 — one line per answer, and a level changed while it runs (2026-10-07)

Two files changed, and three things of Course 3's retired. The seven responses are the same before and after
(`115c36bac276128e245ca57df11c2891`); `tiffinbox-core`, `TiffinBoxApp.java`, `ActuatorRoutes.java`, `KitchenHealthIndicator.java`
and `KitchenMetrics.java` are not touched. The two Java logging files of Course 3 and the exec plugin's argument that named one
are deleted (below):
- `TiffinBoxServer.java` — `handle()`'s `finally` logs **one line per answer at DEBUG**, through TiffinBox's own `System.Logger`
  (`tiffinbox`): the route and the status, `GET /customers -> 200` — the two values the timer tags (`UNKNOWN -> 405` for a verb no
  route declares). Never a header, never the token, never what the client typed. Silent at INFO, Boot's default. The line is
  written before the timer stops, so once a scrape counts an answer, that answer's line has been decided.
- `application.yaml` — **`logging.group.kitchen: tiffinbox, com.tiffinbox`**: a log group, one name for TiffinBox's own logger
  and the loggers under `com.tiffinbox` — Boot logs TiffinBox's startup under its main class's name,
  `com.tiffinbox.web.TiffinBoxServer`.

**One line's road.** `System.Logger` hands a line to `java.util.logging`; on its root logger Boot installed one handler,
`org.slf4j.bridge.SLF4JBridgeHandler`, which hands it to Logback, whose root logger writes through one appender, `CONSOLE`.
Logback's `LevelChangePropagator`, a listener Boot adds, copies every level set in Logback back to `java.util.logging`: DEBUG
there is FINE here, so `System.Logger`'s DEBUG check answers yes.

**At start**, Boot's property — on TiffinBox's own logger (the first lesson's), or on the group:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.tiffinbox=debug
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug
```

The group prints five `route` lines at start, Spring's `Running with Spring Boot v4.1.1, Spring v7.0.9` (logged under
`com.tiffinbox.web.TiffinBoxServer`), and one line per answer: the seven requests add six (`/nowhere` is the JDK server's own
404, never `handle()`'s).

**While it runs**, through Actuator's `loggers` endpoint — exposed by a flag, for one run, never in `application.yaml`: it is a
write on the app's own port, and anyone who reaches the port can call it:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers
curl -s -o loggers.json -w '%{http_code}\n' http://127.0.0.1:18431/actuator/loggers
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/loggers/kitchen
curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:18431/actuator/loggers/kitchen
curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":null}' http://127.0.0.1:18431/actuator/loggers/kitchen
```

Measured on one process: three requests at INFO, 0 lines; the POST, `204`; three more, 3 lines; `null`, `204`; three more,
still 3. **`null` is not a clean reset:** Logback's propagator copies the level `tiffinbox` falls back to, INFO, into
`java.util.logging`, and it stays there. A later POST to the root (`…/loggers/ROOT`, DEBUG) makes Actuator report `tiffinbox` at
DEBUG while TiffinBox prints nothing; on a process where the group was never set, the same root POST prints the line. `loggers.json` lists every logger, Boot's groups `web` and `sql` beside `kitchen`, and the levels; it names only
loggers, but it is long — read it through a filter. **Locked**, the way a production run would keep it:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers --management.endpoint.loggers.access=read-only
```

The POST answers `405`, and the level stays. **The bridge reads any body as JSON:** the same POST without `Content-Type`
answers `204` here — the bridge never looks at the content type — and a POST with no body at all sets the group back to `null`:

```bash
curl -s -w ' %{http_code}\n' -X POST -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:18431/actuator/loggers/kitchen
curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:18431/actuator/loggers/kitchen
```

**A group and one of its members, both set:** while it runs, the last write wins for each logger, and the group's own answer
keeps the level last set on the group; at start, in either order on the command line, the group won. Set one or the other:

```bash
curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"INFO"}' http://127.0.0.1:18431/actuator/loggers/tiffinbox
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug --logging.level.tiffinbox=info
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.tiffinbox=info --logging.level.kitchen=debug
```

**The name decides, not the package.** TiffinBox's logger is `tiffinbox` (Course 2's `System.getLogger("tiffinbox")`):
`com.tiffinbox` alone at DEBUG prints Spring's one line about TiffinBox and 0 lines per answer:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.com.tiffinbox=debug
```

**Boot's own groups are silent here.** `web` (5 members) and `sql` (3) name Spring's web loggers — the bridge's endpoint
package among them — and three SQL libraries' (Spring's JDBC, Hibernate, jOOQ); each at DEBUG prints 0 DEBUG lines over the seven:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.web=debug
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.sql=debug
```

**At TRACE, still no token.** With every logger at TRACE, the seven requests — the last one carrying `X-Shutdown-Token` —
print their six lines, and the log holds the token 0 times and the header's name 0 times:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.root=trace
```

**Retired here: the Java logging files of Course 3.** `tiffinbox-web/logging.properties`, `logging-debug.properties` and the
exec plugin's `-Djava.util.logging.config.file=logging.properties` are deleted in this lesson, measured first on the previous
tree, which still ships them (`../c5-unit24/`, `files`). Under Boot they changed nothing: `java.util.logging` read the file it was
given (its `.level = FINE`), then Boot replaced the root logger's handler with its bridge and set its level from Logback — 0
DEBUG lines, 0 lines on standard error, 0 lines in the file's bare format; the exec plugin's run printed Logback's lines. The line
that measured the debug file, on that tree:

```bash
java -Djava.util.logging.config.file=tiffinbox-web/logging-debug.properties -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

The exec plugin stays, with its `-classpath … TiffinBoxServer` arguments: Course 3's two lines (below) still start TiffinBox, now
without a logging file. **In the AOT jar and the native binary** the exposure list is the one they were
built with: `loggers` by flag answers 404, so a level changes only at start — `--logging.level.kitchen=debug` works in both:

```bash
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --logging.level.kitchen=debug
tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,loggers
```

A copy built with `loggers` in `application.yaml`'s list switches live under AOT. Evidence in `../c5-unit24/`.

---

## Course 5 · unit 26 — TiffinBox's port failure explained to Boot, and a 500 for a missing class (2026-10-07)

Two files added, two changed. The seven responses are the same before and after (`115c36bac276128e245ca57df11c2891`);
`tiffinbox-core`, `TiffinBoxApp.java`, `KitchenHealthIndicator.java`, `KitchenMetrics.java`, `Route.java`, `application.yaml` and
the POMs are not touched:
- `PortTakenFailureAnalyzer.java` (new) — a **failure analyzer**: a class Boot asks, when the start fails, whether it recognises
  the failure; the first that does prints a description and an action instead of the stack trace. This one recognises one
  failure: a `java.net.BindException` whose message is `Address already in use`, thrown by the bind `TiffinBoxServer`'s `start`
  makes (that method on the exception's stack) — something else already listens on TiffinBox's port — and says where TiffinBox
  tried to listen, read from the `Environment` Boot hands its constructor: `tiffinbox.address` and `tiffinbox.port`, never another
  setting. Any other `BindException` — an address this machine does not have, another bean's port — gets `null`: Boot prints the
  trace, as it did before.
- `tiffinbox-web/src/main/resources/META-INF/spring.factories` (new) — one line,
  `org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.PortTakenFailureAnalyzer`. Boot reads its analyzers
  from this file of names, never from the context: the same class as a `@Component` changes nothing.
- `TiffinBoxServer.java` — `handle()`'s catch around a route is **`catch (Exception | LinkageError e)`**, and it logs the error
  at ERROR, with its trace, under the route's name (`GET /customers failed`): a route that needs a class the class path or the
  native binary does not hold answers `500`, and the answer is logged and timed like any other. Caught as an `Exception` only, the
  error left `handle()`, the request's thread died and the client never got an answer — the hints lesson's hang — and at INFO the
  log said nothing. An `OutOfMemoryError` or a `StackOverflowError` is still not caught.
- `ActuatorRoutes.java` — its catch, already `Exception | LinkageError`, logs at ERROR too: a `LinkageError` with its trace, any
  other failure by its class alone (`an actuator request failed: com.fasterxml.jackson.core.JsonParseException`) — an exception's
  message can quote what the client sent, a body or a level, and the log never holds what a client typed.

**Port taken.** Start TiffinBox twice on one port:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
```

The second exits 1 with two sentences and no stack trace — `TiffinBox could not listen on 127.0.0.1:18431: something else
already listens there.` and `Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.` Before
this change it printed 40 stack frames and no analysis: Boot's own port analyzer, `PortInUseFailureAnalyzer`, lives in
`spring-boot-web-server`, for Boot's own web servers, and it only knows Boot's own `PortInUseException`; TiffinBox's server is
the JDK's. An address this machine does not have is not a taken port — the trace, and `Can't assign requested address`:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --tiffinbox.address=192.0.2.1
```

The analysis for the taken port comes from the AOT jar and from the native binary too. **The trace is still there**, with Boot's
condition report, under `--debug`:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --debug
```

**Boot's own analyzers** — 21 in the jars TiffinBox ships (`spring-boot` 18, `spring-boot-autoconfigure` 2,
`spring-boot-micrometer-metrics` 1) — explain a missing bean, a failed validation, a missing import file, a cycle and a malformed
value, among others. A malformed value's analysis prints the value it could not convert — fine for a port, never for a secret:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=nineteen
```

**A cycle stops the start under Boot.** Boot's `spring.main.allow-circular-references` defaults to `false` (Course 4's plain
Spring container allowed one): two beans that need each other through setters stop the start, and the analysis draws the cycle.
The switch is the last resort Boot's action names, never this project's setting; the cure is a third object both of them want:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.main.allow-circular-references=true
```

**After the start, no analyzer runs.** To see a missing class answer `500`, delete one class jackson-databind needs for a record,
`JDK14Util`, from a copy of the extracted jar's `lib/`, with the thin jar copied beside it — its `Class-Path` names `lib/`, so it
reads the copy — all under `target/`:

```bash
rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib
zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'
java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug
curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:18431/customers
```

`/customers` answers `{"error":"ClassNotFoundException"} 500`, and the log's line says `GET /customers -> 500`. Before this
change curl gave up after 5 seconds, while the log said `GET /customers -> -1` and the timer counted an answer no client received.
**At INFO, Boot's default, the error is in the log:** `GET /customers failed`, at ERROR, then
`java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util` and its trace (before this change: nothing at
all). The bridge's catch logs too: Actuator's `sbom` endpoint, exposed for this one run, needs the same class — `an actuator
request failed`, with the trace; a request body the bridge cannot read is logged by its class alone, and the body's words appear
0 times in the log:

```bash
java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,sbom
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/sbom
curl -s -X GET -d 'oops, not json' -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/health
```

In the native binary, the hints lesson's break (the route annotation's `@Reflective` deleted) answers
`{"error":"MissingReflectionRegistrationError"} 500` instead of nothing. Evidence in `../c5-unit26/`.

---

# c3-tiffinbox — TiffinBox, split into modules

The long-lived project of **Build & Test Like a Pro**. It starts as the Core Java II capstone
(`../c2-capstone/`) cut into three POMs, and every later unit in the course changes it: Gradle
scripts beside these POMs, a test source tree, a logging configuration, a workflow file, a
native-image profile.

```
c3-tiffinbox/
  pom.xml                 com.tiffinbox:tiffinbox-parent:1.0.0   <packaging>pom</packaging> — builds nothing
  tiffinbox-core/         com.tiffinbox        Customer · Database · CustomerRepository · OrderQueue · Dashboard
  tiffinbox-web/          com.tiffinbox.web    Route · TiffinBoxServer · logging.properties
```

**The rule that decides which class goes where: core knows nothing about HTTP, web knows
nothing about SQL.** Not a claim — `grep` it:

```bash
grep -rl "com.sun.net.httpserver" tiffinbox-*/src
grep -rl "java.sql" tiffinbox-*/src
```

```
tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
tiffinbox-core/src/main/java/com/tiffinbox/Database.java
```

## What changed from the capstone, and why

| | `c2-capstone` | `c3-tiffinbox` |
|---|---|---|
| modules | 1 | **3** — parent (pom) + core + web |
| packages | `com.tiffinbox` | `com.tiffinbox` (core) · **`com.tiffinbox.web`** (web) |
| `Dashboard.load()` | `StructuredTaskScope.open(…)` — **preview** | **`ExecutorService.invokeAll`** — no preview |
| compile | `--release 25 --enable-preview` | `--release 25` |
| run | `java --enable-preview -jar …` | **`java -jar …`** |
| `target/lib` | 4 jars | **5** — the four, plus `tiffinbox-core-1.0.0.jar` |
| `Main-Class` | `com.tiffinbox.TiffinBoxServer` | `com.tiffinbox.web.TiffinBoxServer` |

**Two decisions, both deliberate.**

1. **The preview flag came out.** `StructuredTaskScope` is a preview API in JDK 25 (JEP 505),
   so it needs `--enable-preview` at compile time *and* at run time, which pins the project to
   one exact JDK. This build has to run on more than one. Nothing was wrong with the original —
   Course 2's capstone still uses it, unchanged — this is the build making a trade, and the
   trade is named. The proof it is faithful is below.
2. **The web classes moved to `com.tiffinbox.web`.** Two jars must not share a package. A
   *split package* is legal on the classpath and refused outright by the module system, and it
   would be inherited by everything this course does later. It cost one `package` line and five
   imports.

## Requirements

JDK **25 or newer** and Maven **3.9 or newer**. On a Mac with more than one JDK installed,
Maven uses the one `JAVA_HOME` names — and with `JAVA_HOME` unset it takes whatever `java` is
first on the path, which here is a different JDK entirely. So **every command below starts with
the export**:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -version           # Java version: 25.0.4.1
```

The first build downloads H2 2.5.250 and Jackson 2.22.2 from Maven Central; after that,
nothing.

## Build

> **Stale since Course 5, unit 13.** Web's build no longer runs `copy-dependencies`, its jar's manifest has no
> `Class-Path`, and there is no `tiffinbox-web/target/lib/`: the jar is Boot's executable jar (unit 13's section at the
> top). The manifest and the `lib/` listing below are Course 3's, kept as they were written.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B clean package
```

Sixteen goals run: one for the parent (`clean` — that is all a `pom` module has to do),
seven for core, and eight for web, the extra one being `copy-dependencies`. The last block is
the reactor summary, in dependency order:

```
[INFO] Reactor Summary for TiffinBox 1.0.0:
[INFO]
[INFO] TiffinBox .......................................... SUCCESS [  n.nnn s]
[INFO] TiffinBox Core ..................................... SUCCESS [  n.nnn s]
[INFO] TiffinBox Web ...................................... SUCCESS [  n.nnn s]
[INFO] BUILD SUCCESS
```

The `[ n.nnn s]` column moves on every run and is the one thing on that block you must never
quote as a fact.

Read the manifest the build wrote:

```bash
unzip -p tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF
```

```
Class-Path: lib/tiffinbox-core-1.0.0.jar lib/h2-2.5.250.jar lib/jackson-
 databind-2.22.2.jar lib/jackson-annotations-2.22.jar lib/jackson-core-2
 .22.2.jar
Main-Class: com.tiffinbox.web.TiffinBoxServer
```

```bash
ls tiffinbox-web/target/lib
```

```
h2-2.5.250.jar
jackson-annotations-2.22.jar
jackson-core-2.22.2.jar
jackson-databind-2.22.2.jar
tiffinbox-core-1.0.0.jar
```

`tiffinbox-core-1.0.0.jar` is in there because `copy-dependencies` does not care that it came
from the module next door: to `tiffinbox-web`, core is a dependency like any other.

## Run

> **Stale under Boot (Course 5, unit 01 measured it).** Since Spring Boot arrived, Boot's logging system owns
> `java.util.logging`: the `-Djava.util.logging.config.file=…` flag below no longer sets any level (the debug file's
> five `route` lines go 5 → 0, silently; see `../c5-unit01/` → `.r-logging.out`). Boot's way is a property:
> `java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.tiffinbox=debug`
> (the port as a flag since Course 5 unit 06, which measured this command: 5 route lines). The rest of this section is
> Course 3's text, kept as it was written — including "pass another as the first argument", which since unit 06 is
> silently ignored (the server listens on 18425). **Since Course 5 unit 24, `logging.properties`, `logging-debug.properties` and
> the exec plugin's `-D` argument are deleted:** the lines below that name them are history; `exec:exec` still starts TiffinBox.

**No `--enable-preview`.** That is the whole point of the swap.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd tiffinbox-web
java -Djava.util.logging.config.file=logging.properties -jar target/tiffinbox-web-1.0.0.jar
```

```
orders cooked:  120
kitchen value:  24300
routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
TiffinBox listening on http://127.0.0.1:18425
```

`-Djava.util.logging.config.file=` is not decoration: `logging.properties` pins
`SimpleFormatter.format = %5$s%n`, and without it the JDK stamps a date and the calling method
on every line. The server binds `127.0.0.1` explicitly, so it is reachable from this machine
and from nowhere else.

`tiffinbox-web/pom.xml` still carries `exec-maven-plugin`, and it no longer has to pass a
preview flag — but starting a module of a multi-module project through Maven needs the sibling
jar in a repository first, so it is **two** commands, not one:

```bash
mvn -B clean install                        # tiffinbox-core lands in your local repository
mvn -q -B -pl tiffinbox-web exec:exec
```

Without `-pl` the goal is asked of the parent too, which has no `<executable>` and fails with
`The parameter 'executable' is missing or invalid`; without the `install` the reactor cannot
find `tiffinbox-core`. Both of those are the local repository's doing, and the repository is a
subject of its own later on — which is why `java -jar` above is the command this project uses.

The port is `18425`; pass another as the first argument:
`java -jar target/tiffinbox-web-1.0.0.jar 9090`.

Then, in a second shell:

```bash
curl -s http://127.0.0.1:18425/customers
curl -s http://127.0.0.1:18425/dashboard
curl -s http://127.0.0.1:18425/kitchen
curl -s http://127.0.0.1:18425/revenue
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18425/pauses    # 404 — no such route
curl -s -w ' %{http_code}\n' http://127.0.0.1:18425/shutdown              # 405 — wrong verb
```

```json
[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
{"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
{"ordersCooked":120,"ordersValue":24300}
{"monthRevenue":24300}
404
{"error":"method not allowed"} 405
```

## Stopping it

> **Stale since Course 5, unit 11:** POST /shutdown now answers 403 unless it carries the token in an
> `X-Shutdown-Token` header — see that unit's section at the top of this README for the command. The line below is
> Course 3's, kept as it was written.

```bash
curl -s -X POST http://127.0.0.1:18425/shutdown     # -> {"stopping":true}
```

The JVM exits on its own a moment later; the database is in memory, so nothing is left on
disk. If a run was killed hard and the port is stuck,
`lsof -nP -iTCP:18425 -sTCP:LISTEN` names the process.

## The receipt: the split changed nothing observable

Both projects were started, asked the same seven questions (four routes, a 404, a 405, and
`POST /shutdown`), and shut down — **three runs of `c2-capstone` and three of `c3-tiffinbox`,
six captures, one hash**:

```
md5  d6402e7c500031cb39addba72cb846e5     6 of 6
diff c2-capstone-run.txt c3-tiffinbox-run.txt     (empty)
```

The class file is where you can see the flag actually leave. Same major version, different
minor:

```bash
javap -v -cp tiffinbox-core/target/classes com.tiffinbox.Dashboard | grep -E 'major|minor'
```

| | minor | major |
|---|---|---|
| `c2-capstone` `Dashboard.class` | **65535** — the preview bit | 69 |
| `c3-tiffinbox` `Dashboard.class` | **0** | 69 |

`65535` is why the capstone's jar cannot start without the flag:
`UnsupportedClassVersionError: Preview features are not enabled for com/tiffinbox/Dashboard
(class file version 69.65535)`. This project's jar has nothing to enable.

## Versions live in exactly one place

The parent's `<dependencyManagement>` decides `tiffinbox-core`, `h2` and `jackson-databind`;
its `<pluginManagement>` decides the four plugin versions. **No child POM contains a
`<version>` for a dependency or a plugin.** Check it:

```bash
mvn -B dependency:tree
```

```
[INFO] com.tiffinbox:tiffinbox-parent:pom:1.0.0
[INFO] com.tiffinbox:tiffinbox-core:jar:1.0.0
[INFO] \- com.h2database:h2:jar:2.5.250:compile
[INFO] com.tiffinbox:tiffinbox-web:jar:1.0.0
[INFO] +- com.tiffinbox:tiffinbox-core:jar:1.0.0:compile
[INFO] |  \- com.h2database:h2:jar:2.5.250:compile
[INFO] \- com.fasterxml.jackson.core:jackson-databind:jar:2.22.2:compile
[INFO]    +- com.fasterxml.jackson.core:jackson-annotations:jar:2.22:compile
[INFO]    \- com.fasterxml.jackson.core:jackson-core:jar:2.22.2:compile
```

**Run that on the whole project, never with `-pl`.** With `-pl tiffinbox-web`, Maven cannot
read the sibling's POM, so it draws `tiffinbox-core` as a leaf — **h2 disappears from the
picture** — prints one `[WARNING]` above the tree and then `BUILD SUCCESS`, exit 0:

```
[WARNING] The POM for com.tiffinbox:tiffinbox-core:jar:1.0.0 is missing, no dependency information available
[INFO] com.tiffinbox:tiffinbox-web:jar:1.0.0
[INFO] +- com.tiffinbox:tiffinbox-core:jar:1.0.0:compile
[INFO] \- com.fasterxml.jackson.core:jackson-databind:jar:2.22.2:compile
[INFO]    +- com.fasterxml.jackson.core:jackson-annotations:jar:2.22:compile
[INFO]    \- com.fasterxml.jackson.core:jackson-core:jar:2.22.2:compile
```

Jackson's own two children are still drawn — it is `tiffinbox-core` that goes flat, taking **h2** with it.

## Building part of it

| Command | Modules *built* | Result |
|---|---|---|
| `mvn -B clean package` | **3** | `BUILD SUCCESS` |
| `mvn -B clean package -pl tiffinbox-core` | **1** — *and no reactor summary is printed at all, which is why a summary-row counter reads zero here* | `BUILD SUCCESS` |
| `mvn -B clean package -pl tiffinbox-web` | **1** | **`BUILD FAILURE`**, exit 1 |
| `mvn -B clean package -pl tiffinbox-web -am` | **3** | `BUILD SUCCESS` |

`-pl` picks modules; `-am` *also makes* what they depend on. Without it:

```
[ERROR] Failed to execute goal on project tiffinbox-web: Could not resolve dependencies for project com.tiffinbox:tiffinbox-web:jar:1.0.0
[ERROR] dependency: com.tiffinbox:tiffinbox-core:jar:1.0.0 (compile)
[ERROR] 	Could not find artifact com.tiffinbox:tiffinbox-core:jar:1.0.0 in central (https://repo.maven.apache.org/maven2)
```

With only two jar modules, `-pl tiffinbox-web -am` **is** the whole build — measured, the
filtered capture of the two commands has the same md5. It starts paying the day there are nine
modules.

## Verified

Built and run on **JDK 25.0.4.1** (`/opt/homebrew/opt/openjdk@25`) with **Maven 3.9.16**,
macOS on Apple silicon, **2026-09-14**, from a clean copy outside the repository, with an
isolated local repository (`-Dmaven.repo.local=`) so nothing of ours reaches `~/.m2`.
Offline receipt after one warm build: `mvn -o -B verify` → `BUILD SUCCESS`, exit 0, three runs.


---

## Course 4 starts here (added 2026-09-16, Section 1 · The Container)

This directory is **the Course 3 line of TiffinBox, carried forward byte-identically** — it was
created by copying `c3-tiffinbox/`, which is frozen and read only. The five carried sources
still hash to `fdb1643d622615f3c331d75deaebb9da` here, as they do in every unit folder that
holds them.

**One thing had to be carried from somewhere else, and it is worth writing down:**
`Wiring.java` is *not* in `c3-tiffinbox/`. It lives in the previous course's final unit folder,
`c3-unit28/src/main/java/com/tiffinbox/wiring/Wiring.java`. It has been copied here into
`tiffinbox-core`, byte-identical, so that the ledger this course is built on has a real file to
count. Verified with `cmp`: identical.

The ledger, re-derived here rather than remembered (`c4-unit01/ledger.sh`):

```
  lines in startEverything(), comments and blanks removed ... 18
  objects constructed with new .............................. 4
  configuration values held as constants beside them ........ 3
  places that order is written down ......................... 0
  things that check it ...................................... 0
```

Units 01 to 30 each move one of those rows; the last unit of the course re-runs the count with
the file deleted. **Every one of those numbers is derived from the file on the day, by that
script, which exits 2 rather than print a number it could not measure.**

## Course 4 — rewired (Spring Framework Core, capstone)

`Wiring.java` is gone, and so is the second hand-wiring in `TiffinBoxServer.main`. The five objects carry
`@Component` (and two `@Value` parameters, one `@PostConstruct`); `tiffinbox-web` adds `TiffinBoxApp`
(`@Configuration @ComponentScan @PropertySource`) and `tiffinbox.properties` (the JDBC URL, cooks, days, port).
The core module now depends on `spring-context` and `jakarta.annotation-api`. The run command is unchanged:

```bash
mvn -q -DskipTests package
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 18431
```

The project as it was before the rewire is frozen in `../c4-unit31/before/`; the evidence that the two serve
byte-identical responses, and everything else the capstone claims, is `../c4-unit31/receipts.sh`.

# c5-unit02 — Anatomy of a Generated Project

Course 5 · Spring Boot · Section 1 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-29.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # every capture below, 3 runs each; every number the video says is asserted; a changed capture stops it
```

`receipts.md5` — each capture's md5, 3/3 on 2026-09-29. This Mac ran them offline (`MAVEN_ARGS=-o ./receipts.sh`, once
`.m2-demo` was full), and once more online, against a loopback mirror standing in for Maven Central that answers 404
(`MAVEN_ARGS="-s <settings with that mirror>"`, a cold cache for the break): the same 8 md5s, and that whole run made
one request — for the break's own parent POM, `spring-boot-starter-parent-4.1.1.RELEASE.pom`:

```
site      89b02c256311048b4063eacc70ddb77e
fetches   260ea1de31d069535424c1168d9a4972
files     1adf18a6316737d977c05a29b3d43b19
parent    e105a97a802f0589ac461ae07419f79d
bind      2e16d7dafd81a8c374ff114105439a71
tests     d7fc38785cbf0667a84d201d4aabad82
release   10dfa2c4d5b5c4861b2a343a97b0e9e7
exercise  43464c76c014e573eb5bbbe55648f146
```
spring-boot-maven-plugin declared in generated/pom.xml:                       1
spring-boot-maven-plugin declared in TiffinBox's root pom.xml:                0
spring-boot-maven-plugin declared in TiffinBox's web pom.xml:                 0
the generated jar's manifest: Main-Class: org.springframework.boot.loader.launch.JarLauncher Start-Class: com.tiffinbox.TiffinboxApplication
the generated jar holds 20 jars in BOOT-INF/lib/: 19 of its 21 run-time dependencies, and 1 more: spring-boot-jarmode-tools-4.1.1.jar
  left out: spring-boot-starter-4.1.1.jar spring-boot-starter-logging-4.1.1.jar - their manifests say: Spring-Boot-Jar-Type: dependencies-starter
java -jar on the generated jar: exit 0 · lines reading "Started TiffinboxApplication": 1
TiffinBox's jar, built as shipped: Main-Class: com.tiffinbox.web.TiffinBoxServer · jars inside it: 0 · jars in lib/ beside it: 26
```
the site's machine-readable version list, site/metadata-client.json:
  Boot, its default:  id 4.1.1.RELEASE · name 4.1.1
  Java, its default:  17 · offered: 27 25 21 17
```

The list gives each version two labels: a `name` (`4.1.1`) and an `id` (`4.1.1.RELEASE`). The id is the one that breaks
the build (below). Java's default that day was 17; the request asked for 25.

(`.r-fetches.out` `260ea1de31d069535424c1168d9a4972`)

```
site/tiffinbox.zip                           md5 9749d87153c3906da902bd04091d654d  = recorded in REQUEST.txt
site/tiffinbox-bootVersion-4.1.1.RELEASE.zip md5 e49c1b51bbbd70580121140471acf45b  = recorded in REQUEST.txt
the two zips hold the same 10 files; the ones that differ: HELP.md pom.xml
  pom.xml, lines changed: 1 - <version>4.1.1</version> -> <version>4.1.1.RELEASE</version>
generated/ against the first zip: 10 of 10 files the same (line endings aside - see README)
breaks/release-suffix/pom.xml against the second zip's pom.xml: the same
```

*Line endings aside:* `generated/.gitattributes` (the site's own file) marks `*.cmd` as `text eol=crlf`, so a fresh clone
checks `generated/mvnw.cmd` out with CRLF endings while the zip holds LF. The comparison strips `\r` from both sides; it
is the only normalisation in this unit.

## What the generator handed over

(The generated `.gitignore` lists `HELP.md` — the site's own project would not commit it. It is force-added here, because
this folder is a record of what the site returned, not a project someone continues. `HELP.md` also explains the empty
elements in `pom.xml` — `<url/>`, `<licenses>`, `<developers>`, `<scm>`: without them the project would inherit "unwanted
elements like `<license>` and `<developers>` from the parent".)

(`.r-files.out` `1adf18a6316737d977c05a29b3d43b19`)

```
the generator handed over 10 files:
  .gitattributes
  .gitignore
  .mvn/wrapper/maven-wrapper.properties
  HELP.md
  mvnw
  mvnw.cmd
  pom.xml
  src/main/java/com/tiffinbox/TiffinboxApplication.java
  src/main/resources/application.properties
  src/test/java/com/tiffinbox/TiffinboxApplicationTests.java
the parent it names: spring-boot-starter-parent 4.1.1
its own dependencies: spring-boot-starter spring-boot-starter-test
java.version it asked for: 25
```

## The parent, opened

`mvn help:effective-pom` on the generated project:

(`.r-parent.out` `e105a97a802f0589ac461ae07419f79d`)

```
the effective POM - the generated pom.xml with everything its parent adds - is 10541 lines
  managed artifacts - each one's version picked by the parent ...... 1911
  <parameters>true</parameters> (the compiler keeps parameter names) 4
  <goal>repackage</goal> (the executable-jar step, configured) ..... 2
```

*Managed artifacts* are the `<dependency>` entries in the effective POM's `<dependencyManagement>`: each one names an
artifact (a file Maven downloads — a library jar, a BOM) and the version the parent picked for it. Nothing is downloaded
until a dependency names one of them.

## Configured is not bound

The parent *configures* `repackage`; it runs only where `spring-boot-maven-plugin` is declared. The generated project
declares it; `../c5-tiffinbox` inherits the same parent and declares nothing (built here from a copy, as shipped):

(`.r-bind.out` `2e16d7dafd81a8c374ff114105439a71`)

```
spring-boot-maven-plugin declared in generated/pom.xml:                       1
spring-boot-maven-plugin declared in c5-tiffinbox/pom.xml:                    0
spring-boot-maven-plugin declared in c5-tiffinbox/tiffinbox-web/pom.xml:      0
the generated jar's manifest: Main-Class: org.springframework.boot.loader.launch.JarLauncher Start-Class: com.tiffinbox.TiffinboxApplication
the generated jar holds 20 jars in BOOT-INF/lib/: 19 of its 21 run-time dependencies, and 1 more: spring-boot-jarmode-tools-4.1.1.jar
  left out: spring-boot-starter-4.1.1.jar spring-boot-starter-logging-4.1.1.jar - their manifests say: Spring-Boot-Jar-Type: dependencies-starter
java -jar on the generated jar: exit 0 · lines reading "Started TiffinboxApplication": 1
TiffinBox's jar, built as shipped: Main-Class: com.tiffinbox.web.TiffinBoxServer · jars inside it: 0 · jars in lib/ beside it: 26
```

Where the plugin runs, the jar's `Main-Class` is Boot's launcher and your class is only the `Start-Class`; the launcher is
what `java -jar` starts, and the `Started TiffinboxApplication` line shows it reached your class. The jar carries 19 of its
21 run-time dependencies — the two it leaves out are starters, whose own manifests mark them
`Spring-Boot-Jar-Type: dependencies-starter` — plus one jar of Boot's own, `spring-boot-jarmode-tools`. TiffinBox's jar
keeps its own `Main-Class` and carries nothing; its libraries sit in `lib/` beside it, named by its `Class-Path`. The
executable jar gets its own video later in this course. The same parent switched `-parameters` on in TiffinBox's own
build — measured in `../c5-unit01` (`MethodParameters` 0 → 3). The `java -jar` log itself (a timestamp, a PID, paths) is
not kept: the capture keeps its exit code and a count of its `Started TiffinboxApplication in` line.

## The test it ships

(`.r-tests.out` `d7fc38785cbf0667a84d201d4aabad82`)

```
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
what the one test checks:  @Test void contextLoads() { } 
```

A context that starts is not evidence that the thing you meant is the thing you got — Course 4's rule, and the generated
test checks nothing else.

## The break — the site's own id, as A/B/A′

The two build files differ in one line (`fetches`, above). A is the first request's project, B the second's, A′ is A
run again:

(`.r-release.out` `10dfa2c4d5b5c4861b2a343a97b0e9e7`)

```
A   generated/              bootVersion=4.1.1           mvn validate: exit 0
B   breaks/release-suffix/  bootVersion=4.1.1.RELEASE   mvn validate: exit 1
    [FATAL] Non-resolvable parent POM for com.tiffinbox:tiffinbox:0.0.1-SNAPSHOT: The following artifacts could not be resolved: org.springframework.boot:spring-boot-starter-parent:pom:4.1.1.RELEASE (absent) … [rest of line cut: it describes the local cache]
A′  generated/, run again   bootVersion=4.1.1           mvn validate: exit 0
```

**The cut, declared.** The capture keeps each run's exit code, taken before any filter, and B's `[FATAL]` line up to
`(absent)`. What follows `(absent)` describes the local Maven cache, so it differs from run to run — measured 2026-09-29
against a loopback mirror that answers 404: a first run says `Could not find artifact … in central`, the next
`… was not found … during a previous attempt. This failure was cached in the local repository …`, and `-o` says
`Cannot access central … in offline mode`. All three give this capture's md5. Maven's full output for B is kept, unhashed,
in `.r-release.raw` (it names your local paths).

Use the version as the site names it — `4.1.1` — and read the parent line of any generated build file before you trust it.

## Exercise

`exercise/`: delete TiffinBox's `<h2.version>` line and find whose H2 you get. `receipts.sh` solves it on a copy:

(`.r-exercise.out` `43464c76c014e573eb5bbbe55648f146`)

```
start   pom.xml <h2.version>: 2.5.250         build exit 0 · lib/ holds: h2-2.5.250.jar
solved  pom.xml <h2.version>: (line deleted)  build exit 0 · lib/ holds: h2-2.4.240.jar
Boot's own BOM, spring-boot-dependencies-4.1.1.pom, line 68: <h2.version>2.4.240</h2.version>
```

`exercise/README.md` has the commands (run as written — transcript in `exercise/solution/RUN.txt`), and the explanation is
in `exercise/solution/SOLUTION.md`. Building both states is also what fills `.m2-demo` with everything that README reads.

## Masks and cuts (contract §R.3)

No capture in this unit masks a token. One capture cuts (`release`, after `(absent)`, above), one normalises line endings
(`fetches`, above), and one keeps a count instead of a log (`bind`'s `java -jar` line, above).

# c5-unit03 — Starters: What One Really Contains

Course 5 · Spring Boot · Section 1 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-29
(re-gated after Section 1's RED review). The fix lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of the
anchor as it leaves it, and "before" is `../c5-unit01/after/`, which `receipts.sh` copies to `target/before/` and builds
there — so these receipts never write into another unit's folder, and later units cannot move them. Builds are clean.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh              # every capture 3 times; dies on drift, on a failed check, or on an md5 that differs from receipts.md5
./receipts.sh --publish    # the same, then rewrites receipts.md5 - only when the video itself changes
```

**Network: resolution only.** The first run resolves from Maven Central into this unit's own repository, `.m2-demo/`:
the core starter's jar and the old web starter's POM, every jar of `web/`'s tree (so the starters it names are on disk),
Jackson 2.22.2 and Jackson 3.1.5 (for Course 2's examples), and what the builds below need. Nothing it runs calls the
network; the two servers bind loopback ports **18540** (before the fix) and **18541** (after).

**Masks: none.** Every capture is hashed exactly as printed. What the script *selects* from longer output is declared
here instead: Maven's `[INFO] ` prefix is stripped from tree lines; the relocation warning is printed once (`sort -u` —
Maven prints it twice per build); `javac`'s own output is reduced to its exit code, its `error:`, `symbol:` and
`location:` lines (runs of spaces squeezed) and its last line — the source path it prints is dropped.

**Every number the video speaks is asserted** by a `grep` in `receipts.sh` that can fail (39 jars, 6 of 6 starters, 0
classes, 0 warnings, the three Jackson inversions, 2.22 / 2.21, the seven responses' md5).

## A starter, opened (`.r-starter.out` `c1742df52242761b89717d0f49bf805b`)

```
spring-boot-starter-4.1.1.jar - every entry:
  META-INF/
  META-INF/MANIFEST.MF
  META-INF/LICENSE.txt
  META-INF/NOTICE.txt
.class files in it: 0
spring-boot-starter-web-4.1.1.pom, its own description:
  Starter for building web, including RESTful, applications using Spring MVC. Uses Tomcat as the default embedded container (deprecated in favor of spring-boot-starter-webmvc)
```

Every Boot starter this repository holds, not only the one opened above (`.r-starters.out` `eb9caa354847ac543d613a3bfd4e38bd`):

```
every Boot starter jar in .m2-demo, and the .class files in it:
  spring-boot-starter-4.1.1.jar                  0
  spring-boot-starter-jackson-4.1.1.jar          0
  spring-boot-starter-logging-4.1.1.jar          0
  spring-boot-starter-tomcat-4.1.1.jar           0
  spring-boot-starter-tomcat-runtime-4.1.1.jar   0
  spring-boot-starter-webmvc-4.1.1.jar           0
starter jars: 6 · with a .class file: 0
```

Boot's own starters are a POM and a jar with no code in it. (A starter you write yourself may carry code; that is a later
unit's subject.) The old web starter still exists in 4.1.1, and its own POM says what replaced it — which is why `web/`
names `spring-boot-starter-webmvc`.

## One web starter's tree (`.r-tree.out` `32adc565a5d184bc65a938934fe34778`)

`web/pom.xml` is the smallest Boot web project there is: the parent and that one starter.

```
com.tiffinbox:one-starter-web:jar:1.0.0
\- org.springframework.boot:spring-boot-starter-webmvc:jar:4.1.1:compile
   +- org.springframework.boot:spring-boot-starter:jar:4.1.1:compile
   |  +- org.springframework.boot:spring-boot-starter-logging:jar:4.1.1:compile
   |  |  +- ch.qos.logback:logback-classic:jar:1.5.38:compile
   |  |  |  +- ch.qos.logback:logback-core:jar:1.5.38:compile
   |  |  |  \- org.slf4j:slf4j-api:jar:2.0.18:compile
   |  |  +- org.apache.logging.log4j:log4j-to-slf4j:jar:2.25.5:compile
   |  |  |  \- org.apache.logging.log4j:log4j-api:jar:2.25.5:compile
   |  |  \- org.slf4j:jul-to-slf4j:jar:2.0.18:compile
   |  +- org.springframework.boot:spring-boot-autoconfigure:jar:4.1.1:compile
   |  +- jakarta.annotation:jakarta.annotation-api:jar:3.0.0:compile
   |  \- org.yaml:snakeyaml:jar:2.6:compile
   +- org.springframework.boot:spring-boot-starter-jackson:jar:4.1.1:compile
   |  \- org.springframework.boot:spring-boot-jackson:jar:4.1.1:compile
   |     \- tools.jackson.core:jackson-databind:jar:3.1.5:compile
   |        +- com.fasterxml.jackson.core:jackson-annotations:jar:2.21:compile
   |        \- tools.jackson.core:jackson-core:jar:3.1.5:compile
   +- org.springframework.boot:spring-boot-starter-tomcat:jar:4.1.1:compile
   |  +- org.springframework.boot:spring-boot-starter-tomcat-runtime:jar:4.1.1:compile
   |  |  +- org.springframework.boot:spring-boot-web-server:jar:4.1.1:compile
   |  |  +- org.apache.tomcat.embed:tomcat-embed-core:jar:11.0.24:compile
   |  |  +- org.apache.tomcat.embed:tomcat-embed-el:jar:11.0.24:compile
   |  |  \- org.apache.tomcat.embed:tomcat-embed-websocket:jar:11.0.24:compile
   |  \- org.springframework.boot:spring-boot-tomcat:jar:4.1.1:compile
   +- org.springframework.boot:spring-boot-http-converter:jar:4.1.1:compile
   |  +- org.springframework.boot:spring-boot:jar:4.1.1:compile
   |  |  +- org.springframework:spring-core:jar:7.0.9:compile
   |  |  |  +- commons-logging:commons-logging:jar:1.3.6:compile
   |  |  |  \- org.jspecify:jspecify:jar:1.0.1:compile
   |  |  \- org.springframework:spring-context:jar:7.0.9:compile
   |  \- org.springframework:spring-web:jar:7.0.9:compile
   |     +- org.springframework:spring-beans:jar:7.0.9:compile
   |     \- io.micrometer:micrometer-observation:jar:1.17.1:compile
   |        \- io.micrometer:micrometer-commons:jar:1.17.1:compile
   \- org.springframework.boot:spring-boot-webmvc:jar:4.1.1:compile
      +- org.springframework.boot:spring-boot-servlet:jar:4.1.1:compile
      \- org.springframework:spring-webmvc:jar:7.0.9:compile
         +- org.springframework:spring-aop:jar:7.0.9:compile
         \- org.springframework:spring-expression:jar:7.0.9:compile
jars in the tree: 39
```

The JSON library a Boot 4.1.1 web app gets is **Jackson 3** — `tools.jackson.core:jackson-databind` — with the 2.x
annotations artifact kept.

## Deprecated in words, or relocated (`.r-relocate.out` `1c70af8d7d4a14ba19ddca234612b052`)

Maven has its own way to retire an artifact: a POM with a `<relocation>` (`harness/relocation/old-starter-1.0.pom`, put
into `.m2-demo` by the script as `mvn install` would). A build against it warns and uses the new artifact. The same build
with `spring-boot-starter-web` (`harness/relocation/uses-starter-web`) prints no warning at all, and never the word
"deprecated": Boot put its note in a `<description>`, which Maven does not print.

```
com.tiffinbox:uses-old-starter:jar:1.0.0
[WARNING] The artifact com.example:old-starter:jar:1.0 has been relocated to com.example:new-starter:jar:1.0: deprecated in favor of new-starter
\- com.example:new-starter:jar:1.0:compile
com.tiffinbox:uses-starter-web:jar:1.0.0
\- org.springframework.boot:spring-boot-starter-web:jar:4.1.1:compile
in that whole build: [WARNING] lines 0 · lines containing "deprecated" 0 · BUILD SUCCESS
```

## Course 2's Jackson examples, on Jackson 3 (`.r-course2.out` `29dd959381fec435b64d6451f4c6f7ab`)

Course 2's five Jackson sources are read from `../c2-unit29` (never copied here), plus two small files
of this unit's — `harness/course2/Strict.java` (JsonOops's strict read, on its own) and `harness/course2/Dates.java`
(Course 2's closing card: a record with a `LocalDate`). Each is compiled as written against Jackson 2.22.2, and again
against Jackson 3.1.5 after a `sed` that moves only `com.fasterxml.jackson.databind`/`.core` to `tools.jackson.…` (the
annotations package does not move). The first line counts what that move changed; the last shows that nothing else in Course 2's folder changes behaviour.

```
the package move changed 12 lines in 7 files; lines that are not an import: 0
Jackson 2.22.2  new ObjectMapper(): FAIL_ON_UNKNOWN_PROPERTIES true  an unknown field -> UnrecognizedPropertyException
Jackson 3.1.5  new ObjectMapper(): FAIL_ON_UNKNOWN_PROPERTIES false  an unknown field -> read Ravi -> 7200
Course 2's JsonOops.java with jackson-databind-2.22.2.jar: javac exit 0 · it runs: lenient mapper: Ravi -> 7200
Course 2's JsonOops.java with jackson-databind-3.1.5.jar: javac exit 1 · error: cannot find symbol · symbol: method configure(DeserializationFeature,boolean) · location: class ObjectMapper · 1 error
Jackson 2.22.2  a LocalDate, no extra module -> InvalidDefinitionException
Jackson 3.1.5  a LocalDate, no extra module -> {"name":"Ravi","from":"2026-09-27"}
the rest of Course 2's Jackson files - Json.java, MapperCost.java, Unchecked.java - javac exit 0 on Jackson 2, 0 on Jackson 3 · Json's whole output, 2 against 3: identical
```

Three inversions: an unknown field is refused by default in 2 and read by default in 3; Course 2's lenient line does not
compile on 3 (`ObjectMapper` has no `configure(DeserializationFeature, boolean)`); a `LocalDate` needs an extra module in
2 and nothing in 3. On the 2.22.2 it was written for, Course 2's file still compiles and runs.

## The break — one family member pinned, A / B / A′ (`.r-jackson.out` `a82572b307e080f31c260beb5deba2c6`)

Course 4 pinned `jackson-databind` alone, which was right while nothing else managed Jackson. Under Boot's parent the
other two members follow Boot's version instead — and the build says nothing (A′ is A, built again):

```
A  before the fix (jackson-databind pinned alone): jackson-annotations-2.21.jar jackson-core-2.21.5.jar jackson-databind-2.22.2.jar · build warnings 0
B  after the fix (jackson-2-bom.version set): jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar · build warnings 0
A′  before the fix, built again: jackson-annotations-2.21.jar jackson-core-2.21.5.jar jackson-databind-2.22.2.jar · build warnings 0
```

The fix is the property Boot's own BOM (bill of materials: a list of versions meant to move together) reads —
`<jackson-2-bom.version>2.22.2</jackson-2-bom.version>` — which moves the whole family together.

## Why the property works: inherited, not imported — A / B / A′ (`.r-steer.out` `6bc0f339d4e1c4de56563b2cfbbaf655`)

`harness/inherits-parent/pom.xml` and `harness/imports-bom/pom.xml` differ only in how Boot's list arrives (parent vs
`<scope>import</scope>`); both set the same property and name `jackson-databind` without a version.

```
A  com.tiffinbox:inherits-parent:jar:1.0.0 · <jackson-2-bom.version>2.22.2</jackson-2-bom.version> -> com.fasterxml.jackson.core:jackson-databind:jar:2.22.2:compile
B  com.tiffinbox:imports-bom:jar:1.0.0 · <jackson-2-bom.version>2.22.2</jackson-2-bom.version> -> com.fasterxml.jackson.core:jackson-databind:jar:2.21.5:compile
A′  com.tiffinbox:inherits-parent:jar:1.0.0 · <jackson-2-bom.version>2.22.2</jackson-2-bom.version> -> com.fasterxml.jackson.core:jackson-databind:jar:2.22.2:compile
```

A property of yours steers a list you inherit; an imported list keeps its own values. That is why TiffinBox's fix works:
it inherits Boot's parent (unit 01).

## The seven responses, both sides of the fix (`.r-responses.out` `bcf80fc25055860347a9b0ec505ab03a`)

`../c4-unit31/curlset.sh` against each build — the split family and the fixed one — hashed on its own (the `' -> '` lines):

```
A  before the fix (the split family): 7 lines  md5 115c36bac276128e245ca57df11c2891  server exit 0
B  after the fix (one family): 7 lines  md5 115c36bac276128e245ca57df11c2891  server exit 0
```

The same hash as Course 4's. The split broke nothing you could see, which is how it hides.

## Harness and exercise

- `web/pom.xml` — the one-starter web project (`com.tiffinbox:one-starter-web`); no sources.
- `harness/course2/` — `Strict.java`, `Dates.java` (see above).
- `harness/inherits-parent/`, `harness/imports-bom/` — the A / B pair for the property.
- `harness/relocation/` — `old-starter-1.0.pom` (relocates), `new-starter-1.0.pom`, and the two consumers.
- `exercise/` — no pin at all: its README's commands, run exactly as written; the answer in `exercise/solution/`.

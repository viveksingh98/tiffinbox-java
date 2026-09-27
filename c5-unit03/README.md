# c5-unit03 — Starters: What One Really Contains

Course 5 · Spring Boot · Section 1 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-27.
The fix lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of the anchor as it leaves it, and "before" is
`../c5-unit01/after/` — so later units cannot move these receipts. Builds are clean builds.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # 3 runs each, every number asserted; resolves two artefacts from Maven Central, runs nothing from them
```

## A starter, opened

(`.r-starter.out` `c1742df52242761b89717d0f49bf805b`)

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

A starter is a POM and a jar with no code in it. The old web starter still exists in 4.1.1, and its own POM says what
replaced it — which is why this unit's web project names `spring-boot-starter-webmvc`.

## One web starter's tree

`web/pom.xml` is the smallest Boot web project there is: the parent and that one starter (`.r-tree.out` `f3a5ae2eee0e872d0cdec20ad3598803`):

```
com.tiffinbox:c5-unit03-web:jar:1.0.0
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
annotations artefact kept. Course 2 taught `com.fasterxml.jackson` 2.22.2: the same project, one major version earlier,
a new package for the databind and core classes, and the same annotations.

## The break — one family member pinned

Course 4 pinned `jackson-databind` alone, which was right while nothing else managed Jackson. Under Boot's parent the
other two members follow Boot's version instead (`.r-jackson.out` `2aa9eae93886065fd1482f01135c48b7`):

```
unit 01 (jackson-databind pinned alone): jackson-annotations-2.21.jar jackson-core-2.21.5.jar jackson-databind-2.22.2.jar
unit 03 (jackson-2-bom.version set): jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar
```

The fix is the property Boot's own BOM reads — `<jackson-2-bom.version>2.22.2</jackson-2-bom.version>` — which moves
the whole family together. It works because TiffinBox inherits Boot's **parent** (unit 02): a BOM *import* cannot be
steered by a property of yours. The seven responses after the fix (`.r-responses.out` `b115f24e6b7d6f10872b808e5403a7b5`):

```
the seven responses after the fix: md5 115c36bac276128e245ca57df11c2891
server exit 0
```

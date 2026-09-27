# c5-unit02 — Anatomy of a Generated Project

Course 5 · Spring Boot · Section 1 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-09-27.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
./receipts.sh     # everything below, 3 runs each, every number asserted — and no step calls start.spring.io
```

`generated/` is exactly what start.spring.io returned on 2026-09-27; `generated/REQUEST.txt` holds the request, the UTC
time, the zip's md5 and the site's defaults that day (Boot 4.1.1; **Java 17** by default — we asked for 25). The site
is called once, at authoring time (Course 5 contract §1); the video explains the committed files.

## What the generator handed over

(The generated `.gitignore` lists `HELP.md` — the site's own project would not commit it. It is force-added here, because
this folder is a record of what the site returned, not a project someone continues.)

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

`mvn help:effective-pom` on the generated project (`.r-parent.out` `214fd55afb8df7cf16f7894a8c7a5f79`):

```
the effective POM - the generated pom.xml with everything its parent adds - is 10541 lines
  dependency versions the parent decides for you ................ 1911
  <parameters>true</parameters> (the compiler keeps parameter names) 4
  <goal>repackage</goal> (the executable-jar step, configured) ..... 2
```

The repackage step is *configured* by the parent and *runs* only where `spring-boot-maven-plugin` is declared: the
generated `pom.xml` declares it; `../c5-tiffinbox` inherits the same parent and does not, so its jar stays thin (unit
13 opens the executable jar). The same parent switched `-parameters` on in TiffinBox's own build — measured in
`../c5-unit01` (`MethodParameters` 0 → 3).

## The test it ships

(`.r-tests.out` `d7fc38785cbf0667a84d201d4aabad82`)

```
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
what the one test checks:  @Test void contextLoads() { } 
```

A context that starts is not evidence that the thing you meant is the thing you got — Course 4's rule, and the generated
test checks nothing else.

## The break — a request that makes an unbuildable project

The site's own metadata names versions like `4.1.1.RELEASE`. Passed back as `bootVersion=4.1.1.RELEASE`, it becomes
the parent's `<version>` verbatim (`breaks/release-suffix/pom.xml`, from that fetch). Maven's answer (`.r-release.out`
`a892902c148b94dc5c8329c0d34beec7`, the local-repository path cut and counted):

```
[FATAL] Non-resolvable parent POM for com.tiffinbox:tiffinbox:0.0.1-SNAPSHOT: The following artifacts could not be resolved: org.springframework.boot:spring-boot-starter-parent:pom:4.1.1.RELEASE (absent) … [+374 chars]
… 13 more line(s) of Maven output elided …
exit 1
```

`bootVersion=4.1.1` generates `<version>4.1.1</version>`, which resolves. Record the exact request, always.

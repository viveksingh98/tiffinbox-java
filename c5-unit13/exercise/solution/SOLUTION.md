# Solution — one property, `start-class`

The change, in `.harness/mine/tiffinbox-web/pom.xml` (the whole file: `pom.xml` beside this one): a `<properties>` block
before `<dependencies>`.

```xml
  <properties>
    <start-class>com.tiffinbox.web.TiffinBoxServer</start-class>
  </properties>
```

Why that property: Boot's parent configures the plugin it manages with `<mainClass>${spring-boot.run.main-class}</mainClass>`
(its line 217), and sets `spring-boot.run.main-class` to `${start-class}` (line 19). With `start-class` set, `repackage` is
told the main class and stops looking for one. `PrintRoutes` stays in the jar. (Writing `<mainClass>` into the plugin's own
`<configuration>` in web's POM also works; it was not measured here.)

## Measured — `exercise/README.md` run exactly as written (2026-10-05)

In a clean shell (`env -i`, only `HOME` and a system `PATH`), from `c5-unit13/`, JDK 25.0.4.1, Maven 3.9.16, offline
against `.m2-demo`. The edit was made by copying this folder's `pom.xml` over `.harness/mine/tiffinbox-web/pom.xml`.

The first package, two main classes — the last command of the first block printed:

```
Unable to find a single main class from the following candidates [com.tiffinbox.web.TiffinBoxServer, com.tiffinbox.web.tools.PrintRoutes]
```

The hint's `grep` (the parent's lines that name the property):

```
19:    <spring-boot.run.main-class>${start-class}</spring-boot.run.main-class>
137:                <mainClass>${start-class}</mainClass>
149:                <mainClass>${start-class}</mainClass>
217:            <mainClass>${spring-boot.run.main-class}</mainClass>
269:                    <mainClass>${start-class}</mainClass>
```

The second package, with the property:

```
[INFO] BUILD SUCCESS
Main-Class: org.springframework.boot.loader.launch.JarLauncher
Start-Class: com.tiffinbox.web.TiffinBoxServer
1
```

`receipts.sh`'s `exercise` capture measures the same two end states on its own copies (`.harness/twomains`,
`.harness/startclass`): the build of `twomains/` fails in `spring-boot-maven-plugin:4.1.1:repackage (repackage)` naming both
candidates, and `startclass/`'s manifest says `Start-Class: com.tiffinbox.web.TiffinBoxServer`, with `PrintRoutes` in the
jar (1).

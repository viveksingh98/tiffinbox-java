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

In one clean shell (`env -i HOME=… PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin bash --noprofile --norc`), from
`c5-unit13/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo` (filled by `receipts.sh`), every line of the README's three
bash blocks in order — re-run by BLUE after the README gained its fresh-clone note (its commands are unchanged). The edit is the
reader's step between the second and third blocks, made here by copying this folder's `pom.xml`:

```
$ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  (exit 0)
$ export PATH="$JAVA_HOME/bin:$PATH"
  (exit 0)
$ rm -rf .harness/mine && mkdir -p .harness && rsync -a --exclude target after/ .harness/mine/
  (exit 0)
$ mkdir -p .harness/mine/tiffinbox-web/src/main/java/com/tiffinbox/web/tools
  (exit 0)
$ cp exercise/PrintRoutes.java .harness/mine/tiffinbox-web/src/main/java/com/tiffinbox/web/tools/
  (exit 0)
$ mvn -o -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package | grep -m1 -oE 'Unable to find a single main class from the following candidates \[[^]]*\]'
Unable to find a single main class from the following candidates [com.tiffinbox.web.TiffinBoxServer, com.tiffinbox.web.tools.PrintRoutes]
  (exit 0)
$ grep -n 'start-class\|main-class' .m2-demo/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom
19:    <spring-boot.run.main-class>${start-class}</spring-boot.run.main-class>
137:                <mainClass>${start-class}</mainClass>
149:                <mainClass>${start-class}</mainClass>
217:            <mainClass>${spring-boot.run.main-class}</mainClass>
269:                    <mainClass>${start-class}</mainClass>
  (exit 0)
(your edit) $ cp exercise/solution/pom.xml .harness/mine/tiffinbox-web/pom.xml
  (exit 0)
$ mvn -o -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package | grep -E '^\[INFO\] BUILD'
[INFO] BUILD SUCCESS
  (exit 0)
$ unzip -p .harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF | grep -E '^(Main|Start)-Class'
Main-Class: org.springframework.boot.loader.launch.JarLauncher
Start-Class: com.tiffinbox.web.TiffinBoxServer
  (exit 0)
$ unzip -l .harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar | grep -c 'tools/PrintRoutes.class'
1
  (exit 0)
```

`receipts.sh`'s `exercise` capture measures the same two end states on its own copies (`.harness/twomains`,
`.harness/startclass`): the build of `twomains/` fails in `spring-boot-maven-plugin:4.1.1:repackage (repackage)` naming both
candidates, and `startclass/`'s manifest says `Start-Class: com.tiffinbox.web.TiffinBoxServer`, with `PrintRoutes` in the
jar (1).

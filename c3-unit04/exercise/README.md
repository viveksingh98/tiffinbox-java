# Exercise — the goal that never ran

## Start here

The unit's rule holds here too: every `mvn` below carries `-Dmaven.repo.local`, so this exercise builds into
`c3-unit04/.m2-unit04` — the same scratch repository the rest of the unit used — and never your real `~/.m2`.
**Keep the quotes:** this tree's path contains a space.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
M2="$PWD/../.m2-unit04"                          # the unit's scratch repo, never your real ~/.m2
mvn -B "-Dmaven.repo.local=$M2" clean package
ls target/lib
java --enable-preview -Djava.util.logging.config.file=logging.properties -jar target/c2-capstone-1.0.0.jar
```

What you get, and every line of it is real (3 runs, byte-identical, md5 `67cc1317d5d3b80eaacd073867443ba9`):

```
[INFO] BUILD SUCCESS                                  <- exit 0. Seven goal lines, not eight.
ls: target/lib: No such file or directory
Exception in thread "main" java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/ObjectMapper
	at com.tiffinbox.TiffinBoxServer.<clinit>(TiffinBoxServer.java:31)
```

The jar's manifest still says `Class-Path: lib/h2-2.5.250.jar …`. It is pointing at a directory that was
never written, and the build did not say a word.

## The task

**Bind the `copy-dependencies` goal to `prepare-package`.** One word in `pom.xml`.

Count the goal lines before and after — that number is the whole exercise:

```bash
mvn -B "-Dmaven.repo.local=$M2" clean package | grep -c '^\[INFO\] --- '
```

## The end state

`ls target/lib` lists **four** jars, and the server starts:

```
h2-2.5.250.jar
jackson-annotations-2.22.jar
jackson-core-2.22.2.jar
jackson-databind-2.22.2.jar
orders cooked:  120
kitchen value:  24300
routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
TiffinBox listening on http://127.0.0.1:18425
```

Stop it with `curl -s -X POST http://127.0.0.1:18425/shutdown`.

## The answer

`solution/pom.xml` is the fixed file. Copy it over and rebuild:

```bash
cp solution/pom.xml pom.xml
mvn -B "-Dmaven.repo.local=$M2" clean package
```

Run by the author on JDK 25.0.4.1 / Maven 3.9.16, **3 times, byte-identical**, md5
`fb155d2ec812b781c8a63644b6a06f43`, package exit 0, server exit 0 — 8 goal lines, 4 jars, the listening line
above.

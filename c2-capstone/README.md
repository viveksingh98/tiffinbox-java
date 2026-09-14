# c2-capstone — TiffinBox Server: every Core Java II section in one runnable service

One Maven project that puts the whole course together: an order queue on **virtual threads**,
a dashboard assembled with **structured concurrency**, an embedded **H2** database behind a
JDBC repository, **Jackson** for JSON, `jdk.httpserver` on a virtual-thread executor, a router
built by **reflection** from a `@Route(path, method)` annotation, and `System.Logger` for output.

## Requirements

JDK 25 **exactly** — `StructuredTaskScope` is a preview API in 25 (JEP 505), so the project is
compiled with `--release 25 --enable-preview`. A newer JDK refuses that combination. On a Mac
with more than one JDK installed, Maven picks the one `JAVA_HOME` names — and with `JAVA_HOME`
unset it picks whichever `java` is first on the path, which here is JDK 26 and fails with
`invalid source release 25 with --enable-preview`. So **every command below starts with the
export**:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -version           # Java version: 25.0.4.1
```

Maven downloads H2 2.5.250 and Jackson 2.22.2 on the first build — that build needs a network.

## Build

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -B clean package
```

`package` does three things: compiles with `--enable-preview`, copies the runtime dependencies
into `target/lib/`, and writes a jar whose manifest carries **`Main-Class`** and a
**`Class-Path`** pointing at `lib/`. Read the manifest yourself:

```bash
unzip -p target/c2-capstone-1.0.0.jar META-INF/MANIFEST.MF
```

```
Class-Path: lib/h2-2.5.250.jar lib/jackson-databind-2.22.2.jar lib/jacks
 on-annotations-2.22.jar lib/jackson-core-2.22.2.jar
Main-Class: com.tiffinbox.TiffinBoxServer
```

## Run

```bash
java --enable-preview -Djava.util.logging.config.file=logging.properties \
     -jar target/c2-capstone-1.0.0.jar
```

`--enable-preview` is needed at **both** steps — Maven passes it to the compiler
(`maven-compiler-plugin/compilerArgs`), you pass it to the JVM. A class compiled with preview
features refuses to load without it:
`UnsupportedClassVersionError: Preview features are not enabled ... Try running with '--enable-preview'`.

The same thing through Maven, if you prefer one command (the `exec-maven-plugin` in `pom.xml`
forks a real JVM so the flag actually reaches it, and passes the same logging config):

```bash
mvn -q -B compile exec:exec
```

The port is `18425` by default; pass another as the first argument:
`java --enable-preview -jar target/c2-capstone-1.0.0.jar 9090`.

## Logging

`TiffinBoxServer` has no `System.out.println` in it. It logs through **`System.Logger`**, the
JDK's own logging facade (`java.lang.System.Logger`, no dependency), which by default writes
through `java.util.logging`. `logging.properties` is the switch:

```bash
# same jar, same classes — one different file, and the DEBUG lines appear
java --enable-preview -Djava.util.logging.config.file=logging-debug.properties \
     -jar target/c2-capstone-1.0.0.jar
```

At `FINE` you also get `jdk.httpserver`'s own internal logging — lines nobody in this project
wrote (`HttpServer created …`, `context created: /customers`, `Exchange request line: …`).
Without a config file at all, the JDK default stamps a date and the calling method on every
line, which is why the commands above always name one.

## Expected output

Startup (captured on JDK 25.0.4.1, macOS, Apple silicon — byte-identical on every run, because
the queue is drained with `close()` before the server starts and the routes come out of a `TreeMap`):

```
orders cooked:  120
kitchen value:  24300
routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
TiffinBox listening on http://127.0.0.1:18425
```

Then, in a second shell:

```bash
curl -s http://127.0.0.1:18425/customers
curl -s http://127.0.0.1:18425/dashboard
curl -s http://127.0.0.1:18425/kitchen
curl -s http://127.0.0.1:18425/revenue
```

```json
[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
{"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
{"ordersCooked":120,"ordersValue":24300}
{"monthRevenue":24300}
```

`24300` is the same month total as the bills the generics section computed and the order rail
cooked — 4 customers x 30 days, priced from H2 this time instead of a hard-coded list.

**The kitchen counters are a startup fact, not a live one.** `main` puts 120 slips on the rail,
three cooks take them off, and `kitchen.close()` returns only when every cook has seen its
poison pill — all of that finishes *before* `server.start()`. So `/kitchen` reports a drained
rail, and it reports the same numbers however many times you call it.

Two negative tests, both real:

```bash
curl -s -o /dev/null -w '%{http_code}\n'  http://127.0.0.1:18425/pauses    # 404 — no such route
curl -s -w ' %{http_code}\n'              http://127.0.0.1:18425/shutdown  # 405 — wrong verb
```

```
404
{"error":"method not allowed"} 405
```

The 405 is the `method()` element of `@Route` doing its job: routes are keyed
`"VERB path"`, so `GET /shutdown` is simply not in the map.

## Stopping it

```bash
curl -s -X POST http://127.0.0.1:18425/shutdown     # -> {"stopping":true}
```

Stopping a server is not a GET — a crawler that prefetches links must not be able to kill it.
The JVM exits on its own a moment later. `Ctrl-C` in the server's shell works too. Nothing is
written to disk: the database is `jdbc:h2:mem:tiffinbox`, in memory, so there is no `.mv.db`
file to clean up. If a run was killed hard and the port is stuck, `lsof -nP -iTCP:18425 -sTCP:LISTEN`
names the process.

## Break it on purpose — `breaks/`

Both failures shown in the unit are re-runnable from this folder.

```bash
# 1. an XML comment may not contain two dashes
mvn -B -f breaks/pom-broken.xml clean package
# [FATAL] Non-parseable POM breaks/pom-broken.xml: in comment after two dashes (--)
#         next character must be > not e ... @ line 35, column 72

# 2. Map.of's randomised iteration order, six runs in a row (needs target/lib from a build)
for i in 1 2 3 4 5 6; do java -cp "target/lib/*" breaks/MapOrder.java; done
```

`MapOrder` prints the same two entries twice — once from a `Map.of`, once from a
`LinkedHashMap`. Over 12 runs here the `Map.of` line came out `{"ordersCooked":…,"ordersValue":…}`
10 times and swapped 2 times; the `LinkedHashMap` line was identical 12 times out of 12.
Your split will differ — that is the whole point.

## Files

| File | What it shows |
|---|---|
| `TiffinBoxServer.java` | `jdk.httpserver` + virtual-thread executor; `scanRoutes()` turns `@Route` annotations into a `"VERB path"` table by reflection; `System.Logger` for every line it prints |
| `Route.java` | the runtime-retained annotation the router reads — `path()` and `method() default "GET"` |
| `Database.java` | H2 connection, schema and seed data, one transaction and one batch |
| `CustomerRepository.java` | JDBC reads behind a plain Java interface |
| `Dashboard.java` | `StructuredTaskScope.open(Joiner.awaitAllSuccessfulOrThrow())` — three reads forked together, joined in the same block, no cast and no `@SuppressWarnings` |
| `OrderQueue.java` | `LinkedBlockingQueue` + three cooks on virtual threads + poison pills |
| `Customer.java` | the record that crosses every layer |
| `logging.properties` / `logging-debug.properties` | the logging switch, INFO and FINE |
| `breaks/` | the two failures from the unit, re-runnable |

These seven classes are classic `public class` files, not the compact source files the first
half of the course used — the same reason the first Maven unit gives: a build plugin that
loads `mainClass` reflectively cannot reach a compact file's package-private class.

Verified by `../verify_course2.sh capstone` from the repo root.

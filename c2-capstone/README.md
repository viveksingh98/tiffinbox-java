# c2-capstone — TiffinBox Server: every Core Java II section in one runnable service

One Maven project that puts the whole course together: an order queue on **virtual threads**,
a dashboard assembled with **structured concurrency**, an embedded **H2** database behind a
JDBC repository, **Jackson** for JSON, `jdk.httpserver` on a virtual-thread executor, and a
router built by **reflection** from a `@Route` annotation.

## Requirements

JDK 25 **exactly** — `StructuredTaskScope` is a preview API in 25 (JEP 505), so the project is
compiled with `--release 25 --enable-preview`. A newer JDK will refuse that combination
(`invalid source release`/preview mismatch), so point Maven at 25:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
java -version          # openjdk version "25.0.4.1"
```

Maven downloads H2 2.5.250 and Jackson 2.22.2 on the first build — that build needs a network.

## Build and run

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -B package
mvn -q -B dependency:copy-dependencies
java --enable-preview -cp "target/classes:target/dependency/*" com.tiffinbox.TiffinBoxServer
```

`--enable-preview` is needed at **both** steps — Maven passes it to the compiler
(`maven-compiler-plugin/compilerArgs`), you pass it to the JVM. A class compiled with preview
features refuses to load without it:
`UnsupportedClassVersionError: Preview features are not enabled ... Try running with '--enable-preview'`.

The same thing through Maven, if you prefer one command (the `exec-maven-plugin` in `pom.xml`
forks a real JVM so the flag actually reaches it):

```bash
mvn -q -B compile exec:exec
```

The port is `18425` by default; pass another as the first argument:
`java --enable-preview -cp "target/classes:target/dependency/*" com.tiffinbox.TiffinBoxServer 9090`.

## Expected output

Startup (captured on JDK 25.0.4.1, macOS, Apple silicon — byte-identical on every run, because
the queue is drained with `close()` before the server starts and the routes come out of a `TreeMap`):

```
orders cooked:  120
kitchen value:  24300
routes mapped:  [/customers, /dashboard, /kitchen, /revenue]
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

`24300` is the same month total as Units 11, 16 and 18 — 4 customers x 30 days, priced from H2
this time instead of a hard-coded list.

## Stopping it

```bash
curl -s http://127.0.0.1:18425/shutdown     # -> {"stopping":true}
```

The JVM exits on its own a moment later. `Ctrl-C` in the server's shell works too. Nothing is
written to disk: the database is `jdbc:h2:mem:tiffinbox`, in memory, so there is no `.mv.db`
file to clean up. If a run was killed hard and the port is stuck, `lsof -nP -iTCP:18425 -sTCP:LISTEN`
names the process.

## Files

| File | What it shows |
|---|---|
| `TiffinBoxServer.java` | `jdk.httpserver` + virtual-thread executor; `scanRoutes()` turns `@Route` annotations into contexts by reflection |
| `Route.java` | the runtime-retained annotation the router reads |
| `Database.java` | H2 connection, schema and seed data, one transaction and one batch |
| `CustomerRepository.java` | JDBC reads behind a plain Java interface |
| `Dashboard.java` | `StructuredTaskScope.open(...)` — three reads forked together, joined in the same block |
| `OrderQueue.java` | `LinkedBlockingQueue` + three cooks on virtual threads + poison pills (Unit 18's pipeline) |
| `Customer.java` | the record that crosses every layer |

Verified by `../verify_course2.sh capstone` from the repo root.

# Exercise — every field error in Boot's own body, and a key Boot no longer reads

**Your turn:** this run should list every field error in Boot's own body, but nothing changes. Find why, fix the key, count the errors.

Since this lesson TiffinBox's `POST /customers` answers a body that breaks its rules itself: 400, each broken field and its rule's
message — it takes a `BindingResult` beside its `@Valid` body. A route that takes no `BindingResult` leaves the answer to Spring MVC:
its 400, with Boot's error body — `timestamp`, `status`, `error`, `path` — which names no field. Boot can add them: one of its error
keys puts an `errors` array in that body, every field error whole. The course's harness has such a route, `probe.web.Unbound`
(`harness/probe/web/Unbound.java`, outside TiffinBox's own code): TiffinBox's `Customer`, marked `@Valid`, no `BindingResult`; it
stores nothing.

Run everything from `c6-unit12/`, in one shell. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give it a config tree with a token of its own — 26
random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable by you alone,
never printed — build the jar offline against this unit's `.m2-demo` and extract it (the class-path layout: TiffinBox's jar, and
every jar it needs in `lib/`), then compile the harness's route against it (`javac -parameters`, so Spring can read the route's
parameter names). Its last line runs in a subshell (the parentheses), so your shell stays in `c6-unit12/` for the next run: it starts
TiffinBox from the copy's folder on `127.0.0.1:19419` with the harness's route joined (`--spring.main.sources`) and **one of Boot's
error keys — as a Boot 3 tutorial writes it**, waits until readiness answers 200, POSTs a body that breaks three rules (an empty name,
zero meals, the meal type `LUNCH`) to the harness's route, its answer saved to `../got.json`, stops TiffinBox with POST /shutdown
(`harness/shutdown.sh`, the token read from the copy's own file), waits for that JVM to exit (`wait $!`: a JVM that failed — another
JDK's `java`, say — ends the line with its own exit code, never with a count), and prints the answer's status, how many field errors
its body lists, and their fields, sorted (`none` when it lists none). The whole log is `.harness/mine/run.log`. On a fresh clone
`.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM is needed for that, but Docker must answer, with
`eclipse-temurin:25-jre` on it: the script checks both before its first build; without `GRAALVM_HOME` it fills `.m2-demo`, makes every
capture that needs none — this exercise's among them — and stops before the native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
javac -parameters -d .harness/mine/hc -cp ".harness/mine/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Unbound.java
(cd .harness/mine/after && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19419 --spring.main.sources=probe.web.Unbound --server.error.include-binding-errors=always > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19419/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.json -w '%{http_code}' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":110,"mealType":"LUNCH"}' http://127.0.0.1:19419/probe/unbound); ../../../harness/shutdown.sh 19419 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"field":"[^"]*"' ../got.json | wc -l | tr -d ' ') && f=$(grep -o '"field":"[^"]*"' ../got.json | sed 's/^"field":"//; s/"$//' | sort | paste -sd' ' -) && echo "status: $s · errors: $n · fields: ${f:-none}")
```

As shipped, it prints `status: 400 · errors: 0 · fields: none`: the body broke three rules, Spring MVC refused it before the route
ran — and Boot's body lists nothing, as if the key were not there. To Boot 4 it is not: the run line gives the key by the name Boot 3
read, which Boot 4.0 replaced — its metadata marks the old name deprecated at level *error* — and Boot 4 ignores a property it no
longer reads, without a word in the log (count the lines of `.harness/mine/run.log` that name the key: none). Find the key's Boot 4
name — this lesson uses the family on screen — give the last line that option instead, and run it again from the same shell.

**Done** when you can print

```
status: 400 · errors: 3 · fields: mealType mealsPerDay name
```

— Boot's body with its `errors` array: one entry for each broken rule, three, none twice, each a field error whole (its field, the
value it was given, its message, and the codes and arguments behind them). The same line is in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

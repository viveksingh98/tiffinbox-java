# Exercise — a new customer, and the header that says it is JSON

**Your turn:** the README's POST answers 415. Read the Accept header in the answer, add the one header it asks for, and post again.

Since this lesson `POST /customers` takes a new customer as the request's body: `@RequestBody Customer customer`. Spring MVC hands
the body to the first of its message converters that can read a `Customer` from the body's media type — the type the request's
`Content-Type` header names — and for a `Customer` only the JSON one can, for `application/json`. Name no `Content-Type` and curl
names one for you: `--data` sends `application/x-www-form-urlencoded`, a form. No converter reads a `Customer` from a form, so
Spring MVC answers 415 before TiffinBox's method runs — and the answer's own `Accept` header lists the media types it would have read.

Run everything from `c6-unit08/`, in one shell. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give it a config tree with a token of its
own — 26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable
by you alone, never printed — and build the jar offline against this unit's `.m2-demo`. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit08/` for the next run: it starts TiffinBox from the copy's folder on
`127.0.0.1:19379`, waits until readiness answers 200, POSTs a new customer, Asha, as JSON (the answer's status line and headers
saved to `../head.txt`, its body to `../body.txt`), counts the customers `/customers` lists, stops TiffinBox with POST /shutdown
(`harness/shutdown.sh`, the token read from the copy's own file), waits for that JVM to exit (`wait $!`: a JVM that failed —
another JDK's `java`, say — ends the line with its own exit code, never with a count), and prints the POST's status, the
answer's `Accept` header (`none` when it has none) and how many customers there are now. The whole log is
`.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM is needed for that, but Docker must answer, with `eclipse-temurin:25-jre` on it: the
script checks both before its first build; without `GRAALVM_HOME` it fills `.m2-demo`, makes every capture that needs none — this
exercise's among them — and stops before the native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
(cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19379 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19379/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19379/customers; n=$(curl -s http://127.0.0.1:19379/customers | grep -o '"name":"' | wc -l | tr -d ' '); ../../../harness/shutdown.sh 19379 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && a=$(grep -i '^accept:' ../head.txt | sed 's/^[^:]*: *//' | tr -d '\r') && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · its Accept header: ${a:-none} · customers now: $n")
```

As shipped, it prints `status: 415 · its Accept header: application/json, application/*+json · customers now: 4`: the POST
carried no `Content-Type` of its own, so curl sent its default for `--data`, a form, and Spring MVC refused the body before
TiffinBox's method ran — nothing was stored. The log's one WARN line names the type it was sent
(`.harness/mine/run.log`). Read the `Accept` header, give the last line's POST the one header that names its body's type, and
run it again from the same shell.

**Done** when you can print

```
status: 200 · its Accept header: none · customers now: 5
```

— the new customer stored, and the answer with no `Accept` header, because it was accepted. The same line is in this unit's
`exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

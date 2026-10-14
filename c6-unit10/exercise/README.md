# Exercise — a name with a space, and the URL TiffinBox hands back

**Your turn:** post a customer whose name has a space, then fetch it. The README's fetch fails; use the Location header instead.

Since this lesson `POST /customers` answers a new customer with **201 Created** and a **`Location`** header: the new customer's own
URL, which Spring builds from the URL the request came to, the name appended to its path — **encoded**, so a space travels as `%20`.
Type the same URL by hand with the space as a space, and curl refuses it before anything is sent: a URL cannot hold a raw space. curl
then reports the status `000` — no answer at all.

Run everything from `c6-unit10/`, in one shell. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give it a config tree with a token of its
own — 26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable
by you alone, never printed — and build the jar offline against this unit's `.m2-demo`. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit10/` for the next run: it starts TiffinBox from the copy's folder on
`127.0.0.1:19399`, waits until readiness answers 200, POSTs a new customer, Sunil K, as JSON (the answer's status line and headers
saved to `../head.txt`), reads the answer's `Location` header into `l`, fetches the customer by the URL typed with the name as it is
written (`'http://127.0.0.1:19399/customers/Sunil K'`, its answer saved to `../got.json`), stops TiffinBox with POST /shutdown
(`harness/shutdown.sh`, the token read from the copy's own file), waits for that JVM to exit (`wait $!`: a JVM that failed —
another JDK's `java`, say — ends the line with its own exit code, never with a count), and prints the POST's status, its Location
(`none` when it has none), the fetch's status and the name the fetch got back (`none` when it got nothing). The whole log is
`.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM is needed for that, but
Docker must answer, with `eclipse-temurin:25-jre` on it: the script checks both before its first build; without `GRAALVM_HOME` it
fills `.m2-demo`, makes every capture that needs none — this exercise's among them — and stops before the native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
(cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19399 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19399/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o /dev/null -H 'Content-Type: application/json' --data '{"name":"Sunil K","mealsPerDay":1,"pricePerMeal":130,"mealType":"VEG"}' http://127.0.0.1:19399/customers; l=$(grep -i '^location:' ../head.txt | sed 's/^[^:]*: *//' | tr -d '\r'); rm -f ../got.json; f=$(curl -s -o ../got.json -w '%{http_code}' 'http://127.0.0.1:19399/customers/Sunil K'); ../../../harness/shutdown.sh 19399 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && g=$(grep -o '"name":"[^"]*"' ../got.json 2> /dev/null | sed 's/^"name":"//; s/"$//') && echo "POST: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · Location: ${l:-none} · fetch: $f · got: ${g:-none}")
```

As shipped, it prints `POST: 201 · Location: http://127.0.0.1:19399/customers/Sunil%20K · fetch: 000 · got: none`: TiffinBox
stored Sunil K and said where he is, but the fetch never left curl — the URL it was given holds a raw space, which no URL may hold,
so curl refused it (its exit code 3, a malformed URL) and there was no answer to save. Read the Location the POST printed, give the
last line's fetch that URL — the line already holds it, in `l` — and run it again from the same shell.

**Done** when you can print

```
POST: 201 · Location: http://127.0.0.1:19399/customers/Sunil%20K · fetch: 200 · got: Sunil K
```

— the customer fetched by the URL TiffinBox handed back, his space encoded as `%20`, which reaches the route as a space again (the
binding lesson measured that: `../c6-unit07/`, `path`). The same line is in this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as
written: `solution/SOLUTION.md`.

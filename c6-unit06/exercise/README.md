# Exercise — the Allow header

**Your turn:** the README's request gets a 405. Read the Allow header, change the verb, and count the customers.

Since this lesson TiffinBox's routes are Spring MVC's own request mappings, each with its verb: `@GetMapping("/customers")` takes
GET (and HEAD), nothing else. A request with another verb never reaches TiffinBox's method: Spring MVC answers it itself, with a
405 and an `Allow` header that names the verbs the path does take.

Run everything from `c6-unit06/`, in one shell. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give it a config tree with a token of its
own — 26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable
by you alone, never printed — and build the jar offline against this unit's `.m2-demo`. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit06/` for the next run: it starts TiffinBox from the copy's folder on
`127.0.0.1:19359`, waits until readiness answers 200, sends one request to `/customers` (its status line and headers saved to
`../head.txt`, its body to `../body.txt`), stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the
copy's own file), waits for that JVM to exit (`wait $!`: a JVM that failed — another JDK's `java`, say — ends the line with its own
exit code, never with a count), and prints the request's status, its `Allow` header (`none` when there is none) and how many
customers its body holds. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM is needed for that:
without `GRAALVM_HOME` it fills `.m2-demo`, makes every capture that needs none — this exercise's among them — and stops before
the native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
(cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19359 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19359/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -X DELETE -D ../head.txt -o ../body.txt http://127.0.0.1:19359/customers; ../../../harness/shutdown.sh 19359 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && a=$(tr -d '\r' < ../head.txt | sed -n 's/^Allow: //p') && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · Allow: ${a:-none} · customers: $(grep -o '"name"' ../body.txt | wc -l | tr -d ' ')")
```

As shipped, it prints `status: 405 · Allow: GET · customers: 0`: the request's verb is not one `/customers` takes, so Spring MVC
answered it, and TiffinBox's method never ran. Read the `Allow` header, change the last line — its verb — and run it again from
the same shell.

**Done** when you can print

```
status: 200 · Allow: none · customers: 4
```

— the verb the header named, and the four customers TiffinBox's method returned. The same line is in this unit's `exercise`
capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

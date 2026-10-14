# Exercise — the meal type, as Spring reads it

**Your turn:** ask for the vegan customers. The README's request answers 400. Find why in the log, fix the URL, and count them.

Since this lesson `GET /customers` takes a request parameter: `@RequestParam(required = false) MealType mealType`. Spring MVC
turns the text after `?mealType=` into a `MealType` before TiffinBox's method runs — and when the text is not one of the enum's
names, the method never runs: Spring MVC answers 400 itself, and logs one WARN line that says why.

Run everything from `c6-unit07/`, in one shell. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give it a config tree with a token of its
own — 26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable
by you alone, never printed — and build the jar offline against this unit's `.m2-demo`. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit07/` for the next run: it starts TiffinBox from the copy's folder on
`127.0.0.1:19369`, waits until readiness answers 200, asks `/customers?mealType=vegan` (its status line and headers saved to
`../head.txt`, its body to `../body.txt`), stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the
copy's own file), waits for that JVM to exit (`wait $!`: a JVM that failed — another JDK's `java`, say — ends the line with its own
exit code, never with a count), and prints the request's status, how many customers its body holds (and their names), and the
conversion failure the log names — the reason in Spring MVC's WARN line for a value it could not convert (`none` when there is none). The whole log is `.harness/mine/run.log`. On a fresh clone
`.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM is needed for that, but Docker must answer, with `eclipse-temurin:25-jre` on it: the
script checks both before its first build; without `GRAALVM_HOME` it fills `.m2-demo`, makes every capture that needs none — this
exercise's among them — and stops before the native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
(cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19369 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19369/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt 'http://127.0.0.1:19369/customers?mealType=vegan'; ../../../harness/shutdown.sh 19369 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"name":"[^"]*"' ../body.txt | sed 's/^"name":"//; s/"$//' | paste -sd' ' -) && w=$(grep -m1 -o "Failed to convert value of type [^;]*" ../run.log || true) && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · customers: $(grep -o '"name":"' ../body.txt | wc -l | tr -d ' ')${n:+ ($n)} · conversion failure: ${w:-none}")
```

As shipped, it prints `status: 400 · customers: 0 · conversion failure: Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'`:
the text `vegan` is not a name `MealType` has, so Spring MVC refused the request before TiffinBox's method ran. Read the WARN line,
compare it with `MealType`'s names (`tiffinbox-core/src/main/java/com/tiffinbox/MealType.java`), change the last line's URL, and
run it again from the same shell.

**Done** when you can print

```
status: 200 · customers: 1 (Priya) · conversion failure: none
```

— the one vegan customer TiffinBox's method returned, and nothing logged. The same line is in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

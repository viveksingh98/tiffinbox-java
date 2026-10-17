# Exercise — a key Boot never read

**Your turn:** the README's copy still answers a missing path with Boot's four keys. Find the misspelt key, fix it, and read the content type.

Since this lesson TiffinBox's `application.yaml` holds one key more, `spring.mvc.problemdetails.enabled: true`, and Spring MVC's own
errors — a path nobody maps among them — answer as problem details, `application/problem+json`. The course's harness ships a copy of
that file without the key, `harness/exercise/application.yaml` (the previous lesson's, byte for byte), and a developer's own settings
file, `harness/exercise/tiffinbox-local.yaml`, that asks for problem details instead: TiffinBox's `application.yaml` imports
`optional:file:./tiffinbox-local.yaml` from the folder TiffinBox starts in.

Run everything from `c6-unit16/`, in one shell. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), put the harness's two files in place, and give the
copy a config tree with a token of its own — 26 random hexadecimal digits (`openssl rand -hex 13`), in
`.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit16/` for the next run: it builds the copy offline against this unit's `.m2-demo`, starts
it from the copy's folder — where `tiffinbox-local.yaml` now is — on `127.0.0.1:19459` (the JVM's locale pinned,
`-Duser.language=en -Duser.country=US`), waits until readiness answers 200, asks for `/nowhere` — curl's own `Accept: */*` — keeping
the status and the content type, stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file),
waits for that JVM to exit (`wait "$p"`, the pid it saved: a JVM that failed — another JDK's `java`, say — ends the line with its own
exit code, never with a status, and so does a build that failed: no JVM, no pid), and prints them. The whole log is
`.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM is needed for that, but
Docker must answer, with `eclipse-temurin:25-jre` on it: the script checks both before its first build; without `GRAALVM_HOME` it
fills `.m2-demo`, makes every capture that needs none — this exercise's among them — and stops before the native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
cp harness/exercise/application.yaml .harness/mine/after/tiffinbox-web/src/main/resources/application.yaml && cp harness/exercise/tiffinbox-local.yaml .harness/mine/after/tiffinbox-local.yaml
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19459 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19459/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o /dev/null -w '%{http_code} · Content-Type: %{content_type}' http://127.0.0.1:19459/nowhere); ../../../harness/shutdown.sh 19459 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "nowhere: $s")
```

As shipped, it prints `nowhere: 404 · Content-Type: application/json`: Boot's error controller wrote its four keys, as if
`tiffinbox-local.yaml` were not there. Boot read the file — and found no key it knows in it. Nothing in the log says so: Boot never
warns about a key nobody reads. Open the copy's `tiffinbox-local.yaml` (`.harness/mine/after/`), compare its key, letter by letter,
with the one in `after/`'s `application.yaml` (`tiffinbox-web/src/main/resources/`), fix it, and run the last line again from the same
shell. A dash is not the mistake: Boot reads `problem-details` as `problemdetails` (this unit's `losers` capture measures both).

**Done** when you can print

```
nowhere: 404 · Content-Type: application/problem+json
```

— the same status, in RFC 9457's shape. The same line is in this unit's `exercise` capture (`.r-exercise.out`). The measured answer,
run exactly as written: `solution/SOLUTION.md`.

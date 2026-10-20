# Exercise — an HTML page where you wanted JSON

**Your turn:** the README's request gets an HTML page, not JSON. Read its Content-Type, change one header, and read the Content-Type again.

TiffinBox — the tree the validation lesson left, `anchor/` here (the link to `../c6-unit12/after`) — answers a name nobody has with a
404 written by Boot's error controller, and that controller picks the answer's type from the request's `Accept` header: the types the
client says it can read. A browser's header asks for HTML first, so Boot sends its Whitelabel page; curl's own `Accept: */*` gets JSON.

Run everything from `c6-unit14/`, in one shell. The commands below copy the anchor to `.harness/mine/anchor` (git-ignored;
`receipts.sh` wipes `.harness/` when it runs) and give the copy a config tree with a token of its own — 26 random hexadecimal digits
(`openssl rand -hex 13`), in `.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed. Its last line
runs in a subshell (the parentheses), so your shell stays in `c6-unit14/` for the next run: it builds the copy offline against this
unit's `.m2-demo`, starts it from the copy's folder on `127.0.0.1:19439` (the JVM's locale pinned, `-Duser.language=en
-Duser.country=US`), waits until readiness answers 200, asks for a customer nobody has with the header a browser leads with —
`Accept: text/html` — and saves the answer to `../got.txt`, stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read
from the copy's own file), waits for that JVM to exit (`wait "$p"`, the pid it saved: a JVM that failed — another JDK's `java`, say —
ends the line with its own exit code, never with a status, and so does a build that failed: no JVM, no pid), and prints the status and
the answer's `Content-Type`. The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh`
once first.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && rm -f ../got.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19439 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19439/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.txt -w '%{http_code} · Content-Type: %{content_type}' -H 'Accept: text/html' http://127.0.0.1:19439/customers/Nobody); ../../../harness/shutdown.sh 19439 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "status: $s")
```

As shipped, it prints `status: 404 · Content-Type: text/html;charset=UTF-8`, and `.harness/mine/got.txt` is Boot's Whitelabel page —
a heading, a sentence, a date and the status, no customer and no reason. A script that parses the answer as JSON fails on it. Change one
header in the last line so the request asks for what a program reads, and run that line again from the same shell.

**Done** when you can print

```
status: 404 · Content-Type: application/json
```

— the same status, and Boot's four keys in `got.txt`: `timestamp`, `status`, `error`, `path`. The same line is in this unit's
`exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

# Exercise — one customer as XML, and the header that asks for it

**Your turn:** the README asks for one customer as XML but gets JSON. Find the wrong header, fix it, and read the root element.

Since this lesson a copy of TiffinBox can write XML: Jackson's XML module is on its class path, and Spring MVC's seventh message
converter writes XML for any request whose `Accept` header asks for it. Two headers name a format, and they point opposite ways:
**`Content-Type`** says what the body *you send* is; **`Accept`** says what you *want back*. A GET sends no body, so nothing reads its
`Content-Type` — TiffinBox's route takes no body — and with no `Accept` header curl sends its own, `*/*` (anything), which TiffinBox
answers in JSON, the first format its converters offer.

Run everything from `c6-unit11/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the responses lesson froze —
to `.harness/mine/xml` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), add Jackson's XML module with this unit's patch
(`harness/xml.patch`: one dependency line in the web module's POM, no version), give the copy a config tree with a token of its own —
26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/xml/secrets/tiffinbox/shutdown-token`, readable by you
alone, never printed — and build the jar offline against this unit's `.m2-demo`. Its last line runs in a subshell (the parentheses),
so your shell stays in `c6-unit11/` for the next run: it starts TiffinBox from the copy's folder on `127.0.0.1:19409`, waits until
readiness answers 200, asks for Ravi with one header (the answer saved to `../got.txt`), stops TiffinBox with POST /shutdown
(`harness/shutdown.sh`, the token read from the copy's own file), waits for that JVM to exit (`wait $!`: a JVM that failed — another
JDK's `java`, say — ends the line with its own exit code, never with an answer), and prints the status, the answer's `Content-Type`,
and the name of its **root element** — the outermost XML element, the one that holds all the others (`none` when the answer is not
XML). The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM
and no Docker are needed: its first two builds fill `.m2-demo`, the XML module's four files among them).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/xml/ && (cd .harness/mine/xml && patch -s -p1 < ../../../harness/xml.patch)
mkdir -p .harness/mine/xml/secrets/tiffinbox && chmod 700 .harness/mine/xml/secrets .harness/mine/xml/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/xml/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/xml && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
(cd .harness/mine/xml && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19409 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19409/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && t=$(curl -s -o ../got.txt -w '%{http_code} · %{content_type}' -H 'Content-Type: application/xml' http://127.0.0.1:19409/customers/Ravi); ../../../harness/shutdown.sh 19409 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && r=$(sed -n 's/^<\([A-Za-z]*\)>.*/\1/p' ../got.txt) && echo "GET /customers/Ravi: $t · root element: ${r:-none}")
```

As shipped, it prints `GET /customers/Ravi: 200 · application/json · root element: none`: TiffinBox answered, but in JSON — the
header the line sends says what the body it sends is, and a GET sends none, so nothing read it, and nothing asked for XML. Give the
last line's curl the header that says what you want back instead, and run it again from the same shell.

**Done** when you can print

```
GET /customers/Ravi: 200 · application/xml;charset=UTF-8 · root element: Customer
```

— Ravi in XML, his root element named after the type the route returns, TiffinBox's `Customer` record. The same line is in this
unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

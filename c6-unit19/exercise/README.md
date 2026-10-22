# Exercise — the preflight that comes back empty

**Your turn:** the README's preflight comes back with no CORS headers. Find the filter that answers every preflight, remove it, and ask again.

`exercise/KitchenCors.java` is a small piece of the kitchen: a route, `/kitchen/menu`, that a page on one other origin —
`http://127.0.0.1:19486` — may read and `PUT` to (`@CrossOrigin`), and, for the kitchen's admin pages, a CORS rule of their own. A
browser asks before that `PUT`: an `OPTIONS` request, a **preflight**, naming the origin, the method and the header it wants to send. The
answer must name the origin back (`Access-Control-Allow-Origin`), or the browser never sends the `PUT`.

Run everything from `c6-unit19/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the problem-detail lesson made —
to `.harness/mine/anchor` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), copy the class to `.harness/mine/KitchenCors.java`
(the file you edit), and give the copy a config tree with a token of its own — 26 random hexadecimal digits (`openssl rand -hex 13`), in
`.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit19/` for the next run: it builds the copy offline against this unit's `.m2-demo`, extracts
its jar, compiles `.harness/mine/KitchenCors.java` against it (into `.harness/mine/hc`), starts TiffinBox on its class path with the class
joined (`--spring.main.sources=probe.web.KitchenCors`) on `127.0.0.1:19488` (the JVM's locale pinned, `-Duser.language=en
-Duser.country=US`), waits until readiness answers 200, sends the menu's preflight with curl — keeping the status and the two CORS headers
a browser reads first — stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file), waits for
that JVM to exit (`wait "$p"`, the pid it saved: a JVM that failed — another JDK's `java`, say — ends the line with its own exit code,
never with an answer, and so does a build that failed), and prints the answer. The whole log is `.harness/mine/run.log`. On a fresh clone
`.m2-demo` is empty: run `./receipts.sh` once first (no browser is needed for this exercise: curl asks the question a browser would).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/ && cp exercise/KitchenCors.java .harness/mine/KitchenCors.java
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../KitchenCors.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19488 --spring.main.sources=probe.web.KitchenCors > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19488/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} · Access-Control-Allow-Origin: [%header{access-control-allow-origin}] · Access-Control-Max-Age: [%header{access-control-max-age}]' -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19488/kitchen/menu); ../../../harness/shutdown.sh 19488 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the preflight: $a")
```

As shipped, it prints `the preflight: 200 · Access-Control-Allow-Origin: [] · Access-Control-Max-Age: []` — a two hundred with no CORS
header at all: a browser reads that as a refusal, and the `PUT` never leaves it. Something in `.harness/mine/KitchenCors.java` answers the
preflight before the `@CrossOrigin` route is ever asked. Find it, remove it, and run the last line again from the same shell.

**Done** when you can print

```
the preflight: 200 · Access-Control-Allow-Origin: [http://127.0.0.1:19486] · Access-Control-Max-Age: [1800]
```

— the route's own rule answering: the origin named back, and a max age nobody set (`@CrossOrigin`'s default). The same line is in this
unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

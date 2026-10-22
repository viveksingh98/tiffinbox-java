# Exercise — the menu that is too big

**Your turn:** the README's menu upload answers four thirteen. Read the limit's key, raise it, and upload again.

`exercise/MenuDesk.java` is the kitchen's menu desk: a route, `POST /kitchen/menu`, that takes one part named `menu` — a **multipart
request**, the way `curl -F` sends a file — and answers with the file's name and its size. Nothing in the class sets a limit. The limits
are Boot's: it reads them from Spring's environment when TiffinBox starts and hands them to Tomcat, which refuses a part, or a whole
request, that is too big — before the route is ever asked.

Run everything from `c6-unit20/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the problem-detail lesson made —
to `.harness/mine/anchor` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), copy the class to `.harness/mine/MenuDesk.java`,
make this week's menu — 1,500,000 bytes, one letter repeated, in `.harness/mine/menu.txt` — and give the copy a config tree with a token
of its own — 26 random hexadecimal digits (`openssl rand -hex 13`), in `.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by
you alone, never printed. Its last line runs in a subshell (the parentheses), so your shell stays in `c6-unit20/` for the next run: it
builds the copy offline against this unit's `.m2-demo`, extracts its jar, compiles `.harness/mine/MenuDesk.java` against it (into
`.harness/mine/hc`), starts TiffinBox on its class path with the class joined (`--spring.main.sources=probe.web.MenuDesk`) on
`127.0.0.1:19499` (the JVM's locale pinned, `-Duser.language=en -Duser.country=US`), waits until readiness answers 200, sends the menu
with curl — keeping the status and the content type — stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the
copy's own file), waits for that JVM to exit (`wait "$p"`, the pid it saved: a JVM that failed — another JDK's `java`, say — ends the line
with its own exit code, never with an answer, and so does a build that failed), and prints the answer. TiffinBox starts in
`.harness/mine/anchor`, so it reads a `tiffinbox-local.yaml` there if one exists (the anchor's `application.yaml` imports it, optionally).
The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM, no Docker and
no browser are needed).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/ && cp exercise/MenuDesk.java .harness/mine/MenuDesk.java
head -c 1500000 /dev/zero | tr '\0' 'm' > .harness/mine/menu.txt
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../MenuDesk.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19499 --spring.main.sources=probe.web.MenuDesk > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19499/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} %{content_type}' -F 'menu=@../menu.txt' http://127.0.0.1:19499/kitchen/menu); ../../../harness/shutdown.sh 19499 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the menu: $a")
```

As shipped, it prints `the menu: 413 application/problem+json` — Content Too Large, as a problem detail, and not a line in the log: the
menu is bigger than the limit Boot gave Tomcat for one file. Find that limit's key — Boot's own metadata names it, with its default (this
unit's `limits` capture lists all seven keys under `spring.servlet.multipart.`) — and raise it for the copy: in a
`.harness/mine/anchor/tiffinbox-local.yaml` of your own, or however you like to set a key. Spring reads a size like `2MB` with 1,024 × 1,024
bytes to the megabyte. Then run the last line again from the same shell.

**Done** when you can print

```
the menu: 200 application/json
```

— the route answered: the menu came in whole. The same line is in this unit's `exercise` capture (`.r-exercise.out`). The measured
answer, run exactly as written: `solution/SOLUTION.md`.

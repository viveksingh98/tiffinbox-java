# Exercise — a stylesheet the server calls unchanged

**Your turn:** the README's new stylesheet still gets three oh four. Switch on content versioning, read the page's link, and ask again.

Since this lesson TiffinBox names its stylesheet by its content: `application.yaml` switches on Boot's content version strategy, and
every page links `/css/tiffinbox-<md5>.css`, the md5 of the file itself. A developer's own file can still switch it off — and this
copy's does. The commands below copy TiffinBox — `after/`, the tree this lesson made — to `.harness/mine/after` (git-ignored;
`receipts.sh` wipes `.harness/` when it runs), put the course's new stylesheet in place of the copy's (`harness/newbuild/tiffinbox.css`:
TiffinBox's with one line added, `footer { color: #555; }`), write the copy a `tiffinbox-local.yaml` — the developer's own file, read
from the folder TiffinBox starts in, which beats `application.yaml` — that turns the strategy off, and give the copy a config tree with a
token of its own — 32 random hexadecimal digits (`openssl rand -hex 16`), in `.harness/mine/after/secrets/tiffinbox/shutdown-token`,
readable by you alone, never printed.

Your browser already holds the old build's stylesheet, kept at `/css/tiffinbox.css`, with the date that build sent: `Last-Modified:
Tue, 15 Sep 2026 00:00:00 GMT` — every build's date, the root POM's fixed build time. The last line asks for the stylesheet the way that
browser would. It runs in a subshell (the parentheses), so your shell stays in `c6-unit23/` for the next run: it builds the copy offline
against this unit's `.m2-demo`, starts it from the copy's folder on `127.0.0.1:19528` (the JVM's locale pinned, `-Duser.language=en
-Duser.country=US`), waits until readiness answers 200, asks for the dashboard as a page and reads its stylesheet's link, then asks for
that link — the link it kept with the kept date (`If-Modified-Since`), any other link plainly: a link it never kept, it has nothing to
ask about — keeping the stylesheet in `.harness/mine/css.out`. It stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token
read from the copy's own file), waits for that JVM to exit (`wait "$p"`, the pid it saved: a JVM that failed — another JDK's `java`,
say — ends the line with its own exit code, and so does a build that failed: no JVM, no pid), and prints the link, the status and the
bytes the answer carried. The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once
first (no GraalVM, Chrome or node is needed for that, but Docker must answer, with `eclipse-temurin:25-jre` on it: the script checks
both before its first build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
cp harness/newbuild/tiffinbox.css .harness/mine/after/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
printf 'spring.web.resources.chain.strategy.content.enabled: false\n' > .harness/mine/after/tiffinbox-local.yaml
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 16 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19528 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19528/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && c=$(curl -s -H 'Accept: text/html' http://127.0.0.1:19528/dashboard | grep -o '/css/[^"]*') && if [ "$c" = /css/tiffinbox.css ]; then s=$(curl -s -o ../css.out -w '%{http_code} · %{size_download} bytes' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' "http://127.0.0.1:19528$c"); else s=$(curl -s -o ../css.out -w '%{http_code} · %{size_download} bytes' "http://127.0.0.1:19528$c"); fi; ../../../harness/shutdown.sh 19528 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the stylesheet: $c · $s")
```

As shipped, it prints `the stylesheet: /css/tiffinbox.css · 304 · 0 bytes`: the page still links the plain name, the stylesheet's
date is the build's fixed time — the same in the old build and this one — so the server answers "not modified", and your browser
keeps the old file. Find the key the copy's `tiffinbox-local.yaml` sets, switch content versioning on in that
file (`.harness/mine/after/tiffinbox-local.yaml`), and run the last line again from the same shell.

**Done** when you can print

```
the stylesheet: /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css · 200 · 224 bytes
```

— a name your browser never kept, so it asks plainly and gets the new file whole: 224 bytes, the footer rule among them. The md5 in
the name is the new stylesheet's own (`md5 -q harness/newbuild/tiffinbox.css`). The same line is in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

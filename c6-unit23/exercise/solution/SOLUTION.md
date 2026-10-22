# Solution — a stylesheet the server calls unchanged

Run from `c6-unit23/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot build or run this jar: the
line ends with an exit code and prints nothing). Then the fix — the copy's `tiffinbox-local.yaml` sets
`spring.web.resources.chain.strategy.content.enabled: false`; `false` becomes `true` (written to a new file and moved back, so it
runs the same on macOS and Linux; run twice, the second finds nothing to change) — and the README's last line again, exactly as
written: it builds the copy again, starts it, asks, stops it.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
f=.harness/mine/after/tiffinbox-local.yaml && sed 's/content\.enabled: false/content.enabled: true/' "$f" > "$f.new" && mv "$f.new" "$f"
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19528 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19528/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && c=$(curl -s -H 'Accept: text/html' http://127.0.0.1:19528/dashboard | grep -o '/css/[^"]*') && if [ "$c" = /css/tiffinbox.css ]; then s=$(curl -s -o ../css.out -w '%{http_code} · %{size_download} bytes' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' "http://127.0.0.1:19528$c"); else s=$(curl -s -o ../css.out -w '%{http_code} · %{size_download} bytes' "http://127.0.0.1:19528$c"); fi; ../../../harness/shutdown.sh 19528 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the stylesheet: $c · $s")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit23/`):

```
the stylesheet: /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css · 200 · 224 bytes
```

The date never moved — every build of this project stamps the same one — so a question asked by date gets "not modified" for a file
that did change. A name made from the file's content changes when the file does: the page links the new name, the browser has never
kept it, and it fetches the new file whole. Removing the line from `tiffinbox-local.yaml` works too: `application.yaml`'s own key is on.

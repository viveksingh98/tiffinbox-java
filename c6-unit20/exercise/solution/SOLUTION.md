# Solution — the menu that is too big

Run from `c6-unit20/`, after `exercise/README.md`'s commands — in the same shell, or in a new one: the README's two `export` lines
come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot run this jar: the JVM stops at
once, and `wait "$p"` ends the line with its exit code). The key is `spring.servlet.multipart.max-file-size` — Boot's metadata gives its
default as `1MB`, which Spring reads as 1,048,576 bytes; the menu is 1,500,000. One line in the copy's `tiffinbox-local.yaml` raises it to
`2MB` (2,097,152 bytes) — `application.yaml` imports that file from the folder TiffinBox starts in. Then the README's last line again,
unchanged: nothing in `MenuDesk.java` changes. Writing the same file twice gives the same file, so run twice they print the same.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
printf 'spring.servlet.multipart.max-file-size: 2MB\n' > .harness/mine/anchor/tiffinbox-local.yaml
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../MenuDesk.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19499 --spring.main.sources=probe.web.MenuDesk > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19499/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} %{content_type}' -F 'menu=@../menu.txt' http://127.0.0.1:19499/kitchen/menu); ../../../harness/shutdown.sh 19499 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the menu: $a")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit20/`):

```
the menu: 200 application/json
```

The same key passed as an option (`--spring.servlet.multipart.max-file-size=2MB` on the java line) does the same: this unit's `limit`
capture measures it (B). A menu over ten mebibytes still gets the 413 under that key — the request has a limit of its own,
`spring.servlet.multipart.max-request-size` (`limit` C).

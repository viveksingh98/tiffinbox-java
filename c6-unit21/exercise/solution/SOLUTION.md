# Solution — the feed that answers five oh three

Run from `c6-unit21/`, after `exercise/README.md`'s commands — in the same shell (the README's `N` lives in that shell), or in a new one:
the README's two `export` lines come first here too, because a bare `java` may be another JDK (on the author's Mac it is 23, which cannot
run this jar: the JVM stops at once, and `wait "$p"` ends the line with its exit code). The key is `spring.mvc.async.request-timeout`, two
seconds in the copy's `tiffinbox-local.yaml`: it gives every stream two seconds in all, counted from the request, and one that has sent
nothing by then is answered `503`. The feed was asked for no
orders (`N=0`), so it never sent a thing. Ask for three — `N=3` — and the feed sends three events and ends the stream itself: the answer below is a
`200` with all three. (A stream still sending when its two seconds are up is cut, and curl sees a clean end, exit 0, that it cannot tell
from a finished feed: this unit's `committed` capture.) Then the README's last line again, unchanged: nothing in `KitchenFeed.java` or the key changes. Run twice, it
prints the same.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
N=3
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../KitchenFeed.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19509 --spring.main.sources=probe.web.KitchenFeed > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19509/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -N -o ../feed.txt -w '%{http_code} %{content_type}' "http://127.0.0.1:19509/kitchen/feed?orders=$N"); ../../../harness/shutdown.sh 19509 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the feed: $a · events: $(grep -c '^data:' ../feed.txt)")
```

Measured (this unit's `exercise` capture, `receipts.sh` — run in the same shell as the README's commands, which left it in
`c6-unit21/`):

```
the feed: 200 text/event-stream · events: 3
```

Removing the key instead does not make the zero-order feed work: it waits the container's own timeout — Tomcat's connector reads
30000 ms (this unit's `timeout` capture, A) — and answers the same `503`. A stream that sends nothing is answered by its timeout, whatever
the timeout is.

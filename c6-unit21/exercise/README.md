# Exercise — the feed that answers five oh three

**Your turn:** the README's feed answers five oh three, after the key's two seconds, not thirty. Ask for three orders, and count the events.

`exercise/KitchenFeed.java` is a kitchen feed: a route, `GET /kitchen/feed?orders=N`, that answers with **server-sent events** — a
`text/event-stream` that stays open while its own clock sends one event every 200 ms, each naming the next of TiffinBox's customers, `N`
of them, and then ends the stream. Asked for none, it sends nothing, and the stream waits — until the request's timeout, which the class
does not set. Boot's timeout key for Spring MVC, `spring.mvc.async.request-timeout`, sets it; unset, the container's default applies.

Run everything from `c6-unit21/`, in one shell. The commands below copy TiffinBox — `anchor/`, the tree the problem-detail lesson made —
to `.harness/mine/anchor` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), copy the class to `.harness/mine/KitchenFeed.java`,
give the copy a config tree with a token of its own — 26 random hexadecimal digits (`openssl rand -hex 13`), in
`.harness/mine/anchor/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed — write the timeout key into the copy's
`.harness/mine/anchor/tiffinbox-local.yaml` (the anchor's `application.yaml` imports that file, optionally, from the folder TiffinBox starts
in), and ask for `N=0` orders. Its last line runs in a subshell (the parentheses), so your shell stays in `c6-unit21/` for the next run: it
builds the copy offline against this unit's `.m2-demo`, extracts its jar, compiles `.harness/mine/KitchenFeed.java` against it (into
`.harness/mine/hc`), starts TiffinBox on its class path with the class joined (`--spring.main.sources=probe.web.KitchenFeed`) on
`127.0.0.1:19509` (the JVM's locale pinned, `-Duser.language=en -Duser.country=US`), waits until readiness answers 200, asks for the feed with
curl — `-N`, curl's `--no-buffer`: print what arrives as it arrives — keeping the status, the content type and the stream (in
`.harness/mine/feed.txt`), stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file), waits for
that JVM to exit (`wait "$p"`, the pid it saved: a JVM that failed — another JDK's `java`, say — ends the line with its own exit code, never
with an answer, and so does a build that failed), and prints the answer and how many events the stream carried (its `data:` lines). The
whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM, no Docker and no
browser are needed).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/ && cp exercise/KitchenFeed.java .harness/mine/KitchenFeed.java
mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
(umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
printf 'spring.mvc.async.request-timeout: 2s\n' > .harness/mine/anchor/tiffinbox-local.yaml
N=0
M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../KitchenFeed.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19509 --spring.main.sources=probe.web.KitchenFeed > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19509/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -N -o ../feed.txt -w '%{http_code} %{content_type}' "http://127.0.0.1:19509/kitchen/feed?orders=$N"); ../../../harness/shutdown.sh 19509 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the feed: $a · events: $(grep -c '^data:' ../feed.txt)")
```

As shipped, it prints `the feed: 503 application/problem+json · events: 0` — Service Unavailable, as a problem detail: the stream
waited, nothing was sent, and the request's timeout ran out first. Find that key — the copy's `tiffinbox-local.yaml` holds it (this unit's
`timeout` capture reads it three ways: Spring's environment, Tomcat's connector, the request's own async context) — then ask the feed for
three orders, from the same shell, and run the last line again.

**Done** when you can print

```
the feed: 200 text/event-stream · events: 3
```

— the stream carried three events and ended before the timeout. The same line is in this unit's `exercise` capture (`.r-exercise.out`).
The measured answer, run exactly as written: `solution/SOLUTION.md`.

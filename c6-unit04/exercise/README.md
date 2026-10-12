# Exercise — two pool threads, eight slow requests

**Your turn:** start TiffinBox with virtual threads off and two pool threads, send eight slow requests, and count the threads
that answered.

Since this lesson TiffinBox answers on embedded Tomcat, and `application.yaml` switches virtual threads on: each request gets a
virtual thread of its own. `--server.tomcat.threads.max=2` caps Tomcat's pool of platform threads at two — but that pool only
answers while virtual threads are off.

Run everything from `c6-unit04/`. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), give it a config tree with a token of its
own — 26 random lowercase letters and digits, in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable by you alone,
never printed — build the jar offline against this unit's `.m2-demo`, extract it, and compile the course's harness
(`harness/probe/web/Threads.java`, outside `com.tiffinbox`: its `/probe/slow` answers after half a second with the name of
the thread that answered). Its last line starts TiffinBox on the extracted jar's class path with the harness joined
(`--spring.main.sources=probe.web.Threads`), on `127.0.0.1:19339`, waits until readiness answers 200, sends eight slow requests
at once (`harness/slow8.sh`), stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own
file), waits for it to exit, and counts the threads that answered. On a fresh clone `.m2-demo` is empty: run `./receipts.sh`
once first (no GraalVM is needed for that: without `GRAALVM_HOME` it fills `.m2-demo`, makes every capture that needs none —
this exercise's among them — and stops before the native build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
javac -d .harness/mine/hc -cp ".harness/mine/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Threads.java
cd .harness/mine/after && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19339 --spring.main.sources=probe.web.Threads --server.tomcat.threads.max=2 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19339/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && ../../../harness/slow8.sh 19339 > ../slow.txt && ../../../harness/shutdown.sh 19339 secrets/tiffinbox/shutdown-token > /dev/null && wait && echo "threads that answered: $(sort -u ../slow.txt | wc -l | tr -d ' ')"
```

As shipped, it prints `threads that answered: 8`: the pool is capped, and nothing used it. Change the last line — one option —
so that the pool answers.

**Done** when you can print

```
threads that answered: 2
```

— eight answers, two threads: the pool's two platform threads took turns. The same line is in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

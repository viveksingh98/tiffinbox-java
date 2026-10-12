# Exercise — virtual threads, and the frames that leave

**Your turn:** add one option that switches on virtual threads, ask the harness route again, and count the frames. Name the ones that left.

The video asked one question of Spring MVC's server, on a copy of TiffinBox with Spring MVC beside its own server: who called
the harness's method? The harness's `@RestController` (`harness/probe/path/Stack.java`, outside `com.tiffinbox`) answers
`GET /probe/stack` with its own stack — the thread it ran on, whether that thread is virtual, and every frame the JDK's stack
walker shows. On Tomcat's default thread pool that was 45 frames, with `java.lang.Thread.run` at the bottom.

Run everything from `c6-unit01/`. The commands below copy TiffinBox — `anchor/`, a link to `../c5-unit27/after`, the last
course's final tree, unchanged — to `.harness/mine/mvc` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), put this
unit's `mvc/tiffinbox-web/pom.xml` over its web module's POM (Spring MVC's starter added, the Boot plugin's two Jackson 3
excludes dropped), give it a config tree with a token of its own — 26 random lowercase letters and digits, in
`.harness/mine/mvc/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed — build it offline against this unit's
`.m2-demo`, unpack the jar (Boot's own `extract`), and compile the harness against it into `.harness/mine/hc`. On a fresh clone
`.m2-demo` is empty: run `./receipts.sh` once first.

The last line starts the copy with the harness joined — TiffinBox's server on `127.0.0.1:19308`, Tomcat on `127.0.0.1:19309`
(always with `--server.address=127.0.0.1`: without it Tomcat listens on every interface) — and **an option meant to switch
virtual threads on**. It waits until Tomcat's readiness answers 200, asks the harness route, saves the answer in
`.harness/mine/stack.txt`, stops the JVM by its process id, and prints the count and the bottom frame.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/mvc/ && cp mvc/tiffinbox-web/pom.xml .harness/mine/mvc/tiffinbox-web/pom.xml
mkdir -p .harness/mine/mvc/secrets/tiffinbox && chmod 700 .harness/mine/mvc/secrets .harness/mine/mvc/secrets/tiffinbox
(umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/mvc/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/mvc && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
javac -d .harness/mine/hc -cp ".harness/mine/mvc/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/mine/mvc/tiffinbox-web/target/extracted/lib/*" harness/probe/path/Stack.java
(cd .harness/mine/mvc && exec java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19308 --server.address=127.0.0.1 --server.port=19309 --spring.main.sources=probe.path.Stack --spring.threads.virtual.enable=true > run.log 2>&1) & p=$!; for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19309/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; curl -s http://127.0.0.1:19309/probe/stack > .harness/mine/stack.txt; kill $p; wait $p; awk 'NR == 1 { f = $0 } $1 == 1 { b = $2 } END { print f " · the bottom frame: " b }' .harness/mine/stack.txt
```

As shipped, it prints

```
frames the stack walker shows: 45 · the bottom frame: java.lang.Thread.run
```

— still 45, still `Thread.run`: the option did nothing, and the JVM's log (`.harness/mine/mvc/run.log`) holds not one line about
it — no WARN, no ERROR, no line that names it. Find out why, mend the last line, and run it again.

**Done** when the last line prints

```
frames the stack walker shows: 42 · the bottom frame: java.lang.VirtualThread.run
```

— and you can name the frames that left (compare `.harness/mine/stack.txt` from the two runs: save the first one before the
second run overwrites it). Both lines are in this unit's `exercise` capture (`.r-exercise.out`), with the frames that left and
the one that came. The measured answer, run exactly as written: `solution/SOLUTION.md`.

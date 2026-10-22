# Exercise — a session id in the address

**Your turn:** the README's redirect carries the session id in its address. Set one key so only the cookie carries it, and post again.

Since this lesson TiffinBox keeps a session's id in its cookie alone: `application.yaml` sets
`server.servlet.session.tracking-modes: cookie`. A developer's own file can still bring back Tomcat's default — and this copy's does.
The commands below copy TiffinBox — `after/`, the tree this lesson made — to `.harness/mine/after` (git-ignored; `receipts.sh` wipes
`.harness/` when it runs), write the copy a `tiffinbox-local.yaml` — the developer's own file, read from the folder TiffinBox starts in,
which beats `application.yaml` — that sets the tracking modes to `cookie,url`, and give the copy a config tree with a token of its own —
32 random hexadecimal digits (`openssl rand -hex 16`), in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable by you alone,
never printed.

The last line posts the form the way a browser does on its first visit: no cookie yet. It runs in a subshell (the parentheses), so your
shell stays in `c6-unit24/` for the next run: it builds the copy offline against this unit's `.m2-demo`, starts it from the copy's folder
on `127.0.0.1:19538` (the JVM's locale pinned, `-Duser.language=en -Duser.country=US`), waits until readiness answers 200, posts the
form (`--data`: curl sends a form's own type, `application/x-www-form-urlencoded`) and keeps the status and the address the redirect
gives (`%{redirect_url}`) — a session id in it printed as `<id>`, never itself: it is a key to that session. It stops TiffinBox with
POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file), waits for that JVM to exit (`wait "$p"`, the pid it
saved: a JVM that failed — another JDK's `java`, say — ends the line with its own exit code, and so does a build that failed: no JVM, no
pid), and prints the redirect. The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once
first (no GraalVM, Chrome or node is needed for that, but Docker must answer, with `eclipse-temurin:25-jre` on it: the script checks
both before its first build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
printf 'server.servlet.session.tracking-modes: cookie,url\n' > .harness/mine/after/tiffinbox-local.yaml
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 16 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19538 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19538/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o /dev/null -w '%{http_code} · %{redirect_url}' --data 'name=Lata&mealsPerDay=2&pricePerMeal=110&mealType=VEG' http://127.0.0.1:19538/customers | sed -E 's/jsessionid=[0-9A-F]+/jsessionid=<id>/'); ../../../harness/shutdown.sh 19538 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the redirect: $s")
```

As shipped, it prints `the redirect: 302 · http://127.0.0.1:19538/dashboard;jsessionid=<id>`: the form's note made a session, the
client sent no cookie, so Tomcat wrote the session's id into the address too — where a log, a browser's history or a copied link keeps
it. Find the key the copy's `tiffinbox-local.yaml` sets, keep only the cookie in that file
(`.harness/mine/after/tiffinbox-local.yaml`), and run the last line again from the same shell.

**Done** when you can print

```
the redirect: 302 · http://127.0.0.1:19538/dashboard
```

— the same redirect, and the id in its `Set-Cookie` alone. The same line is in this unit's `exercise` capture (`.r-exercise.out`). The
measured answer, run exactly as written: `solution/SOLUTION.md`.

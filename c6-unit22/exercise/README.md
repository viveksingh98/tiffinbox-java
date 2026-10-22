# Exercise — a name the template got wrong

**Your turn:** the README's dashboard answers five hundred with TiffinBox's error page. Find the misspelt name in the template, fix it, and reload.

Since this lesson TiffinBox answers `GET /dashboard` with a page for a client that asks for HTML: `DashboardPage` puts the dashboard's
view in the model as `view`, and `templates/dashboard.html` reads it — `view.customers` for the table's rows. The course's harness ships
a copy of that template with one name misspelt, `harness/exercise/dashboard.html`. A template is read when a page is asked for, not
when TiffinBox starts: the build passes, TiffinBox starts, and only the page fails.

Run everything from `c6-unit22/`, in one shell. The commands below copy TiffinBox — `after/`, the tree this lesson made — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), put the harness's template in place of the copy's,
and give the copy a config tree with a token of its own — 32 random hexadecimal digits (`openssl rand -hex 16`), in
`.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable by you alone, never printed. Its last line runs in a subshell (the
parentheses), so your shell stays in `c6-unit22/` for the next run: it builds the copy offline against this unit's `.m2-demo`, starts
it from the copy's folder on `127.0.0.1:19518` (the JVM's locale pinned, `-Duser.language=en -Duser.country=US`), waits until readiness
answers 200, asks for `/dashboard` as a page (`Accept: text/html`, as a browser ranks it), keeping the status, the content type and the
page in `.harness/mine/page.html`, stops TiffinBox with POST /shutdown (`harness/shutdown.sh`, the token read from the copy's own file),
waits for that JVM to exit (`wait "$p"`, the pid it saved: a JVM that failed — another JDK's `java`, say — ends the line with its own
exit code, never with a status, and so does a build that failed: no JVM, no pid), and prints the status, the content type and the
page's title. The whole log is `.harness/mine/run.log`. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM,
Chrome or node is needed for that, but Docker must answer, with `eclipse-temurin:25-jre` on it: the script checks both before its first
build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
cp harness/exercise/dashboard.html .harness/mine/after/tiffinbox-web/src/main/resources/templates/dashboard.html
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && openssl rand -hex 16 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19518 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19518/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../page.html -w '%{http_code} · %{content_type}' -H 'Accept: text/html' http://127.0.0.1:19518/dashboard); ../../../harness/shutdown.sh 19518 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the dashboard: $s · $(sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' ../page.html)")
```

As shipped, it prints `the dashboard: 500 · text/html;charset=UTF-8 · Something broke · TiffinBox`: Thymeleaf found no property of
that name on the view, the page failed, and Boot's error page for a client that asks for HTML is TiffinBox's own,
`templates/error/5xx.html`. The log says where: Thymeleaf's `TemplateEngine` names the template, the expression and its line, and
Tomcat logs the same failure under the servlet's name — two ERROR lines (`.harness/mine/run.log`). Read the expression it names,
compare it with the view's components (`Dashboard.View`: `customers`, `monthRevenue`, `pausedDays`), fix the copy's template
(`.harness/mine/after/tiffinbox-web/src/main/resources/templates/dashboard.html`), and run the last line again from the same shell.

**Done** when you can print

```
the dashboard: 200 · text/html;charset=UTF-8 · Dashboard · TiffinBox
```

— the page, its table filled. The same line is in this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly
as written: `solution/SOLUTION.md`.

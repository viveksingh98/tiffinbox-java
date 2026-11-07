# Exercise — The Repository You Do Not Write

**Your turn:** the README adds a repository to TiffinBox's core and the application refuses to start. Tell Spring Data where to look.

Run it from this unit's folder (`c7-unit15/`) after `./receipts.sh` has run once: it builds `.harness/after` (the anchor after this
unit's change, copied, its jar extracted — 91 libraries, among them `tiffinbox-core-1.0.0.jar` with TiffinBox's own repository,
`com.tiffinbox.CustomerEntityRepository`). The block copies the exercise's application, `harness/src/probe/q/ex/ExApp.java`, to
`.harness/ex/` and compiles it there: a Spring Boot application with no web server, in its own package, `probe.q.ex` — outside
`com.tiffinbox`, as `TiffinBoxApp` is — that names the entities' package (`@EntityScan("com.tiffinbox")`) and has one runner, `kitchen`,
which needs a `CustomerEntityRepository`. Then one JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`),
its arguments in an array, `A`, so bash and zsh pass each one as one argument; the database is the one Boot makes for itself (H2, in that
JVM's memory). It binds no port and stops on its own. The last line keeps the lines that matter from its log.


```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/q/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^APPLICATION FAILED TO START|^Parameter [0-9].*|^Consider defining.*|^PROBE ready.*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
the JVM: exit 1
Found 0 JPA repository interfaces.
APPLICATION FAILED TO START
Parameter 0 of method kitchen in probe.q.ex.ExApp required a bean of type 'com.tiffinbox.CustomerEntityRepository' that could not be found.
Consider defining a bean of type 'com.tiffinbox.CustomerEntityRepository' in your configuration.
```

The interface is on the class path, compiled and ready — and Spring Data never looked at it: Boot starts its repository scan in the
application class's own package, `probe.q.ex`, found nothing there, and the runner that needs the bean stops the start. The same thing
happens to TiffinBox without its annotation (`../receipts.sh`, capture `scan`, B).

**Done** when the JVM prints `exit 0`, `Found 1 JPA repository interface.` and the runner's `PROBE ready` line. The solution, and what it
prints, is in `SOLUTION.md`.

# Exercise — Lazy Loading and LazyInitializationException

**Your turn:** the README's page lists each customer's paused days and fails outside a transaction. Make it work without open-in-view.

Run it from this unit's folder (`c7-unit29/`) after `./receipts.sh` has run once: it builds `.harness/after` (TiffinBox after this
unit's change, copied, its jar extracted — its libraries are Spring Boot's, Hibernate's and H2's, the ones the block compiles against).
The block copies the exercise's application, `harness/src/probe/u/ex/ExApp.java`, to `.harness/ex/` and compiles it there. It is a
Spring Boot application with no web server, in its own package, `probe.u.ex`, with two entities of its own — `Diner` (a name) and
`Break` (a diner's paused days; a diner's `breaks` are a lazy collection, as TiffinBox's `pauses` are) — on tables Hibernate creates in
this JVM's own H2 database (`ddl-auto=create`, the exercise's own tables, never TiffinBox's). The runner stores four diners and two
breaks — Priya 2 days, Sunil 3 — in one transaction, then asks the service `Page` for each diner's paused days, by name: every diner,
and her breaks summed. One JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an
array, `A`, so bash and zsh pass each one as one argument. It binds no port and stops on its own. The last line keeps the lines that
matter from its log: the transaction manager's lines that create a transaction, and the runner's. H2 only, here; open-in-view is a web
setting, and there is no web here — the fix has to be the read's own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/u/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.u.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(\[[A-Za-z]+\] org\.springframework\.orm\.jpa\.JpaTransactionManager : Creating new transaction with name \[[^]]*\]|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
[main] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.u.ex.Page.store]
PROBE the page threw: org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'probe.u.ex.Diner.breaks' with key '2' (no session)
```

The store committed, then the page threw: `pausedDays()` runs its query with no transaction of its own, so the persistence context
that loaded the diners closed when the query returned, and the first `breaks` read — key `2`, Meera, the first diner by name — is
refused with Hibernate 7.4's own text. `TiffinBox`'s B is the same shape (`../receipts.sh`, `anchor`).

**Done** when the JVM prints `exit 0`, the transaction manager names `probe.u.ex.Page.pausedDays`, and the page prints
`{Meera=0, Priya=2, Ravi=0, Sunil=3}`. The solution, and what it prints, is in `SOLUTION.md`.

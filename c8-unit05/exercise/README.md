# Exercise — JdbcTemplate and NamedParameterJdbcTemplate

**Your turn:** this JdbcTemplate query takes its arguments in the wrong order. Rewrite it with NamedParameterJdbcTemplate so the order cannot matter.

Run it from this unit's folder (`c8-unit05/`) after `./receipts.sh` has run once: the block compiles `Ex05.java` against the jar
the receipt built from the anchor (`.harness/after/`, both Spring Data modules) and needs no Maven and no Docker. `Ex05` starts
TiffinBox with no web server on its default database, H2 in memory, and looks Meera up through the context's `JdbcTemplate` by her
meal type and her name: `… where meal_type = ? and name = ?`. The SQL wants the meal type first; the call passes `"Meera"` first and
`"NON_VEG"` second, so the first `?` gets the name and the second gets the meal type. Both are strings, so neither the driver nor the
database objects; the query simply finds no row, `queryForObject` throws, and the exception ends the program with exit 1. Java runs
under an alarm (`perl -e 'alarm 120; exec …'`, macOS has no `timeout`).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/after/tiffinbox-web/target/extracted"; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
cp exercise/Ex05.java .harness/ex/src/probe/ex/Ex05.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*" .harness/ex/src/probe/ex/Ex05.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*" probe.ex.Ex05) > .harness/ex/run.log 2>&1; echo "Ex05: exit $?"
grep '^EX ' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
Ex05: exit 1
EX lookup Meera threw: org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
EX done: no - the lookup found no row
```

**Done** when the last line says `yes` and the program exits 0: Meera's row comes back, and the call no longer depends on the order
its values are written in. A hint: `Ex05.java` already holds the same SQL with a name for each placeholder, and the context's
`NamedParameterJdbcTemplate`. The solution is in `SOLUTION.md`.

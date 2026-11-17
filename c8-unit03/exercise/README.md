# Exercise — Relationships Without an ORM

**Your turn:** saving Sunil unchanged still deletes his pauses. Make the test print the statement count, then explain each statement in the log.

Run it from this unit's folder (`c8-unit03/`) after `./receipts.sh` has run once: the block compiles `Ex03.java` against the jar
the receipt built from the anchor (`.harness/after/`, both Spring Data modules) and the statement witness's library in `.m2-demo`
(datasource-proxy 1.11.1), and needs no Maven and no Docker. `Ex03` starts TiffinBox with no web server on its default database,
H2 in memory, loads Sunil's aggregate through Spring Data JDBC and saves it with nothing changed. A witness on the `DataSource`
bean keeps the text of every statement the driver received during that save; the test prints each one (sorted: the count matters,
never the order), then the count, then Sunil's pause ids and `version` read back by `JdbcTemplate` — a second client — before and
after. Java runs under an alarm (`perl -e 'alarm 120; exec …'`, macOS has no `timeout`).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/after/tiffinbox-web/target/extracted"; W="$PWD/.m2-demo/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
cp exercise/Ex03.java .harness/ex/src/probe/ex/Ex03.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" .harness/ex/src/probe/ex/Ex03.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" probe.ex.Ex03) > .harness/ex/run.log 2>&1; echo "Ex03: exit $?"
grep '^EX ' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
Ex03: exit 0
EX before, read back by JdbcTemplate (a second client): Sunil pauses 1:3 · version 0
EX Sunil loaded: pauses 1 · nothing changed in Java
EX statement: DELETE FROM pause WHERE pause.customer_id = ?
EX statement: INSERT INTO pause (customer_id, DAYS, ID) VALUES (?, ?, ?)
EX statement: UPDATE customer SET NAME = ?, MEALS_PER_DAY = ?, PRICE_PER_MEAL = ?, MEAL_TYPE = ?, VERSION = ? WHERE customer.ID = ? AND customer.VERSION = ?
EX statement count: 0
EX after, read back by JdbcTemplate (a second client): Sunil pauses 1:3 · version 1
EX done: no - the count misses statements the save sent
```

**Done** when the last line says `yes`: the count is every statement the save sent, and each `EX statement` line is one you can
explain. As shipped the test counts only the statements that start with `SELECT` — and a save of an aggregate that is already
loaded reads nothing. A hint: the witness already holds every statement; the count is one expression away. The solution, and the
statement-by-statement explanation, is in `SOLUTION.md`.

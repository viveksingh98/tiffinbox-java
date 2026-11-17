# Solution — Relationships Without an ORM

The witness keeps every statement the driver received during the save; the test as shipped counted only those starting with
`SELECT`, and the save sends none. Count them all: the block is the README's with one line changed — the copy becomes a `sed` that
turns `SQL.stream().filter(q -> q.startsWith("SELECT")).count()` into `SQL.stream().count()`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/after/tiffinbox-web/target/extracted"; W="$PWD/.m2-demo/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
sed 's/SQL.stream().filter(q -> q.startsWith("SELECT")).count()/SQL.stream().count()/' exercise/Ex03.java > .harness/ex/src/probe/ex/Ex03.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" .harness/ex/src/probe/ex/Ex03.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" probe.ex.Ex03) > .harness/ex/run.log 2>&1; echo "Ex03: exit $?"
grep '^EX ' .harness/ex/run.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
Ex03: exit 0
EX before, read back by JdbcTemplate (a second client): Sunil pauses 1:3 · version 0
EX Sunil loaded: pauses 1 · nothing changed in Java
EX statement: DELETE FROM pause WHERE pause.customer_id = ?
EX statement: INSERT INTO pause (customer_id, DAYS, ID) VALUES (?, ?, ?)
EX statement: UPDATE customer SET NAME = ?, MEALS_PER_DAY = ?, PRICE_PER_MEAL = ?, MEAL_TYPE = ?, VERSION = ? WHERE customer.ID = ? AND customer.VERSION = ?
EX statement count: 3
EX after, read back by JdbcTemplate (a second client): Sunil pauses 1:3 · version 1
EX done: yes - the count is every statement of the save
```

Each statement, in the words of the log (H2 in memory; on PostgreSQL the same statements read with lower-case names — capture
`same`):

- `UPDATE customer SET … VERSION = ? WHERE customer.ID = ? AND customer.VERSION = ?` — the root's row, every column the aggregate
  maps, with the optimistic lock's check of the old value in the `WHERE` (the version read back by `JdbcTemplate` after the save
  is the next one). Nothing changed, and the row is still written: Spring Data JDBC keeps no copy of what it loaded to compare
  against.
- `DELETE FROM pause WHERE pause.customer_id = ?` — every pause row of this customer, gone. The root owns the collection, so the
  save replaces it whole; it never asks which pauses changed.
- `INSERT INTO pause (customer_id, DAYS, ID) VALUES (?, ?, ?)` — Sunil's one pause written back, with the id it was loaded with.
  The id survives: `JdbcTemplate` reads the same pause id before and after, and the version is the one column that moved by its read.

So the unchanged save costs the statements counted above, and the DELETE is in the log every time. The count is the witness's —
the statements the driver received — never the SELECTs alone.

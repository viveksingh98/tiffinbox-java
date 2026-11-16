# Exercise — Flyway: Versioned Migrations

**Your turn:** the README's third migration failed halfway on H2, and every migrate since refuses. Make it apply.

Run it from this unit's folder (`c7-unit36/`) after `./receipts.sh` has run once: it builds `.harness/after` (TiffinBox as this unit
leaves it, copied, its jar extracted — its libraries hold Flyway 12.4.0, H2 and TiffinBox's core jar with its two migrations, V1 and V2).
The block copies the exercise's program, `harness/src/probe/f/ex/Ex.java`, to `.harness/ex/` and compiles it there, and writes a third
migration, `V3__add_phone.sql`, into `.harness/ex/broken/`: two statements, the second one misspelt (`ADD COLUM`). It also writes the same
file with the second statement spelt right into `.harness/ex/fixed/`. The program is Flyway's own API with no Spring, in ONE JVM, on an H2
database in that JVM's memory — no port, no container, never TiffinBox's own database. Each argument in `A` is one step: `migrate`,
`repair`, `cleanup` (it drops the column the failed migration left, by hand, over a plain JDBC connection) or `fixed` (the third
migration is read from `.harness/ex/fixed` from then on). After each step it prints the history table and the customer table's columns,
read over a second plain JDBC connection. The JVM runs under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its
arguments in an array, so bash and zsh pass each one as one argument. The last line keeps the program's lines from its log.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes .harness/ex/broken .harness/ex/fixed && cp harness/src/probe/f/ex/Ex.java .harness/ex/
printf '%s\n' 'ALTER TABLE customer ADD COLUMN phone VARCHAR(20);' 'ALTER TABLE customer ADD COLUM email VARCHAR(80);' > .harness/ex/broken/V3__add_phone.sql
printf '%s\n' 'ALTER TABLE customer ADD COLUMN phone VARCHAR(20);' 'ALTER TABLE customer ADD COLUMN email VARCHAR(80);' > .harness/ex/fixed/V3__add_phone.sql
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/Ex.java
A=(migrate migrate)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.f.ex.Ex "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE version: Flyway 12.4.0
PROBE migrate refused: FlywayMigrateException: Failed to execute script V3__add_phone.sql
PROBE   Message : Unknown data type: "EMAIL"; SQL statement:
PROBE   history: -1 - << Flyway Schema History table created >> success=true | 1 v1 customer and pause success=true | 2 v2 seed success=true | 3 v3 add phone success=false
PROBE   customer's columns: id, name, meals_per_day, price_per_meal, meal_type, version, phone
PROBE migrate refused: FlywayValidateException: Validate failed: Migrations have failed validation
PROBE   Detected failed migration to version 3 (add phone).
PROBE   history: -1 - << Flyway Schema History table created >> success=true | 1 v1 customer and pause success=true | 2 v2 seed success=true | 3 v3 add phone success=false
PROBE   customer's columns: id, name, meals_per_day, price_per_meal, meal_type, version, phone
```

**Done** when the last step prints `now at version v3` and the history table's third row says `success=true`. A hint: on H2 the failed
migration's first statement stayed — the column is there and the history table holds a failed row — so a corrected file alone is refused
too. The solution, and what it prints, is in `SOLUTION.md`.

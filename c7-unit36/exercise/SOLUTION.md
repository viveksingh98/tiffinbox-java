# Solution — Flyway: Versioned Migrations

On H2 the failed third migration left two things behind: its first statement's column (`phone` — H2 runs each DDL statement in its own
commit, so nothing rolled it back) and a history row with `success=false`. Every migrate after it is refused at validation (`Detected
failed migration to version 3`), and a corrected file alone is refused the same way. Three steps make it apply, in this order: drop the
column the failed run left (by hand — Flyway does not know what a half-run file did), `repair()` (it removes the failed row from H2's
history table), then `migrate()` with the corrected file. Without the drop, `repair()` and `migrate()` run the file again into
`Duplicate column name "PHONE"` (`../receipts.sh`, capture `fail`). The one changed line is the steps, `A`:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes .harness/ex/broken .harness/ex/fixed && cp harness/src/probe/f/ex/Ex.java .harness/ex/
printf '%s\n' 'ALTER TABLE customer ADD COLUMN phone VARCHAR(20);' 'ALTER TABLE customer ADD COLUM email VARCHAR(80);' > .harness/ex/broken/V3__add_phone.sql
printf '%s\n' 'ALTER TABLE customer ADD COLUMN phone VARCHAR(20);' 'ALTER TABLE customer ADD COLUMN email VARCHAR(80);' > .harness/ex/fixed/V3__add_phone.sql
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/Ex.java
A=(migrate migrate fixed cleanup repair migrate)
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
PROBE fixed: the third migration from now on is ex/fixed's, its second statement spelt right
PROBE   history: -1 - << Flyway Schema History table created >> success=true | 1 v1 customer and pause success=true | 2 v2 seed success=true | 3 v3 add phone success=false
PROBE   customer's columns: id, name, meals_per_day, price_per_meal, meal_type, version, phone
PROBE cleanup: ALTER TABLE customer DROP COLUMN phone
PROBE   history: -1 - << Flyway Schema History table created >> success=true | 1 v1 customer and pause success=true | 2 v2 seed success=true | 3 v3 add phone success=false
PROBE   customer's columns: id, name, meals_per_day, price_per_meal, meal_type, version
PROBE repair: removed failed 1
PROBE   history: -1 - << Flyway Schema History table created >> success=true | 1 v1 customer and pause success=true | 2 v2 seed success=true
PROBE   customer's columns: id, name, meals_per_day, price_per_meal, meal_type, version
PROBE migrate: applied 1 · now at version v3
PROBE   history: -1 - << Flyway Schema History table created >> success=true | 1 v1 customer and pause success=true | 2 v2 seed success=true | 3 v3 add phone success=true
PROBE   customer's columns: id, name, meals_per_day, price_per_meal, meal_type, version, phone, email
```

The last step: `now at version v3`, the history table's third row `success=true`, and the customer table with both new columns.
On PostgreSQL none of this arises: the same failed file is rolled back whole and the history table has no row for it — correct the file
and start again (`../receipts.sh`, capture `fail`).

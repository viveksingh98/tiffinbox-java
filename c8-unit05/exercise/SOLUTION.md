# Solution — JdbcTemplate and NamedParameterJdbcTemplate

`JdbcTemplate` binds its arguments by position: the first value to the first `?`, the second to the second. Swap two values of the
same type and the statement is still valid — it just asks another question. `NamedParameterJdbcTemplate` binds by name: `:mealType`
gets the map's `"mealType"` value and `:name` gets `"name"`, wherever they stand in the map. The block is the README's with one line
changed — the copy becomes a `sed` that turns the `JdbcTemplate` call into the named one, with the two values still written name
first, as the broken call had them.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/after/tiffinbox-web/target/extracted"; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
sed 's/jdbc.queryForObject(BY_TYPE_AND_NAME, BY_HAND, "Meera", "NON_VEG")/named.queryForObject(BY_TYPE_AND_NAME_NAMED, Map.of("name", "Meera", "mealType", "NON_VEG"), BY_HAND)/' exercise/Ex05.java > .harness/ex/src/probe/ex/Ex05.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*" .harness/ex/src/probe/ex/Ex05.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*" probe.ex.Ex05) > .harness/ex/run.log 2>&1; echo "Ex05: exit $?"
grep '^EX ' .harness/ex/run.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
Ex05: exit 0
EX lookup Meera: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]
EX done: yes - Meera's row, whatever the order of the arguments
```

The driver receives the same text either way — `… where meal_type = ? and name = ?` (capture `missing`, the `mixup named` window:
the `:mealType` and `:name` are rewritten to `?` before the driver), so the fix is in how the values are matched to the
placeholders, not in the statement. The swapped call finds no row on H2 in memory and on PostgreSQL 18.6 alike (capture `missing`,
both databases; the check compares them). Two values of different types swapped are not silent: `missing`'s `mixup types swapped`
window shows what each database answers.

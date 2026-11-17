# Solution — JdbcClient and Custom Queries

`single()` promises exactly one row and throws `EmptyResultDataAccessException` when none comes back. `optional()` asks the same
question and answers with `Optional.empty` instead. The block is the README's with one line changed — the copy becomes a `sed` that
turns the Nobody lookup's `query(Customer.class).single()` into `query(Customer.class).optional()`; the Meera lookup keeps its
`single()`, since she is there.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/after/tiffinbox-web/target/extracted"; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
sed 's/param("name", "Nobody").query(Customer.class).single()/param("name", "Nobody").query(Customer.class).optional()/' exercise/Ex04.java > .harness/ex/src/probe/ex/Ex04.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*" .harness/ex/src/probe/ex/Ex04.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*" probe.ex.Ex04) > .harness/ex/run.log 2>&1; echo "Ex04: exit $?"
grep '^EX ' .harness/ex/run.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
Ex04: exit 0
EX lookup Meera: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]
EX lookup Nobody: Optional.empty
EX done: yes - an empty result, no exception
```

The variable is declared with `var`, so the one changed call changes its type too: a `Customer` before, an `Optional<Customer>`
after. A route would then answer the empty result as it answers any missing customer, without the exception. The same lookup with
`list()` answers an empty list (capture `missing`); `optional()` is the shape for one row that may not be there. The exception's
text is the same on H2 in memory and on PostgreSQL 18.6 (capture `missing`, both databases; the check compares them).

# Exercise — JdbcClient and Custom Queries

**Your turn:** looking up a customer who does not exist crashes the route. Return an empty result instead, using JdbcClient.

Run it from this unit's folder (`c8-unit04/`) after `./receipts.sh` has run once: the block compiles `Ex04.java` against the jar
the receipt built from the anchor (`.harness/after/`, both Spring Data modules) and needs no Maven and no Docker. `Ex04` starts
TiffinBox with no web server on its default database, H2 in memory, and makes the lookup a customer route makes — one customer by
name, through the context's `JdbcClient` — first for Meera, who exists, then for Nobody, who does not. As shipped the second lookup
ends in `single()`, which throws when no row comes back; the exception ends the program with exit 1, as it would end the route's
request. Java runs under an alarm (`perl -e 'alarm 120; exec …'`, macOS has no `timeout`).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/after/tiffinbox-web/target/extracted"; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
cp exercise/Ex04.java .harness/ex/src/probe/ex/Ex04.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*" .harness/ex/src/probe/ex/Ex04.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*" probe.ex.Ex04) > .harness/ex/run.log 2>&1; echo "Ex04: exit $?"
grep '^EX ' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
Ex04: exit 1
EX lookup Meera: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]
EX lookup Nobody threw: org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
EX done: no - the lookup crashed
```

**Done** when the last line says `yes` and the program exits 0: the lookup for a name nobody has returns an empty result, and no
exception reaches the caller. A hint: `query(Customer.class)` offers more than one way to end the chain, and one of them is made for
a row that may not be there. The solution is in `SOLUTION.md`.

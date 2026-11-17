# Exercise — Why Another Data Module

**Your turn:** the count says seventy-eight. Change one customer inside that transaction without calling save, and make the commit write nothing.

Run it from this unit's folder (`c8-unit01/`) after `./receipts.sh` has run once: the block compiles `Ex01.java` against the jar
the receipt built from the anchor (`.harness/after/`, both Spring Data modules) and needs no Maven and no Docker. `Ex01` starts
TiffinBox with no web server on its default database, H2 in memory, builds the data line (36 more customers, one 2-day pause each,
by `JdbcTemplate`), then runs ONE transaction: the dashboard's customer read through Spring Data JPA, Ravi's meals raised by one in
Java, no `save()`, the commit. It prints what the persistence context holds after the read, Hibernate's `flushCount` and
`entityUpdateCount` for the commit, and Ravi's row read back by `JdbcTemplate` — a second client — after it. Java runs under an
alarm (`perl -e 'alarm 120; exec …'`, macOS has no `timeout`).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/after/tiffinbox-web/target/extracted"; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
cp exercise/Ex01.java .harness/ex/src/probe/ex/Ex01.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*" .harness/ex/src/probe/ex/Ex01.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*" probe.ex.Ex01) > .harness/ex/run.log 2>&1; echo "Ex01: exit $?"
grep '^EX ' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
Ex01: exit 0
EX data (JdbcTemplate): customers 40 · pauses 38
EX before: Ravi meals 2 · version 0
EX the read: customers 40 · the persistence context holds entities 78
EX changed in Java, no save(): Ravi meals 3
EX the commit: flushCount 1 · entityUpdateCount 1
EX after, read back by JdbcTemplate (a second client): Ravi meals 3 · version 1
EX done: no - the commit wrote the row
```

**Done** when the last line says `yes`: `entityUpdateCount` 0 and Ravi's row, read back by `JdbcTemplate` after the commit, the
same as before it. As shipped the commit's flush finds Ravi changed among the entities the read put in the persistence context and
writes his row — nobody called `save()`. A hint: the check is the row, not which API did the read; there is more than one way to a
commit that writes nothing. The solution, and what it prints, is in `SOLUTION.md`.

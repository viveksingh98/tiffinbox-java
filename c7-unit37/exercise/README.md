# Exercise — Liquibase, and Choosing

**Your turn:** the README's Liquibase start was killed while it held its lock, and the next start cannot get it. Release the lock, then update.

Run it from this unit's folder (`c7-unit37/`) after `./receipts.sh` has run once: it builds `.harness/after` (the anchor copied, its jar
extracted — its libraries hold Hibernate, Spring Boot and H2) and links the harness's Liquibase jars into `.harness/lq`. The block copies
the exercise's program, `harness/src/probe/l/ex/Ex.java`, and its own changelog, `harness/db/changelog/ex/diner.sql` (two changesets: a
`diner` table and three rows), to `.harness/ex/` and compiles the program there; the changelog lands on the class path as
`db/changelog/diner.sql`. The program is ONE JVM on an H2 database in that JVM's memory — no port, no container, never TiffinBox's own
tables. It first leaves the state a killed start leaves behind: Liquibase's lock table, made by plain SQL in the shape Liquibase writes on
H2 (the `fail` capture of `../receipts.sh` reads that shape off a real Liquibase run), with its one row locked. Then it runs the commands in
`A`, in order, through Liquibase's Java API: `update` runs the changelog, `release` is `forceReleaseLocks()`. The lock wait is set by its
system property (`-Dliquibase.changelogLockWaitTimeInMinutes=0`), so a held lock refuses the update with no wait; `-Dliquibase.analytics.enabled=false` keeps Liquibase from fetching its
analytics settings over the network — an exercise never calls the network either. The JVM runs under an alarm
(`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array, so bash and zsh pass each one as one argument. The last
line keeps the program's lines and Liquibase's summary lines from its log.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes/db/changelog && cp harness/src/probe/l/ex/Ex.java .harness/ex/ && cp harness/db/changelog/ex/diner.sql .harness/ex/classes/db/changelog/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/lq/*" .harness/ex/Ex.java
A=(update)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -Dliquibase.analytics.enabled=false -Dliquibase.changelogLockWaitTimeInMinutes=0 -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*:../lq/*" probe.l.ex.Ex "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE version: Liquibase 5.0.4
PROBE before: DATABASECHANGELOGLOCK id 1 locked true
PROBE before: no diner table
PROBE update() refused: CommandExecutionException: liquibase.exception.LockException: Could not acquire change log lock.  Currently locked by a killed start since <time>
PROBE after: DATABASECHANGELOGLOCK id 1 locked true
PROBE after: no diner table
```

**Done** when the update runs: the lock row reads unlocked after it and the diner table holds its rows. A hint: Liquibase's Java API has
one call that clears the lock without asking whose it is. The solution, and what it prints, is in `SOLUTION.md`.

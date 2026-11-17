# Solution — Liquibase, and Choosing

The killed start left its row in Liquibase's lock table locked, and nothing in the table says whether that start is still alive — so
every later start is refused until the lock is released. `forceReleaseLocks()` sets the row back to unlocked; the `update` after it takes
the lock, runs both changesets and releases it. Boot has no key for the release: it is the API (or Liquibase's own command line). The one
changed line is `A`: `release` first, then `update`. Release a lock only when you know the start that took it is gone — the receipt's
`lock` capture checks the killed JVM's statement in the server first.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes/db/changelog && cp harness/src/probe/l/ex/Ex.java .harness/ex/ && cp harness/db/changelog/ex/diner.sql .harness/ex/classes/db/changelog/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/lq/*" .harness/ex/Ex.java
A=(release update)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -Dliquibase.analytics.enabled=false -Dliquibase.changelogLockWaitTimeInMinutes=0 -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*:../lq/*" probe.l.ex.Ex "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — compared with the run, line for line):

```
the JVM: exit 0
PROBE version: Liquibase 5.0.4
PROBE before: DATABASECHANGELOGLOCK id 1 locked true
PROBE before: no diner table
PROBE forceReleaseLocks(): done
PROBE summary: Run: 2
PROBE summary: Previously run: 0
PROBE update(): done
PROBE after: DATABASECHANGELOGLOCK id 1 locked false
PROBE after: diner rows 3
PROBE after: DATABASECHANGELOG rows 2
```

The previous lesson, *Flyway: Versioned Migrations*, keeps TiffinBox's schema in Flyway, which takes no lock table; this unit's README
says why TiffinBox keeps it.

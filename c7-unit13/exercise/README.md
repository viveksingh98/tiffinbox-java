# Exercise — Dates, Times and Zones

**Your turn:** the README stores the order time as a LocalDateTime and Kolkata reads it five and a half hours early. Store the moment.

Run it from this unit's folder (`c7-unit13/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (the frozen anchor,
copied, its jar extracted), `.harness/drv` (the PostgreSQL driver — on the class path, unused here) and `.harness/hc` (the dates-and-zones
harness, compiled). The block copies the exercise's entity, `harness/src/probe/map/ex/OrderLog.java`, to `.harness/ex/` and compiles it
there: an `OrderLog` whose `placedAt` — when the order was placed — is a `LocalDateTime`, a clock face with no zone. Then two JVMs, one
after the other, share one H2 database, a file under `.harness/run/db/`: **the writer, in UTC**, stores Course 2's moment,
`2026-09-14T18:30:00Z`, as its own clock face; **the reader, in Asia/Kolkata**, a new JVM, reads the row back, turns it into an instant
in its own zone and prints how far that is from the moment written — with Course 2's label, `off by`. Each JVM's zone is on its own
java line (`-Duser.timezone=`); its other flags travel as an array, `V`, so bash and zsh pass each one as one argument. The block
deletes the database file at the end. It binds no port and stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex .harness/run/db && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/OrderLog.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/OrderLog.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN -Ddb=h2file)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US -Duser.timezone=UTC "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main ex write u13ex) > .harness/mine-write.log 2>&1; echo "the writer, in UTC: exit $?"
(cd .harness/run && exec java -Duser.language=en -Duser.country=US -Duser.timezone=Asia/Kolkata "${V[@]}" -Ddb.keep=true -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main ex read u13ex) > .harness/mine.log 2>&1; echo "the reader, in Asia/Kolkata: exit $?"
rm -rf .harness/run/db
grep -hE '^PROBE (EXCEPTION|  Caused by|JVM zone|placedAt|off by)' .harness/mine-write.log .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
the writer, in UTC: exit 0
the reader, in Asia/Kolkata: exit 0
PROBE JVM zone (TimeZone.getDefault().getID()): UTC | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): (not set)
PROBE placedAt (LocalDateTime) written by this JVM: 2026-09-14T18:30
PROBE JVM zone (TimeZone.getDefault().getID()): Asia/Kolkata | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): (not set)
PROBE placedAt (LocalDateTime) read back: 2026-09-14T18:30 - as an instant in this JVM's zone: 2026-09-14T13:00:00Z
PROBE off by                           : PT5H30M
```

The writer stored its clock face, `18:30`, and no zone; the reader in Kolkata read `18:30` as Kolkata's clock face — `13:00` UTC — and
printed Course 2's line, byte for byte. (This block does not print the column's type; the `ddl` capture in `../receipts.sh` shows a
`LocalDateTime` field, `wall`, as `timestamp(6)`, a column with no zone.)

**Done** when the reader prints `off by                           : PT0S` — the same moment, whatever the reader's zone. The solution,
and what it prints, is in `SOLUTION.md`.

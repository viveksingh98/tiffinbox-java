# Solution — Dates, Times and Zones

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex .harness/run/db && mkdir -p .harness/ex/classes && sed 's/private LocalDateTime placedAt;/private Instant placedAt;/' harness/src/probe/map/ex/OrderLog.java > .harness/ex/OrderLog.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/OrderLog.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN -Ddb=h2file)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US -Duser.timezone=UTC "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main ex write u13ex) > .harness/mine-write.log 2>&1; echo "the writer, in UTC: exit $?"
(cd .harness/run && exec java -Duser.language=en -Duser.country=US -Duser.timezone=Asia/Kolkata "${V[@]}" -Ddb.keep=true -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main ex read u13ex) > .harness/mine.log 2>&1; echo "the reader, in Asia/Kolkata: exit $?"
rm -rf .harness/run/db
grep -hE '^PROBE (EXCEPTION|  Caused by|JVM zone|placedAt|off by)' .harness/mine-write.log .harness/mine.log
```

One line differs from the README's: the copy of `OrderLog.java` stores the moment itself, an `Instant` (by hand, open
`.harness/ex/OrderLog.java` and change the field's type):

```java
    private Instant placedAt;
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh):

```
the writer, in UTC: exit 0
the reader, in Asia/Kolkata: exit 0
PROBE JVM zone (TimeZone.getDefault().getID()): UTC | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): (not set)
PROBE placedAt (Instant) written by this JVM: 2026-09-14T18:30:00Z
PROBE JVM zone (TimeZone.getDefault().getID()): Asia/Kolkata | -Dtzs (hibernate.timezone.default_storage): (not set) | -Djtz (hibernate.jdbc.time_zone): (not set)
PROBE placedAt (Instant) read back: 2026-09-14T18:30:00Z
PROBE off by                           : PT0S
```

Hibernate gives an `Instant` a `timestamp(6) with time zone` column by default (the `ddl` capture in `../receipts.sh` shows it for the
field `moment`, on H2 and on PostgreSQL; this block does not print the column's type): the reader in Kolkata gets the moment back,
`18:30` UTC, the gap `PT0S`. No Hibernate setting, nothing the two JVMs must agree on but the column.

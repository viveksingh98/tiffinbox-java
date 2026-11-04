# Exercise — Embeddables and Value Objects

**Your turn:** the README embeds two addresses and Hibernate refuses to start. Give the second one its own column names.

Run it from this unit's folder (`c7-unit08/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (the anchor, copied,
its jar extracted) and `.harness/hc` (the mapping harness, compiled, with its `Address`). The block copies the exercise's entity,
`harness/src/probe/map/ex/ExCustomer.java` — a customer with an `@Embedded Address home` and an `@Embedded Address office`, no column
names given — to `.harness/ex/` and compiles it there; then the harness builds its own EntityManagerFactory over it, on H2 in that
JVM's memory, and tries to persist Ravi with a home in Pune and an office in Kolkata. The JVM's flags travel as an array, `V`, so bash
and zsh pass each one as one argument. It binds no port and stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/ExCustomer.java .harness/ex/ExCustomer.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.map.Main ex ex.ExCustomer) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|ex_customer)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
exit 1
PROBE EXCEPTION jakarta.persistence.PersistenceException: Unable to build Hibernate SessionFactory  [persistence unit: u08ex]
PROBE   Caused by org.hibernate.MappingException: Column 'city' is duplicated in mapping for entity 'probe.map.ex.ExCustomer' (use '@Column(insertable=false, updatable=false)' when mapping multiple properties to the same column)
```

Both addresses map their fields to the same three column names — `line1`, `city`, `pincode` — in one table, so Hibernate refuses the
mapping before it sends any SQL, naming the first column it finds twice. Its hint (`insertable=false, updatable=false`) is for two
fields that really are one column, read-only on one side; here they are two different addresses, and each needs columns of its own.

**Done** when the block prints `exit 0` and one row of `ex_customer` with eight columns — both addresses in it. The solution, and what
it prints, is in `SOLUTION.md`.

# Exercise — Your First Entity and EntityManager

**Your turn:** the README starts TiffinBox with one option too many, and Hibernate cannot find the customer table. Take it out.

Run it from this unit's folder (`c7-unit03/`) after `./receipts.sh` has run once: it builds `.harness/after` (after/, copied, with
a config tree and its jar extracted) and `.harness/hc` (the harness, compiled). The options travel as an array, `V`, so bash and zsh
pass each one as one argument. The JVM starts TiffinBox with the harness joined, persists one customer (Kavya) through Hibernate
and asks TiffinBox's own repository whether it sees her, then stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
V=(--spring.main.sources=probe.jpa.Probe --spring.jpa.properties.hibernate.generate_statistics=true --probe.steps=ds,two --spring.datasource.url=)
(cd .harness/after && exec java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19828 "${V[@]}") > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^(PROBE |org\.hibernate\.exception\.)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh; the generated name masked):

```
exit 1
PROBE DataSource beans: 1 [dataSource]
PROBE   dataSource -> jdbc:h2:mem:<uuid> (com.zaxxer.hikari.HikariDataSource)
PROBE tiffinbox.jdbc-url = jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1
PROBE emf property hibernate.hbm2ddl.auto = null
org.hibernate.exception.SQLGrammarException: Could not prepare statement [Table "CUSTOMER" not found (this database is empty); SQL statement:
```

Boot's pool opened a database of its own — an in-memory H2 under a generated name, empty — and Hibernate tried to insert there.
TiffinBox's `Database` created and seeded its table in `jdbc:h2:mem:tiffinbox`, a different database.

**Done** when the run ends `exit 0`, the pool's URL is `jdbc:h2:mem:tiffinbox`, Kavya gets an id, and TiffinBox's own repository sees
her. The solution, and what it prints, is in `SOLUTION.md`.

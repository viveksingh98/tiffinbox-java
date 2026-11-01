# Solution — Your First Entity and EntityManager

`--spring.datasource.url=` (an empty value) is the option too many: it replaces the anchor's own `spring.datasource.url:
${tiffinbox.jdbc-url}`, and with no URL Boot makes up a database name of its own. Take it out of the array, and Boot's pool opens
TiffinBox's database. The same lines as the README's, that one changed:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
V=(--spring.main.sources=probe.jpa.Probe --spring.jpa.properties.hibernate.generate_statistics=true --probe.steps=ds,two)
(cd .harness/after && exec java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19828 "${V[@]}") > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^(PROBE |org\.hibernate\.exception\.)' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, a fresh JVM, in bash and in zsh):

```
exit 0
PROBE DataSource beans: 1 [dataSource]
PROBE   dataSource -> jdbc:h2:mem:tiffinbox (com.zaxxer.hikari.HikariDataSource)
PROBE tiffinbox.jdbc-url = jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1
PROBE emf property hibernate.hbm2ddl.auto = null
PROBE persist: id 5 | statements 1 | inserts 1 | updates 0 | deletes 0 | flushes 1
PROBE anchor repo sees Kavya: true
```

Kavya's id is 5 as printed — the table's own AUTO_INCREMENT, after the four customers `Database` seeds — and the anchor's
`CustomerRepository`, over its own `DriverManager` connection, reads what Hibernate wrote.

# Solution — Reading the SQL Hibernate Writes

One line changes in the block: the copy of `ExApp.java` becomes a `sed` that edits the copy as you would edit the file — `Break`'s
`@Table(name = "break_day")` becomes `@Table(name = "break_day", indexes = @Index(name = "break_day_diner_id_idx", columnList =
"diner_id"))`. Hibernate's schema script then creates the index after the table, from the mapping alone; nothing else in the code
changes.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/@Table(name = "break_day")/@Table(name = "break_day", indexes = @Index(name = "break_day_diner_id_idx", columnList = "diner_id"))/' harness/src/probe/q/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create --spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=../ex/ddl.sql)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh, in the same shell right after the README's lines):

```
the JVM: exit 0
PROBE Hibernate's schema script: 4 lines · lines with "index": 1 · md5 f079135b1c6e39a57d23af6ae03a225e
PROBE create index break_day_diner_id_idx on break_day (diner_id);
```

TiffinBox's own mapping says the same since this lesson — `PauseEntity`'s `@Table` names `pause_customer_id_idx` — and its `Database`
creates the index by hand, because TiffinBox's schema is `Database`'s, not Hibernate's (`ddl-auto: none`). The plan pair on PostgreSQL,
before and after the index, is the lesson's `slow` capture, not this exercise: this one needs no container.

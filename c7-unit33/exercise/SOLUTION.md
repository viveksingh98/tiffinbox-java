# Solution — Batching and the Write Path

One line changes in the block: the arguments, `A`, gain `--spring.jpa.properties.hibernate.order_inserts=true`. At each flush
Hibernate then sorts the queued inserts by entity — every `Diner` before every `Break` that points at one — so each statement text is
sent in batches of up to fifty, the same rows in fewer batches. Nothing in the code changes.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/b/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create --logging.level.org.hibernate.SQL=warn --spring.jpa.properties.hibernate.jdbc.batch_size=50 --spring.jpa.properties.hibernate.order_inserts=true)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.b.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh, in the same shell right after the README's lines):

```
the JVM: exit 0
PROBE hibernate.jdbc.batch_size 50 · hibernate.order_inserts true
PROBE rows read back: diner 100 · break_day 100
PROBE executeBatch 4
```

The keys work only where the ids are known before the INSERT: on an identity column the same key changes nothing (the lesson's
`batch` capture). The lesson called Ids and Generation Strategies chose between those ids; this exercise is about the order of the
inserts.

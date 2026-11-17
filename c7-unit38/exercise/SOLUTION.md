# Solution — Auditing and Soft Deletes

Spring Data merges a copy whose id is set: Hibernate loads the row, copies every field of the copy onto it — `createdAt` among them,
which the copy never had — and writes an UPDATE with every column. Spring Data's listener sets `updatedAt` before that UPDATE and
leaves `createdAt` alone, so the UPDATE writes NULL over the creation stamp. `@Column(updatable = false)` takes `created_at` out of
every UPDATE Hibernate writes: the merge still copies the empty field, and the column keeps the value the INSERT gave it. The one
changed line is the copy: it adds the attribute to the field as it copies the file.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/@CreatedDate Instant createdAt;/@CreatedDate @Column(updatable = false) Instant createdAt;/' harness/src/probe/u/ex/Ex.java > .harness/ex/Ex.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/Ex.java
A=(--logging.level.org.hibernate.SQL=debug '--logging.pattern.console=%logger{0} : %msg%n' --spring.main.banner-mode=off --spring.flyway.enabled=false)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.u.ex.Ex "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE |^SQL : (insert|update) ' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — compared with the run, line for line):

```
the JVM: exit 0
PROBE version: Hibernate 7.4.13.Final
SQL : insert into diner (created_at,meals_per_day,name,updated_at,id) values (?,?,?,?,default)
SQL : update diner set meals_per_day=?,name=?,updated_at=? where id=?
PROBE after the copy was saved: created_at_null=f
```

TiffinBox's own `CustomerEntity` carries the same attribute since this unit (`../c7-tiffinbox`, C2).

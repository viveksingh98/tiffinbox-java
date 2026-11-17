# Exercise — Auditing and Soft Deletes

**Your turn:** the README saves a customer from a copy, and her created time comes back empty. Keep it.

Run it from this unit's folder (`c7-unit38/`) after `./receipts.sh` has run once: it builds `.harness/after` (the anchor copied, its
jar extracted — its libraries hold Hibernate, Spring Data JPA, Spring Boot and H2). The block copies the exercise's program,
`harness/src/probe/u/ex/Ex.java`, to `.harness/ex/` and compiles it there. The program is ONE JVM on an H2 database in that JVM's
memory — no port, no container, never TiffinBox's own tables: an entity of its own, `Diner`, with Spring Data's two date stamps
(`@CreatedDate Instant createdAt`, `@LastModifiedDate Instant updatedAt`) and `@EnableJpaAuditing`. It saves Ravi, then saves a copy
of him made outside the persistence context — the id and a new meals-a-day count, no stamps — which Spring Data merges, and reads the
row back over a plain JDBC connection of its own: `created_at_null=t` means the creation stamp is gone. The arguments in `A` are
Spring's: the SQL logger at DEBUG, a one-line log pattern, no banner, and Flyway switched off (the libraries hold TiffinBox's
migrations; this database is the diner's alone). The JVM runs under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`),
its arguments in an array, so bash and zsh pass each one as one argument. The last line keeps the program's lines and the INSERT and
UPDATE the SQL logger printed.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/u/ex/Ex.java .harness/ex/Ex.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/Ex.java
A=(--logging.level.org.hibernate.SQL=debug '--logging.pattern.console=%logger{0} : %msg%n' --spring.main.banner-mode=off --spring.flyway.enabled=false)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.u.ex.Ex "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE |^SQL : (insert|update) ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE version: Hibernate 7.4.13.Final
SQL : insert into diner (created_at,meals_per_day,name,updated_at,id) values (?,?,?,?,default)
SQL : update diner set created_at=?,meals_per_day=?,name=?,updated_at=? where id=?
PROBE after the copy was saved: created_at_null=t
```

**Done** when the last line says `created_at_null=f` and the UPDATE above it no longer names `created_at`. A hint: one attribute on the
field tells Hibernate never to write that column in an UPDATE. The solution, and what it prints, is in `SOLUTION.md`.

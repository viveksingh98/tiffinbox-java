# Exercise — Never Use ddl-auto in Production

**Your turn:** the README's entity reads meals a day as text, and update turns the integer column into text. Make the start refuse the change instead.

Run it from this unit's folder (`c7-unit35/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (the anchor copied, its
jar extracted — its libraries hold Hibernate, Spring Boot and H2). The block copies the exercise's program, `harness/src/probe/d/ex/Ex.java`,
to `.harness/ex/` and compiles it there. The program is ONE JVM on an H2 database in that JVM's memory — no port, no container, never
TiffinBox's own tables: it creates a table of its own, `diner`, by plain JDBC, with an integer column `meals_per_day` and three rows,
then starts Spring over an entity, `Diner`, whose `mealsPerDay` field is a `String`. It prints the column's type before and after the
start, read over a plain JDBC connection of its own, and whether the start went on. The arguments in `A` are Spring's: the `ddl-auto`
value, the SQL logger at DEBUG and a one-line log pattern. The JVM runs under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no
`timeout`), its arguments in an array, so bash and zsh pass each one as one argument. The last line keeps the program's lines and the
SQL logger's from its log.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/d/ex/Ex.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/Ex.java
A=(--spring.jpa.hibernate.ddl-auto=update --logging.level.org.hibernate.SQL=debug '--logging.pattern.console=%logger{0} : %msg%n' --spring.main.banner-mode=off)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.d.ex.Ex "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE |^SQL : ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the JVM: exit 0
PROBE version: Hibernate 7.4.13.Final
PROBE before the start: diner.meals_per_day integer
SQL : alter table if exists diner alter column meals_per_day set data type varchar(255)
PROBE ready: yes
PROBE after the start: diner.meals_per_day character varying(255)
```

**Done** when the start is refused: the last line names the column's type unchanged, and the line before it is the refusal. A hint: one
value of the same key checks the entity against the table and writes nothing. The solution, and what it prints, is in `SOLUTION.md`.

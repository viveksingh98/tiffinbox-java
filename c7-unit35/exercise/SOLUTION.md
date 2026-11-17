# Solution — Never Use ddl-auto in Production

`update` makes the table fit the entity: it ran an `alter column … set data type` on the integer column, and every row's number is now
text. `validate` compares the entity with the table and writes nothing: it finds the type it does not expect and refuses the start, and
the column stays an integer. The one changed line is `A`'s first argument. The refusal is the solution's success here; the broken run,
the column retyped, is the control.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/d/ex/Ex.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/Ex.java
A=(--spring.jpa.hibernate.ddl-auto=validate --logging.level.org.hibernate.SQL=debug '--logging.pattern.console=%logger{0} : %msg%n' --spring.main.banner-mode=off)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.d.ex.Ex "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE |^SQL : ' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — compared with the run, line for line):

```
the JVM: exit 1
PROBE version: Hibernate 7.4.13.Final
PROBE before the start: diner.meals_per_day integer
PROBE ready: no
PROBE refused: SchemaManagementException: Schema validation: wrong column type encountered in column [meals_per_day] in table [diner]; found [integer (Types#INTEGER)], but expecting [varchar(255) (Types#VARCHAR)]
PROBE after the start: diner.meals_per_day integer
```

`validate` belongs beside a migration — the next lesson, *Flyway: Versioned Migrations*, owns the schema; `ddl-auto` then only checks.

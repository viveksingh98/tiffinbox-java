# Exercise — Inheritance: Three Strategies

**Your turn:** the README stores each meal kind in its own table and Hibernate refuses to start. Give it an id it can use.

Run it from this unit's folder (`c7-unit12/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (the frozen anchor,
copied, its jar extracted), `.harness/drv` (the PostgreSQL driver — on the class path, unused here) and `.harness/hc` (the inheritance
harness, compiled). The block copies the exercise's three entities, `harness/src/probe/map/ex/Meal.java`, `PlatterMeal.java` and
`SaladMeal.java`, to `.harness/ex/` and compiles them there: an abstract `Meal` with `@Inheritance(strategy =
InheritanceType.TABLE_PER_CLASS)` — each kind in a table of its own — and `@Id @GeneratedValue(strategy = GenerationType.IDENTITY)`,
the id TiffinBox's customers use; a `PlatterMeal` (`int dishes`) and a `SaladMeal` (`String dressing`). Then the harness builds its
own EntityManagerFactory over them, on H2 in that JVM's memory, and — if it starts — writes one Platter and one Salad and reads both
tables back by a second connection; it prints the exception if the factory cannot be built. The JVM's flags travel as an array, `V`,
so bash and zsh pass each one as one argument. It binds no port and stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/Meal.java harness/src/probe/map/ex/PlatterMeal.java harness/src/probe/map/ex/SaladMeal.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/Meal.java .harness/ex/PlatterMeal.java .harness/ex/SaladMeal.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main ex probe.map.ex) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|the EntityManagerFactory was built|platter_meal|salad_meal)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
exit 1
PROBE EXCEPTION jakarta.persistence.PersistenceException: Unable to build Hibernate SessionFactory  [persistence unit: u12ex]
PROBE   Caused by org.hibernate.MappingException: Cannot use identity column key generation with <union-subclass> mapping for: probe.map.ex.Meal
```

Hibernate refuses to start: no factory, no table, no row — the same on PostgreSQL (`tpcidentity` B in `../receipts.sh`).
With a table per concrete class a Platter and a Salad live in two tables, and the message names that mapping `<union-subclass>`.
Why Hibernate refuses is not captured here; what `../receipts.sh` does show beside it: two tables with an identity column each
(`mapped`) each hand out id 1.

**Done** when the block prints `exit 0`, `the EntityManagerFactory was built`, and the two tables hold the Platter as id 1 and the
Salad as id 2. The solution, and what it prints, is in `SOLUTION.md`.

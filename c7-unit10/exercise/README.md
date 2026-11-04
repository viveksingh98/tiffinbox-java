# Exercise — @OneToOne and @ManyToMany

**Your turn:** the README removes one favourite meal and Hibernate rewrites the whole list. Change the collection type so it doesn't.

Run it from this unit's folder (`c7-unit10/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (the frozen anchor,
copied, its jar extracted) and `.harness/hc` (the mapping harness, compiled). The block copies the exercise's two entities,
`harness/src/probe/map/ex/ExFan.java` and `ExMeal.java`, to `.harness/ex/` and compiles them there: a customer whose favourite meals
are a `@ManyToMany List<ExMeal>`, and the meal. Then the harness builds its own EntityManagerFactory over them, on H2 in that JVM's
memory, gives Kavya three favourites — Platter, Salad, Soup — and, in a new transaction, removes Salad; it prints what each of the
driver's `executeUpdate` calls returned and the statement it ran, then counts the join table's rows by a second connection. The JVM's
flags travel as an array, `V`, so bash and zsh pass each one as one argument. It binds no port and stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/ExFan.java harness/src/probe/map/ex/ExMeal.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExFan.java .harness/ex/ExMeal.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.map.Main ex ex.ExFan) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|Salad|  returned|ex_fan)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
exit 0
PROBE Salad removed from Kavya's favourites - executeUpdate calls: 3
PROBE   returned 3 <- delete from ex_fan_favourites where ex_fan_id=?
PROBE   returned 1 <- insert into ex_fan_favourites (ex_fan_id,favourites_id) values (?,?)
PROBE   returned 1 <- insert into ex_fan_favourites (ex_fan_id,favourites_id) values (?,?)
PROBE ex_fan_favourites, read by a second connection: 2 rows
```

No error, and the table ends right — two rows, Platter and Soup. But look at what it took: one DELETE that removed **all three** of
Kavya's rows (the driver says it changed 3), then two INSERTs that put Platter and Soup back. A `List` with no `@OrderColumn` is a
*bag* to Hibernate: its join table has no primary key, so no row can be named on its own, and the only way to drop one is to drop them
all and write the rest again. Three favourites, three writes, to remove one (`many` A in
`../receipts.sh` shows the same for `ListFan`, with the join table's DDL: no primary key).

**Done** when the block prints `exit 0`, one write — a DELETE that returned 1 — and two rows left.
The solution, and what it prints, is in `SOLUTION.md`.

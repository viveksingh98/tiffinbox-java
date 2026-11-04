# Exercise — Cascades and Orphan Removal

**Your turn:** the README empties Kavya's pauses by handing her a new list, and the commit fails. Empty the list she already has.

Run it from this unit's folder (`c7-unit11/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (the frozen anchor,
copied, its jar extracted) and `.harness/hc` (the cascades harness, compiled). The block copies the exercise's two entities,
`harness/src/probe/map/ex/ExCustomer.java` and `ExPause.java`, to `.harness/ex/` and compiles them there: a customer whose pauses are a
`@OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true) List<ExPause>`, with a method `emptyPauses()` that
hands her a new list, and the pause. Then the harness builds its own EntityManagerFactory over them, on H2 in that JVM's memory, gives
Kavya pauses of 3 and 2 days and, in a new transaction, calls `emptyPauses()`; it prints the exception if the commit fails, what each of
the driver's `executeUpdate` calls returned and the statement it ran, then counts the pause table's rows by a second connection. The
JVM's flags travel as an array, `V`, so bash and zsh pass each one as one argument. It binds no port and stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/ExCustomer.java harness/src/probe/map/ex/ExPause.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java .harness/ex/ExPause.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.map.Main ex ex.ExCustomer) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|Kavya|  returned|ex_pause)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
exit 1
PROBE EXCEPTION jakarta.persistence.RollbackException: Error while committing the transaction [A collection with orphan deletion was no longer referenced by the owning entity instance: probe.map.ex.ExCustomer.pauses]
PROBE   Caused by org.hibernate.HibernateException: A collection with orphan deletion was no longer referenced by the owning entity instance: probe.map.ex.ExCustomer.pauses
PROBE Kavya's pauses emptied - executeUpdate calls: 0
PROBE ex_pause, read by a second connection: 2 rows
```

The commit fails and nothing is written: both pauses are still in the table. With `orphanRemoval = true`, Hibernate watches the
collection it handed Kavya when she was loaded — its own list, the one that remembers which pauses were in it. `pauses = new
ArrayList<>()` throws that list away; at the commit Hibernate finds the customer no longer holds it and refuses to guess which orphans
to delete (`replace` A in `../receipts.sh` shows the same for `OrphanCustomer`, and `replace` B shows that without `orphanRemoval` the
same line writes nothing at all).

**Done** when the block prints `exit 0`, two DELETEs — each returned 1 — and 0 rows left.
The solution, and what it prints, is in `SOLUTION.md`.

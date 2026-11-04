# Exercise — @OneToMany/@ManyToOne and the Owning Side

**Your turn:** the README adds a pause to Kavya's list and the table never hears who it belongs to. Fix it.

Run it from this unit's folder (`c7-unit09/`) after `./receipts.sh` has run once: it builds `.harness/after` (the anchor after this
unit's change, copied, its jar extracted) and `.harness/hc` (the mapping harness, compiled). The block copies the exercise's two
entities, `harness/src/probe/map/ex/ExCustomer.java` and `ExPause.java`, to `.harness/ex/` and compiles them there: a customer whose
pauses are `@OneToMany(mappedBy = "customer")`, and a pause whose `@ManyToOne` customer owns the foreign key, `customer_id`. Then the
harness builds its own EntityManagerFactory over them, on H2 in that JVM's memory, persists Kavya, gives her a pause of 4 days with
her `addPause`, and reads the pause table by a second connection, then Kavya's pauses in a new EntityManager. The JVM's flags travel as
an array, `V`, so bash and zsh pass each one as one argument. It binds no port and stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/ExCustomer.java harness/src/probe/map/ex/ExPause.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/hc:.harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java .harness/ex/ExPause.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.map.Main ex ex.ExCustomer) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|ex_pause|read in)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
exit 0
PROBE ex_pause, read by a second connection (id | customer_id | days): [1 | null | 4]
PROBE read in a new EntityManager: Kavya's pauses 0
```

No error, and the pause is in the table — with no customer. `addPause` puts the pause in Kavya's list, and that list is the inverse
side: `mappedBy = "customer"` tells Hibernate the foreign key belongs to `ExPause.customer`, so Hibernate writes `customer_id` from that
field alone, and it was never set. The list in memory said one pause; the table says nobody's, and a new EntityManager finds Kavya with
none.

**Done** when the block prints `exit 0` and the pause row says `customer_id` 1 — Kavya's id — and the new EntityManager reads one pause.
The solution, and what it prints, is in `SOLUTION.md`.

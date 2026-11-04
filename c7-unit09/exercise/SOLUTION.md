# Solution — @OneToMany/@ManyToOne and the Owning Side

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/ExPause.java .harness/ex/ && sed 's/^        pauses.add(pause);$/        pauses.add(pause); pause.setCustomer(this);/' harness/src/probe/map/ex/ExCustomer.java > .harness/ex/ExCustomer.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java .harness/ex/ExPause.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.map.Main ex ex.ExCustomer) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|ex_pause|read in)' .harness/mine.log
```

One line differs from the README's: the copy of `ExCustomer.java` gets one more statement in `addPause` (by hand, open
`.harness/ex/ExCustomer.java` and add it):

```java
    public void addPause(ExPause pause) {
        pauses.add(pause); pause.setCustomer(this);
    }
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh):

```
exit 0
PROBE ex_pause, read by a second connection (id | customer_id | days): [1 | 1 | 4]
PROBE read in a new EntityManager: Kavya's pauses 1
```

`pause.setCustomer(this)` sets the owning side — the field `mappedBy` names — so the INSERT carries Kavya's id, 1. The list keeps
the pause too, so the two sides agree in memory. A helper that sets both sides is
the usual home for that one line; setting `pause.setCustomer(kavya)` wherever a pause is made works the same for the table.

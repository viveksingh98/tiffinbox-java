# Solution — Cascades and Orphan Removal

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/map/ex/ExPause.java .harness/ex/ && sed 's/^        pauses = new ArrayList<>();$/        pauses.clear();/' harness/src/probe/map/ex/ExCustomer.java > .harness/ex/ExCustomer.java
javac -d .harness/ex/classes -cp ".harness/hc:.harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExCustomer.java .harness/ex/ExPause.java
V=(-Dlogback.configurationFile=../../harness/logback.xml -Dsql=WARN)
(cd .harness/run && exec java -Duser.language=en -Duser.country=US "${V[@]}" -cp "../ex/classes:../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.map.Main ex ex.ExCustomer) > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE (EXCEPTION|  Caused by|Kavya|  returned|ex_pause)' .harness/mine.log
```

One line differs from the README's: the copy of `ExCustomer.java` empties the list she already has (by hand, open
`.harness/ex/ExCustomer.java` and change the body of `emptyPauses()`):

```java
        pauses.clear();
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh):

```
exit 0
PROBE Kavya's pauses emptied - executeUpdate calls: 2
PROBE   returned 1 <- delete from ex_pause where id=?
PROBE   returned 1 <- delete from ex_pause where id=?
PROBE ex_pause, read by a second connection: 0 rows
```

`clear()` empties Hibernate's own list, so it still knows which two pauses left it: with `orphanRemoval = true` each is an orphan, and
the commit deletes each by its id — two DELETEs, each of which changed 1 row. Kavya stays (`replace` C in `../receipts.sh` shows the
same for `OrphanCustomer`, with the customer's row still there).

# Exercise — Entity States

**Your turn:** the README changes a customer after detaching it, and the database never hears. Make the change reach the table.

Run it from this unit's folder (`c7-unit05/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (the anchor, copied,
with a config tree and its jar extracted) and `.harness/hc` (the harness, compiled). The options travel as an array, `V`, so bash and
zsh pass each one as one argument. The JVM starts TiffinBox with the harness joined, persists Kavya with 2 meals a day, then — in a
new transaction — finds her, detaches her and sets 3, prints what Hibernate did and what TiffinBox's own repository reads, then
stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
V=(--spring.main.sources=probe.jpa.Five --spring.jpa.properties.hibernate.generate_statistics=true --probe.st=ex-detach)
(cd .harness/anchor && exec java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19846 "${V[@]}") > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, a fresh JVM, in bash and in zsh):

```
exit 0
PROBE setup begin - persist Kavya with 2 meals, a transaction of her own
PROBE setup end - after commit: id 5
PROBE setup | statements 1 | loads 0 | inserts 1 | updates 0 | deletes 0 | flushes 1 | transactions 1
PROBE anchor repo reads Kavya's mealsPerDay: 2
PROBE ex-detach begin - Kavya set to 3
PROBE ex-detach end - after commit
PROBE ex-detach | statements 1 | loads 1 | inserts 0 | updates 0 | deletes 0 | flushes 0 | transactions 1
PROBE anchor repo reads Kavya's mealsPerDay: 2
```

`updates 0`: the change was made to an object the persistence context no longer tracks, so the commit had nothing to write, and the
table still says 2.

**Done** when the last line says `3` and the counts line says `updates 1`. The harness has a step that brings the changed instance
back with `merge` — it is named in `../harness/src/probe/jpa/St.java`. The solution, and what it prints, is in `SOLUTION.md`.

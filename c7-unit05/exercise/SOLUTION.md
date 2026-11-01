# Solution — Entity States

`--probe.st=ex-detach` changes Kavya after `detach`: she is detached, so the commit writes nothing. `ex-merge` finds her in a
transaction that ends (so the instance is detached), sets 3 on it, and hands it to `merge` in a new transaction: Hibernate loads her
again, copies the change onto the managed copy, and the commit writes it. The same lines as the README's, that one changed:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
V=(--spring.main.sources=probe.jpa.Five --spring.jpa.properties.hibernate.generate_statistics=true --probe.st=ex-merge)
(cd .harness/anchor && exec java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19846 "${V[@]}") > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, a fresh JVM, in bash and in zsh):

```
exit 0
PROBE setup begin - persist Kavya with 2 meals, a transaction of her own
PROBE setup end - after commit: id 5
PROBE setup | statements 1 | loads 0 | inserts 1 | updates 0 | deletes 0 | flushes 1 | transactions 1
PROBE anchor repo reads Kavya's mealsPerDay: 2
PROBE ex-merge begin - Kavya set to 3
PROBE ex-merge end - after commit
PROBE ex-merge | statements 3 | loads 2 | inserts 0 | updates 1 | deletes 0 | flushes 2 | transactions 2
PROBE anchor repo reads Kavya's mealsPerDay: 3
```

`statements 3`: the find in the first transaction, then `merge`'s SELECT and the UPDATE at the second one's commit.

**The other solution** is not to detach at all: `ex-plain` finds Kavya and sets 3 inside one transaction, so she stays managed and
dirty checking writes the change at the commit. The README's lines, that one changed:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
V=(--spring.main.sources=probe.jpa.Five --spring.jpa.properties.hibernate.generate_statistics=true --probe.st=ex-plain)
(cd .harness/anchor && exec java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19846 "${V[@]}") > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints (measured the same way):

```
exit 0
PROBE setup begin - persist Kavya with 2 meals, a transaction of her own
PROBE setup end - after commit: id 5
PROBE setup | statements 1 | loads 0 | inserts 1 | updates 0 | deletes 0 | flushes 1 | transactions 1
PROBE anchor repo reads Kavya's mealsPerDay: 2
PROBE ex-plain begin - Kavya set to 3
PROBE ex-plain end - after commit
PROBE ex-plain | statements 2 | loads 1 | inserts 0 | updates 1 | deletes 0 | flushes 1 | transactions 1
PROBE anchor repo reads Kavya's mealsPerDay: 3
```

Broken ≠ solved: the README's run leaves the table at **2**, each solution at **3** — read by TiffinBox's own repository, from a
fresh JVM each.

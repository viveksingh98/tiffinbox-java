# Solution — Why Another Data Module

The read put every customer and every pause in the persistence context, and the commit's flush compares each of them with the state
it was loaded with: Ravi differs, so Hibernate writes his row. Two ways stop that, and both are measured by this unit's receipt.
This file shows one: mark the transaction read-only. Spring then tells Hibernate not to flush, so the commit compares nothing and
writes nothing. The block is the README's with one line changed: the copy becomes a `sed` that turns `tx.setReadOnly(false);`
into `tx.setReadOnly(true);`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/after/tiffinbox-web/target/extracted"; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
sed 's/tx.setReadOnly(false);/tx.setReadOnly(true);/' exercise/Ex01.java > .harness/ex/src/probe/ex/Ex01.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*" .harness/ex/src/probe/ex/Ex01.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*" probe.ex.Ex01) > .harness/ex/run.log 2>&1; echo "Ex01: exit $?"
grep '^EX ' .harness/ex/run.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
Ex01: exit 0
EX data (JdbcTemplate): customers 40 · pauses 38
EX before: Ravi meals 2 · version 0
EX the read: customers 40 · the persistence context holds entities 78
EX changed in Java, no save(): Ravi meals 3
EX the commit: flushCount 0 · entityUpdateCount 0
EX after, read back by JdbcTemplate (a second client): Ravi meals 2 · version 0
EX done: yes - the commit wrote nothing
```

The other way keeps the transaction as it was and reads through Spring Data JDBC instead: `agg.findAll(Sort.by("name"))` in place
of `jpa.findAllByOrderByNameAsc()`. The aggregates it returns are plain objects — nothing tracks them, the persistence context holds
none — so changing Ravi's meals changes a Java object and nothing else; writing the row would take `save()`. The receipt runs that
variant too, a `sed` on a copy of `Ex01.java` (capture `exercise`, "the other solution"): the commit writes nothing and the row read
back by `JdbcTemplate` is unchanged. Either is a correct answer; the check is the same row and the same `entityUpdateCount`.

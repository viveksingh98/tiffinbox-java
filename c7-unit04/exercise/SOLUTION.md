# Solution — The Persistence Context

`--probe.pc=twofinds-notx` runs the two finds with no transaction around them. `twofinds-tx` runs the same two finds inside one
`TransactionTemplate` (`tx.execute(…)` in `Pc.java`): one transaction, one persistence context, and the second `find` is answered from
it. The same lines as the README's, that one changed:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
V=(--spring.main.sources=probe.jpa.Four --spring.jpa.properties.hibernate.generate_statistics=true --probe.pc=twofinds-tx)
(cd .harness/anchor && exec java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19835 "${V[@]}") > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, a fresh JVM, in bash and in zsh; the identity hashes masked):

```
exit 0
PROBE twofinds-tx begin - two finds, one TransactionTemplate, the EntityManager Spring injects
PROBE   in a transaction: true
PROBE twofinds-tx end
PROBE   first find -> Ravi | second -> Ravi
PROBE   same object (a == b): true | identityHashCode @… @… | the pair equal: true
PROBE twofinds-tx | statements 1 | loads 1 | updates 0 | flushes 1 | transactions 1
```

One statement, one object: the second `find` came out of the persistence context, not the database. `flushes 1` is the commit's
flush with nothing to write — the one statement is the SELECT.

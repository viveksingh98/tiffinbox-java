# Exercise — The Persistence Context

**Your turn:** the README's two finds hit the database twice. Give them one transaction and watch it drop to one.

Run it from this unit's folder (`c7-unit04/`) after `./receipts.sh` has run once: it builds `.harness/anchor` (the anchor, copied,
with a config tree and its jar extracted) and `.harness/hc` (the harness, compiled). The options travel as an array, `V`, so bash and
zsh pass each one as one argument. The JVM starts TiffinBox with the harness joined, asks the EntityManager Spring injects for
customer 1 twice, prints what Hibernate did, then stops on its own.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
V=(--spring.main.sources=probe.jpa.Four --spring.jpa.properties.hibernate.generate_statistics=true --probe.pc=twofinds-notx)
(cd .harness/anchor && exec java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19835 "${V[@]}") > .harness/mine.log 2>&1; echo "exit $?"
grep -E '^PROBE ' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, a fresh JVM, in bash and in zsh; the two identity
hashes masked — they differ every run):

```
exit 0
PROBE twofinds-notx begin - two finds, no transaction, the EntityManager Spring injects, outside any request
PROBE   in a transaction: false
PROBE twofinds-notx end
PROBE   first find -> Ravi | second -> Ravi
PROBE   same object (a == b): false | identityHashCode @… @… | the pair equal: false
PROBE   contains the first, asked afterwards: false
PROBE twofinds-notx | statements 2 | loads 2 | updates 0 | flushes 0 | transactions 0
```

Two statements, two objects: with no transaction, the EntityManager Spring injects opened a fresh persistence context for each
`find`, and each one asked the database.

**Done** when the counts line says `statements 1` and `same object (a == b): true`. The harness has a step that runs the same two
finds inside one `TransactionTemplate` — it is named in `../harness/src/probe/jpa/Pc.java`. The solution, and what it prints, is in
`SOLUTION.md`.

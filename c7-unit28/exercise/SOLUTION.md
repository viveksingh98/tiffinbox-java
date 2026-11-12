# Solution — Pessimistic Locking and Deadlocks

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/kitchen.lockBoth("Meera", "Ravi", t2First, null)/kitchen.lockBoth("Ravi", "Meera", t2First, null)/' harness/src/probe/t/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.level.root=warn '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep '^PROBE ' .harness/mine.log
```


One line differs from the README's: the copy of `ExApp.java` has T2 lock its diners in T1's order, Ravi first (by hand: open
`.harness/ex/ExApp.java` and swap the two names in T2's call):

```java
                    out[1] = kitchen.lockBoth("Ravi", "Meera", t2First, null);
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
PROBE T1: locked Ravi, then Meera, committed
PROBE T2: locked Ravi, then Meera, committed
PROBE after both, its own JDBC connection reads: Ravi 2, Meera 1
```

Both transactions now take Ravi first. T2 asks for Ravi while T1 holds him and waits; T1 goes on to Meera, which nobody holds, and
commits; then T2 gets Ravi, then Meera, and commits too. No circle, no victim. The `order` capture is the same shape on TiffinBox's
own `CustomerEntity`, on H2 and on PostgreSQL, with T2's wait witnessed by the second connection.

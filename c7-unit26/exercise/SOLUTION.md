# Solution — Rollback Rules

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^    @Transactional$/    @Transactional(rollbackFor = Exception.class)/' harness/src/probe/t/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|Creating new transaction with name \[[^]]*\]|Initiating transaction (commit|rollback)|^PROBE .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` carries `@Transactional(rollbackFor = Exception.class)` on `signUp` (by
hand: open `.harness/ex/ExApp.java` and give the annotation the rule):

```java
    @Transactional(rollbackFor = Exception.class)
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
Creating new transaction with name [probe.t.ex.SignUp.signUp]
Initiating transaction rollback
PROBE signUp(Kavya) threw: java.io.FileNotFoundException: welcome-letter.txt (the letter template is missing)
PROBE after the call, its own JDBC connection reads: customer rows 4 · Kavya gone
```

The same exception leaves the method, and now the transaction rolls back: four customers, Kavya gone. `rollbackFor = Exception.class`
is a rule that names the checked exception's class (or a superclass of it) — the `rules` capture's second row. TiffinBox's own
`CustomerRepository.add` names `SQLException`, the one it throws.

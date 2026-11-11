# Solution — @Transactional: What the Proxy Does

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^    public void signUp(String name) {$/    @Transactional public void signUp(String name) {/' harness/src/probe/t/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../anchor/tiffinbox-web/target/extracted/lib/*" probe.t.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|Creating new transaction with name \[[^]]*\]|Initiating transaction (commit|rollback)|^PROBE .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` carries `@Transactional` on the outer method, the one the runner calls
from outside the bean (by hand: open `.harness/ex/ExApp.java` and put the annotation on `signUp`):

```java
    @Transactional public void signUp(String name) {
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
Found 1 JPA repository interface.
Creating new transaction with name [probe.t.ex.Signup.signUp]
Initiating transaction rollback
PROBE signUp(Asha) threw: java.lang.IllegalStateException: the welcome step failed after the save of Asha
PROBE after the call, its own JDBC connection reads: customer rows 4 · Asha gone
```

With the annotation on the method the runner calls from outside, the call reaches the proxy first: one transaction, named for
`signUp`; `inner`'s save takes part in it; the exception rolls it back, and the table is the seed again (unit 23's `trap` capture, A).
Both runs exit 0 and both print the same exception: they are told apart by the manager's two lines and the row count, never by a
failure. Moving the call to another bean (unit 23's `fixb`) is the other fix; it is not this file's one-line change.

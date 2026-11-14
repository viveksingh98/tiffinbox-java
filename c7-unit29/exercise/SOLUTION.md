# Solution — Lazy Loading and LazyInitializationException

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/^    public Map<String, Integer> pausedDays() {$/    @Transactional(readOnly = true) public Map<String, Integer> pausedDays() {/' harness/src/probe/u/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.u.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(\[[A-Za-z]+\] org\.springframework\.orm\.jpa\.JpaTransactionManager : Creating new transaction with name \[[^]]*\]|^PROBE .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` carries `@Transactional(readOnly = true)` on `Page`'s
`pausedDays()` (by hand: open `.harness/ex/ExApp.java` and annotate the method):

```java
    @Transactional(readOnly = true) public Map<String, Integer> pausedDays() {
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
[main] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.u.ex.Page.store]
[main] org.springframework.orm.jpa.JpaTransactionManager : Creating new transaction with name [probe.u.ex.Page.pausedDays]
PROBE the page: {Meera=0, Priya=2, Ravi=0, Sunil=3}
```

The read now has its own transaction, `probe.u.ex.Page.pausedDays`, read-only: the persistence context stays open until the method
returns, every `breaks` collection is read inside it, and the page prints each diner's days — Priya 2, Sunil 3. No open-in-view,
no change to the mapping: the boundary sits on the read, as unit 29 puts it on `CustomerRepository.pausedDaysByCustomer`.

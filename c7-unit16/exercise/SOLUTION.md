# Solution — Derived Query Methods

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed 's/findByNmae/findByName/g' harness/src/probe/q/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*)' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` gets the method's name right — `findByNmae` becomes `findByName`, in the
repository and in the runner that calls it (by hand: open `.harness/ex/ExApp.java` and fix the two names):

```java
interface Customers extends JpaRepository<CustomerEntity, Long> {

    Optional<CustomerEntity> findByName(String name);
}
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh):

```
the JVM: exit 0
Found 1 JPA repository interface.
PROBE Sunil: Optional[3|Sunil|3|100|VEG]
```

`name` is a property of `CustomerEntity`, so Spring Data derives the query from the method's name at start — `select … from customer
ce1_0 where ce1_0.name=?`, Sunil's name its parameter — and the runner gets her back, in an `Optional`.

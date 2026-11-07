# Exercise — Derived Query Methods

**Your turn:** the README's repository has a method the application cannot start with. Read the error, and fix the method's name.

Run it from this unit's folder (`c7-unit16/`) after `./receipts.sh` has run once: it builds `.harness/after` (the anchor after this
unit's change, copied, its jar extracted — 91 libraries, among them `tiffinbox-core-1.0.0.jar` with TiffinBox's entities and the
shipped `Database`). The block copies the exercise's application, `harness/src/probe/q/ex/ExApp.java`, to `.harness/ex/` and
compiles it there: a Spring Boot application with no web server, in its own package, `probe.q.ex`, that maps TiffinBox's entities
(`@EntityScan("com.tiffinbox")`), seeds its own H2 database with the shipped `Database` (Ravi, Meera, Sunil, Priya), and carries a
repository of its own in the same file — `interface Customers extends JpaRepository<CustomerEntity, Long>` with one method,
`findByNmae(String name)` — and one runner, `kitchen`, that asks it for Sunil. Boot finds the repository in the application's own
package. Then one JVM starts it, under an alarm (`perl -e 'alarm 120; exec …'`: macOS has no `timeout`), its arguments in an array,
`A`, so bash and zsh pass each one as one argument; the database is H2, in that JVM's memory. It binds no port and stops on its own;
a start that fails prints its exception and each cause, one line each. The last line keeps the lines that matter from its log.


```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && cp harness/src/probe/q/ex/ExApp.java .harness/ex/
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=none)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.q.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -oE '(Found [0-9]+ JPA repository interfaces?\.|^PROBE .*)' .harness/mine.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh):

```
the JVM: exit 1
Found 1 JPA repository interface.
PROBE threw: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'kitchen' defined in probe.q.ex.ExApp: Unsatisfied dependency expressed through method 'kitchen' parameter 0: Error creating bean with name 'customers' defined in probe.q.ex.Customers defined in @EnableJpaRepositories declared on DataJpaRepositoriesRegistrar.EnableJpaRepositoriesConfiguration: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'
PROBE caused by: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'customers' defined in probe.q.ex.Customers defined in @EnableJpaRepositories declared on DataJpaRepositoriesRegistrar.EnableJpaRepositoriesConfiguration: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'
PROBE caused by: org.springframework.data.repository.query.QueryCreationException: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'
PROBE caused by: org.springframework.data.core.PropertyReferenceException: No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'
```

Spring Data found the repository (`Found 1`) and read its method's name at start, before any runner: `find`, `By`, then a property
of `CustomerEntity` — and `CustomerEntity` has no `nmae`. The start stops there; the last cause names the property and the one it
probably meant. The same thing happens to TiffinBox with the same letter swapped (`../receipts.sh`, capture `typo`, B).

**Done** when the JVM prints `exit 0` and the runner's line for Sunil. The solution, and what it prints, is in `SOLUTION.md`.

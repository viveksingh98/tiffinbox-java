# Solution — JOIN FETCH vs @EntityGraph vs @BatchSize

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/ex && mkdir -p .harness/ex/classes && sed -e 's/^    List<Diner> findAllByOrderByNameAsc();$/    @EntityGraph(attributePaths = "breaks") List<Diner> findAllByOrderByNameAsc();/' -e 's/diners\.findAll(Sort\.by("name"))/diners.findAllByOrderByNameAsc()/' harness/src/probe/w/ex/ExApp.java > .harness/ex/ExApp.java
javac -d .harness/ex/classes -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ex/ExApp.java
A=(--spring.main.banner-mode=off --spring.thymeleaf.check-template-location=false --logging.config=../../harness/logback.xml '--spring.datasource.url=jdbc:h2:mem:ex;DB_CLOSE_DELAY=-1' --spring.jpa.hibernate.ddl-auto=create --spring.jpa.properties.hibernate.generate_statistics=true)
(cd .harness/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../ex/classes:../after/tiffinbox-web/target/extracted/lib/*" probe.w.ex.ExApp "${A[@]}") > .harness/mine.log 2>&1; echo "the JVM: exit $?"
grep -E '^PROBE ' .harness/mine.log
```

One line differs from the README's: the copy of `ExApp.java` puts the entity graph on the repository's derived method and reads the
page through it (by hand: open `.harness/ex/ExApp.java`, put the annotation on `findAllByOrderByNameAsc()` and call it in `pausedDays`):

```java
    @EntityGraph(attributePaths = "breaks") List<Diner> findAllByOrderByNameAsc();
        for (Diner d : diners.findAllByOrderByNameAsc()) {
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in the same shell, after the README's lines, in bash and in zsh — compared with this block, line for line):

```
the JVM: exit 0
PROBE diners 10 · the page's statements (getPrepareStatementCount): 1
PROBE diners 40 · the page's statements (getPrepareStatementCount): 1
```

Spring Data derives the query from the method's name — every diner, by name — and the entity graph names the collection to fetch with
it: Hibernate joins the breaks into the same statement, so the count stays one at 10 diners and at 40 diners. No JPQL is written: the
query comes from the name, the fetch plan from the annotation. TiffinBox's dashboard took the same step in this unit (`after/`'s
`CustomerEntityRepository.findAllByOrderByNameAsc()`).

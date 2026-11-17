# Solution — Aggregates, Not Entities

Spring Data JPA and Spring Data JDBC each name a repository's bean after its interface's simple name, so two interfaces called
`CustomerEntityRepository` — one for each module — ask for one bean name twice, and Spring stops the start
(`BeanDefinitionOverrideException`). Neither module is wrong; the name is shared. Rename the Spring Data JDBC one: the interface
and its file. Here it goes back to the anchor's name, `CustomerAggregates` — any name no other repository has works the same. The
block is the README's with one line changed: the copy becomes a `sed` that writes the renamed interface into `CustomerAggregates.java`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
rm .harness/ex/tree/tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerAggregates.java
sed 's/^public interface CustomerEntityRepository /public interface CustomerAggregates /' exercise/CustomerEntityRepository.java > .harness/ex/tree/tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerAggregates.java
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
mkdir -p .harness/ex/tree/secrets/tiffinbox && (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/tree/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --spring.main.web-application-type=none) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -oE 'Found [0-9]+ J[A-Z]+ repository interfaces?' .harness/ex/run.log
grep -m1 -oE "BeanDefinitionOverrideException: Invalid bean definition with name '[A-Za-z]+'" .harness/ex/run.log || echo "no override error"
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
Maven: exit 0
TiffinBox: exit 0
Found 1 JPA repository interface
Found 1 JDBC repository interface
no override error
```

Each module now claims one repository by its domain type's annotation — `CustomerEntity`'s `@Entity` for Spring Data JPA,
`CustomerRow`'s `@Table` for Spring Data JDBC — and the context starts on H2 in memory. A name check before the build catches the same
mistake without starting anything: list every repository interface's simple name across both modules, and look for one listed twice
(this unit's receipt does that, `harness/chk02.py names`).

# Exercise — Aggregates, Not Entities

**Your turn:** TiffinBox's second repository refuses to start. Rename one interface so both Spring Data modules register their repositories.

Run it from this unit's folder (`c8-unit02/`) after `./receipts.sh` has run once: it seeds nothing itself, but needs this folder's
`.m2-demo` (the course's Maven repository, offline). The block copies the anchor, `after/`, to `.harness/ex/tree`, takes out its
Spring Data JDBC repository, `CustomerAggregates.java`, and puts this folder's `CustomerEntityRepository.java` in its place — the same
repository under the name Spring Data JPA's repository already has. Maven builds the jar (offline, the tests skipped, under an alarm:
`perl -e 'alarm 300; exec …'`, macOS has no `timeout`); TiffinBox then starts from it with no web server
(`--spring.main.web-application-type=none`), on its default database, H2 in memory — no container, no Docker, no port bound — and stops
by itself once its context is up. The last lines print Maven's exit, TiffinBox's exit, each module's `Found` line from its log and the
first override error, if there was one.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
rm .harness/ex/tree/tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerAggregates.java
cp exercise/CustomerEntityRepository.java .harness/ex/tree/tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerEntityRepository.java
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
mkdir -p .harness/ex/tree/secrets/tiffinbox && (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/tree/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --spring.main.web-application-type=none) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -oE 'Found [0-9]+ J[A-Z]+ repository interfaces?' .harness/ex/run.log
grep -m1 -oE "BeanDefinitionOverrideException: Invalid bean definition with name '[A-Za-z]+'" .harness/ex/run.log || echo "no override error"
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
Maven: exit 0
TiffinBox: exit 1
Found 1 JPA repository interface
BeanDefinitionOverrideException: Invalid bean definition with name 'customerEntityRepository'
```

**Done** when TiffinBox exits 0 and both modules print their `Found` line, one repository each: Spring Data JPA's and Spring Data
JDBC's. As shipped the start stops before either module builds a repository — Spring Data JDBC's has the bean name Spring Data JPA's
already took, and Spring refuses the second definition. A hint: the error names the bean, not the module. The solution, and what it
prints, is in `SOLUTION.md`.

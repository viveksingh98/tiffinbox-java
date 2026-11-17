# Exercise — Testing the JDBC Layer

**Your turn:** this repository test asked for PostgreSQL but ran on an embedded H2 the slice made itself. Make it use the container.

Run it from this unit's folder (`c8-unit07/`) after `./receipts.sh` has run once: the receipt builds `.harness/ex0/`, a copy of
`after/` with its classes compiled, and a receipt home `.harness/home` (Testcontainers' start-up checks off). The block copies that
tree, puts `OnWhichDatabaseIT.java` into its test sources and runs that one test class through Maven, offline, from `.m2-demo`, under
an alarm (`perl -e 'alarm 300; exec …'`, macOS has no `timeout`). The test is `@DataJdbcTest` started from `JdbcSlice`, with a
PostgreSQL container declared from the pinned image; it prints the database that answered, read off the connection, and how many
customers the repository's `findAll()` read, and Spring Data JDBC's first SELECT is read off the log. The block needs Docker on the
socket it exports (OrbStack's on the author's Mac — point it at yours) and the image already on the machine: its first line prints
the image's id, and with no image Testcontainers would try to pull it — check that line before you run the rest. Ryuk, Testcontainers'
clean-up container, stays off (`TESTCONTAINERS_RYUK_DISABLED=true`), as in the anchor's README.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock TESTCONTAINERS_RYUK_DISABLED=true
docker -H "$DOCKER_HOST" image inspect --format '{{.Id}}' postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873 | cut -c1-19 | sed 's/^/the image: /'
rm -rf .harness/ex && rsync -a .harness/ex0/ .harness/ex/
cp exercise/OnWhichDatabaseIT.java .harness/ex/tiffinbox-web/src/test/java/com/tiffinbox/jdbc/OnWhichDatabaseIT.java
(cd .harness/ex && exec env MAVEN_OPTS=-Duser.home=../home perl -e 'alarm 300; exec @ARGV' mvn -o -B -Dmaven.repo.local=../../.m2-demo "-DargLine=-Duser.language=en -Duser.country=US -Duser.home=../../home -Dlogging.level.org.springframework.jdbc.core.JdbcTemplate=debug" -Dtest=OnWhichDatabaseIT -Dsurefire.failIfNoSpecifiedTests=false test) > .harness/ex.log 2>&1; echo "mvn: exit $?"
grep -h '^EX ' .harness/ex.log
grep -o 'Executing prepared SQL statement \[SELECT customer\.[A-Za-z]* AS [A-Za-z]*' .harness/ex.log | sort -u | sed 's/^Executing prepared SQL statement \[/the first SELECT: /'
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
the image: sha256:77f585114c32
mvn: exit 0
EX the database that answered: H2 2.5.250
EX findAll(): 4 customers
the first SELECT: SELECT customer.ID AS ID
```

**Done** when the database line says PostgreSQL: the container the test declared answers it, and the SELECT reads the lower-case
names PostgreSQL keeps. As shipped the test is green, and the database that answered is H2 2.5.250 — the exit says nothing about which database answered. A hint: a
container that is declared and started is not yet the slice's DataSource; something has to hand its URL to the slice, as in
`CustomerAggregatesIT`. The solution is in `SOLUTION.md`.

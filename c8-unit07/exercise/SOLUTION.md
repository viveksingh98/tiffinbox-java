# Solution — Testing the JDBC Layer

`@Container` starts the container; `@ServiceConnection` hands its URL, user and password to the slice's DataSource. Without it
`@DataJdbcTest` replaces the DataSource with an embedded H2 of its own, and the container runs unused. The block below is the
exercise's, with one line changed: the copy of the test gains `@ServiceConnection` on the container's field (the import is already
in the file).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock TESTCONTAINERS_RYUK_DISABLED=true
docker -H "$DOCKER_HOST" image inspect --format '{{.Id}}' postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873 | cut -c1-19 | sed 's/^/the image: /'
rm -rf .harness/ex && rsync -a .harness/ex0/ .harness/ex/
sed 's/^    @Container$/    @Container @ServiceConnection/' exercise/OnWhichDatabaseIT.java > .harness/ex/tiffinbox-web/src/test/java/com/tiffinbox/jdbc/OnWhichDatabaseIT.java
(cd .harness/ex && exec env MAVEN_OPTS=-Duser.home=../home perl -e 'alarm 300; exec @ARGV' mvn -o -B -Dmaven.repo.local=../../.m2-demo "-DargLine=-Duser.language=en -Duser.country=US -Duser.home=../../home -Dlogging.level.org.springframework.jdbc.core.JdbcTemplate=debug" -Dtest=OnWhichDatabaseIT -Dsurefire.failIfNoSpecifiedTests=false test) > .harness/ex.log 2>&1; echo "mvn: exit $?"
grep -h '^EX ' .harness/ex.log
grep -o 'Executing prepared SQL statement \[SELECT customer\.[A-Za-z]* AS [A-Za-z]*' .harness/ex.log | sort -u | sed 's/^Executing prepared SQL statement \[/the first SELECT: /'
```

What it prints (measured, the same capture):

```
the image: sha256:77f585114c32
mvn: exit 0
EX the database that answered: PostgreSQL 18.6
EX findAll(): 4 customers
the first SELECT: SELECT customer.id AS id
```

Both runs exit 0: the check is the database line, never the exit.

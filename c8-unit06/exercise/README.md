# Exercise — JPA vs JDBC vs Plain SQL

**Your turn:** the JDBC dashboard sends forty-three statements on PostgreSQL. Bring it to three without leaving Spring Data JDBC's repository.

Run it from this unit's folder (`c8-unit06/`) after `./receipts.sh` has run once. The receipt builds `.harness/sq/`: a copy of the
anchor whose `JdbcNames` has one more line, `context.setSingleQueryLoadingEnabled(true);` beside the quoting fix (the receipt prints
the diff). The anchor itself keeps Spring Data JDBC's default. The block compiles `Ex06.java` with that copy's jar and the
statement witness's library in `.m2-demo` (datasource-proxy 1.11.1), starts its own PostgreSQL container from the pinned image
(`--pull never`, `c8u06-ex` on `127.0.0.1:20452`, removed with its volume by `rm -fv`), runs `Ex06` on it, then runs `Ex06`
again on TiffinBox's default database, H2 in memory. `Ex06` builds the data line first (the seed's customers and pauses, by
`JdbcTemplate`), then reads the page through `CustomerAggregates` alone — the customers by name and the repository's two sums — with
a witness on the `DataSource` bean counting every statement the driver received. It prints that count beside the two sums and
whether the name order is the JPA side's list (`findAllByOrderByNameAsc()`, read outside the window). Java runs under an alarm
(`perl -e 'alarm 120; exec …'`, macOS has no `timeout`). The block needs Docker on the socket it names (OrbStack's on the author's
Mac) and the image already on the machine: with no image, `docker run` fails, the PostgreSQL line is missing, and the H2 line is the
one you get — the count H2 gives is in the block below, and it does not move with this change (single-query loading reads
`findAll()` in one statement on PostgreSQL only, measured in `../c8-unit03`'s `load` capture and here).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/sq/tiffinbox-web/target/extracted"; W="$PWD/.m2-demo/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"; DH="unix://$HOME/.orbstack/run/docker.sock"; IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
cp exercise/Ex06.java .harness/ex/src/probe/ex/Ex06.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" .harness/ex/src/probe/ex/Ex06.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
docker -H "$DH" run -d --pull never --name c8u06-ex -p 127.0.0.1:20452:5432 -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust "$IMG" > .harness/ex/docker.log 2>&1; echo "docker run: exit $?"
i=0; until docker -H "$DH" exec c8u06-ex pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1 || [ $i -ge 120 ]; do sleep 0.5; i=$((i + 1)); done
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" probe.ex.Ex06 --tiffinbox.jdbc-url='jdbc:postgresql://127.0.0.1:20452/tiffinbox?user=tiffinbox') > .harness/ex/pg.log 2>&1; echo "Ex06 on PostgreSQL: exit $?"
docker -H "$DH" rm -fv c8u06-ex > /dev/null 2>&1; echo "docker rm -fv: exit $?"
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" probe.ex.Ex06) > .harness/ex/h2.log 2>&1; echo "Ex06 on H2: exit $?"
grep -h '^EX ' .harness/ex/pg.log .harness/ex/h2.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
docker run: exit 0
Ex06 on PostgreSQL: exit 0
docker rm -fv: exit 0
Ex06 on H2: exit 0
EX PostgreSQL 18.6: data 40 customers · 38 pauses · single-query loading true
EX PostgreSQL 18.6: statements 43 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
EX PostgreSQL 18.6: done no - the page still sends one SELECT per customer for her pauses
EX H2 2.5.250: data 40 customers · 38 pauses · single-query loading true
EX H2 2.5.250: statements 43 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
EX H2 2.5.250: done no - the page still sends one SELECT per customer for her pauses
```

**Done** when the PostgreSQL line says `done yes`: the count is three, beside the same revenue and paused days, and the names come
in the JPA side's order. As shipped the page is read by `findAll(Sort.by("name"))`, and on Spring Data JDBC 4.1.2 single-query
loading does not cover a sorted `findAll(Sort)`, on PostgreSQL or on H2: the customers come in one statement and each customer's pauses in one more. A hint: the
repository has a read the flag does cover, and the order can be put back in Java. The solution is in `SOLUTION.md`.

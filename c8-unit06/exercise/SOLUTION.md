# Solution — JPA vs JDBC vs Plain SQL

With single-query loading on, Spring Data JDBC 4.1.2 reads `findAll()` in one statement on PostgreSQL, the customers and their pauses
together (`../c8-unit03`'s `load` capture: `findAll()`, `findById` and `findAllById` one statement each on PostgreSQL; `findAll(Sort)`
one per customer plus one; on H2 one per customer plus one for every read). So the page reads `findAll()` and sorts the aggregates by
name in Java, with `Comparator.comparing(CustomerRow::getName)` (the `BY_NAME` field already in `Ex06.java`): the block is the README's
with one line changed — the copy becomes a `sed` that turns `agg.findAll(Sort.by("name"))` into `agg.findAll().stream().sorted(BY_NAME).toList()`.
Still inside the repository: no SQL string is written, and the two sums are the repository's own `@Query` methods.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
X="$PWD/.harness/sq/tiffinbox-web/target/extracted"; W="$PWD/.m2-demo/net/ttddyy/datasource-proxy/1.11.1/datasource-proxy-1.11.1.jar"; DH="unix://$HOME/.orbstack/run/docker.sock"; IMG=postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873; rm -rf .harness/ex && mkdir -p .harness/ex/src/probe/ex .harness/ex/secrets/tiffinbox
sed 's/List<CustomerRow> page = agg.findAll(Sort.by("name"));/List<CustomerRow> page = agg.findAll().stream().sorted(BY_NAME).toList();/' exercise/Ex06.java > .harness/ex/src/probe/ex/Ex06.java
javac -d .harness/ex/classes -cp "$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" .harness/ex/src/probe/ex/Ex06.java > .harness/ex/javac.log 2>&1; echo "javac: exit $?"
(umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/ex/secrets/tiffinbox/shutdown-token)
docker -H "$DH" run -d --pull never --name c8u06-ex -p 127.0.0.1:20452:5432 -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust "$IMG" > .harness/ex/docker.log 2>&1; echo "docker run: exit $?"
i=0; until docker -H "$DH" exec c8u06-ex pg_isready -U tiffinbox -h 127.0.0.1 -q > /dev/null 2>&1 || [ $i -ge 120 ]; do sleep 0.5; i=$((i + 1)); done
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" probe.ex.Ex06 --tiffinbox.jdbc-url='jdbc:postgresql://127.0.0.1:20452/tiffinbox?user=tiffinbox') > .harness/ex/pg.log 2>&1; echo "Ex06 on PostgreSQL: exit $?"
docker -H "$DH" rm -fv c8u06-ex > /dev/null 2>&1; echo "docker rm -fv: exit $?"
(cd .harness/ex && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "classes:$X/tiffinbox-web-1.0.0.jar:$X/lib/*:$W" probe.ex.Ex06) > .harness/ex/h2.log 2>&1; echo "Ex06 on H2: exit $?"
grep -h '^EX ' .harness/ex/pg.log .harness/ex/h2.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
javac: exit 0
docker run: exit 0
Ex06 on PostgreSQL: exit 0
docker rm -fv: exit 0
Ex06 on H2: exit 0
EX PostgreSQL 18.6: data 40 customers · 38 pauses · single-query loading true
EX PostgreSQL 18.6: statements 3 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
EX PostgreSQL 18.6: done yes - three statements, the same sums, the JPA side's order
EX H2 2.5.250: data 40 customers · 38 pauses · single-query loading true
EX H2 2.5.250: statements 43 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
EX H2 2.5.250: done no - the page still sends one SELECT per customer for her pauses
```

On PostgreSQL the page is now one statement for the customers with their pauses and one for each sum; the revenue, the paused days
and the name order are the ones the broken run printed. On H2 the same program still sends one statement per customer for her pauses
plus the customers' own and the two sums: single-query loading covers `findAll()` on PostgreSQL and no read on H2, a setting
whose effect depends on the method and the database (S8.26), and the receipt measures both. The name order is Java's `String` order here and the database's `order by` on the other
sides; with the data line's ASCII names the two lists are equal on both databases — the check above, not a claim about collations.

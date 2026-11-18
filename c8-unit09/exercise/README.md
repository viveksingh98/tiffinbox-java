# Exercise — The Cache Abstraction's Machinery

**Your turn:** two cached methods share one cache and answer each other's calls. Give each method a key of its own.

Run it from this unit's folder (`c8-unit09/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*) and nothing else: no container, no Docker, no port bound. The block copies the anchor (`anchor/`, unit
08's tree) to `.harness/ex/tree` and the harness's sources to `.harness/ex/src`, and prints the `@Cacheable` line above `kSpel` in the
copy of `H09.java`. Maven builds the jar from that tree (offline, the tests skipped, every module from the tree's own sources:
`-pl tiffinbox-web -am`), under an alarm (`perl -e 'alarm 300; exec …'`; macOS has no `timeout`). The harness — this unit's program,
`harness/src/probe/u09` — is compiled against the jar's libraries and starts TiffinBox's application class with no web server, on its
default database, H2 in memory, beside the harness bean `H09.Reads` (a harness bean, not the anchor's cache). It calls `k1("a")`, then
`kSpel("a", 9)`, on the bean's one cache `h09:keys`, and prints what each call returned and both counters per call: the calls that
reached Spring Data JPA's repository (a counter on the repository's proxy) and Hibernate's `getPrepareStatementCount()`. Each method's
body reads the database once, and answers with its own name.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox .harness/ex/src && rsync -a --exclude target --exclude secrets anchor/ .harness/ex/tree/ && cp harness/src/probe/u09/*.java .harness/ex/src/
echo "kSpel's @Cacheable: $(grep -B1 'public String kSpel' .harness/ex/src/H09.java | head -1 | sed -E 's/^ +//')"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -parameters -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" .harness/ex/src/*.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" probe.u09.U9 pair --logging.config=../../../harness/logback.xml --spring.jpa.properties.hibernate.generate_statistics=true) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -oE 'repository calls [0-9]+ · prepareStatementCount [0-9]+ · per call \[[0-9, ]+\] and \[[0-9, ]+\] · returned \[[^]]*\]' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
kSpel's @Cacheable: @Cacheable(cacheNames = "h09:keys", key = "#a")
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
repository calls 1 · prepareStatementCount 1 · per call [1, 0] and [1, 0] · returned [k1:4, k1:4]
```

**Done** when the last line's second answer names `kSpel` and both lists read one for each call. TiffinBox's exit says nothing here:
it is 0 in both states, and so is Maven's. As shipped, `k1` takes the default key — its one argument itself, `a` — and `kSpel` names
its key `#a`, the same `a`: one cache, one key, two methods. `kSpel`'s call finds `k1`'s answer under that key and returns it; its
method never runs, and nothing says so — no exception, no log line. A hint: the key `kSpel` names can say which method it is. The
solution, and what it prints, is in `SOLUTION.md`.

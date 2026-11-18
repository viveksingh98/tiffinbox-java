# Exercise — Caffeine

**Your turn:** Caffeine counts the customer list's hits, yet the prometheus endpoint has no cache line. Make its hits appear there.

Run it from this unit's folder (`c8-unit10/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*) and nothing else: no container, no Docker; it binds one port, 20492 (127.0.0.1), for TiffinBox's own
web server, and frees it when TiffinBox stops. The block copies the anchor, `after/`, to `.harness/ex/tree` and takes the
`spring.cache.cache-names: customers` line out of its `application.yaml` with `harness/variants.py` (the same derivation the receipt's
`nonames` capture uses: that one line, nothing else). Maven builds the jar from that tree (offline, the tests skipped, every module from
the tree's own sources: `-pl tiffinbox-web -am`), under an alarm (`perl -e 'alarm 300; exec …'`; macOS has no `timeout`). The harness —
this unit's program, `harness/src/probe/u10` — is compiled against the jar's libraries and starts TiffinBox's application class with its
web server, on its default database, H2 in memory, calls `CustomerRepository.findAll()` five times through the context's bean, prints
Caffeine's own counts for the customers cache, then asks TiffinBox's `/actuator/prometheus` over HTTP and prints its status and the
cache lines it holds for that cache.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
python3 -I -B harness/variants.py .harness/ex/tree > /dev/null; echo "cache-names lines in application.yaml: $(grep -c '^    cache-names: customers$' .harness/ex/tree/tiffinbox-web/src/main/resources/application.yaml)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" harness/src/probe/u10/*.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" probe.u10.U10 reads,scrape --tiffinbox.port=20492 --logging.config=../../../harness/logback.xml --spring.jpa.properties.hibernate.generate_statistics=true) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -oE 'hitCount=[0-9]+, missCount=[0-9]+|GET /actuator/prometheus -> [0-9]+ · cache_ lines [0-9]+ · cache_ lines for customers [0-9]+|cache_gets_total\{[^}]*result="hit"\} [0-9.]+' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
cache-names lines in application.yaml: 0
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
hitCount=4, missCount=1
GET /actuator/prometheus -> 200 · cache_ lines 0 · cache_ lines for customers 0
```

**Done** when the last line is the customers cache's hit line from `/actuator/prometheus` — a line Micrometer writes for a cache named at the start. TiffinBox's exit says nothing here: it is 0
in both states, and so is Maven's; and Caffeine's own counts are the same in both — Caffeine counts either way. As shipped the endpoint
answers, and holds no cache line at all: no error, no log line. A hint: Micrometer reports a cache it was told about when TiffinBox
started. The solution, and what it prints, is in `SOLUTION.md`.

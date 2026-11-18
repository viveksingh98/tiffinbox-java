# Exercise — @Cacheable, @CacheEvict, @CachePut

**Your turn:** TiffinBox starts, no error, and five customer reads still cost five statements. Make the fifth read cost none.

Run it from this unit's folder (`c8-unit08/`). It needs this folder's `.m2-demo` (a copy of the course's Maven repository, offline —
`README.md`, *The repository*) and nothing else: no container, no Docker, no port bound. The block copies the anchor, `after/`, to
`.harness/ex/tree` and takes `@EnableCaching` off its `TiffinBoxApp` with `harness/variants.py` (the same derivation the receipt's `off`
capture uses: the annotation's line and its import line, nothing else). Maven builds the jar from that tree (offline, the tests skipped,
every module from the tree's own sources: `-pl tiffinbox-web -am`), under an alarm (`perl -e 'alarm 300; exec …'`; macOS has no
`timeout`). The harness — this unit's counter program, `harness/src/probe/u08` — is compiled against the jar's libraries and starts
TiffinBox's application class with no web server, on its default database, H2 in memory, and calls `CustomerRepository.findAll()` five
times through the context's bean. It prints both counters for the five calls: the calls that reached Spring Data JPA's repository (a
counter on the repository's proxy, outside the cached bean) and Hibernate's `getPrepareStatementCount()`, each per call.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
python3 -I -B harness/variants.py .harness/ex/tree > /dev/null; echo "@EnableCaching lines in TiffinBoxApp.java: $(grep -c '^@EnableCaching$' .harness/ex/tree/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" harness/src/probe/u08/*.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" probe.u08.U8 hits --logging.config=../../../harness/logback.xml --spring.jpa.properties.hibernate.generate_statistics=true) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -oE 'repository calls [0-9]+ · prepareStatementCount [0-9]+ · per call \[[0-9, ]+\] and \[[0-9, ]+\]' .harness/ex/run.log
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
@EnableCaching lines in TiffinBoxApp.java: 0
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
repository calls 5 · prepareStatementCount 5 · per call [1, 1, 1, 1, 1] and [1, 1, 1, 1, 1]
```

**Done** when the last line's two lists both read one for the first call and none for the four after it. TiffinBox's exit says nothing
here: it is 0 in both states, and so is Maven's. As shipped `CustomerRepository` still carries `@Cacheable("customers")` on `findAll()` —
and the annotation does nothing, because nothing registered the advisor that reads it, and nothing says so: no CacheManager bean, no
error, no log line. A hint: the annotation that is missing goes on the class Boot starts from. The solution, and what it prints, is in
`SOLUTION.md`.

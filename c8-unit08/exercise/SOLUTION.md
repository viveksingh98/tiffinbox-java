# Solution — @Cacheable, @CacheEvict, @CachePut

**Your turn:** TiffinBox starts, no error, and five customer reads still cost five statements. Make the fifth read cost none.

`@EnableCaching` on `TiffinBoxApp` — the class Boot starts from — registers the advisor that puts `@Cacheable` and `@CacheEvict` in
front of `CustomerRepository`'s methods, and with it Boot's cache module builds a `CacheManager` (no cache library on the class path:
a `ConcurrentMapCacheManager`, each cache a `ConcurrentHashMap` in the JVM). Put it back: here the block keeps `after/` as shipped —
the annotation and its import line, the two lines the README's copy took off. The block is the README's with one line changed: the
derivation is not run, and the count of the annotation's lines is printed as before.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
echo "@EnableCaching lines in TiffinBoxApp.java: $(grep -c '^@EnableCaching$' .harness/ex/tree/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java)"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" harness/src/probe/u08/*.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" probe.u08.U8 hits --logging.config=../../../harness/logback.xml --spring.jpa.properties.hibernate.generate_statistics=true) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -oE 'repository calls [0-9]+ · prepareStatementCount [0-9]+ · per call \[[0-9, ]+\] and \[[0-9, ]+\]' .harness/ex/run.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
@EnableCaching lines in TiffinBoxApp.java: 1
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
repository calls 1 · prepareStatementCount 1 · per call [1, 0, 0, 0, 0] and [1, 0, 0, 0, 0]
```

The first call is a miss — the method runs, the repository is called once, Hibernate prepares one statement — and the cache keeps
its answer under the key of a call with no argument (`SimpleKey []`); the four calls after it are hits: neither counter moves. The
check is the two counters, never the exit: both runs exit 0.

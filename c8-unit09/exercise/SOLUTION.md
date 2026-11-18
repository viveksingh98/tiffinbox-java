# Solution — The Cache Abstraction's Machinery

**Your turn:** two cached methods share one cache and answer each other's calls. Give each method a key of its own.

Name the method in the key. `kSpel`'s `@Cacheable` becomes `@Cacheable(cacheNames = "h09:keys", key = "#root.methodName + ':' + #a")`:
its key for `a` is now `kSpel:a`, and `k1`'s is still `a` — two keys in the one cache. The block is the README's with one line changed:
that line runs `harness/variants.py key` on the copied sources (the one annotation above `kSpel`, asserted, nothing else) before it
prints the line; by hand, it is the same edit in `.harness/ex/src/H09.java`.

The other way, not run here: a cache each — `kSpel` on a cache of its own name (`cacheNames = "h09:spel"`), so the key `a` can repeat
without meeting `k1`'s.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex/run/secrets/tiffinbox .harness/ex/src && rsync -a --exclude target --exclude secrets anchor/ .harness/ex/tree/ && cp harness/src/probe/u09/*.java .harness/ex/src/
python3 -I -B harness/variants.py key .harness/ex/src > /dev/null; echo "kSpel's @Cacheable: $(grep -B1 'public String kSpel' .harness/ex/src/H09.java | head -1 | sed -E 's/^ +//')"
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" clean package -DskipTests -pl tiffinbox-web -am) > .harness/ex/build.log 2>&1; echo "Maven: exit $?"
(cd .harness/ex/tree && exec perl -e 'alarm 120; exec @ARGV' java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted) > .harness/ex/extract.log 2>&1
L=.harness/ex/tree/tiffinbox-web/target/extracted; perl -e 'alarm 120; exec @ARGV' javac -parameters -d .harness/ex/hc -cp "$L/tiffinbox-web-1.0.0.jar:$L/lib/*" .harness/ex/src/*.java; echo "javac: exit $?"
(umask 077 && openssl rand -hex 16 > .harness/ex/run/secrets/tiffinbox/shutdown-token)
(cd .harness/ex/run && exec perl -e 'alarm 120; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../tree/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../tree/tiffinbox-web/target/extracted/lib/*" probe.u09.U9 pair --logging.config=../../../harness/logback.xml --spring.jpa.properties.hibernate.generate_statistics=true) > .harness/ex/run.log 2>&1; echo "TiffinBox: exit $?"
grep -oE 'repository calls [0-9]+ · prepareStatementCount [0-9]+ · per call \[[0-9, ]+\] and \[[0-9, ]+\] · returned \[[^]]*\]' .harness/ex/run.log
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
kSpel's @Cacheable: @Cacheable(cacheNames = "h09:keys", key = "#root.methodName + ':' + #a")
Maven: exit 0
javac: exit 0
TiffinBox: exit 0
repository calls 2 · prepareStatementCount 2 · per call [1, 1] and [1, 1] · returned [k1:4, kSpel:4]
```

Each method now answers with its own value, and each call runs its method once: the two keys are separate entries in `h09:keys`, in the
JVM, a `ConcurrentMap`. The check is the two values and the counters, never the exit: both runs exit 0.

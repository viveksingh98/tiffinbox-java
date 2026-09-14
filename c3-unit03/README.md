# c3-unit03 — Dependencies: Scope, Transitivity, Conflict

**Line 1 of every block below is not optional.** Without it a bare `mvn` on this Mac resolves Java 26.0.2.1 and
a bare `java` is 23.0.1, so the `java -jar` line in step 4 dies with
`UnsupportedClassVersionError … class file version 69.0` instead of the failure this unit is about.
Verified on **Apache Maven 3.9.16** and **JDK 25.0.4.1**, 2026-09-14. Every command below was run **3 times**;
only byte-identical output is quoted.

> **On the local repository.** The commands below run without `-Dmaven.repo.local`, on purpose: they only
> `compile` and `package`, so nothing of this course is ever *installed* into your repository — the units that
> do install (`c3-unit02`, `c3-unit04`, `c3-unit06`) carry the flag on every line, and so does this unit's
> `exercise/`. If you would rather keep even the downloaded third-party jars out of `~/.m2`, add
> `"-Dmaven.repo.local=${TMPDIR:-/tmp}/c3-m2"` to each command — **with the quotes**, because a path
> containing a space is otherwise split by the shell into a bogus goal name.


```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
```

### The five commands

| # | in | command | real output |
|---|---|---|---|
| 1 | `conflict/` | `mvn -B dependency:tree -Dverbose` | two `… - omitted for conflict with 2.22.2` lines |
| 2 | `conflict/` | `cp poms/pom-yaml-first.xml pom.xml && mvn -B -q clean compile && mvn -B -q exec:exec` | `jackson-core  : 2.13.5` |
| 3 | `conflict/` | `cp poms/pom-jsr310-first.xml pom.xml && mvn -B -q clean compile && mvn -B -q exec:exec` | `jackson-core  : 2.22.2` |
| 4 | `provided-break/` | `mvn -B clean package && java --enable-preview -jar target/c2-capstone-1.0.0.jar` | `BUILD SUCCESS`, then `NoClassDefFoundError: com/fasterxml/jackson/databind/ObjectMapper` (exit 1) |
| 5 | `scopes/` | `for s in compile runtime test; do mvn -B -q dependency:build-classpath -DincludeScope=$s -Dmdep.outputFile=cp-$s.txt; done` | `compile 4 jars · runtime 4 jars · test 14 jars` |

### What is in here

```
conflict/          the conflict, and every state of it — one src/, four POMs in poms/
                     pom-databind-first.xml   shipped as pom.xml — databind 2.22.2 + yaml 2.13.5
                     pom-yaml-first.xml       yaml 2.13.5 declared before jsr310 2.22.2
                     pom-jsr310-first.xml     the same two dependencies, exchanged
                     pom-excluded.xml         the fix: <exclusions>, zero "omitted for conflict" lines
                   swap a state with:  cp poms/pom-<name>.xml pom.xml
scopes/            four dependencies, one <scope> each, plus an imported junit-bom
provided-break/    the capstone with ONE edit — jackson-databind marked <scope>provided</scope>
exercise/          green compile, dead run — see exercise/README.md
```

### Receipts

`mvn -o -B verify` → `BUILD SUCCESS`, exit 0, on all four projects, on all four `conflict/` POM states, and on
`exercise/solution/`. `~/.m2/repository/com/tiffinbox` does not exist — nothing here was installed.
Three POMs (`pom-jsr310-first.xml`, `pom-excluded.xml`, `exercise/solution/pom.xml`) produce **byte-identical**
program output, md5 `7af6f75066689b3e6d64c64f707d8782`, 3/3 each.

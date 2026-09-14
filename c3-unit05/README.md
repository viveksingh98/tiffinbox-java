# c3-unit05 — Multi-Module TiffinBox

The unit itself writes to **`../c3-tiffinbox/`** — the long-lived multi-module project that
every later unit of this course builds on. Read that project's own `README.md` for the build
command, the run command and their real output.

> **On the local repository.** The commands below run without `-Dmaven.repo.local`, on purpose: they only
> `compile` and `package`, so nothing of this course is ever *installed* into your repository — the units that
> do install (`c3-unit02`, `c3-unit04`, `c3-unit06`) carry the flag on every line, and so does this unit's
> `exercise/`. If you would rather keep even the downloaded third-party jars out of `~/.m2`, add
> `"-Dmaven.repo.local=${TMPDIR:-/tmp}/c3-m2"` to each command — **with the quotes**, because a path
> containing a space is otherwise split by the shell into a bogus goal name.


This folder holds only what is *not* part of that project: the exercise.

```
c3-unit05/
  exercise/
    README.md          the task, the starting output and the end state
    c3-tiffinbox/      the same project with ONE line added to tiffinbox-web/pom.xml
    solution/pom.xml   the finished tiffinbox-web/pom.xml
```

## The exercise in one line

`tiffinbox-web/pom.xml` declares `jackson-databind` at `2.13.5` while the parent manages
`2.22.2`. `mvn -B clean package` is green either way, with **no warning of any kind**.
Make the version live in exactly one place.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd exercise/c3-tiffinbox
mvn -B clean package
mvn -B dependency:tree -Dincludes=com.fasterxml.jackson.core
ls tiffinbox-web/target/lib
```

**End state:** the tree prints `jackson-databind:jar:2.22.2` and `target/lib` contains
`jackson-databind-2.22.2.jar`.

The answer is `solution/pom.xml`, which is byte-identical to the shipped
`../c3-tiffinbox/tiffinbox-web/pom.xml`.

## Why it is worth doing

The broken state is not broken in any way a build tool will tell you about. Measured on this
Mac: both states compile, both package, both run, and the running server's output is
**byte-identical** — md5 `d6402e7c500031cb39addba72cb846e5` either way. `ls target/lib` is the
only thing that knows which jars you actually shipped.

Verified on **JDK 25.0.4.1** with **Maven 3.9.16**, three runs of each state, both `BUILD
SUCCESS`, exit 0.

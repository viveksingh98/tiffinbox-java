# Exercise — make the version live in exactly one place

`c3-tiffinbox/` here is the split project with **one line added**: `tiffinbox-web/pom.xml`
declares `jackson-databind` at `2.13.5`, while the parent's `<dependencyManagement>` manages
`2.22.2`. The build is green either way, and Maven says nothing at all.

## Start

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
cd c3-tiffinbox
mvn -B clean package
mvn -B dependency:tree -Dincludes=com.fasterxml.jackson.core
ls tiffinbox-web/target/lib
```

Before you change anything, that prints `BUILD SUCCESS`, a tree at **2.13.5**, and a
`target/lib` holding **three 2.13.5 jars**:

```
[INFO] com.tiffinbox:tiffinbox-web:jar:1.0.0
[INFO] \- com.fasterxml.jackson.core:jackson-databind:jar:2.13.5:compile
[INFO]    +- com.fasterxml.jackson.core:jackson-annotations:jar:2.13.5:compile
[INFO]    \- com.fasterxml.jackson.core:jackson-core:jar:2.13.5:compile
```
```
h2-2.5.250.jar
jackson-annotations-2.13.5.jar
jackson-core-2.13.5.jar
jackson-databind-2.13.5.jar
tiffinbox-core-1.0.0.jar
```

## The task

**Make the version live in exactly one place.**

## End state

The same two commands must print `jackson-databind:jar:2.22.2` and a `target/lib` containing
`jackson-databind-2.22.2.jar`:

```
[INFO] com.tiffinbox:tiffinbox-web:jar:1.0.0
[INFO] \- com.fasterxml.jackson.core:jackson-databind:jar:2.22.2:compile
[INFO]    +- com.fasterxml.jackson.core:jackson-annotations:jar:2.22:compile
[INFO]    \- com.fasterxml.jackson.core:jackson-core:jar:2.22.2:compile
```
```
h2-2.5.250.jar
jackson-annotations-2.22.jar
jackson-core-2.22.2.jar
jackson-databind-2.22.2.jar
tiffinbox-core-1.0.0.jar
```

Note what moved and what did not: `jackson-annotations` goes to **2.22**, not 2.22.2 — that
module does not ship on every patch, and the number legitimately differs.

## Answer

`solution/pom.xml` is the finished `tiffinbox-web/pom.xml`: the child's `<version>` element is
gone, and the parent decides. Copy it over and re-run:

```bash
cp ../solution/pom.xml tiffinbox-web/pom.xml
mvn -B clean package
mvn -B dependency:tree -Dincludes=com.fasterxml.jackson.core
ls tiffinbox-web/target/lib
```

**Verified by the author on JDK 25.0.4.1 with Maven 3.9.16** — broken state and solved state
each run three times, both `BUILD SUCCESS`, exit 0.

## Why this is the exercise

Nothing failed. Both states compile, both package, both run, and the running service prints
**byte-identical output** — measured: md5 `d6402e7c500031cb39addba72cb846e5` either way. The
only thing that tells you which jars you shipped is `ls target/lib` and `dependency:tree`.
`<dependencyManagement>` is a **default, not a rule**: it says *if you do not name a version,
use this* — never *you may not name a different one*.

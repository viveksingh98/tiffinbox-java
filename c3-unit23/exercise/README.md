# Exercise 23 — build the same jar twice and get two different files

This directory is the unit's project with **one property missing**. Build it twice and hash
the jar each time:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd <c3-unit23>/exercise
mvn -B -Dmaven.repo.local="../.m2-demo" clean package -DskipTests
md5 -q target/tiffinbox-core-1.0.0.jar
mvn -B -Dmaven.repo.local="../.m2-demo" clean package -DskipTests
md5 -q target/tiffinbox-core-1.0.0.jar
```

**Start state:** the two hashes **differ**, and nothing changed between the two builds — not
a source file, not a dependency, not a flag. The jar's entry timestamps are a wall clock, and
a wall clock is not a build input you control.

**End state:** the same two commands print the **same hash**, with **0 lines of Java
changed**.

The answer is one property, in `solution/pom-fragment.xml`. `../receipts.sh solution` runs
both states for you and **refuses to continue if the untouched exercise is already
reproducible** — so the exercise cannot pass by accident on a machine where it was never
broken.

# Exercise — the menu that loads everywhere except where it matters

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"

java -cp "src/main/java:$CP" com.tiffinbox.Menu     # the class path your IDE gives you
java -cp "$CP"               com.tiffinbox.Menu     # the class path you ship
```

Two runs, one file, two answers.

1. **Find it with the tooling, not by reading the code.** Build the jar and look inside it. Course 3
   taught you the command; one line answers this.
2. **Fix it** so both runs agree — and the fix is one `git mv`, not a code change.
3. **Say why Maven treats the two directories differently** rather than just moving the file. If you
   cannot, the next non-Java file you add lands in the same place.

Solution in `solution/`.

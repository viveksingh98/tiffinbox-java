# Exercise — the condition copied from the documentation

Orders over 500 get a call from the manager. The listener's condition names its parameter, and the
kitchen falls over on the first order. **Fix the condition without touching the build file**: a 900 order
gets the call, a 340 order does not. Then say what one line in the build file would also have fixed it,
and why this course does not rely on it.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.BigOrders
```

Solution in `solution/`.

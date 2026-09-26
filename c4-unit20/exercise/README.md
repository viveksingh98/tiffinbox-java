# Exercise — the receipt log that never writes

`Receipt.java`'s aspect should log every bill. It logs none. **Before reading the pointcut**, run it
and look at `bean class`. Explain from that one line why nothing ran — then fix the pointcut, and
show the class name change.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Receipt
```

Solution in `solution/`.

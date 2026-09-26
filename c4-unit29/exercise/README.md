# Exercise — the heartbeat nobody heard stop

The kitchen's old heartbeat runs on the **JDK's own scheduler** (`scheduleAtFixedRate`), not on Spring's. On its
second beat the printer is out of paper. The heartbeat is never heard from again, and nothing is printed anywhere.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Heartbeat
```

```
beats in 0.7 s: 2 - dead
```

1. The exception was **not** thrown away. It is being kept somewhere. Find it and print it.
2. Make the heartbeat survive a bad beat — and make the bad beat **loud**, so the next person doesn't have to
   go looking.

Solution in `solution/`.

# Exercise — prove the weaving, not the warnings

Load-time weaving is "configured": the agent is on the command line and the warnings print. Run it:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
AJ=$(tr ':' '\n' < cp.txt | grep aspectjweaver)
java -javaagent:"$AJ" -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Proof
```

Decide **from the number, not the warnings**, whether anything was woven. Then fix
`META-INF/aop.xml` until `priceTwice()` runs the advice twice. The warnings will not change either way —
that is the point. Solution in `solution/aop.xml`.

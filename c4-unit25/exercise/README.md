# Exercise — delete the loyalty edge

The kitchen awards loyalty points by calling `LoyaltyBook` directly. Delete that edge: publish
`OrderPlaced`, and let a listener award the points. Prove it with `Edges` — the kitchen's own
dependencies must print `[]` — and the points must still be **34**.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Loyalty
```

Solution in `solution/`.

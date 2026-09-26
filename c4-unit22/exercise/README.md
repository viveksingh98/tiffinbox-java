# Exercise — audit only refunds

The rule in `OnlyRefunds` audits every call in the package. Make it audit **only** `refund()` — and prove
it the unit's way: `menu` must come back as its plain class, not a proxy. Bonus: explain why
`args(String)` would be the wrong fix even if it happened to count right.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.OnlyRefunds
```

Solution in `solution/`.

# Exercise — the checkout the pricing aspect never sees

`checkout()` prices each item by calling `price()` on itself, so the aspect never runs. Fix it **the real
way** — extract a second bean — not with self-injection or `AopContext`. Advice must run once per item.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Checkout
```

Solution in `solution/`.

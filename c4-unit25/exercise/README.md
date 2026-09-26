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

`Edges` sees injected dependencies only — a kitchen that fetches the book with `ctx.getBean(...)` would still
print `[]`. So prove the second half by reading the class, the way the unit counted `SmsNotifier`:

```
sed -n '/class Kitchen/,/^    }/p' src/main/java/com/tiffinbox/Loyalty.java | grep -c LoyaltyBook    # must print 0
```

Solution in `solution/`.

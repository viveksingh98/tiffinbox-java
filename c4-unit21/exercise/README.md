# Exercise — a student discount the billing service never hears about

Students pay 10% less; `BillingService` must not change. Finish `Discount.StudentDiscount` so
`student-Asha` pays 306 and `Ravi` still pays 340. Pick the one advice type that can change a return value,
and do not forget the call that makes the real method run.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Discount
```

Solution in `solution/`.

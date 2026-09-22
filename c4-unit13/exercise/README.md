# Exercise — make the rail you meant win

`rails-one.properties` staffs the kitchen with **four** cooks. `rails-two.properties` was added later
for a load test and still says **one**, and it is winning — so TiffinBox is running a quarter-staffed
kitchen and nothing is wrong with the build, the code or the container.

Run it and see which number arrives:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Sources --key=tiffinbox.cooks
```

**Your job: make `tiffinbox.cooks` resolve to 4, WITHOUT reordering or editing either
`@PropertySource` line and WITHOUT deleting the line from `rails-two.properties`.**

Two rules, and they are the unit's rules:

1. **Prove it with the ordered stack, not with the number.** A capture that only shows `4` does not
   show you *why* — and the `WINNER` line in this unit has already been caught staying still while
   everything under it moved.
2. **Say which source answered.** The report prints every source and whether it carries the key.
   Your fix should be visible as a row, not inferred from an outcome.

The solution is in `solution/`. Read it after you have a capture of your own.

# Exercise — a message with a dollar sign in it

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.CheckADelivery
```

Somebody hit `HV000183`, read the advice at the end of it, and did exactly what it said. Exit 0. The
violation is detected correctly. And your customer is reading a dollar sign.

**Make the message read correctly, then say in one line which of the two fixes you chose and what it
costs.** There are exactly two, and neither is free:

- **Bring an EL implementation** and drop the `ParameterMessageInterpolator`. Costs: two more jars
  on the class path, and an expression language evaluating strings that came from your constraint
  annotations.
- **Keep the interpolator and stop writing EL** in messages — `{value}` is a message parameter and
  works everywhere; `${validatedValue}` is not. Costs: you cannot put the offending value in the
  message at all, so the message is less useful.

**Do not skip the second question.** Before you change anything, run it and look at `stderr`. There
is a warning there naming your exact problem, and the whole point of this unit is that it did not
help — not because it was wrong, but because nobody reads it.

The EL layer is available on this project as `mvn -Pel …`, same as the unit.

Solution in `solution/`.

# Exercise — "we send an idempotency key, so retries are safe"

This gateway **honours an idempotency key**: a second charge that carries a key it has already seen is not
charged again. The payment code sends a key on every call, and the team says that makes the retry safe.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.TheBill
```

```
  one order of 340: paid after 3 attempts
  charged 1020 for one order
```

Keep the retry. Keep the key. **Make the bill 340** — and say in one line why the key the team sends does not
protect anything.

Solution in `solution/`.

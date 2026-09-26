# Exercise — the receipt printer that eats threads

With no executor, every receipt gets a brand-new thread. Give the printer a pool of exactly **3** threads
named `receipts-`, and prove it: 30 receipts must run on 3 distinct threads.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Receipts
```

Solution in `solution/`.

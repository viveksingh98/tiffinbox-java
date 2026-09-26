# Exercise — closing time the kitchen does not know about

After 22:00 `place()` must answer `closed`, **without editing `KitchenRail`**. Build a proxy in front of it.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.ClosingTime 23   # must say closed
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.ClosingTime 12   # must cook
```

The last line calls the real rail directly: it must still cook, at any hour — if it says `closed`, the
kitchen class learned about closing time. Solution in `solution/`.

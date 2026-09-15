# Exercise 25 — the green build that shipped a broken jar

Nothing in this exercise is broken code. `mvn verify` is green:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd ..                     # the unit root
mvn -B -ntp -Dmaven.repo.local="$PWD/.m2-demo" clean package
java -cp target/classes com.tiffinbox.ci.MenuLoader     # prints ok
```

Now run the jar that same build just produced:

```
java -cp target/tiffinbox-core-1.0.0.jar com.tiffinbox.ci.MenuLoader
```

**Start state:** `java.io.IOException: menu resource not found on the classpath:
/menu.json`, exit **1** — from the artifact of a build that said `BUILD SUCCESS`.

**End state:** the same command prints `meal types declared: 3` and `ok`, exit **0**, with
**0 Java files changed**.

The answer is `solution/fix.txt`, and `../receipts.sh solution` runs both states and stops
if the shipped jar already works.

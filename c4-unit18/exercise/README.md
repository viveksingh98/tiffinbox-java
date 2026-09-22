# Exercise — a third customer whose language you do not have

Three bundles: base, Italian, Spanish. A customer asks in **French**, and there is no French.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"

java -Duser.language=en -Duser.country=US -cp "$CP" com.tiffinbox.Notices
java -Duser.language=es -Duser.country=ES -cp "$CP" com.tiffinbox.Notices
```

**Make the French customer get the fallback YOU chose, not the one the laptop chose — and prove it
by changing only the JVM default locale.**

Two rules from the unit:

1. **Pass every locale flag as its own literal argument.** `-Duser.language=es -Duser.country=ES`,
   never a loop variable that your shell may or may not split. That mistake hid this unit's entire
   finding once already.
2. **Prove it with a difference, not with a run.** One green run tells you what happened on *your*
   machine. The claim is about every machine, so the capture has to vary the thing you are claiming
   does not matter.

Solution in `solution/`.

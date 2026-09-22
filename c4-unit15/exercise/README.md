# Exercise — two rails, and the desk cannot choose

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
java -cp "$CP" com.tiffinbox.Desk
```

Both rails are declared and neither says when it applies. Read what the container says — you met
that exception in unit 06, and the fix there was `@Primary` or `@Qualifier`. **Neither is the answer
here**, and the unit says why: those pick between two beans that both exist, and what you want is
for only one of them to exist at all.

Three things:

1. **Make exactly one rail exist**, decided at startup rather than inside an `if`.
2. **Prove which one** with `ContextReport` — `definition` *and* `instantiated`. One column cannot
   tell "there is no recipe" from "nothing built it yet", which is the whole reason the report has
   two.
3. **When nobody chose, refuse to start.** Do not add a fallback. This kitchen has no safe default,
   and a fallback here means shipping a load test against a real database, or the reverse.

```
java -cp "$CP" com.tiffinbox.Desk in-memory     # one rail
java -cp "$CP" com.tiffinbox.Desk               # must fail, and you should be able to say why
java -cp "$CP" com.tiffinbox.ContextReport in-memory
```

Solution in `solution/`.

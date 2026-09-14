# Exercise — the version that lost

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B clean compile     # BUILD SUCCESS
mvn -B exec:exec         # dies, exit 1
```

**Starting state.** `mvn -B clean compile` is green. `mvn -B exec:exec` dies with

```
Exception in thread "main" java.lang.NoClassDefFoundError: com/fasterxml/jackson/core/exc/StreamConstraintsException
	at com.fasterxml.jackson.databind.deser.BasicDeserializerFactory.createTreeDeserializer(BasicDeserializerFactory.java:1130)
```

**Your task.** Run `mvn -B dependency:tree -Dverbose`, find the version that was **omitted**, and fix `pom.xml`.

**End state.** `mvn -B exec:exec` prints:

```
routes        : 3
stops         : 34
jackson-core  : 2.22.2
databind      : 2.22.2
```

**Solution** — `solution/pom.xml`, run by the author (3/3 identical, exit 0): delete the hand-written
`jackson-core:2.13.5` block and import `com.fasterxml.jackson:jackson-bom:2.22.2` in `<dependencyManagement>`.
Copy it over with `cp solution/pom.xml pom.xml`. The tree's wording changes too — `omitted for conflict with`
becomes `version managed from`, which means **you** chose instead of Maven choosing.

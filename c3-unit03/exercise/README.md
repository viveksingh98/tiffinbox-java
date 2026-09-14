# Exercise — the version that lost

Every `mvn` below runs against a **scratch local repository**, never your real `~/.m2` — that is the
one flag that separates these lines from the ones that fill your own repository. **Keep the quotes:**
this tree's path contains a space, and unquoted in bash `-Dmaven.repo.local=` splits and Maven answers
`Unknown lifecycle phase "Content/…"`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M2="${TMPDIR:-/tmp}/c3-m2"                              # scratch repo, never your real ~/.m2
mvn -B "-Dmaven.repo.local=$M2" clean compile           # BUILD SUCCESS
mvn -B "-Dmaven.repo.local=$M2" exec:exec               # dies, exit 1
```

**Starting state.** The `clean compile` line is green. The `exec:exec` line dies with

```
Exception in thread "main" java.lang.NoClassDefFoundError: com/fasterxml/jackson/core/exc/StreamConstraintsException
	at com.fasterxml.jackson.databind.deser.BasicDeserializerFactory.createTreeDeserializer(BasicDeserializerFactory.java:1130)
```

**Your task.** Run `mvn -B "-Dmaven.repo.local=$M2" dependency:tree -Dverbose`, find the version that was
**omitted**, and fix `pom.xml`.

**End state.** `mvn -B "-Dmaven.repo.local=$M2" exec:exec` prints:

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

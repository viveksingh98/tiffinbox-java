# Unit 34 — Maven in 15 Minutes

**What this unit teaches:** The build tool: `pom.xml`, a dependency, a plugin, the standard layout and the runnable jar Maven produces.

**You need:** JDK 25 and Apache Maven 3.9.x, with `JAVA_HOME` pointing at JDK 25. Verified on JDK 25.0.4.1, Maven 3.9.16, compiler 3.15.0, surefire 3.5.3, jar 3.5.0. The first `mvn` run downloads JUnit and the plugins into `~/.m2` and prints ~170 download lines; later runs are quiet.

Run everything from this folder (`cd unit34`), in the order below.

### mvn -q package

Compile, test and package — `-q` hides Maven's own log.

```console
$ mvn -q package && ls target
classes
generated-sources
maven-archiver
maven-status
tiffinbox-1.0.jar
```

### java -jar target/tiffinbox-1.0.jar

The jar runs because `maven-jar-plugin` wrote `Main-Class` into the manifest.

```console
$ java -jar target/tiffinbox-1.0.jar
3 customers on file
Ravi pays 7200
```

### java -cp target/classes com.tiffinbox.Main

The same classes without the jar.

```console
$ java -cp target/classes com.tiffinbox.Main
3 customers on file
Ravi pays 7200
```

### jar tf target/tiffinbox-1.0.jar

What is actually inside the jar.

```console
$ jar tf target/tiffinbox-1.0.jar
META-INF/
META-INF/MANIFEST.MF
com/
com/tiffinbox/
META-INF/maven/
META-INF/maven/com.tiffinbox/
META-INF/maven/com.tiffinbox/tiffinbox/
com/tiffinbox/Billing.class
com/tiffinbox/Main.class
META-INF/maven/com.tiffinbox/tiffinbox/pom.xml
META-INF/maven/com.tiffinbox/tiffinbox/pom.properties
```

### Notes

- `export JAVA_HOME=/opt/homebrew/opt/openjdk@25` (macOS Homebrew) before `mvn`, or Maven may pick a different JDK.
- Break it on purpose: delete the whole `maven-jar-plugin` block from `pom.xml`, run `mvn -q package`, then `java -jar target/tiffinbox-1.0.jar` → `no main manifest attribute, in target/tiffinbox-1.0.jar`. Put the block back and the jar runs again.
- `mvn clean` deletes `target/`; `mvn -q package` brings it back. `target/` is git-ignored — never commit it.

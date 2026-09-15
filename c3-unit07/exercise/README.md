# Unit 07 exercise — the block Maven gave you for free

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRADLE_USER_HOME="$PWD/.gradle-home"
../gradlew jar
```

It fails:

```
* What went wrong:
Execution failed for task ':compileJava' (registered by plugin class 'org.gradle.api.plugins.JavaBasePlugin').
> Could not resolve all files for configuration ':compileClasspath'.
   > Cannot resolve external dependency com.h2database:h2:2.5.250 because no repositories are defined.
     Required by:
         root project 'tiffinbox-core'
```

**Task.** Add the one block that fixes it.

**End state.** `../gradlew jar` prints `BUILD SUCCESSFUL` and `build/libs/tiffinbox-core-1.0.0.jar` exists.

The answer is in [`solution/build.gradle.kts`](solution/build.gradle.kts). The reason it is missing
is worth a minute: the effective POM you read at the start of this course had a whole
`<repositories>` block in it that nobody typed — it came from Maven's own Super POM. Gradle has
no Super POM, so nothing arrives that you did not write.

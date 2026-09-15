# Unit 09 exercise — declare what you use

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRADLE_USER_HOME="$PWD/.gradle-home"
../gradlew :tiffinbox-web:compileJava
```

```
> Task :tiffinbox-web:compileJava FAILED
  tiffinbox-web/src/main/java/com/tiffinbox/web/HealthCheck.java:4: error: package org.h2.jdbcx does not exist
  3 errors
```

**Task.** Make it compile **without touching `tiffinbox-core/build.gradle.kts`.**

**End state.**

```
> Task :tiffinbox-web:compileJava
BUILD SUCCESSFUL
```

…and `grep -c 'api(' tiffinbox-core/build.gradle.kts` still prints `0`.

There are two ways to make this build green and only one of them is right. The answer, with the
argument for it, is in [`solution/tiffinbox-web.build.gradle.kts`](solution/tiffinbox-web.build.gradle.kts):

```bash
cp solution/tiffinbox-web.build.gradle.kts tiffinbox-web/build.gradle.kts
```

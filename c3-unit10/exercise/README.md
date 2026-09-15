# Unit 10 exercise — pin the distribution, then prove the pin bites

This project has a committed wrapper: `gradlew`, `gradlew.bat`, `gradle/wrapper/gradle-wrapper.jar`
and `gradle/wrapper/gradle-wrapper.properties`. One line is missing from the properties file.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cat gradle/wrapper/gradle-wrapper.properties
```

**Task.** Add `distributionSha256Sum` with the published checksum for Gradle 9.7.1, then change
one character of it and show that the wrapper refuses to run.

**End state.** With the wrong checksum and a Gradle home that has never held this distribution:

```bash
rm -rf .gh-fresh
GRADLE_USER_HOME="$PWD/.gh-fresh" ./gradlew --version
```

```
Exception in thread "main" java.lang.RuntimeException: Verification of Gradle distribution failed!
...
Expected checksum: '<the one you typed>'
Actual checksum:   'acd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a'
```

Put the real checksum back and the same command prints `Gradle 9.7.1`.

The finished file is [`solution/gradle-wrapper.properties`](solution/gradle-wrapper.properties):

```bash
cp solution/gradle-wrapper.properties gradle/wrapper/gradle-wrapper.properties
```

**The `GRADLE_USER_HOME="$PWD/.gh-fresh"` is not decoration.** The checksum is verified when the
distribution is **downloaded**, not on every run. If your Gradle home already holds an unpacked
9.7.1, a wrong pin changes nothing until the next machine — which is exactly the machine the pin
is there for. That is worth knowing before you trust it.

The two published checksums for a Gradle release are **not** interchangeable: the distribution's
is `acd53f1e…`, the wrapper jar's is `7a9ce74c…`. Pasting the second into `distributionSha256Sum`
is the mistake this exercise is shaped around. `curl -s https://services.gradle.org/versions/current`
prints both, named `checksum` and `wrapperChecksum`.

Delete `.gh-fresh` when you are done — it holds a full Gradle distribution.

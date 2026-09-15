# Unit 08 exercise — a task that can never be skipped

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRADLE_USER_HOME="$PWD/.gradle-home"
../gradlew stamp
../gradlew stamp
```

Both runs say the same thing:

```
> Task :stamp
1 actionable task: 1 executed
```

Ask Gradle why:

```bash
../gradlew stamp --info | grep -A1 "not up-to-date"
```

```
Task ':stamp' is not up-to-date because:
  Task has not declared any outputs despite executing actions.
```

**Task.** Add the one line that lets Gradle skip it.

**End state.** The second `../gradlew stamp` prints:

```
> Task :stamp UP-TO-DATE
1 actionable task: 1 up-to-date
```

The answer is in [`solution/build.gradle.kts`](solution/build.gradle.kts). Note which half of the
pair this exercise is: the video broke a task by hiding an **input**; this one breaks it by
hiding an **output**. Both ends of the pair have to be declared before the question
*"is there anything left to do?"* has an answer at all.

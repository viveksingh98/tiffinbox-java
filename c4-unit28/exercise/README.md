# Exercise — the lunch reminder that fires on Sunday

The kitchen should send its lunch reminder at **11:15 on weekdays only**. The expression in use is
`0 15 11 * * *`, and customers are getting reminders on Sunday.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.CronNext "0 15 11 * * *"
```

Fix the expression and **prove it by computing, not by waiting**: the next four firings must all be weekdays
at 11:15. Then say in one line why this course never waits for a cron job to fire.

Solution in `solution/`.

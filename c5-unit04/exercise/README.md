# Exercise — take one out, two ways

Boot registered 9 of the 12 classes its file lists for TiffinBox. Take one out **without touching any code**: Boot reads
the property `spring.autoconfigure.exclude`. Exclude task scheduling twice — first by its short name, then by the full
name the file itself uses — and count after each. Run `../receipts.sh` once first, so `after/` is built and `.harness/`
is compiled. Then, from this folder:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
cd ..
CP="after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls after/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"
java -Dspring.autoconfigure.exclude=TaskSchedulingAutoConfiguration \
     -cp ".harness:$CP" com.tiffinbox.harness.AutoConfig count 18547 2>&1 | grep -E 'definitions in all|WARN|ERROR'
java -Dspring.autoconfigure.exclude=org.springframework.boot.autoconfigure.task.TaskSchedulingAutoConfiguration \
     -cp ".harness:$CP" com.tiffinbox.harness.AutoConfig count 18547 2>&1 | grep -E 'definitions in all|WARN|ERROR'
```

The `grep` keeps the harness's count line and any warning or error Boot prints. Done means: you can say which of the two
runs prints `listed auto-configuration classes registered 8`, why the other still says 9 **and printed no warning**, and
why the definitions dropped by more than one. Solution, measured, in `solution/`.

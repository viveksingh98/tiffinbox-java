# Exercise — take one out

Boot registered 9 of the 12 classes its file lists for TiffinBox. Take one out **without touching any code**: Boot reads
`spring.autoconfigure.exclude`. Exclude `org.springframework.boot.autoconfigure.task.TaskSchedulingAutoConfiguration` and
count again with this unit's harness (run `../receipts.sh` once first, so `after/` is built and `.harness/` compiled):

```
cd ..
CP="after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls after/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"
java -Dspring.autoconfigure.exclude=org.springframework.boot.autoconfigure.task.TaskSchedulingAutoConfiguration \
     -cp ".harness:$CP" com.tiffinbox.harness.AutoConfig count 18547
```

Done means: you can say how many listed classes are registered now, how many definitions went with the one you removed,
and why the number of definitions dropped by more than one. Solution in `solution/`.

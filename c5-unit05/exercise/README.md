# Exercise — flip one condition

`SpringApplicationAdminJmxAutoConfiguration` is listed for TiffinBox and not used. Find out why **from the report**, then
turn it on with one property and prove it.

1. Run TiffinBox with `--debug` (see `../receipts.sh` for the class path) and find that class in the report's
   negative matches. The line under it names the condition, and the property that would satisfy it.
2. Run `../../c5-unit04`'s counter with that property set, and count again:
   ```
   cd ../../c5-unit04 && CP="after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar:$(ls after/tiffinbox-web/target/lib/*.jar | tr '\n' ':')"
   java -D<the property>=true -cp ".harness:$CP" com.tiffinbox.harness.AutoConfig count 18548
   ```

Done means: the class reads `registered`, and you can say how many listed classes are registered now. Solution in `solution/`.

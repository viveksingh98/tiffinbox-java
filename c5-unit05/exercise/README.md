# Exercise — make @Async take your executor

The video ends its executor story on **B**: one `Executor` bean of yours (`demo/KitchenExecutorConfig.java`, a pool of
three threads named `kitchen-1` to `kitchen-3`). Boot's pool backs off because of it — and twenty `@Async` calls still
run on twenty brand-new threads. Spring's own INFO line, in the full output, says what `@Async` looks for.

**Your turn:** change **only** `exercise/demo/KitchenExecutorConfig.java` until the harness prints

    @Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 3 threads, named kitchen-#

Run these from the unit's folder (the one that holds `receipts.sh`). `./receipts.sh` builds TiffinBox and the harness into
`.harness/`; if it stops on a `DIFFERS` line, the build it made is still there and the exercise still runs.

    export JAVA_HOME=/opt/homebrew/opt/openjdk@25
    export PATH="$JAVA_HOME/bin:$PATH"
    ./receipts.sh
    CP=".harness/classes:$(cat .harness/classpath)"
    rm -rf .harness/exercise
    javac -cp "$CP" -d .harness/exercise exercise/demo/KitchenExecutorConfig.java
    java -cp ".harness/exercise:$CP" com.tiffinbox.harness.Conditions 18559 kitchen 2>&1 | grep -E '^(Executor beans|@Async bean)'

As shipped, the last command prints (measured 2026-09-29, JDK 25.0.4.1, Spring Boot 4.1.1):

    Executor beans: kitchenExecutor (a ThreadPoolExecutor, core pool size 3)
    @Async bean: CGLIB subclass of AsyncKitchen · 20 calls ran on 20 threads, named SimpleAsyncTaskExecutor-#

`.harness/exercise` comes first on the class path, so your compiled `demo.KitchenExecutorConfig` replaces the harness's
own. Three answers, each run with exactly these commands, are in `solution/`.

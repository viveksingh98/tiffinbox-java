# Exercise — the starter's kitchen, your way, without Java

As shipped, lunch-counter prints the starter's kitchen with the starter's own defaults:

    Kitchen beans: [kitchen] -> TiffinBox kitchen with 3 cooks

**Your turn:** give that kitchen your own name and five cooks — **touching no Java in lunch-counter**, and none in the
starter either. Done means the kitchen line shows both:

    Kitchen beans: [kitchen] -> <your name> with 5 cooks

The keys are written down inside the starter's jar, in the metadata file its build generated
(`../.r-starter.out` prints both, with their types and defaults).

Run these from this folder (`exercise/`), in order. `../receipts.sh` builds the starter, installs it into this unit's
own repository (`../.m2-demo`) and fills that repository; the build below then runs offline (`-o`).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
../receipts.sh
rm -rf my-lunch-counter && rsync -a --exclude target ../lunch-counter/ my-lunch-counter/
```

Now make your change inside `my-lunch-counter/` — no `.java` file. Then build it and run it:

```bash
(cd my-lunch-counter && mvn -o -q -DskipTests clean package -Dmaven.repo.local="$PWD/../../.m2-demo")
java -jar my-lunch-counter/target/lunch-counter-1.0.0.jar | grep '^Kitchen beans'
```

As shipped (no change made), the last command prints the first line above. When you are done: `rm -rf my-lunch-counter`
(it is git-ignored meanwhile). Three answers, each run with exactly these commands, are in `solution/SOLUTION.md`.

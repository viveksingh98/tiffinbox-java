# Exercise — give the kitchen a real backend

## The start state

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" -q compile exec:exec
```

```
SLF4J(W): No SLF4J providers were found.
SLF4J(W): Defaulting to no-operation (NOP) logger implementation
SLF4J(W): See https://www.slf4j.org/codes.html#noProviders for further details.
```

**Three lines on stderr, not one kitchen line, and the process exits 0.** `KitchenLog.java`
made four logging calls and every one of them went nowhere. Nothing failed. That is the
part worth sitting with: a program with no logging backend is not a program that crashes,
it is a program that has stopped telling you anything.

## Your task

Two edits, neither of them in a `.java` file.

1. **Add the binding** to `pom.xml` — `ch.qos.logback:logback-classic:1.6.3`. Do **not**
   also declare `slf4j-api`: logback-classic brings it. Re-run the command above and the
   three warnings should be gone, replaced by two `INFO` lines.
2. **Add `src/main/resources/logback.xml`** with a console appender and a root level of
   `DEBUG`, so the per-customer line appears as well.

## The end state you are reaching

```
<time> DEBUG tiffinbox - placing 30 order(s) for Arun
<time> DEBUG tiffinbox - placing 30 order(s) for Bela
<time> DEBUG tiffinbox - placing 30 order(s) for Chandran
<time> INFO  tiffinbox - orders cooked:  90
<time> INFO  tiffinbox - kitchen value:  26700
```

Five lines, exit 0, and **`src/main/java` untouched** — `git diff` on it must be empty.
That is the whole claim of this unit, done with your own hands: the code did not change,
the jar behind it did.

`<time>` stands for a wall-clock stamp that moves every run. `./receipts.sh solution`
masks it with a named filter before it hashes anything, and so should you before you
compare your output to the block above.

## The answer

`solution/pom.xml` and `solution/logback.xml`. `../receipts.sh solution` copies both into
place in a throwaway copy of this directory, runs it, and prints what it measured.

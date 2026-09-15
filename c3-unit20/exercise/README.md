# Exercise — make it roll, then count what you lost

## The start state

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -B -Dmaven.repo.local="../.m2-demo" -q compile exec:exec
ls -1 target/logs && cat target/logs/* | wc -l
```

```
kitchen.log
     201
```

`src/main/resources/logback.xml` sets `<maxFileSize>1KB</maxFileSize>`. Two hundred and one
lines went into that file and it is now roughly sixteen kilobytes. **One file. No error.
Exit 0.** The build was green and the configuration is the one every tutorial shows.

## Your task

One element, in `logback.xml`, inside the `<triggeringPolicy>`. Then re-run and answer the
second question, which is the one that matters:

> Of the 201 lines the program wrote, **how many are still on disk?**

`SizeBasedTriggeringPolicy` does not look at the file on every event. It asks an
invocation gate first, and the gate's default increment is not zero. `../receipts.sh gate`
reads that default straight out of `logback-core-1.6.3.jar` if you want it before you
guess.

## The end state you are reaching

```
kitchen.1.log
kitchen.2.log
kitchen.3.log
kitchen.log
      45
```

**Four files, forty-five lines.** `head -1 target/logs/kitchen.3.log` names the oldest line
the window still holds: `slip 0156`. One hundred and fifty-six lines were rolled off the
end and deleted — by the configuration, on purpose, without a word on the console.

That is the trade a rolling appender makes, and it is the half nobody mentions: a bounded
log is a log that throws things away. `maxIndex` is where you decide how much.

## The answer

`solution/logback.xml`. `../receipts.sh solution` copies it into a throwaway copy of this
directory, runs both states and prints the two file counts and the two line counts with
the discarded total between them.

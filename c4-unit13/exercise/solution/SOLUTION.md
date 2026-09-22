# Solution

Add the key to a source that **outranks every `@PropertySource`** — the JVM's own system properties,
which this unit measured sitting at position 1:

```
java -Dtiffinbox.cooks=4 -cp "target/classes:$(cat cp.txt)" com.tiffinbox.Sources --key=tiffinbox.cooks
```

`--key=` points the report at the key the exercise contests; the `-D` flag is what puts it in a source
that outranks both files. The row to look at is:

```
  1. systemProperties               tiffinbox.cooks=4
```

**Why this and not the other repairs.** Reordering the two annotations fixes `cooks` and silently
flips `rail` as well, because both keys live in both files — one edit, two consequences, and the
second one is invisible until something else breaks. Deleting the line from `rails-two.properties`
is the right fix *for a file you own*, and the exercise forbids it precisely because the interesting
case is the file you do not own: a config file shipped by another team, a container image, a
Kubernetes ConfigMap. **A source that outranks the problem is the only fix that does not require
editing somebody else's file.**

**What it costs, and say it out loud.** The value now lives on a command line rather than in a file
under version control. That is a real trade: nothing reviews it, nothing diffs it, and the next person
to start the application without that flag gets one cook. The unit's honest position is that
precedence is a tool for *overriding*, not for *configuring* — and if you find yourself overriding the
same key every run, the fix is to change the file after all.

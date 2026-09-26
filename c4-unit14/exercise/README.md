# Exercise — the kitchen cannot read the spice level

`order.properties` says `tiffinbox.spice=extra-hot`. `Order` wants a `Spice`. Run it:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
java -cp "target/classes:$(cat cp.txt)" com.tiffinbox.TiffinBoxConfig
```

**Three things to get right, and the unit gave you all three.**

1. **Write the converter.** `extra-hot` is not `EXTRA_HOT` yet.
2. **Make a bad value readable.** Change the file to `tiffinbox.spice=nuclear` and run again. The
   default `Enum.valueOf` message names the constant it could not find and nothing else — not the
   key it came from, not what you typed, not what was allowed. Yours should name what was typed and what
   is allowed — a converter is never told which key the value came from.
3. **Register it so the container actually uses it.** This is the step that looks done when it is
   not: a converter can be a perfectly good bean in the context and never be consulted. If you get
   `no matching editors or conversion strategy found` while staring at a converter you know is
   correct, you have hit exactly what §2 of the unit measured — and the error will not tell you.

Solution in `solution/`. Write yours first; the wrong version is more instructive than the right one.

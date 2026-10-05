# Exercise — the switch, flipped your own way

**Your turn:** switch virtual threads on with an environment variable, count the threads twenty tasks used, then name
TiffinBox's server executor.

The video flipped the switch with a command-line flag, `--spring.threads.virtual.enabled=true`. Section 2 showed another
way to hand Boot a property, from the shell. Use that one here: no flag.

Run everything from `c5-unit18/`. The commands below build a copy of TiffinBox — the anchor as the Compose lesson left it,
the tree this video ran — under `.harness/mine` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), unpack its jar
the way its README says, compile this unit's harness against it, give the copy a token of its own, and run the harness once
with the switch not set. Builds use this unit's own repository, `.m2-demo`, offline. The last command moves this shell into
`.harness/mine/after`, and leaves it there.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target ../c5-unit17/after/ .harness/mine/after/
mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
(cd .harness/mine/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted)
javac -cp ".harness/mine/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/mine/after/tiffinbox-web/target/extracted/lib/*" -d .harness/mine/classes harness/threads/VThreads.java
mkdir -p .harness/mine/after/secrets/tiffinbox && (umask 077 && printf '%s\n' "$(openssl rand -hex 16)" > .harness/mine/after/secrets/tiffinbox/shutdown-token)
cd .harness/mine/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" threads.VThreads --tiffinbox.port=18899
```

The harness (`harness/threads/VThreads.java`) starts TiffinBox on port 18899, prints its findings to standard error, stops
it and exits. Boot's own log goes to standard output; add `> /dev/null` to the last command to hide it. With the switch
not set, three of its lines read:

```
the switch, as the environment holds it: spring.threads.virtual.enabled = (not set)
20 tasks -> distinct threads 8 · virtual [false]
  TiffinBox's HttpServer executor: java.util.concurrent.ThreadPerTaskExecutor
```

Now, from that folder — `.harness/mine/after`, where the last command left you — run its `java` command again (without the
`cd .harness/mine/after && ` in front: you are already there), with the switch on and **no command-line flag**. Hint: the
property-sources lesson set `tiffinbox.cooks` from the shell, written in front of the command as `TIFFINBOX_COOKS=5` — the
key in upper case, its dots turned into underscores.

**Done** when the harness prints

```
the switch, as the environment holds it: spring.threads.virtual.enabled = true · from systemEnvironment
20 tasks -> distinct threads 20 · virtual [true]
  TiffinBox's HttpServer executor: java.util.concurrent.ThreadPerTaskExecutor
```

— twenty tasks on twenty threads, all virtual, and TiffinBox's own server executor exactly as it was. The same lines are in
this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

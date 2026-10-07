# Exercise — tiffinbox-core as a folder, and what restarts

**Your turn:** put tiffinbox-core's classes folder on the class path instead of its jar, change OrderQueue, and watch what restarts.

The video changed a class of TiffinBox's web module and watched DevTools restart it, then rebuilt tiffinbox-core while TiffinBox ran
and watched nothing happen: Maven lists tiffinbox-core as a jar, and DevTools restarts only what sits in folders. Now hand DevTools
tiffinbox-core as a folder: which class loader defines OrderQueue then, and what does a change to OrderQueue's class file do?

Run everything from `c5-unit25/`. The commands below copy TiffinBox — `anchor/`, this folder's link to the anchor as the Actuator lesson left
it — to `.harness/mine` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), add DevTools to its web module's POM as an
optional dependency (the one line of the video), build it the way the anchor's README builds the class path Maven lists — offline,
against this unit's own repository `.m2-demo` — compile the course's harness `harness/probe/Loaders.java` into `.harness/mine-hc`
(it prints, at every start, which loader defined TiffinBoxServer and OrderQueue), and give the copy a config tree with a token of
its own: 26 random lowercase letters and digits in `.harness/mine/secrets/tiffinbox/shutdown-token` (readable by you alone), never
printed. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first. No GraalVM is needed for that: without `GRAALVM_HOME`
it fills `.m2-demo` from Maven Central, makes every capture that needs no GraalVM — this exercise's among them — and stops before the
native build.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine .harness/mine-hc .harness/mine.log && mkdir -p .harness/mine-hc && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/
perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>\n  </dependencies>|' .harness/mine/tiffinbox-web/pom.xml
mvn -o -B -q -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
javac -d .harness/mine-hc -cp ".harness/mine/tiffinbox-web/target/classes:$(cat .harness/mine/tiffinbox-web/target/classpath.txt)" harness/probe/Loaders.java
mkdir -p .harness/mine/secrets/tiffinbox && chmod 700 .harness/mine/secrets .harness/mine/secrets/tiffinbox && (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/secrets/tiffinbox/shutdown-token)
```

Then, in `.harness/mine/tiffinbox-web/target/classpath.txt` (one line, entries separated by `:`), find the entry that ends
`tiffinbox-core/target/tiffinbox-core-1.0.0.jar` and write a copy of the class path with `tiffinbox-core/target/classes` in its
place. Start TiffinBox from `.harness/mine`, the folder that holds the config tree, the way the video ran the copy — `java -cp`
with `tiffinbox-web/target/classes` in front of that class path, `com.tiffinbox.web.TiffinBoxServer`, port `19045` — with
`.harness/mine-hc` in front of everything and `--spring.main.sources=probe.Loaders` at the end, its output in a file. Once it prints
its first `LOADERS` line, change OrderQueue: `touch` its class file under `tiffinbox-core/target/classes` (or edit `OrderQueue.java`
and recompile the module against `.m2-demo` — the compiler writes all its classes again: `solution/SOLUTION.md` measured that once). Watch the log for
DevTools' line and the second `LOADERS` line. Stop TiffinBox with POST /shutdown and its token — `harness/shutdown.sh 19045
.harness/mine/secrets/tiffinbox/shutdown-token` hands it to curl from the file — and expect exit code 1: DevTools' runs end that way
(the `exits` capture).

**Done** when you can print

```
Restarting due to 1 class path change (0 additions, 0 deletions, 1 modification)
LOADERS start 2 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader RestartClassLoader
```

— tiffinbox-core, as a folder, is DevTools' to restart: OrderQueue is defined by the restart loader, and a change to it restarts
TiffinBox. The same lines are in this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written:
`solution/SOLUTION.md`.

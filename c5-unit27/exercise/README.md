# Exercise — a banner that prints TiffinBox's version

**Your turn:** add a banner that prints TiffinBox's version, then start the jar and the folder run. Which one knows it?

The video printed a banner from a file named on the command line. Boot also reads a file called `banner.txt` at the root of the
class path by itself — in a Maven project, `src/main/resources/banner.txt` — and fills in its placeholders while it prints it:
`${application.version}` is the version of the application, read from where Boot finds it.

Run everything from `c5-unit27/`. The commands below copy TiffinBox — `after/`, the anchor as this lesson leaves it — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs) and give it a config tree with a token of its
own — 26 random lowercase letters and digits, in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable by you alone,
never printed. On a fresh clone this unit's own repository, `.m2-demo`, is empty: run `./receipts.sh` once first. No GraalVM is
needed for that: without `GRAALVM_HOME` it fills `.m2-demo` from Maven Central, makes every capture that needs no GraalVM — this
exercise's among them — and stops before the native build.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
```

Then write `.harness/mine/after/tiffinbox-web/src/main/resources/banner.txt`: one line, `TiffinBox version=[` and the
placeholder for the application's version and `]`. Build the copy offline against `.m2-demo` with the anchor README's class-path
line (`mvn -B package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt`, plus `-o`,
`-Dmaven.repo.local=` this unit's `.m2-demo` and `-DskipTests`). From `.harness/mine/after` — the folder that holds the config
tree — start it twice on port `19069`, one after the other: the jar (`java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar
--tiffinbox.port=19069`, its output in `jar.log`), then the folder run (the anchor README's `java -cp
"tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer` line, its output
in `folders.log`). Each time, wait until `http://127.0.0.1:19069/actuator/health/readiness` answers 200, then stop it with
`harness/shutdown.sh 19069 secrets/tiffinbox/shutdown-token` (POST /shutdown, the token read from the file) and wait for it to
exit. Print the banner line of each log.

**Done** when you can print

```
the jar: TiffinBox version=[1.0.0] · the folders: TiffinBox version=[]
```

— the jar knows its version, and the folders do not: Boot reads `${application.version}` from the jar's manifest
(`Implementation-Version`, written by the build), and a run from `target/classes` has no manifest to read. A banner that types
the version by hand prints it in both, and so does not pass. The same line is in this unit's `exercise` capture
(`.r-exercise.out`). The measured answer, run exactly as written: `solution/SOLUTION.md`.

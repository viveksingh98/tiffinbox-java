# Exercise — TiffinBox's own request log at DEBUG, Spring's lines left at INFO

**Your turn:** switch only TiffinBox's own request log to debug while it runs, and leave Spring's com.tiffinbox loggers at info.

The video switched the group `kitchen` to DEBUG while TiffinBox ran: both its members, `tiffinbox` and `com.tiffinbox`, went to
DEBUG. Here you want one of them: TiffinBox's own logger — the one that writes a line per answer — at DEBUG, and the loggers under
`com.tiffinbox` (Spring's lines about TiffinBox) left at INFO. One POST to the right name, while it runs; no restart.

Run everything from `c5-unit24/`. The commands below copy TiffinBox — `after/`, the anchor as this lesson leaves it — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), build it the plain way, offline against this
unit's own repository `.m2-demo`, and give it a config tree with a token of its own: 26 random lowercase letters and digits, in
`.harness/mine/after/secrets/tiffinbox/shutdown-token` (readable by you alone), never printed. On a fresh clone `.m2-demo` is
empty: run `./receipts.sh` once first. No GraalVM is needed for that: without `GRAALVM_HOME` it fills `.m2-demo` from Maven
Central, makes every capture that needs no GraalVM — this exercise's among them — and stops before the native build.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
```

Then start TiffinBox from `.harness/mine/after`, the folder that holds the config tree, with the anchor README's line that exposes
the loggers endpoint for one run, on port `19039`, its log in `.harness/mine/run.log`; wait until
`http://127.0.0.1:19039/actuator/health/readiness` answers 200; set one logger's level with a POST to
`http://127.0.0.1:19039/actuator/loggers/<name>` (`Content-Type: application/json`, the body `{"configuredLevel":"DEBUG"}`);
send one request to `/customers`; ask `/actuator/loggers/tiffinbox` and `/actuator/loggers/com.tiffinbox` for their
`effectiveLevel`; stop TiffinBox with POST /shutdown and its token — `harness/shutdown.sh 19039
.harness/mine/after/secrets/tiffinbox/shutdown-token` hands it to curl from the file — and, once it has exited, count the log's
DEBUG lines for that request (`GET /customers -> 200`).

**Done** when you can print

```
loggers/tiffinbox DEBUG · loggers/com.tiffinbox INFO · request DEBUG lines 1
```

— TiffinBox's logger is named `tiffinbox`, not after its package (Course 2's `System.getLogger("tiffinbox")`), so the level goes
on that name: the group would have taken `com.tiffinbox` along, and `com.tiffinbox` alone would have printed no request line. The
same line is in this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written:
`solution/SOLUTION.md`.

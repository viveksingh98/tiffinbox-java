# Exercise — Boot's properties migrator

**Your turn:** put Boot's properties migrator on TiffinBox's class path, start it with management dot endpoints dot
enabled-by-default, and read the report.

The video ran the migrator on TiffinBox's own keys, and it reported nothing. It exists for the day you move an application from
Boot 3: on the class path, it reads the environment once the start begins and reports at ERROR every key Boot 4 no longer
supports. `management.endpoints.enabled-by-default` is the old switch for every Actuator endpoint, deprecated since Boot 3.4.0
(the lesson's `notnew` capture) — give it `=true`, so health keeps answering.

Run everything from `c5-unit28/`. The commands below copy TiffinBox — `after/`, the anchor as the command-line lesson left it,
unchanged here — to `.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs) and give it a config tree
with a token of its own — 26 random lowercase letters and digits, in `.harness/mine/after/secrets/tiffinbox/shutdown-token`,
readable by you alone, never printed. On a fresh clone this unit's own repository, `.m2-demo`, is empty: run `./receipts.sh`
once first. That fills it — the migrator's two jars included — from Maven Central.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
```

Then build the copy offline against `.m2-demo` with the anchor README's plain line (`mvn -B package`, plus `-o`,
`-Dmaven.repo.local=` this unit's `.m2-demo` and `-DskipTests`), and extract the jar with the README's extract line. The
migrator is `org.springframework.boot:spring-boot-properties-migrator:4.1.1`; it needs
`org.springframework.boot:spring-boot-configuration-metadata:4.1.1` beside it (without it the start fails — the lesson's
`migrator` capture, C). Both jars are in `.m2-demo` under `org/springframework/boot/`. From `.harness/mine/after` — the folder
that holds the config tree — start the README's exploded line (`java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer`)
with the two jars added to the class path, `--tiffinbox.port=19145` and the old key, its output in `run.log`. Wait until
`http://127.0.0.1:19145/actuator/health/readiness` answers 200, stop it with `harness/shutdown.sh 19145
secrets/tiffinbox/shutdown-token` (POST /shutdown, the token read from the file) and wait for it to exit. Print the report's
`Key:` line.

**Done** when you can print

```
Key: management.endpoints.enabled-by-default
```

— the migrator names the key, and its reason: the replacement, `management.endpoints.access.default`, takes another type (an
access level, not a yes or no). Without the old key it prints nothing at all. The same report is in this unit's `migrator`
capture (B), and this line in its `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written:
`solution/SOLUTION.md`.

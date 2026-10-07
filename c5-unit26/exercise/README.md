# Exercise — the cycle Boot drew, broken without the switch

**Your turn:** break the cycle Boot drew without the switch: give Cook and Rail the third object both of them wanted.

The video joined the harness's two classes, `Cook` and `Rail` (`harness/probe/cycle/`), to TiffinBox: each one needs the other,
through a setter. Plain Spring started them; Boot refused — exit 1, the cycle drawn, and an Action that names
`spring.main.allow-circular-references` as a last resort. The switch starts them and leaves the cycle where it was. Course 4
cured the same shape without any switch: what both sides wanted from each other was a third object, needed by both and needing
neither. Here the cook asks the rail how many slips it holds, and the rail asks the cook how many hands take them off: both
are the shift's numbers.

Run everything from `c5-unit26/`. The commands below copy TiffinBox — `after/`, the anchor as this lesson leaves it — to
`.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs), build it the plain way, offline against this
unit's own repository `.m2-demo`, extract it (the anchor README's extract line), give it a config tree with a token of its own
— 26 random lowercase letters and digits, in `.harness/mine/after/secrets/tiffinbox/shutdown-token`, readable by you alone,
never printed — and copy the harness's `Cook.java` and `Rail.java` to `.harness/mine/probe/cycle/`, where you change them, with
`Tally.java` beside them: the harness's report, never yours to change. On a
fresh clone `.m2-demo` is empty: run `./receipts.sh` once first. No GraalVM is needed for that: without `GRAALVM_HOME` it fills
`.m2-demo` from Maven Central, makes every capture that needs no GraalVM — this exercise's among them — and stops before the
native build.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine/probe/cycle && rsync -a --exclude target after/ .harness/mine/after/ && cp harness/probe/cycle/Cook.java harness/probe/cycle/Rail.java harness/probe/cycle/Tally.java .harness/mine/probe/cycle/
mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
(cd .harness/mine/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
(umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
```

Then change `.harness/mine/probe/cycle/Cook.java` and `Rail.java` — keep their `slipsWaiting()` and `hands()`, which `Tally`
calls — and write `Shift.java` beside them — neither `Cook` nor
`Rail` may know the other, and no switch. Compile the four into `.harness/mine/hc`, against the extracted class path:

    javac -d .harness/mine/hc -cp ".harness/mine/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/mine/after/tiffinbox-web/target/extracted/lib/*" .harness/mine/probe/cycle/*.java

Start TiffinBox from `.harness/mine/after` — the folder that holds the config tree — with the anchor README's exploded line,
`../hc` added to its class path, port `19059`, the four classes joined by
`--spring.main.sources=probe.cycle.Cook,probe.cycle.Rail,probe.cycle.Shift,probe.cycle.Tally`, its log in `.harness/mine/run.log`;
`Tally` prints one line when TiffinBox is ready, starting `harness: ` — what the cook and the rail each depend on (the beans
Spring injected into them, by name) and the number each one counts; wait until
`http://127.0.0.1:19059/actuator/health/readiness` answers 200; send the comparison set with
`harness/seven.sh 19059 .harness/mine/after/secrets/tiffinbox/shutdown-token` — it runs the secrets lesson's seven requests, reads
the token from the file, stops TiffinBox with POST /shutdown, and prints the md5 of the seven lines; once TiffinBox has exited,
count `APPLICATION FAILED TO START` in its log, and print `Tally`'s line without its `harness: `.

**Done** when you can print

```
Cook and Rail started · cook depends on [shift] and counts 12 slips · rail depends on [shift] and counts 3 hands · the seven 115c36bac276128e245ca57df11c2891 · APPLICATION FAILED TO START 0
```

— Boot started both classes with its default, `spring.main.allow-circular-references=false`; each got the third object and
nothing else (`[shift]`), and asked it for the same two numbers the cycle gave; and TiffinBox's seven answers did not change.
`Tally`'s half of the line is what tells a cure from a shortcut: `solution/SOLUTION.md` shows what deleting the setters, or the
switch, prints instead. The same line is in this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written:
`solution/SOLUTION.md`.

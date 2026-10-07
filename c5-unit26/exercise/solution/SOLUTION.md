# Solution — the third object

`solution/probe/cycle/` holds the answer: `Shift.java`, the shift's two numbers — how many slips the rail holds, how many hands
take them off — and `Cook.java` and `Rail.java`, each taking a `Shift` through its constructor and asking it, never each
other. Neither class knows the other any more, so there is no cycle to allow, and Boot's default stands.

In the same shell, after `exercise/README.md`'s commands, from `c5-unit26/` — one line. It copies the three files over yours in
`.harness/mine/probe/cycle/`, compiles them into `.harness/mine/hc`; starts TiffinBox in the background from
`.harness/mine/after` with the anchor README's exploded line, `../hc` on its class path, the four classes joined (`Tally`, the
harness's report, among them), port 19059
(its log in `.harness/mine/run.log`); waits for readiness to answer 200 (every 0.25 s, up to 60 s: "started", or "never ready");
sends the comparison set,
which stops TiffinBox with POST /shutdown and the token read from the file (`harness/seven.sh`, which prints the md5 of the seven
lines); waits for it to exit; and prints what it found:

```bash
cp exercise/solution/probe/cycle/*.java .harness/mine/probe/cycle/ && javac -d .harness/mine/hc -cp ".harness/mine/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/mine/after/tiffinbox-web/target/extracted/lib/*" .harness/mine/probe/cycle/*.java && { (cd .harness/mine/after && exec java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19059 --spring.main.sources=probe.cycle.Cook,probe.cycle.Rail,probe.cycle.Shift,probe.cycle.Tally > ../run.log 2>&1) & } && for i in $(seq 240); do r=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19059/actuator/health/readiness); [ "$r" = 200 ] && break; sleep 0.25; done; [ "$r" = 200 ] && w=started || w="never ready"; s=$(harness/seven.sh 19059 .harness/mine/after/secrets/tiffinbox/shutdown-token); wait; echo "Cook and Rail $w · $(sed -n 's/^harness: //p' .harness/mine/run.log) · the seven $s · APPLICATION FAILED TO START $(grep -c 'APPLICATION FAILED TO START' .harness/mine/run.log)"
```

(`harness/seven.sh` runs the comparison set — the secrets lesson's own `curlset.sh`, read from where it lives — and prints the md5
of its seven lines. The token never reaches a command line: the comparison set reads it from the file and hands it to curl on its
standard input.
The `exec` makes the background job TiffinBox's own process, so `wait` returns when it exits — and only then is the log
counted.)

## Measured — `exercise/README.md` run exactly as written, then the line above (2026-10-08)

In one clean shell — `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash --noprofile --norc`: no
variable of mine, Homebrew's `bin` for `mvn` — from `c5-unit26/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo`, no GraalVM.
The README's seven lines ran as written, one after another in that shell, every one exit 0, none printing a line. The token file:
27 bytes (26 characters and a newline), `-rw-------`. Then `solution/probe/cycle/`'s three files and the line above, exit 0,
printed:

```
Cook and Rail started · cook depends on [shift] and counts 12 slips · rail depends on [shift] and counts 3 hands · the seven 115c36bac276128e245ca57df11c2891 · APPLICATION FAILED TO START 0
```

The third object. `Cook` and `Rail` each take a `Shift` and ask it, so neither needs the other: Boot builds `shift`, then `cook` and
`rail`, with its default `spring.main.allow-circular-references=false` and no switch on the command line. `Tally` reads the bean
factory: each of the two depends on `shift` alone, and each counts what the cycle counted — 12 slips, 3 hands. TiffinBox's seven
answers are the comparison set's, byte for byte, and its log holds no `APPLICATION FAILED TO START`. The same line is in this
unit's `exercise` capture. Port 19059 was free afterwards.

**What the shortcuts print** (the same run line and `Tally`, from the same `.harness/mine/after`, 2026-10-08): the harness's
`Cook` and `Rail` with their two `@Autowired` deleted — no cycle, nothing injected — `cook depends on [] and counts none
(NullPointerException) slips · rail depends on [] and counts 0 hands`; the harness's classes unchanged, with
`--spring.main.allow-circular-references=true` — `cook depends on [rail] and counts 12 slips · rail depends on [cook] and counts 3
hands`. Both started, both kept the seven `115c36ba…` and 0 `APPLICATION FAILED TO START`: only `Tally`'s half of the line tells
them from the cure. (Run in a shell where the README's two `export` lines did not run, the solution starts the shell's default
`java` — 23.0.1 on this Mac — which refuses TiffinBox's classes (`UnsupportedClassVersionError`, class file version 69.0):
readiness never answers, and the line says `Cook and Rail never ready` with another md5 — measured 2026-10-07.)

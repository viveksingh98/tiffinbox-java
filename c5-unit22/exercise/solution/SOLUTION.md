# Solution — the kitchen in liveness, the database closed, liveness asked

In the same shell, after `exercise/README.md`'s commands, from `c5-unit22/` — one line. It starts TiffinBox in the background from
`.harness/mine/run` on the extracted class path plus the harness's classes, port 19019, with the harness that closes the database
and the kitchen added to the liveness group (its log in `.harness/mine/run.log`); waits for the harness's last line (every 0.25 s,
up to 40 s); asks liveness and prints its answer and status; stops TiffinBox with POST /shutdown and its token; and waits for it to
exit:

```bash
(cd .harness/mine/run && exec java -cp "../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19019 --spring.main.sources=probe.health.CloseDb --management.endpoint.health.group.liveness.include=livenessState,kitchen > ../run.log 2>&1) & for i in $(seq 160); do grep -qx 'harness: done' .harness/mine/run.log 2> /dev/null && break; sleep 0.25; done; echo "liveness $(curl -s -w ' [%{http_code}]' http://127.0.0.1:19019/actuator/health/liveness)"; harness/shutdown.sh 19019 .harness/mine/run/secrets/tiffinbox/shutdown-token; wait
```

(The flag replaces the liveness group's members for this run: Boot's own liveness state, and the kitchen. The token never reaches a
command line: `harness/shutdown.sh` reads it from the file and hands it to curl on its standard input. The `exec` makes the
background job TiffinBox's own process, so `wait` returns when it exits.)

## Measured — `exercise/README.md` run exactly as written, then the line above (2026-10-07)

In one clean shell — `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash --noprofile --norc`: no
variable of mine, Homebrew's `bin` for `mvn` — from `c5-unit22/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo`, no GraalVM.
The README's seven lines ran as written, one after another in that shell, every one exit 0, none printing a line. The token file:
27 bytes (26 characters and a newline), `-rw-------`. Then the line above, exit 0, printed:

```
liveness {"status":"DOWN"} [503]
POST /shutdown -> 200 · curl exit 0
```

Liveness now holds Boot's liveness state and the kitchen, and the worst of them answers: the kitchen is DOWN, so liveness is DOWN,
503. A platform that probes liveness restarts a process that answers 503 there — and a restart does not bring a database back:
the harness closes the database in every run it joins, as a database that stays down would (no platform runs here, so the restart
itself is not measured). The same line is in this unit's `exercise` capture. Port 19019 was free afterwards.

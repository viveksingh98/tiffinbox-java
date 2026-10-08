# Solution — one name, while it runs

In the same shell, after `exercise/README.md`'s commands, from `c5-unit24/` — one line. It starts TiffinBox in the background from
`.harness/mine/after` with the anchor README's line that exposes the loggers endpoint, port 19039 (its log in
`.harness/mine/run.log`); waits for readiness to answer 200 (every 0.25 s, up to 60 s); sets **`tiffinbox`** — TiffinBox's own
logger, not the group and not `com.tiffinbox` — to DEBUG; sends one request; reads both loggers' effective levels; stops TiffinBox
with POST /shutdown and its token; waits for it to exit; and prints the two levels and the log's DEBUG lines for the request:

```bash
(cd .harness/mine/after && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19039 --management.endpoints.web.exposure.include=health,prometheus,loggers > ../run.log 2>&1) & for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19039/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19039/actuator/loggers/tiffinbox; curl -s -o /dev/null http://127.0.0.1:19039/customers; t=$(curl -s http://127.0.0.1:19039/actuator/loggers/tiffinbox | sed 's/.*"effectiveLevel":"\([A-Z]*\)".*/\1/'); c=$(curl -s http://127.0.0.1:19039/actuator/loggers/com.tiffinbox | sed 's/.*"effectiveLevel":"\([A-Z]*\)".*/\1/'); harness/shutdown.sh 19039 .harness/mine/after/secrets/tiffinbox/shutdown-token; wait; echo "loggers/tiffinbox $t · loggers/com.tiffinbox $c · request DEBUG lines $(grep -cE ' DEBUG [0-9]+ --- .* tiffinbox +: GET /customers -> 200$' .harness/mine/run.log)"
```

(The token never reaches a command line: `harness/shutdown.sh` reads it from the file and hands it to curl on its standard input.
The `exec` makes the background job TiffinBox's own process, so `wait` returns when it exits — and only then is the log counted:
TiffinBox writes an answer's line after the answer is on the wire, so a count taken the moment curl returns could miss it.)

## Measured — `exercise/README.md` run exactly as written, then the line above (2026-10-07; again 2026-10-08, after RED C5-S4 part B's fixes: the same; and after part A's bridge fix, 2026-10-08: the same, line for line)

In one clean shell — `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash --noprofile --norc`: no
variable of mine, Homebrew's `bin` for `mvn` — from `c5-unit24/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo`, no GraalVM.
The README's six lines ran as written, one after another in that shell, every one exit 0, none printing a line. The token file:
27 bytes (26 characters and a newline), `-rw-------`. Then the line above, exit 0, printed:

```
POST /shutdown -> 200 · curl exit 0
loggers/tiffinbox DEBUG · loggers/com.tiffinbox INFO · request DEBUG lines 1
```

One name, while it runs. The POST went to `tiffinbox`, TiffinBox's own logger — the name Course 2 gave it, `System.getLogger("tiffinbox")`
— so its effective level is DEBUG, and the one request printed its line, `GET /customers -> 200`. `com.tiffinbox`, Spring's loggers
about TiffinBox, kept Boot's default, INFO. The group `kitchen` would have switched both (the video's `runtime`), and `com.tiffinbox`
alone would have printed no request line at all (the video's break, `names` B). The same line is in this unit's `exercise` capture.
Port 19039 was free afterwards.

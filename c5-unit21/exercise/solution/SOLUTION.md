# Solution — one run with env exposed, one question to it

In the same shell, after `exercise/README.md`'s commands, from `c5-unit21/` — one line. It starts the jar in the background from
`.harness/mine/run` with env exposed beside health (port 19009, its log in `.harness/mine/run.log`), asks readiness until it answers
200 (every 0.25 s, up to 30 s), asks env for the token's entry, prints the entry's source and value with the source's absolute path
written as `…`, stops TiffinBox with POST /shutdown and its token, and waits for it to exit:

```bash
(cd .harness/mine/run && exec java -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19009 --management.endpoints.web.exposure.include=health,env > ../run.log 2>&1) & for i in $(seq 120); do curl -sf -o /dev/null http://127.0.0.1:19009/actuator/health/readiness && break; sleep 0.25; done; curl -s http://127.0.0.1:19009/actuator/env/tiffinbox.shutdown-token | python3 -c 'import json, sys; p = json.load(sys.stdin)["property"]; print(p["source"] + " · tiffinbox.shutdown-token = " + p["value"])' | sed "s|'.*/secrets'|'…/secrets'|"; harness/shutdown.sh 19009 .harness/mine/run/secrets/tiffinbox/shutdown-token; wait
```

(`python3` reads the JSON; `sed` writes the path as `…`. The token never reaches a command line: `harness/shutdown.sh` reads it
from the file and hands it to curl on its standard input. The `exec` makes the background job TiffinBox's own process, so `wait`
returns when it exits.)

## Measured — `exercise/README.md` run exactly as written, then the line above (2026-10-07)

In one clean shell — `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash --noprofile --norc`: no
variable of mine, Homebrew's `bin` for `mvn` — from `c5-unit21/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo`, no GraalVM.
The README's five lines ran as written, one after another in that shell, every one exit 0, none printing a line. The token file:
27 bytes (26 characters and a newline), `-rw-------`. Then the line above, exit 0, printed:

```
Config tree '…/secrets' · tiffinbox.shutdown-token = ******
POST /shutdown -> 200 · curl exit 0
```

The source is the config tree `application.yaml` imports (`optional:configtree:./secrets/`), resolved against the folder TiffinBox
started in — its name holds that folder's absolute path, which the line writes as `…`. The value: `******`, as for every value env
shows by default (`management.endpoint.env.show-values`, `never`). The full answer also names the token file's origin, `file […]`, and
lists every other property source by name. The same line is in this unit's `exercise` capture.

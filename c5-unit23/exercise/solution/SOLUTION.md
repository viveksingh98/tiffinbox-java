# Solution — three verbs, one series

In the same shell, after `exercise/README.md`'s commands, from `c5-unit23/` — one line. It starts TiffinBox in the background from
`.harness/mine/after` as the anchor README runs it, port 19029 (its log in `.harness/mine/run.log`); waits for readiness to
answer 200 (every 0.25 s, up to 60 s); sends `/customers` the three verbs; prints the scrape's request counts; stops TiffinBox with
POST /shutdown and its token; and waits for it to exit:

```bash
(cd .harness/mine/after && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19029 > ../run.log 2>&1) & for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19029/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; for v in BREW PUT DELETE; do curl -s -o /dev/null -X "$v" http://127.0.0.1:19029/customers; done; curl -s http://127.0.0.1:19029/actuator/prometheus | grep '^tiffinbox_requests_seconds_count'; harness/shutdown.sh 19029 .harness/mine/after/secrets/tiffinbox/shutdown-token; wait
```

(The token never reaches a command line: `harness/shutdown.sh` reads it from the file and hands it to curl on its standard input.
The `exec` makes the background job TiffinBox's own process, so `wait` returns when it exits. The scrape is never written to a
file: only its `tiffinbox_requests_seconds_count` lines are printed — the rest holds this computer's own numbers.)

## Measured — `exercise/README.md` run exactly as written, then the line above (2026-10-07)

In one clean shell — `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash --noprofile --norc`: no
variable of mine, Homebrew's `bin` for `mvn` — from `c5-unit23/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo`, no GraalVM.
The README's six lines ran as written, one after another in that shell, every one exit 0, none printing a line. The token file:
27 bytes (26 characters and a newline), `-rw-------`. Then the line above, exit 0, printed:

```
tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 3
POST /shutdown -> 200 · curl exit 0
```

Three verbs, one series. TiffinBox's timer tags an answer with the route TiffinBox declares — its key, `GET /customers` — and when no
route takes the request's verb, with `UNKNOWN`: never the word the client sent. All three answers were 405, so all three share the
series `route="UNKNOWN",status="405"`, and its count is 3. Tagged with the verb as sent, the scrape would have kept three series —
and one more for every verb any client ever invents (the video's break shows the same with paths). The same line is in this unit's
`exercise` capture. Port 19029 was free afterwards.

# Solution — TiffinBox's own rows, and their verbs

Run from `c6-unit05/`, after `exercise/README.md`'s commands. One line: the README's last line with the endpoint's id spelt as
Boot spells it — `mappings`, plural. `mapping` names no endpoint, and Boot's exposure list ignores an id it does not know: the
shipped run's log names no `mapping` and holds no WARN or ERROR line, and its one hint is a count at INFO — `Exposing 2 endpoints
beneath base path '/actuator'`, where this line's run says 3 (this unit's `exercise` capture).

```bash
cd .harness/mine/tree && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19349 --management.endpoints.web.exposure.include=health,prometheus,mappings > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19349/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s http://127.0.0.1:19349/actuator/mappings > ../answer.json && ../../../harness/shutdown.sh 19349 secrets/tiffinbox/shutdown-token > /dev/null && wait && python3 ../../../harness/table.py tiffinbox < ../answer.json
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-13):

```
TiffinBox's rows: 5 · the verbs the table gives them: none
```

Each of TiffinBox's rows holds two keys, a path (`predicate`) and the handler's name (`handler`, `TiffinBox route /customers`) —
no `details`, so no `methods`: TiffinBox's handler still matches the verb inside itself. Actuator's rows list theirs (`GET`), and
so will TiffinBox's once the next lesson, *@RestController and Request Mapping*, makes them Spring's own (this unit's `rows`
capture shows both kinds of row, and who answers a wrong verb on each).

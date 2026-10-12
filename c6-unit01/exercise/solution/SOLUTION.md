# Solution — virtual threads, and the frames that leave

Run from `c6-unit01/`, after `exercise/README.md`'s commands. One word changes in the README's last line:
`--spring.threads.virtual.enable=true` becomes `--spring.threads.virtual.enabled=true`, with a **d**. Spelt `enable`, the option
changed nothing that was measured — the same 45 frames, `Thread.run` at the bottom — and the JVM's log said nothing about it: 0 lines
name it, 0 WARN, 0 ERROR (the `exercise` capture, A and A′). A misspelt key is not refused, and nothing here warned about it.

```bash
(cd .harness/mine/mvc && exec java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19308 --server.address=127.0.0.1 --server.port=19309 --spring.main.sources=probe.path.Stack --spring.threads.virtual.enabled=true > run.log 2>&1) & p=$!; for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19309/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; curl -s http://127.0.0.1:19309/probe/stack > .harness/mine/stack.txt; kill $p; wait $p; awk 'NR == 1 { f = $0 } $1 == 1 { b = $2 } END { print f " · the bottom frame: " b }' .harness/mine/stack.txt
```

Measured (this unit's `exercise` capture, `receipts.sh`, 2026-10-12):

```
frames the stack walker shows: 42 · the bottom frame: java.lang.VirtualThread.run
```

**The frames that left** — compare the two runs' `.harness/mine/stack.txt` (the capture does it with `comm`): four left, all of them
Tomcat's pool thread — `java.lang.Thread.run`, `org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run`,
`org.apache.tomcat.util.threads.ThreadPoolExecutor$Worker.run`, `org.apache.tomcat.util.threads.ThreadPoolExecutor.runWorker` — and
one came: `java.lang.VirtualThread.run`. 45 − 4 + 1 = 42; the other 41 frames are the same. With the key spelt right, the harness's
request ran on a virtual thread (`VirtualThread.run` at the bottom), so no pool thread sits under its stack; how Tomcat names and
sizes its threads is *Embedded Tomcat, Threads and Connectors*.

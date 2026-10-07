# Solution — tiffinbox-core as a folder, one change, one restart

In the same shell, after `exercise/README.md`'s commands, from `c5-unit25/`. The first line writes the class path with
tiffinbox-core's classes folder in place of its jar (one entry per line for `sed`, joined again with `paste`). The second starts
TiffinBox in the background from `.harness/mine`, the harness's folder and the web module's classes in front, `probe.Loaders` joined,
its output in `.harness/mine.log`. The third waits — every 0.25 s, up to 60 s — for the harness's first line, and prints it. The fourth
changes OrderQueue's class file's time, as a compiler that rewrites it would. The fifth waits for the second start and prints
DevTools' line and the harness's second line. The last stops TiffinBox with POST /shutdown and its token, waits for it to exit, and prints its exit code:

```bash
tr ':' '\n' < .harness/mine/tiffinbox-web/target/classpath.txt | sed 's|/tiffinbox-core/target/tiffinbox-core-1\.0\.0\.jar$|/tiffinbox-core/target/classes|' | paste -sd: - > .harness/mine/classpath-core-folder.txt
(cd .harness/mine && exec java -cp "../mine-hc:tiffinbox-web/target/classes:$(cat classpath-core-folder.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19045 --spring.main.sources=probe.Loaders > ../mine.log 2>&1) &
for i in $(seq 240); do grep -q '^LOADERS start 1 ' .harness/mine.log 2> /dev/null && break; sleep 0.25; done; grep '^LOADERS start 1 ' .harness/mine.log
touch .harness/mine/tiffinbox-core/target/classes/com/tiffinbox/OrderQueue.class
for i in $(seq 240); do grep -q '^LOADERS start 2 ' .harness/mine.log && break; sleep 0.25; done; grep -o 'Restarting due to .*' .harness/mine.log; grep '^LOADERS start 2 ' .harness/mine.log
harness/shutdown.sh 19045 .harness/mine/secrets/tiffinbox/shutdown-token; wait $!; echo "TiffinBox's exit code: $?"
```

(The token never reaches a command line: `harness/shutdown.sh` reads it from the file and hands it to curl on its standard input.
The `exec` makes the background job TiffinBox's own process, so `wait $!` returns when it exits, with its exit code: 1, as every
DevTools run here ends — the `exits` capture.)

## Measured — `exercise/README.md` run exactly as written, then the lines above (2026-10-07)

In one clean shell — `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash --noprofile --norc`: no
variable of mine, Homebrew's `bin` for `mvn` — from `c5-unit25/`, JDK 25.0.4.1, Maven 3.9.16, offline against `.m2-demo`, no GraalVM,
`anchor/` pointing at `../c5-unit24/after`, the logging lesson's tree (run again after the unit was re-pointed there; the first run,
on `../c5-unit21/after`, printed the same five lines). The README's seven lines ran as written, one after another in that shell, every
one exit 0, none printing a line. The token file: 27 bytes (26 characters and a newline), `-rw-------`. Then the six lines above, which
printed:

```
LOADERS start 1 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader RestartClassLoader
Restarting due to 1 class path change (0 additions, 0 deletions, 1 modification)
LOADERS start 2 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader RestartClassLoader
POST /shutdown -> 200 · curl exit 0
TiffinBox's exit code: 1
```

With tiffinbox-core as a folder, OrderQueue is defined by DevTools' restart loader from the first start on — the video's `which`
capture, with the jar, printed `OrderQueue's loader app` — and touching its class file is one class path change: DevTools restarts
TiffinBox, and the second start's OrderQueue comes from a new restart loader. Edit `OrderQueue.java` instead (one comment line under
its package line) and recompile the module while TiffinBox runs (`mvn -o -q -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo"
-pl tiffinbox-core compile`): measured once on each tree, the same day, the compiler wrote the module's classes again and DevTools
restarted once, `Restarting due to 10 class path changes (0 additions, 0 deletions, 10 modifications)` — then exit 1 after POST
/shutdown, as above.
The same lines as the block above are in this unit's `exercise` capture.

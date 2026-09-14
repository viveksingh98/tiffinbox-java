# c2-unit43 — Watching It Run: JFR, `jcmd` and `jshell`

Nothing new is built here. Everything below points at **`../c2-capstone`**, the server the
previous unit assembled. Build it first, and start every shell with the export — a bare shell
on this Mac hands Maven JDK 26 and the capstone's `--enable-preview` build fails with
`invalid source release 25`.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
(cd ../c2-capstone && mvn -B clean package)      # Java version: 25.0.4.1 → BUILD SUCCESS
```

## The five commands

**1 — record while it runs.** `-XX:StartFlightRecording` needs no agent and no code change.
`settings=profile` is the heavier of the two built-in profiles (`default.jfc` and `profile.jfc` are
the only two the JDK ships); `+jdk.VirtualThreadStart#enabled=true` switches on an event that is off
even in `profile`, because a busy server produces a great many of them. **Cost, measured here rather
than quoted:** the same 20,000-request load, after a warm-up, timed three times each — no recording
9.37 · 10.18 · 5.44 s, `settings=profile` 9.24 · 5.99 · 5.53 s. The spread inside one configuration is
bigger than the gap between them, so on this machine the overhead is **smaller than the noise**.

```bash
cd ../c2-capstone
java --enable-preview \
  "-XX:StartFlightRecording=name=tiffinbox,filename=tiffinbox.jfr,settings=profile,+jdk.VirtualThreadStart#enabled=true" \
  -Djava.util.logging.config.file=logging.properties \
  -jar target/c2-capstone-1.0.0.jar 18543
```
```
[1.486s][info][jfr,startup] Started recording 1. No limit specified, using maxsize=250MB as default.
[1.486s][info][jfr,startup] Use jcmd 57261 JFR.dump name=tiffinbox to copy recording data to file.
orders cooked:  120
kitchen value:  24300
routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
TiffinBox listening on http://127.0.0.1:18543
```

**2 — give it real load.** `Load.java` sends 20,000 requests, 200 in flight, one virtual thread each,
over kept-alive connections. Its output is byte-identical on every run, which is the point: the load is
fixed, so anything that moves in the recording moved because the JVM moved.

```bash
java Load.java 18543 20000 200
```
```
requests sent:   20000
200 responses:   20000
distinct bodies: 1
body:            {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
```

**3 — ask the live process, while it is busy.** `Thread.print` is the classic thread dump and it has
**no virtual threads in it** — only the eight carriers. `Thread.dump_to_file -format=json` is the one
that does. (`jcmd` splits its arguments on spaces and cannot quote, so the destination path must have
no spaces in it — `watch.sh` writes to `$TMPDIR` and copies the file back.)

```bash
jcmd <pid> Thread.print | grep '^"ForkJoinPool'
jcmd <pid> Thread.dump_to_file -overwrite -format=json /tmp/threads.json
jcmd <pid> Thread.vthread_scheduler
```
```
"ForkJoinPool-1-worker-1" #33 [34563] daemon prio=5 os_prio=31 cpu=755.29ms elapsed=8.84s …
…                                                                     (eight of them, 1 to 8)
"container": "java.util.concurrent.ThreadPerTaskExecutor@237772d2"     ← 90 virtual threads in it,
      "tid": "31153",  "virtual": true,  "state": "RUNNABLE",  "carrier": "35"    ← 6 of them mounted
java.util.concurrent.ForkJoinPool@492bdeff[Running, parallelism = 8, size = 8, active = 7, …]
```

**4 — stop the recording and read it.** The two `ThreadStart` lines are the whole lesson.

```bash
jcmd <pid> JFR.stop name=tiffinbox
curl -s -X POST http://127.0.0.1:18543/shutdown        # {"stopping":true}
jfr summary tiffinbox.jfr | grep ThreadStart
jfr view allocation-by-class tiffinbox.jfr
```
```
 jdk.VirtualThreadStart                  80203       1250428
 jdk.ThreadStart                            19           220

Object Type                               Allocation Pressure
byte[]                                                 25.08%
char[]                                                 14.87%
jdk.internal.vm.StackChunk                              5.25%
```
`80203` = `20000 requests × 4` (one for the exchange, three forked by the dashboard's
`StructuredTaskScope`) `+ 200 connections + 3 kitchen cooks`. It came out to exactly that on **nine** runs
here, and the prediction was checked twice by changing the inputs: `20000 × 4 + 50 + 3 = 80053` and
`5000 × 4 + 200 + 3 = 20203`, both exact. **`jdk.ThreadStart` beside it was 18 on seven of those runs
and 19 on two** — virtual threads are not counted there at all, because the operating system never
saw them. Tens against tens of thousands is the measurement; the digits are not.

`jdk.internal.vm.StackChunk` is a virtual thread's stack, copied to the heap when it unmounts.
`StackChunks.java` proves that with one variable changed:

```bash
java "-XX:StartFlightRecording=filename=v.jfr,settings=profile" StackChunks.java virtual
java "-XX:StartFlightRecording=filename=p.jfr,settings=profile" StackChunks.java platform
jfr view allocation-by-class v.jfr | grep StackChunk    # jdk.internal.vm.StackChunk  50.58%
jfr view allocation-by-class p.jfr | grep StackChunk    # (nothing — not in the table at all)
```

**5 — `jshell` on the compiled classes.** No `main`, no rebuild, no server running. `-q` keeps the
transcript free of identity hashes.

```bash
cd ../c2-capstone
jshell -q --class-path "target/classes:target/lib/*"
```
```
jshell> import com.tiffinbox.*
jshell> var db = new Database("jdbc:h2:mem:probe;DB_CLOSE_DELAY=-1")
jshell> db.createAndSeed()
jshell> var repo = new CustomerRepository(db)
jshell> repo.monthRevenue()
$5 ==> 24300
jshell> repo.findAll().size()
$6 ==> 4
jshell> new Dashboard(repo).load()
|  Error:
|  class file for target/classes/com/tiffinbox/Dashboard.class uses preview features of Java SE 25.
|    (use --enable-preview to allow loading of class files which contain preview features)
```
The same lines live in `probe.jsh`, for when you want them replayed rather than typed:
`jshell -q --class-path "target/classes:target/lib/*" ../c2-unit43/probe.jsh`. Run as a script file,
`jshell` prints only the error — script mode suppresses the `$N ==>` echoes.
Only `Dashboard` is marked, because it is the only class that uses a preview API — `javac` stamps the
file, not the project: `javap -v -p target/classes/com/tiffinbox/Dashboard.class | grep "minor version"`
prints `minor version: 65535`, and every other class in the package prints `minor version: 0`.
Add `--enable-preview` to the `jshell` line and `new Dashboard(repo).load()` runs.

## Everything at once

```bash
./watch.sh            # or ./watch.sh 9090 — checks the port first, kills the server after
```

## Files

| File | What it is |
|---|---|
| `watch.sh` | the five steps as one script: port check → record → load → three `jcmd` questions → stop → `lsof` and `pgrep` prove the port is free |
| `Load.java` | 20,000 requests, 200 in flight, `HttpClient` on a virtual-thread executor; deterministic output |
| `StackChunks.java` | the same 40,000 tasks on virtual and on platform threads, so `StackChunk` can be shown appearing and disappearing |
| `probe.jsh` | the `jshell` script: build a database, seed it, call the repository, then hit the preview wall |

Numbers that **do not** move here, measured over nine full cycles: `80203`, the eight
`ForkJoinPool-1-worker` names, `parallelism = 8`, the whole of `Load.java`'s output, `$5 ==> 24300`,
`$6 ==> 4`, and `minor version: 65535`. Numbers that **do** move: every pid, `elapsed`, `cpu`, `steals`,
`active`, `jdk.ThreadStart` (18 or 19), the recording's size in MB, every percentage in
`allocation-by-class` (`StackChunk` at 8.43 · 7.31 · 5.50 · 6.92 · 5.25 %), every row of `hot-methods`,
the virtual-thread count in a dump (52 · 90 · 217 · 414 · 618), and `jdk.VirtualThreadPinned` — which
came out 0 · 4 · 6 · 13 · 16 on five runs of this exact load (and as high as 21 on earlier curl-driven
runs), always during warm-up class loading, never inside a `synchronized` block.

Verified on JDK 25.0.4.1 (`/opt/homebrew/opt/openjdk@25`, macOS, Apple silicon, 8 cores) with
Maven 3.9.16 on 2026-09-14.

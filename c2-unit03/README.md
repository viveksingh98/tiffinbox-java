# c2-unit03 — Garbage Collection: Reachability, G1 and the System.gc() Hint

What it teaches: an object is garbage when nothing can reach it — not when you set a variable to `null` — and how to watch G1 prove that on a live JVM.

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`):

```bash
java Reachability.java
```
```
start:              44 MB used
after allocating:   144 MB used
after bills = null: 144 MB used
after System.gc():  3 MB used
```
The megabyte figures are real captures from Vivek's Mac and move a little between runs; the **shape** is identical every run — dropping the reference frees nothing on its own, the collector is what frees it.

```bash
java -XX:+DisableExplicitGC Reachability.java   # same four lines, but the last one stays at ~144 MB: System.gc() is now a no-op
java -Xlog:gc Reachability.java                 # the same run with every G1 pause printed: [info][gc] GC(0) Pause Young (Normal) ...
```

Inspecting a **running** JVM — `Sleeper.java` holds 20 MB and sleeps for 60 seconds so you have time:

```bash
java -Xmx64m Sleeper.java &     # prints: holding 20 MB — inspect me with jcmd
jcmd -l                         # find the pid (the line ending in Sleeper)
jcmd <pid> GC.heap_info         # garbage-first heap total reserved 65536K, committed ..., used ...
jstat -gcutil <pid>             # survivor/eden/old percentages
jcmd <pid> GC.run               # Command executed successfully — watch GC.heap_info drop
kill <pid>                      # always: do not leave it running
```

Sleeper exits on its own after 60 s, but kill it when you are done so nothing is left behind.

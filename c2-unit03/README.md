# c2-unit03 — Garbage Collection: Reachability, G1 and the System.gc() Hint

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`):
- `java Reachability.java` · `java -XX:+DisableExplicitGC Reachability.java` · `java -Xlog:gc Reachability.java`
- `java -Xmx64m Sleeper.java &` then `jcmd -l`, `jcmd <pid> GC.heap_info`, `jstat -gcutil <pid>`, `jcmd <pid> GC.run`
- Megabyte figures are real captures from Vivek's Mac and move a little between runs; the shape (null frees nothing, System.gc() collapses the heap) is identical every run.

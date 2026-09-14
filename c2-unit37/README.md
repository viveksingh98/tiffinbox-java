# c2-unit37 — Connection Pools: close() That Gives It Back (JDK 25.0.4.1, Maven 3.9.16)
1. `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH` — **required here**: a bare `java` on this Mac is 23.0.1 and answers `UnsupportedClassVersionError … class file version 69.0`.
2. `mvn -q compile exec:java -Dexec.mainClass=Pool` — the proxy, the physical connection under it, and the connection used after it went home.
3. `mvn -q dependency:build-classpath -Dmdep.outputFile=cp.txt` then `java -cp "target/classes:$(cat cp.txt)" Pool` — the same run **plus** HikariCP's own start-up banner, which `mvn -q` swallows.
4. `java -cp "target/classes:$(cat cp.txt)" PoolOops` — a pool of one, borrowed and never returned; the timeout figure is about 2,000 ms and differs every run.
H2 `2.5.250` + HikariCP `7.1.0` + slf4j-simple `2.0.17` (so Hikari's log lines are a real capture). `Pool` is byte-identical 3/3 — md5 `51415475ba023ade0115bb305ef79b0a` under `mvn -q`, `dae4e68b2bd576f515c2953491c8f6de` under `java -cp`. `PoolOops` is byte-identical 4/4 once the millisecond figure is normalised.

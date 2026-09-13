# c2-unit05 — JIT and Escape Analysis: Why Small Objects Can Be Free

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`):
- `java Escape.java` — rounds 1-3 vary run to run (roughly 4-7 MB, sometimes 191 KB); rounds 4-6 printed `0 KB` on all 14 runs.
- `java -XX:-DoEscapeAnalysis Escape.java` · `java -Xint Escape.java` · `java -XX:TieredStopAtLevel=1 Escape.java` — all three print `46875 KB` every round (2,000,000 x 24 bytes = 48 MB).
- `java -XX:+PrintFlagsFinal -version | grep -E 'TieredCompilation|DoEscapeAnalysis'` — both `true` by default; `DoEscapeAnalysis` is tagged `{C2 product}`.

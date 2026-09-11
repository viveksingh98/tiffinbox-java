# Unit 04 — How Java Actually Runs: Source, Bytecode, JVM
Two-step run (what the video shows): `javac Hello.java` creates `Hello.class` (bytecode), then `java Hello` runs it on the JVM.
One-step shortcut (Unit 03 style): `java Hello.java` compiles in memory and runs — no `.class` file is written.
Peek at the bytecode: `javap -c Hello` (needs `Hello.class` from the first step).
Verified on JDK 25.0.4.1 — expected output: `Hello, TiffinBox!`

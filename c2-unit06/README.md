# c2-unit06 — Type Erasure: What the Compiler Really Sees

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`):
- `java SameClass.java` → `same class?      true` · `java InnerStatic.java` → `created: 2` (compact source files).
- `javac -d out Customer.java Bills.java` then `javap -s -p out/Bills.class` (descriptor `(Ljava/util/List;)I`) and `javap -c -p out/Bills.class` (the `checkcast Customer` the compiler inserted).
- `javac -d out ByBill.java` then `javap -c -p out/ByBill.class` (two `compare` methods) and `javap -v -p out/ByBill.class` (`flags: (0x1041) ACC_PUBLIC, ACC_BRIDGE, ACC_SYNTHETIC`).
- `javac -d out NewT.java` · `javac -d out ListOfInt.java` · `javac -d out TDotClass.java` — the four impossible things; `javac -Xlint:unchecked -d out Pollution.java` then `java -cp out Pollution` → `ClassCastException` at `Pollution.java:13`.

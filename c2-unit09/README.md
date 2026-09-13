# c2-unit09 — Wildcards: `? extends`, `? super` and PECS
Verified on JDK 25.0.4.1 (`export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`).
Run the working demo: `java Wildcards.java` → `veg only total: 220` / `mixed total:    410` / `ledger:  [7200, 4500, 9000, 3600]` / `numbers: [7200, 4500, 9000, 3600]` / `howMany(vegOnly): 2, howMany(ledger): 4`.
Deliberate compile errors: `javac -d out Invariant.java` (invariance, line 10) and `javac -Xdiags:verbose -d out AddToExtends.java` (capture `CAP#1`, line 9).
Array contrast — compiles, fails at run time: `javac -d out ArrayStore.java` then `java -cp out ArrayStore` → `java.lang.ArrayStoreException: ArrayStore$NonVegMeal` at `ArrayStore.java:9`.

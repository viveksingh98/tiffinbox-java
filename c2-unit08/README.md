# c2-unit08 — Bounded Types: T extends Comparable&lt;T&gt;

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`):
- `java Bounded.java` — prints `biggest bill:  Sunil -> 9000` / `last label A-Z: VEGAN` / `most meals/day: 3` / `VEG at 120` / `VEGAN at 140` (identical on 3 runs).
- `javac -d out Bounded.java && javap -s -p out/Bounded.class` — `max` erases to `(Ljava/util/List;)Ljava/lang/Comparable;`, `describe` to `(LBounded$Meal;)Ljava/lang/String;` (the **first** bound).
- `javac -d out BareT.java` — fails: `BareT.java:7: error: cannot find symbol` … `T extends Object declared in method <T>max(List<T>)`.
- `javac -d out NotComparable.java` — fails at line 16: `inference variable T has incompatible bounds` · `javac -d out Order.java` — fails: `Order.java:5: error: interface expected here` (class written second in a multiple bound).

# c2-unit07 — Generic Classes and Interfaces: Repository<T, ID>

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`):
- `java Repo.java` — the whole demo; byte-identical output on every run (3 runs checked).
- `javac -d out StaticT.java` — **expected to fail**: two `non-static type variable ... cannot be referenced from a static context` errors (lines 2 and 4), then `2 errors`.
- `javac -d out StaticFix.java` — the fix, `static <E> void clear(E id)`, compiles (exit 0) · `javac -d out WrongId.java` — **expected to fail**: `incompatible types: int cannot be converted to String` on `customers.findById(2)`.

# c2-unit10 — Generic Methods, Type Inference and Class<T> Tokens

Run (JDK 25.0.4.1 — `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH`):
- `java GenericMethods.java` — compact source file; identical output on 3 runs (`firstTwo`, target-type vs explicit-witness `emptyList`, `Class<T>` token lookups).
- `javac -d out Witness.java` — fails on purpose: `Witness.java:7: error: incompatible types: Object cannot be converted to String`. Fixed version: `javac -d out WitnessFixed.java && java -cp out WitnessFixed`.
- `javac -d out DiamondMiss.java` — fails on purpose (`var` + diamond): `DiamondMiss.java:7: error: incompatible types: Object cannot be converted to int`.
- `javac -d out WrongToken.java && java -cp out WrongToken` — `ClassCastException` from `Class.cast` inside `load` (line 8); `javac -d out PlainCast.java && java -cp out PlainCast` shows the unchecked `(T)` cast blaming the caller instead.

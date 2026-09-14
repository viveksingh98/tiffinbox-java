# c2-unit39 — Reflection: Inspecting Classes at Run Time
Verified on JDK 25.0.4.1 (`/opt/homebrew/opt/openjdk@25`). `Customer` must be a **top-level** file, so compile, do not use source mode:
`export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH=$JAVA_HOME/bin:$PATH; javac -d out Customer.java Reflect.java Oops.java`
Then: `java -cp out Reflect` · the module-wall fix: `java --add-opens java.base/java.lang=ALL-UNNAMED -cp out Reflect` · the failures: `java -cp out Oops`
`Compact.java` is the counter-example — it lives in `compact/` on purpose — `cd compact && java Compact.java`: the record compiles to `Compact$Customer`, so `Class.forName("Customer")` throws `ClassNotFoundException`.

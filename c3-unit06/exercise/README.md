# Exercise — make three builds produce one jar

Line 1, always: `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"` (Maven 3.9.16, JDK 25.0.4.1).

**Start** — from this folder:

```
for i in 1 2 3; do mvn -B -q clean package; md5 -q tiffinbox-kitchen/target/*.jar; done
```

Three builds of the same source print **three different hashes**, and `unzip -l tiffinbox-kitchen/target/tiffinbox-kitchen-1.0.0.jar` shows every entry stamped with the wall clock — for example `d59501b8424c7f913ab1cc0310f59988`, `faed0815041ea68ce337113db6d19202`, `3d3ecf82aa5feaf18d604ac2e21f874c` on this machine, at `09-14-2026 13:2x`.

**Task** — one line, in this project's parent `pom.xml`, inside `<properties>`. Make three consecutive builds print one hash.

**End state** — the same loop prints the same hash three times, `ec6afdd1d1188b7b00adb4465895827d` on this machine (yours will match only if you use the same date, Maven 3.9.16, jar plugin 3.5.0 and JDK 25 — the manifest records `Build-Jdk-Spec`), and `unzip -l tiffinbox-kitchen/target/tiffinbox-kitchen-1.0.0.jar` shows **every entry stamped `00:00`**.

**Answer** — `solution/pom.xml`: `cp solution/pom.xml pom.xml` and re-run the loop. Verified by the author, 3 of 3 identical, `mvn -o -B verify` → `BUILD SUCCESS`.

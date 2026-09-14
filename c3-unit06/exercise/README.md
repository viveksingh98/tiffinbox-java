# Exercise — make three builds produce one jar

Line 1, always: `export JAVA_HOME=/opt/homebrew/opt/openjdk@25; export PATH="$JAVA_HOME/bin:$PATH"` (Maven 3.9.16, JDK 25.0.4.1).
Line 2, always, from this folder: `M2="$PWD/../.m2-unit06"`.

The unit's rule holds here too, and this is the unit about the local repository: every `mvn` below carries
`-Dmaven.repo.local`, so the loop fills `c3-unit06/.m2-unit06` — the same scratch repository the rest of the
unit used — and never your real `~/.m2`. **Keep the quotes:** this tree's path contains a space, and unquoted
in bash the flag splits and Maven answers `Unknown lifecycle phase "Content/…"`.

**Start** — from this folder:

```
for i in 1 2 3; do mvn -B -q "-Dmaven.repo.local=$M2" clean package; md5 -q tiffinbox-kitchen/target/*.jar; done
```

Three builds of the same source print **three different hashes**, and `unzip -l tiffinbox-kitchen/target/tiffinbox-kitchen-1.0.0.jar` shows every entry stamped with the wall clock — for example `d59501b8424c7f913ab1cc0310f59988`, `faed0815041ea68ce337113db6d19202`, `3d3ecf82aa5feaf18d604ac2e21f874c` on this machine, at `09-14-2026 13:2x`.

**Task** — one line, in this project's parent `pom.xml`, inside `<properties>`. Make three consecutive builds print one hash.

**End state** — the same loop prints the same hash three times, `ec6afdd1d1188b7b00adb4465895827d` on this machine (yours will match only if you use the same date, Maven 3.9.16, jar plugin 3.5.0 and JDK 25 — the manifest records `Build-Jdk-Spec`), and `unzip -l tiffinbox-kitchen/target/tiffinbox-kitchen-1.0.0.jar` shows **every entry stamped `00:00`**.

**Answer** — `solution/pom.xml`: `cp solution/pom.xml pom.xml` and re-run the loop. Verified by the author, 3 of 3 identical, `mvn -o -B "-Dmaven.repo.local=$M2" verify` → `BUILD SUCCESS`
(after one ordinary online `verify` into that same `$M2` — offline mode resolves nothing new, it cannot
resolve anything that is not already there).

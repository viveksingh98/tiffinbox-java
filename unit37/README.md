# Unit 37 — TiffinBox Console App: The Design

- No new code in this unit: the design slides quote the finished capstone in `../capstone/` (`pom.xml`, `customers.csv`, `src/main/java/com/tiffinbox/` — 8 files, `src/test/java/com/tiffinbox/` — 3 tests). Unit 38 builds it file by file.
- Build + run it now if you want to see the menu: from `../capstone/`, `mvn -q package` then `java -jar target/tiffinbox-1.0.jar` (with `JAVA_HOME` on JDK 25). Choose `1` to list, `3` for the bill report (`Total revenue: 15300`), `5` to save and exit.
- Slide 4 shows `Customer.java` with two of its three checks and the CSV methods folded into comments; the full record is in `../capstone/src/main/java/com/tiffinbox/Customer.java`. Slide 6 quotes the `Scanner` lines from `TiffinBoxApp.java`.
- Pipe input to see the closed-input rule: `printf '1\n3\n5\n' | java -jar target/tiffinbox-1.0.jar` (typed digits are not echoed, so `Choose (1-5): ` is followed directly by the output); `printf 'x\n' | java -jar ...` prints `Please enter a number from 1 to 5`, then `(input closed)` and saves.
- Needs JDK 25 (`java.lang.IO`, JEP 512; records + compact constructors, JEP 395), Apache Maven 3.9.x, JUnit Jupiter 5.13.4. Verified on JDK 25.0.4.1, Maven 3.9.16, surefire 3.5.3, jar plugin 3.5.0.

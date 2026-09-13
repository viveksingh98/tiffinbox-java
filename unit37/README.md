# Unit 37 — TiffinBox Console App: The Design

**What this unit teaches:** Design the capstone before typing it: responsibilities become classes, layers point one way, and the menu loop is drawn first.

**You need:** JDK 25, Apache Maven 3.9.x, JUnit Jupiter 5.13.4, `JAVA_HOME` on JDK 25. Verified on JDK 25.0.4.1, Maven 3.9.16.

Run everything from this folder (`cd unit37`), in the order below.

### Build the capstone and see the menu

Build the designed app and see the menu the slides draw (option 5 saves and exits).

```console
$ cd ../capstone && mvn -q package && printf '5\n' | java -jar target/tiffinbox-1.0.jar
Skipped line 3: For input string: "two" in 'Sunil,two,120,true'
No .../junit-<random>/nothing-here.csv yet, starting empty
Loaded 3 customers from customers.csv

TiffinBox - Asha's tiffin service
1  List customers
2  Add customer
3  Bill report
4  Pause a customer
5  Save and exit
Choose (1-5): Saved 3 customers to customers.csv. Bye!
```

> The two lines before `Loaded 3 customers` come from the capstone's own tests: `CustomerRepositoryTest` deliberately feeds the loader a bad row and a missing file, and `mvn -q` hides Maven's log but not what the tests print.

### Notes

- **There is no code in this folder on purpose.** The design slides quote the finished capstone in [`../capstone/`](../capstone): `pom.xml`, `customers.csv`, eight classes under `src/main/java/com/tiffinbox/` and three test classes under `src/test/java/com/tiffinbox/`. Unit 38 builds it file by file.
- Slide 4 shows `Customer.java` with two of its three checks and the CSV methods folded into comments; the full record is in `../capstone/src/main/java/com/tiffinbox/Customer.java`. Slide 6 quotes the `Scanner` lines from `TiffinBoxApp.java`.
- Typed digits are not echoed when you pipe input, so `Choose (1-5): ` is followed straight by the output. `printf 'x\n' | java -jar target/tiffinbox-1.0.jar` prints `Please enter a number from 1 to 5`, then `(input closed)`, then saves.

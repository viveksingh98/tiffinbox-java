# Capstone — TiffinBox Console App

**What this project pulls together:** The whole course in one Maven project: records, enums, sealed types, collections, streams, Optional, files, exceptions, java.time and JUnit.

**You need:** JDK 25, Apache Maven 3.9.x, JUnit Jupiter 5.13.4 (Maven downloads it on the first run), `JAVA_HOME` on JDK 25. Verified on JDK 25.0.4.1, Maven 3.9.16, surefire 3.5.3, jar 3.5.0.

Run everything from this folder (`cd capstone`), in the order below.

### mvn -B test

Eleven tests across `CustomerTest`, `CustomerRepositoryTest` and `BillingServiceTest`.

```console
$ mvn -B test
[... Maven's own log trimmed ...]
[INFO] Running com.tiffinbox.BillingServiceTest
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.157 s -- in com.tiffinbox.BillingServiceTest
[INFO] Running com.tiffinbox.CustomerTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.048 s -- in com.tiffinbox.CustomerTest
[INFO] Running com.tiffinbox.CustomerRepositoryTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.080 s -- in com.tiffinbox.CustomerRepositoryTest
[INFO] Tests run: 11, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

### mvn -q package

Tests, then the runnable jar.

```console
$ mvn -q package && ls target/tiffinbox-1.0.jar
Skipped line 3: For input string: "two" in 'Sunil,two,120,true'
No .../junit-<random>/nothing-here.csv yet, starting empty
target/tiffinbox-1.0.jar
```

### printf '1\n3\n5\n' | java -jar target/tiffinbox-1.0.jar

List customers, print the bill report, save and exit — piped so it runs without typing.

```console
$ printf '1\n3\n5\n' | java -jar target/tiffinbox-1.0.jar
Loaded 3 customers from customers.csv

TiffinBox - Asha's tiffin service
1  List customers
2  Add customer
3  Bill report
4  Pause a customer
5  Save and exit
Choose (1-5): 
Ravi     2 meals/day  120 per meal  veg
Meera    1 meals/day  150 per meal  non-veg
Sunil    1 meals/day  120 per meal  veg
3 customers

TiffinBox - Asha's tiffin service
1  List customers
2  Add customer
3  Bill report
4  Pause a customer
5  Save and exit
Choose (1-5): 
Name     Type       Bill
Ravi     VEG        7200
Meera    NON_VEG    4500
Sunil    VEG        3600
Total revenue: 15300  |  veg customers: 2 of 3
By type: {VEG=10800, NON_VEG=4500}
Pay by cash at the door or UPI to asha@okbank

TiffinBox - Asha's tiffin service
1  List customers
2  Add customer
3  Bill report
4  Pause a customer
5  Save and exit
Choose (1-5): Saved 3 customers to customers.csv. Bye!
```

### printf '2\nPriya\n2\ny\n\n4\nRavi\n14/09/2026\n20/09/2026\n3\n5\n' | java -jar target/tiffinbox-1.0.jar

Add a customer, pause Ravi for a week, then the report — the full feature set.

```console
$ printf '2\nPriya\n2\ny\n\n4\nRavi\n14/09/2026\n20/09/2026\n3\n5\n' | java -jar target/tiffinbox-1.0.jar
Loaded 3 customers from customers.csv

TiffinBox - Asha's tiffin service
1  List customers
2  Add customer
3  Bill report
4  Pause a customer
5  Save and exit
Choose (1-5): 
Name: Meals per day (1-3): Veg? (y/n): Price per meal [120]: Added Priya: monthly bill 7200

TiffinBox - Asha's tiffin service
1  List customers
2  Add customer
3  Bill report
4  Pause a customer
5  Save and exit
Choose (1-5): 
Customer name: Pause from (dd/MM/yyyy): Pause to (dd/MM/yyyy): Ravi paused 7 days (14/09/2026 to 20/09/2026): this month's bill 5520 instead of 7200

TiffinBox - Asha's tiffin service
1  List customers
2  Add customer
3  Bill report
4  Pause a customer
5  Save and exit
Choose (1-5): 
Name     Type       Bill
Priya    VEG        7200
Ravi     VEG        5520  (paused 7 days)
Meera    NON_VEG    4500
Sunil    VEG        3600
Total revenue: 20820  |  veg customers: 3 of 4
By type: {VEG=16320, NON_VEG=4500}
Pay by cash at the door or UPI to asha@okbank

TiffinBox - Asha's tiffin service
1  List customers
[... trimmed ...]
Choose (1-5): Saved 4 customers to customers.csv. Bye!
```

### Notes

- Run it for real (no pipe): `java -jar target/tiffinbox-1.0.jar`, then type `1`-`5` at the prompt.
- `customers.csv` in this folder is the app's data file and IS committed — option 5 rewrites it. `git checkout customers.csv` undoes any experiment.
- `export JAVA_HOME=/opt/homebrew/opt/openjdk@25` (macOS Homebrew) before `mvn`.
- Layout: `TiffinBoxApp` (menu + Scanner) → `BillingService` / `CustomerRepository` → the model (`Customer`, `MealType`, `Payment`, `Pause`, `TiffinBoxException`). Arrows point one way.

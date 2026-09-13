# Unit 38 — TiffinBox: Build It

**What this unit teaches:** Unit 37's design becomes a real Maven project, built inside-out: model → repository → service → app → tests → jar.

**You need:** JDK 25, Apache Maven 3.9.x, JUnit Jupiter 5.13.4 (downloaded on the first run), `JAVA_HOME` on JDK 25. Verified on JDK 25.0.4.1, Maven 3.9.16, surefire 3.5.3, jar 3.5.0.

Run everything from this folder (`cd unit38`), in the order below.

### Run the capstone's tests

The eleven tests of the finished app.

```console
$ cd ../capstone && mvn -B test
[... Maven's own log trimmed ...]
[INFO] Running com.tiffinbox.BillingServiceTest
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.185 s -- in com.tiffinbox.BillingServiceTest
[INFO] Running com.tiffinbox.CustomerTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.073 s -- in com.tiffinbox.CustomerTest
[INFO] Running com.tiffinbox.CustomerRepositoryTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.075 s -- in com.tiffinbox.CustomerRepositoryTest
[INFO] Tests run: 11, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

### Build the jar and drive the menu

List the customers, print the bill report, save and exit.

```console
$ cd ../capstone && mvn -q package && printf '1\n3\n5\n' | java -jar target/tiffinbox-1.0.jar
Skipped line 3: For input string: "two" in 'Sunil,two,120,true'
No .../junit-<random>/nothing-here.csv yet, starting empty
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

> The two lines before `Loaded 3 customers` come from the capstone's own tests: `CustomerRepositoryTest` deliberately feeds the loader a bad row and a missing file, and `mvn -q` hides Maven's log but not what the tests print.

### Notes

- **There is no code in this folder on purpose** — the unit builds the project in [`../capstone/`](../capstone). Unit 37 designed it, Unit 38 builds it, Unit 39 maps what comes next.
- See the red run from the video: in `../capstone/src/main/java/com/tiffinbox/Pause.java`, change `return (int) ChronoUnit.DAYS.between(from, to) + 1;` to `return (int) ChronoUnit.DAYS.between(from, to);`, run `mvn -B test` → `expected: <5520> but was: <5760>` in `BillingServiceTest.pauseOfSevenDaysBillsTwentyThree`, `BUILD FAILURE`. Put the `+ 1` back for green. The shipped capstone is already fixed.
- Two honest gaps, and your first extensions: pauses live in memory only (`BillingService`) and are never saved — add a `pauses.csv` through a second repository of the same shape; and a name containing a comma breaks `split(",")` in `Customer.fromCsv` — Unit 34's `commons-csv` dependency fixes that.

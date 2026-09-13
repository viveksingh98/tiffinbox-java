# TiffinBox — code for *Java Fundamentals* (Learn Programming with Vivek)

Every unit of the course builds **TiffinBox**, a small tiffin-delivery service app, one concept at a time.
Course playlist: https://www.youtube.com/@LearnProgrammingWithVivek

## How to run
Requires **JDK 25 or newer** (compact source files + `IO.println`). Each unit folder has its own README.

```bash
cd unit03
java Hello.java
```

## Units
| Unit | Topic | Folder |
|---|---|---|
| 01 | Why Java in 2026 (and How This Course Works) | `unit01/` |
| 02 | Install JDK 25 and IntelliJ | `unit02/` |
| 03 | Your First Program: Hello, TiffinBox | `unit03/` |
| 04 | How Java Actually Runs: Source, Bytecode, JVM | `unit04/` |
| 05 | Variables and Types: Where Data Lives | `unit05/` |
| 06 | Operators and Expressions: Ravi's Monthly Bill | `unit06/` |
| 07 | Strings: Text Done Right | `unit07/` |
| 08 | Making Decisions: if, else, switch | `unit08/` |
| 09 | Loops: Doing It 30 Times | `unit09/` |
| 10 | Methods: Name a Piece of Work | `unit10/` |
| 11 | Arrays: Seven Days of Menus | `unit11/` |
| 12 | Classes and Objects: Meet Customer | `unit12/` |
| 13 | Constructors and this | `unit13/` |
| 14 | Encapsulation: Private Fields, Public Doors | `unit14/` |
| 15 | Inheritance: Meal, VegMeal, NonVegMeal | `unit15/` |
| 16 | Polymorphism: One Call, Many Behaviours | `unit16/` |
| 17 | Abstract Classes and Interfaces | `unit17/` |
| 18 | Records, Enums and Sealed Types | `unit18/` |
| 19 | ArrayList: A List That Grows | `unit19/` |
| 20 | HashMap and HashSet: Look Things Up Fast | `unit20/` |
| 21 | Generics: Why List<String> Not Just List | `unit21/` |
| 22 | Sorting and Comparators | `unit22/` |
| 23 | equals, hashCode and toString | `unit23/` |
| 24 | Exceptions: When Things Go Wrong | `unit24/` |
| 25 | Custom Exceptions and Clean Error Handling | `unit25/` |
| 26 | Files: Read and Write with java.nio | `unit26/` |
| 27 | Parsing Data: CSV to Objects | `unit27/` |
| 28 | Lambdas and Functional Interfaces | `unit28/` |
| 29 | Streams: Reports in One Line | `unit29/` |
| 30 | Optional: The End of null Checks | `unit30/` |
| 31 | Pattern Matching: instanceof and switch | `unit31/` |
| 32 | Dates and Times with java.time | `unit32/` |
| 33 | Packages, Imports and Project Structure | `unit33/` |
| 34 | Maven in 15 Minutes | `unit34/` |
| 35 | Testing with JUnit 5 | `unit35/` |
| 36 | Debugging in IntelliJ | `unit36/` |
| 37 | TiffinBox Console App: The Design (→ capstone/) | `unit37/` |
| 38 | TiffinBox: Build It (→ capstone/) | `unit38/` |
| 39 | What's Next: Spring Boot, AI Agents and Your Java Path | `unit39/` |

All 39 Java Fundamentals units are here; the finished app is in `capstone/`.
**Every folder's README states what the unit teaches, the exact command for each file (with flags) and the real output it prints**; files that fail or give the wrong answer on purpose are labelled with the error you should see.

Course 1 needs **JDK 25**, plus Apache Maven 3.9.x for units 34, 35, 37, 38 and the capstone:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25   # or wherever your JDK 25 lives
export PATH="$JAVA_HOME/bin:$PATH"
./verify_course1.sh              # runs every Course 1 command and prints PASS/FAIL per unit
./verify_course1.sh unit05 unit26  # just those folders
```

`verify_course1.sh` time-boxes every command, asserts that the break-it-on-purpose files really fail with the right message, cleans up the files and class trees the examples create, and exits non-zero if anything is off.

## Course 2 — Core Java II: Under the Hood
Code for that course lives in `c2-unitNN/` folders (JVM memory, GC, generics, concurrency, I/O, modules, JDBC), and the finished service in `c2-capstone/`.
Many units need JVM flags — `-Xmx16m`, `--enable-preview`, `-Djdk.virtualThreadScheduler.parallelism=1` and friends. **Each folder's README has the exact command and the real output**, and files that fail on purpose are labelled with the error they print.

Course 2 needs **JDK 25** (compact source files, JEP 512; `StructuredTaskScope` preview, JEP 505):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25   # or wherever your JDK 25 lives
export PATH="$JAVA_HOME/bin:$PATH"
./verify_course2.sh            # runs every c2-* command and prints PASS/FAIL
./verify_course2.sh 09 14      # just those units
SKIP_SLOW=1 ./verify_course2.sh   # skip the ~50 s pool run and the deadlock demo
```

`verify_course2.sh` walks only the `c2-*` folders that exist, time-boxes the long demos, kills every JVM it starts and leaves no ports, heap dumps or build output behind.
Videos publish a few per day on the channel. Roadmap: Core Java → Spring Framework → Spring Boot → JPA → REST → Security → … → Spring AI.

— Vivek Singh · Prompt Vidya AI: https://www.youtube.com/@PromptVidyaAI

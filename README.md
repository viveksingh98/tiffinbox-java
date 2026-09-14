# TiffinBox — code for *Java Fundamentals* and *Core Java II* (Learn Programming with Vivek)

Every unit of both courses builds **TiffinBox**, a small tiffin-delivery service app, one concept at a time.
Course 1 lives in `unitNN/` + `capstone/`; Course 2 in `c2-unitNN/` + `c2-capstone/`.
Channel: https://www.youtube.com/@LearnProgrammingWithVivek

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
| 40 | Recursion, Varargs and Two-Dimensional Arrays | `unit40/` |
| 41 | Numbers You Can Trust: Ranges, Overflow, Math and Random | `unit41/` |
| 42 | Text, Properly: char, the Methods You'll Type Daily, and printf | `unit42/` |
| 43 | Talking to the User: Scanner, args, and a Program That Answers Back | `unit43/` |
| 44 | Comments, Javadoc, and How to Read the Java Docs | `unit44/` |
| 45 | The Keywords We Skipped: protected, final, static Interface Methods, Nested Classes | `unit45/` |
| 46 | You're On Your Own Now: Practice, Errors and Asking for Help | `unit46/` |

All 46 Java Fundamentals units, across 9 sections, are here; the finished app is in `capstone/`.
**Every folder's README states what the unit teaches, the exact command for each file (with flags) and the real output it prints**; files that fail or give the wrong answer on purpose are labelled with the error you should see.

**Section 9 (units 40-46) ships an exercise with every unit** — that is the thing that makes this section more than a code dump. Each `unitNN/exercise/` holds a **starter** that compiles and runs unedited (stubbed answers behind `// TODO`s), the **worked solution** beside it, and an `exercise/README.md` giving the task, the exact run commands, the acceptance output byte for byte, the traps the exercise is built on and what every file in the folder is. Unit 46's starter is the debugging exercise, so it is meant to crash until you fix it. `verify_course1.sh` checks both halves of all seven.

Course 1 needs **JDK 25**, plus Apache Maven 3.9.x for units 34, 35, 37, 38 and the capstone:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25   # or wherever your JDK 25 lives
export PATH="$JAVA_HOME/bin:$PATH"
./verify_course1.sh              # runs every Course 1 command and prints PASS/FAIL per unit
./verify_course1.sh unit05 unit26  # just those folders
```

`verify_course1.sh` time-boxes every command, asserts that the break-it-on-purpose files really fail with the right message, checks every Section 9 exercise (the starter runs unedited; the worked solution prints its acceptance block byte for byte), cleans up the files, class trees and `javadoc` sites the examples create, and exits non-zero if anything is off. Unit 44's `javadoc` runs offline — there is no `-link` flag anywhere in this repo.

## Course 2 — Core Java II: Under the Hood
**44 units across 9 sections**, in `c2-unitNN/`, with the finished service in `c2-capstone/`.
Course playlist: *Core Java II — Under the Hood*. The anchor is the same TiffinBox app: the
Course 1 console program becomes a small multi-threaded HTTP server on an embedded H2 database.

| Section | Units | Folders |
|---|---|---|
| 1 · JVM Memory & GC | 01-05 | `c2-unit01/` … `c2-unit05/` |
| 2 · Generics Deep-Dive | 06-10 | `c2-unit06/` … `c2-unit10/` |
| 3 · Concurrency I: Threads & Executors | 11-14 | `c2-unit11/` … `c2-unit14/` |
| 4 · Concurrency II: Virtual Threads & Structured Concurrency | 15-18 | `c2-unit15/` … `c2-unit18/` |
| 5 · Values, Contracts & Text | 19-24 | `c2-unit19/` … `c2-unit24/` |
| 6 · I/O, NIO & Networking | 25-30 | `c2-unit25/` … `c2-unit30/` |
| 7 · Modules & Packaging | 31-33 | `c2-unit31/` … `c2-unit33/` |
| 8 · JDBC + SQL | 34-38 | `c2-unit34/` … `c2-unit38/` |
| 9 · Reflection, Annotations, Gatherers & Capstone | 39-44 | `c2-unit39/` … `c2-unit44/` + `c2-capstone/` |

| Unit | Topic | Folder |
|---|---|---|
| 01 | Stack vs Heap: Where Your Objects Actually Live | `c2-unit01/` |
| 02 | Heap Limits: -Xmx, OutOfMemoryError and Heap Dumps | `c2-unit02/` |
| 03 | Garbage Collection: Reachability, G1 and the System.gc() Hint | `c2-unit03/` |
| 04 | Reference Types: Strong, Soft, Weak and WeakHashMap | `c2-unit04/` |
| 05 | JIT and Escape Analysis: Why Small Objects Can Be Free | `c2-unit05/` |
| 06 | Type Erasure: What the Compiler Really Sees | `c2-unit06/` |
| 07 | Generic Classes and Interfaces: Repository&lt;T, ID&gt; | `c2-unit07/` |
| 08 | Bounded Types: T extends Comparable&lt;T&gt; | `c2-unit08/` |
| 09 | Wildcards: ? extends, ? super and PECS | `c2-unit09/` |
| 10 | Generic Methods, Type Inference and Class&lt;T&gt; Tokens | `c2-unit10/` |
| 11 | Threads: Two Cooks in One Kitchen | `c2-unit11/` |
| 12 | Race Conditions, synchronized and the Memory Model | `c2-unit12/` |
| 13 | Executors, Thread Pools and Future | `c2-unit13/` |
| 14 | Locks, Atomics and Concurrent Collections | `c2-unit14/` |
| 15 | Virtual Threads: A Million Waiters | `c2-unit15/` |
| 16 | CompletableFuture: Composing Async Work | `c2-unit16/` |
| 17 | Structured Concurrency and Scoped Values | `c2-unit17/` |
| 18 | TiffinBox Order Queue: Producers, Consumers, BlockingQueue | `c2-unit18/` |
| 19 | Contracts: equals, hashCode and the Key That Vanished | `c2-unit19/` |
| 20 | Immutability and the Defensive Copy You Forgot | `c2-unit20/` |
| 21 | Money, Overflow and the Bill That Was Wrong | `c2-unit21/` |
| 22 | Strings Under the Hood: Concat, Interning, Unicode | `c2-unit22/` |
| 23 | Collections Beyond List and Map: Deque, PriorityQueue, EnumMap | `c2-unit23/` |
| 24 | Class Loading: How a .class Becomes a Class | `c2-unit24/` |
| 25 | Byte and Character Streams: InputStream, Reader, Buffers | `c2-unit25/` |
| 26 | NIO.2 Deep-Dive: walk, WatchService and Channels | `c2-unit26/` |
| 27 | Sockets: A TCP Order Line for TiffinBox | `c2-unit27/` |
| 28 | HttpClient: Calling APIs from Java | `c2-unit28/` |
| 29 | JSON Without Spring: Jackson via Maven | `c2-unit29/` |
| 30 | A Tiny HTTP Server: jdk.httpserver on Virtual Threads | `c2-unit30/` |
| 31 | The Module System: module-info.java Explained | `c2-unit31/` |
| 32 | Modules in Practice: exports, requires, ServiceLoader | `c2-unit32/` |
| 33 | jlink and jpackage: Ship TiffinBox as a Runtime Image | `c2-unit33/` |
| 34 | SQL in 15 Minutes: TiffinBox Tables in H2 | `c2-unit34/` |
| 35 | JDBC: Connect, Query, Map Rows to Records | `c2-unit35/` |
| 36 | Transactions, Savepoints and Batches | `c2-unit36/` |
| 37 | Connection Pools: close() That Gives It Back | `c2-unit37/` |
| 38 | TiffinBox on a Real Database: The JDBC Repository | `c2-unit38/` |
| 39 | Reflection: Inspecting Classes at Run Time | `c2-unit39/` |
| 40 | Annotations: Define, Read and Process Them | `c2-unit40/` |
| 41 | Stream Gatherers: Custom Pipeline Steps | `c2-unit41/` |
| 42 | Capstone: The TiffinBox Server, End to End | `c2-capstone/` |
| 43 | Watching It Run: JFR, jcmd and jshell | `c2-unit43/` |
| 44 | What's Next: Build & Test Like a Pro, Then Spring | `c2-unit44/` |

**Unit 42 has no `c2-unit42/` folder on purpose** — its code *is* `c2-capstone/`, the service the
whole course assembles. Unit 43 adds no new code either: every command in it points at that same
build.

Many units need JVM flags — `-Xmx16m`, `--enable-preview`, `-Djdk.virtualThreadScheduler.parallelism=1`
and friends. **Each folder's README has the exact command and the real output**, and files that fail
on purpose are labelled with the error they print.

Course 2 needs **JDK 25** (compact source files, JEP 512; `StructuredTaskScope` preview, JEP 505),
plus Apache Maven 3.9.x for units 29, 30, 34-38 and the capstone.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25   # or wherever your JDK 25 lives
export PATH="$JAVA_HOME/bin:$PATH"
./verify_course2.sh                # runs every c2-* command and prints PASS/FAIL
./verify_course2.sh 09 14          # just those units
./verify_course2.sh capstone       # just the capstone (that is unit 42's code)
SKIP_SLOW=1 ./verify_course2.sh    # skip every demo that is slow on purpose
```

`export JAVA_HOME` is not decoration. A default shell on this Mac hands Maven **JDK 26**, and the
capstone's `--enable-preview` build then fails with `invalid source release 25`. The script exports
it for every `mvn` and `java` it runs, and warns if the JDK is older than 25.

**What makes this repo runnable rather than a code dump: `verify_course1.sh` and `verify_course2.sh`
actually run every command the READMEs give a viewer** — all 44 Course 2 units and the capstone —
assert the real output, assert that the break-it-on-purpose files fail with the *right* error text,
time-box every command, check each port is free before use and kill by PID after, and delete every
`target/`, `out/`, `.class`, `.db`, `.jfr`, thread dump, jlink image and jpackage bundle the examples
create. Either script exits non-zero if anything is off.

Units that start servers (27, 28, 30, 42, 43) each own one port at a time — 8123, 8234/8456, 8345,
18425 and 18543 — and the script asserts the port is free again afterwards. `SKIP_SLOW=1` skips the
~50 s virtual-thread pool run, the deadlock demo, unit 25's 50 MB four-way read, unit 33's `jpackage`
bundle and unit 43's `StackChunks` recordings plus the full `watch.sh` cycle. The `jpackage --type dmg`
build is always skipped — it takes minutes and shows nothing the app-image does not.

Videos publish a few per day on the channel. Roadmap: Core Java → Spring Framework → Spring Boot → JPA → REST → Security → … → Spring AI.

— Vivek Singh · Prompt Vidya AI: https://www.youtube.com/@PromptVidyaAI

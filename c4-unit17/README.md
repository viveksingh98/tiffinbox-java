# Unit 17 — Resources and the ResourceLoader

Course 4 · Section 3 · *Configuration and Environment*.
**Verified on JDK 25.0.4.1**, Apache Maven 3.9.16, Spring Framework 7.0.9, macOS 27.0.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" compile
mvn -q -Dmaven.repo.local="$PWD/.m2-demo" -Dmdep.outputFile=cp.txt dependency:build-classpath
CP="target/classes:$(cat cp.txt)"
```

`./receipts.sh` regenerates everything, including the jar check and a teardown check.

## The same menu, in three places, through one API

```
java -cp "$CP" com.tiffinbox.ThreePlaces
```

`.r-three.out` · md5 `dca2c5e03d9098b8b33f49cf53ff4ac3` · exit 0 · 3 of 3.

```
  classpath:  class path resource [menu.csv]                      md5 5a758f068bfd2e5a5f1df63e49c5d26d
  file:       URL [file:<tmp>/tiffinbox-menu.csv]                 md5 5a758f068bfd2e5a5f1df63e49c5d26d
  http:       URL [http://127.0.0.1:<port>/menu.csv]              md5 5a758f068bfd2e5a5f1df63e49c5d26d
locations=3  identical bytes=3
```

**Three prefixes, one `ResourceLoader`** — not three libraries and not three branches in your code.
`getDescription()` is printed so you can see *which* one answered, and the bytes are **hashed**
rather than eyeballed, because three panels that look alike are not evidence that they are alike.
The program exits **2** if the three ever stop matching.

**The `http:` case is a loopback server and nothing leaves this machine.** It binds
`InetAddress.getLoopbackAddress()` and it is the `jdk.httpserver` you built in Course 2. The port is
chosen by the OS and masked in the output, along with the temp path — those are the two things in
this capture that are not properties of the code, which is why it hashes at all.

**Started by `main`, not by a `@Bean`, and that is a decision with a reason.** A server bean that
fails to bind turns a *resources* lesson into a *lifecycle* debugging session, and unit 08 is where
lifecycle lives. A real application would make it a bean; unit 08 already showed what that costs.
It is stopped in a `finally`, so a second run does not meet a port the first one kept.

## The break — it works in the IDE and fails from the jar

`specials.csv` sits in `src/main/java/com/tiffinbox/`, right next to the class that reads it, which
is exactly where it feels like it belongs.

```
java -cp "src/main/java:$CP" com.tiffinbox.WorksInTheIde   # .r-ide.out       023263350e64cfcf46e1eb031ce56c82  exit 0
java -cp "$CP"               com.tiffinbox.WorksInTheIde   # .r-artefact.out  0b5aedf739de0913f7989555d6582713  exit 1
```

| class path | `exists()` | then what |
|---|---|---|
| source root included (what many IDEs give you) | `true` | 34 bytes, exit 0 |
| `target/classes` only (what you ship) | `false` | `FileNotFoundException`, exit **1** |

`src/main/java` is a **source** directory and `src/main/resources` is a **resource** directory, and
only the second is copied into `target/classes` and therefore into the jar. The file is in your
repository, in your editor, in your diff — and not in the artefact.

The capture checks `exists()` **and then opens it anyway**, because checking `exists()` is the half
people do and opening it regardless is the half that throws.

**Course 3 gave you the one line that finds this:**

```
jar tf target/c4-unit17-1.0.0.jar | grep csv
```

```
  in the jar:  specials.csv=0  menu.csv=1
```

Derived off the built jar by `receipts.sh`, not typed.

## Files

| file | what it is |
|---|---|
| `ThreePlaces.java` | three prefixes, one loader, hashed bytes, loopback server with teardown |
| `WorksInTheIde.java` | the break |
| `src/main/resources/menu.csv` | ships |
| `src/main/java/com/tiffinbox/specials.csv` | **does not ship** — that is the lesson |
| `receipts.sh` | captures, the jar check, and a listener check |
| `exercise/` | a menu that loads everywhere except where it matters |

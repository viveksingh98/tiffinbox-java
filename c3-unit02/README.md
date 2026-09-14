# c3-unit02 — The Lifecycle and the Reactor

A three-module TiffinBox reactor: `tiffinbox-core` → `tiffinbox-kitchen` → `tiffinbox-web`.
Maven **3.9.16**, **JDK 25.0.4.1**. Run everything from this directory.
**The quotes around `-Dmaven.repo.local=` are not optional** — this tree's path contains a space, and an
unquoted path splits: Maven reads the tail as a goal and answers `Unknown lifecycle phase "Content/…"`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25 && export PATH="$JAVA_HOME/bin:$PATH"
mvn -B clean package -Dmaven.repo.local="$PWD/.m2-demo"     # 4 modules, BUILD SUCCESS, exit 0
./verify-selectors.sh                                        # the -pl / -am / -amd table, 6 rows
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar       # the three jars, actually running
mvn -o -B verify -Dmaven.repo.local="$PWD/.m2-demo"          # offline receipt: BUILD SUCCESS, exit 0
```

Real output of those four commands, captured on this Mac (3 runs each, byte-identical):

```
[INFO] Reactor Build Order:
[INFO] TiffinBox (reactor demo)                                           [pom]
[INFO] TiffinBox Core                                                     [jar]
[INFO] TiffinBox Kitchen                                                  [jar]
[INFO] TiffinBox Web                                                      [jar]
[INFO] BUILD SUCCESS
```
```
<no selector>                 modules=4  exit=0  BUILD SUCCESS
-pl tiffinbox-core            modules=0  exit=0  BUILD SUCCESS
-pl tiffinbox-kitchen         modules=0  exit=1  BUILD FAILURE
-pl tiffinbox-kitchen -am     modules=3  exit=0  BUILD SUCCESS
-pl tiffinbox-core -amd       modules=3  exit=0  BUILD SUCCESS
-pl tiffinbox-web -amd        modules=0  exit=1  BUILD FAILURE
```
```
Meera  VEG       120
Ravi   NON_VEG   180
Asha   VEGAN      75
trays on the rail : 3
daily total       : 375
```
```
[INFO] BUILD SUCCESS        (mvn -o -B verify, all four modules, exit 0)
```

`modules=` counts the rows of the **Reactor Summary**, not the word `BUILD SUCCESS`. A single-module build
prints no Reactor Summary at all, which is why the two one-module rows read `modules=0`: *the absence of the
block is the count.* Never read `BUILD SUCCESS` as evidence that a selector did what you meant.

`.m2-demo/` is an isolated local repository created on the first run so that `-pl` without `-am` genuinely
cannot find its sibling. It is not committed. Your real `~/.m2` is never written to by anything here —
nothing in this project runs `install`.

Notes
- `export JAVA_HOME=…openjdk@25` is line 1 of every command above. Without it a bare `java` on this Mac is
  **23.0.1**, and `java -jar tiffinbox-web/…jar` dies with
  `UnsupportedClassVersionError … class file version 69.0` (verified, exit 1, 3/3).
- `breaks/cycle/` — the one-dependency edit that makes the reactor a loop.
- `breaks/stale-sibling/` — `-pl` without `-am` printing `BUILD SUCCESS` against last week's jar.
- `exercise/` — one flag, one end state.

# c3-unit04 — Plugins: Bind Your Own Goal

**Five commands, and the real output of each.** `export JAVA_HOME=/opt/homebrew/opt/openjdk@25` is line 1 of
every one of them: units 01, 04 and 05 compile with `--enable-preview`, and a bare `mvn` on this Mac resolves
**Java 26.0.2.1**, which refuses `--release 25 --enable-preview`. Verified on **JDK 25.0.4.1 · Apache Maven
3.9.16 · macOS 27.0, Apple silicon**, 2026-09-14. Every capture below was taken **3 times and is byte-identical
3/3**; its md5 and exit code are beside it.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25 && cd enforcer && mvn -B clean package | grep '^\[ERROR\]' | head -6   # 1
export JAVA_HOME=/opt/homebrew/opt/openjdk@25 && cd enforcer && mvn -B -f pom-upgraded.xml clean package | grep '^\[ERROR\]' | head -6   # 2
export JAVA_HOME=/opt/homebrew/opt/openjdk@25 && cd enforcer && mvn -B -f pom-pinned.xml clean package exec:exec   # 3
export JAVA_HOME=/opt/homebrew/opt/openjdk@25 && cd proc && mvn -B clean install && cd menu-app && mvn -B exec:exec   # 4
export JAVA_HOME=/opt/homebrew/opt/openjdk@25 && cd wrongphase && mvn -B -f pom-wrongphase.xml clean package && ls target/lib   # 5
```

```
1  [ERROR] Failed to execute goal org.apache.maven.plugins:maven-enforcer-plugin:3.6.3:enforce (no-known-bad-jars) on project c3-unit04-enforcer:
   [ERROR] Rule 0: org.apache.maven.enforcer.rules.dependency.BannedDependencies failed with message:      exit 1  md5 7a725dfb53bec85d822f5f0cdab68f3e
   [ERROR] snakeyaml 1.31 is CVE-2022-1471. Exclude it and declare a current one.
   [ERROR] com.tiffinbox:c3-unit04-enforcer:jar:1.0.0
   [ERROR]    com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:jar:2.13.5
   [ERROR]       org.yaml:snakeyaml:jar:1.31 <--- banned via the exclude/include list

2  ... first 4 of the 6 lines are byte-identical to block 1 and elided; only these two differ ...
   [ERROR]    com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:jar:2.22.2   exit 1  md5 fb2d7cadae32dec20e8a45c4680f5b98
   [ERROR]       org.yaml:snakeyaml:jar:2.5 <--- banned via the exclude/include list
   (the hash is over all six lines, as printed by the filter above; the upgrade is clean, and
    a bare version in an enforcer pattern is the range [1.31,) so it bans 2.5 too)

3  [INFO] BUILD SUCCESS                                                    exit 0  md5 51cd33e10da4fc4c8df4046da8579a11
   routes : 2                                                              exit 0  md5 969d38271734d46f18df708776b6a1aa
     North Block -> 14 stops
     River Lane -> 9 stops

4  generated-sources/annotations/com/tiffinbox/MenuCatalog.java             exit 0  md5 e314f0b342617be3999f4a34d3558c6b
   GardenBowl.class  GrilledWrap.class  Kitchen.class  MenuCatalog.class  SoupOfTheDay.class
   catalog size : 3                                                        exit 0  md5 c2c4a3281d7c68e512d9a4e667f5ba19
     Garden Bowl @ 120
     Grilled Wrap @ 150
     Soup of the Day @ 100

5  [INFO] BUILD SUCCESS   (7 goal lines, not 8)                            exit 0  md5 b18e2d890507eebd7719ad2b43bf6b08
   ls: target/lib: No such file or directory
   Class-Path: lib/h2-2.5.250.jar lib/jackson-databind-2.22.2.jar lib/jacks
    on-annotations-2.22.jar lib/jackson-core-2.22.2.jar
```

---

## What is in here

| Folder | What it is |
|---|---|
| `enforcer/` | the YAML route reader from the dependency unit, with `maven-enforcer-plugin:3.6.3` bound to `validate` |
| `proc/` | a two-module reactor: `menu-processor` (the annotation + the processor) and `menu-app` (the dishes) |
| `wrongphase/` | the Core Java II capstone, with `copy-libs` at the right phase and at the wrong one, side by side |
| `exercise/` | the capstone shipped **broken** — `copy-libs` bound to `install` — plus `solution/pom.xml` |

### `enforcer/` — six poms, six verified outcomes

Every variant is the same project; only the two lines named below differ. All 3/3 byte-identical.

| pom | the YAML library | the rule pattern | result |
|---|---|---|---|
| `pom.xml` | 2.13.5 → snakeyaml **1.31** | `org.yaml:snakeyaml:1.31` | **FAILURE**, exit 1, path trace through the YAML library |
| `pom-upgraded.xml` | **2.22.2** → snakeyaml **2.5** | `org.yaml:snakeyaml:1.31` | **FAILURE**, exit 1 — *the over-ban* |
| `pom-pinned.xml` | 2.22.2 → snakeyaml 2.5 | `org.yaml:snakeyaml:[1.31]` | **SUCCESS**, exit 0, and `exec:exec` prints the routes |
| `pom-pinned-unfixed.xml` | 2.13.5 → snakeyaml 1.31 | `org.yaml:snakeyaml:[1.31]` | **FAILURE**, exit 1 — the bracket still catches the real thing |
| `pom-excluded.xml` | 2.13.5 + `<exclusions>` + hand-declared snakeyaml 2.5 | `org.yaml:snakeyaml:[1.31]` | **SUCCESS**, exit 0 — **and the program dies at run time**, exit 1, `NoSuchMethodError: org.yaml.snakeyaml.parser.ParserImpl.<init>(StreamReader)` (md5 `415d8b232bcdb0ccbf032b84bc307935`). The 2.13.5 module was compiled against SnakeYAML 1.x. Upgrade the library, do not bolt a new jar under the old one. |
| `pom-warnonly.xml` | 2.13.5 → snakeyaml 1.31 | `<level>WARN</level>` inside the rule | **SUCCESS**, exit 0. Only the **header line** is prefixed — `[WARNING] Rule 0: …BannedDependencies warned with message:` — and the message sentence and the three-line path trace under it print **unprefixed**, where the failing run prefixes *every* one of those lines `[ERROR]`. The whole build therefore holds exactly **one** `^\[WARNING\]` line and **zero** `^\[ERROR\]` lines (md5 `629ec74c817358581d7919faaf22dab0`) |

Side by side, the same rule failing and warning — note where the prefix stops:

```
$ mvn -B -f pom.xml clean package                  # <level>ERROR</level>, the default
[ERROR] Rule 0: org.apache.maven.enforcer.rules.dependency.BannedDependencies failed with message:
[ERROR] snakeyaml 1.31 is CVE-2022-1471. Exclude it and declare a current one.
[ERROR] com.tiffinbox:c3-unit04-enforcer:jar:1.0.0
[ERROR]    com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:jar:2.13.5
[ERROR]       org.yaml:snakeyaml:jar:1.31 <--- banned via the exclude/include list

$ mvn -B -f pom-warnonly.xml clean package         # <level>WARN</level>
[WARNING] Rule 0: org.apache.maven.enforcer.rules.dependency.BannedDependencies warned with message:
snakeyaml 1.31 is CVE-2022-1471. Exclude it and declare a current one.
com.tiffinbox:c3-unit04-enforcer:jar:1.0.0
   com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:jar:2.13.5
      org.yaml:snakeyaml:jar:1.31 <--- banned via the exclude/include list
```

`grep -c '^\[WARNING\]'` over that whole build prints **1** — the rule fired once and told you five lines'
worth, four of which no line-prefix filter will ever see. If you count warn-only rules by grepping for the
prefix, you count the rules, never what they said.

`<fail>false</fail>` is a parameter of the **`enforce` goal**, not of a rule: put it beside `<rules>` and every
rule in that execution warns instead of failing. Inside `<bannedDependencies>` it is a hard error —
`ComponentConfigurationException: Cannot find 'fail' in class …BannedDependencies`. Measured, both ways.

### `proc/` — the annotation processor

`menu-processor` is three files: `MenuItem` (a `SOURCE`-retention annotation), `MenuCatalogProcessor`, and
`src/main/resources/META-INF/services/javax.annotation.processing.Processor` naming the processor class. Its
own compile sets `<proc>none</proc>` so it does not try to run itself while it is being compiled.

`menu-app` wires it in with six lines of `<annotationProcessorPaths>`. **The processor must be installed to be
resolvable**, so build the reactor with `install`, not `package`. `Kitchen` looks `MenuCatalog` up by name
rather than importing it — that is the only reason the mis-wiring below is silent.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
cd proc/menu-app && mvn -B -f pom-classpath.xml clean package        # the processor on the ordinary classpath
```

```
[INFO] BUILD SUCCESS        exit 0   md5 4484c5fa510526a3157b064b504159a2
warnings: 0
gen files: 0
GardenBowl.class  GrilledWrap.class  Kitchen.class  SoupOfTheDay.class      <- four, not five
```

```
catalog size : no MenuCatalog was generated
```

Same source, same JDK, green build, zero warnings, and the processor never ran. `pom-classpath.xml` differs
from `pom.xml` by exactly one deleted `<annotationProcessorPaths>` block.

### Isolated local repository

Everything above was verified with a scratch repository **inside this folder**, so the author's own `~/.m2`
was never the subject. Anchor it once, from `c3-unit04/`: this folder has no `pom.xml` of its own, so every
`mvn` runs from a demo folder below it, and anchoring `$M2` *before* the `cd` keeps all five commands in one
scratch repository instead of one per demo. Then add the same flag to each command above.

```bash
M2="$PWD/.m2-unit04"                                        # once, from c3-unit04/
cd proc && mvn -B "-Dmaven.repo.local=$M2" clean install    # command 4, with the flag
```

**The quotes are not decoration.** This tree lives under a directory whose name contains a space
(`Youtube Content`), and an unquoted `-Dmaven.repo.local=` is split by the shell, after which Maven reads the
tail as a goal name and the build fails for a reason that has nothing to do with the lesson.

### Offline receipt

After one warm build, with `$M2` still set from above. **Every line below keeps the flag** — that is
what makes it a receipt for `$M2` and not for your real repository. Drop `-Dmaven.repo.local="$M2"` and
the same four commands read, and fill, your real `~/.m2` instead:

```
enforcer  (pom-pinned.xml)   mvn -o -B "-Dmaven.repo.local=$M2" verify  ->  BUILD SUCCESS   exit 0
proc      (reactor)          mvn -o -B "-Dmaven.repo.local=$M2" verify  ->  BUILD SUCCESS   exit 0
wrongphase (pom.xml)         mvn -o -B "-Dmaven.repo.local=$M2" verify  ->  BUILD SUCCESS   exit 0
wrongphase (pom-wrongphase)  mvn -o -B "-Dmaven.repo.local=$M2" verify  ->  BUILD SUCCESS   exit 0
```

### Break it on purpose — `wrongphase/`

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
cd wrongphase
mvn -B clean package                      | grep -c '^\[INFO\] --- '   # 8
mvn -B -f pom-wrongphase.xml clean package | grep -c '^\[INFO\] --- '  # 7
```

One word changed — `prepare-package` became `install` — and the goal is not late, it is **absent**, because
`install` comes after `package` and you asked for `package`. `BUILD SUCCESS` either way. Count the goal lines.

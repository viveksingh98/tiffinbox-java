# c3-unit10 — Maven or Gradle: the same project, both tools

One directory. One set of sources. **Two complete builds**, side by side, so that every number below
comes from the same project on the same machine in the same session.

```
c3-unit10/
  pom.xml · tiffinbox-core/pom.xml · tiffinbox-web/pom.xml        the Maven build
  settings.gradle.kts · build.gradle.kts · gradle/libs.versions.toml
  tiffinbox-core/build.gradle.kts · tiffinbox-web/build.gradle.kts the Gradle build
  tiffinbox-core/src · tiffinbox-web/src                           the sources, shared by both
  gradlew · gradlew.bat · gradle/wrapper/     the Gradle wrapper, pinned to 9.7.1 by sha256
  mvnw · mvnw.cmd · .mvn/wrapper/             the Maven wrapper,  pinned to 3.9.16
  exercise/ · receipts.sh
```

The three POMs and the seven Java files are **byte-identical** to [`../c3-tiffinbox/`](../c3-tiffinbox/):

```bash
md5 -q pom.xml tiffinbox-core/pom.xml tiffinbox-web/pom.xml
```

```
4303ad02dc14f99ac2213baabb3c8999
2bf4a5b3bd375cbbdbb148692cc5a7e5
f8736191a4900ae1a76d1fcdf744c4ab
```

Run the same three lines in `../c3-tiffinbox/` and you get the same three hashes. **That is the point
of this directory:** a comparison between two tools is worth nothing if the two sides are different
projects.

## Every hash on this page is regenerable

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh            # re-runs every quoted capture and prints its md5
./receipts.sh counts     # just one of them
```

Two blocks need something extra and say so in the script: `drift` needs a second Gradle
distribution (`OLD_GRADLE=/path/to/gradle-8.5/bin/gradle ./receipts.sh drift`) and `shapin`
downloads into a throw-away Gradle home.

## Build it twice

```bash
export GRADLE_USER_HOME="$PWD/.gradle-home"
mvn -B -Dmaven.repo.local="$PWD/.m2-demo" clean package
./gradlew clean build
```

Five jars land in `tiffinbox-web/target/lib` and five in `tiffinbox-web/build/libs/lib` — the same
five names. Both jars are runnable and both produce the same bytes of output:

```bash
cd tiffinbox-web
java -Djava.util.logging.config.file=logging.properties -jar target/tiffinbox-web-1.0.0.jar
java -Djava.util.logging.config.file=logging.properties -jar build/libs/tiffinbox-web-1.0.0.jar
```

```
orders cooked:  120
kitchen value:  24300
routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
TiffinBox listening on http://127.0.0.1:18425
```

The server, seven HTTP calls and a shutdown, run three times from each jar — **six captures, one
hash**: `md5 5da5f0f66da7105f322537b77751a0ea`. `./receipts.sh probe` prints it for both jars.

And the class files themselves:

```bash
for j in tiffinbox-web/target/tiffinbox-web-1.0.0.jar tiffinbox-web/build/libs/tiffinbox-web-1.0.0.jar; do
  for c in $(unzip -Z1 "$j" | grep '\.class$' | sort); do unzip -p "$j" "$c" | md5 -q; done | md5
done
```

```
cb46ca054c40d14146a9e8579b4b1ff3
cb46ca054c40d14146a9e8579b4b1ff3
```

The same command over `tiffinbox-core-1.0.0.jar` gives `8bd6fdb961f65dddc82a242e5472059c` from both
tools here **and** from the standalone project in [`../c3-unit07/`](../c3-unit07/) and the two-module
one in [`../c3-unit09/`](../c3-unit09/) — one class-content hash, five jars, two tools, two layouts.

The jars are not byte-identical: Maven adds five `META-INF/maven/…` entries and three manifest lines.
`./receipts.sh stat` → `md5 4a6c095942d29eaacb6f0f74ed330b78` re-runs the incrementality proof (it prints the
comparison, not the raw mtimes, because an epoch second is this machine on this morning).
`./receipts.sh samejars` → `md5 d9259d97c5931d126696170cc5b4f62a` prints exactly what differs, and `samejars-cls` prints the class-file hash `cb46ca054c40d14146a9e8579b4b1ff3` once for each jar — the number the slides quote as this unit's headline.

## The comparison

Same project, same machine, one session. Counts first.

| | **Maven 3.9.16** | **Gradle 9.7.1** |
|---|---|---|
| work units named in a clean build | **16** goals | **25** tasks |
| work units named in a no-change build | **13** goals | **23** tasks |
| of those, ones that said out loud they had nothing to do | **2** — `Nothing to compile` | **23** — 15 `UP-TO-DATE` + 8 `NO-SOURCE` |
| a one-line summary of what happened | *none* | `5 actionable tasks: 5 up-to-date` |
| configuration files | 3 | 5 |
| configuration lines, raw | **183** | **59** |
| configuration lines, comments stripped and blanks removed | **155** | **43** |
| build tool version pinned in the repository | `mvnw` → 3.9.16 | `gradlew` → 9.7.1 **+ sha256** |

```bash
./receipts.sh counts      # md5 654f4b2d5aadd07d2109663824de2fac
./receipts.sh states      # md5 ed2cd6e548e41691841e8a353ccc4b11
./receipts.sh conflines   # md5 53c396fdc4aa99424b99fa7e9969cb72
```

**Read the third row carefully, because it is the one that decides.** Both tools are incremental:
Maven's compiler plugin prints `Nothing to compile - all classes are up to date.`, its jar plugin does
not rewrite an unchanged jar, and `copy-dependencies` does not re-copy. Measured — the file
modification times do not move. The difference is not *whether* work is skipped. It is that Gradle
labels **every** unit of work with a word that says why, and Maven labels two of thirteen, leaving
you to infer the rest.

The line-count rows are *not* a verdict either. XML needs a closing tag for every element, which is
most of the gap; the rest is that `java-library` supplies defaults that the POM writes out. A shorter
file is easier to read and harder to grep for across a hundred repositories. Both of those are true.

## Timings — and read the flags before the numbers

**8-core, 16 GB, Apple silicon, macOS 27.0, JDK 25.0.4.1.** Measured on Vivek's Mac; yours will differ.
**N = 5 measured runs after 2 discarded warm-up runs**, one session, both tools offline
(`mvn -o`, `./gradlew --offline`), Gradle with `--no-build-cache`, and the Gradle daemon state named
on every row.

| Configuration | ms, 5 runs |
|---|---|
| `mvn -o -B clean package` | 2383 · 2369 · 2377 · 2386 · 2380 |
| `mvn -o -B package` (nothing changed) | 1857 · 1835 · 1867 · 1844 · 1856 |
| `./gradlew --offline --no-build-cache clean build` — **daemon** | 654 · 645 · 626 · 640 · 590 |
| `./gradlew --offline --no-build-cache build` — **daemon**, nothing changed | 492 · 493 · 479 · 484 · 474 |
| `./gradlew --offline --no-build-cache --no-daemon clean build` | 3849 · 3836 · 3822 · 3853 · 3851 |
| `./gradlew --offline --no-build-cache --no-daemon build` — nothing changed | 3237 · 3209 · 3251 · 3267 · 3279 |

**With the daemon, Gradle's build is faster than Maven's here. Without it, Gradle's is slower.** The
daemon is a JVM Gradle keeps alive between builds so the next one starts warm; it is on by default, it
is the reason for the numbers in rows three and four, and `./gradlew --stop` is how you get rid of it.
Maven has no daemon on by default. (`mvnd` — the Maven Daemon — is a separate project and is not used
anywhere in this course; naming it is not the same as measuring it, and this table only contains
things that were measured.)

Nothing in that table is a property of either tool in the abstract. It is this project — two Java
modules, seven source files, two external dependencies — on one machine, with those flags.

## The wrapper, for both

```bash
./receipts.sh wrappers    # md5 d7ed841f844e6957e02f398c7892626e
```

```
$ grep -E "distributionUrl|Sha256" gradle/wrapper/gradle-wrapper.properties
distributionSha256Sum=acd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a
distributionUrl=https\://services.gradle.org/distributions/gradle-9.7.1-bin.zip
$ grep distributionUrl .mvn/wrapper/maven-wrapper.properties
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.16/apache-maven-3.9.16-bin.zip

$ shasum -a 256 gradle/wrapper/gradle-wrapper.jar
7a9ce74cff467ca1bf60a4fcd9f05185acceda4d0f382434d393e17864262c5d  gradle/wrapper/gradle-wrapper.jar
```

`mvnw` was generated with `mvn wrapper:wrapper` and fetches Maven 3.9.16 on first use:

```bash
MAVEN_USER_HOME="$PWD/.m2-demo" ./mvnw -v | head -3
```

```
Apache Maven 3.9.16 (2bdd9fddda4b155ebf8000e807eb73fd829a51d5)
Maven home: …/c3-unit10/.m2-demo/wrapper/dists/apache-maven-3.9.16/56ba1f9f
Java version: 25.0.4.1, vendor: Homebrew, runtime: /opt/homebrew/Cellar/openjdk@25/…
```

`MAVEN_USER_HOME` is there so the download lands beside the project instead of in `~/.m2`.
*Receipt:* `./receipts.sh mvnw` → `md5 da136ace8f0e986dae59e819f4e7e72b`. **The two `…` above are the
only edit on this page to a quoted capture**: lines 2 and 3 print full absolute paths, and the hash is
over the unshortened output, so run the command to see them.

**Gradle's wrapper pins a checksum as well as a version; Maven's pins a URL.** That difference is real
and it is not decorative:

```bash
sed -i '' 's/^distributionSha256Sum=acd/distributionSha256Sum=bcd/' gradle/wrapper/gradle-wrapper.properties
rm -rf .gh-fresh && GRADLE_USER_HOME="$PWD/.gh-fresh" ./gradlew --version
```

```
Exception in thread "main" java.lang.RuntimeException: Verification of Gradle distribution failed!

Your Gradle distribution may have been tampered with.
Confirm that the 'distributionSha256Sum' property in your gradle-wrapper.properties file is correct and you are downloading the wrapper from a trusted source.

Distribution Url: https://services.gradle.org/distributions/gradle-9.7.1-bin.zip
Download Location: <your Gradle home>/wrapper/dists/gradle-9.7.1-bin/…/gradle-9.7.1-bin.zip
Expected checksum: 'bcd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a'
Actual checksum:   'acd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a'
Visit https://gradle.org/release-checksums/ to verify the checksums of official distributions. If your build uses a custom distribution, see with its provider.
```

*Receipt:* `./receipts.sh shapin` → `md5 6aef8d99a8bf0c0d133a081c60275364`, three runs. The script makes
that one-character edit, runs it against a fresh Gradle home, puts the file back and deletes the home;
the `Download Location:` line is masked before hashing because it names your own path.

**The check happens on download, not on every run.** A Gradle home that already holds an unpacked
9.7.1 will not notice a wrong pin at all — which is why the command above needs a fresh
`GRADLE_USER_HOME`, and why the pin protects the *next* machine rather than yours. Put the real value
back afterwards, or `git checkout gradle/wrapper/gradle-wrapper.properties`.

## The break: the same project, a machine with a different tool

`./gradlew` is 8 656 bytes of shell script. Typing `gradle` instead skips it and uses whatever is
installed. Here is that, with a real second distribution — Gradle 8.5, unpacked, on this same JDK 25:

```
$ gradle --version | grep ^Gradle        # the gradle that is on this machine's PATH
Gradle 8.5
$ gradle build                           # ...so this is what the project gets
* What went wrong:
25.0.4.1

... 4 JDK-25 native-access WARNING lines elided ...

$ ./gradlew --version | grep ^Gradle     # the gradle the PROJECT names
Gradle 9.7.1
$ ./gradlew build
BUILD SUCCESSFUL
5 actionable tasks: 5 up-to-date
```

**The entire "what went wrong" is a version number.** Gradle 8.5 predates JDK 25 and cannot parse its
four-part version string, so it fails with the string as the message and nothing else. That is the
shape of a tool-version mismatch in the wild: not a helpful error, a baffling one. The next line of
the same session, in the same directory, with `./gradlew`, works.

*Receipt:* `OLD_GRADLE=/path/to/gradle-8.5/bin/gradle ./receipts.sh drift` →
`md5 db953c25b49d6b582acbac740ec956fa`, three runs. Any older Gradle reproduces the shape of this;
the exact message depends on which one. Get one from `https://services.gradle.org/distributions/`.

## Clean up

```bash
./gradlew --stop
rm -rf */build */target .gradle .gradle-home .m2-demo .gh-fresh .gh-old
```

## Verified

**JDK 25.0.4.1**, **Gradle 9.7.1** through the committed wrapper, **Apache Maven 3.9.16**, macOS 27.0 on
an 8-core 16 GB Apple-silicon Mac, **2026-09-15**. Every capture on this page was run three times and
was byte-identical each time; every hash is produced by `receipts.sh` and by nothing else. Every
duration is a range across five runs with two warm-up runs discarded and every flag named. Nothing was
installed into `~/.m2` or `~/.gradle`.

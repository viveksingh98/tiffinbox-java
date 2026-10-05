# Your turn — half a gigabyte, and three quarters of it for Java

In the lesson, every container ran with `-m 512m`: a memory limit of half a gigabyte. Java read that limit and kept a
quarter of it for its heap — the memory it keeps its objects in. **Run the image with half a gigabyte of memory, read the
heap limit, then give Java three quarters of it.**

Run everything from this unit's folder (`c5-unit16/`), with its own `.m2-demo` (every Maven build is offline). The first two
commands build the lesson's image, `tiffinbox-docker:1.0.0`, from `after/` — the jar on your machine, then the image from
`after/Dockerfile`. The third runs Java in that image, not TiffinBox: `--entrypoint java` replaces the image's own command,
and `-XX:+PrintFlagsFinal -version` prints every setting Java chose, then stops. `grep -w` keeps the heap limit's line:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
docker build -q -t tiffinbox-docker:1.0.0 after
docker run --rm -m 512m --entrypoint java tiffinbox-docker:1.0.0 -XX:+PrintFlagsFinal -version | grep -w MaxHeapSize
```

`docker build -q` prints the new image's ID and nothing else. The last line prints `MaxHeapSize = 134217728`: 128 MiB, a
quarter of 512 MiB. (`java -version`'s three lines go to the terminal too: they are its standard error, which `grep` never
sees.)

**Your turn.** Start the same image with the same limit, and give Java three quarters of it. Java reads extra options from
an environment variable, `JAVA_TOOL_OPTIONS`; the option that sets the share is `-XX:MaxRAMPercentage`. Nothing in the image
changes: the Dockerfile bakes in no memory flag.

**Done** when the same line says `MaxHeapSize = 402653184` — 384 MiB, three quarters of 512 MiB — and Java's first line on
the terminal says it picked your option up. The measured answer, run exactly as written: `solution/SOLUTION.md`.

When you are done:

```bash
docker image rm tiffinbox-docker:1.0.0
```

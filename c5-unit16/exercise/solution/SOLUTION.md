# Solution — three quarters of the limit, from the environment

The same image and the same limit as `../README.md`; the option goes into `docker run`'s `-e`, as `JAVA_TOOL_OPTIONS`:

```bash
docker run --rm -m 512m -e JAVA_TOOL_OPTIONS=-XX:MaxRAMPercentage=75 --entrypoint java tiffinbox-docker:1.0.0 -XX:+PrintFlagsFinal -version | grep -w MaxHeapSize
```

**Measured.** `../README.md`'s first bash block, then the block above, then `../README.md`'s clean-up block, every line exactly as
written, in one clean shell (`env -i HOME=… PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin bash --noprofile --norc`), from
`c5-unit16/`, on 2026-10-05. One thing is masked here: the image IDs `docker build -q` and `docker image rm` printed. Java's
`-version` lines are its standard error, so they reach the terminal ahead of `grep`'s line.

```
$ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  (exit 0)
$ export PATH="$JAVA_HOME/bin:$PATH"
  (exit 0)
$ mvn -o -q -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
  (exit 0)
$ docker build -q -t tiffinbox-docker:1.0.0 after
[an image ID]
  (exit 0)
$ docker run --rm -m 512m --entrypoint java tiffinbox-docker:1.0.0 -XX:+PrintFlagsFinal -version | grep -w MaxHeapSize
openjdk version "25.0.4.1" 2026-08-18 LTS
OpenJDK Runtime Environment Temurin-25.0.4.1+1 (build 25.0.4.1+1-LTS)
OpenJDK 64-Bit Server VM Temurin-25.0.4.1+1 (build 25.0.4.1+1-LTS, mixed mode, sharing)
   size_t MaxHeapSize                              = 134217728                                 {product} {ergonomic}
  (exit 0)
$ docker run --rm -m 512m -e JAVA_TOOL_OPTIONS=-XX:MaxRAMPercentage=75 --entrypoint java tiffinbox-docker:1.0.0 -XX:+PrintFlagsFinal -version | grep -w MaxHeapSize
Picked up JAVA_TOOL_OPTIONS: -XX:MaxRAMPercentage=75
openjdk version "25.0.4.1" 2026-08-18 LTS
OpenJDK Runtime Environment Temurin-25.0.4.1+1 (build 25.0.4.1+1-LTS)
OpenJDK 64-Bit Server VM Temurin-25.0.4.1+1 (build 25.0.4.1+1-LTS, mixed mode, sharing)
   size_t MaxHeapSize                              = 402653184                                 {product} {ergonomic}
  (exit 0)
$ docker image rm tiffinbox-docker:1.0.0
Untagged: tiffinbox-docker:1.0.0
Deleted: [an image ID]
  (exit 0)
```

**Why.** Java reads the container's memory limit, half a gigabyte here, and by default lets its heap grow to a quarter of it:
`MaxRAMPercentage = 25`. `JAVA_TOOL_OPTIONS` is a variable every JVM reads for extra options — it says so on its first line,
`Picked up JAVA_TOOL_OPTIONS` — and `-XX:MaxRAMPercentage=75` sets the share to three quarters: 402,653,184 bytes, 384 MiB. The image
is the same; only the run changed, which is why the Dockerfile bakes in no memory flag. (TiffinBox's own JVM would read it
too — the image's entrypoint is `java` — not run here.)

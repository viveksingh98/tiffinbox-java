# Solution — which layer `tiffinbox-core` lands in

**`dependencies`** — and the copy that landed there is **not the one you changed**.

Run exactly as written in `../README.md`, every line of its bash block in order, in one clean shell (`env -i HOME=… PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin bash --noprofile --norc`), from `c5-unit14/`, on 2026-10-05 (re-run by BLUE the same day, after the README gained its fresh-clone note: the same
transcript, line for line):

```
$ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  (exit 0)
$ export PATH="$JAVA_HOME/bin:$PATH"
  (exit 0)
$ rm -rf .harness/mine && mkdir -p .harness && rsync -a --exclude target after/ .harness/mine/
  (exit 0)
$ mvn -o -q -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests install
  (exit 0)
$ perl -pi -e 's/must be 16 characters or more/must have 16 characters or more/' .harness/mine/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
  (exit 0)
$ mvn -o -q -B -f .harness/mine/tiffinbox-web/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
  (exit 0)
$ rm -rf .harness/mine-layers && java -Djarmode=tools -jar .harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --destination .harness/mine-layers
  (exit 0)
$ find .harness/mine-layers -name 'tiffinbox-core-*.jar'
.harness/mine-layers/dependencies/lib/tiffinbox-core-1.0.0.jar
  (exit 0)
$ unzip -p "$(find .harness/mine-layers -name 'tiffinbox-core-*.jar')" com/tiffinbox/TiffinBoxProperties.class | LC_ALL=C grep -aoE 'must [a-z]+ 16 characters'
must be 16 characters
  (exit 0)
```

**Why.** Built from the root, the reactor builds `tiffinbox-core` in the same run, and Boot's index lists it under
`application`, beside TiffinBox's own classes (`after/`'s jar: `- "application":` … `- "BOOT-INF/lib/tiffinbox-core-1.0.0.jar"`).
Built alone, `tiffinbox-web` is the whole reactor: `tiffinbox-core` is just another library, resolved from the local repository,
so Boot's index puts it with the other libraries — `- "dependencies":` now lists `BOOT-INF/lib/` whole, every jar in it — and
`extract --layers` writes it to `dependencies/lib/`.

**And the line you changed is not in it.** The module built alone took `tiffinbox-core` from the local repository, where the
`install` put it **before** the change: its class still says `must be 16 characters`. To package your change, build from the root
(`-f .harness/mine/pom.xml`, or `-pl tiffinbox-web -am`, which adds the module it needs to the reactor) — and then `tiffinbox-core`
is back in `application`. `receipts.sh` runs these same commands, read from the README (capture `exercise`, asserted:
`.harness/mine-layers/dependencies/lib/tiffinbox-core-1.0.0.jar`, `must be 16 characters`, and the changed line present once in
`.harness/mine`'s source).

Without the `install` (a fresh `.m2-demo`), the web module alone does not build at all, offline: `Cannot access central
(https://repo.maven.apache.org/maven2) in offline mode and the artifact com.tiffinbox:tiffinbox-core:jar:1.0.0 has not been
downloaded from it before.` (measured while building this unit, before any install).

# Your turn — which layer does tiffinbox-core land in?

Boot's index sorts TiffinBox's jars into four layers. Built from the root, `tiffinbox-core` sits in `application`, beside
TiffinBox's own classes (`BOOT-INF/layers.idx`, the lesson's first capture). Change one line in `tiffinbox-core`, package
**only** `tiffinbox-web`, and find which layer `tiffinbox-core` lands in — and whether your line is in it.

Run from this folder (`c5-unit14/`), with this unit's own `.m2-demo` (the seeded repository: every build is offline). A
module built on its own resolves its sibling from the local repository, so the first `mvn` installs the copy's modules there
once — then the line changes, then only the web module is packaged:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness && rsync -a --exclude target after/ .harness/mine/
mvn -o -q -B -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests install
perl -pi -e 's/must be 16 characters or more/must have 16 characters or more/' .harness/mine/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
mvn -o -q -B -f .harness/mine/tiffinbox-web/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
rm -rf .harness/mine-layers && java -Djarmode=tools -jar .harness/mine/tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --layers --destination .harness/mine-layers
find .harness/mine-layers -name 'tiffinbox-core-*.jar'
unzip -p "$(find .harness/mine-layers -name 'tiffinbox-core-*.jar')" com/tiffinbox/TiffinBoxProperties.class | LC_ALL=C grep -aoE 'must [a-z]+ 16 characters'
```

**Done** when `find` prints one path — the folder after `.harness/mine-layers/` is the layer — and the last command tells you
which message that jar carries: yours (`must have`) or the one from before your change (`must be`).

The measured answer, run exactly as written: `solution/SOLUTION.md`. Clean up with `rm -rf .harness/mine .harness/mine-layers`
(the install also left `com/tiffinbox/` in `.m2-demo`; it is git-ignored, and a build from the root never reads it).

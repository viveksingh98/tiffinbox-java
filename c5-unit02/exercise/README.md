# Exercise — whose H2?

`../../c5-unit01/after/pom.xml` sets `<h2.version>2.5.250</h2.version>`, and its own `<dependencyManagement>` gives H2 (the
database TiffinBox uses) the version `${h2.version}`. Boot's parent manages H2 as well.

**Delete one line — the `<h2.version>` property — and nothing else.** Before you build, predict: does the build fail on
an undefined `${h2.version}`, or does it pick a version — and whose?

Run these from this folder (`c5-unit02/exercise/`), exactly as written:

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25      # or wherever your JDK 25 lives
rsync -a --delete --exclude target ../../c5-unit01/after/ my-tiffinbox/
mvn -q -f my-tiffinbox/pom.xml -Dmaven.repo.local="$PWD/../.m2-demo" -DskipTests clean package
ls my-tiffinbox/tiffinbox-web/target/lib | grep h2
grep -v '<h2.version>' my-tiffinbox/pom.xml > my-tiffinbox/pom.edited && mv my-tiffinbox/pom.edited my-tiffinbox/pom.xml
mvn -q -f my-tiffinbox/pom.xml -Dmaven.repo.local="$PWD/../.m2-demo" -DskipTests clean package
ls my-tiffinbox/tiffinbox-web/target/lib | grep h2
```

The first `ls` is the start: `h2-2.5.250.jar`. The `grep -v` line is the one-line deletion; do it in your editor instead
if you prefer. **Done means:** the second `ls` prints one H2 jar, you can name its version, point at the line that set it
(hint: look one parent further up than TiffinBox's own), and say why `${h2.version}` did not break the build.

`-Dmaven.repo.local` points at this unit's own repository, `../.m2-demo`. `../receipts.sh` fills it with everything these
commands read — its `exercise` capture runs the same start and the same deletion on a copy, and its `solved` line is
the end state to compare with. Without a receipts run, Maven fills the same folder from Maven Central on your first build.
`my-tiffinbox/` is yours to break; `.gitignore` keeps it out of git, and the `rsync` line resets it.

Solution, and a transcript of these commands run as written: `solution/`.

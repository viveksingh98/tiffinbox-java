# Exercise — the property that is ignored

Every `mvn` below runs against a **scratch local repository**, never your real `~/.m2` — that is the
one flag that separates these lines from the ones that fill your own repository. **Keep the quotes:**
this tree's path contains a space, and unquoted in bash `-Dmaven.repo.local=` splits and Maven answers
`Unknown lifecycle phase "Content/…"`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M2="${TMPDIR:-/tmp}/c3-m2"                       # scratch repo, never your real ~/.m2
mvn -B "-Dmaven.repo.local=$M2" clean package
```

**Start state.** `BUILD SUCCESS`, exit 0 — even though `<properties>` asks for
`<maven.compiler.release>17</maven.compiler.release>`.

**Your task.** Find the line that overrules the property and make the build fail.

**End state.** `[ERROR] invalid source release 17 with --enable-preview`, exit **1**.

**Solution** — `solution/pom.xml` (run by the author, 3/3): the compiler plugin's own `<release>` is `25`,
and a plugin `<configuration>` beats a property. Set it to 17 and copy it over:
`cp solution/pom.xml pom.xml && mvn -B "-Dmaven.repo.local=$M2" clean package` → exit 1;
`… | grep -E '^\[ERROR\]' | head -4` hashes to `6742c83f84c6c9b0044888d3cb706a11`.

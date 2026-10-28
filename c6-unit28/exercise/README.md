# Exercise — a five hundred the slice never sees

**Your turn:** the README's test expects a five hundred from a failing repository, and fails. Assert what MockMvc really saw, and run it again.

`RevenueTest.java`, beside this README, is a slice test of TiffinBox's web layer, set up as `TiffinBoxWebTest` is: `@WebMvcTest`,
`WebSlice`, the three mocks, and the token as a literal (`not-the-real-token` — written in the test, not a secret). Its one test makes
the repository throw, asks for `/revenue`, and expects a `500`. The commands below copy TiffinBox — `after/`, the tree this lesson made
— to `.harness/mine/after` (git-ignored; `receipts.sh` wipes `.harness/` when it runs) and put `RevenueTest.java` among its tests.

The last line runs that one test, offline against this unit's `.m2-demo`, in a subshell (the parentheses), so your shell stays in
`c6-unit28/` for the next run: `-pl tiffinbox-web` builds the web module alone and takes `tiffinbox-core` from `.m2-demo`, where
`receipts.sh`'s first build installs it; `clean`, so no report of an earlier run is read; `-Dtest=RevenueTest`, this test and no other.
Maven's log goes to `.harness/mine/test.log`. Then the line prints Maven's exit code and Surefire's counts for the test, read from its
report (`TEST-com.tiffinbox.web.RevenueTest.xml`), and — when the test failed — the first two lines of its failure. No server starts,
no port is bound. On a fresh clone `.m2-demo` is empty: run `./receipts.sh` once first (no GraalVM is needed for that, but Docker must
answer, with `eclipse-temurin:25-jre` on it: the script checks both before its first build).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
cp exercise/RevenueTest.java .harness/mine/after/tiffinbox-web/src/test/java/com/tiffinbox/web/
M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -pl tiffinbox-web -Dtest=RevenueTest clean test > ../test.log 2>&1; e=$?; x=tiffinbox-web/target/surefire-reports/TEST-com.tiffinbox.web.RevenueTest.xml; echo "exit $e · RevenueTest: $(sed -n 's/.* tests="\([0-9]*\)" errors="\([0-9]*\)" skipped="[0-9]*" failures="\([0-9]*\)".*/tests \1 · errors \2 · failures \3/p' "$x")"; sed -n 's/.*<failure message="&#10;\([^&]*\)&#10; \([^&]*\)&#10;.*/  \1 \2/p' "$x")
```

As shipped, it prints

```
exit 1 · RevenueTest: tests 1 · errors 0 · failures 1
  Request failed unexpectedly: jakarta.servlet.ServletException: Request processing failed: java.lang.IllegalStateException: kitchen on fire
```

— the assertion failed: there is no status to compare. Nobody handled the exception, and MockMvc runs no error dispatch, so no `500`
was ever written; what MockMvc holds is the failure itself. Change the copy's test
(`.harness/mine/after/tiffinbox-web/src/test/java/com/tiffinbox/web/RevenueTest.java`) to assert that the request failed, and with
the repository's own words, then run the last line again from the same shell.

**Done** when you can print

```
exit 0 · RevenueTest: tests 1 · errors 0 · failures 0
```

The same lines are in this unit's `exercise` capture (`.r-exercise.out`). The measured answer, run exactly as written:
`solution/SOLUTION.md`.

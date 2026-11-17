# Exercise — Capstone: TiffinBox on Postgres

**Your turn:** the README's test counts the queries, and it passes while the page runs one statement per customer. Make it catch the extra statements.

Run it from this unit's folder (`c7-unit39/`) after `./receipts.sh` has run once: it seeds nothing itself, but needs this folder's
`.m2-demo` (the course's Maven repository, offline). The block copies the anchor, `after/`, to `.harness/ex/tree` and puts this
folder's test, `CountersTest.java`, into its web module's tests. The test is the data slice of TiffinBox's own capstone test on an
**embedded H2** database — no container, no Docker: without `@Testcontainers` and a service connection, Boot's slice replaces the
DataSource with an embedded one and Flyway migrates it. It adds 36 customers, each with a pause of two days, then reads them the way
a page that loops would: every customer by name, then each one's pauses — one statement for the list and one more per customer. It
counts with one of Hibernate's statistics counters and asserts the read was one statement. Maven runs that one test (`-Dtest`), offline,
under an alarm (`perl -e 'alarm 300; exec …'`: macOS has no `timeout`); its output goes to `.harness/mine.log`, and the last four lines
print Maven's exit, the embedded database's line, the test's own line and the assertion's message, if one failed.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
cp exercise/CountersTest.java .harness/ex/tree/tiffinbox-web/src/test/java/com/tiffinbox/CountersTest.java
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" -Dtest=CountersTest -Dsurefire.failIfNoSpecifiedTests=false test) > .harness/mine.log 2>&1; echo "Maven: exit $?"
echo "embedded H2 (the slice's own database): $(grep -c "Replacing 'dataSource' DataSource bean with embedded version" .harness/mine.log)"
grep -E '^EX ' .harness/mine.log
grep -A1 -m1 '^expected: ' .harness/mine.log || echo "the assertion: passed"
```

What it prints, as shipped (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — the script compares this block with the run, line for line):

```
Maven: exit 0
embedded H2 (the slice's own database): 1
EX customers 40, paused days 77, counted 1
the assertion: passed
```

**Done** when Maven exits 1 and the last two lines are the assertion's message: the test fails on the page's extra statements, and
`counted` on the `EX` line is one more than the customers. As shipped the test is green on that page — that is the fault. A hint:
the counter it asserts leaves out the loads of a customer's pauses; one of its neighbours counts every statement Hibernate prepares.
The solution, and what it prints, is in `SOLUTION.md`.

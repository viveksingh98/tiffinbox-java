# Solution — Capstone: TiffinBox on Postgres

`getQueryExecutionCount()` counts the queries Hibernate runs — the list of customers is one — and leaves out the collection loads:
each customer's pauses, read when the test sums their days, are loaded by a statement of their own that is not a query in that
count. `getPrepareStatementCount()` counts every statement Hibernate prepares, the forty pause loads among them: the same page now
counts 41, and the test fails, `expected: 1L but was: 41L`. Here the broken test is the green one and the solution is the red one —
a test that counts the wrong thing passes on the bug it was written to catch. Fixing the page is the dashboard's own read,
`findAllByOrderByNameAsc()` with its entity graph: one statement, and this test then passes with the right counter (the capstone's
test, `CustomerEntityRepositoryIT`, on PostgreSQL in a container). The one changed line is the copy: it swaps the counter as it copies
the file.

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
M="$PWD/.m2-demo"; rm -rf .harness/ex && mkdir -p .harness/ex && rsync -a --exclude target --exclude secrets after/ .harness/ex/tree/
sed 's/long counted = stats.getQueryExecutionCount();/long counted = stats.getPrepareStatementCount();/' exercise/CountersTest.java > .harness/ex/tree/tiffinbox-web/src/test/java/com/tiffinbox/CountersTest.java
(cd .harness/ex/tree && exec perl -e 'alarm 300; exec @ARGV' mvn -o -q -B -Dmaven.repo.local="$M" -Dtest=CountersTest -Dsurefire.failIfNoSpecifiedTests=false test) > .harness/mine.log 2>&1; echo "Maven: exit $?"
echo "embedded H2 (the slice's own database): $(grep -c "Replacing 'dataSource' DataSource bean with embedded version" .harness/mine.log)"
grep -E '^EX ' .harness/mine.log
grep -A1 -m1 '^expected: ' .harness/mine.log || echo "the assertion: passed"
```

What it prints (measured, `../receipts.sh`, capture `exercise`, in bash and in zsh — compared with the run, line for line):

```
Maven: exit 1
embedded H2 (the slice's own database): 1
EX customers 40, paused days 77, counted 41
expected: 1L
 but was: 41L
```

TiffinBox's own capstone test asserts `getPrepareStatementCount()` since this unit (`../c7-tiffinbox`, C3) — the counter of the lesson
called *N+1, Measured*.

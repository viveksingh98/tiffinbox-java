# Exercise - unit 23: the cell that names a feature

**Your turn:** the Elasticsearch row's silent-wrong-answer cell says powerful full-text search. Replace it with the capture that failed and its number.

`exercise/table.md` is this unit's table with that one cell changed: every other cell is the shipped one. `exercise/check.sh` runs the
unit's checker, `harness/u23check.py`, on a table and prints its report and its exit. The checker reads each cell: a cell is a capture
of this course and the number it printed, or the word `unmeasured` where no capture exists. It holds the list of the captures this
course printed, so `unmeasured` in a cell that has one fails too. No Docker and no JVM: Python 3 alone.

Run, from `c8-unit23/`:

```bash
EX=$(mktemp -d)
cp exercise/table.md "$EX/table.md"
bash exercise/check.sh "$EX/table.md"
rm -rf "$EX"
```

What it prints:

```
self-test: 12 cases, each rule failing on a two-row sketch, the controls passing
BAD Elasticsearch · a silent wrong answer: a feature word: powerful | neither unmeasured nor a capture reference
cells 25 · measured 17 · unmeasured 7 · bad 1
check: exit 1
```

The cell to write is a capture reference in backticks, a colon, and the number that capture printed, in its own words. The captures
of unit 21 are in `../c8-unit21/README.md`; `SOLUTION.md` has the answer.

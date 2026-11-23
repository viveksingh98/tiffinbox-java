# Solution - unit 23: the cell that names its capture

The capture that failed is unit 21's `nohit`: a copy of the dish index with the standard analyzer, where `veg` found no dish
(`../c8-unit21/README.md`, section 4). The cell names it and the number it printed:

```bash
EX=$(mktemp -d)
perl -pe 's/\| powerful full-text search \|/| `unit21\/nohit`: veg, 0 hits |/' exercise/table.md > "$EX/table.md"
bash exercise/check.sh "$EX/table.md"
rm -rf "$EX"
```

What it prints:

```
self-test: 12 cases, each rule failing on a two-row sketch, the controls passing
cells 25 · measured 18 · unmeasured 7 · bad 0
check: exit 0
```

The word `unmeasured` in that cell is refused as well: the checker's list holds `unit21/nohit` for Elasticsearch's silent wrong
answer, so the check prints `bad 1` and exits `1`.

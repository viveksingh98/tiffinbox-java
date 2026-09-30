# Solution

Measured 2026-09-30 (JDK 25.0.4.1, Maven 3.9.16, Spring Boot 4.1.1), after `../receipts.sh` had built the harness, by
running `../README.md`'s block **exactly as written**, from the unit's folder, in a clean shell (`env -i HOME="$HOME"
PATH=/usr/bin:/bin:/usr/sbin:/sbin bash --noprofile --norc`, so nothing but the block's own two `export` lines chose the
JDK, and no variable of the author's could become a property source). Each command below was run in place of the block's
last line, after its first three. Port 18689 had no listener after any run.

> **Re-run 2026-09-30 (BLUE, after the RED/BLUE changes to `../receipts.sh`):** `../receipts.sh` passed (10 captures,
> 3/3, = published), then the README's block and every command on this page — the four blocks, the dash trap, and the
> two variants the text calls measured (`TIFFINBOX_MEAL_TYPES_0`, and `env 'TIFFINBOX_MEAL-TYPES[0]=VEGAN'`) — were run
> again exactly as written, the same way: every record line identical, the trap exit 127 (bash reading the block from
> standard input words it `bash: line 4: …: command not found`; typed at a prompt it prints the line below), and 0
> listeners on 18689 after each run.

## The prediction, and the answer

The tempting prediction is `[VEGAN, NON_VEG, VEGAN]`: the first item replaced, the other two kept. The block's last line
with the variable in front:

```bash
TIFFINBOX_MEALTYPES_0=VEGAN java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18689 2>&1 | grep '^the record'
```

```
the record: TiffinBoxProperties[jdbcUrl=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1, cooks=3, days=30, port=18689, mealTypes=[VEGAN]]
```

**`[VEGAN]` — one item, not three.** The variable's name follows the rules the previous unit measured: capitals, the dot
an underscore, the dash dropped, and the index as one more `_0` (`TIFFINBOX_MEAL_TYPES_0`, with an underscore for the
dash, gives the same line — measured). The environment outranks `application.yaml`, and the list came whole from the
environment, which holds one item: the file's other two were not merged in behind it. A list set in a higher-ranked
source replaces the whole list. A command-line flag does the same, from the same folder and class path:

```bash
java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18689 "--tiffinbox.meal-types[0]=VEGAN" 2>&1 | grep '^the record'
```

prints `…, mealTypes=[VEGAN]]` (measured).

## Keeping the other two

Say the whole list, in the one source — every index:

```bash
TIFFINBOX_MEALTYPES_0=VEGAN TIFFINBOX_MEALTYPES_1=NON_VEG TIFFINBOX_MEALTYPES_2=VEGAN java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18689 2>&1 | grep '^the record'
```

or the list as one comma-separated value, under the list's own name:

```bash
TIFFINBOX_MEALTYPES=VEGAN,NON_VEG,VEGAN java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18689 2>&1 | grep '^the record'
```

Both print `…, mealTypes=[VEGAN, NON_VEG, VEGAN]]` (measured).

## A trap on the way — the dash

Copying the key's own spelling, dash included:

```bash
TIFFINBOX_MEAL-TYPES_0=VEGAN java -cp "$AFTER" com.tiffinbox.harness.Props --tiffinbox.port=18689
```

```
bash: TIFFINBOX_MEAL-TYPES_0=VEGAN: command not found
```

(zsh words it `zsh:1: command not found: TIFFINBOX_MEAL-TYPES_0=VEGAN`.) Exit 127 in both, and TiffinBox never starts:
a shell variable's name cannot hold a dash, so the shell reads the whole word as the name of a command. Boot itself would
accept the dash — `env 'TIFFINBOX_MEAL-TYPES[0]=VEGAN' java …` also prints `mealTypes=[VEGAN]` (measured) — but it is
the shell that has to set the variable first.

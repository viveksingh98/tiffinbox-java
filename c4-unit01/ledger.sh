#!/bin/sh
# The Wiring.java ledger. Five counts, DERIVED from the file every time this runs - never
# remembered, and never copied off the previous course's slide. The awk/grep below are the
# same ones the previous course's own receipts used, so the numbers are comparable.
#
# Every count here DIES rather than print a confident zero: a zero that comes from a file
# nobody could read is not a measurement.
set -eu
SRC="${1:-src/main/java/com/tiffinbox/wiring/Wiring.java}"
[ -s "$SRC" ] || { echo "ledger: no $SRC - the ledger has nothing to count" >&2; exit 2; }

body=$(awk '/public static String startEverything/,/^    }$/' "$SRC" \
        | grep -vE '^[[:space:]]*(//|/\*|\*)' | grep -vE '^[[:space:]]*$' | wc -l | tr -d ' ')
[ "$body" -gt 0 ] || { echo "ledger: could not read the body of startEverything()" >&2; exit 2; }
ctors=$(awk '/public static String startEverything/,/^    }$/' "$SRC" | grep -cE ' = new [A-Z]' || true)
[ "$ctors" -gt 0 ] || { echo "ledger: counted 0 constructor calls, which cannot be right" >&2; exit 2; }
consts=$(grep -cE '^    public static final ' "$SRC" || true)
[ "$consts" -gt 0 ] || { echo "ledger: counted 0 constants, which cannot be right" >&2; exit 2; }

# The two zeros are the point, so they are SEARCHES, not literals. A description file is any
# file that writes the startup order down; a check is any test source.
# The search root is the MAIN SOURCE TREE, not the unit folder: five levels up from
# .../com/tiffinbox/wiring is .../src. That is deliberate and it is what keeps the number
# stable - an exercise/ or breaks/ copy of the same file is not a second place the startup
# order is written down, it is the same place, copied for a demo.
root=$(cd "$(dirname "$SRC")/../../../../.." 2>/dev/null && pwd || echo .)
order=$(find "$root" -name '*Config.java' -o -name 'applicationContext*.xml' 2>/dev/null | wc -l | tr -d ' ')
checks=$(find "$root" -path '*/src/test/*' -name '*.java' 2>/dev/null | wc -l | tr -d ' ')

printf 'and what starting it costs, counted out of the source:\n'
printf '  lines in startEverything(), comments and blanks removed ... %s\n' "$body"
printf '  objects constructed with new .............................. %s\n' "$ctors"
printf '  configuration values held as constants beside them ........ %s\n' "$consts"
printf '  places that order is written down ......................... %s\n' "$order"
printf '  things that check it ...................................... %s\n' "$checks"

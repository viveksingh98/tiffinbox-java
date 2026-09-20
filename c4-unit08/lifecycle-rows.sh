#!/bin/sh
# Which rows of the hand-wiring ledger THIS SECTION moves, derived from the same file the
# ledger counts - never typed, and never copied off a slide.
#
# A lifecycle step in that file is a discarded no-argument call on an object constructed
# above it: the object already exists, and the line is a thing that has to happen to it
# AFTER it was built or BEFORE it goes away. That is matched on SHAPE, not on a method name,
# so it keeps working when the method is renamed.
#
# It DIES rather than print a confident zero: a zero here would be the claim "this section
# moves nothing", and that claim has to be earned by a file that was actually read.
set -eu
SRC="${1:-../c4-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java}"
[ -s "$SRC" ] || { echo "lifecycle-rows: no $SRC - nothing to count" >&2; exit 2; }

body=$(awk '/public static String startEverything/,/^    }$/' "$SRC" \
        | grep -vE '^[[:space:]]*(//|/\*|\*)' | grep -vE '^[[:space:]]*$')
total=$(printf '%s\n' "$body" | wc -l | tr -d ' ')
[ "$total" -gt 0 ] || { echo "lifecycle-rows: could not read the body" >&2; exit 2; }

steps=$(printf '%s\n' "$body" | grep -cE '^[[:space:]]*[a-z][A-Za-z0-9]*\.[a-zA-Z][A-Za-z0-9]*\(\);[[:space:]]*$' || true)
[ "$steps" -gt 0 ] || { echo "lifecycle-rows: 0 lifecycle steps found, which cannot be right for this file" >&2; exit 2; }

# The rule that lives in a comment: a comment line that says WHEN something may happen.
rules=$(awk '/public static String startEverything/,/^    }$/' "$SRC" \
        | grep -cE '^[[:space:]]*//.*(must be|before|until|after)' || true)

printf 'what this section can take off that file, counted out of the source:\n'
printf '  lines in startEverything(), comments and blanks removed ... %s\n' "$total"
printf '  of those, lifecycle steps a container can own ............. %s\n' "$steps"
printf '  they are:\n'
printf '%s\n' "$body" | grep -E '^[[:space:]]*[a-z][A-Za-z0-9]*\.[a-zA-Z][A-Za-z0-9]*\(\);[[:space:]]*$' \
  | sed 's/^[[:space:]]*/    /'
printf '  comment lines stating WHEN something may happen ........... %s\n' "$rules"

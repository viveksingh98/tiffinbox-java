#!/bin/bash
# exercise/check.sh TABLE.md - unit 23's checker on a table: ../harness/u23check.py reads every body cell; its report, then its exit.
# The check reads the cells, never the exit alone: a cell that says "unmeasured" passes only where no capture of this course exists
# (the checker holds that list), and a feature word fails wherever it stands.
H="$(cd "$(dirname "$0")/../harness" && pwd)"
python3 -I -B "$H/u23check.py" "$1"
e=$?
echo "check: exit $e"
exit $e

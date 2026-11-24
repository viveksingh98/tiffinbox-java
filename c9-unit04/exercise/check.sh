#!/bin/bash
# Course 9, unit 04's exercise check: PASS only when the two tries made ONE pause of 2 paused days. Read by a second client on the
# public API: the dashboard's pausedDays against the number before the sends, each Location the tries carried read back by GET, and
# the id after the last one, which must not exist. Never the exit code of send.sh alone.
# Usage: bash exercise/check.sh PORT BEFORE SENT-FILE
PORT=$1; BEFORE=$2; SENT=$3; B="http://127.0.0.1:$PORT"; bad=0
now=$(curl -s --noproxy '*' -H 'Accept: application/json' "$B/dashboard" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["pausedDays"])')
codes=$(sed -n 's/^try [0-9]*: \([0-9]*\).*/\1/p' "$SENT" | paste -sd' ' -)
locs=$(sed -n 's/^try [0-9]*: 201 //p' "$SENT" | sort -u)
nloc=$(printf '%s\n' "$locs" | grep -c /pauses/)
echo "the tries answered: $codes"
echo "pausedDays: $BEFORE before, $now after (+$((now - BEFORE)))"
echo "distinct pauses the answers named: $nloc"
[ "$codes" = "201 201" ] || { echo "FAIL: a try was refused - the second try must be the same request"; bad=1; }
[ $((now - BEFORE)) = 2 ] || { echo "FAIL: the pause counted $(( (now - BEFORE) / 2 )) times on the dashboard"; bad=1; }
[ "$nloc" = 1 ] || { echo "FAIL: the answers name $nloc pauses, not one"; bad=1; }
for l in $locs; do
  echo "GET $(echo "$l" | sed -E 's#/[0-9]+$#/<id>#'): $(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "$B$l") $(curl -s --noproxy '*' "$B$l" | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("days", d["days"])')"
  last=$l
done
if [ -n "${last:-}" ]; then nx=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' "$B${last%/*}/$(( ${last##*/} + 1 ))"); echo "GET the next id: $nx"; [ "$nx" = 404 ] || { echo "FAIL: a pause after the last one exists"; bad=1; }; fi
[ $bad = 0 ] && echo "PASS: one pause, counted once" || echo "check: FAIL"
exit $bad

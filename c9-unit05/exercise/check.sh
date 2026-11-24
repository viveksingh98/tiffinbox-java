#!/bin/sh
# Course 9 · Unit 05's exercise check - removes the saved status first (a stale one from another run must not pass), reads Meera and the
# month's revenue, runs patch.sh, then reads them again. /revenue is never cached (a sum the database computes on every ask), and the
# route empties Meera's cache entry after a write, so neither reading can come from a stale cache. PASS only when the status is a two
# hundred AND Meera's meals a day are 2 with her price and meal type kept AND the revenue moved by exactly that change.
B="http://127.0.0.1:${PORT:-8080}"
rm -f patch.status
one() { curl --noproxy "*" -sS "$B/customers/Meera" | sed -n "s/.*\"$1\":\"*\([A-Z_0-9]*\)\"*.*/\1/p"; }
rev() { curl --noproxy "*" -sS "$B/revenue" | sed -n 's/.*"monthRevenue":\([0-9]*\).*/\1/p'; }
m0=$(one mealsPerDay); p0=$(one pricePerMeal); t0=$(one mealType); r0=$(rev)
sh patch.sh
s=$(cat patch.status 2> /dev/null)
m1=$(one mealsPerDay); p1=$(one pricePerMeal); t1=$(one mealType); r1=$(rev)
echo "Meera before: $m0 meals a day, $p0 a meal, $t0 · after: $m1, $p1, $t1 · revenue $r0 -> $r1"
if [ "$s" = 200 ] && [ "$m1" = 2 ] && [ "$p1" = "$p0" ] && [ "$t1" = "$t0" ] && [ "$r1" = $(( r0 + (2 - m0) * p0 * 30 )) ]; then
  echo "PASS: status $s · only her meals changed"; exit 0; fi
echo "FAIL: status ${s:-none} · meals ${m1:-none}"; exit 1

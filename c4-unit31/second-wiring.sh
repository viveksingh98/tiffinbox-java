#!/bin/sh
# Slide 1's receipt, BEFORE the rewire only. The ledger both earlier courses counted is Wiring.java alone;
# this counts the hand-wiring the server does on its own - per file, whether the server ever calls Wiring,
# and the lines of main() that type in the values the rewire moves into tiffinbox.properties.
# Usage: sh second-wiring.sh before ../c4-tiffinbox   (the second tree only supplies the list of values)
set -eu
B="$1"; A="$2"
die() { echo "second-wiring: $*" >&2; exit 2; }
W="$B/tiffinbox-core/src/main/java/com/tiffinbox/wiring/Wiring.java"
S="$B/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java"
P="$A/tiffinbox-web/src/main/resources/tiffinbox.properties"
[ -f "$W" ] && [ -f "$S" ] && [ -f "$P" ] || die "need $W, $S and $P"
pat='new (Database|CustomerRepository|Dashboard|OrderQueue|TiffinBoxServer)\('
n() { grep -oE "$pat" "$1" | wc -l | tr -d ' '; }
printf 'hand-written constructions, counted per file (before the rewire):\n'
printf '  core: Wiring.java ...................... %s\n' "$(n "$W")"
printf '  web:  TiffinBoxServer.java ............. %s\n' "$(n "$S")"
printf '  both modules ........................... %s\n' "$(( $(n "$W") + $(n "$S") ))"
printf 'lines of TiffinBoxServer.java that mention Wiring: %s\n' "$(grep -c 'Wiring' "$S" || true)"
start=$(grep -n 'public static void main' "$S" | cut -d: -f1)
end=$(awk -v s="$start" 'NR > s && /^    }$/ { print NR; exit }' "$S")
printf 'its main() (lines %s-%s) types in these values, as written:\n' "$start" "$end"
grep '^tiffinbox\.' "$P" | cut -d= -f2- | while IFS= read -r v; do
  awk -v s="$start" -v e="$end" -v v="$v" 'NR >= s && NR <= e && $0 !~ /^[[:space:]]*\/\// {
      q = "\"" v "\""; x = $0; hit = index(x, q) > 0
      while (!hit && (i = index(x, v)) > 0) {
        b = (i == 1) ? "" : substr(x, i - 1, 1); a = substr(x, i + length(v), 1)
        if (b !~ /[0-9A-Za-z_.]/ && a !~ /[0-9A-Za-z_.]/) hit = 1; else x = substr(x, i + 1) }
      if (hit) { sub(/^[[:space:]]+/, ""); printf "  %4d: %s\n", NR, $0 } }' "$S"
done

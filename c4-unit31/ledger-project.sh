#!/bin/sh
# The ledger, counted over BOTH modules, before the rewire and after it. c4-unit01/ledger.sh counts
# Wiring.java only - and after the rewire it has nothing to count (exit 2). This counts what replaced it.
# Every number is DERIVED from the two trees; a count that could not have been measured dies instead.
set -eu
B="$1"; A="$2"
die() { echo "ledger-project: $*" >&2; exit 2; }
srcs() { echo "$1/tiffinbox-core/src/main/java $1/tiffinbox-web/src/main/java"; }
[ -d "$B/tiffinbox-core" ] && [ -d "$A/tiffinbox-core" ] || die "need two project trees"
# The classes the container now builds: every class the REWIRED project marks @Component. Derived, not typed.
classes=$(grep -rlx --include='*.java' '@Component' $(srcs "$A") | xargs -n1 basename | sed 's/\.java$//' | sort | paste -sd'|' -)
[ -n "$classes" ] || die "found no @Component class in $A"
ctors() { grep -rhoE --include='*.java' "new ($classes)\(" $(srcs "$1") | wc -l | tr -d ' '; }
consts() { grep -rhE --include='*.java' 'static final (String|int) [A-Z_]+ =' $(srcs "$1") | wc -l | tr -d ' '; }
props() { f="$1/tiffinbox-web/src/main/resources/tiffinbox.properties"; [ -f "$f" ] && grep -c '^tiffinbox\.' "$f" || echo 0; }
body() { f=$(find $(srcs "$1") -name "$2" 2>/dev/null | head -1); [ -n "$f" ] || { echo 0; return; }
         awk "/$3/,/^    }\$/" "$f" | grep -vE '^[[:space:]]*(//|/\*|\*)' | grep -vE '^[[:space:]]*$' | wc -l | tr -d ' '; }
cb=$(ctors "$B"); [ "$cb" -gt 0 ] || die "counted 0 hand-written constructions BEFORE the rewire, which cannot be right"
printf 'the classes the container now builds (every @Component in the rewired project):\n  %s\n' "$(echo "$classes" | tr '|' ' ')"
printf 'counted over both modules - before the rewire -> after it:\n'
printf '  hand-written constructions of those classes ......................... %s -> %s\n' "$cb" "$(ctors "$A")"
printf '  configuration values held as constants in code ...................... %s -> %s\n' "$(consts "$B")" "$(consts "$A")"
printf '  values in tiffinbox.properties ....................................... %s -> %s\n' "$(props "$B")" "$(props "$A")"
printf '  lines in Wiring.startEverything(), comments and blanks removed ...... %s -> %s\n' "$(body "$B" Wiring.java 'public static String startEverything')" "$(body "$A" Wiring.java 'public static String startEverything')"
printf '  lines in TiffinBoxServer.main(), comments and blanks removed ........ %s -> %s\n' "$(body "$B" TiffinBoxServer.java 'public static void main')" "$(body "$A" TiffinBoxServer.java 'public static void main')"

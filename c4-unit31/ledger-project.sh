#!/bin/sh
# The ledger, counted over BOTH modules, before the rewire and after it. c4-unit01/ledger.sh counts
# Wiring.java only - and after the rewire it has nothing to count (exit 2). This counts what replaced it.
# Every number is DERIVED from the two trees; a count that could not have been measured dies instead,
# and a count over a file that does not exist says so instead of printing a confident 0.
set -eu
B="$1"; A="$2"
die() { echo "ledger-project: $*" >&2; exit 2; }
srcs() { echo "$1/tiffinbox-core/src/main/java $1/tiffinbox-web/src/main/java"; }
[ -d "$B/tiffinbox-core" ] && [ -d "$A/tiffinbox-core" ] || die "need two project trees"
PROPS="$A/tiffinbox-web/src/main/resources/tiffinbox.properties"
[ -f "$PROPS" ] || die "no $PROPS in the rewired tree"
# The classes the container now builds: every class the REWIRED project marks @Component or @Configuration.
classes=$(grep -rlxE --include='*.java' '@(Component|Configuration)' $(srcs "$A") | xargs -n1 basename | sed 's/\.java$//' | sort | paste -sd'|' -)
[ -n "$classes" ] || die "found no @Component class in $A"
ctors() { grep -rhoE --include='*.java' "new ($classes)\(" $(srcs "$1") | wc -l | tr -d ' '; }
consts() { grep -rhE --include='*.java' 'static final (String|int) [A-Z_]+ =' $(srcs "$1") | wc -l | tr -d ' '; }
props() { f="$1/tiffinbox-web/src/main/resources/tiffinbox.properties"; [ -f "$f" ] && grep -c '^tiffinbox\.' "$f" || echo "0 (no file)"; }
# The body of one method, comments and blanks removed; "(file gone)" when the file itself is gone.
body() { f=$(find $(srcs "$1") -name "$2" 2>/dev/null | head -1); [ -n "$f" ] || { echo "(file gone)"; return; }
         awk "/$3/,/^    }\$/" "$f" | grep -vE '^[[:space:]]*(//|/\*|\*)' | grep -vE '^[[:space:]]*$' | wc -l | tr -d ' '; }
# How many of the rewired tiffinbox.properties VALUES a tree's main() types in as literals.
lits() { f=$(find $(srcs "$1") -name TiffinBoxServer.java | head -1); n=0
         m=$(awk '/public static void main/,/^    }$/' "$f" | grep -vE '^[[:space:]]*//')
         for v in $(grep '^tiffinbox\.' "$PROPS" | cut -d= -f2-); do
           printf '%s\n' "$m" | grep -qF -- "\"$v\"" && { n=$((n+1)); continue; }
           printf '%s\n' "$m" | grep -qE -- "(^|[^0-9A-Za-z_.])$v([^0-9A-Za-z_.]|\$)" && n=$((n+1)); done; echo $n; }
deps() { grep -c '<dependency>' "$1/tiffinbox-core/pom.xml"; }
jarsin() { d="$1/tiffinbox-web/target/lib"; [ -d "$d" ] && ls "$d"/*.jar | wc -l | tr -d ' ' || echo "(not built)"; }
cb=$(ctors "$B"); [ "$cb" -gt 0 ] || die "counted 0 hand-written constructions BEFORE the rewire, which cannot be right"
printf 'the classes the container builds (every @Component or @Configuration in the rewired project):\n  %s\n' "$(echo "$classes" | tr '|' ' ')"
printf 'counted over both modules - before the rewire -> after it:\n'
printf '  hand-written constructions of those classes ......................... %s -> %s\n' "$cb" "$(ctors "$A")"
printf '  configuration values held as constants in code ...................... %s -> %s\n' "$(consts "$B")" "$(consts "$A")"
printf '  tiffinbox.properties values typed as literals into main() ........... %s -> %s\n' "$(lits "$B")" "$(lits "$A")"
printf '  values in tiffinbox.properties ....................................... %s -> %s\n' "$(props "$B")" "$(props "$A")"
printf '  lines in Wiring.startEverything(), comments and blanks removed ...... %s -> %s\n' "$(body "$B" Wiring.java 'public static String startEverything')" "$(body "$A" Wiring.java 'public static String startEverything')"
printf '  lines in TiffinBoxServer.main(), comments and blanks removed ........ %s -> %s\n' "$(body "$B" TiffinBoxServer.java 'public static void main')" "$(body "$A" TiffinBoxServer.java 'public static void main')"
printf '  lines in start() and stop(), which the container now calls .......... %s -> %s\n' "$(( $(body "$B" TiffinBoxServer.java 'void start\(\)') + $(body "$B" TiffinBoxServer.java 'void stop\(\)') ))" "$(( $(body "$A" TiffinBoxServer.java 'void start\(\)') + $(body "$A" TiffinBoxServer.java 'void stop\(\)') ))"
printf 'the price:\n'
printf '  dependencies tiffinbox-core declares in its pom.xml ................. %s -> %s\n' "$(deps "$B")" "$(deps "$A")"
printf '  jars the application needs at run time (tiffinbox-web/target/lib) .. %s -> %s\n' "$(jarsin "$B")" "$(jarsin "$A")"

#!/bin/sh
# This unit's comparison set: ../c4-unit31/curlset.sh with ONE change - POST /shutdown carries the X-Shutdown-Token
# header. The token is the first line of the file $2 names (a config tree's file; - reads standard input, first), handed
# to curl on its standard input: it is never on a command line, curl's or this script's. Loopback only. $1 = port.
B="http://127.0.0.1:$1"
T=$(mktemp)
req() { out=$(curl -s -o "$T" -w '%{http_code} %{content_type}' -X "$1" "$B$2")
        printf '%-5s %-11s -> %s  %s\n' "$1" "$2" "$out" "$(cat "$T")"; }
if [ "$2" = - ]; then IFS= read -r tok; else IFS= read -r tok < "$2"; fi
req GET /customers
req GET /revenue
req GET /dashboard
req GET /kitchen
req GET /nowhere
req GET /shutdown
out=$(printf 'X-Shutdown-Token: %s\n' "$tok" | curl -s -o "$T" -w '%{http_code} %{content_type}' -H @- -X POST "$B/shutdown")
printf '%-5s %-11s -> %s  %s\n' POST /shutdown "$out" "$(cat "$T")"
rm -f "$T"

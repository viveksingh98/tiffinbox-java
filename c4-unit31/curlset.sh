#!/bin/sh
# The comparison set (brief ⚑2): one request per layer the rewire touched. Status, content type, body.
# Loopback only. $1 = port.
B="http://127.0.0.1:$1"
T=$(mktemp)
req() { out=$(curl -s -o "$T" -w '%{http_code} %{content_type}' -X "$1" "$B$2")
        printf '%-5s %-11s -> %s  %s\n' "$1" "$2" "$out" "$(cat "$T")"; }
req GET /customers
req GET /revenue
req GET /dashboard
req GET /kitchen
req GET /nowhere
req GET /shutdown
req POST /shutdown
rm -f "$T"

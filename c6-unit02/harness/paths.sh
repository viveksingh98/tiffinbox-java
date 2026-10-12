#!/bin/sh
# harness/paths.sh PORT [PATH...] - the harness's requests, the course's, never TiffinBox's. GET each PATH from
# http://127.0.0.1:PORT - loopback only - or, when no PATH is given, these seven: /raw /raw/menu/today /lunch.tiff
# /raw/lunch.tiff /customers /rawXYZ /nowhere. One line each: the path, the status, the content type, the value of the raw
# filter's header X-Raw-Filter ("-" when the answer has none), then the answer itself.
B="http://127.0.0.1:$1"; shift
[ $# -gt 0 ] || set -- /raw /raw/menu/today /lunch.tiff /raw/lunch.tiff /customers /rawXYZ /nowhere
H=$(mktemp); T=$(mktemp)
for p in "$@"; do
  out=$(curl -s -D "$H" -o "$T" -w '%{http_code} %{content_type}' "$B$p")
  f=$(tr -d '\r' < "$H" | grep -i '^x-raw-filter:' | sed 's/^[^:]*: *//')
  printf 'GET %-16s -> %s  X-Raw-Filter: %s  %s\n' "$p" "$out" "${f:--}" "$(cat "$T")"
done
rm -f "$H" "$T"

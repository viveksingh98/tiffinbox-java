#!/bin/sh
# slow8.sh PORT: eight GET /probe/slow at once on 127.0.0.1:PORT - the harness's Threads answers each after half a second
# with the name of the thread that answered and whether it is virtual. Prints the eight answers, sorted. curl gives each up
# after 30 seconds. Loopback only.
d=$(mktemp -d)
for i in 1 2 3 4 5 6 7 8; do curl -s -m 30 "http://127.0.0.1:$1/probe/slow" > "$d/$i" & done
wait
cat "$d"/1 "$d"/2 "$d"/3 "$d"/4 "$d"/5 "$d"/6 "$d"/7 "$d"/8 | sort
rm -rf "$d"

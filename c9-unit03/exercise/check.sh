#!/bin/sh
# Course 9 · Unit 03's exercise check - removes the saved results first (a stale one from another run must not pass), runs ask.sh, then
# reads what it saved: the status (ask.status) AND the body's byte count (ask.bytes). PASS only for a three oh four with no body - the
# stylesheet's own answer when the condition holds. A status alone, or a status with a body, is a FAIL.
rm -f ask.status ask.bytes
sh ask.sh
s=$(cat ask.status 2> /dev/null); n=$(cat ask.bytes 2> /dev/null)
if [ "$s" = 304 ] && [ "$n" = 0 ]; then echo "PASS: status $s · body bytes $n"; exit 0; fi
echo "FAIL: status ${s:-none} · body bytes ${n:-none}"; exit 1

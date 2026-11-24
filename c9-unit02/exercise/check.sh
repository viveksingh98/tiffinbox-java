#!/bin/sh
# Course 9 · Unit 02's exercise check - reads ask.out (what ask.sh, or your fixed line, printed): curl's exit code AND the Allow line.
# PASS only when curl exited 0 (it stopped after the headers) and an Allow line names exactly the methods /shutdown allows, read as a
# set (POST and OPTIONS - what the run prints for OPTIONS /shutdown). An exit code alone, or another address's Allow, is a FAIL.
[ -f ask.out ] || { echo "FAIL: no ask.out - run the ask first"; exit 1; }
e=$(sed -n 's/^curl exit //p' ask.out | tail -1)
a=$(tr -d '\r' < ask.out | sed -n 's/^[Aa]llow: *//p' | tr -d ' ' | tr ',' '\n' | sed '/^$/d' | sort | paste -sd, -)
if [ "$e" = 0 ] && [ "$a" = "OPTIONS,POST" ]; then echo "PASS: curl exit 0 · the methods shutdown allows: $a"; exit 0; fi
echo "FAIL: curl exit ${e:-none} · Allow ${a:-none}"; exit 1

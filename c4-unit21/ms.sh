#!/bin/sh
# Masks elapsed-millisecond values (contract 2f.2: a duration is never the fact) and COUNTS them, so a
# mask that silently stops matching is visible. Every other character of the capture is kept.
awk '{ if (match($0, /took [0-9]+\.[0-9]+ ms/)) { n++; sub(/took [0-9]+\.[0-9]+ ms/, "took <ms>") } print }
     END { printf "… %d elapsed-time value(s) masked …\n", n }'

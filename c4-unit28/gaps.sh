#!/bin/sh
# Masks the raw millisecond gaps (a duration is never the fact - contract 2f.1) and COUNTS them. The
# verdict on each line - "every gap within 40 ms of N" - is kept: the SHAPE is the claim.
awk '{ if (gsub(/starts: \[[0-9, ]+\]/, "starts: [<gaps>]")) n++; print }
     END { printf "… %d line(s) of raw gaps masked …\n", n }'

#!/bin/sh
# Drops JUL timestamp HEADER lines (wall clock) and counts them. Every SEVERE/WARNING line is KEPT.
awk '/^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9]{4} [0-9:]+ (AM|PM) / { c++; next } { print }
     END { printf "… %d JUL timestamp line(s) elided …\n", c }'

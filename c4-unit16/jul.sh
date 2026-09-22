#!/bin/sh
# Two things in this unit's captures are not properties of the code, and both are masked here so
# that what remains can be hashed. The filter COUNTS what it touched and prints the count, so a
# filter that silently starts matching more than it should is visible (contract 0.6a).
#
#  1. Hibernate Validator's JUL banner, whose first line carries a wall-clock timestamp.
#  2. The CGLIB subclass sequence number in AtTheBoundary's output -- $$SpringCGLIB$$0 is a
#     counter, not a fact about your class.
#
# Matching is on the JUL DATE SHAPE and the HV000001 code, never on an English word: the JUL level
# word is localised by the logging framework, so -Duser.language would change it.
awk '
  /^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9]{4} [0-9:]+ (AM|PM) / { cut++; next }
  /HV000001: Hibernate Validator/                            { cut++; next }
  { if (match($0, /\$\$SpringCGLIB\$\$[0-9]+/)) { masked++; gsub(/\$\$SpringCGLIB\$\$[0-9]+/, "$$SpringCGLIB$$<n>") }
    print }
  END { printf "… %d line(s) of JUL banner elided, %d CGLIB sequence number(s) masked …\n", cut, masked }'

#!/bin/sh
# Two things in these captures are not properties of the code, and both are masked AND COUNTED:
#  - JUL timestamp header lines (Spring's run logs one before its WARNING)
#  - the absolute path of the weaver jar, which the JVM prints inside its sun.misc.Unsafe warning
# Every WARNING line itself is KEPT - in this unit the warnings are evidence.
awk '/^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9]{4} [0-9:]+ (AM|PM) / { ts++; next }
     { if (gsub(/\(file:[^)]*\)/, "(file:<path>/aspectjweaver-1.9.25.1.jar)")) p++; print }
     END { printf "… %d JUL timestamp line(s) elided, %d jar path(s) masked …\n", ts, p }'

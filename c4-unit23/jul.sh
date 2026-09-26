#!/bin/sh
# Drops the JUL timestamp HEADER lines (a wall clock is not a property of the code) and COUNTS them.
# Every WARNING line is KEPT: in this unit the warning about a final method is evidence, and the
# absence of any warning about self-invocation is evidence too. Filtering warnings out for tidiness
# is how this section twice nearly called an ignorable failure "silent".
awk '/^[A-Z][a-z][a-z] [ 0-9][0-9], [0-9]{4} [0-9:]+ (AM|PM) / { cut++; next } { print }
     END { printf "… %d JUL timestamp header line(s) elided …\n", cut }'

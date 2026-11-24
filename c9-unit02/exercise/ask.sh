#!/bin/sh
# Course 9 · Unit 02's exercise - ask TiffinBox (on PORT, 8080 by default) for the customer list's headers. As shipped it is BROKEN:
# curl -X HEAD sends the method but still reads the body the Content-Length announces, and HEAD sends none - so curl waits until its
# own cap ends the ask (exit 28). The cap is the script's, never a measurement. Its output goes to ask.out; check.sh reads that file.
B="http://127.0.0.1:${PORT:-8080}"
{ curl --noproxy "*" -sS -X HEAD --max-time 5 -D - -o /dev/null "$B/customers"; echo "curl exit $?"; } > ask.out 2>&1; cat ask.out

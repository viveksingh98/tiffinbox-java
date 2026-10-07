#!/bin/sh
# shutdown.sh PORT TOKENFILE: POST /shutdown on 127.0.0.1:PORT with the X-Shutdown-Token header, the token read from the first
# line of TOKENFILE and handed to curl on its standard input (never on a command line) - as ../c5-unit11/curlset.sh sends it -
# but with a limit: curl gives up after 5 seconds. Prints the HTTP status curl saw (000: no answer) and curl's exit code
# (28: the 5 seconds ran out).
IFS= read -r tok < "$2"
code=$(printf 'X-Shutdown-Token: %s\n' "$tok" | curl -s -m 5 -o /dev/null -w '%{http_code}' -H @- -X POST "http://127.0.0.1:$1/shutdown")
e=$?
echo "POST /shutdown -> $code · curl exit $e"

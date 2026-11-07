#!/bin/sh
# shutdown.sh PORT TOKENFILE [PATH] [HEADER]: POST PATH (/shutdown unless named) on 127.0.0.1:PORT with the token in the header
# HEADER (X-Shutdown-Token unless named: another name is how a misspelt header is sent), the token read from the first line of
# TOKENFILE and handed to curl on its standard input (never on a command line) - as ../c5-unit11/curlset.sh sends it - but with
# a limit: curl gives up after 5 seconds. Prints the HTTP status curl saw (000: no answer), the answer's content type, its
# Content-Length header (none: not sent), its body, and curl's exit code (28: the 5 seconds ran out). The header's name is
# printed only when it is not X-Shutdown-Token.
IFS= read -r tok < "$2"
p=${3:-/shutdown}
h=${4:-X-Shutdown-Token}
b=$(mktemp)
w=$(printf '%s: %s\n' "$h" "$tok" | curl -s -m 5 -o "$b" -w '%{http_code}|%{content_type}|%header{content-length}' -H @- -X POST "http://127.0.0.1:$1$p")
e=$?
code=${w%%|*}; rest=${w#*|}; type=${rest%%|*}; len=${rest#*|}
[ "$h" = X-Shutdown-Token ] && n="" || n=" (the token in a header named $h)"
echo "POST $p$n -> $code ${type:-(no type)} · Content-Length: ${len:-none} · $(cat "$b") · curl exit $e"
rm -f "$b"

#!/bin/sh
# Course 9 · Unit 03's exercise - ask TiffinBox's stylesheet (on PORT, 8080 by default) with a condition. The stylesheet's path is read
# off the dashboard page's own link (its fingerprinted name changes with the file), then its validators off its own answer. As shipped
# it is BROKEN: it sends If-None-Match with the stylesheet's own ETag, and the answer is the whole file again. It saves the status to
# ask.status and the body's byte count to ask.bytes; check.sh reads those two files.
B="http://127.0.0.1:${PORT:-8080}"
CSS=$(curl --noproxy "*" -sS -H "Accept: text/html" "$B/dashboard" | sed -n 's/.*<link[^>]*href="\([^"]*\.css\)".*/\1/p' | head -1)
curl --noproxy "*" -sS -D ask.head -o /dev/null "$B$CSS"
ETAG=$(tr -d '\r' < ask.head | sed -n 's/^[Ee][Tt][Aa][Gg]: //p')
LM=$(tr -d '\r' < ask.head | sed -n 's/^[Ll]ast-[Mm]odified: //p')
: > ask.body
curl --noproxy "*" -sS -o ask.body -w '%{http_code}\n' -H "If-None-Match: $ETAG" "$B$CSS" > ask.status
wc -c < ask.body | tr -d ' ' > ask.bytes
echo "the stylesheet: $CSS · ETag $ETAG · Last-Modified $LM"
echo "status $(cat ask.status) · body bytes $(cat ask.bytes)"
rm -f ask.head ask.body

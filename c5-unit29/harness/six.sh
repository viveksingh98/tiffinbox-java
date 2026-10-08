#!/bin/sh
# six.sh PORT: the comparison set's first six requests (../../c5-unit11/curlset.sh's GETs, in its order) against 127.0.0.1:PORT,
# without its seventh - POST /shutdown - so the server keeps running and can be scraped after them. No token is read or sent.
# Prints the verb, the path and the HTTP status of each; the bodies are not printed.
for p in /customers /revenue /dashboard /kitchen /nowhere /shutdown; do
  printf 'GET   %-11s -> %s\n' "$p" "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$1$p")"
done

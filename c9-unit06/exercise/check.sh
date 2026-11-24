#!/bin/sh
# check.sh - removes the saved answer, runs read.sh, and PASSES only on a two hundred from the public address for Priya
# (/api/v1/customers/Priya) whose body is Priya's record; anything else FAILS with what it saw.
rm -f read.status read.body
sh read.sh > /dev/null 2>&1
set -- $(cat read.status 2> /dev/null)
code=$1; rpath=$(printf '%s' "$2" | sed -E 's#^https?://[^/]+##')
name=$(sed -n -E 's/^\{"name":"([^"]*)".*/\1/p' read.body 2> /dev/null)
if [ "$code" = 200 ] && [ "$rpath" = /api/v1/customers/Priya ] && [ "$name" = Priya ]; then
  echo "PASS: status $code · $rpath · the body's name $name"
else
  echo "FAIL: status ${code:-none} · ${rpath:-no address} · the body's name ${name:-none}"; exit 1
fi

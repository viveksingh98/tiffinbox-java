#!/bin/sh
# read.sh - read Priya back from TiffinBox's public address and save the answer: the status and the address asked (read.status),
# the body (read.body). As shipped it is broken: run it, read what it saved, and fix one word of the curl line.
curl -s -o read.body -w '%{http_code} %{url_effective}\n' "http://127.0.0.1:${PORT:-18425}/api/v1/customers/priya" > read.status
cat read.status

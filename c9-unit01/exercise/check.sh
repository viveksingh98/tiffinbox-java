#!/bin/sh
# Course 9 unit 01's checker: reads what post.sh saved - never asks TiffinBox again (the note is shown once). PASS needs BOTH:
# the dashboard page holds the note "<this try's name> added", and the cookie jar holds TiffinBox's session cookie, JSESSIONID.
# curl writes an HttpOnly cookie's line as "#HttpOnly_127.0.0.1 ...": that prefix is stripped before the line is read.
[ -f name.txt ] && [ -f dashboard.html ] || { echo "FAIL: run post.sh first (no name.txt or dashboard.html here)"; exit 1; }
NAME=$(head -1 name.txt)
NOTE=absent; grep -q "<p class=\"note\">$NAME added</p>" dashboard.html && NOTE=present
COOKIE=absent
[ -f jar.txt ] && sed 's/^#HttpOnly_//' jar.txt | grep -v '^#' | awk -F '\t' 'NF >= 7 && $6 == "JSESSIONID" { f = 1 } END { exit !f }' && COOKIE=present
echo "the note for this try's name: $NOTE · the session cookie JSESSIONID in jar.txt: $COOKIE"
if [ $NOTE = present ] && [ $COOKIE = present ]; then echo PASS; else echo FAIL; exit 1; fi

# Course 8, unit 22's exercise check: the store's own count by curl on 127.0.0.1:20618, and the program's own requests, read off its
# log (the client's trace logger) - never the exit of a run. Solved: the index counts exactly 1, the program sent exactly ONE document
# write, and a refresh stands behind it - refresh=true or refresh=wait_for on that write, or a _refresh request after it. A second
# write fails the check; so does a pause before the count, which sends no refresh. The exercise's index template turns the index's
# periodic refresh off (its refresh interval -1), so only a refresh the program asks for makes the document countable: the check reads
# that setting first, prints it on a line of its own, and says solved: no when it is not -1. Run with bash exercise/check.sh LOG.
L=${1:?name the program log}
P=$(curl -s --noproxy '*' http://127.0.0.1:20618/dishes/_settings | python3 -I -c 'import json,sys; print(json.load(sys.stdin).get("dishes", {}).get("settings", {}).get("index", {}).get("refresh_interval", "unset"))' 2> /dev/null)
case "$P" in -1) echo "index dishes: its refresh interval -1 - no periodic refresh (the exercise's template)" ;;
  *) echo "index dishes: its refresh interval is not -1 - not the exercise's template, so the count cannot judge the program" ;; esac
C=$(curl -s --noproxy '*' http://127.0.0.1:20618/dishes/_count | python3 -I -c 'import json,sys; print(json.load(sys.stdin).get("count"))')
WR=$(python3 -I -c '
import re, sys
w = 0; r = False
for l in open(sys.argv[1], encoding="utf-8", errors="replace"):
    m = re.search(r"Request +: curl -iX (PUT|POST) \x27[^\x27]*/dishes/(_doc|_create|_bulk)[^\x27]*\x27", l)
    if m:
        w += 1
        r = r or bool(re.search(r"refresh=(true|wait_for)\x27", m.group(0)))
    elif w and re.search(r"Request +: curl -iX POST \x27[^\x27]*/dishes/_refresh\x27", l):
        r = True
print(w, "yes" if r else "no")' "$L")
W=${WR% *}; R=${WR#* }
case "$P $C $W $R" in "-1 1 1 yes") S=yes ;; *) S=no ;; esac
echo "check: _count -> $C · document writes the program sent: $W · a refresh behind the write: $R · solved: $S"

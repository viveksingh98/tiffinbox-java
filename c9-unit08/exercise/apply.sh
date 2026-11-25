#!/bin/sh
# apply.sh URL - the receipt's solution: what a viewer does in sealed.sh's window, done by the harness's
# cdp9.mjs in a headless sealed Chrome - open the page, open the operation, Try it out, type the name, Execute. Default: the operation
# customer-reads-one and the name Ravi; OP, WHO and HOW (noexec: the page opened, nothing executed; twice: a second operation executed
# after it) change them for the receipt's refused variants.
[ -n "$1" ] || { echo "apply.sh URL"; exit 1; }
url=$1; op=${OP:-customer-reads-one}; who=${WHO:-Ravi}; how=${HOW:-}
dev=${DEVTOOLS:-20977}
rm -f apply.log
HEADLESS=1 sh sealed.sh about:blank > /dev/null 2>&1 &
cpid=$!
i=0; until curl --noproxy '*' -s -o /dev/null --max-time 1 "http://127.0.0.1:$dev/json/version"; do
  kill -0 $cpid 2> /dev/null || { echo "apply.sh: Chrome did not start"; exit 1; }
  i=$((i + 1)); [ $i -lt 300 ] || { kill $cpid; echo "apply.sh: no DevTools"; exit 1; }; sleep 0.1; done
node ../harness/cdp.mjs "$dev" open "$url" apply.ev.json > apply.log 2>&1
node ../harness/cdp9.mjs "$dev" rendered 30000 >> apply.log 2>&1
if [ "$how" != noexec ]; then node ../harness/cdp9.mjs "$dev" tryit "$op" "$who" apply.ev.json >> apply.log 2>&1; fi
if [ "$how" = twice ]; then node ../harness/cdp9.mjs "$dev" tryit tiffin-box-server-customer "$who" apply.ev.json >> apply.log 2>&1; fi
node ../harness/cdp.mjs "$dev" close > /dev/null 2>&1
wait $cpid 2> /dev/null
rm -f apply.ev.json
echo "apply.sh: $(grep -c '^request: ' apply.log) request(s) sent from the page ($op, $who${how:+, $how})"

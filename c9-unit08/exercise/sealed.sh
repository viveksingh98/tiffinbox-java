#!/bin/sh
# sealed.sh URL - opens URL in Chrome sealed the way Course 6 unit 23 sealed it: a dead proxy (127.0.0.1:9, nothing listens there) and a
# host-resolver rule that maps every name to nothing but 127.0.0.1, on a throwaway profile (sealed.profile, removed when Chrome exits).
# HEADLESS=1 (the receipt's apply.sh) runs it headless - the only difference, printed. DevTools on 127.0.0.1:${DEVTOOLS:-20977}.
# CHROME names the browser (default: the Chrome app on a Mac).
chrome=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
[ -n "$1" ] || { echo "give the page's address: sh sealed.sh http://127.0.0.1:20978/swagger-ui/index.html"; exit 1; }
if [ -n "$HEADLESS" ]; then mode=--headless=new; echo "sealed.sh: headless (HEADLESS=1)"; else mode=--new-window; echo "sealed.sh: headed (a window opens)"; fi
rm -rf sealed.profile
"$chrome" $mode --user-data-dir="$PWD/sealed.profile" --no-first-run --no-default-browser-check --disable-background-networking \
  --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US \
  --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 \
  --remote-debugging-port="${DEVTOOLS:-20977}" "$1" > sealed.log 2>&1
rc=$?
rm -rf sealed.profile sealed.log
exit $rc

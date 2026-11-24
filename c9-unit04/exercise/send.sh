#!/bin/bash
# Course 9, unit 04's exercise: send ONE pause - and, as a client does when an answer gets lost, send it again.
# Usage: bash exercise/send.sh PORT NAME. Each try prints its status and the Location the answer carried.
PORT=$1
NAME=$2
KEY1=$(uuidgen)
KEY2=$(uuidgen)
DAYS1=2
DAYS2=2
try() { local n=$1 key=$2 days=$3 h
  h=$(curl -s --noproxy '*' --http1.1 -o /dev/null -D - -X POST -H "Idempotency-Key: \"$key\"" "http://127.0.0.1:$PORT/api/v1/customers/$NAME/pauses?days=$days" | tr -d '\r')
  echo "try $n: $(printf '%s\n' "$h" | head -1 | cut -d' ' -f2) $(printf '%s\n' "$h" | grep -i '^Location:' | sed 's#^[^:]*: http://127.0.0.1:[0-9]*##')"; }
try 1 "$KEY1" "$DAYS1"
try 2 "$KEY2" "$DAYS2"

# Unit 04's exercise

**Your turn:** the same pause sent twice counts twice on the dashboard. Send it twice so it counts once.

`send.sh` sends one pause of `2` paused days for Sunil, and then sends it again, the way a client does when the first answer gets
lost. Each try carries an `Idempotency-Key` header, which the pause route requires. Start TiffinBox (`after/`'s jar, H2 in memory, on
port `20938`), then run these lines from this unit's folder:

```bash
PORT=20938
BEFORE=$(curl -s --noproxy '*' -H 'Accept: application/json' "http://127.0.0.1:$PORT/dashboard" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["pausedDays"])')
bash exercise/send.sh "$PORT" Sunil > sent.txt
cat sent.txt
bash exercise/check.sh "$PORT" "$BEFORE" sent.txt
```

What it prints (the ids masked as `<id>`):

```
try 1: 201 /api/v1/customers/Sunil/pauses/<id>
try 2: 201 /api/v1/customers/Sunil/pauses/<id>
the tries answered: 201 201
pausedDays: 5 before, 9 after (+4)
distinct pauses the answers named: 2
FAIL: the pause counted 2 times on the dashboard
FAIL: the answers name 2 pauses, not one
GET /api/v1/customers/Sunil/pauses/<id>: 200 days 2
GET /api/v1/customers/Sunil/pauses/<id>: 200 days 2
GET the next id: 404
check: FAIL
```

`check.sh` reads the dashboard's `pausedDays` and each pause the answers named, by `GET`, and the id after the last: never the exit
code of `send.sh` alone. Change one line of `send.sh` so the check passes. `SOLUTION.md` has the line.

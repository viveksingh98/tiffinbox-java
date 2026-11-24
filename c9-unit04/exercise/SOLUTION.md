# Unit 04's exercise: the solution

Both tries carry ONE key. The second try is then the same request under the same key, and the filter answers it with the first
answer, stored with the pause: one pause, the same `Location` twice. The line in `send.sh` is `KEY2=$(uuidgen)`; it becomes
`KEY2=$KEY1`. The block below makes that change on a copy and runs it:

```bash
PORT=20938
BEFORE=$(curl -s --noproxy '*' -H 'Accept: application/json' "http://127.0.0.1:$PORT/dashboard" | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["pausedDays"])')
sed 's/^KEY2=$(uuidgen)$/KEY2=$KEY1/' exercise/send.sh > fixed.sh && bash fixed.sh "$PORT" Sunil > sent.txt
cat sent.txt
bash exercise/check.sh "$PORT" "$BEFORE" sent.txt
```

What it prints (the ids masked as `<id>`):

```
try 1: 201 /api/v1/customers/Sunil/pauses/<id>
try 2: 201 /api/v1/customers/Sunil/pauses/<id>
the tries answered: 201 201
pausedDays: 5 before, 7 after (+2)
distinct pauses the answers named: 1
GET /api/v1/customers/Sunil/pauses/<id>: 200 days 2
GET the next id: 404
PASS: one pause, counted once
```

The same key with another request is not a solution: with `DAYS2=3` the second try is another request under a used key, the filter
answers `422`, and `check.sh` fails it ("a try was refused").

# Unit 15's exercise, solved

The client stops writing the member's path in. It asks the entry point first and sends the `href` of the link the entry point
answers with, named `ravi`:

```python
status, entry = get(B + "/probe/entry")              # the entry point
status, body = get(entry["_links"]["ravi"]["href"])  # the link it answered with
```

These two lines replace the one line that wrote `/probe/people/Ravi` in. `sh apply.sh MY_CLIENT` makes that one edit on your copy
and checks that the result holds the two lines above, byte for byte.

Why it passes: server B moved the member route, and its entry point says so. The client reads the new path from the answer, so
the same file reads Ravi from both servers. Its source names neither path, and it keeps nothing between runs.

What it prints (`sh check.sh MY_CLIENT`, H2 in memory, the port masked):

```
server A (the member route at /probe/people): the client printed: the member -> 200|Ravi (exit 0)
server A: the client's requests: GET /probe/entry 200;GET /probe/people/Ravi 200 · the entry point's link: http://127.0.0.1:<port>/probe/people/Ravi
server B (moved to /probe/members): the client printed: the member -> 200|Ravi (exit 0)
server B: the client's requests: GET /probe/entry 200;GET /probe/members/Ravi 200 · the entry point's link: http://127.0.0.1:<port>/probe/members/Ravi
PASS - every clause holds
```

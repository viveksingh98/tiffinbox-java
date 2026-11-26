# Unit 15's exercise: follow the link

**Your turn:** this client writes the path in. Make it follow the entry point's link instead, then move the route and run it again.

`client.py` is the harness's client of the harness's member route. As shipped it sends `GET /probe/people/Ravi`: the member's
path, written into the file. The two servers are the harness's copy of `../before` with the one starter line, and the harness's
classes built twice: server A serves the member route at `/probe/people`, server B has the route moved to `/probe/members`. Both
answer `GET /probe/entry`, the entry point, with one link named `ravi` that points at the member route wherever it is.

1. `sh build.sh` builds both servers once, offline when `MAVEN_REPO` names a local repository (into `../.harness/servers/`, never
   tracked).
2. Copy `client.py` to a file of your own, say `my_client.py`, and change only that copy.
3. `sh check.sh my_client.py` starts server A on port `21048` (or `PORT`), runs your client, stops A, starts server B on the same
   port, runs the same file again, and reads the two access logs.

The check passes only when your client prints Ravi from both servers, asks the entry point before the member every time, sends
exactly the `href` the entry point answered, holds neither path in its source, and writes no file. H2 in memory each time.

What it prints (`sh check.sh --allow-broken client.py`, the shipped client, H2 in memory, the port masked):

```
server A (the member route at /probe/people): the client printed: the member -> 200|Ravi (exit 0)
server A: the client's requests: GET /probe/people/Ravi 200 · the entry point's link: http://127.0.0.1:<port>/probe/people/Ravi
server B (moved to /probe/members): the client printed: the member -> 404 (exit 1)
server B: the client's requests: GET /probe/people/Ravi 404 · the entry point's link: http://127.0.0.1:<port>/probe/members/Ravi
FAIL clause 3: server A's access log does not show GET /probe/entry before the member request (1 lines)
FAIL clause 2: against server B the client does not print Ravi with exit 0 (exit 1)
FAIL clause 3: server B's access log does not show GET /probe/entry before the member request (1 lines)
FAIL clause 5: on server B the client's member request (/probe/people/Ravi) is not the href the entry point answers (/probe/members/Ravi)
FAIL clause 4: the client's source writes the member's path in
check.sh: 5 clause(s) failed
```

Against server A the shipped client reads Ravi. Against server B it gets the problem answer for a path nothing serves, while the
entry point on the same server already names the new path.

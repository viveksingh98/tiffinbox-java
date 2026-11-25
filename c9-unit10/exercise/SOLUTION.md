# Solution — unit 10

Write the committed file again from the running copy, by unit 08's rule (`GET /v3/api-docs`, `servers` removed, the fixed JSON form
with a final newline); the next build generates the client again from it. The receipt makes it with `apply.sh` and checks it, as
`check.sh` runs it:

```
sh apply.sh my-tiffinbox
sh check.sh my-tiffinbox
```

What it prints
```
the generated call: 200 Ravi · its PATH_ONE constant /api/v1/customers/{name} · the served document's address for it /api/v1/customers/{name}
PASS: the generated public read answered 200 Ravi at the served address; the committed file is the served document; the hand-written parts as ../after's
```

The receipt's refused variants, each its own copy and start: nothing changed (clause 1), the generated constant edited by hand under
`target/` (the clean build writes it again: clause 1), and the server's mapping moved to the broken address (the call answers, but the
served document then gives the operation `one` to another route: clause 1).

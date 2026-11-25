# Unit 12's exercise: the solution

The solution is a reading, not an edit: start the retired tree, send the old request, save the answer. The receipt runs it as

```
sh break.sh my-tiffinbox
sh apply.sh my-tiffinbox
sh check.sh my-tiffinbox
```

`apply.sh` builds the retired tree, starts its jar alone on H2, sends `GET /api/v1/customers/Ravi`, and writes `answer.http` from what
TiffinBox answered: the status line, the headers with `Date` masked, and the body. The old client gets a four hundred whose `detail`
names the version it asked for, as the resolver reads it, and the handler that used to answer it is still mapped.

What it prints:

```
the live answer to the old request: 400 · detail: Invalid API version: '1.0.0'.
PASS: the saved answer is the old request's, its status 400 and its detail the live answer's; the tree is the retired tree
```

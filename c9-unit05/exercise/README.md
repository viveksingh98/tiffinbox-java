# Exercise · PATCH Properly: JSON Patch and Merge Patch

**Your turn:** this PATCH sends Meera's meals as plain JSON and the server refuses it. Send it so only her meals change.

Start TiffinBox (unit five's `after`, the default run, H2 in memory), then, from this folder:

```sh
sh check.sh
```

`check.sh` removes the status the patch saves (`patch.status`), reads Meera and the month's revenue, runs `patch.sh`, and reads
both again. `/revenue` is a sum the database computes on every ask, and the route empties Meera's cache entry after a write, so
neither reading can come from a stale cache. It passes only when the status is a two hundred AND Meera's meals a day are `2` AND
her price and meal type are kept AND `/revenue` moved by exactly that change. As shipped `patch.sh` is broken: its asking line
sends the patch with `Content-Type: application/json`, and the answer names the two media types the route takes in its
`Accept-Patch` header.

What it prints (the broken patch; the capture `exercise`, bash and zsh alike):

```
PATCH /api/v1/customers/Meera {"mealsPerDay":2} · status 415 · Accept-Patch (sorted): application/json-patch+json application/merge-patch+json
Meera before: 1 meals a day, 150 a meal, NON_VEG · after: 1, 150, NON_VEG · revenue 24300 -> 24300
FAIL: status 415 · meals 1
```

The fix is one line of `patch.sh`: see `SOLUTION.md`.

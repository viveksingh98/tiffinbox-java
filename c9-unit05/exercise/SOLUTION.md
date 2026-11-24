# Solution · PATCH Properly: JSON Patch and Merge Patch

One line of `patch.sh` changes - its asking line. Send the same body as a merge patch, `application/merge-patch+json`:

```sh
curl --noproxy "*" -sS -D patch.head -o patch.body -w '%{http_code}\n' -X PATCH -H "Content-Type: application/merge-patch+json" --data-binary "$BODY" "$B/api/v1/customers/$WHO" > patch.status
```

What it prints (the capture `exercise`, bash and zsh alike):

```
PATCH /api/v1/customers/Meera {"mealsPerDay":2} · status 200 · Accept-Patch (sorted): 
Meera before: 1 meals a day, 150 a meal, NON_VEG · after: 2, 150, NON_VEG · revenue 24300 -> 28800
PASS: status 200 · only her meals changed
```

What it measured: the merge patch names only `mealsPerDay`, and JSON-P's `createMergePatch` keeps every member it does not name,
so her price and meal type stay as they were. The capture also runs four refused "solutions", each `patch.sh` with one more line
changed, and each fails `check.sh`: the same body sent as `application/json-patch+json` (a four hundred: a JSON Patch is an array
of operations), `{"mealsPerDay":2,"mealType":null}` (a four twenty-two: in a merge patch, null removes the member, and the document
after the patch is not a valid customer), `{"mealsPerDay":"two"}` (a four twenty-two: the document after the patch cannot be read), and the
right patch sent to Ravi (a two hundred, but Meera did not change).

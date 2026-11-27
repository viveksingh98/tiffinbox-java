# Exercise — the stale tag (Course 9 · ETags and Conditional GET)

**Your turn:** the PATCH ignores If-Match. Make a stale version answer 412 and change nothing.

The broken tree is `../after` with one edit: `break.sh` removes the `If-Match` check that both `PATCH /api/v1/customers/{name}` routes
share, in `CustomerPatches.apply`. Copy `../after` somewhere, break the copy, then run the check against it:

```
cp -R ../after /tmp/tiffinbox-ex && sh break.sh /tmp/tiffinbox-ex && sh check.sh /tmp/tiffinbox-ex
```

`check.sh` builds the tree offline, starts its jar alone on `21098` (H2, a fresh database, the default settings), reads Ravi's tag from
`GET /api/v1/customers/Ravi`, sends a merge `PATCH` with it, then sends the old tag again on both routes. On the broken tree the old tag
writes: the second `PATCH` answers two hundred and Ravi reads back changed - what a writer gets when the precondition is ignored.

What it prints (the broken tree, H2, measured by this unit's receipts under bash and `zsh -f`; `after/` answers the old tag `412`
and writes nothing)
```
measured: tag "v0" · PATCH with it -> 200, the tag now "v1" · the old tag again (merge) -> 200 · (JSON Patch) -> 200 · W/ of the current -> 200 · no If-Match -> 200
FAIL (2) the old tag on the merge PATCH answered 200 and Ravi reads CHANGED: a stale tag wrote
FAIL (3) the old tag on the JSON Patch answered 200 and Ravi reads CHANGED
FAIL (4) a weak form of the current tag answered 200
check.sh: 3 clause(s) failed
```

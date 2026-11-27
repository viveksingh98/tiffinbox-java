# Solution — the stale tag

Put the check back where both routes pass, in `CustomerPatches.apply`, on the line below the version read:

```java
        if (request.checkNotModified(CustomerReads.tag(row.version()))) {
            return refuse(HttpStatus.PRECONDITION_FAILED, "Precondition failed", "the customer has changed since the tag in If-Match was read");
        }
```

`checkNotModified` compares the request's `If-Match` with the row's tag, strongly: a stale tag or a `W/` form of the current one does not
match, and the route answers `412` before `update` runs, so nothing is written. A request without `If-Match` is not refused: it writes as
before. `sh apply.sh TREE` makes exactly this edit (the file then byte-equal to `../after`'s), and `check.sh` passes.

What it prints (the solved tree, H2, under bash and `zsh -f`)
```
measured: tag "v0" · PATCH with it -> 200, the tag now "v1" · the old tag again (merge) -> 412 · (JSON Patch) -> 412 · W/ of the current -> 412 · no If-Match -> 200
PASS
```

# The exercise — a key the caller picks

**Your turn:** this limiter keys on a header the client picks. Key it on the client's address, and show the forged header stops helping.

`sh break.sh TREE` (TREE is a copy of `../after`; `../after` itself is refused) edits one line of
`tiffinbox-web/src/main/java/com/tiffinbox/web/RateLimitFilter.java`: the bucket's key becomes the header `X-Api-Key` when the request
carries one, and the client's address only without it. Build the tree (`mvn -o -DskipTests clean package -pl tiffinbox-web -am`), start
its jar with `--tiffinbox.rate-limit.capacity=5`, and send `GET /api/v1/customers/Ravi` with `curl -i` until the refusal comes. Then send
the same request with `-H 'X-Api-Key: forged-1'`, and again with `forged-2`. Fix the key line, and show both forged requests are refused.

`sh check.sh TREE` builds the tree, starts its jar alone (H2 in memory, the capacity five by a run flag), sends the requests itself, and
passes only if five reads are let through and the sixth refused, both forged keys after that refusal are refused too, a forged
`X-Forwarded-For` is refused, no other source file differs from `../after`'s, and the filter reads no request header.

What it prints on the broken tree (measured on the route the exercise names, H2):
```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
started: the jar alone, H2, --tiffinbox.rate-limit.capacity=5 (a run flag)
GET /api/v1/customers/Ravi x6 -> 200 200 200 200 200 429
measured: X-Api-Key forged-1 -> 200 (Retry-After lines 0) · forged-2 -> 200 · X-Forwarded-For 10.0.0.1 -> 429
FAIL (2) a forged X-Api-Key after the 429 answered 200, 200 (Retry-After lines 0): the key is a header the caller picks
check.sh: 1 clause(s) failed
```

The existing tests still pass on the broken tree; `RateLimitFilterTest`'s forged-header test does not. H2 only.

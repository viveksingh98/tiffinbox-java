# The exercise — the solution

The key is the address the container gives, and nothing the caller sends: the key line goes back to
`buckets.forAddress(request.getRemoteAddr())`, as `../after`'s `RateLimitFilter.java` has it (`sh apply.sh TREE` makes that edit and
checks the file is byte-equal to `../after`'s). A forged `X-Api-Key` is then counted under the address, and so is a forged
`X-Forwarded-For` at Boot's default.

What it prints after the fix (H2):
```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
started: the jar alone, H2, --tiffinbox.rate-limit.capacity=5 (a run flag)
GET /api/v1/customers/Ravi x6 -> 200 200 200 200 200 429
measured: X-Api-Key forged-1 -> 429 (Retry-After lines 1) · forged-2 -> 429 · X-Forwarded-For 10.0.0.1 -> 429
PASS
```

The address is still not an identity: callers behind one address share a bucket, and a caller who can change its address is not stopped.
Who a caller is belongs to *Spring Security — complete*.

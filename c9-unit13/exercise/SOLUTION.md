# Unit 13's exercise — the solution

Put the whitelist back: look the sort up by name in `SORTS`, and refuse a name it does not hold with the route's own problem type,
`sort-unknown`, naming the four sorts. The cursor's binding needs no new line: it compares the sort the cursor was written for with the
sort the request asks, so a cursor stays bound once the sort is one of the four. `sh apply.sh TREE` makes exactly that edit on a broken
copy, byte for byte as `../after` has it; then `sh check.sh TREE` passes.

What it prints on the solved copy (measured by the receipts, H2):

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
sort=nosuch -> 400 application/problem+json · type tag:tiffinbox.example,2026:sort-unknown · detail sort must be one of [newest, oldest, amount, customer]
a newest cursor reused with sort=oldest -> 400 application/problem+json · type tag:tiffinbox.example,2026:cursor-mismatch · detail this cursor was written for another request: sort (the cursor's newest, this request's oldest)
sort=newest -> 200 application/json · ids [19, 20, 17, 18, 15]
the JVM's log: lines naming an Exception 0
PASS - every clause holds
```

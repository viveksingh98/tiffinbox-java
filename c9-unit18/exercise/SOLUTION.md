# Course 9 · Binary Payloads — the solution

In `CustomerBills.java`, declare the signed download as the bill route is declared, as `../after` has it:

```java
    ResponseEntity<StreamingResponseBody> signedBill(@PathVariable String name, @RequestParam(required = false) String expires,
```

`sh apply.sh TREE` makes that edit in a broken copy (the file then equals `../after`'s, asserted), and `sh check.sh TREE` passes. The
handler returns a streaming body inside a `ResponseEntity`; declared with its body type, Spring MVC streams it. Declared as
`ResponseEntity<Object>`, the copy answered as the wildcard did and fails clause 2 and clause 6; the fix made in another file as
well fails clause 5; a fixed CSV literal in place of the bill fails clause 2; a signed route that stops checking the signature fails
clause 4.

What it prints:

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
started: the jar alone, H2, the shipped lifetime (no flag)
GET /api/v1/customers/Ravi/bill-link -> 200 · href /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked>
measured: the signed download -> 200 text/csv;charset=UTF-8
measured: the bill route -> 200 text/csv;charset=UTF-8
the name changed in the link -> 403
the signed handler's declared type: ResponseEntity<StreamingResponseBody>
PASS - every clause holds
```

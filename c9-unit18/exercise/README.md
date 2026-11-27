# Course 9 · Binary Payloads — the exercise

**Your turn:** this download route answers with an error, though the bill streams fine elsewhere. Find the declared type that breaks it.

`../after` is TiffinBox after this unit: `GET /api/v1/customers/{name}/bill` streams the bill, `GET /api/v1/customers/{name}/bill-link`
mints a signed link to it, and `GET /api/v1/customers/{name}/bill/signed` checks the link before it streams the same bill. `break.sh`
changes one line of `CustomerBills.java` in a copy of `../after`: the signed download's declared return type. Your job is to find that
line and declare the type the handler really returns, in `CustomerBills.java` alone.

```
cp -R ../after /tmp/u18-tree        # any copy; ../after itself is refused
sh break.sh /tmp/u18-tree
sh check.sh /tmp/u18-tree           # builds the copy offline, starts it alone on 21078 (H2, the shipped lifetime), sends the requests itself
```

`check.sh` passes only when every clause holds: the mint answers `200` with an `href` that carries `expires` and `sig`; the minted
link opens `200` as `text/csv`, byte for byte the bill route's answer in the same run; the bill route answers `200`; the
link with the name changed answers `403`; every other main file, the three poms and the spec equal `../after`'s; and the signed
handler is not declared with a wildcard, with `Object` or as a raw `ResponseEntity`.

The broken copy, measured first on the route the exercise names (H2; host `127.0.0.1:<port>`; the receipts' `exercise` capture, every
run): the signed download answers `500` as `application/problem+json`, its `detail` `Failed to write request`, while the bill route on
the same JVM answers `200`.

What it prints:

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
started: the jar alone, H2, the shipped lifetime (no flag)
GET /api/v1/customers/Ravi/bill-link -> 200 · href /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked>
measured: the signed download -> 500 application/problem+json · title Internal Server Error · detail Failed to write request
measured: the bill route -> 200 text/csv;charset=UTF-8
the name changed in the link -> 403
the signed handler's declared type: ResponseEntity<?>
FAIL (2) the minted link does not open 200 text/csv with the bill's own bytes (got 500 application/problem+json)
FAIL (6) the signed handler is declared ResponseEntity<?> - a wildcard, Object or raw type
check.sh: 2 clause(s) failed
```

Hint: the bill route and the signed download return the same helper's answer; compare the two declarations.

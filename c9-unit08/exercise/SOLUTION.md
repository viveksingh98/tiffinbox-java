# Solution — unit 08

The operation is `customer-reads-one`, `GET /api/v1/customers/{name}`: open it, Try it out, type `Ravi`, Execute. The page sends one
request; TiffinBox's access log holds its line, with the page as its Referer. The receipt does the same clicks in a headless sealed
Chrome with `apply.sh` (the harness's `cdp9.mjs`), as `check.sh` runs it:

```
VISIT="sh apply.sh" sh check.sh my-tiffinbox
```

What it prints
```
PASS: one request from the page, GET /api/v1/customers/Ravi 200 (the access log, Referer the page)
```

The old route's read by name (`GET /customers/{name}`, under `tiffin-box-server`) answers Ravi too, and the check passes on it - the
near miss the receipt runs once. A `curl` of Ravi has no page as its Referer and fails clause 1; Meera fails clause 3; two requests fail
clause 2; the page opened with nothing executed fails clause 1.

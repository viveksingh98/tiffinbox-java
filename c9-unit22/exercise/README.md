# Exercise: read the body into the record

**Your turn:** this route reads the body onto the entity. Read it into the record, so another customer's id never reaches the row.

Start from a copy of `../after` and break it: `sh break.sh <your copy>`. It adds one file to your copy,
`tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerOverwrite.java`: `PUT /exercise/customers/{name}` finds the row the URL names
and reads the request body onto that `CustomerEntity` with Jackson's `readerForUpdating`, then saves it. No shipped route does this;
the route exists only in your copy. Then run the check against your copy: `MAVEN_REPO=<an offline repository> sh check.sh <your copy>`.
It builds your copy's web jar offline, starts it on port `21168` (H2 in memory), sends Sunil's row a body carrying Ravi's `id` and
Meera's row a body carrying Priya's `id`, and reads Ravi and Priya back.

What it prints on the broken copy (measured by `../receipts.sh`, the `exercise` capture):

```
(1) PUT /exercise/customers/Sunil <- Ravi's id 1 at version 0 -> 200 · Ravi reads back: Ravi 404 · Mallory: Mallory 3 100 VEG
FAIL (1) another customer's id reached Ravi's row
(2) PUT /exercise/customers/Meera <- Priya's id 4 at version 0 -> 200 · Priya reads back: Priya 404 · Eve: Eve 1 150 NON_VEG
FAIL (2) another customer's id reached Priya's row
(3) PUT /exercise/customers/Sunil <- a whole body, no id -> 200 · Sunil reads back: Sunil 2 100 VEG
(4) the files other than CustomerOverwrite.java byte-equal to ../after's: yes
```

The route answered `200` both times, and both times it wrote another customer's row: the body's `id` reached the entity, so the save
went to Ravi's row, and Ravi is gone. The check passes only when Ravi's and Priya's rows read back unchanged, the route still writes
the row its URL names, and no other file moved. Reading the body onto the entity with `FAIL_ON_UNKNOWN_PROPERTIES` switched on still
fails it (`id` is a member the entity has), and so does a route that answers `200` and writes nothing.

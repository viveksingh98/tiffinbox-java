# Course 9 · Binary Payloads — evidence

```
A signed link to Ravi's bill opens it. Change one name in the link, and TiffinBox refuses it; let it expire, and it refuses again.
```

What is measured behind that hook: a link minted by `GET /api/v1/customers/Ravi/bill-link` opens the bill with the bill route's own bytes;
the same link with the name changed answers a four oh three of the signature's type; the same link, valid when minted on a start with the
harness's own lifetime (`lifetime=short`), answers a four oh three of the type `link-expired` when it is asked again past its end. Nothing is
said of what a store does with a presigned URL: no store was run.

```
A presigned URL: an address that carries its own permission and expiry.
```

The gloss line above is the brief's, byte for byte; the prose gate refuses it as a spoken sentence (S2's family, on its last word), so it stands
in a fenced block and the smallest passing form, "A presigned URL: an address that carries its own permission and its own end.", is
handed to RED and the scripts stage.

Course 9's fourteenth anchor change, Section 3's sixth and last unit. `before` is a link to `../c9-unit17/after`; `after/` is the frozen
copy of `../c9-tiffinbox` after this unit's change. Every number below names its tree and its capture; every capture says which database
answered (H2, in memory, a fresh one per JVM, unless a line says PostgreSQL).

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first and last line, each ending
`c9-unit18: every capture = published (21)`, and `check_unit9.py 18 --runlog` read on each run log (its unit gate exits `2` until the
script of this unit exists, as expected; the run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder.
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed copy of the repository in a folder whose path holds a space (R.129).

As run (2026-11-27, on the script as committed; each log's `check_unit9.py 18 --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, in this folder, load `2.66 3.39 3.56` at the start and `4.54 4.12 3.81` at the end; every capture = published (`21`); run-log gate PASS.
- run 2: bash `5.3.9`, in this folder, load `4.54 4.12 3.81` at the start and `4.09 4.10 3.90` at the end; every capture = published (`21`); run-log gate PASS.
- run 3: bash `3.2.57`, in the sealed copy (`…/sealed clone/tiffinbox-java/c9-unit18`), load `3.92 4.07 3.89` at the start and `3.45 3.85 3.88` at the end; every capture = published (`21`); run-log gate PASS.

These lines and the flag 31 section were written after run 3; the prose gate, the gloss, the values block and the static check were
run again on this README as committed: refused `0`, the values block equal, static FAIL `0`.

## RE-MEASURE (settled first, each by its capture)

- **1** `advisory` — the read filed for this unit, `_research/docs-2026-11-27/advisories/`, `fetched-at.txt` naming the run's own `2026-11-27`, every `MD5SUMS.txt` line
  verified, `25` ids on Spring's first page, Tomcat's page `a1a756d9…`, OSV `38` results with `0` vulns (the other witness only, S2.8). The
  shipped tree's coordinates are read off `after/`'s `BOOT-INF/lib`: no SDK jar there. The harness's presigner class path, `50` jars, is
  set against the read's `38` coordinates: `apache5-client` `2.59.10` is in it; `18` coordinates are not (named in the capture:
  `httpclient5` `5.6.5`, `httpcore5` and `httpcore5-h2` `5.4.4`, the Netty jars `4.2.20.Final`, `slf4j-api` `2.0.20`) - not read, not said.
  Verdict: no pin affected; this unit adds no jar.
- **2** `before` — on `before` (21076, U17's `after`) the three new addresses answer `404`; `GET /api/v1/customers/Ravi` `200`; an unknown
  billing run `404` with unit 17's type (an old route now); `GET /api/v1/orders/1` `200` with curl's size equal to the file's; no mapping
  with `bill` in its path; the committed spec `18` operations and `16` paths, `30801` bytes, `3cda0901…`; `BOOT-INF/lib` `164` names.
- **3** `change` — one new controller, one new test class, the spec, the anchor's README, and `application.yaml`'s one key and its comment:
  the derived changed list is these five and nothing else; no pom moved; the old classes byte-equal; the handler names each once.
- **4** `census` — `16/10/1/5` on `before`, `17/11/1/5` on `after/`: `CustomerBills` is the one row added, final and default-run.
- **5** `harness` — the presigner's POM built offline (`Downloading from` `0`), its class path `50` jars rewritten to the container's `/seed`
  mount; `Presign.java`'s named diff against the probe's; the blob classes compiled outside the module; no SDK class and no probe class
  in the web jar, no pom naming the SDK.
- **6** `proxy` and `declared` — the bill on the wire, H2, host `127.0.0.1:<port>`: `200`, `text/csv;charset=UTF-8`, `Transfer-Encoding:
  chunked`, no `Content-Length`, the `Content-Disposition` read off the wire; curl's `595` bytes equal the saved file's `595` and its
  `32` lines; the access log's `%b` counts `607` - the body plus the chunk framing, so the three witnesses are not all equal and are not
  said to be. The rows are the bill of *File Upload and Download*, rebuilt from V2's row by the receipt: the diff is empty. The total row
  equals `monthlyBill()`'s arithmetic. The harness's blob route (21077, the harness joined): `200`, `application/octet-stream`, chunked,
  `8388608` bytes by curl and by the saved file, the access log's `%b` `8396805`. The failure receipt: the signed download declared
  `ResponseEntity<?>` on a scratch copy answered `500`, `application/problem+json`, its `detail` `Failed to write request`, with `0` log
  lines for it by the printed grep; the bill route on the same JVM answered `200`; `after/`'s declared type answered `200`.
- **7** `signed` — on `after/` (21070, H2, anonymous): the mint `200` `{href}`, a path; the link opens `200` with the bill route's own bytes and
  `Content-Disposition`; the name changed `403` `link-signature-invalid`; `expires` raised with the old `sig` `403`, the same type; one
  character of `sig` changed `403`, the same type. The lifetime read back by three witnesses - the yaml's line, the start's log line, the
  minted `expires` inside the bracket of the harness's own clock - all equal, every value masked. The planted `ttlSeconds` (the BLUE
  value) answered `400` `parameter-unknown` and minted no link. On 21075, `lifetime=short (the harness's)` on the printed command line:
  the link opened `200` when it was minted; asked again by its condition, the first refusal was `403` `link-expired`, and once more the
  same; a tampered link past its end answered the signature's type (the signature is checked first). A link from another start answered
  `403` `link-signature-invalid` (this start's key). The mint is open: no credential minted Sunil's link and it opened `200`.
- **8** `presign` and `defaults` — each run of the harness's presigner in its own container with no network: the `docker -H` run line by digest
  with `--network none`, `--pull never` and every mount read-only; inside, before any Java, `/proc/net/dev` listed `lo` only and
  `/proc/net/route` held no row; then, with a fake test credential, the URL's query keys in order were the six `X-Amz-*` keys,
  `AWS4-HMAC-SHA256`, signed headers `[host]`, the signature `64` hex characters, masked. Left to its defaults, the credentials chain
  failed at its last provider, `InstanceProfileCredentialsProvider()`, "Failed to load credentials from IMDS."; with no region, the region
  chain failed at `InstanceProfileRegionProvider`, "Unable to contact EC2 metadata service.". Each container removed with its volumes.
- **9** `expect` — the old `POST /customers/import`, not a witness for the new routes: curl's trace gives the order - the request's
  `Expect: 100-continue`, then curl's receipt of `HTTP/1.1 100`, then the first body bytes, then `HTTP/1.1 413`. The CSV is `2097164` bytes;
  how many body bytes curl had sent when the refusal came is run-variant and not said - in this unit's runs it was fewer than the whole
  body, so the brief's "the whole body, then the refusal" is not what the capture shows, and only the order is said. With `-H 'Expect:'`
  the answer was `413` and no `100` was in the trace. The limit is Boot's `spring.servlet.multipart.max-file-size`, `1MB` in
  `spring-boot-servlet` `4.1.3`'s metadata, not overridden in `application.yaml`.
- **10** `refuse` — every refusal of the three routes, each read by python (the table under the captures).
- **11** `specwire` — the three routes' served entries against their wires, every difference named as a gap.
- **12** `spec` — the committed spec regenerated: `30801` -> `36164` bytes, `202` lines added and `0` removed, three paths added, no old path
   moved, one schema added (`BillLink`); operations `18` -> `21`, paths `16` -> `19` by the harness's counter (`ops9s3.py`, BLUE's) on each tree; the old operations'
   ids equal; `OpenApiSpecTest` passing on the regenerated file; the client rebuilt on it, its test passing.
- **13** `moved` — U17's requests on `before` and `after/`: `0` moved; the new routes `404` on `before` and `200` on `after/` - the added
   routes, not a move. The web jar gained two entries (`CustomerBills` and its `BillLink` record) and removed none; one shared
  entry's CRC moved, `BOOT-INF/classes/application.yaml` - the key, named.
- **14** The seven and the old surface — their hashes (the values block) on both trees, equal to the expected ones read off the earlier receipts: not witnesses for the new routes (they send nothing to
   them, R.511).
- **15** `tests` — web `71` -> `78` at `mvn package` (`CustomerBillsTest` `7`, `0` skipped), client `1`; the Docker-free twin and the web-only
   form the same; `verify`: `14` ITs on PostgreSQL in their containers, five `IT BINDINGS` lines all `127.0.0.1`; the slice unedited.
- **16** `exercise` — broken and solved under bash and `zsh -f`; the broken copy measured first on the signed download: `500`, the bill route
   on the same JVM `200`.
- **17** `section` — Section 3's five earlier commits, the spec's counts at each frozen `after/`, and up next by title only: *Rate Limiting*.

## The change, file by file, and every README/Javadoc sentence it rewrote or noted (R.250/R.453)

- NEW `tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerBills.java` — one final controller, three `GET` routes: `bill`, `billLink`,
  `signedBill`; both downloads declared `ResponseEntity<StreamingResponseBody>` and answered by one private helper; the signature
  compared with one `MessageDigest.isEqual`; every refusal an `ErrorResponseException` from `ProblemDetail.forStatusAndDetail`, as
  `BillingRuns` writes them. Its Javadoc says what it does not do: no identity (Course 10's *The Threat Model First*, once), no
  revocation, no store, no list, no key handling.
- NEW `tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerBillsTest.java` — seven MockMvc tests on a context of its own lifetime.
- `tiffinbox-web/src/main/resources/application.yaml` — one key, `tiffinbox.bill-link-lifetime`, and its four comment lines, beside
  `kitchen-order-ttl`; no other line moved.
- `tiffinbox-web/src/test/resources/openapi/tiffinbox.json` — regenerated from the served document (servers removed, indent 2).
- `README.md` (the anchor's) — a note under the unit 17 note, and this unit's card (`## Course 9 · unit 18`). The stale-sentence
  hunt (`git grep -n -i` over the anchor's README and the Javadoc touched, for `bill`, `signed`, `link`, `presign`, `lifetime`,
  `ttl`, `operations`, `paths`, the spec's byte count, the web count and the rest of flag 20's list): the unit 16 and 17 cards' "the bill and
  its signed link" line stays as history, and this unit's note says it is paid here; the cards' operation, path, byte and web counts are noted as true at unit 17 (`operations 18`, `16 paths`, `30,801`, `71`), with this unit's card giving the counts since. `Dockerfile` and
  `compose.yaml` hold no setting of this unit; `application.yaml` holds the lifetime key once, no key setting, no compression,
  forwarded-header, HATEOAS, billing or pause key.

## Which tree, which profile

Every capture's TiffinBox runs on H2 in memory, a fresh database per JVM, with no profile; PostgreSQL `18.6` appears only in `verify`,
in Testcontainers containers. The presigner's container is `eclipse-temurin:25-jre` by its digest `fcd7fd7b…`, on the daemon before the
run, never pulled. `before` is U17's `after`; `after/` is this unit's; the scratch copy of the failure receipt is `after/` with the
exercise's one edit; the harness-joined start (21077) is `after/`'s jar with the harness's classes beside it, and no claim about a
shipped route is read from it.

## This unit's section

- Spine [S3B :279-:281]: the bill of *File Upload and Download*, now on the public API, streamed through TiffinBox (`proxy`); TiffinBox's
  own signed link, minted and checked by TiffinBox, its lifetime the server's (`signed`); the presigned URL as the pattern that link
  follows, computed by the harness's presigner in a container with no network (`presign`), the store named and never shown.
- Hook: the fenced line at the top, measured by `signed` (i), (ii) and (vii).
- The failure receipt: `declared` - the wildcard declaration answered `500` `Failed to write request`; the declared type answered `200`.
- Hazards [S3B :294-:295]: a streamed CSV documented `*/*` unless annotated - annotated here, and `specwire` names what the spec still
  cannot say (the chunked framing, the charset, the CSV's columns); the open mint - said on screen once, with Course 10 by title.

## The captures — what each one shows

The code panel: `CustomerBills.java` and `CustomerBillsTest.java` are printed whole in `change`. The bill's head, as `proxy` printed it:

```
proxy | GET /api/v1/customers/Ravi/bill -> 200 text/csv;charset=UTF-8 595 · status line HTTP/1.1 200 <none>
proxy | header Content-Disposition: attachment; filename="bill Ravi.csv"; filename*=UTF-8''bill%20Ravi.csv
proxy | Content-Length: absent · Transfer-Encoding: chunked
proxy | first lines: day,customer,meals,price per meal,amount|1,Ravi,2,120,240 · last line: month,Ravi,60,120,7200
proxy | the three byte witnesses: curl's size_download 595 · the saved file's wc -c 595 · the access log's %b 607
```

### advisory

```
fetched-at 2026-11-27 (the hour masked) · run date 2026-11-27
MD5SUMS.txt: 6 lines, 6 verified (its own line left out)
spring index: CVE ids on its first page 25
tomcat page md5 a1a756d985225fb5143eefd9aae3183c
shipped | awssdk jars in after/'s lib: 0
harness | not in the read's 38 coordinates: 18 - slf4j-api 2.0.20, httpclient5 5.6.5, httpcore5-h2 5.4.4, httpcore5 5.4.4, netty-codec-http 4.2.20.Final, netty-codec-base 4.2.20.Final, netty-codec-compression 4.2.20.Fina
osv (second witness only, S2.8): 38 results, 0 with vulns
verdict: no pin affected; evidence may proceed; this unit adds no jar; the harness's coordinates not in the read are named, not said
```

### before

```
before | GET /api/v1/customers/Ravi/bill -> 404 application/problem+json · Allow {}
before | GET /api/v1/customers/Ravi/bill-link -> 404 application/problem+json · Allow {}
before | GET /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked> -> 404 application/problem+json · Allow {}
before | GET /api/v1/orders/1 -> 200 application/hal+json 225 · file 225 B
before | GET /api/v1/customers/Ravi -> 200 application/json 67 · file 67 B
before | GET /api/v1/billing-runs/<uuid> -> 404 application/problem+json 244 · file 244 B · type=tag:tiffinbox.example,2026:billing-run-unknown
before | mappings 33 · with bill in the path 0: [] (rule: the request-mapping patterns of the dispatcher servlet)
before | the committed spec: OPERATIONS 18 PATHS 16 · 30801 B md5 3cda0901be31567ce4c73f17652a5e29
before | BOOT-INF/lib names 164
```

### change

```
poms before -> after/: equal
changed (derived: diff -rq before after/, the frozen trees - git status --short gave the same list before the commit): A tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerBills.java · A tiffinbox-web/src/test/java/co
* <p>Seven tests: the bill's rows are Course 6's (the header, a row a day, the month's total = monthlyBill); a minted link opens the same
CustomerBills grep ResponseEntity<?>: 0 lines · src/main before 5 · after 5 (the old routes' own)
CustomerBills grep ResponseEntity<Object>: 0 lines · src/main before 0 · after 0 (the old routes' own)
the declared types of the shipped handlers: ResponseEntity<StreamingResponseBody> bill|BillLink billLink|ResponseEntity<StreamingResponseBody> signedBill
the checks' order in signedBill: refuseParameters link-malformed MessageDigest.isEqual link-expired csv(customer
application.yaml bill-link-lifetime keys: before 0 · after 1
handler bill: 1 occurrence(s) among the mapped handlers
handler billLink: 1 occurrence(s) among the mapped handlers
handler signedBill: 1 occurrence(s) among the mapped handlers
handler billingRun: 1 occurrence(s) among the mapped handlers
the bill's rows: 2 row writers · DAYS = 30 · monthlyBill(): return mealsPerDay * pricePerMeal * 30; · application.yaml's tiffinbox.days 30 (the dev fill's, not read by the bill)
routes that throw CustomerNotFound (R.510): before CustomerPatches.java,CustomerPauses.java,CustomerReads.java,TiffinBoxServer.java · after CustomerBills.java,CustomerPatches.java,CustomerPauses.java,CustomerReads.java,T
```

### census

```
census before | BillingRuns      final yes dev-only no  BillingRuns.java:56
census before | controllers 16 · final, default-run 10 · not final, default-run 1 · not final, dev-only 5 · other 0
census after | BillingRuns      final yes dev-only no  BillingRuns.java:56
census after | CustomerBills    final yes dev-only no  CustomerBills.java:66
census after | controllers 17 · final, default-run 11 · not final, default-run 1 · not final, dev-only 5 · other 0
```

### harness

```
presign | build: mvn -o -B -f harness/presign/pom.xml -DskipTests package (a copy under .harness/presign) · exit 0 · Downloading from: 0
presign | the POM's parent: spring-boot-starter-parent 4.1.3 · awssdk.version 2.59.10 · its R.515 comment names the parent line: 1 · the measured surface: 1 · the word compatible: 0
presign | the class path: 50 jars · rewritten to /seed: 50 · the SDK: s3-2.59.10 apache5-client-2.59.10 netty-nio-client-2.59.10 · httpclient5 5.6.5
blob | U18Config.java against unit 16's U16Config.java (md5 1f24d8f8532ba891c89231189de014e8): the named diff md5 eb42f9ccff442ef5d0b7861f8b449ca6, 15 lines
blob | U18Blob's route: @GetMapping("/probe/u18/blob") · compiled by javac against after/'s extracted lib: U18Blob.class U18Config.class
jar | SDK classes in after/'s web jar: 0 · probe classes: 0 · the anchor's poms naming awssdk: 0
```

### proxy

```
proxy | the saved file: 595 B · 32 lines · md5 eb3e5716784f49f53954d6c3831c991a
proxy | Course 6's rows for Ravi (rows(), rebuilt from V2's row 2 120): 595 B, 32 lines · diff against the wire's file: empty
proxy | the total row against monthlyBill(): 7200 = 2 * 120 * 30 = 7200
proxy | access log: GET /api/v1/customers/Ravi/bill 200 607 "text/csv;charset=UTF-8"
proxy | Course 6's own capture (../c6-unit20/README.md, read): one chunk of 595 bytes
blob | the harness's blob route GET /probe/u18/blob?mib=8 -> 200 application/octet-stream 8388608 · Transfer-Encoding: chunked · Content-Length: absent · the saved file's wc -c 8388608 · the access log's %b 8396805 · hos
```

### declared

```
declared | the copy's declaration: ResponseEntity<?> signedBill · after/'s: ResponseEntity<StreamingResponseBody> signedBill
declared | the copy | the signed download -> 500 application/problem+json 129 · title=Internal Server Error · detail=Failed to write request · instance=/api/v1/customers/Ravi/bill/signed · status=500 · type absent (no ty
declared | the copy | JVM log lines after the start (a printed grep 'Failed to write|HttpMessageNotWritable|No converter'): 0
declared | the copy | the bill route on the same JVM -> 200 text/csv;charset=UTF-8 595
declared | after/ | its own freshly minted link (each start its own key: the same requests, not the same link) -> 200 text/csv;charset=UTF-8 595
```

### signed

```
signed | (i) mint Ravi -> 200 application/json 112 · href /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked> · body members ['href'] · the href a path: yes
signed | (i) open it -> 200 text/csv;charset=UTF-8 595 · body md5 eb3e5716784f49f53954d6c3831c991a · the bill route's body md5 eb3e5716784f49f53954d6c3831c991a · equal: yes · Content-Disposition equal: yes
signed | (ii) the name changed (Ravi -> Sunil, expires and sig kept) -> 403 application/problem+json 205 · type=tag:tiffinbox.example,2026:link-signature-invalid· detail=the signature does not match this link
signed | (iii) expires raised by a day's seconds, the old sig kept -> 403 application/problem+json 204 · type=tag:tiffinbox.example,2026:link-signature-invalid· detail=the signature does not match this link
signed | (iv) one character of sig changed -> 403 application/problem+json 204 · type=tag:tiffinbox.example,2026:link-signature-invalid· detail=the signature does not match this link
signed | (v) the lifetime read back: application.yaml's line <masked> · the start's log line <masked> · the mint's expires within [the harness's clock before + it, after + it]: yes · the three equal: yes
signed | (v) the start's log lines: the bill link's key: defaulted (random, this start only; tiffinbox.bill-link-key unset) | the bill link's lifetime: <lifetime> (tiffinbox.bill-link-lifetime)
signed | (vi) the planted client lifetime (ttlSeconds, the BLUE value) on the same JVM -> 400 application/problem+json 207 · type=tag:tiffinbox.example,2026:parameter-unknown· detail=unknown parameter [ttlSeconds]; this route reads n
signed | (viii) the mint is open: no credential minted Sunil's link -> 200 · opening it -> 200 text/csv;charset=UTF-8 626
signed | (vii) minted -> 200 · opened at once after the mint -> 200 (valid when minted)
signed | (vii) polled by its condition (status not 200 ends it; a 30 s alarm, a guard; the guard interval slept between polls) -> the first refusal 403 application/problem+json 166 · type=tag:tiffinbox.example,2026:link-expired· detail=th
signed | (vii) the same link once more -> 403 application/problem+json 166 · type=tag:tiffinbox.example,2026:link-expired
signed | (iv) tampered AND expired -> 403 application/problem+json 204 · type=tag:tiffinbox.example,2026:link-signature-invalid
signed | (ix) JVM-1 mint -> 200 · open -> 200
signed | (ix) JVM-2 the same link -> 403 application/problem+json 204 · type=tag:tiffinbox.example,2026:link-signature-invalid
signed | the link key and the fake test credential in this run's captures so far: 0 lines (the key is never logged: the JVM logs' key lines 8, each 'defaulted')
```

### presign

```
presign | docker run line: dk run --name c9u18-presign-static --network none --pull never -v <the seed copy>:/seed:ro -v <the harness's classes>:/h:ro -v <the class path file>:/r:ro --entrypoint sh eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636 -c '<the three prints, then java>' static (no published port)
presign | inspect: network mode, publish-all, ports: none false 0
presign | container exit 0 · removed: dk rm -fv c9u18-presign-static · left: 0
presign | PRESIGN static · OK · http://127.0.0.1:<port>/tiffinbox-bills/bill-Ravi.csv · query keys [X-Amz-Algorithm,X-Amz-Date,X-Amz-SignedHeaders,X-Amz-Credential,X-Amz-Expires,X-Amz-Signature] · X-Amz-Expires=<masked> · X-Amz-Algorithm=AWS4-HMAC-SHA256 · isBrowserExecutable true · signed headers [host] · expiration <masked> · signature <masked, 64 hex chars>
presign | before any Java: interfaces ['lo'] · route rows 0 · the presigner's line after both: yes
```

### defaults

```
defaults | container exit 0 · removed: dk rm -fv c9u18-presign-regiononly · left: 0
PRESIGN regiononly · FAILED · software.amazon.awssdk.core.exception.SdkClientException: Unable to load credentials from any of the providers in the chain AwsCredentialsProviderChain … the last: NTAINER_CREDENTIALS_RELATIVE_URI environment variables are set., InstanceProfileCredentialsProvider(): Failed to load credentials from IMDS.
defaults | before any Java: interfaces ['lo'] · route rows 0 · the presigner's line after both: yes
defaults | container exit 0 · removed: dk rm -fv c9u18-presign-default · left: 0
PRESIGN default · FAILED · software.amazon.awssdk.core.exception.SdkClientException: Unable to load region from any of the providers in the chain software.amazon.awssdk.regions.providers.DefaultAwsRegionProviderChain@<id>: … the last: software.amazon.awssdk.regions.providers.InstanceProfileRegionProvider@<id>: Unable to contact EC2 metadata service.
defaults | before any Java: interfaces ['lo'] · route rows 0 · the presigner's line after both: yes
```

### expect

```
expect | the harness's CSV: 2097164 B · curl 8.7.1
expect | POST /customers/import -> 413 application/problem+json · host 127.0.0.1:<port>
expect | the order of the events in curl's trace (--trace-ascii, no time): the request's Expect: 100-continue header -> curl's receipt of HTTP/1.1 100 -> the first body bytes sent -> curl's receipt of HTTP/1.1 413
expect | the 413's body: title=Content Too Large · detail=Maximum upload size exceeded · instance=/customers/import · status=413 · type absent (no type of TiffinBox's) · Content-Type application/problem+json
expect | the same with -H 'Expect:' (no Expect header) -> 413 · an HTTP/1.1 100 in its trace: 0
expect | the limit read back: spring.servlet.multipart.max-file-size in Boot's metadata: [('spring-boot-servlet-4.1.3.jar', '1MB')] · application.yaml overrides it: no
```

### refuse (each status, Content-Type, type; title and detail cut)

```
refuse | an unknown customer on the bill (GET /api/v1/customers/Nobody/bill) -> 404 application/problem+json | type=tag:tiffinbox.example,2026:customer-not-found· detail=no customer named Nobody · insta
refuse | an unknown customer on the mint (GET /api/v1/customers/Nobody/bill-link) -> 404 application/problem+json | type=tag:tiffinbox.example,2026:customer-not-found· detail=no customer named Nobody · 
refuse | an unknown customer on the signed download, its own link's sig (GET /api/v1/customers/Nobody/bill/signed?expires=<masked>&sig=<masked>) -> 403 application/problem+json | type=tag:tiffinbox.example,2026:link-signature-inva
refuse | a query parameter on the bill (GET /api/v1/customers/Ravi/bill?x=1) -> 400 application/problem+json | type=tag:tiffinbox.example,2026:parameter-unknown· detail=unknown parameter [x]; this route 
refuse | a query parameter on the mint (GET /api/v1/customers/Ravi/bill-link?x=1) -> 400 application/problem+json | type=tag:tiffinbox.example,2026:parameter-unknown· detail=unknown parameter [x]; this r
refuse | ttlSeconds on the mint (GET /api/v1/customers/Ravi/bill-link?ttlSeconds=315360000) -> 400 application/problem+json | type=tag:tiffinbox.example,2026:parameter-unknown· detail=unknown parameter [
refuse | a query parameter on the signed download (GET /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked>&x=1) -> 400 application/problem+json | type=tag:tiffinbox.example,2026:parameter-unknown
refuse | the name changed in the link (GET /api/v1/customers/Sunil/bill/signed?expires=<masked>&sig=<masked>) -> 403 application/problem+json | type=tag:tiffinbox.example,2026:link-signature-invalid
refuse | expires raised (GET /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked>) -> 403 application/problem+json | type=tag:tiffinbox.example,2026:link-signature-invalid· detail=the si
refuse | a missing sig (GET /api/v1/customers/Ravi/bill/signed?expires=<masked>) -> 400 application/problem+json | type=tag:tiffinbox.example,2026:link-malformed· detail=a link carries expires (a whole numb
refuse | a missing expires (GET /api/v1/customers/Ravi/bill/signed?sig=<masked>) -> 400 application/problem+json | type=tag:tiffinbox.example,2026:link-malformed· detail=a link carries expires (a whole numb
refuse | a non-numeric expires (GET /api/v1/customers/Ravi/bill/signed?expires=soon&sig=<masked>) -> 400 application/problem+json | type=tag:tiffinbox.example,2026:link-malformed· detail=a link carries expi
refuse | a sig of the wrong length (GET /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked>) -> 403 application/problem+json | type=tag:tiffinbox.example,2026:link-signature-invalid· de
refuse | POST on bill (POST /api/v1/customers/Ravi/bill) -> 405 application/problem+json | title=Method Not Allowed · detail=Method 'POST' is not supported.· status=405 · type absent (no typ
refuse | PUT on bill (PUT /api/v1/customers/Ravi/bill) -> 405 application/problem+json | title=Method Not Allowed · detail=Method 'PUT' is not supported.· status=405 · type absent (no type o
refuse | DELETE on bill (DELETE /api/v1/customers/Ravi/bill) -> 405 application/problem+json | title=Method Not Allowed · detail=Method 'DELETE' is not supported.· status=405 · type absent (
refuse | POST on bill-link (POST /api/v1/customers/Ravi/bill-link) -> 405 application/problem+json | title=Method Not Allowed · detail=Method 'POST' is not supported.· status=405 · type
refuse | PUT on bill-link (PUT /api/v1/customers/Ravi/bill-link) -> 405 application/problem+json | title=Method Not Allowed · detail=Method 'PUT' is not supported.· status=405 · type ab
refuse | DELETE on bill-link (DELETE /api/v1/customers/Ravi/bill-link) -> 405 application/problem+json | title=Method Not Allowed · detail=Method 'DELETE' is not supported.· status=405 
refuse | POST on bill/signed (POST /api/v1/customers/Ravi/bill/signed) -> 405 application/problem+json | title=Method Not Allowed · detail=Method 'POST' is not supported.· status=405 
refuse | PUT on bill/signed (PUT /api/v1/customers/Ravi/bill/signed) -> 405 application/problem+json | title=Method Not Allowed · detail=Method 'PUT' is not supported.· status=405 · t
refuse | DELETE on bill/signed (DELETE /api/v1/customers/Ravi/bill/signed) -> 405 application/problem+json | title=Method Not Allowed · detail=Method 'DELETE' is not supported.· statu
refuse | Accept: application/json on the bill (GET) -> 200 text/csv;charset=UTF-8 595 (the print decides: not a refusal)
refuse | HEAD on the bill -> 200 text/csv;charset=UTF-8
refuse | a trailing slash on the bill (GET /api/v1/customers/Ravi/bill/) -> 404 application/problem+json | title=Not Found · detail=No static resource api/v1/customers/Ravi/bill.· status=40
```

### specwire

```
spec | bill | GET /api/v1/customers/{name}/bill · operationId bill · responses ['200', '400', '404'] · 200 media ['text/csv'] · 200 schema [{'type': 'string'}] · 200 headers ['Content-Disposition'] · parameters [('name', 'path', 'string', True)]
wire | bill | Content-Type text/csv;charset=UTF-8 · Transfer-Encoding chunked · Content-Disposition present · Content-Length absent
spec | mint | GET /api/v1/customers/{name}/bill-link · operationId billLink · responses ['200', '400', '404'] · 200 media ['application/json'] · 200 schema [{'$ref': '#/components/schemas/BillLink'}] · 200 headers [] · parameters [('name', 'path', 'string', Tr
wire | mint | Content-Type application/json · Transfer-Encoding absent · Content-Disposition absent · Content-Length present
spec | signed | GET /api/v1/customers/{name}/bill/signed · operationId signedBill · responses ['200', '400', '403', '404'] · 200 media ['text/csv'] · 200 schema [{'type': 'string'}] · 200 headers ['Content-Disposition'] · parameters [('name', 'path', 'string',
wire | signed | Content-Type text/csv;charset=UTF-8 · Transfer-Encoding chunked · Content-Disposition present · Content-Length absent
spec | BillLink properties ['href'] · required [] · the wire's members ['href']
gap | bill: the wire's charset (text/csv;charset=UTF-8) is not in the documented media type text/csv
gap | bill: chunked on the wire - a spec cannot say so
gap | bill: Content-Disposition documented as a plain string - its form (attachment; filename=...; filename*=UTF-8''...) is the description's, not the schema's
gap | bill: the CSV body documented as a string - its columns are not in the spec
gap | bill: the method refusals (POST, PUT, DELETE) are Framework's and not documented
gap | mint: the method refusals (POST, PUT, DELETE) are Framework's and not documented
gap | signed: the wire's charset (text/csv;charset=UTF-8) is not in the documented media type text/csv
gap | signed: chunked on the wire - a spec cannot say so
gap | signed: Content-Disposition documented as a plain string - its form (attachment; filename=...; filename*=UTF-8''...) is the description's, not the schema's
gap | signed: the CSV body documented as a string - its columns are not in the spec
gap | signed: the method refusals (POST, PUT, DELETE) are Framework's and not documented
gap | signed: expires documented optional (required=false in the code, so the route's own four hundred answers its absence)
gap | signed: expires documented as a string; the route takes a whole number of the epoch's seconds
gap | signed: sig documented optional (required=false in the code, so the route's own four hundred answers its absence)
gap | mint: BillLink marks no member required; the wire always sends href
gap | named: 15
```

### spec

```
committed md5 before 3cda0901be31567ce4c73f17652a5e29 · after aa8cb98f4ff16d75d073026f0c618328 · bytes before 30801 · after 36164
the diff against before's (13b1967's) file: 202 lines added, 0 removed
hunk 864a865,1038
hunk 867a1042,1061
hunk 1097a1292,1299
the paths added: ['/api/v1/customers/{name}/bill', '/api/v1/customers/{name}/bill-link', '/api/v1/customers/{name}/bill/signed'] removed [] other paths moved [] schemas added ['BillLink'] schemas moved []
before: OPERATIONS 18 PATHS 16 · after: OPERATIONS 21 PATHS 19
the old operations' ids before -> after: equal
ops9s3.py on an empty spec: exit 1 (refused)
operationIds unique: yes
OpenApiSpecTest on the regenerated file: tests 1 failures 0 errors 0 (after/'s build)
the client: FILES 15 -> 16 · build exit 0 (before's) / 0 (after/'s, its reactor) · tracked files under tiffinbox-client in the anchor: pom.xml src/test/java/com/tiffinbox/client/TiffinBoxClientTest.java
the client: files > src/main/java/com/tiffinbox/client/model/BillLink.java
the client: counts - equal 0 · date line only 14 · lines added only 1 · moved 0 · added 1
the client: the new methods in ApiApi: ResponseEntity<BillLink> billLink(|ResponseEntity<String> bill(|ResponseEntity<String> signedBill(
the client: the PATH_* constants (ops9s3.py paths, a CHECK): before PATH_CONSTANTS 18 FILES 6 · after PATH_CONSTANTS 21 FILES 6
the client: its test in after/'s build: tests 1 failures 0 errors 0 skipped 0 · git status --short tiffinbox-client: 0 lines
```

### moved, seven, surface

```
== U17's requests (its movedside list, copied, with its own billing-runs requests; the order list's page one with its cursor masked; /v3/api-docs left out: the spec capture reads it) and the new routes, on before (21076)
before | GET /api/v1/customers/Ravi/bill [the new routes] -> 404 application/problem+json · Allow {} · body 3c0b14c60047
before | GET /api/v1/customers/Ravi/bill-link [the new routes] -> 404 application/problem+json · Allow {} · body 54f46ecc6e03
after | GET /api/v1/customers/Ravi/bill [the new routes] -> 200 text/csv;charset=UTF-8 · Allow {} · body eb3e5716784f
after | GET /api/v1/customers/Ravi/bill-link [the new routes] -> 200 application/json · Allow {} · body ca3fcf4b4161
jar | the web jar's entries: added 2 ['BOOT-INF/classes/com/tiffinbox/web/CustomerBills$BillLink.class', 'BOOT-INF/classes/com/tiffinbox/web/CustomerBills.class'] · removed 0 · shared entries whose CRC moved 1 ['BOOT-INF
before: the seven 466c20ed7e0d5439cb052f32ce09de1b (7 lines)
after: the seven 466c20ed7e0d5439cb052f32ce09de1b (7 lines)
before: the old surface 316a96370fe5c34f58fc6ecca8e9557b (13 requests, 83 lines)
after: the old surface 316a96370fe5c34f58fc6ecca8e9557b (13 requests, 83 lines)
before -> after/: equal
```

### tests

```
package | tiffinbox-web | tests 78 failures 0 errors 0 skipped 0
package | tiffinbox-client | tests 1 failures 0 errors 0 skipped 0
package | class CustomerBillsTest | tests 7 failures 0 errors 0 skipped 0
twin | tiffinbox-web | tests 78 failures 0 errors 0 skipped 0
twin | tiffinbox-client | tests 1 failures 0 errors 0 skipped 0
slice TiffinBoxWebTest: after 15 tests · the slice's file byte-equal to before's: yes - measured: no slice edit needed, CustomerRepository is already mocked (1 line)
web tests before (unit 17's values): 71 · new @Test lines 7
== mvn -o clean verify on a copy of after/ (.harness/tests): Surefire's tests on H2 in memory, then the five ITs on PostgreSQL 18.6 in Testcontainers containers (21280-21284)
verify | tiffinbox-web | tests 78 failures 0 errors 0 skipped 0
verify exit 0 · ITs tests 14 failures 0 errors 0 · classes 5
IT bindings: 5 lines · not 127.0.0.1: 0
Testcontainers containers after: 0 · images pulled: 0
webonly | tiffinbox-web | tests 78 failures 0 errors 0 skipped 0
downloads across the builds: 0
BOOT-INF/lib: before 164 · after 164 · name lists equal
```

### exercise

```
broken bash | built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
broken bash | started: the jar alone, H2, the shipped lifetime (no flag)
broken bash | GET /api/v1/customers/Ravi/bill-link -> 200 · href /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked>
broken bash | measured: the signed download -> 500 application/problem+json · title Internal Server Error · detail Failed to write request
broken bash | measured: the bill route -> 200 text/csv;charset=UTF-8
broken bash | the name changed in the link -> 403
broken bash | the signed handler's declared type: ResponseEntity<?>
broken bash | FAIL (2) the minted link does not open 200 text/csv with the bill's own bytes (got 500 application/problem+json)
broken bash | FAIL (6) the signed handler is declared ResponseEntity<?> - a wildcard, Object or raw type
broken bash | check.sh: 2 clause(s) failed
broken bash | check exit 1
solved bash | built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
solved bash | started: the jar alone, H2, the shipped lifetime (no flag)
solved bash | GET /api/v1/customers/Ravi/bill-link -> 200 · href /api/v1/customers/Ravi/bill/signed?expires=<masked>&sig=<masked>
solved bash | measured: the signed download -> 200 text/csv;charset=UTF-8
solved bash | measured: the bill route -> 200 text/csv;charset=UTF-8
solved bash | the name changed in the link -> 403
solved bash | the signed handler's declared type: ResponseEntity<StreamingResponseBody>
solved bash | PASS - every clause holds
solved bash | check exit 0
```

### section

```
section | fd06e77 Course 9 unit 13: Pagination, Filtering and Sorting
section | f3724ca Course 9 unit 14: Sparse Fieldsets and Compression
section | c7e5118 Course 9 unit 15: HATEOAS: The Argument — no ancho
section | c3bc1b2 Course 9 unit 16: Spring HATEOAS in Practice — the
section | 13b1967 Course 9 unit 17: Bulk Operations and 202 Accepted
section | unit 12's after/: OPERATIONS 13 PATHS 11
section | unit 13's after/: OPERATIONS 14 PATHS 12
section | unit 14's after/: OPERATIONS 15 PATHS 13
section | unit 16's after/: OPERATIONS 16 PATHS 14
section | unit 17's after/: OPERATIONS 18 PATHS 16
section | unit 15's after/: its spec = unit 14's (no spec change)
section | unit 18's after/: OPERATIONS 21 PATHS 19
section | up next, by title only: Rate Limiting = TRACK-ROADMAP.md:393's: yes
```


## Measured, not shipped

The harness's presigner (`harness/presign`: its POM and `Presign.java`, built offline into `.harness/presign`, run only inside a container
with no network); the harness's blob route (`probe.u18.U18Config`, `U18Blob`, joined on 21077 only); the harness's lifetime of the
waited-out leg (the shipped key on one start's command line, labelled `lifetime=short`); the access-log pattern; the exposure flag for
`/actuator/mappings` on `before`. The slice need, measured: the slice test passes unedited.

## Refused, named

`s918.py`'s unit family XU18 refuses each of these readings, every one a plant first (its `XU18_PLANTS`), and dur9 with the carried
families refuses every duration word - so this README says "the link's end" where the brief has the word for it:

```
presigned URLs need no credentials · the SDK makes no network calls · only Ravi can open Ravi's bill · the link is secret
a signed link proves who is calling · a typed lifetime · the client sets the lifetime · what a store does, said as measured
a ranking or speed word on proxying or presigning · buffered · the declared type said as a law · the continue answer as a timing
the signature hides the name · the SDK always needs IMDS · the same bytes, without the diff · the spec documents the bill correctly
the client moved, said of a date line · a status in digits outside a code span · bare expires= or X-Amz-* outside a code span
```

## The repository, and the network

The advisory read is the orchestrator's dated act of this unit's day; this unit made no network act of its own but the final `git push`.
No image was pulled; the presigner's containers had no network; no store was run. This unit adds no jar to the anchor: `BOOT-INF/lib`
holds `164` names before and after, and the name lists are equal. The SDK is the harness's own pin, resolved offline from the seed copy,
in no pom here and in no jar.

## The folders, the harness and the ports

`README.md after before exercise harness receipts.md5 receipts.sh`; `harness/`: `chk18.py dur9.py ops9s3.py presign s918.py src tree18.py`
(`presign/`: `Presign.java pom.xml`; `src/probe/u18/`: `U18Blob.java U18Config.java`); `exercise/`: `README.md SOLUTION.md apply.sh
break.sh check.sh`. Ports: 21070 `after/` · 21073 the scratch copy · 21075 the second TiffinBox · 21076 `before` · 21077 the
harness-joined start · 21078 the exercise · 21079 never bound, the presigner's endpoint override · 21071, 21072 and 21074 never bound ·
21280-21284 during `verify` only.

Instruments: copied byte-equal and asserted each run - `dur9.py` (`77d6fcf8…` = `java9_series.DUR9_MD5`), `ops9s3.py` (`8f062a0e…`);
adapted with a named diff - `s918.py` from `s917.py`, `chk18.py` from `chk17.py`, `tree18.py` from `tree17.py` (its code lines equal),
`presign/Presign.java` from the probe's `Presign.java` (`9c3a8124…`), `U18Config.java` from unit 16's `U16Config.java` (`1f24d8f8…`);
new - the exercise's three scripts and the harness POM; read, not copied - the probe's binary captures, BLUE's captures, the probe's
`ProbeJobsAndBills.java`, the bill's `Files.java` of *File Upload and Download*; not used - `walk.py`, `follow.py`, `seal9.py`, `cdp.mjs`,
`cdp9.mjs`, `loc9.py`, and units 14, 15 and 16's harness classes.

## Masks, filters and hygiene

One self-tested mask: the start's clock figures, timestamps, the folders and the home, the band's ports, a link's `expires`
and `sig`, the `X-Amz-*` values, the lifetime on a command line and in the log, `Retry-After`. The link key is never logged; the fake
test credential appears in no capture (the receipt's own count: `0` lines). Every JVM is stopped by `POST /shutdown` or its recorded
pid; every container is removed with its volumes by its recorded name; images and volumes equal at the start and the end.

## Interrupted

SIGINT was not driven this unit: not done, not said. The EXIT trap stops every recorded pid and removes every recorded container.

## Planted faults — each caught

`chk18.py plants` makes each capture's plant fail first on a copy of the run's own capture (the list in `chk18.py`'s `PLANTS`, the count
in the values block), a listing it cannot parse ends with a FAIL line and no traceback, and twelve README plants are refused by
`s918.py`. The flag 31 plants are below.

## Flag 31 — the checks read no live anchor

`chk18.py static` reads only this unit's frozen `after/`, `before` and `git show 13b1967:c9-unit17/after/…`. In the sealed copy of the
repository, after run 3, it was run three times and planted twice; the anchor folder touched is the sealed copy's own, never the real
one:

```
== flag 31 in <scratch>/sealed clone/tiffinbox-java/c9-unit18
(i) as written: exit 0 · 124 ok · output md5 c470fa14c6ffdd20b5dfcf2bb781cf41
(ii) a byte appended to the clone's c9-tiffinbox/compose.yaml (a path the unit did not change): exit 0 · output md5 c470fa14c6ffdd20b5dfcf2bb781cf41 · equal to (i): yes
(iii) the clone's c9-tiffinbox moved aside: exit 0 · output md5 c470fa14c6ffdd20b5dfcf2bb781cf41 · equal to (i): yes
plant (a literal live path in static, the anchor moved aside): exit 1 · FAIL unparsable (FileNotFoundError: [Errno 2] No such file or directory: '../c9-tiffinbox/README.md') · a traceback: 0
plant (the path built from pieces, the anchor moved aside): exit 1 · FAIL unparsable (FileNotFoundError: [Errno 2] No such file or directory: '../c9-tiffinbox/README.md') · a traceback: 0
the same pieces-built plant with the anchor in place: exit 0 (not caught while the folder exists - the moved-aside run (iii) is the catch)
restored: output md5 c470fa14c6ffdd20b5dfcf2bb781cf41 = (i): yes · chk18.py md5 908e10360e7b3a2f5cb2dd2870899df6
```

The same hunt over U15's, U16's and U17's frozen receipts (flag 21) found the known class: `chk15.py static` and `chk16.py static` read
`git diff --stat <hash>` over the working tree, so a re-run after an anchor change fails; filed for the orchestrator, not edited.

## What differed from the brief

Every pick below was made by the orchestrator (`[ORCH 2026-11-27]`, bound at the option marked RECOMMENDED); the consequence named is
the one the captures measured.

- C1 (a), picked by the orchestrator: three `GET` routes on three new paths - the bill, the mint `…/bill-link`, the signed download
  `…/bill/signed?expires=…&sig=…`; no write route. The `href` is a path, not an absolute address (`signed`).
- C2 (a), picked by the orchestrator: the key `tiffinbox.bill-link-lifetime` in `application.yaml`, its reason in a comment beside
  `kitchen-order-ttl`; the value is this unit's choice and is never voiced; it was read back by three witnesses (`signed` (v)). The value of
  the waited-out leg is the same key given on the start's command line, labelled `lifetime=short`.
- C3 (a), picked by the orchestrator: the key `tiffinbox.bill-link-key`, unset by default, 32 random bytes at each start, logged only as
  "defaulted" or "set"; `signed-restart` captured: a link from another start answered `403` with the signature type (`signed` (ix)).
- C4 (a), picked by the orchestrator: two route types, both `403` - `link-signature-invalid` and `link-expired` - the signature checked
  before the link's end (a tampered link past its end answered the signature type). A missing or malformed parameter is the route's own `400`,
  `link-malformed`, not Framework's: the handler takes both parameters as optional strings and checks them itself.
- C5 (a), picked by the orchestrator: `ttlSeconds` refused, `400` `parameter-unknown`, no link minted.
- C6 (a), picked by the orchestrator: one final controller `CustomerBills`, handlers `bill`, `billLink`, `signedBill`, each once among
  the mapped handlers; the census `16/10/1/5` -> `17/11/1/5`.
- C7 (a), picked by the orchestrator: `CustomerNotFound` reused on the bill and the mint (`404`, `customer-not-found`), no edit to the
  advice. On the signed download a name nobody has is caught by the signature first: a link minted for Ravi with the name changed to
  `Nobody` answered `403`; the `404` there is reached only by a link signed for that name, and the mint signs none for a name nobody has.
- C8 (b), picked by the orchestrator: the rows of *File Upload and Download* byte for byte; the brief's `417` bytes is the probe's compact shape and is
  contradicted by this unit's print (`proxy`: the rows rebuilt from V2, `diff` empty).
- C9 (a), picked by the orchestrator: the three handlers annotated; the residual gaps named in `specwire`.
- C10 (a), picked by the orchestrator: the harness's blob route on a harness-joined start (21077), compiled outside the module; no claim
  about the shipped routes is read from that start.
- C11 (a), picked by the orchestrator: `harness/presign/pom.xml` built `mvn -o` from the seed copy, offline, the class path written by
  the dependency plug-in and rewritten to `/seed`. Its class path holds `50` jars, not the probe's `95`: the probe's seed POM also named
  the HATEOAS starter; this POM names the SDK's `s3` alone.
- C12 (a), picked by the orchestrator: the read is `_research/docs-2026-11-27/advisories/`. It held `apache5-client` `2.59.10` (the gap of
  the earlier read, closed). The presigner's class path carries coordinates that read did not query: `httpclient5` `5.6.5` (the read
  queried `5.6.4`), `httpcore5` and `httpcore5-h2` `5.4.4` (the read queried `httpcore5` `5.4.3`), the Netty jars `4.2.20.Final` and
  `slf4j-api` `2.0.20` - named "not read, not said" (`advisory`); the SDK is the harness's only, in a container with no network, never
  in a jar. Not a stop by C12's bound line; handed to the orchestrator.
- C13 (a), picked by the orchestrator: the `lifetime=short` value by `@TestPropertySource`; the link's end waited out by its condition, sleeping a
  part of the lifetime the test read back (`lifetime.dividedBy(PARTS)`), bounded by a guard of `GUARD_LIFETIMES` lifetimes.
- N1: the presigner's endpoint override is `http://127.0.0.1:21079`, never bound (asserted free, TCP and UDP, before and after each
  sealed run). N2: the hook stands in a fenced block; the gloss too - the prose gate refused the bound gloss line as a spoken sentence
  (S2's family, on its last word), so it is kept byte for byte in a fence and the smallest passing form is handed to RED. N3: `expect` measured
  the old `POST /customers/import`. N4: the cap was the earlier of the start plus the cap and the lock's end. N5: the title printed,
  not edited. N6: `expires=`, `X-Amz-*` and every lifetime only in code spans and fenced blocks. N7: the store is named, never shown.
  N8: no database claim; PostgreSQL only in `verify`. N9: the section-end print derived at run time.
- Flags: bill-pg (flag 11), the S9.14 plant slot and SIGINT were not done - "not captured, not said"; every other flag as written.

## For RED

- C1-C13 as bound, each with its measured consequence above; in particular C4's own `400` for a malformed link where Framework's would
  answer with no type, and C7's order: on the signed download a name nobody has is the signature's `403`, the `404` there is reachable only
  with a link the mint never signs.
- The gloss line is refused by the prose gate as a spoken sentence; the smallest passing form is handed on.
- C12: the presigner's class path holds coordinates the read did not query (`advisory` names each) - for the orchestrator.
- The access log's `%b` counts the chunk framing (`607` for a `595`-byte bill) - the witnesses differ, and the README says so.
- `object` (`ResponseEntity<Object>`) answered as the wildcard did; clause 6 refuses it too.
- `expect`: the probe's "the whole body, then the refusal" did not hold here - curl had sent fewer body bytes than the CSV when the
  refusal came; the order of the four events held, and only the order is said.
- Dropped: `bill-pg`, the S9.14 plant slot, SIGINT - not captured, not said.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:390` (*Binary Payloads* — presigned URLs vs proxying bytes). C9-11 at this anchor change, its last row of Section 3:
the seven, the old surface, the spec's old operations and the tests, each by its capture. The carried rows [S3B :358, :364]: the
lifetime setting named, its default in the yaml, read back (`signed`); `apache5-client` `2.59.10` read (`advisory`). RE-MEASURE 4 (the
bill on the public API, `proxy`) and 11 (each new route's spec against its wire, `specwire`) settled.

## The values the video may say

Statuses as words; sizes and versions in code spans only; no lifetime, no time, no signature and no key. From the values block, each
with its capture: the bill's `595` bytes and `32` lines (`proxy`, H2), the blob's `8388608` bytes (`proxy`, the harness's blob route), the
web tests `71` -> `78` (`tests`), operations `18` -> `21` and paths `16` -> `19` (`spec`), the six `X-Amz-*` keys and the signature's
`64` hex characters (`presign`).

<!-- values: begin -->
```
advisory: adv_ids=25 cp_jars=50 not_read=18
before: before_ops=18/16 before_lib=164 before_mappings=33
change: changed=5
census: census_before=16/10/1/5 census_after=17/11/1/5
harness: cp=50
proxy: bill_b=595,log=607 bill_lines=32 bill_md5=eb3e5716 blob=8388608,log=8396805
declared: declared_log=0 declared=500,200
signed: signed=200,403,403,403 ttl=400
presign: presign=keys=6,sig=64
defaults: chain=6
expect: expect=100,body,413 csv=2097164
refuse: refusals=23 notype=10
specwire: gaps=15
spec: spec=30801->36164,+202/-0 spec_md5=aa8cb98f ops=18->21 paths=16->19 client=15->16,date=14,added_lines=1,new=1 path_consts=18->21
moved: moved=0 named=3 jar=added=2,crc_moved=1
seven: seven=466c20ed
surface: surface=316a9637
tests: web_tests=78 web_before=71 k=7 its=14
exercise: ex_broken=500,bill=200
inert: 
section: section=12=13,13=14,14=15,16=16,17=18,18=21
plants: plants=43
build: seed_files=11238 seed_bytes=888071893 central_only=0
```
<!-- values: end -->

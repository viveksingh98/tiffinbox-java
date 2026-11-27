# Course 9 · Unit 21 — `Timeouts and Retries From the Caller's Side`

> One payment, one key, three attempts. The payment service says yes three times.

The party here is the stub from Course 6's harness, a stand-in that honours no key; a server that did would answer the repeats with the
first payment. The retry fired on `the harness's lost reply: a later call in the same method`.

Course 9's seventeenth anchor change, Section 4's third. TiffinBox turns around and becomes a caller, in test scope only:
`tiffinbox-client/src/test` gains its own `RestClient`-backed payments interface (the shape of *HTTP Interface Clients: @HttpExchange*
plus one `Idempotency-Key` header parameter), a `@Retryable` caller that receives one key minted outside the retried method, and a
`MockRestServiceServer` test. No `src/main` file, no pom, no route and no spec byte changed. `before` is a link to `../c9-unit20/after`;
`after/` is the frozen copy of `../c9-tiffinbox` after this unit's change.

What is measured behind that hook: the harness's caller, on the client module's own test class path, sends one payment through the
shipped `PaymentCaller` to the stub; each attempt's `POST` gets its `201`, then the harness's lost reply cuts the method, and the stub's
dump shows three `POST /payments` with one key value and three payment ids, `pay-1`, `pay-2`, `pay-3`. The caller retried correctly; the
party did not honour the key.

## Runs of record

Three runs, each launched below load1 `20` with the load printed on its first line, each ending `every capture = published (19)`,
and `check_unit9.py 21 --runlog` read on each run log (its unit gate exits `2` until this unit's script exists, as expected; the
run-log line is the one read):

- run 1: bash `3.2.57`, `RUNNO=1 ./receipts.sh` in this folder (the exercise's five refused variants run here only).
- run 2: bash `5.3.9`, `RUNNO=2 bash receipts.sh` in this folder.
- run 3: bash `3.2.57`, `RUNNO=3 ./receipts.sh` in a sealed copy of the repository in a folder whose path holds a space (R.129),
  cloned from the local repository at `f73a7c3` with this unit's files laid over it.

The pins in `receipts.md5` were taken from a development run (`NOPIN=1`) of this same script before run 1; the three runs then had to
print the same hashes. The static check's three runs: `chk21.py static after before` printed the same output (i) as written, (ii) on a
scratch copy with a byte appended to `compose.yaml` it exits `1` and names the file, (iii) in a folder copy with no anchor folder beside
it the output is the same; an audit hook refuses any open of a path inside the live anchor's folder, and both plants exit `1`.

As run (2026-11-27; each log's `check_unit9.py 21 --runlog` line: `RESULT (run logs): PASS`):

- run 1: bash `3.2.57`, in this folder, load `4.54 4.52 3.66` at the start; every capture = published (`19`); run-log gate PASS.
- run 2: bash `5.3.9`, in this folder, load `3.71 3.75 3.55` at the start; every capture = published (`19`); run-log gate PASS.
- run 3: bash `3.2.57`, in the sealed copy (`…/sealed clone/tiffinbox-java/c9-unit21`), load `3.35 3.62 3.55` at the start; every
  capture = published (`19`); run-log gate PASS.

These lines were written after run 3; the prose gate and the values block were run again on this README as committed.

## RE-MEASURE (settled first, each by its capture)

- **1** `advisory` — the read filed for Section 4 (`_research/docs-2026-11-27/advisories-s4probe/`), its `fetched-at.txt` naming the
  run's own day; both of the day's `MD5SUMS.txt` verified line by line; Tomcat's page `a1a756d9…` as before; OSV `0` with vulns (the
  other witness only). The pins read off the jar: Boot `4.1.3`, Framework `7.0.11`, Tomcat `11.0.29`. `BOOT-INF/lib` `167` = `167` by
  name and `tiffinbox-client/pom.xml` byte-equal: this unit adds no artifact to the anchor. HttpClient 5, Resilience4j and Micrometer
  are on harness class paths only, read off the seed. Verdict: no pin affected.
- **2** `before` — on `before` (U20's `after`): the client module's test class path holds `61` jars and `0` named `httpclient5`
  (`spring-boot-restclient` `4.1.3`, `spring-boot-restclient-test` `4.1.3`, `spring-test` `7.0.11`); its one test green; the harness's
  caller on that class path gets `DefaultRestClientBuilder` and `JdkClientHttpRequestFactory`. The web jar's `BOOT-INF/lib` holds
  `httpclient5-5.6.5.jar`: that fact is the web module's, not the client's.
- **3** `change` — three new test files and the anchor's README: the derived changed list is these four paths and nothing else; the
  interface is the only client file naming `Idempotency-Key`; no interceptor, no `resilience4j`, nothing in `src/main`; the client's
  test class path equal by name before and after; the generated client's files equal by CRC (`ApiApi.add1` has no key parameter).
- **4** `census` — the controllers `17` / `11` / `1` / `5` on both trees: the caller is no controller.
- **5** `factory` — on the module's class path the builder builds `JdkClientHttpRequestFactory`, and the stub saw `User-Agent:
  Java-http-client/<jdk>` with `Upgrade` and `Http2-settings`; on the harness's HttpClient 5 class path (labelled) it builds
  `HttpComponentsClientHttpRequestFactory`, and the stub saw `Apache-HttpClient/5.6.5`.
- **6** `timeout` — a raw `RestClient` from the module's builder on the stub's `/slow` path: with no `read-timeout` set, `200` and
  `{"slow":true}`, the call waited for the stub's whole delay (the harness's boolean `true`; the metadata's entry for
  `spring.http.clients.read-timeout` has no default); with the run flag `--spring.http.clients.read-timeout` (its value in `receipts.sh`, masked in the capture),
  `ResourceAccessException` ending `Request cancelled`, root `java.net.http.HttpTimeoutException` - the caller gave up, the stub still
  answered; on the harness's HttpClient 5 class path, `Read timed out`, root `java.net.SocketTimeoutException`, labelled.
- **7** `retry` — the shipped caller against the stub: one key minted outside the method gives `3` `POST`s, `1` distinct key, payments
  `pay-1`, `pay-2`, `pay-3`, then the root `Request cancelled` of `the harness's lost reply: a later call in the same method`; the key minted inside the method (a copy) gives `3`
  distinct keys for three payments; a remote `404` under the shipped narrow list reached the stub once, under `includes =
  RestClientException` (a copy) three times, `HttpClientErrorException$NotFound` each time; the harness's HttpClient 5 class path:
  `3` `POST`s, `1` key, root `Read timed out`. The settings read back: `maxRetries 2`, `delay 10`, the two classes; the annotation's
  defaults on `spring-context-7.0.11.jar`: `maxRetries 3`, `delay 1000`, `jitter 0`, `multiplier 1.0`.
- **8** `mock` — `PaymentRetryTest`: `4` tests green, none skipped; three requests with one key (`IOException`, `500`, `201`), three
  `500`s with the caller's key matched on each and `verify()`, two payments with two keys, a `404` sent once. The factory is
  `MockRestServiceServer$MockClientHttpRequestFactory`: no socket, no HTTP client.
- **9** `resilience4j` — on a harness class path only: the core `Retry` made `3` calls with `2` `RETRY` events; the Boot 4 starter
  `2.4.0` does not start without `micrometer-core` (`ClassNotFoundException: io.micrometer.core.instrument.MeterRegistry`) and starts
  with `1.17.3` (`retryRegistry` among its beans). The anchor names it nowhere.
- **10** `spec` — the served document equals the committed file (`36164` bytes, `aa8cb98f…`), `21` operations and `19` paths.
- **11** `moved`, `api`, the seven, the surface, `inert` — not witnesses for this change: none of their requests reaches a test-scope
  class. What they do show is that the shipped app is untouched: the web jar, the core jar and the client's main jar `0` entries moved,
  `BOOT-INF/lib` `167` = `167`; the `/api/v1/` census printed the same lines on both trees; the seven and the old surface printed
  unit 20's values on both; no TiffinBox JVM saw a key header.
- **12** `tests` — `mvn package`: web `85` (unchanged since unit 20), client `1` → `5`, none skipped; the Docker-free twin the same;
  `mvn verify`: the five ITs `14` green on their Testcontainers stores; the client-only form `-pl tiffinbox-client -am` the same `5`.
- **13** `exercise` — the broken copy (the key minted inside the retried method) sends three keys for one payment at the stub and the
  shipped test's two key methods go red; the solution passes under bash and `zsh -f`; five refused variants fail.

## The change, file by file

- `tiffinbox-client/src/test/java/com/tiffinbox/client/Payments.java` — new: `@HttpExchange("/payments")`, `pay(@RequestHeader(
  "Idempotency-Key") String key, @RequestBody Charge charge)` answered by a `Payment`, and `slow()`; the two records nested; the
  header's name as a constant `KEY_HEADER`, so the test spells it nowhere else.
- `tiffinbox-client/src/test/java/com/tiffinbox/client/PaymentCaller.java` — new: `pay(key, charge)` under `@Retryable(maxRetries = 2,
  delay = 10, includes = {ResourceAccessException.class, HttpServerErrorException.class})`, the key a parameter; its nested `Checkout`
  mints one key per payment and calls through the proxy; `attempts()` read through the proxy's methods.
- `tiffinbox-client/src/test/java/com/tiffinbox/client/PaymentRetryTest.java` — new: four tests, a minimal Spring context
  (`AnnotationConfigApplicationContext`, `@EnableResilientMethods` on the test's own configuration), `MockRestServiceServer.bindTo(builder)`
  before the interface is built.
- `c9-tiffinbox/README.md` — a *Course 9, unit 21* note under the unit 20 note and a `## Course 9 · unit 21` card; the stale-sentence
  hunt found the client's test count "1" as current only in unit 20's note, now history beside unit 21's.
- Not changed: every `src/main` file, every pom, `TiffinBoxClientTest`, the spec, `Dockerfile`, `compose.yaml`.

## Which tree, which profile

The two TiffinBox JVMs (`after/` on `21100`, `before` on `21106`) run the default profile on H2 in memory, harness-free, at the default
capacity, with Tomcat's access log naming the key header's value. The stub and the caller touch no database. `mvn verify`'s five ITs
bring their own Testcontainers stores (PostgreSQL, Redis, MongoDB, Elasticsearch). No container of this unit's own starts.

## Unit 21's section

The spine [S4B `## Unit 21`] is measured as written, with two readings. The interface is TiffinBox's own, in test scope; the socket
facts come from the harness's caller on the client module's class path. The failure receipt is the stub's three payment ids for one key:
the caller retried correctly and the party did not honour the key. The hazards, each with its capture: the module's class path holds
no HttpClient 5 (`before`, `factory`); the `@Retryable` bean is a proxy, `PaymentCaller$$SpringCGLIB$$N`, read through its methods
(`retry`); the generated `add1` has no key parameter (`change`); the starter needs Micrometer (`resilience4j`); a wide `includes`
repeats a remote `404` three times and the narrow list sent it once (`retry`).

## The captures — what each one shows

### `advisory`, `before`, `change`, `census`
The read's day and its two `MD5SUMS.txt`; the client module's class path and its one test on `before`; the three new files printed whole,
the interface in Course 6's harness beside this unit's - the one added parameter:

```
c6:   Payment pay(@RequestBody Charge charge);
u21:  Payment pay(@RequestHeader("Idempotency-Key") String key, @RequestBody Charge charge);
```

### `factory` (the stub, a stand-in; no database)

| class path | request factory | `User-Agent` at the stub | `httpclient5` |
|---|---|---|---|
| the client module's | `JdkClientHttpRequestFactory` | `Java-http-client/<jdk>` (with `Upgrade`, `Http2-settings`) | `0` |
| the harness's HttpClient 5 class path | `HttpComponentsClientHttpRequestFactory` | `Apache-HttpClient/5.6.5 (Java/<jdk>)` | added, labelled |

### `timeout` (a raw `RestClient` from the module's builder; the stub)

| setting | answer | root |
|---|---|---|
| none (`absent`, no metadata default) | `200` `{"slow":true}`, waited for the stub's whole delay | - |
| `read-timeout` run flag, the module's class path | `ResourceAccessException` ... `Request cancelled` | `java.net.http.HttpTimeoutException` |
| `read-timeout` run flag, HttpClient 5 class path | `ResourceAccessException` ... `Read timed out` | `java.net.SocketTimeoutException` |

### `retry` (the shipped `PaymentCaller`; the stub, which honours no key)

Every row's root is that of `the harness's lost reply: a later call in the same method` (`GET /payments/slow`, cut by the run flag).

| key mode | attempts | distinct keys at the stub | payment ids | root |
|---|---|---|---|---|
| one key, minted outside the method | `3` | `1` | `pay-1`, `pay-2`, `pay-3` | `Request cancelled` |
| minted inside the method (a copy) | `3` | `3` | `pay-1`, `pay-2`, `pay-3` | `Request cancelled` |
| one key, the HttpClient 5 class path | `3` | `1` | `pay-1`, `pay-2`, `pay-3` | `Read timed out` |

| `includes` | `GET /status/404` at the stub | exception |
|---|---|---|
| `{ResourceAccessException, HttpServerErrorException}` (shipped) | `1` | `HttpClientErrorException$NotFound` |
| `RestClientException` (a copy, the loser) | `3` | `HttpClientErrorException$NotFound` |

### `mock` (MockRestServiceServer: no socket)
`PaymentRetryTest` `4` / `0` / `0` / `0` skipped; one key over three requests; the key matched on each of `times(3)`; two payments, two
keys; a `404` sent once; the factory `MockRestServiceServer$MockClientHttpRequestFactory`.

### `resilience4j` (a harness class path only)
Core `Retry`: `3` calls, `2` `RETRY` events, `resilience4j-retry-2.4.0.jar`. The starter without `micrometer-core`: exit `1`,
`ClassNotFoundException: io.micrometer.core.instrument.MeterRegistry`; with `1.17.3`: started on Boot `4.1.3`, `retryRegistry`,
`retryEventConsumerRegistry`, `retryRegistryEventConsumer`, the Boot 4 verifier present.

### `spec`, `moved`, `api`, `seven`, `surface`, `inert` (H2; not witnesses for this change)
The served document equals the committed file; the web jar's `384`, the core jar's `41` and the client main jar's `32` entries: `0`
added, `0` removed, `0` moved; `BOOT-INF/lib` `167` = `167`; the census of `11` `/api/v1/` requests printed the same lines on `before`
(`21106`) and `after/` (`21100`); the seven and the old surface as unit 20's; `0` access-log lines with a key.

### `tests`, `harness`, `exercise`, `title`
`mvn package`: web `85`, client `5`; the twin the same; `mvn verify`: `14` ITs in `5` classes, `5` binding lines all on `127.0.0.1`,
nothing pulled, no container left; client-only `5`; downloads `0`. The title for search, `55` characters by `len()`, printed beside
the other course's search title read off `java6_series.py` (the copy step's clash, RED4 #31).

## Measured, not shipped

The stub copy (`harness/stub`, the stub from Course 6's harness byte for byte), the harness's caller (`harness/src/probe21/Caller21.java`),
the harness's HttpClient 5 class path, the Resilience4j class paths (`harness/src/r4`, the S4 probe's two classes), the wide-`includes`
copy and the key-per-attempt copy of `PaymentCaller` (`.harness/wide`, `.harness/broken`), the exercise's copies. None is in a jar or a
module.

## Refused, named

Each refused by `harness/s921.py` (XU21C9) and planted in its self-test: `the retry is safe` (the stub honours no key), `the reply was
lost` (the `POST`'s own `201` arrived), `waits forever` (it waited for the stub's whole delay), `the generated client sends the key`
(`add1` has no key parameter), `the key's interceptor` (none is shipped), `Resilience4j is the course's retry` (a harness preview),
`the census proves the retry` (it is not a witness for the caller), a count typed instead of printed.

## The repository, and the network

The advisory read of the batch day stands: Spring's, Tomcat's and OSV's pages filed under `_research/docs-2026-11-27/` cleared Boot
`4.1.3`, Framework `7.0.11` and Tomcat `11.0.29`, and this unit adds no anchor coordinate. Nothing else was read from the network; the
only network act is the final `git push`.

## The folders, the harness and the ports

`README.md`, `receipts.sh`, `receipts.md5`, `before` (the link), `after/`, `harness/` (`chk21.py`, `dur9.py`, `ops9s3.py`, `s921.py`,
`tree21.py`, `src/probe21/Caller21.java`, `src/r4/R4.java`, `src/r4/R4Core.java`, `stub/`), `exercise/` (`README.md`, `SOLUTION.md`,
`apply.sh`, `break.sh`, `check.sh`). Ports: `21100` `after/`, `21105` the stub, `21106` `before`, `21108` the exercise's stub;
`21101`-`21104`, `21107` and `21109` never bound; `21280`-`21284` during `mvn verify` only. The caller JVMs bind no port.

## Masks, filters and hygiene

One self-tested mask: the start lines' times, the `ms` counts, timestamps, the folders, the band's ports, the stub's `ms=`, the
`read-timeout` value, the JDK build in a `User-Agent`, the proxy class's number, keys (UUIDs), HTTP dates. The keys' distinct count is the
value kept. Every process is stopped by its recorded pid; no container of this unit's own; images and volumes equal at the end.

## Interrupted

Not done in this unit's runs of record (the cap's drop order allows it): no SIGINT driver was run. The receipt's EXIT trap stops every
JVM and stub it recorded and removes `.r-*.new` on an interrupt; that path was exercised once in development (a run stopped by its own
pid mid-capture left no JVM, no stub and no listener).

## Planted faults — each caught

`chk21.py plants` on every run of record: `38` plants caught, each a FAIL line with exit `1` and no traceback. They cover the module's
factory typed as HttpComponents, the client's HttpClient 5 count typed `1`, the two exception messages swapped between class paths, the
metadata default typed present, the harness's boolean typed false, each leg's key count typed wrong, the `404` counts swapped, a payment id
typed wrong, the lost-reply label dropped, the mock's factory typed as the JDK's, the not-tested line removed, the events typed `3`, the
start without Micrometer typed as started, a key header in another file, an interceptor, a pom and a `src/main` file touched, a skipped
test, a refusal at the default capacity, a conditional annotation, the seven's and the surface's md5 altered, the jar
list typed `164`, a moved jar entry, the census moved, the spec touched, the solution equal to the broken copy, a read dated after the
run, a keyed request at a TiffinBox JVM, a request count over the cap, a refusal line, a title over the limit, and three unparseable
listings. The static gate's own plants and the prose gate's self-test (XU21C9's plants and near misses) run at every start.

## What differed from the brief

- C1-C8: picked by the orchestrator, each its RECOMMENDED (a). C1's self-invocation variant: not captured, not said (dropped first).
- C3: the test's context is an `AnnotationConfigApplicationContext` built in the test (no Boot); `k` = `4`.
- C5: the check sends two payments through the tree's caller and asserts one key within each and two across; the refused variants
  `none`, `constant`, `onlyfirst`, `swallow`, `fixedelsewhere` run in run 1 only (`  ~` lines, out of the hash).
- C6: the wait shown by the harness's boolean; the stub was stopped before it wrote its answer to the cut requests ("no answer written").
- D1: no interceptor is shipped; the interceptor phrase in S4B ⚑S4-8 is stale (for the orchestrator).
- D2: the hook is gated as written and passes `s921.py`; the line after it names the stand-in.
- D3: both modules' `httpclient5` printed; S9.19's sentence is out of date for the client module (for the orchestrator).
- D5: BLUE's numbers were the expectation on a `Map`/`String` stand-in; on the shipped interface the stub's ids and key counts printed
  the same values.
- D6: `read-timeout`, its value and the stub's `ms` live in code spans and captures only; `ALLOW = {}` read, not edited.
- D8: `@Retryable`'s defaults re-read on `7.0.11`: `maxRetries 3`, `delay 1000`, as *Core Resilience Annotations in Framework 7* read them on `7.0.9`.
- D9: the shipped caller's own method sends the `POST` only; the harness's `Payments` wrapper adds the call after the `POST` (`lossy`) or the remote
  `404` (`missing`) inside the retried method.
- The client module's test class path is `61` jars by this receipt's count (the probe's notes say `60`, counted with `wc -l` over a list
  with no final newline).
- The test reads the header's name from `Payments.KEY_HEADER`, so the interface stays the only client file that spells it.
- The static check's third run: in a folder copy with no anchor folder beside it, not by moving the sealed clone's anchor aside.
- Not captured, not said: SIGINT points; C9-18's `type` branch; the gloss lines of units before 13 (U13-U20 checked).

## For RED

- C1-C8 as bound (each RECOMMENDED (a)), the key-per-attempt copy as the exercise's broken state, the wide `includes` copy.
- D2: the hook's "payment service" against a stub that honours no key; the hook passes `s921.py` as written (`13` words).
- D3: S9.19's sentence about HttpClient 5 is out of date for the client module.
- C8: C9-18's `type` branch left open, not captured, not said.
- D1: the interceptor phrase of ⚑S4-8.
- D6: `read-timeout` and its value as a script-stage item; `dur9_allow.py` has `ALLOW = {}`, not edited.
- D5: the shipped interface against BLUE's `Map`/`String` caller; the printed values agree.
- D10: the title's clash with the other course's search title (RED4 #31), for the copy step.
- The dropped SIGINT points; the client class path's `61` against the probe's `60`; the spoken form of Resilience4j for the scripts
  stage's sample.

## The ledger rows this unit pays

`TRACK-ROADMAP.md:395` (Resilience4j previewed, the full treatment *Microservices & Spring Cloud*'s). **C9-6**: no default `read-timeout`
(the metadata read back), `Request cancelled` re-measured on this module's class path, the remote `404` repeated three times by a wide
`includes` and once by the narrow one (its server-side counterpart is *RestClient*'s, called back). **C9-7**: the payment three times is
this unit's; backoff and jitter by title only. **C9-9**: `MockRestServiceServer` counts the attempts and opens no socket. **C9-11**: the
seven, the surface and the census on both trees. **C9-12**: the interface shape plus one parameter. **C9-14** (*Testing Spring Apps*) and
**C9-15** (*Microservices & Spring Cloud*) by title. **C9-18** is NOT paid here: the caller never reads a problem type. No ledger edit.

## The values the video may say

From this unit's own receipts, 3/3, each with its store: on the client module's class path the builder's factory is
`JdkClientHttpRequestFactory` (the stub); with no `read-timeout` the call waited for the stub's whole delay and with the run flag it ended
`Request cancelled` (the stub); one key over `3` attempts, `1` distinct key, payments `pay-1` to `pay-3` (the stub, which honours no key);
the key minted per attempt, `3` keys (the stub); a remote `404` once under the narrow list and `3` times under the wide one (the stub);
`PaymentRetryTest` `4` tests, client `1` → `5` (MockRestServiceServer: no socket); web `85`, ITs `14` (H2 and Testcontainers);
`BOOT-INF/lib` `167` (the jar); Resilience4j's core `Retry` `3` calls and `2` events (a harness class path).

<!-- values: begin -->
```
advisory: fetched=2026-11-27 lib=167->167
before: client_cp=61 httpclient5=0 factory=JdkClientHttpRequestFactory client=1 lib=167
change: changed=4 generated=22/16 cp=unchanged
census: census=17/11/1/5
factory: module=JdkClientHttpRequestFactory ua_module=Java-http-client/<jdk> hc5=HttpComponentsClientHttpRequestFactory ua_hc5=Apache-HttpClient/5.6.5 cp=61
timeout: none=200_waited module=Request_cancelled/HttpTimeoutException hc5=Read_timed_out/SocketTimeoutException default=absent
retry: onekey=3/1/pay-1,pay-2,pay-3 keyper=3/3 404narrow=1 404wide=3 hc5=3/1
mock: tests=4 requests=3 distinct=1 factory=MockClientHttpRequestFactory
resilience4j: core_calls=3 events=2 without=ClassNotFoundException with=started
spec: spec=36164 ops=OPERATIONS 21 PATHS 19
moved: moved=0 web=384 core=41 client=32 lib=167->167
api: api=11 identical
seven: seven=466c20ed
surface: surface=316a9637
tests: web=85 client=1->5 its=14 lib=167->167
harness: static=8968a239ade04475271ef767eb2a56b9
exercise: broken=FAIL(3_keys) solved=PASS
inert: keyed=0
title: title_len=55
plants: plants=38
build: seed_files=11323 seed_bytes=889446136 central_only=0
```
<!-- values: end -->

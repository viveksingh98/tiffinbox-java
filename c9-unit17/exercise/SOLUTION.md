# Course 9 · Unit 17 — the solution

In `BillingRuns.java`'s status handler, `billingRun`, set the header only while the run is `RUNNING`, as `../after` has it:

```java
        BillingRunView view = run.view();
        ResponseEntity.BodyBuilder answer = ResponseEntity.ok();
        if (view.state() == State.RUNNING) {
            answer.header(HttpHeaders.RETRY_AFTER, COME_BACK);
        }
        return answer.body(view);
```

`sh apply.sh TREE` makes that edit in a broken copy (the file then equals `../after`'s, asserted), and `sh check.sh TREE` passes. A header
sent in every state fails clause 3; no header fails clause 2; the fix made in another file as well fails clause 5; a state written as
`RUNNING` for every answer never finishes and fails clause 4.

What it prints:

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
started: the jar alone, H2, delay=on (the harness's pause on the command line)
POST /api/v1/billing-runs -> 202 · Location http://127.0.0.1:<port>/api/v1/billing-runs/<id>
measured: RUNNING -> 200 application/json · Retry-After present
measured: SUCCEEDED -> 200 application/json · Retry-After absent · bills Meera=4500 Priya=3600 Ravi=7200 Sunil=9000
states observed in order: RUNNING SUCCEEDED
PASS - every clause holds
```

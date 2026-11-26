# Course 9 · Unit 17 — the exercise

**Your turn:** the status resource never says when to come back. Add the header, and stop sending it once the run is done.

`../after` is TiffinBox after this unit: `POST /api/v1/billing-runs` answers `202` with `Location` and `Retry-After`, and the status
resource `GET /api/v1/billing-runs/{id}` sends `Retry-After` while the run is `RUNNING` and never once it is finished. `break.sh` removes
the status resource's `Retry-After` in a copy of `../after`. Your job is to send it again from the status handler, in `BillingRuns.java`
alone, while the run is `RUNNING`, and not once the run is done.

```
cp -R ../after /tmp/u17-tree        # any copy; ../after itself is refused
sh break.sh /tmp/u17-tree
sh check.sh /tmp/u17-tree           # builds the copy offline, starts it alone on 21068 (H2, the harness's pause on), sends the requests itself
```

`check.sh` starts the jar with the harness's pause between customers on its command line (`--tiffinbox.billing-runs.harness-pause-ms`),
so a run is seen `RUNNING`. It passes only when every clause holds: the POST answers `202` with its `Location`; at least one `RUNNING`
answer carries `Retry-After` with a whole number; no finished answer carries it; the finished answer holds the four customers' bills;
every other main file, the three poms and the spec equal `../after`'s; and the status handler sets `Retry-After` inside a condition on
the run's state.

The broken copy, measured first on the route the exercise names (H2; host `127.0.0.1:<port>`; the receipts' `exercise` capture, every
run): the status resource answers `200` with the run's state while it is `RUNNING`, and no `Retry-After` in any state.

What it prints:

```
built: mvn -o -DskipTests clean package -pl tiffinbox-web -am (exit 0)
started: the jar alone, H2, delay=on (the harness's pause on the command line)
POST /api/v1/billing-runs -> 202 · Location http://127.0.0.1:<port>/api/v1/billing-runs/<id>
measured: RUNNING -> 200 application/json · Retry-After absent
measured: SUCCEEDED -> 200 application/json · Retry-After absent · bills Meera=4500 Priya=3600 Ravi=7200 Sunil=9000
states observed in order: RUNNING SUCCEEDED
FAIL (2) no RUNNING poll carries Retry-After with a non-negative integer value (the status resource never says when to come back)
FAIL (6) the status handler does not set Retry-After inside a condition on the run's state
check.sh: 2 clause(s) failed
```

Hint: the POST handler already does it; the status handler needs the same condition on the run's state.

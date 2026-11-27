# Exercise: one key for all attempts

**Your turn:** this retry sends a new Idempotency-Key on every attempt. Send one key for all attempts.

Start from a copy of `../after` and break it: `sh break.sh <your copy>`. The one edit moves the key's minting inside the retried method:
`PaymentCaller.pay` ignores the key it was given and sends `UUID.randomUUID()` on every attempt. Then run the check against your copy:
`MAVEN_REPO=<an offline repository> sh check.sh <your copy>`. It builds your copy's client module offline with its tests, calls your
`PaymentCaller` from the harness against the stub from Course 6's harness on port `21108` (a stand-in that honours no key), and reads the stub's dump. H2
is not involved and no request goes to TiffinBox.

What a party that honours a key sees when the caller sends a new one on each attempt: three different keys, so three payments.

What it prints on the broken copy (measured by `../receipts.sh`, the `exercise` capture):

```
FAIL (1) the tree's client tests are red: oneKeyOnEveryAttempt theCallersKeyOnEachOfThreeRequests
(2) the stub (Course 6's, a stand-in that honours no key): POSTs 6 · payment 1: 3 attempts, 3 distinct key(s) · payment 2: 3 attempts, 3 distinct key(s) · distinct across the two: 6 · payments it made: 6
FAIL (2) one payment's attempts must carry one key, and the two payments two keys
(3) the files other than PaymentCaller.java byte-equal to ../after's: yes
```

The check passes only when one payment's three attempts carry one key and another payment carries a different one, the client
module's tests are green, and no other file moved. A key typed as a constant, a key sent on the first attempt only, a retry removed,
and a fix made in another file each fail it.

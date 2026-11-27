# Solution: one key for all attempts

The key is the retried method's parameter. Whoever calls `pay` mints it once, outside the retried method - here `Checkout`, which calls
through the proxy - and `pay` sends the key it was given on every attempt:

```java
@Retryable(maxRetries = 2, delay = 10, includes = {ResourceAccessException.class, HttpServerErrorException.class})
public Payments.Payment pay(String key, Payments.Charge charge) {
    attempts.incrementAndGet();
    return payments.pay(key, charge);
}
```

`sh apply.sh <your copy>` makes that one edit. The stub still makes three payments for the one key: it is the stand-in from Course 6's harness
and honours no key. A server that honours the key answers the repeats with its first payment; that server side is *Idempotency, Safety and
Retries*.

What it prints on the solved copy (measured by `../receipts.sh`, the `exercise` capture):

```
(1) the tree's client tests: green (Tests run: 5, Failures: 0, Errors: 0, Skipped: 0)
(2) the stub (Course 6's, a stand-in that honours no key): POSTs 6 · payment 1: 3 attempts, 1 distinct key(s) · payment 2: 3 attempts, 1 distinct key(s) · distinct across the two: 2 · payments it made: 6
(3) the files other than PaymentCaller.java byte-equal to ../after's: yes
PASS
```

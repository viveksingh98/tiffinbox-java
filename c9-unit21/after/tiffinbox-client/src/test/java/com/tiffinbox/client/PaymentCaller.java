package com.tiffinbox.client;

import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.resilience.annotation.Retryable;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.ResourceAccessException;

/**
 * Course 9, unit 21: the retried caller. pay() carries Framework 7's core @Retryable: two retries after the first attempt (three
 * attempts), a short fixed delay, and only two kinds of failure retried - an I/O failure (ResourceAccessException: no answer, or a
 * timeout) and a 5xx (HttpServerErrorException). A 4xx such as a 404 is not retried: the party has answered.
 *
 * <p>The key is a PARAMETER: whoever calls pay() mints it once, outside the retried method, so every attempt sends the same key.
 * Checkout below is that caller. The bean is a proxy (@Retryable): read it through its methods, never its fields.
 *
 * <p>What it does NOT do: no backoff growth, no jitter, no retry budget (Course 16's, Microservices &amp; Spring Cloud); it does not
 * make a repeat safe - only a party that honours the key does that.
 */
public class PaymentCaller {

    private final Payments payments;
    private final AtomicInteger attempts = new AtomicInteger();

    public PaymentCaller(Payments payments) {
        this.payments = payments;
    }

    /** Course 9, unit 21: one payment; the same key on every attempt. */
    @Retryable(maxRetries = 2, delay = 10, includes = {ResourceAccessException.class, HttpServerErrorException.class})
    public Payments.Payment pay(String key, Payments.Charge charge) {
        attempts.incrementAndGet();
        return payments.pay(key, charge);
    }

    /** Attempts made since the last reset - counted by the target, read through the proxy. */
    public int attempts() {
        return attempts.get();
    }

    public void reset() {
        attempts.set(0);
    }

    /** Course 9, unit 21: mints ONE key per payment, outside the retried method, then calls through the proxy. */
    public static class Checkout {

        private final PaymentCaller caller;

        public Checkout(PaymentCaller caller) {
            this.caller = caller;
        }

        public Payments.Payment pay(Payments.Charge charge) {
            String key = UUID.randomUUID().toString();
            return caller.pay(key, charge);
        }
    }
}

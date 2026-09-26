package com.tiffinbox;

import java.util.*;
import org.springframework.context.annotation.*;
import org.springframework.resilience.annotation.*;

/**
 * EXERCISE. This gateway HONOURS an idempotency key: a second charge carrying a key it has already seen is
 * not charged again. The payment code sends a key on every call - "so retries are safe", says the team.
 * The bill disagrees. Keep the retry. Keep the key. Make the bill 340.
 */
public final class TheBill {
    private TheBill() { }
    static int calls, charged;
    static final Set<String> keysSeen = new HashSet<>();
    /** The gateway, simulated: charges once per key; the reply is lost on the first two calls. */
    static void gateway(String idempotencyKey, int amount) {
        calls++;
        if (keysSeen.add(idempotencyKey)) charged += amount;
        if (calls < 3) throw new IllegalStateException("gateway timeout");
    }
    public static class Payments {
        @Retryable(maxRetries = 2, delay = 10)
        public String pay(String order, int amount) {
            String key = UUID.randomUUID().toString();
            gateway(key, amount);
            return "paid";
        }
    }
    @Configuration @EnableResilientMethods static class Cfg { @Bean Payments payments() { return new Payments(); } }

    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            String result = ctx.getBean(Payments.class).pay("order-7", 340);
            System.out.println("  one order of 340: " + result + " after " + calls + " attempts");
            System.out.println("  charged " + charged + " for one order");
        }
    }
}

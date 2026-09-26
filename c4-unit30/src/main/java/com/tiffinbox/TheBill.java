package com.tiffinbox;

import org.springframework.context.annotation.*;
import org.springframework.resilience.annotation.*;

/**
 * THE BREAK. The gateway takes the money and THEN times out: the charge went through, the reply got lost.
 * @Retryable does exactly what it was told. It tries again - and the gateway charges again.
 */
public final class TheBill {
    private TheBill() { }
    static int calls, charged;
    /** The payment gateway, simulated: every call charges the card; the reply is lost on the first two. */
    static void gateway(String order, int amount) {
        calls++;
        charged += amount;                                                    // the money moved...
        if (calls < 3) throw new IllegalStateException("gateway timeout");   // ...and the reply never arrived
    }
    public static class Payments {
        @Retryable(maxRetries = 2, delay = 10)
        public String pay(String order, int amount) { gateway(order, amount); return "paid"; }
    }
    @Configuration @EnableResilientMethods static class Cfg { @Bean Payments payments() { return new Payments(); } }

    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            String result = ctx.getBean(Payments.class).pay("order-7", 340);
            System.out.println("  one order of 340: " + result + " after " + calls + " attempts");
            System.out.println("  charged " + charged + " for one order   (" + calls + " x 340)");
        }
    }
}

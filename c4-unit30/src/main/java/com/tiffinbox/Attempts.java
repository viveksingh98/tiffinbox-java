package com.tiffinbox;

import org.springframework.context.annotation.*;
import org.springframework.context.event.EventListener;
import org.springframework.resilience.annotation.*;

/**
 * @Retryable, counted. Two retries means three attempts in all. Then every attempt failing - what does the
 * caller get? - and then the same method called from INSIDE its own class, where the proxy never sees it.
 */
public final class Attempts {
    private Attempts() { }
    static int attempts, failFirst;                 // failFirst: how many attempts fail before one succeeds
    public static class Payments {
        @Retryable(maxRetries = 2, delay = 10)
        public String pay(String order) {
            attempts++;
            boolean fails = attempts <= failFirst;
            System.out.println("    attempt " + attempts + (fails ? " failed" : " succeeded"));
            if (fails) throw new IllegalStateException("gateway timeout on attempt " + attempts);
            return "paid";
        }
        public String payFromInside(String order) { return pay(order); }
    }
    /** Spring publishes a MethodRetryEvent for every failure of a @Retryable method - a listener sees them all (RED 2026-09-26). */
    public static class RetryWatcher {
        @EventListener public void on(org.springframework.resilience.retry.MethodRetryEvent e) {
            Throwable f = e.getFailure();
            if (e.isRetryAborted())
                System.out.println("      [event] retries exhausted - " + f.getClass().getSimpleName() + ", cause: "
                        + (f.getCause() == null ? "none" : f.getCause().getMessage()) + ", earlier failures attached: " + f.getSuppressed().length);
            else
                System.out.println("      [event] " + f.getMessage());
        }
    }
    @Configuration @EnableResilientMethods static class Cfg {
        @Bean Payments payments() { return new Payments(); }
        @Bean RetryWatcher retryWatcher() { return new RetryWatcher(); }
    }

    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Payments p = ctx.getBean(Payments.class);
            System.out.println("  fails twice, then works - called through the bean:");
            attempts = 0; failFirst = 2;
            System.out.println("    -> " + p.pay("order-7") + " after " + attempts + " attempts");
            System.out.println("  fails every time - called through the bean:");
            attempts = 0; failFirst = 99;
            try { p.pay("order-7"); } catch (RuntimeException e) {
                System.out.println("    -> the caller gets " + e.getClass().getSimpleName() + ": " + e.getMessage()
                        + "   (earlier failures attached: " + e.getSuppressed().length + ", cause: " + e.getCause() + ")");
            }
            System.out.println("  fails twice, then works - called from INSIDE the class:");
            attempts = 0; failFirst = 2;
            try { p.payFromInside("order-7"); } catch (RuntimeException e) {
                System.out.println("    -> " + e.getClass().getSimpleName() + " after " + attempts + " attempt(s)"
                        + (attempts == 1 ? " - no retry at all" : " - it was retried"));
            }
        }
    }
}

package com.tiffinbox;

import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.context.annotation.*;
import org.springframework.scheduling.annotation.*;

/**
 * PITFALL ONE, taken to the end (added after the section's RED review). A slow job only DELAYS the order
 * check - it catches up afterwards (Starved). A job that never RETURNS holds the one default thread for ever:
 * the check stops, and nothing is logged. That is the "stopped weeks ago, nothing failed" story.
 */
public final class Hung {
    private Hung() { }
    static final AtomicInteger checks = new AtomicInteger();
    static volatile boolean release;
    public static class Jobs {
        @Scheduled(fixedRate = 100) public void checkOrders() { checks.incrementAndGet(); }
        @Scheduled(fixedRate = 100, initialDelay = 250) public void report() {
            while (!release) Thread.onSpinWait();                  // a report that never comes back
        }
    }
    @Configuration @EnableScheduling static class Cfg { @Bean Jobs jobs() { return new Jobs(); } }
    public static void main(String[] a) throws Exception {
        int early, late;
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Thread.sleep(600);  early = checks.get();
            Thread.sleep(2000); late = checks.get();
            release = true;                                        // let the spinning report end, so the JVM can exit
        }
        System.out.println("  one report that never returns, on the default single thread:");
        System.out.println("    order checks by 0.6 s: " + early + "   by 2.6 s: " + late
                + "   -> " + (late == early ? "the check has STOPPED" : "the check is still running"));
    }
}

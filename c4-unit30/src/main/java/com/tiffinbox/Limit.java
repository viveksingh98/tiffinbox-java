package com.tiffinbox;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.context.annotation.*;
import org.springframework.resilience.annotation.*;

/**
 * @ConcurrencyLimit: at most N callers inside a method at once. Six cooks arrive together and the kitchen has
 * two burners. The other four do not fail - they wait (policy BLOCK, the default; WhereItLives reads it).
 */
public final class Limit {
    private Limit() { }
    static final AtomicInteger inside = new AtomicInteger(), peak = new AtomicInteger(), cooked = new AtomicInteger();
    static void cook() throws InterruptedException {
        peak.accumulateAndGet(inside.incrementAndGet(), Math::max);
        Thread.sleep(200);
        inside.decrementAndGet(); cooked.incrementAndGet();
    }
    public static class Kitchen {
        @ConcurrencyLimit(2) public void cookOnTwoBurners() throws InterruptedException { cook(); }
        public void cookAnywhere() throws InterruptedException { cook(); }
    }
    @Configuration @EnableResilientMethods static class Cfg { @Bean Kitchen kitchen() { return new Kitchen(); } }
    interface Cook { void run() throws InterruptedException; }
    static String sixAtOnce(Cook c) {
        inside.set(0); peak.set(0); cooked.set(0);
        try (ExecutorService pool = Executors.newFixedThreadPool(6)) {
            for (int i = 0; i < 6; i++) pool.submit(() -> { c.run(); return null; });
        }
        return "at most " + peak.get() + " cooking at once, " + cooked.get() + " of 6 cooked";
    }
    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Kitchen k = ctx.getBean(Kitchen.class);
            System.out.println("  six cooks at once, no limit            : " + sixAtOnce(k::cookAnywhere));
            System.out.println("  six cooks at once, @ConcurrencyLimit(2): " + sixAtOnce(k::cookOnTwoBurners));
        }
    }
}

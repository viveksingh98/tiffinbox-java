package com.tiffinbox;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.*;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.*;

/**
 * @Async on a listener: it leaves the publisher's thread, so publish returns without waiting for it. The
 * thread NAME is the proof - its prefix, never its number (contract 2g). And when an async listener throws,
 * the publisher never hears: Spring logs it at SEVERE and the caller carries on. Observed here; configured
 * in the next unit.
 */
public final class AsyncListener {
    private AsyncListener() { }
    /**
     * The async listener WAITS for the publisher to say it has returned before it prints. That makes the
     * capture's order deterministic - and it is itself a proof: if publish waited for this listener, the
     * listener would be waiting for a return that could not happen until it finished. The 2-second
     * timeout is a guard so a synchronous mistake shows up as a slow run, not a hang.
     */
    static volatile java.util.concurrent.CountDownLatch returned = new java.util.concurrent.CountDownLatch(1);
    static final java.util.concurrent.CountDownLatch done = new java.util.concurrent.CountDownLatch(2);
    public static class Listeners {
        @EventListener public void sync(OrderPlaced e) { System.out.println("  [sync ] on " + t()); }
        @Async @EventListener public void async(OrderPlaced e) throws InterruptedException {
            boolean afterReturn = returned.await(2, java.util.concurrent.TimeUnit.SECONDS);
            System.out.println("  [async] on " + t() + (afterReturn ? "   (after publish returned)" : "   (*** publish had NOT returned ***)"));
            done.countDown();
            if (e.customer().equals("nobody")) throw new IllegalStateException("async listener refused nobody");
        }
    }
    static String t() { return Thread.currentThread().getName().replaceAll("\\d+$", "<n>"); }
    @Configuration @EnableAsync static class Cfg { @Bean Listeners l() { return new Listeners(); } }
    public static void main(String[] args) throws Exception {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            ApplicationEventPublisher p = ctx;
            System.out.println("  publishing on " + t());
            p.publishEvent(new OrderPlaced("Ravi", 340));
            System.out.println("  publish returned");
            returned.countDown();
            Thread.sleep(200);
            returned = new java.util.concurrent.CountDownLatch(1);
            System.out.println("an async listener throws:");
            p.publishEvent(new OrderPlaced("nobody", 340));
            System.out.println("  publish returned - the caller never heard");
            returned.countDown();
            done.await(3, java.util.concurrent.TimeUnit.SECONDS);
            Thread.sleep(200);
        }
    }
}

package com.tiffinbox;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.context.annotation.*;
import org.springframework.scheduling.annotation.*;

/**
 * PITFALL TWO - and the skeleton had it pinned on the wrong scheduler. The same job, throwing on its second
 * run, handed to two schedulers. Spring's @Scheduled logs the error at SEVERE and KEEPS GOING. The JDK's
 * own scheduleAtFixedRate stops for ever, and prints nothing at all.
 */
public final class TwoSchedulers {
    private TwoSchedulers() { }
    static final AtomicInteger springRuns = new AtomicInteger(), jdkRuns = new AtomicInteger();
    static void tick(AtomicInteger n) { if (n.incrementAndGet() == 2) throw new IllegalStateException("the till jammed on run 2"); }
    public static class Job { @Scheduled(fixedRate = 100) public void tick() { TwoSchedulers.tick(springRuns); } }
    @Configuration @EnableScheduling static class Cfg { @Bean Job job() { return new Job(); } }

    public static void main(String[] a) throws Exception {
        System.out.println("Spring's @Scheduled, throwing on run 2:");
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) { Thread.sleep(700); }
        System.out.println("  runs in 0.7 s: " + (springRuns.get() > 3 ? "MORE than 3 - it kept going" : "3 or fewer - it stopped"));
        System.out.println("the JDK's scheduleAtFixedRate, the same job:");
        ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
        ScheduledFuture<?> f = ses.scheduleAtFixedRate(() -> tick(jdkRuns), 0, 100, TimeUnit.MILLISECONDS);
        Thread.sleep(700);
        System.out.println("  runs in 0.7 s: " + jdkRuns.get() + "   (and nothing was printed)   future done? " + f.isDone());
        ses.shutdownNow();
    }
}

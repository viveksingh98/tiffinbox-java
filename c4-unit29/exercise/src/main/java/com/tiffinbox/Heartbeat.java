package com.tiffinbox;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * EXERCISE. The kitchen's old heartbeat runs on the JDK's own scheduler, not on Spring's. On its second beat
 * the printer is out of paper, and the heartbeat is never heard from again - with nothing printed anywhere.
 *   1. The exception was not thrown away. It is being KEPT somewhere. Find it and print it.
 *   2. Make the heartbeat survive a bad beat - and make the bad beat loud.
 */
public final class Heartbeat {
    private Heartbeat() { }
    static final AtomicInteger beats = new AtomicInteger();
    static void beat() { if (beats.incrementAndGet() == 2) throw new IllegalStateException("printer out of paper on beat 2"); }

    public static void main(String[] a) throws Exception {
        ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
        ScheduledFuture<?> f = ses.scheduleAtFixedRate(Heartbeat::beat, 0, 100, TimeUnit.MILLISECONDS);
        Thread.sleep(700);
        System.out.println("beats in 0.7 s: " + (beats.get() > 3 ? "more than 3 - alive" : beats.get() + " - dead"));
        ses.shutdownNow();
    }
}

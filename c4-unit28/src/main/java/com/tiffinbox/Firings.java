package com.tiffinbox;

import java.util.*;
import java.util.concurrent.*;

/**
 * Records when each firing STARTS, then prints the gaps between starts - the only numbers the claim
 * needs. Work is done by spinning on the clock rather than sleeping, so closing the context never
 * interrupts a job mid-sleep (that printed a SEVERE InterruptedException in the first probe, which is
 * noise, not evidence).
 */
final class Firings {
    private Firings() { }
    static final List<Long> starts = Collections.synchronizedList(new ArrayList<>());
    static volatile CountDownLatch finished;
    static volatile int running, maxRunning;

    static void job(long workMs) {
        synchronized (Firings.class) { running++; maxRunning = Math.max(maxRunning, running); }
        starts.add(System.nanoTime());
        long end = System.nanoTime() + workMs * 1_000_000;
        while (System.nanoTime() < end) { Thread.onSpinWait(); }
        synchronized (Firings.class) { running--; }
        finished.countDown();
    }

    static void reset(int firings) { starts.clear(); running = 0; maxRunning = 0; finished = new CountDownLatch(firings); }

    /** Gaps between consecutive starts, in whole milliseconds. */
    static List<Long> gaps() {
        List<Long> g = new ArrayList<>();
        for (int i = 1; i < starts.size(); i++) g.add(Math.round((starts.get(i) - starts.get(i - 1)) / 1e6));
        return g;
    }
}

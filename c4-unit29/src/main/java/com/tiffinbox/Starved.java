package com.tiffinbox;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.context.annotation.*;
import org.springframework.scheduling.annotation.*;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;

/**
 * PITFALL ONE. A quick order check every 100 ms, and one slow report of 800 ms. With no scheduler
 * configured, Spring uses ONE thread.
 *
 * A FIRST VERSION OF THIS PROGRAM COUNTED CHECKS, and got 11 against 11 - no difference - while printing
 * "the report starved it" unconditionally. Both were wrong. A fixed-rate task that misses its slots CATCHES
 * UP in a burst afterwards, so the COUNT recovers and hides the starvation. What does not recover is the
 * RHYTHM: the longest gap between two checks, and the burst of back-to-back checks that follows it. That is
 * what this measures, and every verdict below is computed, not printed beside the numbers.
 */
public final class Starved {
    private Starved() { }
    static final List<Long> checks = Collections.synchronizedList(new ArrayList<>());
    static volatile boolean reportRan;
    static final Set<String> threads = ConcurrentHashMap.newKeySet();
    public static class Jobs {
        @Scheduled(fixedRate = 100) public void checkOrders() { checks.add(System.nanoTime()); threads.add(Thread.currentThread().getName()); }
        @Scheduled(fixedRate = 100, initialDelay = 50) public void report() {
            threads.add(Thread.currentThread().getName());
            if (reportRan) return;
            reportRan = true;
            long end = System.nanoTime() + 800_000_000L;
            while (System.nanoTime() < end) Thread.onSpinWait();
        }
    }
    @Configuration @EnableScheduling static class OneThread { @Bean Jobs jobs() { return new Jobs(); } }
    @Configuration @EnableScheduling static class TwoThreads {
        @Bean Jobs jobs() { return new Jobs(); }
        @Bean ThreadPoolTaskScheduler taskScheduler() {
            ThreadPoolTaskScheduler s = new ThreadPoolTaskScheduler(); s.setPoolSize(2); s.setThreadNamePrefix("kitchen-sched-"); return s;
        }
    }
    record Result(int count, long longestGapMs, int burst, Set<String> threads) { }
    static Result run(Class<?> cfg) throws Exception {
        checks.clear(); threads.clear(); reportRan = false;
        try (var ctx = new AnnotationConfigApplicationContext(cfg)) { Thread.sleep(1200); }
        long gap = 0; int burst = 0;
        for (int i = 1; i < checks.size(); i++) {
            long g = Math.round((checks.get(i) - checks.get(i - 1)) / 1e6);
            gap = Math.max(gap, g);
            if (g < 20) burst++;                                   // two checks under 20 ms apart: a catch-up run
        }
        return new Result(checks.size(), gap, burst, new TreeSet<>(threads));
    }
    static String masked(Set<String> names) {
        return names.size() + " " + new TreeSet<>(names.stream().map(n -> n.replaceAll("\\d+", "<n>")).toList());
    }
    public static void main(String[] a) throws Exception {
        Result one = run(OneThread.class), two = run(TwoThreads.class);
        System.out.println("  threads that ran both jobs, one thread (the default): " + masked(one.threads()));
        System.out.println("  threads that ran both jobs, a pool of two           : " + masked(two.threads()));
        System.out.println("  the same 1.2 s: an 800 ms report beside a 100 ms order check");
        System.out.println("    check count, one thread vs pool of two     : "
                + (Math.abs(one.count() - two.count()) <= 2 ? "about the same -> counting cannot see the problem" : "different"));
        System.out.println("    longest gap between checks, one thread     : "
                + (one.longestGapMs() >= 600 ? "600 ms or more -> the report STARVED the check" : "under 600 ms -> not starved"));
        System.out.println("    longest gap between checks, pool of two    : "
                + (two.longestGapMs() <= 200 ? "200 ms or less -> the check kept its rhythm" : "over 200 ms -> still starved"));
        System.out.println("    checks run back-to-back, one thread        : "
                + (one.burst() >= 5 ? "5 or more -> the missed checks caught up in a burst" : "fewer than 5"));
        System.out.println("    checks run back-to-back, pool of two       : " + (two.burst() == 0 ? "none" : "some"));
        System.out.println("  raw (printed, never spoken): counts " + one.count() + " vs " + two.count()
                + ", longest gaps " + one.longestGapMs() + " vs " + two.longestGapMs() + " ms, back-to-back "
                + one.burst() + " vs " + two.burst());
    }
}

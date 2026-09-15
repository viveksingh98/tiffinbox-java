package com.tiffinbox.bench;

import com.tiffinbox.Customer;

import java.util.List;

/**
 * The benchmark everybody writes first: nanoTime, a loop, a division.
 *
 * <p>It measures exactly the same three methods as {@link ReceiptBench}, from the same
 * roster, in the same JVM. It is not a straw man - it is careful by the standards of a
 * stopwatch. It uses {@code System.nanoTime} rather than {@code currentTimeMillis}, it
 * divides by the iteration count, and it keeps a running sink so the result is at least
 * used. Read it and decide what is missing before you read the next paragraph.
 *
 * <p>What is missing: <b>no warm-up</b>, so the first thousands of iterations run
 * interpreted and then get recompiled halfway through. <b>One JVM</b>, so one set of JIT
 * decisions is the whole sample. <b>No repetition</b>, so there is nothing to compute a
 * spread from and no error term can exist. <b>Three measurements in one process</b>, so
 * whichever runs first pays for class loading and the profile of the last one is polluted
 * by the two before it. And the sink is a field read by nobody, which the JIT is entitled
 * to notice.
 *
 * <p>Run it three times. The numbers will not agree with each other, and none of them will
 * carry anything that tells you that.
 */
public final class NaiveTimer {

    private static final List<Customer> ROSTER = Receipts.ROSTER;

    private static int sink;

    public static void main(String[] args) {
        int reps = args.length > 0 ? Integer.parseInt(args[0]) : 200_000;
        System.out.printf("naive: %d iterations each, one JVM, no warm-up%n", reps);
        time("concatInALoop", reps, NaiveTimer::concat);
        time("stringBuilder", reps, NaiveTimer::builder);
        time("streamJoining", reps, NaiveTimer::stream);
    }

    private static void time(String name, int reps, Runnable body) {
        long t0 = System.nanoTime();
        for (int i = 0; i < reps; i++) {
            body.run();
        }
        long ns = System.nanoTime() - t0;
        System.out.printf("%-14s %8.3f ns/op%n", name, (double) ns / reps);
    }

    // The SAME three methods the JMH benchmark calls. Nothing here is a different program.
    private static void concat()  { sink += Receipts.concat(ROSTER).length(); }

    private static void builder() { sink += Receipts.builder(ROSTER).length(); }

    private static void stream()  { sink += Receipts.stream(ROSTER).length(); }
}

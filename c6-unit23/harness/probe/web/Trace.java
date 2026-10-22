package probe.web;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * The course's harness, never TiffinBox's: every hook below prints one line through here, to standard output - the same stream Boot's
 * log writes to - as "HOOK nnn what happened". The number counts every hook line this JVM printed, in the order the code ran, so the
 * order on screen is the program's own, never typed. No thread name: under virtual threads one request can show two.
 */
public final class Trace {

    private static final AtomicInteger N = new AtomicInteger();

    private Trace() {
    }

    public static void log(String what) {
        System.out.println("HOOK " + String.format("%04d", N.incrementAndGet()) + " " + what);
    }
}

// Why a stopwatch cannot answer "is + in a loop slow?" - and what can.
// Run:  java Timing.java
import java.lang.management.ManagementFactory;
import com.sun.management.ThreadMXBean;

String plusLoop(int n) {
    String s = "";
    for (int i = 0; i < n; i++) {
        s = s + "VEG, ";
    }
    return s;
}

String builderLoop(int n) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < n; i++) {
        sb.append("VEG, ");
    }
    return sb.toString();
}

void main() {
    int n = 5000;

    IO.println("A. the stopwatch everyone writes -- no warm-up");
    for (int round = 1; round <= 5; round++) {
        long t0 = System.nanoTime();
        String s = plusLoop(n);
        long ms = (System.nanoTime() - t0) / 1_000_000;
        IO.println("   round " + round + " : about " + ms + " ms   (" + s.length() + " characters)");
    }

    IO.println("B. the same method, warmed up first -- 50 discarded runs");
    long sink = 0;
    for (int i = 0; i < 50; i++) {
        sink += plusLoop(n).length();
    }
    long best = Long.MAX_VALUE, worst = 0;
    for (int round = 1; round <= 7; round++) {
        long t0 = System.nanoTime();
        sink += plusLoop(n).length();
        long us = (System.nanoTime() - t0) / 1_000;
        best = Math.min(best, us);
        worst = Math.max(worst, us);
    }
    IO.println("   7 warmed rounds        : " + (best / 1000.0) + " ms to " + (worst / 1000.0) + " ms");
    IO.println("   (warm-up total ignored : " + sink + " characters)");

    IO.println("C. counted instead of timed -- bytes this thread allocated");
    ThreadMXBean tb = (ThreadMXBean) ManagementFactory.getThreadMXBean();
    long id = Thread.currentThread().threadId();
    plusLoop(n);
    builderLoop(n);
    long b0 = tb.getThreadAllocatedBytes(id);
    String s1 = plusLoop(n);
    long b1 = tb.getThreadAllocatedBytes(id);
    String s2 = builderLoop(n);
    long b2 = tb.getThreadAllocatedBytes(id);
    long plus = b1 - b0, built = b2 - b1;
    IO.println("   + in a loop  allocated : " + (plus / (1024 * 1024)) + " MB");
    IO.println("   StringBuilder allocated: " + (built / 1024) + " KB");
    IO.println("   ratio                  : " + (plus / built) + " times more");
    IO.println("   same string?           : " + s1.equals(s2));

    IO.println("   double n, quadruple the bytes:");
    for (int size : new int[] { 5000, 10000, 20000 }) {
        plusLoop(size);                                   // warm this size first
        long a0 = tb.getThreadAllocatedBytes(id);
        plusLoop(size);
        long a1 = tb.getThreadAllocatedBytes(id);
        IO.println("     n = " + size + "  ->  " + ((a1 - a0) / (1024 * 1024)) + " MB");
    }
}

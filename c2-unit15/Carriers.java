import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

// The carrier is the real OS thread a virtual thread is mounted on right now.
// Thread.currentThread() prints  VirtualThread[#26,cook-1]/runnable@ForkJoinPool-1-worker-1
static String carrier() {
    String s = Thread.currentThread().toString();
    int at = s.lastIndexOf('@');
    return at < 0 ? "(unmounted)" : s.substring(at + 1);
}

void main() throws Exception {
    // ── phase 1: four virtual threads mounted AT THE SAME TIME ──
    var phase1 = new ConcurrentSkipListSet<String>();
    var arrived = new AtomicInteger();
    var done = new CountDownLatch(4);
    for (int i = 0; i < 4; i++) {
        Thread.ofVirtual().start(() -> {
            phase1.add(carrier());
            arrived.incrementAndGet();
            while (arrived.get() < 4) Thread.onSpinWait();   // stay mounted until all four are
            done.countDown();
        });
    }
    done.await();
    IO.println("phase 1 virtual threads: 4");
    IO.println("carriers used:           " + phase1.size() + " " + phase1);

    // ── phase 2: a thousand of them ──
    var phase2 = new ConcurrentSkipListSet<String>();
    try (var runner = Executors.newVirtualThreadPerTaskExecutor()) {
        for (int i = 0; i < 1000; i++) {
            runner.submit(() -> {
                phase2.add(carrier());
                try { Thread.sleep(1); } catch (InterruptedException e) { return; }
                phase2.add(carrier());          // it may come back on a DIFFERENT carrier
            });
        }
    }
    IO.println("phase 2 virtual threads: 1000");
    IO.println("carriers used:           " + phase2.size() + " " + phase2);
}

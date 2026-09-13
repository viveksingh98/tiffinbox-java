import java.time.Duration;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

// The same ten thousand waiters, on Section 3's answer: a fixed pool of platform threads.
void main() {
    int waiters = 10_000, poolSize = 200;
    var completed = new AtomicInteger();
    long t0 = System.nanoTime();

    try (var runner = Executors.newFixedThreadPool(poolSize)) {        // 200 OS threads
        for (int i = 0; i < waiters; i++) {
            runner.submit(() -> {
                try { Thread.sleep(Duration.ofSeconds(1)); }
                catch (InterruptedException e) { return; }
                completed.incrementAndGet();
            });
        }
    }

    long secs = Math.round((System.nanoTime() - t0) / 1_000_000_000.0);
    IO.println("pool threads:      " + poolSize);
    IO.println("waiters started:   " + waiters);
    IO.println("completed:         " + completed.get());
    IO.println("wall clock:        about " + secs + " s");
}

import java.time.Duration;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

// Ten thousand TiffinBox customers, each waiting one second for the payment gateway.
void main() {
    int waiters = 10_000;
    var completed = new AtomicInteger();
    long t0 = System.nanoTime();

    try (var runner = Executors.newVirtualThreadPerTaskExecutor()) {   // not a pool
        for (int i = 0; i < waiters; i++) {
            runner.submit(() -> {
                try { Thread.sleep(Duration.ofSeconds(1)); }           // the gateway answers
                catch (InterruptedException e) { return; }
                completed.incrementAndGet();
            });
        }
    }                                                                  // close() waits for all

    long secs = Math.round((System.nanoTime() - t0) / 1_000_000_000.0);
    IO.println("waiters started:   " + waiters);
    IO.println("completed:         " + completed.get());
    IO.println("each one waited:   1 s");
    IO.println("wall clock:        about " + secs + " s");
}

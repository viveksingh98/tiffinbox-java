import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

// JEP 491 (JDK 24): blocking inside synchronized no longer pins the carrier.
// Four virtual threads, four separate monitors, ONE carrier thread for the whole JVM.
// Before JDK 24 the first cook would pin that carrier and the other three never start.
void main() throws Exception {
    var allInside = new CountDownLatch(4);
    var completed = new AtomicInteger();
    var cooks = new Thread[4];

    for (int i = 0; i < 4; i++) {
        final Object fridge = new Object();                 // its own monitor: no contention
        cooks[i] = Thread.ofVirtual().name("cook-" + (i + 1)).start(() -> {
            synchronized (fridge) {
                allInside.countDown();
                try { allInside.await(); }                  // blocks INSIDE synchronized
                catch (InterruptedException e) { return; }
                completed.incrementAndGet();
            }
        });
    }

    boolean all = allInside.await(20, TimeUnit.SECONDS);    // false = the old pinning behaviour
    for (Thread cook : cooks) cook.join(5_000);

    IO.println("carrier threads allowed: " + System.getProperty("jdk.virtualThreadScheduler.maxPoolSize"));
    IO.println("virtual threads blocked inside synchronized: 4");
    IO.println("all finished:            " + all);
    IO.println("completed:               " + completed.get());
}

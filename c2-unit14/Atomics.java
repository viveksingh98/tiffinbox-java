import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.LongAdder;

static final AtomicInteger ordersTaken = new AtomicInteger();
static final LongAdder mealsServed = new LongAdder();

void main() throws InterruptedException {
    int cooks = 4, ordersEach = 500_000;
    var done = new CountDownLatch(cooks);
    for (int c = 1; c <= cooks; c++) {
        Thread.ofPlatform().name("cook-" + c).start(() -> {
            for (int i = 0; i < ordersEach; i++) {
                ordersTaken.incrementAndGet();   // compare-and-set, retried
                mealsServed.increment();         // one cell per thread
            }
            done.countDown();
        });
    }
    done.await();
    IO.println("AtomicInteger: " + ordersTaken.get());
    IO.println("LongAdder:     " + mealsServed.sum());
}

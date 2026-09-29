package demo;

import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import org.springframework.scheduling.annotation.Async;

/**
 * One @Async method, and a note of every thread it ran on. Each order takes 50 ms, so twenty orders are in flight at
 * once: a pool of N threads shows N names, and an executor that starts a thread per task shows twenty.
 */
public class AsyncKitchen implements Kitchen {

    public static final int ORDERS = 20;

    private final Set<String> names = ConcurrentHashMap.newKeySet();
    private final CountDownLatch done = new CountDownLatch(ORDERS);

    @Async
    @Override
    public void cook(int order) {
        names.add(Thread.currentThread().getName());
        try {
            Thread.sleep(50);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        done.countDown();
    }

    @Override
    public List<String> threadsUsed() throws InterruptedException {
        if (!done.await(10, TimeUnit.SECONDS)) {
            throw new IllegalStateException("only " + (ORDERS - done.getCount()) + " of " + ORDERS + " orders cooked in 10 s");
        }
        return names.stream().sorted().toList();
    }
}

package com.tiffinbox;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

/** Unit 18: the kitchen rail. Cooks are virtual threads; the poison pill stops them. */
public final class OrderQueue implements AutoCloseable {

    public record Order(String customer, int value) {}

    private static final Order CLOSED = new Order("--kitchen closed--", 0);

    private final LinkedBlockingQueue<Order> rail = new LinkedBlockingQueue<>();
    private final AtomicInteger cooked = new AtomicInteger();
    private final AtomicInteger cookedValue = new AtomicInteger();
    private final CountDownLatch closed;
    private final int cooks;
    private final ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

    public OrderQueue(int cooks) {
        this.cooks = cooks;
        this.closed = new CountDownLatch(cooks);
        for (int i = 0; i < cooks; i++) {
            executor.submit(() -> {
                while (true) {
                    Order o = rail.take();
                    if (o == CLOSED) {
                        closed.countDown();
                        return null;
                    }
                    cooked.incrementAndGet();
                    cookedValue.addAndGet(o.value());
                }
            });
        }
    }

    public void place(Order o) throws InterruptedException {
        rail.put(o);
    }

    public int cooked() { return cooked.get(); }

    public int cookedValue() { return cookedValue.get(); }

    @Override
    public void close() throws InterruptedException {
        for (int i = 0; i < cooks; i++) rail.put(CLOSED);
        closed.await();
        executor.close();
    }
}

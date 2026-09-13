import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

record Order(String customer, int meals, int pricePerMeal) {
    int value() { return meals * pricePerMeal; }
}

static final Order CLOSED = new Order("--kitchen closed--", 0, 0);

void main() throws Exception {
    int cooks = 3;
    var rail     = new LinkedBlockingQueue<Order>();
    var revenue  = new ConcurrentHashMap<String, Integer>();
    var consumed = new AtomicInteger();
    var cookIds  = ConcurrentHashMap.<Long>newKeySet();
    var virtual  = ConcurrentHashMap.<Boolean>newKeySet();
    var closed   = new CountDownLatch(cooks);
    int queued   = 0;

    try (var kitchen = Executors.newVirtualThreadPerTaskExecutor()) {
        for (int i = 0; i < cooks; i++) {
            kitchen.submit(() -> {
                cookIds.add(Thread.currentThread().threadId());
                virtual.add(Thread.currentThread().isVirtual());
                while (true) {
                    Order o = rail.take();
                    if (o == CLOSED) { closed.countDown(); return null; }
                    revenue.merge(o.customer(), o.value(), Integer::sum);
                    consumed.incrementAndGet();
                }
            });
        }
        Order[] menu = {
            new Order("Ravi",  2, 120),
            new Order("Meera", 1, 150),
            new Order("Sunil", 3, 100),
            new Order("Priya", 1, 120)
        };
        for (int day = 1; day <= 30; day++)
            for (Order o : menu) { rail.put(o); queued++; }
        for (int i = 0; i < cooks; i++) rail.put(CLOSED);
        closed.await();
    }

    IO.println("orders queued:   " + queued);
    IO.println("orders consumed: " + consumed.get());
    IO.println("rail empty:      " + rail.isEmpty());
    boolean allVirtual = virtual.equals(Set.of(true));
    IO.println("cooks (virtual): " + (allVirtual ? cookIds.size() : "NOT ALL VIRTUAL"));
    int total = 0;
    for (Map.Entry<String, Integer> e : new TreeMap<>(revenue).entrySet()) {
        IO.println(e.getKey() + " -> " + e.getValue());
        total += e.getValue();
    }
    IO.println("kitchen revenue: " + total);
}

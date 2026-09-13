import java.util.List;
import java.util.TreeMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;

record Order(String mealType, int price) {}

static final List<Order> MENU = List.of(
        new Order("VEG", 120), new Order("NON_VEG", 150),
        new Order("VEGAN", 140), new Order("VEG", 100));

void main() throws InterruptedException {
    var revenue = new ConcurrentHashMap<String, Integer>();
    int cooks = 4, ordersEach = 1_000;
    var done = new CountDownLatch(cooks);
    for (int c = 1; c <= cooks; c++) {
        Thread.ofPlatform().name("cook-" + c).start(() -> {
            for (int i = 0; i < ordersEach; i++) {
                Order o = MENU.get(i % MENU.size());
                revenue.merge(o.mealType(), o.price(), Integer::sum);
            }
            done.countDown();
        });
    }
    done.await();
    int total = 0;
    for (var e : new TreeMap<>(revenue).entrySet()) {
        IO.println(e.getKey() + ": " + e.getValue());
        total += e.getValue();
    }
    IO.println("total: " + total);
}

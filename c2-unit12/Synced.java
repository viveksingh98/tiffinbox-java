// One cook at the counter at a time.
static final Object counterLock = new Object();
static int ordersTaken = 0;

static void takeOrders() {
    for (int i = 0; i < 1_000_000; i++) {
        synchronized (counterLock) {
            ordersTaken++;
        }
    }
}

void main() throws InterruptedException {
    Thread cook1 = new Thread(() -> takeOrders(), "cook-1");
    Thread cook2 = new Thread(() -> takeOrders(), "cook-2");
    cook1.start();
    cook2.start();
    cook1.join();
    cook2.join();
    IO.println("expected: 2000000");
    IO.println("actual:   " + ordersTaken);
}

// volatile buys visibility. It does not buy atomicity.
static volatile int ordersTaken = 0;

static void takeOrders() {
    for (int i = 0; i < 1_000_000; i++) {
        ordersTaken++;                 // still read, add one, write back
    }
}

void main() throws InterruptedException {
    Thread cook1 = new Thread(() -> takeOrders(), "cook-1");
    Thread cook2 = new Thread(() -> takeOrders(), "cook-2");
    cook1.start();
    cook2.start();
    cook1.join();
    cook2.join();
    IO.println("volatile counter: " + ordersTaken + "  (expected 2000000)");
}

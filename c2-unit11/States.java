import java.util.concurrent.CountDownLatch;

void main() throws InterruptedException {
    Object orderCounter = new Object();
    CountDownLatch aboutToReach = new CountDownLatch(1);

    Runnable shift = () -> {
        try { Thread.sleep(300); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
        aboutToReach.countDown();
        synchronized (orderCounter) { }
    };
    Thread cook = Thread.ofPlatform().name("cook").unstarted(shift);

    IO.println("1 before start:      " + cook.getState());
    synchronized (orderCounter) {
        cook.start();
        Thread.sleep(100);
        IO.println("2 during sleep:      " + cook.getState());
        aboutToReach.await();
        Thread.sleep(100);
        IO.println("3 waiting for lock:  " + cook.getState());
    }
    cook.join();
    IO.println("4 after join:        " + cook.getState());
}

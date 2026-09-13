import java.util.concurrent.CountDownLatch;

public class Deadlock {
    static final Object fridge = new Object();
    static final Object stove  = new Object();

    public static void main(String[] args) throws Exception {
        CountDownLatch bothHold = new CountDownLatch(2);

        Thread cook1 = Thread.ofPlatform().name("cook-1").unstarted(() -> {
            synchronized (fridge) {
                bothHold.countDown();
                awaitQuietly(bothHold);
                synchronized (stove) { System.out.println("cook-1 plated"); }
            }
        });
        Thread cook2 = Thread.ofPlatform().name("cook-2").unstarted(() -> {
            synchronized (stove) {
                bothHold.countDown();
                awaitQuietly(bothHold);
                synchronized (fridge) { System.out.println("cook-2 plated"); }
            }
        });

        cook1.start();
        cook2.start();
        System.out.println("both cooks started; neither will finish");
        cook1.join();
        cook2.join();
    }

    static void awaitQuietly(CountDownLatch latch) {
        try { latch.await(); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
    }
}

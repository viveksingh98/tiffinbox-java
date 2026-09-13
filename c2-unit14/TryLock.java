import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;

void main() throws InterruptedException {
    var counter = new ReentrantLock();
    var held = new CountDownLatch(1);      // "the other cook has it"
    var release = new CountDownLatch(1);   // "let it go now"

    Thread other = Thread.ofPlatform().name("cook-2").start(() -> {
        counter.lock();
        try {
            held.countDown();
            release.await();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            counter.unlock();              // not style — the whole contract
        }
    });

    held.await();
    IO.println("counter locked by someone: " + counter.isLocked());
    IO.println("tryLock() now:             " + counter.tryLock());
    IO.println("tryLock(100ms):            " + counter.tryLock(100, TimeUnit.MILLISECONDS));
    release.countDown();
    other.join();
    boolean mine = counter.tryLock();
    IO.println("tryLock() after release:   " + mine);
    if (mine) counter.unlock();
}

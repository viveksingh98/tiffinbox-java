import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CountDownLatch;

void main() throws InterruptedException {
    CompletableFuture<Integer> bill = CompletableFuture.supplyAsync(
            () -> 7200 / Integer.parseInt("0"));

    var settled = new CountDownLatch(1);          // only so the demo is deterministic
    bill.whenComplete((value, ex) -> settled.countDown());
    settled.await();

    IO.println("stage failed? " + bill.isCompletedExceptionally()
            + " -- and nothing was printed");

    bill.join();   // the only line that makes the failure real
}

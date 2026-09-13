import java.util.NoSuchElementException;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.StructuredTaskScope;
import java.util.concurrent.StructuredTaskScope.FailedException;
import java.util.concurrent.StructuredTaskScope.Joiner;
import java.util.concurrent.StructuredTaskScope.Subtask;

void main() throws InterruptedException {
    var bothReady = new CountDownLatch(1);
    try (var scope = StructuredTaskScope.open(Joiner.<Integer>allSuccessfulOrThrow())) {
        Subtask<Integer> ravi = scope.fork(() -> {
            bothReady.await();
            Thread.sleep(10_000);          // a slow price feed
            return 7200;
        });
        Subtask<Integer> kiran = scope.fork(() -> {
            bothReady.await();
            throw new NoSuchElementException("no price card for Kiran");
        });
        bothReady.countDown();             // release both at the same moment
        try {
            scope.join();
        } catch (FailedException e) {
            IO.println("join threw:    " + e.getClass().getName());
            IO.println("because:       " + e.getCause());
        }
        IO.println("Kiran subtask: " + kiran.state());
        IO.println("Ravi subtask:  " + ravi.state() + "   <- cancelled, not waited for");
        IO.println("scope cancelled? " + scope.isCancelled());
    }
}

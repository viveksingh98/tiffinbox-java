import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

void main() {
    String c = CompletableFuture
            .supplyAsync(() -> { try { Thread.sleep(2000); } catch (InterruptedException e) {} return "slow"; })
            .orTimeout(200, TimeUnit.MILLISECONDS)
            .exceptionally(ex -> "gave up: " + ex.getCause().getClass().getSimpleName())
            .join();
    IO.println(c);
}

import java.util.Map;
import java.util.NoSuchElementException;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

static final Map<String, Integer> SUBSCRIPTIONS = Map.of("Ravi", 2, "Kiran", 1);
static final Map<String, Integer> PRICE_CARD    = Map.of("Ravi", 120);

static int priceFor(String name) {
    Integer p = PRICE_CARD.get(name);
    if (p == null) throw new NoSuchElementException("no price card for " + name);
    return p;
}

static String bill(String name) {
    return name + " -> " + SUBSCRIPTIONS.get(name) * priceFor(name) * 30;
}

// the Throwable is a CompletionException when a task threw, and the RAW
// exception when orTimeout completed the stage -- so getCause() can be null.
static Throwable unwrap(Throwable ex) { return ex.getCause() != null ? ex.getCause() : ex; }

void main() {
    String a = CompletableFuture.supplyAsync(() -> bill("Kiran"))
            .exceptionally(ex -> "Kiran -> unbilled (" + unwrap(ex).getMessage() + ")")
            .join();
    IO.println("exceptionally: " + a);

    String b = CompletableFuture.supplyAsync(() -> bill("Ravi"))
            .handle((value, ex) -> ex == null ? "ok:   " + value : "lost: " + unwrap(ex))
            .join();
    IO.println("handle:        " + b);

    String c = CompletableFuture.supplyAsync(() -> { sleepQuietly(2000); return "slow price feed"; })
            .orTimeout(200, TimeUnit.MILLISECONDS)
            .exceptionally(ex -> "gave up: " + unwrap(ex))
            .join();
    IO.println("orTimeout:     " + c);
}

static void sleepQuietly(long ms) {
    try { Thread.sleep(ms); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
}

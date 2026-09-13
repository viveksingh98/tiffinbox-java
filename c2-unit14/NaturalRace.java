import java.util.ArrayList;
import java.util.ConcurrentModificationException;
import java.util.List;

void main() throws InterruptedException {
    List<String> orders = new ArrayList<>(List.of("order-1", "order-2", "order-3"));
    String[] verdict = {"no exception"};
    Thread reader = Thread.ofPlatform().name("reader").unstarted(() -> {
        try {
            for (String o : orders) { if (o.isEmpty()) IO.println("?"); }
        } catch (ConcurrentModificationException e) {
            verdict[0] = "ConcurrentModificationException";
        }
    });
    Thread writer = Thread.ofPlatform().name("writer").unstarted(() -> orders.add("order-4"));
    reader.start(); writer.start();
    reader.join(); writer.join();
    IO.println(verdict[0]);
}

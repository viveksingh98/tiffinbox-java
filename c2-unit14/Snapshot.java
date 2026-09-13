import java.util.ArrayList;
import java.util.ConcurrentModificationException;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Semaphore;

String race(List<String> orders) throws InterruptedException {
    var writerTurn = new Semaphore(0);
    var readerTurn = new Semaphore(0);
    int[] seen = {0};
    String[] verdict = {"no exception"};

    Thread reader = Thread.ofPlatform().name("reader").unstarted(() -> {
        try {
            for (String order : orders) {          // one iterator, start to end
                seen[0]++;
                if (seen[0] == 1) {                // baton: let the writer in, then wait
                    writerTurn.release();
                    readerTurn.acquire();
                }
            }
        } catch (ConcurrentModificationException e) {
            verdict[0] = e.getClass().getName();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    });
    Thread writer = Thread.ofPlatform().name("writer").unstarted(() -> {
        try {
            writerTurn.acquire();
            orders.add("order-4");                 // the append the reader never asked for
            readerTurn.release();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    });
    reader.start(); writer.start();
    reader.join(); writer.join();
    return "reader saw " + seen[0] + ", list size now " + orders.size() + ", " + verdict[0];
}

void main() throws InterruptedException {
    IO.println("ArrayList:            "
             + race(new ArrayList<>(List.of("order-1", "order-2", "order-3"))));
    IO.println("CopyOnWriteArrayList: "
             + race(new CopyOnWriteArrayList<>(List.of("order-1", "order-2", "order-3"))));
}

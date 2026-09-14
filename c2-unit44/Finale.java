import java.lang.reflect.Method;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.*;

record Order(String customer, int meals, int price) {
    int value() { return meals * price; }
}

class Kitchen {
    static List<Order> menu() {                                  // Section 2 — generics
        return List.of(new Order("Ravi", 2, 120), new Order("Meera", 1, 150),
                       new Order("Sunil", 3, 100), new Order("Priya", 1, 120));
    }

    static int day() throws Exception {                          // Sections 3-4 — concurrency
        try (var cooks = Executors.newVirtualThreadPerTaskExecutor()) {
            var jobs = menu().stream().map(o -> (Callable<Integer>) o::value).toList();
            int total = 0;
            for (var f : cooks.invokeAll(jobs)) total += f.get();
            return total;
        }
    }

    static int rows() throws Exception {                         // Section 5 — files
        Path csv = Files.createTempFile("tiffinbox", ".csv");
        Files.write(csv, menu().stream().map(o -> o.customer() + "," + o.value()).toList());
        int n = Files.readAllLines(csv).size();
        Files.delete(csv);
        return n;
    }

    static String parts() {                                      // Section 8 — reflection
        return Arrays.stream(Order.class.getRecordComponents())
                     .map(c -> c.getName()).collect(Collectors.joining(", "));
    }

    static String windows() {                                    // Section 8 — gatherers
        var w = menu().stream().gather(Gatherers.windowFixed(2)).toList();
        return w.size() + " windows of " + w.getFirst().size();
    }
}

void main() throws Exception {
    Method m = Kitchen.class.getDeclaredMethod("menu");

    IO.println("1 memory      heap ceiling " + Runtime.getRuntime().maxMemory() / (1 << 20) + " MB");
    IO.println("2 generics    " + m.getGenericReturnType() + "  ->  " + m.getReturnType().getName());
    IO.println("3 concurrency four virtual threads joined, kitchen total " + Kitchen.day());
    IO.println("4 service     " + Kitchen.rows() + " rows of CSV written and read back");
    IO.println("5 reflection  Order's components: " + Kitchen.parts());
    IO.println("6 gatherers   windowFixed(2) -> " + Kitchen.windows());
}

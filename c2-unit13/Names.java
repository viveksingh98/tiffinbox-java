import java.util.*;
import java.util.concurrent.*;

void main() {
    Set<String> names = ConcurrentHashMap.newKeySet();
    try (var pool = Executors.newFixedThreadPool(4)) {
        for (int i = 0; i < 40; i++)
            pool.submit(() -> names.add(Thread.currentThread().getName()));
    }
    IO.println("thread names: " + new TreeSet<>(names));
    IO.println("cores: " + Runtime.getRuntime().availableProcessors());
}

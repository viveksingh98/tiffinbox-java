import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.ToIntFunction;
import java.util.stream.Gatherer;
import java.util.stream.Gatherers;
import java.util.stream.Stream;

record Order(String customer, int value) {}

static <T> Gatherer<T, ?, T> withinBudget(int budget, ToIntFunction<T> cost) {
    return Gatherer.ofSequential(
            () -> new int[1],                                  // the private state
            (state, item, downstream) -> {
                if (state[0] + cost.applyAsInt(item) > budget) return false;   // STOP
                state[0] += cost.applyAsInt(item);
                return downstream.push(item);
            });
}

void main() {
    List<Order> day = List.of(
            new Order("Ravi", 240), new Order("Meera", 150), new Order("Sunil", 300),
            new Order("Priya", 120), new Order("Ravi", 240), new Order("Meera", 150));

    var pulled = new AtomicInteger();
    IO.println("budget 800, six orders:");
    day.stream().peek(o -> pulled.incrementAndGet())
       .gather(withinBudget(800, Order::value))
       .forEach(o -> IO.println("  " + o.customer() + " -> " + o.value()));
    IO.println("  orders pulled from upstream: " + pulled + " of " + day.size());

    IO.println("infinite stream, budget 1000:");
    IO.println("  " + Stream.iterate(100, n -> n + 50)
            .gather(withinBudget(1000, n -> n))
            .toList());

    IO.println("mapConcurrent(4) over the same six orders:");
    IO.println("  " + day.stream()
            .gather(Gatherers.mapConcurrent(4, o -> o.customer() + ":" + o.value()))
            .toList());
}

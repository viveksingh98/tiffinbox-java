import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.function.ToIntFunction;
import java.util.stream.Gatherer;

static <T> Gatherer<T, ?, T> withinBudget(int budget, ToIntFunction<T> cost, Set<String> seen) {
    return Gatherer.ofSequential(() -> new int[1], (state, item, downstream) -> {
        seen.add(Thread.currentThread().getName());
        if (state[0] + cost.applyAsInt(item) > budget) return false;
        state[0] += cost.applyAsInt(item);
        return downstream.push(item);
    });
}

void main() {
    var seen = new ConcurrentSkipListSet<String>();
    List<Integer> big = java.util.stream.IntStream.rangeClosed(1, 2000).boxed().toList();
    var got = big.parallelStream().gather(withinBudget(55, i -> i, seen)).toList();
    IO.println("parallelStream result: " + got);
    IO.println("distinct threads that ran the integrator: " + seen.size());
}

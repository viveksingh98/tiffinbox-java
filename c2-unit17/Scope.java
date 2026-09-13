import java.util.List;
import java.util.Map;
import java.util.concurrent.StructuredTaskScope;
import java.util.concurrent.StructuredTaskScope.Joiner;
import java.util.concurrent.StructuredTaskScope.Subtask;

static final Map<String, Integer> SUBSCRIPTIONS =
        Map.of("Meera", 1, "Priya", 1, "Ravi", 2, "Sunil", 2);
static final Map<String, Integer> PRICE_CARD =
        Map.of("Meera", 150, "Priya", 120, "Ravi", 120, "Sunil", 150);

static String bill(String name) throws InterruptedException {
    try (var scope = StructuredTaskScope.open(Joiner.<Integer>allSuccessfulOrThrow())) {
        scope.fork(() -> SUBSCRIPTIONS.get(name));
        scope.fork(() -> PRICE_CARD.get(name));
        List<Integer> parts = scope.join().map(Subtask::get).toList();
        return name + " -> " + (parts.get(0) * parts.get(1) * 30);
    }
}

void main() throws InterruptedException {
    List<String> customers = List.of("Ravi", "Meera", "Sunil", "Priya");
    try (var scope = StructuredTaskScope.open(Joiner.<String>allSuccessfulOrThrow())) {
        for (String c : customers) scope.fork(() -> bill(c));
        IO.println("subtasks forked: " + customers.size());
        List<String> bills = scope.join().map(Subtask::get).sorted().toList();
        bills.forEach(IO::println);
    }
    IO.println("scope closed: every subtask has finished");
}

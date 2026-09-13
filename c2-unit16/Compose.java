import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean active) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

// two services that know nothing about each other
static final Map<String, Integer> SUBSCRIPTIONS =
        Map.of("Ravi", 2, "Priya", 1, "Meera", 1, "Sunil", 2);
static final Map<String, Integer> PRICE_CARD =
        Map.of("Ravi", 120, "Priya", 120, "Meera", 150, "Sunil", 150);

static CompletableFuture<Customer> lookUp(String name) {
    CompletableFuture<Integer> meals = CompletableFuture.supplyAsync(() -> SUBSCRIPTIONS.get(name));
    CompletableFuture<Integer> price = CompletableFuture.supplyAsync(() -> PRICE_CARD.get(name));
    return meals.thenCombine(price, (m, p) -> new Customer(name, m, p, true));
}

void main() {
    List<String> names = List.of("Ravi", "Priya", "Meera", "Sunil");
    List<CompletableFuture<Customer>> found = names.stream().map(n -> lookUp(n)).toList();
    List<CompletableFuture<String>> stages = found.stream()
            .map(f -> f.thenApply(c -> c.name() + " -> " + c.monthlyBill()))
            .toList();

    CompletableFuture.allOf(stages.toArray(new CompletableFuture[0])).join();
    IO.println("all four stages done: " + stages.stream().allMatch(CompletableFuture::isDone));

    List<String> bills = new ArrayList<>();
    for (CompletableFuture<String> s : stages) bills.add(s.join());
    Collections.sort(bills);
    bills.forEach(IO::println);

    int total = found.stream().mapToInt(f -> f.join().monthlyBill()).sum();
    IO.println("month total: " + total);
}

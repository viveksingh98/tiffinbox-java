import java.util.*;
import java.util.concurrent.*;

record Customer(String name, int mealsPerDay, int pricePerMeal) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

void main() throws Exception {
    List<Customer> anchors = List.of(
            new Customer("Ravi",  2, 120),
            new Customer("Meera", 1, 150),
            new Customer("Sunil", 3, 100),
            new Customer("Priya", 1, 120));
    List<Customer> customers = new ArrayList<>();
    for (Customer a : anchors)
        for (int i = 1; i <= 10; i++)
            customers.add(new Customer(a.name() + "-" + i, a.mealsPerDay(), a.pricePerMeal()));

    Set<String> threadsUsed = ConcurrentHashMap.newKeySet();
    List<Future<String>> futures = new ArrayList<>();

    try (var pool = Executors.newFixedThreadPool(4)) {
        for (Customer c : customers)
            futures.add(pool.submit(() -> {
                threadsUsed.add(Thread.currentThread().getName());
                return c.name() + " -> " + c.monthlyBill();
            }));
    }

    List<String> bills = new ArrayList<>();
    for (Future<String> f : futures) bills.add(f.get());
    Collections.sort(bills);

    int total = customers.stream().mapToInt(Customer::monthlyBill).sum();
    IO.println("customers billed:      " + bills.size());
    IO.println("distinct pool threads: " + threadsUsed.size());
    IO.println("first three, sorted:   " + String.join(" | ", bills.subList(0, 3)));
    IO.println("month total:           " + total);
}

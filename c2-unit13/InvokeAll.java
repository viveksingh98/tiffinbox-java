import java.util.*;
import java.util.concurrent.*;

record Customer(String name, int mealsPerDay, int pricePerMeal) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

void main() throws Exception {
    List<Customer> customers = List.of(
            new Customer("Ravi",  2, 120),
            new Customer("Meera", 1, 150),
            new Customer("Sunil", 3, 100),
            new Customer("Priya", 1, 120));

    var tasks = new ArrayList<Callable<String>>();
    for (Customer c : customers)
        tasks.add(() -> c.name() + " -> " + c.monthlyBill());

    try (var pool = Executors.newFixedThreadPool(4)) {
        List<Future<String>> done = pool.invokeAll(tasks);
        for (Future<String> f : done) IO.println(f.get());
    }
}

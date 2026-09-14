import java.util.List;
import java.util.stream.Gatherers;

record Customer(String name, int meals, int pricePerMeal) {
    int monthlyBill() { return meals * pricePerMeal * 30; }
}

void main() {
    List<Integer> days = List.of(240, 150, 300, 120, 240, 150, 300);

    IO.println("windowFixed(3):");
    days.stream().gather(Gatherers.windowFixed(3)).forEach(w -> IO.println("  " + w));

    IO.println("windowSliding(3):");
    days.stream().gather(Gatherers.windowSliding(3)).forEach(w -> IO.println("  " + w));

    IO.println("scan (running revenue):");
    IO.println("  " + days.stream()
            .gather(Gatherers.scan(() -> 0, Integer::sum))
            .toList());

    List<Customer> book = List.of(
            new Customer("Ravi", 2, 120), new Customer("Meera", 1, 150),
            new Customer("Sunil", 3, 100), new Customer("Priya", 1, 120));

    IO.println("fold (month's revenue):");
    IO.println("  " + book.stream()
            .gather(Gatherers.fold(() -> 0, (acc, c) -> acc + c.monthlyBill()))
            .findFirst().orElseThrow());
}

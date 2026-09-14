import java.util.ArrayList;
import java.util.List;

public class Handlers {
    static final List<Customer> BOOK = List.of(
            new Customer("Ravi", 2, 120, true),
            new Customer("Meera", 1, 150, false),
            new Customer("Sunil", 3, 100, true),
            new Customer("Priya", 1, 120, true));

    @Route(path = "/customers")
    String listCustomers() {
        List<String> names = new ArrayList<>();
        for (Customer c : BOOK) names.add(c.name());
        return names.toString();
    }

    @Route(path = "/revenue")
    String revenue() {
        int perDay = 0;
        for (Customer c : BOOK) perDay += c.mealsPerDay() * c.pricePerMeal();
        return String.valueOf(perDay * 30);
    }

    @Route(path = "/orders", method = "POST")
    String placeOrder() {
        return "order accepted";
    }

    String notARoute() {
        return "internal helper, not a route";
    }
}

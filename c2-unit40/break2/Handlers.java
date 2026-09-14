import java.util.ArrayList;
import java.util.List;

public class Handlers {
    @Route(path = "/oops")
    static final String KITCHEN = "Asha's kitchen";

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
}

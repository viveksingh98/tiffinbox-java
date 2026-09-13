import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

record Subscription(int id, String customer, String meal) {}

static <T> List<T> firstTwo(List<T> items) {
    return items.subList(0, Math.min(2, items.size()));
}

static <T> T load(Class<T> type, Map<Class<?>, Object> store) {
    return type.cast(store.get(type));
}

void main() {
    List<Customer> customers = List.of(
            new Customer("Ravi", 2, 120, true),
            new Customer("Meera", 1, 150, true),
            new Customer("Sunil", 3, 100, false),
            new Customer("Priya", 1, 120, true));
    List<String> labels = List.of("VEG", "NON_VEG", "VEGAN");

    List<Customer> twoCustomers = firstTwo(customers);
    List<String> twoLabels = firstTwo(labels);
    IO.println("firstTwo(customers): " + twoCustomers.get(0).name() + ", " + twoCustomers.get(1).name());
    IO.println("firstTwo(labels):    " + twoLabels);

    List<Customer> nobody = Collections.emptyList();
    IO.println("target type:         " + nobody + " size " + nobody.size());
    var witness = Collections.<Customer>emptyList();
    IO.println("explicit witness:    " + witness + " size " + witness.size());

    Map<Class<?>, Object> store = new HashMap<>();
    store.put(Customer.class, new Customer("Ravi", 2, 120, true));
    store.put(Subscription.class, new Subscription(1, "Ravi", "VEG"));
    Customer ravi = load(Customer.class, store);
    IO.println("load(Customer.class):     " + ravi.name() + " -> " + ravi.monthlyBill());
    IO.println("load(Subscription.class): " + load(Subscription.class, store));
}

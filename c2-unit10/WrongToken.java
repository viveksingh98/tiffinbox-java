import java.util.HashMap;
import java.util.Map;

class WrongToken {
    record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {}
    record Subscription(int id, String customer, String meal) {}

    static <T> T load(Class<T> type, Map<Class<?>, Object> store) { return type.cast(store.get(type)); }

    public static void main(String[] args) {
        Map<Class<?>, Object> store = new HashMap<>();
        store.put(Customer.class, new Subscription(1, "Ravi", "VEG"));
        Customer ravi = load(Customer.class, store);
        System.out.println(ravi);
    }
}

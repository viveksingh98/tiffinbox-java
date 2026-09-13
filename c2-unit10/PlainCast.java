import java.util.HashMap;
import java.util.Map;

class PlainCast {
    record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {}
    record Subscription(int id, String customer, String meal) {}

    @SuppressWarnings("unchecked")
    static <T> T loadUnchecked(Class<T> type, Map<Class<?>, Object> store) { return (T) store.get(type); }

    public static void main(String[] args) {
        Map<Class<?>, Object> store = new HashMap<>();
        store.put(Customer.class, new Subscription(1, "Ravi", "VEG"));
        Customer ravi = loadUnchecked(Customer.class, store);
        System.out.println("no error yet: " + ravi.getClass().getSimpleName());
        System.out.println(ravi.name());
    }
}

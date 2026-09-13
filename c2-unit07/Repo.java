import java.util.function.Function;

interface Repository<T, ID> {
    void save(T item);
    Optional<T> findById(ID id);
    List<T> findAll();
    int count();
}

class InMemoryRepository<T, ID> implements Repository<T, ID> {
    private final Map<ID, T> store = new LinkedHashMap<>();
    private final Function<T, ID> idOf;

    InMemoryRepository(Function<T, ID> idOf) { this.idOf = idOf; }

    public void save(T item)              { store.put(idOf.apply(item), item); }
    public Optional<T> findById(ID id)    { return Optional.ofNullable(store.get(id)); }
    public List<T> findAll()              { return List.copyOf(store.values()); }
    public int count()                    { return store.size(); }
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

enum MealType { VEG, NON_VEG, VEGAN }

record Subscription(int id, String customer, MealType meal) {}

void main() {
    Repository<Customer, String> customers = new InMemoryRepository<>(Customer::name);
    customers.save(new Customer("Ravi",  2, 120, true));
    customers.save(new Customer("Meera", 1, 150, false));
    customers.save(new Customer("Sunil", 3, 100, true));

    Repository<Subscription, Integer> subs = new InMemoryRepository<>(Subscription::id);
    subs.save(new Subscription(1, "Ravi", MealType.VEG));
    subs.save(new Subscription(2, "Meera", MealType.NON_VEG));

    IO.println("customers: " + customers.count() + ", subscriptions: " + subs.count());
    IO.println("findById(\"Ravi\"):  " + customers.findById("Ravi"));
    IO.println("findById(\"Priya\"): " + customers.findById("Priya"));
    IO.println("findById(2):       " + subs.findById(2));
    IO.println("bill for Meera:    " + customers.findById("Meera").map(Customer::monthlyBill).orElse(0));
}

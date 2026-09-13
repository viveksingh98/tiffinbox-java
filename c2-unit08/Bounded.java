import java.util.List;

void main() {
    List<Customer> customers = List.of(
            new Customer("Ravi",  2, 120, true),
            new Customer("Meera", 1, 150, true),
            new Customer("Sunil", 3, 100, false),
            new Customer("Priya", 1, 120, true));

    Customer top = max(customers);
    IO.println("biggest bill:  " + top.name() + " -> " + top.monthlyBill());
    IO.println("last label A-Z: " + max(List.of("VEG", "NON_VEG", "VEGAN")));
    IO.println("most meals/day: " + max(List.of(2, 1, 3, 1)));
    IO.println(describe(new VegMeal(120)));
    IO.println(describe(new VeganMeal(140)));
}

static <T extends Comparable<T>> T max(List<T> items) {
    T best = items.get(0);
    for (T item : items) {
        if (item.compareTo(best) > 0) best = item;
    }
    return best;
}

static <T extends Meal & Priced> String describe(T meal) {
    return meal.label() + " at " + meal.price();
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg)
        implements Comparable<Customer> {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
    public int compareTo(Customer other) {
        return Integer.compare(this.monthlyBill(), other.monthlyBill());
    }
}

interface Meal  { String label(); }
interface Priced { int price(); }

record VegMeal(int price)   implements Meal, Priced { public String label() { return "VEG";   } }
record VeganMeal(int price) implements Meal, Priced { public String label() { return "VEGAN"; } }

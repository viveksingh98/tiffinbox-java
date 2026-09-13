import java.util.ArrayList;
import java.util.List;

sealed interface Meal permits VegMeal, NonVegMeal, VeganMeal {
    int price();
}
record VegMeal(int price) implements Meal {}
record NonVegMeal(int price) implements Meal {}
record VeganMeal(int price) implements Meal {}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

// PRODUCER: we only read meals out of the list
static int totalPrice(List<? extends Meal> meals) {
    int total = 0;
    for (Meal m : meals) total += m.price();
    return total;
}

// PECS in one signature: source produces, target consumes
static void copyBills(List<? extends Customer> source, List<? super Integer> target) {
    for (Customer c : source) target.add(c.monthlyBill());
}

// bare wildcard: we touch no element at all
static int howMany(List<?> anything) {
    return anything.size();
}

void main() {
    List<VegMeal> vegOnly = List.of(new VegMeal(120), new VegMeal(100));
    List<Meal> mixed = List.of(new VegMeal(120), new NonVegMeal(150), new VeganMeal(140));
    IO.println("veg only total: " + totalPrice(vegOnly));
    IO.println("mixed total:    " + totalPrice(mixed));

    List<Customer> customers = List.of(
        new Customer("Ravi", 2, 120, true),
        new Customer("Meera", 1, 150, false),
        new Customer("Sunil", 3, 100, true),
        new Customer("Priya", 1, 120, true));
    List<Object> ledger = new ArrayList<>();
    List<Number> numbers = new ArrayList<>();
    copyBills(customers, ledger);
    copyBills(customers, numbers);
    IO.println("ledger:  " + ledger);
    IO.println("numbers: " + numbers);

    IO.println("howMany(vegOnly): " + howMany(vegOnly) + ", howMany(ledger): " + howMany(ledger));
}

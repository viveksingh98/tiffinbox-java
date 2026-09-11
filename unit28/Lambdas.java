void main() {
    var ravi = new Customer("Ravi", 2, 120, true);
    var meera = new Customer("Meera", 1, 150, false);
    var sunil = new Customer("Sunil", 1, 120, true);
    var customers = new ArrayList<>(List.of(ravi, meera, sunil));

    Predicate<Customer> isVeg = c -> c.isVeg();
    IO.println(isVeg.test(ravi) + " " + isVeg.test(meera));

    Function<Customer, Integer> bill = Customer::monthlyBill;
    IO.println(bill.apply(ravi));
    Consumer<Customer> print = c -> IO.println(c.name() + " pays " + bill.apply(c));
    customers.forEach(print);
    Supplier<Customer> walkIn = () -> new Customer("Guest", 1, 120, true);
    IO.println(walkIn.get());

    Predicate<Customer> bigSpender = c -> c.monthlyBill() > 5000;
    Predicate<Customer> vegAndBig = isVeg.and(bigSpender);
    IO.println(vegAndBig.test(ravi) + " " + vegAndBig.test(sunil));
    customers.removeIf(isVeg.negate());
    IO.println(customers.size() + " veg customers");
    Discount festive = amount -> amount - amount / 10;
    IO.println(festive.apply(7200));
}

@FunctionalInterface
interface Discount {
    int apply(int amount);
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

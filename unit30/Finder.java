void main() {
    var customers = List.of(new Customer("Ravi", 2, 120, true), new Customer("Meera", 1, 150, false), new Customer("Sunil", 1, 120, true));
    IO.println(findByName(customers, "Meera"));
    IO.println(findByName(customers, "Asha"));
    IO.println(findByName(customers, "Meera").map(Customer::monthlyBill).orElse(0));
    IO.println(findByName(customers, "Asha").map(Customer::monthlyBill).orElse(0));
    findByName(customers, "Sunil").ifPresent(c -> IO.println(c.name() + " is on the list"));
    findByName(customers, "Asha").ifPresentOrElse(
        c -> IO.println(c.name() + " is on the list"),
        () -> IO.println("no such customer"));
}

Optional<Customer> findByName(List<Customer> customers, String name) {
    return customers.stream().filter(c -> c.name().equals(name)).findFirst();
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

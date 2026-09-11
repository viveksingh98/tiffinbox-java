void main() {
    var customers = List.of(new Customer("Ravi", 2, 120, true), new Customer("Meera", 1, 150, false), new Customer("Sunil", 1, 120, true));
    var ravi = findByName(customers, "Ravi")
        .orElseThrow(() -> new IllegalArgumentException("no customer named Ravi"));
    IO.println(ravi.name() + " pays " + ravi.monthlyBill());
    var guest = findByName(customers, "Asha")
        .orElseGet(() -> new Customer("Guest", 1, 120, true));
    IO.println(guest);
}

Optional<Customer> findByName(List<Customer> customers, String name) {
    return customers.stream().filter(c -> c.name().equals(name)).findFirst();
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

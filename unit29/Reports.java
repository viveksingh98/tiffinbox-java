void main() {
    var customers = List.of(
        new Customer("Ravi", 2, 120, true),
        new Customer("Meera", 1, 150, false),
        new Customer("Sunil", 1, 120, true));

    var vegNames = customers.stream()
        .filter(Customer::isVeg)
        .map(Customer::name)
        .toList();
    IO.println(vegNames);

    int revenue = customers.stream().mapToInt(Customer::monthlyBill).sum();
    IO.println("Monthly revenue: " + revenue);

    IO.println(customers.stream()
        .sorted(Comparator.comparing(Customer::monthlyBill).reversed())
        .map(c -> c.name() + " " + c.monthlyBill())
        .toList());

    IO.println("Reminder to: " + customers.stream()
        .map(Customer::name)
        .collect(Collectors.joining(", ")));
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

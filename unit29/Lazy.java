void main() {
    var customers = List.of(
        new Customer("Ravi", 2, 120, true),
        new Customer("Meera", 1, 150, false),
        new Customer("Sunil", 1, 120, true));

    var veg = customers.stream()
        .filter(c -> { IO.println("filter " + c.name()); return c.isVeg(); })
        .map(Customer::name);
    IO.println("pipeline built, nothing ran yet");
    IO.println(veg.toList());
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

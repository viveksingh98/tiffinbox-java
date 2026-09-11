void main() {
    var customers = List.of(new Customer("Ravi", 2, 120, true),
        new Customer("Meera", 1, 150, false), new Customer("Sunil", 1, 120, true));
    var vegOnly = customers.stream().filter(Customer::isVeg);
    IO.println(vegOnly.count());
    IO.println(vegOnly.map(Customer::name).toList());
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

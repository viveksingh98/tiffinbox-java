void main() {
    var customers = List.of(new Customer("Ravi", 2, 120, true), new Customer("Meera", 1, 150, false), new Customer("Sunil", 1, 120, true));
    var asha = findByName(customers, "Asha").get();
    IO.println(asha.monthlyBill());
}

Optional<Customer> findByName(List<Customer> customers, String name) {
    return customers.stream().filter(c -> c.name().equals(name)).findFirst();
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

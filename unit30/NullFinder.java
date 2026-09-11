void main() {
    var customers = List.of(new Customer("Ravi", 2, 120, true), new Customer("Meera", 1, 150, false), new Customer("Sunil", 1, 120, true));
    IO.println(findByName(customers, "Asha").monthlyBill());
}

Customer findByName(List<Customer> customers, String name) {
    for (var c : customers) if (c.name().equals(name)) return c;
    return null;
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

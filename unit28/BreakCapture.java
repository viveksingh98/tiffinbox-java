void main() {
    var customers = List.of(new Customer("Ravi", 2, 120, true), new Customer("Meera", 1, 150, false), new Customer("Sunil", 1, 120, true));
    int total = 0;
    customers.forEach(c -> total += c.monthlyBill());
    IO.println("Revenue: " + total);
}

record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

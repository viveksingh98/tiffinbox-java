void main() {
    List<Customer> customers = new ArrayList<>();
    List<String> names = new ArrayList<>();
    customers.add(new Customer("Ravi", 2, 120, true));
    names.add("Ravi");
    IO.println("customers class: " + customers.getClass().getName());
    IO.println("names class:     " + names.getClass().getName());
    IO.println("same class?      " + (customers.getClass() == names.getClass()));
}
record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

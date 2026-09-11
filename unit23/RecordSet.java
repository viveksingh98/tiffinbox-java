void main() {
    var ravi = new Customer("Ravi", 2);
    var again = new Customer("Ravi", 2);
    IO.println(ravi);
    IO.println(ravi.equals(again));
    Set<Customer> customers = new HashSet<>();
    customers.add(ravi);
    customers.add(again);
    customers.add(new Customer("Meera", 1));
    IO.println(customers.size());
}

record Customer(String name, int mealsPerDay) {}

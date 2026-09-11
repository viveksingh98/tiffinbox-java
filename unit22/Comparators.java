void main() {
    var customers = new ArrayList<Customer>();
    customers.add(new Customer("Ravi", 2, 120));
    customers.add(new Customer("Meera", 1, 150));
    customers.add(new Customer("Sunil", 1, 120));
    customers.sort(Comparator.comparing(Customer::monthlyBill));
    show(customers);
    customers.sort(Comparator.comparing(Customer::monthlyBill).reversed());
    show(customers);
    customers.sort(Comparator.comparing(Customer::getMealsPerDay)
                             .thenComparing(Customer::getName));
    show(customers);
}

void show(List<Customer> customers) {
    var line = "";
    for (var c : customers) line += c.getName() + " " + c.monthlyBill() + " | ";
    IO.println(line);
}

class Customer {
    private final String name;
    private final int mealsPerDay;
    private final int pricePerMeal;

    Customer(String name, int mealsPerDay, int pricePerMeal) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
        this.pricePerMeal = pricePerMeal;
    }

    String getName() { return name; }
    int getMealsPerDay() { return mealsPerDay; }
    int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

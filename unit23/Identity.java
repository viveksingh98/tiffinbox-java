void main() {
    var ravi = new Customer("Ravi", 2);
    var again = new Customer("Ravi", 2);
    IO.println(ravi);
    IO.println(ravi.equals(again));
    IO.println(ravi.hashCode() == again.hashCode());
}

class Customer {
    private final String name;
    private int mealsPerDay;

    Customer(String name, int mealsPerDay) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
    }

    String getName() { return name; }
    int getMealsPerDay() { return mealsPerDay; }
}

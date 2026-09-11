void main() {
    var ravi = new Customer("Ravi", 2);
    var again = new Customer("Ravi", 2);
    IO.println(ravi);
    IO.println("Today: " + ravi);
    IO.println(ravi.equals(again));
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

    @Override
    public String toString() {
        return name + " (" + mealsPerDay + " meals/day)";
    }

    @Override
    public boolean equals(Object o) {
        return o instanceof Customer other
            && name.equals(other.name)
            && mealsPerDay == other.mealsPerDay;
    }
}

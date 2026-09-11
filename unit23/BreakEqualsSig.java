void main() {
    var ravi = new Customer("Ravi", 2);
    IO.println(ravi.equals(new Customer("Ravi", 2)));
}

class Customer {
    private final String name;
    private int mealsPerDay;

    Customer(String name, int mealsPerDay) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
    }

    @Override
    public boolean equals(Customer other) {
        return name.equals(other.name)
            && mealsPerDay == other.mealsPerDay;
    }
}

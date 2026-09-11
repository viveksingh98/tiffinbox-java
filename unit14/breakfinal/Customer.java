public class Customer {
    private final String name;
    private int mealsPerDay;

    public Customer(String name, int mealsPerDay) {
        this.mealsPerDay = mealsPerDay;
    }

    public String getName() { return name; }
}

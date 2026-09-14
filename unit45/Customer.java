public class Customer {

    private final String name;
    private final int    mealsPerDay;

    private Customer(Builder b) { this.name = b.name; this.mealsPerDay = b.mealsPerDay; }

    /** static nested: filed inside Customer for tidiness, needs no Customer to exist. */
    public static class Builder {
        private String name        = "Guest";
        private int    mealsPerDay = 0;
        public Builder name(String n)     { this.name = n; return this; }
        public Builder mealsPerDay(int m) { this.mealsPerDay = m; return this; }
        public Customer build()           { return new Customer(this); }
    }

    /** inner: cannot exist without a Customer, and reads name without a dot. */
    public class Receipt {
        public String print() { return "Receipt for " + name + ": " + mealsPerDay * 120 * 30; }
    }

    public static void main(String[] args) {
        Customer priya = new Customer.Builder().name("Priya").mealsPerDay(2).build();
        System.out.println(priya.name + " x" + priya.mealsPerDay);
        Customer.Receipt slip = priya.new Receipt();
        System.out.println(slip.print());
        System.out.println("Builder needs no Customer : " + Customer.Builder.class.getName());
        System.out.println("Receipt is tied to one    : " + Customer.Receipt.class.getName());
    }
}

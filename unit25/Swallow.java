void main() {
    var ravi = new Customer("Ravi", 2);
    try {
        ravi.setMealsPerDay(-5);
    } catch (Exception e) { }
    IO.println("Bill for " + ravi.getName() + ": " + ravi.monthlyBill());
}

class TiffinBoxException extends RuntimeException {
    TiffinBoxException(String message) { super(message); }
    TiffinBoxException(String message, Throwable cause) { super(message, cause); }
}

class Customer {
    private final String name;
    private int mealsPerDay;

    Customer(String name, int mealsPerDay) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
    }

    String getName() { return name; }
    int monthlyBill() { return mealsPerDay * 120 * 30; }

    void setMealsPerDay(int mealsPerDay) {
        if (mealsPerDay < 1 || mealsPerDay > 3)
            throw new TiffinBoxException("meals a day must be 1 to 3, got " + mealsPerDay);
        this.mealsPerDay = mealsPerDay;
    }
}

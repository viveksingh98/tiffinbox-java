void main() {
    var ravi = new Customer("Ravi", 2, 120, true);
    IO.println(ravi.name + ": " + ravi.monthlyBill());
    var meera = new Customer("  Meera ");
    IO.println("[" + meera.name + "]: " + meera.monthlyBill());
}

class Customer {
    String name;
    int mealsPerDay;
    int pricePerMeal;
    boolean isVeg;

    Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
        this.name = name;
        this.mealsPerDay = mealsPerDay;
        this.pricePerMeal = pricePerMeal;
        this.isVeg = isVeg;
    }

    Customer(String name) {
        var clean = name.trim();
        this(clean, 2, 120, true);
    }

    int monthlyBill() {
        return mealsPerDay * pricePerMeal * 30;
    }
}

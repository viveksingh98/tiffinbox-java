void main() {
    Customer ravi = new Customer("Ravi", 2, 120);
    Rider sunil = new Rider("Sunil", 22);
    Payable[] payables = { ravi, sunil };
    for (var p : payables) {
        IO.println(p.receipt());
    }
}

interface Payable {
    int amountDue();
    default String receipt() { return "Due: " + amountDue(); }
}

class Customer implements Payable {
    String name; int mealsPerDay; int pricePerMeal;
    Customer(String name, int mealsPerDay, int pricePerMeal) {
        this.name = name; this.mealsPerDay = mealsPerDay; this.pricePerMeal = pricePerMeal;
    }
    @Override public int amountDue() { return mealsPerDay * pricePerMeal * 30; }
}

class Rider implements Payable {
    String name; int deliveryDays;
    Rider(String name, int deliveryDays) { this.name = name; this.deliveryDays = deliveryDays; }
    @Override public int amountDue() { return deliveryDays * 400; }
    @Override public String receipt() { return name + " earns " + amountDue(); }
}

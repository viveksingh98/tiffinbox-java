void main() {
    Object item = new Order("Ravi", MealType.VEG, 2);
    if (item instanceof Order order && order.quantity() > 1) {
        IO.println(order.customer() + " ordered " + order.quantity() + " meals");
    }
    Payment[] today = { new Cash(), new Upi("ravi@okbank"), new Card("4421"), new Card("5123") };
    for (var payment : today) IO.println(describe(payment));
    Receipt[] receipts = {
        new Receipt(new Order("Meera", MealType.NON_VEG, 1), new Upi("meera@okbank")),
        new Receipt(new Order("Sunil", MealType.VEGAN, 1), new Cash())
    };
    for (var receipt : receipts) IO.println(summarise(receipt));
}

String describe(Payment payment) {
    return switch (payment) {
        case Cash() -> "cash at the door";
        case Upi(String vpa) -> "UPI to " + vpa;
        case Card(String last4) when last4.startsWith("4") -> "Visa ending " + last4;
        case Card(String last4) -> "card ending " + last4;
    };
}

String summarise(Receipt receipt) {
    return switch (receipt) {
        case Receipt(Order(var customer, var type, var quantity), Upi(var vpa)) ->
            customer + " paid for " + quantity + " " + type + " by UPI (" + vpa + ")";
        case Receipt(Order order, Payment other) ->
            order.customer() + " paid " + order.total() + " another way";
    };
}

record Order(String customer, MealType type, int quantity) {
    int total() { return quantity * type.price(); }
}

enum MealType {
    VEG(120), NON_VEG(150), VEGAN(130);

    private final int price;

    MealType(int price) { this.price = price; }

    int price() { return price; }
}

sealed interface Payment permits Cash, Upi, Card {}
record Cash() implements Payment {}
record Upi(String vpa) implements Payment {}
record Card(String last4) implements Payment {}
record Receipt(Order order, Payment payment) {}

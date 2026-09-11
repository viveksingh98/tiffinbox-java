void main() {
    Payable sunil = new Rider("Sunil", 22);
    IO.println(sunil.receipt());
}

interface Payable {
    int amountDue();
    default String receipt() { return "Due: " + amountDue(); }
}

class Rider implements Payable {
    String name; int deliveryDays;
    Rider(String name, int deliveryDays) { this.name = name; this.deliveryDays = deliveryDays; }
    // amountDue() forgotten: the promise is not kept
}

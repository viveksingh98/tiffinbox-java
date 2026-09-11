void main() {
    var order = new Order("Ravi", MealType.VEG, 2);
    IO.println(order);
    IO.println(order.customer() + " pays " + order.total());
    IO.println(order.equals(new Order("Ravi", MealType.VEG, 2)));
    for (var type : MealType.values()) {
        IO.println(type + " -> " + type.price());
    }
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

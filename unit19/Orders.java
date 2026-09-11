void main() {
    var orders = new ArrayList<Order>();
    orders.add(new Order("Ravi", MealType.VEG, 2));
    orders.add(new Order("Meera", MealType.NON_VEG, 1));
    orders.add(new Order("Sunil", MealType.VEGAN, 1));
    int total = 0;
    for (var order : orders) total += order.total();
    IO.println(orders.size() + " orders, today's takings: " + total);
    var menu = List.of("lentil rice", "bean curry", "chickpea curry");
    IO.println(menu.get(1) + " of " + menu.size());
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

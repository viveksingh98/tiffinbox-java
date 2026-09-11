void main() {
    var orders = List.of(
        new Order("Ravi", MealType.VEG, 2),
        new Order("Meera", MealType.NON_VEG, 1),
        new Order("Sunil", MealType.VEGAN, 1),
        new Order("Ravi", MealType.VEG, 1));

    var byType = orders.stream().collect(
        Collectors.groupingBy(Order::type, TreeMap::new, Collectors.summingInt(Order::total)));
    IO.println(byType);

    var countByType = orders.stream().collect(
        Collectors.groupingBy(Order::type, TreeMap::new, Collectors.counting()));
    IO.println(countByType);

    IO.println("Takings: " + orders.stream().mapToInt(Order::total).sum());
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

void main() {
    Object item = new Order("Ravi", MealType.VEG, 2);
    if (item instanceof Order order || order.quantity() > 1) {
        IO.println("matched");
    }
}

record Order(String customer, MealType type, int quantity) {}

enum MealType { VEG, NON_VEG, VEGAN }

void main() {
    var order = new Order("Ravi", MealType.VEG, 2);
    order.quantity = 3;   // a record is a value
    IO.println(order);
}

record Order(String customer, MealType type, int quantity) {}

enum MealType { VEG, NON_VEG, VEGAN }

void main() {
    String[] types = {"veg", "non-veg", "vge"};
    int[] quantities = {2, 1, 1};
    for (int i = 0; i <= 3; i++) {
        try {
            IO.println(types[i] + " x " + quantities[i] + " = " + priceFor(types[i]) * quantities[i]);
        } catch (IllegalArgumentException | ArrayIndexOutOfBoundsException e) {
            IO.println("Skipped: " + e.getMessage());
        }
    }
}
int priceFor(String mealType) {
    return switch (mealType) {
        case "veg" -> 120;
        case "non-veg" -> 150;
        case "jain" -> 130;
        default -> throw new IllegalArgumentException("unknown meal type: " + mealType);
    };
}

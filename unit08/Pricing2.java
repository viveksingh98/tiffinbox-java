void main() {
    String mealType = "jain";
    int price = switch (mealType) {
        case "veg" -> 120;
        case "non-veg" -> 150;
        case "jain" -> {
            IO.println("Jain: no onion, no garlic");
            yield 130;
        }
        default -> 0;
    };
    IO.println(mealType + " meal: " + price);
}

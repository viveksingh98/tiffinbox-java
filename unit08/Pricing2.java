void main() {
    String mealType = "vegan";
    int price = switch (mealType) {
        case "veg" -> 120;
        case "non-veg" -> 150;
        case "vegan" -> {
            IO.println("Vegan: no dairy, no eggs");
            yield 130;
        }
        default -> 0;
    };
    IO.println(mealType + " meal: " + price);
}

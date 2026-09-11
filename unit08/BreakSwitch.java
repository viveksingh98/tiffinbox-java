void main() {
    String mealType = "vegan";
    int price = switch (mealType) {
        case "veg" -> 120;
        case "non-veg" -> 150;
        case "vegan" -> 130;
    };
    IO.println(mealType + " meal: " + price);
}

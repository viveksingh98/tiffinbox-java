void main() {
    String mealType = "jain";
    int price = switch (mealType) {
        case "veg" -> 120;
        case "non-veg" -> 150;
        case "jain" -> 130;
    };
    IO.println(mealType + " meal: " + price);
}

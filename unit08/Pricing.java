void main() {
    String mealType = "vegan";
    int price;
    if (mealType.equals("veg")) {
        price = 120;
    } else if (mealType.equals("non-veg")) {
        price = 150;
    } else {
        price = 130;
    }
    IO.println(mealType + " meal: " + price);
}

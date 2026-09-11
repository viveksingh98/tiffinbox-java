void main() {
    int mealsPerDay = 2;
    double pricePerMeal = 120.0;
    boolean isVeg = true;
    String customerName = "Ravi";
    var total = mealsPerDay * pricePerMeal;
    IO.println(customerName + " eats " + mealsPerDay + " meals, pays " + total);
}

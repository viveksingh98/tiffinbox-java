public record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    public int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
}

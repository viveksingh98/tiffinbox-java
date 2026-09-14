/** Asha's customer — a record, so the JVM knows its own shape. */
public record Customer(String name, int mealsPerDay, int pricePerMeal, boolean isVeg) {
    public int monthlyBill() { return mealsPerDay * pricePerMeal * 30; }
    private String secretNote() { return "priority customer"; }
}

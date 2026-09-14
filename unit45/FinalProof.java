class Meal {
    protected int basePrice = 120;
    final int deliveryFee() { return 20; }
}

final class VeganMeal extends Meal { }

record Order(String customer, int meals) { }

void main() throws Exception {
    IO.println("String        is final: " + Modifier.isFinal(String.class.getModifiers()));
    IO.println("Integer       is final: " + Modifier.isFinal(Integer.class.getModifiers()));
    IO.println("LocalDate     is final: " + Modifier.isFinal(LocalDate.class.getModifiers()));
    IO.println("java.lang.IO  is final: " + Modifier.isFinal(IO.class.getModifiers()));
    IO.println("record Order  is final: " + Modifier.isFinal(Order.class.getModifiers()));
    IO.println("Meal (ours)   is final: " + Modifier.isFinal(Meal.class.getModifiers()));
    IO.println("VeganMeal     is final: " + Modifier.isFinal(VeganMeal.class.getModifiers()));
    IO.println("deliveryFee() is final: " + Modifier.isFinal(Meal.class.getDeclaredMethod("deliveryFee").getModifiers()));
}

class Meal {
    protected int basePrice = 120;
    final int deliveryFee() { return 20; }
}

class VeganMeal extends Meal {
    @Override int deliveryFee() { return 0; }
}

void main() {
    IO.println(new VeganMeal().deliveryFee());
}

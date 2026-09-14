public class Pricing {
    static int deliveryFee(Meal m) {
        return switch (m) {
            case Veg v    -> 20;
            case NonVeg n -> 30;
        };
    }

    public static void main(String[] args) {
        Meal today = Meal.today();
        System.out.println("today: " + today);
        System.out.println("fee:   " + deliveryFee(today));
    }
}

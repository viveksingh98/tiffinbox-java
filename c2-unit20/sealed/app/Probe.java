/** Catches the MatchException so you can read its message with your own eyes. */
public class Probe {
    public static void main(String[] args) {
        try {
            Pricing.deliveryFee(Meal.today());
        } catch (MatchException e) {
            System.out.println("class:   " + e.getClass().getName());
            System.out.println("message: " + e.getMessage());
            System.out.println("cause:   " + e.getCause());
            System.out.println("frames:  " + e.getStackTrace().length);
        }
    }
}

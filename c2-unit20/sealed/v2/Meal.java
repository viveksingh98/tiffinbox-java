/** TiffinBox menu library, version 2. One more permitted kind. Nothing else changed. */
public sealed interface Meal permits Veg, NonVeg, Vegan {
    String name();
    int price();

    /** What the kitchen is serving today. */
    static Meal today() {
        return new Vegan("Garden Bowl", 120);
    }
}

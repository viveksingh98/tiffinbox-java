/** TiffinBox menu library, version 1. Two kinds of meal, and that is the whole world. */
public sealed interface Meal permits Veg, NonVeg {
    String name();
    int price();

    /** What the kitchen is serving today. */
    static Meal today() {
        return new Veg("Garden Bowl", 120);
    }
}

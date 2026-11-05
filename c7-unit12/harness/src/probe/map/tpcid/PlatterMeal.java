package probe.map.tpcid;

import jakarta.persistence.Entity;

/** A platter: a meal of several dishes. */
@Entity
public class PlatterMeal extends Meal {
    private int dishes;

    protected PlatterMeal() { }
    public PlatterMeal(String title, int price, int dishes) { super(title, price); this.dishes = dishes; }
    @Override protected String extra() { return "dishes " + dishes; }
}

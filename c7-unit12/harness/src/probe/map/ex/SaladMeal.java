package probe.map.ex;

import jakarta.persistence.Entity;

/** A salad, with its dressing. */
@Entity
public class SaladMeal extends Meal {
    private String dressing;

    protected SaladMeal() { }
    public SaladMeal(String title, int price, String dressing) { super(title, price); this.dressing = dressing; }
    @Override protected String extra() { return "dressing " + dressing; }
}

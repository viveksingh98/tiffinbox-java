package com.tiffinbox;

import org.springframework.beans.factory.annotation.Value;

/**
 * One bean, three values, and every one of them arrives as a string in a file.
 *
 * <p>{@code meal} is the interesting one: the file holds {@code non-veg} and this field is a
 * MealType, so a converter has to run between the two. The other two are here because
 * {@code @Value} handles them with no help at all, which is what makes the third one worth a unit.
 */
public class Kitchen {

    /** No converter needed: Spring has always known how to make an int out of "4". */
    private final int cooks;

    /** A default, after the colon. Nothing in the file sets this. */
    private final String rail;

    /** THE ONE THAT NEEDS YOUR CONVERTER. */
    private final MealType meal;

    public Kitchen(@Value("${tiffinbox.cooks}") int cooks,
                   @Value("${tiffinbox.rail:kitchen}") String rail,
                   @Value("${tiffinbox.meal}") MealType meal) {
        this.cooks = cooks;
        this.rail = rail;
        this.meal = meal;
    }

    public int cooks() { return cooks; }
    public String rail() { return rail; }
    public MealType meal() { return meal; }

    @Override public String toString() {
        return "Kitchen[cooks=" + cooks + ", rail=" + rail + ", meal=" + meal + "]";
    }
}

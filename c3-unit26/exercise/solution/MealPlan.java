package com.tiffinbox.quality;

import com.tiffinbox.Customer;

import java.util.List;
import java.util.Map;

/**
 * Three real defects in twenty lines, and every one of them compiles.
 *
 * <p>None of these is a typo and none is a style opinion. Each is a thing the Java compiler
 * is required to accept and a thing that will page somebody at two in the morning.
 */
public final class MealPlan {

    /** The meal types the kitchen actually cooks, keyed exactly as the database stores them. */
    private static final Map<String, Integer> PORTION_GRAMS =
            Map.of("VEG", 450, "NON_VEG", 520, "VEGAN", 430);

    private MealPlan() {
    }

    /**
     * FIXED. `==` on strings compares identities; the literal and the value the database
     * hands back are two different objects the moment anything stops interning them.
     * "VEGAN".equals(...) also survives a null mealType, which `==` would too but
     * c.mealType().equals("VEGAN") would not - so the literal goes first on purpose.
     */
    public static boolean isVegan(Customer c) {
        return "VEGAN".equals(c.mealType());
    }

    /**
     * FIXED. Map.get returns null for a key that is not there, and returning it from a
     * method whose return type is int unboxes it. An unknown meal type is a real thing -
     * a new one added to the database before the code knows about it - so 0 is the
     * answer, and it is written down rather than thrown.
     */
    public static int portionGrams(String mealType) {
        Integer grams = PORTION_GRAMS.get(mealType);
        return grams == null ? 0 : grams;
    }

    /** The correct version of both, for the test to compare against. */
    public static int portionGramsSafely(String mealType) {
        Integer grams = PORTION_GRAMS.get(mealType);
        return grams == null ? 0 : grams;
    }

    public static int totalGrams(List<Customer> roster) {
        int total = 0;
        for (Customer c : roster) {
            total += portionGramsSafely(c.mealType()) * c.mealsPerDay();
        }
        return total;
    }
}

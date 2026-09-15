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
     * DEFECT 1 - reference equality on strings. `==` compares identities, not characters.
     * It works in a test where both strings are compile-time constants interned into the
     * same object, and stops working the moment one of them comes out of a database, a
     * JSON document or a HTTP parameter. Error Prone's [ReferenceEquality] finds it.
     */
    public static boolean isVegan(Customer c) {
        return c.mealType() == "VEGAN";
    }

    /**
     * DEFECT 2 - an unchecked map lookup. Map.get returns null for a key that is not
     * there, and the very next operation unboxes it. NullAway finds it; javac does not,
     * because unboxing a null Integer is legal code that throws at run time.
     */
    public static int portionGrams(String mealType) {
        Integer grams = PORTION_GRAMS.get(mealType);
        return grams;
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

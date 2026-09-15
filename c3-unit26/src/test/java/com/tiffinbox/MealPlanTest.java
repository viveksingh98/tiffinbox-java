package com.tiffinbox;

import com.tiffinbox.quality.MealPlan;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The test that passes while the code is broken, which is the whole reason static analysis
 * exists. Every assertion here is true. None of them touches the two defects.
 */
class MealPlanTest {

    @Test
    void theKnownMealTypesHaveAPortionSize() {
        assertThat(MealPlan.portionGramsSafely("VEG")).isEqualTo(450);
        assertThat(MealPlan.portionGramsSafely("NON_VEG")).isEqualTo(520);
        assertThat(MealPlan.portionGramsSafely("VEGAN")).isEqualTo(430);
    }

    @Test
    void aRosterAddsUp() throws Exception {
        var db = new Database("jdbc:h2:mem:unit26test;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        var roster = new CustomerRepository(db).findAll();
        assertThat(roster).hasSize(4);
        assertThat(MealPlan.totalGrams(roster)).isPositive();
    }

    /**
     * And here is the test that a reasonable person writes for isVegan, passing, against a
     * method that is wrong. Both strings here are compile-time constants, so `==` is true.
     */
    @Test
    void isVeganPassesForTheWrongReason() {
        assertThat(MealPlan.isVegan(new Customer("Priya", 1, 120, "VEGAN"))).isTrue();
    }
}

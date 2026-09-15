package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.sql.SQLException;
import java.util.List;
import org.assertj.core.api.SoftAssertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

/**
 * The AssertJ side of the unit, over the real seeded roster rather than a made-up list.
 * Every assertion here PASSES - the failure messages are in breaks/three-messages/, because
 * a failure message you cannot see is not evidence of anything.
 */
class RosterAssertionsTest {

    private static List<Customer> roster;

    @BeforeAll
    static void seed() throws SQLException {
        var db = new Database("jdbc:h2:mem:unit13roster;DB_CLOSE_DELAY=-1");
        db.createAndSeed();
        roster = new CustomerRepository(db).findAll();
    }

    /** extracting turns a list of records into a list of one field, and asserts on that. */
    @Test
    void theRosterHoldsExactlyTheFourSeededCustomers() {
        assertThat(roster)
                .hasSize(4)
                .extracting(Customer::name)
                .containsExactlyInAnyOrder("Ravi", "Meera", "Sunil", "Priya");
    }

    /** filteredOn narrows first, so the message names the narrowed list when it fails. */
    @Test
    void twoOfThemAreOnTheVegetarianPlan() {
        assertThat(roster)
                .filteredOn(c -> c.mealType().equals("VEG"))
                .extracting(Customer::name)
                .containsExactly("Ravi", "Sunil");
    }

    /**
     * usingRecursiveComparison walks the fields instead of calling equals, so when it fails
     * it can name the field. Here it passes.
     */
    @Test
    void oneCustomerMatchesFieldForField() {
        Customer ravi = roster.stream().filter(c -> c.name().equals("Ravi")).findFirst().orElseThrow();
        assertThat(ravi).usingRecursiveComparison()
                .isEqualTo(new Customer("Ravi", 2, 120, "VEG"));
    }

    /** Soft assertions run every check and report every failure. Here there are none. */
    @Test
    void everyCustomerBillsAtLeastTheMinimumPlan() {
        SoftAssertions softly = new SoftAssertions();
        roster.forEach(c -> softly.assertThat(c.monthlyBill())
                .as("%s monthly bill", c.name())
                .isGreaterThanOrEqualTo(3000));
        softly.assertAll();
    }

    /** The exception form: the thrown thing is the subject, and its message is assertable. */
    @Test
    void anEmptyRailRefusesToCookNothing() {
        assertThatThrownBy(() -> List.of(1, 2, 3).subList(2, 1))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("fromIndex(2) > toIndex(1)");
    }
}

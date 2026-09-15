package com.tiffinbox;

import com.tiffinbox.wiring.Wiring;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * The order in Wiring is not a style choice. Three of the five lines cannot move, and
 * nothing in the language or the build tool says so.
 */
class WiringOrderTest {

    @Test
    void theWiringAsWrittenWorks() throws Exception {
        assertThat(Wiring.startEverything())
                .contains("customers=4")
                .contains("cooked=");
    }

    /** Move the seed AFTER the first read, which still compiles, and here is what happens. */
    @Test
    void readingBeforeTheDatabaseIsSeededFails() {
        var db = new Database("jdbc:h2:mem:unseeded;DB_CLOSE_DELAY=-1");
        var repo = new CustomerRepository(db);
        assertThatThrownBy(repo::findAll)
                .isInstanceOf(Exception.class);
    }

    /** Read the counters before close() and the answer is a race, not a number. */
    @Test
    void theRailMustBeClosedBeforeItsCountersMeanAnything() throws Exception {
        var kitchen = new OrderQueue(1);
        kitchen.place(new OrderQueue.Order("Meera", 100));
        int beforeClose = kitchen.cooked();
        kitchen.close();
        int afterClose = kitchen.cooked();

        assertThat(afterClose).isEqualTo(1);
        assertThat(beforeClose).isBetween(0, 1);
    }
}

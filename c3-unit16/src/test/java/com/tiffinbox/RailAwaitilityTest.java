package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;

import java.time.Duration;
import org.junit.jupiter.api.Test;

/**
 * The same rail, the same twenty thousand orders, no sleep. Awaitility polls a condition
 * until it is true or a deadline passes - so the test waits exactly as long as the machine
 * needs and no longer, and a slow machine makes it slower rather than red.
 */
class RailAwaitilityTest {

    static final int ORDERS = 20_000;

    @Test
    void everyOrderIsCooked() throws Exception {
        OrderQueue q = new OrderQueue(4);
        for (int i = 0; i < ORDERS; i++) {
            q.place(new OrderQueue.Order("customer-" + i, 100));
        }

        await("every order cooked")
            .atMost(Duration.ofSeconds(5))
            .pollInterval(Duration.ofMillis(2))
            .until(() -> q.cooked() == ORDERS);

        assertThat(q.cooked()).isEqualTo(ORDERS);
        q.close();
    }
}

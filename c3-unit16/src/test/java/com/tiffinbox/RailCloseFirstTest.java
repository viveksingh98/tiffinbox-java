package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/**
 * The cheapest fix of the three, and the one to reach for first: this class already has a
 * barrier. close() puts one poison pill per cook on the rail and blocks until every cook has
 * taken one - so when close() returns, there is nothing left to wait for. No library, no
 * deadline, no polling.
 */
class RailCloseFirstTest {

    static final int ORDERS = 20_000;

    @Test
    void everyOrderIsCooked() throws Exception {
        OrderQueue q = new OrderQueue(4);
        for (int i = 0; i < ORDERS; i++) {
            q.place(new OrderQueue.Order("customer-" + i, 100));
        }

        q.close();                                   // the barrier that was there all along

        assertThat(q.cooked()).isEqualTo(ORDERS);
        assertThat(q.cookedValue()).isEqualTo(ORDERS * 100);
    }
}

package com.tiffinbox;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/**
 * Twenty thousand orders onto the rail, four cooks taking them off it, and one millisecond
 * of sleep in between. The sleep is a guess about how fast this machine is. Run it once and
 * you will not learn anything; run it twelve times and you will.
 */
class RailSleepTest {

    /** -Dorders=2000 to shorten the queue. The default is the length this unit ships. */
    static final int ORDERS = Integer.getInteger("orders", 20_000);

    @Test
    void everyOrderIsCooked() throws Exception {
        OrderQueue q = new OrderQueue(4);
        for (int i = 0; i < ORDERS; i++) {
            q.place(new OrderQueue.Order("customer-" + i, 100));
        }

        Thread.sleep(1);                             // "that should be enough"

        assertThat(q.cooked()).isEqualTo(ORDERS);
        q.close();
    }
}

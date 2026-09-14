package com.tiffinbox;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DeliverySlotTest {

    @Test
    void slotSerialisesToJson() throws Exception {
        assertEquals("{\"route\":\"North Loop\",\"stops\":14}",
                DeliverySlot.asJson(new DeliverySlot.Slot("North Loop", 14)));
    }
}

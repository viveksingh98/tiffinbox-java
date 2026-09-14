package com.tiffinbox;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.Generated;

/**
 * One dependency per scope, and each scope is visible in this file:
 *   compile  — jackson-databind, imported above and used below
 *   provided — jakarta.annotation, imported above and gone by run time (SOURCE retention)
 *   runtime  — h2, never imported: it is looked up by name
 *   test     — junit-jupiter, only in src/test
 */
@Generated(value = "TiffinBox route planner", date = "2026-09-14")
public final class DeliverySlot {

    public record Slot(String route, int stops) { }

    public static String asJson(Slot slot) throws Exception {
        return new ObjectMapper().writeValueAsString(slot);
    }

    public static void main(String[] args) throws Exception {
        System.out.println(asJson(new Slot("North Loop", 14)));
        System.out.println("driver        : " + Class.forName("org.h2.Driver").getName());
    }
}

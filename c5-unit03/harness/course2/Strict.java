package com.tiffinbox;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.cfg.PackageVersion;

/**
 * Course 2's "field nobody told you about" (c2-unit29 JsonOops: the same JSON, the same Customer), read by a mapper
 * built the way Course 2 built it: new ObjectMapper(), nothing configured. receipts.sh compiles this file twice — as
 * written, against Jackson 2, and with only the package names moved, against Jackson 3 — and prints what each did.
 */
public final class Strict {

    static final String FROM_MOBILE = """
            { "name": "Ravi", "mealsPerDay": 2, "pricePerMeal": 120, "veg": true, "loyaltyPoints": 40 }
            """;

    public static void main(String[] args) {
        ObjectMapper mapper = new ObjectMapper();
        String outcome;
        try {
            Customer c = mapper.readValue(FROM_MOBILE, Customer.class);
            outcome = "read " + c.name() + " -> " + c.monthlyBill();
        } catch (Exception e) {
            outcome = e.getClass().getSimpleName();
        }
        System.out.println("Jackson " + PackageVersion.VERSION + "  new ObjectMapper(): FAIL_ON_UNKNOWN_PROPERTIES "
                + mapper.isEnabled(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES) + "  an unknown field -> " + outcome);
    }
}

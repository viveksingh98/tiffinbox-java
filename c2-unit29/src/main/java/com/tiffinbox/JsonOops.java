package com.tiffinbox;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException;

import java.util.TreeSet;

/** The field nobody told you about: strict mapper vs lenient mapper. */
public final class JsonOops {

    static final String FROM_MOBILE = """
            { "name": "Ravi", "mealsPerDay": 2, "pricePerMeal": 120, "veg": true, "loyaltyPoints": 40 }
            """;

    public static void main(String[] args) throws Exception {
        System.out.println("strict mapper (the default) ...");
        try {
            new ObjectMapper().readValue(FROM_MOBILE, Customer.class);
        } catch (UnrecognizedPropertyException e) {
            System.out.println("  " + e.getClass().getName());
            System.out.println("  " + e.getOriginalMessage());
            var known = new TreeSet<String>();
            e.getKnownPropertyIds().forEach(id -> known.add(id.toString()));
            System.out.println("  known: " + known);
            System.out.println("  path:  " + e.getPathReference());
        }

        ObjectMapper lenient = new ObjectMapper()
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        Customer c = lenient.readValue(FROM_MOBILE, Customer.class);
        System.out.println("lenient mapper: " + c.name() + " -> " + c.monthlyBill());
    }
}

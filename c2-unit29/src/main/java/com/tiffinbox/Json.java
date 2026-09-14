package com.tiffinbox;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.List;

/** Records in, JSON out, JSON in, records back. One shared ObjectMapper. */
public final class Json {

    // Thread-safe once configured, expensive to build: one per application, not one per call.
    static final ObjectMapper MAPPER = new ObjectMapper();

    static final String BOOK = """
            [
              { "name": "Ravi",  "mealsPerDay": 2, "pricePerMeal": 120, "veg": true  },
              { "name": "Meera", "mealsPerDay": 1, "pricePerMeal": 150, "veg": true  },
              { "name": "Sunil", "mealsPerDay": 3, "pricePerMeal": 100, "veg": false },
              { "name": "Priya", "mealsPerDay": 1, "pricePerMeal": 120, "veg": true  }
            ]
            """;

    public static void main(String[] args) throws Exception {
        var ravi = new Customer("Ravi", 2, 120, true);

        String one = MAPPER.writeValueAsString(ravi);
        System.out.println("write:  " + one);
        System.out.println("pretty: " + MAPPER.writerWithDefaultPrettyPrinter().writeValueAsString(ravi));

        Customer back = MAPPER.readValue(one, Customer.class);
        System.out.println("read:   " + back.name() + " -> " + back.monthlyBill());

        List<Customer> customers = MAPPER.readValue(BOOK, new TypeReference<List<Customer>>() { });
        int total = 0;
        for (Customer c : customers) {
            System.out.println("  " + c.name() + " " + c.mealType() + " -> " + c.monthlyBill());
            total += c.monthlyBill();
        }
        System.out.println("month total: " + total);

        List<?> raw = MAPPER.readValue(BOOK, List.class);
        System.out.println("List.class gives you: " + raw.get(0).getClass().getName());
    }
}

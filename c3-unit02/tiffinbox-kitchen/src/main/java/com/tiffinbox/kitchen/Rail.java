package com.tiffinbox.kitchen;

import com.tiffinbox.core.Customer;
import java.util.List;

/** The kitchen rail: it turns customers into trays. It needs Core; Core does not need it. */
public final class Rail {

    private Rail() {
    }

    public static List<String> trays(List<Customer> customers) {
        return customers.stream()
                .map(c -> "%-6s %-8s %4d".formatted(c.name(), c.mealType(), c.dailyCost()))
                .toList();
    }

    public static int totalDaily(List<Customer> customers) {
        return customers.stream().mapToInt(Customer::dailyCost).sum();
    }
}

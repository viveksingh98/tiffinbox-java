package com.tiffinbox.aot;

import com.tiffinbox.Customer;

import java.util.List;

/** One line per customer. Nothing imports this class; it is reached only through its name. */
public final class PlainFormatter implements Formatter {
    @Override
    public String render(List<Customer> roster) {
        var sb = new StringBuilder();
        for (Customer c : roster) {
            sb.append(c.name()).append(" x").append(c.mealsPerDay()).append('\n');
        }
        return sb.toString();
    }
}

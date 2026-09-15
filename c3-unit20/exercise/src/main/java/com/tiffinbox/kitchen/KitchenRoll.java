package com.tiffinbox.kitchen;

import com.tiffinbox.Customer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * Enough lines to make a 1KB file roll, and nothing more.
 *
 * <p>The count is an argument rather than a constant so the receipt can say how many lines
 * it asked for beside how many files it found. Every line is the same width, so the roll
 * points are a property of the configuration rather than of the data.
 */
public final class KitchenRoll {

    private static final Logger log = LoggerFactory.getLogger("kitchen");

    private static final List<Customer> ROSTER = List.of(
            new Customer("Arun", 2, 120, "VEG"),
            new Customer("Bela", 1, 200, "VEGAN"),
            new Customer("Chandran", 3, 150, "NON_VEG"));

    public static void main(String[] args) {
        int lines = args.length > 0 ? Integer.parseInt(args[0]) : 60;
        for (int i = 0; i < lines; i++) {
            Customer c = ROSTER.get(i % ROSTER.size());
            log.info("slip {} cooked for {} at {} rupees", String.format("%04d", i), c.name(), c.monthlyBill());
        }
        log.info("wrote {} slip line(s)", lines);
    }
}

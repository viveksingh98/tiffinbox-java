package com.tiffinbox;

/**
 * The loyalty tier a customer's monthly bill earns.
 *
 * <p>The rule the kitchen agreed, in writing:
 * <ul>
 *   <li>10000 rupees and above: GOLD</li>
 *   <li>6000 rupees and above: SILVER</li>
 *   <li>anything below that: BRONZE</li>
 * </ul>
 */
public final class Pricing {

    private Pricing() {
    }

    public static String tier(Customer customer) {
        int bill = customer.monthlyBill();
        if (bill >= 10_000) {
            return "GOLD";
        }
        if (bill > 6_000) {
            return "SILVER";
        }
        return "BRONZE";
    }
}

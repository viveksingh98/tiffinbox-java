package com.tiffinbox.billing;

import com.tiffinbox.Customer;
import java.util.List;

/**
 * And this is the fix the failing test asks for: monthlyBill(), not pricePerMeal(). Copy this
 * over src/main/java/com/tiffinbox/billing/BillingService.java once you have SEEN the failure -
 * seeing it is the exercise.
 */
public final class BillingService {

    public record Receipt(String customer, int charged, String reference) {}

    private final PaymentGateway gateway;

    public BillingService(PaymentGateway gateway) {
        this.gateway = gateway;
    }

    public Receipt chargeMonthly(Customer c) {
        String reference = gateway.charge(c.name(), c.monthlyBill());
        return new Receipt(c.name(), c.monthlyBill(), reference);
    }

    public int monthlyTotal(List<Customer> roster) {
        return roster.stream().mapToInt(Customer::monthlyBill).sum();
    }
}

package com.tiffinbox.billing;

import com.tiffinbox.Customer;
import java.util.List;

/** The thing under test. It owns one decision: what to charge, and when not to charge at all. */
public final class BillingService {

    public record Receipt(String customer, int charged, String reference) {}

    private final PaymentGateway gateway;

    public BillingService(PaymentGateway gateway) {
        this.gateway = gateway;
    }

    /** Charges one customer for the month and hands back what the gateway said. */
    public Receipt chargeMonthly(Customer c) {
        String reference = gateway.charge(c.name(), c.monthlyBill());
        return new Receipt(c.name(), c.monthlyBill(), reference);
    }

    /** A sum, and nothing else. This method must never reach the gateway - a dummy proves it. */
    public int monthlyTotal(List<Customer> roster) {
        return roster.stream().mapToInt(Customer::monthlyBill).sum();
    }
}

package com.tiffinbox;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class BillingServiceTest {

    private final List<Customer> customers = List.of(
            new Customer("Ravi", 2, 120, true),
            new Customer("Meera", 1, 150, false),
            new Customer("Sunil", 1, 120, true));

    private final BillingService billing = new BillingService();

    @Test
    void totalRevenueAddsEveryBill() {
        assertEquals(15300, billing.totalRevenue(customers));
    }

    @Test
    void countsVegCustomers() {
        assertEquals(2, billing.vegCount(customers));
    }

    @Test
    void sortsBiggestBillFirst() {
        var names = billing.sortedByBill(customers).stream().map(Customer::name).toList();
        assertEquals(List.of("Ravi", "Meera", "Sunil"), names);
    }

    @Test
    void pauseOfSevenDaysBillsTwentyThree() {
        billing.addPause(new Pause("Ravi", LocalDate.of(2026, 9, 14), LocalDate.of(2026, 9, 20)));
        assertEquals(5520, billing.bill(customers.getFirst()));
        assertEquals(13620, billing.totalRevenue(customers));
    }

    @Test
    void describesEveryPaymentType() {
        assertEquals("cash at the door", billing.describe(new Payment.Cash()));
        assertEquals("UPI to ravi@okbank", billing.describe(new Payment.Upi("ravi@okbank")));
        assertEquals("card ending 4421", billing.describe(new Payment.Card("4421")));
    }
}

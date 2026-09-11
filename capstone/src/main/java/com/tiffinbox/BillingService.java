package com.tiffinbox;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

public class BillingService {

    private static final List<Payment> ACCEPTED = List.of(new Payment.Cash(), new Payment.Upi("asha@okbank"));

    private final List<Pause> pauses = new ArrayList<>();

    public void addPause(Pause pause) {
        pauses.add(pause);
    }

    public int pausedDays(Customer customer) {
        return pauses.stream()
                .filter(p -> p.customer().equalsIgnoreCase(customer.name()))
                .mapToInt(Pause::days)
                .sum();
    }

    public int bill(Customer customer) {
        return customer.billFor(Customer.DAYS_IN_MONTH - pausedDays(customer));
    }

    public int totalRevenue(List<Customer> customers) {
        return customers.stream().mapToInt(this::bill).sum();
    }

    public long vegCount(List<Customer> customers) {
        return customers.stream().filter(Customer::isVeg).count();
    }

    public List<Customer> sortedByBill(List<Customer> customers) {
        return customers.stream()
                .sorted(Comparator.comparingInt(this::bill).reversed())
                .toList();
    }

    public Map<MealType, Integer> revenueByType(List<Customer> customers) {
        return customers.stream()
                .collect(Collectors.groupingBy(Customer::mealType, TreeMap::new, Collectors.summingInt(this::bill)));
    }

    public String describe(Payment payment) {
        return switch (payment) {
            case Payment.Cash c -> "cash at the door";
            case Payment.Upi(String vpa) -> "UPI to " + vpa;
            case Payment.Card(String last4) -> "card ending " + last4;
        };
    }

    public String paymentOptions() {
        return ACCEPTED.stream().map(this::describe).collect(Collectors.joining(" or "));
    }
}
